import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../core/colors.dart';
import '../../services/recommendation_service.dart';
import '../../services/customer_state.dart';
import 'products/product_details_screen.dart';

class DiscoverTab extends StatefulWidget {
  const DiscoverTab({super.key});

  @override
  State<DiscoverTab> createState() => _DiscoverTabState();
}

class _DiscoverTabState extends State<DiscoverTab> {
  final RecommendationService _recService = RecommendationService();
  final CustomerState _customerState = CustomerState();

  bool _isLoading = true;
  bool _isNewCustomer = false;
  String _mode = 'personalized';

  List<Map<String, dynamic>> _nextBasket = [];
  List<Map<String, dynamic>> _recencyWeighted = [];
  List<Map<String, dynamic>> _priceAware = [];
  List<Map<String, dynamic>> _localPopular = [];

  static const Map<String, String> _cropImages = {
    "Tomato": "https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=600&auto=format&fit=crop&q=80",
    "Potato": "https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=600&auto=format&fit=crop&q=80",
    "Onion": "https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?w=600&auto=format&fit=crop&q=80",
    "Carrot": "https://images.unsplash.com/photo-1598170845058-12f6a67a9657?w=600&auto=format&fit=crop&q=80",
    "Cabbage": "https://images.unsplash.com/photo-1594282486552-05b4d80fbb9f?w=600&auto=format&fit=crop&q=80",
    "Green Peas": "https://images.unsplash.com/photo-1587735243615-c03f25aaff15?w=600&auto=format&fit=crop&q=80",
    "Green Chilli": "https://images.unsplash.com/photo-1588252303782-cb80119abd6d?w=600&auto=format&fit=crop&q=80",
    "Palak": "https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=600&auto=format&fit=crop&q=80",
    "Coriander": "https://images.unsplash.com/photo-1608797178974-15b35a6018b3?w=600&auto=format&fit=crop&q=80",
    "Banana": "https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=600&auto=format&fit=crop&q=80",
    "Papaya": "https://images.unsplash.com/photo-1526318897912-3283331804f1?w=600&auto=format&fit=crop&q=80",
    "Rice": "https://images.unsplash.com/photo-1586201375761-83865001e31c?w=600&auto=format&fit=crop&q=80",
    "Apple": "https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=600&auto=format&fit=crop&q=80",
    "Wheat": "https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=600&auto=format&fit=crop&q=80",
    "Beans": "https://images.unsplash.com/photo-1567375698348-5d9d5ae99de0?w=600&auto=format&fit=crop&q=80",
    "Brinjal": "https://images.unsplash.com/photo-1582284540020-8acbe03f4924?w=600&auto=format&fit=crop&q=80",
    "Orange": "https://images.unsplash.com/photo-1547514701-42782101795e?w=600&auto=format&fit=crop&q=80",
    "Cucumber": "https://images.unsplash.com/photo-1449300079323-02e209d9d3a6?w=600&auto=format&fit=crop&q=80",
    "Ginger": "https://images.unsplash.com/photo-1615485290382-441e4d049cb5?w=600&auto=format&fit=crop&q=80",
    "Garlic": "https://images.unsplash.com/photo-1540148426945-6cf22a6b2383?w=600&auto=format&fit=crop&q=80",
  };

  String _resolveImage(String? cropName, String? fallback) {
    if (cropName != null && _cropImages.containsKey(cropName)) {
      return _cropImages[cropName]!;
    }
    if (cropName != null) {
      for (final entry in _cropImages.entries) {
        if (cropName.toLowerCase().contains(entry.key.toLowerCase())) {
          return entry.value;
        }
      }
    }
    return fallback ?? _cropImages['Tomato']!;
  }

  @override
  void initState() {
    super.initState();
    _loadDiscover();
  }

  Future<void> _loadDiscover() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final customerId = _customerState.customerId;
    final data = await _recService.getDiscoverDashboard(customerId);

