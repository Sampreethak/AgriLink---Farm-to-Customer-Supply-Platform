import 'package:dio/dio.dart';
import '../core/config.dart';
import 'storage_service.dart';

class UserService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConfig.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  final StorageService _storageService = StorageService();

  Future<Map<String, dynamic>> _getHeaders() async {
    final token = await _storageService.getToken();
    return {
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Get user profile
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get('/users/profile', options: Options(headers: headers));
      return response.data ?? {};
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // Update profile
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.put(
        '/users/profile',
        data: data,
        options: Options(headers: headers),
      );
      return response.data ?? {};
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // Get addresses
  Future<List<dynamic>> getAddresses() async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get('/users/addresses', options: Options(headers: headers));
      return response.data ?? [];
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // Add address
  Future<Map<String, dynamic>> addAddress(Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.post(
        '/users/addresses',
        data: data,
        options: Options(headers: headers),
      );
      return response.data ?? {};
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // Set default address
  Future<bool> setDefaultAddress(String addressId) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.patch(
        '/users/addresses/$addressId/default',
        options: Options(headers: headers),
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // Get Farmer Dashboard view
  Future<Map<String, dynamic>> getFarmerDashboard() async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get('/users/farmer/dashboard', options: Options(headers: headers));
      return response.data ?? {};
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // Get Admin Analytics view
  Future<Map<String, dynamic>> getAdminAnalytics() async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get('/users/admin/analytics', options: Options(headers: headers));
      return response.data ?? {};
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // Get notifications
  Future<List<dynamic>> getNotifications() async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get('/users/notifications', options: Options(headers: headers));
      return response.data ?? [];
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // Mark notification read
  Future<bool> markNotificationRead(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.patch(
        '/users/notifications/$id/read',
        options: Options(headers: headers),
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  String _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response != null && error.response?.data != null) {
        return error.response?.data['error'] ?? 'Server error';
      }
      return error.message ?? 'Network connection failed';
    }
    return error.toString();
  }
}
