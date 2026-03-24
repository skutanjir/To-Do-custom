import 'package:flutter/material.dart';

class AppColors {
  // Primary & Backgrounds
  static const Color primary = Color(0xFF0F172A); // Sleek Slate 900 (Modern Dark)
  static const Color primaryDark = Color(0xFF020617); // Slate 950
  static const Color background = Color(0xFFF9FAFB); // Ultra light gray for depth
  static const Color surface = Color(0xFFFFFFFF); // Pure White
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color white = Colors.white;

  // Text Colors
  static const Color textPrimary = Color(0xFF111827); // Very Dark Gray
  static const Color textSecondary = Color(0xFF6B7280); // Neutral Gray
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textPlaceholder = Color(0xFFD1D5DB);
  static const Color textLight = Colors.white;

  // Accents & Components
  static const Color iconAccent = Color(0xFF0F172A);
  static const Color calendarSelected = Color(0xFF0F172A);
  static const Color calendarBorder = Color(0xFFE5E7EB); // Lighter border
  static const Color calendarOtherMonth = Color(0xFFD1D5DB);
  static const Color calendarEmptyIcon = Color(0xFF9CA3AF);
  static const Color calendarEmptyText = Color(0xFF6B7280);

  // Task Timeline
  static const Color timelineDot = Color(0xFF0F172A);
  static const Color timelineLine = Color(0xFFE5E7EB);

  // Text Fields
  static const Color inputDarkBg = Color(0xFFF3F4F6); // Gray 100

  // Errors & States
  static const Color errorBg = Color(0xFFFEF2F2);
  static const Color errorText = Color(0xFFDC2626);
  static const Color successBg = Color(0xFFF0FDF4);
  static const Color successText = Color(0xFF16A34A);
  static const Color warningBg = Color(0xFFFEFCE8);
  static const Color warningText = Color(0xFFCA8A04);
}

class AppTextStyles {
  static const TextStyle titleLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800, // Heavier weight for contrast
    color: AppColors.textPrimary,
    letterSpacing: -1.0, // Tighter spacing for modern look
    height: 1.2,
  );

  static const TextStyle title = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      fontFamily: 'SF Pro Display', // Reverting to system default like SF Pro/Inter
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        surface: AppColors.background,
        primary: AppColors.primary,
        onPrimary: AppColors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Slightly less rounded for a sharp look
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.calendarBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.calendarBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        hintStyle: const TextStyle(color: AppColors.textPlaceholder, fontWeight: FontWeight.w400),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.calendarBorder, width: 1),
        ),
      ),
    );
  }
}
