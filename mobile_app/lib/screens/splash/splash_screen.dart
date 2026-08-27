import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/colors.dart';
import '../language/language_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    Timer(
      const Duration(seconds: 3),
      () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const LanguageSelectionScreen(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: AppColors.primaryGreen,

      body: Center(

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            const Icon(
              Icons.agriculture,
              color: Colors.white,
              size: 110,
            ),

            const SizedBox(height: 20),

            const Text(
              "AgriLink",
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Connecting Farmers to Customers",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 50),

            const CircularProgressIndicator(
              color: Colors.white,
            ),

          ],
        ),
      ),
    );
  }
}