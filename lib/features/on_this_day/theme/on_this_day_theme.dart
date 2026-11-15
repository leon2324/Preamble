import 'package:flutter/material.dart';
import 'package:preamble/theme/preamble_tokens.dart';

/// 「那年今日 (OnThisDay)」色彩與排版語意層。
///
/// 已全面橋接至全域 `PreambleTokens` (`context.tokens`)，
/// 同時支援宣紙白日間模式 (`#F8F6F1`) 與深曜石夜間模式 (`#0E1211`)。
class OnThisDayColors {
  static const Color primaryGreen = Color(0xFF18362C);
  static const Color secondaryGreen = Color(0xFF235D46);
  static const Color accentGold = Color(0xFFB5894A);
  static const Color bgCream = Color(0xFFF1EDE4);
  static const Color paperBeige = Color(0xFFF8F6F1);
  static const Color bgPaperLight = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF151C19);
  static const Color textSecondary = Color(0xFF55625C);
  static const Color textMuted = Color(0xFF838F89);

  static const Color borderLight = Color(0xFFE5DFD3);
}

class OnThisDayTextStyles {
  static TextStyle titleSerif(BuildContext context) {
    final t = context.tokens;
    return t.serifTitle(
      weight: FontWeight.w700,
      color: t.textPrimary,
    );
  }

  static TextStyle pageTitle(BuildContext context) {
    final t = context.tokens;
    return t.serifTitle(
      weight: FontWeight.w800,
      color: t.textPrimary,
    );
  }

  static TextStyle cardTitle(BuildContext context) {
    final t = context.tokens;
    return t.sansTitle(
      weight: FontWeight.w700,
      color: t.textPrimary,
    );
  }

  static TextStyle body(BuildContext context) {
    final t = context.tokens;
    return t.sansBody(
      weight: FontWeight.w500,
      color: t.textSecondary,
      height: 1.6,
    );
  }

  static TextStyle caption(BuildContext context) {
    final t = context.tokens;
    return t.sansBody(
      weight: FontWeight.w500,
      color: t.textMuted,
    );
  }
}
