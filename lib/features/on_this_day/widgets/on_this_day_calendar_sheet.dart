import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/features/on_this_day/theme/on_this_day_theme.dart';

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
    return SizedBox(
      width: width.w,
      height: height.h,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Stacked page shadows
          Positioned(
            left: 5.w,
            right: 0.w,
            bottom: -4.h,
            top: 10.h,
            child: _buildShadowSheet(const Color(0xFFE4C995), -0.04),
          ),
          Positioned(
            left: 2.w,
            right: 2.w,
            bottom: -2.h,
            top: 5.h,
            child: _buildShadowSheet(const Color(0xFFECD7AE), -0.02),
          ),
          // Main sheet
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFFFCF7),
                    Color(0xFFFBF1D8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: const Color(0xFFD9BC84),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFCFAE71).withValues(alpha: 0.16),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _CalendarDividerPainter(),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 10.h),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '$year',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF6A5842),
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const Spacer(),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            monthDay,
                            style: TextStyle(
                              fontSize: 24.sp,
                              height: 1.0,
                              fontWeight: FontWeight.w900,
                              color: OnThisDayColors.primaryGreen,
                            ),
                          ),
                        ),
                        const Spacer(),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF6A5842),
                            ),
                          ),
                        ),
                        SizedBox(height: 4.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Binder rings
          Positioned(
            top: -6.h,
            left: 16.w,
            child: const _BinderRing(),
          ),
          Positioned(
            top: -6.h,
            right: 16.w,
            child: const _BinderRing(),
          ),
        ],
      ),
    );
  }

  Widget _buildShadowSheet(Color color, double rotation) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: const Color(0xFFD0B27B).withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }
}

class _CalendarDividerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final dividerY = size.height * 0.42;
    final linePaint = Paint()
      ..color = const Color(0xFFD9C49A).withValues(alpha: 0.8)
      ..strokeWidth = 1.0;
    canvas.drawLine(
      Offset(12.w, dividerY),
      Offset(size.width - 12.w, dividerY),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BinderRing extends StatelessWidget {
  const _BinderRing();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 14.w,
      height: 32.h,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: 10.w,
            height: 28.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999.r),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFE2C987),
                  Color(0xFF9E7733),
                  Color(0xFFE2C987),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 3,
                  offset: const Offset(0, 1.5),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(2.w),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF7E8),
                  borderRadius: BorderRadius.circular(999.r),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 2.h,
            child: Container(
              width: 14.w,
              height: 8.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF86642C).withValues(alpha: 0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
