import 'package:flutter/material.dart';

class AppColors {
  // State for manual toggling locally (Syncs with ThemeController)
  static bool isDarkMode = false; // Default to Light

  // Brand Colors (Shared or Adaptive)
  static const Color _primary = Color(0xFF2979FF); // Electric Blue
  static Color get primary => _primary;

  static const Color _primaryDark = Color(0xFF1565C0);
  static Color get primaryDark => _primaryDark;

  static const Color _primaryLight = Color(0xFF64B5F6);
  static Color get primaryLight => _primaryLight;

  // Status Colors
  static const Color success = Color(0xFF00E676);
  static const Color warning = Color(0xFFFF9100);
  static const Color error = Color(0xFFFF1744);

  // Design Specific Accents
  // Dark Mode Accents
  static const Color _accentCyanDark = Color(0xFF00F0FF);
  static const Color _accentRedDark = Color(0xFFFF2A6D);
  static const Color _accentGreenDark = Color(0xFF05D5AA);

  // Light Mode Accents (Slightly darker for contrast)
  static const Color _accentCyanLight = Color(0xFF0097A7);
  static const Color _accentRedLight = Color(0xFFD50000);
  static const Color _accentGreenLight = Color(0xFF00C853);

  static Color get accentCyan =>
      isDarkMode ? _accentCyanDark : _accentCyanLight;
  static Color get accentRed => isDarkMode ? _accentRedDark : _accentRedLight;
  static Color get accentGreen =>
      isDarkMode ? _accentGreenDark : _accentGreenLight;

  // Background Colors
  // Dark
  static const Color _backgroundDark = Color(0xFF0F0F12);
  static const Color _surfaceDark = Color(0xFF1A1625);
  static const Color _surfaceContainerDark = Color(0xFF231E32);
  static const Color _surfaceVariantDark = Color(0xFF2C2C2C);

  // Light
  static const Color _backgroundLight =
      Color(0xFFEEF2F6); // Soft Gray/Blue (Darker)
  static const Color _surfaceLight = Color(0xFFFFFFFF); // White
  static const Color _surfaceContainerLight = Color(0xFFFFFFFF);
  static const Color _surfaceVariantLight = Color(0xFFEAECF0); // Gray 200

  static Color get background =>
      isDarkMode ? _backgroundDark : _backgroundLight;
  static Color get surface => isDarkMode ? _surfaceDark : _surfaceLight;
  static Color get surfaceContainer =>
      isDarkMode ? _surfaceContainerDark : _surfaceContainerLight;
  static Color get surfaceVariant =>
      isDarkMode ? _surfaceVariantDark : _surfaceVariantLight;

  // Shadows
  static const List<BoxShadow> neonShadow = [];
  static const List<BoxShadow> neonCyanShadow = [];

  // Text Colors
  // Dark
  static const Color _textPrimaryDark = Color(0xFFFFFFFF);
  static const Color _textSecondaryDark = Color(0xB3FFFFFF);
  static const Color _textTertiaryDark = Color(0x80FFFFFF);
  static const Color _textDisabledDark = Color(0x62FFFFFF);

  // Light
  static const Color _textPrimaryLight = Color(0xFF1A1625); // Dark Text
  static const Color _textSecondaryLight = Color(0xFF616161); // Grey Text
  static const Color _textTertiaryLight = Color(0xFF9E9E9E); // Lighter Grey
  static const Color _textDisabledLight = Color(0xFFBDBDBD);

  static Color get textPrimary =>
      isDarkMode ? _textPrimaryDark : _textPrimaryLight;
  static Color get textSecondary =>
      isDarkMode ? _textSecondaryDark : _textSecondaryLight;
  static Color get textTertiary =>
      isDarkMode ? _textTertiaryDark : _textTertiaryLight;
  static Color get textDisabled =>
      isDarkMode ? _textDisabledDark : _textDisabledLight;
}
