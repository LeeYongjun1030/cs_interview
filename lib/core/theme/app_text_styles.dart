import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract class AppTextStyles {
  // Display & Headings: Space Grotesk (Futuristic, Tech)
  static TextStyle get _displayFont => GoogleFonts.spaceGrotesk();
  
  // Body: Noto Sans KR (Readable, clean)
  static TextStyle get _bodyFont => GoogleFonts.notoSansKr();

  static TextStyle displayLarge = _displayFont.copyWith(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    letterSpacing: -0.25,
  );

  static TextStyle displayMedium = _displayFont.copyWith(
    fontSize: 45,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    letterSpacing: 0,
  );

  static TextStyle displaySmall = _displayFont.copyWith(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    letterSpacing: 0,
  );

  static TextStyle headlineLarge = _displayFont.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    letterSpacing: 0,
  );

  static TextStyle headlineMedium = _displayFont.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    letterSpacing: 0,
  );

  static TextStyle headlineSmall = _displayFont.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    letterSpacing: 0,
  );

  static TextStyle titleLarge = _displayFont.copyWith(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    letterSpacing: 0,
  );

  static TextStyle titleMedium = _bodyFont.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    letterSpacing: 0.15,
  );

  static TextStyle titleSmall = _bodyFont.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    letterSpacing: 0.1,
  );

  static TextStyle bodyLarge = _bodyFont.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    letterSpacing: 0.5,
  );

  static TextStyle bodyMedium = _bodyFont.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    letterSpacing: 0.25,
  );

  static TextStyle bodySmall = _bodyFont.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
    letterSpacing: 0.4,
  );

  static TextStyle labelLarge = _bodyFont.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    letterSpacing: 0.1,
  );

  static TextStyle labelMedium = _bodyFont.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.5,
  );

  static TextStyle labelSmall = _bodyFont.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textTertiary,
    letterSpacing: 0.5,
  );
}
