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
import 'package:preamble/features/on_this_day/pages/on_this_day_date_discovery_page.dart';
import 'package:preamble/features/on_this_day/pages/on_this_day_detail_page.dart';
import 'package:preamble/features/on_this_day/pages/on_this_day_list_page.dart';
import 'package:preamble/features/on_this_day/widgets/on_this_day_calendar_sheet.dart';
import 'package:preamble/features/on_this_day/widgets/on_this_day_postcard_elements.dart';
import 'package:preamble/features/on_this_day/widgets/retro_date_dial_picker.dart';
import 'package:preamble/theme/preamble_tokens.dart';

class OnThisDayHomePage extends StatefulWidget {
  const OnThisDayHomePage({super.key});

  @override
  State<OnThisDayHomePage> createState() => _OnThisDayHomePageState();
}

class _OnThisDayHomePageState extends State<OnThisDayHomePage> {
  static const int _initialPage = 10000;

  late final DateTime _today;
  late final DateTime _anchorDate;
  late DateTime _selectedDate;
  late PageController _pageController;

  OnThisDayCase? _exactMainCase;
  OnThisDayCase? _nearestCase;
  List<OnThisDayCase> _otherCases = const [];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _today = DateTime(now.year, now.month, now.day);
    _anchorDate = _today;
    _selectedDate = _today;
    _pageController = PageController(initialPage: _initialPage);
    _initRepository();
    _loadCasesForSelectedDate();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _initRepository() async {
    final repo = CaseLibraryRepository.instance;
    if (repo.cases.isEmpty) {
      await repo.initialize();
      if (mounted) {
        setState(() {});
      }
    }
  }

  bool _isSameMonthDay(DateTime a, DateTime b) =>
      a.month == b.month && a.day == b.day;

  void _loadCasesForSelectedDate() {
    final dayCases =
        onThisDayCasesForDate(_selectedDate.month, _selectedDate.day);
    final nearest =
        onThisDayNearestCaseForDate(_selectedDate.month, _selectedDate.day);
    setState(() {
      if (dayCases.isNotEmpty) {
        _exactMainCase = dayCases.first;
        _nearestCase = dayCases.first;
        _otherCases = dayCases.skip(1).toList();
      } else {
        _exactMainCase = null;
        _nearestCase = nearest;
        _otherCases = const [];
      }
    });
  }

  void _jumpToDate(DateTime targetDate, {bool animate = false}) {
    final normalized =
        DateTime(_anchorDate.year, targetDate.month, targetDate.day);
    final page = _initialPage + normalized.difference(_anchorDate).inDays;
    setState(() {
      _selectedDate = normalized;
      _loadCasesForSelectedDate();
    });
    if (_pageController.hasClients) {
      if (animate) {
        _pageController.animateToPage(
          page,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutCubic,
        );
      } else {
        _pageController.jumpToPage(page);
      }
    }
  }

  void _timeTravel() {
    final random = math.Random();
    final availableCases = onThisDayCases
        .where((c) =>
            !(c.month == _selectedDate.month && c.day == _selectedDate.day))
        .toList();
    final casesToUse =
        availableCases.isNotEmpty ? availableCases : onThisDayCases;
    if (casesToUse.isEmpty) return;

    final randomCase = casesToUse[random.nextInt(casesToUse.length)];
    final isLeapYear = (_anchorDate.year % 4 == 0 &&
            _anchorDate.year % 100 != 0) ||
        (_anchorDate.year % 400 == 0);
    final safeDay =
        (randomCase.month == 2 && randomCase.day == 29 && !isLeapYear)
            ? 28
            : randomCase.day;
    _jumpToDate(
      DateTime(_anchorDate.year, randomCase.month, safeDay),
      animate: true,
    );
  }

