import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static TextStyle get displayLarge => GoogleFonts.nunito(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
      );

  static TextStyle get displayMedium => GoogleFonts.nunito(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.3,
      );

  static TextStyle get headlineLarge => GoogleFonts.nunito(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get headlineMedium => GoogleFonts.nunito(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get headlineSmall => GoogleFonts.nunito(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get titleLarge => GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get titleMedium => GoogleFonts.nunito(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyLarge => GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyMedium => GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodySmall => GoogleFonts.nunito(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  static TextStyle get labelLarge => GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0.5,
      );

  static TextStyle get labelMedium => GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        letterSpacing: 0.3,
      );

  static TextStyle get labelSmall => GoogleFonts.nunito(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.textMuted,
        letterSpacing: 0.3,
      );

  static TextStyle get scoreDisplay => GoogleFonts.nunito(
        fontSize: 48,
        fontWeight: FontWeight.w800,
        color: AppColors.accent,
        letterSpacing: -1,
      );
}
