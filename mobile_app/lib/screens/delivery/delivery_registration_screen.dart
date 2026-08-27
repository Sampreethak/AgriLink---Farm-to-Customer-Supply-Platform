import 'package:flutter/material.dart';
import '../../core/colors.dart';
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
  final _licenceController = TextEditingController();
  final _bankController = TextEditingController();
  String selectedVehicle = "Electric Cargo Loader";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Delivery Partner Setup"),
        backgroundColor: AppColors.primaryGreen,
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
                const SizedBox(height: 30),

                // Vehicle Selector
                DropdownButtonFormField<String>(
                  value: selectedVehicle,
                  decoration: const InputDecoration(
                    labelText: "Vehicle Type",
                    prefixIcon: Icon(Icons.electric_rickshaw),
                  ),
                  items: const [
                    DropdownMenuItem(value: "Electric Cargo Loader", child: Text("Electric Cargo Loader")),
                    DropdownMenuItem(value: "Pickup Truck", child: Text("Pickup Truck")),
                    DropdownMenuItem(value: "Two-Wheeler", child: Text("Two-Wheeler")),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        selectedVehicle = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 20),

                // Driving License
                TextFormField(
                  controller: _licenceController,
                  decoration: const InputDecoration(
                    labelText: "Commercial Driving License (DL)",
                    prefixIcon: Icon(Icons.badge),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your DL number";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Bank Account (for Weekly Payouts)
                TextFormField(
                  controller: _bankController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Bank Account Number (for payouts)",
                    prefixIcon: Icon(Icons.account_balance),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter bank details";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 35),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
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
                    },
                    child: const Text("Complete Onboarding", style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}