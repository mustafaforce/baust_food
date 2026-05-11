import 'package:flutter/material.dart';

/// Vodafone-inspired design tokens.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFFE60000);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF25282B);
  static const Color body = Color(0xFF7E7E7E);
  static const Color mute = Color(0xFFBEBEBE);
  static const Color canvas = Color(0xFFFFFFFF);
  static const Color canvasSoft = Color(0xFFF2F2F2);
  static const Color onDark = Color(0xFFFFFFFF);

  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFED6C02);
  static const Color info = Color(0xFF0288D1);
}

class AppSpacing {
  AppSpacing._();

  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xl2 = 24;
  static const double xl3 = 32;
}

class AppRadius {
  AppRadius._();

  static const double none = 0;
  static const double xs = 1;
  static const double sm = 6;
  static const double card = 6;
  static const double pillMd = 32;
  static const double pillLg = 60;
  static const double full = 9999;
}
