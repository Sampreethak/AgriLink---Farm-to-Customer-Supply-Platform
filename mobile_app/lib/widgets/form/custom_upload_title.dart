import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/colors.dart';
import '../../services/image_upload_service.dart';

class CustomUploadTile extends StatefulWidget {
  final String title;
  final IconData icon;
  final String? initialImageUrl;
  final ValueChanged<String>? onImageUploaded;

  const CustomUploadTile({
    super.key,
    required this.title,
    required this.icon,
    this.initialImageUrl,
    this.onImageUploaded,
  });

  @override
  State<CustomUploadTile> createState() => _CustomUploadTileState();
}

class _CustomUploadTileState extends State<CustomUploadTile> {
  final ImageUploadService _uploadService = ImageUploadService();
  String? _previewUrl;
  XFile? _localFile;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _previewUrl = widget.initialImageUrl;
  }

  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.primaryGreen),
                title: const Text('Take Photo (Camera)'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndUpload(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.primaryGreen),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndUpload(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndUpload(ImageSource source) async {
    final file = await _uploadService.pickImage(source: source);
    if (file == null) return;

    setState(() {
      _localFile = file;
      _isUploading = true;
    });

    final uploadedUrl = await _uploadService.uploadImage(file);

    if (mounted) {
      setState(() {
        _previewUrl = uploadedUrl ?? file.path;
        _isUploading = false;
      });

      if (uploadedUrl != null && widget.onImageUploaded != null) {
        widget.onImageUploaded!(uploadedUrl);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image uploaded successfully!'),
          backgroundColor: AppColors.primaryGreen,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _isUploading ? null : _showImageSourcePicker,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
                ),
                child: _isUploading
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : _previewUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(9),
                            child: _previewUrl!.startsWith('http')
                                ? Image.network(_previewUrl!, fit: BoxFit.cover)
                                : kIsWeb
                                    ? Image.network(_previewUrl!, fit: BoxFit.cover)
                                    : Image.file(File(_localFile?.path ?? _previewUrl!), fit: BoxFit.cover),
                          )
                        : Icon(widget.icon, color: AppColors.primaryGreen, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _previewUrl != null ? 'Image attached (Tap to change)' : 'Tap to take photo or upload from gallery',
                      style: TextStyle(
                        fontSize: 12,
                        color: _previewUrl != null ? AppColors.primaryGreen : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                _previewUrl != null ? Icons.check_circle : Icons.upload_file,
                color: _previewUrl != null ? AppColors.primaryGreen : Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}