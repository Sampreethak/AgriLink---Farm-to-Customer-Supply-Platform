import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'recommendation_service.dart';
import 'platform_state.dart';
import 'user_registry.dart';

class CartItemModel {
  final String id;
  final String name;
  final double priceNum;
  final String priceStr;
  final String unit;
  final String imageUrl;
  final String farmer;
  int qty;

  CartItemModel({
    required this.id,
    required this.name,
    required this.priceNum,
    required this.priceStr,
    this.unit = 'kg',
    required this.imageUrl,
    required this.farmer,
    this.qty = 1,
  });
}

class CustomerOrderModel {
  final String orderId;
  final List<CartItemModel> items;
  final double totalAmount;
  final String date;
  final String status;
  final String paymentMethod;
  final String address;

  CustomerOrderModel({
    required this.orderId,
    required this.items,
    required this.totalAmount,
    required this.date,
    this.status = 'PAID',
    this.paymentMethod = 'RAZORPAY',
    required this.address,
  });
}

class CustomerState extends ChangeNotifier {
  static final CustomerState _instance = CustomerState._internal();
  factory CustomerState() => _instance;
  CustomerState._internal();

  // Active Customer Profile
  String name = "Priya Verma";
  String email = "priya.buyer@agrilink.com";
  String phone = "+91 98111 22233";
  String location = "Mumbai, Maharashtra";
  String role = "Individual Customer";
  String customerId = "99999999-9999-9999-9999-999999999999";

  void setProfile(AppUserModel user) {
    name = user.fullName;
    email = user.email;
    phone = user.phone;
    location = user.region;
    role = user.customerType;
    customerId = user.id;

    // Load database seed past order history for this specific customer
    _orders.clear();
    final lowerEmail = user.email.toLowerCase();

    if (lowerEmail == "amit.buyer@agrilink.com" || lowerEmail == "cust1005@agrilink.com") {
      // Amit Roy (Hostel & PG Mess Buyer) past orders
      _orders.addAll([
        CustomerOrderModel(
          orderId: "ORD-98650",
          items: [
            CartItemModel(
              id: "103",
              name: "Premium Sharbati Wheat",
              priceNum: 42.0,
              priceStr: "₹42/kg",
              imageUrl: "https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=600",
              farmer: "Suresh Patel",
              qty: 100,
            ),
          ],
          totalAmount: 4240.0,
          date: "Delivered July 26, 2026",
          status: "DELIVERED",
          address: "St. John Hostel Mess, Block B, Pune / Kolar",
        ),
        CustomerOrderModel(
          orderId: "ORD-98642",
          items: [
            CartItemModel(
              id: "107",
              name: "Organic Basmati Rice 1121",
              priceNum: 95.0,
              priceStr: "₹95/kg",
              imageUrl: "https://images.unsplash.com/photo-1586201375761-83865001e31c?w=600",
              farmer: "Vikram Singh",
              qty: 80,
            ),
          ],
          totalAmount: 7640.0,
          date: "Delivered July 24, 2026",
          status: "DELIVERED",
          address: "St. John Hostel Mess, Block B, Pune / Kolar",
        ),
      ]);
    } else if (lowerEmail == "sneha.buyer@agrilink.com" || lowerEmail == "cust1004@agrilink.com") {
      // Sneha Kapoor (Hospital Dietary Buyer) past orders
      _orders.addAll([
        CustomerOrderModel(
          orderId: "ORD-98510",
          items: [
            CartItemModel(
              id: "105",
              name: "Shimla Royal Delicious Apples",
              priceNum: 120.0,
              priceStr: "₹120/kg",
              imageUrl: "https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=600",
              farmer: "Anita Sharma",
              qty: 40,
            ),
          ],
          totalAmount: 4840.0,
          date: "Delivered July 27, 2026",
          status: "DELIVERED",
          address: "Fortis Care Hospital Dietary Wing, Delhi NCR / Bengaluru",
        ),
      ]);
    } else if (lowerEmail == "rajesh.buyer@agrilink.com") {
      // Rajesh Joshi (Corporate Buyer) past orders
      _orders.addAll([
        CustomerOrderModel(
          orderId: "ORD-98301",
          items: [
            CartItemModel(
              id: "103",
              name: "Premium Sharbati Wheat",
              priceNum: 42.0,
              priceStr: "₹42/kg",
              imageUrl: "https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=600",
              farmer: "Suresh Patel",
              qty: 500,
            ),
          ],
          totalAmount: 21040.0,
          date: "Delivered July 25, 2026",
          status: "DELIVERED",
          address: "Central Agro Wholesaler Yard, Ahmedabad / Bengaluru",
        ),
      ]);
    } else if (lowerEmail == "priya.buyer@agrilink.com" || user.id == "99999999-9999-9999-9999-999999999999") {
      // Priya Verma / Seed Dataset account
      _orders.addAll([
        CustomerOrderModel(
          orderId: "ORD-98721",
          items: [
            CartItemModel(
              id: "101",
              name: "Fresh Red Tomatoes (Nashik Special)",
              priceNum: 28.0,
              priceStr: "₹28/kg",
              imageUrl: "https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=600",
              farmer: "Ramesh Kumar",
              qty: 50,
            ),
          ],
          totalAmount: 1440.0,
          date: "Delivered July 28, 2026",
          status: "DELIVERED",
          address: "Flat 402, Sunshine Heights, Bandra West, Mumbai",
        ),
      ]);
    }
    // For real Supabase / Google authenticated users, fetch placed orders from Supabase DB
    if (user.id.length == 36 && !lowerEmail.endsWith("@agrilink.com")) {
      _fetchUserOrdersFromSupabase(user.id);
    }
    notifyListeners();
  }

