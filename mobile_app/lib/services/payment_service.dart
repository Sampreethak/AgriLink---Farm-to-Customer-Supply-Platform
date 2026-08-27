import 'package:dio/dio.dart';
import '../core/config.dart';
import 'storage_service.dart';

class PaymentService {
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

  // Create Razorpay order on backend
  Future<Map<String, dynamic>> createRazorpayOrder({
    required String orderId,
    required double amount,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.post(
        '/payments/create-order',
        data: {'order_id': orderId, 'amount': amount},
        options: Options(headers: headers),
      );
      return response.data ?? {};
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // Verify Razorpay payment signature
  Future<bool> verifyPayment({
    required String orderId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.post(
        '/payments/verify',
        data: {
          'order_id': orderId,
          'razorpay_order_id': razorpayOrderId,
          'razorpay_payment_id': razorpayPaymentId,
          'razorpay_signature': razorpaySignature,
        },
        options: Options(headers: headers),
      );
      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // Initiate Refund (Admin only)
  Future<Map<String, dynamic>> initiateRefund(String orderId) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.post(
        '/payments/refund/$orderId',
        options: Options(headers: headers),
      );
      return response.data ?? {};
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
