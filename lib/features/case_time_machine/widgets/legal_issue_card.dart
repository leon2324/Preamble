import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/features/case_time_machine/models/case_time_machine_models.dart';
import 'package:lawapp/features/case_time_machine/theme/case_time_machine_theme.dart';

class LegalIssueCard extends StatelessWidget {
  const LegalIssueCard({super.key, required this.issue});

  final LegalIssue issue;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: CaseTimeMachineSpacing.spaceM.h),
      padding: EdgeInsets.all(CaseTimeMachineSpacing.spaceM.w),
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(CaseTimeMachineRadii.radiusMedium.r),
        border: Border.all(color: CaseTimeMachineColors.libraryBorderGold),
        color: CaseTimeMachineColors.libraryDeepTeal.withValues(alpha: .76),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(issue.title,
              style: CaseTimeMachineTextStyles.cardTitle(context)),
          SizedBox(height: CaseTimeMachineSpacing.spaceS.h),
          Text(issue.plainExplanation,
              style: CaseTimeMachineTextStyles.bodySmall(context)),
          SizedBox(height: CaseTimeMachineSpacing.spaceS.h),
          Text(issue.relationToCase,
              style: CaseTimeMachineTextStyles.caption(context)),
        ],
      ),
    );
  }
}
