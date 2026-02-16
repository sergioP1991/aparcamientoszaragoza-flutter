import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  static const textFormFieldBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
    borderSide: BorderSide(color: Colors.grey, width: 1.6),
  );

  static ThemeData getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: AppColors.primaryColor,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkestBlue,
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 34,
          letterSpacing: 0.5,
        ),
        bodySmall: TextStyle(
          color: Colors.grey,
          fontSize: 14,
          letterSpacing: 0.5,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Colors.transparent,
        errorStyle: TextStyle(fontSize: 12),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 14,
        ),
        border: textFormFieldBorder,
        errorBorder: textFormFieldBorder,
        focusedBorder: textFormFieldBorder,
        focusedErrorBorder: textFormFieldBorder,
        enabledBorder: textFormFieldBorder,
        labelStyle: TextStyle(
          fontSize: 17,
          color: Colors.grey,
          fontWeight: FontWeight.w500,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryColor,
          padding: const EdgeInsets.all(4),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryColor,
          minimumSize: const Size(double.infinity, 50),
          side: BorderSide(color: Colors.grey.shade200),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: AppColors.primaryColor,
          disabledBackgroundColor: Colors.grey.shade300,
          minimumSize: const Size(double.infinity, 52),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  static ThemeData getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: AppColors.primaryColor,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.lightText,
          fontSize: 34,
          letterSpacing: 0.5,
        ),
        bodySmall: TextStyle(
          color: AppColors.lightSecondaryText,
          fontSize: 14,
          letterSpacing: 0.5,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurface,
        errorStyle: TextStyle(fontSize: 12),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 14,
        ),
        border: textFormFieldBorder,
        errorBorder: textFormFieldBorder,
        focusedBorder: textFormFieldBorder,
        focusedErrorBorder: textFormFieldBorder,
        enabledBorder: textFormFieldBorder,
        labelStyle: TextStyle(
          fontSize: 17,
          color: AppColors.lightSecondaryText,
          fontWeight: FontWeight.w500,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryColor,
          padding: const EdgeInsets.all(4),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryColor,
          minimumSize: const Size(double.infinity, 50),
          side: BorderSide(color: AppColors.lightSecondaryText),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: AppColors.primaryColor,
          disabledBackgroundColor: Colors.grey.shade300,
          minimumSize: const Size(double.infinity, 52),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  // Dark theme styles
  static const TextStyle titleLarge = TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontSize: 34,
    letterSpacing: 0.5,
  );

  static const TextStyle bodySmall = TextStyle(
    color: Colors.grey,
    letterSpacing: 0.5,
  );

  static const TextStyle bodyTextGreen = TextStyle(
    color: Colors.greenAccent,
    letterSpacing: 0.9,
  );

  static const TextStyle bodyTextRed = TextStyle(
    color: Colors.redAccent,
    letterSpacing: 0.9,
  );

  // Light theme styles
  static const TextStyle titleLargeLight = TextStyle(
    fontWeight: FontWeight.bold,
    color: AppColors.lightText,
    fontSize: 34,
    letterSpacing: 0.5,
  );

  static const TextStyle bodySmallLight = TextStyle(
    color: AppColors.lightSecondaryText,
    letterSpacing: 0.5,
  );

  static const TextStyle bodyTextGreenLight = TextStyle(
    color: AppColors.accentGreen,
    letterSpacing: 0.9,
  );

  static const TextStyle bodyTextRedLight = TextStyle(
    color: AppColors.accentRed,
    letterSpacing: 0.9,
  );
}
