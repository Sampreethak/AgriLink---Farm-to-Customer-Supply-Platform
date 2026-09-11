import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../services/product_service.dart';
import '../../services/customer_state.dart';
import 'products/product_details_screen.dart';
import 'bulk_order_screen.dart';
import 'recurring_order_screen.dart';
import 'qa_tracking_screen.dart';
import 'fair_pricing_screen.dart';
import '../../services/recommendation_service.dart';
import '../../widgets/voice_input_field.dart';

class HomeTab extends StatefulWidget {
  final VoidCallback? onNavigateToCart;
  const HomeTab({super.key, this.onNavigateToCart});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final CustomerState _customerState = CustomerState();
  String customerType = "Individual Customer";
  String searchQuery = "";
  String selectedCategory = "All"; // Active category filter
  final TextEditingController _searchController = TextEditingController();
  final ProductService _productService = ProductService();
  final RecommendationService _recService = RecommendationService();

  String _activeCustomerId = "d48b9f71-c110-4f5f-83da-7b65dbfbc328";
  List<Map<String, dynamic>> _buyAgainRecs = [];
  List<Map<String, dynamic>> _pickedForYouRecs = [];
  List<Map<String, dynamic>> _youMayAlsoWantRecs = [];
  bool _isLoadingRecs = true;

  List<Map<String, dynamic>> _allProducts = [];
  bool _isLoadingProducts = true;

  List<Map<String, String>> get _dynamicPreviousOrders {
    final List<Map<String, String>> list = [];
    for (final order in _customerState.orders) {
      for (final item in order.items) {
        list.add({
          "name": item.name,
          "crop_name": item.name.split(' ').first,
          "quantity": "${item.qty} kg",
          "price": item.priceStr,
          "date": order.date,
          "farmer": item.farmer,
          "imageUrl": _resolveProduceImage(item.name.split(' ').first, item.imageUrl),
        });
      }
    }
    return list;
  }

  // Category definitions with real produce images
  final List<Map<String, String>> _categories = [
    {
      'title': 'All',
      'imageUrl': 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=500&auto=format&fit=crop&q=80'
    },
    {
      'title': 'Vegetables',
      'imageUrl': 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=500&auto=format&fit=crop&q=80'
    },
    {
      'title': 'Fruits',
      'imageUrl': 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=500&auto=format&fit=crop&q=80'
    },
    {
      'title': 'Grains',
      'imageUrl': 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=500&auto=format&fit=crop&q=80'
    },
    {
      'title': 'Pulses',
      'imageUrl': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&auto=format&fit=crop&q=80'
    },
  ];

  static const Map<String, String> _cropImages = {
    "Tomato": "https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=600&auto=format&fit=crop&q=80",
    "Potato": "https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=600&auto=format&fit=crop&q=80",
    "Onion": "https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?w=600&auto=format&fit=crop&q=80",
    "Carrot": "https://images.unsplash.com/photo-1598170845058-12f6a67a9657?w=600&auto=format&fit=crop&q=80",
    "Cabbage": "https://images.unsplash.com/photo-1594282486552-05b4d80fbb9f?w=600&auto=format&fit=crop&q=80",
    "Green Peas": "https://images.unsplash.com/photo-1587735243615-c03f25aaff15?w=600&auto=format&fit=crop&q=80",
    "Green Capsicum": "https://images.unsplash.com/photo-1563565375-f3fdfdbefa83?w=600&auto=format&fit=crop&q=80",
    "Green Chilli": "https://images.unsplash.com/photo-1588252303782-cb80119abd6d?w=600&auto=format&fit=crop&q=80",
    "Palak": "https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=600&auto=format&fit=crop&q=80",
    "Coriander": "https://images.unsplash.com/photo-1608797178974-15b35a6018b3?w=600&auto=format&fit=crop&q=80",
    "Mint": "https://images.unsplash.com/photo-1628556270448-4d4e4148e1b1?w=600&auto=format&fit=crop&q=80",
    "Ginger": "https://images.unsplash.com/photo-1615485290382-441e4d049cb5?w=600&auto=format&fit=crop&q=80",
    "Garlic": "https://images.unsplash.com/photo-1540148426945-6cf22a6b2383?w=600&auto=format&fit=crop&q=80",
    "Banana": "https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=600&auto=format&fit=crop&q=80",
    "Papaya": "https://images.unsplash.com/photo-1526318897912-3283331804f1?w=600&auto=format&fit=crop&q=80",
    "Pomegranate": "https://images.unsplash.com/photo-1553530666-ba11a7da3888?w=600&auto=format&fit=crop&q=80",
    "Grapes": "https://images.unsplash.com/photo-1537640538966-79f369143f8f?w=600&auto=format&fit=crop&q=80",
    "Ragi": "https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=600&auto=format&fit=crop&q=80",
    "Rice": "https://images.unsplash.com/photo-1586201375761-83865001e31c?w=600&auto=format&fit=crop&q=80",
    "Apple": "https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=600&auto=format&fit=crop&q=80",
    "Honey": "https://images.unsplash.com/photo-1587049352846-4a222e784d38?w=600&auto=format&fit=crop&q=80",
    "Wheat": "https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=600&auto=format&fit=crop&q=80"
  };

