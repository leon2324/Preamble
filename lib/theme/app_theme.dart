import 'package:flutter/material.dart';
import 'package:preamble/theme/app_colors.dart';
import 'package:preamble/theme/app_fonts.dart';
import 'package:preamble/theme/preamble_tokens.dart';

/// Preamble 全域 Theme 建構器。
///
/// 正式掛載 `AppFonts`（Inter + 思源黑體 TW + 思源宋體 TW）與 `PreambleTokens`
/// Light / Dark 雙生語意設計系統。
class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    const t = PreambleTokens.light;
    final textTheme = AppFonts.applyDefaultFallbacks(
      Typography.material2021().black,
      bodyColor: t.textPrimary,
      displayColor: t.textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: AppFonts.defaultFamily,
      fontFamilyFallback: AppFonts.defaultFallbacks,
      scaffoldBackgroundColor: t.canvas,
      extensions: const [PreambleTokens.light],
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.light,
        seedColor: t.brandPrimary,
        primary: t.brandPrimary,
        onPrimary: t.brandOnPrimary,
        secondary: t.accentBrass,
        surface: t.surface,
        onSurface: t.textPrimary,
        error: t.semanticUrgent,
      ),
      textTheme: textTheme,
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE5DFD3),
        thickness: 1,
        space: 1,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF8F6F1),
        foregroundColor: Color(0xFF151C19),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: t.brandPrimaryStrong,
        contentTextStyle: const TextStyle(
          fontFamily: AppFonts.defaultFamily,
          fontFamilyFallback: AppFonts.defaultFallbacks,
          color: Color(0xFFFAF8F4),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: t.accentBrass.withValues(alpha: 0.35), width: 1),
        ),
        elevation: 4,
      ),
    );
  }

  static ThemeData dark() {
    const t = PreambleTokens.dark;
    final textTheme = AppFonts.applyDefaultFallbacks(
      Typography.material2021().white,
      bodyColor: t.textPrimary,
      displayColor: t.textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: AppFonts.defaultFamily,
      fontFamilyFallback: AppFonts.defaultFallbacks,
      scaffoldBackgroundColor: t.canvas,
      extensions: const [PreambleTokens.dark],
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.dark,
        seedColor: t.brandPrimary,
        primary: t.brandPrimary,
        onPrimary: t.brandOnPrimary,
        secondary: t.accentBrass,
        surface: t.surface,
        onSurface: t.textPrimary,
        error: t.semanticUrgent,
      ),
      textTheme: textTheme,
      dividerTheme: const DividerThemeData(
        color: Color(0xFF2A3732),
        thickness: 1,
        space: 1,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0E1211),
        foregroundColor: Color(0xFFF2F5F3),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: t.surfaceElevated,
        contentTextStyle: const TextStyle(
          fontFamily: AppFonts.defaultFamily,
          fontFamilyFallback: AppFonts.defaultFallbacks,
          color: Color(0xFFF2F5F3),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: t.borderStrong, width: 1),
        ),
        elevation: 4,
      ),
    );
  }

  /// 供舊有常數參考相容保留
  static Color get primary => AppColors.primary;
}
