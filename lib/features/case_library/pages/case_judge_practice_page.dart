import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:preamble/features/case_library/data/case_interactive_profiles.dart';
import 'package:preamble/features/case_library/models/case_library_models.dart';
import 'package:preamble/features/case_library/theme/case_library_theme.dart';
import 'package:preamble/features/case_library/widgets/case_library_svg_icon.dart';

// 「如果你是法官」互動練習頁面 (CaseJudgePracticePage)
// 旨在讓使用者先閱讀案件背景與爭點，在不知道或對比實際判決前，
// 先選取符合自身直覺法感的立場，再將其立場與法院實際理由進行 1:1 的雷達對照，
// 藉此達成「先判斷再對照」的法學思辨學習效果。
class CaseJudgePracticePage extends StatefulWidget {
  const CaseJudgePracticePage({
    super.key,
    required this.book,
  });

  final CaseBook book;

  @override
  State<CaseJudgePracticePage> createState() => _CaseJudgePracticePageState();
}

class _CaseJudgePracticePageState extends State<CaseJudgePracticePage>
    with SingleTickerProviderStateMixin {
  int? _selectedStanceIndex;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // 取得該案件 100% 獨立量身打造之法官心證選項
  List<Map<String, dynamic>> _getStances() {
    return CaseInteractiveProfiles.getJudgeStances(widget.book);
  }

  void _selectStance(int index) {
    setState(() {
      _selectedStanceIndex = index;
    });
    _animController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final stances = _getStances();
    final hasSelected = _selectedStanceIndex != null;

    return Scaffold(
      backgroundColor: CaseLibraryColors.bgCream,
      body: SafeArea(
        child: Column(
          children: [
            // 置中 AppBar，左右圖示緊貼邊界，返回鍵置左，移除所有預設內距。
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              child: SizedBox(
                height: 56.h,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      left: 0,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: SvgPicture.string(
                          _svgBackIcon,
                          width: 20.w,
                          height: 20.w,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 60.w),
                        child: Text(
                          '如果你是法官',
                          style: LightTextStyles.pageTitle(context).copyWith(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 頂部進度指引與案件名稱橫幅。
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFBF8F2),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: CaseLibraryColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 6.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: CaseLibraryColors.primaryGreen
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          widget.book.displayCode,
                          style: TextStyle(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.bold,
                            color: CaseLibraryColors.primaryGreen,
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          widget.book.titleZh,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: LightTextStyles.cardTitle(context).copyWith(
                            fontSize: 12.5.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    '法感練習：請依據以下背景，在做出判決前選出符合您正義直覺的論點。',
                    style: LightTextStyles.caption(context).copyWith(
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 32.h),
                children: [
                  // 案件背景卡
                  _buildCaseIntroCard(),
                  SizedBox(height: 14.h),

                  // 核心爭點
                  _buildIssueSnippetCard(),
                  SizedBox(height: 16.h),

                  // 標題：你的抉擇
                  Text(
                    hasSelected ? '⚖️ 抉擇對照分析' : '👉 請選擇你的法官立場：',
                    style: LightTextStyles.sectionTitle(context).copyWith(
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 10.h),

                  // 抉擇面板
                  if (!hasSelected) ...[
                    for (int i = 0; i < stances.length; i++)
                      _buildStanceButton(i, stances[i])
                  ] else ...[
                    _buildComparisonPanel(stances[_selectedStanceIndex!]),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaseIntroCard() {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [CaseLibraryShadows.softShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 5.w,
                height: 14.h,
                decoration: BoxDecoration(
                  color: CaseLibraryColors.accentGold,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                '事件背景',
                style: LightTextStyles.cardTitle(context).copyWith(
                  fontSize: 13.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            widget.book.background,
            style: LightTextStyles.body(context).copyWith(
              fontSize: 12.sp,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIssueSnippetCard() {
    final hasIssues = widget.book.legalIssues.isNotEmpty;
    final issueText = hasIssues
        ? widget.book.legalIssues.first.title
        : '被告行為是否符合緊急避難或相關阻卻違法事由？';
    final issueExplain = hasIssues
        ? widget.book.legalIssues.first.plainExplanation
        : '法律須審酌手段是否為唯一且最小侵害之途徑。';

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF5FAF8),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFDCEFE9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CaseLibrarySvgIcon(
                CaseLibrarySvgIcons.gavel,
                size: 16,
                color: Color(0xFF1B5E4F),
              ),
              SizedBox(width: 8.w),
              Text(
                '本案焦點法律爭點',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1B5E4F),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'Q: $issueText',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1B5E4F),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            issueExplain,
            style: TextStyle(
              fontSize: 11.sp,
              color: const Color(0xFF336E60),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStanceButton(int index, Map<String, dynamic> stance) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectStance(index),
          borderRadius: BorderRadius.circular(14.r),
          child: Ink(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: CaseLibraryColors.borderLight),
              boxShadow: [CaseLibraryShadows.softShadow],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 20.w,
                  height: 20.w,
                  margin: EdgeInsets.only(top: 2.h),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: CaseLibraryColors.accentGold,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 10.w,
                      height: 10.w,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stance['title'] as String,
                        style: LightTextStyles.cardTitle(context).copyWith(
                          fontSize: 13.sp,
                          color: CaseLibraryColors.primaryGreen,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        stance['description'] as String,
                        style: LightTextStyles.bodySmall(context).copyWith(
                          fontSize: 11.sp,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildComparisonPanel(Map<String, dynamic> selectedStance) {
    return Column(
      children: [
        // 當使用者選取立場後，顯示精心設計的 SVG 天平動畫。
        // 天平會根據所選立場的 'tiltAngle' 產生動態傾斜，生動地表現出法益權衡。
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            final double currentTilt =
                (selectedStance['tiltAngle'] as double) * _scaleAnimation.value;
            return Container(
              height: 130.h,
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFDFBF7),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: CaseLibraryColors.borderLight),
              ),
              child: Center(
                child: Transform.rotate(
                  angle: currentTilt,
                  child: SvgPicture.string(
                    _svgBalanceScale,
                    width: 100.w,
                    height: 100.w,
                  ),
                ),
              ),
            );
          },
        ),
        SizedBox(height: 14.h),

        // 法益一致性匹配結果
        Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color:
                (selectedStance['matchColor'] as Color).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: (selectedStance['matchColor'] as Color)
                  .withValues(alpha: 0.28),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.compare_arrows,
                    size: 16.sp,
                    color: selectedStance['matchColor'] as Color,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    '法感匹配度：${selectedStance['matchText']}',
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w900,
                      color: selectedStance['matchColor'] as Color,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              Text(
                selectedStance['analysis'] as String,
                style: TextStyle(
                  fontSize: 11.5.sp,
                  color: const Color(0xFF2C3532),
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 14.h),

        // 法院判決原文卡
        Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: CaseLibraryColors.borderLight),
            boxShadow: [CaseLibraryShadows.softShadow],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CaseLibrarySvgIcon(
                    CaseLibrarySvgIcons.award,
                    size: 16,
                    color: Color(0xFFB08C4A),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '法院裁判結果與理由',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w900,
                      color: CaseLibraryColors.primaryGreen,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF6EE),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  widget.book.judgmentResult,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF8C6E3B),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                widget.book.courtReasoning,
                style: LightTextStyles.body(context).copyWith(
                  fontSize: 12.sp,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20.h),

        // 重新選擇
        TextButton.icon(
          onPressed: () {
            setState(() {
              _selectedStanceIndex = null;
            });
          },
          icon: const Icon(Icons.refresh, size: 14),
          label: Text(
            '重新選擇立場',
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
          ),
          style: TextButton.styleFrom(
            foregroundColor: CaseLibraryColors.textMuted,
          ),
        )
      ],
    );
  }

  // 返回鍵與天平圖形專用向量 SVG 定義。
  static const String _svgBackIcon = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round">
  <path d="m15 18-6-6 6-6"></path>
</svg>
''';

  static const String _svgBalanceScale = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" fill="currentColor">
  <!-- 支架 (底座與中心軸) -->
  <rect x="47" y="20" width="6" height="60" rx="2" fill="#5C5144"/>
  <rect x="35" y="77" width="30" height="6" rx="2" fill="#5C5144"/>
  
  <!-- 橫樑 -->
  <line x1="15" y1="35" x2="85" y2="35" stroke="#8A7761" stroke-width="5" stroke-linecap="round"/>
  <circle cx="50" cy="35" r="5" fill="#B09A80"/>
  
  <!-- 左秤盤與吊線 -->
  <line x1="15" y1="35" x2="5" y2="60" stroke="#8A7761" stroke-width="2"/>
  <line x1="15" y1="35" x2="25" y2="60" stroke="#8A7761" stroke-width="2"/>
  <path d="M2" y1="60" x2="28" y2="60" d="M 2 60 A 13 13 0 0 0 28 60 Z" fill="#D6C7B2"/>
  
  <!-- 右秤盤與吊線 -->
  <line x1="85" y1="35" x2="75" y2="60" stroke="#8A7761" stroke-width="2"/>
  <line x1="85" y1="35" x2="95" y2="60" stroke="#8A7761" stroke-width="2"/>
  <path d="M72" y1="60" x2="98" y2="60" d="M 72 60 A 13 13 0 0 0 98 60 Z" fill="#D6C7B2"/>
</svg>
''';
}
