import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/features/on_this_day/data/on_this_day_mock_data.dart';
import 'package:lawapp/features/on_this_day/models/on_this_day_models.dart';
import 'package:lawapp/features/on_this_day/theme/on_this_day_theme.dart';
import 'package:lawapp/features/on_this_day/pages/on_this_day_date_discovery_page.dart';
import 'package:lawapp/features/on_this_day/pages/on_this_day_list_page.dart';
import 'package:lawapp/features/on_this_day/pages/on_this_day_detail_page.dart';
import 'package:lawapp/features/on_this_day/widgets/on_this_day_calendar_sheet.dart';
import 'package:lawapp/features/on_this_day/widgets/on_this_day_postcard_elements.dart';
import 'package:lawapp/features/on_this_day/widgets/retro_date_dial_picker.dart';
import 'package:lawapp/features/case_time_machine/data/case_time_machine_repository.dart';
import 'package:lawapp/features/case_time_machine/pages/case_dossier_detail_page.dart';
import 'package:lawapp/features/case_time_machine/models/case_time_machine_models.dart';

class OnThisDayHomePage extends StatefulWidget {
  const OnThisDayHomePage({super.key});

  @override
  State<OnThisDayHomePage> createState() => _OnThisDayHomePageState();
}

class _OnThisDayHomePageState extends State<OnThisDayHomePage> {
  late DateTime _selectedDate;
  OnThisDayCase? _mainCase;
  List<OnThisDayCase> _otherCases = [];
  OnThisDayLegalQuote? _selectedQuote;

