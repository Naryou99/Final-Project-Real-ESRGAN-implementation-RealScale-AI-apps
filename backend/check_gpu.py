import torch

print(f"Versi PyTorch yang terinstal: {torch.__version__}")
print("-" * 30)

is_cuda_available = torch.cuda.is_available()
print(f"Apakah CUDA (GPU NVIDIA) terdeteksi? -> {is_cuda_available}")

if is_cuda_available:
    print(f"Nama GPU: {torch.cuda.get_device_name(0)}")
    print("\n>>> STATUS: SANGAT BAIK! PyTorch Anda sudah benar dan siap untuk GPU.")
else:
    print("\n>>> STATUS: MASALAH DITEMUKAN. PyTorch Anda adalah versi CPU-only.")
    print(">>> SOLUSI: Anda harus menginstal ulang PyTorch dengan versi CUDA seperti pada langkah berikutnya.")