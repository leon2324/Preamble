import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/data/learning/learning_game_state.dart';
import 'package:preamble/pages/learning/widgets/notebook_aesthetics.dart';
import 'package:preamble/theme/app_colors.dart';
import 'package:preamble/components/home/v2/home_v2_palette.dart';
import 'package:preamble/features/case_library/widgets/case_library_svg_icon.dart';

class MockCourtChallengePage extends StatefulWidget {
  const MockCourtChallengePage({super.key});

  @override
  State<MockCourtChallengePage> createState() => _MockCourtChallengePageState();
}

class _MockCourtChallengePageState extends State<MockCourtChallengePage> {
  int _currentStep = 0;
  int? _selectedAnswerIndex;
  bool _isAnswered = false;
  int _correctCount = 0;

  final List<Map<String, dynamic>> _questions = [
    {
      'title': '案例一：深夜的車禍糾紛',
      'fact': '小明在深夜開車被後方超速的小華追撞。小明驚慌之下，下車跟小華理論，小華滿身酒氣並動手推人。此時，小明應該第一時間怎麼做？',
      'options': [
        'A. 立刻把車開走避免阻礙交通。',
        'B. 保持車輛現場，立刻報警、拍照存證，並防範對方暴力。',
        'C. 自行跟小華私下寫和解書。'
      ],
      'correctIndex': 1,
      'explanation':
          '車禍且對方有醉酒、暴力傾向時，安全第一。保持現場、拍照並報警是最佳保障，切勿在不安全或無公正第三方在場時私下和解或任意移動車輛（除非無人傷亡且已標繪定位）。',
    },
    {
      'title': '案例二：突然的退租要求',
      'fact':
          '大華租屋合約寫明「租期一年，提前解約需賠償一個月租金」。大華因工作變動，在租滿六個月時要求提前退租，並在一週前通知房東。房東要求沒收全部兩個月押金。依據現行法規，房東這樣合法嗎？',
      'options': [
        'A. 合法，房東高興扣多少就扣多少。',
        'B. 不合法，但因為大華有提前通知，所以完全不用賠違約金。',
        'C. 不合法，房東最多只能扣除一個月租金作為違約金，其餘一個月押金必須退還。'
      ],
      'correctIndex': 2,
      'explanation':
          '契約中已約定提前解約賠償一個月租金，且依住宅租賃契約應約定事項，違約金最高不得超過一個月。因此沒收全部兩個月押金是不合法的，溢收部分需退還。',
    },
    {
      'title': '案例三：網購拆封能退嗎？',
      'fact':
          '阿花在網路上買了一件衣服，收到後拆封試穿發現尺寸不合，想要退貨。賣家卻說「消保法規定拆封後不適用七天鑑賞期，一律不退換」。賣家說法站得住腳嗎？',
      'options': [
        'A. 站得住腳，只要拆封就不能退。',
        'B. 站不住腳，衣服並非消保法規定的合理例外排除商品（如易腐敗、個人衛生用品等），試穿亦屬合理檢視範疇，仍享有七天鑑賞期。',
        'C. 站得住腳，網購本來就不能退換。'
      ],
      'correctIndex': 1,
      'explanation':
          '一般成衣不屬於七天鑑賞期之合理例外排除商品，且試穿為合理檢視商品之必要行為。商家不得以「拆封不可退」之自訂條款排除消保法規定。',
    }
  ];

  void _submitAnswer() {
    if (_selectedAnswerIndex == null || _isAnswered) return;

    final isCorrect =
        _selectedAnswerIndex == _questions[_currentStep]['correctIndex'];
    if (isCorrect) {
      _correctCount++;
    } else {
      // 答錯，加入錯題本
      final q = _questions[_currentStep];
      LearningGameState.instance.addIncorrectQuestion(
        q['fact'],
        q['options'][_selectedAnswerIndex!],
        q['options'][q['correctIndex']],
        q['explanation'],
      );
    }

    setState(() {
      _isAnswered = true;
    });
  }

  void _nextStep() {
    if (_currentStep < _questions.length - 1) {
      setState(() {
        _currentStep++;
        _selectedAnswerIndex = null;
        _isAnswered = false;
      });
    } else {
      // 結束挑戰
      if (_correctCount == _questions.length) {
        LearningGameState.instance.unlockBadge('擂台霸主');
        LearningGameState.instance.addExperience(50); // 全對加 50 XP
      } else {
        LearningGameState.instance.addExperience(20); // 未全對加 20 XP
      }
      _showResultDialog();
    }
  }

