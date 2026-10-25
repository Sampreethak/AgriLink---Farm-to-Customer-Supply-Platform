import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
    } catch (e) {
      debugPrint('[RecommendationService] Network error: $e');
    }
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
    } catch (e) {
      debugPrint('[RecommendationService] Network error: $e');
    }
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
    } catch (e) {
      debugPrint('[RecommendationService] Network error: $e');
    }
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
    } catch (e) {
      debugPrint('[RecommendationService] Network error: $e');
    }
  }

  /// Legacy compatibility method
  Future<List<Map<String, dynamic>>> getRecommendedListings(String customerId, {int topK = 10}) async {
    try {
      final response = await _dio.get('$_baseUrl/recommendations/$customerId', queryParameters: {'top_k': topK});
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> raw = response.data['recommendations'] ?? [];
        return raw.map((item) => Map<String, dynamic>.from(item)).toList();
      }
    } catch (e) {
      debugPrint('[RecommendationService] Network error: $e');
    }
    return [];
  }

  /// Replacement Listing Recommendations for Out-of-Stock / Alternative items
  Future<List<Map<String, dynamic>>> getReplacementListings(String listingId, {int topK = 3}) async {
    try {
      final response = await _dio.get('$_baseUrl/recommendations/replacement/$listingId', queryParameters: {'top_k': topK});
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> raw = response.data['recommendations'] ?? [];
        return raw.map((item) => Map<String, dynamic>.from(item)).toList();
      }
    } catch (e) {
      debugPrint('[RecommendationService] Network error: $e');
    }
    return [];
  }

  /// Farmer Crop Opportunities (Demand gap + APMC price predictions)
  Future<List<Map<String, dynamic>>> getFarmerCropOpportunities(String farmerId, {int topK = 10}) async {
    try {
      final response = await _dio.get('$_baseUrl/recommendations/farmer/$farmerId', queryParameters: {'top_k': topK});
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> raw = response.data['recommendations'] ?? [];
        return raw.map((item) => Map<String, dynamic>.from(item)).toList();
      }
    } catch (e) {
      debugPrint('[RecommendationService] Network error: $e');
    }
    return [];
  }

  /// Aggregator Supplier Matching for bulk produce procurement
  Future<List<Map<String, dynamic>>> getAggregatorSupplierMatches(String cropName, {double requiredQuantity = 500.0, int topK = 10}) async {
    try {
      final response = await _dio.get('$_baseUrl/recommendations/aggregator/match', queryParameters: {
        'crop_name': cropName,
        'required_quantity': requiredQuantity,
        'top_k': topK,
      });
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> raw = response.data['recommendations'] ?? [];
        return raw.map((item) => Map<String, dynamic>.from(item)).toList();
      }
    } catch (e) {
      debugPrint('[RecommendationService] Network error: $e');
    }
    return [];
  }

  // ─────────────────────────────────────────────────────────────────────────
  // EXTENDED ML RECOMMENDATION MODELS (4 new notebook-backed algorithms)
  // ─────────────────────────────────────────────────────────────────────────

  /// Unified Discover Dashboard — all 4 extended models in one call
  Future<Map<String, dynamic>?> getDiscoverDashboard(String customerId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/recommendations/discover/$customerId',
        options: Options(receiveTimeout: const Duration(seconds: 15)),
      );
      if (response.statusCode == 200 && response.data != null) {
        return Map<String, dynamic>.from(response.data);
      }
    } catch (e) {
      debugPrint('[RecommendationService] Network error: $e');
    }
    return null;
  }

  /// Model 4: Next-Basket Prediction (NBR Frequency Baseline)
  Future<List<Map<String, dynamic>>> getNextBasket(String customerId, {int topK = 6}) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/recommendations/next-basket/$customerId',
        queryParameters: {'top_k': topK},
      );
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> raw = response.data['recommendations'] ?? [];
        return raw.map((item) => Map<String, dynamic>.from(item)).toList();
      }
    } catch (e) {
      debugPrint('[RecommendationService] Network error: $e');
    }
    return [];
  }

  /// Model 5: Recency-Weighted (Exponential Time-Decay Scoring)
  Future<List<Map<String, dynamic>>> getRecencyWeighted(String customerId, {int topK = 6}) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/recommendations/recency-weighted/$customerId',
        queryParameters: {'top_k': topK},
      );
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> raw = response.data['recommendations'] ?? [];
        return raw.map((item) => Map<String, dynamic>.from(item)).toList();
      }
    } catch (e) {
      debugPrint('[RecommendationService] Network error: $e');
    }
    return [];
  }

  /// Model 6: Price-Aware (Budget-Fit + Popularity Heuristic)
  Future<List<Map<String, dynamic>>> getPriceAware(String customerId, {int topK = 6}) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/recommendations/price-aware/$customerId',
        queryParameters: {'top_k': topK},
      );
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> raw = response.data['recommendations'] ?? [];
        return raw.map((item) => Map<String, dynamic>.from(item)).toList();
      }
    } catch (e) {
      debugPrint('[RecommendationService] Network error: $e');
    }
    return [];
  }

  /// Model 7: Local Popularity (Region-Based Trending)
  Future<List<Map<String, dynamic>>> getLocalPopularity(String customerId, {int topK = 6, String? region}) async {
    try {
      final params = <String, dynamic>{'buyer_id': customerId, 'top_k': topK};
      if (region != null) params['region'] = region;
      final response = await _dio.get(
        '$_baseUrl/recommendations/local-popularity',
        queryParameters: params,
      );
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> raw = response.data['recommendations'] ?? [];
        return raw.map((item) => Map<String, dynamic>.from(item)).toList();
      }
    } catch (e) {
      debugPrint('[RecommendationService] Network error: $e');
    }
    return [];
  }
}

