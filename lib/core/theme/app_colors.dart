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

  // Background Colors (High-End Dark Mode)
  static const Color background = Color(0xFF121212); // Deep Dark
  static const Color surface = Color(0xFF1E1E1E); // Card Surface
  static const Color surfaceVariant = Color(0xFF2C2C2C); // Slight Lighter Surface

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF); // High Emphasis
  static const Color textSecondary = Color(0xB3FFFFFF); // Medium Emphasis (70%)
  static const Color textTertiary = Color(0x80FFFFFF); // Low Emphasis (50%)
  static const Color textDisabled = Color(0x62FFFFFF); // Disabled (38%)
}
