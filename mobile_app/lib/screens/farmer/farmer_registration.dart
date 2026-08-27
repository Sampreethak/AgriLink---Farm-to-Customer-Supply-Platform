import 'package:flutter/material.dart';

import '../../widgets/common/app_logo.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/cards/progress_card.dart';

import '../common/success_screen.dart';
import 'farmer_dashboard.dart';

import 'widgets/personal_information_section.dart';
import 'widgets/farm_information_section.dart';
import 'widgets/banking_information_section.dart';
import 'widgets/additional_information_section.dart';

class FarmerRegistration extends StatefulWidget {
  const FarmerRegistration({super.key});

  @override
  State<FarmerRegistration> createState() =>
      _FarmerRegistrationState();
}

class _FarmerRegistrationState
    extends State<FarmerRegistration> {

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
                "Complete Farmer Profile",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Complete your profile to start selling fresh produce directly to customers.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 25),

              const ProgressCard(
                progress: 0.35,
              ),

              const SizedBox(height: 20),

              const PersonalInformationSection(),

              const FarmInformationSection(),

              const BankingInformationSection(),

              const AdditionalInformationSection(),

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
                            "Your farmer profile has been created successfully.",

                        nextScreen: const FarmerDashboard(),

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