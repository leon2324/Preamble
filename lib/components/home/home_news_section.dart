import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/components/home/home_content.dart';
import 'package:lawapp/components/home/home_section_title.dart';
import 'package:lawapp/theme/adaptive_layout.dart';
import 'package:lawapp/theme/app_colors.dart';

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
    final cardHeight = mediaHeight + 74.h;

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
                      Positioned(
                        top: -15.h,
                        left: -10.w,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 8.r,
                                offset: Offset(0, 2.h),
                              ),
                            ],
                          ),
                          child: Container(
                            width: 42.w,
                            height: 42.w,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE1E1DE),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              item.sourceLabel ?? 'MOJ',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 7.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: -15.h,
                        right: -7.w,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              top: 3.h,
                              right: -1.w,
                              child: Container(
                                width: 58.w,
                                height: 28.h,
                                decoration: BoxDecoration(
                                  color: badgeStyle.shadowColor,
                                  borderRadius: BorderRadius.circular(999.r),
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: badgeStyle.backgroundColor,
                                borderRadius: BorderRadius.circular(999.r),
                                border: Border.all(
                                  color: badgeStyle.borderColor,
                                  width: 1.w,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withValues(alpha: 0.55),
                                    blurRadius: 2.r,
                                    offset: Offset(0, -1.h),
                                  ),
                                ],
                              ),
                              child: Text(
                                item.badge,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: badgeStyle.textColor,
                                  letterSpacing: 0,
                                ),
                              ),
                            ),
                          ],
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
