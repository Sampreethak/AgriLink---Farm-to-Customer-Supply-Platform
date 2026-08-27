import 'package:flutter/material.dart';

class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Earnings Dashboard"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(20),
              ),

              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  Text(
                    "Total Earnings",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                    ),
                  ),

                  SizedBox(height: 10),

                  Text(
                    "₹52,430",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                ],
              ),
            ),

            const SizedBox(height: 25),

            Row(
              children: [

                Expanded(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(15),

                      child: Column(
                        children: [

                          Icon(
                            Icons.today,
                            color: Colors.green,
                          ),

                          SizedBox(height: 10),

                          Text(
                            "Today",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 5),

                          Text("₹2,450"),

                        ],
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(15),

                      child: Column(
                        children: [

                          Icon(
                            Icons.calendar_view_week,
                            color: Colors.orange,
                          ),

                          SizedBox(height: 10),

                          Text(
                            "This Week",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 5),

                          Text("₹12,800"),

                        ],
                      ),
                    ),
                  ),
                ),

              ],
            ),

            const SizedBox(height: 25),

            const Text(
              "Recent Transactions",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),

              itemCount: 5,

              itemBuilder: (context, index) {

                return Card(
                  child: ListTile(

                    leading: CircleAvatar(
                      backgroundColor: Colors.green.shade100,
                      child: const Icon(
                        Icons.currency_rupee,
                        color: Colors.green,
                      ),
                    ),

                    title: Text(
                      "Order #100${index + 1}",
                    ),

                    subtitle: const Text(
                      "Payment Received",
                    ),

                    trailing: Text(
                      "+ ₹${(index + 1) * 850}",
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                  ),
                );

              },

            ),

          ],
        ),
      ),
    );
  }
}
