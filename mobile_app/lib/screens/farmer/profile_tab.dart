import 'package:flutter/material.dart';

import 'profile/edit_profile_screen.dart';
import 'profile/notifications_screen.dart';
import 'profile/settings_screen.dart';
import '../auth/login_screen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
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

            const Text(
              "Sampreetha",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              "Farmer",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
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