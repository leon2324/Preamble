import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/components/home/v2/home_v2_palette.dart';
import 'package:lawapp/data/mock_data/home/home_v2_mock_data.dart';
import 'package:lawapp/pages/home/subpages/home_subpage_primitives.dart';
import 'package:lawapp/pages/learning/know_law_page.dart';
import 'package:lawapp/pages/learning/statute_database_page.dart';
import 'package:lawapp/theme/app_colors.dart';

// 首頁子頁的常見法律問題入口。
// 只放情境問題列表與卡片 UI，導航仍維持原本前往小法助或法規庫的行為。

/// 首頁常見法律問題的完整子頁。
///
/// 這頁把首頁橫向小入口展開成完整情境選單；一般生活問題交給小法助，
/// 法規查詢則直接進資料庫頁，讓使用者不用理解背後功能分工。
class CommonLegalIssuesPage extends StatelessWidget {
  const CommonLegalIssuesPage({super.key});

  void _openIssue(BuildContext context, HomeV2IssueItem item) {
    if (item.label == '法規查詢') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (__) => const StatuteDatabasePage()),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (__) => LawAssistantChatPage(
          initialPrompt: '我想了解${item.label}常見法律問題，可以先看哪些方向？',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, topPadding + 14.h, 16.w, 30.h),
        children: [
          SubpageTopBar(onBack: () => Navigator.of(context).pop()),
          SizedBox(height: 18.h),
          const SubpageHero(
            title: '常見法律問題',
            subtitle: '先選情境，再交給小法助整理方向、相關法條與下一步。未登入仍可試用一次。',
            icon: Icons.psychology_alt_outlined,
            color: HomeV2Palette.aiYellow,
          ),
          SizedBox(height: 16.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: homeV2IssueItems.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10.h,
              crossAxisSpacing: 10.w,
              childAspectRatio: 1.25,
            ),
            itemBuilder: (context, index) {
              final item = homeV2IssueItems[index];
              return _IssueCard(
                item: item,
                onTap: () => _openIssue(context, item),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _IssueCard extends StatelessWidget {
  const _IssueCard({
    required this.item,
    required this.onTap,
  });

  final HomeV2IssueItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Ink(
          padding: EdgeInsets.all(15.w),
          decoration: BoxDecoration(
            color: item.color,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(item.icon, color: HomeV2Palette.trustGreen, size: 28.sp),
              const Spacer(),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w900,
                  color: HomeV2Palette.ink,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                item.label == '法規查詢' ? '進入官方法規庫' : '整理常見爭點',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
