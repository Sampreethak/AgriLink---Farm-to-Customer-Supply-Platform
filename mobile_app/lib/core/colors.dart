import 'package:flutter/material.dart';

class AppColors {
  // Pure Cream & Light Green Palette for AgriLink
  static const Color creamBackground = Color(0xFFFDFBF7); // Soft Warm Cream
  static const Color creamSurface = Color(0xFFF5F2EB);    // Light Cream Card Surface
  static const Color creamBorder = Color(0xFFE8E4D8);     // Muted Cream Border

  // Light Green Shades
  static const Color lightGreenPrimary = Color(0xFF2E7D32); // Deep Organic Leaf Green
  static const Color lightGreenMedium = Color(0xFF4CAF50);  // Fresh Harvest Green
  static const Color lightGreenAccent = Color(0xFF81C784);  // Soft Pastel Light Green
  static const Color mintLight = Color(0xFFE8F5E9);         // Soft Mint Highlight

  // Accent Colors
  static const Color accentOrange = Color(0xFFE65100);
  static const Color warmGold = Color(0xFFF57F17);

  // Backward compatibility & static aliases for screens
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color primaryGreenDark = Color(0xFF1B5E20);
  static const Color primaryGreenLight = Color(0xFF81C784);
  static const Color lightGreen = Color(0xFF81C784);
  static const Color orange = Color(0xFFE65100);
  static const Color accent = Color(0xFFE65100);
  static const Color border = Color(0xFFE8E4D8);
  static const Color greyLight = Color(0xFFF1F5F4);
  static const Color grey = Color(0xFF757575);

  static const Color background = Color(0xFFFDFBF7);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceGreen = Color(0xFFE8F5E9);

  // Typography
  static const Color text = Color(0xFF1B3B2B);          // Dark Slate Green
  static const Color textSecondary = Color(0xFF5D6D5E); // Muted Earthy Green/Grey
  static const Color textHint = Color(0xFF9EABA1);

  // Status
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF57F17);
  static const Color error = Color(0xFFC62828);
  static const Color info = Color(0xFF0288D1);

  // Gradients
  static const LinearGradient creamGreenGradient = LinearGradient(
    colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF4CAF50)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}