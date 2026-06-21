part of '../case_dossier_detail_page.dart';

// 台灣繁體中文教學註解：
// 這個 part 檔集中收納案件詳情頁的 Bottom Sheet UI。
// 呼叫時機、route/navigation 與資料 helper 仍保留在主頁狀態類別中。

extension _CaseDossierBottomSheets on _CaseDossierDetailPageState {
  void _showLawBottomSheet(BuildContext context, RelatedLaw law) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: CaseTimeMachineColors.bgCream,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 36.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: CaseTimeMachineColors.borderLight,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    child: Text(
                      '${law.lawName} ${law.articleNumber}',
                      style: TextStyle(
                        fontFamily: 'Songti TC',
                        fontFamilyFallback: const [
                          'BiauKai',
                          'Songti SC',
                          'STSong'
                        ],
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: CaseTimeMachineColors.primaryGreen,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: CaseTimeMachineColors.accentGold
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      '關聯法條',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: CaseTimeMachineColors.accentGold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              const Divider(color: CaseTimeMachineColors.borderLight),
              SizedBox(height: 16.h),
              Text(
                '【條文概要與釋義】',
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w900,
                  color: CaseTimeMachineColors.accentGold,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                law.plainSummary,
                style: TextStyle(
                  fontSize: 13.sp,
                  height: 1.6,
                  color: CaseTimeMachineColors.textPrimary,
                ),
              ),
              if (law.relationToCase.isNotEmpty) ...[
                SizedBox(height: 20.h),
                Text(
                  '【本案關聯與適用】',
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w900,
                    color: CaseTimeMachineColors.accentGold,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  law.relationToCase,
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    height: 1.6,
                    color: CaseTimeMachineColors.textSecondary,
                  ),
                ),
              ],
              SizedBox(height: 28.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CaseTimeMachineColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('我知道了',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showHoldingBottomSheet(BuildContext context, _TrialStep step) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: CaseTimeMachineColors.bgCream,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 36.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: CaseTimeMachineColors.borderLight,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: CaseTimeMachineColors.accentGold
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      step.stage,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: CaseTimeMachineColors.accentGold,
                      ),
                    ),
                  ),
                  Text(
                    step.date,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: CaseTimeMachineColors.textMuted,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                step.courtName,
                style: TextStyle(
                  fontFamily: 'Songti TC',
                  fontFamilyFallback: const ['BiauKai', 'Songti SC', 'STSong'],
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: CaseTimeMachineColors.primaryGreen,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                step.caseNumber,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: CaseTimeMachineColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 16.h),
              const Divider(color: CaseTimeMachineColors.borderLight),
              SizedBox(height: 16.h),
              Text(
                '判決主文與核心理由',
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w900,
                  color: CaseTimeMachineColors.primaryGreen,
                ),
              ),
              SizedBox(height: 10.h),
              Flexible(
                child: SingleChildScrollView(
                  child: Text(
                    step.holdingDetail,
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      height: 1.6,
                      color: CaseTimeMachineColors.textPrimary,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: CaseTimeMachineColors.primaryGreen,
                        side: const BorderSide(
                            color: CaseTimeMachineColors.primaryGreen),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      icon: CtmSvgIcon(
                        CtmSvgIcons.copy,
                        size: 16.sp,
                        color: CaseTimeMachineColors.primaryGreen,
                      ),
                      label: const Text('複製案號資訊',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  '已複製：${step.courtName} ${step.caseNumber}')),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CaseTimeMachineColors.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      icon: CtmSvgIcon(
                        CtmSvgIcons.externalLink,
                        size: 16.sp,
                        color: Colors.white,
                      ),
                      label: const Text('官方裁判書連結',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('正在開起司法行政機關裁判書系統...')),
                        );
                      },
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

  void _showGlossaryBottomSheet(BuildContext context, _GlossaryItem item) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: CaseTimeMachineColors.bgCream,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 36.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: CaseTimeMachineColors.borderLight,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    item.term,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: CaseTimeMachineColors.primaryGreen,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      '(${item.pinyin})',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontStyle: FontStyle.italic,
                        color: CaseTimeMachineColors.textMuted,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              const Divider(color: CaseTimeMachineColors.borderLight),
              SizedBox(height: 16.h),
              Text(
                '【名詞釋義】',
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w900,
                  color: CaseTimeMachineColors.accentGold,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                item.definition,
                style: TextStyle(
                  fontSize: 13.sp,
                  height: 1.5,
                  color: CaseTimeMachineColors.textPrimary,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                '【本案關聯】',
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w900,
                  color: CaseTimeMachineColors.accentGold,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                item.importance,
                style: TextStyle(
                  fontSize: 12.5.sp,
                  height: 1.5,
                  color: CaseTimeMachineColors.textSecondary,
                ),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CaseTimeMachineColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: const Text('我知道了',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
