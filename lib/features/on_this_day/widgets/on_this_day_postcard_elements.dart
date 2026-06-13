import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/features/on_this_day/theme/on_this_day_theme.dart';

class PostageStamp extends StatelessWidget {
  const PostageStamp({
    super.key,
    this.width = 44,
    this.height = 54,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width.w, height.h),
      painter: const StampBorderPainter(
        backgroundColor: Color(0xFFFFFDF5),
        borderColor: Color(0xFFD9BC84),
        borderWidth: 1.0,
        scallopRadius: 2.0,
        scallopSpacing: 6.0,
      ),
      child: SizedBox(
        width: width.w,
        height: height.h,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Inner dashed border
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFFD9BC84).withValues(alpha: 0.4),
                    style: BorderStyle.solid,
                    width: 0.8,
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
                SizedBox(height: 2.h),
                Icon(
                  Icons.balance_rounded,
                  size: 16.sp,
                  color: OnThisDayColors.primaryGreen,
                ),
                SizedBox(height: 2.h),
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
      ),
    );
  }
}

class StampBorderPainter extends CustomPainter {
  const StampBorderPainter({
    required this.backgroundColor,
    required this.borderColor,
    this.borderWidth = 1.0,
    this.scallopRadius = 2.0,
    this.scallopSpacing = 6.0,
  });

  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final double scallopRadius;
  final double scallopSpacing;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildScallopedPath(size, scallopRadius, scallopSpacing);

    final fillPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  Path _buildScallopedPath(Size size, double scallopRadius, double spacing) {
    final path = Path();
    path.moveTo(0, 0);

    // Top Edge
    final topW = size.width;
    int numX = (topW / spacing).floor();
    if (numX < 2) numX = 2;
    double actualSpacingX = topW / numX;
    for (int i = 0; i < numX; i++) {
      double nextX = (i + 0.5) * actualSpacingX;
      path.lineTo(nextX - scallopRadius, 0);
      path.arcToPoint(
        Offset(nextX + scallopRadius, 0),
        radius: Radius.circular(scallopRadius),
        clockwise: true,
      );
    }
    path.lineTo(size.width, 0);

    // Right Edge
    final rightH = size.height;
    int numY = (rightH / spacing).floor();
    if (numY < 2) numY = 2;
    double actualSpacingY = rightH / numY;
    for (int i = 0; i < numY; i++) {
      double nextY = (i + 0.5) * actualSpacingY;
      path.lineTo(size.width, nextY - scallopRadius);
      path.arcToPoint(
        Offset(size.width, nextY + scallopRadius),
        radius: Radius.circular(scallopRadius),
        clockwise: true,
      );
    }
    path.lineTo(size.width, size.height);

    // Bottom Edge
    for (int i = numX - 1; i >= 0; i--) {
      double nextX = (i + 0.5) * actualSpacingX;
      path.lineTo(nextX + scallopRadius, size.height);
      path.arcToPoint(
        Offset(nextX - scallopRadius, size.height),
        radius: Radius.circular(scallopRadius),
        clockwise: true,
      );
    }
    path.lineTo(0, size.height);

    // Left Edge
    for (int i = numY - 1; i >= 0; i--) {
      double nextY = (i + 0.5) * actualSpacingY;
      path.lineTo(0, nextY + scallopRadius);
      path.arcToPoint(
        Offset(0, nextY - scallopRadius),
        radius: Radius.circular(scallopRadius),
        clockwise: true,
      );
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant StampBorderPainter oldDelegate) {
    return oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.scallopRadius != scallopRadius ||
        oldDelegate.scallopSpacing != scallopSpacing;
  }
}

class ProgrammaticPostmarkPainter extends CustomPainter {
  const ProgrammaticPostmarkPainter({
    required this.dateText,
    required this.locationText,
    this.categoryText = '那年今日',
    required this.color,
  });

