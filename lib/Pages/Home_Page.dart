import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/Reuseable/search_row_home_page.dart';
import 'package:lawapp/data/home_mock_data.dart';
import 'package:lawapp/component/home/home_discussion_section.dart';
import 'package:lawapp/component/home/home_news_section.dart';
import 'package:lawapp/component/home/home_newsletter_section.dart';
import 'package:lawapp/component/home/home_quiz_section.dart';
import 'package:lawapp/component/home/home_tracked_topics_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const double _sectionGap = 40;

  final TextEditingController controller = TextEditingController();
  final PageController newsletterController = PageController();
  final ScrollController scrollController = ScrollController();

  int newsletterPage = 0;
  int? selectedQuizIndex;
  bool showQuizResult = false;
  double searchCollapseProgress = 0;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    final nextProgress = (scrollController.offset / 56).clamp(0.0, 1.0);
    if ((nextProgress - searchCollapseProgress).abs() < 0.01) return;
    setState(() {
      searchCollapseProgress = nextProgress;
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

  void _submitQuiz() {
    if (selectedQuizIndex == null) return;
    setState(() {
      showQuizResult = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomScrollView(
            controller: scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    16.w,
                    106.h,
                    16.w,
                    28.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const HomeNewsSection(items: homeNewsItems),
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
                      ),
                      SizedBox(height: _sectionGap.h),
                      const HomeTrackedTopicsSection(items: homeTrackedTopics),
                      SizedBox(height: _sectionGap.h),
                      HomeQuizSection(
                        selectedQuizIndex: selectedQuizIndex,
                        showQuizResult: showQuizResult,
                        quizOptions: homeQuizOptions,
                        onSelect: (index) {
                          setState(() {
                            selectedQuizIndex = index;
                            showQuizResult = false;
                          });
                        },
                        onSubmit: _submitQuiz,
                      ),
                      SizedBox(height: _sectionGap.h),
                      const HomeDiscussionSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SearchRowHomePage(
            controller: controller,
            collapseProgress: searchCollapseProgress,
          ),
        ),
      ],
    );
  }
}
