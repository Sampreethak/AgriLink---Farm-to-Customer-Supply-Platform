import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../auth/role_selection_screen.dart';

class AggregatorDashboard extends StatefulWidget {
  const AggregatorDashboard({super.key});

  @override
  State<AggregatorDashboard> createState() => _AggregatorDashboardState();
}

class _AggregatorDashboardState extends State<AggregatorDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      const CollectionGradingTab(),
      const BulkInventoryTab(),
      const DispatchManagementTab(),
      const AggregatorReportsTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Aggregator Hub Dashboard"),
        backgroundColor: AppColors.primaryGreen,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                (route) => false,
              );
            },
          )
        ],
      ),
      body: tabs[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        height: 70,
        indicatorColor: Colors.green.shade100,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.assignment_outlined), selectedIcon: Icon(Icons.assignment), label: "Collect"),
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2), label: "Inventory"),
          NavigationDestination(icon: Icon(Icons.local_shipping_outlined), selectedIcon: Icon(Icons.local_shipping), label: "Dispatch"),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: "Reports"),
        ],
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

// ----------------------------------------------------
// Tab 1: Collection & Quality Grading
// ----------------------------------------------------
class CollectionGradingTab extends StatefulWidget {
  const CollectionGradingTab({super.key});

  @override
  State<CollectionGradingTab> createState() => _CollectionGradingTabState();
}

class _CollectionGradingTabState extends State<CollectionGradingTab> {
  final List<String> farmers = ["Farmer Guptha", "Farmer Patil", "Farmer Ram Singh"];
  String selectedFarmer = "Farmer Guptha";
  String selectedProduce = "Tomato";
  double qty = 100.0;
  String selectedGrade = "A";

  final List<Map<String, dynamic>> gradingLogs = [
    {"farmer": "Farmer Patil", "produce": "Potato", "qty": "250 Kg", "grade": "B", "payout": "₹7,437", "date": "Today"},
    {"farmer": "Farmer Ram Singh", "produce": "Onion", "qty": "500 Kg", "grade": "A", "payout": "₹15,000", "date": "Yesterday"},
  ];

  double getBaseRate(String crop) {
    if (crop == "Tomato") return 40.0;
    if (crop == "Potato") return 35.0;
    return 30.0;
  }

  double getGradeMultiplier(String grade) {
    if (grade == "A") return 1.0; // Best price
    if (grade == "B") return 0.85; // 15% discount for B grade defects
    return 0.70; // 30% discount for C grade
  }