  void _goToPreviousDay() {
    if (_pageController.hasClients) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  CaseBook? _findDossierSync(OnThisDayCase? item) {
    if (item == null) return null;
    final cases = CaseLibraryRepository.instance.cases;
    for (final book in cases) {
      if (book.id == item.id ||
          book.titleZh.contains(item.title) ||
          item.title.contains(book.titleZh) ||
          (book.shortTitleZh.isNotEmpty &&
              (book.shortTitleZh.contains(item.title) ||
                  item.title.contains(book.shortTitleZh)))) {
        return book;
      }
    }
    return null;
  }

  void _showRetroDatePicker() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return RetroDateDialPicker(
          initialDate: _selectedDate,
          onDateSelected: (newDate) => _jumpToDate(newDate),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final displayCase = _exactMainCase ?? _nearestCase;

    return Scaffold(
      backgroundColor: t.canvas,
      appBar: AppBar(
        backgroundColor: t.canvas,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            PhosphorIconsRegular.caretLeft,
            color: t.textPrimary,
            size: 20.sp,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 14.w),
            child: TextButton.icon(
              onPressed: _timeTravel,
              icon: Icon(
                PhosphorIconsRegular.shuffle,
                size: 15.sp,
                color: t.accentBrass,
              ),
              label: Text(
                '隨機漫遊',
                style: t.sansBody(
                  size: 12.sp,
                  weight: FontWeight.w700,
                  color: t.accentBrass,
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(18.w, 4.h, 18.w, 32.h),
        physics: const BouncingScrollPhysics(),
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 18.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                          '今日座標 · ${_today.month}月${_today.day}日',
                          style: t.tabularMetric(
                            size: 10.5.sp,
                            weight: FontWeight.w700,
                            color: t.accentOnBrassContainer,
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        '歷史上的今日',
                        style: t.serifTitle(
                          size: 26.sp,
                          weight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '臺灣法制與人權里程碑日誌',
                        style: t.sansBody(
                          size: 12.5.sp,
                          weight: FontWeight.w600,
                          color: t.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 128.w,
                  height: 60.h,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        right: 0,
                        top: 4.h,
                        child: const PostageStamp(),
                      ),
                      Positioned(
                        left: 0,
                        top: 2.h,
                        child: IgnorePointer(
                          child: CustomPaint(
                            size: Size(96.w, 52.h),
                            painter: ProgrammaticPostmarkPainter(
                              dateText: displayCase != null
                                  ? displayCase.fullDateLabel
                                  : '${_selectedDate.year}.${_selectedDate.month.toString().padLeft(2, '0')}.${_selectedDate.day.toString().padLeft(2, '0')}',
                              locationText: displayCase?.location ?? '法治歲月',
                              color: t.textMuted,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildPositioningBanner(t),
          _buildFeaturedCasePager(t),
          SizedBox(height: 24.h),
          _buildExploreByDateSection(t),
          SizedBox(height: 24.h),
          _buildCuratedHistorySection(t),
        ],
      ),
    );
  }

  Widget _buildPositioningBanner(PreambleTokens t) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(14.w),
      decoration: t.subtleBoxDecoration(radius: 16.r),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34.w,
            height: 34.w,
            decoration: BoxDecoration(
              color: t.brandContainer,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              PhosphorIconsRegular.compass,
              color: t.brandOnContainer,
              size: 18.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '探索法治足跡，拉近法律與現代生活的距離',
                  style: t.sansTitle(
                    size: 13.sp,
                    weight: FontWeight.w700,
                    color: t.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '每一樁憲政與司法轉折都塑造了今日的權利保障。滑動日曆翻閱當日或鄰近歷史事件，對照現代法理演進。',
                  style: t.sansBody(
                    size: 11.5.sp,
                    color: t.textSecondary,
                    height: 1.48,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCasePager(PreambleTokens t) {
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final pageHeight =
        (textScale > 1.5 ? 430 : (textScale > 1.2 ? 375 : 315)).h;

    return SizedBox(
      height: pageHeight,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (page) {
          setState(() {
            _selectedDate =
                _anchorDate.add(Duration(days: page - _initialPage));
            _loadCasesForSelectedDate();
          });
        },
        itemBuilder: (context, index) {
          final date = _anchorDate.add(Duration(days: index - _initialPage));
          final dayCases = onThisDayCasesForDate(date.month, date.day);
          final exactCase = dayCases.isNotEmpty ? dayCases.first : null;
          final nearestCase =
              exactCase ?? onThisDayNearestCaseForDate(date.month, date.day);

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child: _buildFeaturedCaseCardForDate(
              t,
              date: date,
              exactCase: exactCase,
              nearestCase: nearestCase,
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedCaseCardForDate(
    PreambleTokens t, {
    required DateTime date,
    required OnThisDayCase? exactCase,
    required OnThisDayCase? nearestCase,
  }) {
    final isToday = _isSameMonthDay(date, _today);
    final isExact = exactCase != null;
    final activeCase = exactCase ?? nearestCase;
    final matchedBook = _findDossierSync(activeCase);
    final quoteItem = onThisDayLegalQuotes[
        (date.month * 31 + date.day) % onThisDayLegalQuotes.length];

    final String statusBadgeLabel;
    if (isExact) {
      statusBadgeLabel = isToday
          ? '今日正日事件 · ${date.month}月${date.day}日'
          : '當日歷史事件 · ${date.month}月${date.day}日';
    } else if (activeCase != null) {
      final sameMonth = activeCase.month == date.month;
      final prefix = isToday
          ? '今日 ${date.month}月${date.day}日'
          : '所選 ${date.month}月${date.day}日';
      final relation = sameMonth ? '本月鄰近記憶' : '近期鄰近記憶';
      statusBadgeLabel =
          '$prefix · $relation (${activeCase.month}/${activeCase.day})';
    } else {
      statusBadgeLabel = '${date.month}月${date.day}日';
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: t.cardDecoration(radius: 20.r),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 6.w,
                    runSpacing: 4.h,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 9.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: isExact
                              ? t.brandContainer
                              : t.accentBrassContainer,
                          borderRadius: BorderRadius.circular(999.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isExact
                                  ? PhosphorIconsRegular.calendarCheck
                                  : PhosphorIconsRegular.clockCounterClockwise,
                              size: 12.sp,
                              color: isExact
                                  ? t.brandOnContainer
                                  : t.accentOnBrassContainer,
                            ),
                            SizedBox(width: 4.w),
                            Flexible(
                              child: Text(
                                statusBadgeLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: t.sansBody(
                                  size: 10.5.sp,
                                  weight: FontWeight.w700,
                                  color: isExact
                                      ? t.brandOnContainer
                                      : t.accentOnBrassContainer,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 6.w),
                _buildPreviousDayButton(t),
              ],
            ),
            SizedBox(height: 14.h),
            if (activeCase != null) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OnThisDayCalendarSheet(
                    year: activeCase.year,
                    monthDay: '${activeCase.month} / ${activeCase.day}',
                    location: activeCase.location,
                    width: 96,
                    height: 114,
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 7.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: t.surfaceSubtle,
                                borderRadius: BorderRadius.circular(6.r),
                                border: Border.all(color: t.border),
                              ),
                              child: Text(
                                activeCase.category,
                                style: t.sansBody(
                                  size: 10.sp,
                                  weight: FontWeight.w700,
                                  color: t.textSecondary,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          activeCase.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: t.serifTitle(
                            size: 17.5.sp,
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
                        SizedBox(height: 10.h),
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 6.h,
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (matchedBook != null) {
                                  Navigator.of(context).push(
                                    CupertinoPageRoute<void>(
                                      builder: (__) => CaseDossierDetailPage(
                                        book: matchedBook,
                                      ),
                                    ),
                                  );
                                } else {
                                  Navigator.of(context).push(
                                    CupertinoPageRoute<void>(
                                      builder: (__) => OnThisDayDetailPage(
                                        caseId: activeCase.id,
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 13.w,
                                  vertical: 7.h,
                                ),
                                decoration: BoxDecoration(
                                  color: t.brandPrimaryStrong,
                                  borderRadius: BorderRadius.circular(999.r),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      matchedBook != null
                                          ? '調閱法治卷宗'
                                          : '閱讀歷史卷宗',
                                      style: t.sansBody(
                                        size: 11.5.sp,
                                        weight: FontWeight.w700,
                                        color: const Color(0xFFFAF8F4),
                                        height: 1.2,
                                      ),
                                    ),
                                    SizedBox(width: 4.w),
                                    Icon(
                                      PhosphorIconsRegular.arrowRight,
                                      size: 12.sp,
                                      color: const Color(0xFFFAF8F4),
                                    ),
                                  ],
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
              SizedBox(height: 12.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
                decoration: BoxDecoration(
                  color: t.surfaceSubtle,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border(
                    left: BorderSide(color: t.accentBrass, width: 3),
                  ),
                ),
                child: Text(
                  isExact
                      ? '「${activeCase.quote}」'
                      : '當日思辨：「${quoteItem.quote}」—— ${quoteItem.author}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: t.serifBody(
                    size: 11.5.sp,
                    color: t.textSecondary,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPreviousDayButton(PreambleTokens t) {
    return GestureDetector(
      onTap: _goToPreviousDay,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: t.surfaceSubtle,
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(color: t.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              PhosphorIconsRegular.arrowLeft,
              size: 11.sp,
              color: t.textSecondary,
            ),
            SizedBox(width: 3.w),
            Text(
              '前一日',
              style: t.sansBody(
                size: 10.sp,
                weight: FontWeight.w700,
                color: t.textSecondary,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExploreByDateSection(PreambleTokens t) {
    final isTodaySelected = _isSameMonthDay(_selectedDate, _today);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '依時間維度探索',
          style: t.sansTitle(size: 15.sp, weight: FontWeight.w700),
        ),
        SizedBox(height: 10.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildExplorePill(
                t,
                '今天 (${_today.month}/${_today.day})',
                isSelected: isTodaySelected,
                onTap: () => _jumpToDate(_today, animate: true),
              ),
              SizedBox(width: 8.w),
              _buildExplorePill(t, '本月記憶', onTap: () => _openDiscovery('本月')),
              SizedBox(width: 8.w),
              _buildExplorePill(t, '週年紀念', onTap: () => _openDiscovery('今年')),
              SizedBox(width: 8.w),
              _buildExplorePill(
                t,
                '重大憲政',
                onTap: () => _openDiscovery('重大事件'),
              ),
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: _showRetroDatePicker,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: t.surface,
                    borderRadius: BorderRadius.circular(999.r),
                    border: Border.all(color: t.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        PhosphorIconsRegular.calendarBlank,
                        size: 15.sp,
                        color: t.brandPrimary,
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        '指定日期',
                        style: t.sansBody(
                          size: 12.sp,
                          weight: FontWeight.w700,
                          color: t.textPrimary,
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
      ],
    );
  }

  Widget _buildExplorePill(
    PreambleTokens t,
    String label, {
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? t.brandPrimaryStrong : t.surface,
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(
            color: isSelected ? t.brandPrimaryStrong : t.border,
          ),
        ),
        child: Text(
          label,
          style: t.sansBody(
            size: 12.sp,
            weight: FontWeight.w700,
            color: isSelected ? const Color(0xFFFAF8F4) : t.textSecondary,
            height: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildCuratedHistorySection(PreambleTokens t) {
    final activeId = (_exactMainCase ?? _nearestCase)?.id;
    final sameMonthCases = onThisDayCasesForMonth(_selectedDate.month)
        .where((c) => c.id != activeId)
        .toList();
    final listCases = _otherCases.isNotEmpty
        ? _otherCases
        : (sameMonthCases.isNotEmpty
            ? sameMonthCases
            : onThisDayCases
                .where((c) => c.id != activeId)
                .take(4)
                .toList());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              sameMonthCases.isNotEmpty
                  ? '${_selectedDate.month} 月相關法治事件'
                  : '經典法治歷史館藏',
              style: t.sansTitle(size: 15.sp, weight: FontWeight.w700),
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  CupertinoPageRoute<void>(
                    builder: (__) => const OnThisDayListPage(),
                  ),
                );
              },
              child: Row(
                children: [
                  Text(
                    '查看全部',
                    style: t.sansBody(
                      size: 12.sp,
                      weight: FontWeight.w700,
                      color: t.accentBrass,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Icon(
                    PhosphorIconsRegular.caretRight,
                    size: 14.sp,
                    color: t.accentBrass,
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 112.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: listCases.length,
            separatorBuilder: (_, __) => SizedBox(width: 10.w),
            itemBuilder: (context, index) {
              final c = listCases[index];
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute<void>(
                      builder: (__) => OnThisDayDetailPage(caseId: c.id),
                    ),
                  );
                },
                child: Container(
                  width: 168.w,
                  padding: EdgeInsets.all(13.w),
                  decoration: t.cardDecoration(radius: 16.r, elevated: false),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${c.year}.${c.month.toString().padLeft(2, '0')}.${c.day.toString().padLeft(2, '0')}',
                            style: t.tabularMetric(
                              size: 11.sp,
                              weight: FontWeight.w700,
                              color: t.accentBrass,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: Text(
                              c.category,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                              style: t.sansBody(
                                size: 10.sp,
                                weight: FontWeight.w600,
                                color: t.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Expanded(
                        child: Text(
                          c.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: t.serifTitle(
                            size: 13.5.sp,
                            weight: FontWeight.w700,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _openDiscovery(String initialTab) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (__) => OnThisDayDateDiscoveryPage(initialTab: initialTab),
      ),
    );
  }
}
