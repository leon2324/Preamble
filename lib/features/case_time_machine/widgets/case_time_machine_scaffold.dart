import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/features/case_time_machine/data/case_time_machine_mock_data.dart';
import 'package:lawapp/features/case_time_machine/theme/case_time_machine_theme.dart';

enum CaseTimeMachineScene {
  entry,
  halls,
  timeline,
  theme,
  classic,
  shelf,
  dossier,
}

class CaseTimeMachineScaffold extends StatelessWidget {
  const CaseTimeMachineScaffold({
    super.key,
    required this.child,
    this.scene = CaseTimeMachineScene.entry,
    this.showBackButton = true,
    this.useSafeArea = true,
  });

  final Widget child;
  final CaseTimeMachineScene scene;
  final bool showBackButton;
  final bool useSafeArea;

  @override
  Widget build(BuildContext context) {
    // 舊版沉浸式圖書館頁面需要共用 scaffold 代管 SafeArea 與返回鍵；
    // 新版有自己 AppBar 的頁面則會把 useSafeArea 關掉，讓頁面背景能覆蓋狀態列，
    // 再由頁面內部只保留一層 SafeArea，避免舊圖層或舊返回鍵疊在新 AppBar 上。
    final foreground = Stack(
      children: [
        child,
        if (showBackButton)
          Positioned(
            top: 8.h,
            left: 12.w,
            child: _BackButton(),
          ),
      ],
    );

    return Scaffold(
      backgroundColor: CaseTimeMachineColors.libraryMidnight,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            caseTimeMachineV2BackgroundAsset,
            fit: BoxFit.cover,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color:
                  CaseTimeMachineColors.libraryMidnight.withValues(alpha: .18),
            ),
          ),
          CustomPaint(painter: _GeneratedLibraryScenePainter(scene)),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: .08),
                  Colors.transparent,
                  CaseTimeMachineColors.libraryMidnight.withValues(alpha: .7),
                ],
              ),
            ),
          ),
          CustomPaint(painter: _GoldFrameAndDustPainter(scene)),
          if (useSafeArea)
            SafeArea(bottom: false, child: foreground)
          else
            foreground,
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          width: 38.w,
          height: 38.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: CaseTimeMachineColors.libraryCardGlass,
            border: Border.all(color: CaseTimeMachineColors.libraryBorderGold),
          ),
          child: Icon(CupertinoIcons.chevron_left,
              color: CaseTimeMachineColors.libraryFogWhite, size: 18.sp),
        ),
      ),
    );
  }
}

class _GeneratedLibraryScenePainter extends CustomPainter {
  const _GeneratedLibraryScenePainter(this.scene);

  final CaseTimeMachineScene scene;

  @override
  void paint(Canvas canvas, Size size) {
    _paintBaseMist(canvas, size);

    switch (scene) {
      case CaseTimeMachineScene.entry:
        _paintGrandHall(canvas, size);
      case CaseTimeMachineScene.halls:
        _paintThreeDoors(canvas, size);
      case CaseTimeMachineScene.timeline:
        _paintShelfRows(canvas, size, glowIndex: 1);
      case CaseTimeMachineScene.theme:
        _paintThemeArchive(canvas, size);
      case CaseTimeMachineScene.classic:
        _paintClassicVault(canvas, size);
      case CaseTimeMachineScene.shelf:
        _paintShelfWall(canvas, size);
      case CaseTimeMachineScene.dossier:
        _paintDossierChamber(canvas, size);
    }
  }

