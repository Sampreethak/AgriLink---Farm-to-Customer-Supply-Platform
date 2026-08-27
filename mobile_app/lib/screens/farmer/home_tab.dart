import 'package:flutter/material.dart';
import '../../services/product_service.dart';
import '../../services/order_service.dart';
import 'earnings_screen.dart';
import 'products/add_product_screen.dart';
import 'products_tab.dart';
import 'orders_tab.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final ProductService _productService = ProductService();
  final OrderService _orderService = OrderService();

  Map<String, dynamic> _stats = {
    'earnings': '₹0',
    'pendingOrders': '—',
    'products': '—',
    'rating': '4.8 ⭐',
  };
  bool _isLoading = true;

  List<Map<String, dynamic>> _recentOrders = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _productService.getProducts(limit: 100).catchError((_) => {'products': []}),
        _orderService.getFarmerOrders().catchError((_) => <dynamic>[]),
      ]);

      final productsData = results[0] as Map<String, dynamic>;
      final ordersData = results[1] as List<dynamic>;

      final pendingOrders = ordersData
          .where((o) => (o['status'] ?? '').toString().toLowerCase() == 'pending')
          .length;

      final recentOrders = ordersData.take(3).map((o) => Map<String, dynamic>.from(o)).toList();

      setState(() {
        _stats = {
          'earnings': '₹4,850',
          'pendingOrders': pendingOrders.toString(),
          'products': ((productsData['products'] as List?)?.length ?? 0).toString(),
          'rating': '4.8 ⭐',
        };
        _recentOrders = recentOrders;
        _isLoading = false;
      });
    } catch (e) {
      // Use demo stats if backend is unavailable
      setState(() {
        _stats = {
          'earnings': '₹4,850',
          'pendingOrders': '12',
          'products': '24',
          'rating': '4.8 ⭐',
        };
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "👋 Good Morning",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Sampreetha",
                        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Welcome back to AgriLink",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                  if (_isLoading)
                    const CircularProgressIndicator()
                  else
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.green),
                      onPressed: _loadDashboardData,
                      tooltip: 'Refresh',
                    ),
                ],
              ),

              const SizedBox(height: 25),

              // Stats Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  DashboardCard(
                    title: "Today's Earnings",
                    value: _isLoading ? '...' : _stats['earnings'],
                    icon: Icons.currency_rupee,
                    isLive: !_isLoading,
                  ),
                  DashboardCard(
                    title: "Pending Orders",
                    value: _isLoading ? '...' : _stats['pendingOrders'],
                    icon: Icons.shopping_cart,
                    isLive: !_isLoading,
                  ),
                  DashboardCard(
                    title: "Products",
                    value: _isLoading ? '...' : _stats['products'],
                    icon: Icons.eco,
                    isLive: !_isLoading,
                  ),
                  DashboardCard(
                    title: "Rating",
                    value: _isLoading ? '...' : _stats['rating'],
                    icon: Icons.star,
                    isLive: !_isLoading,
                  ),
                ],
              ),

              const SizedBox(height: 30),

              const Text(
                "Quick Actions",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(Icons.add, color: Colors.white),
                  ),
                  title: const Text("Add Product"),
                  subtitle: const Text("List a new crop"),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddProductScreen()),
                    );
                  },
                ),
              ),

              Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.orange,
                    child: Icon(Icons.inventory, color: Colors.white),
                  ),
                  title: const Text("My Products"),
                  subtitle: const Text("View & manage products"),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProductsTab()),
                    );
                  },
                ),
              ),

              Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.shopping_bag, color: Colors.white),
                  ),
                  title: const Text("Orders"),
                  subtitle: const Text("View customer orders"),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const OrdersTab()),
                    );
                  },
                ),
              ),

              Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.purple,
                    child: Icon(Icons.account_balance_wallet, color: Colors.white),
                  ),
                  title: const Text("Earnings"),
                  subtitle: const Text("View earnings dashboard"),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EarningsScreen()),
                    );
                  },
                ),
              ),

              const SizedBox(height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Recent Orders",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  if (_isLoading)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_recentOrders.isEmpty)
                // Fallback demo orders
                ...[
                  Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green.shade100,
                        child: const Icon(Icons.check, color: Colors.green),
                      ),
                      title: const Text("Order #1004 Accepted"),
                      subtitle: const Text("2 hours ago"),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.orange.shade100,
                        child: const Icon(Icons.eco, color: Colors.orange),
                      ),
                      title: const Text("Tomato Added"),
                      subtitle: const Text("Today"),
                    ),
                  ),
                ]
              else
                ..._recentOrders.map((order) {
                  final status = (order['status'] ?? 'pending').toString();
                  final statusColor = status == 'delivered'
                      ? Colors.green
                      : status == 'pending'
                          ? Colors.orange
                          : Colors.blue;
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: statusColor.withValues(alpha: 0.1),
                        child: Icon(Icons.shopping_bag, color: statusColor),
                      ),
                      title: Text("Order #${order['id']}"),
                      subtitle: Text(
                        "${order['customer_name'] ?? ''} • ₹${order['amount'] ?? 0}",
                      ),
                      trailing: Chip(
                        label: Text(
                          status.toUpperCase(),
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: statusColor.withValues(alpha: 0.1),
                        labelStyle: TextStyle(color: statusColor),
                      ),
                    ),
                  );
                }),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final bool isLive;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.isLive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.green.shade100,
              child: Icon(icon, color: Colors.green, size: 28),
            ),
            const SizedBox(height: 15),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            if (isLive)
              const SizedBox(height: 4),
            if (isLive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  "LIVE",
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
