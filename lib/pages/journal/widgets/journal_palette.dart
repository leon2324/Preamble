import 'package:flutter/material.dart';
import 'package:lawapp/theme/app_colors.dart';

/// 記事頁主頁色票。
///
/// 主頁 prototype 先使用獨立色票，避免把「案件資料館」的策展視覺直接寫進全站主題；
/// 等記事頁定版後，再評估哪些顏色可以回收到 `AppColors` 共用。
class JournalPalette {
  const JournalPalette({
    required this.background,
    required this.surface,
    required this.border,
    required this.primaryText,
    required this.secondaryText,
  });

  final Color background;
  final Color surface;
  final Color border;
  final Color primaryText;
  final Color secondaryText;

  /// 有些記事頁舊版元件使用 mutedText 命名；先保留這個相容 getter，
  /// 讓新舊元件都能吃同一份色票，之後統一命名時再一起清掉。
  Color get mutedText => secondaryText;

  static JournalPalette of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return const JournalPalette(
        background: Color(0xFF0F1216),
        surface: Color(0xFF171C22),
        border: Color(0xFF2B3441),
        primaryText: Color(0xFFF2F4F7),
        secondaryText: Color(0xFFA3ABB6),
      );
    }

    return const JournalPalette(
      background: AppColors.background,
      surface: Colors.white,
      border: AppColors.border,
      primaryText: AppColors.textPrimary,
      secondaryText: AppColors.textSecondary,
    );
  }
}
