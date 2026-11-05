import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/colors.dart';
import '../../services/auth_service.dart';
import '../../services/user_registry.dart';
import '../language/language_selection_screen.dart';
import '../auth/login_screen.dart';
import '../customer/customer_dashboard.dart';
import '../farmer/farmer_dashboard.dart';
import '../aggregator/aggregator_dashboard.dart';
import '../delivery/delivery_dashboard.dart';
import '../admin/admin_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  StreamSubscription<AuthState>? _authSub;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    // Listen for OAuth redirects (e.g. Google Sign-In on Chrome)
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final session = data.session;
      if (session != null && mounted && !_hasNavigated) {
        final authService = AuthService();
        final user = await authService.restoreSession();
        if (user != null && mounted && !_hasNavigated) {
          _hasNavigated = true;
          _routeToDashboard(user);
        }
      }
    });
    _initApp();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  Future<void> _initApp() async {
    // Show splash for at least 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted || _hasNavigated) return;

    // Try to restore an existing Supabase session
    try {
      final authService = AuthService();
      final user = await authService.restoreSession();

      if (!mounted || _hasNavigated) return;

      if (user != null) {
        _hasNavigated = true;
        _routeToDashboard(user);
        return;
      }
    } catch (_) {
      // No session or Supabase not reachable — continue to language selection
    }

    if (!mounted || _hasNavigated) return;
    _hasNavigated = true;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LanguageSelectionScreen()),
    );
  }

  void _routeToDashboard(AppUserModel user) {
    Widget target;
    switch (user.role.toLowerCase()) {
      case 'farmer':
        target = const FarmerDashboard();
        break;
      case 'aggregator':
        target = const AggregatorDashboard();
        break;
      case 'delivery':
        target = const DeliveryDashboard();
        break;
      case 'admin':
        target = const AdminDashboard();
        break;
      case 'customer':
      default:
        target = const CustomerDashboard();
        break;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => target),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryGreen,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.agriculture, color: Colors.white, size: 110),
            SizedBox(height: 20),
            Text(
              'AgriLink',
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Connecting Farmers to Customers',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            SizedBox(height: 50),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
