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

class OnThisDayHomePage extends StatefulWidget {
  const OnThisDayHomePage({super.key});

  @override
  State<OnThisDayHomePage> createState() => _OnThisDayHomePageState();
}

class _OnThisDayHomePageState extends State<OnThisDayHomePage> {
  late DateTime _selectedDate;
  OnThisDayCase? _mainCase;
  List<OnThisDayCase> _otherCases = [];

  @override
  void initState() {
    super.initState();
    // Default to April 7th for demonstration (Zheng Nan-rong Event)
    _selectedDate = DateTime(2026, 4, 7);
    _loadCasesForSelectedDate();
  }

  void _loadCasesForSelectedDate() {
    final dayCases = onThisDayCasesForDate(_selectedDate.month, _selectedDate.day);
    setState(() {
      if (dayCases.isNotEmpty) {
        _mainCase = dayCases.first;
        _otherCases = dayCases.skip(1).toList();
      } else {
        _mainCase = null;
        _otherCases = [];
      }
    });
  }

  void _goToPreviousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
      _loadCasesForSelectedDate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OnThisDayColors.paperBeige,
      appBar: AppBar(
        backgroundColor: OnThisDayColors.paperBeige,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: OnThisDayColors.primaryGreen),
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
                      style: OnThisDayTextStyles.pageTitle(context).copyWith(fontSize: 28.sp),
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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomPaint(
                      size: Size(54.w, 20.h),
                      painter: PostmarkPainter(),
                    ),
                    SizedBox(width: 4.w),
                    const PostageStamp(),
                  ],
                ),
              ],
            ),
          ),
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

  Widget _buildFeaturedCaseCard() {
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
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Vintage Calendar Card
              Column(
                children: [
                  OnThisDayCalendarSheet(
                    year: _mainCase != null ? _mainCase!.year : _selectedDate.year,
                    monthDay: '${_selectedDate.month} / ${_selectedDate.day}',
                    location: _mainCase != null ? _mainCase!.location : '歷史歲月',
                  ),
                  SizedBox(height: 12.h),
                  GestureDetector(
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
                          Icon(Icons.arrow_back_rounded, size: 10.sp, color: OnThisDayColors.secondaryGreen),
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
                  ),
                ],
              ),
              SizedBox(width: 16.w),

              // Right Column: Summary text and button
              Expanded(
                child: _mainCase != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _mainCase!.title,
                            style: OnThisDayTextStyles.titleSerif(context).copyWith(
                              fontSize: 18.sp,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            _mainCase!.summary,
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
                              Navigator.of(context).push(
                                CupertinoPageRoute<void>(
                                  builder: (__) => OnThisDayDetailPage(caseId: _mainCase!.id),
                                ),
                              );
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
                                    '回到那一天',
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
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '今日無大事',
                            style: OnThisDayTextStyles.titleSerif(context).copyWith(
                              fontSize: 18.sp,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            '在這一天歷史上暫無收錄的重大案件整理。您可以點擊「倒回前一天」或「依日期探索」查詢其他日期。',
                            style: OnThisDayTextStyles.body(context).copyWith(
                              fontSize: 11.5.sp,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
          if (_mainCase != null) ...[
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9EE),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFD5C3A3).withValues(alpha: 0.5)),
              ),
              child: Text(
                '「${_mainCase!.quote}」',
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
    );
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
              style: OnThisDayTextStyles.cardTitle(context).copyWith(fontSize: 15.sp),
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
                  Icon(Icons.chevron_right_rounded, size: 14.sp, color: OnThisDayColors.accentGold),
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
          style: OnThisDayTextStyles.cardTitle(context).copyWith(fontSize: 15.sp),
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildExplorePill('今天', isSelected: true, onTap: () {
              setState(() {
                _selectedDate = DateTime(2026, 4, 7);
                _loadCasesForSelectedDate();
              });
            }),
            _buildExplorePill('本月', onTap: () => _openDiscovery('本月')),
            _buildExplorePill('今年', onTap: () => _openDiscovery('今年')),
            _buildExplorePill('重大事件', onTap: () => _openDiscovery('重大事件')),
            GestureDetector(
              onTap: () => _openDiscovery('全部'),
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

  Widget _buildExplorePill(String label, {bool isSelected = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? OnThisDayColors.primaryGreen : OnThisDayColors.bgPaperLight,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? OnThisDayColors.primaryGreen : OnThisDayColors.borderLight,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5.sp,
            fontWeight: FontWeight.w900,
            color: isSelected ? OnThisDayColors.bgPaperLight : OnThisDayColors.textSecondary,
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
