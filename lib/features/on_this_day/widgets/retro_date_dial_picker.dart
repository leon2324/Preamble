import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/theme/preamble_tokens.dart';

class RetroDateDialPicker extends StatefulWidget {
  const RetroDateDialPicker({
    super.key,
    required this.initialDate,
    required this.onDateSelected,
  });

  final DateTime initialDate;
  final ValueChanged<DateTime> onDateSelected;

  @override
  State<RetroDateDialPicker> createState() => _RetroDateDialPickerState();
}

class _RetroDateDialPickerState extends State<RetroDateDialPicker> {
  late int _selectedMonth;
  late int _selectedDay;
  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _dayController;

  @override
  void initState() {
    super.initState();
    _selectedMonth = widget.initialDate.month;
    _selectedDay = widget.initialDate.day;
    _monthController =
        FixedExtentScrollController(initialItem: _selectedMonth - 1);
    _dayController = FixedExtentScrollController(initialItem: _selectedDay - 1);
  }

  @override
  void dispose() {
    _monthController.dispose();
    _dayController.dispose();
    super.dispose();
  }

  bool _isLeapYear(int year) =>
      (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);

  int _daysInMonth(int month) {
    final year = DateTime.now().year;
    if (month == 2) return _isLeapYear(year) ? 29 : 28;
    if (month == 4 || month == 6 || month == 9 || month == 11) return 30;
    return 31;
  }

  void _onSelectionChanged() {
    final maxDays = _daysInMonth(_selectedMonth);
    if (_selectedDay > maxDays) {
      _selectedDay = maxDays;
      _dayController.jumpToItem(maxDays - 1);
    }
    final year = DateTime.now().year;
    widget.onDateSelected(DateTime(year, _selectedMonth, _selectedDay));
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return Container(
      decoration: BoxDecoration(
        color: t.surfaceElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        border: Border.all(color: t.borderStrong, width: 1),
        boxShadow: [
          BoxShadow(
            color: t.shadowAmbient,
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 14.h),
                decoration: BoxDecoration(
                  color: t.borderStrong,
                  borderRadius: BorderRadius.circular(999.r),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '選擇法治記憶座標',
                    style: t.serifTitle(size: 16.5.sp, weight: FontWeight.w700),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      '確認',
                      style: t.sansTitle(
                        size: 14.sp,
                        weight: FontWeight.w700,
                        color: t.accentBrass,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              Container(
                height: 180.h,
                decoration: t.subtleBoxDecoration(radius: 16.r),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      left: 10.w,
                      right: 10.w,
                      height: 42.h,
                      child: Container(
                        decoration: BoxDecoration(
                          color: t.accentBrassContainer.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.symmetric(
                            horizontal: BorderSide(
                              color: t.accentBrass.withValues(alpha: 0.65),
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ListWheelScrollView.useDelegate(
                            controller: _monthController,
                            itemExtent: 42.h,
                            perspective: 0.005,
                            diameterRatio: 1.5,
                            physics: const FixedExtentScrollPhysics(),
                            onSelectedItemChanged: (index) {
                              setState(() {
                                _selectedMonth = index + 1;
                              });
                              _onSelectionChanged();
                            },
                            childDelegate: ListWheelChildBuilderDelegate(
                              childCount: 12,
                              builder: (context, index) {
                                final month = index + 1;
                                final isSelected = month == _selectedMonth;
                                return Center(
                                  child: Text(
                                    '$month 月',
                                    style: t.serifTitle(
                                      size: 18.sp,
                                      weight: isSelected
                                          ? FontWeight.w800
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? t.brandPrimary
                                          : t.textMuted,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 132.h,
                          color: t.border,
                        ),
                        Expanded(
                          child: ListWheelScrollView.useDelegate(
                            controller: _dayController,
                            itemExtent: 42.h,
                            perspective: 0.005,
                            diameterRatio: 1.5,
                            physics: const FixedExtentScrollPhysics(),
                            onSelectedItemChanged: (index) {
                              setState(() {
                                _selectedDay = index + 1;
                              });
                              _onSelectionChanged();
                            },
                            childDelegate: ListWheelChildBuilderDelegate(
                              childCount: _daysInMonth(_selectedMonth),
                              builder: (context, index) {
                                final day = index + 1;
                                final isSelected = day == _selectedDay;
                                return Center(
                                  child: Text(
                                    '$day 日',
                                    style: t.serifTitle(
                                      size: 18.sp,
                                      weight: isSelected
                                          ? FontWeight.w800
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? t.brandPrimary
                                          : t.textMuted,
                                    ),
                                  ),
                                );
                              },
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
        ),
      ),
    );
  }
}
