import 'package:flutter/material.dart';
import '../../../core/colors.dart';
import '../../chatbot/agritalk_chat_screen.dart';

class FarmerQueryInsightsSection extends StatefulWidget {
  const FarmerQueryInsightsSection({super.key});

  @override
  State<FarmerQueryInsightsSection> createState() => _FarmerQueryInsightsSectionState();
}

class _FarmerQueryInsightsSectionState extends State<FarmerQueryInsightsSection> {
  String _selectedDomain = 'All';
  String _selectedCrop = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _domainClusters = [
    {
      'id': 'All',
      'label': 'All Queries',
      'percentage': '100%',
      'count': '5,000',
      'icon': Icons.all_inclusive,
      'color': AppColors.primaryGreen,
    },
    {
      'id': 'PEST_DISEASE',
      'label': 'Pest & Disease',
      'percentage': '45.0%',
      'count': '2,250',
      'icon': Icons.bug_report,
      'color': const Color(0xFF2E7D32),
    },
    {
      'id': 'AGRONOMY',
      'label': 'Cultivation',
      'percentage': '22.3%',
      'count': '1,116',
      'icon': Icons.grass,
      'color': const Color(0xFFE65100),
    },
    {
      'id': 'FERTILIZER',
      'label': 'Fertilizer & NPK',
      'percentage': '13.4%',
      'count': '668',
      'icon': Icons.science,
      'color': const Color(0xFF1565C0),
    },
    {
      'id': 'VETERINARY',
      'label': 'Livestock & Vet',
      'percentage': '11.2%',
      'count': '558',
      'icon': Icons.pets,
      'color': const Color(0xFFC2410C),
    },
    {
      'id': 'SCHEMES',
      'label': 'PM-Kisan & KCC',
      'percentage': '8.2%',
      'count': '408',
      'icon': Icons.account_balance,
      'color': const Color(0xFF6A1B9A),
    },
  ];

  final List<String> _cropFilterList = [
    'All',
    'Rice',
    'Tomato',
    'Potato',
    'Chilli',
    'Brinjal',
    'Cucurbits',
    'Coconut',
  ];

