import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  // Returns the theme based on current AppColors state
  static ThemeData get theme {
    final isDark = AppColors.isDarkMode;

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,

      // Color Scheme
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.primaryLight,
        onSecondary: Colors.white,
        error: AppColors.error,
        onError: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge:
            AppTextStyles.displayLarge.copyWith(color: AppColors.textPrimary),
        displayMedium:
            AppTextStyles.displayMedium.copyWith(color: AppColors.textPrimary),
        displaySmall:
            AppTextStyles.displaySmall.copyWith(color: AppColors.textPrimary),
        headlineLarge:
            AppTextStyles.headlineLarge.copyWith(color: AppColors.textPrimary),
        headlineMedium:
            AppTextStyles.headlineMedium.copyWith(color: AppColors.textPrimary),
        headlineSmall:
            AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimary),
        titleLarge:
            AppTextStyles.titleLarge.copyWith(color: AppColors.textPrimary),
        titleMedium:
            AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary),
        titleSmall:
            AppTextStyles.titleSmall.copyWith(color: AppColors.textPrimary),
        bodyLarge:
            AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
        bodyMedium:
            AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
        bodySmall:
            AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary),
        labelLarge:
            AppTextStyles.labelLarge.copyWith(color: AppColors.textPrimary),
        labelMedium:
            AppTextStyles.labelMedium.copyWith(color: AppColors.textPrimary),
        labelSmall:
            AppTextStyles.labelSmall.copyWith(color: AppColors.textPrimary),
      ),

      // Component Themes
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle:
            AppTextStyles.titleLarge.copyWith(color: AppColors.textPrimary),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),

      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(8),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          textStyle: AppTextStyles.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
