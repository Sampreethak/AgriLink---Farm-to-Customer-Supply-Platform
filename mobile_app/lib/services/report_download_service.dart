import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../core/config.dart';
import 'web_auth_redirect.dart';

class ReportDownloadService {
  static Future<void> downloadTriServiceReport(
    BuildContext context, {
    String? citizenId,
  }) async {
    final query = (citizenId != null && citizenId.isNotEmpty)
        ? '?citizen_id=${Uri.encodeComponent(citizenId)}'
        : '';
    final downloadUrl = '${AppConfig.baseUrl}/ecosystem/report/download$query';
    await _triggerDownload(context, downloadUrl, '${AppConfig.baseUrl}/ecosystem/report$query');
  }

  static Future<void> downloadUserReport(
    BuildContext context, {
    required String userIdentifier,
  }) async {
    final encoded = Uri.encodeComponent(userIdentifier.trim());
    final downloadUrl = '${AppConfig.baseUrl}/ecosystem/users/$encoded/report/download';
    final jsonUrl = '${AppConfig.baseUrl}/ecosystem/users/$encoded/report';
    await _triggerDownload(context, downloadUrl, jsonUrl);
  }

  static Future<void> _triggerDownload(
    BuildContext context,
    String downloadUrl,
    String jsonUrl,
  ) async {
    if (kIsWeb) {
      openUrlOnWeb(downloadUrl);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Downloading Tri-Service Report...'),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
      }
      return;
    }

    // Mobile fallback: fetch live JSON summary and display it
    try {
      final res = await Dio(BaseOptions(connectTimeout: const Duration(seconds: 6)))
          .get(jsonUrl);
      if (!context.mounted) return;
      final data = res.data is Map ? res.data as Map : {};
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(data['report_title']?.toString() ?? 'Tri-Service Live Report'),
          content: SingleChildScrollView(
            child: Text('Report ready.\n\nDownload URL:\n$downloadUrl'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          ],
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not fetch report: $e')),
        );
      }
    }
  }
}
