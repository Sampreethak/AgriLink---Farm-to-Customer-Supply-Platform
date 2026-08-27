import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/colors.dart';
import '../../core/localization.dart';
import '../../widgets/voice_input_field.dart';
import '../../services/auth_service.dart';
import 'otp_verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String _selectedRole = 'customer'; // Default role

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passwords do not match"),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = AuthService();
      bool success = await authService.register(
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        role: _selectedRole,
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (success) {
        // Send OTP
        final result = await authService.sendOTP(
          phone: _phoneController.text.trim(),
          purpose: 'registration',
        );

        if (mounted) {
          final otpCode = result['otp'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("OTP sent to ${_phoneController.text.trim()}! Code: $otpCode"),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 8),
            ),
          );
          // Navigate to OTP verification
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OtpVerificationScreen(
                phoneNumber: _phoneController.text.trim(),
                purpose: 'registration',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll("Exception: ", "")),
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
    final langProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(langProvider.translate('register_title')),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.text,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                const Icon(
                  Icons.person_add_alt_1,
                  size: 80,
                  color: AppColors.primaryGreen,
                ),
                const SizedBox(height: 15),
                Text(
                  langProvider.translate('register_title'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  langProvider.translate('register_subtitle'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 30),
                VoiceInputField(
                  controller: _nameController,
                  hintText: langProvider.translate('full_name'),
                  prefixIcon: Icons.person,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return "Please enter your full name";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                VoiceInputField(
                  controller: _emailController,
                  hintText: langProvider.translate('email'),
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return "Please enter your email";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                VoiceInputField(
                  controller: _phoneController,
                  hintText: langProvider.translate('phone_number'),
                  prefixIcon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return "Please enter your phone number";
                    }
                    if (val.trim().length < 10) {
                      return "Enter a valid 10-digit number";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.group),
                    hintText: "Select Role",
                  ),
                  items: const [
                    DropdownMenuItem(value: 'customer', child: Text("Customer")),
                    DropdownMenuItem(value: 'farmer', child: Text("Farmer")),
                    DropdownMenuItem(value: 'delivery_partner', child: Text("Delivery Partner")),
                    DropdownMenuItem(value: 'aggregator', child: Text("Aggregator")),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedRole = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "Please enter a password";
                    }
                    if (val.length < 6) {
                      return "Password must be at least 6 characters";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    hintText: "Password",
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "Please confirm your password";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    hintText: "Confirm Password",
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
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
                          langProvider.translate('register'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: const [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text("OR", style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: () async {
                    setState(() => _isLoading = true);
                    final authService = AuthService();
                    await authService.signInWithGoogle();
                    if (mounted) {
                      setState(() => _isLoading = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Google Sign-In Successful! Welcome."),
                          backgroundColor: AppColors.success,
                        ),
                      );
                      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
                    }
                  },
                  icon: const Icon(Icons.g_mobiledata, size: 28, color: Colors.red),
                  label: const Text(
                    "Sign in with Google",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppColors.border, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
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