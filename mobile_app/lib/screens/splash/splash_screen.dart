import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/colors.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../../services/web_auth_redirect.dart';
import '../../services/platform_state.dart';
import '../../services/customer_state.dart';
import '../../services/user_registry.dart';
import '../language/language_selection_screen.dart';
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

  /// Check if the current URL contains an OAuth callback token (web only)
  bool _isOAuthCallback() {
    if (!kIsWeb) return false;
    try {
      final uri = Uri.base;
      final fragment = uri.fragment;
      final query = uri.queryParametersAll;
      // Supabase OAuth returns tokens in the hash fragment or query params
      return fragment.contains('access_token') ||
          fragment.contains('refresh_token') ||
          query.containsKey('code') ||
          query.containsKey('access_token');
    } catch (_) {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    // Listen for OAuth redirects (e.g. Google Sign-In on Chrome)
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      final session = data.session;
      if (session != null && mounted && !_hasNavigated) {
        if (event == AuthChangeEvent.signedIn ||
            event == AuthChangeEvent.tokenRefreshed ||
            event == AuthChangeEvent.initialSession) {
          try {
            final authService = AuthService();
            final user = await authService.restoreSession();
            if (user != null && mounted && !_hasNavigated) {
              _hasNavigated = true;
              _routeToDashboard(user);
            }
          } catch (e) {
            debugPrint('[OAuth Redirect Error]: $e');
          }
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
    // Show splash for at least 1.2 seconds
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted || _hasNavigated) return;

    final storage = StorageService();
    final targetRole = await storage.getTargetGoogleRole();

    // 1. Check if returning from Google OAuth redirect or if URL has OAuth callback tokens
    if (_isOAuthCallback() || targetRole != null) {
      final authService = AuthService();

      // (A) Direct PKCE Code Exchange on Web
      if (kIsWeb) {
        final uri = Uri.base;
        final code = uri.queryParameters['code'];
        if (code != null && code.isNotEmpty) {
          try {
            final res = await Supabase.instance.client.auth.exchangeCodeForSession(code);
            final sbUser = res.session.user;
            final user = await authService.buildUserFromSupabaseUser(sbUser);
            clearUrlHashOnWeb();
            if (mounted && !_hasNavigated) {
              _hasNavigated = true;
              _routeToDashboard(user);
              return;
            }
          } catch (e) {
            debugPrint('[exchangeCodeForSession Error]: $e');
          }
        }
      }

      // (B) Check if Supabase client already initialized an active session
      final activeSession = Supabase.instance.client.auth.currentSession;
      if (activeSession != null) {
        try {
          final user = await authService.buildUserFromSupabaseUser(activeSession.user);
          clearUrlHashOnWeb();
          if (mounted && !_hasNavigated) {
            _hasNavigated = true;
            _routeToDashboard(user);
            return;
          }
        } catch (_) {}
      }

      // (C) Poll session resolution for up to 6 cycles
      for (int i = 0; i < 6; i++) {
        await Future.delayed(const Duration(milliseconds: 300));
        if (!mounted || _hasNavigated) return;
        try {
          final user = await authService.restoreSession();
          if (user != null && mounted && !_hasNavigated) {
            clearUrlHashOnWeb();
            _hasNavigated = true;
            _routeToDashboard(user);
            return;
          }
        } catch (_) {}
      }

      // (D) Direct JWT Extraction from URL hash or current Supabase Auth user
      try {
        final uri = Uri.base;
        String? token;
        final fragment = uri.fragment;
        for (final part in fragment.split('&')) {
          if (part.startsWith('access_token=')) {
            token = part.substring('access_token='.length);
            break;
          }
        }
        if (token == null && uri.queryParameters.containsKey('access_token')) {
          token = uri.queryParameters['access_token'];
        }

        final role = targetRole ?? 'customer';
        final sbUser = Supabase.instance.client.auth.currentUser;
        String email = sbUser?.email ?? 'google.user@agrilink.com';
        String fullName = sbUser?.userMetadata?['full_name']?.toString() ??
            sbUser?.userMetadata?['name']?.toString() ??
            (email.isNotEmpty && !email.startsWith('google.user@') ? email.split('@').first : 'AgriLink Member');
        String uid = sbUser?.id ?? 'usr-google-${DateTime.now().millisecondsSinceEpoch}';

        if (token != null && token.isNotEmpty) {
          try {
            final parts = token.split('.');
            if (parts.length == 3) {
              var payload = parts[1];
              while (payload.length % 4 != 0) {
                payload += '=';
              }
              final jsonStr = utf8.decode(base64Url.decode(payload));
              final data = json.decode(jsonStr) as Map<String, dynamic>;
              if (data['email'] != null) email = data['email'].toString();
              if (data['sub'] != null) uid = data['sub'].toString();
              final meta = (data['user_metadata'] as Map<String, dynamic>?) ?? {};
              if (meta['full_name'] != null && meta['full_name'].toString().isNotEmpty) {
                fullName = meta['full_name'].toString();
              } else if (meta['name'] != null && meta['name'].toString().isNotEmpty) {
                fullName = meta['name'].toString();
              } else if (email.contains('@')) {
                fullName = email.split('@').first;
              }
            }
          } catch (_) {}
        }

        // Persist user directly to AWS RDS PostgreSQL
        await authService.syncProfileToAwsRds(
          id: uid,
          email: email,
          fullName: fullName,
          role: role,
          location: 'Bengaluru / Mandya Corridor',
          authProvider: 'google',
        );

        final user = AppUserModel(
          id: uid,
          email: email,
          fullName: fullName,
          role: role,
          customerType: role == 'farmer' ? 'Farmer (Producer)' : 'Individual Customer',
          region: 'Bengaluru / Mandya Corridor',
          phone: '',
        );

        await storage.saveUserData(
          name: fullName,
          phone: '',
          role: role,
          id: uid,
        );
        if (token != null) await storage.saveToken(token);
        await storage.clearTargetGoogleRole();
        clearUrlHashOnWeb();

        PlatformState().setCurrentUser(user);
        if (role == 'customer') CustomerState().setProfile(user);

        if (mounted && !_hasNavigated) {
          _hasNavigated = true;
          _routeToDashboard(user);
          return;
        }
      } catch (e) {
        debugPrint('[Direct OAuth Token Parse Error]: $e');
      }
    }

    // 2. Normal launch: Try to restore an existing session (Supabase or cached StorageService)
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
      // Continue to language selection
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
    final r = AuthService.normalizeRole(user.role);
    switch (r) {
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
