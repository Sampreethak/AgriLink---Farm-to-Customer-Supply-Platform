import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;

  StorageService._internal();

  final _secureStorage = const FlutterSecureStorage();

  // Storage keys
  static const String _keyToken = 'auth_token';
  static const String _keyRefreshToken = 'refresh_token';

  // Save Token (safe on Web and HTTP without crypto.subtle errors)
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    if (!kIsWeb) {
      try {
        await _secureStorage.write(key: _keyToken, value: token);
      } catch (_) {}
    }
  }

  // Get Token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_keyToken);
    if (token != null && token.isNotEmpty) return token;
    if (!kIsWeb) {
      try {
        return await _secureStorage.read(key: _keyToken);
      } catch (_) {}
    }
    return null;
  }

  // Delete Token
  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    if (!kIsWeb) {
      try {
        await _secureStorage.delete(key: _keyToken);
      } catch (_) {}
    }
  }

  // Save Refresh Token
  Future<void> saveRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyRefreshToken, token);
    if (!kIsWeb) {
      try {
        await _secureStorage.write(key: _keyRefreshToken, value: token);
      } catch (_) {}
    }
  }

  // Get Refresh Token
  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_keyRefreshToken);
    if (token != null && token.isNotEmpty) return token;
    if (!kIsWeb) {
      try {
        return await _secureStorage.read(key: _keyRefreshToken);
      } catch (_) {}
    }
    return null;
  }

  // Delete Refresh Token
  Future<void> deleteRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyRefreshToken);
    if (!kIsWeb) {
      try {
        await _secureStorage.delete(key: _keyRefreshToken);
      } catch (_) {}
    }
  }

  // Save user details
  Future<void> saveUserData({
    required String name,
    required String phone,
    required String role,
    required String id,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    await prefs.setString('user_phone', phone);
    await prefs.setString('user_role', role);
    await prefs.setString('user_id', id);
  }

  // Save demo password for autofill fallback
  Future<void> saveSavedPassword(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_pwd_${email.toLowerCase().trim()}', password);
    await prefs.setString('last_logged_in_email', email.toLowerCase().trim());
  }

  // Get demo password for autofill fallback
  Future<String?> getSavedPassword(String email) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('saved_pwd_${email.toLowerCase().trim()}');
  }

  // Get last logged in email
  Future<String?> getLastEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('last_logged_in_email');
  }

  // Save target Google role selected before OAuth redirect
  Future<void> saveTargetGoogleRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('google_login_target_role', role);
  }

  // Get target Google role after OAuth redirect
  Future<String?> getTargetGoogleRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('google_login_target_role');
  }

  // Clear target Google role
  Future<void> clearTargetGoogleRole() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('google_login_target_role');
  }

  // Clear all storage on logout
  Future<void> clearAll() async {
    if (!kIsWeb) {
      try {
        await _secureStorage.deleteAll();
      } catch (_) {}
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyRefreshToken);
    await prefs.remove('user_name');
    await prefs.remove('user_phone');
    await prefs.remove('user_role');
    await prefs.remove('user_id');
    await prefs.remove('google_login_target_role');
  }

  Future<Map<String, String?>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('user_name'),
      'phone': prefs.getString('user_phone'),
      'role': prefs.getString('user_role'),
      'id': prefs.getString('user_id'),
    };
  }
}
