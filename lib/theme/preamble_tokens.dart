import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/theme/app_fonts.dart';

/// 《緒言 Preamble》全域「靜奢律政編輯風 × 雙重編碼」語意設計系統 (Design Tokens)。
///
/// 統一收斂全站色彩、材質邊框、圓角規範與「字體語氣雙重編碼」：
/// - 宋體 (`SourceHanSerifTW`)：承載法定條文、判決原文、歷史案卷與刊頭識別（權威語氣）。
/// - 黑體 (`Inter` + `SourceHanSansTW`)：承載現代行動介面、白話解析與數據指標（行動語氣）。
@immutable
class PreambleTokens extends ThemeExtension<PreambleTokens> {
  const PreambleTokens({
    required this.isDark,
    required this.canvas,
    required this.surface,
    required this.surfaceElevated,
    required this.surfaceSubtle,
    required this.surfaceMuted,
    required this.border,
    required this.borderStrong,
    required this.brandPrimary,
    required this.brandPrimaryStrong,
    required this.brandOnPrimary,
    required this.brandContainer,
    required this.brandOnContainer,
    required this.accentBrass,
    required this.accentBrassContainer,
    required this.accentOnBrassContainer,
    required this.semanticUrgent,
    required this.semanticUrgentContainer,
    required this.semanticSuccess,
    required this.semanticSuccessContainer,
    required this.semanticInfo,
    required this.semanticInfoContainer,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.shadowAmbient,
  });

  final bool isDark;

  /// 全站畫布底色（Light: 溫潤宣紙白 #F8F6F1 / Dark: 深曜石墨黑 #0E1211）
  final Color canvas;

  /// 主要卡片表面（Light: 純淨象牙白 #FFFFFF / Dark: 墨玉深灰 #161D1B）
  final Color surface;

  /// 浮起彈窗或懸浮層表面
  final Color surfaceElevated;

  /// 微凹輸入艙、次級對照區塊底色
  final Color surfaceSubtle;

  /// 停用或低調標籤底色
  final Color surfaceMuted;

  /// 標準 1px 結構細邊框
  final Color border;

  /// 強調態或聚焦邊框
  final Color borderStrong;

  /// 品牌核心色（Light: 深松墨綠 #18362C / Dark: 松霧青綠 #7AB39E）
  final Color brandPrimary;

  /// 深底品牌色（供雜誌頭版封面或深色膠囊使用，永遠保持沉穩深松綠）
  final Color brandPrimaryStrong;

  /// 品牌主色上的文字顏色
  final Color brandOnPrimary;

  /// 品牌淺底容器色
  final Color brandContainer;

  /// 品牌淺底容器上的文字色
  final Color brandOnContainer;

  /// 典藏古銅金點綴（PRO 徽章、連勝印記、掃描解讀、重點標記）
  final Color accentBrass;

  /// 古銅金淺底容器
  final Color accentBrassContainer;

  /// 古銅金淺底容器上的文字色
  final Color accentOnBrassContainer;

  /// 法定時效緊急／罰則警示色（朱砂印記紅）
  final Color semanticUrgent;
  final Color semanticUrgentContainer;

  /// 通關／已完成／合法檢核通過色
  final Color semanticSuccess;
  final Color semanticSuccessContainer;

  /// 法規異動／中立對照輔助色（岩青灰藍）
  final Color semanticInfo;
  final Color semanticInfoContainer;

  /// 動態語意文字階層（確保淺深色皆達 WCAG AA+ 對比度）
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  /// 環境微光影
  final Color shadowAmbient;

