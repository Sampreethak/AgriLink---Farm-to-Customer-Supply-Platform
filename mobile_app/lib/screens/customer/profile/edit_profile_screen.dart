import 'package:flutter/material.dart';

import '../../../widgets/common/primary_button.dart';
import '../../../widgets/form/custom_text_field.dart';
import '../../../widgets/form/custom_upload_title.dart';

class CustomerEditProfileScreen extends StatelessWidget {
  const CustomerEditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Edit Profile"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            const CustomUploadTile(
              title: "Change Profile Picture",
              icon: Icons.person,
            ),

            const SizedBox(height: 20),

            const CustomTextField(
              label: "Full Name",
              icon: Icons.person,
              initialValue: "Sampreetha",
            ),

            const CustomTextField(
              label: "Phone Number",
              icon: Icons.phone,
            ),

            const CustomTextField(
              label: "Email",
              icon: Icons.email,
            ),

            const CustomTextField(
              label: "Address",
              icon: Icons.home,
            ),

            const CustomTextField(
              label: "City",
              icon: Icons.location_city,
            ),

            const CustomTextField(
              label: "State",
              icon: Icons.map,
            ),

            const CustomTextField(
              label: "Pincode",
              icon: Icons.pin_drop,
            ),

            const SizedBox(height: 20),

            PrimaryButton(
              text: "Save Changes",
              onPressed: () {

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Profile Updated"),
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