import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/features/case_time_machine/models/case_time_machine_models.dart';
import 'package:lawapp/features/case_time_machine/theme/case_time_machine_theme.dart';
import 'package:lawapp/features/case_time_machine/widgets/case_book_spine_card.dart';

class ImmersiveBookshelf extends StatelessWidget {
  const ImmersiveBookshelf({
    super.key,
    required this.books,
    required this.onBookTap,
    this.compact = false,
  });

  final List<CaseBook> books;
  final ValueChanged<CaseBook> onBookTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final booksPerShelf = compact ? 4 : 7;
    final shelves = <List<CaseBook>>[
      for (var index = 0; index < books.length; index += booksPerShelf)
        books.skip(index).take(booksPerShelf).toList(),
    ];

    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 14.h, 12.w, 16.h),
      decoration: BoxDecoration(
        color: CaseTimeMachineColors.libraryMidnight.withValues(alpha: .94),
        borderRadius: BorderRadius.circular(CaseTimeMachineRadii.radiusXL.r),
        border: Border.all(color: CaseTimeMachineColors.libraryBorderGold),
        boxShadow: [CaseTimeMachineShadows.goldGlow],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(CupertinoIcons.book,
                  color: CaseTimeMachineColors.libraryMutedGold, size: 15.sp),
              SizedBox(width: 7.w),
              Expanded(
                child: Text('案件書架',
                    style: CaseTimeMachineTextStyles.caption(context).copyWith(
                        color: CaseTimeMachineColors.libraryMutedGold)),
              ),
              Text('抽出一本案件之書',
                  style: CaseTimeMachineTextStyles.caption(context)),
            ],
          ),
          SizedBox(height: CaseTimeMachineSpacing.spaceM.h),
          // 年代館的 Prototype 是「上方一層主書架、下方案件資訊」；
          // 所以書脊集中成單層 shelf，文字保持水平，完整名稱交給下方卡片。
          for (final shelfBooks in shelves) ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final book in shelfBooks) ...[
                    CaseBookSpineCard(
                      book: book,
                      compact: compact,
                      onTap: () => onBookTap(book),
                    ),
                    SizedBox(width: compact ? 8.w : 7.w),
                  ],
                ],
              ),
            ),
            _ShelfRail(compact: compact),
          ],
        ],
      ),
    );
  }
}

class _ShelfRail extends StatelessWidget {
  const _ShelfRail({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: compact ? 9.h : 12.h,
      margin: EdgeInsets.only(
        top: CaseTimeMachineSpacing.spaceS.h,
        bottom: CaseTimeMachineSpacing.spaceM.h,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: LinearGradient(
          colors: [
            CaseTimeMachineColors.libraryMutedGold.withValues(alpha: .2),
            CaseTimeMachineColors.libraryMutedGold.withValues(alpha: .82),
            CaseTimeMachineColors.libraryMutedGold.withValues(alpha: .2),
          ],
        ),
      ),
    );
  }
}
