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

    if (kIsWeb) {
      openUrlOnWeb(downloadUrl);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Downloading AgriLink Tri-Service Ecosystem Report...'),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
      }
      return;
    }

    // Mobile fallback: fetch live JSON summary and display it
    try {
      final res = await Dio(BaseOptions(connectTimeout: const Duration(seconds: 6)))
          .get('${AppConfig.baseUrl}/ecosystem/report$query');
      if (!context.mounted) return;
      final data = res.data is Map ? res.data as Map : {};
      final health = (data['services_health'] as Map?) ?? {};
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Tri-Service Live Report'),
          content: SingleChildScrollView(
            child: Text(
              'M1 AgriLink: ${health['agrilink_m1']?['status'] ?? 'UNKNOWN'}\n'
              'M2 Citizen: ${health['citizen_m2']?['status'] ?? 'UNKNOWN'}\n'
              'M3 RTO Vehicle: ${health['rto_vehicle_m3']?['status'] ?? 'UNKNOWN'}\n\n'
              'Download URL:\n$downloadUrl',
            ),
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
