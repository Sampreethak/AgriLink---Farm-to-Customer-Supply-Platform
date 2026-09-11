import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../services/platform_state.dart';
import '../customer/fair_pricing_screen.dart';
import '../auth/role_selection_screen.dart';

class AggregatorDashboard extends StatefulWidget {
  const AggregatorDashboard({super.key});

  @override
  State<AggregatorDashboard> createState() => _AggregatorDashboardState();
}

class _AggregatorDashboardState extends State<AggregatorDashboard> {
  final PlatformState _platformState = PlatformState();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = _platformState.currentUser;

    final List<Widget> tabs = [
      const CollectionGradingTab(),
      const BulkInventoryTab(),
      const DispatchManagementTab(),
      const AggregatorReportsTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.fullName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(
              "${user.region} • SHG Hub",
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            tooltip: 'Dynamic Pricing Oracle',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FairPricingScreen()),
              );
            },
          ),
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
// Tab 1: Collection & Quality Grading (APMC Linked)
// ----------------------------------------------------
class CollectionGradingTab extends StatefulWidget {
  const CollectionGradingTab({super.key});

  @override
  State<CollectionGradingTab> createState() => _CollectionGradingTabState();
}

class _CollectionGradingTabState extends State<CollectionGradingTab> {
  final PlatformState _platformState = PlatformState();
  final List<String> farmers = ["Ramesh Kumar (Mandya)", "Suresh Patel (Anand)", "Anita Sharma (Shimla)", "Farmer Guptha"];
  String selectedFarmer = "Ramesh Kumar (Mandya)";
  String selectedProduce = "Tomato";
  double qty = 100.0;
  String selectedGrade = "Grade A+";

  final List<Map<String, dynamic>> gradingLogs = [
    {"farmer": "Ramesh Kumar", "produce": "Tomato", "qty": "500 Kg", "grade": "Grade A+", "payout": "₹15,195", "hubMargin": "₹2,235", "date": "Today"},
    {"farmer": "Suresh Patel", "produce": "Potato", "qty": "250 Kg", "grade": "Grade A", "payout": "₹5,950", "hubMargin": "₹875", "date": "Today"},
    {"farmer": "Anita Sharma", "produce": "Apple", "qty": "300 Kg", "grade": "Grade A+", "payout": "₹24,480", "hubMargin": "₹3,600", "date": "Yesterday"},
  ];

