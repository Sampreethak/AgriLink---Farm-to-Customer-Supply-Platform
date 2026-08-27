import 'package:flutter/material.dart';
import '../../core/colors.dart';

class BulkOrderScreen extends StatefulWidget {
  const BulkOrderScreen({super.key});

  @override
  State<BulkOrderScreen> createState() => _BulkOrderScreenState();
}

class _BulkOrderScreenState extends State<BulkOrderScreen> {
  String selectedProduce = "Tomato";
  double quantity = 100.0; // in Kgs
  double basePrice = 40.0; // ₹/Kg

  double getDiscountPercentage(double qty) {
    if (qty >= 500) return 20.0;
    if (qty >= 200) return 15.0;
    if (qty >= 100) return 10.0;
    return 5.0;
  }

  @override
  Widget build(BuildContext context) {
    double discount = getDiscountPercentage(quantity);
    double originalTotal = quantity * basePrice;
    double finalTotal = originalTotal * (1 - discount / 100);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Bulk Procurement"),
        backgroundColor: AppColors.primaryGreen,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Hostel & PG Bulk Ordering",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Order in bulk directly from aggregators or farmers and receive high-volume discounts.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Select Crop",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedProduce,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.eco),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      ),
                      items: const [
                        DropdownMenuItem(value: "Tomato", child: Text("Tomato (Base: ₹40/Kg)")),
                        DropdownMenuItem(value: "Potato", child: Text("Potato (Base: ₹35/Kg)")),
                        DropdownMenuItem(value: "Onion", child: Text("Onion (Base: ₹30/Kg)")),
                        DropdownMenuItem(value: "Rice", child: Text("Rice (Base: ₹60/Kg)")),
                        DropdownMenuItem(value: "Wheat", child: Text("Wheat (Base: ₹50/Kg)")),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            selectedProduce = val;
                            if (val == "Tomato") basePrice = 40.0;
                            if (val == "Potato") basePrice = 35.0;
                            if (val == "Onion") basePrice = 30.0;
                            if (val == "Rice") basePrice = 60.0;
                            if (val == "Wheat") basePrice = 50.0;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Quantity (in Kilograms)",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            min: 50,
                            max: 1000,
                            divisions: 19,
                            value: quantity,
                            activeColor: AppColors.primaryGreen,
                            label: "${quantity.toInt()} Kg",
                            onChanged: (val) {
                              setState(() {
                                quantity = val;
                              });
                            },
                          ),
                        ),
                        Text(
                          "${quantity.toInt()} Kg",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "Discount Tiers:",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const Text("• 50+ Kg: 5% | 100+ Kg: 10% | 200+ Kg: 15% | 500+ Kg: 20%"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              color: Colors.green.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Base Price:"),
                        Text("₹${basePrice.toStringAsFixed(2)} / Kg"),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Subtotal:"),
                        Text("₹${originalTotal.toStringAsFixed(2)}"),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Bulk Discount ($discount%):", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                        Text("-₹${(originalTotal - finalTotal).toStringAsFixed(2)}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(height: 20, thickness: 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Final Price:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text("₹${finalTotal.toStringAsFixed(2)}", style: const TextStyle(fontSize: 22, color: AppColors.text, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.shopping_cart_checkout),
              label: const Text("Place Bulk Order"),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.primaryGreen,
                    content: Text("Bulk Order for ${quantity.toInt()} Kg $selectedProduce placed successfully!"),
                  ),
                );
                Navigator.pop(context);
              },
            )
          ],
        ),
      ),
    );
  }
}
