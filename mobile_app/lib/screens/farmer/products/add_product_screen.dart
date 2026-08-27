import 'package:flutter/material.dart';

import '../../../widgets/common/primary_button.dart';
import '../../../widgets/form/custom_dropdown.dart';
import '../../../widgets/form/custom_text_field.dart';
import '../../../widgets/form/custom_upload_title.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() =>
      _AddProductScreenState();
}

class _AddProductScreenState
    extends State<AddProductScreen> {

  bool available = true;

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Add Product"),
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            const CustomUploadTile(
              title: "Upload Product Image",
              icon: Icons.image,
            ),

            const SizedBox(height: 15),

            const CustomTextField(
              label: "Product Name",
              icon: Icons.eco,
            ),

            const CustomDropdown(
              label: "Category",
              icon: Icons.category,
              items: [
                "Vegetables",
                "Fruits",
                "Grains",
                "Pulses",
                "Spices",
                "Leafy Vegetables",
              ],
            ),

            const CustomTextField(
              label: "Price per Kg",
              icon: Icons.currency_rupee,
              keyboardType: TextInputType.number,
            ),

            const CustomTextField(
              label: "Available Quantity",
              icon: Icons.inventory,
              keyboardType: TextInputType.number,
            ),

            const CustomDropdown(
              label: "Unit",
              icon: Icons.scale,
              items: [
                "Kg",
                "Quintal",
                "Ton",
                "Piece",
                "Dozen",
              ],
            ),

            const CustomTextField(
              label: "Description",
              icon: Icons.description,
              maxLines: 4,
            ),

            SwitchListTile(
              value: available,
              activeThumbColor: Colors.green,
              title: const Text("Available for Sale"),
              onChanged: (value) {
                setState(() {
                  available = value;
                });
              },
            ),

            const SizedBox(height: 20),

            PrimaryButton(
              text: "Save Product",
              onPressed: () {

                ScaffoldMessenger.of(context).showSnackBar(

                  const SnackBar(
                    content: Text(
                      "Product added successfully",
                    ),
                  ),

                );

                Navigator.pop(context);

              },
            ),

          ],
        ),
      ),
    );
  }
}