  void _showResultDialog() {
    final allCorrect = _correctCount == _questions.length;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          title: Text(
            allCorrect ? '🏆 擂台通關！完美判斷' : '👏 挑戰結束！繼續加油',
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                allCorrect
                    ? '恭喜你！3 題法官模擬案件判斷全部正確！\n解鎖了「擂台霸主」榮譽勳章，並獲得經驗值 +50 XP！'
                    : '你答對了 $_correctCount / ${_questions.length} 題！\n答錯的題目已自動記錄到你的「📕 錯題本」中，隨時可以在成就室重新溫習挑戰！',
                textAlign: TextAlign.center,
                style: TextStyle(height: 1.45, fontSize: 13.5.sp),
              ),
              SizedBox(height: 16.h),
              Text(
                allCorrect ? '🎓 Mascot Expression 升級啦！' : '📚 熟能生巧！',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: HomeV2Palette.trustGreen),
              )
            ],
          ),
          actions: [
            Center(
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).pop(); // 關閉 dialog
                  Navigator.of(context).pop(); // 退出擂台頁
                },
                style: FilledButton.styleFrom(
                  backgroundColor: HomeV2Palette.trustGreen,
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                ),
                child: const Text('回到學堂'),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[_currentStep];

    return Scaffold(
      appBar: AppBar(
        title: const Text('🏆 公民法律小擂台'),
        centerTitle: true,
      ),
      body: NotebookBackground(
        child: ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            NotebookCard(
              hasBookmark: true,
              bookmarkColor: const Color(0xFF9FC6B0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFAEC),
                          borderRadius: BorderRadius.circular(6.r),
                          border: Border.all(color: const Color(0xFFE8B95F)),
                        ),
                        child: Text(
                          '模擬審判',
                          style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF94610D)),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '進度：${_currentStep + 1} / ${_questions.length}',
                        style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    q['title'],
                    style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    q['fact'],
                    style: TextStyle(
                        fontSize: 13.5.sp,
                        height: 1.5,
                        color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),

            // 選項
            ...List.generate(q['options'].length, (index) {
              final isSelected = _selectedAnswerIndex == index;
              final isCorrectOpt = _isAnswered && index == q['correctIndex'];
              final isWrongOpt =
                  _isAnswered && isSelected && index != q['correctIndex'];

              Color cardBg = Colors.white;
              Color borderCol = const Color(0xFFECE6DB);
              if (isCorrectOpt) {
                cardBg = const Color(0xFFEAF6E2);
                borderCol = const Color(0xFF9EC979);
              } else if (isWrongOpt) {
                cardBg = const Color(0xFFFBE8E7);
                borderCol = const Color(0xFFE4A29D);
              } else if (isSelected) {
                cardBg = const Color(0xFFFFFAEC);
                borderCol = const Color(0xFFE8B95F);
              }

              Widget iconWidget;
              if (isCorrectOpt) {
                iconWidget = CaseLibrarySvgIcon(CaseLibrarySvgIcons.star,
                    size: 18.sp, color: Colors.green);
              } else if (isWrongOpt) {
                iconWidget = CaseLibrarySvgIcon(CaseLibrarySvgIcons.xCircle,
                    size: 18.sp, color: Colors.red);
              } else if (isSelected) {
                iconWidget = CaseLibrarySvgIcon(CaseLibrarySvgIcons.star,
                    size: 18.sp, color: const Color(0xFFE8B95F));
              } else {
                iconWidget = CaseLibrarySvgIcon(CaseLibrarySvgIcons.timeline,
                    size: 18.sp, color: Colors.grey);
              }

              return GestureDetector(
                onTap: _isAnswered
                    ? null
                    : () {
                        setState(() {
                          _selectedAnswerIndex = index;
                        });
                      },
                child: NotebookCard(
                  backgroundColor: cardBg,
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                  margin: EdgeInsets.only(bottom: 10.h),
                  child: Row(
                    children: [
                      iconWidget,
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          q['options'][index],
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            SizedBox(height: 16.h),

            // 解析說明
            if (_isAnswered)
              NotebookCard(
                backgroundColor: const Color(0xFFF7F2EA),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '⚖️ 小法助白話判決書',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5.sp,
                          color: const Color(0xFF94610D)),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      q['explanation'],
                      style: TextStyle(
                          fontSize: 12.5.sp,
                          height: 1.45,
                          color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),

            SizedBox(height: 16.h),

            // 按鈕
            if (!_isAnswered)
              FilledButton(
                onPressed: _selectedAnswerIndex == null ? null : _submitAnswer,
                style: FilledButton.styleFrom(
                  backgroundColor: HomeV2Palette.trustGreen,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                ),
                child: Text('敲定法槌 (送出)',
                    style: TextStyle(
                        fontSize: 14.sp, fontWeight: FontWeight.bold)),
              )
            else
              FilledButton(
                onPressed: _nextStep,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.textPrimary,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                ),
                child: Text(
                  _currentStep == _questions.length - 1 ? '觀看判斷結果' : '前進下一案',
                  style:
                      TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
