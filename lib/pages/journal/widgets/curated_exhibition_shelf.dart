import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:preamble/features/case_library/data/case_library_repository.dart';
import 'package:preamble/features/case_library/models/case_library_models.dart';
import 'package:preamble/features/case_library/pages/case_dossier_detail_page.dart';
import 'package:preamble/pages/journal/data/journal_page_items.dart';
import 'package:preamble/pages/journal/widgets/journal_palette.dart';
import 'package:preamble/pages/journal/widgets/journal_section_header.dart';
import 'package:preamble/theme/preamble_tokens.dart';

/// 主題策展特展區（現代美術館數位策展卡，移除舊版擬物木架與首案寫死跳轉錯誤）。
class CuratedExhibitionShelf extends StatefulWidget {
  const CuratedExhibitionShelf({super.key, required this.palette});

  final JournalPalette palette;

  @override
  State<CuratedExhibitionShelf> createState() => _CuratedExhibitionShelfState();
}

class _CuratedExhibitionShelfState extends State<CuratedExhibitionShelf> {
  @override
  void initState() {
    super.initState();
    _ensureRepoInitialized();
  }

  Future<void> _ensureRepoInitialized() async {
    final repo = CaseLibraryRepository.instance;
    if (repo.cases.isEmpty) {
      await repo.initialize();
    }
    // 台灣繁體中文教學註解：預先向雲端載入特展收錄的真實案件標題與年份，避免卡片與抽屜顯示「0 · 案件載入中...」。
    final allIds = curatedExhibitionItems
        .expand((item) => item.caseIds)
        .toSet()
        .toList(growable: false);
    await Future.wait(allIds.map((id) async {
      try {
        await repo.getCaseDetail(id);
      } catch (_) {}
    }));
    if (mounted) setState(() {});
  }

