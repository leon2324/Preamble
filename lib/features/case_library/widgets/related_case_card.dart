import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/features/case_library/models/case_library_models.dart';
import 'package:preamble/features/case_library/theme/case_library_theme.dart';

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
        borderRadius: BorderRadius.circular(CaseLibraryRadii.radiusMedium.r),
        child: Container(
          margin: EdgeInsets.only(bottom: CaseLibrarySpacing.spaceS.h),
          padding: EdgeInsets.all(CaseLibrarySpacing.spaceM.w),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(CaseLibraryRadii.radiusMedium.r),
            border: Border.all(color: CaseLibraryColors.libraryBorderGold),
            color: CaseLibraryColors.libraryDeepGreen.withValues(alpha: .76),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(relatedCase.yearLabel,
                        style: CaseLibraryTextStyles.chipText(context)),
                    Text(relatedCase.title,
                        style: CaseLibraryTextStyles.cardTitle(context)),
                    Text(relatedCase.reason,
                        style: CaseLibraryTextStyles.bodySmall(context)),
                  ],
                ),
              ),
              Icon(CupertinoIcons.chevron_right,
                  color: CaseLibraryColors.libraryMutedGold, size: 16.sp),
            ],
          ),
        ),
      ),
    );
  }
}
