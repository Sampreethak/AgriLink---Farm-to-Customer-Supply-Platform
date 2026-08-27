import 'package:flutter/material.dart';

import '../../widgets/common/app_logo.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/cards/progress_card.dart';
import '../../widgets/cards/expansion_card.dart';
import '../../widgets/form/custom_text_field.dart';
import '../../widgets/form/custom_dropdown.dart';
import '../../widgets/form/custom_upload_title.dart';

import '../common/success_screen.dart';
import 'customer_dashboard.dart';

class CustomerRegistrationScreen extends StatefulWidget {
  const CustomerRegistrationScreen({super.key});

  @override
  State<CustomerRegistrationScreen> createState() =>
      _CustomerRegistrationScreenState();
}

class _CustomerRegistrationScreenState
    extends State<CustomerRegistrationScreen> {

  bool agree = false;

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xffF8FFF5),

      body: SafeArea(

        child: SingleChildScrollView(

          padding: const EdgeInsets.all(20),

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.stretch,

            children: [

              const SizedBox(height: 10),

              const AppLogo(),

              const SizedBox(height: 25),

              const Text(
                "Complete Customer Profile",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Complete your profile to start ordering fresh produce directly from farmers.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 25),

              const ProgressCard(
                progress: 0.25,
              ),

              const SizedBox(height: 20),

              ExpansionCard(

                initiallyExpanded: true,

                title: "Personal Information",

                icon: Icons.person,

                child: Column(

                  children: const [

                    CustomTextField(
                      label: "Full Name",
                      icon: Icons.person,
                    ),

                    CustomTextField(
                      label: "Email Address",
                      icon: Icons.email,
                    ),

                    CustomTextField(
                      label: "Phone Number",
                      icon: Icons.phone,
                    ),

                  ],

                ),

              ),

              ExpansionCard(

                title: "Address Information",

                icon: Icons.location_on,

                child: Column(

                  children: const [

                    CustomTextField(
                      label: "Address",
                      icon: Icons.home,
                    ),

                    CustomTextField(
                      label: "City",
                      icon: Icons.location_city,
                    ),

                    CustomTextField(
                      label: "State",
                      icon: Icons.map,
                    ),

                    CustomTextField(
                      label: "Pincode",
                      icon: Icons.pin_drop,
                    ),

                  ],

                ),

              ),

              ExpansionCard(

                title: "Customer Type",

                icon: Icons.groups,

                child: Column(

                  children: const [

                    CustomDropdown(
                      label: "Select Customer Type",
                      icon: Icons.business,
                      items: [
                        "Individual Customer",
                        "Hostel / PG",
                        "Hospital",
                      ],
                    ),

                  ],

                ),

              ),

              ExpansionCard(

                title: "Additional Information",

                icon: Icons.description,

                child: Column(

                  children: const [

                    CustomUploadTile(
                      title: "Upload Profile Picture",
                      icon: Icons.person,
                    ),

                    SizedBox(height: 15),

                    CustomTextField(
                      label: "Additional Notes",
                      icon: Icons.note,
                      maxLines: 4,
                    ),

                  ],

                ),

              ),

              const SizedBox(height: 15),

              Card(

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),

                child: CheckboxListTile(

                  value: agree,

                  activeColor: Colors.green,

                  title: const Text(
                    "I agree to the Terms & Conditions",
                  ),

                  onChanged: (value) {

                    setState(() {

                      agree = value ?? false;

                    });

                  },

                ),

              ),

              const SizedBox(height: 25),

              PrimaryButton(

                text: "Complete Registration",

                onPressed: () {

                  if (!agree) {

                    ScaffoldMessenger.of(context).showSnackBar(

                      const SnackBar(

                        content: Text(
                          "Please accept Terms & Conditions",
                        ),

                      ),

                    );

                    return;

                  }

                  Navigator.pushReplacement(

                    context,

                    MaterialPageRoute(

                      builder: (_) => SuccessScreen(

                        title: "Registration Successful!",

                        subtitle:
                            "Your customer profile has been created successfully.",

                        nextScreen: const CustomerDashboard(),

                      ),

                    ),

                  );

                },

              ),

              const SizedBox(height: 30),

            ],

          ),

        ),

      ),

    );

  }

}