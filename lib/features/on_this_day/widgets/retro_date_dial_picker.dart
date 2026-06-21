import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/features/on_this_day/theme/on_this_day_theme.dart';

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

  int _daysInMonth(int month) {
    if (month == 2) return 28;
    if (month == 4 || month == 6 || month == 9 || month == 11) return 30;
    return 31;
  }

  void _onSelectionChanged() {
    final maxDays = _daysInMonth(_selectedMonth);
    if (_selectedDay > maxDays) {
      _selectedDay = maxDays;
      _dayController.jumpToItem(maxDays - 1);
    }
    widget.onDateSelected(DateTime(2026, _selectedMonth, _selectedDay));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: OnThisDayColors.paperBeige,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        border: Border.all(color: OnThisDayColors.borderLight, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
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
              // Title bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '選擇法治記憶座標',
                    style: TextStyle(
                      fontFamily: 'Songti TC',
                      fontFamilyFallback: const ['BiauKai', 'serif'],
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w900,
                      color: OnThisDayColors.primaryGreen,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      '確認',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w900,
                        color: OnThisDayColors.accentGold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              // Picker Wheels Container
              Container(
                height: 180.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFDF5),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                      color: const Color(0xFFD9BC84).withValues(alpha: 0.6)),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Selection Highlight Overlay
                    Positioned(
                      left: 10.w,
                      right: 10.w,
                      height: 40.h,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFECE0).withValues(alpha: 0.3),
                          border: const Border(
                            top: BorderSide(
                                color: OnThisDayColors.accentGold, width: 1.2),
                            bottom: BorderSide(
                                color: OnThisDayColors.accentGold, width: 1.2),
                          ),
                        ),
                      ),
                    ),

                    // Two Wheel Columns
                    Row(
                      children: [
                        // Month Dial
                        Expanded(
                          child: ListWheelScrollView.useDelegate(
                            controller: _monthController,
                            itemExtent: 40.h,
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
                                    style: TextStyle(
                                      fontFamily: 'Songti TC',
                                      fontFamilyFallback: const [
                                        'BiauKai',
                                        'serif'
                                      ],
                                      fontSize: 18.sp,
                                      fontWeight: isSelected
                                          ? FontWeight.w900
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? OnThisDayColors.primaryGreen
                                          : OnThisDayColors.textSecondary
                                              .withValues(alpha: 0.6),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        // Divider column
                        Container(
                          width: 1.w,
                          height: 140.h,
                          color: const Color(0xFFD9BC84).withValues(alpha: 0.4),
                        ),

                        // Day Dial
                        Expanded(
                          child: ListWheelScrollView.useDelegate(
                            controller: _dayController,
                            itemExtent: 40.h,
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
                                    style: TextStyle(
                                      fontFamily: 'Songti TC',
                                      fontFamilyFallback: const [
                                        'BiauKai',
                                        'serif'
                                      ],
                                      fontSize: 18.sp,
                                      fontWeight: isSelected
                                          ? FontWeight.w900
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? OnThisDayColors.primaryGreen
                                          : OnThisDayColors.textSecondary
                                              .withValues(alpha: 0.6),
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
