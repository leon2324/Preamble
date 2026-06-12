import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/features/on_this_day/theme/on_this_day_theme.dart';

class PostageStamp extends StatelessWidget {
  const PostageStamp({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44.w,
      height: 54.h,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF5),
        border: Border.all(
          color: const Color(0xFFD9BC84),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Inner dashed border
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFFD9BC84).withValues(alpha: 0.5),
                  style: BorderStyle.solid,
                ),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'POSTAGE',
                style: TextStyle(
                  fontSize: 5.5.sp,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF8C7B6B),
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 1.h),
              Icon(
                Icons.balance_rounded,
                size: 16.sp,
                color: OnThisDayColors.primaryGreen,
              ),
              SizedBox(height: 1.h),
              Text(
                '法治歷史',
                style: TextStyle(
                  fontSize: 5.5.sp,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF8C7B6B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PostmarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF8C7B6B).withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (var i = 0; i < 3; i++) {
      final yOffset = i * 5.0;
      final path = Path()
        ..moveTo(0, 10 + yOffset)
        ..quadraticBezierTo(size.width * 0.25, yOffset, size.width * 0.5, 10 + yOffset)
        ..quadraticBezierTo(size.width * 0.75, 20 + yOffset, size.width, 10 + yOffset);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
