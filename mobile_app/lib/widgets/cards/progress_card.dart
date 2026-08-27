import 'package:flutter/material.dart';

import '../../core/colors.dart';

class ProgressCard extends StatelessWidget {
  final double progress;

  const ProgressCard({
    super.key,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (progress * 100).toInt();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),

      child: Padding(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const Text(
              "Profile Completion",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 15),

            LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              borderRadius: BorderRadius.circular(20),
              color: AppColors.primaryGreen,
            ),

            const SizedBox(height: 10),

            Text(
              "$percentage% Completed",
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),

          ],
        ),
      ),
    );
  }
}