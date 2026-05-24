import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/features/case_time_machine/theme/case_time_machine_theme.dart';

class ExpandableDossierSection extends StatelessWidget {
  const ExpandableDossierSection(
      {super.key, required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        collapsedIconColor: CaseTimeMachineColors.libraryMutedGold,
        iconColor: CaseTimeMachineColors.libraryMutedGold,
        title:
            Text(title, style: CaseTimeMachineTextStyles.sectionTitle(context)),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(bottom: CaseTimeMachineSpacing.spaceM.h),
              child: Text(body, style: CaseTimeMachineTextStyles.body(context)),
            ),
          ),
        ],
      ),
    );
  }
}
