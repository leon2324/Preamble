import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/features/case_time_machine/models/case_time_machine_models.dart';
import 'package:lawapp/features/case_time_machine/theme/case_time_machine_theme.dart';

class RelatedCaseCard extends StatelessWidget {
  const RelatedCaseCard(
      {super.key, required this.relatedCase, required this.onTap});

  final RelatedCase relatedCase;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(CaseTimeMachineRadii.radiusMedium.r),
        child: Container(
          margin: EdgeInsets.only(bottom: CaseTimeMachineSpacing.spaceS.h),
          padding: EdgeInsets.all(CaseTimeMachineSpacing.spaceM.w),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(CaseTimeMachineRadii.radiusMedium.r),
            border: Border.all(color: CaseTimeMachineColors.libraryBorderGold),
            color:
                CaseTimeMachineColors.libraryDeepGreen.withValues(alpha: .76),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(relatedCase.yearLabel,
                        style: CaseTimeMachineTextStyles.chipText(context)),
                    Text(relatedCase.title,
                        style: CaseTimeMachineTextStyles.cardTitle(context)),
                    Text(relatedCase.reason,
                        style: CaseTimeMachineTextStyles.bodySmall(context)),
                  ],
                ),
              ),
              Icon(CupertinoIcons.chevron_right,
                  color: CaseTimeMachineColors.libraryMutedGold, size: 16.sp),
            ],
          ),
        ),
      ),
    );
  }
}
