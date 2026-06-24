part of '../case_dossier_detail_page.dart';

// 台灣繁體中文教學註解：
// 這個 part 檔集中收納案件詳情頁可重用的基礎 UI 元件與純展示 class。
// 頁面 state、repository、route 與收藏追蹤行為仍留在 case_dossier_detail_page.dart。

extension _CaseDossierPrimitives on _CaseDossierDetailPageState {
  Widget _buildContentCard({
    required Widget child,
    Color accentColor = CaseTimeMachineColors.accentGold,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: CaseTimeMachineColors.bgWhite,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 4.w,
                color: accentColor,
              ),
              Expanded(
                child: Padding(
                  padding: padding ?? EdgeInsets.all(16.w),
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 台灣繁體中文教學註解：
// 「思辨與探索」區塊的個別快捷方格 Tile。
// 複用 CaseLibraryInteractiveGrid 的莫蘭迪色設計，直接依此案件開啟對應分析頁面。
class _ExploreShortcutTile extends StatelessWidget {
  const _ExploreShortcutTile({
    required this.iconSvg,
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onTap,
  });

  final String iconSvg;
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(minHeight: 88.h),
        padding: EdgeInsets.fromLTRB(11.w, 10.h, 11.w, 9.h),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: foregroundColor.withValues(alpha: 0.12),
            width: 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.65),
                shape: BoxShape.circle,
              ),
              child: CtmSvgIcon(
                iconSvg,
                size: 16.sp,
                color: foregroundColor,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w900,
                    color: foregroundColor,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 8.5.sp,
                    fontWeight: FontWeight.w700,
                    color: foregroundColor.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverTabBarDelegate({required this.child});

  final Widget child;

  @override
  double get minExtent => 54.h;

  @override
  double get maxExtent => 54.h;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(covariant _SliverTabBarDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}
