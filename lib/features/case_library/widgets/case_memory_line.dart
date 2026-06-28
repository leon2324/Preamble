import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/features/case_library/theme/case_library_theme.dart';

class CaseMemoryLine extends StatelessWidget {
  const CaseMemoryLine({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(CaseLibrarySpacing.spaceL.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(CaseLibraryRadii.radiusLarge.r),
        color: CaseLibraryColors.libraryDeepTeal.withValues(alpha: .42),
        border: Border.all(color: CaseLibraryColors.libraryBorderMist),
      ),
      child: Text('「$text」',
          textAlign: TextAlign.center,
          style: CaseLibraryTextStyles.body(context)
              .copyWith(color: CaseLibraryColors.libraryFogWhite)),
    );
  }
}
