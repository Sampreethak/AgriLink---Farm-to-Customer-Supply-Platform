import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../services/customer_state.dart';
import 'profile/edit_profile_screen.dart';
import 'profile/notifications_screen.dart';
import 'profile/settings_screen.dart';
import '../auth/login_screen.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final CustomerState _customerState = CustomerState();

  @override
  void initState() {
    super.initState();
    _customerState.addListener(_onStateChange);
  }

  @override
  void dispose() {
    _customerState.removeListener(_onStateChange);
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final name = _customerState.name;
    final email = _customerState.email;
    final phone = _customerState.phone;
    final location = _customerState.location;
    final role = _customerState.role;
    final orderCount = _customerState.orders.length;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      appBar: AppBar(
        title: const Text("My Profile", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Card Header
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              color: const Color(0xFFF5F2EB),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: const Color(0xFF81C784).withValues(alpha: 0.3),
                          child: const Icon(Icons.person, size: 55, color: Color(0xFF2E7D32)),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: Color(0xFF2E7D32), shape: BoxShape.circle),
                            child: const Icon(Icons.verified, color: Colors.white, size: 18),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      name,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.text),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$role • $location",
                      style: const TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(email, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    Text(phone, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Live Dashboard Statistics Row
            Row(
              children: [
                Expanded(
                  child: _statCard("Total Orders", "$orderCount", Icons.receipt_long, Colors.blue),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _statCard("Reward Points", "240 pts", Icons.stars, Colors.amber.shade800),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _statCard("Saved Addr.", "2 Saved", Icons.location_on, Colors.purple),
                ),
              ],
            ),

            const SizedBox(height: 22),

            // Menu Items
            _menuTile(
              context,
              "Edit Profile Details",
              Icons.edit,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CustomerEditProfileScreen()),
                );
              },
            ),

            _menuTile(
              context,
              "Notification Preferences",
              Icons.notifications_active_outlined,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CustomerNotificationsScreen()),
                );
              },
            ),

            _menuTile(
              context,
              "App Settings & Privacy",
              Icons.settings_outlined,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CustomerSettingsScreen()),
                );
              },
            ),

            _menuTile(
              context,
              "Logout",
              Icons.logout,
              () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _menuTile(BuildContext context, String title, IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: Icon(icon, color: isDestructive ? Colors.red : const Color(0xFF2E7D32)),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: isDestructive ? Colors.red : AppColors.text,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: isDestructive ? Colors.red : Colors.grey),
        onTap: onTap,
      ),
    );
  }
}