import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/features/case_time_machine/models/case_time_machine_models.dart';
import 'package:preamble/features/case_time_machine/theme/case_time_machine_theme.dart';

class RelatedLawCard extends StatelessWidget {
  const RelatedLawCard({super.key, required this.law});

  final RelatedLaw law;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: CaseTimeMachineSpacing.spaceS.h),
      padding: EdgeInsets.all(CaseTimeMachineSpacing.spaceM.w),
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(CaseTimeMachineRadii.radiusMedium.r),
        border: Border.all(color: CaseTimeMachineColors.libraryBorderMist),
      ),
      child: Text(
          '${law.lawName} ${law.articleNumber}｜${law.plainSummary}\n${law.relationToCase}',
          style: CaseTimeMachineTextStyles.bodySmall(context)),
    );
  }
}
