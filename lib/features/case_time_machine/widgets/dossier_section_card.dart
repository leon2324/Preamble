import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/features/case_time_machine/theme/case_time_machine_theme.dart';
import 'package:lawapp/features/case_time_machine/widgets/_ctm_surface.dart';

class DossierSectionCard extends StatelessWidget {
  const DossierSectionCard(
      {super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CtmSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: CaseTimeMachineTextStyles.sectionTitle(context)),
          SizedBox(height: CaseTimeMachineSpacing.spaceM.h),
          child,
        ],
      ),
    );
  }
}