    if (data != null && mounted) {
      final sections = data['sections'] as Map<String, dynamic>? ?? {};
      setState(() {
        _isNewCustomer = data['is_new_customer'] as bool? ?? false;
        _mode = data['mode'] as String? ?? 'personalized';

        _nextBasket = _extractItems(sections['next_basket']);
        _recencyWeighted = _extractItems(sections['recency_weighted']);
        _priceAware = _extractItems(sections['price_smart']);
        _localPopular = _extractItems(sections['local_popular']);
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> _extractItems(dynamic section) {
    if (section == null) return [];
    final items = (section as Map<String, dynamic>)['items'];
    if (items == null) return [];
    return List<Map<String, dynamic>>.from(
      (items as List<dynamic>).map((e) => Map<String, dynamic>.from(e)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        color: AppColors.lightGreenPrimary,
        onRefresh: _loadDiscover,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            if (_isLoading)
              const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
            else ...[
              if (_isNewCustomer) SliverToBoxAdapter(child: _buildColdStartBanner()),
              SliverToBoxAdapter(child: _buildMLStatusChip()),
              SliverToBoxAdapter(
                child: _buildSection(
                  title: 'Your Next Picks',
                  subtitle: _isNewCustomer
                      ? 'Top picks for new members — start your first basket!'
                      : 'Predicted from your basket patterns',
                  icon: Icons.shopping_basket_rounded,
                  color: const Color(0xFF2E7D32),
                  items: _nextBasket,
                  emptyMessage: 'Start buying to unlock next-basket predictions',
                ),
              ),
              SliverToBoxAdapter(
                child: _buildSection(
                  title: 'Fresh on Your Radar',
                  subtitle: _isNewCustomer
                      ? 'Freshest farm produce available right now'
                      : 'Items you bought recently, still available and fresh',
                  icon: Icons.timer_outlined,
                  color: const Color(0xFF00838F),
                  items: _recencyWeighted,
                  emptyMessage: 'Your recent purchases will appear here',
                ),
              ),
              SliverToBoxAdapter(
                child: _buildSection(
                  title: 'Price-Smart Picks',
                  subtitle: _isNewCustomer
                      ? 'Best value farm produce for your budget'
                      : 'Matches your usual spending range',
                  icon: Icons.currency_rupee_rounded,
                  color: const Color(0xFFE65100),
                  items: _priceAware,
                  emptyMessage: 'Price-aware suggestions coming soon',
                ),
              ),
              SliverToBoxAdapter(
                child: _buildSection(
                  title: 'Popular Near You',
                  subtitle: 'Trending in your local area — what your neighbours are buying',
                  icon: Icons.location_on_outlined,
                  color: const Color(0xFF6A1B9A),
                  items: _localPopular,
                  emptyMessage: 'Local popularity data loading...',
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF388E3C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              Text(
                'Discover',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white70),
                onPressed: _loadDiscover,
                tooltip: 'Refresh recommendations',
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'ML-powered picks just for ${_customerState.name.split(' ').first}',
            style: const TextStyle(color: Color(0xFFE8F5E9), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildColdStartBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFCC02), width: 1.5),
      ),
      child: Row(
        children: [
          const Text('👋', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome to AgriLink!',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SizedBox(height: 2),
                Text(
                  'These are trending picks from Mandya-Bengaluru farms. As you shop, we\'ll personalise these for you.',
                  style: TextStyle(fontSize: 12, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMLStatusChip() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.lightGreenPrimary.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2E7D32),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _mode == 'personalized' ? 'ML Personalised' : 'Popularity-Based',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            '4 models • Live from farm data',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required List<Map<String, dynamic>> items,
    required String emptyMessage,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                emptyMessage,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            )
          else
            SizedBox(
              height: 210,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return _buildRecommendationCard(items[index], color);
                },
              ),
            ),
          const SizedBox(height: 4),
          Divider(color: Colors.grey.withOpacity(0.15)),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(Map<String, dynamic> item, Color accentColor) {
    final cropName = item['crop_name']?.toString() ?? 'Produce';
    final price = item['price_per_unit'];
    final priceStr = price != null ? '₹${price.toString()}/kg' : '₹30/kg';
    final rating = (item['rating_avg'] ?? 4.8).toString();
    final grade = item['grade']?.toString() ?? 'A';
    final isOrganic = item['is_organic'] as bool? ?? false;
    final score = ((item['score'] ?? 0.85) * 100).toInt();
    final reason = item['reason']?.toString() ?? '';
    final badge = item['badge']?.toString() ?? '';
    final imageUrl = _resolveImage(cropName, item['image_url']?.toString());

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CustomerProductDetailsScreen(
              productName: cropName,
              price: priceStr,
              imageUrl: imageUrl,
              category: 'Vegetables',
              farmerName: 'Mandya Local Farmer',
              rating: rating,
            ),
          ),
        );
      },
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image + badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                  child: Image.network(
                    imageUrl,
                    height: 100,
                    width: 160,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 100,
                      width: 160,
                      color: const Color(0xFFE8F5E9),
                      child: const Icon(Icons.eco, color: Color(0xFF2E7D32), size: 36),
                    ),
                  ),
                ),
                if (badge.isNotEmpty)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                if (isOrganic)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.shade800,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'ORG',
                        style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
            // Details
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cropName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        priceStr,
                        style: TextStyle(
                          color: accentColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Grade $grade',
                          style: const TextStyle(fontSize: 9, color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 11, color: Colors.amber),
                      const SizedBox(width: 2),
                      Text(rating, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      const Spacer(),
                      Text(
                        '$score% match',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: accentColor.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                  if (reason.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      reason,
                      style: const TextStyle(fontSize: 9, color: Colors.grey),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
