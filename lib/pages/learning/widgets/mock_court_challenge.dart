import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:preamble/data/learning/learning_game_state.dart';
import 'package:preamble/pages/learning/widgets/notebook_aesthetics.dart';
import 'package:preamble/theme/preamble_tokens.dart';

/// 章節 Boss 關卡：「模擬法庭審判長 (Mock Court Challenge)」。
///
/// 採用靜奢律政編輯風與雙重編碼（宋體事實卷宗 × 黑體選項與判決解析），
/// 全面支援深色模式與正確語意單選圖示。
class MockCourtChallengePage extends StatefulWidget {
  const MockCourtChallengePage({
    super.key,
    this.topicTitle,
  });

  final String? topicTitle;

  @override
  State<MockCourtChallengePage> createState() => _MockCourtChallengePageState();
}

class _MockCourtChallengePageState extends State<MockCourtChallengePage> {
  int _currentStep = 0;
  int? _selectedAnswerIndex;
  bool _isAnswered = false;
  int _correctCount = 0;

  static const List<Map<String, dynamic>> _questions = [
    {
      'title': '第一案：深夜追撞與現場保全',
      'statuteRef': '道路交通事故處理辦法第 3 條 · 刑法第 284 條',
      'fact':
          '當事人甲於深夜駕車遭後方超速之乙車追撞。甲下車查看時，發現乙渾身酒氣且情緒激動推擠。站在審判與自保觀點，甲第一時間應採取何種處置最為妥適？',
      'options': [
        'A. 立即將車輛駛離現場，以免阻礙後方車流。',
        'B. 保持車輛現場位置（或標繪定位）、立即報警並錄影存證，拉開安全距離防範暴力。',
        'C. 當場與乙私下簽署簡易和解切結書以求息事寧人。',
      ],
      'correctIndex': 1,
      'explanation':
          '涉及酒駕與人身安全威脅時，人身安全與現場證據保全為最高原則。應立即報警、全景拍攝車損與煞車痕，切勿在未釐清肇責與傷勢前簽署私下和解書。',
    },
    {
      'title': '第二案：提前終止租約之押金抵扣上限',
      'statuteRef': '租賃住宅市場發展及管理條例 · 住宅租賃定型化契約應記載事項',
      'fact':
          '承租人丙與房東簽訂一年期住宅租約，約定「得提前終止租約，違約金為 1 個月租金」。丙於租滿 6 個月時因工作調動提前一週通知退租，房東卻主張沒收全數 2 個月押金。本院應如何認定？',
      'options': [
        'A. 房東主張合法，提前退租本就由房東自由決定扣款金額。',
        'B. 房東主張不合法，且因丙已提前一週通知，故一毛違約金都不必付。',
        'C. 房東主張逾越法定上限，最高僅得抵扣 1 個月租金違約金，其餘 1 個月押金應予返還。',
      ],
      'correctIndex': 2,
      'explanation':
          '依內政部住宅租賃定型化契約應記載事項規定，約定得提前終止租約而未依限期先通知者，賠償金額最高不得超過 1 個月租金額。房東超額沒收第 2 個月押金部分無法律上原因，應予返還。',
    },
    {
      'title': '第三案：通訊交易拆封試穿之鑑賞期爭議',
      'statuteRef': '消費者保護法第 19 條 · 通訊交易解除權合理例外情事適用準則',
      'fact':
          '消費者丁於網路商店購買一般外穿夾克，收貨拆封試穿後發現版型不符，於第 3 日申請退貨。賣家抗辯稱「官網已公告拆封即不適用七日鑑賞期」。賣家抗辯是否有理由？',
      'options': [
        'A. 有理由，只要包裝拆封即喪失解約退貨權。',
        'B. 無理由，一般外穿成衣非屬法定合理例外排除商品，拆封試穿屬必要檢視行為，仍得於 7 日內解除契約。',
        'C. 有理由，網路特價服飾一律排除消費者保護法適用。',
      ],
      'correctIndex': 1,
      'explanation':
          '依消保法第 19 條及子法規定，一般外穿服飾並非個人貼身衛生用品或易腐敗商品，拆封試穿屬檢查商品之必要行為，企業經營者片面公告「拆封不退」違反強制規定而無效。',
    },
  ];

  void _submitAnswer() {
    if (_selectedAnswerIndex == null || _isAnswered) return;
    HapticFeedback.mediumImpact();

    final q = _questions[_currentStep];
    final correctIdx = q['correctIndex'] as int;
    final options = q['options'] as List<String>;
    final isCorrect = _selectedAnswerIndex == correctIdx;
    if (isCorrect) {
      _correctCount++;
    } else {
      LearningGameState.instance.addIncorrectQuestion(
        q['fact'] as String,
        options[_selectedAnswerIndex!],
        options[correctIdx],
        q['explanation'] as String,
      );
    }

    setState(() {
      _isAnswered = true;
    });
  }

