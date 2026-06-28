import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/features/case_library/models/case_library_models.dart';
import 'package:preamble/features/case_library/theme/case_library_theme.dart';
import 'package:preamble/features/case_library/widgets/_case_library_surface.dart';

class ShelfCard extends StatelessWidget {
  const ShelfCard({super.key, required this.shelf, required this.onTap});

  final CaseShelf shelf;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CaseLibrarySurface(
      onTap: onTap,
      child: Row(
        children: [
          _MiniBooks(count: shelf.caseIds.length),
          SizedBox(width: CaseLibrarySpacing.spaceM.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(shelf.name,
                    style: CaseLibraryTextStyles.cardTitle(context)),
                SizedBox(height: CaseLibrarySpacing.spaceXS.h),
                Text('${shelf.caseIds.length} 本案件之書',
                    style: CaseLibraryTextStyles.caption(context)),
                SizedBox(height: CaseLibrarySpacing.spaceXS.h),
                Text(shelf.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: CaseLibraryTextStyles.bodySmall(context)),
              ],
            ),
          ),
          Icon(CupertinoIcons.chevron_right,
              color: CaseLibraryColors.libraryMutedGold, size: 16.sp),
        ],
      ),
    );
  }
}

class _MiniBooks extends StatelessWidget {
  const _MiniBooks({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72.w,
      height: 58.h,
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(CaseLibraryRadii.radiusMedium.r),
        border: Border.all(color: CaseLibraryColors.libraryBorderGold),
        color: CaseLibraryColors.libraryMidnight.withValues(alpha: .78),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var index = 0; index < count.clamp(3, 5); index++) ...[
            Container(
              width: 8.w,
              height: (34 - index % 2 * 5).h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3.r),
                color: index.isEven
                    ? CaseLibraryColors.libraryDeepTeal
                    : CaseLibraryColors.libraryDeepGreen,
                border: Border.all(
                    color: CaseLibraryColors.libraryMutedGold
                        .withValues(alpha: .48)),
              ),
            ),
            SizedBox(width: 3.w),
          ],
        ],
      ),
    );
  }
}
