import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/features/case_time_machine/data/case_time_machine_mock_data.dart';
import 'package:preamble/features/case_time_machine/models/case_time_machine_models.dart';
import 'package:preamble/features/case_time_machine/pages/case_dossier_detail_page.dart';
import 'package:preamble/features/case_time_machine/theme/case_time_machine_theme.dart';
import 'package:preamble/features/case_time_machine/widgets/_ctm_surface.dart';
import 'package:preamble/features/case_time_machine/widgets/case_book_cover.dart';
import 'package:preamble/features/case_time_machine/widgets/case_memory_line.dart';
import 'package:preamble/features/case_time_machine/widgets/case_time_machine_scaffold.dart';
import 'package:preamble/features/case_time_machine/widgets/issue_chip_wrap.dart';
import 'package:preamble/features/case_time_machine/widgets/login_prompt_bottom_sheet.dart';

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
    if (!caseTimeMachineMockIsLoggedIn) {
      showLoginPromptBottomSheet(context);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已收藏案件之書')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CaseTimeMachineScaffold(
      scene: CaseTimeMachineScene.shelf,
      child: ListView(
        padding: EdgeInsets.fromLTRB(20.w, 66.h, 20.w, 32.h),
        children: [
          Text('返回書架',
              style: CaseTimeMachineTextStyles.caption(context)
                  .copyWith(color: CaseTimeMachineColors.libraryMutedGold)),
          SizedBox(height: CaseTimeMachineSpacing.spaceM.h),
          Center(
            child: SizedBox(
              width: 236.w,
              height: 326.h,
              child: CaseBookCover(book: book),
            ),
          ),
          SizedBox(height: CaseTimeMachineSpacing.spaceXL.h),
          Text('你即將翻開一本案件之書',
              textAlign: TextAlign.center,
              style: CaseTimeMachineTextStyles.caption(context)
                  .copyWith(color: CaseTimeMachineColors.libraryMutedGold)),
          SizedBox(height: CaseTimeMachineSpacing.spaceS.h),
          Text(book.titleZh,
              textAlign: TextAlign.center,
              style: CaseTimeMachineTextStyles.pageTitle(context)),
          Text(book.titleEn,
              textAlign: TextAlign.center,
              style: CaseTimeMachineTextStyles.caption(context)),
          SizedBox(height: CaseTimeMachineSpacing.spaceM.h),
          Text(
            '${book.year}｜${book.location}｜${book.status}',
            textAlign: TextAlign.center,
            style: CaseTimeMachineTextStyles.chipText(context)
                .copyWith(color: CaseTimeMachineColors.libraryMutedGold),
          ),
          SizedBox(height: CaseTimeMachineSpacing.spaceM.h),
          Center(
              child:
                  IssueChipWrap(labels: [book.category, ...book.tags.take(3)])),
          SizedBox(height: CaseTimeMachineSpacing.spaceXL.h),
          CaseMemoryLine(text: book.memoryLine),
          SizedBox(height: CaseTimeMachineSpacing.spaceL.h),
          CtmSurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('案件摘要',
                    style: CaseTimeMachineTextStyles.sectionTitle(context)),
                SizedBox(height: CaseTimeMachineSpacing.spaceM.h),
                Text(book.shortDescription,
                    style: CaseTimeMachineTextStyles.body(context)),
                SizedBox(height: CaseTimeMachineSpacing.spaceL.h),
                Text('卷宗包含資訊',
                    style: CaseTimeMachineTextStyles.cardTitle(context)),
                SizedBox(height: CaseTimeMachineSpacing.spaceM.h),
                _DossierStats(book: book),
              ],
            ),
          ),
          SizedBox(height: CaseTimeMachineSpacing.spaceXL.h),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: Size.fromHeight(52.h),
              backgroundColor: CaseTimeMachineColors.libraryDeepTeal,
              side: const BorderSide(
                  color: CaseTimeMachineColors.libraryBorderGold),
            ),
            onPressed: () => _openDossier(context),
            child: Text('翻開卷宗',
                style: CaseTimeMachineTextStyles.buttonText(context)),
          ),
          SizedBox(height: CaseTimeMachineSpacing.spaceM.h),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: Size.fromHeight(48.h),
              side: const BorderSide(
                  color: CaseTimeMachineColors.libraryBorderMist),
              foregroundColor: CaseTimeMachineColors.libraryFogWhite,
            ),
            onPressed: () => _saveCase(context),
            child: Text('收藏案件',
                style: CaseTimeMachineTextStyles.buttonText(context)),
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
              color:
                  CaseTimeMachineColors.libraryDeepGreen.withValues(alpha: .78),
              borderRadius:
                  BorderRadius.circular(CaseTimeMachineRadii.radiusMedium.r),
              border:
                  Border.all(color: CaseTimeMachineColors.libraryBorderMist),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stat.$1,
                    style: CaseTimeMachineTextStyles.caption(context)),
                SizedBox(height: 3.h),
                Text(stat.$2,
                    style: CaseTimeMachineTextStyles.cardTitle(context)),
              ],
            ),
          ),
      ],
    );
  }
}
