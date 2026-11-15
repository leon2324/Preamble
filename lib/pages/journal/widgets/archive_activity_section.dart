import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:preamble/features/case_library/data/case_library_repository.dart';
import 'package:preamble/features/case_library/pages/case_dossier_detail_page.dart';
import 'package:preamble/features/case_library/pages/case_library_entry_page.dart';
import 'package:preamble/pages/journal/data/journal_page_items.dart';
import 'package:preamble/pages/journal/widgets/journal_palette.dart';
import 'package:preamble/pages/journal/widgets/journal_section_header.dart';
import 'package:preamble/theme/preamble_tokens.dart';

class ArchiveActivitySection extends StatelessWidget {
  const ArchiveActivitySection({super.key, required this.palette});

  final JournalPalette palette;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        JournalSectionHeader(
          title: '卷宗編纂動態',
          subtitle: '新增判決、時間軸更新與法普筆記，追蹤近期館藏修訂節奏。',
          palette: palette,
          actionLabel: '查看全部',
          onActionTap: () {
            Navigator.of(context).push(
              CupertinoPageRoute<void>(
                builder: (_) => const CaseLibraryEntryPage(),
              ),
            );
          },
        ),
        SizedBox(height: 12.h),
        Container(
          decoration: t.cardDecoration(radius: 20.r, elevated: false),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var index = 0; index < archiveUpdateItems.length; index++)
                _ArchiveUpdateRow(
                  item: archiveUpdateItems[index],
                  showDivider: index != archiveUpdateItems.length - 1,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ArchiveUpdateRow extends StatelessWidget {
  const _ArchiveUpdateRow({
    required this.item,
    required this.showDivider,
  });

  final ArchiveUpdateItem item;
  final bool showDivider;

  IconData _iconForType(String type) {
    switch (type) {
      case '新增判決':
        return PhosphorIconsRegular.scales;
      case '時間軸更新':
        return PhosphorIconsRegular.clockCounterClockwise;
      case '資料補完':
      case '新增卷宗':
        return PhosphorIconsRegular.bookBookmark;
      case '生活避坑':
      case '防詐筆記':
      default:
        return PhosphorIconsRegular.notePencil;
    }
  }

  Color _accentForType(PreambleTokens t, String type) {
    switch (type) {
      case '新增判決':
        return t.brandPrimary;
      case '時間軸更新':
        return t.semanticInfo;
      case '資料補完':
      case '新增卷宗':
        return t.accentBrass;
      case '防詐筆記':
        return t.semanticUrgent;
      case '生活避坑':
      default:
        return t.semanticSuccess;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final accent = _accentForType(t, item.type);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final repo = CaseLibraryRepository.instance;
          if (repo.cases.isEmpty) {
            await repo.initialize();
          }
          if (!context.mounted) return;
          final book = repo.getCaseById(item.caseId);
          Navigator.of(context).push(
            CupertinoPageRoute<void>(
              builder: (_) => CaseDossierDetailPage(
                book: book,
                initialTab: item.initialTab,
              ),
            ),
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          decoration: BoxDecoration(
            border: showDivider
                ? Border(
                    bottom: BorderSide(color: t.border, width: 1),
                  )
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: t.isDark ? 0.18 : 0.12),
                  borderRadius: BorderRadius.circular(11.r),
                ),
                child: Icon(
                  _iconForType(item.type),
                  size: 18.sp,
                  color: accent,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: accent.withValues(
                              alpha: t.isDark ? 0.2 : 0.1,
                            ),
                            borderRadius: BorderRadius.circular(5.r),
                          ),
                          child: Text(
                            item.type,
                            style: t.sansBody(
                              size: 10.sp,
                              weight: FontWeight.w700,
                              color: accent,
                              height: 1.2,
                            ),
                          ),
                        ),
                        SizedBox(width: 7.w),
                        Expanded(
                          child: Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: t.serifTitle(
                              size: 14.sp,
                              weight: FontWeight.w700,
                              color: t.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      item.summary,
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
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    item.timeLabel,
                    style: t.tabularMetric(
                      size: 10.5.sp,
                      weight: FontWeight.w600,
                      color: t.textMuted,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Icon(
                    PhosphorIconsRegular.caretRight,
                    size: 14.sp,
                    color: t.textMuted,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
