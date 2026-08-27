import 'package:flutter/material.dart';

import '../../core/colors.dart';

class SuccessScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget nextScreen;

  const SuccessScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.nextScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [

              Container(
                height: 120,
                width: 120,

                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  shape: BoxShape.circle,
                ),

                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 80,
                ),
              ),

              const SizedBox(height: 30),

              Text(
                title,
                textAlign: TextAlign.center,

                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              Text(
                subtitle,
                textAlign: TextAlign.center,

                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 50),

              SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton(

                  onPressed: () {

                    Navigator.pushAndRemoveUntil(

                      context,

                      MaterialPageRoute(
                        builder: (_) => nextScreen,
                      ),

                      (route) => false,

                    );

                  },

                  child: const Text(
                    "Continue",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),

                ),

              ),

            ],
          ),
        ),
      ),
    );
  }
}