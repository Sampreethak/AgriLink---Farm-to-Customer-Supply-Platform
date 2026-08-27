import 'package:dio/dio.dart';
import '../core/config.dart';
import 'storage_service.dart';

class ProductService {
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

  // Get all active categories
  Future<List<dynamic>> getCategories() async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get('/products/categories', options: Options(headers: headers));
      return response.data ?? [];
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // Fetch product list with pagination and filters
  Future<Map<String, dynamic>> getProducts({
    String? category,
    String? search,
    double? minPrice,
    double? maxPrice,
    bool? organic,
    String? sort,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '/products',
        queryParameters: {
          if (category != null) 'category': category,
          if (search != null) 'search': search,
          if (minPrice != null) 'min_price': minPrice,
          if (maxPrice != null) 'max_price': maxPrice,
          if (organic != null) 'organic': organic,
          if (sort != null) 'sort': sort,
          'page': page,
          'limit': limit,
        },
        options: Options(headers: headers),
      );
      return response.data ?? {'products': [], 'total': 0, 'page': page, 'totalPages': 0};
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // Fetch details of a single product
  Future<Map<String, dynamic>> getProductById(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get('/products/$id', options: Options(headers: headers));
      return response.data ?? {};
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // Create new product (Farmer only)
  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.post(
        '/products',
        data: data,
        options: Options(headers: headers),
      );
      return response.data ?? {};
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // Update existing product (Farmer only)
  Future<Map<String, dynamic>> updateProduct(String id, Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.put(
        '/products/$id',
        data: data,
        options: Options(headers: headers),
      );
      return response.data ?? {};
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // Update stock quantity (Farmer only)
  Future<bool> updateStock(String id, double stock) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.patch(
        '/products/$id/stock',
        data: {'stock_quantity': stock},
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
