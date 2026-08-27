import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../services/customer_state.dart';

class CartTab extends StatefulWidget {
  final VoidCallback? onOrderPlaced;
  const CartTab({super.key, this.onOrderPlaced});

  @override
  State<CartTab> createState() => _CartTabState();
}

class _CartTabState extends State<CartTab> {
  final CustomerState _customerState = CustomerState();
  final TextEditingController _addressController = TextEditingController(
    text: "Flat 402, Sunshine Heights, Bandra West, Mumbai, Maharashtra 400050",
  );
  String _paymentMethod = "RAZORPAY";
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _customerState.addListener(_onStateChange);
  }

  @override
  void dispose() {
    _customerState.removeListener(_onStateChange);
    _addressController.dispose();
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  void _handleCheckout() async {
    if (_customerState.cart.isEmpty) return;

    setState(() {
      _isProcessing = true;
    });

    await Future.delayed(const Duration(milliseconds: 900));

    final newOrder = _customerState.placeOrder(
      deliveryAddress: _addressController.text.trim(),
      paymentMethod: _paymentMethod,
    );

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
    });

    // Show Success Dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: const [
            Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 60),
            SizedBox(height: 10),
            Text(
              "Order Placed Successfully!",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF2E7D32)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Order ID: ${newOrder.orderId}", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text("Total Paid: ₹${newOrder.totalAmount.toStringAsFixed(2)} via ${_paymentMethod == 'RAZORPAY' ? 'Razorpay UPI' : 'COD'}"),
            const SizedBox(height: 6),
            Text("Delivering to: ${newOrder.address}", style: const TextStyle(fontSize: 12, color: Colors.grey), textAlign: TextAlign.center),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                widget.onOrderPlaced?.call();
              },
              child: const Text("View In My Orders"),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = _customerState.cart.values.toList();
    final subtotal = _customerState.subtotal;
    const deliveryFee = 40.0;
    final grandTotal = subtotal > 0 ? subtotal + deliveryFee : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      appBar: AppBar(
        title: const Text("My Shopping Cart", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        actions: [
          if (cartItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              onPressed: () {
                _customerState.clearCart();
              },
              tooltip: "Clear Cart",
            ),
        ],
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF81C784).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.shopping_cart_outlined, size: 70, color: Color(0xFF2E7D32)),
                  ),
                  const SizedBox(height: 18),
                  const Text("Your Cart is Empty", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.text)),
                  const SizedBox(height: 8),
                  const Text("Add fresh produce from the Home tab to get started!", style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cart Items List Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Items (${cartItems.length})",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text),
                      ),
                      Text(
                        "Delivery to: ${CustomerState().name}",
                        style: const TextStyle(fontSize: 12, color: Color(0xFF2E7D32), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Cart Items ListView
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cartItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      final itemTotal = item.priceNum * item.qty;

                      return Card(
                        elevation: 1.5,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        color: const Color(0xFFF5F2EB),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              // Image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  item.imageUrl,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.green.shade100,
                                    child: const Icon(Icons.eco, color: Color(0xFF2E7D32)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Name & Farmer
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.text),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text("By ${item.farmer}", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${item.priceStr} × ${item.qty} = ₹${itemTotal.toStringAsFixed(0)}",
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D32), fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),

                              // Quantity Controls
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove, size: 16, color: Color(0xFF2E7D32)),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                      onPressed: () {
                                        _customerState.updateQuantity(
                                          item.name,
                                          item.priceNum,
                                          item.priceStr,
                                          item.imageUrl,
                                          item.farmer,
                                          -1,
                                        );
                                      },
                                    ),
                                    Text("${item.qty}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    IconButton(
                                      icon: const Icon(Icons.add, size: 16, color: Color(0xFF2E7D32)),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                      onPressed: () {
                                        _customerState.updateQuantity(
                                          item.name,
                                          item.priceNum,
                                          item.priceStr,
                                          item.imageUrl,
                                          item.farmer,
                                          1,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Delivery Address Card
                  Card(
                    elevation: 1.5,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.location_on, color: Color(0xFF2E7D32), size: 18),
                              SizedBox(width: 6),
                              Text("Delivery Address", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _addressController,
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Payment Method Selection
                  Card(
                    elevation: 1.5,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.payment, color: Color(0xFF2E7D32), size: 18),
                              SizedBox(width: 6),
                              Text("Payment Option", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              ChoiceChip(
                                label: const Text("Razorpay UPI"),
                                selected: _paymentMethod == "RAZORPAY",
                                selectedColor: const Color(0xFF81C784).withValues(alpha: 0.3),
                                onSelected: (_) => setState(() => _paymentMethod = "RAZORPAY"),
                              ),
                              const SizedBox(width: 10),
                              ChoiceChip(
                                label: const Text("Cash on Delivery"),
                                selected: _paymentMethod == "COD",
                                selectedColor: const Color(0xFF81C784).withValues(alpha: 0.3),
                                onSelected: (_) => setState(() => _paymentMethod = "COD"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Bill Breakdown Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Order Summary", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Items Subtotal", style: TextStyle(color: Colors.grey)),
                              Text("₹${subtotal.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text("Direct Farm Delivery Fee", style: TextStyle(color: Colors.grey)),
                              Text("₹40.00", style: TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Grand Total", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text(
                                "₹${grandTotal.toStringAsFixed(2)}",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF2E7D32)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2E7D32),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: _isProcessing ? null : _handleCheckout,
                              child: _isProcessing
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : Text(
                                      "Place Order (₹${grandTotal.toStringAsFixed(0)})",
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}