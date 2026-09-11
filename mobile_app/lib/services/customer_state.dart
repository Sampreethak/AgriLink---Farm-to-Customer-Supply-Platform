import 'package:flutter/material.dart';
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

    if (lowerEmail.contains("amit") || lowerEmail.contains("hostel") || lowerEmail.contains("pg")) {
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
        CustomerOrderModel(
          orderId: "ORD-98631",
          items: [
            CartItemModel(
              id: "101",
              name: "Fresh Red Tomatoes (Nashik Special)",
              priceNum: 28.0,
              priceStr: "₹28/kg",
              imageUrl: "https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=600",
              farmer: "Ramesh Kumar",
              qty: 60,
            ),
          ],
          totalAmount: 1720.0,
          date: "Delivered July 22, 2026",
          status: "DELIVERED",
          address: "St. John Hostel Mess, Block B, Pune / Kolar",
        ),
      ]);
    } else if (lowerEmail.contains("sneha") || lowerEmail.contains("hospital") || lowerEmail.contains("clinic")) {
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
        CustomerOrderModel(
          orderId: "ORD-98495",
          items: [
            CartItemModel(
              id: "106",
              name: "Organic Himachal Honey",
              priceNum: 380.0,
              priceStr: "₹380/kg",
              imageUrl: "https://images.unsplash.com/photo-1587049352846-4a222e784d38?w=600",
              farmer: "Anita Sharma",
              qty: 15,
            ),
          ],
          totalAmount: 5740.0,
          date: "Delivered July 23, 2026",
          status: "DELIVERED",
          address: "Fortis Care Hospital Dietary Wing, Delhi NCR / Bengaluru",
        ),
        CustomerOrderModel(
          orderId: "ORD-98480",
          items: [
            CartItemModel(
              id: "102",
              name: "Organic Red Onions",
              priceNum: 22.5,
              priceStr: "₹22.5/kg",
              imageUrl: "https://images.unsplash.com/photo-1618512496248-a07fe83aa8cf?w=600",
              farmer: "Ramesh Kumar",
              qty: 25,
            ),
          ],
          totalAmount: 602.5,
          date: "Delivered July 21, 2026",
          status: "DELIVERED",
          address: "Fortis Care Hospital Dietary Wing, Delhi NCR / Bengaluru",
        ),
      ]);
    } else if (lowerEmail.contains("rajesh") || lowerEmail.contains("corp") || lowerEmail.contains("wholesale")) {
      // Rajesh Joshi (Corporate & Wholesaler Buyer) past orders
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
        CustomerOrderModel(
          orderId: "ORD-98290",
          items: [
            CartItemModel(
              id: "107",
              name: "Organic Basmati Rice 1121",
              priceNum: 95.0,
              priceStr: "₹95/kg",
              imageUrl: "https://images.unsplash.com/photo-1586201375761-83865001e31c?w=600",
              farmer: "Vikram Singh",
              qty: 400,
            ),
          ],
          totalAmount: 38040.0,
          date: "Delivered July 22, 2026",
          status: "DELIVERED",
          address: "Central Agro Wholesaler Yard, Ahmedabad / Bengaluru",
        ),
      ]);
    } else {
      // Default: Priya Verma / Individual Customer past orders from database seed
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
        CustomerOrderModel(
          orderId: "ORD-98715",
          items: [
            CartItemModel(
              id: "105",
              name: "Shimla Royal Delicious Apples",
              priceNum: 120.0,
              priceStr: "₹120/kg",
              imageUrl: "https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=600",
              farmer: "Anita Sharma",
              qty: 20,
            ),
          ],
          totalAmount: 2440.0,
          date: "Delivered July 25, 2026",
          status: "DELIVERED",
          address: "Flat 402, Sunshine Heights, Bandra West, Mumbai",
        ),
        CustomerOrderModel(
          orderId: "ORD-98702",
          items: [
            CartItemModel(
              id: "102",
              name: "Organic Red Onions",
              priceNum: 22.5,
              priceStr: "₹22.5/kg",
              imageUrl: "https://images.unsplash.com/photo-1618512496248-a07fe83aa8cf?w=600",
              farmer: "Ramesh Kumar",
              qty: 30,
            ),
          ],
          totalAmount: 715.0,
          date: "Delivered July 20, 2026",
          status: "DELIVERED",
          address: "Flat 402, Sunshine Heights, Bandra West, Mumbai",
        ),
      ]);
    }

    notifyListeners();
  }

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
    CustomerOrderModel(
      orderId: "ORD-98715",
      items: [
        CartItemModel(
          id: "105",
          name: "Shimla Royal Delicious Apples",
          priceNum: 120.0,
          priceStr: "₹120/kg",
          imageUrl: "https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=600",
          farmer: "Anita Sharma",
          qty: 20,
        ),
      ],
      totalAmount: 2440.0,
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

    _cart.clear();
    notifyListeners();
    return order;
  }
}
