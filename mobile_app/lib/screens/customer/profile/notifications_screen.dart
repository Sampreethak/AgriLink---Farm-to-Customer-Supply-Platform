import 'package:flutter/material.dart';

class CustomerNotificationsScreen extends StatelessWidget {
  const CustomerNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Notifications"),
      ),

      body: ListView(

        padding: const EdgeInsets.all(16),

        children: [

          _notification(
            "Order Confirmed",
            "Your order #1001 has been confirmed",
            Icons.check_circle,
          ),

          _notification(
            "Order Shipped",
            "Your order is on the way",
            Icons.local_shipping,
          ),

          _notification(
            "Payment Successful",
            "₹850 paid successfully",
            Icons.currency_rupee,
          ),

          _notification(
            "Fresh Products Available",
            "New vegetables added today",
            Icons.eco,
          ),

        ],

      ),

    );

  }

  Widget _notification(
    String title,
    String subtitle,
    IconData icon,
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