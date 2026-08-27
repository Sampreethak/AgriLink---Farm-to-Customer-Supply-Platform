import 'package:flutter/material.dart';

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

  // Logged-in Customer Details
  String name = "Priya Verma";
  String email = "priya.buyer@agrilink.com";
  String phone = "+91 98111 22233";
  String location = "Mumbai, Maharashtra";
  String role = "Individual Customer";

  // Cart Items State: key is produce name
  final Map<String, CartItemModel> _cart = {};

  // Placed Orders History
  final List<CustomerOrderModel> _orders = [
    CustomerOrderModel(
      orderId: "ORD-98721",
      items: [
        CartItemModel(
          id: "101",
          name: "Fresh Red Tomatoes (Nashik Special)",
          priceNum: 28.0,
          priceStr: "₹28/kg",
          imageUrl: "https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=500",
          farmer: "Ramesh Kumar",
          qty: 50,
        ),
      ],
      totalAmount: 1400.0,
      date: "Delivered July 28, 2026",
      status: "DELIVERED",
      address: "Flat 402, Sunshine Heights, Bandra West, Mumbai",
    ),
    CustomerOrderModel(
      orderId: "ORD-98715",
      items: [
        CartItemModel(
          id: "105",
          name: "Shimla Royal Delicious Apples",
          priceNum: 120.0,
          priceStr: "₹120/kg",
          imageUrl: "https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=500",
          farmer: "Anita Sharma",
          qty: 20,
        ),
      ],
      totalAmount: 2400.0,
      date: "Delivered July 25, 2026",
      status: "DELIVERED",
      address: "Flat 402, Sunshine Heights, Bandra West, Mumbai",
    ),
  ];

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

  CustomerOrderModel placeOrder({required String deliveryAddress, String paymentMethod = "RAZORPAY"}) {
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

    final order = CustomerOrderModel(
      orderId: orderId,
      items: itemsList,
      totalAmount: subtotal + 40.0, // Subtotal + Delivery fee
      date: "Just now",
      status: "PAID",
      paymentMethod: paymentMethod,
      address: deliveryAddress,
    );

    _orders.insert(0, order);
    _cart.clear();
    notifyListeners();
    return order;
  }
}
