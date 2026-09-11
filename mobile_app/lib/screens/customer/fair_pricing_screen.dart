import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../services/pricing_service.dart';
import '../../services/platform_state.dart';

class FairPricingScreen extends StatefulWidget {
  const FairPricingScreen({super.key});

  @override
  State<FairPricingScreen> createState() => _FairPricingScreenState();
}

class _FairPricingScreenState extends State<FairPricingScreen> {
  final PricingService _pricingService = PricingService();

  String _selectedCommodity = 'Tomato';
  String _selectedOrigin = 'Mandya';
  String _selectedGrade = 'Grade A+';
  bool _isOrganic = true;

  final Map<String, double> _distanceMap = {
    'Mandya': 85.0,
    'Maddur': 75.0,
    'Srirangapatna': 115.0,
    'Ramanagara': 50.0,
  };

  final List<String> _commodities = [
    'Tomato', 'Potato', 'Onion', 'Carrot', 'Palak',
    'Ginger', 'Garlic', 'Banana', 'Pomegranate', 'Ragi', 'Rice'
  ];

  Map<String, dynamic>? _pricingData;
  Map<String, double> _benchmarks = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchPricing();
    _fetchBenchmarks();
  }

  Future<void> _fetchPricing() async {
    setState(() => _isLoading = true);
    final data = await _pricingService.calculateFairShare(
      commodity: _selectedCommodity,
      variety: _isOrganic ? 'Organic Certified' : 'Hybrid / Nati',
      grade: _selectedGrade,
      originDistrict: _selectedOrigin,
      distanceKm: _distanceMap[_selectedOrigin] ?? 85.0,
      isOrganic: _isOrganic,
    );
    if (data != null) {
      final consumer = (data['fair_consumer_price_rs_per_kg'] as num?)?.toDouble() ?? 44.69;
      final shares = data['value_chain_split'] as Map<String, dynamic>? ?? {};
      final farmerP = (shares['farmer_payout_rs'] as num?)?.toDouble() ?? (consumer * 0.68);
      final aggP = (shares['aggregator_share_rs'] as num?)?.toDouble() ?? (consumer * 0.10);
      final delP = (shares['delivery_share_rs'] as num?)?.toDouble() ?? (consumer * 0.14);
      final platP = (shares['platform_share_rs'] as num?)?.toDouble() ?? (consumer * 0.08);
      final bench = (data['apmc_modal_price_rs_per_kg'] as num?)?.toDouble() ?? 25.77;

      PlatformState().updatePricing(
        commodity: _selectedCommodity,
        consumerPrice: consumer,
        farmerPayout: farmerP,
        aggregatorShare: aggP,
        deliveryShare: delP,
        platformFee: platP,
        apmcBenchmark: bench,
      );
    }
    if (mounted) {
      setState(() {
        _pricingData = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchBenchmarks() async {
    final benchmarks = await _pricingService.getApmcBenchmarks();
    if (mounted) {
      setState(() => _benchmarks = benchmarks);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      appBar: AppBar(
        backgroundColor: AppColors.lightGreenPrimary,
        foregroundColor: Colors.white,
        title: const Text('Fair Pricing & 4-Way Payout', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Mandya ➔ Bengaluru Pricing Oracle',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Trained on 15,500+ APMC government mandi records to guarantee 68% direct payout to farmers while saving consumers 20% vs city supermarkets.',
                    style: TextStyle(color: Color(0xFFE8F5E9), fontSize: 12, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Controls Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Dynamic Pricing Simulator', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.lightGreenPrimary)),
                    const SizedBox(height: 14),

                    // Commodity Dropdown
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Commodity', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<String>(
                                initialValue: _selectedCommodity,
                                isDense: true,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                items: _commodities.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13)))).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    _selectedCommodity = val;
                                    _fetchPricing();
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Corridor Origin', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<String>(
                                initialValue: _selectedOrigin,
                                isDense: true,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                items: _distanceMap.keys.map((o) => DropdownMenuItem(value: o, child: Text('$o (${_distanceMap[o]?.toInt()}km)', style: const TextStyle(fontSize: 13)))).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    _selectedOrigin = val;
                                    _fetchPricing();
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Grade & Organic Toggle
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Quality Grade', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<String>(
                                initialValue: _selectedGrade,
                                isDense: true,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                items: ['Grade A+', 'Grade A', 'Grade B'].map((g) => DropdownMenuItem(value: g, child: Text(g, style: const TextStyle(fontSize: 13)))).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    _selectedGrade = val;
                                    _fetchPricing();
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Farming Type', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<bool>(
                                initialValue: _isOrganic,
                                isDense: true,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                items: const [
                                  DropdownMenuItem(value: true, child: Text('Organic Certified', style: TextStyle(fontSize: 13))),
                                  DropdownMenuItem(value: false, child: Text('Conventional', style: TextStyle(fontSize: 13))),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    _isOrganic = val;
                                    _fetchPricing();
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Live Calculation Result
            if (_isLoading)
              const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
            else if (_pricingData != null) ...[
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_pricingData!['commodity']} (${_pricingData!['corridor']})',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1B5E20)),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'APMC Benchmark: ₹${_pricingData!['apmc_mandi_benchmark_per_kg']}/kg',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('FAIR CONSUMER PRICE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                              Text(
                                '₹${_pricingData!['predicted_fair_consumer_price_per_kg']}/kg',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.lightGreenPrimary),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      const Text('4-Way Value Share Breakdown:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 12),

                      // 4 Shares Grid
                      _buildShareRow('🌾 Farmer (Producer)', '68%', _pricingData!['fair_share_breakdown']['farmer']['payout_per_kg'], const Color(0xFFE8F5E9), const Color(0xFF2E7D32)),
                      const SizedBox(height: 8),
                      _buildShareRow('👩‍🌾 SHG Aggregator', '10%', _pricingData!['fair_share_breakdown']['aggregator']['payout_per_kg'], const Color(0xFFFFF8E1), const Color(0xFFF57F17)),
                      const SizedBox(height: 8),
                      _buildShareRow('🚚 Delivery Partner', '14%', _pricingData!['fair_share_breakdown']['delivery_partner']['payout_per_kg'], const Color(0xFFE1F5FE), const Color(0xFF0277BD)),
                      const SizedBox(height: 8),
                      _buildShareRow('⚡ AgriLink Tech', '8%', _pricingData!['fair_share_breakdown']['platform']['payout_per_kg'], const Color(0xFFF3E5F5), const Color(0xFF7B1FA2)),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),
            // APMC Corridor Benchmarks Card
            if (_benchmarks.isNotEmpty) ...[
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('APMC Mandi Benchmarks (Karnataka)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.text)),
                      const SizedBox(height: 10),
                      ..._benchmarks.entries.take(6).map((e) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(e.key, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                            Text('₹${e.value.toStringAsFixed(2)}/kg', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildShareRow(String role, String pct, dynamic payout, Color bg, Color textCol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(role, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: textCol)),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: textCol, borderRadius: BorderRadius.circular(8)),
                child: Text(pct, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          Text('₹$payout/kg', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textCol)),
        ],
      ),
    );
  }
}
