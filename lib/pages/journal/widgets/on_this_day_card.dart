import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:preamble/features/case_library/data/case_library_repository.dart';
import 'package:preamble/features/case_library/models/case_library_models.dart';
import 'package:preamble/features/case_library/pages/case_dossier_detail_page.dart';
import 'package:preamble/features/on_this_day/data/on_this_day_mock_data.dart';
import 'package:preamble/features/on_this_day/models/on_this_day_models.dart';
import 'package:preamble/features/on_this_day/pages/on_this_day_detail_page.dart';
import 'package:preamble/features/on_this_day/pages/on_this_day_home_page.dart';
import 'package:preamble/pages/journal/widgets/journal_palette.dart';
import 'package:preamble/theme/preamble_tokens.dart';

/// 公共法治策展首屏：今日歷史記憶主視覺卡（取代舊版 3D 金屬活頁孔環）。
class OnThisDayCard extends StatefulWidget {
  const OnThisDayCard({super.key, required this.palette});

  final JournalPalette palette;

  @override
  State<OnThisDayCard> createState() => _OnThisDayCardState();
}

class _OnThisDayCardState extends State<OnThisDayCard> {
  late final DateTime _today;
  late DateTime _currentDate;
  CaseBook? _matchedBook;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _today = DateTime(now.year, now.month, now.day);
    _currentDate = _today;
    _checkDossier();
  }

  OnThisDayCase? get _activeCase {
    final exact =
        onThisDayCasesForDate(_currentDate.month, _currentDate.day);
    if (exact.isNotEmpty) return exact.first;
    return onThisDayNearestCaseForDate(_currentDate.month, _currentDate.day);
  }

  bool get _isExactDateMatch =>
      onThisDayCasesForDate(_currentDate.month, _currentDate.day).isNotEmpty;

  Future<void> _checkDossier() async {
    try {
      final repository = CaseLibraryRepository.instance;
      if (repository.cases.isEmpty) {
        await repository.initialize();
      }
      final active = _activeCase;
      if (active == null) {
        if (mounted) setState(() => _matchedBook = null);
        return;
      }
      CaseBook? found;
      for (final book in repository.cases) {
        if (book.id == active.id ||
            book.titleZh.contains(active.title) ||
            active.title.contains(book.titleZh) ||
            (book.shortTitleZh.isNotEmpty &&
                (book.shortTitleZh.contains(active.title) ||
                    active.title.contains(book.shortTitleZh)))) {
          found = book;
          break;
        }
      }
      if (mounted) {
        setState(() => _matchedBook = found);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _matchedBook = null);
      }
    }
  }

  void _randomRoam() {
    if (onThisDayCases.isEmpty) return;
    final random = math.Random();
    final activeId = _activeCase?.id;
    final pool =
        onThisDayCases.where((c) => c.id != activeId).toList(growable: false);
    final chosen = (pool.isNotEmpty ? pool : onThisDayCases)[
        random.nextInt(pool.isNotEmpty ? pool.length : onThisDayCases.length)];
    final isLeapYear = (_today.year % 4 == 0 && _today.year % 100 != 0) ||
        (_today.year % 400 == 0);
    final safeDay =
        (chosen.month == 2 && chosen.day == 29 && !isLeapYear) ? 28 : chosen.day;
    setState(() {
      _currentDate = DateTime(_today.year, chosen.month, safeDay);
    });
    _checkDossier();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final activeCase = _activeCase;
    final isToday =
        _currentDate.month == _today.month && _currentDate.day == _today.day;
    final isExact = _isExactDateMatch;

    final String badgeText;
    if (isExact) {
      badgeText = isToday
          ? '今日法治記憶 · ${_today.month}月${_today.day}日'
          : '漫遊法治記憶 · ${_currentDate.month}月${_currentDate.day}日';
    } else if (activeCase != null) {
      final relation =
          activeCase.month == _today.month ? '本月鄰近記憶' : '鄰近歷史記憶';
      badgeText =
          '今日 ${_today.month}月${_today.day}日 · $relation (${activeCase.month}/${activeCase.day})';
    } else {
      badgeText = '今日 ${_today.month}月${_today.day}日';
    }

    return Container(
      decoration: t.cardDecoration(radius: 22.r),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 14.w, 14.h),
            decoration: BoxDecoration(
              color: t.brandPrimaryStrong,
              border: Border(
                bottom: BorderSide(
                  color: t.accentBrass.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  PhosphorIconsRegular.calendarStar,
                  size: 15.sp,
                  color: const Color(0xFFEED3A5),
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    badgeText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.sansBody(
                      size: 11.5.sp,
                      weight: FontWeight.w700,
                      color: const Color(0xFFEED3A5),
                      height: 1.2,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _randomRoam,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 9.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(999.r),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          PhosphorIconsRegular.shuffle,
                          size: 12.sp,
                          color: const Color(0xFFFAF8F4),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '換一則',
                          style: t.sansBody(
                            size: 10.5.sp,
                            weight: FontWeight.w700,
                            color: const Color(0xFFFAF8F4),
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (activeCase != null)
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 78.w,
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: t.surfaceSubtle,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: t.accentBrass.withValues(alpha: 0.45),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${activeCase.year}',
                              style: t.tabularMetric(
                                size: 11.5.sp,
                                weight: FontWeight.w700,
                                color: t.accentBrass,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '${activeCase.month} / ${activeCase.day}',
                                style: t.serifTitle(
                                  size: 19.sp,
                                  weight: FontWeight.w800,
                                  color: t.brandPrimary,
                                ),
                              ),
                            ),
                            SizedBox(height: 5.h),
                            Text(
                              activeCase.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: t.sansBody(
                                size: 9.5.sp,
                                weight: FontWeight.w600,
                                color: t.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 7.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: t.brandContainer,
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                activeCase.category,
                                style: t.sansBody(
                                  size: 10.5.sp,
                                  weight: FontWeight.w700,
                                  color: t.brandOnContainer,
                                  height: 1.2,
                                ),
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              activeCase.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: t.serifTitle(
                                size: 18.sp,
                                weight: FontWeight.w800,
                                height: 1.28,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              activeCase.summary,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: t.sansBody(
                                size: 12.sp,
                                color: t.textSecondary,
                                height: 1.48,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 9.h,
                    ),
                    decoration: BoxDecoration(
                      color: t.surfaceSubtle,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border(
                        left: BorderSide(color: t.accentBrass, width: 3),
                      ),
                    ),
                    child: Text(
                      '「${activeCase.quote}」',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: t.serifBody(
                        size: 12.sp,
                        color: t.textPrimary,
                        height: 1.48,
                      ),
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              CupertinoPageRoute<void>(
                                builder: (_) => const OnThisDayHomePage(),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            side: BorderSide(color: t.borderStrong),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          icon: Icon(
                            PhosphorIconsRegular.calendarBlank,
                            size: 15.sp,
                            color: t.textPrimary,
                          ),
                          label: Text(
                            '日曆總覽',
                            style: t.sansBody(
                              size: 12.sp,
                              weight: FontWeight.w700,
                              color: t.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (_matchedBook != null) {
                              Navigator.of(context).push(
                                CupertinoPageRoute<void>(
                                  builder: (_) => CaseDossierDetailPage(
                                    book: _matchedBook!,
                                  ),
                                ),
                              );
                            } else {
                              Navigator.of(context).push(
                                CupertinoPageRoute<void>(
                                  builder: (_) => OnThisDayDetailPage(
                                    caseId: activeCase.id,
                                  ),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: t.brandPrimaryStrong,
                            foregroundColor: const Color(0xFFFAF8F4),
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          icon: Icon(
                            PhosphorIconsRegular.bookOpenText,
                            size: 15.sp,
                            color: const Color(0xFFFAF8F4),
                          ),
                          label: Text(
                            _matchedBook != null ? '調閱案件卷宗' : '閱讀歷史始末',
                            style: t.sansBody(
                              size: 12.sp,
                              weight: FontWeight.w700,
                              color: const Color(0xFFFAF8F4),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
