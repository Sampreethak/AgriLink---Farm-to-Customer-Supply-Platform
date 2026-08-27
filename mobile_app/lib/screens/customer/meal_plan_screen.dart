import 'package:flutter/material.dart';
import '../../core/colors.dart';

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  final Map<String, List<String>> weeklyMeals = {
    "Monday": ["Potato Masala", "Rice & Dal", "Mixed Veg Salad"],
    "Tuesday": ["Sambar Rice", "Roti & Tomato Kurma", "Curd Cup"],
    "Wednesday": ["Paneer Butter Masala", "Jeera Rice", "Onion Raita"],
    "Thursday": ["Mixed Veg Khichdi", "Potato Chips", "Fruit Custard"],
    "Friday": ["Veg Biryani", "Mirchi Ka Salan", "Cucumber Salad"],
    "Saturday": ["Chole Bhature", "Lassi", "Onion Lemon Salad"],
    "Sunday": ["Paneer Pulao", "Aloo Gobi", "Sweet Kheer"],
  };

  final Map<String, List<Map<String, dynamic>>> neededIngredients = {
    "Monday": [
      {"item": "Potato", "qty": "15 Kg", "cost": 525.0},
      {"item": "Rice", "qty": "20 Kg", "cost": 1200.0},
      {"item": "Dal (Pulses)", "qty": "8 Kg", "cost": 800.0},
    ],
    "Tuesday": [
      {"item": "Tomato", "qty": "10 Kg", "cost": 400.0},
      {"item": "Rice", "qty": "20 Kg", "cost": 1200.0},
      {"item": "Wheat Flour", "qty": "12 Kg", "cost": 600.0},
    ],
    "Wednesday": [
      {"item": "Onion", "qty": "10 Kg", "cost": 300.0},
      {"item": "Rice", "qty": "15 Kg", "cost": 900.0},
    ],
    "Thursday": [
      {"item": "Vegetable Mix", "qty": "12 Kg", "cost": 720.0},
      {"item": "Potato", "qty": "10 Kg", "cost": 350.0},
    ],
    "Friday": [
      {"item": "Rice", "qty": "25 Kg", "cost": 1500.0},
      {"item": "Cucumber", "qty": "8 Kg", "cost": 240.0},
      {"item": "Tomato", "qty": "6 Kg", "cost": 240.0},
    ],
    "Saturday": [
      {"item": "Onion", "qty": "12 Kg", "cost": 360.0},
      {"item": "Chickpeas", "qty": "10 Kg", "cost": 900.0},
    ],
    "Sunday": [
      {"item": "Rice", "qty": "20 Kg", "cost": 1200.0},
      {"item": "Potato", "qty": "8 Kg", "cost": 280.0},
      {"item": "Cauliflower", "qty": "10 Kg", "cost": 500.0},
    ]
  };

  String activeDay = "Monday";

  @override
  Widget build(BuildContext context) {
    final meals = weeklyMeals[activeDay] ?? [];
    final ingredients = neededIngredients[activeDay] ?? [];

    double totalDayCost = ingredients.fold(0.0, (sum, item) => sum + (item['cost'] as double));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Weekly Meal Planner"),
        backgroundColor: AppColors.primaryGreen,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: AppColors.primaryGreen.withValues(alpha: 0.08),
            height: 70,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              children: weeklyMeals.keys.map((day) {
                bool isSelected = day == activeDay;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(
                      day,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.primaryGreen,
                    onSelected: (val) {
                      if (val) {
                        setState(() {
                          activeDay = day;
                        });
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$activeDay's Planned Menu",
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: meals.map((meal) {
                      return Chip(
                        avatar: const Icon(Icons.restaurant_menu, size: 16),
                        label: Text(meal),
                        backgroundColor: Colors.orange.shade50,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Auto-Calculated Produce Requirements",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: AppColors.primaryGreen),
                        onPressed: () {
                          // Allow adding ingredients in prototype
                          setState(() {
                            ingredients.add({"item": "Fresh Garlic", "qty": "2 Kg", "cost": 300.0});
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: ingredients.length,
                    itemBuilder: (context, index) {
                      final ing = ingredients[index];
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.shopping_basket, color: Colors.green),
                          title: Text(ing['item']),
                          subtitle: Text("Required: ${ing['qty']}"),
                          trailing: Text(
                            "₹${ing['cost'].toStringAsFixed(0)}",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Card(
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total Estimated Cost:",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            "₹${totalDayCost.toStringAsFixed(0)}",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.text),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add_shopping_cart),
                    label: Text("Order Produce for $activeDay"),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.primaryGreen,
                          content: Text("Orders created for all items required on $activeDay!"),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: const Text("Order Full Week Produce (Bulk Dispatch)"),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.orange,
                          content: Text("Weekly dispatch order initiated. Invoices generated in Hospital/PG billing panel."),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
