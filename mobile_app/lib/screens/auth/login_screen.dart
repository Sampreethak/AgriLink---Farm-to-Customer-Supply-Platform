import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/colors.dart';
import '../../core/localization.dart';
import '../../widgets/voice_input_field.dart';
import '../../services/auth_service.dart';
import '../../services/user_registry.dart';
import 'register_screen.dart';
import 'otp_verification_screen.dart';
import '../customer/customer_dashboard.dart';
import '../farmer/farmer_dashboard.dart';
import '../aggregator/aggregator_dashboard.dart';
import '../delivery/delivery_dashboard.dart';
import '../admin/admin_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPhoneLogin = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _routeToDashboard(AppUserModel user) {
    Widget targetDashboard;
    switch (user.role.toLowerCase()) {
      case 'farmer':
        targetDashboard = const FarmerDashboard();
        break;
      case 'aggregator':
        targetDashboard = const AggregatorDashboard();
        break;
      case 'delivery':
        targetDashboard = const DeliveryDashboard();
        break;
      case 'admin':
        targetDashboard = const AdminDashboard();
        break;
      case 'customer':
      default:
        targetDashboard = const CustomerDashboard();
        break;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => targetDashboard),
      (route) => false,
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = AuthService();
      if (_isPhoneLogin) {
        // Send OTP and navigate to verification screen
        final result = await authService.sendOTP(
          phone: _phoneController.text.trim(),
          purpose: 'login',
        );
        if (result['success'] == true && mounted) {
          final otpCode = result['otp'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("OTP sent to ${_phoneController.text.trim()}! Code: $otpCode"),
              backgroundColor: AppColors.primaryGreen,
              duration: const Duration(seconds: 8),
            ),
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OtpVerificationScreen(
                phoneNumber: _phoneController.text.trim(),
                purpose: 'login',
              ),
            ),
          );
        }
      } else {
        // Strict Email Authentication in the background
        final user = await authService.login(
          identifier: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Welcome ${user.fullName}!"),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 2),
            ),
          );
          _routeToDashboard(user);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll("Exception: ", "")),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 35),
                const Icon(
                  Icons.agriculture,
                  size: 80,
                  color: AppColors.primaryGreen,
                ),
                const SizedBox(height: 12),
                Text(
                  langProvider.translate('welcome_back'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  langProvider.translate('login_continue'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 35),

                // Toggle Button (Email / Phone)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.greyLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isPhoneLogin = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !_isPhoneLogin ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: !_isPhoneLogin
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      )
                                    ]
                                  : null,
                            ),
                            child: const Text(
                              "Email & PW",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.text,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isPhoneLogin = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _isPhoneLogin ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: _isPhoneLogin
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      )
                                    ]
                                  : null,
                            ),
                            child: const Text(
                              "Phone OTP",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.text,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                if (_isPhoneLogin) ...[
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
                ] else ...[
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
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return "Please enter password";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: langProvider.translate('password'),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
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
                          _isPhoneLogin ? "Send OTP" : langProvider.translate('login'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),

                const SizedBox(height: 20),

                // Divider OR
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

                // Google Sign In Button
                OutlinedButton.icon(
                  onPressed: () async {
                    setState(() => _isLoading = true);
                    final authService = AuthService();
                    await authService.signInWithGoogle();
                    if (mounted) {
                      setState(() => _isLoading = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Signed in with Google! Welcome."),
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

                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(langProvider.translate('dont_have_account')),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: Text(
                        langProvider.translate('register'),
                        style: const TextStyle(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}