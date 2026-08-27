import 'package:flutter/material.dart';
import '../../../core/colors.dart';

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  int currentStep = 2; // 0: Confirmed, 1: Packed, 2: Out for Delivery, 3: Delivered

  final List<Map<String, dynamic>> trackingSteps = [
    {
      "title": "Order Confirmed",
      "desc": "Aggregator accepted your institutional order",
      "icon": Icons.assignment_turned_in,
    },
    {
      "title": "Quality Verified & Packed",
      "desc": "Graded Grade A. Cold chain temperature verified at 3.5°C",
      "icon": Icons.verified,
    },
    {
      "title": "Out For Delivery",
      "desc": "Delivery Partner 'Karthik S.' is in transit with your batch",
      "icon": Icons.local_shipping,
    },
    {
      "title": "Delivered",
      "desc": "Secured check-in via mess warden signature & OTP clearance",
      "icon": Icons.home,
    },
  ];

  void _nextStep() {
    if (currentStep < 3) {
      setState(() {
        currentStep++;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Delivery Status updated: ${trackingSteps[currentStep]['title']}"),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    }
  }

  void _resetStep() {
    setState(() {
      currentStep = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Order Tracking"),
        backgroundColor: AppColors.primaryGreen,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Order #1001",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Hospital Dietetics batch • Today",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: currentStep == 3 ? Colors.green.shade100 : Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    currentStep == 3 ? "DELIVERED" : "IN TRANSIT",
                    style: TextStyle(
                      color: currentStep == 3 ? Colors.green.shade700 : Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                )
              ],
            ),
            const Divider(height: 40),

            // Swiggy-style timeline
            ...List.generate(trackingSteps.length, (index) {
              final step = trackingSteps[index];
              final isCompleted = index <= currentStep;
              final isCurrent = index == currentStep;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted
                              ? (isCurrent ? AppColors.orange : AppColors.primaryGreen)
                              : Colors.grey.shade300,
                        ),
                        child: Icon(
                          step['icon'] as IconData,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      if (index != trackingSteps.length - 1)
                        Container(
                          width: 3,
                          height: 50,
                          color: index < currentStep ? AppColors.primaryGreen : Colors.grey.shade300,
                        ),
                    ],
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step['title'] as String,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isCompleted ? Colors.black : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            step['desc'] as String,
                            style: TextStyle(
                              color: isCompleted ? Colors.black54 : Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 15),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),

            const Divider(height: 30),

            // Delivery partner card info
            if (currentStep >= 2) ...[
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.orange.shade100,
                        child: const Icon(Icons.delivery_dining, color: Colors.orange, size: 30),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Karthik S. (Delivery Partner)",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(height: 4),
                            Text("Vehicle: Electric Cargo Loader (KA-03-EM-4421)"),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.phone, color: Colors.green),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Calling Karthik S. (Delivery Partner)...")),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
            ],

            // Simulator Buttons
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    const Text(
                      "Frontend Simulation Panel",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            minimumSize: const Size(120, 40),
                          ),
                          onPressed: currentStep < 3 ? _nextStep : null,
                          child: const Text("Next Status", style: TextStyle(fontSize: 12)),
                        ),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(120, 40),
                          ),
                          onPressed: _resetStep,
                          child: const Text("Reset Status", style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}