import 'package:flutter/material.dart';
import '../../core/colors.dart';

class QaTrackingScreen extends StatelessWidget {
  const QaTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("QA & Batch Clearance"),
        backgroundColor: AppColors.primaryGreen,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Quality Assurance & Certification",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Hospital-grade food safety audits. Check temperatures, batch lab clearance reports, and source tracking.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Active Batch: BATCH-QA-882",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            "CLEARED",
                            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        )
                      ],
                    ),
                    const Divider(height: 25),
                    _qaMetric(Icons.thermostat, "Cold Chain Temp Log", "3.4 °C (Required < 5°C)", Colors.blue),
                    _qaMetric(Icons.check_circle_outline, "Pesticide Residue Test", "0.0% Detected (Pass)", Colors.green),
                    _qaMetric(Icons.gavel, "Government Food Standard", "FSSAI Grade A Cleared", Colors.purple),
                    _qaMetric(Icons.person, "Inspecting Officer", "Dr. A. K. Shastri (Ph.D. Agronomy)", Colors.orange),
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.file_download),
                      label: const Text("Download Lab Audit Report (PDF)"),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Lab clearance certificate download initiated...")),
                        );
                      },
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              "QA History Logs",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _pastQaLog("BATCH-QA-874", "Apple Red (Organic)", "Cleared", "2026-06-20"),
            _pastQaLog("BATCH-QA-861", "Fresh Potato Bulk", "Cleared", "2026-06-18"),
            _pastQaLog("BATCH-QA-859", "Tomato Grade A", "Flagged & Rectified", "2026-06-15", isFlagged: true),
          ],
        ),
      ),
    );
  }

  Widget _qaMetric(IconData icon, String title, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.1),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(value, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _pastQaLog(String id, String item, String result, String date, {bool isFlagged = false}) {
    return Card(
      child: ListTile(
        leading: Icon(
          isFlagged ? Icons.warning : Icons.verified_user,
          color: isFlagged ? Colors.orange : Colors.green,
        ),
        title: Text("$item ($id)"),
        subtitle: Text("Date: $date"),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isFlagged ? Colors.orange.shade50 : Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            result,
            style: TextStyle(
              color: isFlagged ? Colors.orange : Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
