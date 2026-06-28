import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/features/case_library/models/case_library_models.dart';
import 'package:preamble/features/case_library/theme/case_library_theme.dart';

class RelatedLawCard extends StatelessWidget {
  const RelatedLawCard({super.key, required this.law});

  final RelatedLaw law;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: CaseLibrarySpacing.spaceS.h),
      padding: EdgeInsets.all(CaseLibrarySpacing.spaceM.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(CaseLibraryRadii.radiusMedium.r),
        border: Border.all(color: CaseLibraryColors.libraryBorderMist),
      ),
      child: Text(
          '${law.lawName} ${law.articleNumber}｜${law.plainSummary}\n${law.relationToCase}',
          style: CaseLibraryTextStyles.bodySmall(context)),
    );
  }
}
