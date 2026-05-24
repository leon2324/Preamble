import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/features/case_time_machine/models/case_time_machine_models.dart';
import 'package:lawapp/features/case_time_machine/theme/case_time_machine_theme.dart';

class CasePersonRoleCard extends StatelessWidget {
  const CasePersonRoleCard({super.key, required this.role});

  final CasePersonRole role;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: CaseTimeMachineSpacing.spaceS.h),
      padding: EdgeInsets.all(CaseTimeMachineSpacing.spaceM.w),
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(CaseTimeMachineRadii.radiusMedium.r),
        border: Border.all(color: CaseTimeMachineColors.libraryBorderMist),
        color: CaseTimeMachineColors.libraryDeepGreen.withValues(alpha: .74),
      ),
      child: Row(
        children: [
          Icon(Icons.person_outline_rounded,
              color: CaseTimeMachineColors.libraryMutedGold, size: 20.sp),
          SizedBox(width: CaseTimeMachineSpacing.spaceM.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(role.role,
                    style: CaseTimeMachineTextStyles.cardTitle(context)),
                Text(role.description,
                    style: CaseTimeMachineTextStyles.bodySmall(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