  late PageController _pageController;
  final DateTime _anchorDate = DateTime(2026, 4, 7);
  final int _initialPage = 10000;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime(2026, 4, 7);
    _currentPage = _initialPage;
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
    final repo = CaseTimeMachineRepository.instance;
    if (repo.cases.isEmpty) {
      await repo.initialize();
      if (mounted) {
        setState(() {}); // refresh to check dossiers
      }
    }
  }

  void _loadCasesForSelectedDate() {
    final dayCases =
        onThisDayCasesForDate(_selectedDate.month, _selectedDate.day);
    setState(() {
      if (dayCases.isNotEmpty) {
        _mainCase = dayCases.first;
        _otherCases = dayCases.skip(1).toList();
        _selectedQuote = null;
      } else {
        _mainCase = null;
        _otherCases = [];
        final index = (_selectedDate.month * 31 + _selectedDate.day) %
            onThisDayLegalQuotes.length;
        _selectedQuote = onThisDayLegalQuotes[index];
      }
    });
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
    final targetDate =
        DateTime(_anchorDate.year, randomCase.month, randomCase.day);

    setState(() {
      _selectedDate = targetDate;
      final page = _initialPage + targetDate.difference(_anchorDate).inDays;
      _currentPage = page;
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          page,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
      _loadCasesForSelectedDate();
    });
  }

  void _goToPreviousDay() {
    if (_pageController.hasClients) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  CaseBook? _findDossierSync(OnThisDayCase? mainCase) {
    if (mainCase == null) return null;
    final cases = CaseTimeMachineRepository.instance.cases;
    for (final book in cases) {
      if (book.id == mainCase.id ||
          book.titleZh.contains(mainCase.title) ||
          mainCase.title.contains(book.titleZh) ||
          (book.shortTitleZh.isNotEmpty &&
              (book.shortTitleZh.contains(mainCase.title) ||
                  mainCase.title.contains(book.shortTitleZh)))) {
        return book;
      }
    }
    return null;
  }

  void _showRetroDatePicker() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return RetroDateDialPicker(
          initialDate: _selectedDate,
          onDateSelected: (newDate) {
            setState(() {
              _selectedDate = newDate;
              final page =
                  _initialPage + newDate.difference(_anchorDate).inDays;
              _currentPage = page;
              if (_pageController.hasClients) {
                _pageController.jumpToPage(page);
              }
              _loadCasesForSelectedDate();
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OnThisDayColors.paperBeige,
      appBar: AppBar(
        backgroundColor: OnThisDayColors.paperBeige,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: OnThisDayColors.primaryGreen),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 4.h),
        physics: const BouncingScrollPhysics(),
        children: [
          // Postcard Header with Stamp & Postmarks
          Padding(
            padding: EdgeInsets.only(bottom: 20.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '那年今日',
                      style: OnThisDayTextStyles.pageTitle(context)
                          .copyWith(fontSize: 28.sp),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '法制史上的今天',
                      style: TextStyle(
                        fontFamily: 'Songti TC',
                        fontFamilyFallback: const ['BiauKai', 'serif'],
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w900,
                        color: OnThisDayColors.secondaryGreen,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: 130.w,
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
                        top: 0,
                        child: IgnorePointer(
                          child: CustomPaint(
                            size: Size(100.w, 54.h),
                            painter: ProgrammaticPostmarkPainter(
                              dateText: _mainCase != null
                                  ? '${_mainCase!.year}.${_mainCase!.month.toString().padLeft(2, '0')}.${_mainCase!.day.toString().padLeft(2, '0')}'
                                  : '${_selectedDate.year}.${_selectedDate.month.toString().padLeft(2, '0')}.${_selectedDate.day.toString().padLeft(2, '0')}',
                              locationText: _mainCase != null
                                  ? _mainCase!.location
                                  : '歷史歲月',
                              color: const Color(0xFF8C7B6B),
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
          // 0. Positioning introduction card
          _buildPositioningBanner(),
          // 1. Premium Calendar & Featured Case Card
          _buildFeaturedCaseCard(),
          SizedBox(height: 24.h),

          // 2. "今天的歷史案件" Section
          _buildTodayHistorySection(),
          SizedBox(height: 24.h),

          // 3. "依日期探索" Section
          _buildExploreByDateSection(),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildPositioningBanner() {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF6EE),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFD6C0A0), width: 1.w),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: const BoxDecoration(
              color: Color(0xFFEAF5EF),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.mark_as_unread_rounded,
              color: OnThisDayColors.primaryGreen,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '探索法治足跡，拉近法律與生活的距離',
                  style: TextStyle(
                    color: OnThisDayColors.primaryGreen,
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  '歷史是一面鏡子，每一樁法治里程碑都默默指引著現代人的生活。那年今日帶您開啟一封封歷史信札，從思辨中找尋現代法律生活的定位。',
                  style: TextStyle(
                    color: const Color(0xFF7E6E5A),
                    fontSize: 10.5.sp,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCaseCard() {
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final pageHeight =
        (textScale > 1.6 ? 410 : (textScale > 1.25 ? 350 : 255)).h;

    return SizedBox(
      height: pageHeight,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (page) {
          setState(() {
            _currentPage = page;
            _selectedDate =
                _anchorDate.add(Duration(days: page - _initialPage));
            _loadCasesForSelectedDate();
          });
        },
        itemBuilder: (context, index) {
          final date = _anchorDate.add(Duration(days: index - _initialPage));
          final dayCases = onThisDayCasesForDate(date.month, date.day);
          final mainCase = dayCases.isNotEmpty ? dayCases.first : null;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: _buildFeaturedCaseCardForDate(date, mainCase),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedCaseCardForDate(DateTime date, OnThisDayCase? mainCase) {
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final useStackedLayout = textScale > 1.25;
    final matchedBook = _findDossierSync(mainCase);

    final cardContent = useStackedLayout
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    OnThisDayCalendarSheet(
                      year: mainCase != null ? mainCase.year : date.year,
                      monthDay: '${date.month} / ${date.day}',
                      location: mainCase != null ? mainCase.location : '歷史歲月',
                    ),
                    SizedBox(height: 8.h),
                    _buildPreviousDayButton(),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              _buildFeaturedCardTextContent(date, mainCase, matchedBook),
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Vintage Calendar Card
              Column(
                children: [
                  OnThisDayCalendarSheet(
                    year: mainCase != null ? mainCase.year : date.year,
                    monthDay: '${date.month} / ${date.day}',
                    location: mainCase != null ? mainCase.location : '歷史歲月',
                  ),
                  SizedBox(height: 12.h),
                  _buildPreviousDayButton(),
                ],
              ),
              SizedBox(width: 16.w),
              // Right Column: Summary text and button
              Expanded(
                child:
                    _buildFeaturedCardTextContent(date, mainCase, matchedBook),
              ),
            ],
          );

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: OnThisDayColors.bgPaperLight,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: OnThisDayColors.borderLight, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            cardContent,
            if (mainCase != null) ...[
              SizedBox(height: 12.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9EE),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                      color: const Color(0xFFD5C3A3).withValues(alpha: 0.5)),
                ),
                child: Text(
                  '「${mainCase.quote}」',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w800,
                    fontStyle: FontStyle.italic,
                    color: const Color(0xFF6C5437),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPreviousDayButton() {
    return GestureDetector(
      onTap: _goToPreviousDay,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: OnThisDayColors.paperBeige.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: OnThisDayColors.borderLight),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.arrow_back_rounded,
                size: 10.sp, color: OnThisDayColors.secondaryGreen),
            SizedBox(width: 4.w),
            Text(
              '倒回前一天',
              style: TextStyle(
                fontSize: 9.sp,
                fontWeight: FontWeight.w800,
                color: OnThisDayColors.secondaryGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedCardTextContent(
      DateTime date, OnThisDayCase? mainCase, CaseBook? matchedBook) {
    final hasDossier = matchedBook != null;

    if (mainCase != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            mainCase.title,
            style: OnThisDayTextStyles.titleSerif(context).copyWith(
              fontSize: 18.sp,
              height: 1.2,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            mainCase.summary,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: OnThisDayTextStyles.body(context).copyWith(
              fontSize: 11.5.sp,
              height: 1.5,
            ),
          ),
          SizedBox(height: 14.h),
          GestureDetector(
            onTap: () {
              if (hasDossier) {
                Navigator.of(context).push(
                  CupertinoPageRoute<void>(
                    builder: (__) => CaseDossierDetailPage(book: matchedBook),
                  ),
                );
              } else {
                Navigator.of(context).push(
                  CupertinoPageRoute<void>(
                    builder: (__) => OnThisDayDetailPage(caseId: mainCase.id),
                  ),
                );
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: OnThisDayColors.primaryGreen,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    hasDossier ? '調閱法治卷宗' : '回到那一天',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w900,
                      color: OnThisDayColors.bgPaperLight,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 11.sp,
                    color: OnThisDayColors.bgPaperLight,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      final index = (date.month * 31 + date.day) % onThisDayLegalQuotes.length;
      final quoteItem = onThisDayLegalQuotes[index];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.format_quote_rounded,
                  color: OnThisDayColors.accentGold, size: 16.sp),
              SizedBox(width: 4.w),
              Text(
                '思辨格言',
                style: TextStyle(
                  fontFamily: 'Songti TC',
                  fontFamilyFallback: const ['BiauKai', 'serif'],
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w900,
                  color: OnThisDayColors.secondaryGreen,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            '「${quoteItem.quote}」',
            style: TextStyle(
              fontFamily: 'Songti TC',
              fontFamilyFallback: const ['BiauKai', 'serif'],
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              height: 1.4,
              color: const Color(0xFF6C5437),
            ),
          ),
          SizedBox(height: 4.h),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '—— ${quoteItem.author}',
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w800,
                color: OnThisDayColors.textSecondary,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '思辨問題：${quoteItem.reflectiveQuestion}',
            style: TextStyle(
              fontSize: 10.5.sp,
              height: 1.4,
              color: OnThisDayColors.textSecondary,
            ),
          ),
          SizedBox(height: 12.h),
          GestureDetector(
            onTap: _timeTravel,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: OnThisDayColors.accentGold,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: OnThisDayColors.accentGold.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '歷史時空漫遊 🃏',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w900,
                      color: OnThisDayColors.bgPaperLight,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.casino_outlined,
                    size: 11.sp,
                    color: OnThisDayColors.bgPaperLight,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }
  }

  // Removed internal _buildCalendarSheet to use the shared OnThisDayCalendarSheet widget

  Widget _buildTodayHistorySection() {
    // Other cases happening on this day
    final listCases = _otherCases.isNotEmpty
        ? _otherCases
        : onThisDayCases.where((c) => c.id != _mainCase?.id).take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '今天的歷史案件',
              style: OnThisDayTextStyles.cardTitle(context)
                  .copyWith(fontSize: 15.sp),
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
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w800,
                      color: OnThisDayColors.accentGold,
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      size: 14.sp, color: OnThisDayColors.accentGold),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 90.h,
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
                  width: 140.w,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: OnThisDayColors.bgCream.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: OnThisDayColors.borderLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${c.year}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w900,
                          color: OnThisDayColors.accentGold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Expanded(
                        child: Text(
                          c.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w800,
                            color: OnThisDayColors.primaryGreen,
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

  Widget _buildExploreByDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '依日期探索',
          style:
              OnThisDayTextStyles.cardTitle(context).copyWith(fontSize: 15.sp),
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildExplorePill('今天',
                isSelected: _selectedDate.month == 4 && _selectedDate.day == 7,
                onTap: () {
              setState(() {
                _selectedDate = DateTime(2026, 4, 7);
                final page =
                    _initialPage + _selectedDate.difference(_anchorDate).inDays;
                _currentPage = page;
                if (_pageController.hasClients) {
                  _pageController.jumpToPage(page);
                }
                _loadCasesForSelectedDate();
              });
            }),
            _buildExplorePill('本月', onTap: () => _openDiscovery('本月')),
            _buildExplorePill('今年', onTap: () => _openDiscovery('今年')),
            _buildExplorePill('重大事件', onTap: () => _openDiscovery('重大事件')),
            GestureDetector(
              onTap: _showRetroDatePicker,
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: OnThisDayColors.bgPaperLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: OnThisDayColors.borderLight),
                ),
                child: Icon(
                  Icons.calendar_today_rounded,
                  size: 16.sp,
                  color: OnThisDayColors.primaryGreen,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExplorePill(String label,
      {bool isSelected = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? OnThisDayColors.primaryGreen
              : OnThisDayColors.bgPaperLight,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected
                ? OnThisDayColors.primaryGreen
                : OnThisDayColors.borderLight,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5.sp,
            fontWeight: FontWeight.w900,
            color: isSelected
                ? OnThisDayColors.bgPaperLight
                : OnThisDayColors.textSecondary,
          ),
        ),
      ),
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
