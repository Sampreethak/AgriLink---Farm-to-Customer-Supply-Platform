import 'package:flutter/material.dart';
import '../../services/order_service.dart';
import '../../services/platform_state.dart';

class OrdersTab extends StatefulWidget {
  const OrdersTab({super.key});

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> with SingleTickerProviderStateMixin {
  final OrderService _orderService = OrderService();
  final PlatformState _platformState = PlatformState();
  late TabController _tabController;

  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _platformState.addListener(_onPlatformChange);
    _loadOrders();
  }

  @override
  void dispose() {
    _platformState.removeListener(_onPlatformChange);
    _tabController.dispose();
    super.dispose();
  }

  void _onPlatformChange() {
    if (mounted) _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final farmerName = _platformState.currentUser.fullName;
      final syncedOrders = _platformState.getFarmerOrders(farmerName);

      if (syncedOrders.isNotEmpty) {
        setState(() {
          _orders = syncedOrders.map<Map<String, dynamic>>((o) => {
            'id': o.orderId,
            'status': o.status.toLowerCase(),
            'amount': o.farmerPayout.toStringAsFixed(0),
            'customer_name': '${o.customerName} (${o.deliveryAddress})',
            'item_count': o.items.length,
            'created_at': '${o.createdAt.day}/${o.createdAt.month}',
            'payout_label': '68% Direct Farmer Payout: ₹${o.farmerPayout.toStringAsFixed(0)}',
          }).toList();
          _isLoading = false;
        });
      } else {
        final raw = await _orderService.getFarmerOrders();
        setState(() {
          _orders = raw.map<Map<String, dynamic>>((o) => Map<String, dynamic>.from(o)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _orders = [
          {
            'id': 'ORD-98721',
            'status': 'delivered',
            'amount': '952',
            'customer_name': 'Priya Verma (Bandra West, Mumbai)',
            'item_count': 1,
            'created_at': '28/7',
            'payout_label': '68% Direct Farmer Payout: ₹952',
          },
          {
            'id': 'ORD-98715',
            'status': 'delivered',
            'amount': '1632',
            'customer_name': 'Priya Verma (Bandra West, Mumbai)',
            'item_count': 1,
            'created_at': '25/7',
            'payout_label': '68% Direct Farmer Payout: ₹1,632',
          },
        ];
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
      case 'pending':
      case 'confirmed':
        return Colors.orange;
      case 'accepted':
      case 'in_transit':
      case 'collected':
        return Colors.blue;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'confirmed':
        return Icons.access_time;
      case 'accepted':
      case 'in_transit':
      case 'collected':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.shopping_bag;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoading ? "Farmer Orders" : "Farmer Orders (${_orders.length})"),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
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
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: "All Orders"),
            Tab(text: "Pending / Confirmed"),
            Tab(text: "In Transit"),
            Tab(text: "Delivered & Settled"),
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
                  Text("Loading synced orders...", style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOrderList(_filtered('all')),
                _buildOrderList(_filtered('confirmed').isNotEmpty ? _filtered('confirmed') : _filtered('pending')),
                _buildOrderList(_filtered('in_transit').isNotEmpty ? _filtered('in_transit') : _filtered('accepted')),
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
          children: const [
            Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "No orders in this category",
              style: TextStyle(fontSize: 16, color: Colors.grey),
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
          final status = (order['status'] ?? 'confirmed').toString();
          final color = _statusColor(status);
          final orderId = order['id']?.toString() ?? 'ORD-98721';
          final amount = order['amount']?.toString() ?? '0';
          final customerName = order['customer_name']?.toString() ?? 'Customer';
          final itemCount = order['item_count']?.toString() ?? '1';
          final payoutLabel = order['payout_label'] ?? '68% Direct Farmer Payout: ₹$amount';

          return Card(
            margin: const EdgeInsets.only(bottom: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
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
                          "$customerName • $itemCount item${itemCount == '1' ? '' : 's'}",
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Text(
                            payoutLabel,
                            style: TextStyle(
                              color: Colors.green.shade800,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
