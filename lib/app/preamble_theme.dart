import 'package:flutter/material.dart';

/// Preamble 色彩主題輪廓
enum PreambleThemeAccent {
  morandiGreen, // 莫蘭迪綠 (預設)
  charcoalDark, // 典雅黑炭
  navyBlue,     // 海軍藍
}

/// 集中管理 App 深淺色主題與客製化色彩
class PreambleTheme {
  static ThemeData getLightTheme({
    PreambleThemeAccent accent = PreambleThemeAccent.morandiGreen,
  }) {
    final primary = _getPrimaryColor(accent, false);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: const Color(0xFFF9FBFA), // 象牙白底
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: const Color(0xFF9E4A4A),
        surface: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF17231F),
        elevation: 0,
      ),
      fontFamily: 'Inter', // 若專案有引進字體可調整
    );
  }

  static ThemeData getDarkTheme({
    PreambleThemeAccent accent = PreambleThemeAccent.charcoalDark,
  }) {
    final primary = _getPrimaryColor(accent, true);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primary,
      scaffoldBackgroundColor: const Color(0xFF121212),
      colorScheme: ColorScheme.dark(
        primary: primary,
        secondary: const Color(0xFFE57373),
        surface: const Color(0xFF1E1E1E),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      fontFamily: 'Inter',
    );
  }

  static Color _getPrimaryColor(PreambleThemeAccent accent, bool isDark) {
    switch (accent) {
      case PreambleThemeAccent.morandiGreen:
        return isDark ? const Color(0xFF488764) : const Color(0xFF2C5E43);
      case PreambleThemeAccent.charcoalDark:
        return isDark ? const Color(0xFF333333) : const Color(0xFF17231F);
      case PreambleThemeAccent.navyBlue:
        return isDark ? const Color(0xFF5A8BBA) : const Color(0xFF2A4D69);
    }
  }
}
