import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/features/case_time_machine/theme/case_time_machine_theme.dart';

class CaseMemoryLine extends StatelessWidget {
  const CaseMemoryLine({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(CaseTimeMachineSpacing.spaceL.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(CaseTimeMachineRadii.radiusLarge.r),
        color: CaseTimeMachineColors.libraryDeepTeal.withValues(alpha: .42),
        border: Border.all(color: CaseTimeMachineColors.libraryBorderMist),
      ),
      child: Text('「$text」',
          textAlign: TextAlign.center,
          style: CaseTimeMachineTextStyles.body(context)
              .copyWith(color: CaseTimeMachineColors.libraryFogWhite)),
    );
  }
}
