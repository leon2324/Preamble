import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/components/home/home_news_section.dart';
import 'package:lawapp/components/home/legacy/home_discussion_section_legacy.dart'
    as legacy_home;
import 'package:lawapp/components/home/v2/home_v2_header.dart';
import 'package:lawapp/components/home/v2/home_v2_primitives.dart';
import 'package:lawapp/components/home/v2/home_v2_sections.dart';
import 'package:lawapp/components/home/v2/home_v2_bento_cards.dart';
import 'package:lawapp/data/mock_data/home/home_mock_data.dart';
import 'package:lawapp/data/mock_data/home/home_v2_mock_data.dart';
import 'package:lawapp/data/moj/moj_feed_item.dart';
import 'package:lawapp/pages/home/home_subpages.dart';
import 'package:lawapp/pages/learning/home_mission_quiz_page.dart';
import 'package:lawapp/pages/learning/know_law_page.dart';
import 'package:lawapp/pages/learning/statute_database_page.dart';
import 'package:lawapp/pages/profile/profile_page.dart';
import 'package:lawapp/theme/adaptive_layout.dart';
import 'package:lawapp/theme/app_colors.dart';

/// 新版首頁。
///
/// 台灣繁體中文教學註解：
/// 這個版本承接先前 prototype 的方向，已拆成多個 v2 元件檔案，
/// 之後若要逐步接 API、補上會員狀態與互動流程，可以從各 section 分別替換。
class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.onNavigateToTab,
  });

  final void Function(int targetOriginalIndex,
      {int? subTabIndex, String? toolTab}) onNavigateToTab;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _openStatuteDatabase() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (__) => const StatuteDatabasePage()),
    );
  }

  void _openOfficialFeed(MojFeedCategory category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (__) => OfficialFeedPage(category: category),
      ),
    );
  }

  void _openLifeLegalTips() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (__) => const LifeLegalTipsPage()),
    );
  }

  void _openLearningTopics() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (__) => const HomeLearningTopicsPage()),
    );
  }

  void _openProfilePage() {
    // 台灣繁體中文教學註解：
    // 首頁的「我的」現在直接開會員頁，不再依賴底部第 5 個 tab；
    // 這樣底部導覽可以改成新的「追蹤」，同時保留原本會員功能入口。
    Navigator.of(context).push(
      MaterialPageRoute(builder: (__) => const ProfilePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final layout = context.homeSearchLayout;
    final topContentPadding =
        context.hasLargeTopInset ? context.topSafeInset + 10.h : 18.h;

    return Stack(
      children: [
        ColoredBox(
          color: AppColors.background,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.fromLTRB(16.w, topContentPadding, 16.w, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          HomeV2HeroHeader(onProfileTap: _openProfilePage),
                          SizedBox(height: 14.h),
                          const HomeV2GreetingCard(),
                          SizedBox(height: 16.h),
                          const HomeV2QuickAskSection(),
                          SizedBox(height: 18.h),
                          const HomeV2WatchlistCard(),
                          SizedBox(height: 18.h),
                          SizedBox(
                            height: 155.h,
                            child: Row(
                              children: [
                                const Expanded(child: HomeV2AchievementCard()),
                                SizedBox(width: 12.w),
                                const Expanded(
                                    child: HomeV2DailyCaseStoryCard()),
                              ],
                            ),
                          ),
                          SizedBox(height: 18.h),
                          HomeV2ToolsDrawer(
                              onNavigateToTab: widget.onNavigateToTab),
                          SizedBox(height: 18.h),
                          HomeV2LawDatabaseCard(
                            onTap: _openStatuteDatabase,
                          ),
                          SizedBox(height: 18.h),
                          HomeV2SectionHeader(
                            title: '專題',
                            action: '全部專題',
                            onTap: _openLearningTopics,
                          ),
                          SizedBox(height: 10.h),
                          HomeV2TopicBentoGrid(
                            onTopicTap: (__) => _openLearningTopics(),
                          ),
                          SizedBox(height: 18.h),
                          HomeV2SectionHeader(
                            title: '生活避坑筆記',
                            action: '更多提醒',
                            onTap: _openLifeLegalTips,
                          ),
                          SizedBox(height: 10.h),
                          HomeV2NewsletterFocusCard(
                            item: homeNewsletterItems.first,
                            onTap: _openLifeLegalTips,
                          ),
                          SizedBox(height: 18.h),
                          HomeV2SocialNewsSection(
                            newsItems: homeNewsItems,
                            discussionFeed: homeDiscussionFeed,
                            onMoreNewsTap: () =>
                                _openOfficialFeed(MojFeedCategory.news),
                            onMoreDiscussionTap: () =>
                                widget.onNavigateToTab(3),
                          ),
                          SizedBox(height: 112.h),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (layout.hasLargeTopInset)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Container(
                height: layout.topMaskHeight.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0, 0.12, 0.28, 0.52, 1],
                    colors: [
                      AppColors.background,
                      AppColors.background.withValues(alpha: 0.92),
                      AppColors.background.withValues(alpha: 0.56),
                      AppColors.background.withValues(alpha: 0.18),
                      AppColors.background.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
