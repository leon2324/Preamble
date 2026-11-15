import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:preamble/theme/preamble_tokens.dart';

class PostageStamp extends StatelessWidget {
  const PostageStamp({
    super.key,
    this.width = 46,
    this.height = 56,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return CustomPaint(
      size: Size(width.w, height.h),
      painter: StampBorderPainter(
        backgroundColor: t.surface,
        borderColor: t.accentBrass.withValues(alpha: 0.65),
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
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: t.accentBrass.withValues(alpha: 0.35),
                    width: 0.8,
                  ),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'ARCHIVE',
                  style: t.tabularMetric(
                    size: 5.5.sp,
                    weight: FontWeight.w700,
                    color: t.textMuted,
                  ),
                ),
                SizedBox(height: 2.h),
                Icon(
                  PhosphorIconsRegular.scales,
                  size: 16.sp,
                  color: t.brandPrimary,
                ),
                SizedBox(height: 2.h),
                Text(
                  '法治記憶',
                  style: t.sansBody(
                    size: 5.8.sp,
                    weight: FontWeight.w700,
                    color: t.accentBrass,
                    height: 1.1,
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

    final topW = size.width;
    int numX = (topW / spacing).floor();
    if (numX < 2) numX = 2;
    final double actualSpacingX = topW / numX;
    for (int i = 0; i < numX; i++) {
      final double nextX = (i + 0.5) * actualSpacingX;
      path.lineTo(nextX - scallopRadius, 0);
      path.arcToPoint(
        Offset(nextX + scallopRadius, 0),
        radius: Radius.circular(scallopRadius),
        clockwise: true,
      );
    }
    path.lineTo(size.width, 0);

    final rightH = size.height;
    int numY = (rightH / spacing).floor();
    if (numY < 2) numY = 2;
    final double actualSpacingY = rightH / numY;
    for (int i = 0; i < numY; i++) {
      final double nextY = (i + 0.5) * actualSpacingY;
      path.lineTo(size.width, nextY - scallopRadius);
      path.arcToPoint(
        Offset(size.width, nextY + scallopRadius),
        radius: Radius.circular(scallopRadius),
        clockwise: true,
      );
    }
    path.lineTo(size.width, size.height);

    for (int i = numX - 1; i >= 0; i--) {
      final double nextX = (i + 0.5) * actualSpacingX;
      path.lineTo(nextX + scallopRadius, size.height);
      path.arcToPoint(
        Offset(nextX - scallopRadius, size.height),
        radius: Radius.circular(scallopRadius),
        clockwise: true,
      );
    }
    path.lineTo(0, size.height);

    for (int i = numY - 1; i >= 0; i--) {
      final double nextY = (i + 0.5) * actualSpacingY;
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
    final paint = Paint()
      ..color = color.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (var i = 0; i < 4; i++) {
      final yOffset = i * 8.0 + 8.0;
      final path = Path()
        ..moveTo(0, yOffset)
        ..quadraticBezierTo(
            size.width * 0.25, yOffset - 5, size.width * 0.5, yOffset)
        ..quadraticBezierTo(
            size.width * 0.75, yOffset + 5, size.width, yOffset);
      canvas.drawPath(path, paint);
    }

    final center = Offset(size.width * 0.5, size.height * 0.5);
    final outerRadius = size.height * 0.45;
    final innerRadius = outerRadius - 3.0;

    final circlePaint = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(center, outerRadius, circlePaint);
    canvas.drawCircle(center, innerRadius, circlePaint);

    final textStyle = TextStyle(
      fontSize: 6.sp,
      fontWeight: FontWeight.w800,
      color: color.withValues(alpha: 0.55),
    );

    _drawTextOnArc(
      canvas,
      locationText,
      center,
      innerRadius - 3.0,
      0.0,
      textStyle,
      true,
    );

    _drawTextOnArc(
      canvas,
      categoryText,
      center,
      innerRadius - 3.0,
      3.14159,
      textStyle,
      false,
    );

    final dateStyle = TextStyle(
      fontSize: 7.sp,
      fontWeight: FontWeight.w800,
      color: color.withValues(alpha: 0.65),
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
