import 'package:dio/dio.dart';
import '../core/config.dart';

class PricingService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
  ));

  static const String _baseUrl = AppConfig.baseUrl;

  /// Fetches APMC government benchmark modal prices for Mandya-Bengaluru corridor
  Future<Map<String, double>> getApmcBenchmarks() async {
    try {
      final response = await _dio.get('$_baseUrl/pricing/benchmarks');
      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> raw = response.data['benchmarks_rs_per_kg'] ?? {};
        return raw.map((key, value) => MapEntry(key, (value as num).toDouble()));
      }
    } catch (e) {
      // Fallback defaults
    }
    return {
      'Tomato': 25.77,
      'Potato': 22.50,
      'Onion': 30.92,
      'Carrot': 35.40,
      'Palak': 17.48,
      'Ginger': 77.11,
      'Garlic': 101.03,
      'Banana': 35.00,
      'Pomegranate': 98.20,
      'Ragi': 41.19,
    };
  }

  /// Calculates dynamic fair price and 4-way share breakdown (Farmer 68%, Aggregator 10%, Delivery 14%, Platform 8%)
  Future<Map<String, dynamic>?> calculateFairShare({
    required String commodity,
    String variety = 'Hybrid / Nati',
    String grade = 'Grade A',
    String originDistrict = 'Mandya',
    double distanceKm = 85.0,
    bool isOrganic = false,
  }) async {
    try {
      final response = await _dio.post('$_baseUrl/pricing/calculate-fair-share', data: {
        'commodity': commodity,
        'variety': variety,
        'grade': grade,
        'origin_district': originDistrict,
        'distance_km': distanceKm,
        'is_organic': isOrganic,
      });
      if (response.statusCode == 200 && response.data != null) {
        return Map<String, dynamic>.from(response.data);
      }
    } catch (e) {
      // Fallback calculation
    }

    final double apmcModal = 28.0;
    final double fairPrice = isOrganic ? 46.0 : 36.0;
    final double farmerPayout = double.parse((fairPrice * 0.68).toStringAsFixed(2));
    final double aggregatorPayout = double.parse((fairPrice * 0.10).toStringAsFixed(2));
    final double deliveryPayout = double.parse((fairPrice * 0.14).toStringAsFixed(2));
    final double platformFee = double.parse((fairPrice * 0.08).toStringAsFixed(2));

    return {
      'commodity': commodity,
      'grade': grade,
      'is_organic': isOrganic,
      'corridor': '$originDistrict -> Bengaluru (${distanceKm.toInt()} km)',
      'apmc_mandi_benchmark_per_kg': apmcModal,
      'predicted_fair_consumer_price_per_kg': fairPrice,
      'fair_share_breakdown': {
        'farmer': {
          'role': 'Farmer (Producer)',
          'share_pct': 68.0,
          'payout_per_kg': farmerPayout,
          'benefit_description': '+268% higher payout vs traditional middlemen',
        },
        'aggregator': {
          'role': 'SHG Homemaker (Tier-1) + Corridor Hub (Tier-2)',
          'share_pct': 10.0,
          'payout_per_kg': aggregatorPayout,
          'benefit_description': 'Fair compensation for SHG village pooling and quality grading',
        },
        'delivery_partner': {
          'role': 'Corridor Highway Transport & Last-Mile Rider',
          'share_pct': 14.0,
          'payout_per_kg': deliveryPayout,
          'benefit_description': 'Covers Mandya-Bengaluru highway pooling and doorstep delivery',
        },
        'platform': {
          'role': 'AgriLink Platform & Quality Tech',
          'share_pct': 8.0,
          'payout_per_kg': platformFee,
          'benefit_description': 'AI pricing oracle, QR traceability, and escrow settlement',
        },
      },
      'consumer_savings': {
        'supermarket_benchmark_per_kg': double.parse((fairPrice * 1.25).toStringAsFixed(2)),
        'savings_pct': 20.0,
        'savings_description': 'Fresh morning harvest delivered at 20% lower price than city supermarket retail',
      },
    };
  }
}