  void _nextStep() {
    HapticFeedback.selectionClick();
    if (_currentStep < _questions.length - 1) {
      setState(() {
        _currentStep++;
        _selectedAnswerIndex = null;
        _isAnswered = false;
      });
    } else {
      if (_correctCount == _questions.length) {
        LearningGameState.instance.unlockBadge('擂台霸主');
        LearningGameState.instance.addExperience(50);
      } else {
        LearningGameState.instance.addExperience(20);
      }
      if (widget.topicTitle != null && widget.topicTitle!.isNotEmpty) {
        LearningGameState.instance.completeStep('${widget.topicTitle}_BOSS');
      }
      _showResultDialog();
    }
  }

  void _showResultDialog() {
    final allCorrect = _correctCount == _questions.length;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        final dt = dialogCtx.tokens;
        return AlertDialog(
          backgroundColor: dt.surfaceElevated,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22.r),
            side: BorderSide(color: dt.borderStrong),
          ),
          title: Column(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: allCorrect
                      ? dt.accentBrassContainer
                      : dt.brandContainer,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: allCorrect ? dt.accentBrass : dt.brandPrimary,
                  ),
                ),
                child: Icon(
                  allCorrect
                      ? PhosphorIconsFill.trophy
                      : PhosphorIconsFill.scales,
                  size: 24.sp,
                  color: allCorrect
                      ? dt.accentOnBrassContainer
                      : dt.brandPrimary,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                allCorrect ? '審判通關 · 完美裁判' : '庭審結束 · 持續精進',
                textAlign: TextAlign.center,
                style: dt.serifTitle(size: 18.sp),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                allCorrect
                    ? '3 道實務模擬卷宗全數裁定正確！已授予「擂台霸主」榮譽印記，並獲得 +50 XP 修煉經驗。'
                    : '本次正確裁定 $_correctCount / ${_questions.length} 案（獲得 +20 XP）。誤判卷宗已自動歸檔至「修煉錯題本」，可隨時複習。',
                textAlign: TextAlign.center,
                style: dt.sansBody(
                  size: 13.sp,
                  color: dt.textPrimary,
                  height: 1.55,
                ),
              ),
              SizedBox(height: 14.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: dt.accentBrassContainer,
                  borderRadius: BorderRadius.circular(99.r),
                ),
                child: Text(
                  allCorrect ? '+50 XP · 榮譽審判長印記解鎖' : '+20 XP · 法學思辨累積中',
                  style: dt.tabularMetric(
                    size: 12.sp,
                    color: dt.accentOnBrassContainer,
                  ),
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.of(dialogCtx).pop();
                Navigator.of(context).pop(true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: dt.brandPrimary,
                foregroundColor: dt.brandOnPrimary,
                padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                '返回修煉地圖',
                style: dt.sansBody(
                  size: 13.sp,
                  weight: FontWeight.w700,
                  color: dt.brandOnPrimary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    final q = _questions[_currentStep];
    final options = q['options'] as List<String>;
    final correctIdx = q['correctIndex'] as int;

    return Scaffold(
      backgroundColor: t.canvas,
      appBar: AppBar(
        backgroundColor: t.canvas,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            PhosphorIconsRegular.caretLeft,
            size: 20.sp,
            color: t.textPrimary,
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              PhosphorIconsFill.gavel,
              size: 18.sp,
              color: t.accentBrass,
            ),
            SizedBox(width: 6.w),
            Flexible(
              child: Text(
                '模擬法庭審判長',
                overflow: TextOverflow.ellipsis,
                style: t.serifTitle(size: 17.5.sp),
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: NotebookBackground(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, safeBottom + 28.h),
          children: [
            // 卷宗事實卡（宋體權威敘事）
            NotebookCard(
              hasBookmark: true,
              bookmarkColor: t.accentBrass,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 6.h,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 9.w,
                          vertical: 3.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: t.accentBrassContainer,
                          borderRadius: BorderRadius.circular(7.r),
                          border: Border.all(
                            color: t.accentBrass.withValues(alpha: 0.45),
                          ),
                        ),
                        child: Text(
                          widget.topicTitle != null
                              ? 'BOSS 庭審 · ${widget.topicTitle}'
                              : 'BOSS 庭審卷宗',
                          style: t.sansBody(
                            size: 11.sp,
                            weight: FontWeight.w700,
                            color: t.accentOnBrassContainer,
                          ),
                        ),
                      ),
                      Text(
                        '審理進度 ${_currentStep + 1} / ${_questions.length}',
                        style: t.tabularMetric(
                          size: 12.sp,
                          color: t.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    q['title'] as String,
                    style: t.serifTitle(size: 17.sp),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    '參照法源：${q['statuteRef']}',
                    style: t.sansBody(
                      size: 11.5.sp,
                      weight: FontWeight.w600,
                      color: t.brandPrimary,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: t.surfaceSubtle,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border(
                        left: BorderSide(color: t.accentBrass, width: 3.w),
                      ),
                    ),
                    child: Text(
                      q['fact'] as String,
                      style: t.serifBody(
                        size: 14.sp,
                        height: 1.68,
                        color: t.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 6.h),

            // 裁定選項（標準語意圓形單選圖示 + 完整深色模式對比）
            for (var index = 0; index < options.length; index++)
              _buildOptionTile(
                t: t,
                index: index,
                label: options[index],
                isSelected: _selectedAnswerIndex == index,
                isCorrectOpt: _isAnswered && index == correctIdx,
                isWrongOpt: _isAnswered &&
                    _selectedAnswerIndex == index &&
                    index != correctIdx,
              ),

            // 白話判決理由書
            if (_isAnswered) ...[
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: t.brandContainer.withValues(
                    alpha: t.isDark ? 0.55 : 0.72,
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: t.brandPrimary.withValues(alpha: 0.35),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          PhosphorIconsFill.scales,
                          size: 16.sp,
                          color: t.brandPrimary,
                        ),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            '審判長白話判決理由要旨',
                            style: t.serifTitle(
                              size: 14.5.sp,
                              color: t.brandOnContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      q['explanation'] as String,
                      style: t.sansBody(
                        size: 13.sp,
                        height: 1.55,
                        color: t.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: 18.h),

            if (!_isAnswered)
              FilledButton.icon(
                onPressed: _selectedAnswerIndex == null ? null : _submitAnswer,
                icon: Icon(
                  PhosphorIconsFill.gavel,
                  size: 17.sp,
                  color: t.brandOnPrimary,
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: t.brandPrimary,
                  foregroundColor: t.brandOnPrimary,
                  disabledBackgroundColor: t.surfaceMuted,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                label: Text(
                  '敲定法槌 · 宣判裁定',
                  style: t.sansBody(
                    size: 14.sp,
                    weight: FontWeight.w700,
                    color: _selectedAnswerIndex == null
                        ? t.textMuted
                        : t.brandOnPrimary,
                  ),
                ),
              )
            else
              FilledButton.icon(
                onPressed: _nextStep,
                icon: Icon(
                  PhosphorIconsBold.arrowRight,
                  size: 16.sp,
                  color: t.accentOnBrassContainer,
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: t.accentBrassContainer,
                  foregroundColor: t.accentOnBrassContainer,
                  side: BorderSide(color: t.accentBrass),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                label: Text(
                  _currentStep == _questions.length - 1
                      ? '檢視庭審總評與領取經驗值'
                      : '審理下一宗案件',
                  style: t.sansBody(
                    size: 14.sp,
                    weight: FontWeight.w700,
                    color: t.accentOnBrassContainer,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required PreambleTokens t,
    required int index,
    required String label,
    required bool isSelected,
    required bool isCorrectOpt,
    required bool isWrongOpt,
  }) {
    Color fill = t.surface;
    Color borderColor = t.border;
    IconData iconData = PhosphorIconsRegular.circle;
    Color iconColor = t.textMuted;

    if (isCorrectOpt) {
      fill = t.semanticSuccessContainer;
      borderColor = t.semanticSuccess;
      iconData = PhosphorIconsFill.checkCircle;
      iconColor = t.semanticSuccess;
    } else if (isWrongOpt) {
      fill = t.semanticUrgentContainer;
      borderColor = t.semanticUrgent;
      iconData = PhosphorIconsFill.xCircle;
      iconColor = t.semanticUrgent;
    } else if (isSelected) {
      fill = t.accentBrassContainer;
      borderColor = t.accentBrass;
      iconData = PhosphorIconsFill.checkCircle;
      iconColor = t.accentOnBrassContainer;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isAnswered
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _selectedAnswerIndex = index;
                  });
                },
          borderRadius: BorderRadius.circular(14.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: borderColor,
                width: (isSelected || isCorrectOpt || isWrongOpt) ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 2.h),
                  child: Icon(
                    iconData,
                    size: 19.sp,
                    color: iconColor,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    label,
                    style: t.sansBody(
                      size: 13.sp,
                      weight: FontWeight.w600,
                      color: t.textPrimary,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
