import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/features/case_time_machine/data/case_time_machine_mock_data.dart';
import 'package:lawapp/features/case_time_machine/models/case_time_machine_models.dart';
import 'package:lawapp/features/case_time_machine/pages/case_book_preview_page.dart';
import 'package:lawapp/features/case_time_machine/theme/case_time_machine_theme.dart';
import 'package:lawapp/features/case_time_machine/widgets/_ctm_surface.dart';
import 'package:lawapp/features/case_time_machine/widgets/case_memory_line.dart';
import 'package:lawapp/features/case_time_machine/widgets/case_person_role_card.dart';
import 'package:lawapp/features/case_time_machine/widgets/case_time_machine_scaffold.dart';
import 'package:lawapp/features/case_time_machine/widgets/case_timeline_section.dart';
import 'package:lawapp/features/case_time_machine/widgets/dossier_section_card.dart';
import 'package:lawapp/features/case_time_machine/widgets/expandable_dossier_section.dart';
import 'package:lawapp/features/case_time_machine/widgets/favorite_follow_button.dart';
import 'package:lawapp/features/case_time_machine/widgets/issue_chip_wrap.dart';
import 'package:lawapp/features/case_time_machine/widgets/legal_issue_card.dart';
import 'package:lawapp/features/case_time_machine/widgets/login_prompt_bottom_sheet.dart';
import 'package:lawapp/features/case_time_machine/widgets/related_case_shelf_sections.dart';
import 'package:lawapp/features/case_time_machine/widgets/related_law_card.dart';
import 'package:lawapp/features/case_time_machine/widgets/source_info_card.dart';

class CaseDossierDetailPage extends StatelessWidget {
  const CaseDossierDetailPage({super.key, required this.book});

  final CaseBook book;

  void _openRelatedCase(BuildContext context, RelatedCase relatedCase) {
    final relatedBook = caseTimeMachineCaseById(relatedCase.caseId);
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => CaseBookPreviewPage(book: relatedBook),
      ),
    );
  }

  void _showLoginPrompt(BuildContext context) {
    showLoginPromptBottomSheet(context);
  }

  @override
  Widget build(BuildContext context) {
    return CaseTimeMachineScaffold(
      scene: CaseTimeMachineScene.dossier,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isLandscapeDossier = constraints.maxWidth >= 680;
          final padding = EdgeInsets.fromLTRB(20.w, 66.h, 20.w, 32.h);

          if (isLandscapeDossier) {
            // 台灣繁體中文教學註解：
            // 橫向卷宗採雙欄：左邊保留案件書封面式摘要，右邊閱讀完整卷宗。
            // 這比把直式頁面硬拉寬更接近 Prototype 的平板／橫向模式。
            return ListView(
              padding: padding,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: _DossierLeadingColumn(
                        book: book,
                        onLoginPrompt: () => _showLoginPrompt(context),
                      ),
                    ),
                    SizedBox(width: CaseTimeMachineSpacing.spaceL.w),
                    Expanded(
                      flex: 6,
                      child: _DossierBodyColumn(
                        book: book,
                        onRelatedCaseTap: (relatedCase) =>
                            _openRelatedCase(context, relatedCase),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }

          return ListView(
            padding: padding,
            children: [
              _DossierLeadingColumn(
                book: book,
                onLoginPrompt: () => _showLoginPrompt(context),
              ),
              SizedBox(height: CaseTimeMachineSpacing.spaceM.h),
              _DossierBodyColumn(
                book: book,
                onRelatedCaseTap: (relatedCase) =>
                    _openRelatedCase(context, relatedCase),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DossierLeadingColumn extends StatelessWidget {
  const _DossierLeadingColumn({
    required this.book,
    required this.onLoginPrompt,
  });

  final CaseBook book;
  final VoidCallback onLoginPrompt;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _DossierHeader(book: book),
        SizedBox(height: CaseTimeMachineSpacing.spaceL.h),
        DossierSectionCard(
          title: '卷宗導讀',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CaseMemoryLine(text: book.oneSentenceSummary),
              SizedBox(height: CaseTimeMachineSpacing.spaceM.h),
              Text(book.shortDescription,
                  style: CaseTimeMachineTextStyles.body(context)),
            ],
          ),
        ),
        SizedBox(height: CaseTimeMachineSpacing.spaceL.h),
        DossierSectionCard(
          title: '案件基本資料',
          child: _BasicInfoGrid(book: book),
        ),
        SizedBox(height: CaseTimeMachineSpacing.spaceL.h),
        DossierSectionCard(
          title: '收藏 / 追蹤',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('登入後可以把案件之書放進個人書櫃、追蹤卷宗更新，並同步你的閱讀紀錄。',
                  style: CaseTimeMachineTextStyles.bodySmall(context)),
              SizedBox(height: CaseTimeMachineSpacing.spaceM.h),
              FavoriteFollowButton(
                  label: '加入追蹤', primary: true, onPressed: onLoginPrompt),
              SizedBox(height: CaseTimeMachineSpacing.spaceS.h),
              FavoriteFollowButton(label: '收藏案件', onPressed: onLoginPrompt),
            ],
          ),
        ),
      ],
    );
  }
}

