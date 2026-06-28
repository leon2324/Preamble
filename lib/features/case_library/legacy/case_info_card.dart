import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/features/case_library/models/case_library_models.dart';
import 'package:preamble/features/case_library/theme/case_library_theme.dart';
import 'package:preamble/features/case_library/widgets/_case_library_surface.dart';
import 'package:preamble/features/case_library/widgets/issue_chip_wrap.dart';

class CaseInfoCard extends StatelessWidget {
  const CaseInfoCard({super.key, required this.book, required this.onTap});

  final CaseBook book;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CaseLibrarySurface(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${book.year}｜${book.category}｜${book.status}',
                    style: CaseLibraryTextStyles.caption(context)
                        .copyWith(color: CaseLibraryColors.libraryMutedGold)),
                SizedBox(height: CaseLibrarySpacing.spaceXS.h),
                Text(book.titleZh,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: CaseLibraryTextStyles.cardTitle(context)),
                Text(book.titleEn,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CaseLibraryTextStyles.caption(context)),
                SizedBox(height: CaseLibrarySpacing.spaceS.h),
                Text(book.shortDescription,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: CaseLibraryTextStyles.bodySmall(context)),
                SizedBox(height: CaseLibrarySpacing.spaceS.h),
                IssueChipWrap(labels: book.tags.take(3).toList()),
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
