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
  });

  final int selectedIndex;
  final List<BottomNavItemData> items;
  final ValueChanged<int> onTap;
  final bool showLabels;

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

    final extraHeight = context.adaptiveBuffer(12);
    final labelFontSize = 11 + context.adaptiveBuffer(1.5);
    final iconBoxHeight = 30 + (extraHeight * 0.6);
    final iconLabelGap = (5 - context.adaptiveBuffer(1)).clamp(4.0, 5.0);
    return LayoutBuilder(
      builder: (context, constraints) {
        // 台灣繁體中文教學註解：文字實際會被 Expanded 的單一項目寬度換行，
        // 因此量測時必須使用扣除邊框後的 item 寬度；不能用無限寬、單行的
        // TextPainter 高度，否則 Dynamic Type 在中文三字標籤上會低估所需高度。
        final itemWidth = math.max(
          0.0,
          (constraints.maxWidth - 2) / math.max(items.length, 1),
        );
        final labelHeight = showLabels
            ? _maxLabelHeight(
                context,
                items: items,
                fontSize: labelFontSize,
                maxWidth: itemWidth,
              )
            : 0.0;
        final contentHeight = 6 +
            iconBoxHeight +
            (showLabels ? iconLabelGap + labelHeight : 0) +
            4;
        final navHeight = math.max(
          (showLabels ? 70 : 56) + extraHeight,
          contentHeight + 2,
        );
        final navShellHeight = navHeight + 6;

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

  double _maxLabelHeight(
    BuildContext context, {
    required List<BottomNavItemData> items,
    required double fontSize,
    required double maxWidth,
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
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
      )..layout(maxWidth: maxWidth);
      maxHeight = math.max(maxHeight, painter.height);
      painter.dispose();
    }
    return maxHeight;
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
