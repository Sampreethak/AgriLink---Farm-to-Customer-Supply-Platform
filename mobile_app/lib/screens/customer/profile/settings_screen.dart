import 'package:flutter/material.dart';

class CustomerSettingsScreen extends StatefulWidget {
  const CustomerSettingsScreen({super.key});

  @override
  State<CustomerSettingsScreen> createState() =>
      _CustomerSettingsScreenState();
}

class _CustomerSettingsScreenState
    extends State<CustomerSettingsScreen> {

  bool notifications = true;

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Settings"),
      ),

      body: ListView(

        children: [

          SwitchListTile(
            value: notifications,
            title: const Text("Notifications"),
            onChanged: (value) {
              setState(() {
                notifications = value;
              });
            },
          ),

          const ListTile(
            leading: Icon(Icons.lock),
            title: Text("Change Password"),
          ),

          const ListTile(
            leading: Icon(Icons.language),
            title: Text("Language"),
          ),

          const ListTile(
            leading: Icon(Icons.info),
            title: Text("About App"),
          ),

        ],

      ),

    );

  }
}