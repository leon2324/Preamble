import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/components/home/home_news_section.dart';
import 'package:lawapp/components/home/legacy/home_discussion_section_legacy.dart'
    as legacy_home;
import 'package:lawapp/components/home/v2/home_v2_header.dart';
import 'package:lawapp/components/home/v2/home_v2_primitives.dart';
import 'package:lawapp/components/home/v2/home_v2_sections.dart';
import 'package:lawapp/data/mock_data/home/home_mock_data.dart';
import 'package:lawapp/pages/learning/home_mission_quiz_page.dart';
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

  final ValueChanged<int> onNavigateToTab;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _hasAnsweredMission = false;

  void _openMissionQuiz() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const HomeMissionQuizPage(),
      ),
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
                          const HomeV2HeroHeader(),
                          SizedBox(height: 14.h),
                          const HomeV2GreetingCard(),
                          SizedBox(height: 12.h),
                          const HomeV2AiAssistantCard(),
                          SizedBox(height: 18.h),
                          HomeV2SectionHeader(
                            title: '常見法律問題',
                            action: '查看更多',
                            onTap: () => widget.onNavigateToTab(1),
                          ),
                          SizedBox(height: 10.h),
                          const HomeV2QuickIssueGrid(),
                          SizedBox(height: 18.h),
                          HomeV2LawDatabaseCard(
                            onTap: () => widget.onNavigateToTab(1),
                          ),
                          SizedBox(height: 18.h),
                          HomeV2SectionHeader(
                            title: '給你的小任務(*¯︶¯*)',
                            action: _hasAnsweredMission ? null : '更多題目',
                            onTap:
                                _hasAnsweredMission ? null : _openMissionQuiz,
                          ),
                          SizedBox(height: 10.h),
                          HomeV2DailyMissionCard(
                            onAnsweredStateChanged: (hasAnswered) {
                              if (_hasAnsweredMission == hasAnswered) return;
                              setState(() {
                                _hasAnsweredMission = hasAnswered;
                              });
                            },
                            onOpenMore: _openMissionQuiz,
                          ),
                          SizedBox(height: 18.h),
                          HomeV2SectionHeader(
                            title: '法律新知小報',
                            action: '更多小報',
                            onTap: () => widget.onNavigateToTab(1),
                          ),
                          SizedBox(height: 10.h),
                          const HomeV2NewsletterCard(),
                          SizedBox(height: 18.h),
                          HomeV2SectionHeader(
                            title: '今日新聞',
                            action: '看全部',
                            onTap: () => widget.onNavigateToTab(3),
                          ),
                          SizedBox(height: 10.h),
                          HomeNewsSection(
                            items: homeNewsItems,
                            onMoreTap: () => widget.onNavigateToTab(3),
                            showHeader: false,
                          ),
                          SizedBox(height: 18.h),
                          HomeV2SectionHeader(
                            title: '大家都在討論',
                            action: '看全部',
                            onTap: () => widget.onNavigateToTab(3),
                          ),
                          SizedBox(height: 10.h),
                          // 台灣繁體中文教學註解：
                          // 這裡保留舊版「大家都在討論」的完整互動內容，
                          // 但標題列改由新版 Header 統一樣式，避免首頁不同區塊的標題長相不一致。
                          legacy_home.HomeDiscussionSection(
                            onMoreTap: () => widget.onNavigateToTab(3),
                            feed: homeDiscussionFeed,
                            showHeader: false,
                          ),
                          SizedBox(height: 18.h),
                          HomeV2SectionHeader(
                            title: '專題',
                            action: '全部專題',
                            onTap: () => widget.onNavigateToTab(1),
                          ),
                          SizedBox(height: 10.h),
                          const HomeV2TopicSeries(),
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