  @override
  Widget build(BuildContext context) {
    double baseRate = getBaseRate(selectedProduce);
    double multiplier = getGradeMultiplier(selectedGrade);
    double finalRate = baseRate * multiplier;
    double payout = qty * finalRate;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Farmer Produce Intake & Grading",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          const Text("Collect fresh produce directly from farmers, perform QA grading, and calculate payouts.", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Collection Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.text)),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: selectedFarmer,
                    decoration: const InputDecoration(labelText: "Select Farmer"),
                    items: farmers.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                    onChanged: (val) => setState(() => selectedFarmer = val!),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedProduce,
                          decoration: const InputDecoration(labelText: "Produce Crop"),
                          items: const [
                            DropdownMenuItem(value: "Tomato", child: Text("Tomato")),
                            DropdownMenuItem(value: "Potato", child: Text("Potato")),
                            DropdownMenuItem(value: "Onion", child: Text("Onion")),
                          ],
                          onChanged: (val) => setState(() => selectedProduce = val!),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: TextFormField(
                          initialValue: "100",
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: "Quantity (Kg)"),
                          onChanged: (val) => setState(() => qty = double.tryParse(val) ?? 0.0),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text("Quality Grade Grading", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ["A", "B", "C"].map((grade) {
                      bool isSelected = grade == selectedGrade;
                      return ChoiceChip(
                        label: Text(
                          "Grade $grade",
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: AppColors.primaryGreen,
                        onSelected: (val) {
                          if (val) setState(() => selectedGrade = grade);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    selectedGrade == "A"
                        ? "• Grade A: Premium quality, zero spots. Full payout."
                        : selectedGrade == "B"
                            ? "• Grade B: Minor skin spots, fully edible. 15% rate markdown."
                            : "• Grade C: Significant shape defects. 30% rate markdown.",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            color: Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Applicable Crop Payout Rate:"),
                      Text("₹${finalRate.toStringAsFixed(2)} / Kg"),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Estimated Total Payout:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text("₹${payout.toStringAsFixed(2)}", style: const TextStyle(fontSize: 18, color: AppColors.text, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.add_task),
            label: const Text("Save Collection & Approve Payout"),
            onPressed: () {
              setState(() {
                gradingLogs.insert(0, {
                  "farmer": selectedFarmer,
                  "produce": selectedProduce,
                  "qty": "${qty.toInt()} Kg",
                  "grade": selectedGrade,
                  "payout": "₹${payout.toStringAsFixed(0)}",
                  "date": "Just Now",
                });
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Collection recorded and payout voucher generated.")),
              );
            },
          ),
          const SizedBox(height: 25),
          const Text("Recent Collections Logs", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: gradingLogs.length,
            itemBuilder: (context, index) {
              final log = gradingLogs[index];
              return Card(
                child: ListTile(
                  title: Text("${log['farmer']} • ${log['produce']}"),
                  subtitle: Text("Qty: ${log['qty']} | Grade: ${log['grade']}\nDate: ${log['date']}"),
                  trailing: Text(
                    log['payout'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------
// Tab 2: Bulk Inventory Management
// ----------------------------------------------------
class BulkInventoryTab extends StatelessWidget {
  const BulkInventoryTab({super.key});

  final List<Map<String, dynamic>> inventory = const [
    {"name": "Organic Tomatoes", "qty": "850 Kg", "status": "Good", "color": Colors.green},
    {"name": "Fresh Potatoes", "qty": "2,400 Kg", "status": "Good", "color": Colors.green},
    {"name": "Red Onions", "qty": "120 Kg", "status": "Low Stock Warning", "color": Colors.orange},
    {"name": "Green Cabbage", "qty": "80 Kg", "status": "Near Expiry Warning", "color": Colors.red},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Bulk Inventory Management", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          const Text("Track collective produce stocks stored at the central warehouse hub.", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: inventory.length,
            itemBuilder: (context, index) {
              final item = inventory[index];
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    child: Icon(Icons.warehouse),
                  ),
                  title: Text(item['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Available Stock: ${item['qty']}"),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: (item['color'] as Color).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item['status'] ?? '',
                      style: TextStyle(color: item['color'] as Color, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------
// Tab 3: Dispatch Management
// ----------------------------------------------------
class DispatchManagementTab extends StatefulWidget {
  const DispatchManagementTab({super.key});

  @override
  State<DispatchManagementTab> createState() => _DispatchManagementTabState();
}

class _DispatchManagementTabState extends State<DispatchManagementTab> {
  final List<String> deliveryDrivers = ["Karthik S. (Electric Loader)", "Manjunath (Electric Loader)", "Arjun R. (Pickup Truck)"];
  String selectedDriver = "Karthik S. (Electric Loader)";
  String destination = "City General Hospital - Diet Wing";

  final List<Map<String, String>> dispatches = [
    {"id": "DISP-401", "driver": "Karthik S.", "destination": "City General Hospital", "status": "In Transit"},
    {"id": "DISP-398", "driver": "Arjun R.", "destination": "Green Meadows PG Mess", "status": "Completed"},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text("Logistics & Dispatch Management", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          const Text("Batch customer orders, allocate to delivery partners and dispatch trucks.", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Create Dispatch Batch", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.text)),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: selectedDriver,
                    decoration: const InputDecoration(labelText: "Assign Delivery Partner"),
                    items: deliveryDrivers.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                    onChanged: (val) => setState(() => selectedDriver = val!),
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    initialValue: destination,
                    decoration: const InputDecoration(labelText: "Destination Facility"),
                    onChanged: (val) => destination = val,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.send),
                    label: const Text("Launch Dispatch Truck"),
                    onPressed: () {
                      setState(() {
                        dispatches.insert(0, {
                          "id": "DISP-40${dispatches.length + 2}",
                          "driver": selectedDriver.split(' ')[0],
                          "destination": destination,
                          "status": "Ready for Pickup",
                        });
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Dispatch order broadcast to delivery partner")),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 25),
          const Text("Active Dispatch Tracking", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dispatches.length,
            itemBuilder: (context, index) {
              final disp = dispatches[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.local_shipping, color: AppColors.primaryGreen),
                  title: Text("${disp['id']} to ${disp['destination']}"),
                  subtitle: Text("Assigned Driver: ${disp['driver']}"),
                  trailing: Chip(
                    label: Text(disp['status'] ?? '', style: const TextStyle(fontSize: 11)),
                    backgroundColor: disp['status'] == "Completed" ? Colors.green.shade50 : Colors.blue.shade50,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------
// Tab 4: Reports & Analytics
// ----------------------------------------------------
class AggregatorReportsTab extends StatelessWidget {
  const AggregatorReportsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Aggregator Hub Analytics", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          const Text("Operational metrics overview.", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          Row(
            children: const [
              Expanded(
                child: _MetricCard(title: "Today's Intake", value: "3.2 Tons", icon: Icons.download, color: Colors.green),
              ),
              SizedBox(width: 15),
              Expanded(
                child: _MetricCard(title: "Dispatched", value: "2.8 Tons", icon: Icons.upload, color: Colors.blue),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: const [
              Expanded(
                child: _MetricCard(title: "Active Farmers", value: "48", icon: Icons.people, color: Colors.orange),
              ),
              SizedBox(width: 15),
              Expanded(
                child: _MetricCard(title: "Grade A Ratio", value: "78%", icon: Icons.verified_user, color: Colors.purple),
              ),
            ],
          ),
          const SizedBox(height: 30),
          const Text("Grade Analysis (Visual Representation)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 15),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text("Quality Grade Distribution", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _bar(78, "Grade A", Colors.green),
                      _bar(15, "Grade B", Colors.orange),
                      _bar(7, "Grade C", Colors.red),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _bar(double val, String label, Color color) {
    return Column(
      children: [
        Text("${val.toInt()}%", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 8),
        Container(
          width: 40,
          height: val * 1.5,
          color: color,
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.1),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
