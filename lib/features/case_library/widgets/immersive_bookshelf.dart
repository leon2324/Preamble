import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/features/case_library/models/case_library_models.dart';
import 'package:preamble/features/case_library/theme/case_library_theme.dart';
import 'package:preamble/features/case_library/widgets/case_book_spine_card.dart';

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
        color: CaseLibraryColors.libraryMidnight.withValues(alpha: .94),
        borderRadius: BorderRadius.circular(CaseLibraryRadii.radiusXL.r),
        border: Border.all(color: CaseLibraryColors.libraryBorderGold),
        boxShadow: [CaseLibraryShadows.goldGlow],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(CupertinoIcons.book,
                  color: CaseLibraryColors.libraryMutedGold, size: 15.sp),
              SizedBox(width: 7.w),
              Expanded(
                child: Text('案件書架',
                    style: CaseLibraryTextStyles.caption(context)
                        .copyWith(color: CaseLibraryColors.libraryMutedGold)),
              ),
              Text('抽出一本案件之書', style: CaseLibraryTextStyles.caption(context)),
            ],
          ),
          SizedBox(height: CaseLibrarySpacing.spaceM.h),
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
        top: CaseLibrarySpacing.spaceS.h,
        bottom: CaseLibrarySpacing.spaceM.h,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: LinearGradient(
          colors: [
            CaseLibraryColors.libraryMutedGold.withValues(alpha: .2),
            CaseLibraryColors.libraryMutedGold.withValues(alpha: .82),
            CaseLibraryColors.libraryMutedGold.withValues(alpha: .2),
          ],
        ),
      ),
    );
  }
}
