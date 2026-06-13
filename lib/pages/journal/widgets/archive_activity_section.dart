import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/pages/journal/data/journal_page_items.dart';
import 'package:lawapp/pages/journal/widgets/journal_palette.dart';
import 'package:lawapp/pages/journal/widgets/journal_section_header.dart';
import 'package:lawapp/features/case_time_machine/data/case_time_machine_repository.dart';
import 'package:lawapp/features/case_time_machine/pages/case_dossier_detail_page.dart';

class ArchiveActivitySection extends StatelessWidget {
  const ArchiveActivitySection({super.key, required this.palette});

  final JournalPalette palette;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        JournalSectionHeader(
          title: '圖書館動態',
          subtitle: '新增判決、時間軸更新與資料補完，先用 mock data 呈現更新節奏。',
          palette: palette,
          actionLabel: '查看全部',
        ),
        SizedBox(height: 12.h),
        Container(
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: palette.border.withValues(alpha: 0.78)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
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

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          final book = CaseTimeMachineRepository.instance.getCaseById(item.caseId);
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
          padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
          decoration: BoxDecoration(
            border: showDivider
                ? Border(
                    bottom: BorderSide(
                      color: const Color(0xFFE6EAE7),
                    ),
                  )
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34.w,
                height: 34.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: item.tint.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11.r),
                ),
                child: Icon(
                  CupertinoIcons.doc_text,
                  size: 18.sp,
                  color: item.tint,
                ),
              ),
              SizedBox(width: 11.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 12.7.sp,
                          height: 1.3,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF173C37),
                        ),
                        children: [
                          TextSpan(
                            text: '[${item.type}] ',
                            style: TextStyle(color: item.tint),
                          ),
                          TextSpan(text: item.title),
                        ],
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      item.summary,
                      style: TextStyle(
                        fontSize: 11.1.sp,
                        height: 1.45,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6A726F),
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
                    style: TextStyle(
                      fontSize: 10.8.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF7A827E),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Icon(
                    CupertinoIcons.chevron_right,
                    size: 14.sp,
                    color: const Color(0xFF97A09D),
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
