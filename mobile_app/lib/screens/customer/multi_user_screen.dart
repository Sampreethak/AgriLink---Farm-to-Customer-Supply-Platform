import 'package:flutter/material.dart';
import '../../core/colors.dart';

class MultiUserScreen extends StatefulWidget {
  const MultiUserScreen({super.key});

  @override
  State<MultiUserScreen> createState() => _MultiUserScreenState();
}

class _MultiUserScreenState extends State<MultiUserScreen> {
  final List<Map<String, String>> users = [
    {"name": "Sampreetha", "role": "Primary Admin / Buyer", "status": "Owner"},
    {"name": "Ramesh Kumar", "role": "Kitchen Head Chef", "status": "Order Requester"},
    {"name": "Seema Patil", "role": "PG Inventory Auditor", "status": "View Only"},
  ];

  final _nameController = TextEditingController();
  String selectedRole = "Order Requester";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mess Multi-user Control"),
        backgroundColor: AppColors.primaryGreen,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Account Access Management",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Allow your mess staff, chefs, or accountants to view or place requisitions under this account.",
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
                      "Add Staff Member",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: "Staff Full Name",
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: const InputDecoration(
                        labelText: "Define Permission Role",
                      ),
                      items: const [
                        DropdownMenuItem(value: "Order Requester", child: Text("Order Requester (Chefs)")),
                        DropdownMenuItem(value: "Approver", child: Text("Approver (Mess Warden)")),
                        DropdownMenuItem(value: "View Only", child: Text("View Only (Auditors)")),
                      ],
                      onChanged: (val) {
                        setState(() {
                          selectedRole = val!;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.person_add),
                      label: const Text("Grant Access"),
                      onPressed: () {
                        if (_nameController.text.isNotEmpty) {
                          setState(() {
                            users.add({
                              "name": _nameController.text,
                              "role": selectedRole == "Order Requester"
                                  ? "Kitchen Assistant"
                                  : selectedRole == "Approver"
                                      ? "Finance Manager"
                                      : "Audit Officer",
                              "status": selectedRole,
                            });
                            _nameController.clear();
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Staff access role granted successfully")),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Please enter staff name")),
                          );
                        }
                      },
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              "Current Team Access",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: user['status'] == 'Owner' ? Colors.green.shade100 : Colors.blue.shade100,
                      child: Icon(
                        user['status'] == 'Owner' ? Icons.security : Icons.people,
                        color: user['status'] == 'Owner' ? Colors.green : Colors.blue,
                      ),
                    ),
                    title: Text(user['name'] ?? ''),
                    subtitle: Text("${user['role']} • Role: ${user['status']}"),
                    trailing: user['status'] == 'Owner'
                        ? const Chip(label: Text("Owner", style: TextStyle(color: Colors.green, fontSize: 12)))
                        : IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                users.removeAt(index);
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Staff member access revoked")),
                              );
                            },
                          ),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
