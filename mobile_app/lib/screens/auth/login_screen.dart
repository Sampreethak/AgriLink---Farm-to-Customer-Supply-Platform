import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/colors.dart';
import '../../core/validators.dart';
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

enum AuthMethod {
  emailPassword,
  emailOtp,
  phoneOtp,
  whatsappOtp,
}

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
  final FocusNode _emailFocusNode = FocusNode();

  AuthMethod _selectedMethod = AuthMethod.emailPassword;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _obscurePassword = true;
  bool _isAutofilling = false;

  String? _detectedRole;
  String? _autofillStatus;
  List<Map<String, dynamic>> _registeredAccounts = [];

  @override
  void initState() {
    super.initState();
    _loadAccountsFromDb();

    // Trigger database password lookup whenever email field loses focus
    _emailFocusNode.addListener(() {
      if (!_emailFocusNode.hasFocus && _emailController.text.trim().isNotEmpty) {
        _autofillPasswordFromDb(_emailController.text.trim());
      }
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  // Load all registered accounts from Supabase database
  Future<void> _loadAccountsFromDb() async {
    try {
      final authService = AuthService();
      final list = await authService.getRegisteredAccountsFromDb();
      if (mounted) {
        setState(() {
          _registeredAccounts = list;
        });
      }
    } catch (_) {}
  }

  // Retrieve password from Supabase database for the given email
  Future<void> _autofillPasswordFromDb(String email) async {
    final cleanEmail = email.trim();
    if (cleanEmail.isEmpty) return;

    setState(() {
      _isAutofilling = true;
      _autofillStatus = null;
    });

    try {
      final authService = AuthService();
      final accountData = await authService.getAccountAutofill(cleanEmail);

      if (accountData != null && accountData['demo_password'] != null) {
        final pwd = accountData['demo_password'].toString();
        final role = accountData['user_role']?.toString().toUpperCase() ?? 'USER';

        if (mounted) {
          setState(() {
            _passwordController.text = pwd;
            _detectedRole = role;
            _autofillStatus = "Password autofilled from database for [$role]";
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _autofillStatus = null;
          });
        }
      }
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() => _isAutofilling = false);
      }
    }
  }

  // Route to the appropriate role dashboard
  void _routeToDashboard(AppUserModel user) {
    Widget targetDashboard;
    final r = AuthService.normalizeRole(user.role);

    switch (r) {
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

  // Handle Google OAuth Sign-In
  Future<void> _handleGoogleSignIn() async {
    setState(() => _isGoogleLoading = true);
    try {
      final authService = AuthService();
      await authService.signInWithGoogle();
      // On Web, the browser initiates the Google consent screen and redirects back to Uri.base.origin.
      // SplashScreen / restoreSession() will intercept the returned session and navigate to dashboard.
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Google Sign-In: ${e.toString().replaceAll("Exception: ", "")}"),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  // Handle Primary Login Submission based on active method
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = AuthService();

      switch (_selectedMethod) {
        case AuthMethod.emailPassword:
          final user = await authService.login(
            identifier: _emailController.text.trim(),
            password: _passwordController.text,
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Welcome back, ${user.fullName} (${user.role.toUpperCase()})!"),
                backgroundColor: AppColors.success,
                duration: const Duration(seconds: 2),
              ),
            );
            _routeToDashboard(user);
          }
          break;

        case AuthMethod.emailOtp:
          final email = _emailController.text.trim();
          await authService.sendEmailOTP(email);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("8-digit OTP sent to $email. Check your inbox!"),
                backgroundColor: AppColors.primaryGreen,
                duration: const Duration(seconds: 6),
              ),
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OtpVerificationScreen(
                  email: email,
                  purpose: 'login',
                  channel: 'email',
                  otpLength: 8,
                ),
              ),
            );
          }
          break;

        case AuthMethod.phoneOtp:
          final phone = _phoneController.text.trim();
          final res = await authService.sendOTP(phone: phone, purpose: 'login', channel: 'sms');
          if (mounted) {
            final devOtp = res['otp'];
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(devOtp != null
                    ? "SMS OTP for $phone: $devOtp"
                    : "6-digit SMS OTP sent to $phone"),
                backgroundColor: AppColors.primaryGreen,
                duration: const Duration(seconds: 8),
              ),
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OtpVerificationScreen(
                  phoneNumber: phone,
                  purpose: 'login',
                  channel: 'phone',
                  otpLength: 6,
                ),
              ),
            );
          }
          break;

        case AuthMethod.whatsappOtp:
          final phone = _phoneController.text.trim();
          final res = await authService.sendOTP(phone: phone, purpose: 'login', channel: 'whatsapp');
          if (mounted) {
            final devOtp = res['otp'];
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(devOtp != null
                    ? "WhatsApp OTP for $phone: $devOtp"
                    : "6-digit WhatsApp OTP sent to $phone"),
                backgroundColor: const Color(0xFF25D366),
                duration: const Duration(seconds: 8),
              ),
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OtpVerificationScreen(
                  phoneNumber: phone,
                  purpose: 'login',
                  channel: 'whatsapp',
                  otpLength: 6,
                ),
              ),
            );
          }
          break;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll("Exception: ", "")),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Open Bottom Sheet to select registered account and autofill credentials
  void _openAccountPickerSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.65,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Select Registered Account",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Text(
                "Tap an account to autofill credentials directly from Supabase:",
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const Divider(height: 24),
              Expanded(
                child: _registeredAccounts.isEmpty
                    ? const Center(child: Text("No registered accounts found."))
                    : ListView.separated(
                        itemCount: _registeredAccounts.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final acc = _registeredAccounts[index];
                          final email = acc['email'] ?? '';
                          final name = acc['full_name'] ?? 'User';
                          final role = (acc['user_role'] ?? 'USER').toString().toUpperCase();
                          final pwd = acc['demo_password'] ?? '';

                          Color roleColor;
                          switch (role.toLowerCase()) {
                            case 'farmer':
                              roleColor = Colors.green.shade700;
                              break;
                            case 'aggregator':
                              roleColor = Colors.orange.shade800;
                              break;
                            case 'delivery':
                              roleColor = Colors.blue.shade700;
                              break;
                            case 'admin':
                              roleColor = Colors.purple.shade700;
                              break;
                            default:
                              roleColor = Colors.teal.shade700;
                              break;
                          }

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                            leading: CircleAvatar(
                              backgroundColor: roleColor.withValues(alpha: 0.15),
                              child: Text(
                                name.isNotEmpty ? name[0] : 'U',
                                style: TextStyle(fontWeight: FontWeight.bold, color: roleColor),
                              ),
                            ),
                            title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text(email, style: const TextStyle(fontSize: 12)),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: roleColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: roleColor.withValues(alpha: 0.4)),
                              ),
                              child: Text(
                                role,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: roleColor,
                                ),
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(ctx);
                              setState(() {
                                _selectedMethod = AuthMethod.emailPassword;
                                _emailController.text = email;
                                _passwordController.text = pwd;
                                _detectedRole = role;
                                _autofillStatus = "Autofilled credentials for [$role]";
                              });
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMethodTab({
    required AuthMethod method,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedMethod == method;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedMethod = method),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: isSelected
                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 4, offset: const Offset(0, 2))]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? AppColors.primaryGreen : AppColors.textSecondary,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? AppColors.text : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getSubmitButtonLabel(LanguageProvider langProvider) {
    switch (_selectedMethod) {
      case AuthMethod.emailPassword:
        return langProvider.translate('login');
      case AuthMethod.emailOtp:
        return "Send 8-Digit Email OTP";
      case AuthMethod.phoneOtp:
        return "Send 6-Digit SMS OTP";
      case AuthMethod.whatsappOtp:
        return "Send 6-Digit WhatsApp OTP";
    }
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),
                  const Icon(
                    Icons.agriculture,
                    size: 70,
                    color: AppColors.primaryGreen,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    langProvider.translate('welcome_back'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    langProvider.translate('login_continue'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ─────────────────────────────────────────────
                  // 4-METHOD AUTHENTICATION SELECTOR
                  // ─────────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.greyLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        _buildMethodTab(
                          method: AuthMethod.emailPassword,
                          label: "Email & PW",
                          icon: Icons.lock_outline,
                        ),
                        _buildMethodTab(
                          method: AuthMethod.emailOtp,
                          label: "Email OTP",
                          icon: Icons.mark_email_read_outlined,
                        ),
                        _buildMethodTab(
                          method: AuthMethod.phoneOtp,
                          label: "Phone SMS",
                          icon: Icons.sms_outlined,
                        ),
                        _buildMethodTab(
                          method: AuthMethod.whatsappOtp,
                          label: "WhatsApp",
                          icon: Icons.chat_bubble_outline,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Quick Account Picker (for Email & PW)
                  if (_selectedMethod == AuthMethod.emailPassword) ...[
                    OutlinedButton.icon(
                      onPressed: _openAccountPickerSheet,
                      icon: const Icon(Icons.key, color: AppColors.primaryGreen, size: 18),
                      label: const Text(
                        "Select Saved Account (Autofill Password)",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        side: const BorderSide(color: AppColors.primaryGreen, width: 1.1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.04),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // ─────────────────────────────────────────────
                  // INPUT FIELDS BY SELECTED METHOD
                  // ─────────────────────────────────────────────
                  if (_selectedMethod == AuthMethod.phoneOtp || _selectedMethod == AuthMethod.whatsappOtp) ...[
                    VoiceInputField(
                      controller: _phoneController,
                      hintText: langProvider.translate('phone_number'),
                      prefixIcon: _selectedMethod == AuthMethod.whatsappOtp
                          ? Icons.chat_bubble_outline
                          : Icons.phone,
                      keyboardType: TextInputType.phone,
                      validator: (val) => Validators.validatePhone(val),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _selectedMethod == AuthMethod.whatsappOtp
                          ? "Enter your 10-digit phone number to receive a 6-digit WhatsApp OTP."
                          : "Enter your 10-digit phone number to receive a 6-digit SMS OTP.",
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ] else ...[
                    // Email Input Field
                    TextFormField(
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) => Validators.validateEmail(val),
                      onChanged: (val) {
                        if (_selectedMethod == AuthMethod.emailPassword && val.contains('@') && val.contains('.')) {
                          _autofillPasswordFromDb(val);
                        }
                      },
                      decoration: InputDecoration(
                        hintText: langProvider.translate('email'),
                        prefixIcon: const Icon(Icons.email_outlined),
                        suffixIcon: _isAutofilling
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : (_selectedMethod == AuthMethod.emailPassword
                                ? IconButton(
                                    icon: const Icon(Icons.search, size: 20),
                                    tooltip: "Search password in database",
                                    onPressed: () => _autofillPasswordFromDb(_emailController.text),
                                  )
                                : null),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Password Input Field (Only for Email & PW)
                    if (_selectedMethod == AuthMethod.emailPassword) ...[
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        validator: (val) {
                          if (val == null || val.isEmpty) return "Please enter password";
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: langProvider.translate('password'),
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                      ),
                    ] else ...[
                      // Helper banner for Email OTP
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                "An 8-digit OTP will be delivered directly to your Gmail inbox via Gmail SMTP.",
                                style: TextStyle(fontSize: 11, color: Colors.blueGrey),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Autofill Status Badge
                    if (_selectedMethod == AuthMethod.emailPassword && _autofillStatus != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, size: 16, color: Colors.green.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _autofillStatus!,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],

                  const SizedBox(height: 20),

                  // Submit Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            _getSubmitButtonLabel(langProvider),
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                  ),

                  const SizedBox(height: 18),

                  // ─────────────────────────────────────────────
                  // OR DIVIDER
                  // ─────────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text(
                          "OR",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // ─────────────────────────────────────────────
                  // GOOGLE SIGN-IN BUTTON (Supabase OAuth Web / Chrome)
                  // ─────────────────────────────────────────────
                  OutlinedButton(
                    onPressed: (_isLoading || _isGoogleLoading) ? null : _handleGoogleSignIn,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      side: BorderSide(color: Colors.grey.shade300, width: 1.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      backgroundColor: Colors.white,
                    ),
                    child: _isGoogleLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.network(
                                'https://www.gstatic.com/images/branding/product/2x/googleg_48dp.png',
                                width: 20,
                                height: 20,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.g_mobiledata,
                                  color: Colors.blue,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                "Continue with Google",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                  ),

                  const SizedBox(height: 22),

                  // Don't have an account? Register link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(langProvider.translate('dont_have_account')),
                      TextButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RegisterScreen()),
                          );
                          // If user registered, auto-fill credentials
                          if (result != null && result is Map) {
                            setState(() {
                              _selectedMethod = AuthMethod.emailPassword;
                              _emailController.text = result['email'] ?? '';
                              _passwordController.text = result['password'] ?? '';
                              _detectedRole = (result['role'] ?? 'USER').toString().toUpperCase();
                              _autofillStatus = "Registered as [$_detectedRole]! Password autofilled from database.";
                            });
                            _loadAccountsFromDb();
                          }
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
      ),
    );
  }
}
