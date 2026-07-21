import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/components/home/home_content.dart';
import 'package:preamble/components/home/home_section_title.dart';
import 'package:preamble/theme/adaptive_layout.dart';
import 'package:preamble/theme/app_colors.dart';

/// 首頁「今日新聞」橫向卡片區塊。
class HomeNewsSection extends StatelessWidget {
  const HomeNewsSection({
    super.key,
    required this.items,
    this.onMoreTap,
    this.onItemTap,
    this.showHeader = true,
  });

  static const double _itemGap = 14;

  final List<HomeNewsItem> items;
  final VoidCallback? onMoreTap;
  final ValueChanged<HomeNewsItem>? onItemTap;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    final extraSpace = context.adaptiveBuffer(22);
    final cardWidth = 164.w + extraSpace;
    final mediaHeight = 92.h + context.adaptiveBuffer(10);
    final cardHeight = _NewsCardLayoutMetrics.compute(
      context: context,
      items: items,
      cardWidth: cardWidth,
      mediaHeight: mediaHeight,
    ).height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader) ...[
          _SectionHeader(
            title: '今日新聞',
            onMoreTap: onMoreTap,
          ),
          SizedBox(height: 15.h),
        ],
        SizedBox(
          height: cardHeight,
          child: ListView.separated(
            clipBehavior: Clip.none,
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => SizedBox(width: _itemGap.w),
            itemBuilder: (context, index) => _NewsCard(
              item: items[index],
              width: cardWidth,
              mediaHeight: mediaHeight,
              onTap: onItemTap == null ? null : () => onItemTap!(items[index]),
            ),
          ),
        ),
      ],
    );
  }
}

/// 新聞輪播需要 bounded height，這份純量測契約讓外層 ListView 與卡片文字
/// 使用同一個內容需求；不依裝置方向或固定文字倍率猜測高度。
class _NewsCardLayoutMetrics {
  const _NewsCardLayoutMetrics({required this.height});

  final double height;

  static _NewsCardLayoutMetrics compute({
    required BuildContext context,
    required List<HomeNewsItem> items,
    required double cardWidth,
    required double mediaHeight,
  }) {
    final textWidth = (cardWidth - 14.w - 12.w).clamp(1.0, double.infinity);
    final textStyle = TextStyle(
      fontSize: 15.sp,
      height: 1.05,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
    );
    final textScaler = MediaQuery.textScalerOf(context);
    var tallestTitle = 0.0;
    for (final item in items) {
      final painter = TextPainter(
        text: TextSpan(text: item.title, style: textStyle),
        textScaler: textScaler,
        textDirection: Directionality.of(context),
      )..layout(maxWidth: textWidth);
      tallestTitle =
          tallestTitle < painter.height ? painter.height : tallestTitle;
    }

    // 既有正常字級卡片高度保留為下限；只有真實標題高度超過時才擴張。
    final contentHeight = mediaHeight + 2.h + 8.w + tallestTitle + 5.h + 13.h;
    return _NewsCardLayoutMetrics(
        height: (mediaHeight + 74.h) < contentHeight
            ? contentHeight
            : mediaHeight + 74.h);
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.onMoreTap,
  });

  final String title;
  final VoidCallback? onMoreTap;

  @override
  Widget build(BuildContext context) {
    return HomeSectionTitle(
      title: title,
      onTap: onMoreTap,
    );
  }
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({
    required this.item,
    required this.width,
    required this.mediaHeight,
    this.onTap,
  });

  final HomeNewsItem item;
  final double width;
  final double mediaHeight;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // 標籤風格依新聞來源/分類切換，讓相同卡片結構仍有辨識度。
    final cardRadius = 21.r;
    final mediaRadius = 19.r;
    final badgeStyle = _NewsBadgeStyle.fromLabel(item.badge);

    return SizedBox(
      width: width,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(cardRadius),
          child: Ink(
            padding: EdgeInsets.fromLTRB(7.w, 7.h, 7.w, 6.h),
            decoration: BoxDecoration(
              color: AppColors.newsSurface,
              borderRadius: BorderRadius.circular(cardRadius),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: mediaHeight,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: mediaHeight,
                        width: double.infinity,
                        margin: EdgeInsets.only(
                          top: 4.h,
                          left: 4.w,
                          right: 4.w,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.placeholder,
                          borderRadius: BorderRadius.circular(mediaRadius),
                        ),
                        child: Icon(
                          Icons.article_outlined,
                          color: Colors.white.withValues(alpha: 0.72),
                          size: 34.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 2.h),
                Padding(
                  padding: EdgeInsets.fromLTRB(6.w, 8.w, 6.w, 5.h),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 15.sp,
                        height: 1.05,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NewsBadgeStyle {
  const _NewsBadgeStyle({
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.shadowColor,
  });

  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final Color shadowColor;

  factory _NewsBadgeStyle.fromLabel(String label) {
    // 目前以假資料標籤做切換，之後若接後端資料可改成列舉會更安全。
    switch (label) {
      case '快訊':
        return const _NewsBadgeStyle(
          backgroundColor: Color(0xFFFFF2EE),
          borderColor: Color(0xFFF4D9D0),
          textColor: Color(0xFF99513E),
          shadowColor: Color(0x26D99A89),
        );
      case '天氣':
        return const _NewsBadgeStyle(
          backgroundColor: Color(0xFFFFF8E8),
          borderColor: Color(0xFFF2E4B9),
          textColor: Color(0xFF907227),
          shadowColor: Color(0x26E0C978),
        );
      case '社會':
        return const _NewsBadgeStyle(
          backgroundColor: Color(0xFFF2F4F7),
          borderColor: Color(0xFFDCE3EA),
          textColor: Color(0xFF56697A),
          shadowColor: Color(0x26485E75),
        );
      default:
        return const _NewsBadgeStyle(
          backgroundColor: Color(0xFFF8F8F8),
          borderColor: Color(0xFFE4E4E4),
          textColor: Color(0xFF444444),
          shadowColor: Color(0x1A000000),
        );
    }
  }
}
