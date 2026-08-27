import 'package:flutter/material.dart';
import '../../services/customer_state.dart';
import 'home_tab.dart';
import 'cart_tab.dart';
import 'orders_tab.dart';
import 'profile_tab.dart';

class CustomerDashboard extends StatefulWidget {
  final int initialIndex;
  const CustomerDashboard({super.key, this.initialIndex = 0});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  late int selectedIndex;
  final CustomerState _customerState = CustomerState();

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
    _customerState.addListener(_onStateChange);
  }

  @override
  void dispose() {
    _customerState.removeListener(_onStateChange);
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) {
      setState(() {});
    }
  }

  void _navigateToTab(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeTab(onNavigateToCart: () => _navigateToTab(1)),
      CartTab(onOrderPlaced: () => _navigateToTab(2)),
      const OrdersTab(),
      const ProfileTab(),
    ];

    final cartBadgeCount = _customerState.cartCount;

    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        selectedItemColor: const Color(0xFF2E7D32),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_cart),
                if (cartBadgeCount > 0)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$cartBadgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: "Cart",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: "Orders",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}