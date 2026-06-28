import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/features/case_library/models/case_library_models.dart';
import 'package:preamble/features/case_library/theme/case_library_theme.dart';
import 'package:preamble/features/case_library/widgets/related_case_card.dart';

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
      margin: EdgeInsets.only(bottom: CaseLibrarySpacing.spaceL.h),
      padding: EdgeInsets.all(CaseLibrarySpacing.spaceM.w),
      decoration: BoxDecoration(
        color: CaseLibraryColors.libraryMidnight.withValues(alpha: .76),
        borderRadius: BorderRadius.circular(CaseLibraryRadii.radiusMedium.r),
        border: Border.all(
          color: CaseLibraryColors.libraryBorderMist.withValues(alpha: .66),
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
                  color: CaseLibraryColors.libraryMutedGold,
                ),
              ),
              SizedBox(width: CaseLibrarySpacing.spaceS.w),
              Text(title, style: CaseLibraryTextStyles.cardTitle(context)),
            ],
          ),
          SizedBox(height: CaseLibrarySpacing.spaceM.h),
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
