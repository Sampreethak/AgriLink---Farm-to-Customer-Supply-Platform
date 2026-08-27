import 'package:flutter/material.dart';

import 'edit_product_screen.dart';
import 'inventory_screen.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Product Details"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            ClipRRect(
              borderRadius: BorderRadius.circular(20),

              child: Container(
                height: 220,
                width: double.infinity,
                color: Colors.green.shade100,

                child: const Icon(
                  Icons.image,
                  size: 90,
                  color: Colors.green,
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Fresh Tomatoes",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "₹40 / Kg",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 20),

            Card(
              child: ListTile(
                leading: const Icon(Icons.inventory),
                title: const Text("Available Quantity"),
                subtitle: const Text("150 Kg"),
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(Icons.category),
                title: const Text("Category"),
                subtitle: const Text("Vegetables"),
              ),
            ),

            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
                title: const Text("Status"),
                subtitle: const Text("Available"),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Description",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Fresh organically grown tomatoes harvested directly from the farm. Rich in nutrients and ideal for daily cooking. Stored carefully to maintain freshness and quality.",
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 55),
                ),

                onPressed: () {

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EditProductScreen(),
                    ),
                  );

                },

                icon: const Icon(Icons.edit),

                label: const Text("Edit Product"),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 55),
                ),

                onPressed: () {

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const InventoryScreen(),
                    ),
                  );

                },

                icon: const Icon(Icons.inventory),

                label: const Text("Manage Inventory"),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 55),
                ),

                onPressed: () {

                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(

                      title: const Text("Delete Product"),

                      content: const Text(
                        "Are you sure you want to delete this product?",
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

                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Product Deleted Successfully",
                                ),
                              ),
                            );

                            Navigator.pop(context);

                          },
                          child: const Text("Delete"),
                        ),

                      ],
                    ),
                  );

                },

                icon: const Icon(Icons.delete),

                label: const Text("Delete Product"),
              ),
            ),

            const SizedBox(height: 25),

          ],
        ),
      ),
    );
  }
}
