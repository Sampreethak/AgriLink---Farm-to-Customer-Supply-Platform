import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;

  StorageService._internal();

  final _secureStorage = const FlutterSecureStorage();

  // Secure Storage keys
  static const String _keyToken = 'auth_token';
  static const String _keyRefreshToken = 'refresh_token';

  // Save Token
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _keyToken, value: token);
  }

  // Get Token
  Future<String?> getToken() async {
    return await _secureStorage.read(key: _keyToken);
  }

  // Delete Token
  Future<void> deleteToken() async {
    await _secureStorage.delete(key: _keyToken);
  }

  // Save Refresh Token
  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: _keyRefreshToken, value: token);
  }

  // Get Refresh Token
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _keyRefreshToken);
  }

  // Delete Refresh Token
  Future<void> deleteRefreshToken() async {
    await _secureStorage.delete(key: _keyRefreshToken);
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

  // Clear all storage on logout
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_name');
    await prefs.remove('user_phone');
    await prefs.remove('user_role');
    await prefs.remove('user_id');
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
