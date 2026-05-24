import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/features/case_time_machine/models/case_time_machine_models.dart';
import 'package:lawapp/features/case_time_machine/theme/case_time_machine_theme.dart';
import 'package:lawapp/features/case_time_machine/widgets/related_case_card.dart';

class RelatedCaseShelfSections extends StatelessWidget {
  const RelatedCaseShelfSections({
    super.key,
    required this.relatedCases,
    required this.onCaseTap,
  });

  final List<RelatedCase> relatedCases;
  final ValueChanged<RelatedCase> onCaseTap;

  @override
  Widget build(BuildContext context) {
    final sameEra = relatedCases.take(1).toList();
    final sameTheme = relatedCases.skip(1).take(1).toList();
    final curatorPicks = relatedCases.take(3).toList();

    // 台灣繁體中文教學註解：
    // 延伸書架維持「直向分區」：同年代、同主題、館員推薦。
    // 這樣符合 Prototype 的案件圖書館世界觀，也避免變成一般橫向推薦 carousel。
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RelatedShelfBlock(
          title: '同年代書架',
          cases: sameEra.isEmpty ? relatedCases : sameEra,
          onCaseTap: onCaseTap,
        ),
        _RelatedShelfBlock(
          title: '同主題書架',
          cases: sameTheme.isEmpty ? relatedCases : sameTheme,
          onCaseTap: onCaseTap,
        ),
        _RelatedShelfBlock(
          title: '館員推薦',
          cases: curatorPicks,
          onCaseTap: onCaseTap,
        ),
      ],
    );
  }
}

class _RelatedShelfBlock extends StatelessWidget {
  const _RelatedShelfBlock({
    required this.title,
    required this.cases,
    required this.onCaseTap,
  });

  final String title;
  final List<RelatedCase> cases;
  final ValueChanged<RelatedCase> onCaseTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: CaseTimeMachineSpacing.spaceL.h),
      padding: EdgeInsets.all(CaseTimeMachineSpacing.spaceM.w),
      decoration: BoxDecoration(
        color: CaseTimeMachineColors.libraryMidnight.withValues(alpha: .76),
        borderRadius:
            BorderRadius.circular(CaseTimeMachineRadii.radiusMedium.r),
        border: Border.all(
          color: CaseTimeMachineColors.libraryBorderMist.withValues(alpha: .66),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28.w,
                height: 7.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: CaseTimeMachineColors.libraryMutedGold,
                ),
              ),
              SizedBox(width: CaseTimeMachineSpacing.spaceS.w),
              Text(title, style: CaseTimeMachineTextStyles.cardTitle(context)),
            ],
          ),
          SizedBox(height: CaseTimeMachineSpacing.spaceM.h),
          for (final relatedCase in cases)
            RelatedCaseCard(
              relatedCase: relatedCase,
              onTap: () => onCaseTap(relatedCase),
            ),
        ],
      ),
    );
  }
}
