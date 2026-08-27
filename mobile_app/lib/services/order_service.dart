import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../core/config.dart';
import 'storage_service.dart';

class OrderService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConfig.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
  ));

  final StorageService _storageService = StorageService();

  Future<Map<String, dynamic>> _getHeaders() async {
    final token = await _storageService.getToken();
    return {
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Get customer cart
  Future<Map<String, dynamic>> getCart() async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get('/orders/cart', options: Options(headers: headers));
      return response.data ?? {'items': [], 'subtotal': 0.0};
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // Add/Update cart item
  Future<bool> addToCart(String productId, double quantity) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.post(
        '/orders/cart',
        data: {'product_id': productId, 'quantity': quantity},
        options: Options(headers: headers),
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // Remove from cart
  Future<bool> removeFromCart(String productId) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.delete(
        '/orders/cart/$productId',
        options: Options(headers: headers),
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // Clear cart
  Future<bool> clearCart() async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.delete(
        '/orders/cart',
        options: Options(headers: headers),
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // Place Order
  Future<Map<String, dynamic>> placeOrder({
    required String deliveryAddressId,
    String? couponId,
    String? specialInstructions,
    String? expectedDeliveryDate,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.post(
        '/orders',
        data: {
          'delivery_address_id': deliveryAddressId,
          if (couponId != null) 'coupon_id': couponId,
          if (specialInstructions != null) 'special_instructions': specialInstructions,
          if (expectedDeliveryDate != null) 'expected_delivery_date': expectedDeliveryDate,
        },
        options: Options(headers: headers),
      );
      return response.data ?? {};
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // Get Customer Orders
  Future<List<dynamic>> getCustomerOrders({String? status}) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '/orders',
        queryParameters: {
          if (status != null) 'status': status,
        },
        options: Options(headers: headers),
      );
      return response.data ?? [];
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // Get Order details by ID
  Future<Map<String, dynamic>> getOrderById(String orderId) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get('/orders/$orderId', options: Options(headers: headers));
      return response.data ?? {};
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // Get Farmer Order items
  Future<List<dynamic>> getFarmerOrders() async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get('/orders/farmer/list', options: Options(headers: headers));
      return response.data ?? [];
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // Update order status (Admin/Delivery partner only)
  Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.patch(
        '/orders/$orderId/status',
        data: {'status': status},
        options: Options(headers: headers),
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // Cancel order
  Future<bool> cancelOrder(String orderId) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.post(
        '/orders/$orderId/cancel',
        options: Options(headers: headers),
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // Download Invoice PDF
  Future<String> downloadInvoicePDF(String invoiceNumber) async {
    try {
      final token = await _storageService.getToken();
      final url = '${AppConfig.baseUrl}/invoices/$invoiceNumber/download';

      // For Mobile platforms, download to local app directory
      // For Web, direct them to the URL with the authentication token in a query parameter or header
      // Since it's web-safe, we can download raw bytes and return a path (or trigger local save)
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/invoice_$invoiceNumber.pdf';

      await _dio.download(
        url,
        filePath,
        options: Options(
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );

      return filePath;
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
