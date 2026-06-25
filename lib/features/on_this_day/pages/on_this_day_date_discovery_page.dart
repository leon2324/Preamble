import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/features/on_this_day/data/on_this_day_mock_data.dart';
import 'package:lawapp/features/on_this_day/models/on_this_day_models.dart';
import 'package:lawapp/features/on_this_day/theme/on_this_day_theme.dart';
import 'package:lawapp/features/on_this_day/pages/on_this_day_detail_page.dart';

class OnThisDayDateDiscoveryPage extends StatefulWidget {
  const OnThisDayDateDiscoveryPage({super.key, this.initialTab = '全部'});

  final String initialTab;

  @override
  State<OnThisDayDateDiscoveryPage> createState() =>
      _OnThisDayDateDiscoveryPageState();
}

class _OnThisDayDateDiscoveryPageState
    extends State<OnThisDayDateDiscoveryPage> {
  late int _selectedMonth;
  late int _selectedDay;
  List<OnThisDayCase> _discoveredCases = [];

  @override
  void initState() {
    super.initState();
    // Default starting date: April 7th
    _selectedMonth = 4;
    _selectedDay = 7;
    _loadDiscoveredCases();
  }

  void _loadDiscoveredCases() {
    setState(() {
      _discoveredCases = onThisDayCasesForDate(_selectedMonth, _selectedDay);
    });
  }

  void _goToPreviousDay() {
    setState(() {
      final prevDate = DateTime(2026, _selectedMonth, _selectedDay)
          .subtract(const Duration(days: 1));
      _selectedMonth = prevDate.month;
      _selectedDay = prevDate.day;
      _loadDiscoveredCases();
    });
  }

  void _goToNextDay() {
    setState(() {
      final nextDate = DateTime(2026, _selectedMonth, _selectedDay)
          .add(const Duration(days: 1));
      _selectedMonth = nextDate.month;
      _selectedDay = nextDate.day;
      _loadDiscoveredCases();
    });
  }

  Future<void> _selectCustomDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2026, _selectedMonth, _selectedDay),
      firstDate: DateTime(2026, 1, 1),
      lastDate: DateTime(2026, 12, 31),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: OnThisDayColors.primaryGreen,
              onPrimary: Colors.white,
              onSurface: OnThisDayColors.textPrimary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                  foregroundColor: OnThisDayColors.primaryGreen),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedMonth = picked.month;
        _selectedDay = picked.day;
        _loadDiscoveredCases();
      });
    }
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
        title: Text(
          '日期探索',
          style:
              OnThisDayTextStyles.pageTitle(context).copyWith(fontSize: 20.sp),
        ),
      ),
      body: Column(
        children: [
          // Date Selector Header
          Container(
            margin: EdgeInsets.all(18.w),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: OnThisDayColors.bgCream.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: OnThisDayColors.borderLight),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded,
                      color: OnThisDayColors.primaryGreen),
                  onPressed: _goToPreviousDay,
                ),
                GestureDetector(
                  onTap: () => _selectCustomDate(context),
                  child: Row(
                    children: [
                      Text(
                        '$_selectedMonth月$_selectedDay日',
                        style: OnThisDayTextStyles.titleSerif(context).copyWith(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 16.sp,
                        color: OnThisDayColors.accentGold,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios_rounded,
                      color: OnThisDayColors.primaryGreen),
                  onPressed: _goToNextDay,
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '在 $_selectedMonth月$_selectedDay日 發生的重要事件',
                style: OnThisDayTextStyles.caption(context).copyWith(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),

          // Discovered cases list
          Expanded(
            child: _discoveredCases.isNotEmpty
                ? ListView.separated(
                    padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 24.h),
                    itemCount: _discoveredCases.length,
                    separatorBuilder: (_, __) => SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      final c = _discoveredCases[index];
                      return _buildCaseCard(c);
                    },
                  )
                : _buildEmptyState(),
          ),
        ],
      ),
    );
  }

  Widget _buildCaseCard(OnThisDayCase c) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: OnThisDayColors.bgPaperLight,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: OnThisDayColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color:
                            OnThisDayColors.accentGold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        '${c.year}',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w900,
                          color: OnThisDayColors.accentGold,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        c.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: OnThisDayTextStyles.cardTitle(context).copyWith(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Text(
                  c.summary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: OnThisDayTextStyles.body(context).copyWith(
                    fontSize: 11.5.sp,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 14.w),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: OnThisDayColors.primaryGreen,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
            onPressed: () {
              Navigator.of(context).push(
                CupertinoPageRoute<void>(
                  builder: (__) => OnThisDayDetailPage(caseId: c.id),
                ),
              );
            },
            child: Text(
              '查看案件',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w900,
                color: OnThisDayColors.bgPaperLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    // Show some random cases as recommended historical events
    final recommendations = onThisDayCases.take(3).toList();

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      physics: const BouncingScrollPhysics(),
      children: [
        SizedBox(height: 32.h),
        Center(
          child: Column(
            children: [
              Icon(
                Icons.history_toggle_off_rounded,
                size: 64.sp,
                color: OnThisDayColors.borderLight,
              ),
              SizedBox(height: 16.h),
              Text(
                '在此日期無歷史案件記錄',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w900,
                  color: OnThisDayColors.textSecondary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                '推薦您查看其他重大歷史案件：',
                style: OnThisDayTextStyles.caption(context)
                    .copyWith(fontSize: 11.sp),
              ),
            ],
          ),
        ),
        SizedBox(height: 24.h),
        ...recommendations.map((c) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: _buildCaseCard(c),
            )),
      ],
    );
  }
}
