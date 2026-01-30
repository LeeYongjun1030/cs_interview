import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract class AppTextStyles {
  // Display & Headings: Space Grotesk (Futuristic, Tech)
  static TextStyle get _displayFont => GoogleFonts.spaceGrotesk();

  // Body: Noto Sans KR (Readable, clean)
  static TextStyle get _bodyFont => GoogleFonts.notoSansKr();

  static TextStyle get displayLarge => _displayFont.copyWith(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        letterSpacing: -0.25,
      );

  static TextStyle get displayMedium => _displayFont.copyWith(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        letterSpacing: 0,
      );

  static TextStyle get displaySmall => _displayFont.copyWith(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        letterSpacing: 0,
      );

  static TextStyle get headlineLarge => _displayFont.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        letterSpacing: 0,
      );

  static TextStyle get headlineMedium => _displayFont.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        letterSpacing: 0,
      );

  static TextStyle get headlineSmall => _displayFont.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        letterSpacing: 0,
      );

  static TextStyle get titleLarge => _displayFont.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        letterSpacing: 0,
      );

  static TextStyle get titleMedium => _bodyFont.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        letterSpacing: 0.15,
      );

  static TextStyle get titleSmall => _bodyFont.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        letterSpacing: 0.1,
      );

  static TextStyle get bodyLarge => _bodyFont.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        letterSpacing: 0.5,
      );

  static TextStyle get bodyMedium => _bodyFont.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        letterSpacing: 0.25,
      );

  static TextStyle get bodySmall => _bodyFont.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textTertiary,
        letterSpacing: 0.4,
      );

  static TextStyle get labelLarge => _bodyFont.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        letterSpacing: 0.1,
      );

  static TextStyle get labelMedium => _bodyFont.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        letterSpacing: 0.5,
      );

  static TextStyle get labelSmall => _bodyFont.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.textTertiary,
        letterSpacing: 0.5,
      );
}