  // Cart Items State: key is produce name
  final Map<String, CartItemModel> _cart = {};

  // Placed Orders History (fresh for new users, populated on demand)
  final List<CustomerOrderModel> _orders = [];

  Map<String, CartItemModel> get cart => _cart;
  List<CustomerOrderModel> get orders => List.unmodifiable(_orders);

  int get cartCount => _cart.values.fold(0, (sum, item) => sum + item.qty);

  double get subtotal => _cart.values.fold(0.0, (sum, item) => sum + (item.priceNum * item.qty));

  int getQuantity(String productName) {
    return _cart[productName]?.qty ?? 0;
  }

  void updateQuantity(
    String name,
    double priceNum,
    String priceStr,
    String imageUrl,
    String farmer,
    int delta,
  ) {
    if (!_cart.containsKey(name)) {
      if (delta > 0) {
        _cart[name] = CartItemModel(
          id: name.hashCode.toString(),
          name: name,
          priceNum: priceNum,
          priceStr: priceStr,
          imageUrl: imageUrl,
          farmer: farmer,
          qty: delta,
        );
      }
    } else {
      final current = _cart[name]!;
      current.qty += delta;
      if (current.qty <= 0) {
        _cart.remove(name);
      }
    }
    notifyListeners();
  }

  void setQuantity(
    String name,
    double priceNum,
    String priceStr,
    String imageUrl,
    String farmer,
    int qty,
  ) {
    if (qty <= 0) {
      _cart.remove(name);
    } else {
      _cart[name] = CartItemModel(
        id: name.hashCode.toString(),
        name: name,
        priceNum: priceNum,
        priceStr: priceStr,
        imageUrl: imageUrl,
        farmer: farmer,
        qty: qty,
      );
    }
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  Future<CustomerOrderModel> placeOrder({required String deliveryAddress, String paymentMethod = "RAZORPAY"}) async {
    final orderId = "ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}";
    final itemsList = _cart.values.map((item) => CartItemModel(
      id: item.id,
      name: item.name,
      priceNum: item.priceNum,
      priceStr: item.priceStr,
      unit: item.unit,
      imageUrl: item.imageUrl,
      farmer: item.farmer,
      qty: item.qty,
    )).toList();

    final orderTotal = subtotal + 40.0; // Subtotal + Delivery fee

    final order = CustomerOrderModel(
      orderId: orderId,
      items: itemsList,
      totalAmount: orderTotal,
      date: "Just now",
      status: "CONFIRMED",
      paymentMethod: paymentMethod,
      address: deliveryAddress,
    );

    _orders.insert(0, order);

    // Sync to PlatformState so Farmer, Aggregator, and Delivery Partner receive this order in real time!
    PlatformState().createOrder(
      customerId: customerId,
      customerName: name,
      customerEmail: email,
      deliveryAddress: deliveryAddress,
      paymentMethod: paymentMethod,
      items: itemsList.map((i) => PlatformOrderItem(
        id: i.id,
        cropName: i.name.split(' ').first,
        title: i.name,
        quantity: i.qty.toDouble(),
        pricePerKg: i.priceNum,
        farmerName: i.farmer,
        imageUrl: i.imageUrl,
      )).toList(),
      totalAmount: orderTotal,
    );

    // 1. Sync live to Supabase PostgreSQL Database (orders & order_items)
    try {
      final supabase = Supabase.instance.client;
      if (customerId.length == 36) {
        await supabase.from('profiles').upsert({
          'id': customerId,
          'user_id': customerId,
          'full_name': name,
          'email': email,
          'user_role': 'CUSTOMER',
        });

        final orderRow = await supabase.from('orders').insert({
          'buyer_id': customerId,
          'total_amount': orderTotal,
          'status': 'PAID',
          'payment_method': paymentMethod,
          'delivery_address': deliveryAddress,
        }).select().maybeSingle();

        final dbOrderId = orderRow?['id'];
        for (final item in itemsList) {
          if (dbOrderId != null) {
            await supabase.from('order_items').insert({
              'order_id': dbOrderId,
              'crop_name': item.name,
              'quantity': item.qty,
              'unit_price': item.priceNum,
              'total_price': item.priceNum * item.qty,
            });
          }
          await supabase.from('user_interactions').insert({
            'buyer_id': customerId,
            'interaction_type': 'PURCHASE',
          });
        }
      }
    } catch (e) {
      debugPrint('[CustomerState] Supabase sync note: $e');
    }

    // 2. Feed purchase events into the Render Machine Learning Recommendation Engine
    for (final item in itemsList) {
      try {
        final recService = RecommendationService();
        await recService.recordInteraction(customerId, item.name, "PURCHASE");
      } catch (_) {}
    }

    _cart.clear();
    notifyListeners();
    return order;
  }

  Future<void> _fetchUserOrdersFromSupabase(String uid) async {
    try {
      final supabase = Supabase.instance.client;
      final rows = await supabase
          .from('orders')
          .select('*, order_items(*)')
          .eq('buyer_id', uid)
          .order('created_at', ascending: false);

      if (rows is List && rows.isNotEmpty) {
        _orders.clear();
        for (final r in rows) {
          final itemsRaw = r['order_items'] as List<dynamic>? ?? [];
          final items = itemsRaw.map((it) => CartItemModel(
            id: it['id']?.toString() ?? it['crop_name'] ?? 'item',
            name: it['crop_name'] ?? 'Fresh Produce',
            priceNum: (it['unit_price'] as num?)?.toDouble() ?? 30.0,
            priceStr: "₹${it['unit_price'] ?? 30}/kg",
            imageUrl: "https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=600",
            farmer: "Direct Producer",
            qty: (it['quantity'] as num?)?.toInt() ?? 1,
          )).toList();

          _orders.add(CustomerOrderModel(
            orderId: r['id']?.toString().substring(0, 8).toUpperCase() ?? 'ORD-LIVE',
            items: items,
            totalAmount: (r['total_amount'] as num?)?.toDouble() ?? 0.0,
            date: "Placed recently",
            status: r['status'] ?? 'PAID',
            paymentMethod: r['payment_method'] ?? 'RAZORPAY',
            address: r['delivery_address'] ?? 'Verified Address',
          ));
        }
        notifyListeners();
      }
    } catch (_) {}
  }
}
