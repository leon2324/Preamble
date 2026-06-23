import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/pages/journal/data/journal_page_items.dart';
import 'package:lawapp/pages/journal/widgets/journal_palette.dart';
import 'package:lawapp/pages/journal/widgets/journal_section_header.dart';
import 'package:lawapp/features/case_time_machine/data/case_time_machine_repository.dart';
import 'package:lawapp/features/case_time_machine/pages/case_dossier_detail_page.dart';

class CuratedExhibitionShelf extends StatelessWidget {
  const CuratedExhibitionShelf({super.key, required this.palette});

  final JournalPalette palette;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        JournalSectionHeader(
          title: '主題策展特展架',
          subtitle: '精選法律歷史與社會重大議題的系列卷宗特展。',
          palette: palette,
        ),
        SizedBox(height: 14.h),
        Stack(
          children: [
            // Shelf Background board (behind/bottom)
            Positioned(
              left: 4.w,
              right: 4.w,
              bottom: 8.h,
              child: Container(
                height: 12.h,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF8E6F54), // Morandi wood / Warm clay
                      Color(0xFF6E4E42),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: Offset(0, 3.h),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
            // Scrollable exhibition cards list
            Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: SizedBox(
                height: 195.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  itemCount: curatedExhibitionItems.length,
                  itemBuilder: (context, index) {
                    final item = curatedExhibitionItems[index];
                    return _ExhibitionFolderCard(item: item);
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ExhibitionFolderCard extends StatelessWidget {
  const _ExhibitionFolderCard({required this.item});

  final CuratedExhibition item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 175.w,
      margin: EdgeInsets.symmetric(horizontal: 6.w),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (item.caseIds.isEmpty) return;
            final firstCaseId = item.caseIds.first;
            final book =
                CaseTimeMachineRepository.instance.getCaseById(firstCaseId);
            Navigator.of(context).push(
              CupertinoPageRoute<void>(
                builder: (_) => CaseDossierDetailPage(
                  book: book,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Folder top tab
              Container(
                width: 65.w,
                height: 16.h,
                decoration: BoxDecoration(
                  color: item.themeColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8.r),
                    topRight: Radius.circular(8.r),
                  ),
                ),
                child: Center(
                  child: Text(
                    'EXHIBITION',
                    style: TextStyle(
                      fontSize: 8.sp,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
              // Folder main body
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: item.themeColor,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(16.r),
                      bottomLeft: Radius.circular(16.r),
                      bottomRight: Radius.circular(16.r),
                      topLeft: Radius.circular(0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: item.themeColor.withOpacity(0.25),
                        offset: const Offset(0, 4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(12.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Progress tag
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 7.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.16),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              '已讀 ${item.readProgress}',
                              style: TextStyle(
                                fontSize: 9.sp,
                                color: Colors.white.withOpacity(0.95),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Icon(
                            CupertinoIcons.folder_open,
                            size: 13.sp,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      // Exhibition Title
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      // Exhibition Description
                      Text(
                        item.description,
                        style: TextStyle(
                          fontSize: 10.sp,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.75),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      // Stacked Book Covers & Read Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(bottom: 4.h),
                            child: Row(
                              children: [
                                Text(
                                  '進入特展',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 2.w),
                                Icon(
                                  CupertinoIcons.chevron_right_circle_fill,
                                  size: 11.sp,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ],
                            ),
                          ),
                          _BookStack(caseIds: item.caseIds),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookStack extends StatelessWidget {
  const _BookStack({required this.caseIds});

  final List<String> caseIds;

  @override
  Widget build(BuildContext context) {
    final bookCount = caseIds.length;
    if (bookCount == 0) return const SizedBox.shrink();

    return SizedBox(
      width: 65.w,
      height: 46.h,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomRight,
        children: [
          if (bookCount > 2)
            Positioned(
              right: 24.w,
              bottom: 3.h,
              child: Transform.rotate(
                angle: -0.15,
                child: _MiniBook(
                  bookId: caseIds[2],
                  baseColor: Colors.white.withOpacity(0.4),
                ),
              ),
            ),
          if (bookCount > 1)
            Positioned(
              right: 12.w,
              bottom: 1.5.h,
              child: Transform.rotate(
                angle: -0.07,
                child: _MiniBook(
                  bookId: caseIds[1],
                  baseColor: Colors.white.withOpacity(0.7),
                ),
              ),
            ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Transform.rotate(
              angle: 0.05,
              child: _MiniBook(
                bookId: caseIds[0],
                baseColor: Colors.white,
                isFront: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniBook extends StatelessWidget {
  const _MiniBook({
    required this.bookId,
    required this.baseColor,
    this.isFront = false,
  });

  final String bookId;
  final Color baseColor;
  final bool isFront;

  @override
  Widget build(BuildContext context) {
    String displayLabel = '';
    final book = CaseTimeMachineRepository.instance.getCaseById(bookId);

    if (book.displayCode.isNotEmpty) {
      displayLabel =
          book.displayCode.replaceAll('CTM-', '').replaceAll('JY-', '');
    } else if (book.shortTitleZh.isNotEmpty) {
      displayLabel = book.shortTitleZh;
    } else {
      displayLabel = book.titleZh
          .substring(0, book.titleZh.length > 3 ? 3 : book.titleZh.length);
    }

    return Container(
      width: 28.w,
      height: 40.h,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(3.r),
          bottomRight: Radius.circular(3.r),
          topLeft: Radius.circular(1.r),
          bottomLeft: Radius.circular(1.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 2,
            offset: const Offset(1, 1),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Spine Line
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 2.w,
            child: Container(
              color: Colors.black.withOpacity(0.12),
            ),
          ),
          // Title on the front cover
          if (isFront && displayLabel.isNotEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.only(left: 3.w, right: 1.w),
                child: Text(
                  displayLabel,
                  style: TextStyle(
                    fontSize: 7.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF2C3E3B),
                    height: 1.1,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
