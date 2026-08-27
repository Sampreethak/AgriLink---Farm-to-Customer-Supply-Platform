import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../services/customer_state.dart';
import 'orders/order_tracking_screen.dart';

class OrdersTab extends StatefulWidget {
  const OrdersTab({super.key});

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> {
  final CustomerState _customerState = CustomerState();

  @override
  void initState() {
    super.initState();
    _customerState.addListener(_onStateChange);
  }

  @override
  void dispose() {
    _customerState.removeListener(_onStateChange);
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'DELIVERED':
        return const Color(0xFF2E7D32);
      case 'PAID':
      case 'PROCESSING':
        return Colors.blue.shade700;
      case 'IN TRANSIT':
      case 'SHIPPED':
        return Colors.orange.shade800;
      default:
        return Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final orders = _customerState.orders;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      appBar: AppBar(
        title: const Text("My Orders", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
      ),
      body: orders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.receipt_long_outlined, size: 70, color: Colors.grey),
                  SizedBox(height: 15),
                  Text("No orders placed yet", style: TextStyle(fontSize: 18, color: AppColors.text, fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Text("Your order history will appear here", style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final order = orders[index];
                final statusColor = _getStatusColor(order.status);

                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  color: const Color(0xFFF5F2EB),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const OrderTrackingScreen(),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: Order ID & Status Badge
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.receipt, color: Color(0xFF2E7D32), size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    order.orderId,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.text),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: statusColor),
                                ),
                                child: Text(
                                  order.status,
                                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Purchased Produce Line Items
                          Column(
                            children: order.items.map((item) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Row(
                                  children: [
                                    Text("• ${item.name}", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                                    const Spacer(),
                                    Text("${item.qty} ${item.unit}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),

                          const Divider(height: 20),

                          // Total & Address
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Total: ₹${order.totalAmount.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF2E7D32))),
                                  Text("Paid via ${order.paymentMethod} • ${order.date}", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                ],
                              ),
                              Row(
                                children: const [
                                  Text("Track Order", style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold, fontSize: 12)),
                                  SizedBox(width: 4),
                                  Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFF2E7D32)),
                                ],
                              ),
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