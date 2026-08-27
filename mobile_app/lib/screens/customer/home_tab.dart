import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../services/product_service.dart';
import '../../services/customer_state.dart';
import 'products/product_details_screen.dart';
import 'bulk_order_screen.dart';
import 'recurring_order_screen.dart';
import 'qa_tracking_screen.dart';
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

  List<Map<String, dynamic>> _allProducts = [];
  bool _isLoadingProducts = true;

  // Local cart quantities map: productName -> quantity
  final Map<String, int> _cartQuantities = {};

  // Previously ordered items history (explicitly shown for ML context demonstration)
  final List<Map<String, String>> _previousOrders = [
    {
      "name": "Fresh Red Tomatoes (Nashik Special)",
      "crop_name": "Tomato",
      "quantity": "50 kg",
      "price": "₹1,400",
      "date": "Delivered July 28, 2026",
      "farmer": "Ramesh Kumar",
      "imageUrl": "https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=500&auto=format&fit=crop&q=80"
    },
    {
      "name": "Shimla Royal Delicious Apples",
      "crop_name": "Apple",
      "quantity": "20 kg",
      "price": "₹2,400",
      "date": "Delivered July 25, 2026",
      "farmer": "Anita Sharma",
      "imageUrl": "https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=500&auto=format&fit=crop&q=80"
    },
    {
      "name": "Organic Red Onions",
      "crop_name": "Onion",
      "quantity": "30 kg",
      "price": "₹675",
      "date": "Delivered July 20, 2026",
      "farmer": "Ramesh Kumar",
      "imageUrl": "https://images.unsplash.com/photo-1618512496248-a07fe83aa8cf?w=500&auto=format&fit=crop&q=80"
    },
  ];

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

  static const Map<String, String> _categoryImages = {
    'Vegetables': 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=500&auto=format&fit=crop&q=80',
    'Fruits': 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=500&auto=format&fit=crop&q=80',
    'Grains': 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=500&auto=format&fit=crop&q=80',
    'Pulses': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&auto=format&fit=crop&q=80',
    'default': 'https://images.unsplash.com/photo-1598170845058-12f6a67a9657?w=500&auto=format&fit=crop&q=80',
  };

  @override
  void initState() {
    super.initState();
    _customerState.addListener(_onCustomerStateChange);
    _loadProducts();
  }

  @override
  void dispose() {
    _customerState.removeListener(_onCustomerStateChange);
    _searchController.dispose();
    super.dispose();
  }

  void _onCustomerStateChange() {
    if (mounted) setState(() {});
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
                : (_categoryImages[category] ?? _categoryImages['default']!),
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
    final imageUrl = (item['imageUrl'] ?? '').toString();
    final farmer = (item['farmer'] ?? 'Ramesh Kumar').toString();

    final priceMatch = RegExp(r'[\d\.]+').firstMatch(priceStr);
    final priceNum = priceMatch != null ? (double.tryParse(priceMatch.group(0)!) ?? 30.0) : 30.0;

    _customerState.updateQuantity(name, priceNum, priceStr, imageUrl, farmer, delta);

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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CustomerProductDetailsScreen(
          productName: product['name'],
          price: product['price'],
          imageUrl: product['imageUrl'],
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

    final totalCartCount = _cartQuantities.values.fold(0, (sum, q) => sum + q);

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
                  children: const [
                    Text(
                      "👋 Welcome Priya",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    Text(
                      "Farm-to-Customer Supply Hub",
                      style: TextStyle(
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
    final recommendations = _allProducts.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        // 📦 SECTION 2: PREVIOUS ORDERS (Demonstrating ML Input Data Context)
        // ---------------------------------------------------------------------
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: const [
                Icon(Icons.history, color: AppColors.lightGreenPrimary, size: 22),
                SizedBox(width: 6),
                Text(
                  "Your Order History",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.mintLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.lightGreenAccent),
              ),
              child: const Text(
                "ML Input Context",
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.lightGreenPrimary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          "Items you previously ordered. The LightFM AI model uses these records to generate your recommendations below:",
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 105,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _previousOrders.length,
            itemBuilder: (context, index) {
              final ord = _previousOrders[index];
              return Container(
                width: 250,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(10),
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
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        ord['imageUrl']!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 50,
                          height: 50,
                          color: AppColors.mintLight,
                          child: const Icon(Icons.eco, color: AppColors.lightGreenPrimary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            ord['name']!,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.text),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppColors.mintLight,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  ord['quantity']!,
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.lightGreenPrimary),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(ord['price']!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.text)),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            ord['date']!,
                            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 25),

        // ---------------------------------------------------------------------
        // 🤖 SECTION 3: AI RECOMMENDED FOR YOU (With Fixed 240px Height)
        // ---------------------------------------------------------------------
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: const [
                Icon(Icons.auto_awesome, color: AppColors.warmGold, size: 22),
                SizedBox(width: 6),
                Text(
                  "Recommended for You",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: const Text(
                "LightFM Model Top Picks",
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.warmGold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // SizedBox height fixed to 240px to completely prevent bottom overflow!
        SizedBox(
          height: 240,
          child: _isLoadingProducts
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: recommendations.length,
                  itemBuilder: (context, index) {
                    final item = recommendations[index];
                    final qty = _customerState.getQuantity(item['name']);
                    return RecommendationCard(
                      name: item['name'],
                      price: item['price'],
                      rating: '${item['rating']} ⭐',
                      imageUrl: item['imageUrl'],
                      farmer: item['farmer'] ?? 'Ramesh Kumar',
                      quantityInCart: qty,
                      onTap: () => _navigateToDetails(item),
                      onAdd: () => _updateCartItem(item, 1),
                      onMinus: () => _updateCartItem(item, -1),
                    );
                  },
                ),
        ),
        const SizedBox(height: 25),

        // ---------------------------------------------------------------------
        // 🌽 SECTION 4: ALL CROP LISTINGS (Category & Search Filtered)
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