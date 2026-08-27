import 'package:flutter/material.dart';

import '../../../widgets/cards/expansion_card.dart';
import '../../../widgets/form/custom_dropdown.dart';
import '../../../widgets/form/custom_text_field.dart';
import '../../../widgets/form/custom_upload_title.dart';

class FarmInformationSection extends StatelessWidget {
  const FarmInformationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ExpansionCard(
      title: "Farm Information",
      icon: Icons.agriculture,

      child: Column(
        children: [

          const CustomTextField(
            label: "Farm Name",
            icon: Icons.eco,
          ),

          const CustomTextField(
            label: "Farm Address",
            icon: Icons.home,
          ),

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.my_location,
                color: Colors.green,
              ),

              title: const Text("Use Current Location"),

              subtitle: const Text(
                "Auto fill farm location",
              ),

              trailing: const Icon(Icons.arrow_forward_ios),

              onTap: () {

                ScaffoldMessenger.of(context).showSnackBar(

                  const SnackBar(

                    content: Text(
                      "Location integration coming soon",
                    ),

                  ),

                );

              },
            ),
          ),

          const SizedBox(height: 15),

          const CustomTextField(
            label: "Village",
            icon: Icons.location_city,
          ),

          const CustomTextField(
            label: "District",
            icon: Icons.map,
          ),

          const CustomTextField(
            label: "State",
            icon: Icons.public,
          ),

          const CustomTextField(
            label: "Pincode",
            icon: Icons.pin_drop,
          ),

          const CustomTextField(
            label: "Farm Size (Acres)",
            icon: Icons.square_foot,
          ),

          const CustomDropdown(
            label: "Primary Crop",
            icon: Icons.grass,
            items: [
              "Rice",
              "Wheat",
              "Tomato",
              "Potato",
              "Onion",
              "Carrot",
              "Brinjal",
              "Cabbage",
              "Banana",
              "Mango",
            ],
          ),

          const SizedBox(height: 10),

          const CustomUploadTile(
            title: "Upload Farm Image",
            icon: Icons.image,
          ),
        ],
      ),
    );
  }
}