  final List<Map<String, dynamic>> _advisoryItems = [
    {
      'crop': 'Rice',
      'problem': 'Stem Borer & Leaf Folder',
      'category': 'PEST_DISEASE',
      'frequency': 89,
      'severity': 'High',
      'symptoms': 'Dead hearts at vegetative stage, white ears at heading, folded leaf margins.',
      'chemicalRemedy': 'Tricel / Chlorpyrifos 20 EC @ 2ml/L water, or Cartap Hydrochloride 4G @ 10kg/acre.',
      'bioControl': 'Install Trichogramma japonicum egg parasitoid egg cards @ 5 cards/acre.',
      'suggestedQuery': 'How to control stem borer and leaf folder in rice?',
    },
    {
      'crop': 'Potato',
      'problem': 'Late Blight Outbreak',
      'category': 'PEST_DISEASE',
      'frequency': 65,
      'severity': 'Critical',
      'symptoms': 'Irregular water-soaked brown lesions on leaves and stems, white fungal growth under humid canopy.',
      'chemicalRemedy': 'Indofil M-45 (Mancozeb 75 WP) @ 2.5g/L preventive; Ridomil Gold (Metalaxyl + Mancozeb) @ 2g/L curative.',
      'bioControl': 'Spray Trichoderma viride @ 5g/L; avoid overhead sprinkler irrigation during cloudy weather.',
      'suggestedQuery': 'Treatment for potato late blight fungal infection',
    },
    {
      'crop': 'Cucurbits',
      'problem': 'Fruit Fly Maggot Infestation',
      'category': 'PEST_DISEASE',
      'frequency': 56,
      'severity': 'High',
      'symptoms': 'Sunken oviposition punctures on young gourds/melons, larval rotting and premature fruit dropping.',
      'chemicalRemedy': 'Bait spray: Malathion 50 EC (2ml/L) + 10g Jaggery / Molasses in 1L water on foliage.',
      'bioControl': 'Install Cue-lure pheromone traps (6-8 traps per acre) 15 days before flowering.',
      'suggestedQuery': 'Control of fruit fly maggots in cucumber and bottle gourd',
    },
    {
      'crop': 'Brinjal',
      'problem': 'Shoot & Fruit Borer (Leucinodes)',
      'category': 'PEST_DISEASE',
      'frequency': 52,
      'severity': 'High',
      'symptoms': 'Wilted and drooping terminal shoot tips, circular exit holes in mature brinjal fruits with frass.',
      'chemicalRemedy': 'Spinosad 45 SC @ 0.4ml/L or Emamectin Benzoate 5 SG @ 0.5g/L water.',
      'bioControl': 'Clip and burn wilted shoots weekly; spray Neem oil 1500 ppm @ 5ml/L.',
      'suggestedQuery': 'How to treat shoot and fruit borer in brinjal?',
    },
    {
      'crop': 'Chilli',
      'problem': 'Viral Leaf Curl & Thrips/Whitefly',
      'category': 'PEST_DISEASE',
      'frequency': 50,
      'severity': 'High',
      'symptoms': 'Leaves curling upwards (thrips) or downwards (mites), thickened brittle veins, stunted bush.',
      'chemicalRemedy': 'Rogor (Dimethoate 30 EC) @ 2ml/L or Imidacloprid 17.8 SL @ 0.5ml/L for vector insect suppression.',
      'bioControl': 'Set up yellow and blue sticky traps (10-12 per acre); spray systemic neem formulation.',
      'suggestedQuery': 'Best spray for leaf curl and thrips in green chilli',
    },
    {
      'crop': 'Tomato',
      'problem': 'Bacterial & Fungal Wilt (Ralstonia/Fusarium)',
      'category': 'PEST_DISEASE',
      'frequency': 39,
      'severity': 'Critical',
      'symptoms': 'Rapid daytime wilting of foliage without yellowing; vascular browning visible inside cut stem.',
      'chemicalRemedy': 'Root drench with Streptocycline (1g/10L) + Copper Oxychloride / Blitox (30g/10L water).',
      'bioControl': 'Incorporate bio-agent Pseudomonas fluorescens @ 2.5kg/acre enriched in FYM at planting.',
      'suggestedQuery': 'Tomato bacterial wilt root drenching and cure',
    },
    {
      'crop': 'Tomato',
      'problem': 'Early & Late Blight Spots',
      'category': 'PEST_DISEASE',
      'frequency': 34,
      'severity': 'High',
      'symptoms': 'Concentric target-board rings on bottom leaves, yellow chlorotic margins turning into brown necrosis.',
      'chemicalRemedy': 'Indofil M-45 (Mancozeb) @ 2.5g/L or Saaf (Carbendazim + Mancozeb) @ 2g/L at first symptom.',
      'bioControl': 'Maintain good crop canopy air circulation; mulch beds to prevent rain-splash spores.',
      'suggestedQuery': 'How to cure tomato blight spots and leaf yellowing',
    },
    {
      'crop': 'Coconut',
      'problem': 'Button Shedding & Nut Drop',
      'category': 'FERTILIZER',
      'frequency': 31,
      'severity': 'Moderate',
      'symptoms': 'Immature female flowers (buttons) and marble-sized young coconuts drying and dropping profusely.',
      'chemicalRemedy': 'Soil application of Borax (50g/palm/year) + balanced annual NPK ring dose (500g N, 320g P, 1200g K).',
      'bioControl': 'Maintain summer basin irrigation (45L/palm/day) and apply green leaf mulch.',
      'suggestedQuery': 'Coconut premature nut drop and borax fertilizer dose',
    },
    {
      'crop': 'Rice',
      'problem': 'Blast & Brown Spot (Pyricularia)',
      'category': 'PEST_DISEASE',
      'frequency': 30,
      'severity': 'High',
      'symptoms': 'Spindle-shaped lesions with ash-grey center and brownish-red borders on leaf blades and neck nodes.',
      'chemicalRemedy': 'Tricyclazole 75 WP (Baan) @ 0.6g/L or Bavistin (Carbendazim 50 WP) @ 1g/L at panicle emergence.',
      'bioControl': 'Avoid excessive nitrogen split applications; seed treatment with Trichoderma @ 10g/kg seed.',
      'suggestedQuery': 'Rice leaf blast and neck blast fungicide treatment',
    },
    {
      'crop': 'All',
      'problem': 'NPK Fertilizer Dosing per Bigha/Acre',
      'category': 'FERTILIZER',
      'frequency': 293,
      'severity': 'Moderate',
      'symptoms': 'Uneven vegetative vigor, nitrogen deficiency chlorosis or excessive lush prone to lodging.',
      'chemicalRemedy': 'Paddy: Urea 44kg, SSP 125kg, MOP 33kg per bigha. Split Urea 50% basal, 25% tillering, 25% panicle.',
      'bioControl': 'Apply Azospirillum and PSB biofertilizer @ 2kg/acre mixed with 200kg vermicompost.',
      'suggestedQuery': 'What is the recommended NPK fertilizer dose per bigha for crops?',
    },
    {
      'crop': 'All',
      'problem': 'Cattle Diarrhoea & Bovine Health',
      'category': 'VETERINARY',
      'frequency': 250,
      'severity': 'High',
      'symptoms': 'Profuse watery dung, calf scour, dehydration, loss of appetite, hollow flanks.',
      'chemicalRemedy': 'Oral electrolyte hydration solution + Bolus Neblon / Sulpha bolus (2 boluses twice daily for 3 days).',
      'bioControl': 'Feed boiled rice gruel (congee) with fenugreek; withhold lush wet forage during acute phase.',
      'suggestedQuery': 'Treatment for cow diarrhoea and dehydration remedies',
    },
    {
      'crop': 'All',
      'problem': 'PM-Kisan & KCC Direct Assistance',
      'category': 'SCHEMES',
      'frequency': 234,
      'severity': 'Moderate',
      'symptoms': 'Beneficiary status pending, e-KYC mismatch, land seeding status no, or bank DBT rejected.',
      'chemicalRemedy': 'Verify Aadhaar-Bank NPCI mapping on pmkisan.gov.in portal. Visit local Raitha Samparka Kendra.',
      'bioControl': 'Call national Kisan Call Center helpline 1800-180-1551 (toll-free, 6 AM to 10 PM in Kannada/Hindi/English).',
      'suggestedQuery': 'How to check PM-Kisan installment status and KCC loan interest rate',
    },
  ];

