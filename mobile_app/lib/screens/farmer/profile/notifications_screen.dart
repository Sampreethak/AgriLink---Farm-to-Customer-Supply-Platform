import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Notifications"),
        centerTitle: true,
      ),

      body: ListView(

        padding: const EdgeInsets.all(16),

        children: [

          notificationTile(
            Icons.shopping_bag,
            "New Order Received",
            "Order #1005 received",
          ),

          notificationTile(
            Icons.currency_rupee,
            "Payment Received",
            "₹850 credited",
          ),

          notificationTile(
            Icons.eco,
            "Product Added",
            "Tomato added successfully",
          ),

          notificationTile(
            Icons.inventory,
            "Inventory Updated",
            "Stock updated",
          ),

          notificationTile(
            Icons.local_shipping,
            "Order Delivered",
            "Order delivered successfully",
          ),

        ],
      ),
    );
  }

  Widget notificationTile(
      IconData icon,
      String title,
      String subtitle,
      ) {

    return Card(
      margin: const EdgeInsets.only(bottom: 12),

      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade100,
          child: Icon(
            icon,
            color: Colors.green,
          ),
        ),

        title: Text(title),

        subtitle: Text(subtitle),
      ),
    );
  }
}