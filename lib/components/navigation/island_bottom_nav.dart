import 'dart:math' as math;
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:preamble/theme/adaptive_layout.dart';
import 'package:preamble/theme/app_colors.dart';

/// App 主殼層底部的島嶼式導覽列。
///
/// 這個元件只負責底部 Nav 的視覺與點擊回呼；分頁順序、目前頁面與是否顯示文字，
/// 仍由外層 AppState / main.dart 決定，避免導覽 UI 與 App 狀態管理混在一起。
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Liquid Glass 霧面半透明底色
    final shellColor = isDark
        ? const Color(0xFF161E28).withValues(alpha: 0.72)
        : const Color(0xFFF7F5F0).withValues(alpha: 0.78);

    final selectedColor =
        isDark ? const Color(0xFFF2F4F7) : AppColors.textPrimary;
    final unselectedColor = selectedColor.withValues(alpha: 0.42);

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
                    // 台灣繁體中文教學註解：懸浮 Nav 的陰影只加深透明度 20%，保留原本 Liquid Glass 的高度、模糊與位移。
                    color:
                        Colors.black.withValues(alpha: isDark ? 0.42 : 0.144),
                    blurRadius: 20,
                    spreadRadius: 1,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(34),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    height: navHeight,
                    decoration: BoxDecoration(
                      color: shellColor,
                      borderRadius: BorderRadius.circular(34),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.12)
                            : Colors.black.withValues(alpha: 0.05),
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
                                padding:
                                    const EdgeInsets.only(top: 6, bottom: 4),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AnimatedScale(
                                      scale: isSelected ? 1.08 : 0.93,
                                      duration:
                                          const Duration(milliseconds: 250),
                                      curve: Curves.easeOutBack,
                                      child: Container(
                                        width: 50,
                                        height: iconBoxHeight,
                                        alignment: Alignment.center,
                                        child: item.label == '小法助'
                                            ? Opacity(
                                                opacity: isSelected ? 1.0 : 0.6,
                                                child: Container(
                                                  width: 25,
                                                  height: 25,
                                                  decoration:
                                                      const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: ClipOval(
                                                    child: Image.asset(
                                                      'assets/images/assistant/law_assistant_home.png',
                                                      fit: BoxFit.cover,
                                                      alignment:
                                                          Alignment.topCenter,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : Icon(
                                                isSelected
                                                    ? item.selectedIcon
                                                    : item.icon,
                                                size: 25,
                                                color: isSelected
                                                    ? selectedColor
                                                    : unselectedColor,
                                              ),
                                      ),
                                    ),
                                    if (showLabels) ...[
                                      SizedBox(height: iconLabelGap),
                                      Text(
                                        item.label,
                                        style: TextStyle(
                                          fontSize: labelFontSize,
                                          height: 1.2,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.w400,
                                          color: selectedColor.withValues(
                                              alpha: isSelected ? 1.0 : 0.7),
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
///
/// 台灣繁體中文教學註解：shell 不能自行重算 Nav 高度，否則字型 fallback、
/// Dynamic Type 換行或 item 寬度改變時，body reservation 就會與實際 Nav 脫節。
/// 這個物件同時提供目前所需高度與 100% 最小浮島高度，讓 shell 只避讓大字級
/// 額外長出的部分，不會把五個頁面的既有底部留白再加一次。
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

  /// 大字級相對於 100% 最小浮島實際增加的高度。
  double get additionalBodyReservation =>
      math.max(0.0, navShellHeight - minimumNavShellHeight);

  /// Nav 外框、Home Indicator safe area 與 shell 外距的完整垂直 footprint。
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
    // 台灣繁體中文教學註解：這是 IslandBottomNav 自己原有的最小高度
    // 契約（有標籤 70pt、無標籤 56pt，加上外層置中殼 6pt），不是從任何
    // 頁面的底部 padding 反推的魔術數字。不得用「不縮放」的 TextScaler
    // 重畫文字取得基準，否則會違反系統 Dynamic Type 的縮放契約。
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
            fontWeight: FontWeight.bold,
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
