import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/data/learning/learning_game_state.dart';
import 'package:preamble/theme/app_fonts.dart';
import 'package:preamble/theme/preamble_tokens.dart';

/// 全域筆記字體雙重編碼轉換器：
/// 當啟用典藏宋體模式時，統一採用台灣繁體權威宋體 (`SourceHanSerifTW`)，
/// 徹底移除缺字嚴重的簡體手寫字型 (`maShanZheng`)。
TextStyle getNotebookTextStyle(BuildContext context, TextStyle baseStyle) {
  final gameState = LearningGameState.instance;
  if (gameState.useHandwrittenFont) {
    return baseStyle.copyWith(
      fontFamily: AppFonts.serifTW,
      fontFamilyFallback: AppFonts.serifFallbacks,
      height: baseStyle.height ?? 1.65,
    );
  }
  return baseStyle;
}

/// 靜奢編輯風筆記本底紙背景，支援方格、橫線、點陣、康乃爾三段論底紋，並完整適配深色模式。
class NotebookBackground extends StatelessWidget {
  const NotebookBackground({
    super.key,
    required this.child,
    this.gridSize = 26.0,
    this.lineColor,
    this.marginColor,
  });

  final Widget child;
  final double gridSize;
  final Color? lineColor;
  final Color? marginColor;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final gameState = LearningGameState.instance;
    final paperStyle = gameState.notebookPaperStyle;

    final actualLineColor = lineColor ??
        t.border.withValues(alpha: t.isDark ? 0.42 : 0.62);
    final actualMarginColor = marginColor ??
        t.accentBrass.withValues(alpha: t.isDark ? 0.28 : 0.32);

    return Container(
      color: t.canvas,
      child: CustomPaint(
        painter: _StationeryGridPainter(
          gridSize: gridSize.w,
          lineColor: actualLineColor,
          marginColor: actualMarginColor,
          paperStyle: paperStyle,
        ),
        child: child,
      ),
    );
  }
}

class _StationeryGridPainter extends CustomPainter {
  _StationeryGridPainter({
    required this.gridSize,
    required this.lineColor,
    required this.marginColor,
    required this.paperStyle,
  });

  final double gridSize;
  final Color lineColor;
  final Color marginColor;
  final String paperStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 0.75;

    if (paperStyle == 'grid') {
      for (double y = 0; y < size.height; y += gridSize) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      }
      for (double x = 0; x < size.width; x += gridSize) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      }
    } else if (paperStyle == 'lined') {
      for (double y = 0; y < size.height; y += gridSize) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      }
    } else if (paperStyle == 'dotted') {
      final dotPaint = Paint()
        ..color = lineColor
        ..style = PaintingStyle.fill;
      for (double y = gridSize; y < size.height; y += gridSize) {
        for (double x = gridSize; x < size.width; x += gridSize) {
          canvas.drawCircle(Offset(x, y), 1.0, dotPaint);
        }
      }
    } else if (paperStyle == 'cornell') {
      final double cueDivider = size.width * 0.28;
      final double summaryDivider = size.height * 0.82;

      for (double y = gridSize * 2; y < summaryDivider; y += gridSize) {
        canvas.drawLine(Offset(cueDivider, y), Offset(size.width, y), paint);
      }

      final dividerPaint = Paint()
        ..color = marginColor
        ..strokeWidth = 1.0;

      canvas.drawLine(
        Offset(cueDivider, 0),
        Offset(cueDivider, summaryDivider),
        dividerPaint,
      );
      canvas.drawLine(
        Offset(0, summaryDivider),
        Offset(size.width, summaryDivider),
        dividerPaint,
      );
    }

    if (paperStyle != 'cornell') {
      final marginPaint = Paint()
        ..color = marginColor
        ..strokeWidth = 1.0;
      final double leftMargin = 10.w;
      canvas.drawLine(
        Offset(leftMargin, 0),
        Offset(leftMargin, size.height),
        marginPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StationeryGridPainter oldDelegate) =>
      oldDelegate.gridSize != gridSize ||
      oldDelegate.lineColor != lineColor ||
      oldDelegate.marginColor != marginColor ||
      oldDelegate.paperStyle != paperStyle;
}

/// 靜奢律政典藏紙卡（溫潤象牙白／深曜墨玉底紙 + 1px 結構細邊框 + 古銅金垂墜書籤點綴）。
class NotebookCard extends StatelessWidget {
  const NotebookCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.hasBinderRings = false,
    this.hasPaperClip = false,
    this.hasBookmark = false,
    this.bookmarkColor,
    this.padding,
    this.margin,
  });

  final Widget child;
  final Color? backgroundColor;
  final bool hasBinderRings;
  final bool hasPaperClip;
  final bool hasBookmark;
  final Color? bookmarkColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final cardColor = backgroundColor ?? t.surface;
    final ribbonColor = bookmarkColor ?? t.accentBrass;

    return Container(
      margin: margin ?? EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: t.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: t.shadowAmbient,
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Stack(
          children: [
            Padding(
              padding: padding ??
                  EdgeInsets.symmetric(horizontal: 15.w, vertical: 14.h),
              child: child,
            ),
            if (hasBookmark)
              Positioned(
                top: 0,
                right: 16.w,
                child: IgnorePointer(
                  child: CustomPaint(
                    size: Size(12.w, 22.h),
                    painter: _EditorialBookmarkPainter(color: ribbonColor),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EditorialBookmarkPainter extends CustomPainter {
  const _EditorialBookmarkPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width / 2, size.height * 0.74)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _EditorialBookmarkPainter oldDelegate) =>
      oldDelegate.color != color;
}
