import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../services/auth_service.dart';
import '../common/success_screen.dart';
import 'delivery_dashboard.dart';

class DeliveryRegistrationScreen extends StatefulWidget {
  const DeliveryRegistrationScreen({super.key});

  @override
  State<DeliveryRegistrationScreen> createState() =>
      _DeliveryRegistrationScreenState();
}

class _DeliveryRegistrationScreenState
    extends State<DeliveryRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _licenceController = TextEditingController();
  final _bankController = TextEditingController();
  String selectedVehicle = "Electric Cargo Loader";
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _licenceController.dispose();
    _bankController.dispose();
    super.dispose();
  }

  Future<void> _handleRegisterDriver() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final name = _nameController.text.trim();
      final phone = _phoneController.text.trim();

      final authService = AuthService();
      await authService.register(
        fullName: name.isNotEmpty ? name : "Delivery Driver",
        phone: phone.isNotEmpty ? phone : "+91 98777 ${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}",
        role: "delivery",
        customerType: "Delivery Partner",
        region: "Mandya ➔ Bengaluru Electric Fleet Corridor",
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SuccessScreen(
              title: "Onboarded!",
              subtitle: "Your Delivery Partner profile is now verified and active.",
              nextScreen: const DeliveryDashboard(),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Delivery Partner Setup"),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.delivery_dining,
                  size: 80,
                  color: AppColors.primaryGreen,
                ),
                const SizedBox(height: 15),
                const Text(
                  "Partner Registration",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Deliver fresh agricultural products from local aggregator hubs to hospitals, messes, and retail customers.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 25),

                // Driver Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "Driver Full Name *",
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please enter your name";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Phone
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: "Mobile Phone Number *",
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please enter phone number";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Vehicle Selector
                DropdownButtonFormField<String>(
                  value: selectedVehicle,
                  decoration: const InputDecoration(
                    labelText: "Assigned Vehicle Type",
                    prefixIcon: Icon(Icons.electric_rickshaw),
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                  items: const [
                    DropdownMenuItem(value: "Electric Cargo Loader", child: Text("Electric Cargo Loader (EV 3W)")),
                    DropdownMenuItem(value: "Pickup Truck", child: Text("Pickup Truck (Cold-Van)")),
                    DropdownMenuItem(value: "Two-Wheeler", child: Text("Two-Wheeler EV")),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        selectedVehicle = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Driving License
                TextFormField(
                  controller: _licenceController,
                  decoration: const InputDecoration(
                    labelText: "Commercial Driving License (DL) *",
                    prefixIcon: Icon(Icons.badge),
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please enter your DL number";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Bank Account (for Weekly Payouts)
                TextFormField(
                  controller: _bankController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Bank Account / UPI (for 14% logistics payouts)",
                    prefixIcon: Icon(Icons.account_balance),
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isLoading ? null : _handleRegisterDriver,
                    child: Text(
                      _isLoading ? "Onboarding Partner..." : "Complete Onboarding",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}