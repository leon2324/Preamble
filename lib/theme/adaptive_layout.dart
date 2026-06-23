import 'package:flutter/widgets.dart';

/// 把首頁/搜尋頁共用的安全區與內容間距收斂成一份設定。
class HomeSearchLayout {
  const HomeSearchLayout({
    required this.hasLargeTopInset,
    required this.searchBarTopOffset,
    required this.contentTopPadding,
    required this.contentBottomPadding,
    required this.topMaskHeight,
  });

  final bool hasLargeTopInset;
  final double searchBarTopOffset;
  final double contentTopPadding;
  final double contentBottomPadding;
  final double topMaskHeight;
}

/// 針對目前設計稿補上的版面輔助 extension。
///
/// 這裡的數值多半不是通用規則，而是讓首頁、搜尋頁在不同 iPhone
/// 安全區與字級下仍維持接近設計稿比例。
extension AdaptiveLayout on BuildContext {
  double get adaptiveTextScale {
    final scale = MediaQuery.textScalerOf(this).scale(1);
    return scale.clamp(1.0, 1.4);
  }

  double get topSafeInset => MediaQuery.paddingOf(this).top;

  bool get hasLargeTopInset => topSafeInset >= 50;

  double get searchPageContentTopPadding {
    if (hasLargeTopInset) return 132;
    return 86;
  }

  double get pageContentBottomPadding => 148;

  double adaptiveBuffer(double maxExtra) {
    // 字級放大時，用 0~1 的進度平滑增加間距，
    // 比直接塞固定高度更不容易在小螢幕爆版。
    final progress = ((adaptiveTextScale - 1.15) / 0.25).clamp(0.0, 1.0);
    return maxExtra * progress;
  }

  HomeSearchLayout get homeSearchLayout {
    if (hasLargeTopInset) {
      return const HomeSearchLayout(
        hasLargeTopInset: true,
        searchBarTopOffset: 55,
        contentTopPadding: 166,
        contentBottomPadding: 148,
        topMaskHeight: 112,
      );
    }

    return HomeSearchLayout(
      hasLargeTopInset: false,
      searchBarTopOffset: (topSafeInset + 2).clamp(0.0, 34.0),
      contentTopPadding: 112,
      contentBottomPadding: pageContentBottomPadding,
      topMaskHeight: 0,
    );
  }
}
