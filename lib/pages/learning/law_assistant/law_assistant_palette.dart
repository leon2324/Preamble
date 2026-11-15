part of '../know_law_page.dart';

/// 小法助靜奢雙重編碼專用色票（直接衍生自 `PreambleTokens`，確保淺深色一致）。
class _LawAssistantPalette {
  const _LawAssistantPalette({
    required this.pageBackground,
    required this.cardSurface,
    required this.introSurface,
    required this.subtleSurface,
    required this.chipSurface,
    required this.softPaper,
    required this.softMist,
    required this.softIllustration,
    required this.border,
    required this.neutralBorder,
    required this.divider,
    required this.cardStroke,
    required this.accent,
    required this.secondary,
    required this.highlight,
    required this.primaryText,
    required this.mutedText,
    required this.inverseText,
  });

  final Color pageBackground;
  final Color cardSurface;
  final Color introSurface;
  final Color subtleSurface;
  final Color chipSurface;
  final Color softPaper;
  final Color softMist;
  final Color softIllustration;
  final Color border;
  final Color neutralBorder;
  final Color divider;
  final Color cardStroke;
  final Color accent;
  final Color secondary;
  final Color highlight;
  final Color primaryText;
  final Color mutedText;
  final Color inverseText;

  static _LawAssistantPalette of(BuildContext context) {
    final t = context.tokens;
    return _LawAssistantPalette(
      pageBackground: t.canvas,
      cardSurface: t.surface,
      introSurface: t.surfaceSubtle,
      subtleSurface: t.brandContainer,
      chipSurface: t.surface,
      softPaper: t.surfaceSubtle,
      softMist: t.surfaceSubtle,
      softIllustration: t.brandContainer,
      border: t.borderStrong,
      neutralBorder: t.border,
      divider: t.border,
      cardStroke: t.border,
      accent: t.brandPrimary,
      secondary: t.accentOnBrassContainer,
      highlight: t.accentBrass,
      primaryText: t.textPrimary,
      mutedText: t.textSecondary,
      inverseText: t.brandOnPrimary,
    );
  }
}
