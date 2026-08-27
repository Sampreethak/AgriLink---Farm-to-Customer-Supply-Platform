import 'package:flutter/material.dart';

import '../../../widgets/common/primary_button.dart';
import '../../../widgets/form/custom_dropdown.dart';
import '../../../widgets/form/custom_text_field.dart';
import '../../../widgets/form/custom_upload_title.dart';

class EditProductScreen extends StatefulWidget {
  const EditProductScreen({super.key});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {

  bool available = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Product"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            const CustomUploadTile(
              title: "Update Product Image",
              icon: Icons.image,
            ),

            const SizedBox(height: 15),

            const CustomTextField(
              label: "Product Name",
              icon: Icons.eco,
              initialValue: "Tomato",
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
              ],
            ),

            const CustomTextField(
              label: "Price per Kg",
              icon: Icons.currency_rupee,
              keyboardType: TextInputType.number,
              initialValue: "40",
            ),

            const CustomTextField(
              label: "Available Quantity",
              icon: Icons.inventory,
              keyboardType: TextInputType.number,
              initialValue: "150",
            ),

            const CustomDropdown(
              label: "Unit",
              icon: Icons.scale,
              items: [
                "Kg",
                "Quintal",
                "Ton",
              ],
            ),

            const CustomTextField(
              label: "Description",
              icon: Icons.description,
              maxLines: 4,
              initialValue:
                  "Fresh organically grown tomatoes.",
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
              text: "Update Product",
              onPressed: () {

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Product Updated Successfully",
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
