import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => _base(
        brightness: Brightness.light,
        bg: AppColors.bgLight,
        card: AppColors.cardLight,
        border: AppColors.borderLight,
        text: AppColors.textDark,
        textSecondary: AppColors.textGrey,
      );

  static ThemeData get dark => _base(
        brightness: Brightness.dark,
        bg: AppColors.bgDark,
        card: AppColors.cardDark,
        border: AppColors.borderDark,
        text: AppColors.textLight,
        textSecondary: AppColors.textGreyDark,
      );

  static ThemeData _base({
    required Brightness brightness,
    required Color bg,
    required Color card,
    required Color border,
    required Color text,
    required Color textSecondary,
  }) {
    final baseText = GoogleFonts.nunitoTextTheme().apply(
      bodyColor: text,
      displayColor: text,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.orange,
        brightness: brightness,
        primary: AppColors.orange,
        secondary: AppColors.blue,
        surface: card,
        error: AppColors.red,
      ),
      textTheme: baseText.copyWith(
        headlineMedium: baseText.headlineMedium
            ?.copyWith(fontWeight: FontWeight.w900, fontSize: 26),
        titleLarge: baseText.titleLarge
            ?.copyWith(fontWeight: FontWeight.w800, fontSize: 20),
        titleMedium: baseText.titleMedium
            ?.copyWith(fontWeight: FontWeight.w700),
        bodyMedium: baseText.bodyMedium?.copyWith(fontSize: 15),
        labelLarge: baseText.labelLarge?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        foregroundColor: text,
        titleTextStyle: GoogleFonts.nunito(
          fontWeight: FontWeight.w900,
          fontSize: 20,
          color: text,
        ),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: border, width: 2),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerColor: border,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: border, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: border, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.blue, width: 2),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: text,
        contentTextStyle: GoogleFonts.nunito(
          fontWeight: FontWeight.w700,
          color: bg,
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.orange,
        unselectedLabelColor: textSecondary,
        indicatorColor: AppColors.orange,
        labelStyle: GoogleFonts.nunito(fontWeight: FontWeight.w800),
      ),
    );
  }
}
