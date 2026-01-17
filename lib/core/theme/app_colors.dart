import 'package:flutter/material.dart';

abstract class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF2979FF); // Electric Blue
  static const Color primaryDark = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFF64B5F6);

  // Status Colors
  static const Color success = Color(0xFF00E676); // Success Green
  static const Color warning = Color(0xFFFF9100); // Review Orange
  static const Color error = Color(0xFFFF1744);

  // Design Specific Accents
  static const Color accentCyan = Color(0xFF00F0FF);
  static const Color accentRed = Color(0xFFFF2A6D);
  static const Color accentGreen = Color(0xFF05D5AA);

  // Background Colors (High-End Dark Mode)
  static const Color background = Color(0xFF0F0F12); // Deep charcoal/black
  static const Color surface = Color(0xFF1A1625); // Surface Dark
  static const Color surfaceContainer =
      Color(0xFF231E32); // Slightly Lighter Surface
  static const Color surfaceVariant =
      Color(0xFF2C2C2C); // Slight Lighter Surface

  // Shadows
  static const List<BoxShadow> neonShadow = [
    BoxShadow(
        color: Color.fromRGBO(146, 19, 236, 0.5),
        blurRadius: 10,
        spreadRadius: 0),
    BoxShadow(
        color: Color.fromRGBO(146, 19, 236, 0.3),
        blurRadius: 20,
        spreadRadius: 0),
  ];

  static const List<BoxShadow> neonCyanShadow = [
    BoxShadow(
        color: Color.fromRGBO(0, 240, 255, 0.5),
        blurRadius: 10,
        spreadRadius: 0),
    BoxShadow(
        color: Color.fromRGBO(0, 240, 255, 0.3),
        blurRadius: 20,
        spreadRadius: 0),
  ];

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF); // High Emphasis
  static const Color textSecondary = Color(0xB3FFFFFF); // Medium Emphasis (70%)
  static const Color textTertiary = Color(0x80FFFFFF); // Low Emphasis (50%)
  static const Color textDisabled = Color(0x62FFFFFF); // Disabled (38%)
}
