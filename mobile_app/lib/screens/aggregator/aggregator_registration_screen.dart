import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../services/auth_service.dart';
import '../common/success_screen.dart';
import 'aggregator_dashboard.dart';

class AggregatorRegistrationScreen extends StatefulWidget {
  const AggregatorRegistrationScreen({super.key});

  @override
  State<AggregatorRegistrationScreen> createState() =>
      _AggregatorRegistrationScreenState();
}

class _AggregatorRegistrationScreenState
    extends State<AggregatorRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _warehouseController = TextEditingController();
  final _capacityController = TextEditingController();
  final _locationController = TextEditingController(text: "Mandya / Kolar Agro Yard");
  bool hasColdStorage = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _warehouseController.dispose();
    _capacityController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _handleRegisterAggregator() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final name = _nameController.text.trim();
      final phone = _phoneController.text.trim();
      final email = _emailController.text.trim();
      final location = _locationController.text.trim();

      final authService = AuthService();
      await authService.register(
        fullName: name,
        phone: phone.isNotEmpty ? phone : "+91 98000 ${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}",
        email: email.isNotEmpty ? email : null,
        role: "aggregator",
        customerType: "Aggregator Hub",
        region: location.isNotEmpty ? location : "Mandya Consolidation Hub",
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SuccessScreen(
              title: "Hub Registered!",
              subtitle: "Your Aggregator Hub profile is configured successfully.",
              nextScreen: const AggregatorDashboard(),
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
        title: const Text("Aggregator Profile Setup"),
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
                  Icons.warehouse,
                  size: 80,
                  color: AppColors.primaryGreen,
                ),
                const SizedBox(height: 15),
                const Text(
                  "Aggregator Hub Details",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Register your collection point to grade produce, manage local inventory, and dispatch deliveries.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 25),

                // Hub Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "Aggregator / Business Name *",
                    prefixIcon: Icon(Icons.business),
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please enter business name";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Contact Phone
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: "Contact Phone Number *",
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

                // Contact Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "Contact Email (Optional)",
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                ),
                const SizedBox(height: 16),

                // Warehouse address
                TextFormField(
                  controller: _warehouseController,
                  decoration: const InputDecoration(
                    labelText: "Warehouse Hub Address",
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                ),
                const SizedBox(height: 16),

                // Location / City
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: "Operating City / Catchment Zone",
                    prefixIcon: Icon(Icons.location_city),
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                ),
                const SizedBox(height: 16),

                // Capacity
                TextFormField(
                  controller: _capacityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Storage Capacity (in Metric Tons)",
                    prefixIcon: Icon(Icons.storage),
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                ),
                const SizedBox(height: 16),

                // Cold storage facilities toggle
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: CheckboxListTile(
                    title: const Text("Equipped with pre-cooling & cold storage"),
                    subtitle: const Text("Ensures hospital and fresh produce quality compliance"),
                    value: hasColdStorage,
                    activeColor: AppColors.primaryGreen,
                    onChanged: (val) {
                      setState(() {
                        hasColdStorage = val ?? false;
                      });
                    },
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
                    onPressed: _isLoading ? null : _handleRegisterAggregator,
                    child: Text(
                      _isLoading ? "Creating Hub Profile..." : "Register Aggregator Hub",
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