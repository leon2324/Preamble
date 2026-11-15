import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:preamble/features/on_this_day/data/on_this_day_mock_data.dart';
import 'package:preamble/features/on_this_day/models/on_this_day_models.dart';
import 'package:preamble/features/on_this_day/pages/on_this_day_detail_page.dart';
import 'package:preamble/theme/preamble_tokens.dart';

class OnThisDayDateDiscoveryPage extends StatefulWidget {
  const OnThisDayDateDiscoveryPage({super.key, this.initialTab = '全部'});

  final String initialTab;

  @override
  State<OnThisDayDateDiscoveryPage> createState() =>
      _OnThisDayDateDiscoveryPageState();
}

class _OnThisDayDateDiscoveryPageState
    extends State<OnThisDayDateDiscoveryPage> {
  static const List<String> _modes = ['全部', '本月', '今年', '重大事件'];

  late String _activeMode;
  late int _selectedMonth;
  late int _selectedDay;
  List<OnThisDayCase> _discoveredCases = [];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = now.month;
    _selectedDay = now.day;
    _activeMode = _modes.contains(widget.initialTab) ? widget.initialTab : '全部';
    _loadDiscoveredCases();
  }

  void _loadDiscoveredCases() {
    final nowYear = DateTime.now().year;
    setState(() {
      switch (_activeMode) {
        case '本月':
          _discoveredCases = onThisDayCasesForMonth(_selectedMonth);
          break;
        case '今年':
          final sorted = [...onThisDayCases]..sort((a, b) {
              final aMod = (nowYear - a.year) % 5 == 0 ? 0 : 1;
              final bMod = (nowYear - b.year) % 5 == 0 ? 0 : 1;
              if (aMod != bMod) return aMod.compareTo(bMod);
              return a.year.compareTo(b.year);
            });
          _discoveredCases = sorted;
          break;
        case '重大事件':
          _discoveredCases = onThisDayCases
              .where((c) =>
                  c.tags.contains('人權里程碑') ||
                  c.category == '民主運動' ||
                  c.category == '言論自由' ||
                  c.category == '司法爭議')
              .toList();
          break;
        case '全部':
        default:
          _discoveredCases =
              onThisDayCasesForDate(_selectedMonth, _selectedDay);
          break;
      }
    });
  }

  void _goToPreviousDay() {
    final year = DateTime.now().year;
    final prevDate = DateTime(year, _selectedMonth, _selectedDay)
        .subtract(const Duration(days: 1));
    setState(() {
      _selectedMonth = prevDate.month;
      _selectedDay = prevDate.day;
      _activeMode = '全部';
    });
    _loadDiscoveredCases();
  }

  void _goToNextDay() {
    final year = DateTime.now().year;
    final nextDate = DateTime(year, _selectedMonth, _selectedDay)
        .add(const Duration(days: 1));
    setState(() {
      _selectedMonth = nextDate.month;
      _selectedDay = nextDate.day;
      _activeMode = '全部';
    });
    _loadDiscoveredCases();
  }

  Future<void> _selectCustomDate(BuildContext context) async {
    final t = context.tokens;
    final year = DateTime.now().year;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(year, _selectedMonth, _selectedDay),
      firstDate: DateTime(year, 1, 1),
      lastDate: DateTime(year, 12, 31),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: t.isDark
                ? ColorScheme.dark(
                    primary: t.brandPrimary,
                    onPrimary: t.brandOnPrimary,
                    surface: t.surfaceElevated,
                    onSurface: t.textPrimary,
                  )
                : ColorScheme.light(
                    primary: t.brandPrimary,
                    onPrimary: t.brandOnPrimary,
                    surface: t.surfaceElevated,
                    onSurface: t.textPrimary,
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
        _activeMode = '全部';
      });
      _loadDiscoveredCases();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

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
        title: Text(
          '法治記憶探索',
          style: t.serifTitle(size: 19.sp, weight: FontWeight.w800),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 38.h,
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              scrollDirection: Axis.horizontal,
              itemCount: _modes.length,
              separatorBuilder: (_, __) => SizedBox(width: 8.w),
              itemBuilder: (context, index) {
                final mode = _modes[index];
                final label = switch (mode) {
                  '全部' => '指定日期',
                  '本月' => '$_selectedMonth 月事件',
                  '今年' => '週年回顧',
                  '重大事件' => '重大憲政',
                  _ => mode,
                };
                final isSelected = _activeMode == mode;
                return GestureDetector(
                  onTap: () {
                    setState(() => _activeMode = mode);
                    _loadDiscoveredCases();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 6.h,
                    ),
                    alignment: Alignment.center,
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
                        color: isSelected
                            ? const Color(0xFFFAF8F4)
                            : t.textSecondary,
                        height: 1.2,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 12.h),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: t.cardDecoration(radius: 16.r, elevated: false),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(
                    PhosphorIconsRegular.caretLeft,
                    color: t.brandPrimary,
                    size: 18.sp,
                  ),
                  onPressed: _goToPreviousDay,
                ),
                GestureDetector(
                  onTap: () => _selectCustomDate(context),
                  child: Row(
                    children: [
                      Text(
                        '$_selectedMonth 月 $_selectedDay 日',
                        style: t.serifTitle(
                          size: 17.5.sp,
                          weight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(
                        PhosphorIconsRegular.calendarBlank,
                        size: 16.sp,
                        color: t.accentBrass,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    PhosphorIconsRegular.caretRight,
                    color: t.brandPrimary,
                    size: 18.sp,
                  ),
                  onPressed: _goToNextDay,
                ),
              ],
            ),
          ),
          Expanded(
            child: _discoveredCases.isNotEmpty
                ? ListView.separated(
                    padding: EdgeInsets.fromLTRB(18.w, 4.h, 18.w, 28.h),
                    itemCount: _discoveredCases.length,
                    separatorBuilder: (_, __) => SizedBox(height: 12.h),
                    itemBuilder: (context, index) =>
                        _buildCaseCard(t, _discoveredCases[index]),
                  )
                : _buildEmptyState(t),
          ),
        ],
      ),
    );
  }

  Widget _buildCaseCard(PreambleTokens t, OnThisDayCase c) {
    final yearsAgo = DateTime.now().year - c.year;
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          CupertinoPageRoute<void>(
            builder: (__) => OnThisDayDetailPage(caseId: c.id),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: t.cardDecoration(radius: 18.r, elevated: false),
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
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: t.accentBrassContainer,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          '${c.fullDateLabel} · $yearsAgo 週年',
                          style: t.tabularMetric(
                            size: 10.5.sp,
                            weight: FontWeight.w700,
                            color: t.accentOnBrassContainer,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        c.category,
                        style: t.sansBody(
                          size: 11.sp,
                          weight: FontWeight.w600,
                          color: t.textMuted,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    c.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.serifTitle(
                      size: 15.5.sp,
                      weight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    c.summary,
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
            SizedBox(width: 12.w),
            Icon(
              PhosphorIconsRegular.caretRight,
              size: 18.sp,
              color: t.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(PreambleTokens t) {
    final nearest =
        onThisDayNearestCaseForDate(_selectedMonth, _selectedDay);
    final recommendations = [
      if (nearest != null) nearest,
      ...onThisDayCases.where((c) => c.id != nearest?.id).take(2),
    ];

    return ListView(
      padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 28.h),
      physics: const BouncingScrollPhysics(),
      children: [
        Container(
          padding: EdgeInsets.all(18.w),
          decoration: t.subtleBoxDecoration(radius: 16.r),
          child: Column(
            children: [
              Icon(
                PhosphorIconsRegular.clockCounterClockwise,
                size: 36.sp,
                color: t.accentBrass,
              ),
              SizedBox(height: 10.h),
              Text(
                _activeMode == '本月'
                    ? '$_selectedMonth 月尚無載錄事件，為您推薦鄰近法治里程碑'
                    : '$_selectedMonth 月 $_selectedDay 日尚無正日事件，為您標記鄰近歷史記憶',
                textAlign: TextAlign.center,
                style: t.sansTitle(size: 13.5.sp, weight: FontWeight.w700),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        ...recommendations.map(
          (c) => Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: _buildCaseCard(t, c),
          ),
        ),
      ],
    );
  }
}
