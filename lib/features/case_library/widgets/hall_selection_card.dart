import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/features/case_library/data/case_library_data.dart';
import 'package:preamble/features/case_library/models/case_library_models.dart';
import 'package:preamble/features/case_library/theme/case_library_theme.dart';
import 'package:preamble/features/case_library/widgets/_case_library_surface.dart';

class HallSelectionCard extends StatelessWidget {
  const HallSelectionCard({super.key, required this.hall, required this.onTap});

  final CaseLibraryHall hall;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CaseLibrarySurface(
      onTap: onTap,
      child: Row(
        children: [
          _HallIcon(type: hall.type),
          SizedBox(width: CaseLibrarySpacing.spaceL.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hall.name,
                    style: CaseLibraryTextStyles.pageTitle(context)
                        .copyWith(fontSize: 22.sp)),
                SizedBox(height: CaseLibrarySpacing.spaceS.h),
                Text(hall.description,
                    style: CaseLibraryTextStyles.bodySmall(context)),
              ],
            ),
          ),
          Icon(CupertinoIcons.chevron_right,
              color: CaseLibraryColors.libraryMutedGold, size: 18.sp),
        ],
      ),
    );
  }
}

class _HallIcon extends StatelessWidget {
  const _HallIcon({required this.type});

  final CaseLibraryHallType type;

  @override
  Widget build(BuildContext context) {
    final asset = switch (type) {
      CaseLibraryHallType.timeline => caseLibraryV2EraEmblemAsset,
      CaseLibraryHallType.theme => caseLibraryV2ThemeEmblemAsset,
      CaseLibraryHallType.classic => caseLibraryV2ClassicEmblemAsset,
      CaseLibraryHallType.status => caseLibraryV2ClassicEmblemAsset,
    };
    return Container(
      width: 78.w,
      height: 86.h,
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(CaseLibraryRadii.radiusMedium.r),
        color: CaseLibraryColors.libraryMidnight.withValues(alpha: .78),
        border: Border.all(color: CaseLibraryColors.libraryBorderMist),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Image.asset(asset, fit: BoxFit.cover),
      ),
    );
  }
}
