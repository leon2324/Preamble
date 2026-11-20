part of '../know_law_page.dart';

/// 生活工具箱 Tab 外層容器。
///
/// 台灣繁體中文維護註解：全站統一收斂至 LegalToolkitHubPage（法務實戰工具館），
/// 此處不再維護第二套重複工具，改為提供直達實戰工具館與常用工具的單一入口。
class LearningToolsTab extends StatelessWidget {
  const LearningToolsTab({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}

extension LearningToolsTabBuilder on KnowLawPageState {
  Widget buildLearningToolsTab(bool isDark, LearningGameState gameState) {
    final t = context.tokens;
    const quickTools = [
      (
        key: '租屋催告',
        title: '租屋催告與存證信函',
        subtitle: '押金返還、修繕限期催告範本與匯出',
      ),
      (
        key: '加班費試算',
        title: '加班費與資遣費試算',
        subtitle: '依勞基法第 24 條計算平日與休息日加班費',
      ),
      (
        key: '車禍折舊',
        title: '車禍零件折舊試算器',
        subtitle: '依行政院固定資產耐用年數表計算合理賠償',
      ),
      (
        key: '消費退貨',
        title: '消費退貨與申訴函',
        subtitle: '網購七天鑑賞期與瑕疵解除契約範本',
      ),
    ];

    return LearningToolsTab(children: [
      Container(
        padding: EdgeInsets.all(16.w),
        decoration: t.cardDecoration(radius: 18.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('法務實戰工具館', style: t.serifTitle(size: 17.sp)),
            SizedBox(height: 6.h),
            Text(
              '已整合全站唯一的法務工具模組，包含書狀草稿、存證信函、勞資與車禍試算及全國法規查詢。',
              style: t.sansBody(
                size: 12.5.sp,
                color: t.textSecondary,
                height: 1.5,
              ),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const LegalToolkitHubPage(),
                    ),
                  );
                },
                icon: Icon(Icons.handyman_rounded, size: 17.sp),
                label: Text(
                  '開啟法務實戰工具館',
                  style: t.sansTitle(size: 13.sp, color: t.brandOnPrimary),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: t.brandPrimary,
                  foregroundColor: t.brandOnPrimary,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      SizedBox(height: 12.h),
      for (final item in quickTools) ...[
        Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14.r),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        LegalToolkitHubPage(initialToolKey: item.key),
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.all(14.w),
                decoration: t.cardDecoration(radius: 14.r),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.title, style: t.sansTitle(size: 13.5.sp)),
                          SizedBox(height: 3.h),
                          Text(
                            item.subtitle,
                            style: t.sansBody(
                              size: 12.sp,
                              color: t.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18.sp,
                      color: t.textMuted,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
      SizedBox(height: 4.h),
      _buildStatuteSearchWidget(),
    ]);
  }
}
