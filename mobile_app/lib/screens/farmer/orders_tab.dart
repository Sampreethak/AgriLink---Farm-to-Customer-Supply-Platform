import 'package:flutter/material.dart';
import '../../services/order_service.dart';
import 'orders/order_details_screen.dart';

class OrdersTab extends StatefulWidget {
  const OrdersTab({super.key});

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> with SingleTickerProviderStateMixin {
  final OrderService _orderService = OrderService();
  late TabController _tabController;

  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });
    try {
      final raw = await _orderService.getFarmerOrders();
      setState(() {
        _orders = raw.map<Map<String, dynamic>>((o) => Map<String, dynamic>.from(o)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        // Demo fallback orders
        _orders = List.generate(8, (i) => {
          'id': 1001 + i,
          'status': ['pending', 'accepted', 'delivered', 'cancelled'][i % 4],
          'amount': 1150 + i * 200,
          'customer_name': 'Customer ${i + 1}',
          'item_count': (i % 3) + 1,
          'created_at': '2026-07-0${(i % 9) + 1}',
        });
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _filtered(String status) {
    if (status == 'all') return _orders;
    return _orders.where((o) => (o['status'] ?? '').toString().toLowerCase() == status).toList();
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'accepted': return Colors.blue;
      case 'delivered': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Icons.access_time;
      case 'accepted': return Icons.check_circle_outline;
      case 'delivered': return Icons.check_circle;
      case 'cancelled': return Icons.cancel_outlined;
      default: return Icons.shopping_bag;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoading ? "Orders" : "Orders (${_orders.length})"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.green,
          labelColor: Colors.green,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: "All"),
            Tab(text: "Pending"),
            Tab(text: "Accepted"),
            Tab(text: "Delivered"),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Loading orders from backend...", style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOrderList(_filtered('all')),
                _buildOrderList(_filtered('pending')),
                _buildOrderList(_filtered('accepted')),
                _buildOrderList(_filtered('delivered')),
              ],
            ),
    );
  }

  Widget _buildOrderList(List<Map<String, dynamic>> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              "No orders found",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            if (_error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  "Backend offline – showing demo data.",
                  style: TextStyle(fontSize: 12, color: Colors.orange.shade700),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          final status = (order['status'] ?? 'pending').toString();
          final color = _statusColor(status);
          final orderId = order['id']?.toString() ?? '${1001 + index}';
          final amount = order['amount']?.toString() ?? '0';
          final customerName = order['customer_name']?.toString() ?? 'Customer';
          final itemCount = order['item_count']?.toString() ?? '1';

          return Card(
            margin: const EdgeInsets.only(bottom: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OrderDetailsScreen()),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: color.withValues(alpha: 0.1),
                      child: Icon(_statusIcon(status), color: color),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Order #$orderId",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            customerName,
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "₹$amount • $itemCount item${itemCount == '1' ? '' : 's'}",
                            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: color.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
