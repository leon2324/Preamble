import 'package:flutter/material.dart';
import 'package:preamble/theme/app_colors.dart';

/// Preamble 全域 Theme 建構器。
///
/// Theme 的顏色、字體與 Material 基礎樣式集中在這裡；`main.dart` 只負責套用，
/// 避免 App 殼層同時承擔主題細節與分頁狀態管理。
class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.background,
      ),
      textTheme: Typography.blackMountainView.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1E352F),
        contentTextStyle: const TextStyle(
          color: Color(0xFFFAF6F0),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFF32544A), width: 1),
        ),
        elevation: 4,
      ),
    );
  }

  static ThemeData dark() {
    // 深色主題先處理全域背景、文字與 Material 元件基礎色；
    // 部分既有首頁插畫卡片仍保留品牌色，避免一鍵深色後失去首頁識別。
    const darkBackground = Color(0xFF0F1216);
    const darkSurface = Color(0xFF171C22);
    const darkText = Color(0xFFF2F4F7);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.dark,
        seedColor: const Color(0xFF9FB0C6),
        primary: const Color(0xFF9FB0C6),
        surface: darkSurface,
      ),
      textTheme: Typography.whiteMountainView.apply(
        bodyColor: darkText,
        displayColor: darkText,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        foregroundColor: darkText,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1F242A),
        contentTextStyle: const TextStyle(
          color: Color(0xFFE2E8F0),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFF333D4B), width: 1),
        ),
        elevation: 4,
      ),
    );
  }
}
