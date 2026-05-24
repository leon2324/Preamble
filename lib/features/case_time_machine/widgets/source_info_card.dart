import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/features/case_time_machine/models/case_time_machine_models.dart';
import 'package:lawapp/features/case_time_machine/theme/case_time_machine_theme.dart';

class SourceInfoCard extends StatelessWidget {
  const SourceInfoCard({super.key, required this.source});

  final CaseSource source;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: CaseTimeMachineSpacing.spaceS.h),
      child: Text('${source.sourceType}｜${source.title}｜更新 ${source.updatedAt}',
          style: CaseTimeMachineTextStyles.caption(context)),
    );
  }
}
