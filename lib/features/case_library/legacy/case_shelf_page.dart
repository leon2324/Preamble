import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/features/case_library/data/case_library_data.dart';
import 'package:preamble/features/case_library/models/case_library_models.dart';
import 'package:preamble/features/case_library/pages/case_book_preview_page.dart';
import 'package:preamble/features/case_library/theme/case_library_theme.dart';
import 'package:preamble/features/case_library/legacy/case_info_card.dart';
import 'package:preamble/features/case_library/legacy/case_shelf_header.dart';
import 'package:preamble/features/case_library/widgets/case_library_scaffold.dart';
import 'package:preamble/features/case_library/legacy/immersive_bookshelf.dart';

class CaseShelfPage extends StatelessWidget {
  const CaseShelfPage({super.key, required this.hall, required this.shelf});

  final CaseLibraryHall hall;
  final CaseShelf shelf;

  void _openPreview(BuildContext context, CaseBook book) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (__) => CaseBookPreviewPage(book: book),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final books = caseLibraryCasesForShelf(shelf);

    return CaseLibraryScaffold(
      scene: CaseLibraryScene.shelf,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isLandscapeLibrary = constraints.maxWidth >= 680;
          final contentPadding = EdgeInsets.fromLTRB(20.w, 70.h, 20.w, 32.h);

          if (isLandscapeLibrary) {
            // 橫向模式不把直式 UI 硬拉寬，而是改成 Prototype 指定的
            // 左側「案件書架牆」＋右側「完整案件資訊卡」雙欄閱讀。
            return ListView(
              padding: contentPadding,
              children: [
                CaseShelfHeader(shelf: shelf, hall: hall),
                SizedBox(height: CaseLibrarySpacing.spaceXL.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: ImmersiveBookshelf(
                        books: books,
                        compact: true,
                        onBookTap: (book) => _openPreview(context, book),
                      ),
                    ),
                    SizedBox(width: CaseLibrarySpacing.spaceL.w),
                    Expanded(
                      flex: 6,
                      child: _CaseInfoColumn(
                        books: books,
                        onBookTap: (book) => _openPreview(context, book),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }

          return ListView(
            padding: contentPadding,
            children: [
              CaseShelfHeader(shelf: shelf, hall: hall),
              SizedBox(height: CaseLibrarySpacing.spaceXL.h),
              ImmersiveBookshelf(
                books: books,
                onBookTap: (book) => _openPreview(context, book),
              ),
              SizedBox(height: CaseLibrarySpacing.spaceXL.h),
              _CaseInfoColumn(
                books: books,
                onBookTap: (book) => _openPreview(context, book),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CaseInfoColumn extends StatelessWidget {
  const _CaseInfoColumn({required this.books, required this.onBookTap});

  final List<CaseBook> books;
  final ValueChanged<CaseBook> onBookTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('案件資訊卡', style: CaseLibraryTextStyles.sectionTitle(context)),
        SizedBox(height: CaseLibrarySpacing.spaceM.h),
        // 書脊負責營造「抽書」氛圍，完整中文／英文案名則放在資訊卡；
        // 這樣可同時保留沉浸感，也能支援未來較長的雙語案件名稱。
        for (final book in books) ...[
          CaseInfoCard(book: book, onTap: () => onBookTap(book)),
          SizedBox(height: CaseLibrarySpacing.spaceM.h),
        ],
      ],
    );
  }
}
