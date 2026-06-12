import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:lawapp/app/app_state.dart';
import 'package:lawapp/components/home/v2/home_v2_palette.dart';
import 'package:lawapp/components/home/v2/home_v2_primitives.dart';
import 'package:lawapp/components/shared/mvp_state_widgets.dart';
import 'package:lawapp/data/law_assistant/guest_law_assistant_usage.dart';
import 'package:lawapp/data/law_assistant/law_assistant_models.dart';
import 'package:lawapp/data/law_assistant/law_assistant_repository.dart';
import 'package:lawapp/data/mock_data/learning/learning_mock_data.dart';
import 'package:lawapp/pages/learning/learning_mock_detail_page.dart';
import 'package:lawapp/pages/learning/learning_quiz_page.dart';
import 'package:lawapp/pages/learning/statute_database_page.dart';
import 'package:lawapp/theme/adaptive_layout.dart';
import 'package:lawapp/theme/app_colors.dart';

part 'law_assistant/law_assistant_palette.dart';
part 'law_assistant/law_assistant_search_page.dart';
part 'law_assistant/law_assistant_prototype_widgets.dart';
part 'law_assistant/law_assistant_chat_page.dart';

/// 學習頁 Prototype：把文章入口整理成「情境學習中心」。
///
/// 台灣繁體中文教學註解：
/// 這版先用首頁 v2 的色票與卡片語言重新排列內容，重點是驗證資訊架構；
/// 詳細資料仍沿用 learning mock data，等視覺方向確認後再拆成正式元件檔。
class KnowLawPage extends StatefulWidget {
  const KnowLawPage({super.key});

  @override
  KnowLawPageState createState() => KnowLawPageState();
}

class KnowLawPageState extends State<KnowLawPage> {
  static const List<String> _learningCategories = [
    '租屋',
    '勞資',
    '交通',
    '刑事',
    '消費',
  ];

  void _openArticle(LearningMockArticle article) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (__) => LearningMockDetailPage(article: article),
      ),
    );
  }

  void _openLearningSearch() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (__) => const LawAssistantSearchPage(),
      ),
    );
  }

  void _openStatuteDatabase({String initialQuery = ''}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (__) => StatuteDatabasePage(initialQuery: initialQuery),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;

    // 台灣繁體中文教學註解：
    // Prototype 先取消舊版固定頂部，改用首頁同款垂直資訊流，讓學習分頁
    // 和首頁、記事頁保持同一個產品節奏；底部仍預留全域 Nav 的安全距離。
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          16.w,
          18.h,
          16.w,
          context.pageContentBottomPadding + 70.h + keyboardInset,
        ),
        children: [
          _LearningPrototypeHeader(onSearchTap: _openLearningSearch),
          SizedBox(height: 14.h),
          _LearningPrototypeActionStrip(
            onAskTap: _openLearningSearch,
            onRouteTap: () => _openArticle(learningTopic.heroArticle),
            onStatuteTap: _openStatuteDatabase,
          ),
          SizedBox(height: 18.h),
          HomeV2SectionHeader(
            title: '專題',
            action: '查看',
            onTap: () => _openArticle(learningTopic.heroArticle),
          ),
          SizedBox(height: 10.h),
          _LearningRouteCard(
            topic: learningTopic,
            onTap: () => _openArticle(learningTopic.heroArticle),
            onQuizTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (__) => const LearningQuizPage()),
              );
            },
          ),
          SizedBox(height: 18.h),
          const HomeV2SectionHeader(title: '根據最近查看的案件'),
          SizedBox(height: 10.h),
          _LearningCaseRecommendationList(
            items: _recentCases,
            onTap: (item) => _openArticle(item.article),
          ),
          SizedBox(height: 18.h),
          const HomeV2SectionHeader(title: '常見法律學習主題'),
          SizedBox(height: 10.h),
          _LearningTopicMatrix(
            items: _commonTopics,
            onTap: (item) => _openArticle(item.article),
          ),
          SizedBox(height: 18.h),
          _LearningReviewAndGlossaryRow(
            onQuizTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (__) => const LearningQuizPage()),
              );
            },
            onGlossaryTap: () =>
                _openArticle(learningTopic.supportItems.first.article),
          ),
          SizedBox(height: 18.h),
          const HomeV2SectionHeader(title: '法條資料庫'),
          SizedBox(height: 10.h),
          _LearningStatuteToolCard(
            onTap: _openStatuteDatabase,
            onChipTap: (query) => _openStatuteDatabase(initialQuery: query),
          ),
          SizedBox(height: 18.h),
          const HomeV2SectionHeader(title: '法律翻譯機'),
          SizedBox(height: 10.h),
          _LearningTranslatorPrototypeCard(
            article: learningTopic.supportItems[1].article,
            onTap: () => _openArticle(learningTopic.supportItems[1].article),
          ),
          SizedBox(height: 18.h),
          const HomeV2SectionHeader(title: '文件與證據準備'),
          SizedBox(height: 10.h),
          _LearningEvidenceChecklistCard(
            onTap: () => _openArticle(learningTopic.supportItems[2].article),
          ),
        ],
      ),
    );
  }
}

