import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agrilink_app/core/colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.creamBackground,
      primaryColor: AppColors.lightGreenPrimary,

      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.lightGreenPrimary,
        primary: AppColors.lightGreenPrimary,
        secondary: AppColors.lightGreenAccent,
        surface: AppColors.creamBackground,
        error: AppColors.error,
      ),

      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: AppColors.text,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColors.text,
        ),
        headlineLarge: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.text,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.text,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.text,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.text,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: AppColors.text,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          color: AppColors.textHint,
        ),
        labelLarge: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),

      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.lightGreenPrimary,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 54),
          backgroundColor: AppColors.lightGreenPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 54),
          foregroundColor: AppColors.lightGreenPrimary,
          side: const BorderSide(color: AppColors.lightGreenPrimary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.creamSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: GoogleFonts.inter(
          color: AppColors.textHint,
          fontSize: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.creamBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.creamBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.lightGreenPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        prefixIconColor: AppColors.lightGreenPrimary,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.mintLight,
        selectedColor: AppColors.lightGreenPrimary,
        labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.creamSurface,
        selectedItemColor: AppColors.lightGreenPrimary,
        unselectedItemColor: AppColors.textHint,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}