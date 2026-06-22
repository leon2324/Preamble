import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/components/home/v2/home_v2_palette.dart';
import 'package:lawapp/data/mock_data/home/home_v2_mock_data.dart';
import 'package:lawapp/theme/app_colors.dart';
import 'package:lawapp/features/case_time_machine/pages/case_dossier_detail_page.dart';
import 'package:lawapp/features/case_time_machine/data/case_time_machine_mock_data.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 尋找租屋糾紛案件
    final rentalCase = caseTimeMachineCases.firstWhere(
      (c) => c.titleZh.contains('租屋') || c.shortTitleZh.contains('租'),
      orElse: () => caseTimeMachineCases.first,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E242B) : const Color(0xFFFAF7F2),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? const Color(0xFF2E394A) : const Color(0xFFEBE6DB),
          width: 1.2.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 頂部小標誌
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFD85A53).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  '本周焦點議題對決',
                  style: TextStyle(
                    color: const Color(0xFFD85A53),
                    fontSize: 9.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '1.2w 人參與思辨',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            '租屋退租押金扣除：自然折舊 vs 恢復原狀',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            '房客退租時，日常房屋磨損與壁面汙損究竟應由誰買單？正反法律立場如何碰撞？',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11.sp,
              height: 1.4,
            ),
          ),
          SizedBox(height: 16.h),

          // 正反雙方卡片對決 Row
          Stack(
            alignment: Alignment.center,
            children: [
              Row(
                children: [
                  // 左側正方卡片 (房東方 - 恢復原狀)
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (__) => CaseDossierDetailPage(book: rentalCase),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1B2E24) : const Color(0xFFF2F8F4),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12.r),
                            bottomLeft: Radius.circular(12.r),
                          ),
                          border: Border.all(
                            color: isDark ? const Color(0xFF275435) : const Color(0xFFD4E8DA),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '正方：應恢復原狀',
                              style: TextStyle(
                                color: isDark ? const Color(0xFF76BA8B) : const Color(0xFF275435),
                                fontSize: 11.5.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              '終止租約時承租人負有返還原狀義務，房東有權依法扣除清潔與修繕費。',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 10.sp,
                                height: 1.35,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              '深入探究 →',
                              style: TextStyle(
                                color: isDark ? const Color(0xFF76BA8B) : const Color(0xFF275435),
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w), // 給 VS 徽章留下中間空隙
                  // 右側反方卡片 (房客方 - 折舊耗損)
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (__) => CaseDossierDetailPage(book: rentalCase),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF381E1E) : const Color(0xFFFAF2F2),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(12.r),
                            bottomRight: Radius.circular(12.r),
                          ),
                          border: Border.all(
                            color: isDark ? const Color(0xFF7A4242) : const Color(0xFFF2D2D2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '反方：折舊屬耗損',
                              style: TextStyle(
                                color: isDark ? const Color(0xFFD88585) : const Color(0xFFB24C4C),
                                fontSize: 11.5.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              '合理使用之自然折舊屬日常租金之對價耗損，不得無端扣抵押金。',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 10.sp,
                                height: 1.35,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              '深入探究 →',
                              style: TextStyle(
                                color: isDark ? const Color(0xFFD88585) : const Color(0xFFB24C4C),
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // 中間的 VS 徽章
              Container(
                width: 24.w,
                height: 24.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFD85A53),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5.w),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'VS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
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
