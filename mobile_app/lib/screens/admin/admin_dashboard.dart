import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../auth/role_selection_screen.dart';
import 'database_console_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      const AdminAnalyticsTab(),
      const UserManagementTab(),
      const OrderMonitoringTab(),
      const DisputeResolutionTab(),
      const ProductApprovalTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Central Control"),
        backgroundColor: AppColors.primaryGreen,
        actions: [
          IconButton(
            icon: const Icon(Icons.storage),
            tooltip: "Database Console",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DatabaseConsoleScreen()),
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
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: "Analytics"),
          NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: "Users"),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: "Orders"),
          NavigationDestination(icon: Icon(Icons.report_problem_outlined), selectedIcon: Icon(Icons.report_problem), label: "Disputes"),
          NavigationDestination(icon: Icon(Icons.assignment_turned_in_outlined), selectedIcon: Icon(Icons.assignment_turned_in), label: "Approvals"),
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
// Tab 1: Analytics
// ----------------------------------------------------
class AdminAnalyticsTab extends StatelessWidget {
  const AdminAnalyticsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Platform Analytics & Reports", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          const Text("Live operations overview across all ecosystem modules.", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          Row(
            children: const [
              Expanded(
                child: _AdminStatCard(title: "Total Sales", value: "₹4,85,920", icon: Icons.currency_rupee, color: Colors.green),
              ),
              SizedBox(width: 15),
              Expanded(
                child: _AdminStatCard(title: "Active Orders", value: "84 Today", icon: Icons.shopping_cart, color: Colors.blue),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: const [
              Expanded(
                child: _AdminStatCard(title: "Ecosystem Users", value: "1,240 Total", icon: Icons.people, color: Colors.orange),
              ),
              SizedBox(width: 15),
              Expanded(
                child: _AdminStatCard(title: "Intake Weight", value: "14.2 Tons", icon: Icons.warehouse, color: Colors.purple),
              ),
            ],
          ),
          const SizedBox(height: 25),
          const Text("Revenue Trends (Visual Representation)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text("Sales Breakdown (Last 3 Months)", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("₹", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _bar(120, "April", Colors.green),
                      _bar(210, "May", Colors.blue),
                      _bar(280, "June (Est)", Colors.orange),
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

  Widget _bar(double height, String label, Color color) {
    return Column(
      children: [
        Text("₹${(height * 1000).toInt()}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
        const SizedBox(height: 8),
        Container(
          width: 50,
          height: height * 0.4,
          color: color,
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _AdminStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _AdminStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.1),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// Tab 2: User & Role Management (RBAC)
// ----------------------------------------------------
class UserManagementTab extends StatefulWidget {
  const UserManagementTab({super.key});

  @override
  State<UserManagementTab> createState() => _UserManagementTabState();
}

class _UserManagementTabState extends State<UserManagementTab> {
  final List<Map<String, String>> users = [
    {"name": "Sampreetha", "email": "sampreetha@gmail.com", "role": "Customer"},
    {"name": "Farmer Guptha", "email": "guptha.farm@gmail.com", "role": "Farmer"},
    {"name": "Aggregator Patil", "email": "patil.hub@agrilink.com", "role": "Aggregator"},
    {"name": "Karthik S.", "email": "karthik.deliver@gmail.com", "role": "Delivery Partner"},
  ];

  void _changeRole(int index, String newRole) {
    setState(() {
      users[index]['role'] = newRole;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Role updated to $newRole for ${users[index]['name']}")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(user['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("${user['email']}\nActive Role: ${user['role']}"),
              isThreeLine: true,
              trailing: PopupMenuButton<String>(
                icon: const Icon(Icons.edit_road),
                onSelected: (newRole) => _changeRole(index, newRole),
                itemBuilder: (context) => const [
                  PopupMenuItem(value: "Customer", child: Text("Set as Customer")),
                  PopupMenuItem(value: "Farmer", child: Text("Set as Farmer")),
                  PopupMenuItem(value: "Aggregator", child: Text("Set as Aggregator")),
                  PopupMenuItem(value: "Delivery Partner", child: Text("Set as Delivery Partner")),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ----------------------------------------------------
// Tab 3: Order Monitoring
// ----------------------------------------------------
class OrderMonitoringTab extends StatelessWidget {
  const OrderMonitoringTab({super.key});

  final List<Map<String, String>> systemOrders = const [
    {"id": "ORD-1004", "customer": "St. John Hospital", "amount": "₹34,800", "status": "In Transit"},
    {"id": "ORD-1003", "customer": "Green Meadows PG", "amount": "₹12,450", "status": "Packed"},
    {"id": "ORD-1002", "customer": "Sampreetha (Retail)", "amount": "₹115", "status": "Processing"},
    {"id": "ORD-1001", "customer": "Kengeri Mess Hostels", "amount": "₹45,200", "status": "Delivered"},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: systemOrders.length,
      itemBuilder: (context, index) {
        final order = systemOrders[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.1),
              child: const Icon(Icons.shopping_basket, color: AppColors.primaryGreen),
            ),
            title: Text("${order['id']} • ${order['customer']}"),
            subtitle: Text("Price Total: ${order['amount']}"),
            trailing: Chip(
              label: Text(order['status'] ?? '', style: const TextStyle(fontSize: 11)),
              backgroundColor: order['status'] == "Delivered" ? Colors.green.shade50 : Colors.blue.shade50,
            ),
          ),
        );
      },
    );
  }
}

// ----------------------------------------------------
// Tab 4: Dispute Resolution
// ----------------------------------------------------
class DisputeResolutionTab extends StatefulWidget {
  const DisputeResolutionTab({super.key});

  @override
  State<DisputeResolutionTab> createState() => _DisputeResolutionTabState();
}

class _DisputeResolutionTabState extends State<DisputeResolutionTab> {
  final List<Map<String, dynamic>> tickets = [
    {
      "id": "TKT-108",
      "customer": "ICU Nutrition Dietetics",
      "issue": "10 Kg Tomatoes Grade A received crushed / rotten",
      "amount": "₹400",
      "status": "Pending Review",
    },
    {
      "id": "TKT-105",
      "customer": "Ramesh Kumar (PG Chef)",
      "issue": "Missing 1 bag of potatoes in bulk order",
      "amount": "₹1,750",
      "status": "Refunded",
    }
  ];

  void _resolveTicket(int index, String resolution) {
    setState(() {
      tickets[index]['status'] = resolution;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primaryGreen,
        content: Text("Ticket resolved: $resolution. Refund triggered to gateway."),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: tickets.length,
      itemBuilder: (context, index) {
        final tkt = tickets[index];
        final isResolved = tkt['status'] == "Refunded" || tkt['status'] == "Resolved";
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Dispute ${tkt['id']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                    Chip(
                      label: Text(tkt['status'] ?? '', style: const TextStyle(fontSize: 11)),
                      backgroundColor: isResolved ? Colors.green.shade50 : Colors.orange.shade50,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text("Client: ${tkt['customer']}", style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 4),
                Text("Issue: ${tkt['issue']}"),
                const SizedBox(height: 4),
                Text("Disputed Amount: ${tkt['amount']}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                const Divider(height: 25),
                if (!isResolved)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => _resolveTicket(index, "Dispute Rejected"),
                        child: const Text("Reject Dispute"),
                      ),
                      const SizedBox(width: 15),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () => _resolveTicket(index, "Refunded"),
                        child: const Text("Approve Refund"),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ----------------------------------------------------
// Tab 5: Product Approval
// ----------------------------------------------------
class ProductApprovalTab extends StatefulWidget {
  const ProductApprovalTab({super.key});

  @override
  State<ProductApprovalTab> createState() => _ProductApprovalTabState();
}

class _ProductApprovalTabState extends State<ProductApprovalTab> {
  final List<Map<String, String>> pendingProducts = [
    {"name": "Organic Sweet Corn", "farmer": "Farmer Guptha", "price": "₹25/pc", "status": "Pending"},
    {"name": "Premium Basmati Rice", "farmer": "Farmer Ram Singh", "price": "₹80/kg", "status": "Pending"},
  ];

  void _approveProduct(int index, bool approve) {
    setState(() {
      pendingProducts.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primaryGreen,
        content: Text(approve ? "Produce approved and listed in catalog!" : "Produce rejected."),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return pendingProducts.isEmpty
        ? const Center(
            child: Text("No produce listings pending approval", style: TextStyle(color: Colors.grey)),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: pendingProducts.length,
            itemBuilder: (context, index) {
              final prod = pendingProducts[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(prod['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      Text("Farmer: ${prod['farmer']}", style: const TextStyle(color: Colors.grey)),
                      Text("Proposed Rate: ${prod['price']}"),
                      const Divider(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () => _approveProduct(index, false),
                            child: const Text("Reject"),
                          ),
                          const SizedBox(width: 15),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                            onPressed: () => _approveProduct(index, true),
                            child: const Text("Approve listing"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }
}
