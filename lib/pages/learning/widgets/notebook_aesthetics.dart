import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lawapp/data/learning/learning_game_state.dart';

/// 全域手寫字體轉換器，當 useHandwrittenFont 啟用時套用
TextStyle getNotebookTextStyle(BuildContext context, TextStyle baseStyle) {
  final gameState = LearningGameState.instance;
  if (gameState.useHandwrittenFont) {
    return GoogleFonts.maShanZheng(
      textStyle: baseStyle.copyWith(
        fontSize: (baseStyle.fontSize ?? 14.sp) * 1.15,
        fontWeight: FontWeight.normal, // 手寫字體不適合過粗的 font weight
        fontFamilyFallback: const ['Kai', 'SourceHanSerifTW'],
      ),
    );
  }
  return baseStyle;
}

/// 筆記本底紙背景，支援多種格式底紋（方格、橫線、點陣、康乃爾）
class NotebookBackground extends StatelessWidget {
  const NotebookBackground({
    super.key,
    required this.child,
    this.gridSize = 25.0,
    this.lineColor = const Color(0xFFE5EFF2), // 隱約的淡粉藍格線
    this.marginColor = const Color(0xFFF6CCD2), // 邊線粉紅
  });

  final Widget child;
  final double gridSize;
  final Color lineColor;
  final Color marginColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gameState = LearningGameState.instance;
    final paperStyle = gameState.notebookPaperStyle;

    // 深色模式下的格線顏色
    final actualLineColor = isDark ? const Color(0xFF1E262F) : lineColor;
    final actualMarginColor = isDark ? const Color(0xFF3A2327) : marginColor;
    final actualBgColor =
        isDark ? const Color(0xFF0F1216) : const Color(0xFFFCFBF9);

    return Container(
      color: actualBgColor,
      child: CustomPaint(
        painter: _GridPainter(
          gridSize: gridSize.w,
          lineColor: actualLineColor,
          marginColor: actualMarginColor,
          isDark: isDark,
          paperStyle: paperStyle,
        ),
        child: child,
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  _GridPainter({
    required this.gridSize,
    required this.lineColor,
    required this.marginColor,
    required this.isDark,
    required this.paperStyle,
  });

  final double gridSize;
  final Color lineColor;
  final Color marginColor;
  final bool isDark;
  final String paperStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 0.8.w;

    if (paperStyle == 'grid') {
      // 1) 方格紙：畫水平與垂直格線
      for (double y = 0; y < size.height; y += gridSize) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      }
      for (double x = 0; x < size.width; x += gridSize) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      }
    } else if (paperStyle == 'lined') {
      // 2) 橫線紙：僅畫水平格線
      for (double y = 0; y < size.height; y += gridSize) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      }
    } else if (paperStyle == 'dotted') {
      // 3) 點陣紙：在交叉點繪製隱約的點
      final dotPaint = Paint()
        ..color = lineColor.withOpacity(0.6)
        ..style = PaintingStyle.fill;
      for (double y = gridSize; y < size.height; y += gridSize) {
        for (double x = gridSize; x < size.width; x += gridSize) {
          canvas.drawCircle(Offset(x, y), 1.2.w, dotPaint);
        }
      }
    } else if (paperStyle == 'cornell') {
      // 4) 康乃爾紙：右側區塊畫水平線，並繪製 Cue Column 與 Summary Column 紅線
      final double cueDivider = size.width * 0.28;
      final double summaryDivider = size.height * 0.82;

      // 筆記區（Notes Column）的水平線
      for (double y = gridSize * 2; y < summaryDivider; y += gridSize) {
        canvas.drawLine(Offset(cueDivider, y), Offset(size.width, y), paint);
      }

      // 畫分割紅線
      final dividerPaint = Paint()
        ..color = isDark ? const Color(0xFF4A282D) : const Color(0xFFF0ACB4)
        ..strokeWidth = 1.2.w;

      // 垂直分割線
      canvas.drawLine(Offset(cueDivider, 0), Offset(cueDivider, summaryDivider),
          dividerPaint);
      // 水平分割線
      canvas.drawLine(Offset(0, summaryDivider),
          Offset(size.width, summaryDivider), dividerPaint);
    }

    // 畫左側紅色筆記本邊緣線 (僅在非康乃爾樣式下畫，避免干擾康乃爾版面)
    if (paperStyle != 'cornell') {
      final marginPaint = Paint()
        ..color = isDark ? const Color(0xFF1E262F) : lineColor.withOpacity(0.8)
        ..strokeWidth = 1.w;

      final double leftMargin = 8.w;
      canvas.drawLine(
          Offset(leftMargin, 0), Offset(leftMargin, size.height), marginPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) =>
      oldDelegate.gridSize != gridSize ||
      oldDelegate.lineColor != lineColor ||
      oldDelegate.marginColor != marginColor ||
      oldDelegate.isDark != isDark ||
      oldDelegate.paperStyle != paperStyle;
}

