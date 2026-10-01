import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../chatbot/agritalk_chat_screen.dart';
import 'home_tab.dart';
import 'orders_tab.dart';
import 'products_tab.dart';
import 'profile_tab.dart';

class FarmerDashboard extends StatefulWidget {
  const FarmerDashboard({super.key});

  @override
  State<FarmerDashboard> createState() => _FarmerDashboardState();
}

class _FarmerDashboardState extends State<FarmerDashboard> {

  int currentIndex = 0;

  final List<Widget> pages = const [

    HomeTab(),

    ProductsTab(),

    OrdersTab(),

    ProfileTab(),

  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      floatingActionButton: FloatingActionButton.extended(
        heroTag: "farmer_agritalk_fab",
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AgriTalkChatScreen()),
          );
        },
        backgroundColor: AppColors.primaryGreen,
        icon: const Icon(Icons.smart_toy, color: Colors.white),
        label: const Text("AgriTalk AI", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),

      body: IndexedStack(

        index: currentIndex,

        children: pages,

      ),

      bottomNavigationBar: NavigationBar(

        selectedIndex: currentIndex,

        height: 70,

        indicatorColor: Colors.green.shade100,

        destinations: const [

          NavigationDestination(

            icon: Icon(Icons.home_outlined),

            selectedIcon: Icon(Icons.home),

            label: "Home",

          ),

          NavigationDestination(

            icon: Icon(Icons.inventory_2_outlined),

            selectedIcon: Icon(Icons.inventory),

            label: "Products",

          ),

          NavigationDestination(

            icon: Icon(Icons.shopping_bag_outlined),

            selectedIcon: Icon(Icons.shopping_bag),

            label: "Orders",

          ),

          NavigationDestination(

            icon: Icon(Icons.person_outline),

            selectedIcon: Icon(Icons.person),

            label: "Profile",

          ),

        ],

        onDestinationSelected: (index) {

          setState(() {

            currentIndex = index;

          });

        },

      ),

    );

  }

}

