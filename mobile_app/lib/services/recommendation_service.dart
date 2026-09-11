import 'package:dio/dio.dart';
import '../core/config.dart';

class RecommendationService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
  ));

  static const String _baseUrl = AppConfig.baseUrl;

  /// Fetches unified 3-model dashboard payload (Buy Again, Picked For You, You May Also Want)
  Future<Map<String, dynamic>?> getCustomerHomeDashboard(String customerId, {List<String>? cartCrops}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (cartCrops != null && cartCrops.isNotEmpty) {
        queryParams['cart_crops'] = cartCrops.join(',');
      }
      final response = await _dio.get('$_baseUrl/recommendations/customer-home/$customerId', queryParameters: queryParams);
      if (response.statusCode == 200 && response.data != null) {
        return Map<String, dynamic>.from(response.data);
      }
    } catch (e) {
      // Fallback handled in UI
    }
    return null;
  }

  /// Model 1: Buy Again (Recency & Frequency Scoring)
  Future<List<Map<String, dynamic>>> getBuyAgain(String customerId, {int topK = 4}) async {
    try {
      final response = await _dio.get('$_baseUrl/recommendations/buy-again/$customerId', queryParameters: {'top_k': topK});
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> raw = response.data['recommendations'] ?? [];
        return raw.map((item) => Map<String, dynamic>.from(item)).toList();
      }
    } catch (e) {}
    return [];
  }

  /// Model 2: You May Also Want (FP-Growth Co-purchase Rules)
  Future<List<Map<String, dynamic>>> getYouMayAlsoWant(String customerId, {List<String>? cartCrops, int topK = 4}) async {
    try {
      final queryParams = <String, dynamic>{'top_k': topK};
      if (cartCrops != null && cartCrops.isNotEmpty) {
        queryParams['cart_crops'] = cartCrops.join(',');
      }
      final response = await _dio.get('$_baseUrl/recommendations/you-may-also-want/$customerId', queryParameters: queryParams);
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> raw = response.data['recommendations'] ?? [];
        return raw.map((item) => Map<String, dynamic>.from(item)).toList();
      }
    } catch (e) {}
    return [];
  }

  /// Model 3: Picked For You (Collaborative Filtering)
  Future<List<Map<String, dynamic>>> getPickedForYou(String customerId, {int topK = 4}) async {
    try {
      final response = await _dio.get('$_baseUrl/recommendations/picked-for-you/$customerId', queryParameters: {'top_k': topK});
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> raw = response.data['recommendations'] ?? [];
        return raw.map((item) => Map<String, dynamic>.from(item)).toList();
      }
    } catch (e) {}
    return [];
  }

  /// Dynamically logs customer interaction (VIEW, CART, PURCHASE) in real time
  Future<void> recordInteraction(String customerId, String listingId, String interactionType) async {
    try {
      await _dio.post('$_baseUrl/recommendations/interact', data: {
        'customer_id': customerId,
        'listing_id': listingId,
        'interaction_type': interactionType,
      });
    } catch (e) {}
  }

  /// Legacy compatibility method
  Future<List<Map<String, dynamic>>> getRecommendedListings(String customerId, {int topK = 10}) async {
    try {
      final response = await _dio.get('$_baseUrl/recommendations/$customerId', queryParameters: {'top_k': topK});
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> raw = response.data['recommendations'] ?? [];
        return raw.map((item) => Map<String, dynamic>.from(item)).toList();
      }
    } catch (e) {}
    return [];
  }
}
