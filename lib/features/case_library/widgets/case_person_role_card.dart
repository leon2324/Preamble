import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/features/case_library/models/case_library_models.dart';
import 'package:preamble/features/case_library/theme/case_library_theme.dart';

class CasePersonRoleCard extends StatelessWidget {
  const CasePersonRoleCard({super.key, required this.role});

  final CasePersonRole role;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: CaseLibrarySpacing.spaceS.h),
      padding: EdgeInsets.all(CaseLibrarySpacing.spaceM.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(CaseLibraryRadii.radiusMedium.r),
        border: Border.all(color: CaseLibraryColors.libraryBorderMist),
        color: CaseLibraryColors.libraryDeepGreen.withValues(alpha: .74),
      ),
      child: Row(
        children: [
          Icon(Icons.person_outline_rounded,
              color: CaseLibraryColors.libraryMutedGold, size: 20.sp),
          SizedBox(width: CaseLibrarySpacing.spaceM.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(role.role,
                    style: CaseLibraryTextStyles.cardTitle(context)),
                Text(role.description,
                    style: CaseLibraryTextStyles.bodySmall(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
