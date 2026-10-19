import 'package:flutter/material.dart';
import '../../services/platform_state.dart';
import '../../services/recommendation_service.dart';
import '../customer/fair_pricing_screen.dart';
import 'earnings_screen.dart';
import 'products/add_product_screen.dart';
import 'orders_tab.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final PlatformState _platformState = PlatformState();
  final RecommendationService _recService = RecommendationService();

  Map<String, dynamic> _stats = {
    'earnings': '₹0',
    'pendingOrders': '—',
    'products': '—',
    'rating': '4.9 ⭐',
  };
  List<Map<String, dynamic>> _farmerCropOpportunities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _platformState.addListener(_onPlatformStateChange);
    _loadDashboardData();
  }

  @override
  void dispose() {
    _platformState.removeListener(_onPlatformStateChange);
    super.dispose();
  }

  void _onPlatformStateChange() {
    if (mounted) _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final user = _platformState.currentUser;
      final farmerName = user.fullName;
      final syncedOrders = _platformState.getFarmerOrders(farmerName);
      final farmerEarnings = _platformState.getFarmerTotalEarnings(farmerName);
      final farmerProducts = _platformState.getProductsForFarmer(farmerName);

      final isSeedAccount = farmerName.toLowerCase().contains("ramesh") || user.id == "11111111-1111-1111-1111-111111111111";

      final pendingCount = syncedOrders.where((o) => o.status != 'DELIVERED').length;

      final displayEarnings = farmerEarnings > 0 
          ? '₹${farmerEarnings.toStringAsFixed(0)}' 
          : (isSeedAccount ? '₹2,584' : '₹0');

      final displayOrders = syncedOrders.isNotEmpty
          ? pendingCount.toString()
          : (isSeedAccount ? '2' : '0');

      final displayProducts = farmerProducts.isNotEmpty
          ? '${farmerProducts.length} Crops'
          : (isSeedAccount ? '6 Crops' : '0 Crops');

      // Fetch AI Demand Crop Opportunities
      final opps = await _recService.getFarmerCropOpportunities(user.id);

      setState(() {
        _stats = {
          'earnings': displayEarnings,
          'pendingOrders': displayOrders,
          'products': displayProducts,
          'rating': '5.0 ⭐',
        };
        _farmerCropOpportunities = opps;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _stats = {
          'earnings': '₹0',
          'pendingOrders': '0',
          'products': '0 Crops',
          'rating': '5.0 ⭐',
        };
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final user = _platformState.currentUser;
    final tomatoPrice = _platformState.getBreakdown('Tomato');

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "👋 Good Morning",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        user.fullName,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${user.region} • Direct Producer",
                        style: const TextStyle(color: Colors.green, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  if (_isLoading)
                    const CircularProgressIndicator()
                  else
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.green),
                      onPressed: _loadDashboardData,
                      tooltip: 'Refresh',
                    ),
                ],
              ),

              const SizedBox(height: 20),

              // ---------------------------------------------------------------
              // ⚖️ APMC FAIR PRICING & 68% PAYOUT ORACLE BANNER
              // ---------------------------------------------------------------
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
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.analytics, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '⚖️ APMC Dynamic Pricing Oracle',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Your 68% Payout: ₹${tomatoPrice.farmerPayout.toStringAsFixed(2)}/kg on Grade A+ Tomato (+268% boost vs mandi)',
                              style: const TextStyle(color: Color(0xFFE8F5E9), fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Stats Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  DashboardCard(
                    title: "Farmer Payout (68%)",
                    value: _isLoading ? '...' : _stats['earnings'],
                    icon: Icons.currency_rupee,
                    isLive: !_isLoading,
                    color: Colors.green,
                  ),
                  DashboardCard(
                    title: "Active Orders",
                    value: _isLoading ? '...' : _stats['pendingOrders'],
                    icon: Icons.shopping_cart,
                    isLive: !_isLoading,
                    color: Colors.orange,
                  ),
                  DashboardCard(
                    title: "Listed Produce",
                    value: _isLoading ? '...' : _stats['products'],
                    icon: Icons.eco,
                    isLive: !_isLoading,
                    color: Colors.teal,
                  ),
                  DashboardCard(
                    title: "Quality Rating",
                    value: _isLoading ? '...' : _stats['rating'],
                    icon: Icons.star,
                    isLive: !_isLoading,
                    color: Colors.amber.shade800,
                  ),
                ],
              ),

              const SizedBox(height: 25),

              if (_farmerCropOpportunities.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "💡 High-Demand Crop Opportunities",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "AI Demand Gap",
                      style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 130,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _farmerCropOpportunities.length,
                    itemBuilder: (context, index) {
                      final item = _farmerCropOpportunities[index];
                      return Container(
                        width: 220,
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item['crop_name'] ?? 'Crop',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade700,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'Score: ${((item['opportunity_score'] ?? 0.85) * 100).toStringAsFixed(0)}%',
                                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item['reason'] ?? 'High demand gap in North Bengaluru.',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                            ),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Gap: ${item['supply_gap'] ?? item['quantity_demand'] ?? 500} kg',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  'APMC: ₹${item['predicted_price'] ?? 40}/kg',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 25),
              ],

              const Text(
                "Quick Actions",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),


              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(Icons.add, color: Colors.white),
                  ),
                  title: const Text("Add New Harvest Listing"),
                  subtitle: const Text("List produce at APMC-linked fair pricing"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddProductScreen()),
                    );
                  },
                ),
              ),

              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.receipt_long, color: Colors.white),
                  ),
                  title: const Text("Customer Orders & 68% Payouts"),
                  subtitle: const Text("Live orders dispatched via aggregator"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const OrdersTab()),
                    );
                  },
                ),
              ),

              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.orange,
                    child: Icon(Icons.account_balance_wallet, color: Colors.white),
                  ),
                  title: const Text("Payouts & Direct Bank Settlement"),
                  subtitle: const Text("View Razorpay escrow deposits"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EarningsScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final bool isLive;
  final Color color;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.isLive = false,
    this.color = Colors.green,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color, size: 22),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
