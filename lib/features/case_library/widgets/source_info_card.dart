import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/features/case_library/models/case_library_models.dart';
import 'package:preamble/features/case_library/theme/case_library_theme.dart';

class SourceInfoCard extends StatelessWidget {
  const SourceInfoCard({super.key, required this.source});

  final CaseSource source;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: CaseLibrarySpacing.spaceS.h),
      child: Text('${source.sourceType}｜${source.title}｜更新 ${source.updatedAt}',
          style: CaseLibraryTextStyles.caption(context)),
    );
  }
}
