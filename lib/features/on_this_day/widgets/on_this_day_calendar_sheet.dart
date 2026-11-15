import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/theme/preamble_tokens.dart';

/// 靜奢數位典藏曆牌（取代舊版 3D 金屬活頁孔環）。
class OnThisDayCalendarSheet extends StatelessWidget {
  const OnThisDayCalendarSheet({
    super.key,
    required this.year,
    required this.monthDay,
    required this.location,
    this.width = 100,
    this.height = 120,
  });

  final int year;
  final String monthDay;
  final String location;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return Container(
      width: width.w,
      height: height.h,
      decoration: BoxDecoration(
        color: t.surfaceSubtle,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: t.accentBrass.withValues(alpha: 0.42),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: t.brandPrimaryStrong,
              borderRadius: BorderRadius.vertical(top: Radius.circular(15.r)),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '$year',
                style: t.tabularMetric(
                  size: 11.sp,
                  weight: FontWeight.w700,
                  color: const Color(0xFFFAF8F4),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      monthDay,
                      style: t.serifTitle(
                        size: 22.sp,
                        weight: FontWeight.w800,
                        height: 1.05,
                        color: t.brandPrimary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: double.infinity,
                    height: 1,
                    color: t.border,
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.sansBody(
                      size: 9.5.sp,
                      weight: FontWeight.w600,
                      color: t.textSecondary,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