  Future<void> _openExhibitionCollectionSheet(
    BuildContext context,
    CuratedExhibition item,
    int exhibitionIndex,
  ) async {
    final repo = CaseLibraryRepository.instance;
    if (repo.cases.isEmpty) {
      await repo.initialize();
    }
    final books = await Future.wait(item.caseIds.map((id) async {
      try {
        return await repo.getCaseDetail(id);
      } catch (_) {
        return repo.getCaseById(id);
      }
    }));
    if (!context.mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _ExhibitionCollectionSheet(
          exhibition: item,
          exhibitionNumber: exhibitionIndex + 1,
          books: books,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        JournalSectionHeader(
          title: '主題策展特展',
          subtitle: '依憲政議題串聯多份指標卷宗，點擊展開該特展完整收錄清單。',
          palette: widget.palette,
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: MediaQuery.textScalerOf(context).scale(212.h),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: curatedExhibitionItems.length,
            separatorBuilder: (_, __) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              final item = curatedExhibitionItems[index];
              return _ExhibitionMuseumCard(
                item: item,
                exhibitionNumber: index + 1,
                onTap: () => _openExhibitionCollectionSheet(
                  context,
                  item,
                  index,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ExhibitionMuseumCard extends StatelessWidget {
  const _ExhibitionMuseumCard({
    required this.item,
    required this.exhibitionNumber,
    required this.onTap,
  });

  final CuratedExhibition item;
  final int exhibitionNumber;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final repo = CaseLibraryRepository.instance;
    final previewTitles = item.caseIds.map((id) {
      final book = repo.getCaseById(id);
      return book.shortTitleZh.isNotEmpty ? book.shortTitleZh : book.titleZh;
    }).toList(growable: false);

    return SizedBox(
      width: 248.w,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20.r),
          child: Ink(
            padding: EdgeInsets.all(15.w),
            decoration: t.cardDecoration(radius: 20.r, elevated: false),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: t.accentBrassContainer,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        'EXHIBITION 0$exhibitionNumber',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.tabularMetric(
                          size: 10.sp,
                          weight: FontWeight.w700,
                          color: t.accentOnBrassContainer,
                        ),
                      ),
                    ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      '收錄 ${item.caseIds.length} 案',
                      style: t.tabularMetric(
                        size: 11.sp,
                        weight: FontWeight.w700,
                        color: t.brandPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.serifTitle(
                    size: 16.sp,
                    weight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  item.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: t.sansBody(
                    size: 11.5.sp,
                    color: t.textSecondary,
                    height: 1.42,
                  ),
                ),
                const Spacer(),
                Wrap(
                  spacing: 6.w,
                  runSpacing: 4.h,
                  children: previewTitles.take(2).map((label) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 7.w,
                        vertical: 2.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: t.surfaceSubtle,
                        borderRadius: BorderRadius.circular(6.r),
                        border: Border.all(color: t.border),
                      ),
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.sansBody(
                          size: 10.sp,
                          weight: FontWeight.w600,
                          color: t.textSecondary,
                          height: 1.2,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                      '閱讀進度 ${item.readProgress}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.tabularMetric(
                        size: 10.5.sp,
                        weight: FontWeight.w600,
                        color: t.textMuted,
                      ),
                    ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      '展開策展目錄',
                      style: t.sansBody(
                        size: 11.5.sp,
                        weight: FontWeight.w700,
                        color: t.brandPrimary,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Icon(
                      PhosphorIconsRegular.arrowRight,
                      size: 13.sp,
                      color: t.brandPrimary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExhibitionCollectionSheet extends StatelessWidget {
  const _ExhibitionCollectionSheet({
    required this.exhibition,
    required this.exhibitionNumber,
    required this.books,
  });

  final CuratedExhibition exhibition;
  final int exhibitionNumber;
  final List<CaseBook> books;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return FractionallySizedBox(
      heightFactor: 0.78,
      child: Container(
        decoration: BoxDecoration(
          color: t.surfaceElevated,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26.r)),
          border: Border.all(color: t.borderStrong, width: 1),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38.w,
                  height: 4.h,
                  margin: EdgeInsets.only(top: 12.h, bottom: 14.h),
                  decoration: BoxDecoration(
                    color: t.borderStrong,
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: t.accentBrassContainer,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            'CURATED EXHIBITION 0$exhibitionNumber · 共 ${books.length} 案',
                            style: t.tabularMetric(
                              size: 10.5.sp,
                              weight: FontWeight.w700,
                              color: t.accentOnBrassContainer,
                            ),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(
                            PhosphorIconsRegular.x,
                            size: 18.sp,
                            color: t.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      exhibition.title,
                      style: t.serifTitle(
                        size: 21.sp,
                        weight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      exhibition.description,
                      style: t.sansBody(
                        size: 12.5.sp,
                        color: t.textSecondary,
                        height: 1.48,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14.h),
              Divider(color: t.border, height: 1),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
                  physics: const BouncingScrollPhysics(),
                  itemCount: books.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final book = books[index];
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18.r),
                        onTap: () {
                          final navigator = Navigator.of(context);
                          navigator.pop();
                          navigator.push(
                            CupertinoPageRoute<void>(
                              builder: (_) => CaseDossierDetailPage(book: book),
                            ),
                          );
                        },
                        child: Ink(
                          padding: EdgeInsets.all(15.w),
                          decoration:
                              t.cardDecoration(radius: 18.r, elevated: false),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 32.w,
                                height: 32.w,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: t.brandContainer,
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Text(
                                  '0${index + 1}',
                                  style: t.tabularMetric(
                                    size: 12.sp,
                                    weight: FontWeight.w700,
                                    color: t.brandOnContainer,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Wrap(
                                      spacing: 6.w,
                                      runSpacing: 4.h,
                                      children: [
                                        Text(
                                          '${book.year} · ${book.category}',
                                          style: t.tabularMetric(
                                            size: 11.sp,
                                            weight: FontWeight.w700,
                                            color: t.accentBrass,
                                          ),
                                        ),
                                        if (book.displayCode.isNotEmpty)
                                          Text(
                                            '· ${book.displayCode}',
                                            style: t.tabularMetric(
                                              size: 11.sp,
                                              weight: FontWeight.w600,
                                              color: t.textMuted,
                                            ),
                                          ),
                                      ],
                                    ),
                                    SizedBox(height: 5.h),
                                    Text(
                                      book.titleZh,
                                      style: t.serifTitle(
                                        size: 15.5.sp,
                                        weight: FontWeight.w800,
                                      ),
                                    ),
                                    SizedBox(height: 5.h),
                                    Text(
                                      book.oneSentenceSummary.isNotEmpty
                                          ? book.oneSentenceSummary
                                          : book.shortDescription,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: t.sansBody(
                                        size: 12.sp,
                                        color: t.textSecondary,
                                        height: 1.45,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Padding(
                                padding: EdgeInsets.only(top: 6.h),
                                child: Icon(
                                  PhosphorIconsRegular.caretRight,
                                  size: 16.sp,
                                  color: t.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
