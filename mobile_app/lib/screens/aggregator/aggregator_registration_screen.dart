import 'package:flutter/material.dart';
import '../../core/colors.dart';
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
  final _warehouseController = TextEditingController();
  final _capacityController = TextEditingController();
  final _locationController = TextEditingController();
  bool hasColdStorage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Aggregator Profile Setup"),
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
                const SizedBox(height: 30),

                // Hub Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "Aggregator / Business Name",
                    prefixIcon: Icon(Icons.business),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter business name";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Warehouse address
                TextFormField(
                  controller: _warehouseController,
                  decoration: const InputDecoration(
                    labelText: "Warehouse Hub Address",
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter warehouse address";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Location / City
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: "Operating City / Zone",
                    prefixIcon: Icon(Icons.location_city),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter operating city";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Capacity
                TextFormField(
                  controller: _capacityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Storage Capacity (in Metric Tons)",
                    prefixIcon: Icon(Icons.storage),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter storage capacity";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Cold storage facilities toggle
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: CheckboxListTile(
                    title: const Text("Equipped with cold storage refrigeration"),
                    subtitle: const Text("Hospitals require strict cold chain compliance"),
                    value: hasColdStorage,
                    activeColor: AppColors.primaryGreen,
                    onChanged: (val) {
                      setState(() {
                        hasColdStorage = val ?? false;
                      });
                    },
                  ),
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
                              title: "Hub Registered!",
                              subtitle: "Your Aggregator Hub profile is configured successfully.",
                              nextScreen: const AggregatorDashboard(),
                            ),
                          ),
                        );
                      }
                    },
                    child: const Text("Register Aggregator Hub", style: TextStyle(fontSize: 18)),
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