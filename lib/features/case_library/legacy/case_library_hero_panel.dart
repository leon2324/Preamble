import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/features/case_library/data/case_library_data.dart';
import 'package:preamble/features/case_library/theme/case_library_theme.dart';

class CaseLibraryHeroPanel extends StatelessWidget {
  const CaseLibraryHeroPanel({
    super.key,
    required this.title,
    required this.subtitle,
    this.eyebrow,
    this.emblemAsset = caseLibraryV2CaseBookCoverAsset,
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
            color: CaseLibraryColors.libraryMidnight.withValues(alpha: .72),
            border: Border.all(color: CaseLibraryColors.libraryBorderGold),
            boxShadow: [CaseLibraryShadows.mistGlow],
          ),
          child: ClipOval(child: Image.asset(emblemAsset, fit: BoxFit.cover)),
        ),
        SizedBox(height: CaseLibrarySpacing.spaceM.h),
        if (eyebrow != null)
          Text(eyebrow!,
              style: CaseLibraryTextStyles.caption(context)
                  .copyWith(letterSpacing: 3)),
        Text(title,
            textAlign: TextAlign.center,
            style: CaseLibraryTextStyles.displayTitle(context)),
        SizedBox(height: CaseLibrarySpacing.spaceS.h),
        Container(
            width: 132.w,
            height: 1,
            color: CaseLibraryColors.libraryMutedGold.withValues(alpha: .72)),
        SizedBox(height: CaseLibrarySpacing.spaceM.h),
        Text(subtitle,
            textAlign: TextAlign.center,
            style: CaseLibraryTextStyles.body(context)),
      ],
    );
  }
}
