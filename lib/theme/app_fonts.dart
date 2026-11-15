import 'package:flutter/material.dart';

/// 專案共用字體入口。
///
/// 字體 family 名稱必須和 `pubspec.yaml` 的 `flutter.fonts` 完全一致。
/// 之後若要換字體檔，優先改 `pubspec.yaml` 與這個檔案，頁面端只引用常數，
/// 才不會散落一堆手寫 family 字串，造成日後維護困難。
class AppFonts {
  AppFonts._();

  static const nunito = 'Nunito';
  static const openHuninn = 'OpenHuninn';
  static const inter = 'Inter';
  static const sansTW = 'SourceHanSansTW';
  static const sansCN = 'SourceHanSansCN';
  static const sansJP = 'SourceHanSansJP';
  static const serifTW = 'SourceHanSerifTW';
  static const serifCN = 'SourceHanSerifCN';
  static const serifJP = 'SourceHanSerifJP';
  static const kai = 'Kai';

  /// 全站改採圓潤親切的「Nunito + 粉圓體 OpenHuninn」組合，
  /// 讓英文、數字與繁體中文都呈現溫暖、無壓力的生活工具手感。
  static const defaultFamily = nunito;
  static const defaultFallbacks = <String>[
    openHuninn,
    sansTW,
    'PingFang TC',
    'Noto Sans TC',
    sansJP,
    sansCN,
    'sans-serif',
  ];

  /// 條文原文框專用清晰黑體（保留微弱區隔但不使用生硬宋體）。
  static const serifFallbacks = <String>[
    sansTW,
    openHuninn,
    'PingFang TC',
    'Noto Sans TC',
    'sans-serif',
  ];

  /// Flutter 的 TextTheme 不會自動知道我們新增的字體；透過這個 helper 套用，
  /// 就能讓全域文字同時吃到 Inter 與 Source Han fallback。
  static TextTheme applyDefaultFallbacks(
    TextTheme base, {
    required Color bodyColor,
    required Color displayColor,
  }) {
    return base.apply(
      fontFamily: defaultFamily,
      fontFamilyFallback: defaultFallbacks,
      bodyColor: bodyColor,
      displayColor: displayColor,
    );
  }
}