  final String dateText;
  final String locationText;
  final String categoryText;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw wavy cancellation lines
    final paint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (var i = 0; i < 4; i++) {
      final yOffset = i * 8.0 + 8.0;
      final path = Path()
        ..moveTo(0, yOffset)
        ..quadraticBezierTo(size.width * 0.25, yOffset - 5, size.width * 0.5, yOffset)
        ..quadraticBezierTo(size.width * 0.75, yOffset + 5, size.width, yOffset);
      canvas.drawPath(path, paint);
    }

    // 2. Draw circular processing mark
    final center = Offset(size.width * 0.5, size.height * 0.5);
    final outerRadius = size.height * 0.45;
    final innerRadius = outerRadius - 3.0;

    final circlePaint = Paint()
      ..color = color.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(center, outerRadius, circlePaint);
    canvas.drawCircle(center, innerRadius, circlePaint);

    // 3. Draw top curved text: locationText
    final textStyle = TextStyle(
      fontFamily: 'Songti TC',
      fontFamilyFallback: const ['BiauKai', 'serif', 'sans-serif'],
      fontSize: 6.sp,
      fontWeight: FontWeight.w900,
      color: color.withValues(alpha: 0.4),
    );

    _drawTextOnArc(
      canvas,
      locationText,
      center,
      innerRadius - 3.0,
      0.0, // centered at 0 (top in charAngle)
      textStyle,
      true, // isUpward
    );

    // 4. Draw bottom curved text: categoryText
    _drawTextOnArc(
      canvas,
      categoryText,
      center,
      innerRadius - 3.0,
      3.14159, // centered at pi (bottom in charAngle)
      textStyle,
      false, // isUpward
    );

    // 5. Draw center straight text: dateText
    final dateStyle = TextStyle(
      fontSize: 7.sp,
      fontWeight: FontWeight.w900,
      color: color.withValues(alpha: 0.45),
      letterSpacing: 0.3,
    );
    final datePainter = TextPainter(
      text: TextSpan(text: dateText, style: dateStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    datePainter.paint(
      canvas,
      center - Offset(datePainter.width / 2, datePainter.height / 2),
    );
  }

  void _drawTextOnArc(
    Canvas canvas,
    String text,
    Offset center,
    double radius,
    double centerAngle,
    TextStyle style,
    bool isUpward,
  ) {
    final textPainters = <TextPainter>[];
    double totalWidth = 0.0;
    for (int i = 0; i < text.length; i++) {
      final tp = TextPainter(
        text: TextSpan(text: text[i], style: style),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainters.add(tp);
      totalWidth += tp.width;
    }

    final double angularWidth = totalWidth / radius;

    if (isUpward) {
      double currentAngle = centerAngle - angularWidth / 2;
      for (int i = 0; i < text.length; i++) {
        final tp = textPainters[i];
        final charAngle = currentAngle + (tp.width / 2) / radius;
        
        canvas.save();
        canvas.translate(center.dx, center.dy);
        canvas.rotate(charAngle);
        canvas.translate(0, -radius);
        tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
        canvas.restore();
        
        currentAngle += tp.width / radius;
      }
    } else {
      double currentAngle = centerAngle + angularWidth / 2;
      for (int i = 0; i < text.length; i++) {
        final tp = textPainters[i];
        final charAngle = currentAngle - (tp.width / 2) / radius;
        
        canvas.save();
        canvas.translate(center.dx, center.dy);
        canvas.rotate(charAngle);
        canvas.translate(0, radius);
        canvas.rotate(3.14159);
        tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
        canvas.restore();
        
        currentAngle -= tp.width / radius;
      }
    }
  }

  @override
  bool shouldRepaint(covariant ProgrammaticPostmarkPainter oldDelegate) {
    return oldDelegate.dateText != dateText ||
        oldDelegate.locationText != locationText ||
        oldDelegate.categoryText != categoryText ||
        oldDelegate.color != color;
  }
}
