import 'package:flutter/material.dart';
import '../../../core/colors.dart';
import '../../../services/customer_state.dart';

class CustomerProductDetailsScreen extends StatefulWidget {
  final String? productName;
  final String? price;
  final String? imageUrl;
  final String? category;
  final String? farmerName;
  final String? rating;
  final String? description;
  final bool isOrganic;

  const CustomerProductDetailsScreen({
    super.key,
    this.productName,
    this.price,
    this.imageUrl,
    this.category,
    this.farmerName,
    this.rating,
    this.description,
    this.isOrganic = true,
  });

  @override
  State<CustomerProductDetailsScreen> createState() =>
      _CustomerProductDetailsScreenState();
}

class _CustomerProductDetailsScreenState
    extends State<CustomerProductDetailsScreen> {
  int quantity = 1;
  int userRating = 5;
  final TextEditingController _reviewController = TextEditingController();

  final List<Map<String, String>> reviewsList = [
    {
      "user": "Anita Desai",
      "rating": "5",
      "comment": "Absolutely fresh produce! Clean packaging and direct farm delivery.",
      "date": "2026-07-28"
    },
    {
      "user": "Rajesh Hegde",
      "rating": "5",
      "comment": "Top quality grade produce, very crisp and sweet.",
      "date": "2026-07-25"
    },
    {
      "user": "Hotel Kitchen Chef",
      "rating": "5",
      "comment": "Ordered bulk 100 kg. Direct farmer pricing saved 25% cost.",
      "date": "2026-07-20"
    }
  ];

  void _showAddReviewDialog() {
    showDialog(
      context: context,
      builder: (context) {
        int tempRating = 5;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.creamBackground,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text("Rate & Review Produce"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("How would you rate this farm produce?"),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < tempRating ? Icons.star : Icons.star_border,
                          color: AppColors.warmGold,
                          size: 32,
                        ),
                        onPressed: () {
                          setState(() {
                            tempRating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _reviewController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: "Write your review here...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.lightGreenPrimary),
                  onPressed: () {
                    this.setState(() {
                      reviewsList.insert(0, {
                        "user": "Priya Verma (You)",
                        "rating": "$tempRating",
                        "comment": _reviewController.text.isNotEmpty
                            ? _reviewController.text
                            : "Excellent organic harvest!",
                        "date": "Today"
                      });
                    });
                    _reviewController.clear();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Thank you for your rating & review!")),
                    );
                  },
                  child: const Text("Submit"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final titleText = widget.productName ?? "Fresh Red Tomatoes (Nashik Special)";
    final priceText = widget.price ?? "₹28/kg";
    final imgUrl = widget.imageUrl ?? "https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=500&auto=format&fit=crop&q=80";
    final farmer = widget.farmerName ?? "Ramesh Kumar (Nashik Farm)";
    final ratingVal = widget.rating ?? "4.8";
    final descText = widget.description ??
        "Farm fresh grade A red juicy produce harvested directly from verified fields. Grown with zero chemical pesticides and stored in climate-controlled transport sheds.";

    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        title: Text(titleText, style: const TextStyle(fontSize: 16)),
        backgroundColor: AppColors.lightGreenPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Crop Header Image Banner
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.network(
                  imgUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.mintLight,
                    child: const Icon(Icons.eco, size: 80, color: AppColors.lightGreenPrimary),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title & Badges
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titleText,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.mintLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.isOrganic ? "🌱 Organic Certified • Grade A+" : "🚜 Farm Direct",
                          style: const TextStyle(
                            color: AppColors.lightGreenPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      Text(
                        " $ratingVal",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber.shade900),
                      ),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 12),

            // Price & Stock
            Row(
              children: [
                Text(
                  priceText,
                  style: const TextStyle(
                    color: AppColors.lightGreenPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 15),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text("In Stock (1500 kg available)", style: TextStyle(color: Colors.green, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Farmer Profile Info
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.creamSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.creamBorder),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: AppColors.lightGreenAccent,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Farmer / Source", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                        Text(farmer, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                  ),
                  const Icon(Icons.verified, color: AppColors.lightGreenPrimary, size: 20),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Description
            const Text(
              "Description",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              descText,
              style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 25),

            // Reviews Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Customer Reviews", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: _showAddReviewDialog,
                  icon: const Icon(Icons.rate_review, size: 16),
                  label: const Text("Write Review"),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Column(
              children: reviewsList.map((rev) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.creamSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.creamBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(rev['user']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Row(
                            children: List.generate(
                              int.parse(rev['rating']!),
                              (i) => const Icon(Icons.star, color: Colors.amber, size: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(rev['comment']!, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      Text(rev['date']!, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.creamSurface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.creamBorder),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, size: 18),
                    onPressed: () {
                      if (quantity > 1) setState(() => quantity--);
                    },
                  ),
                  Text("$quantity kg", style: const TextStyle(fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.add, size: 18),
                    onPressed: () => setState(() => quantity++),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightGreenPrimary,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  final priceMatch = RegExp(r'[\d\.]+').firstMatch(priceText);
                  final priceNum = priceMatch != null ? (double.tryParse(priceMatch.group(0)!) ?? 30.0) : 30.0;

                  CustomerState().updateQuantity(
                    titleText,
                    priceNum,
                    priceText,
                    imgUrl,
                    farmer,
                    quantity,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Added $quantity kg of $titleText to your Cart!"),
                      backgroundColor: AppColors.lightGreenPrimary,
                    ),
                  );
                },
                icon: const Icon(Icons.shopping_cart_checkout),
                label: const Text("Add to Cart", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}