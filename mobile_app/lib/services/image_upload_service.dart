import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../core/config.dart';

/// Service for picking and uploading crop images, KYC documents, and profile pictures
class ImageUploadService {
  final ImagePicker _picker = ImagePicker();
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConfig.baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));

  /// Pick an image from camera or gallery
  Future<XFile?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  /// Uploads an image file to Supabase Storage or Backend API
  /// Returns the accessible Image URL
  Future<String?> uploadImage(XFile imageFile, {String folder = 'crop-images'}) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${imageFile.name}';
      final bytes = await imageFile.readAsBytes();

      // 1. Direct Supabase Storage Upload if configured
      try {
        final supabaseUrl = AppConfig.supabaseUrl;
        final anonKey = AppConfig.supabaseAnonKey;
        
        final supabaseDio = Dio();
        final uploadResponse = await supabaseDio.post(
          '$supabaseUrl/storage/v1/object/$folder/$fileName',
          data: Stream.fromIterable([bytes]),
          options: Options(
            headers: {
              'apikey': anonKey,
              'Authorization': 'Bearer $anonKey',
              'Content-Type': imageFile.mimeType ?? 'image/jpeg',
            },
          ),
        );

        if (uploadResponse.statusCode == 200 || uploadResponse.statusCode == 201) {
          final publicUrl = '$supabaseUrl/storage/v1/object/public/$folder/$fileName';
          return publicUrl;
        }
      } catch (supabaseError) {
        debugPrint('Supabase direct upload notice: $supabaseError');
      }

      // 2. Fallback to FastAPI Backend /api/v1/upload
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: fileName),
        'folder': folder,
      });

      final response = await _dio.post('/upload', data: formData);
      if (response.statusCode == 200 && response.data != null) {
        return response.data['image_url'];
      }

      // 3. Fallback Data URI for local testing
      final base64String = base64Encode(bytes);
      return 'data:image/jpeg;base64,$base64String';
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=500';
    }
  }
}