  static const light = PreambleTokens(
    isDark: false,
    canvas: Color(0xFFFAF8F4),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFFFFFFF),
    surfaceSubtle: Color(0xFFF3F1EC),
    surfaceMuted: Color(0xFFEAE6DD),
    border: Color(0xFFECE8DF),
    borderStrong: Color(0xFFD8D1C4),
    brandPrimary: Color(0xFF538A74),
    brandPrimaryStrong: Color(0xFF447561),
    brandOnPrimary: Color(0xFFFFFFFF),
    brandContainer: Color(0xFFE6F2EC),
    brandOnContainer: Color(0xFF2D5847),
    accentBrass: Color(0xFFDFA065),
    accentBrassContainer: Color(0xFFFDF2E6),
    accentOnBrassContainer: Color(0xFF8C5828),
    semanticUrgent: Color(0xFFDF7366),
    semanticUrgentContainer: Color(0xFFFDF0EE),
    semanticSuccess: Color(0xFF4B9B7B),
    semanticSuccessContainer: Color(0xFFE8F5EF),
    semanticInfo: Color(0xFF6E95B8),
    semanticInfoContainer: Color(0xFFEDF3F8),
    textPrimary: Color(0xFF2C3531),
    textSecondary: Color(0xFF66726D),
    textMuted: Color(0xFF949F9A),
    shadowAmbient: Color(0x0D2C3531),
  );

  static const dark = PreambleTokens(
    isDark: true,
    canvas: Color(0xFF151A18),
    surface: Color(0xFF1E2522),
    surfaceElevated: Color(0xFF262F2B),
    surfaceSubtle: Color(0xFF242C29),
    surfaceMuted: Color(0xFF2D3733),
    border: Color(0xFF2E3934),
    borderStrong: Color(0xFF3E4D46),
    brandPrimary: Color(0xFF85BFA7),
    brandPrimaryStrong: Color(0xFF3B6856),
    brandOnPrimary: Color(0xFF10201A),
    brandContainer: Color(0xFF233A31),
    brandOnContainer: Color(0xFFD6EFE3),
    accentBrass: Color(0xFFE8B888),
    accentBrassContainer: Color(0xFF362B20),
    accentOnBrassContainer: Color(0xFFF5D8B8),
    semanticUrgent: Color(0xFFEB8E83),
    semanticUrgentContainer: Color(0xFF382220),
    semanticSuccess: Color(0xFF79C2A4),
    semanticSuccessContainer: Color(0xFF1E352B),
    semanticInfo: Color(0xFF8FB4D4),
    semanticInfoContainer: Color(0xFF1F2B36),
    textPrimary: Color(0xFFF0F3F1),
    textSecondary: Color(0xFFAAB6B0),
    textMuted: Color(0xFF7B8882),
    shadowAmbient: Color(0x33000000),
  );

  /// 溫柔日系粉彩卡片裝飾（大圓角 + 輕柔陰影 + 淡化硬邊框）
  BoxDecoration cardDecoration({
    double? radius,
    Color? fill,
    Color? borderColor,
    bool elevated = true,
  }) {
    final r = radius ?? 22.r;
    return BoxDecoration(
      color: fill ?? surface,
      borderRadius: BorderRadius.circular(r),
      border: borderColor != null
          ? Border.all(color: borderColor, width: 1.2)
          : (isDark ? Border.all(color: border, width: 1) : null),
      boxShadow: elevated
          ? [
              BoxShadow(
                color: shadowAmbient,
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ]
          : null,
    );
  }

  /// 次級內嵌模組裝飾（柔和色塊留白，拿掉硬線條框）
  BoxDecoration subtleBoxDecoration({
    double? radius,
    Color? fill,
    Color? borderColor,
  }) {
    final r = radius ?? 16.r;
    return BoxDecoration(
      color: fill ?? surfaceSubtle,
      borderRadius: BorderRadius.circular(r),
      border: borderColor != null ? Border.all(color: borderColor, width: 1) : null,
    );
  }

  // ---------------------------------------------------------------------------
  // 圓潤親切字體階層 (Friendly Rounded Typography)
  // ---------------------------------------------------------------------------

  /// 親切圓體主標題（全站統一圓潤好讀，拿掉生硬宋體）
  TextStyle serifTitle({
    double? size,
    FontWeight weight = FontWeight.w700,
    Color? color,
    double height = 1.38,
    double letterSpacing = 0.1,
  }) {
    return TextStyle(
      fontFamily: AppFonts.defaultFamily,
      fontFamilyFallback: AppFonts.defaultFallbacks,
      fontSize: size ?? 17.sp,
      fontWeight: weight,
      color: color ?? textPrimary,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  /// 清晰黑體／圓體內文（法條引文或長文說明）
  TextStyle serifBody({
    double? size,
    FontWeight weight = FontWeight.w500,
    Color? color,
    double height = 1.7,
  }) {
    return TextStyle(
      fontFamily: AppFonts.defaultFamily,
      fontFamilyFallback: AppFonts.serifFallbacks,
      fontSize: size ?? 14.5.sp,
      fontWeight: weight,
      color: color ?? textPrimary,
      height: height,
    );
  }

  /// 現代圓體標題（功能與介面區塊）
  TextStyle sansTitle({
    double? size,
    FontWeight weight = FontWeight.w700,
    Color? color,
    double height = 1.32,
  }) {
    return TextStyle(
      fontFamily: AppFonts.defaultFamily,
      fontFamilyFallback: AppFonts.defaultFallbacks,
      fontSize: size ?? 15.5.sp,
      fontWeight: weight,
      color: color ?? textPrimary,
      height: height,
    );
  }

  /// 現代黑體內文（白話說明、摘要、清單）
  TextStyle sansBody({
    double? size,
    FontWeight weight = FontWeight.w500,
    Color? color,
    double height = 1.5,
  }) {
    return TextStyle(
      fontFamily: AppFonts.defaultFamily,
      fontFamilyFallback: AppFonts.defaultFallbacks,
      fontSize: size ?? 13.sp,
      fontWeight: weight,
      color: color ?? textSecondary,
      height: height,
    );
  }

  /// 等寬數字指標（金額、時效天數、條號、百分比 — 確保空間對齊）
  TextStyle tabularMetric({
    double? size,
    FontWeight weight = FontWeight.w700,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: AppFonts.defaultFamily,
      fontFamilyFallback: AppFonts.defaultFallbacks,
      fontSize: size ?? 13.sp,
      fontWeight: weight,
      color: color ?? textPrimary,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  @override
  PreambleTokens copyWith({
    bool? isDark,
    Color? canvas,
    Color? surface,
    Color? surfaceElevated,
    Color? surfaceSubtle,
    Color? surfaceMuted,
    Color? border,
    Color? borderStrong,
    Color? brandPrimary,
    Color? brandPrimaryStrong,
    Color? brandOnPrimary,
    Color? brandContainer,
    Color? brandOnContainer,
    Color? accentBrass,
    Color? accentBrassContainer,
    Color? accentOnBrassContainer,
    Color? semanticUrgent,
    Color? semanticUrgentContainer,
    Color? semanticSuccess,
    Color? semanticSuccessContainer,
    Color? semanticInfo,
    Color? semanticInfoContainer,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? shadowAmbient,
  }) {
    return PreambleTokens(
      isDark: isDark ?? this.isDark,
      canvas: canvas ?? this.canvas,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      surfaceSubtle: surfaceSubtle ?? this.surfaceSubtle,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      brandPrimary: brandPrimary ?? this.brandPrimary,
      brandPrimaryStrong: brandPrimaryStrong ?? this.brandPrimaryStrong,
      brandOnPrimary: brandOnPrimary ?? this.brandOnPrimary,
      brandContainer: brandContainer ?? this.brandContainer,
      brandOnContainer: brandOnContainer ?? this.brandOnContainer,
      accentBrass: accentBrass ?? this.accentBrass,
      accentBrassContainer: accentBrassContainer ?? this.accentBrassContainer,
      accentOnBrassContainer:
          accentOnBrassContainer ?? this.accentOnBrassContainer,
      semanticUrgent: semanticUrgent ?? this.semanticUrgent,
      semanticUrgentContainer:
          semanticUrgentContainer ?? this.semanticUrgentContainer,
      semanticSuccess: semanticSuccess ?? this.semanticSuccess,
      semanticSuccessContainer:
          semanticSuccessContainer ?? this.semanticSuccessContainer,
      semanticInfo: semanticInfo ?? this.semanticInfo,
      semanticInfoContainer:
          semanticInfoContainer ?? this.semanticInfoContainer,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      shadowAmbient: shadowAmbient ?? this.shadowAmbient,
    );
  }

  @override
  PreambleTokens lerp(ThemeExtension<PreambleTokens>? other, double t) {
    if (other is! PreambleTokens) return this;
    return PreambleTokens(
      isDark: t < 0.5 ? isDark : other.isDark,
      canvas: Color.lerp(canvas, other.canvas, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      surfaceSubtle: Color.lerp(surfaceSubtle, other.surfaceSubtle, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      brandPrimary: Color.lerp(brandPrimary, other.brandPrimary, t)!,
      brandPrimaryStrong:
          Color.lerp(brandPrimaryStrong, other.brandPrimaryStrong, t)!,
      brandOnPrimary: Color.lerp(brandOnPrimary, other.brandOnPrimary, t)!,
      brandContainer: Color.lerp(brandContainer, other.brandContainer, t)!,
      brandOnContainer:
          Color.lerp(brandOnContainer, other.brandOnContainer, t)!,
      accentBrass: Color.lerp(accentBrass, other.accentBrass, t)!,
      accentBrassContainer:
          Color.lerp(accentBrassContainer, other.accentBrassContainer, t)!,
      accentOnBrassContainer:
          Color.lerp(accentOnBrassContainer, other.accentOnBrassContainer, t)!,
      semanticUrgent: Color.lerp(semanticUrgent, other.semanticUrgent, t)!,
      semanticUrgentContainer: Color.lerp(
          semanticUrgentContainer, other.semanticUrgentContainer, t)!,
      semanticSuccess: Color.lerp(semanticSuccess, other.semanticSuccess, t)!,
      semanticSuccessContainer: Color.lerp(
          semanticSuccessContainer, other.semanticSuccessContainer, t)!,
      semanticInfo: Color.lerp(semanticInfo, other.semanticInfo, t)!,
      semanticInfoContainer:
          Color.lerp(semanticInfoContainer, other.semanticInfoContainer, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      shadowAmbient: Color.lerp(shadowAmbient, other.shadowAmbient, t)!,
    );
  }
}

extension PreambleTokensContext on BuildContext {
  /// 取得當前主題對應的靜奢語意 Token；若未掛載則依系統明暗自動回退。
  PreambleTokens get tokens {
    final theme = Theme.of(this);
    return theme.extension<PreambleTokens>() ??
        (theme.brightness == Brightness.dark
            ? PreambleTokens.dark
            : PreambleTokens.light);
  }
}
