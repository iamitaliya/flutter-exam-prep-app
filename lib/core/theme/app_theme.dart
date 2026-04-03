import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accent,
          onPrimary: Colors.black,
          secondary: AppColors.accentLight,
          onSecondary: Colors.black,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
          error: AppColors.error,
          onError: Colors.white,
          surfaceContainerHighest: AppColors.surfaceLight,
          outline: AppColors.border,
        ),
        textTheme: GoogleFonts.nunitoTextTheme(
          ThemeData.dark().textTheme,
        ).copyWith(
          displayLarge: GoogleFonts.nunito(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
          headlineMedium: GoogleFonts.nunito(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
          bodyLarge: GoogleFonts.nunito(
            color: AppColors.textPrimary,
          ),
          bodyMedium: GoogleFonts.nunito(
            color: AppColors.textSecondary,
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          centerTitle: false,
          scrolledUnderElevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.accent,
          unselectedItemColor: AppColors.textMuted,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        cardTheme: CardTheme(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.border, width: 1),
          ),
          margin: EdgeInsets.zero,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: GoogleFonts.nunito(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
            elevation: 0,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.accent,
            side: const BorderSide(color: AppColors.accent, width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: GoogleFonts.nunito(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.accent,
            textStyle: GoogleFonts.nunito(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.accent, width: 2),
          ),
          hintStyle: GoogleFonts.nunito(color: AppColors.textMuted),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.border,
          thickness: 1,
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? AppColors.accent
                : AppColors.textMuted,
          ),
          trackColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? AppColors.accentDark
                : AppColors.border,
          ),
        ),
        sliderTheme: const SliderThemeData(
          activeTrackColor: AppColors.accent,
          thumbColor: AppColors.accent,
          overlayColor: Color(0x33F0A500),
          inactiveTrackColor: AppColors.border,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.surface,
          selectedColor: AppColors.accentDark,
          labelStyle: GoogleFonts.nunito(
            fontSize: 12,
            color: AppColors.textPrimary,
          ),
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.accent,
          linearTrackColor: AppColors.border,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.surface,
          contentTextStyle: GoogleFonts.nunito(color: AppColors.textPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          behavior: SnackBarBehavior.floating,
        ),
        dialogTheme: DialogTheme(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          titleTextStyle: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          contentTextStyle: GoogleFonts.nunito(
            fontSize: 15,
            color: AppColors.textSecondary,
          ),
        ),
      );

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF0F4F8),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFD4920A),
          onPrimary: Colors.white,
          secondary: Color(0xFFF0A500),
          surface: Colors.white,
          onSurface: Color(0xFF1A2D42),
          error: AppColors.error,
          outline: Color(0xFFD1DCE8),
        ),
        textTheme: GoogleFonts.nunitoTextTheme(ThemeData.light().textTheme),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF0F4F8),
          foregroundColor: Color(0xFF1A2D42),
          elevation: 0,
          centerTitle: false,
          scrolledUnderElevation: 0,
        ),
      );
}
