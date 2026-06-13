import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/data/mock_data/learning/learning_mock_data.dart';
import 'package:lawapp/theme/app_colors.dart';
import 'package:lawapp/data/learning/learning_game_state.dart';
import 'package:lawapp/components/home/v2/home_v2_palette.dart';
import 'package:lawapp/pages/learning/widgets/notebook_aesthetics.dart';
import 'package:lawapp/features/case_time_machine/widgets/case_time_machine_svg_icon.dart';
import 'package:lawapp/pages/learning/know_law_page.dart'; // To access LawAssistantSearchPage
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

class LearningMockDetailPage extends StatefulWidget {
  const LearningMockDetailPage({
    super.key,
    required this.article,
    this.unitStepLabel,
  });

  final LearningMockArticle article;
  final String? unitStepLabel;

  @override
  State<LearningMockDetailPage> createState() => _LearningMockDetailPageState();
}

class _LearningMockDetailPageState extends State<LearningMockDetailPage> {
  int? _selectedQuizIndex;
  bool _isQuizAnswered = false;

  // 1 題思辨測試題目資料
  late final Map<String, dynamic>? _quizData;

  String _guessCategory(String title) {
    if (title.contains('租屋') || title.contains('押金') || title.contains('房東') || title.contains('房客')) return '租屋糾紛';
    if (title.contains('職場') || title.contains('加班') || title.contains('工時') || title.contains('離職')) return '職場權益';
    if (title.contains('網購') || title.contains('退貨') || title.contains('消保') || title.contains('消費')) return '網購消費';
    if (title.contains('肖像') || title.contains('發文') || title.contains('個資') || title.contains('隱私')) return '個資隱私';
    if (title.contains('車禍') || title.contains('事故') || title.contains('碰撞') || title.contains('交通')) return '車禍事故';
    return '法律常識';
  }

  @override
  void initState() {
    super.initState();
    _quizData = widget.article.quizData ?? _getQuizForStep(widget.unitStepLabel);
    final cat = widget.article.category ?? _guessCategory(widget.article.title);
    LearningGameState.instance.markCategoryViewed(cat);
  }

  Map<String, dynamic>? _getQuizForStep(String? step) {
    if (step == null) return null;
    switch (step) {
      case 'STEP 1':
        return {
          'question': '阿榮退租時，房東說沙發有自然老化的皮裂，要扣押金 3000 元買新沙發。請問這合理嗎？',
          'options': [
            'A. 合理，房東收押金就是為了能扣除任何老舊家具的維護費。',
            'B. 不合理，自然老化耗損屬於正常使用，折舊與修繕責任應由房東承擔，不得扣抵押金。',
            'C. 合理，家具折舊費用本來就是由租客全額補貼新家具。'
          ],
          'correctIndex': 1,
          'explanation': '自然耗損非屬人為故意或過失之損害，房東應自行承擔家具耗損，不得據此扣抵租客的押金。',
        };
      case 'STEP 2':
        return {
          'question': '大雄租約寫明「提前解約賠一個月租金」。大雄租了半年後退租，並提早一個月告知，房東太太要求沒收全額兩個月押金。請問合理嗎？',
          'options': [
            'A. 不合理，既然合約已約定賠一個月，且法律規定違約金最高上限也是一個月，房東要求兩個月是違法的。',
            'B. 合理，因為提早告知仍會對房東造成出租空窗期的損失，所以可以多扣一個月。',
            'C. 合理，契約只要簽字，房東要扣多少就以房東口頭要求為準。'
          ],
          'correctIndex': 0,
          'explanation': '提前解約的違約金應按合約約定為之，且依政府租賃住宅委託管理辦法規定，最高不得超過一個月租金。',
        };
      case 'STEP 3':
        return {
          'question': '房客搬走後，房東發現牆壁上有前房客貼海報留下的隱約膠帶痕跡，要求房客必須負擔「整間屋子全新油漆」的費用。請問合理嗎？',
          'options': [
            'A. 合理，租客必須保證退租時房屋跟全新的一模一樣。',
            'B. 不合理，賠償應以「恢復原狀」為原則，正常使用痕跡已折舊，且不應無限上綱要求整間油漆的費用。',
            'C. 合理，房東找工人的所有開銷都可以直接從押金扣除。'
          ],
          'correctIndex': 1,
          'explanation': '房屋租賃折舊是常態，且貼海報之輕微痕跡通常屬於合理使用範圍，房東要求整間粉刷費用並不符合法理上賠償折舊與恢復原狀之比例原則。',
        };
      case 'STEP 4':
        return {
          'question': '合約上若手寫了一句「租客自願拋棄任何提前解約的法律通知期權利，且一旦解約，違約金由房東自由決定」。這句話有效嗎？',
          'options': [
            'A. 完全有效，法律尊重當事人契約自由，有簽名就必須遵守。',
            'B. 部分或全部無效，因違反消費者保護法與內政部定型化契約之強制禁止規定，顯失公平之條款無效。',
            'C. 完全有效，手寫字體法律效力高於一切法規。'
          ],
          'correctIndex': 1,
          'explanation': '若條款內容違反消保法或內政部定型化契約應記載及不得記載事項，即便租客簽字，該條款亦會被認定為無效。',
        };
      default:
        return null;
    }
  }

