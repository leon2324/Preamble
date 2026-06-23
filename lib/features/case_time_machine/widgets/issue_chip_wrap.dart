import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/features/case_time_machine/theme/case_time_machine_theme.dart';

class IssueChipWrap extends StatelessWidget {
  const IssueChipWrap({super.key, required this.labels});

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 7.w,
      runSpacing: 7.h,
      children: [
        for (final label in labels)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border:
                  Border.all(color: CaseTimeMachineColors.libraryBorderMist),
              color:
                  CaseTimeMachineColors.libraryDeepGreen.withValues(alpha: .46),
            ),
            child:
                Text(label, style: CaseTimeMachineTextStyles.chipText(context)),
          ),
      ],
    );
  }
}
