import 'package:flutter/material.dart';
import 'package:preamble/theme/preamble_tokens.dart';

/// 記事頁色票相容層（全面橋接至全域 `PreambleTokens`）。
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

  Color get mutedText => secondaryText;

  static JournalPalette of(BuildContext context) {
    final t = context.tokens;
    return JournalPalette(
      background: t.canvas,
      surface: t.surface,
      border: t.border,
      primaryText: t.textPrimary,
      secondaryText: t.textSecondary,
    );
  }
}
