import 'package:flutter/material.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {

  int quantity = 150;
  bool available = true;

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Inventory Management"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Card(
              elevation: 3,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),

              child: const ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(
                    Icons.eco,
                    color: Colors.white,
                  ),
                ),

                title: Text(
                  "Fresh Tomato",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                subtitle: Text("Vegetables"),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "Available Quantity",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Row(

              mainAxisAlignment: MainAxisAlignment.center,

              children: [

                IconButton(

                  iconSize: 40,

                  onPressed: () {

                    if (quantity > 0) {
                      setState(() {
                        quantity--;
                      });
                    }

                  },

                  icon: const Icon(
                    Icons.remove_circle,
                    color: Colors.red,
                  ),
                ),

                Container(

                  width: 120,

                  alignment: Alignment.center,

                  child: Text(
                    "$quantity Kg",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                ),

                IconButton(

                  iconSize: 40,

                  onPressed: () {

                    setState(() {
                      quantity++;
                    });

                  },

                  icon: const Icon(
                    Icons.add_circle,
                    color: Colors.green,
                  ),
                ),

              ],
            ),

            const SizedBox(height: 30),

            SwitchListTile(

              value: available,

              activeThumbColor: Colors.green,

              title: const Text(
                "Available for Sale",
              ),

              subtitle: Text(
                available
                    ? "Customers can order"
                    : "Out of Stock",
              ),

              onChanged: (value) {

                setState(() {

                  available = value;

                });

              },

            ),

            const Spacer(),

            SizedBox(

              width: double.infinity,

              height: 55,

              child: ElevatedButton(

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),

                onPressed: () {

                  ScaffoldMessenger.of(context).showSnackBar(

                    const SnackBar(
                      content: Text(
                        "Inventory Updated Successfully",
                      ),
                    ),

                  );

                },

                child: const Text(
                  "Save Changes",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),

              ),

            ),

          ],
        ),
      ),
    );
  }
}
