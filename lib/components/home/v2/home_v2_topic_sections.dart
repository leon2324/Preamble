import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/components/home/v2/home_v2_palette.dart';
import 'package:lawapp/data/mock_data/home/home_v2_mock_data.dart';
import 'package:lawapp/theme/app_colors.dart';

// 首頁 V2 的專題區塊。
// 只放專題橫向列表與 Bento Grid UI，不放首頁路由與資料載入邏輯。

class HomeV2TopicSeries extends StatelessWidget {
  const HomeV2TopicSeries({
    super.key,
    this.onTopicTap,
  });

  final ValueChanged<HomeV2TopicItem>? onTopicTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 138.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: homeV2TopicItems
            .map(
              (item) => _TopicCard(
                title: item.title,
                subtitle: item.subtitle,
                color: item.color,
                icon: item.icon,
                onTap: onTopicTap == null ? null : () => onTopicTap!(item),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(22.r);

    return SizedBox(
      width: 168.w,
      child: Padding(
        padding: EdgeInsets.only(right: 12.w),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            child: Ink(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: color,
                borderRadius: radius,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: HomeV2Palette.trustGreen, size: 28.sp),
                  const Spacer(),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: HomeV2Palette.ink,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w900,
                      height: 1.18,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomeV2TopicBentoGrid extends StatelessWidget {
  const HomeV2TopicBentoGrid({
    super.key,
    this.onTopicTap,
  });

  final ValueChanged<HomeV2TopicItem>? onTopicTap;

  @override
  Widget build(BuildContext context) {
    if (homeV2TopicItems.length < 3) return const SizedBox.shrink();

    final itemBig = homeV2TopicItems[0];
    final itemSmall1 = homeV2TopicItems[1];
    final itemSmall2 = homeV2TopicItems[2];

    return SizedBox(
      height: 160.h,
      child: Row(
        children: [
          // 左側大卡片
          Expanded(
            flex: 3,
            child: _BigBentoTopicCard(
              item: itemBig,
              onTap: onTopicTap == null ? null : () => onTopicTap!(itemBig),
            ),
          ),
          SizedBox(width: 12.w),
          // 右側兩張小卡片
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Expanded(
                  child: _SmallBentoTopicCard(
                    item: itemSmall1,
                    onTap: onTopicTap == null
                        ? null
                        : () => onTopicTap!(itemSmall1),
                  ),
                ),
                SizedBox(height: 12.h),
                Expanded(
                  child: _SmallBentoTopicCard(
                    item: itemSmall2,
                    onTap: onTopicTap == null
                        ? null
                        : () => onTopicTap!(itemSmall2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BigBentoTopicCard extends StatelessWidget {
  const _BigBentoTopicCard({
    required this.item,
    this.onTap,
  });

  final HomeV2TopicItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(22.r);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Ink(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: item.color,
            borderRadius: radius,
            border: Border.all(
              color: isDark ? const Color(0xFF2A3340) : const Color(0xFFE9DFD2),
              width: 1.2.w,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.05 : 0.015),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.6),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.icon,
                  color: HomeV2Palette.trustGreen,
                  size: 24.sp,
                ),
              ),
              const Spacer(),
              Text(
                item.title,
                style: TextStyle(
                  color: HomeV2Palette.ink,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                item.subtitle,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallBentoTopicCard extends StatelessWidget {
  const _SmallBentoTopicCard({
    required this.item,
    this.onTap,
  });

  final HomeV2TopicItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(18.r);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Ink(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: item.color,
            borderRadius: radius,
            border: Border.all(
              color: isDark ? const Color(0xFF2A3340) : const Color(0xFFE9DFD2),
              width: 1.2.w,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.05 : 0.015),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: HomeV2Palette.ink,
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      item.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                item.icon,
                color: HomeV2Palette.trustGreen.withValues(alpha: 0.8),
                size: 20.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
