import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/features/case_library/models/case_library_models.dart';
import 'package:preamble/features/case_library/theme/case_library_theme.dart';

class LegalIssueCard extends StatelessWidget {
  const LegalIssueCard({super.key, required this.issue});

  final LegalIssue issue;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: CaseLibrarySpacing.spaceM.h),
      padding: EdgeInsets.all(CaseLibrarySpacing.spaceM.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(CaseLibraryRadii.radiusMedium.r),
        border: Border.all(color: CaseLibraryColors.libraryBorderGold),
        color: CaseLibraryColors.libraryDeepTeal.withValues(alpha: .76),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(issue.title, style: CaseLibraryTextStyles.cardTitle(context)),
          SizedBox(height: CaseLibrarySpacing.spaceS.h),
          Text(issue.plainExplanation,
              style: CaseLibraryTextStyles.bodySmall(context)),
          SizedBox(height: CaseLibrarySpacing.spaceS.h),
          Text(issue.relationToCase,
              style: CaseLibraryTextStyles.caption(context)),
        ],
      ),
    );
  }
}