/// 模擬實體卡片效果，可選擇加裝「金屬裝訂線圈」、「迴紋針」或「書籤」
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = isDark ? const Color(0xFF161C23) : Colors.white;
    final cardColor = backgroundColor ?? defaultBg;

    // 簡化為極簡紙片卡片，移除過度裝飾以釋放寬度與高度空間
    return Container(
      margin: margin ?? EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: isDark ? const Color(0xFF26323E) : const Color(0xFFECE6DB),
          width: 1.w,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding:
              padding ?? EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          child: child,
        ),
      ),
    );
  }
}

/// 繪製迴紋針 (Paper Clip)
class _PaperClipPainter extends CustomPainter {
  final bool isDark;
  _PaperClipPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark ? const Color(0xFF8D9CA4) : const Color(0xFF7F8C8D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0.w
      ..strokeCap = StrokeCap.round;

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0.w
      ..strokeCap = StrokeCap.round;

    final path = Path();
    // 迴紋針迴旋路徑
    path.moveTo(size.width * 0.5, size.height * 0.85);
    path.lineTo(size.width * 0.5, size.height * 0.25);
    path.arcTo(
      Rect.fromLTWH(size.width * 0.1, size.height * 0.05, size.width * 0.8,
          size.height * 0.4),
      3.14,
      3.14,
      false,
    );
    path.lineTo(size.width * 0.9, size.height * 0.65);
    path.arcTo(
      Rect.fromLTWH(size.width * 0.3, size.height * 0.45, size.width * 0.6,
          size.height * 0.4),
      0,
      3.14,
      false,
    );
    path.lineTo(size.width * 0.3, size.height * 0.35);

    // 畫陰影稍微位移
    canvas.drawPath(path.shift(Offset(1.w, 1.h)), shadowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 繪製書籤 (Bookmark)
class _BookmarkPainter extends CustomPainter {
  final Color color;
  _BookmarkPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width / 2, size.height * 0.75);
    path.lineTo(0, size.height);
    path.close();

    // 畫陰影
    canvas.drawShadow(path, Colors.black, 3, false);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 繪製單個活頁線圈 (Binder Ring)
class _BinderRingPainter extends CustomPainter {
  final bool isDark;
  _BinderRingPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    // 繪製穿孔小黑點
    final holePaint = Paint()
      ..color = isDark ? const Color(0xFF0F1216) : const Color(0xFFD2C7B8)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
        Offset(size.width * 0.7, size.height * 0.5), 3.w, holePaint);

    // 繪製金屬線圈
    final ringPaint = Paint()
      ..shader = LinearGradient(
        colors: isDark
            ? [
                const Color(0xFF4A5560),
                const Color(0xFF9EAEB8),
                const Color(0xFF4A5560)
              ]
            : [
                const Color(0xFF7F8C8D),
                const Color(0xFFBDC3C7),
                const Color(0xFF7F8C8D)
              ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0.w
      ..strokeCap = StrokeCap.round;

    final path = Path();
    // 線圈從紙外面扣進穿孔
    path.moveTo(0, size.height * 0.2);
    path.cubicTo(
      size.width * 0.3,
      size.height * 0.05,
      size.width * 0.7,
      size.height * 0.1,
      size.width * 0.7,
      size.height * 0.5,
    );
    path.cubicTo(
      size.width * 0.7,
      size.height * 0.9,
      size.width * 0.3,
      size.height * 0.95,
      0,
      size.height * 0.8,
    );

    canvas.drawPath(path, ringPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
