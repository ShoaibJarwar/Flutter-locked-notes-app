import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Colors
  static const Color primaryColor = Color(0xFF43A047);
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Colors.grey;

  // Spacing
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;

  // Border radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;

  // Text Styles
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 16,
    color: textSecondary,
  );

  static ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
    useMaterial3: true,
    primaryColor: primaryColor,
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        elevation: 0,
      ),
    ),
  );
}