class _LearningPrototypeHeader extends StatelessWidget {
  const _LearningPrototypeHeader({required this.onSearchTap});

  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    return HomeV2SurfaceCard(
      color: HomeV2Palette.mint,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 14.w, 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42.w,
                height: 42.w,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.menu_book_rounded,
                  color: HomeV2Palette.trustGreen,
                  size: 23.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '學習',
                      style: TextStyle(
                        color: HomeV2Palette.ink,
                        fontSize: 26.sp,
                        height: 1,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '用生活情境建立法律判斷順序',
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
              _LearningIconButton(
                icon: Icons.search_rounded,
                label: '搜尋學習內容',
                onTap: onSearchTap,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onSearchTap,
              borderRadius: BorderRadius.circular(18.r),
              child: Ink(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18.r),
                  border: Border.all(color: const Color(0xFFD5E2D9)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search_rounded,
                      color: HomeV2Palette.trustGreen,
                      size: 20.sp,
                    ),
                    SizedBox(width: 9.w),
                    Expanded(
                      child: Text(
                        '輸入情境、法條或術語',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: HomeV2Palette.trustGreen,
                      size: 20.sp,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LearningPrototypeActionStrip extends StatelessWidget {
  const _LearningPrototypeActionStrip({
    required this.onAskTap,
    required this.onRouteTap,
    required this.onStatuteTap,
  });

  final VoidCallback onAskTap;
  final VoidCallback onRouteTap;
  final VoidCallback onStatuteTap;

  @override
  Widget build(BuildContext context) {
    final actions = [
      _LearningActionItem(
        title: '描述情況',
        subtitle: '初步整理',
        icon: Icons.psychology_alt_outlined,
        color: HomeV2Palette.aiYellow,
        onTap: onAskTap,
      ),
      _LearningActionItem(
        title: '學習路線',
        subtitle: '依序閱讀',
        icon: Icons.route_outlined,
        color: HomeV2Palette.lavender,
        onTap: onRouteTap,
      ),
      _LearningActionItem(
        title: '查詢條文',
        subtitle: '法規資料',
        icon: Icons.article_outlined,
        color: HomeV2Palette.lawBlue,
        onTap: onStatuteTap,
      ),
    ];

    return SizedBox(
      height: 104.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return _LearningActionCard(item: actions[index]);
        },
        separatorBuilder: (_, __) => SizedBox(width: 10.w),
        itemCount: actions.length,
      ),
    );
  }
}

class _LearningActionItem {
  const _LearningActionItem({
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

class _LearningActionCard extends StatelessWidget {
  const _LearningActionCard({required this.item});

  final _LearningActionItem item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Ink(
          width: 112.w,
          padding: EdgeInsets.all(13.w),
          decoration: BoxDecoration(
            color: item.color,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(item.icon, color: HomeV2Palette.trustGreen, size: 25.sp),
              const Spacer(),
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: HomeV2Palette.ink,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                item.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10.sp,
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

class _LearningRouteCard extends StatelessWidget {
  const _LearningRouteCard({
    required this.topic,
    required this.onTap,
    required this.onQuizTap,
  });

  final LearningTopicData topic;
  final VoidCallback onTap;
  final VoidCallback onQuizTap;

  @override
  Widget build(BuildContext context) {
    return HomeV2SurfaceCard(
      color: Colors.white,
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(18.r),
              child: Ink(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: HomeV2Palette.aiYellow,
                  borderRadius: BorderRadius.circular(18.r),
                  border: Border.all(color: const Color(0xFFE8B95F)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42.w,
                      height: 42.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.76),
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Icon(
                        Icons.home_work_outlined,
                        color: HomeV2Palette.trustGreen,
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '租屋糾紛怎麼看懂',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: HomeV2Palette.ink,
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 5.h),
                          Text(
                            topic.summary,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: const Color(0xFF6B4B14),
                              fontSize: 11.sp,
                              height: 1.35,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: HomeV2Palette.trustGreen,
                      size: 24.sp,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 14.h),
          _LearningProgressBar(completed: 2, total: topic.units.length),
          SizedBox(height: 14.h),
          ...topic.units.take(4).map(
                (unit) => _LearningRouteStep(
                  label: unit.stepLabel,
                  title: unit.title,
                  meta: unit.readTime,
                  isDone: unit.stepLabel == '01' || unit.stepLabel == '02',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (__) =>
                          LearningMockDetailPage(article: unit.article),
                    ),
                  ),
                ),
              ),
          SizedBox(height: 6.h),
          _LearningRouteStep(
            label: '05',
            title: '用一題測驗確認判斷順序',
            meta: '1 題測驗',
            icon: Icons.fact_check_outlined,
            isDone: false,
            onTap: onQuizTap,
          ),
        ],
      ),
    );
  }
}

class _LearningProgressBar extends StatelessWidget {
  const _LearningProgressBar({required this.completed, required this.total});

  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = completed / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '目前進度',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              '$completed / $total 單元',
              style: TextStyle(
                color: HomeV2Palette.trustGreen,
                fontSize: 11.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(99.r),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8.h,
            backgroundColor: const Color(0xFFE8ECE8),
            valueColor: const AlwaysStoppedAnimation<Color>(
              HomeV2Palette.trustGreen,
            ),
          ),
        ),
      ],
    );
  }
}

class _LearningRouteStep extends StatelessWidget {
  const _LearningRouteStep({
    required this.label,
    required this.title,
    required this.meta,
    required this.isDone,
    required this.onTap,
    this.icon,
  });

  final String label;
  final String title;
  final String meta;
  final bool isDone;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final markerColor =
        isDone ? HomeV2Palette.trustGreen : const Color(0xFFE8ECE8);
    final markerTextColor = isDone ? Colors.white : AppColors.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 5.h),
          child: Row(
            children: [
              Container(
                width: 34.w,
                height: 34.w,
                decoration: BoxDecoration(
                  color: markerColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: icon == null
                      ? Text(
                          label,
                          style: TextStyle(
                            color: markerTextColor,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w900,
                          ),
                        )
                      : Icon(icon, color: markerTextColor, size: 18.sp),
                ),
              ),
              SizedBox(width: 11.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: HomeV2Palette.ink,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      meta,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
                size: 20.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LearningCaseRecommendationList extends StatelessWidget {
  const _LearningCaseRecommendationList({
    required this.items,
    required this.onTap,
  });

  final List<_RecentCaseItem> items;
  final ValueChanged<_RecentCaseItem> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 128.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final item = items[index];

          return _LearningRecommendationCard(
            title: item.title,
            subtitle: '建議閱讀：${item.article.badge}',
            icon: Icons.inventory_2_outlined,
            color: index.isEven ? HomeV2Palette.lawBlue : HomeV2Palette.mint,
            onTap: () => onTap(item),
          );
        },
        separatorBuilder: (_, __) => SizedBox(width: 10.w),
        itemCount: items.length,
      ),
    );
  }
}

class _LearningRecommendationCard extends StatelessWidget {
  const _LearningRecommendationCard({
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

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Ink(
          width: 168.w,
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: HomeV2Palette.trustGreen, size: 24.sp),
              const Spacer(),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: HomeV2Palette.ink,
                  fontSize: 13.sp,
                  height: 1.2,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 5.h),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10.sp,
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

class _LearningTopicMatrix extends StatelessWidget {
  const _LearningTopicMatrix({
    required this.items,
    required this.onTap,
  });

  final List<_CommonTopicItem> items;
  final ValueChanged<_CommonTopicItem> onTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10.h,
        crossAxisSpacing: 10.w,
        childAspectRatio: 0.98,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        final icon = _topicIconForLabel(item.label);

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onTap(item),
            borderRadius: BorderRadius.circular(18.r),
            child: Ink(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: index.isEven ? Colors.white : HomeV2Palette.mint,
                borderRadius: BorderRadius.circular(18.r),
                border:
                    Border.all(color: AppColors.border.withValues(alpha: 0.6)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: HomeV2Palette.trustGreen, size: 25.sp),
                  SizedBox(height: 8.h),
                  Text(
                    item.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: HomeV2Palette.ink,
                      fontSize: 12.sp,
                      height: 1.18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _topicIconForLabel(String label) {
    switch (label) {
      case '租屋':
        return Icons.home_work_outlined;
      case '職場':
        return Icons.badge_outlined;
      case '交通':
        return Icons.directions_car_outlined;
      case '網路':
        return Icons.language_outlined;
      case '消費':
        return Icons.shopping_bag_outlined;
      default:
        return Icons.balance_outlined;
    }
  }
}

class _LearningReviewAndGlossaryRow extends StatelessWidget {
  const _LearningReviewAndGlossaryRow({
    required this.onQuizTap,
    required this.onGlossaryTap,
  });

  final VoidCallback onQuizTap;
  final VoidCallback onGlossaryTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _LearningMiniFeatureCard(
            title: '複習',
            subtitle: '錯題與待讀單元',
            icon: Icons.replay_outlined,
            color: HomeV2Palette.lavender,
            onTap: onQuizTap,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _LearningMiniFeatureCard(
            title: '術語字典',
            subtitle: '故意、過失、契約',
            icon: Icons.translate_outlined,
            color: HomeV2Palette.aiYellow,
            onTap: onGlossaryTap,
          ),
        ),
      ],
    );
  }
}

class _LearningMiniFeatureCard extends StatelessWidget {
  const _LearningMiniFeatureCard({
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

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Ink(
          height: 112.h,
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: HomeV2Palette.trustGreen, size: 24.sp),
              const Spacer(),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: HomeV2Palette.ink,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10.sp,
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

class _LearningStatuteToolCard extends StatelessWidget {
  const _LearningStatuteToolCard({
    required this.onTap,
    required this.onChipTap,
  });

  final VoidCallback onTap;
  final ValueChanged<String> onChipTap;

  static const List<String> _queries = [
    '民法',
    '刑法',
    '勞基法',
    '消保法',
  ];

  @override
  Widget build(BuildContext context) {
    return HomeV2SurfaceCard(
      color: HomeV2Palette.lawBlue,
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(18.r),
              child: Ink(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.article_outlined,
                      color: const Color(0xFF1F4E87),
                      size: 24.sp,
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        '依法名、條號或生活情境查詢',
                        style: TextStyle(
                          color: HomeV2Palette.ink,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: const Color(0xFF1F4E87),
                      size: 22.sp,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: _queries.map((query) {
              final actualQuery = query == '勞基法' ? '勞動基準法' : query;

              return _LearningPlainChip(
                label: query,
                onTap: () => onChipTap(actualQuery),
              );
            }).toList(growable: false),
          ),
        ],
      ),
    );
  }
}

class _LearningTranslatorPrototypeCard extends StatelessWidget {
  const _LearningTranslatorPrototypeCard({
    required this.article,
    required this.onTap,
  });

  final LearningMockArticle article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return HomeV2SurfaceCard(
      color: const Color(0xFFF5F1DF),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const HomeV2TinyLabel(
                icon: Icons.gavel_outlined,
                label: '法條白話整理',
                color: Color(0xFF5D5A38),
              ),
              const Spacer(),
              _LearningIconButton(
                icon: Icons.arrow_forward_rounded,
                label: '查看法律翻譯機',
                onTap: onTap,
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Text(
            '民法第184條第1項前段',
            style: TextStyle(
              color: const Color(0xFF5D5A38),
              fontSize: 15.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            article.summary,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xFF524E35),
              fontSize: 13.sp,
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12.h),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(999.r),
              child: Ink(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFD7D09D),
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Text(
                  '查看白話整理',
                  style: TextStyle(
                    color: const Color(0xFF433F24),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LearningEvidenceChecklistCard extends StatelessWidget {
  const _LearningEvidenceChecklistCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final items = ['合約與附約', '對話紀錄', '照片與點交紀錄'];

    return HomeV2SurfaceCard(
      color: Colors.white,
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.task_alt_rounded,
                color: HomeV2Palette.trustGreen,
                size: 24.sp,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  '租屋爭議先整理哪些資料',
                  style: TextStyle(
                    color: HomeV2Palette.ink,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ...items.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    color: HomeV2Palette.trustGreen,
                    size: 18.sp,
                  ),
                  SizedBox(width: 9.w),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 4.h),
          Align(
            alignment: Alignment.centerLeft,
            child: _LearningPlainChip(
              label: '查看準備清單',
              onTap: onTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _LearningPlainChip extends StatelessWidget {
  const _LearningPlainChip({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999.r),
        child: Ink(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.86),
            borderRadius: BorderRadius.circular(999.r),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: HomeV2Palette.trustGreen,
              fontSize: 11.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _LearningIconButton extends StatelessWidget {
  const _LearningIconButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(99.r),
          child: Ink(
            width: 36.w,
            height: 36.w,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: HomeV2Palette.trustGreen,
              size: 20.sp,
            ),
          ),
        ),
      ),
    );
  }
}

class _LearningSectionTitle extends StatelessWidget {
  const _LearningSectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20.sp,
        height: 1.08,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _LearningFrozenToolbar extends StatelessWidget {
  const _LearningFrozenToolbar({
    required this.categories,
    required this.onSearchTap,
  });

  final List<String> categories;
  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    final assistantPalette = _LawAssistantPalette.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: assistantPalette.introSurface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: assistantPalette.border),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const _LawBuddyAvatar(),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onSearchTap,
                        borderRadius: BorderRadius.circular(8.r),
                        child: Container(
                          height: 36.h,
                          padding: EdgeInsets.symmetric(horizontal: 2.w),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: assistantPalette.border,
                                width: 1.2.w,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search_rounded,
                                size: 18.sp,
                                color: assistantPalette.accent,
                              ),
                              SizedBox(width: 7.w),
                              Expanded(
                                child: Text(
                                  '說說你遇到的情況，我們一起解決',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w800,
                                    color: assistantPalette.primaryText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        SizedBox(
          height: 34.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return _LearningCategoryChip(label: categories[index]);
            },
            separatorBuilder: (_, __) => SizedBox(width: 8.w),
            itemCount: categories.length,
          ),
        ),
      ],
    );
  }
}

class _LawBuddyAvatar extends StatelessWidget {
  const _LawBuddyAvatar();

  @override
  Widget build(BuildContext context) {
    final assistantPalette = _LawAssistantPalette.of(context);

    // 教學註解：小法助先用內建 icon 組出 IP 雛形，刻意不加外框，
    // 讓角色像直接出現在 Header 裡；未來可整段替換成正式角色圖。
    return SizedBox(
      width: 42.w,
      height: 42.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.smart_toy_rounded,
            size: 35.sp,
            color: assistantPalette.accent,
          ),
          Positioned(
            right: 3.w,
            bottom: 2.w,
            child: Container(
              width: 15.w,
              height: 15.w,
              decoration: BoxDecoration(
                color: assistantPalette.highlight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.balance_rounded,
                size: 10.sp,
                color: assistantPalette.primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LearningCategoryChip extends StatelessWidget {
  const _LearningCategoryChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAEC),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: const Color(0xFFE2D7B8)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.5.sp,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF5C5C45),
        ),
      ),
    );
  }
}

class _FeaturedTopicCard extends StatelessWidget {
  const _FeaturedTopicCard({
    required this.topic,
    required this.onTap,
  });

  final LearningTopicData topic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24.r),
        child: Container(
          height: 254.h,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: const [
              BoxShadow(
                color: Color(0x18000000),
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              const _RoomSceneBackground(),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.05),
                      Colors.transparent,
                      const Color(0x3A000000),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 5.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.76),
                            borderRadius: BorderRadius.circular(999.r),
                          ),
                          child: Text(
                            '主專題',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primarySoft,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '2026/04/12',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF74685D),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      '租屋糾紛怎麼看懂',
                      style: TextStyle(
                        fontSize: 18.sp,
                        height: 1.05,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      topic.summary,
                      style: TextStyle(
                        fontSize: 12.sp,
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF2D261F),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      '從押金、解約到修繕責任，這個主專題會帶你用一條完整順序理解租屋爭議。',
                      style: TextStyle(
                        fontSize: 12.sp,
                        height: 1.45,
                        color: const Color(0xFF2F2A23),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        Text(
                          '往下滑還有更多主題',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF4D5A8A),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 24.sp,
                          color: AppColors.primary,
                        ),
                      ],
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

class _RoomSceneBackground extends StatelessWidget {
  const _RoomSceneBackground();

  @override
  Widget build(BuildContext context) {
    // 這裡不是要真的畫出照片，而是用暖色漸層與幾何塊模擬
    // 設計稿裡那種柔和、偏居家室內的主視覺質感。
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF3ECE1),
            Color(0xFFE4CBAE),
            Color(0xFFC8A377),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 18.w,
            top: 16.h,
            width: 120.w,
            height: 152.h,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.38),
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.4),
                ),
              ),
            ),
          ),
          Positioned(
            right: -18.w,
            top: 28.h,
            width: 120.w,
            height: 26.h,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(999.r),
              ),
            ),
          ),
          Positioned(
            right: 22.w,
            top: 48.h,
            width: 52.w,
            height: 10.h,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.42),
                borderRadius: BorderRadius.circular(999.r),
              ),
            ),
          ),
          Positioned(
            right: 24.w,
            bottom: 42.h,
            width: 82.w,
            height: 34.h,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFB98E5C).withValues(alpha: 0.32),
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 122.h,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Color(0x2D000000),
                    Color(0x52000000),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({
    required this.activeIndex,
    required this.count,
  });

  final int activeIndex;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == activeIndex;
        return Container(
          width: isActive ? 10.w : 8.w,
          height: isActive ? 10.w : 8.w,
          margin: EdgeInsets.symmetric(horizontal: 3.w),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFD8C7E8) : const Color(0xFFD8D8D8),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}