  List<Map<String, dynamic>> get _filteredAdvisoryList {
    return _advisoryItems.where((item) {
      // Domain filter
      if (_selectedDomain != 'All' && item['category'] != _selectedDomain) {
        return false;
      }
      // Crop filter
      if (_selectedCrop != 'All' && item['crop'] != _selectedCrop && item['crop'] != 'All') {
        return false;
      }
      // Search query filter
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final inProblem = item['problem'].toString().toLowerCase().contains(q);
        final inCrop = item['crop'].toString().toLowerCase().contains(q);
        final inSymptoms = item['symptoms'].toString().toLowerCase().contains(q);
        final inRemedy = item['chemicalRemedy'].toString().toLowerCase().contains(q);
        return inProblem || inCrop || inSymptoms || inRemedy;
      }
      return true;
    }).toList();
  }

  void _openChatWithQuery(String query) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AgriTalkChatScreen(initialQuery: query),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 25, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title & Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.psychology, color: AppColors.primaryGreen, size: 20),
                        ),
                        const SizedBox(width: 8),
                        const Flexible(
                          child: Text(
                            "Farmer Query & Advisory Insights",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Data-driven patterns from 5,000+ agro-corridor queries",
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.mintLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.lightGreenMedium.withValues(alpha: 0.4)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.bolt, color: AppColors.primaryGreen, size: 14),
                    SizedBox(width: 4),
                    Text(
                      "NLP Active",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // -------------------------------------------------------------
          // KPI STATS CARDS (Clustering Insights)
          // -------------------------------------------------------------
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: "Plant Protection",
                  value: "~45.0%",
                  subtitle: "2,250 pest/disease calls",
                  icon: Icons.shield,
                  color: const Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricCard(
                  title: "Dosing & Cultivation",
                  value: "35.7%",
                  subtitle: "Fertilizer + field crops",
                  icon: Icons.science,
                  color: const Color(0xFF1565C0),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricCard(
                  title: "Model Stability",
                  value: "0.998",
                  subtitle: "K-Means ARI Score",
                  icon: Icons.verified,
                  color: const Color(0xFFE65100),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // -------------------------------------------------------------
          // INTERACTIVE SEARCH BAR
          // -------------------------------------------------------------
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.creamBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() => _searchQuery = val.trim());
              },
              decoration: InputDecoration(
                hintText: "Search crop, pest, disease or remedy (e.g. blight, borax, urea)...",
                hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                prefixIcon: const Icon(Icons.search, color: AppColors.primaryGreen, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // -------------------------------------------------------------
          // 5-DOMAIN INTERACTIVE CHIP SELECTOR
          // -------------------------------------------------------------
          SizedBox(
            height: 38,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _domainClusters.length,
              itemBuilder: (context, idx) {
                final d = _domainClusters[idx];
                final isSelected = _selectedDomain == d['id'];
                final chipColor = d['color'] as Color;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    showCheckmark: false,
                    avatar: Icon(
                      d['icon'] as IconData,
                      size: 15,
                      color: isSelected ? Colors.white : chipColor,
                    ),
                    label: Text(
                      "${d['label']} (${d['percentage']})",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : AppColors.text,
                      ),
                    ),
                    backgroundColor: Colors.white,
                    selectedColor: chipColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? chipColor : AppColors.creamBorder,
                      ),
                    ),
                    onSelected: (_) {
                      setState(() {
                        _selectedDomain = d['id'];
                      });
                    },
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          // -------------------------------------------------------------
          // SECONDARY CROP FILTER PILLS
          // -------------------------------------------------------------
          Row(
            children: [
              const Text(
                "Filter Crop: ",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: SizedBox(
                  height: 30,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _cropFilterList.length,
                    itemBuilder: (context, idx) {
                      final crop = _cropFilterList[idx];
                      final isSelected = _selectedCrop == crop;

                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedCrop = crop);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryGreen : Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: isSelected ? AppColors.primaryGreen : AppColors.creamBorder,
                            ),
                          ),
                          child: Text(
                            crop,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // -------------------------------------------------------------
          // ADVISORY CARDS LIST
          // -------------------------------------------------------------
          if (_filteredAdvisoryList.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.creamBorder),
              ),
              child: Column(
                children: [
                  const Icon(Icons.search_off, size: 40, color: Colors.grey),
                  const SizedBox(height: 8),
                  Text(
                    "No matches found for '$_searchQuery'",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.text),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Try searching for Rice, Blight, Leaf Curl, Urea, or Borax.",
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filteredAdvisoryList.length,
              itemBuilder: (context, idx) {
                final item = _filteredAdvisoryList[idx];
                return _buildAdvisoryCard(item);
              },
            ),

          const SizedBox(height: 16),

          // -------------------------------------------------------------
          // QUICK DOSAGE & KISAN CALL CENTER ASSISTANCE BANNER
          // -------------------------------------------------------------
          _buildQuickActionAssistanceBanner(),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.creamBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
              Icon(icon, size: 14, color: color),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 9.5, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvisoryCard(Map<String, dynamic> item) {
    final severity = item['severity'] as String;
    Color severityColor = Colors.orange;
    if (severity == 'Critical') severityColor = Colors.red.shade700;
    if (severity == 'Moderate') severityColor = Colors.blue.shade700;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.creamBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Crop Tag, Problem Title, Frequency Tag
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item['crop'],
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item['problem'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: severityColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "${item['frequency']} calls",
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: severityColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Symptoms
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, size: 14, color: Colors.grey),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    item['symptoms'],
                    style: TextStyle(fontSize: 11.5, color: Colors.grey.shade700, height: 1.3),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Chemical Remedy
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F8E9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFC8E6C9)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.medication, size: 16, color: Color(0xFF2E7D32)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 11.5, color: Color(0xFF1B5E20), height: 1.35),
                        children: [
                          const TextSpan(
                            text: "Recommended Remedy: ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: item['chemicalRemedy']),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // Bio Control / Cultural advice
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFFECB3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.eco, size: 15, color: Color(0xFFF57F17)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 11, color: Color(0xFFE65100), height: 1.3),
                        children: [
                          const TextSpan(
                            text: "Bio/Organic Tip: ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: item['bioControl']),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Action: Ask AgriTalk AI Button
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () => _openChatWithQuery(item['suggestedQuery']),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 13, color: Colors.white),
                      SizedBox(width: 5),
                      Text(
                        "Ask AgriTalk AI",
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios, size: 10, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionAssistanceBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.phone_in_talk, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Kisan Call Center (KCC) Free Helpline",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Text(
                      "Toll-free advisory in Kannada, Hindi, and English (6 AM - 10 PM)",
                      style: TextStyle(color: Color(0xFFBBDEFB), fontSize: 10.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "📞 Dial: 1800-180-1551",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              InkWell(
                onTap: () => _openChatWithQuery("What government subsidies and KCC loans are available for my farm?"),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    "Check Schemes",
                    style: TextStyle(
                      color: Color(0xFF0D47A1),
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
