import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  // Common colors for both themes
  static const Color primaryColor = Color(0xff4FC3F7);
  static const Color accentGreen = Color(0xff00E676);
  static const Color accentOrange = Color(0xffFF9100);
  static const Color accentRed = Color(0xffFF5252);

  // Dark theme colors
  static const Color darkBlue = Color(0xff0A0F1F);
  static const Color darkerBlue = Color(0xff080C16);
  static const Color darkestBlue = Color(0xff05080F);
  static const Color darkCardBackground = Color(0xff161B2E);
  static const Color darkSearchBackground = Color(0xff111626);
  static const Color darkChipBackground = Color(0xff111626);
  static const Color darkChipText = Colors.white70;

  // Light theme colors
  static const Color lightBackground = Color(0xffFFFFFF);
  static const Color lightSurface = Color(0xffF5F5F5);
  static const Color lightCardBackground = Color(0xffFFFFFF);
  static const Color lightSearchBackground = Color(0xffE8E8E8);
  static const Color lightChipBackground = Color(0xffE0E0E0);
  static const Color lightChipText = Color(0xff757575);
  static const Color lightText = Color(0xff212121);
  static const Color lightSecondaryText = Color(0xff757575);

  // Gradients
  static const List<Color> darkGradient = [
    darkBlue,
    darkerBlue,
    darkestBlue,
  ];

  static const List<Color> lightGradient = [
    Color(0xffF8F9FA),
    Color(0xffE9ECEF),
    Color(0xffDEE2E6),
  ];

  // Helper methods to get theme-aware colors
  static Color getCardBackground(bool isDarkTheme) {
    return isDarkTheme ? darkCardBackground : lightCardBackground;
  }

  static Color getSearchBackground(bool isDarkTheme) {
    return isDarkTheme ? darkSearchBackground : lightSearchBackground;
  }

  static Color getChipBackground(bool isDarkTheme) {
    return isDarkTheme ? darkChipBackground : lightChipBackground;
  }

  static List<Color> getGradient(bool isDarkTheme) {
    return isDarkTheme ? darkGradient : lightGradient;
  }

  // Legacy properties for backward compatibility
  static Color get cardBackground => darkCardBackground;
  static Color get searchBackground => darkSearchBackground;
  static Color get chipBackground => darkChipBackground;
  static List<Color> get defaultGradient => darkGradient;
}
