import 'package:flutter/widgets.dart';

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
        topMaskHeight: 150,
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
