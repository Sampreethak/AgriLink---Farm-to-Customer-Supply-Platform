import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  bool notifications = true;
  bool darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),

        children: [

          SwitchListTile(
            value: notifications,
            title: const Text("Notifications"),
            subtitle: const Text("Receive app notifications"),
            secondary: const Icon(Icons.notifications),
            onChanged: (value) {
              setState(() {
                notifications = value;
              });
            },
          ),

          SwitchListTile(
            value: darkMode,
            title: const Text("Dark Mode"),
            subtitle: const Text("Coming soon"),
            secondary: const Icon(Icons.dark_mode),
            onChanged: (value) {
              setState(() {
                darkMode = value;
              });
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text("Change Password"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.language),
            title: const Text("Language"),
            subtitle: const Text("English"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.support_agent),
            title: const Text("Contact Support"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.info),
            title: const Text("About AgriLink"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),

        ],
      ),
    );
  }
}