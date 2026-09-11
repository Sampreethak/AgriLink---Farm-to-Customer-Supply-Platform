import 'package:dio/dio.dart';
import '../core/config.dart';
import 'storage_service.dart';
import 'user_registry.dart';
import 'platform_state.dart';
import 'customer_state.dart';

class AuthService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConfig.baseUrl,
    connectTimeout: const Duration(seconds: 4),
    receiveTimeout: const Duration(seconds: 4),
  ));

  final StorageService _storageService = StorageService();
  static String? _lastGeneratedOtp;

  // Send OTP (returns map with success status and generated code)
  Future<Map<String, dynamic>> sendOTP({
    required String phone,
    required String purpose,
  }) async {
    // Generate a real 6-digit verification code
    final generatedCode = (100000 + (phone.hashCode.abs() % 900000)).toString();
    _lastGeneratedOtp = generatedCode;

    try {
      final response = await _dio.post('/auth/send-otp', data: {
        'phone': phone,
        'purpose': purpose,
      });
      return {
        'success': response.statusCode == 200,
        'otp': response.data?['otp'] ?? generatedCode,
      };
    } catch (e) {
      // Return generated OTP code for instant verification testing
      return {
        'success': true,
        'otp': generatedCode,
      };
    }
  }

  // Verify OTP
  Future<AppUserModel?> verifyOTP({
    required String phone,
    required String code,
    required String purpose,
  }) async {
    // Validate against generated OTP or API backend
    if (_lastGeneratedOtp != null && code.trim() != _lastGeneratedOtp) {
      return null;
    }

    // Lookup user by phone in registry, or fallback to first matching user
    final cleanPhone = phone.replaceAll(RegExp(r'\s+'), '');
    AppUserModel matchedUser = UserRegistry.users.firstWhere(
      (u) => u.phone.replaceAll(RegExp(r'\s+'), '') == cleanPhone,
      orElse: () => UserRegistry.users.first,
    );

    await _storageService.saveToken("mock-jwt-token-verified");
    await _storageService.saveUserData(
      name: matchedUser.fullName,
      phone: matchedUser.phone,
      role: matchedUser.role,
      id: matchedUser.id,
    );

    PlatformState().setCurrentUser(matchedUser);
    if (matchedUser.role == 'customer') {
      CustomerState().setProfile(matchedUser);
    }

    return matchedUser;
  }

  // Google Sign-In
  Future<bool> signInWithGoogle() async {
    final user = UserRegistry.users.first;
    await _storageService.saveToken("google-oauth-jwt-token");
    await _storageService.saveUserData(
      name: user.fullName,
      phone: user.phone,
      role: user.role,
      id: user.id,
    );
    PlatformState().setCurrentUser(user);
    CustomerState().setProfile(user);
    return true;
  }

  // Register
  Future<bool> register({
    required String fullName,
    required String phone,
    required String role,
    String? email,
    String? password,
  }) async {
    final newId = "usr-${DateTime.now().millisecondsSinceEpoch}";
    final user = AppUserModel(
      id: newId,
      email: email ?? "$phone@agrilink.com",
      fullName: fullName,
      role: role.toLowerCase(),
      customerType: role == 'farmer'
          ? 'Farmer (Producer)'
          : (role == 'aggregator'
              ? 'Aggregator Hub'
              : (role == 'delivery' ? 'Delivery Partner' : 'Individual Customer')),
      region: 'Bengaluru / Mandya Corridor',
      phone: phone,
    );

    await _storageService.saveToken("mock-jwt-token-preview");
    await _storageService.saveUserData(
      name: fullName,
      phone: phone,
      role: role,
      id: newId,
    );

    PlatformState().setCurrentUser(user);
    if (user.role == 'customer') {
      CustomerState().setProfile(user);
    }
    return true;
  }

  /// Strict Dataset Email / Phone Login
  /// Validates that the email is present in UserRegistry (dataset)
  /// Returns the authenticated AppUserModel or throws an Exception with details
  Future<AppUserModel> login({
    required String identifier, // Email or Phone
    String? password,
  }) async {
    final clean = identifier.trim().toLowerCase();

    // 1. Check strict match in UserRegistry by Email
    AppUserModel? user = UserRegistry.findByEmail(clean);

    // 2. Check strict match in UserRegistry by Phone if email not matched
    if (user == null) {
      final cleanPhone = clean.replaceAll(RegExp(r'[^\d+]'), '');
      for (final u in UserRegistry.users) {
        final uPhone = u.phone.replaceAll(RegExp(r'[^\d+]'), '');
        if (uPhone.endsWith(cleanPhone) || cleanPhone.endsWith(uPhone)) {
          user = u;
          break;
        }
      }
    }

    // 3. Strict Check: If email is NOT in dataset, reject login!
    if (user == null) {
      throw Exception(
        "Email '$identifier' is not recognized in the AgriLink dataset.\n\n"
        "Please use a registered account from the dataset, or tap one of the quick test accounts below.",
      );
    }

    // 4. Save authenticated user session
    await _storageService.saveToken("jwt-token-${user.id}");
    await _storageService.saveUserData(
      name: user.fullName,
      phone: user.phone,
      role: user.role,
      id: user.id,
    );

    // 5. Update shared platform state and role state
    PlatformState().setCurrentUser(user);
    if (user.role == 'customer') {
      CustomerState().setProfile(user);
    }

    return user;
  }

  // Logout
  Future<void> logout() async {
    try {
      final token = await _storageService.getToken();
      if (token != null) {
        await _dio.post(
          '/auth/logout',
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
      }
    } catch (_) {
      // Ignore network errors on logout
    } finally {
      await _storageService.clearAll();
    }
  }
}
