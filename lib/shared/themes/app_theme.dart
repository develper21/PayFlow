import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.shape,
        background: AppColors.background,
        error: AppColors.delete,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.heading,
        onBackground: AppColors.heading,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        elevation: 0,
        titleTextStyle: GoogleFonts.lexendDeca(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      textTheme: TextTheme(
        displayLarge: _lightTextStyle(AppColors.heading, 32, FontWeight.w600),
        titleLarge: _lightTextStyle(AppColors.heading, 20, FontWeight.w600),
        titleMedium: _lightTextStyle(AppColors.heading, 17, FontWeight.w600),
        bodyLarge: _lightTextStyle(AppColors.body, 16, FontWeight.w400),
        bodyMedium: _lightTextStyle(AppColors.body, 15, FontWeight.w400),
        bodySmall: _lightTextStyle(AppColors.body, 13, FontWeight.w400),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.shape,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.stroke),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.stroke),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        labelStyle: TextStyle(color: AppColors.input),
      ),
      cardTheme: CardTheme(
        color: AppColors.shape,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: AppColors.stroke),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.stroke,
        thickness: 1,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.body,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.darkPrimary,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkPrimary,
        secondary: AppColors.darkSecondary,
        surface: AppColors.darkSurface,
        background: AppColors.darkBackground,
        error: AppColors.delete,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.darkHeading,
        onBackground: AppColors.darkHeading,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkPrimary,
        elevation: 0,
        titleTextStyle: GoogleFonts.lexendDeca(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      textTheme: TextTheme(
        displayLarge: _darkTextStyle(AppColors.darkHeading, 32, FontWeight.w600),
        titleLarge: _darkTextStyle(AppColors.darkHeading, 20, FontWeight.w600),
        titleMedium: _darkTextStyle(AppColors.darkHeading, 17, FontWeight.w600),
        bodyLarge: _darkTextStyle(AppColors.darkBody, 16, FontWeight.w400),
        bodyMedium: _darkTextStyle(AppColors.darkBody, 15, FontWeight.w400),
        bodySmall: _darkTextStyle(AppColors.darkBody, 13, FontWeight.w400),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkShape,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.darkStroke),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.darkStroke),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.darkPrimary),
        ),
        labelStyle: TextStyle(color: AppColors.darkInput),
      ),
      cardTheme: CardTheme(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: AppColors.darkStroke),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.darkStroke,
        thickness: 1,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkBackground,
        selectedItemColor: AppColors.darkPrimary,
        unselectedItemColor: AppColors.darkBody,
      ),
    );
  }

  static TextStyle _lightTextStyle(Color color, double size, FontWeight weight) {
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      color: color,
    );
  }

  static TextStyle _darkTextStyle(Color color, double size, FontWeight weight) {
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      color: color,
    );
  }
}
