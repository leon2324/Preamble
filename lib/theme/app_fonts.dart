import 'package:flutter/material.dart';

/// 專案共用字體入口。
///
/// 字體 family 名稱必須和 `pubspec.yaml` 的 `flutter.fonts` 完全一致。
/// 之後若要換字體檔，優先改 `pubspec.yaml` 與這個檔案，頁面端只引用常數，
/// 才不會散落一堆手寫 family 字串，造成日後維護困難。
class AppFonts {
  AppFonts._();

  static const inter = 'Inter';
  static const sansTW = 'SourceHanSansTW';
  static const sansCN = 'SourceHanSansCN';
  static const sansJP = 'SourceHanSansJP';
  static const serifTW = 'SourceHanSerifTW';
  static const serifCN = 'SourceHanSerifCN';
  static const serifJP = 'SourceHanSerifJP';
  static const kai = 'Kai';

  /// App 預設先用 Inter 呈現英文與數字，再依序 fallback 到繁中、日文、簡中。
  /// Preamble 主要服務台灣使用者，所以繁中 TW 必須排在 JP/CN 前面，避免同字異形被日文字形搶走。
  static const defaultFamily = inter;
  static const defaultFallbacks = <String>[
    sansTW,
    sansJP,
    sansCN,
    kai,
    'PingFang TC',
    'Noto Sans TC',
    'sans-serif',
  ];

  /// 明體 fallback 給法律條文、判決摘錄、歷史文本這類需要比較正式語氣的內容使用。
  static const serifFallbacks = <String>[
    serifTW,
    serifJP,
    serifCN,
    kai,
    'Songti TC',
    'STSong',
    'serif',
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
