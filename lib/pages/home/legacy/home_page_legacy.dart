import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/components/home/home_news_section.dart';
import 'package:preamble/components/home/legacy/home_discussion_section_legacy.dart';
import 'package:preamble/components/home/legacy/home_newsletter_section_legacy.dart';
import 'package:preamble/components/home/legacy/home_quiz_section_legacy.dart';
import 'package:preamble/components/home/legacy/home_tracked_topics_section_legacy.dart';
import 'package:preamble/components/search/search_row_home_page.dart';
import 'package:preamble/data/mock_data/home/legacy/home_mock_data_legacy.dart';
import 'package:preamble/theme/adaptive_layout.dart';
import 'package:preamble/theme/app_colors.dart';

/// 首頁整合新聞、法律小報、追蹤議題、小任務與熱門討論等主要入口。
class HomePageLegacy extends StatefulWidget {
  const HomePageLegacy({
    super.key,
    required this.onNavigateToTab,
  });

  final ValueChanged<int> onNavigateToTab;

  @override
  State<HomePageLegacy> createState() => _HomePageLegacyState();
}

class _HomePageLegacyState extends State<HomePageLegacy> {
  static const double _sectionGap = 40;

  final TextEditingController controller = TextEditingController();
  final PageController newsletterController = PageController();
  final ScrollController scrollController = ScrollController();

  int newsletterPage = 0;
  int currentQuizQuestionIndex = 0;
  int? selectedQuizIndex;
  final Set<int> incorrectQuizIndices = <int>{};
  bool isQuizSolved = false;
  double searchCollapseProgress = 0;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    // 搜尋列收合程度直接跟 scroll offset 綁定，
    // 讓首頁不用再維護額外的動畫 controller。
    final nextProgress = (scrollController.offset / 56).clamp(0.0, 1.0);
    if ((nextProgress - searchCollapseProgress).abs() < 0.01) return;
    setState(() {
      searchCollapseProgress = nextProgress;
    });
  }

  void _resetQuizState() {
    selectedQuizIndex = null;
    incorrectQuizIndices.clear();
    isQuizSolved = false;
  }

  void _showNextQuizQuestion() {
    setState(() {
      currentQuizQuestionIndex =
          (currentQuizQuestionIndex + 1) % homeQuizQuestions.length;
      _resetQuizState();
    });
  }

  @override
  void dispose() {
    scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    controller.dispose();
    newsletterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final layout = context.homeSearchLayout;
    final currentQuizQuestion = homeQuizQuestions[currentQuizQuestionIndex];

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusScope.of(context).unfocus(),
            child: CustomScrollView(
              controller: scrollController,
              physics: const BouncingScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      16.w,
                      layout.contentTopPadding.h,
                      16.w,
                      // 直接加上鍵盤高度，確保底部留言欄在彈出鍵盤後
                      // 仍然有空間可以捲到可視範圍。
                      layout.contentBottomPadding.h +
                          MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HomeNewsSection(
                          items: homeNewsItems,
                          onMoreTap: () => widget.onNavigateToTab(3),
                        ),
                        SizedBox(height: _sectionGap.h),
                        HomeNewsletterSection(
                          controller: newsletterController,
                          items: homeNewsletterItems,
                          currentPage: newsletterPage,
                          onPageChanged: (index) {
                            setState(() {
                              newsletterPage = index;
                            });
                          },
                          onMoreTap: () => widget.onNavigateToTab(1),
                        ),
                        SizedBox(height: _sectionGap.h),
                        HomeTrackedTopicsSection(
                          items: homeTrackedTopics,
                          onMoreTap: () => widget.onNavigateToTab(2),
                        ),
                        SizedBox(height: _sectionGap.h),
                        HomeQuizSection(
                          question: currentQuizQuestion,
                          selectedQuizIndex: selectedQuizIndex,
                          incorrectQuizIndices: incorrectQuizIndices,
                          isSolved: isQuizSolved,
                          onNextQuestion: _showNextQuizQuestion,
                          onMoreTap: () => widget.onNavigateToTab(1),
                          onSelect: (index) {
                            setState(() {
                              selectedQuizIndex = index;

                              if (isQuizSolved) return;

                              if (currentQuizQuestion
                                  .options[index].isCorrect) {
                                isQuizSolved = true;
                              } else {
                                incorrectQuizIndices.add(index);
                              }
                            });
                          },
                        ),
                        SizedBox(height: _sectionGap.h),
                        HomeDiscussionSection(
                          onMoreTap: () => widget.onNavigateToTab(3),
                          feed: homeDiscussionFeed,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: layout.searchBarTopOffset.h,
          left: 0,
          right: 0,
          child: SearchRowHomePage(
            controller: controller,
            collapseProgress: searchCollapseProgress,
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
