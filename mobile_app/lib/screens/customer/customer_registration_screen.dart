import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../services/auth_service.dart';
import '../../widgets/common/app_logo.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/cards/progress_card.dart';
import '../../widgets/cards/expansion_card.dart';
import '../../widgets/form/custom_text_field.dart';
import '../../widgets/form/custom_dropdown.dart';
import '../../widgets/form/custom_upload_title.dart';

import '../common/success_screen.dart';
import 'customer_dashboard.dart';

class CustomerRegistrationScreen extends StatefulWidget {
  const CustomerRegistrationScreen({super.key});

  @override
  State<CustomerRegistrationScreen> createState() =>
      _CustomerRegistrationScreenState();
}

class _CustomerRegistrationScreenState
    extends State<CustomerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController(text: "Bengaluru");
  final TextEditingController _stateController = TextEditingController(text: "Karnataka");
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String _selectedCustomerType = "Individual Customer";
  bool agree = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleCompleteRegistration() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in all required fields"),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!agree) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please accept Terms & Conditions"),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final name = _nameController.text.trim();
      final phone = _phoneController.text.trim();
      final email = _emailController.text.trim();
      final region = "${_cityController.text.trim()}, ${_stateController.text.trim()}";

      final authService = AuthService();
      await authService.register(
        fullName: name.isNotEmpty ? name : "New Customer",
        phone: phone.isNotEmpty ? phone : "+91 98${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}",
        email: email.isNotEmpty ? email : null,
        role: "customer",
        customerType: _selectedCustomerType,
        region: region,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SuccessScreen(
              title: "Registration Successful!",
              subtitle: "Welcome to AgriLink! Your personal buying dashboard is ready.",
              nextScreen: const CustomerDashboard(),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Registration error: $e"),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FFF5),
      appBar: AppBar(
        title: const Text("Customer Registration"),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                const AppLogo(),
                const SizedBox(height: 20),
                const Text(
                  "Create Your Customer Account",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Join AgriLink to buy farm-fresh produce directly from local farmers at fair prices.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                const ProgressCard(progress: 0.85),
                const SizedBox(height: 20),

                // 1. Personal Information
                ExpansionCard(
                  initiallyExpanded: true,
                  title: "Personal Information",
                  icon: Icons.person,
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: _nameController,
                        label: "Full Name *",
                        icon: Icons.person,
                        validator: (v) => (v == null || v.trim().isEmpty) ? "Please enter your full name" : null,
                      ),
                      CustomTextField(
                        controller: _emailController,
                        label: "Email Address *",
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => (v == null || v.trim().isEmpty) ? "Please enter your email" : null,
                      ),
                      CustomTextField(
                        controller: _phoneController,
                        label: "Phone Number *",
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: (v) => (v == null || v.trim().isEmpty) ? "Please enter phone number" : null,
                      ),
                    ],
                  ),
                ),

                // 2. Address Information
                ExpansionCard(
                  initiallyExpanded: true,
                  title: "Delivery Address",
                  icon: Icons.location_on,
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: _addressController,
                        label: "Street Address / Building *",
                        icon: Icons.home,
                        validator: (v) => (v == null || v.trim().isEmpty) ? "Please enter delivery address" : null,
                      ),
                      CustomTextField(
                        controller: _cityController,
                        label: "City *",
                        icon: Icons.location_city,
                      ),
                      CustomTextField(
                        controller: _stateController,
                        label: "State *",
                        icon: Icons.map,
                      ),
                      CustomTextField(
                        controller: _pincodeController,
                        label: "Pincode",
                        icon: Icons.pin_drop,
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),

                // 3. Customer Type
                ExpansionCard(
                  initiallyExpanded: true,
                  title: "Customer Type",
                  icon: Icons.groups,
                  child: Column(
                    children: [
                      CustomDropdown(
                        label: "Select Customer Category",
                        icon: Icons.business,
                        initialValue: _selectedCustomerType,
                        items: const [
                          "Individual Customer",
                          "Hostel / PG",
                          "Hospital",
                          "Corporate",
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedCustomerType = val);
                          }
                        },
                      ),
                    ],
                  ),
                ),

                // 4. Additional Information
                ExpansionCard(
                  title: "Additional Preferences",
                  icon: Icons.description,
                  child: Column(
                    children: [
                      const CustomUploadTile(
                        title: "Upload Profile Avatar (Optional)",
                        icon: Icons.person,
                      ),
                      const SizedBox(height: 15),
                      CustomTextField(
                        controller: _notesController,
                        label: "Delivery Notes / Dietary Specs",
                        icon: Icons.note,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                // Terms checkbox
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: CheckboxListTile(
                    value: agree,
                    activeColor: AppColors.primaryGreen,
                    title: const Text(
                      "I agree to AgriLink Terms of Service & Privacy Policy",
                      style: TextStyle(fontSize: 13),
                    ),
                    onChanged: (value) {
                      setState(() {
                        agree = value ?? false;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 25),

                PrimaryButton(
                  text: _isLoading ? "Setting up Profile..." : "Complete Registration",
                  onPressed: _isLoading ? () {} : _handleCompleteRegistration,
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}