class _DossierBodyColumn extends StatelessWidget {
  const _DossierBodyColumn({
    required this.book,
    required this.onRelatedCaseTap,
  });

  final CaseBook book;
  final ValueChanged<RelatedCase> onRelatedCaseTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CtmSurface(
          child: Column(
            children: [
              ExpandableDossierSection(title: '案件背景', body: book.background),
              ExpandableDossierSection(title: '事件經過', body: book.fullStory),
              ExpandableDossierSection(
                  title: '偵查與審理歷程', body: book.investigationAndTrial),
              ExpandableDossierSection(
                  title: '法院認定重點', body: book.courtReasoning),
              ExpandableDossierSection(
                  title: '社會影響與後續發展', body: book.socialImpact),
            ],
          ),
        ),
        SizedBox(height: CaseTimeMachineSpacing.spaceM.h),
        DossierSectionCard(
          title: '關鍵時間軸',
          child: CaseTimelineSection(items: book.timeline),
        ),
        SizedBox(height: CaseTimeMachineSpacing.spaceM.h),
        DossierSectionCard(
          title: '關鍵人物與關係',
          child: Column(
            children: [
              for (final person in book.people)
                CasePersonRoleCard(role: person),
            ],
          ),
        ),
        SizedBox(height: CaseTimeMachineSpacing.spaceM.h),
        DossierSectionCard(
          title: '主要法律爭點',
          child: Column(
            children: [
              for (final issue in book.legalIssues)
                LegalIssueCard(issue: issue),
            ],
          ),
        ),
        SizedBox(height: CaseTimeMachineSpacing.spaceM.h),
        DossierSectionCard(
          title: '判決結果 / 目前狀態',
          child: Text(book.judgmentResult,
              style: CaseTimeMachineTextStyles.body(context)),
        ),
        SizedBox(height: CaseTimeMachineSpacing.spaceM.h),
        DossierSectionCard(
          title: '相關法條',
          child: Column(
            children: [
              for (final law in book.relatedLaws) RelatedLawCard(law: law),
            ],
          ),
        ),
        SizedBox(height: CaseTimeMachineSpacing.spaceM.h),
        DossierSectionCard(
          title: '延伸書架 / 相關案件',
          child: RelatedCaseShelfSections(
            relatedCases: book.relatedCases,
            onCaseTap: onRelatedCaseTap,
          ),
        ),
        SizedBox(height: CaseTimeMachineSpacing.spaceM.h),
        DossierSectionCard(
          title: '資料來源與更新時間',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final source in book.sources) SourceInfoCard(source: source),
              SizedBox(height: CaseTimeMachineSpacing.spaceS.h),
              Text(
                '本卷宗為 LawApp MVP 示範資料，僅供法律知識與產品體驗參考，不構成正式法律意見。',
                style: CaseTimeMachineTextStyles.caption(context),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DossierHeader extends StatelessWidget {
  const _DossierHeader({required this.book});

  final CaseBook book;

  @override
  Widget build(BuildContext context) {
    return CtmSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IssueChipWrap(labels: ['${book.year}', book.category, book.status]),
          SizedBox(height: CaseTimeMachineSpacing.spaceM.h),
          Text(book.titleZh,
              style: CaseTimeMachineTextStyles.pageTitle(context)),
          SizedBox(height: CaseTimeMachineSpacing.spaceXS.h),
          Text(book.titleEn, style: CaseTimeMachineTextStyles.caption(context)),
          SizedBox(height: CaseTimeMachineSpacing.spaceM.h),
          Text('${book.year}｜${book.location}｜${book.status}',
              style: CaseTimeMachineTextStyles.bodySmall(context)),
        ],
      ),
    );
  }
}

class _BasicInfoGrid extends StatelessWidget {
  const _BasicInfoGrid({required this.book});

  final CaseBook book;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('年份', '${book.year}'),
      ('地點', book.location),
      ('類型', book.category),
      ('狀態', book.status),
    ];

    // 台灣繁體中文教學註解：
    // Wrap 讓基本資料在不同手機寬度下自動換行，比固定 Grid 更不容易爆版。
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        for (final item in items)
          Container(
            width: 136.w,
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
                Text(item.$1,
                    style: CaseTimeMachineTextStyles.caption(context)),
                SizedBox(height: 3.h),
                Text(item.$2,
                    style: CaseTimeMachineTextStyles.cardTitle(context)),
              ],
            ),
          ),
      ],
    );
  }
}
