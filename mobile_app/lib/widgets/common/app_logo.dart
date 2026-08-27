import 'package:flutter/material.dart';

import '../../core/colors.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showSubtitle;

  const AppLogo({
    super.key,
    this.size = 80,
    this.showSubtitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        CircleAvatar(
          radius: size / 2,
          backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.1),

          child: Icon(
            Icons.agriculture,
            size: size * 0.6,
            color: AppColors.primaryGreen,
          ),
        ),

        const SizedBox(height: 15),

        const Text(
          "AgriLink",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryGreen,
          ),
        ),

        if (showSubtitle) ...[
          const SizedBox(height: 6),

          const Text(
            "Connecting Farmers & Customers",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 15,
            ),
          ),
        ],
      ],
    );
  }
}