import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class JournalHeroIllustration extends StatelessWidget {
  const JournalHeroIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _JournalHeroIllustrationPainter(),
      size: Size(184.w, 176.h),
    );
  }
}

class JournalTimeMachineIllustration extends StatelessWidget {
  const JournalTimeMachineIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _JournalTimeMachineIllustrationPainter(),
      size: Size(178.w, 134.h),
    );
  }
}

class JournalPortraitIllustration extends StatelessWidget {
  const JournalPortraitIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _JournalPortraitIllustrationPainter(),
      size: Size(102.w, 92.h),
    );
  }
}

class _JournalHeroIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 這裡先用 CustomPaint 模擬 prototype 的資料館主視覺；未來若有正式插圖，
    // 可把這個 widget 換成 Image.asset，而其他頁面版型不需要重寫。
    final mint = Paint()
      ..color = const Color(0xFFCBE9DE).withValues(alpha: 0.76);
    final deepGreen = const Color(0xFF215C52);
    final line = Paint()
      ..color = const Color(0xFF7BAFA4).withValues(alpha: 0.68)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    final ink = Paint()
      ..color = deepGreen.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;
    final parchment = Paint()..color = const Color(0xFFF7F2E2);
    final parchmentShade = Paint()
      ..color = const Color(0xFFE8DDC2).withValues(alpha: 0.7);
    final bookShade = Paint()
      ..color = const Color(0xFF6E8B73).withValues(alpha: 0.7);

    final arch = Path()
      ..moveTo(size.width * 0.18, size.height)
      ..cubicTo(size.width * 0.32, size.height * 0.74, size.width * 0.48,
          size.height * 0.36, size.width * 0.78, size.height * 0.2)
      ..lineTo(size.width, size.height * 0.15)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(arch, mint);

    for (var i = 0; i < 4; i++) {
      final path = Path()
        ..moveTo(size.width * 0.08, size.height * (0.92 - i * 0.09))
        ..cubicTo(
            size.width * 0.26,
            size.height * (0.84 - i * 0.09),
            size.width * 0.48,
            size.height * (0.98 - i * 0.09),
            size.width * 0.74,
            size.height * (0.82 - i * 0.09))
        ..cubicTo(
            size.width * 0.86,
            size.height * (0.74 - i * 0.09),
            size.width * 0.94,
            size.height * (0.77 - i * 0.09),
            size.width,
            size.height * (0.72 - i * 0.09));
      canvas.drawPath(path, line);
    }

    final columnPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFF4F1E7),
          Color(0xFFE3DDCF),
        ],
      ).createShader(Rect.fromLTWH(
        size.width * 0.78,
        size.height * 0.02,
        size.width * 0.25,
        size.height * 0.86,
      ));
    final capital = Path()
      ..moveTo(size.width * 0.72, size.height * 0.12)
      ..lineTo(size.width * 1.02, size.height * 0.02)
      ..lineTo(size.width * 1.06, size.height * 0.18)
      ..lineTo(size.width * 0.74, size.height * 0.18)
      ..close();
    canvas.drawPath(capital, columnPaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.84,
          size.height * 0.16,
          size.width * 0.14,
          size.height * 0.62,
        ),
        Radius.circular(10.r),
      ),
      columnPaint,
    );
    for (var i = 0; i < 5; i++) {
      canvas.drawLine(
        Offset(size.width * (0.85 + i * 0.025), size.height * 0.2),
        Offset(size.width * (0.85 + i * 0.025), size.height * 0.76),
        Paint()
          ..color = const Color(0xFFD2CBBE)
          ..strokeWidth = 1,
      );
    }

    final shelfPaint = Paint()
      ..color = const Color(0xFF7A9B7A).withValues(alpha: 0.72);
    for (var i = 0; i < 5; i++) {
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * (0.44 + i * 0.055),
          size.height * (0.34 + (i % 2) * 0.03),
          size.width * 0.045,
          size.height * 0.22,
        ),
        Radius.circular(4.r),
      );
      canvas.drawRRect(rect, shelfPaint);
      canvas.drawLine(
        Offset(rect.left + 3.w, rect.top + 10.h),
        Offset(rect.right - 3.w, rect.top + 10.h),
        Paint()
          ..color = const Color(0xFFE9E1C6)
          ..strokeWidth = 1,
      );
    }

    final folder = Path()
      ..moveTo(size.width * 0.44, size.height * 0.72)
      ..lineTo(size.width * 0.61, size.height * 0.72)
      ..lineTo(size.width * 0.64, size.height * 0.68)
      ..lineTo(size.width * 0.82, size.height * 0.68)
      ..lineTo(size.width * 0.78, size.height * 0.96)
      ..lineTo(size.width * 0.38, size.height * 0.96)
      ..close();
    canvas.drawPath(folder, parchment);
    canvas.drawPath(
      folder,
      Paint()
        ..color = const Color(0xFFE0D4B7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    final paperA = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.5, size.height * 0.5, size.width * 0.22,
          size.height * 0.24),
      Radius.circular(8.r),
    );
    final paperB = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.6, size.height * 0.56, size.width * 0.2,
          size.height * 0.2),
      Radius.circular(8.r),
    );
    canvas.drawRRect(paperA, parchment);
    canvas.drawRRect(paperB, parchmentShade);
    for (var i = 0; i < 3; i++) {
      final y = size.height * (0.56 + i * 0.04);
      canvas.drawLine(
        Offset(size.width * 0.53, y),
        Offset(size.width * 0.69, y),
        Paint()
          ..color = const Color(0xFFC8B796)
          ..strokeWidth = 1,
      );
    }

    final leafPaint = Paint()
      ..color = const Color(0xFF7AB28B).withValues(alpha: 0.86);
    for (final leaf in [
      Rect.fromLTWH(size.width * 0.33, size.height * 0.64, size.width * 0.08,
          size.height * 0.18),
      Rect.fromLTWH(size.width * 0.42, size.height * 0.46, size.width * 0.07,
          size.height * 0.16),
      Rect.fromLTWH(size.width * 0.66, size.height * 0.34, size.width * 0.08,
          size.height * 0.18),
    ]) {
      canvas.drawOval(leaf, leafPaint);
      canvas.drawLine(
        Offset(leaf.left + leaf.width / 2, leaf.bottom),
        Offset(leaf.left + leaf.width / 2, leaf.top),
        Paint()
          ..color = const Color(0xFFE9F0E8).withValues(alpha: 0.8)
          ..strokeWidth = 1,
      );
    }

    canvas.drawCircle(
      Offset(size.width * 0.78, size.height * 0.84),
      size.width * 0.12,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    canvas.drawCircle(
      Offset(size.width * 0.78, size.height * 0.84),
      size.width * 0.1,
      Paint()
        ..color = deepGreen.withValues(alpha: 0.78)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.8,
    );
    canvas.drawLine(
      Offset(size.width * 0.85, size.height * 0.9),
      Offset(size.width * 0.99, size.height * 1.01),
      ink,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.89, size.height * 0.74, size.width * 0.08,
            size.height * 0.16),
        Radius.circular(4.r),
      ),
      bookShade,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _JournalTimeMachineIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gold = Paint()
      ..color = const Color(0xFFE5CD93).withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFF8E4A6).withValues(alpha: 0.9),
          const Color(0xFFF8E4A6).withValues(alpha: 0.0),
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.7, size.height * 0.53),
          radius: size.width * 0.38,
        ),
      );
    canvas.drawCircle(
        Offset(size.width * 0.7, size.height * 0.53), size.width * 0.38, glow);

    final center = Offset(size.width * 0.66, size.height * 0.58);
    for (var i = 1; i <= 4; i++) {
      canvas.drawCircle(center, size.width * (0.12 + i * 0.065), gold);
    }
    for (var i = 0; i < 18; i++) {
      final angle = -math.pi * 0.88 + i * math.pi / 14;
      final start = Offset(
        center.dx + math.cos(angle) * size.width * 0.12,
        center.dy + math.sin(angle) * size.width * 0.12,
      );
      final end = Offset(
        center.dx + math.cos(angle) * size.width * 0.38,
        center.dy + math.sin(angle) * size.width * 0.38,
      );
      canvas.drawLine(start, end, gold..strokeWidth = i % 3 == 0 ? 1.3 : 0.55);
    }

    const numerals = ['IX', 'X', 'XI', 'XII', 'I', 'II'];
    for (var i = 0; i < numerals.length; i++) {
      final angle = -math.pi * 0.86 + i * math.pi / 9;
      final position = Offset(
        center.dx + math.cos(angle) * size.width * 0.24,
        center.dy + math.sin(angle) * size.width * 0.24,
      );
      final textPainter = TextPainter(
        text: TextSpan(
          text: numerals[i],
          style: TextStyle(
            color: const Color(0xFFF5E2AA).withValues(alpha: 0.88),
            fontSize: 10.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas,
          position - Offset(textPainter.width / 2, textPainter.height / 2));
    }

    final pagePaint = Paint()
      ..color = const Color(0xFFF2E6C9).withValues(alpha: 0.95);
    final pageStroke = Paint()
      ..color = const Color(0xFFE5CD93).withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final leftPage = Path()
      ..moveTo(size.width * 0.42, size.height * 0.77)
      ..quadraticBezierTo(size.width * 0.54, size.height * 0.66,
          size.width * 0.66, size.height * 0.79)
      ..lineTo(size.width * 0.65, size.height * 0.93)
      ..quadraticBezierTo(size.width * 0.53, size.height * 0.82,
          size.width * 0.41, size.height * 0.91)
      ..close();
    final rightPage = Path()
      ..moveTo(size.width * 0.66, size.height * 0.79)
      ..quadraticBezierTo(size.width * 0.82, size.height * 0.67,
          size.width * 0.96, size.height * 0.77)
      ..lineTo(size.width * 0.92, size.height * 0.91)
      ..quadraticBezierTo(size.width * 0.8, size.height * 0.84,
          size.width * 0.65, size.height * 0.93)
      ..close();
    canvas.drawPath(leftPage, pagePaint);
    canvas.drawPath(rightPage, pagePaint);
    canvas.drawPath(leftPage, pageStroke);
    canvas.drawPath(rightPage, pageStroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _JournalPortraitIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final wash = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          const Color(0xFF4D565C).withValues(alpha: 0.13),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, wash);

    final ink = Paint()
      ..color = const Color(0xFF394248).withValues(alpha: 0.72);
    final soft = Paint()
      ..color = const Color(0xFF394248).withValues(alpha: 0.12);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.63, size.height * 0.3),
        width: size.width * 0.34,
        height: size.height * 0.42,
      ),
      soft,
    );
    canvas.drawCircle(
        Offset(size.width * 0.64, size.height * 0.3), size.width * 0.14, ink);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.48, size.height * 0.45, size.width * 0.36,
            size.height * 0.4),
        Radius.circular(18.r),
      ),
      Paint()..color = const Color(0xFF505A61).withValues(alpha: 0.42),
    );
    canvas.drawLine(
      Offset(size.width * 0.72, size.height * 0.53),
      Offset(size.width * 0.96, size.height * 0.78),
      Paint()
        ..color = const Color(0xFF38424A).withValues(alpha: 0.55)
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(
      Offset(size.width * 0.72, size.height * 0.53),
      size.width * 0.045,
      Paint()..color = const Color(0xFF38424A).withValues(alpha: 0.65),
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.5, size.height * 0.23)
        ..quadraticBezierTo(size.width * 0.63, size.height * 0.12,
            size.width * 0.78, size.height * 0.23),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