  void _paintBaseMist(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF03100F),
          Color(0xFF071D1B),
          Color(0xFF0B2A24),
          Color(0xFF061817),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, paint);

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          CaseTimeMachineColors.libraryMistBlue.withValues(alpha: .22),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * .52, size.height * .28),
          radius: size.shortestSide * .62,
        ),
      );
    canvas.drawRect(rect, glowPaint);

    final lowerMist = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          CaseTimeMachineColors.libraryMistBlue.withValues(alpha: .08),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromLTWH(0, size.height * .62, size.width, size.height * .28),
      );
    canvas.drawRect(rect, lowerMist);
  }

  void _paintGrandHall(Canvas canvas, Size size) {
    _paintPerspectiveShelves(canvas, size, left: true);
    _paintPerspectiveShelves(canvas, size, left: false);
    _paintArchDoor(canvas, size,
        center: Offset(size.width * .5, size.height * .33),
        width: size.width * .34,
        height: size.height * .34,
        alpha: .78);
  }

  void _paintThreeDoors(Canvas canvas, Size size) {
    for (var index = 0; index < 3; index++) {
      _paintArchDoor(
        canvas,
        size,
        center: Offset(size.width * (.25 + index * .25), size.height * .34),
        width: size.width * .19,
        height: size.height * .34,
        alpha: index == 1 ? .78 : .52,
      );
    }
    _paintShelfRows(canvas, size, top: size.height * .58, rows: 3);
  }

  void _paintThemeArchive(Canvas canvas, Size size) {
    final iconPaint = Paint()
      ..color = CaseTimeMachineColors.libraryBorderGold.withValues(alpha: .26)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (var row = 0; row < 3; row++) {
      for (var col = 0; col < 2; col++) {
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            size.width * (.16 + col * .36),
            size.height * (.2 + row * .15),
            size.width * .24,
            size.height * .1,
          ),
          const Radius.circular(18),
        );
        canvas.drawRRect(rect, iconPaint);
        canvas.drawCircle(rect.outerRect.center, 12, iconPaint);
      }
    }
  }

  void _paintClassicVault(Canvas canvas, Size size) {
    for (var index = 0; index < 4; index++) {
      final center = Offset(
        size.width * (.28 + (index % 2) * .28),
        size.height * (.28 + (index ~/ 2) * .2),
      );
      final glow = Paint()
        ..shader = RadialGradient(
          colors: [
            CaseTimeMachineColors.libraryMutedGold.withValues(alpha: .28),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: 90));
      canvas.drawCircle(center, 90, glow);
      _paintTinyBook(canvas, center.translate(-16, -20), 32, 58);
    }
  }

  void _paintShelfWall(Canvas canvas, Size size) {
    _paintShelfRows(canvas, size,
        top: size.height * .14, rows: 6, glowIndex: 2);
  }

  void _paintDossierChamber(Canvas canvas, Size size) {
    _paintArchDoor(canvas, size,
        center: Offset(size.width * .5, size.height * .22),
        width: size.width * .62,
        height: size.height * .28,
        alpha: .28);
    final paperPaint = Paint()
      ..color = CaseTimeMachineColors.libraryFogWhite.withValues(alpha: .05);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * .1, size.height * .34, size.width * .8,
            size.height * .38),
        const Radius.circular(28),
      ),
      paperPaint,
    );
  }

  void _paintPerspectiveShelves(Canvas canvas, Size size,
      {required bool left}) {
    final paint = Paint()
      ..color = CaseTimeMachineColors.libraryBorderGold.withValues(alpha: .18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final startX = left ? size.width * .05 : size.width * .95;
    final endX = left ? size.width * .34 : size.width * .66;
    for (var index = 0; index < 8; index++) {
      final y = size.height * (.12 + index * .06);
      canvas.drawLine(Offset(startX, y), Offset(endX, y + index * 5), paint);
    }
  }

  void _paintShelfRows(Canvas canvas, Size size,
      {double? top, int rows = 5, int? glowIndex}) {
    final startTop = top ?? size.height * .2;
    final railPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          CaseTimeMachineColors.libraryMutedGold.withValues(alpha: .12),
          CaseTimeMachineColors.libraryMutedGold.withValues(alpha: .48),
          CaseTimeMachineColors.libraryMutedGold.withValues(alpha: .12),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, 20));

    for (var row = 0; row < rows; row++) {
      final y = startTop + row * size.height * .105;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width * .09, y, size.width * .82, 8),
          const Radius.circular(999),
        ),
        railPaint,
      );
      for (var col = 0; col < 9; col++) {
        final bookHeight = 44.0 + ((row + col) % 3) * 10;
        final x = size.width * .13 + col * size.width * .078;
        final bookY = y - bookHeight;
        final isGlow = glowIndex == row && col == 4;
        _paintTinyBook(canvas, Offset(x, bookY), size.width * .045, bookHeight,
            glow: isGlow);
      }
    }
  }

  void _paintArchDoor(Canvas canvas, Size size,
      {required Offset center,
      required double width,
      required double height,
      required double alpha}) {
    final rect = Rect.fromCenter(center: center, width: width, height: height);
    final path = Path()
      ..moveTo(rect.left, rect.bottom)
      ..lineTo(rect.left, rect.center.dy)
      ..quadraticBezierTo(rect.center.dx, rect.top, rect.right, rect.center.dy)
      ..lineTo(rect.right, rect.bottom)
      ..close();
    final fill = Paint()
      ..shader = RadialGradient(
        colors: [
          CaseTimeMachineColors.libraryMistBlue.withValues(alpha: alpha * .32),
          CaseTimeMachineColors.libraryDeepTeal.withValues(alpha: alpha * .42),
          Colors.transparent,
        ],
      ).createShader(rect.inflate(width * .35));
    canvas.drawPath(path, fill);

    final stroke = Paint()
      ..color = CaseTimeMachineColors.libraryBorderGold.withValues(alpha: alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    canvas.drawPath(path, stroke);
  }

  void _paintTinyBook(Canvas canvas, Offset offset, double width, double height,
      {bool glow = false}) {
    if (glow) {
      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF79D8CF).withValues(alpha: .26),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(
            center: offset.translate(width / 2, height / 2), radius: 46));
      canvas.drawCircle(offset.translate(width / 2, height / 2), 46, glowPaint);
    }
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(offset.dx, offset.dy, width, height),
      const Radius.circular(4),
    );
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          CaseTimeMachineColors.libraryDeepTeal.withValues(alpha: .88),
          CaseTimeMachineColors.libraryDeepGreen.withValues(alpha: .96),
        ],
      ).createShader(rect.outerRect);
    canvas.drawRRect(rect, paint);
    canvas.drawRRect(
      rect,
      Paint()
        ..color = CaseTimeMachineColors.libraryBorderGold.withValues(alpha: .38)
        ..style = PaintingStyle.stroke
        ..strokeWidth = .8,
    );
  }

  @override
  bool shouldRepaint(covariant _GeneratedLibraryScenePainter oldDelegate) =>
      oldDelegate.scene != scene;
}

class _GoldFrameAndDustPainter extends CustomPainter {
  const _GoldFrameAndDustPainter(this.scene);

  final CaseTimeMachineScene scene;

  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = CaseTimeMachineColors.libraryBorderGold.withValues(alpha: .42)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(7, 7, size.width - 14, size.height - 14),
        const Radius.circular(24),
      ),
      borderPaint,
    );

    final dustPaint = Paint()
      ..color = const Color(0xFF79D8CF).withValues(alpha: .58);
    for (var index = 0; index < 56; index++) {
      final x = (math.sin(index * 12.9898) * 43758.5453).abs() % size.width;
      final y = (math.cos(index * 78.233) * 24634.6345).abs() % size.height;
      final radius = index % 7 == 0 ? 1.7 : .8;
      canvas.drawCircle(Offset(x, y), radius, dustPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GoldFrameAndDustPainter oldDelegate) =>
      oldDelegate.scene != scene;
}
