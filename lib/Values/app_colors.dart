import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  // Common colors for both themes (updated modern palette)
  @Deprecated('Use gray900 instead')
  static const Color primaryColor = Color(0xff4FC3F7);
  @Deprecated('Use success instead')
  static const Color accentGreen = Color(0xff16a34a);
  @Deprecated('Use warning or error instead')
  static const Color accentOrange = Color(0xffd97706);
  @Deprecated('Use error instead')
  static const Color accentRed = Color(0xffd32f2f);

  // ─── BASE GRAYS (Neutral foundation - modern, muted palette) ──────────────
  static const Color gray50 = Color(0xfffffbfa);
  static const Color gray100 = Color(0xfff8f5f2);
  static const Color gray200 = Color(0xffede9e3);
  static const Color gray300 = Color(0xffd8d0c5);
  static const Color gray400 = Color(0xffb5a896);
  static const Color gray500 = Color(0xff8b7f6f);
  static const Color gray600 = Color(0xff5f554a);
  static const Color gray700 = Color(0xff362f28);
  static const Color gray800 = Color(0xff1a1410);
  static const Color gray900 = Color(0xff0d0a08);

  // ─── PRIMARY SEMANTIC COLORS ──────────────────────────────────────────────
  static const Color blue = Color(0xff2563eb);
  static const Color blueSoft = Color(0xff3b82f6);
  static const Color blueLight = Color(0xffdbeafe);
  static const Color success = Color(0xff16a34a);
  static const Color successLight = Color(0xffdcfce7);
  static const Color warning = Color(0xffd97706);
  static const Color warningLight = Color(0xfffef3c7);
  static const Color error = Color(0xffd32f2f);
  static const Color errorLight = Color(0xffffe0e6);
  static const Color info = Color(0xff0891b2);
  static const Color infoLight = Color(0xffcffafe);

  // ─── BACKGROUND COLORS ────────────────────────────────────────────────────
  static const Color bgLight = Color(0xfffdfdfc);
  static const Color bgCard = Color(0xfffff9f7);
  static const Color bgAlt = Color(0xfff5f3f0);
  static const Color bgDark = Color(0xff1a1410);
  static const Color bgCardDark = Color(0xff262219);
  // Dark theme colors (deprecated - use new palette instead)
  @Deprecated('Use gray900 instead')
  static const Color darkBlue = Color(0xff0A0F1F);
  @Deprecated('Use gray800 instead')
  static const Color darkerBlue = Color(0xff080C16);
  @Deprecated('Use gray900 instead')
  static const Color darkestBlue = Color(0xff05080F);
  @Deprecated('Use bgCardDark instead')
  static const Color darkCardBackground = Color(0xff161B2E);
  @Deprecated('Use gray700 instead')
  static const Color darkSearchBackground = Color(0xff111626);
  @Deprecated('Use gray700 instead')
  static const Color darkChipBackground = Color(0xff111626);
  static const Color darkChipText = Colors.white70;

  // Light theme colors (deprecated - use new palette instead)
  @Deprecated('Use bgLight instead')
  static const Color lightBackground = Color(0xffFFFFFF);
  @Deprecated('Use bgCard instead')
  static const Color lightSurface = Color(0xfff5f5f5);
  @Deprecated('Use bgCard instead')
  static const Color lightCardBackground = Color(0xffFFFFFF);
  @Deprecated('Use gray200 instead')
  static const Color lightSearchBackground = Color(0xffE8E8E8);
  @Deprecated('Use gray200 instead')
  static const Color lightChipBackground = Color(0xffE0E0E0);
  static const Color lightChipText = Color(0xff757575);
  @Deprecated('Use gray700 instead')
  static const Color lightText = Color(0xff212121);
  static const Color lightSecondaryText = Color(0xff757575);

  // Gradients (minimal use - only when justified)
  static const List<Color> darkGradient = [
    gray900,
    gray800,
    gray700,
  ];

  static const List<Color> lightGradient = [
    bgLight,
    bgAlt,
    gray200,
  ];

  // ─── HELPER METHODS (Theme-aware) ─────────────────────────────────────────
  static Color getCardBackground(bool isDarkTheme) {
    return isDarkTheme ? bgCardDark : bgCard;
  }

  static Color getSearchBackground(bool isDarkTheme) {
    return isDarkTheme ? gray800 : gray200;
  }

  static Color getChipBackground(bool isDarkTheme) {
    return isDarkTheme ? gray800 : gray200;
  }

  static List<Color> getGradient(bool isDarkTheme) {
    return isDarkTheme ? darkGradient : lightGradient;
  }

  // Legacy properties for backward compatibility
  static Color get cardBackground => bgCardDark;
  static Color get searchBackground => gray800;
  static Color get chipBackground => gray800;
  static List<Color> get defaultGradient => darkGradient;
}
