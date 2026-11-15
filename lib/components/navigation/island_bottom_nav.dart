import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:preamble/theme/adaptive_layout.dart';
import 'package:preamble/theme/preamble_tokens.dart';

/// App 主殼層底部的靜奢島嶼式導覽列 (Quiet Luxury Island Navigation)。
///
/// 全面採用一致的雙態線條／填色圖示與深松墨綠微膠囊選取態，
/// 移除過往突兀的圓形卡通插畫頭貼，確保全站 5 大分頁具備國際級精品視覺語言。
class IslandBottomNav extends StatelessWidget {
  const IslandBottomNav({
    super.key,
    required this.selectedIndex,
    required this.items,
    required this.onTap,
    required this.showLabels,
    this.layoutMetrics,
  });

  final int selectedIndex;
  final List<BottomNavItemData> items;
  final ValueChanged<int> onTap;
  final bool showLabels;
  final IslandBottomNavLayoutMetrics? layoutMetrics;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    final shellColor = t.isDark
        ? const Color(0xFF151C1A).withValues(alpha: 0.84)
        : const Color(0xFFFCFBF8).withValues(alpha: 0.86);

    final selectedColor = t.brandPrimary;
    final unselectedColor = t.textMuted;

    return LayoutBuilder(
      builder: (context, constraints) {
        final metrics = layoutMetrics ??
            IslandBottomNavLayoutMetrics.compute(
              context,
              availableWidth: constraints.maxWidth,
              items: items,
              showLabels: showLabels,
            );
        final iconBoxHeight = metrics.iconBoxHeight;
        final iconLabelGap = metrics.iconLabelGap;
        final labelFontSize = metrics.labelFontSize;
        final navHeight = metrics.navHeight;
        final navShellHeight = metrics.navShellHeight;

        return SizedBox(
          height: navShellHeight,
          child: Center(
            child: Container(
              height: navHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(34),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: t.isDark ? 0.44 : 0.09),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(34),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                  child: Container(
                    height: navHeight,
                    decoration: BoxDecoration(
                      color: shellColor,
                      borderRadius: BorderRadius.circular(34),
                      border: Border.all(
                        color: t.isDark
                            ? Colors.white.withValues(alpha: 0.10)
                            : t.border.withValues(alpha: 0.85),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: List.generate(items.length, (index) {
                        final item = items[index];
                        final isSelected = index == selectedIndex;

                        return Expanded(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                onTap(index);
                              },
                              splashFactory: NoSplash.splashFactory,
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 6, bottom: 4),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 220),
                                      curve: Curves.easeOutCubic,
                                      width: 48,
                                      height: iconBoxHeight,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? t.brandContainer
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Icon(
                                        isSelected ? item.selectedIcon : item.icon,
                                        size: 22,
                                        color: isSelected
                                            ? selectedColor
                                            : unselectedColor,
                                      ),
                                    ),
                                    if (showLabels) ...[
                                      SizedBox(height: iconLabelGap),
                                      Text(
                                        item.label,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: labelFontSize,
                                          height: 1.2,
                                          fontWeight: isSelected
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          color: isSelected
                                              ? selectedColor
                                              : t.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class BottomNavItemData {
  const BottomNavItemData({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

/// IslandBottomNav 與 App shell 共用的內容導向尺寸契約。
class IslandBottomNavLayoutMetrics {
  const IslandBottomNavLayoutMetrics._({
    required this.availableWidth,
    required this.itemWidth,
    required this.labelFontSize,
    required this.labelHeight,
    required this.iconBoxHeight,
    required this.iconLabelGap,
    required this.contentHeight,
    required this.navHeight,
    required this.navShellHeight,
    required this.minimumNavShellHeight,
    required this.safeBottom,
    required this.bottomOffset,
  });

  final double availableWidth;
  final double itemWidth;
  final double labelFontSize;
  final double labelHeight;
  final double iconBoxHeight;
  final double iconLabelGap;
  final double contentHeight;
  final double navHeight;
  final double navShellHeight;
  final double minimumNavShellHeight;
  final double safeBottom;
  final double bottomOffset;

  double get additionalBodyReservation =>
      math.max(0.0, navShellHeight - minimumNavShellHeight);

  double get totalFootprint => navShellHeight + safeBottom + bottomOffset;

  static IslandBottomNavLayoutMetrics compute(
    BuildContext context, {
    required double availableWidth,
    required List<BottomNavItemData> items,
    required bool showLabels,
    double bottomOffset = 0,
  }) {
    final safeWidth = math.max(0.0, availableWidth);
    final actual = _calculate(
      items: items,
      showLabels: showLabels,
      availableWidth: safeWidth,
      textScaler: MediaQuery.textScalerOf(context),
      textDirection: Directionality.of(context),
      adaptiveScale: context.adaptiveTextScale,
    );
    final minimumNavShellHeight = (showLabels ? 70.0 : 56.0) + 6;

    return IslandBottomNavLayoutMetrics._(
      availableWidth: safeWidth,
      itemWidth: actual.itemWidth,
      labelFontSize: actual.labelFontSize,
      labelHeight: actual.labelHeight,
      iconBoxHeight: actual.iconBoxHeight,
      iconLabelGap: actual.iconLabelGap,
      contentHeight: actual.contentHeight,
      navHeight: actual.navHeight,
      navShellHeight: actual.navShellHeight,
      minimumNavShellHeight: minimumNavShellHeight,
      safeBottom: MediaQuery.paddingOf(context).bottom,
      bottomOffset: bottomOffset,
    );
  }

  static _IslandBottomNavDimensions _calculate({
    required List<BottomNavItemData> items,
    required bool showLabels,
    required double availableWidth,
    required TextScaler textScaler,
    required TextDirection textDirection,
    required double adaptiveScale,
  }) {
    final progress = ((adaptiveScale - 1.15) / 0.25).clamp(0.0, 1.0);
    final extraHeight = 12 * progress;
    final labelFontSize = 11 + (1.5 * progress);
    final iconBoxHeight = 30 + (extraHeight * 0.6);
    final iconLabelGap = (5 - progress).clamp(4.0, 5.0);
    final itemWidth = math.max(
      0.0,
      (availableWidth - 2) / math.max(items.length, 1),
    );
    final labelHeight = showLabels
        ? _maxLabelHeight(
            items: items,
            fontSize: labelFontSize,
            maxWidth: itemWidth,
            textScaler: textScaler,
            textDirection: textDirection,
          )
        : 0.0;
    final contentHeight =
        6 + iconBoxHeight + (showLabels ? iconLabelGap + labelHeight : 0) + 4;
    final navHeight = math.max(
      (showLabels ? 70 : 56) + extraHeight,
      contentHeight + 2,
    );

    return _IslandBottomNavDimensions(
      itemWidth: itemWidth,
      labelFontSize: labelFontSize,
      labelHeight: labelHeight,
      iconBoxHeight: iconBoxHeight,
      iconLabelGap: iconLabelGap,
      contentHeight: contentHeight,
      navHeight: navHeight,
      navShellHeight: navHeight + 6,
    );
  }

  static double _maxLabelHeight({
    required List<BottomNavItemData> items,
    required double fontSize,
    required double maxWidth,
    required TextScaler textScaler,
    required TextDirection textDirection,
  }) {
    var maxHeight = 0.0;
    for (final item in items) {
      final painter = TextPainter(
        text: TextSpan(
          text: item.label,
          style: TextStyle(
            fontSize: fontSize,
            height: 1.2,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: textDirection,
        textScaler: textScaler,
      )..layout(maxWidth: maxWidth);
      maxHeight = math.max(maxHeight, painter.height);
      painter.dispose();
    }
    return maxHeight;
  }
}

class _IslandBottomNavDimensions {
  const _IslandBottomNavDimensions({
    required this.itemWidth,
    required this.labelFontSize,
    required this.labelHeight,
    required this.iconBoxHeight,
    required this.iconLabelGap,
    required this.contentHeight,
    required this.navHeight,
    required this.navShellHeight,
  });

  final double itemWidth;
  final double labelFontSize;
  final double labelHeight;
  final double iconBoxHeight;
  final double iconLabelGap;
  final double contentHeight;
  final double navHeight;
  final double navShellHeight;
}
