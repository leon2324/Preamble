import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/features/case_time_machine/models/case_time_machine_models.dart';
import 'package:lawapp/features/case_time_machine/theme/case_time_machine_theme.dart';
import 'package:lawapp/features/case_time_machine/widgets/_ctm_surface.dart';
import 'package:lawapp/features/case_time_machine/widgets/issue_chip_wrap.dart';

class CaseInfoCard extends StatelessWidget {
  const CaseInfoCard({super.key, required this.book, required this.onTap});

  final CaseBook book;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CtmSurface(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${book.year}｜${book.category}｜${book.status}',
                    style: CaseTimeMachineTextStyles.caption(context).copyWith(
                        color: CaseTimeMachineColors.libraryMutedGold)),
                SizedBox(height: CaseTimeMachineSpacing.spaceXS.h),
                Text(book.titleZh,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: CaseTimeMachineTextStyles.cardTitle(context)),
                Text(book.titleEn,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CaseTimeMachineTextStyles.caption(context)),
                SizedBox(height: CaseTimeMachineSpacing.spaceS.h),
                Text(book.shortDescription,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: CaseTimeMachineTextStyles.bodySmall(context)),
                SizedBox(height: CaseTimeMachineSpacing.spaceS.h),
                IssueChipWrap(labels: book.tags.take(3).toList()),
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
