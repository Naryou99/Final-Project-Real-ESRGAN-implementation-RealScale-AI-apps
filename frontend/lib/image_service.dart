import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ImageService {
  final String _apiUrl = "https://pggd965z-8000.asse.devtunnels.ms/upscale"; 
  
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  Future<Map<String, int>> getImageDimensions(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final decodedImage = await _decodeImage(bytes); 
    return decodedImage;
  }

  Future<Map<String, int>> _decodeImage(Uint8List imageBytes) async {
    final image = await decodeImageFromList(imageBytes);
    return {'width': image.width, 'height': image.height};
  }

  Future<File?> upscaleImage({
    required File imageFile,
    required String scaleOption,
    required String format,
    required bool useFaceEnhance, 
  }) async {
    try {
      var uri = Uri.parse(_apiUrl);
      var request = http.MultipartRequest("POST", uri);

      request.fields['scale_option'] = scaleOption;
      request.fields['format'] = format;
      request.fields['use_face_enhance'] = useFaceEnhance.toString();

      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

      var streamedResponse = await request.send().timeout(const Duration(minutes: 10));
      
      if (streamedResponse.statusCode == 200) {
        final bytes = await streamedResponse.stream.toBytes();
        final tempDir = await getTemporaryDirectory();
        
        String originalFileName = imageFile.path.split('/').last;
        String baseName = originalFileName.contains('.') ? originalFileName.substring(0, originalFileName.lastIndexOf('.')) : originalFileName;
        String originalExtension = originalFileName.contains('.') ? originalFileName.split('.').last : '';

        String finalExtension;
        if (format.toUpperCase() == 'AUTO') {
          finalExtension = originalExtension;
        } else {
          finalExtension = format;
        }
        
        final fileName = '${baseName}_temp.${finalExtension.toLowerCase()}';
        final file = File('${tempDir.path}/$fileName');
        
        await file.writeAsBytes(bytes);
        return file;
        
      } else {
        final responseBody = await streamedResponse.stream.bytesToString();
        debugPrint("Error dari server (status ${streamedResponse.statusCode}): $responseBody");
        throw Exception('Gagal upscale: ${streamedResponse.reasonPhrase}');
      }
    } catch (e) {
      debugPrint("Error di upscaleImage: $e");
      rethrow;
    }
  }

  // ===================================================================
  // PERUBAHAN: Menambahkan parameter useFaceEnhance dan logika penamaan file
  // ===================================================================
  Future<bool> saveImageToCustomPath(File imageFile, String directoryPath, String originalName, String scale, String format, bool useFaceEnhance) async {
    try {
      // Mengambil nama dasar file tanpa ekstensi
      String baseName = originalName.contains('.') ? originalName.substring(0, originalName.lastIndexOf('.')) : originalName;
      
      // Menambahkan tag _faceenhance jika fiturnya aktif
      String faceEnhanceTag = useFaceEnhance ? "_faceenhanced" : "";
      
      // Membuat nama file baru yang deskriptif
      // Contoh: foto_asli_upscaled_2x_faceenhanced.png
      String finalFileName = '${baseName}_upscaled_${scale}${faceEnhanceTag}.${format.toLowerCase()}';
      
      final newPath = '$directoryPath/$finalFileName';
      
      await imageFile.copy(newPath);
      return true;
    } catch (e) {
      debugPrint("Error saat menyimpan gambar: $e");
      return false;
    }
  }
}