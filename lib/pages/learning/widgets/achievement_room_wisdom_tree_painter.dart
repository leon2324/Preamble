import 'dart:math' as math;

import 'package:flutter/material.dart';

// 成就室智慧樹的自訂繪圖。
// 只放樹、雲朵、孩子與澆水粒子的畫布邏輯，不放學習資料或導頁行為。

class WisdomTreePainter extends CustomPainter {
  WisdomTreePainter({
    required this.level,
    required this.completedUnits,
    required this.animationValue,
    required this.treeScale,
    required this.showParticles,
  });

  final int level;
  final int completedUnits;
  final double animationValue; // 0.0 to 1.0
  final double treeScale;
  final bool showParticles;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // 1. 繪製天空與陽光背景
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFE2F0FD),
          Color(0xFFFFF9E6),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, skyPaint);

    // 太陽
    final sunPaint = Paint()
      ..color = const Color(0xFFFFE699).withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;
    final sunGlowPaint = Paint()
      ..color = const Color(0xFFFFD966).withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    canvas.drawCircle(Offset(size.width - 40, 40), 25, sunGlowPaint);
    canvas.drawCircle(Offset(size.width - 40, 40), 18, sunPaint);

    // 雲朵 (微風吹拂移動)
    final cloudPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;
    final cloudOffset = animationValue * size.width;
    _drawCloud(
        canvas,
        Offset((cloudOffset - 100) % (size.width + 120) - 60, 25.0),
        cloudPaint);
    _drawCloud(
        canvas,
        Offset(((cloudOffset * 0.5) + 120) % (size.width + 120) - 60, 45.0),
        cloudPaint);

    // 2. 繪製底部綠色草地
    final grassPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF9DD49D),
          Color(0xFF7CB87C),
        ],
      ).createShader(Rect.fromLTWH(0, size.height - 40, size.width, 40));
    final grassPath = Path()
      ..moveTo(0, size.height - 15)
      ..quadraticBezierTo(size.width * 0.4, size.height - 35, size.width * 0.75,
          size.height - 20)
      ..quadraticBezierTo(
          size.width * 0.9, size.height - 15, size.width, size.height - 25)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(grassPath, grassPaint);

    // 3. 智慧之樹主體 (以 center 為基準)
    final treeCenter = Offset(size.width / 2, size.height - 22);
    canvas.save();
    canvas.translate(treeCenter.dx, treeCenter.dy);
    canvas.scale(treeScale); // 點擊澆水彈跳縮放

    // 依等級設定樹幹寬與高
    final double trunkWidth = 4.0 + (level * 1.2);
    final double trunkHeight = 25.0 + (level * 5.0);

    // 繪製樹幹 (帶有分支)
    final trunkPaint = Paint()
      ..color = const Color(0xFF8B5A2B)
      ..style = PaintingStyle.fill;

    // 樹根
    if (level >= 7) {
      final rootPath = Path()
        ..moveTo(-trunkWidth * 1.5, 2)
        ..lineTo(trunkWidth * 1.5, 2)
        ..quadraticBezierTo(0, -5, 0, -trunkHeight)
        ..close();
      canvas.drawPath(rootPath, trunkPaint);
    }

    // 主樹幹
    final trunkRect =
        Rect.fromLTWH(-trunkWidth / 2, -trunkHeight, trunkWidth, trunkHeight);
    canvas.drawRRect(
        RRect.fromRectAndRadius(trunkRect, const Radius.circular(2)),
        trunkPaint);

    // 樹枝分岔 (Level 3 以上)
    if (level >= 3) {
      final branchPaint = Paint()
        ..color = const Color(0xFF8B5A2B)
        ..strokeWidth = trunkWidth * 0.6
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      // 左樹枝
      canvas.drawLine(
        Offset(-trunkWidth * 0.1, -trunkHeight * 0.5),
        Offset(-trunkWidth * 1.6, -trunkHeight * 0.78),
        branchPaint,
      );
      // 右樹枝
      canvas.drawLine(
        Offset(trunkWidth * 0.1, -trunkHeight * 0.6),
        Offset(trunkWidth * 1.8, -trunkHeight * 0.82),
        branchPaint,
      );
    }

    // 4. 繪製樹冠 (圓形葉子球，隨微風輕微擺晃)
    final double windSway = math.sin(animationValue * 2 * math.pi) * 1.8;
    canvas.save();
    canvas.translate(0, -trunkHeight);
    canvas.rotate(windSway * math.pi / 180); // 隨風微擺

    final double canopyRadius = 15.0 + (level * 3.8);
    final leafPaint = Paint()..style = PaintingStyle.fill;

    // 依等級繪製多層漸層葉子球
    final List<Offset> leafOffsets = [];
    if (level == 1) {
      leafOffsets.add(const Offset(0, -5));
    } else if (level <= 3) {
      leafOffsets.addAll([
        const Offset(0, -8),
        const Offset(-10, 0),
        const Offset(10, 0),
      ]);
    } else if (level <= 6) {
      leafOffsets.addAll([
        const Offset(0, -15),
        const Offset(-18, -5),
        const Offset(18, -5),
        const Offset(-10, 10),
        const Offset(10, 10),
      ]);
    } else {
      leafOffsets.addAll([
        const Offset(0, -28),
        const Offset(-28, -14),
        const Offset(28, -14),
        const Offset(-32, 10),
        const Offset(32, 10),
        const Offset(-15, -15),
        const Offset(15, -15),
        const Offset(0, 5),
      ]);
    }

    for (int i = 0; i < leafOffsets.length; i++) {
      final offset = leafOffsets[i];
      // 漸層色調：深淺交錯
      final isTop = offset.dy < -10;
      final Color leafColor;
      if (isTop) {
        leafColor = const Color(0xFF6EBE78);
      } else {
        leafColor =
            i % 2 == 0 ? const Color(0xFF4FA65A) : const Color(0xFF388E44);
      }

      leafPaint.shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [leafColor, leafColor.withRed(10).withGreen(100)],
      ).createShader(Rect.fromCircle(center: offset, radius: canopyRadius));

      canvas.drawCircle(offset, canopyRadius, leafPaint);
    }

    // 5. 智慧之花 (Level 5 ~ 6) 或 智慧之果 (Level 7 ~ 10)
    if (level >= 5 && level <= 6) {
      // 智慧花苞 (粉白小點)
      final flowerPaint = Paint()
        ..color = const Color(0xFFFFF0F5)
        ..style = PaintingStyle.fill;
      final flowerCorePaint = Paint()
        ..color = const Color(0xFFFFB6C1)
        ..style = PaintingStyle.fill;

      for (int i = 0; i < leafOffsets.length; i++) {
        final flowerPos = leafOffsets[i] +
            Offset(canopyRadius * 0.4 * math.sin(i), -canopyRadius * 0.4);
        canvas.drawCircle(flowerPos, 3.5, flowerPaint);
        canvas.drawCircle(flowerPos, 1.8, flowerCorePaint);
      }
    } else if (level >= 7) {
      // 智慧之果 (金色小果實)
      final fruitPaint = Paint()
        ..color = const Color(0xFFFFD700)
        ..style = PaintingStyle.fill;
      final fruitHighlightPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      // 果實掛載位置
      for (int i = 0; i < (level - 5).clamp(2, 6); i++) {
        final offsetIdx = i % leafOffsets.length;
        final fruitPos = leafOffsets[offsetIdx] +
            Offset(canopyRadius * 0.5 * math.sin(i * 1.5), canopyRadius * 0.3);
        canvas.drawCircle(fruitPos, 4.5, fruitPaint);
        // 高光點
        canvas.drawCircle(
            fruitPos + const Offset(-1.2, -1.2), 1.2, fruitHighlightPaint);
      }
    }

    // 6. 微觀綠葉 (數量 = completedUnits)
    final singleLeafPaint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < completedUnits; i++) {
      // 圍繞樹冠均勻分布或輕微飄落
      final double angle = (i * 2.4) + (animationValue * 0.1);
      final double dist = canopyRadius * 1.1 + (i % 3) * 3.0;
      final double leafX = dist * math.cos(angle);
      final double leafY = dist * math.sin(angle) - 5;

      canvas.save();
      canvas.translate(leafX, leafY);
      canvas.rotate(angle);
      canvas.drawOval(const Rect.fromLTRB(-3.5, -2, 3.5, 2), singleLeafPaint);
      canvas.restore();
    }

    canvas.restore(); // 結束樹冠擺動
    canvas.restore(); // 結束樹整體縮放

    // 7. 繪製小孩跑跳動畫
    // 依等級決定小孩人數
    final int kidsCount;
    if (level == 1 || level == 2) {
      kidsCount = 1;
    } else if (level == 3 || level == 4) {
      kidsCount = 2;
    } else if (level == 5 || level == 6) {
      kidsCount = 3;
    } else if (level == 7 || level == 8) {
      kidsCount = 4;
    } else {
      kidsCount = 5;
    }

    for (int i = 0; i < kidsCount; i++) {
      _drawChild(canvas, size, i, animationValue);
    }

    // 8. 澆水動畫粒子 (showParticles = true 時渲染)
    if (showParticles) {
      final particlePaint = Paint()
        ..color = const Color(0xFFFFD700).withValues(alpha: 0.8)
        ..style = PaintingStyle.fill;
      for (int i = 0; i < 8; i++) {
        // 從樹中心向外擴散的金色光斑
        final double angle = i * math.pi / 4 + (animationValue * 4);
        final double dist = 35.0 + 40.0 * (animationValue % 0.5) * 2;
        final double px = treeCenter.dx + dist * math.cos(angle);
        final double py =
            treeCenter.dy - trunkHeight - 20 + dist * math.sin(angle);
        canvas.drawCircle(
            Offset(px, py), 2.5 * (1.0 - (dist / 75.0)), particlePaint);
      }
    }
  }

  // 雲朵位置微調 helper
  double get _cloudYOffset => 0.0;
  double get _cloudXOffset => 0.0;

  void _drawCloud(Canvas canvas, Offset pos, Paint paint) {
    canvas.drawCircle(pos, 15, paint);
    canvas.drawCircle(pos + const Offset(12, -4), 12, paint);
    canvas.drawCircle(pos + const Offset(-12, -2), 10, paint);
    canvas.drawCircle(pos + const Offset(22, 2), 9, paint);
  }

  void _drawChild(Canvas canvas, Size size, int index, double anim) {
    // 每個小孩的衣服顏色
    final List<Color> clothesColors = [
      const Color(0xFF3F8FDF), // 藍
      const Color(0xFFDF5F3F), // 紅
      const Color(0xFFDFBF3F), // 黃
      const Color(0xFF9F3FDF), // 紫
      const Color(0xFF3FDFBF), // 青
    ];

    final clothesColor = clothesColors[index % clothesColors.length];

    if (index == 0) {
      // 第一個小孩：Level 1 起解鎖，坐在樹底下看書的小男孩 (安靜坐在樹左側)
      final Offset pos = Offset(size.width / 2 - 40, size.height - 22);
      _drawSittingChild(canvas, pos, clothesColor);
    } else if (index == 1) {
      // 第二個小孩：Level 3 起解鎖，在右側跳躍的女孩
      final double sway = math.sin(anim * 4 * math.pi);
      final Offset pos =
          Offset(size.width / 2 + 45, size.height - 24 + sway.abs() * -6);
      _drawJumpingChild(canvas, pos, clothesColor, sway);
    } else if (index == 2) {
      // 第三個小孩：Level 5 起解鎖，在左側快樂跑動的小孩
      // x座標在 [size.width/2 - 120, size.width/2 - 50] 之間移動
      final double progress = (anim * 2) % 2; // 0 to 2
      final double xRange = 60.0;
      final double direction = progress > 1 ? -1 : 1;
      final double relativeProgress = progress > 1 ? progress - 1 : progress;

      final double childX = direction > 0
          ? (size.width / 2 - 110) + relativeProgress * xRange
          : (size.width / 2 - 50) - relativeProgress * xRange;

      final double bob = (math.sin(anim * 6 * math.pi)).abs() * -4.0;
      final Offset pos = Offset(childX, size.height - 23 + bob);
      _drawRunningChild(canvas, pos, clothesColor, direction > 0, anim);
    } else if (index == 3) {
      // 第四個小孩：Level 7 起解鎖，在右側大範圍奔跑的小長腿
      // x座標在 [size.width/2 + 50, size.width/2 + 130] 之間跑動
      final double progress = (anim * 1.5 + 0.5) % 2;
      final double xRange = 70.0;
      final double direction = progress > 1 ? -1 : 1;
      final double relativeProgress = progress > 1 ? progress - 1 : progress;

      final double childX = direction > 0
          ? (size.width / 2 + 55) + relativeProgress * xRange
          : (size.width / 2 + 125) - relativeProgress * xRange;

      final double bob = (math.sin(anim * 5 * math.pi)).abs() * -4.5;
      final Offset pos = Offset(childX, size.height - 23 + bob);
      _drawRunningChild(canvas, pos, clothesColor, direction > 0, anim + 0.25);
    } else {
      // 第五個小孩：Level 9 起解鎖，在中右側開心地抱著氣球手舞足蹈的小孩
      final double sway = math.sin(anim * 3 * math.pi);
      final Offset pos =
          Offset(size.width / 2 + 85 + sway * 8, size.height - 25);
      _drawDancingChild(canvas, pos, clothesColor, sway);
    }
  }

  void _drawSittingChild(Canvas canvas, Offset pos, Color clothesColor) {
    final headPaint = Paint()
      ..color = const Color(0xFFFFD5B3)
      ..style = PaintingStyle.fill;
    final hairPaint = Paint()
      ..color = const Color(0xFF333333)
      ..style = PaintingStyle.fill;
    final clothesPaint = Paint()
      ..color = clothesColor
      ..style = PaintingStyle.fill;
    final pantsPaint = Paint()
      ..color = const Color(0xFF4F5B66)
      ..style = PaintingStyle.fill;
    final bookPaint = Paint()
      ..color = const Color(0xFF4A90E2)
      ..style = PaintingStyle.fill;
    final pagePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // 身體/坐姿
    canvas.drawRect(
        Rect.fromLTWH(pos.dx - 5, pos.dy - 10, 10, 8), clothesPaint);
    // 腿/屈膝
    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(pos.dx - 8, pos.dy - 3, 14, 4),
            const Radius.circular(2)),
        pantsPaint);

    // 頭部
    canvas.drawCircle(pos + const Offset(0, -14), 5.5, headPaint);
    // 頭髮
    final hairPath = Path()
      ..addArc(Rect.fromCircle(center: pos + const Offset(0, -14), radius: 5.8),
          -math.pi, math.pi)
      ..lineTo(pos.dx + 5.8, pos.dy - 14)
      ..lineTo(pos.dx + 3, pos.dy - 12)
      ..lineTo(pos.dx - 3, pos.dy - 12)
      ..lineTo(pos.dx - 5.8, pos.dy - 14)
      ..close();
    canvas.drawPath(hairPath, hairPaint);

    // 小藍書
    canvas.drawRect(Rect.fromLTWH(pos.dx - 2, pos.dy - 10, 8, 5), bookPaint);
    canvas.drawRect(Rect.fromLTWH(pos.dx, pos.dy - 9, 6, 3), pagePaint);
  }

  void _drawJumpingChild(
      Canvas canvas, Offset pos, Color clothesColor, double sway) {
    final headPaint = Paint()
      ..color = const Color(0xFFFFD5B3)
      ..style = PaintingStyle.fill;
    final hairPaint = Paint()
      ..color = const Color(0xFFC68E17)
      ..style = PaintingStyle.fill; // 橘金髮
    final clothesPaint = Paint()
      ..color = clothesColor
      ..style = PaintingStyle.fill;
    final limbPaint = Paint()
      ..color = const Color(0xFFFFD5B3)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // 身體
    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(pos.dx - 4, pos.dy - 10, 8, 9),
            const Radius.circular(2)),
        clothesPaint);

    // 頭部
    canvas.drawCircle(pos + const Offset(0, -15), 5.5, headPaint);
    // 頭髮 (雙馬尾/小辮子)
    canvas.drawCircle(pos + const Offset(-5.5, -16), 2, hairPaint);
    canvas.drawCircle(pos + const Offset(5.5, -16), 2, hairPaint);
    canvas.drawCircle(pos + const Offset(0, -16.5), 5.8, hairPaint);

    // 手部 (V字揮舞)
    canvas.drawLine(Offset(pos.dx - 4, pos.dy - 8),
        Offset(pos.dx - 9, pos.dy - 14 + sway), limbPaint);
    canvas.drawLine(Offset(pos.dx + 4, pos.dy - 8),
        Offset(pos.dx + 9, pos.dy - 14 - sway), limbPaint);

    // 腿部 (懸空/分開)
    canvas.drawLine(Offset(pos.dx - 2, pos.dy - 1),
        Offset(pos.dx - 5, pos.dy + 3), limbPaint);
    canvas.drawLine(Offset(pos.dx + 2, pos.dy - 1),
        Offset(pos.dx + 5, pos.dy + 3), limbPaint);
  }

  void _drawRunningChild(Canvas canvas, Offset pos, Color clothesColor,
      bool facingRight, double anim) {
    final headPaint = Paint()
      ..color = const Color(0xFFFFD5B3)
      ..style = PaintingStyle.fill;
    final hairPaint = Paint()
      ..color = const Color(0xFF4A4A4A)
      ..style = PaintingStyle.fill;
    final clothesPaint = Paint()
      ..color = clothesColor
      ..style = PaintingStyle.fill;
    final limbPaint = Paint()
      ..color = const Color(0xFFFFD5B3)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final double stepPhase = math.sin(anim * 5 * math.pi);

    // 身體 (傾斜奔跑)
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate((facingRight ? 8.0 : -8.0) * math.pi / 180);

    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(-4, -10, 8, 9), const Radius.circular(2)),
        clothesPaint);

    // 頭部
    canvas.drawCircle(const Offset(0, -15), 5.5, headPaint);
    canvas.drawCircle(const Offset(0, -16.5), 5.8, hairPaint);

    // 手臂 (擺動)
    final double leftArmAngle = stepPhase * 10;
    final double rightArmAngle = -stepPhase * 10;
    canvas.drawLine(
        const Offset(-4, -8),
        Offset(-4 + (facingRight ? -4 : 4) + leftArmAngle * 0.2, -4),
        limbPaint);
    canvas.drawLine(
        const Offset(4, -8),
        Offset(4 + (facingRight ? 4 : -4) + rightArmAngle * 0.2, -4),
        limbPaint);

    // 雙腿 (跑動剪刀步)
    final double frontLegSway = stepPhase * 6;
    final double backLegSway = -stepPhase * 6;
    canvas.drawLine(
        const Offset(-2, -1), Offset(-4 + backLegSway * 0.5, 4), limbPaint);
    canvas.drawLine(
        const Offset(2, -1), Offset(4 + frontLegSway * 0.5, 4), limbPaint);

    canvas.restore();
  }

  void _drawDancingChild(
      Canvas canvas, Offset pos, Color clothesColor, double sway) {
    final headPaint = Paint()
      ..color = const Color(0xFFFFD5B3)
      ..style = PaintingStyle.fill;
    final hairPaint = Paint()
      ..color = const Color(0xFF8B5A2B)
      ..style = PaintingStyle.fill; // 棕髮
    final clothesPaint = Paint()
      ..color = clothesColor
      ..style = PaintingStyle.fill;
    final limbPaint = Paint()
      ..color = const Color(0xFFFFD5B3)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final stringPaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    final balloonPaint = Paint()
      ..color = const Color(0xFFFF6B6B)
      ..style = PaintingStyle.fill;

    // 身體
    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(pos.dx - 4, pos.dy - 10, 8, 9),
            const Radius.circular(2)),
        clothesPaint);

    // 頭部
    canvas.drawCircle(pos + const Offset(0, -15), 5.5, headPaint);
    canvas.drawCircle(pos + const Offset(0, -16.2), 5.8, hairPaint);

    // 左手臂捧著氣球線
    canvas.drawLine(Offset(pos.dx - 4, pos.dy - 8),
        Offset(pos.dx - 10, pos.dy - 12), limbPaint);
    // 右手臂上舉
    canvas.drawLine(Offset(pos.dx + 4, pos.dy - 8),
        Offset(pos.dx + 9, pos.dy - 14 + sway * 3), limbPaint);

    // 氣球線與紅色氣球
    final Offset balloonPos = pos + Offset(-15, -35 + sway * 2);
    canvas.drawLine(Offset(pos.dx - 10, pos.dy - 12), balloonPos, stringPaint);
    canvas.drawCircle(balloonPos, 7.5, balloonPaint);
    // 氣球小尾巴三角形
    final tailPath = Path()
      ..moveTo(balloonPos.dx, balloonPos.dy + 7.5)
      ..lineTo(balloonPos.dx - 2, balloonPos.dy + 10)
      ..lineTo(balloonPos.dx + 2, balloonPos.dy + 10)
      ..close();
    canvas.drawPath(tailPath, balloonPaint);

    // 雙腿
    canvas.drawLine(Offset(pos.dx - 2, pos.dy - 1),
        Offset(pos.dx - 4 + sway * 2, pos.dy + 4), limbPaint);
    canvas.drawLine(Offset(pos.dx + 2, pos.dy - 1),
        Offset(pos.dx + 4 - sway * 2, pos.dy + 4), limbPaint);
  }

  @override
  bool shouldRepaint(covariant WisdomTreePainter oldDelegate) {
    return oldDelegate.level != level ||
        oldDelegate.completedUnits != completedUnits ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.treeScale != treeScale ||
        oldDelegate.showParticles != showParticles;
  }
}
