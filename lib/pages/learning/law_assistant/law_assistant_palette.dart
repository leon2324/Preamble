part of '../know_law_page.dart';

/// 小法助 Prototype 專用色票。
///
/// 台灣繁體中文教學介紹型註解：
/// 這個檔案只放小法助流程的顏色語意，避免入口頁、整理頁與聊天頁各自硬寫色碼；
/// 未來若 Prototype 色票調整，優先改這裡，再由共用元件同步套用。
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
  // 主題主色：用在機器人 icon、送出按鈕、使用者泡泡等「主要強調」。
  final Color accent;
  // 輔色：用在較弱的 icon/標籤，讓畫面有溫度但不搶戲。
  final Color secondary;
  // 點綴色：只用在極小面積（例如徽章），避免整頁變成金色系。
  final Color highlight;
  final Color primaryText;
  final Color mutedText;
  final Color inverseText;

  static _LawAssistantPalette of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 教學註解：小法助沿用首頁新版的「暖米黃 + 信任綠 + 淡薄荷」方向，
    // 讓使用者從首頁卡片進入後，視覺語言不會突然切回舊版學習頁風格。
    // 深色模式則提升明度與對比，避免主色在暗底上看起來灰掉。
    if (isDark) {
      return const _LawAssistantPalette(
        pageBackground: Color(0xFF0F1216),
        cardSurface: Color(0xFF151A20),
        introSurface: Color(0xFF17202A),
        subtleSurface: Color(0xFF131820),
        chipSurface: Color(0xFF182029),
        softPaper: Color(0xFF211E17),
        softMist: Color(0xFF17202A),
        softIllustration: Color(0xFF202B24),
        border: Color(0xFF2A3340),
        neutralBorder: Color(0xFF2A3340),
        divider: Color(0xFF28313D),
        cardStroke: Color(0xFF2A3340),
        // 深色模式下將主色提亮，確保按鈕/泡泡有足夠對比。
        accent: Color(0xFF9FB0C6),
        secondary: Color(0xFF9EB19A),
        // 深色模式的米金點綴：提高亮度，讓小徽章在暗底上更清楚。
        highlight: Color(0xFFE5CD93),
        primaryText: Color(0xFFF2F4F7),
        mutedText: Color(0xFFA3ABB6),
        inverseText: Color(0xFF0B0F14),
      );
    }

    return const _LawAssistantPalette(
      // 亮色模式：直接承接 Home V2 色票，保留首頁卡片的溫暖與可信感。
      pageBackground: AppColors.background,
      cardSurface: Colors.white,
      introSurface: HomeV2Palette.aiYellow,
      subtleSurface: HomeV2Palette.mint,
      chipSurface: Color(0xFFFFFAEC),
      softPaper: Color(0xFFF3EAD7),
      softMist: Color(0xFFF8F2E8),
      softIllustration: Color(0xFFE7F0DE),
      border: Color(0xFFE4C179),
      neutralBorder: Color(0xFFDDE7E0),
      divider: Color(0xFFEDE4D8),
      cardStroke: Color(0xFFE9DFD2),
      // 主色：首頁新版 trust green，用在主要 CTA、使用者泡泡與小法助 icon。
      accent: HomeV2Palette.trustGreen,
      // 輔色：首頁 AI 卡片的棕金文字色，用在次要說明與 pill。
      secondary: Color(0xFF94610D),
      // 點綴：暖米金，用在 Beta 徽章與角色小標，面積小但能接住首頁氛圍。
      highlight: Color(0xFFE8B95F),
      primaryText: HomeV2Palette.ink,
      mutedText: AppColors.textSecondary,
      inverseText: Colors.white,
    );
  }
}
