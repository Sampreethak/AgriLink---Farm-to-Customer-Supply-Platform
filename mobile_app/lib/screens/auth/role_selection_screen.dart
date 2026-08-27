import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../farmer/farmer_registration.dart';
import '../customer/customer_registration_screen.dart';
import '../aggregator/aggregator_registration_screen.dart';
import '../delivery/delivery_registration_screen.dart';
import '../admin/admin_login.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  Widget roleCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.only(bottom: 18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.lightGreen,
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 30,
                ),
              ),

              const SizedBox(width: 18),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text("Select Role"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const SizedBox(height: 10),

            const Text(
              "Choose Your Role",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Select how you want to use AgriLink",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 30),

            Expanded(
              child: ListView(
                children: [
                  roleCard(
                    context: context,
                    icon: Icons.agriculture,
                    title: "Farmer",
                    subtitle: "Sell your produce",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const FarmerRegistration(),
                        ),
                      );
                    },
                  ),

                  roleCard(
                    context: context,
                    icon: Icons.shopping_cart,
                    title: "Customer",
                    subtitle: "Buy fresh farm products",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CustomerRegistrationScreen(),
                      
                        ),
                      );
                    },
                  ),

                  roleCard(
                    context: context,
                    icon: Icons.warehouse,
                    title: "Aggregator",
                    subtitle: "Manage collections",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const AggregatorRegistrationScreen(),
                        ),
                      );
                    },
                  ),

                  roleCard(
                    context: context,
                    icon: Icons.delivery_dining,
                    title: "Delivery Partner",
                    subtitle: "Deliver customer orders",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const DeliveryRegistrationScreen(),
                        ),
                      );
                    },
                  ),

                  roleCard(
                    context: context,
                    icon: Icons.admin_panel_settings,
                    title: "Admin",
                    subtitle: "Manage platform",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminLoginScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
