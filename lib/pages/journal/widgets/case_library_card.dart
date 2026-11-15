import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:preamble/features/case_library/pages/case_legal_vocabulary_page.dart';
import 'package:preamble/features/case_library/pages/case_library_entry_page.dart';
import 'package:preamble/features/on_this_day/pages/on_this_day_home_page.dart';
import 'package:preamble/pages/journal/widgets/journal_palette.dart';
import 'package:preamble/pages/journal/widgets/journal_section_header.dart';
import 'package:preamble/theme/preamble_tokens.dart';

/// 公共法治館藏三大入口卡片組：
/// 1. 重大案件館 (`CaseLibraryEntryPage`)
/// 2. 歷史上的今日 (`OnThisDayHomePage`)
/// 3. 法學術語白話辭典 (`CaseLegalVocabularyPage`)
class CaseLibraryCard extends StatelessWidget {
  const CaseLibraryCard({super.key, required this.palette});

  final JournalPalette palette;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        JournalSectionHeader(
          title: '公共法治典藏館',
          subtitle: '從重大憲政刑案、法制歷史座標到白話法學詞卡，系統化探索法治脈絡。',
          palette: palette,
        ),
        SizedBox(height: 12.h),
        _PrimaryGatewayCard(
          tokens: t,
          badge: 'MAJOR CASE ARCHIVE',
          title: '重大案件館',
          subtitle: '深度收錄憲法法庭釋字、冤案平反與社會矚目案件卷宗，拆解爭點與歷審推理。',
          actionLabel: '進入重大案件館',
          icon: PhosphorIconsRegular.bank,
          onTap: () {
            Navigator.of(context).push(
              CupertinoPageRoute<void>(
                builder: (_) => const CaseLibraryEntryPage(),
              ),
            );
          },
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: _SecondaryGatewayCard(
                tokens: t,
                icon: PhosphorIconsRegular.clockCounterClockwise,
                badge: 'ON THIS DAY',
                title: '歷史上的今日',
                subtitle: '依真實日期翻閱臺灣人權與法制史關鍵時刻',
                accentColor: t.accentBrass,
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute<void>(
                      builder: (_) => const OnThisDayHomePage(),
                    ),
                  );
                },
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _SecondaryGatewayCard(
                tokens: t,
                icon: PhosphorIconsRegular.bookOpenText,
                badge: 'LEXICON',
                title: '法學術語白話辭典',
                subtitle: '翻轉判決艱深術語，對照生活實例與代表案件',
                accentColor: t.brandPrimary,
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute<void>(
                      builder: (_) => const CaseLegalVocabularyPage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PrimaryGatewayCard extends StatelessWidget {
  const _PrimaryGatewayCard({
    required this.tokens,
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.icon,
    required this.onTap,
  });

  final PreambleTokens tokens;
  final String badge;
  final String title;
  final String subtitle;
  final String actionLabel;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = tokens;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Ink(
          padding: EdgeInsets.all(18.w),
          decoration: BoxDecoration(
            color: t.brandPrimaryStrong,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: t.accentBrass.withValues(alpha: 0.45),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: t.shadowAmbient,
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: const Color(0x24D4AC6E),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: const Color(0x55D4AC6E)),
                    ),
                    child: Icon(
                      icon,
                      size: 20.sp,
                      color: const Color(0xFFEED3A5),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      badge,
                      style: t.tabularMetric(
                        size: 10.5.sp,
                        weight: FontWeight.w700,
                        color: const Color(0xFFEED3A5),
                      ),
                    ),
                  ),
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 11.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0x26D4AC6E),
                        borderRadius: BorderRadius.circular(999.r),
                        border: Border.all(color: const Color(0x66D4AC6E)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              actionLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: t.sansBody(
                                size: 11.sp,
                                weight: FontWeight.w700,
                                color: const Color(0xFFFAF8F4),
                                height: 1.2,
                              ),
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Icon(
                            PhosphorIconsRegular.arrowRight,
                            size: 12.sp,
                            color: const Color(0xFFEED3A5),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              Text(
                title,
                style: t.serifTitle(
                  size: 21.sp,
                  weight: FontWeight.w800,
                  color: const Color(0xFFFAF8F4),
                ),
              ),
              SizedBox(height: 5.h),
              Text(
                subtitle,
                style: t.sansBody(
                  size: 12.5.sp,
                  color: const Color(0xFFD6EAE2),
                  height: 1.48,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecondaryGatewayCard extends StatelessWidget {
  const _SecondaryGatewayCard({
    required this.tokens,
    required this.icon,
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.onTap,
  });

  final PreambleTokens tokens;
  final IconData icon;
  final String badge;
  final String title;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = tokens;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Ink(
          padding: EdgeInsets.all(14.w),
          decoration: t.cardDecoration(radius: 18.r, elevated: false),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 34.w,
                    height: 34.w,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(
                        alpha: t.isDark ? 0.18 : 0.12,
                      ),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(icon, size: 18.sp, color: accentColor),
                  ),
                  const Spacer(),
                  Icon(
                    PhosphorIconsRegular.arrowUpRight,
                    size: 15.sp,
                    color: t.textMuted,
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Text(
                badge,
                style: t.tabularMetric(
                  size: 9.5.sp,
                  weight: FontWeight.w700,
                  color: accentColor,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: t.serifTitle(
                  size: 15.sp,
                  weight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: t.sansBody(
                  size: 11.5.sp,
                  color: t.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
