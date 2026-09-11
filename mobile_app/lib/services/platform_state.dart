import 'package:flutter/foundation.dart';
import 'user_registry.dart';

class PlatformOrderItem {
  final String id;
  final String cropName;
  final String title;
  final double quantity; // in kg
  final double pricePerKg;
  final String farmerName;
  final String imageUrl;

  PlatformOrderItem({
    required this.id,
    required this.cropName,
    required this.title,
    required this.quantity,
    required this.pricePerKg,
    required this.farmerName,
    required this.imageUrl,
  });

  double get totalPrice => pricePerKg * quantity;
}

class PlatformOrder {
  final String orderId;
  final String customerId;
  final String customerName;
  final String customerEmail;
  final String deliveryAddress;
  final String paymentMethod;
  final List<PlatformOrderItem> items;
  final double totalAmount;
  final double farmerPayout;     // 68%
  final double aggregatorShare;   // 10%
  final double deliveryPayout;    // 14%
  final double platformFee;       // 8%
  String status;                  // 'PENDING', 'CONFIRMED', 'COLLECTED', 'IN_TRANSIT', 'DELIVERED'
  final DateTime createdAt;
  String? assignedDriver;

  PlatformOrder({
    required this.orderId,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    required this.deliveryAddress,
    required this.paymentMethod,
    required this.items,
    required this.totalAmount,
    required this.farmerPayout,
    required this.aggregatorShare,
    required this.deliveryPayout,
    required this.platformFee,
    this.status = 'CONFIRMED',
    required this.createdAt,
    this.assignedDriver,
  });
}

class CommodityPriceBreakdown {
  final String commodity;
  final double consumerPrice;
  final double farmerPayout;    // 68%
  final double aggregatorShare;  // 10%
  final double deliveryShare;   // 14%
  final double platformFee;      // 8%
  final double apmcBenchmark;
  final double boostPercent;

  const CommodityPriceBreakdown({
    required this.commodity,
    required this.consumerPrice,
    required this.farmerPayout,
    required this.aggregatorShare,
    required this.deliveryShare,
    required this.platformFee,
    required this.apmcBenchmark,
    this.boostPercent = 268.0,
  });
}

class PlatformState extends ChangeNotifier {
  static final PlatformState _instance = PlatformState._internal();
  factory PlatformState() => _instance;
  PlatformState._internal() {
    _initDefaultPricing();
    _initSeedOrders();
  }

  // Active Logged-in User
  AppUserModel _currentUser = UserRegistry.users.first; // Default Priya Verma
  AppUserModel get currentUser => _currentUser;