class _RecentCaseGrid extends StatelessWidget {
  const _RecentCaseGrid({
    required this.items,
    required this.onTap,
  });

  final List<_RecentCaseItem> items;
  final ValueChanged<_RecentCaseItem> onTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10.h,
        crossAxisSpacing: 10.w,
        childAspectRatio: 2.45,
      ),
      itemBuilder: (context, index) {
        final item = items[index];

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onTap(item),
            borderRadius: BorderRadius.circular(16.r),
            child: Container(
              padding: EdgeInsets.fromLTRB(12.w, 11.h, 12.w, 10.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F1F0),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 1.h,
                    right: 28.w,
                    child: Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        height: 1.25,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    bottom: 1.h,
                    right: 28.w,
                    child: Text(
                      item.lastViewedLabel,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: 20.sp,
                        color: const Color(0xFF4B5563),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CommonTopicGrid extends StatelessWidget {
  const _CommonTopicGrid({
    required this.items,
    required this.onTap,
  });

  final List<_CommonTopicItem> items;
  final ValueChanged<_CommonTopicItem> onTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10.h,
        crossAxisSpacing: 10.w,
        childAspectRatio: 1.18,
      ),
      itemBuilder: (context, index) {
        final item = items[index];

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onTap(item),
            borderRadius: BorderRadius.circular(14.r),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.icon,
                    style: TextStyle(fontSize: 26.sp, height: 1),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 14.sp,
                      height: 1.1,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

enum _TranslatorCardVariant { defaultStyle, compact }

class _StatuteDatabaseEntryCard extends StatelessWidget {
  const _StatuteDatabaseEntryCard({
    required this.onTap,
    required this.onChipTap,
  });

  final VoidCallback onTap;
  final ValueChanged<String> onChipTap;

  static const List<String> _quickQueries = [
    '民法',
    '刑法',
    '勞動基準法',
  ];

  @override
  Widget build(BuildContext context) {
    // 法條資料庫放在學習頁裡，是讓使用者從生活情境往正式條文查證；
    // 入口本身保持輕量，避免把整個資料庫直接塞進首頁造成閱讀負擔。
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: const Color(0xFFEFEFE8),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFE4E0D5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16.r),
              child: Row(
                children: [
                  Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFFDDE7D4),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.gavel_rounded,
                      size: 22.sp,
                      color: const Color(0xFF405238),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      '查民法、刑法、勞基法與常用條文',
                      style: TextStyle(
                        fontSize: 15.sp,
                        height: 1.35,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 22.sp,
                    color: const Color(0xFF4B5563),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 14.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: _quickQueries.map((query) {
              return _StatuteQuickQueryChip(
                label: query == '勞動基準法' ? '勞基法' : query,
                onTap: () => onChipTap(query),
              );
            }).toList(growable: false),
          ),
        ],
      ),
    );
  }
}

class _StatuteQuickQueryChip extends StatelessWidget {
  const _StatuteQuickQueryChip({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 7.h),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFAEC),
            borderRadius: BorderRadius.circular(999.r),
            border: Border.all(color: const Color(0xFFE2D7B8)),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF5C5C45),
            ),
          ),
        ),
      ),
    );
  }
}

