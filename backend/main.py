import os
import cv2
import torch
import numpy as np
import logging
import io
from fastapi import FastAPI, UploadFile, File, Form, HTTPException
from fastapi.responses import StreamingResponse
from starlette.formparsers import MultiPartParser
from basicsr.archs.rrdbnet_arch import RRDBNet
from realesrgan import RealESRGANer
from gfpgan import GFPGANer

# Menambah batas ukuran file unggahan
MultiPartParser.max_file_size = 200 * 1024 * 1024 

# --- (Bagian Konfigurasi dan Pemuatan Model tidak ada perubahan) ---
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)
app = FastAPI(title="Optimized Real-ESRGAN API")
DEVICE_ID = 0
HALF_PRECISION = True if DEVICE_ID != -1 else False
try:
    model_path = os.path.join('realesrgan', 'weights', 'RealESRGAN_x4plus.pth')
    model = RRDBNet(num_in_ch=3, num_out_ch=3, num_feat=64, num_block=23, num_grow_ch=32, scale=4)
    face_enhance_model_path = os.path.join('gfpgan', 'weights', 'GFPGANv1.3.pth')
    bg_sampler = RealESRGANer(
        scale=4, model_path=model_path, dni_weight=None, model=model,
        tile=400, tile_pad=10, pre_pad=0, half=HALF_PRECISION, gpu_id=DEVICE_ID
    )
    face_enhancer = GFPGANer(
        model_path=face_enhance_model_path, upscale=4, arch='clean',
        channel_multiplier=2, bg_upsampler=bg_sampler
    )
    logger.info(f"Semua model berhasil dimuat. Menggunakan perangkat: {'GPU' if DEVICE_ID != -1 else 'CPU'}")
except Exception as e:
    logger.error(f"Gagal memuat model saat startup: {e}", exc_info=True)
    face_enhancer = None
    logger.info("Server berjalan tanpa model AI. Endpoint /upscale akan gagal.")

def resize_image_array(image_array, target_width=None, target_height=None):
    """Resize numpy array gambar ke target_width ATAU target_height dengan menjaga aspek rasio."""
    try:
        h, w, _ = image_array.shape
        if w == 0 or h == 0: return image_array

        if target_width:
            if w == target_width: return image_array
            scale_factor = target_width / w
            new_w, new_h = target_width, int(h * scale_factor)
        elif target_height:
            if h == target_height: return image_array
            scale_factor = target_height / h
            new_h, new_w = target_height, int(w * scale_factor)
        else:
            return image_array

        logger.info(f"Melakukan resize dari {w}x{h} ke {new_w}x{new_h}")
        interpolation = cv2.INTER_AREA if new_w < w else cv2.INTER_LANCZOS4
        resized_img = cv2.resize(image_array, (new_w, new_h), interpolation=interpolation)
        return resized_img
    except Exception as e:
        logger.error(f"Error saat resize gambar: {e}")
        return image_array

@app.get("/", summary="Health Check")
def read_root():
    return {"status": "ok", "message": "Optimized Real-ESRGAN API is running"}


@app.post("/upscale", summary="Upscale an Image")
async def upscale_image(
    scale_option: str = Form("4x"),
    format: str = Form("AUTO"),
    use_face_enhance: bool = Form(True),
    image: UploadFile = File(...),
):
    if face_enhancer is None:
        raise HTTPException(status_code=500, detail="Model AI tidak berhasil dimuat.")
    try:
        logger.info(f"Menerima request untuk: {image.filename} dengan face_enhance={use_face_enhance} dan scale={scale_option}")
        
        image_bytes = await image.read()
        img_np = np.frombuffer(image_bytes, np.uint8)
        img = cv2.imdecode(img_np, cv2.IMREAD_COLOR)

        if img is None: raise HTTPException(status_code=400, detail="Gagal membaca file gambar.")
        
        original_height, original_width, _ = img.shape
        
        scale_map = {'2x': 2, '4x': 4, '6x': 6}
        outscale_factor = scale_map.get(scale_option, 4)

        logger.info(f"Memulai proses upscale dengan outscale_factor: {outscale_factor}")
        
        # Logika upscale dasar tetap sama, selalu ke 4x terlebih dahulu
        if use_face_enhance:
            _, _, upscaled_4x_image = face_enhancer.enhance(img, has_aligned=False, only_center_face=False, paste_back=True)
        else:
            upscaled_4x_image, _ = bg_sampler.enhance(img, outscale=outscale_factor)
        logger.info("Proses upscale dasar selesai.")

        final_output = upscaled_4x_image
        
        # ===================================================================
        # LOGIKA RESIZE DIPERBARUI UNTUK SEMUA SKALA
        # ===================================================================
        is_portrait = original_height > original_width
        
        if scale_option.lower() == '2k':
            target_dim = 2048
            if is_portrait:
                final_output = resize_image_array(upscaled_4x_image, target_height=target_dim)
            else:
                final_output = resize_image_array(upscaled_4x_image, target_width=target_dim)
        elif scale_option.lower() == '4k':
            target_dim = 3840
            if is_portrait:
                final_output = resize_image_array(upscaled_4x_image, target_height=target_dim)
            else:
                final_output = resize_image_array(upscaled_4x_image, target_width=target_dim)
        elif scale_option.lower() == '2x':
            if is_portrait:
                final_output = resize_image_array(upscaled_4x_image, target_height=original_height * 2)
            else:
                 final_output = resize_image_array(upscaled_4x_image, target_width=original_width * 2)
        elif scale_option.lower() == '6x':
            if is_portrait:
                final_output = resize_image_array(upscaled_4x_image, target_height=original_height * 6)
            else:
                final_output = resize_image_array(upscaled_4x_image, target_width=original_width * 6)
        
        target_format = format.upper()
        if target_format == 'AUTO':
            original_extension = os.path.splitext(image.filename)[1][1:].upper()
            target_format = 'JPG' if original_extension in ['JPG', 'JPEG'] else 'PNG'
            logger.info(f"Format AUTO dipilih, output akan menjadi {target_format}")
        
        if scale_option.lower() == '4k' and target_format == 'PNG':
            logger.warning("Target 4K PNG sangat berat. Mengalihkan ke format JPG untuk stabilitas.")
            target_format = 'JPG'

        if target_format == 'PNG':
            file_extension = '.png'; encode_param = [cv2.IMWRITE_PNG_COMPRESSION, 3]; media_type = "image/png"
        else: # JPG
            file_extension = '.jpg'; encode_param = [cv2.IMWRITE_JPEG_QUALITY, 95]; media_type = "image/jpeg"

        output_filename = f"{os.path.splitext(image.filename)[0]}_out{file_extension}"
        
        is_success, buffer = cv2.imencode(file_extension, final_output, encode_param)
        if not is_success:
            raise HTTPException(status_code=500, detail="Gagal melakukan encode gambar hasil.")
            
        return StreamingResponse(io.BytesIO(buffer), media_type=media_type, headers={'Content-Disposition': f'attachment; filename="{output_filename}"'})

    except Exception as e:
        logger.error(f"Terjadi error saat upscale: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"Terjadi kesalahan internal: {str(e)}")