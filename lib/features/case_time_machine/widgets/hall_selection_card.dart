import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/features/case_time_machine/data/case_time_machine_mock_data.dart';
import 'package:preamble/features/case_time_machine/models/case_time_machine_models.dart';
import 'package:preamble/features/case_time_machine/theme/case_time_machine_theme.dart';
import 'package:preamble/features/case_time_machine/widgets/_ctm_surface.dart';

class HallSelectionCard extends StatelessWidget {
  const HallSelectionCard({super.key, required this.hall, required this.onTap});

  final CaseLibraryHall hall;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CtmSurface(
      onTap: onTap,
      child: Row(
        children: [
          _HallIcon(type: hall.type),
          SizedBox(width: CaseTimeMachineSpacing.spaceL.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hall.name,
                    style: CaseTimeMachineTextStyles.pageTitle(context)
                        .copyWith(fontSize: 22.sp)),
                SizedBox(height: CaseTimeMachineSpacing.spaceS.h),
                Text(hall.description,
                    style: CaseTimeMachineTextStyles.bodySmall(context)),
              ],
            ),
          ),
          Icon(CupertinoIcons.chevron_right,
              color: CaseTimeMachineColors.libraryMutedGold, size: 18.sp),
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
      CaseLibraryHallType.timeline => caseTimeMachineV2EraEmblemAsset,
      CaseLibraryHallType.theme => caseTimeMachineV2ThemeEmblemAsset,
      CaseLibraryHallType.classic => caseTimeMachineV2ClassicEmblemAsset,
      CaseLibraryHallType.status => caseTimeMachineV2ClassicEmblemAsset,
    };
    return Container(
      width: 78.w,
      height: 86.h,
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(CaseTimeMachineRadii.radiusMedium.r),
        color: CaseTimeMachineColors.libraryMidnight.withValues(alpha: .78),
        border: Border.all(color: CaseTimeMachineColors.libraryBorderMist),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Image.asset(asset, fit: BoxFit.cover),
      ),
    );
  }
}