class _TranslatorCard extends StatelessWidget {
  const _TranslatorCard({
    required this.article,
    required this.onTap,
    this.variant = _TranslatorCardVariant.defaultStyle,
  });

  final LearningMockArticle article;
  final VoidCallback onTap;
  final _TranslatorCardVariant variant;

  @override
  Widget build(BuildContext context) {
    final isCompact = variant == _TranslatorCardVariant.compact;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          padding: EdgeInsets.all(isCompact ? 14.w : 16.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F1DF),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '法條',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF8C8B59),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 22.w,
                    height: 22.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF3C3B31),
                        width: 1.2.w,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: isCompact ? 8.h : 10.h),
              Text(
                '民法第184條第1項前段：',
                style: TextStyle(
                  fontSize: isCompact ? 13.sp : 14.sp,
                  height: 1.32,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF5D5A38),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                article.summary,
                style: TextStyle(
                  fontSize: isCompact ? 12.sp : 13.sp,
                  height: 1.45,
                  color: const Color(0xFF524E35),
                ),
              ),
              if (!isCompact) ...[
                SizedBox(height: 10.h),
                Text(
                  '因故意或過失，不法侵害他人之權利者，負損害賠償責任。',
                  style: TextStyle(
                    fontSize: 13.sp,
                    height: 1.45,
                    color: const Color(0xFF524E35),
                  ),
                ),
              ],
              SizedBox(height: isCompact ? 10.h : 14.h),
              Align(
                alignment: Alignment.center,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD7D09D),
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Text(
                    '開始翻譯',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF433F24),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuizEntryCard extends StatelessWidget {
  const _QuizEntryCard({
    required this.entry,
    required this.onTap,
  });

  final LearningQuizEntryData entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Container(
          padding: EdgeInsets.fromLTRB(16.w, 14.h, 14.w, 14.h),
          decoration: BoxDecoration(
            color: const Color(0xFFEFEFE8),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: const Color(0xFFE4E0D5)),
          ),
          child: Row(
            children: [
              Container(
                width: 42.w,
                height: 42.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFD46A),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.quiz_outlined,
                  size: 22.sp,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '快速測驗',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      entry.subtitle,
                      style: TextStyle(
                        fontSize: 11.sp,
                        height: 1.35,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              Icon(
                Icons.arrow_forward_rounded,
                size: 22.sp,
                color: const Color(0xFF4B5563),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FaqFloatingChip extends StatelessWidget {
  const _FaqFloatingChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 46.w,
          height: 46.w,
          decoration: const BoxDecoration(
            color: Color(0xFFF1CB69),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0x19000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'FAQ',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RecentCaseItem {
  const _RecentCaseItem({
    required this.title,
    required this.lastViewedLabel,
    required this.article,
  });

  final String title;
  final String lastViewedLabel;
  final LearningMockArticle article;
}

class _CommonTopicItem {
  const _CommonTopicItem({
    required this.icon,
    required this.label,
    required this.article,
  });

  final String icon;
  final String label;
  final LearningMockArticle article;
}

final List<_RecentCaseItem> _recentCases = [
  _RecentCaseItem(
    title: '道路交通管理條例',
    lastViewedLabel: '最近一次查看：10分鐘前',
    article: learningTopic.heroArticle,
  ),
  _RecentCaseItem(
    title: '證券交易法',
    lastViewedLabel: '最近一次查看：15分鐘前',
    article: learningTopic.relatedTopics[0].article,
  ),
  _RecentCaseItem(
    title: '銀行法',
    lastViewedLabel: '最近一次查看：23分鐘前',
    article: learningTopic.supportItems[1].article,
  ),
  _RecentCaseItem(
    title: '少年事件處理法',
    lastViewedLabel: '最近一次查看：昨天',
    article: learningTopic.supportItems[2].article,
  ),
];

final List<_CommonTopicItem> _commonTopics = [
  _CommonTopicItem(
    icon: '🏠',
    label: '租屋',
    article: learningTopic.heroArticle,
  ),
  _CommonTopicItem(
    icon: '💼',
    label: '勞資',
    article: learningTopic.relatedTopics[0].article,
  ),
  _CommonTopicItem(
    icon: '🚗',
    label: '車禍',
    article: learningTopic.supportItems[2].article,
  ),
  _CommonTopicItem(
    icon: '📱',
    label: '網路',
    article: learningTopic.relatedTopics[1].article,
  ),
  _CommonTopicItem(
    icon: '👪',
    label: '家事',
    article: learningTopic.supportItems.first.article,
  ),
  _CommonTopicItem(
    icon: '⚖️',
    label: '刑事',
    article: learningTopic.supportItems[1].article,
  ),
];