  static const Map<String, String> _categoryImages = {
    'Vegetables': 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=500&auto=format&fit=crop&q=80',
    'Fruits': 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=500&auto=format&fit=crop&q=80',
    'Grains': 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=500&auto=format&fit=crop&q=80',
    'Pulses': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&auto=format&fit=crop&q=80',
    'default': 'https://images.unsplash.com/photo-1598170845058-12f6a67a9657?w=500&auto=format&fit=crop&q=80',
  };

  static String _resolveProduceImage(String? cropName, String? defaultUrl) {
    if (cropName != null && _cropImages.containsKey(cropName)) {
      return _cropImages[cropName]!;
    }
    // Check partial match
    if (cropName != null) {
      for (final entry in _cropImages.entries) {
        if (cropName.toLowerCase().contains(entry.key.toLowerCase())) {
          return entry.value;
        }
      }
    }
    return defaultUrl ?? _cropImages['Tomato']!;
  }

  @override
  void initState() {
    super.initState();
    final role = _customerState.role;
    if (role.contains("Hostel") || role.contains("PG")) {
      customerType = "Hostel / PG";
    } else if (role.contains("Hospital")) {
      customerType = "Hospital";
    } else {
      customerType = "Individual Customer";
    }
    _activeCustomerId = _customerState.customerId;
    _customerState.addListener(_onCustomerStateChange);
    _loadProducts();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    setState(() => _isLoadingRecs = true);
    final activeCartCrops = _customerState.cart.keys.map((k) => k.split(' ').first).toList();
    final data = await _recService.getCustomerHomeDashboard(_activeCustomerId, cartCrops: activeCartCrops);
    if (data != null && data['sections'] != null) {
      if (mounted) {
        setState(() {
          _buyAgainRecs = List<Map<String, dynamic>>.from(data['sections']['buy_again']['items'] ?? []);
          _pickedForYouRecs = List<Map<String, dynamic>>.from(data['sections']['picked_for_you']['items'] ?? []);
          _youMayAlsoWantRecs = List<Map<String, dynamic>>.from(data['sections']['you_may_also_want']['items'] ?? []);
          _isLoadingRecs = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoadingRecs = false);
    }
  }

  @override
  void dispose() {
    _customerState.removeListener(_onCustomerStateChange);
    _searchController.dispose();
    super.dispose();
  }

  void _onCustomerStateChange() {
    if (mounted) {
      final role = _customerState.role;
      if (role.contains("Hostel") || role.contains("PG")) {
        customerType = "Hostel / PG";
      } else if (role.contains("Hospital")) {
        customerType = "Hospital";
      } else {
        customerType = "Individual Customer";
      }
      _activeCustomerId = _customerState.customerId;
      setState(() {});
      _loadRecommendations();
    }
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoadingProducts = true;
    });
    try {
      final data = await _productService.getProducts(limit: 30);
      final List<dynamic> raw = data['products'] ?? [];
      setState(() {
        _allProducts = raw.map<Map<String, dynamic>>((p) {
          final category = (p['category'] ?? 'default').toString();
          final priceNum = (p['price'] ?? 0);
          final unit = p['unit'] ?? 'kg';
          return {
            'name': p['name'] ?? '',
            'price': '₹${priceNum.toString()}/$unit',
            'imageUrl': (p['image_urls'] != null && (p['image_urls'] as List).isNotEmpty)
                ? p['image_urls'][0]
                : _resolveProduceImage(p['name'] ?? p['crop_name'], _categoryImages[category] ?? _categoryImages['default']!),
            'category': category,
            'rating': (p['rating'] ?? 4.8).toString(),
            'reviews': (p['reviews'] ?? 42).toString(),
            'id': p['id']?.toString() ?? '',
            'farmer': p['farmer_name'] ?? 'Ramesh Kumar',
          };
        }).toList();
        _isLoadingProducts = false;
      });
    } catch (e) {
      setState(() {
        _allProducts = [
          {
            "name": "Fresh Red Tomatoes (Nashik Special)",
            "price": "₹28/kg",
            "imageUrl": "https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=500&auto=format&fit=crop&q=80",
            "category": "Vegetables",
            "rating": "4.8",
            "reviews": "42",
            "farmer": "Ramesh Kumar"
          },
          {
            "name": "Fresh Kolar Potato",
            "price": "₹35/kg",
            "imageUrl": "https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=500&auto=format&fit=crop&q=80",
            "category": "Vegetables",
            "rating": "4.5",
            "reviews": "98",
            "farmer": "Suresh Patel"
          },
          {
            "name": "Organic Red Onions",
            "price": "₹22.5/kg",
            "imageUrl": "https://images.unsplash.com/photo-1618512496248-a07fe83aa8cf?w=500&auto=format&fit=crop&q=80",
            "category": "Vegetables",
            "rating": "4.6",
            "reviews": "28",
            "farmer": "Ramesh Kumar"
          },
          {
            "name": "Shimla Royal Delicious Apples",
            "price": "₹120/kg",
            "imageUrl": "https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=500&auto=format&fit=crop&q=80",
            "category": "Fruits",
            "rating": "4.95",
            "reviews": "65",
            "farmer": "Anita Sharma"
          },
          {
            "name": "Organic Himachal Honey",
            "price": "₹380/kg",
            "imageUrl": "https://images.unsplash.com/photo-1587049352846-4a222e784d38?w=500&auto=format&fit=crop&q=80",
            "category": "Fruits",
            "rating": "5.0",
            "reviews": "31",
            "farmer": "Anita Sharma"
          },
          {
            "name": "Organic Basmati Rice 1121",
            "price": "₹95/kg",
            "imageUrl": "https://images.unsplash.com/photo-1586201375761-83865001e31c?w=500&auto=format&fit=crop&q=80",
            "category": "Grains",
            "rating": "4.7",
            "reviews": "38",
            "farmer": "Vikram Singh"
          },
          {
            "name": "Premium Sharbati Wheat",
            "price": "₹42/kg",
            "imageUrl": "https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=500&auto=format&fit=crop&q=80",
            "category": "Grains",
            "rating": "4.9",
            "reviews": "56",
            "farmer": "Suresh Patel"
          },
          {
            "name": "Organic Tur Dal",
            "price": "₹120/kg",
            "imageUrl": "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&auto=format&fit=crop&q=80",
            "category": "Pulses",
            "rating": "4.7",
            "reviews": "76",
            "farmer": "Suresh Patel"
          },
        ];
        _isLoadingProducts = false;
      });
    }
  }

