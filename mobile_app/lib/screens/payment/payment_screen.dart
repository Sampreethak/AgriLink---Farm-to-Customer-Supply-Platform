import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../core/colors.dart';
import '../../core/localization.dart';
import '../../services/payment_service.dart';

class PaymentScreen extends StatefulWidget {
  final String orderId;
  final double totalAmount;

  const PaymentScreen({
    super.key,
    required this.orderId,
    required this.totalAmount,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late Razorpay _razorpay;
  bool _isLoading = false;
  String? _paymentStatusMessage;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _startPayment() async {
    setState(() {
      _isLoading = true;
      _paymentStatusMessage = "Initializing payment gateway...";
    });

    try {
      final paymentService = PaymentService();
      
      // 1. Create order on Razorpay through backend API
      final response = await paymentService.createRazorpayOrder(
        orderId: widget.orderId,
        amount: widget.totalAmount,
      );

      final razorpayOrderId = response['razorpay_order_id'];
      final rzpKey = response['key_id'] ?? 'rzp_test_placeholder_key';

      // 2. Open Razorpay checkout interface
      var options = {
        'key': rzpKey,
        'amount': (widget.totalAmount * 100).toInt(), // Amount in paise
        'name': 'AgriLink Marketplace',
        'description': 'Payment for Order #${widget.orderId.substring(0, 8)}',
        'order_id': razorpayOrderId,
        'prefill': {
          'contact': '9876543210',
          'email': 'customer@agrilink.com',
        },
        'external': {
          'wallets': ['paytm']
        }
      };

      _razorpay.open(options);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _paymentStatusMessage = "Failed to start payment: $e";
      });
    }
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    setState(() => _paymentStatusMessage = "Verifying payment signature...");

    try {
      final paymentService = PaymentService();
      bool isVerified = await paymentService.verifyPayment(
        orderId: widget.orderId,
        razorpayOrderId: response.orderId ?? '',
        razorpayPaymentId: response.paymentId ?? '',
        razorpaySignature: response.signature ?? '',
      );

      if (isVerified && mounted) {
        setState(() {
          _isLoading = false;
          _paymentStatusMessage = "Payment successful and verified!";
        });
        
        _showSuccessDialog();
      } else if (mounted) {
        setState(() {
          _isLoading = false;
          _paymentStatusMessage = "Payment verification failed.";
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _paymentStatusMessage = "Verification error: $e";
      });
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {
      _isLoading = false;
      _paymentStatusMessage = "Payment failed: [Code: ${response.code}] ${response.message}";
    });
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() {
      _isLoading = false;
      _paymentStatusMessage = "External wallet selected: ${response.walletName}";
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final langProvider = Provider.of<LanguageProvider>(context, listen: false);
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              const Icon(
                Icons.check_circle_outline,
                color: AppColors.success,
                size: 80,
              ),
              const SizedBox(height: 20),
              Text(
                langProvider.translate('payment_success'),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Your order has been placed successfully.",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Dismiss dialog
                  Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Go to Home", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);

    // Calculate invoice values
    final subtotal = widget.totalAmount / 1.05;
    final gst = widget.totalAmount - subtotal;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(langProvider.translate('checkout')),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.text,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Select Payment Option",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.text),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Invoice / Price breakdown card
                    Card(
                      elevation: 0,
                      color: AppColors.surfaceLight,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              "Order ID: #${widget.orderId.substring(0, 8)}",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(langProvider.translate('subtotal')),
                                Text("₹${subtotal.toStringAsFixed(2)}"),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(langProvider.translate('gst')),
                                Text("₹${gst.toStringAsFixed(2)}"),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(langProvider.translate('delivery_charge')),
                                const Text("₹0.00"),
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  langProvider.translate('total'),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                                Text(
                                  "₹${widget.totalAmount.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: AppColors.primaryGreen,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    if (_paymentStatusMessage != null)
                      Text(
                        _paymentStatusMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _paymentStatusMessage!.contains("fail") || _paymentStatusMessage!.contains("error")
                              ? AppColors.error
                              : AppColors.primaryGreen,
                        ),
                      ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: _isLoading ? null : _startPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        langProvider.translate('pay_now'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
