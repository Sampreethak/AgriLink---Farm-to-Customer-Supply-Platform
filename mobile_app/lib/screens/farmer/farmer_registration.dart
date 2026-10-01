import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../../services/auth_service.dart';
import '../../widgets/common/app_logo.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/cards/progress_card.dart';
import '../../widgets/cards/expansion_card.dart';
import '../../widgets/form/custom_text_field.dart';
import '../../widgets/form/custom_dropdown.dart';

import '../common/success_screen.dart';
import 'farmer_dashboard.dart';

class FarmerRegistration extends StatefulWidget {
  const FarmerRegistration({super.key});

  @override
  State<FarmerRegistration> createState() => _FarmerRegistrationState();
}

class _FarmerRegistrationState extends State<FarmerRegistration> {
  final _formKey = GlobalKey<FormState>();
  
  // Personal Info
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // Farm Info
  final TextEditingController _farmNameController = TextEditingController();
  final TextEditingController _villageController = TextEditingController();
  final TextEditingController _districtController = TextEditingController(text: "Mandya");
  final TextEditingController _stateController = TextEditingController(text: "Karnataka");
  final TextEditingController _farmSizeController = TextEditingController(text: "4.5");
  String _primaryCrop = "Tomato";

  // Banking / UPI
  final TextEditingController _upiController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _ifscController = TextEditingController();

  bool agree = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _farmNameController.dispose();
    _villageController.dispose();
    _districtController.dispose();
    _stateController.dispose();
    _farmSizeController.dispose();
    _upiController.dispose();
    _accountController.dispose();
    _ifscController.dispose();
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
      final district = _districtController.text.trim().isNotEmpty ? _districtController.text.trim() : "Mandya";
      final state = _stateController.text.trim().isNotEmpty ? _stateController.text.trim() : "Karnataka";
      final region = "$district, $state Agro Corridor";

      final authService = AuthService();
      await authService.register(
        fullName: name.isNotEmpty ? name : "Farmer Producer",
        phone: phone.isNotEmpty ? phone : "+91 98${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}",
        email: email.isNotEmpty ? email : null,
        role: "farmer",
        customerType: "Farmer (Producer)",
        region: region,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SuccessScreen(
              title: "Farmer Profile Created!",
              subtitle: "Welcome to AgriLink! Your producer dashboard and dynamic fair pricing tools are ready.",
              nextScreen: const FarmerDashboard(),
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
        title: const Text("Farmer Registration"),
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
                  "Complete Farmer Profile",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Sell your produce directly to consumers and aggregators with guaranteed 68% take-home payout.",
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
                        label: "Farmer Full Name *",
                        icon: Icons.person,
                        validator: (v) => (v == null || v.trim().isEmpty) ? "Please enter your name" : null,
                      ),
                      CustomTextField(
                        controller: _phoneController,
                        label: "Phone Number (for OTP & UPI) *",
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: (v) => (v == null || v.trim().isEmpty) ? "Please enter phone number" : null,
                      ),
                      CustomTextField(
                        controller: _emailController,
                        label: "Email Address (Optional)",
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ],
                  ),
                ),

                // 2. Farm Information
                ExpansionCard(
                  initiallyExpanded: true,
                  title: "Farm & Land Information",
                  icon: Icons.agriculture,
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: _farmNameController,
                        label: "Farm Name / Field Identifier",
                        icon: Icons.eco,
                      ),
                      CustomTextField(
                        controller: _villageController,
                        label: "Village / Gram Panchayat *",
                        icon: Icons.location_city,
                        validator: (v) => (v == null || v.trim().isEmpty) ? "Please enter village" : null,
                      ),
                      CustomTextField(
                        controller: _districtController,
                        label: "District *",
                        icon: Icons.map,
                      ),
                      CustomTextField(
                        controller: _stateController,
                        label: "State *",
                        icon: Icons.public,
                      ),
                      CustomTextField(
                        controller: _farmSizeController,
                        label: "Farm Size (Acres)",
                        icon: Icons.square_foot,
                        keyboardType: TextInputType.number,
                      ),
                      CustomDropdown(
                        label: "Primary Cultivated Crop",
                        icon: Icons.grass,
                        initialValue: _primaryCrop,
                        items: const [
                          "Tomato",
                          "Potato",
                          "Onion",
                          "Carrot",
                          "Wheat",
                          "Rice",
                          "Green Capsicum",
                          "Apples",
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _primaryCrop = val);
                        },
                      ),
                    ],
                  ),
                ),

                // 3. Banking & Instant UPI Payouts
                ExpansionCard(
                  title: "Instant 68% Payout Details",
                  icon: Icons.account_balance,
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: _upiController,
                        label: "UPI ID / VPA (e.g. mobile@upi)",
                        icon: Icons.qr_code,
                      ),
                      CustomTextField(
                        controller: _accountController,
                        label: "Bank Account Number",
                        icon: Icons.account_balance,
                        keyboardType: TextInputType.number,
                      ),
                      CustomTextField(
                        controller: _ifscController,
                        label: "IFSC Code",
                        icon: Icons.numbers,
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
                    activeColor: Colors.green,
                    title: const Text(
                      "I agree to AgriLink Fair-Share terms & Quality Standards",
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
                  text: _isLoading ? "Configuring Producer Profile..." : "Complete Registration",
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