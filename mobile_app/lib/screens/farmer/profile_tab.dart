import 'package:flutter/material.dart';

import '../../services/platform_state.dart';
import 'profile/edit_profile_screen.dart';
import 'profile/notifications_screen.dart';
import 'profile/settings_screen.dart';
import '../auth/login_screen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = PlatformState().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Farmer Profile"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            const SizedBox(height: 20),

            CircleAvatar(
              radius: 55,
              backgroundColor: Colors.green.shade100,

              child: const Icon(
                Icons.person,
                size: 60,
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 15),

            Text(
              user.fullName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              "${user.customerType} • ${user.region}",
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 3),

            Text(
              user.email,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 30),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),

              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(
                    Icons.edit,
                    color: Colors.white,
                  ),
                ),

                title: const Text("Edit Profile"),

                subtitle: const Text("Update your details"),

                trailing: const Icon(Icons.arrow_forward_ios),

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EditProfileScreen(),
                    ),
                  );
                },
              ),
            ),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),

              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.orange,
                  child: Icon(
                    Icons.notifications,
                    color: Colors.white,
                  ),
                ),

                title: const Text("Notifications"),

                subtitle: const Text("View recent updates"),

                trailing: const Icon(Icons.arrow_forward_ios),

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationsScreen(),
                    ),
                  );
                },
              ),
            ),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),

              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Icon(
                    Icons.settings,
                    color: Colors.white,
                  ),
                ),

                title: const Text("Settings"),

                subtitle: const Text("App preferences"),

                trailing: const Icon(Icons.arrow_forward_ios),

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SettingsScreen(),
                    ),
                  );
                },
              ),
            ),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),

              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.red,
                  child: Icon(
                    Icons.logout,
                    color: Colors.white,
                  ),
                ),

                title: const Text("Logout"),

                subtitle: const Text("Sign out from AgriLink"),

                trailing: const Icon(Icons.arrow_forward_ios),

                onTap: () {

                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(

                      title: const Text("Logout"),

                      content: const Text(
                        "Are you sure you want to logout?",
                      ),

                      actions: [

                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("Cancel"),
                        ),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {

                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                              (route) => false,
                            );

                          },
                          child: const Text("Logout"),
                        ),

                      ],
                    ),
                  );

                },
              ),
            ),

            const SizedBox(height: 30),

          ],
        ),
      ),
    );
  }
}