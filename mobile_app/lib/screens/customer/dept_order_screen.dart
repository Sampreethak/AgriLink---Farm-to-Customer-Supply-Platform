import 'package:flutter/material.dart';
import '../../core/colors.dart';

class DeptOrderScreen extends StatefulWidget {
  const DeptOrderScreen({super.key});

  @override
  State<DeptOrderScreen> createState() => _DeptOrderScreenState();
}

class _DeptOrderScreenState extends State<DeptOrderScreen> {
  String selectedDept = "General Kitchen";
  String selectedItem = "Tomato";
  int quantity = 20;

  final Map<String, List<Map<String, dynamic>>> deptOrders = {
    "General Kitchen": [
      {"item": "Potato", "qty": "100 Kg", "price": 3500.0},
      {"item": "Onion", "qty": "80 Kg", "price": 2400.0},
    ],
    "ICU Nutrition Wing": [
      {"item": "Apple (Organic)", "qty": "15 Kg", "price": 3000.0},
      {"item": "Spinach (QA Grade A)", "qty": "10 Kg", "price": 400.0},
    ],
    "Staff Cafeteria": [
      {"item": "Tomato", "qty": "50 Kg", "price": 2000.0},
      {"item": "Rice", "qty": "100 Kg", "price": 6000.0},
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Department Requisitions"),
        backgroundColor: AppColors.primaryGreen,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Hospital Department Ordering",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Place separate requisitions for individual wings with consolidated institutional billing.",
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
                      "New Requisition Form",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text),
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      value: selectedDept,
                      decoration: const InputDecoration(
                        labelText: "Select Hospital Department",
                        prefixIcon: Icon(Icons.local_hospital),
                      ),
                      items: const [
                        DropdownMenuItem(value: "General Kitchen", child: Text("General Ward Kitchen")),
                        DropdownMenuItem(value: "ICU Nutrition Wing", child: Text("ICU / Cardiac Nutrition")),
                        DropdownMenuItem(value: "Staff Cafeteria", child: Text("Staff Cafeteria")),
                      ],
                      onChanged: (val) {
                        setState(() {
                          selectedDept = val!;
                        });
                      },
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      value: selectedItem,
                      decoration: const InputDecoration(
                        labelText: "Select Item",
                        prefixIcon: Icon(Icons.eco),
                      ),
                      items: const [
                        DropdownMenuItem(value: "Tomato", child: Text("Tomato (₹40/Kg)")),
                        DropdownMenuItem(value: "Potato", child: Text("Potato (₹35/Kg)")),
                        DropdownMenuItem(value: "Onion", child: Text("Onion (₹30/Kg)")),
                        DropdownMenuItem(value: "Apple (Organic)", child: Text("Apple Organic (₹200/Kg)")),
                        DropdownMenuItem(value: "Spinach (QA Grade A)", child: Text("Spinach QA (₹40/Kg)")),
                      ],
                      onChanged: (val) {
                        setState(() {
                          selectedItem = val!;
                        });
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      initialValue: "20",
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Quantity (Kgs)",
                      ),
                      onChanged: (val) {
                        quantity = int.tryParse(val) ?? 20;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text("Add to Department Requisition"),
                      onPressed: () {
                        double rate = 40.0;
                        if (selectedItem.contains("Potato")) rate = 35.0;
                        if (selectedItem.contains("Onion")) rate = 30.0;
                        if (selectedItem.contains("Apple")) rate = 200.0;

                        setState(() {
                          deptOrders[selectedDept]!.add({
                            "item": selectedItem,
                            "qty": "$quantity Kg",
                            "price": rate * quantity,
                          });
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppColors.primaryGreen,
                            content: Text("Added to $selectedDept list"),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              "Consolidated Active Requisitions",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...deptOrders.keys.map((dept) {
              final list = deptOrders[dept] ?? [];
              if (list.isEmpty) return const SizedBox();
              return Card(
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ExpansionTile(
                  leading: const Icon(Icons.corporate_fare, color: AppColors.primaryGreen),
                  title: Text(dept, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${list.length} Items Listed"),
                  initiallyExpanded: true,
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final orderItem = list[index];
                        return ListTile(
                          title: Text(orderItem['item']),
                          subtitle: Text("Qty: ${orderItem['qty']}"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("₹${orderItem['price'].toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    list.removeAt(index);
                                  });
                                },
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.orange),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Consolidated Institutional Order Sent to Aggregator!"),
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text("Submit Consolidated Hospital Order"),
            ),
          ],
        ),
      ),
    );
  }
}
