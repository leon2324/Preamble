import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/components/home/v2/home_v2_palette.dart';
import 'package:lawapp/data/mock_data/home/home_v2_mock_data.dart';
import 'package:lawapp/theme/app_colors.dart';

// 首頁 V2 的入口卡片群。
// 只放 AI、快速議題、MMP 功能入口與法規資料庫入口 UI，不放首頁路由與資料載入邏輯。

class HomeV2AiAssistantCard extends StatelessWidget {
  const HomeV2AiAssistantCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // 首頁這張卡只扮演「導到小法助入口」的角色，實際提問、guest 次數限制
    // 與後端設定判斷都集中在小法助主流程，避免日後維護兩套流程。
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22.r),
        child: Ink(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: HomeV2Palette.aiYellow,
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(color: const Color(0xFFE8B95F)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 34.w,
                    height: 34.w,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.psychology_alt_outlined,
                      color: const Color(0xFF94610D),
                      size: 22.sp,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      'AI 法律輔助',
                      style: TextStyle(
                        color: const Color(0xFF5C3A07),
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const _BetaBadge(),
                ],
              ),
              SizedBox(height: 14.h),
              Text(
                '請描述你遇到的法律問題',
                style: TextStyle(
                  color: const Color(0xFF5C3A07),
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                '越完整描述情境，越能提供精準的建議與法規來源。',
                style: TextStyle(
                  color: const Color(0xFF8C651E),
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 14.h),
              Semantics(
                button: true,
                label: '前往問小法助',
                child: Container(
                  padding: EdgeInsets.fromLTRB(14.w, 10.h, 8.w, 10.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: const Color(0xFFE4C179)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '例如：房東不退押金怎麼辦？',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Container(
                        width: 42.w,
                        height: 42.w,
                        decoration: const BoxDecoration(
                          color: HomeV2Palette.trustGreen,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 24.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Icon(
                    Icons.lock_open_rounded,
                    color: HomeV2Palette.trustGreen,
                    size: 15.sp,
                  ),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      '未登入也可使用基礎查詢，登入後可保存紀錄與追蹤案件。',
                      style: TextStyle(
                        color: const Color(0xFF6B4B14),
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeV2QuickIssueGrid extends StatelessWidget {
  const HomeV2QuickIssueGrid({
    super.key,
    this.onIssueTap,
  });

  final ValueChanged<HomeV2IssueItem>? onIssueTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 86.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final item = homeV2IssueItems[index];
          final radius = BorderRadius.circular(18.r);

          return SizedBox(
            width: 74.w,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onIssueTap == null ? null : () => onIssueTap!(item),
                borderRadius: radius,
                child: Ink(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: item.color,
                    borderRadius: radius,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item.icon,
                        color: HomeV2Palette.trustGreen,
                        size: 25.sp,
                      ),
                      SizedBox(height: 7.h),
                      FittedBox(
                        child: Text(
                          item.label,
                          style: TextStyle(
                            color: HomeV2Palette.trustGreen,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => SizedBox(width: 10.w),
        itemCount: homeV2IssueItems.length,
      ),
    );
  }
}

class HomeV2MmpFeatureStrip extends StatelessWidget {
  const HomeV2MmpFeatureStrip({
    super.key,
    required this.onOpenTools,
    required this.onOpenCases,
    required this.onOpenProfile,
  });

  final VoidCallback onOpenTools;
  final VoidCallback onOpenCases;
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    // 這排是首頁進入完整 MMP 的三個主入口，對應「解決問題、看記事、管理權限」。
    // 之後若新增正式文件 API 或收藏 API，優先從各入口進到專頁，不把首頁塞成工具頁。
    final items = [
      _MmpFeatureItem(
        title: '文件產生',
        subtitle: '存證、協商、備忘',
        icon: Icons.description_outlined,
        color: const Color(0xFFF6E8D7),
        onTap: onOpenTools,
      ),
      _MmpFeatureItem(
        title: '記事',
        subtitle: '趨勢、議題、案件',
        icon: Icons.inventory_2_outlined,
        color: HomeV2Palette.lawBlue,
        onTap: onOpenCases,
      ),
      _MmpFeatureItem(
        title: '會員權限',
        subtitle: '登入、Pro、收藏',
        icon: Icons.verified_user_outlined,
        color: HomeV2Palette.mint,
        onTap: onOpenProfile,
      ),
    ];

    final stripHeight = 118.h + MediaQuery.textScalerOf(context).scale(4);

    return SizedBox(
      height: stripHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return _MmpFeatureCard(item: items[index]);
        },
        separatorBuilder: (_, __) => SizedBox(width: 10.w),
        itemCount: items.length,
      ),
    );
  }
}

class _MmpFeatureItem {
  const _MmpFeatureItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
}

class _MmpFeatureCard extends StatelessWidget {
  const _MmpFeatureCard({required this.item});

  final _MmpFeatureItem item;

  @override
  Widget build(BuildContext context) {
    // 這張卡目前會被用在首頁的三個主入口上，因此改用 InkWell + Ink 的標準組合，
    // 可以讓點擊命中區與圓角背景完全一致，降低日後調整版型時出現「看得到但點不到」的風險。
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Ink(
          width: 122.w,
          padding: EdgeInsets.all(13.w),
          decoration: BoxDecoration(
            color: item.color,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(item.icon, color: HomeV2Palette.trustGreen, size: 25.sp),
              SizedBox(height: 10.h),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: HomeV2Palette.ink,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w900,
                        height: 1.12,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      item.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeV2LawDatabaseCard extends StatelessWidget {
  const HomeV2LawDatabaseCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // 這張卡是 MAIC Demo 的 Spotlight 落地入口候選；
    // 未來 iOS 端把法條與案例索引到 Core Spotlight 後，可直接深連結回這個搜尋流程。
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: HomeV2Palette.lawBlue,
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(color: const Color(0xFF9DCAFF)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.article_outlined,
                  color: const Color(0xFF1F4E87),
                  size: 26.sp,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '法規資料庫搜尋',
                        style: TextStyle(
                          color: const Color(0xFF1F4E87),
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        '查詢法條、條文、解釋函令與生活關鍵字',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xFF4C6D95),
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    color: AppColors.textMuted,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      '搜尋法條關鍵字，例如：民法 184',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  CircleAvatar(
                    radius: 16.r,
                    backgroundColor: const Color(0xFF1F4E87),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 18.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BetaBadge extends StatelessWidget {
  const _BetaBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(99.r),
      ),
      child: Text(
        'Beta',
        style: TextStyle(
          color: const Color(0xFF94610D),
          fontSize: 10.sp,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
