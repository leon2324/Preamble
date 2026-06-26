import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/features/case_time_machine/data/case_time_machine_mock_data.dart';
import 'package:lawapp/features/case_time_machine/models/case_time_machine_models.dart';
import 'package:lawapp/features/case_time_machine/pages/case_book_preview_page.dart';
import 'package:lawapp/features/case_time_machine/theme/case_time_machine_theme.dart';
import 'package:lawapp/features/case_time_machine/legacy/case_info_card.dart';
import 'package:lawapp/features/case_time_machine/legacy/case_shelf_header.dart';
import 'package:lawapp/features/case_time_machine/widgets/case_time_machine_scaffold.dart';
import 'package:lawapp/features/case_time_machine/legacy/immersive_bookshelf.dart';

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
    final books = caseTimeMachineCasesForShelf(shelf);

    return CaseTimeMachineScaffold(
      scene: CaseTimeMachineScene.shelf,
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
                SizedBox(height: CaseTimeMachineSpacing.spaceXL.h),
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
                    SizedBox(width: CaseTimeMachineSpacing.spaceL.w),
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
              SizedBox(height: CaseTimeMachineSpacing.spaceXL.h),
              ImmersiveBookshelf(
                books: books,
                onBookTap: (book) => _openPreview(context, book),
              ),
              SizedBox(height: CaseTimeMachineSpacing.spaceXL.h),
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
        Text('案件資訊卡', style: CaseTimeMachineTextStyles.sectionTitle(context)),
        SizedBox(height: CaseTimeMachineSpacing.spaceM.h),
        // 書脊負責營造「抽書」氛圍，完整中文／英文案名則放在資訊卡；
        // 這樣可同時保留沉浸感，也能支援未來較長的雙語案件名稱。
        for (final book in books) ...[
          CaseInfoCard(book: book, onTap: () => onBookTap(book)),
          SizedBox(height: CaseTimeMachineSpacing.spaceM.h),
        ],
      ],
    );
  }
}
