import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/components/home/v2/home_v2_palette.dart';
import 'package:lawapp/data/mock_data/learning/learning_mock_data.dart';
import 'package:lawapp/pages/home/subpages/home_subpage_primitives.dart';
import 'package:lawapp/pages/learning/learning_mock_detail_page.dart';
import 'package:lawapp/theme/app_colors.dart';

// 首頁子頁的法律學習專題列表。
// 只放 learning topic 列表與文章卡片 UI，不放首頁資料組裝或其他子頁邏輯。

/// 首頁專題的完整列表頁。
///
/// 台灣繁體中文教學註解：
/// 這頁復用 learning mock data，等學習 API 完成時，只要把資料來源換成 repository，
/// 卡片與導頁方式可以沿用。
class HomeLearningTopicsPage extends StatelessWidget {
  const HomeLearningTopicsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final units = learningTopic.units;
    final related = learningTopic.relatedTopics;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, topPadding + 14.h, 16.w, 30.h),
        children: [
          SubpageTopBar(onBack: () => Navigator.of(context).pop()),
          SizedBox(height: 18.h),
          const SubpageHero(
            title: '法律學習專題',
            subtitle: '沿用首頁淡色卡片，把課程單元、相關主題與測驗入口整理成完整列表。',
            icon: Icons.menu_book_outlined,
            color: HomeV2Palette.mint,
          ),
          SizedBox(height: 16.h),
          _LearningArticleCard(
            title: learningTopic.heroArticle.title,
            summary: learningTopic.heroArticle.summary,
            label: '主專題',
            onTap: () => _openArticle(context, learningTopic.heroArticle),
          ),
          SizedBox(height: 12.h),
          ...units.map(
            (unit) => Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: _LearningArticleCard(
                title: unit.title,
                summary: unit.goal,
                label: unit.stepLabel,
                onTap: () => _openArticle(context, unit.article),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '延伸主題',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 10.h),
          ...related.map(
            (topic) => Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: _LearningArticleCard(
                title: topic.title,
                summary: topic.summary,
                label: topic.focusLabel,
                onTap: () => _openArticle(context, topic.article),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openArticle(BuildContext context, LearningMockArticle article) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (__) => LearningMockDetailPage(article: article),
      ),
    );
  }
}

class _LearningArticleCard extends StatelessWidget {
  const _LearningArticleCard({
    required this.title,
    required this.summary,
    required this.label,
    required this.onTap,
  });

  final String title;
  final String summary;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Ink(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TinySourceLabel(label: label),
              SizedBox(height: 8.h),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  height: 1.28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                summary,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.sp,
                  height: 1.45,
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
