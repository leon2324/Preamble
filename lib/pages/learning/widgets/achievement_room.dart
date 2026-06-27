import 'package:flutter/material.dart';
import 'package:preamble/components/shared/custom_toast.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/data/learning/learning_game_state.dart';
import 'package:preamble/pages/learning/widgets/notebook_aesthetics.dart';
import 'package:preamble/theme/app_colors.dart';
import 'package:preamble/components/home/v2/home_v2_palette.dart';
import 'package:preamble/data/mock_data/learning/learning_mock_data.dart';
import 'package:preamble/features/case_time_machine/widgets/case_time_machine_svg_icon.dart';
import 'package:intl/intl.dart';
import 'package:preamble/pages/learning/learning_mock_detail_page.dart';
import 'package:preamble/data/learning/supabase_learning_service.dart';
import 'package:preamble/pages/learning/widgets/notebook_cover_editor_page.dart';
import 'achievement_room_badges.dart';
import 'achievement_room_wisdom_tree_painter.dart';
import 'achievement_saved_notes_page.dart';
import 'achievement_history_section.dart';

class AchievementRoomPage extends StatefulWidget {
  const AchievementRoomPage({super.key});

  @override
  State<AchievementRoomPage> createState() => _AchievementRoomPageState();
}

class _AchievementRoomPageState extends State<AchievementRoomPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _treeAnimController;
  double _waterScale = 1.0;
  bool _showWaterParticles = false;

  @override
  void initState() {
    super.initState();
    _treeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _treeAnimController.dispose();
    super.dispose();
  }

  void _triggerWatering() {
    if (_waterScale != 1.0) return;
    setState(() {
      _waterScale = 1.12;
      _showWaterParticles = true;
    });
    Future.delayed(const Duration(milliseconds: 140), () {
      if (mounted) {
        setState(() {
          _waterScale = 0.94;
        });
      }
    });
    Future.delayed(const Duration(milliseconds: 260), () {
      if (mounted) {
        setState(() {
          _waterScale = 1.0;
        });
      }
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _showWaterParticles = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = LearningGameState.instance;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '小法助成長檔案與成就室',
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle:
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ),
      body: ListenableBuilder(
        listenable: gameState,
        builder: (context, _) {
          return NotebookBackground(
            child: ListView(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 40.h),
              children: [
                // 1. 吉祥物成長狀態卡片
                _buildMascotStatusCard(gameState),
                SizedBox(height: 12.h),

                // 2. 榮譽法律徽章牆
                AchievementBadgeWall(gameState: gameState),
                SizedBox(height: 12.h),

                // 3. 我的備忘錄 (錯題本 + 儲存證據清單)
                _buildMemoSection(gameState),
                SizedBox(height: 12.h),

                // 4. 解答與學習歷史紀錄
                AchievementHistorySection(
                  gameState: gameState,
                  onHistoryTap: (record) =>
                      _showHistoryDetailSheet(context, record),
                  onShowAllHistory: () => _showAllHistoryPage(gameState),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 1. 吉祥物狀態卡
  // 1. 吉祥物狀態卡 (現改版為：動態法學智慧樹與奔跑小孩主視覺)
  Widget _buildMascotStatusCard(LearningGameState gameState) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return NotebookCard(
      hasPaperClip: true,
      padding: EdgeInsets.zero,
      backgroundColor: isDark ? const Color(0xFF161C23) : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. 動態畫布區域
          GestureDetector(
            onTap: _triggerWatering, // 點擊樹木澆水互動
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
              child: Stack(
                children: [
                  SizedBox(
                    height: 195.h,
                    width: double.infinity,
                    child: AnimatedBuilder(
                      animation: _treeAnimController,
                      builder: (context, _) {
                        return CustomPaint(
                          painter: WisdomTreePainter(
                            level: gameState.level,
                            completedUnits: gameState.completedSteps.length,
                            animationValue: _treeAnimController.value,
                            treeScale: _waterScale,
                            showParticles: _showWaterParticles,
                          ),
                        );
                      },
                    ),
                  ),
                  // 澆水浮動提示標籤
                  Positioned(
                    top: 10.h,
                    left: 10.w,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                            color:
                                const Color(0xFF9EC979).withValues(alpha: 0.5)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.water_drop,
                              color: Colors.blue[400], size: 12.sp),
                          SizedBox(width: 2.w),
                          Text(
                            '點擊大樹澆水',
                            style: TextStyle(
                              fontSize: 9.5.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 2. 下半部膠囊進度條與資訊
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: HomeV2Palette.aiYellow,
                        borderRadius: BorderRadius.circular(6.r),
                        border: Border.all(color: const Color(0xFFE8B95F)),
                      ),
                      child: Text(
                        'Level ${gameState.level} / ${gameState.maxLevel}',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w900,
                          color: HomeV2Palette.ink,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      gameState.levelTitle,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '經驗值：${gameState.experience} / ${gameState.nextLevelXp} XP',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                // 進度條
                ClipRRect(
                  borderRadius: BorderRadius.circular(99.r),
                  child: LinearProgressIndicator(
                    value: gameState.levelProgress,
                    minHeight: 8.h,
                    backgroundColor: isDark
                        ? const Color(0xFF2D3845)
                        : const Color(0xFFEFECE6),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      HomeV2Palette.trustGreen,
                    ),
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  gameState.level >= gameState.maxLevel
                      ? '已達最高 Level ${gameState.maxLevel}，智慧法治神木已完全長成！🌳'
                      : '再獲得 ${gameState.xpToNextLevel} XP 可升級為「${gameState.nextLevelTitle}」並壯大樹木與解鎖可愛奔跑小孩！',
                  style: TextStyle(
                    fontSize: 9.sp,
                    color: AppColors.textMuted,
                  ),
                ),
                SizedBox(height: 12.h),
                const Divider(),
                SizedBox(height: 6.h),
                ElevatedButton.icon(
                  icon: Icon(Icons.palette_rounded, size: 14.sp),
                  label: Text('自訂我的法學筆記本封面',
                      style: TextStyle(
                          fontSize: 11.5.sp, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HomeV2Palette.mint,
                    foregroundColor: HomeV2Palette.trustGreen,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r)),
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const NotebookCoverEditorPage()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 3. 我的備忘錄
  Widget _buildMemoSection(LearningGameState gameState) {
    return NotebookCard(
      hasBinderRings: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CtmSvgIcon(CtmSvgIcons.bookmark,
                  color: HomeV2Palette.trustGreen, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                '我的備忘錄',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // 錯題本入口
          ListTile(
            leading: CtmSvgIcon(CtmSvgIcons.bookOpen,
                color: const Color(0xFFE88B8B), size: 20.sp),
            title: Text(
              '📕 我的錯題本',
              style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '目前有 ${gameState.incorrectQuestions.length} 題答錯的題目',
              style: TextStyle(fontSize: 11.sp),
            ),
            trailing: CtmSvgIcon(CtmSvgIcons.chevronRight,
                size: 16.sp, color: Colors.grey),
            onTap: () => _openIncorrectQuestions(gameState),
          ),
          const Divider(),

          // 證據清單入口
          ListTile(
            leading: CtmSvgIcon(CtmSvgIcons.filePen,
                color: const Color(0xFF6FA8DC), size: 20.sp),
            title: Text(
              '💾 儲存的證據清單',
              style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '目前已儲存 ${gameState.savedEvidenceLists.length} 份清單',
              style: TextStyle(fontSize: 11.sp),
            ),
            trailing: CtmSvgIcon(CtmSvgIcons.chevronRight,
                size: 16.sp, color: Colors.grey),
            onTap: () => _openSavedEvidenceLists(gameState),
          ),
          const Divider(),

          // 收藏的法律金句與筆記入口
          ListTile(
            leading: CtmSvgIcon(CtmSvgIcons.bookmark,
                color: const Color(0xFFE8B95F), size: 20.sp),
            title: Text(
              '🏷️ 收藏的法律金句與筆記',
              style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '目前已儲存 ${gameState.savedQuotes.length + gameState.savedArticles.length + gameState.savedHighlights.length} 項內容',
              style: TextStyle(fontSize: 11.sp),
            ),
            trailing: CtmSvgIcon(CtmSvgIcons.chevronRight,
                size: 16.sp, color: Colors.grey),
            onTap: () => _openSavedNotesPage(gameState),
          ),
        ],
      ),
    );
  }

  void _showHistoryDetailSheet(
      BuildContext context, Map<String, dynamic> record) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCorrect = record['isCorrect'] as bool? ?? false;
    final category = record['category'] as String? ?? '法學知識';
    final topicSlug = record['topicSlug'] as String?;
    final stepLabel = record['stepLabel'] as String? ?? '專題測驗';
    final question = record['question'] as String? ?? '';
    final options = List<String>.from(record['options'] ?? []);
    final selectedAnswer = record['selectedAnswer'] as String? ?? '';
    final correctAnswer = record['correctAnswer'] as String? ?? '';
    final explanation = record['explanation'] as String? ?? '';
    final themeColor = achievementHistoryCategoryColor(category);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A222D) : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.r),
              topRight: Radius.circular(24.r),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
              16.w, 12.h, 16.w, MediaQuery.of(context).padding.bottom + 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: themeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: themeColor,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    stepLabel,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: isCorrect
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isCorrect ? Icons.check_circle : Icons.cancel,
                          color: isCorrect ? Colors.green : Colors.red,
                          size: 14.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          isCorrect ? '解答正確' : '解答錯誤',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: isCorrect ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Text(
                '題目：',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                question,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF263238) : Colors.grey[50],
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isDark ? const Color(0xFF37474F) : Colors.grey[200]!,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person,
                            size: 16.sp,
                            color: isCorrect ? Colors.green : Colors.red),
                        SizedBox(width: 6.w),
                        Text(
                          '你的解答：',
                          style: TextStyle(
                              fontSize: 12.sp,
                              color:
                                  isDark ? Colors.grey[300] : Colors.grey[700]),
                        ),
                        Expanded(
                          child: Text(
                            selectedAnswer,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: isCorrect ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (!isCorrect) ...[
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Icon(Icons.check_circle_outline,
                              size: 16.sp, color: Colors.green),
                          SizedBox(width: 6.w),
                          Text(
                            '正確解答：',
                            style: TextStyle(
                                fontSize: 12.sp,
                                color: isDark
                                    ? Colors.grey[300]
                                    : Colors.grey[700]),
                          ),
                          Expanded(
                            child: Text(
                              correctAnswer,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                '💡 實務解析：',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: themeColor,
                ),
              ),
              SizedBox(height: 6.h),
              Container(
                constraints: BoxConstraints(maxHeight: 180.h),
                child: SingleChildScrollView(
                  child: Text(
                    explanation,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('關閉'),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _navigateToQuizUnit(
                          category,
                          stepLabel,
                          topicSlug: topicSlug,
                        );
                      },
                      child: Text(isCorrect ? '前往複習' : '重新挑戰'),
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

  void _showAllHistoryPage(LearningGameState gameState) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('📜 全部解答歷史'),
            centerTitle: true,
          ),
          body: ListenableBuilder(
            listenable: gameState,
            builder: (context, _) {
              if (gameState.quizHistory.isEmpty) {
                return const Center(child: Text('目前沒有解答歷史紀錄。🌱'));
              }
              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                itemCount: gameState.quizHistory.length,
                itemBuilder: (context, index) {
                  return AchievementHistoryItem(
                    record: gameState.quizHistory[index],
                    onTap: () => _showHistoryDetailSheet(
                      context,
                      gameState.quizHistory[index],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _navigateToQuizUnit(
    String category,
    String stepLabel, {
    String? topicSlug,
  }) async {
    final normalizedTopicSlug = topicSlug?.trim();
    LearningTopicData? topic;
    var routeCategory = category;

    // 歷史紀錄導頁優先使用穩定 topicSlug；舊紀錄則相容分類 key 與顯示標題。
    if (normalizedTopicSlug != null && normalizedTopicSlug.isNotEmpty) {
      topic = featuredLearningTopicsBySlug[normalizedTopicSlug];
      if (topic != null) {
        for (final entry in featuredLearningTopics.entries) {
          if (entry.value.topicSlug == normalizedTopicSlug) {
            routeCategory = entry.key;
            break;
          }
        }
      }
    }

    topic ??= featuredLearningTopics[category];
    if (topic == null) {
      for (final entry in featuredLearningTopics.entries) {
        if (entry.value.title == category ||
            entry.value.topicSlug == normalizedTopicSlug) {
          topic = entry.value;
          routeCategory = entry.key;
          break;
        }
      }
    }

    if (topic == null) {
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
              Text('正在從雲端載入專題內容...'),
            ],
          ),
          duration: Duration(seconds: 1),
        ),
      );
      topic =
          await SupabaseLearningService.instance.fetchTopicByTitle(category);
      if (!mounted) return;
    }

    if (topic == null) {
      CustomToast.show(context, '找不到對應的主題，可能尚未同步或已移除。');

      return;
    }

    final finalTopic = topic;
    LearningMockArticle? targetArticle;
    String? finalStepLabel;

    if (stepLabel == '專題測驗') {
      finalStepLabel = 'STEP 5';
      final step5Unit = finalTopic.units.firstWhere(
        (u) => u.stepLabel == 'STEP 5',
        orElse: () => finalTopic.units.last,
      );
      targetArticle = step5Unit.article;
    } else {
      for (final unit in finalTopic.units) {
        if (unit.stepLabel == stepLabel) {
          targetArticle = unit.article;
          finalStepLabel = unit.stepLabel;
          break;
        }
      }
    }

    if (targetArticle != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => LearningMockDetailPage(
            article: targetArticle!,
            unitStepLabel: finalStepLabel,
            category: routeCategory,
            topicSlug: finalTopic.topicSlug,
          ),
        ),
      );
    } else {
      CustomToast.show(context, '找不到對應的學習單元。');

    }
  }

  // 開啟錯題本
  void _openIncorrectQuestions(LearningGameState gameState) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('📕 我的錯題本')),
          body: ListenableBuilder(
            listenable: gameState,
            builder: (context, _) {
              if (gameState.incorrectQuestions.isEmpty) {
                return const Center(
                  child: Text('目前沒有答錯的題目，太棒了！👏'),
                );
              }
              return NotebookBackground(
                child: ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: gameState.incorrectQuestions.length,
                  itemBuilder: (context, index) {
                    final item = gameState.incorrectQuestions[index];
                    return NotebookCard(
                      backgroundColor: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 3.h),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFBE8E7),
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Text(
                                  '待挑戰',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: const Color(0xFFC00000),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: CtmSvgIcon(CtmSvgIcons.xCircle,
                                    size: 18.sp, color: Colors.grey),
                                onPressed: () {
                                  setState(() {
                                    gameState.incorrectQuestions
                                        .removeAt(index);
                                  });
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            item['question'],
                            style: TextStyle(
                              fontSize: 14.5.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            '你的答案：${item['wrongAnswer']}',
                            style: const TextStyle(
                                color: Colors.red, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '正確答案：${item['correctAnswer']}',
                            style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 8.h),
                          Container(
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F2EA),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Text(
                              '白話解析：\n${item['explanation']}',
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.textSecondary,
                                  height: 1.4),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          ElevatedButton.icon(
                            icon: CtmSvgIcon(CtmSvgIcons.clock,
                                size: 14.sp, color: HomeV2Palette.trustGreen),
                            label: const Text('重新挑戰'),
                            onPressed: () => _rechallengeQuestion(item),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // 重新挑戰錯題
  void _rechallengeQuestion(Map<String, dynamic> incorrectItem) {
    final String qText = incorrectItem['question'];
    final String correctAns = incorrectItem['correctAnswer'];
    final String explanation = incorrectItem['explanation'] ?? '';
    final List<String> options = List<String>.from(
      incorrectItem['options'] ?? [incorrectItem['wrongAnswer'], correctAns],
    );

    int? tempSelectedIndex;
    bool isAnswered = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 30.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '重新挑戰 🎯',
                    style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: HomeV2Palette.trustGreen),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    qText,
                    style:
                        TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 14.h),
                  ...List.generate(options.length, (index) {
                    final optTitle = options[index];
                    final isSelected = tempSelectedIndex == index;
                    final isCorrectOpt = isAnswered && optTitle == correctAns;
                    final isWrongOpt =
                        isAnswered && isSelected && optTitle != correctAns;

                    Color cardBg = Colors.white;
                    Color borderCol = const Color(0xFFE8E4DC);
                    if (isCorrectOpt) {
                      cardBg = const Color(0xFFEAF6E2);
                      borderCol = const Color(0xFF9EC979);
                    } else if (isWrongOpt) {
                      cardBg = const Color(0xFFFBE8E7);
                      borderCol = const Color(0xFFE4A29D);
                    } else if (isSelected) {
                      cardBg = const Color(0xFFFFF7E6);
                      borderCol = const Color(0xFFE8B95F);
                    }

                    return Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: InkWell(
                        onTap: isAnswered
                            ? null
                            : () {
                                setModalState(() {
                                  tempSelectedIndex = index;
                                });
                              },
                        borderRadius: BorderRadius.circular(12.r),
                        child: Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: cardBg,
                            border: Border.all(color: borderCol, width: 1.2.w),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            optTitle,
                            style: TextStyle(
                                fontSize: 13.sp, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    );
                  }),
                  SizedBox(height: 16.h),
                  if (!isAnswered)
                    FilledButton(
                      onPressed: tempSelectedIndex == null
                          ? null
                          : () {
                              setModalState(() {
                                isAnswered = true;
                                final pickedText = options[tempSelectedIndex!];
                                final pickedCorrect = pickedText == correctAns;
                                if (pickedCorrect) {
                                  LearningGameState.instance
                                      .removeIncorrectQuestion(qText);
                                } else {
                                  LearningGameState.instance
                                      .addIncorrectQuestion(
                                    qText,
                                    pickedText,
                                    correctAns,
                                    explanation,
                                    options,
                                  );
                                }
                              });
                            },
                      style: FilledButton.styleFrom(
                          backgroundColor: HomeV2Palette.trustGreen),
                      child: const Text('送出答案'),
                    )
                  else ...[
                    Text(
                      options[tempSelectedIndex!] == correctAns
                          ? '答對了！🎉 經驗值 +15'
                          : '可惜又答錯了，再看一次白話解析吧！',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: options[tempSelectedIndex!] == correctAns
                            ? Colors.green.shade800
                            : Colors.red.shade800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12.h),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('關閉'),
                    )
                  ]
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 開啟儲存的證據清單
  void _openSavedEvidenceLists(LearningGameState gameState) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('💾 儲存的證據清單')),
          body: ListenableBuilder(
            listenable: gameState,
            builder: (context, _) {
              if (gameState.savedEvidenceLists.isEmpty) {
                return const Center(
                  child: Text('目前尚未儲存任何證據清單，\n可去「生活工具箱」勾選並儲存！'),
                );
              }
              return NotebookBackground(
                child: ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: gameState.savedEvidenceLists.length,
                  itemBuilder: (context, index) {
                    final item = gameState.savedEvidenceLists[index];
                    final checkedItems =
                        List<String>.from(item['checkedItems']);
                    final allItems = List<String>.from(item['allItems']);
                    final String timeStr = DateFormat('yyyy/MM/dd HH:mm')
                        .format(DateTime.parse(item['timestamp']));

                    return NotebookCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item['title'],
                                  style: TextStyle(
                                    fontSize: 14.5.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: CtmSvgIcon(CtmSvgIcons.xCircle,
                                    size: 18.sp, color: Colors.grey),
                                onPressed: () {
                                  gameState.deleteEvidenceList(index);
                                },
                              ),
                            ],
                          ),
                          Text(
                            '儲存時間：$timeStr',
                            style: TextStyle(
                                fontSize: 10.sp, color: AppColors.textMuted),
                          ),
                          SizedBox(height: 8.h),
                          ...allItems.map((name) {
                            final isChecked = checkedItems.contains(name);
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 2.h),
                              child: Row(
                                children: [
                                  CtmSvgIcon(
                                    isChecked
                                        ? CtmSvgIcons.star
                                        : CtmSvgIcons.timeline,
                                    color: isChecked
                                        ? HomeV2Palette.trustGreen
                                        : Colors.grey,
                                    size: 18.sp,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    name,
                                    style: TextStyle(
                                      fontSize: 12.5.sp,
                                      decoration: isChecked
                                          ? TextDecoration.lineThrough
                                          : null,
                                      color: isChecked
                                          ? AppColors.textMuted
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          SizedBox(height: 12.h),
                          Row(
                            children: [
                              Text(
                                '進度：${checkedItems.length} / ${allItems.length}',
                                style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.bold,
                                    color: HomeV2Palette.trustGreen),
                              ),
                              const Spacer(),
                              ElevatedButton.icon(
                                icon: CtmSvgIcon(CtmSvgIcons.externalLink,
                                    size: 14.sp, color: Colors.white),
                                label: const Text('複製清單'),
                                onPressed: () {
                                  final title =
                                      item['title'] as String? ?? '學習清單';
                                  final content = [
                                    '【$title】',
                                    ...checkedItems.map((entry) => '✓ $entry'),
                                  ].join('\n');
                                  Clipboard.setData(
                                      ClipboardData(text: content));
                                  CustomToast.show(context, '已複製「$title」清單文字，可貼到外部工具保存。');

                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // 開啟收藏與筆記頁面
  void _openSavedNotesPage(LearningGameState gameState) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SavedNotesPage(),
      ),
    );
  }
}
