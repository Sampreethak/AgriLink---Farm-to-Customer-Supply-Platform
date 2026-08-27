import 'package:flutter/material.dart';
import '../../core/colors.dart';

class RecurringOrderScreen extends StatefulWidget {
  const RecurringOrderScreen({super.key});

  @override
  State<RecurringOrderScreen> createState() => _RecurringOrderScreenState();
}

class _RecurringOrderScreenState extends State<RecurringOrderScreen> {
  String selectedProduce = "Milk";
  String frequency = "Daily";
  int quantity = 10;
  String unit = "Liters";

  final List<Map<String, dynamic>> activeSubscriptions = [
    {
      "id": "SUB-101",
      "item": "Milk",
      "qty": 15,
      "unit": "Liters",
      "freq": "Daily",
      "nextDelivery": "Tomorrow, 07:00 AM",
      "status": "Active"
    },
    {
      "id": "SUB-102",
      "item": "Potato",
      "qty": 50,
      "unit": "Kgs",
      "freq": "Weekly (Mon)",
      "nextDelivery": "2026-06-29, 08:30 AM",
      "status": "Active"
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recurring Deliveries"),
        backgroundColor: AppColors.primaryGreen,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Schedule Recurring Fresh Produce",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Set up automated orders for mess essentials. No manual checkouts required.",
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
                    const Text(
                      "Create Subscription",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text),
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      value: selectedProduce,
                      decoration: const InputDecoration(
                        labelText: "Select Produce Item",
                        prefixIcon: Icon(Icons.shopping_basket),
                      ),
                      items: const [
                        DropdownMenuItem(value: "Milk", child: Text("Fresh Milk")),
                        DropdownMenuItem(value: "Curd", child: Text("Curd (Bulk)")),
                        DropdownMenuItem(value: "Bread", child: Text("Whole Wheat Bread")),
                        DropdownMenuItem(value: "Potato", child: Text("Potatoes")),
                        DropdownMenuItem(value: "Onion", child: Text("Onions")),
                      ],
                      onChanged: (val) {
                        setState(() {
                          selectedProduce = val!;
                          if (val == "Milk" || val == "Curd") {
                            unit = "Liters";
                          } else if (val == "Bread") {
                            unit = "Packets";
                          } else {
                            unit = "Kgs";
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            initialValue: "10",
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: "Quantity ($unit)",
                            ),
                            onChanged: (val) {
                              quantity = int.tryParse(val) ?? 10;
                            },
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          flex: 3,
                          child: DropdownButtonFormField<String>(
                            value: frequency,
                            decoration: const InputDecoration(
                              labelText: "Frequency",
                            ),
                            items: const [
                              DropdownMenuItem(value: "Daily", child: Text("Daily")),
                              DropdownMenuItem(value: "Alternate Days", child: Text("Alternate Days")),
                              DropdownMenuItem(value: "Weekly (Mon)", child: Text("Weekly (Monday)")),
                              DropdownMenuItem(value: "Weekly (Wed)", child: Text("Weekly (Wednesday)")),
                              DropdownMenuItem(value: "Weekly (Fri)", child: Text("Weekly (Friday)")),
                            ],
                            onChanged: (val) {
                              setState(() {
                                frequency = val!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: () {
                        setState(() {
                          activeSubscriptions.add({
                            "id": "SUB-10${activeSubscriptions.length + 3}",
                            "item": selectedProduce,
                            "qty": quantity,
                            "unit": unit,
                            "freq": frequency,
                            "nextDelivery": "Starts from tomorrow, 07:00 AM",
                            "status": "Active"
                          });
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppColors.primaryGreen,
                            content: Text("Subscription created for $quantity $unit of $selectedProduce ($frequency)"),
                          ),
                        );
                      },
                      child: const Text("Create Subscription Plan"),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              "Active Subscription Schedules",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activeSubscriptions.length,
              itemBuilder: (context, index) {
                final sub = activeSubscriptions[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      child: Icon(Icons.autorenew),
                    ),
                    title: Text("${sub['item']} - ${sub['qty']} ${sub['unit']}"),
                    subtitle: Text("Frequency: ${sub['freq']}\nNext delivery: ${sub['nextDelivery']}"),
                    trailing: TextButton(
                      onPressed: () {
                        setState(() {
                          activeSubscriptions.removeAt(index);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Subscription canceled")),
                        );
                      },
                      child: const Text("Cancel", style: TextStyle(color: Colors.red)),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