  @override
  Widget build(BuildContext context) {
    final breakdown = _platformState.getBreakdown(selectedProduce);
    final farmerRate = breakdown.farmerPayout; // 68%
    final aggRate = breakdown.aggregatorShare;   // 10%
    final farmerPayout = qty * farmerRate;
    final hubMargin = qty * aggRate;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // APMC Dynamic Pricing Oracle Banner
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FairPricingScreen()),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.scale, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Oracle APMC Rate for $selectedProduce: ₹${breakdown.consumerPrice.toStringAsFixed(2)}/kg (Hub gets 10% = ₹${aggRate.toStringAsFixed(2)}/kg)",
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.green),
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),

          const Text(
            "Farmer Produce Intake & Grading",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          const Text("Collect fresh produce directly from farmers, perform QA grading, and calculate 4-way payouts.", style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 15),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedFarmer,
                    decoration: const InputDecoration(labelText: "Select Farmer"),
                    items: farmers.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                    onChanged: (val) => setState(() => selectedFarmer = val!),
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: selectedProduce,
                    decoration: const InputDecoration(labelText: "Produce Type"),
                    items: ["Tomato", "Potato", "Onion", "Carrot", "Green Capsicum", "Rice"]
                        .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                    onChanged: (val) => setState(() => selectedProduce = val!),
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    initialValue: qty.toStringAsFixed(0),
                    decoration: const InputDecoration(labelText: "Weighed Intake Quantity (Kg)", suffixText: "Kg"),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => setState(() => qty = double.tryParse(val) ?? 0.0),
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: selectedGrade,
                    decoration: const InputDecoration(labelText: "Quality Grade (Assessed)"),
                    items: ["Grade A+", "Grade A", "Grade B (Processing)"]
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (val) => setState(() => selectedGrade = val!),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Farmer Direct Payout (68%):", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text("₹${farmerPayout.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Aggregator Hub Margin (10%):", style: TextStyle(fontSize: 12, color: Colors.black87)),
                            Text("₹${hubMargin.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.deepOrange)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        gradingLogs.insert(0, {
                          "farmer": selectedFarmer.split(' ').first,
                          "produce": selectedProduce,
                          "qty": "${qty.toStringAsFixed(0)} Kg",
                          "grade": selectedGrade,
                          "payout": "₹${farmerPayout.toStringAsFixed(0)}",
                          "hubMargin": "₹${hubMargin.toStringAsFixed(0)}",
                          "date": "Just now",
                        });
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Intake Recorded & Digital Weigh Slip Generated!"), backgroundColor: AppColors.primaryGreen),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Center(child: Text("Accept Intake & Issue QA Receipt", style: TextStyle(fontWeight: FontWeight.bold))),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 25),
          const Text("Recent Intake Logs", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: gradingLogs.length,
            itemBuilder: (context, index) {
              final log = gradingLogs[index];
              return Card(
                child: ListTile(
                  title: Text("${log['farmer']} • ${log['produce']} (${log['qty']})", style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Grade: ${log['grade']} • Hub Fee: ${log['hubMargin'] ?? ''}"),
                  trailing: Text(
                    log['payout'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 15),
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
    {"name": "Organic Tomatoes (Nashik / Mandya)", "qty": "1,500 Kg", "status": "Good Condition", "color": Colors.green},
    {"name": "Fresh Potatoes (Kolar)", "qty": "3,000 Kg", "status": "Good Condition", "color": Colors.green},
    {"name": "Organic Red Onions", "qty": "3,000 Kg", "status": "Ventilated Storage", "color": Colors.green},
    {"name": "Shimla Royal Apples", "qty": "1,200 Kg", "status": "Cold Storage (4°C)", "color": Colors.blue},
    {"name": "Basmati Rice 1121", "qty": "4,000 Kg", "status": "Bagged (50kg)", "color": Colors.teal},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Bulk Inventory Management", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          const Text("Track collective produce stocks pooled across cluster farmers.", style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 15),
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
                  title: Text(item['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text("Hub Stock: ${item['qty']}"),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: (item['color'] as Color).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item['status'] ?? '',
                      style: TextStyle(color: item['color'] as Color, fontWeight: FontWeight.bold, fontSize: 11),
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
// Tab 3: Dispatch Management (Synced with Customer Orders)
// ----------------------------------------------------
class DispatchManagementTab extends StatefulWidget {
  const DispatchManagementTab({super.key});

  @override
  State<DispatchManagementTab> createState() => _DispatchManagementTabState();
}

class _DispatchManagementTabState extends State<DispatchManagementTab> {
  final PlatformState _platformState = PlatformState();
  final List<String> deliveryDrivers = ["Raju (Express Cold Fleet)", "Karthik S. (Electric Loader)", "Manjunath (Pickup Truck)"];
  String selectedDriver = "Raju (Express Cold Fleet)";

  @override
  void initState() {
    super.initState();
    _platformState.addListener(_onPlatformChange);
  }

  @override
  void dispose() {
    _platformState.removeListener(_onPlatformChange);
    super.dispose();
  }

  void _onPlatformChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final liveOrders = _platformState.getAggregatorOrders();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text("Live Customer Order Dispatch", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          const Text("Real-time orders placed by customers automatically pooled for cluster dispatch.", style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 15),

          if (liveOrders.isEmpty)
            const Center(child: Text("No orders waiting for dispatch"))
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: liveOrders.length,
              itemBuilder: (context, index) {
                final order = liveOrders[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Order #${order.orderId}",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                order.status,
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green.shade800),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text("Customer: ${order.customerName} (${order.customerEmail})", style: const TextStyle(fontSize: 12, color: Colors.black87)),
                        Text("Delivery Address: ${order.deliveryAddress}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Total: ₹${order.totalAmount.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text("Hub Commission (10%): ₹${order.aggregatorShare.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange, fontSize: 13)),
                          ],
                        ),
                        const Divider(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                order.assignedDriver != null ? "Driver: ${order.assignedDriver}" : "Driver: Not yet assigned",
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                            ),
                            if (order.status != 'DELIVERED')
                              ElevatedButton(
                                onPressed: () {
                                  _platformState.updateOrderStatus(order.orderId, 'IN_TRANSIT', driverName: selectedDriver);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Order #${order.orderId} dispatched with $selectedDriver!"), backgroundColor: AppColors.primaryGreen),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryGreen,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                child: const Text("Dispatch Fleet", style: TextStyle(fontSize: 12)),
                              ),
                          ],
                        ),
                      ],
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
// Tab 4: Aggregator Financial Reports
// ----------------------------------------------------
class AggregatorReportsTab extends StatelessWidget {
  const AggregatorReportsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = PlatformState();
    final totalEarnings = state.getAggregatorTotalEarnings();
    final totalOrders = state.allOrders.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text("Financial & Aggregation Reports", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.mintLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Total Hub Aggregation Commission (10%)", style: TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 4),
                Text("₹${totalEarnings.toStringAsFixed(2)}", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
                const SizedBox(height: 8),
                Text("Processed $totalOrders collective batches across Mandya & Kolar corridors.", style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: const Icon(Icons.analytics, color: Colors.green),
              title: const Text("Open APMC Dynamic Pricing Simulator"),
              subtitle: const Text("View live benchmarks & 4-way share oracle"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FairPricingScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
