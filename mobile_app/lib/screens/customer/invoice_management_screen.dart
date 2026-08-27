import 'package:flutter/material.dart';
import '../../core/colors.dart';

class InvoiceManagementScreen extends StatelessWidget {
  const InvoiceManagementScreen({super.key});

  final List<Map<String, String>> invoices = const [
    {
      "id": "INV-2026-004",
      "date": "2026-06-20",
      "amount": "₹34,800.00",
      "dept": "Consolidated (General + ICU + Staff)",
      "status": "Unpaid"
    },
    {
      "id": "INV-2026-003",
      "date": "2026-06-15",
      "amount": "₹12,450.00",
      "dept": "General Kitchen",
      "status": "Paid"
    },
    {
      "id": "INV-2026-002",
      "date": "2026-06-08",
      "amount": "₹45,200.00",
      "dept": "Consolidated Institutional",
      "status": "Paid"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Institutional Invoices"),
        backgroundColor: AppColors.primaryGreen,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Invoice & Bill Management",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Track billing cycles, pay monthly consolidated accounts, and review department-wise splits.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 25),
            Card(
              color: Colors.orange.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(Icons.receipt_long, size: 50, color: Colors.orange),
                    const SizedBox(height: 10),
                    const Text(
                      "Consolidated Outstanding Balance",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "₹34,800.00",
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.text),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Next Bill Cycle Ends: 2026-06-30",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Redirecting to corporate bank gateway...")),
                        );
                      },
                      child: const Text("Clear Outstanding Balance"),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              "Invoice History",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: invoices.length,
              itemBuilder: (context, index) {
                final inv = invoices[index];
                final isPaid = inv['status'] == "Paid";
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isPaid ? Colors.green.shade100 : Colors.red.shade100,
                      child: Icon(
                        isPaid ? Icons.check : Icons.pending,
                        color: isPaid ? Colors.green : Colors.red,
                      ),
                    ),
                    title: Text(inv['id'] ?? ''),
                    subtitle: Text("Date: ${inv['date']}\nDept: ${inv['dept']}"),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          inv['amount'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          inv['status'] ?? '',
                          style: TextStyle(
                            color: isPaid ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      _showInvoiceDetailsDialog(context, inv);
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showInvoiceDetailsDialog(BuildContext context, Map<String, String> inv) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Invoice Details - ${inv['id']}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Billing Date: ${inv['date']}"),
              const SizedBox(height: 8),
              Text("Department: ${inv['dept']}"),
              const SizedBox(height: 8),
              Text("Total Bill: ${inv['amount']}"),
              const SizedBox(height: 8),
              Text("Payment Status: ${inv['status']}"),
              const Divider(height: 30),
              const Text("Items Breakdown:", style: TextStyle(fontWeight: FontWeight.bold)),
              const Text("• Organic Tomatoes (Bulk 100Kg) - ₹4,000.00"),
              const Text("• Fresh Potatoes (Bulk 200Kg) - ₹7,000.00"),
              const Text("• Whole Grains Mix (Bulk 300Kg) - ₹18,000.00"),
              const Text("• Swiggy-Style Priority Delivery - ₹5,800.00"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Mock PDF download started...")),
                );
              },
              child: const Text("Download PDF"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }
}
