import 'package:flutter/material.dart';

// =============================================================================
// [審查標記] 此檔案為設計階段遺留的死碼。
// =============================================================================
// PreambleTheme 從未被專案中任何檔案使用。main.dart 的 MaterialApp 使用的是
// lib/theme/app_theme.dart 中的 AppTheme.light() / AppTheme.dark()。
//
// 保留此檔案供日後參考（例如需要回顧最初的色彩規劃），
// 但請勿在新程式碼中引用這個類別。若需要調整主題，請修改 AppTheme。
//
// 教學重點：在專案演進過程中，早期的原型程式碼很容易變成死碼。
// 建議定期執行 `flutter analyze` 搭配 unused_element 規則來偵測此類問題。
// =============================================================================

/// [已棄用] 設計階段的色彩主題原型，已被 AppTheme 取代。
/// 請使用 lib/theme/app_theme.dart 中的 AppTheme 類別。
@Deprecated('Use AppTheme from lib/theme/app_theme.dart instead. '
    'This class was an early design prototype and is not referenced anywhere in the codebase.')
enum PreambleThemeAccent {
  morandiGreen, // 莫蘭迪綠 (預設)
  charcoalDark, // 典雅黑炭
  navyBlue,     // 海軍藍
}

/// [已棄用] 設計階段的主題管理原型，已被 AppTheme 取代。
@Deprecated('Use AppTheme from lib/theme/app_theme.dart instead.')
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
