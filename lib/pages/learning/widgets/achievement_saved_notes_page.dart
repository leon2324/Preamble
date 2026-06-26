import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:preamble/components/home/v2/home_v2_palette.dart';
import 'package:preamble/data/learning/learning_game_state.dart';
import 'package:preamble/data/learning/supabase_learning_service.dart';
import 'package:preamble/data/mock_data/learning/learning_mock_data.dart';
import 'package:preamble/features/case_time_machine/widgets/case_time_machine_svg_icon.dart';
import 'package:preamble/pages/learning/learning_mock_detail_page.dart';
import 'package:preamble/pages/learning/widgets/notebook_aesthetics.dart';
import 'package:preamble/theme/app_colors.dart';

// 成就室的收藏筆記頁。
// 只放收藏金句、文章收藏與重點劃記頁籤，不放成就室主頁、歷史紀錄或錯題本邏輯。

// 獨立的收藏與筆記查看頁面
class SavedNotesPage extends StatefulWidget {
  const SavedNotesPage({super.key});

  @override
  State<SavedNotesPage> createState() => _SavedNotesPageState();
}

class _SavedNotesPageState extends State<SavedNotesPage> {
  void _navigateToArticle(String articleTitle) async {
    LearningMockArticle? matchedArticle;
    String? matchedCategory;
    String? stepLabel;

    for (final entry in featuredLearningTopics.entries) {
      final topicName = entry.key;
      final topic = entry.value;

      if (topic.heroArticle.title == articleTitle) {
        matchedArticle = topic.heroArticle;
        matchedCategory = topicName;
        break;
      }

      for (final unit in topic.units) {
        if (unit.article.title == articleTitle) {
          matchedArticle = unit.article;
          matchedCategory = topicName;
          stepLabel = unit.stepLabel;
          break;
        }
      }
      if (matchedArticle != null) break;

      for (final related in topic.relatedTopics) {
        if (related.article.title == articleTitle) {
          matchedArticle = related.article;
          matchedCategory = topicName;
          break;
        }
      }
      if (matchedArticle != null) break;

      for (final support in topic.supportItems) {
        if (support.article.title == articleTitle) {
          matchedArticle = support.article;
          matchedCategory = topicName;
          break;
        }
      }
      if (matchedArticle != null) break;
    }

    if (matchedArticle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              ),
              SizedBox(width: 12),
              Text('正在從雲端載入文章內容...'),
            ],
          ),
          duration: Duration(seconds: 1),
        ),
      );
      matchedArticle = await SupabaseLearningService.instance
          .fetchArticleByTitle(articleTitle);
      if (!mounted) return;
      if (matchedArticle != null) {
        matchedCategory = matchedArticle.category ?? '法律情境';
        if (matchedArticle.stepNumber != null) {
          stepLabel = 'STEP ${matchedArticle.stepNumber}';
        }
      }
    }

    if (matchedArticle != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => LearningMockDetailPage(
            article: matchedArticle!,
            unitStepLabel: stepLabel,
            category: matchedCategory,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('找不到對應的學習單元，可能已移除。')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = LearningGameState.instance;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '收藏的法律金句與筆記',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            labelColor: HomeV2Palette.trustGreen,
            unselectedLabelColor: Colors.grey,
            indicatorColor: HomeV2Palette.trustGreen,
            labelStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: '金句收藏'),
              Tab(text: '單元收藏'),
              Tab(text: '重點劃記'),
            ],
          ),
        ),
        body: ListenableBuilder(
          listenable: gameState,
          builder: (context, _) {
            return NotebookBackground(
              child: TabBarView(
                children: [
                  _buildQuotesTab(gameState),
                  _buildArticlesTab(gameState),
                  _buildHighlightsTab(gameState),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuotesTab(LearningGameState gameState) {
    if (gameState.savedQuotes.isEmpty) {
      return const Center(
        child: Text('目前尚未收藏任何金句。可在學習單元內點擊星星收藏金句！'),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      itemCount: gameState.savedQuotes.length,
      itemBuilder: (context, index) {
        final item = gameState.savedQuotes[index];
        final String quote = item['quote'] ?? '';
        final String articleTitle = item['articleTitle'] ?? '';
        String timeStr = '';
        if (item['timestamp'] != null) {
          try {
            timeStr = DateFormat('yyyy/MM/dd HH:mm')
                .format(DateTime.parse(item['timestamp']));
          } catch (_) {}
        }

        return NotebookCard(
          margin: EdgeInsets.only(bottom: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      '「$quote」',
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        height: 1.45,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: CtmSvgIcon(
                      CtmSvgIcons.xCircle,
                      size: 18.sp,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      gameState.toggleQuoteSave(quote, articleTitle);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('已取消收藏該金句！'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _navigateToArticle(articleTitle),
                      child: Row(
                        children: [
                          CtmSvgIcon(
                            CtmSvgIcons.bookOpen,
                            size: 14.sp,
                            color: HomeV2Palette.trustGreen,
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              articleTitle,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: HomeV2Palette.trustGreen,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Text(
                    timeStr,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildArticlesTab(LearningGameState gameState) {
    if (gameState.savedArticles.isEmpty) {
      return const Center(
        child: Text('目前尚未收藏任何學習單元。可在單元頁面右上角點擊書籤進行收藏！'),
      );
    }

    final allMockArticles = [
      learningTopic.heroArticle,
      ...learningTopic.units.map((u) => u.article),
      ...learningTopic.relatedTopics.map((r) => r.article),
      ...learningTopic.supportItems.map((s) => s.article),
    ];

    final savedTitlesList = gameState.savedArticles.toList();

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      itemCount: savedTitlesList.length,
      itemBuilder: (context, index) {
        final title = savedTitlesList[index];
        LearningMockArticle? matchedArticle;
        for (final article in allMockArticles) {
          if (article.title == title) {
            matchedArticle = article;
            break;
          }
        }

        final badge = matchedArticle?.badge ?? '學習單元';
        final summary = matchedArticle?.summary ?? '點選進入學習單元閱讀詳細內容。';
        final readTime = matchedArticle?.readTime ?? '3 分鐘';

        return NotebookCard(
          margin: EdgeInsets.only(bottom: 10.h),
          child: InkWell(
            onTap: () => _navigateToArticle(title),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: HomeV2Palette.mint,
                        borderRadius: BorderRadius.circular(999.r),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          color: HomeV2Palette.trustGreen,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: CtmSvgIcon(
                        CtmSvgIcons.bookmark,
                        size: 18.sp,
                        color: HomeV2Palette.trustGreen,
                      ),
                      onPressed: () {
                        gameState.toggleArticleSave(title);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('已取消收藏本單元！'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  summary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    CtmSvgIcon(
                      CtmSvgIcons.clock,
                      size: 12.sp,
                      color: Colors.grey,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      readTime,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHighlightsTab(LearningGameState gameState) {
    if (gameState.savedHighlights.isEmpty) {
      return const Center(
        child: Text('目前尚未劃記任何重點。可在學習單元正文中選取文字並點擊「劃記重點 ✍️」！'),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      itemCount: gameState.savedHighlights.length,
      itemBuilder: (context, index) {
        final item = gameState.savedHighlights[index];
        final String highlight = item['highlight'] ?? '';
        final String articleTitle = item['articleTitle'] ?? '';
        String timeStr = '';
        if (item['timestamp'] != null) {
          try {
            timeStr = DateFormat('yyyy/MM/dd HH:mm')
                .format(DateTime.parse(item['timestamp']));
          } catch (_) {}
        }

        return NotebookCard(
          margin: EdgeInsets.only(bottom: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: Colors.yellow.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        highlight,
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: CtmSvgIcon(
                      CtmSvgIcons.xCircle,
                      size: 18.sp,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      gameState.removeHighlight(index);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('已刪除此劃記重點！'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _navigateToArticle(articleTitle),
                      child: Row(
                        children: [
                          CtmSvgIcon(
                            CtmSvgIcons.bookOpen,
                            size: 14.sp,
                            color: HomeV2Palette.trustGreen,
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              articleTitle,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: HomeV2Palette.trustGreen,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Text(
                    timeStr,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
