import 'package:flutter/material.dart';

class OnThisDayColors {
  static const Color primaryGreen = Color(0xFF123D36);
  static const Color secondaryGreen = Color(0xFF2F5D50);
  static const Color accentGold = Color(0xFFC8A46B);
  static const Color bgCream = Color(0xFFF6FEF2);
  static const Color paperBeige = Color(0xFFEBE1D3);
  static const Color bgPaperLight = Color(0xFFFFFDF9);

  static const Color textPrimary = Color(0xFF3A3A3A);
  static const Color textSecondary = Color(0xFF5F5548);
  static const Color textMuted = Color(0xFF8C7B6B);

  static const Color borderLight = Color(0xFFE4CFA7);
}

class OnThisDayTextStyles {
  static TextStyle titleSerif(BuildContext context) {
    return const TextStyle(
      fontFamily: 'Songti TC',
      fontFamilyFallback: ['Songti SC', 'STSong', 'BiauKai', 'serif'],
      fontWeight: FontWeight.bold,
      color: OnThisDayColors.primaryGreen,
    );
  }

  static TextStyle pageTitle(BuildContext context) {
    return const TextStyle(
      fontFamily: 'Songti TC',
      fontFamilyFallback: ['Songti SC', 'BiauKai', 'serif'],
      fontWeight: FontWeight.w900,
      color: OnThisDayColors.primaryGreen,
    );
  }

  static TextStyle cardTitle(BuildContext context) {
    return const TextStyle(
      fontWeight: FontWeight.w900,
      color: OnThisDayColors.primaryGreen,
    );
  }

  static TextStyle body(BuildContext context) {
    return const TextStyle(
      fontWeight: FontWeight.w600,
      color: OnThisDayColors.textSecondary,
      height: 1.55,
    );
  }

  static TextStyle caption(BuildContext context) {
    return const TextStyle(
      fontWeight: FontWeight.w500,
      color: OnThisDayColors.textMuted,
    );
  }
}
