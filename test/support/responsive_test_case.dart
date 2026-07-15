import 'package:flutter/material.dart';

/// 響應式稽核使用的單一裝置與環境組合。
///
/// 台灣繁體中文教學註解：集中管理矩陣可避免各測試自行調整尺寸，導致
/// 同一個「120% 字體」在不同測試其實代表不同的畫面條件。
class ResponsiveTestCase {
  const ResponsiveTestCase({
    required this.id,
    required this.viewport,
    required this.textScale,
    this.locale = const Locale('zh', 'TW'),
    this.safeArea = ResponsiveSafeArea.none,
    this.keyboardInset = 0,
  });

  final String id;
  final Size viewport;
  final double textScale;
  final Locale locale;
  final ResponsiveSafeArea safeArea;
  final double keyboardInset;

  bool get isLandscape => viewport.width > viewport.height;
  String get orientation => isLandscape ? 'landscape' : 'portrait';

  /// 模擬 iOS 在鍵盤開啟時的 `MediaQuery.padding`。
  ///
  /// 台灣繁體中文教學註解：`padding` 不能同時保留完整的底部安全區與
  /// 鍵盤高度；Flutter 會從 `viewPadding` 扣除 `viewInsets`，避免底部元件
  /// 在測試裡被重複往上推。
  EdgeInsets get padding => EdgeInsets.only(
        top: safeArea.padding.top,
        bottom:
            (safeArea.padding.bottom - keyboardInset).clamp(0, double.infinity),
      );
  EdgeInsets get viewPadding => safeArea.padding;
  EdgeInsets get viewInsets => EdgeInsets.only(bottom: keyboardInset);

  String get description =>
      '${viewport.width.toInt()}x${viewport.height.toInt()} '
      '$orientation text=$textScale safe=${safeArea.id} '
      'keyboard=${keyboardInset.toInt()} locale=${locale.toLanguageTag()}';
}

enum ResponsiveSafeArea {
  none('none', EdgeInsets.zero),
  iphone('iphone', EdgeInsets.only(top: 59, bottom: 34));

  const ResponsiveSafeArea(this.id, this.padding);

  final String id;
  final EdgeInsets padding;
}

/// 所有自動化頁面都會跑的快速矩陣。
const responsiveFastMatrix = <ResponsiveTestCase>[
  ResponsiveTestCase(
    id: 'compact-normal',
    viewport: Size(320, 568),
    textScale: 1,
  ),
  ResponsiveTestCase(
    id: 'compact-large',
    viewport: Size(320, 568),
    textScale: 1.4,
    safeArea: ResponsiveSafeArea.iphone,
  ),
  ResponsiveTestCase(
    id: 'phone-normal',
    viewport: Size(393, 852),
    textScale: 1,
    safeArea: ResponsiveSafeArea.iphone,
  ),
  ResponsiveTestCase(
    id: 'phone-200',
    viewport: Size(393, 852),
    textScale: 2,
    safeArea: ResponsiveSafeArea.iphone,
  ),
  ResponsiveTestCase(
    id: 'landscape-large',
    viewport: Size(852, 393),
    textScale: 1.4,
    safeArea: ResponsiveSafeArea.iphone,
  ),
];

/// 所有已自動化頁面都必須通過的發布前 P0 防線。
///
/// 台灣繁體中文教學註解：此矩陣只放一般字體與 120% 字體的常見 iPhone
/// 尺寸。這裡不接受 known finding，任何版面錯誤或主要操作消失都代表新
/// 的發布風險。
const responsiveP0StrictMatrix = <ResponsiveTestCase>[
  ResponsiveTestCase(
    id: 'p0-320-100',
    viewport: Size(320, 568),
    textScale: 1,
  ),
  ResponsiveTestCase(
    id: 'p0-393-100',
    viewport: Size(393, 852),
    textScale: 1,
    safeArea: ResponsiveSafeArea.iphone,
  ),
  ResponsiveTestCase(
    id: 'p0-393-120',
    viewport: Size(393, 852),
    textScale: 1.2,
    safeArea: ResponsiveSafeArea.iphone,
  ),
  ResponsiveTestCase(
    id: 'p0-430-120',
    viewport: Size(430, 932),
    textScale: 1.2,
    safeArea: ResponsiveSafeArea.iphone,
  ),
];

/// 高風險共用元件與主要流程採用的深度矩陣。
const responsiveDeepMatrix = <ResponsiveTestCase>[
  ResponsiveTestCase(
    id: '320-80',
    viewport: Size(320, 568),
    textScale: 0.8,
  ),
  ResponsiveTestCase(
    id: '360-120',
    viewport: Size(360, 640),
    textScale: 1.2,
    safeArea: ResponsiveSafeArea.iphone,
  ),
  ResponsiveTestCase(
    id: '375-140',
    viewport: Size(375, 812),
    textScale: 1.4,
    safeArea: ResponsiveSafeArea.iphone,
  ),
  ResponsiveTestCase(
    id: '393-160',
    viewport: Size(393, 852),
    textScale: 1.6,
    safeArea: ResponsiveSafeArea.iphone,
  ),
  ResponsiveTestCase(
    id: '430-200',
    viewport: Size(430, 932),
    textScale: 2,
    safeArea: ResponsiveSafeArea.iphone,
  ),
  ResponsiveTestCase(
    id: '568x320-140',
    viewport: Size(568, 320),
    textScale: 1.4,
  ),
  ResponsiveTestCase(
    id: '640x360-120',
    viewport: Size(640, 360),
    textScale: 1.2,
  ),
  ResponsiveTestCase(
    id: '812x375-100-en',
    viewport: Size(812, 375),
    textScale: 1,
    locale: Locale('en', 'US'),
  ),
  ResponsiveTestCase(
    id: '932x430-140',
    viewport: Size(932, 430),
    textScale: 1.4,
  ),
];

/// 這組壓力矩陣不要求維持原排列，但禁止 crash、overflow 或主操作消失。
const responsiveExtremeMatrix = <ResponsiveTestCase>[
  ResponsiveTestCase(
    id: '320-200',
    viewport: Size(320, 568),
    textScale: 2,
    safeArea: ResponsiveSafeArea.iphone,
  ),
  ResponsiveTestCase(
    id: '320-300',
    viewport: Size(320, 568),
    textScale: 3,
    safeArea: ResponsiveSafeArea.iphone,
  ),
  ResponsiveTestCase(
    id: '393-300',
    viewport: Size(393, 852),
    textScale: 3,
    safeArea: ResponsiveSafeArea.iphone,
  ),
  ResponsiveTestCase(
    id: '568x320-200',
    viewport: Size(568, 320),
    textScale: 2,
  ),
  ResponsiveTestCase(
    id: 'keyboard-300',
    viewport: Size(393, 852),
    textScale: 1.4,
    safeArea: ResponsiveSafeArea.iphone,
    keyboardInset: 300,
  ),
  ResponsiveTestCase(
    id: 'keyboard-400',
    viewport: Size(393, 852),
    textScale: 1.4,
    safeArea: ResponsiveSafeArea.iphone,
    keyboardInset: 400,
  ),
];
