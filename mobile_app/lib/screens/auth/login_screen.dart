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

  bool _isPhoneLogin = false;
  bool _isLoading = false;
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

  // Handle Login submission
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = AuthService();

      if (_isPhoneLogin) {
        final result = await authService.sendOTP(
          phone: _phoneController.text.trim(),
          purpose: 'login',
        );
        if (result['success'] == true && mounted) {
          final otpCode = result['otp'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(otpCode != null
                  ? "OTP for ${_phoneController.text.trim()}: $otpCode"
                  : "OTP sent to ${_phoneController.text.trim()}"),
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
        // Authenticate via Supabase Auth
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.75,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Autofill Credentials",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Text(
                "Tap any registered account below to automatically fill email and password from the database:",
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 16),
              if (_registeredAccounts.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Center(
                    child: Text(
                      "No accounts in database yet. Register a new account below!",
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _registeredAccounts.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (c, idx) {
                      final acc = _registeredAccounts[idx];
                      final role = (acc['user_role'] ?? 'CUSTOMER').toString().toUpperCase();
                      final email = acc['email'] ?? '';
                      final name = acc['full_name'] ?? email;
                      final pwd = acc['demo_password'] ?? '';

                      Color badgeColor = AppColors.primaryGreen;
                      IconData roleIcon = Icons.person;

                      if (role.contains('FARM')) {
                        badgeColor = Colors.green.shade800;
                        roleIcon = Icons.agriculture;
                      } else if (role.contains('AGGR')) {
                        badgeColor = Colors.orange.shade800;
                        roleIcon = Icons.store;
                      } else if (role.contains('DELIV')) {
                        badgeColor = Colors.blue.shade800;
                        roleIcon = Icons.local_shipping;
                      } else if (role.contains('ADMIN')) {
                        badgeColor = Colors.purple.shade800;
                        roleIcon = Icons.admin_panel_settings;
                      }

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        leading: CircleAvatar(
                          backgroundColor: badgeColor.withValues(alpha: 0.15),
                          child: Icon(roleIcon, color: badgeColor, size: 22),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: badgeColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
                              ),
                              child: Text(
                                role,
                                style: TextStyle(
                                  color: badgeColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 2),
                            Text(email, style: const TextStyle(fontSize: 13)),
                            const SizedBox(height: 2),
                            Text(
                              "Password: ●●●●●●●● (${pwd.isNotEmpty ? 'ready' : 'none'})",
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.pop(ctx);
                          setState(() {
                            _emailController.text = email;
                            _passwordController.text = pwd;
                            _detectedRole = role;
                            _autofillStatus = "Password autofilled from database for [$role]";
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
                const SizedBox(height: 25),
                const Icon(
                  Icons.agriculture,
                  size: 75,
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

                // Toggle: Email & Password vs Phone OTP
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
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            decoration: BoxDecoration(
                              color: !_isPhoneLogin ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: !_isPhoneLogin
                                  ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))]
                                  : null,
                            ),
                            child: const Text(
                              "Email & PW",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.text),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isPhoneLogin = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            decoration: BoxDecoration(
                              color: _isPhoneLogin ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: _isPhoneLogin
                                  ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))]
                                  : null,
                            ),
                            child: const Text(
                              "Phone OTP",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.text),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // ─────────────────────────────────────────────
                // QUICK AUTOFILL ACCOUNT SELECTOR BUTTON
                // ─────────────────────────────────────────────
                if (!_isPhoneLogin)
                  OutlinedButton.icon(
                    onPressed: _openAccountPickerSheet,
                    icon: const Icon(Icons.key, color: AppColors.primaryGreen, size: 20),
                    label: const Text(
                      "Select Saved Account (Autofill Password)",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: AppColors.primaryGreen, width: 1.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.04),
                    ),
                  ),

                const SizedBox(height: 16),

                if (_isPhoneLogin) ...[
                  VoiceInputField(
                    controller: _phoneController,
                    hintText: langProvider.translate('phone_number'),
                    prefixIcon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    validator: (val) => Validators.validatePhone(val),
                  ),
                ] else ...[
                  // Email Input Field
                  TextFormField(
                    controller: _emailController,
                    focusNode: _emailFocusNode,
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) => Validators.validateEmail(val),
                    onChanged: (val) {
                      if (val.contains('@') && val.contains('.')) {
                        _autofillPasswordFromDb(val);
                      }
                    },
                    decoration: InputDecoration(
                      hintText: langProvider.translate('email'),
                      prefixIcon: const Icon(Icons.email),
                      suffixIcon: _isAutofilling
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: Padding(
                                padding: EdgeInsets.all(12.0),
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : IconButton(
                              icon: const Icon(Icons.search, size: 20),
                              tooltip: "Search password in database",
                              onPressed: () => _autofillPasswordFromDb(_emailController.text),
                            ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Password Input Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    validator: (val) {
                      if (val == null || val.isEmpty) return "Please enter password";
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: langProvider.translate('password'),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),

                  // Autofill Status Badge
                  if (_autofillStatus != null) ...[
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

                const SizedBox(height: 22),

                // Submit Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          _isPhoneLogin ? "Send OTP" : langProvider.translate('login'),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),

                const SizedBox(height: 25),

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
                        // If user registered, auto-fill the email and password immediately
                        if (result != null && result is Map) {
                          setState(() {
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
                        style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
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
