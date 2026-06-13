import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/data/mock_data/learning/learning_mock_data.dart';
import 'package:lawapp/theme/app_colors.dart';
import 'package:lawapp/data/learning/learning_game_state.dart';
import 'package:lawapp/components/home/v2/home_v2_palette.dart';
import 'package:lawapp/pages/learning/widgets/notebook_aesthetics.dart';

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

  @override
  void initState() {
    super.initState();
    _quizData = _getQuizForStep(widget.unitStepLabel);
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
      LearningGameState.instance.completeStep(widget.unitStepLabel!);
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
          widget.article.badge,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: gameState,
        builder: (context, _) {
          return NotebookBackground(
            child: ListView(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 40.h),
              children: [
                // 1. 主卡片
                NotebookCard(
                  hasPaperClip: true,
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
                          fontSize: 24.sp,
                          height: 1.25,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        widget.article.summary,
                        style: TextStyle(
                          fontSize: 14.sp,
                          height: 1.55,
                          color: AppColors.textSecondary,
                        ),
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
                        child: Text(
                          widget.article.heroNote,
                          style: TextStyle(
                            fontSize: 13.5.sp,
                            height: 1.55,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.orange.shade100 : const Color(0xFF6B5439),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 14.h),

                // 2. 重點框
                Text(
                  '💡 三個核心法律思考點',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 12.h),
                ...widget.article.keyPoints.map(
                  (point) => NotebookCard(
                    padding: EdgeInsets.all(14.w),
                    margin: EdgeInsets.only(bottom: 10.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 2.h),
                          child: Icon(
                            Icons.check_circle_outline_rounded,
                            size: 18.sp,
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
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 18.h),

                // 3. 詳細章節
                ...widget.article.sections.map(
                  (section) => NotebookCard(
                    hasBinderRings: true,
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
                        Text(
                          section.body,
                          style: TextStyle(
                            fontSize: 13.5.sp,
                            height: 1.6,
                            color: AppColors.textSecondary,
                          ),
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
                    hasBookmark: true,
                    bookmarkColor: isStepCompleted ? HomeV2Palette.trustGreen : const Color(0xFFE8B85F),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isStepCompleted) ...[
                          Row(
                            children: [
                              Icon(Icons.check_circle_rounded, color: HomeV2Palette.trustGreen, size: 24.sp),
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
                                    Icon(
                                      (isCorrect || (isStepCompleted && index == quiz['correctIndex']))
                                          ? Icons.check_circle_rounded
                                          : (isWrong ? Icons.cancel_rounded : (isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded)),
                                      color: (isCorrect || (isStepCompleted && index == quiz['correctIndex']))
                                          ? Colors.green
                                          : (isWrong ? Colors.red : (isSelected ? const Color(0xFFE8B95F) : Colors.grey)),
                                      size: 18.sp,
                                    ),
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
                          Container(
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F2EA),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '⚖️ 白話解析：',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: const Color(0xFF94610D)),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  quiz['explanation'],
                                  style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10.h),
                          if (_isQuizAnswered && _selectedQuizIndex == quiz['correctIndex'])
                            Text(
                              '🎉 回答正確！經驗值 +20 XP！該單元已標記完成！',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade800, fontSize: 13.sp),
                              textAlign: TextAlign.center,
                            )
                          else if (_isQuizAnswered)
                            Text(
                              '❌ 答錯了，錯題已加進錯題本，隨時可去成就室重新挑戰。',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade800, fontSize: 13.sp),
                              textAlign: TextAlign.center,
                            )
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
    );
  }
}