  void _submitQuizAnswer() {
    final quiz = _quizData;
    if (_selectedQuizIndex == null || _isQuizAnswered || quiz == null) return;

    final isCorrect = _selectedQuizIndex == quiz['correctIndex'];
    if (isCorrect) {
      // 答對了！記錄進度並給 XP
      if (widget.unitStepLabel != null) {
        LearningGameState.instance.completeStep(widget.unitStepLabel!);
      } else {
        LearningGameState.instance.addExperience(20); // 動態專題答對直接給 20 XP
      }
    } else {
      // 答錯，加進錯題本
      LearningGameState.instance.addIncorrectQuestion(
        quiz['question'],
        quiz['options'][_selectedQuizIndex!],
        quiz['options'][quiz['correctIndex']],
        quiz['explanation'],
      );
    }

    setState(() {
      _isQuizAnswered = true;
    });
  }

  void _showNotebookBottomSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gameState = LearningGameState.instance;
    final noteController = TextEditingController(text: gameState.getArticleNote(widget.article.title));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ListenableBuilder(
          listenable: gameState,
          builder: (context, _) {
            // 取得該文章的劃記重點
            final articleHighlights = gameState.savedHighlights
                .where((item) => item['articleTitle'] == widget.article.title)
                .toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161C23) : const Color(0xFFFBF8F5),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.r),
                  topRight: Radius.circular(24.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10.r,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // 頂部把手
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 5.h,
                      margin: EdgeInsets.symmetric(vertical: 12.h),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                  // 標題
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CtmSvgIcon(
                              CtmSvgIcons.filePen,
                              size: 22.sp,
                              color: HomeV2Palette.trustGreen,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              '專題學習筆記本',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(Icons.close, size: 20.sp, color: Colors.grey),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1.h, color: Colors.grey.shade300),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                      children: [
                        // 1. 自訂筆記區
                        Text(
                          '📝 我的學習心得與筆記',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                            color: HomeV2Palette.trustGreen,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF232A33) : const Color(0xFFFFFDF9),
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: isDark ? Colors.transparent : const Color(0xFFE9DFD2),
                              width: 1.2.w,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 4.r,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: noteController,
                            maxLines: 4,
                            onChanged: (val) {
                              gameState.setArticleNote(widget.article.title, val);
                            },
                            style: TextStyle(
                              fontSize: 13.5.sp,
                              height: 1.45,
                              color: AppColors.textPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: '在此寫下您的理解或心得筆記，系統會自動儲存...',
                              hintStyle: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.grey.shade400,
                              ),
                              contentPadding: EdgeInsets.all(14.w),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        SizedBox(height: 24.h),

                        // 2. 劃記重點區
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '✍️ 本單元劃記重點 (${articleHighlights.length})',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w800,
                                color: HomeV2Palette.trustGreen,
                              ),
                            ),
                            if (articleHighlights.isNotEmpty)
                              Text(
                                '提示：選取正文文字也可劃記',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.grey,
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        if (articleHighlights.isEmpty)
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: Colors.grey.shade300, width: 0.8.w),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.edit_note, size: 32.sp, color: Colors.grey.shade400),
                                SizedBox(height: 8.h),
                                Text(
                                  '目前尚無劃記重點\n您可以選取正文中的文字，並點擊「劃記重點 ✍️」將其存入這裡。',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    height: 1.45,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          ...List.generate(articleHighlights.length, (index) {
                            final highlightText = articleHighlights[index]['highlight'] as String;
                            // 找出當前重點在 gameState.savedHighlights 中的真實全域 index
                            final globalIndex = gameState.savedHighlights.indexOf(articleHighlights[index]);
                            return Container(
                              margin: EdgeInsets.only(bottom: 8.h),
                              padding: EdgeInsets.fromLTRB(12.w, 10.h, 6.w, 10.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFCEE),
                                border: Border.all(color: const Color(0xFFFBE4A2), width: 1.w),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      highlightText,
                                      style: TextStyle(
                                        fontSize: 12.5.sp,
                                        height: 1.4,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete_outline, size: 18.sp, color: Colors.red.shade400),
                                    onPressed: () {
                                      if (globalIndex != -1) {
                                        gameState.removeHighlight(globalIndex);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          }),
                        SizedBox(height: 24.h),

                        // 3. 快速點選核心重點 (不必選取文字即可劃記)
                        Text(
                          '💡 快速將核心思考點加入筆記',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                            color: HomeV2Palette.trustGreen,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        ...widget.article.keyPoints.map((point) {
                          final isPointHighlighted = articleHighlights.any((item) => item['highlight'] == point);
                          return Container(
                            margin: EdgeInsets.only(bottom: 8.h),
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF232A33) : Colors.white,
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                color: isPointHighlighted ? const Color(0xFFFBE4A2) : Colors.grey.shade300,
                                width: 1.w,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    point,
                                    style: TextStyle(
                                      fontSize: 12.5.sp,
                                      height: 1.45,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () {
                                    if (isPointHighlighted) {
                                      // 移除劃記
                                      final matchIndex = gameState.savedHighlights.indexWhere(
                                        (item) => item['highlight'] == point && item['articleTitle'] == widget.article.title
                                      );
                                      if (matchIndex != -1) {
                                        gameState.removeHighlight(matchIndex);
                                      }
                                    } else {
                                      // 新增劃記
                                      gameState.addHighlight(point, widget.article.title);
                                    }
                                  },
                                  icon: Icon(
                                    isPointHighlighted ? Icons.check_circle : Icons.add_circle_outline,
                                    size: 16.sp,
                                    color: isPointHighlighted ? const Color(0xFFE8B85F) : HomeV2Palette.trustGreen,
                                  ),
                                  label: Text(
                                    isPointHighlighted ? '已收錄' : '劃記',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                      color: isPointHighlighted ? const Color(0xFFE8B85F) : HomeV2Palette.trustGreen,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gameState = LearningGameState.instance;
    final isStepCompleted = widget.unitStepLabel != null && gameState.completedSteps.contains(widget.unitStepLabel);
    final quiz = _quizData;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Text(
          widget.article.category ?? _guessCategory(widget.article.title),
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          ListenableBuilder(
            listenable: gameState,
            builder: (context, _) {
              final isBookmarked = gameState.isArticleSaved(widget.article.title);
              return IconButton(
                icon: CtmSvgIcon(
                  CtmSvgIcons.bookmark,
                  size: 20.sp,
                  color: isBookmarked ? HomeV2Palette.trustGreen : Colors.grey,
                ),
                tooltip: isBookmarked ? '取消收藏單元' : '收藏本單元',
                onPressed: () {
                  gameState.toggleArticleSave(widget.article.title);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        gameState.isArticleSaved(widget.article.title)
                            ? '已收藏本單元！'
                            : '已取消收藏本單元！',
                      ),
                      backgroundColor: HomeV2Palette.trustGreen,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              );
            },
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: ListenableBuilder(
        listenable: gameState,
        builder: (context, _) {
          // 取得當前單元已劃記的重點列表
          final currentHighlights = gameState.savedHighlights
              .where((item) => item['articleTitle'] == widget.article.title)
              .map((item) => item['highlight'] as String)
              .toList();

          return NotebookBackground(
            child: ListView(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 80.h), // 底部留白以防阻擋懸浮按鈕
              children: [
                // 1. 主卡片
                NotebookCard(
                  backgroundColor: isDark ? const Color(0xFF161C23) : Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: HomeV2Palette.mint,
                          borderRadius: BorderRadius.circular(999.r),
                        ),
                        child: Text(
                          widget.article.readTime,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: HomeV2Palette.trustGreen,
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        widget.article.title,
                        style: TextStyle(
                          fontSize: 20.sp,
                          height: 1.25,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      HighlightedSelectableText(
                        text: widget.article.summary,
                        highlights: currentHighlights,
                        style: TextStyle(
                          fontSize: 14.sp,
                          height: 1.55,
                          color: AppColors.textSecondary,
                        ),
                        articleTitle: widget.article.title,
                      ),
                      SizedBox(height: 18.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF232A33) : const Color(0xFFF7F2EA),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(color: isDark ? Colors.transparent : const Color(0xFFE9DFD2)),
                        ),
                        child: HighlightedSelectableText(
                          text: widget.article.heroNote,
                          highlights: currentHighlights,
                          style: TextStyle(
                            fontSize: 13.5.sp,
                            height: 1.55,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.orange.shade100 : const Color(0xFF6B5439),
                          ),
                          articleTitle: widget.article.title,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 14.h),

                // 2. 重點思考框
                Text(
                  '💡 三個核心法律思考點',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 12.h),
                ...widget.article.keyPoints.map((point) {
                  final isPointSaved = gameState.isQuoteSaved(point);
                  return NotebookCard(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                    margin: EdgeInsets.only(bottom: 10.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 2.h),
                          child: CtmSvgIcon(
                            CtmSvgIcons.star,
                            size: 16.sp,
                            color: HomeV2Palette.trustGreen,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            point,
                            style: TextStyle(
                              fontSize: 13.5.sp,
                              height: 1.45,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: CtmSvgIcon(
                            CtmSvgIcons.star,
                            size: 18.sp,
                            color: isPointSaved ? const Color(0xFFE8B85F) : Colors.grey.shade300,
                          ),
                          onPressed: () {
                            gameState.toggleQuoteSave(point, widget.article.title);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  gameState.isQuoteSaved(point)
                                      ? '已成功將金句收藏至備忘錄！'
                                      : '已取消收藏金句！',
                                ),
                                backgroundColor: HomeV2Palette.trustGreen,
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }),

                SizedBox(height: 18.h),

                // 3. 詳細章節
                ...widget.article.sections.map(
                  (section) => NotebookCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          section.title,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: HomeV2Palette.trustGreen,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        HighlightedSelectableText(
                          text: section.body,
                          highlights: currentHighlights,
                          style: TextStyle(
                            fontSize: 13.5.sp,
                            height: 1.6,
                            color: AppColors.textSecondary,
                          ),
                          articleTitle: widget.article.title,
                        ),
                      ],
                    ),
                  ),
                ),

                // 4. 嵌入的思辨小測驗
                if (quiz != null) ...[
                  SizedBox(height: 20.h),
                  Text(
                    '📝 課堂思辨小測試',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  NotebookCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isStepCompleted) ...[
                          Row(
                            children: [
                              CtmSvgIcon(CtmSvgIcons.star, color: HomeV2Palette.trustGreen, size: 24.sp),
                              SizedBox(width: 8.w),
                              const Text('本單元測驗已通關！', style: TextStyle(fontWeight: FontWeight.bold, color: HomeV2Palette.trustGreen)),
                            ],
                          ),
                          SizedBox(height: 8.h),
                        ],
                        Text(
                          quiz['question'],
                          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        SizedBox(height: 14.h),
                        ...List.generate(quiz['options'].length, (index) {
                          final isSelected = _selectedQuizIndex == index;
                          final isCorrect = _isQuizAnswered && index == quiz['correctIndex'];
                          final isWrong = _isQuizAnswered && isSelected && index != quiz['correctIndex'];

                          Color optionBg = Colors.white;
                          Color optionBorder = const Color(0xFFECE6DB);
                          if (isCorrect || (isStepCompleted && index == quiz['correctIndex'])) {
                            optionBg = const Color(0xFFEAF6E2);
                            optionBorder = const Color(0xFF9EC979);
                          } else if (isWrong) {
                            optionBg = const Color(0xFFFBE8E7);
                            optionBorder = const Color(0xFFE4A29D);
                          } else if (isSelected) {
                            optionBg = const Color(0xFFFFFAEC);
                            optionBorder = const Color(0xFFE8B95F);
                          }

                          Widget optionIcon;
                          if (isCorrect || (isStepCompleted && index == quiz['correctIndex'])) {
                            optionIcon = CtmSvgIcon(CtmSvgIcons.star, color: Colors.green, size: 18.sp);
                          } else if (isWrong) {
                            optionIcon = CtmSvgIcon(CtmSvgIcons.xCircle, color: Colors.red, size: 18.sp);
                          } else if (isSelected) {
                            optionIcon = CtmSvgIcon(CtmSvgIcons.star, color: const Color(0xFFE8B95F), size: 18.sp);
                          } else {
                            optionIcon = Container(
                              width: 18.w,
                              height: 18.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey, width: 1.5.w),
                              ),
                            );
                          }

                          return Padding(
                            padding: EdgeInsets.only(bottom: 8.h),
                            child: InkWell(
                              onTap: (_isQuizAnswered || isStepCompleted) ? null : () {
                                setState(() {
                                  _selectedQuizIndex = index;
                                });
                              },
                              borderRadius: BorderRadius.circular(10.r),
                              child: Container(
                                padding: EdgeInsets.all(12.w),
                                decoration: BoxDecoration(
                                  color: optionBg,
                                  border: Border.all(color: optionBorder, width: 1.2.w),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Row(
                                  children: [
                                    optionIcon,
                                    SizedBox(width: 8.w),
                                    Expanded(
                                      child: Text(
                                        quiz['options'][index],
                                        style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                        SizedBox(height: 12.h),
                        if (!_isQuizAnswered && !isStepCompleted)
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: _selectedQuizIndex == null ? null : _submitQuizAnswer,
                              style: FilledButton.styleFrom(backgroundColor: HomeV2Palette.trustGreen),
                              child: const Text('送出答案'),
                            ),
                          )
                        else ...[
                          // 答題後的動態吉祥物與泡泡反饋區
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 44.w,
                                height: 44.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: HomeV2Palette.trustGreen, width: 1.5.w),
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    gameState.mascotAsset,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.all(12.w),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1E2622) : const Color(0xFFF2FAF6),
                                    border: Border.all(
                                      color: isDark ? const Color(0xFF2E3C36) : const Color(0xFFD2E6DE),
                                      width: 1.2.w,
                                    ),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(2.r),
                                      topRight: Radius.circular(12.r),
                                      bottomLeft: Radius.circular(12.r),
                                      bottomRight: Radius.circular(12.r),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        (_isQuizAnswered && _selectedQuizIndex == quiz['correctIndex']) || isStepCompleted
                                            ? '🎉 答對了！恭喜！'
                                            : '❌ 答錯了，再接再厲！',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13.sp,
                                          color: isDark ? const Color(0xFF99C3B3) : const Color(0xFF1B4D3E),
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        (_isQuizAnswered && _selectedQuizIndex == quiz['correctIndex']) || isStepCompleted
                                            ? '您表現得非常好，真不愧是「${gameState.levelTitle} ${gameState.mascotExpression}」！獲得 20 XP！'
                                            : '沒關係，小法助已經把這道錯題記錄在您的「錯題本」了。先看看白話判決解析，再重新溫習吧！',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          height: 1.4,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          // 白話解析框
                          Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF232A33) : const Color(0xFFF7F2EA),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: isDark ? Colors.transparent : const Color(0xFFE9DFD2),
                                width: 1.w,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CtmSvgIcon(
                                      CtmSvgIcons.gavel,
                                      size: 16.sp,
                                      color: const Color(0xFF94610D),
                                    ),
                                    SizedBox(width: 6.w),
                                    Text(
                                      '白話判決解析',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13.sp,
                                        color: const Color(0xFF94610D),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 6.h),
                                Text(
                                  quiz['explanation'],
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    height: 1.45,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'learning_notebook_fab',
            onPressed: () => _showNotebookBottomSheet(context),
            backgroundColor: isDark ? const Color(0xFF1E2622) : const Color(0xFFF7F2EA),
            shape: CircleBorder(
              side: BorderSide(
                color: HomeV2Palette.trustGreen,
                width: 1.5.w,
              ),
            ),
            elevation: 8,
            child: ClipOval(
              child: Image.asset(
                'assets/images/learning/legal_notebook_icon.png',
                fit: BoxFit.cover,
                width: 56.w,
                height: 56.w,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          ListenableBuilder(
            listenable: gameState,
            builder: (context, _) {
              return FloatingActionButton(
                heroTag: 'mascot_ai_assistant_fab',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => LawAssistantSearchPage(
                        initialPrompt: '我正在學《${widget.article.title}》，想問問小法助關於這個主題的細節：',
                      ),
                    ),
                  );
                },
                backgroundColor: HomeV2Palette.mint,
                shape: CircleBorder(
                  side: BorderSide(
                    color: HomeV2Palette.trustGreen,
                    width: 1.5.w,
                  ),
                ),
                elevation: 8, // 更懸浮一點
                child: ClipOval(
                  child: Image.asset(
                    gameState.mascotAsset,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class HighlightedSelectableText extends StatelessWidget {
  const HighlightedSelectableText({
    super.key,
    required this.text,
    required this.highlights,
    required this.style,
    required this.articleTitle,
  });

  final String text;
  final List<String> highlights;
  final TextStyle style;
  final String articleTitle;

  @override
  Widget build(BuildContext context) {
    if (highlights.isEmpty || text.isEmpty) {
      return SelectableText(
        text,
        style: style,
        contextMenuBuilder: _buildContextMenu,
      );
    }

    final List<_TextRange> ranges = [];
    for (final highlight in highlights) {
      if (highlight.trim().isEmpty) continue;
      int start = 0;
      while (true) {
        final index = text.indexOf(highlight, start);
        if (index == -1) break;
        ranges.add(_TextRange(index, index + highlight.length));
        start = index + highlight.length;
      }
    }

    if (ranges.isEmpty) {
      return SelectableText(
        text,
        style: style,
        contextMenuBuilder: _buildContextMenu,
      );
    }

    ranges.sort((a, b) => a.start.compareTo(b.start));
    final List<_TextRange> mergedRanges = [];
    _TextRange? currentRange = ranges.first;
    for (int i = 1; i < ranges.length; i++) {
      final nextRange = ranges[i];
      if (nextRange.start <= currentRange!.end) {
        if (nextRange.end > currentRange.end) {
          currentRange = _TextRange(currentRange.start, nextRange.end);
        }
      } else {
        mergedRanges.add(currentRange);
        currentRange = nextRange;
      }
    }
    if (currentRange != null) {
      mergedRanges.add(currentRange);
    }

    final List<TextSpan> spans = [];
    int currentIndex = 0;
    for (final range in mergedRanges) {
      if (range.start > currentIndex) {
        spans.add(TextSpan(text: text.substring(currentIndex, range.start)));
      }
      final highlightStr = text.substring(range.start, range.end);
      spans.add(TextSpan(
        text: highlightStr,
        style: TextStyle(
          backgroundColor: Colors.yellow.withOpacity(0.45),
        ),
        recognizer: LongPressGestureRecognizer()..onLongPress = () {
          _showShareCardDialog(context, highlightStr, articleTitle);
        },
      ));
      currentIndex = range.end;
    }
    if (currentIndex < text.length) {
      spans.add(TextSpan(text: text.substring(currentIndex)));
    }

    return SelectableText.rich(
      TextSpan(
        style: style,
        children: spans,
      ),
      contextMenuBuilder: _buildContextMenu,
    );
  }

  Widget _buildContextMenu(BuildContext context, EditableTextState editableTextState) {
    final List<ContextMenuButtonItem> buttonItems = editableTextState.contextMenuButtonItems;
    final selection = editableTextState.textEditingValue.selection;
    if (!selection.isCollapsed && selection.start >= 0 && selection.end <= text.length) {
      final selectedText = text.substring(selection.start, selection.end);
      if (selectedText.trim().isNotEmpty) {
        buttonItems.add(
          ContextMenuButtonItem(
            label: '劃記重點 ✍️',
            onPressed: () {
              LearningGameState.instance.addHighlight(selectedText, articleTitle);
              editableTextState.hideToolbar();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('已成功劃記此重點並儲存至成就室備忘錄！'),
                  backgroundColor: HomeV2Palette.trustGreen,
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        );
      }
    }
    return AdaptiveTextSelectionToolbar.buttonItems(
      anchors: editableTextState.contextMenuAnchors,
      buttonItems: buttonItems,
    );
  }
}

class _TextRange {
  final int start;
  final int end;
  _TextRange(this.start, this.end);
}

void _showShareCardDialog(BuildContext context, String highlightText, String articleTitle) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 卡片主體
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E2622) : const Color(0xFFFFFBF3),
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                  color: isDark ? const Color(0xFF2E3C36) : const Color(0xFFE9DFD2),
                  width: 1.5.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15.r,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.format_quote_rounded,
                        size: 32.sp,
                        color: HomeV2Palette.trustGreen.withOpacity(0.4),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Text(
                      highlightText,
                      style: TextStyle(
                        fontSize: 16.sp,
                        height: 1.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.yellow.withOpacity(0.6),
                        decorationThickness: 4,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Transform.rotate(
                        angle: 3.14159,
                        child: Icon(
                          Icons.format_quote_rounded,
                          size: 32.sp,
                          color: HomeV2Palette.trustGreen.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '—— 摘自《$articleTitle》',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: HomeV2Palette.trustGreen,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '小法助 • 隨身法律避坑筆記',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: '$highlightText\n\n—— 摘自《$articleTitle》• 小法助'));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('已複製重點及來源文字！'),
                        backgroundColor: HomeV2Palette.trustGreen,
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: HomeV2Palette.trustGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(99.r),
                      side: BorderSide(color: HomeV2Palette.trustGreen, width: 1.2.w),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  ),
                  icon: Icon(Icons.copy_rounded, size: 16.sp),
                  label: const Text('複製文字'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('🎨 成功生成精美圖卡！已儲存至相簿，您可以直接分享！'),
                        backgroundColor: HomeV2Palette.trustGreen,
                        action: SnackBarAction(
                          label: '分享',
                          textColor: Colors.white,
                          onPressed: () {},
                        ),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HomeV2Palette.trustGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(99.r),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  ),
                  icon: Icon(Icons.share_rounded, size: 16.sp),
                  label: const Text('分享圖卡'),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