  void _updateCartItem(Map<String, dynamic> item, int delta) {
    final name = item['name'].toString();
    final priceStr = item['price'].toString();
    final rawImg = (item['imageUrl'] ?? '').toString();
    final imageUrl = _resolveProduceImage(name, rawImg.isNotEmpty ? rawImg : null);
    final farmer = (item['farmer'] ?? 'Ramesh Kumar').toString();

    final priceMatch = RegExp(r'[\d\.]+').firstMatch(priceStr);
    final priceNum = priceMatch != null ? (double.tryParse(priceMatch.group(0)!) ?? 30.0) : 30.0;

    _customerState.updateQuantity(name, priceNum, priceStr, imageUrl, farmer, delta);

    if (delta > 0) {
      _recService.recordInteraction(_activeCustomerId, name, "CART");
    }
    _loadRecommendations();

    final newQty = _customerState.getQuantity(name);
    final message = newQty > 0
        ? "Updated cart: $newQty kg of $name"
        : "Removed $name from cart";

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.lightGreenPrimary,
        action: SnackBarAction(
          label: "VIEW CART",
          textColor: Colors.white,
          onPressed: () {
            widget.onNavigateToCart?.call();
          },
        ),
      ),
    );
  }

  void _navigateToDetails(Map<String, dynamic> product) {
    final name = product['name']?.toString() ?? 'Produce';
    final img = _resolveProduceImage(name, product['imageUrl']);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CustomerProductDetailsScreen(
          productName: name,
          price: product['price'],
          imageUrl: img,
          category: product['category'],
          farmerName: product['farmer'],
          rating: product['rating'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter products based on active Search Query AND Selected Category Icon
    final filteredProducts = _allProducts.where((product) {
      final matchesSearch = product['name'].toString().toLowerCase().contains(searchQuery.toLowerCase());
      final matchesCategory = selectedCategory == "All" ||
          product['category'].toString().toLowerCase() == selectedCategory.toLowerCase();
      return matchesSearch && matchesCategory;
    }).toList();

    final totalCartCount = _customerState.cartCount;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "👋 Welcome ${_customerState.name.split(' ').first}",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    Text(
                      "${_customerState.role} • ${_customerState.location}",
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                Stack(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.mintLight,
                      child: const Icon(Icons.shopping_basket_outlined, color: AppColors.lightGreenPrimary),
                    ),
                    if (totalCartCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.accentOrange,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            "$totalCartCount",
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Mode Selector
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.creamSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.creamBorder),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: customerType,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down, color: AppColors.lightGreenPrimary),
                  items: const [
                    DropdownMenuItem(
                      value: "Individual Customer",
                      child: Text("Individual Customer Mode", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.text)),
                    ),
                    DropdownMenuItem(
                      value: "Hostel / PG",
                      child: Text("Hostel & PG Customer Mode", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.text)),
                    ),
                    DropdownMenuItem(
                      value: "Hospital",
                      child: Text("Hospital Customer Mode", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.text)),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        customerType = val;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Search Bar
            VoiceInputField(
              controller: _searchController,
              hintText: "Search organic produce & crops...",
              prefixIcon: Icons.search,
              onChanged: (val) {
                setState(() {
                  searchQuery = val;
                });
              },
            ),
            const SizedBox(height: 22),

            // Customer Mode Conditional View
            if (customerType == "Individual Customer") ...[
              _buildIndividualCustomerView(filteredProducts),
            ] else if (customerType == "Hostel / PG") ...[
              _buildHostelPgView(),
            ] else ...[
              _buildHospitalView(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIndividualCustomerView(List<Map<String, dynamic>> products) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---------------------------------------------------------------------
        // ⚖️ SECTION: FAIR PRICING & 4-WAY PAYOUT ACCESS
        // ---------------------------------------------------------------------
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FairPricingScreen()),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.scale, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        '⚖️ APMC Fair Pricing & 4-Way Split',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Farmer gets 68% direct payout (+268% boost)',
                        style: TextStyle(color: Color(0xFFE8F5E9), fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
              ],
            ),
          ),
        ),

        // ---------------------------------------------------------------------
        // 🥦 SECTION 1: INTERACTIVE CATEGORIES (Round Icons Click to Filter List)
        // ---------------------------------------------------------------------
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Categories",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text),
            ),
            if (selectedCategory != "All")
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedCategory = "All";
                  });
                },
                child: const Text("Show All", style: TextStyle(fontSize: 12, color: AppColors.lightGreenPrimary)),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _categories.map((cat) {
            final isSelected = selectedCategory.toLowerCase() == cat['title']!.toLowerCase();
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedCategory = cat['title']!;
                });
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      selectedCategory == "All"
                          ? "Showing all produce"
                          : "Filtered product list for ${cat['title']}",
                    ),
                    duration: const Duration(seconds: 1),
                    backgroundColor: AppColors.lightGreenPrimary,
                  ),
                );
              },
              child: Column(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? AppColors.lightGreenPrimary : AppColors.creamSurface,
                      border: Border.all(
                        color: isSelected ? AppColors.lightGreenPrimary : AppColors.creamBorder,
                        width: isSelected ? 2.5 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.lightGreenPrimary.withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              )
                            ]
                          : [],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.network(
                        cat['imageUrl']!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.mintLight,
                          child: const Icon(Icons.eco, color: AppColors.lightGreenPrimary),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    cat['title']!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? AppColors.lightGreenPrimary : AppColors.text,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 25),

        // ---------------------------------------------------------------------
        // 🛒 SECTION 2: RECOMMENDATIONS (Buy Again, Recommended, Frequently Bought Together)
        // ---------------------------------------------------------------------

        // 1. Buy Again
        if (_buyAgainRecs.isNotEmpty || _allProducts.isNotEmpty) ...[
          _buildMultiModelSection(
            title: "Buy Again",
            icon: Icons.replay_rounded,
            iconColor: AppColors.lightGreenPrimary,
            items: _buyAgainRecs.isNotEmpty ? _buyAgainRecs : _allProducts.take(4).toList(),
          ),
          const SizedBox(height: 25),
        ],

        // 2. Recommended For You (Collaborative Filtering)
        if (_pickedForYouRecs.isNotEmpty || _allProducts.isNotEmpty) ...[
          _buildMultiModelSection(
            title: "Recommended For You",
            icon: Icons.favorite_border,
            iconColor: const Color(0xFFC62828),
            items: _pickedForYouRecs.isNotEmpty ? _pickedForYouRecs : _allProducts.skip(2).take(4).toList(),
          ),
          const SizedBox(height: 25),
        ],

        // 3. Frequently Bought Together (FP-Growth Association Rules)
        if (_youMayAlsoWantRecs.isNotEmpty || _allProducts.isNotEmpty) ...[
          _buildMultiModelSection(
            title: "Frequently Bought Together",
            icon: Icons.shopping_bag_outlined,
            iconColor: AppColors.accentOrange,
            items: _youMayAlsoWantRecs.isNotEmpty ? _youMayAlsoWantRecs : _allProducts.skip(4).take(4).toList(),
          ),
          const SizedBox(height: 25),
        ],

        // ---------------------------------------------------------------------
        // 🌽 SECTION 3: ALL CROP LISTINGS (Category & Search Filtered)
        // ---------------------------------------------------------------------
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedCategory != "All"
                  ? "$selectedCategory Produce"
                  : (searchQuery.isNotEmpty ? "Search Results" : "Fresh Farm Produce"),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text),
            ),
            TextButton.icon(
              onPressed: _loadProducts,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text("Refresh", style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_isLoadingProducts)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 30),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (products.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.search_off, size: 48, color: Colors.grey),
                  const SizedBox(height: 8),
                  Text(
                    "No produce found for category \"$selectedCategory\"${searchQuery.isNotEmpty ? ' matching "$searchQuery"' : ''}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          )
        else
          Column(
            children: products.map((prod) {
              final qty = _customerState.getQuantity(prod['name']);
              return ProductCard(
                productName: prod['name'],
                price: prod['price'],
                imageUrl: prod['imageUrl'] ?? '',
                rating: prod['rating'],
                reviews: prod['reviews'],
                farmerName: prod['farmer'] ?? 'Ramesh Kumar',
                quantityInCart: qty,
                onTap: () => _navigateToDetails(prod),
                onAdd: () => _updateCartItem(prod, 1),
                onMinus: () => _updateCartItem(prod, -1),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildHostelPgView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Hostel & PG Mess Procurement",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          title: "Bulk Produce Orders",
          subtitle: "Order 50kg - 1000kg sacks with wholesale discounts.",
          icon: Icons.scale,
          color: AppColors.lightGreenPrimary,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BulkOrderScreen()),
            );
          },
        ),
        _buildActionCard(
          title: "Recurring Mess Subscriptions",
          subtitle: "Schedule automated weekly deliveries for tomatoes, onions & rice.",
          icon: Icons.loop,
          color: AppColors.accentOrange,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RecurringOrderScreen()),
            );
          },
        ),
        const SizedBox(height: 20),
        _buildMultiModelSection(
          title: "Frequently Ordered for Mess",
          icon: Icons.replay_rounded,
          iconColor: AppColors.lightGreenPrimary,
          items: _buyAgainRecs.isNotEmpty ? _buyAgainRecs : _allProducts.take(4).toList(),
        ),
        const SizedBox(height: 20),
        _buildMultiModelSection(
          title: "Popular Mess Pairings",
          icon: Icons.shopping_bag_outlined,
          iconColor: AppColors.accentOrange,
          items: _youMayAlsoWantRecs.isNotEmpty ? _youMayAlsoWantRecs : _allProducts.skip(4).take(4).toList(),
        ),
      ],
    );
  }

  Widget _buildHospitalView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Hospital Dietary Procurement",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          title: "Quality Inspection Reports",
          subtitle: "View lab-tested pesticide and organic residue certificates.",
          icon: Icons.verified,
          color: AppColors.lightGreenPrimary,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const QaTrackingScreen()),
            );
          },
        ),
        const SizedBox(height: 20),
        _buildMultiModelSection(
          title: "Frequently Ordered Dietary Items",
          icon: Icons.replay_rounded,
          iconColor: AppColors.lightGreenPrimary,
          items: _buyAgainRecs.isNotEmpty ? _buyAgainRecs : _allProducts.take(4).toList(),
        ),
        const SizedBox(height: 20),
        _buildMultiModelSection(
          title: "Recommended Nutrition Essentials",
          icon: Icons.favorite_border,
          iconColor: const Color(0xFFC62828),
          items: _pickedForYouRecs.isNotEmpty ? _pickedForYouRecs : _allProducts.skip(2).take(4).toList(),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.creamSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.creamBorder),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          radius: 24,
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Widget _buildMultiModelSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Map<String, dynamic>> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 240,
          child: _isLoadingRecs
              ? const Center(child: CircularProgressIndicator())
              : items.isEmpty
                  ? const Center(child: Text("No items available", style: TextStyle(fontSize: 12, color: Colors.grey)))
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final name = item['crop_name'] ?? item['name'] ?? 'Fresh Produce';
                        final price = item['price_per_unit'] != null
                            ? '₹${item['price_per_unit']}/${item['unit'] ?? 'kg'}'
                            : (item['price']?.toString() ?? '₹35/kg');
                        final img = _resolveProduceImage(name, item['image_url'] ?? item['imageUrl']);
                        final farmer = item['farmer_name'] ?? item['farmer'] ?? 'Mandya Corridor Farmer';
                        final rating = (item['rating_avg'] ?? item['rating'] ?? 4.8).toString();
                        final qty = _customerState.getQuantity(name);

                        return RecommendationCard(
                          name: name,
                          price: price,
                          rating: '$rating ⭐',
                          imageUrl: img,
                          farmer: farmer,
                          quantityInCart: qty,
                          onTap: () => _navigateToDetails({
                            'name': name,
                            'price': price,
                            'imageUrl': img,
                            'farmer': farmer,
                            'rating': rating,
                            'category': item['category'] ?? 'Vegetables',
                          }),
                          onAdd: () => _updateCartItem({
                            'name': name,
                            'price': price,
                            'imageUrl': img,
                            'farmer': farmer,
                            'rating': rating,
                            'category': item['category'] ?? 'Vegetables',
                          }, 1),
                          onMinus: () => _updateCartItem({
                            'name': name,
                            'price': price,
                            'imageUrl': img,
                            'farmer': farmer,
                            'rating': rating,
                            'category': item['category'] ?? 'Vegetables',
                          }, -1),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// 🟢 RECOMMENDATION CARD WITH DIRECT - / + QUICK CART CONTROLS & CLEAN HEIGHT
// -----------------------------------------------------------------------------
class RecommendationCard extends StatelessWidget {
  final String name;
  final String price;
  final String rating;
  final String imageUrl;
  final String farmer;
  final int quantityInCart;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final VoidCallback onMinus;

  const RecommendationCard({
    super.key,
    required this.name,
    required this.price,
    required this.rating,
    required this.imageUrl,
    required this.farmer,
    required this.quantityInCart,
    required this.onTap,
    required this.onAdd,
    required this.onMinus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: AppColors.creamSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.creamBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Produce Image Stack (Clicking image or title opens full product description)
          GestureDetector(
            onTap: onTap,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                  child: Image.network(
                    imageUrl,
                    height: 95,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 95,
                      color: AppColors.mintLight,
                      child: const Icon(Icons.eco, color: AppColors.lightGreenPrimary),
                    ),
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      rating,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Name, Price & Quick Cart Controls
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tapping name opens full description
                GestureDetector(
                  onTap: onTap,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.text),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        price,
                        style: const TextStyle(color: AppColors.lightGreenPrimary, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Direct [-] [ Qty ] [+] Quick Cart Buttons
                Row(
                  children: [
                    if (quantityInCart > 0) ...[
                      InkWell(
                        onTap: onMinus,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.mintLight,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.lightGreenAccent),
                          ),
                          child: const Icon(Icons.remove, size: 14, color: AppColors.lightGreenPrimary),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          "$quantityInCart",
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.lightGreenPrimary),
                        ),
                      ),
                    ],
                    Expanded(
                      child: InkWell(
                        onTap: onAdd,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.lightGreenPrimary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.add, size: 14, color: Colors.white),
                              SizedBox(width: 2),
                              Text("Add", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 🟢 PRODUCT CARD WITH DIRECT - / + QUICK CART CONTROLS & FULL DESCRIPTION TAP
// -----------------------------------------------------------------------------
class ProductCard extends StatelessWidget {
  final String productName;
  final String price;
  final String imageUrl;
  final String rating;
  final String reviews;
  final String farmerName;
  final int quantityInCart;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final VoidCallback onMinus;

  const ProductCard({
    super.key,
    required this.productName,
    required this.price,
    required this.imageUrl,
    required this.rating,
    required this.reviews,
    required this.farmerName,
    required this.quantityInCart,
    required this.onTap,
    required this.onAdd,
    required this.onMinus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.creamSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.creamBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              // Product Image (Clicking opens details)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 64,
                    height: 64,
                    color: AppColors.mintLight,
                    child: const Icon(Icons.eco, color: AppColors.lightGreenPrimary),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Title & Info (Clicking opens details)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.text),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Farmer: $farmerName",
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          price,
                          style: const TextStyle(color: AppColors.lightGreenPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        Text(
                          " $rating ($reviews)",
                          style: const TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Direct [-] [ Qty ] [+] Quick Cart Controls
              Container(
                decoration: BoxDecoration(
                  color: AppColors.mintLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.lightGreenAccent),
                ),
                child: Row(
                  children: [
                    if (quantityInCart > 0) ...[
                      IconButton(
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.remove, size: 16, color: AppColors.lightGreenPrimary),
                        onPressed: onMinus,
                      ),
                      Text(
                        "$quantityInCart",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.lightGreenPrimary),
                      ),
                    ],
                    IconButton(
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.add, size: 16, color: AppColors.lightGreenPrimary),
                      onPressed: onAdd,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}