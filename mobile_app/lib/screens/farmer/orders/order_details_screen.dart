import 'package:flutter/material.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Details"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(
                    Icons.shopping_bag,
                    color: Colors.white,
                  ),
                ),

                title: const Text(
                  "Order #1001",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                subtitle: const Text("Pending"),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Customer Details",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: ListTile(
                leading: const Icon(Icons.person),
                title: const Text("Rahul Sharma"),
                subtitle: const Text("9876543210"),
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(Icons.location_on),
                title: const Text("Delivery Address"),
                subtitle: const Text(
                  "Bangalore, Karnataka",
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Order Items",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: ListTile(
                leading: Icon(Icons.eco),
                title: Text("Tomato"),
                subtitle: Text("20 Kg"),
                trailing: Text("₹800"),
              ),
            ),

            Card(
              child: ListTile(
                leading: Icon(Icons.eco),
                title: Text("Potato"),
                subtitle: Text("10 Kg"),
                trailing: Text("₹350"),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Total Amount",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),

            const Text(
              "₹1150",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            Row(
              children: [

                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 55),
                    ),

                    onPressed: () {

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Order Accepted"),
                        ),
                      );

                    },

                    icon: const Icon(Icons.check),

                    label: const Text("Accept"),
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 55),
                    ),

                    onPressed: () {

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Order Rejected"),
                        ),
                      );

                    },

                    icon: const Icon(Icons.close),

                    label: const Text("Reject"),
                  ),
                ),

              ],
            ),

          ],
        ),
      ),
    );
  }
}
