import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Warm orange is widely used in food-related products because it is energetic,
  // appetite-friendly, and high contrast on light backgrounds.
  static const Color brandColor = Color(0xFFFF6B35);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(seedColor: brandColor);

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFFFFBF8),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          backgroundColor: brandColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
