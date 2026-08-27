import 'package:dio/dio.dart';

class RecommendationService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
  ));

  static const String _baseUrl = 'http://localhost:8000';

  Future<List<Map<String, dynamic>>> getRecommendedListings(String customerId, {int topK = 10}) async {
    try {
      final response = await _dio.get('$_baseUrl/recommend/$customerId', queryParameters: {'top_k': topK});
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> raw = response.data['recommendations'] ?? [];
        return raw.map((item) => Map<String, dynamic>.from(item)).toList();
      }
    } catch (e) {
      // Fallback for offline UI preview
    }

    // Clean customer-facing demo recommendations with real crop photography
    return [
      {
        "listing_id": "lst-101",
        "crop_name": "Organic Red Tomato",
        "seller_name": "Green Farm Harvest (Farmer)",
        "seller_type": "Farmer",
        "price": 32.0,
        "freshness": 95.0,
        "distance_km": 4.5,
        "delivery_time_mins": 30,
        "delivery_cost_rs": 30.0,
        "is_organic": true,
        "reason": "95% Fresh Harvest • Organic Certified Farm",
        "image_url": "https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=500&auto=format&fit=crop&q=80"
      },
      {
        "listing_id": "lst-102",
        "crop_name": "Fresh Kolar Onion",
        "seller_name": "Kolar Organic Farmers Co-op",
        "seller_type": "Farmer",
        "price": 28.0,
        "freshness": 92.0,
        "distance_km": 6.8,
        "delivery_time_mins": 35,
        "delivery_cost_rs": 45.0,
        "is_organic": true,
        "reason": "Top seller in Kolar District • Direct farm price",
        "image_url": "https://images.unsplash.com/photo-1618512496248-a07fe83aa8cf?w=500&auto=format&fit=crop&q=80"
      },
      {
        "listing_id": "lst-103",
        "crop_name": "Cold Storage Potato",
        "seller_name": "Central Kolar Cold Warehouse",
        "seller_type": "Aggregator",
        "price": 24.0,
        "freshness": 88.0,
        "distance_km": 12.0,
        "delivery_time_mins": 45,
        "delivery_cost_rs": 80.0,
        "is_organic": false,
        "reason": "Best value for bulk cooking • Quality Grade A",
        "image_url": "https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=500&auto=format&fit=crop&q=80"
      },
      {
        "listing_id": "lst-104",
        "crop_name": "Green Capsicum",
        "seller_name": "Valley Fresh Farms",
        "seller_type": "Farmer",
        "price": 45.0,
        "freshness": 94.0,
        "distance_km": 5.2,
        "delivery_time_mins": 32,
        "delivery_cost_rs": 35.0,
        "is_organic": true,
        "reason": "Harvested today • Nearby farm (5.2 km)",
        "image_url": "https://images.unsplash.com/photo-1563565375-f3fdfdbefa83?w=500&auto=format&fit=crop&q=80"
      }
    ];
  }
}
