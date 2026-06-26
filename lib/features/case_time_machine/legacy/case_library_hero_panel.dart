import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/features/case_time_machine/data/case_time_machine_mock_data.dart';
import 'package:preamble/features/case_time_machine/theme/case_time_machine_theme.dart';

class CaseLibraryHeroPanel extends StatelessWidget {
  const CaseLibraryHeroPanel({
    super.key,
    required this.title,
    required this.subtitle,
    this.eyebrow,
    this.emblemAsset = caseTimeMachineV2CaseBookCoverAsset,
  });

  final String title;
  final String subtitle;
  final String? eyebrow;
  final String emblemAsset;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64.w,
          height: 64.w,
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: CaseTimeMachineColors.libraryMidnight.withValues(alpha: .72),
            border: Border.all(color: CaseTimeMachineColors.libraryBorderGold),
            boxShadow: [CaseTimeMachineShadows.mistGlow],
          ),
          child: ClipOval(child: Image.asset(emblemAsset, fit: BoxFit.cover)),
        ),
        SizedBox(height: CaseTimeMachineSpacing.spaceM.h),
        if (eyebrow != null)
          Text(eyebrow!,
              style: CaseTimeMachineTextStyles.caption(context)
                  .copyWith(letterSpacing: 3)),
        Text(title,
            textAlign: TextAlign.center,
            style: CaseTimeMachineTextStyles.displayTitle(context)),
        SizedBox(height: CaseTimeMachineSpacing.spaceS.h),
        Container(
            width: 132.w,
            height: 1,
            color:
                CaseTimeMachineColors.libraryMutedGold.withValues(alpha: .72)),
        SizedBox(height: CaseTimeMachineSpacing.spaceM.h),
        Text(subtitle,
            textAlign: TextAlign.center,
            style: CaseTimeMachineTextStyles.body(context)),
      ],
    );
  }
}
