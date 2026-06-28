import 'package:flutter/cupertino.dart';
import 'package:preamble/components/shared/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/features/case_library/data/case_library_data.dart';
import 'package:preamble/features/case_library/models/case_library_models.dart';
import 'package:preamble/features/case_library/pages/case_dossier_detail_page.dart';
import 'package:preamble/features/case_library/theme/case_library_theme.dart';
import 'package:preamble/features/case_library/widgets/_case_library_surface.dart';
import 'package:preamble/features/case_library/widgets/case_book_cover.dart';
import 'package:preamble/features/case_library/widgets/case_memory_line.dart';
import 'package:preamble/features/case_library/widgets/case_library_scaffold.dart';
import 'package:preamble/features/case_library/widgets/issue_chip_wrap.dart';
import 'package:preamble/features/case_library/widgets/login_prompt_bottom_sheet.dart';

class CaseBookPreviewPage extends StatelessWidget {
  const CaseBookPreviewPage({super.key, required this.book});

  final CaseBook book;

  void _openDossier(BuildContext context) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (__) => CaseDossierDetailPage(book: book),
      ),
    );
  }

  void _saveCase(BuildContext context) {
    if (!caseLibraryMockIsLoggedIn) {
      showLoginPromptBottomSheet(context);
      return;
    }
    CustomToast.show(context, '已收藏案件之書');
  }

  @override
  Widget build(BuildContext context) {
    return CaseLibraryScaffold(
      scene: CaseLibraryScene.shelf,
      child: ListView(
        padding: EdgeInsets.fromLTRB(20.w, 66.h, 20.w, 32.h),
        children: [
          Text('返回書架',
              style: CaseLibraryTextStyles.caption(context)
                  .copyWith(color: CaseLibraryColors.libraryMutedGold)),
          SizedBox(height: CaseLibrarySpacing.spaceM.h),
          Center(
            child: SizedBox(
              width: 236.w,
              height: 326.h,
              child: CaseBookCover(book: book),
            ),
          ),
          SizedBox(height: CaseLibrarySpacing.spaceXL.h),
          Text('你即將翻開一本案件之書',
              textAlign: TextAlign.center,
              style: CaseLibraryTextStyles.caption(context)
                  .copyWith(color: CaseLibraryColors.libraryMutedGold)),
          SizedBox(height: CaseLibrarySpacing.spaceS.h),
          Text(book.titleZh,
              textAlign: TextAlign.center,
              style: CaseLibraryTextStyles.pageTitle(context)),
          Text(book.titleEn,
              textAlign: TextAlign.center,
              style: CaseLibraryTextStyles.caption(context)),
          SizedBox(height: CaseLibrarySpacing.spaceM.h),
          Text(
            '${book.year}｜${book.location}｜${book.status}',
            textAlign: TextAlign.center,
            style: CaseLibraryTextStyles.chipText(context)
                .copyWith(color: CaseLibraryColors.libraryMutedGold),
          ),
          SizedBox(height: CaseLibrarySpacing.spaceM.h),
          Center(
              child:
                  IssueChipWrap(labels: [book.category, ...book.tags.take(3)])),
          SizedBox(height: CaseLibrarySpacing.spaceXL.h),
          CaseMemoryLine(text: book.memoryLine),
          SizedBox(height: CaseLibrarySpacing.spaceL.h),
          CaseLibrarySurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('案件摘要',
                    style: CaseLibraryTextStyles.sectionTitle(context)),
                SizedBox(height: CaseLibrarySpacing.spaceM.h),
                Text(book.shortDescription,
                    style: CaseLibraryTextStyles.body(context)),
                SizedBox(height: CaseLibrarySpacing.spaceL.h),
                Text('卷宗包含資訊', style: CaseLibraryTextStyles.cardTitle(context)),
                SizedBox(height: CaseLibrarySpacing.spaceM.h),
                _DossierStats(book: book),
              ],
            ),
          ),
          SizedBox(height: CaseLibrarySpacing.spaceXL.h),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: Size.fromHeight(52.h),
              backgroundColor: CaseLibraryColors.libraryDeepTeal,
              side:
                  const BorderSide(color: CaseLibraryColors.libraryBorderGold),
            ),
            onPressed: () => _openDossier(context),
            child:
                Text('翻開卷宗', style: CaseLibraryTextStyles.buttonText(context)),
          ),
          SizedBox(height: CaseLibrarySpacing.spaceM.h),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: Size.fromHeight(48.h),
              side:
                  const BorderSide(color: CaseLibraryColors.libraryBorderMist),
              foregroundColor: CaseLibraryColors.libraryFogWhite,
            ),
            onPressed: () => _saveCase(context),
            child:
                Text('收藏案件', style: CaseLibraryTextStyles.buttonText(context)),
          ),
        ],
      ),
    );
  }
}

class _DossierStats extends StatelessWidget {
  const _DossierStats({required this.book});

  final CaseBook book;

  @override
  Widget build(BuildContext context) {
    final stats = [
      ('時間節點', '${book.timeline.length} 個'),
      ('法律爭點', '${book.legalIssues.length} 個'),
      ('相關法條', '${book.relatedLaws.length} 則'),
      ('相關案件', '${book.relatedCases.length} 件'),
    ];

    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        for (final stat in stats)
          Container(
            width: 132.w,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: CaseLibraryColors.libraryDeepGreen.withValues(alpha: .78),
              borderRadius:
                  BorderRadius.circular(CaseLibraryRadii.radiusMedium.r),
              border: Border.all(color: CaseLibraryColors.libraryBorderMist),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stat.$1, style: CaseLibraryTextStyles.caption(context)),
                SizedBox(height: 3.h),
                Text(stat.$2, style: CaseLibraryTextStyles.cardTitle(context)),
              ],
            ),
          ),
      ],
    );
  }
}