  void setCurrentUser(AppUserModel user) {
    _currentUser = user;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // ⚖️ DYNAMIC PRICING ORACLE STATE (4-WAY VALUE SHARE)
  // ---------------------------------------------------------------------------
  final Map<String, CommodityPriceBreakdown> _commodityPrices = {};
  Map<String, CommodityPriceBreakdown> get commodityPrices => _commodityPrices;

  void _initDefaultPricing() {
    _commodityPrices['Tomato'] = const CommodityPriceBreakdown(
      commodity: 'Tomato',
      consumerPrice: 44.69,
      farmerPayout: 30.39,
      aggregatorShare: 4.47,
      deliveryShare: 6.26,
      platformFee: 3.58,
      apmcBenchmark: 25.77,
      boostPercent: 268.0,
    );
    _commodityPrices['Potato'] = const CommodityPriceBreakdown(
      commodity: 'Potato',
      consumerPrice: 35.00,
      farmerPayout: 23.80,
      aggregatorShare: 3.50,
      deliveryShare: 4.90,
      platformFee: 2.80,
      apmcBenchmark: 21.00,
      boostPercent: 250.0,
    );
    _commodityPrices['Onion'] = const CommodityPriceBreakdown(
      commodity: 'Onion',
      consumerPrice: 35.29,
      farmerPayout: 24.00,
      aggregatorShare: 3.53,
      deliveryShare: 4.94,
      platformFee: 2.82,
      apmcBenchmark: 22.50,
      boostPercent: 270.0,
    );
    _commodityPrices['Carrot'] = const CommodityPriceBreakdown(
      commodity: 'Carrot',
      consumerPrice: 48.00,
      farmerPayout: 32.64,
      aggregatorShare: 4.80,
      deliveryShare: 6.72,
      platformFee: 3.84,
      apmcBenchmark: 28.00,
      boostPercent: 260.0,
    );
    _commodityPrices['Green Capsicum'] = const CommodityPriceBreakdown(
      commodity: 'Green Capsicum',
      consumerPrice: 62.00,
      farmerPayout: 42.16,
      aggregatorShare: 6.20,
      deliveryShare: 8.68,
      platformFee: 4.96,
      apmcBenchmark: 38.00,
      boostPercent: 280.0,
    );
    _commodityPrices['Rice'] = const CommodityPriceBreakdown(
      commodity: 'Rice',
      consumerPrice: 95.00,
      farmerPayout: 64.60,
      aggregatorShare: 9.50,
      deliveryShare: 13.30,
      platformFee: 7.60,
      apmcBenchmark: 60.00,
      boostPercent: 240.0,
    );
  }

  void updatePricing({
    required String commodity,
    required double consumerPrice,
    required double farmerPayout,
    required double aggregatorShare,
    required double deliveryShare,
    required double platformFee,
    required double apmcBenchmark,
  }) {
    _commodityPrices[commodity] = CommodityPriceBreakdown(
      commodity: commodity,
      consumerPrice: consumerPrice,
      farmerPayout: farmerPayout,
      aggregatorShare: aggregatorShare,
      deliveryShare: deliveryShare,
      platformFee: platformFee,
      apmcBenchmark: apmcBenchmark,
    );
    notifyListeners();
  }

  CommodityPriceBreakdown getBreakdown(String commodity) {
    if (_commodityPrices.containsKey(commodity)) {
      return _commodityPrices[commodity]!;
    }
    // Fallback dynamic 68/10/14/8 calculation for any commodity
    return const CommodityPriceBreakdown(
      commodity: 'Produce',
      consumerPrice: 40.00,
      farmerPayout: 27.20,
      aggregatorShare: 4.00,
      deliveryShare: 5.60,
      platformFee: 3.20,
      apmcBenchmark: 24.00,
    );
  }

  // ---------------------------------------------------------------------------
  // 📦 SHARED UNIFIED ORDER LIFECYCLE (Customer ➔ Farmer ➔ Aggregator ➔ Delivery)
  // ---------------------------------------------------------------------------
  final List<PlatformOrder> _allOrders = [];
  List<PlatformOrder> get allOrders => List.unmodifiable(_allOrders);

  void _initSeedOrders() {
    _allOrders.addAll([
      PlatformOrder(
        orderId: "ORD-98721",
        customerId: "99999999-9999-9999-9999-999999999999",
        customerName: "Priya Verma",
        customerEmail: "priya.buyer@agrilink.com",
        deliveryAddress: "Flat 402, Sunshine Heights, Bandra West, Mumbai",
        paymentMethod: "RAZORPAY",
        items: [
          PlatformOrderItem(
            id: "101",
            cropName: "Tomato",
            title: "Fresh Red Tomatoes (Nashik Special)",
            quantity: 50.0,
            pricePerKg: 28.0,
            farmerName: "Ramesh Kumar",
            imageUrl: "https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=600",
          ),
        ],
        totalAmount: 1400.0,
        farmerPayout: 952.0,     // 68% of ₹1400
        aggregatorShare: 140.0,  // 10%
        deliveryPayout: 196.0,   // 14%
        platformFee: 112.0,      // 8%
        status: "DELIVERED",
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        assignedDriver: "Raju Express Logistics",
      ),
      PlatformOrder(
        orderId: "ORD-98715",
        customerId: "99999999-9999-9999-9999-999999999999",
        customerName: "Priya Verma",
        customerEmail: "priya.buyer@agrilink.com",
        deliveryAddress: "Flat 402, Sunshine Heights, Bandra West, Mumbai",
        paymentMethod: "RAZORPAY",
        items: [
          PlatformOrderItem(
            id: "105",
            cropName: "Apple",
            title: "Shimla Royal Delicious Apples",
            quantity: 20.0,
            pricePerKg: 120.0,
            farmerName: "Anita Sharma",
            imageUrl: "https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=600",
          ),
        ],
        totalAmount: 2400.0,
        farmerPayout: 1632.0,    // 68% of ₹2400
        aggregatorShare: 240.0,  // 10%
        deliveryPayout: 336.0,   // 14%
        platformFee: 192.0,      // 8%
        status: "DELIVERED",
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
        assignedDriver: "Raju Express Logistics",
      ),
    ]);
  }

  /// Create a new order placed by the active customer
  PlatformOrder createOrder({
    required String customerId,
    required String customerName,
    required String customerEmail,
    required String deliveryAddress,
    required String paymentMethod,
    required List<PlatformOrderItem> items,
    required double totalAmount,
  }) {
    final orderId = "ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}";
    final farmerCut = totalAmount * 0.68;
    final aggCut = totalAmount * 0.10;
    final delCut = totalAmount * 0.14;
    final techCut = totalAmount * 0.08;

    final newOrder = PlatformOrder(
      orderId: orderId,
      customerId: customerId,
      customerName: customerName,
      customerEmail: customerEmail,
      deliveryAddress: deliveryAddress,
      paymentMethod: paymentMethod,
      items: items,
      totalAmount: totalAmount,
      farmerPayout: farmerCut,
      aggregatorShare: aggCut,
      deliveryPayout: delCut,
      platformFee: techCut,
      status: "CONFIRMED",
      createdAt: DateTime.now(),
    );

    _allOrders.insert(0, newOrder);
    notifyListeners();
    return newOrder;
  }

  /// Orders filtered for a specific Customer
  List<PlatformOrder> getCustomerOrders(String email) {
    final clean = email.trim().toLowerCase();
    return _allOrders.where((o) => o.customerEmail.toLowerCase() == clean).toList();
  }

  /// Orders filtered for a specific Farmer (where farmer produced the items)
  List<PlatformOrder> getFarmerOrders(String farmerName) {
    final clean = farmerName.trim().toLowerCase();
    return _allOrders.where((o) {
      return o.items.any((item) => item.farmerName.toLowerCase().contains(clean) || clean.contains(item.farmerName.toLowerCase()));
    }).toList();
  }

  /// Total earnings calculated for a Farmer based on 68% fair share
  double getFarmerTotalEarnings(String farmerName) {
    final orders = getFarmerOrders(farmerName);
    return orders.fold(0.0, (sum, o) => sum + o.farmerPayout);
  }

  /// Orders available for Aggregator Hub batching / dispatch
  List<PlatformOrder> getAggregatorOrders() {
    return _allOrders;
  }

  /// Total aggregator earnings based on 10% hub handling margin
  double getAggregatorTotalEarnings() {
    return _allOrders.fold(0.0, (sum, o) => sum + o.aggregatorShare);
  }

  /// Available delivery jobs on the Delivery Partner Job Board
  List<PlatformOrder> getDeliveryJobBoard() {
    return _allOrders.where((o) => o.status != 'DELIVERED').toList();
  }

  /// Total earnings for Delivery Partner based on 14% logistics payouts
  double getDeliveryTotalEarnings() {
    return _allOrders
        .where((o) => o.status == 'DELIVERED' || o.status == 'IN_TRANSIT')
        .fold(0.0, (sum, o) => sum + o.deliveryPayout);
  }

  /// Update order delivery lifecycle status
  void updateOrderStatus(String orderId, String newStatus, {String? driverName}) {
    for (final order in _allOrders) {
      if (order.orderId == orderId) {
        order.status = newStatus;
        if (driverName != null) {
          order.assignedDriver = driverName;
        }
        notifyListeners();
        break;
      }
    }
  }
}
