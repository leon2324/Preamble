import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 筆記本方格紙背景
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
    
    // 深色模式下的格線顏色
    final actualLineColor = isDark ? const Color(0xFF1E262F) : lineColor;
    final actualMarginColor = isDark ? const Color(0xFF3A2327) : marginColor;
    final actualBgColor = isDark ? const Color(0xFF0F1216) : const Color(0xFFFCFBF9);

    return Container(
      color: actualBgColor,
      child: CustomPaint(
        painter: _GridPainter(
          gridSize: gridSize.w,
          lineColor: actualLineColor,
          marginColor: actualMarginColor,
          isDark: isDark,
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
  });

  final double gridSize;
  final Color lineColor;
  final Color marginColor;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 0.8.w;

    // 畫水平格線
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // 畫垂直格線
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // 畫左側紅色筆記本邊緣線 (簡化為單一淡線，靠邊 8.w，避免佔用大量水平空間)
    final marginPaint = Paint()
      ..color = isDark ? const Color(0xFF1E262F) : lineColor.withValues(alpha: 0.8)
      ..strokeWidth = 1.w;
    
    final double leftMargin = 8.w;
    canvas.drawLine(Offset(leftMargin, 0), Offset(leftMargin, size.height), marginPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
          padding: padding ?? EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
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
      Rect.fromLTWH(size.width * 0.1, size.height * 0.05, size.width * 0.8, size.height * 0.4),
      3.14,
      3.14,
      false,
    );
    path.lineTo(size.width * 0.9, size.height * 0.65);
    path.arcTo(
      Rect.fromLTWH(size.width * 0.3, size.height * 0.45, size.width * 0.6, size.height * 0.4),
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
    
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.5), 3.w, holePaint);

    // 繪製金屬線圈
    final ringPaint = Paint()
      ..shader = LinearGradient(
        colors: isDark
            ? [const Color(0xFF4A5560), const Color(0xFF9EAEB8), const Color(0xFF4A5560)]
            : [const Color(0xFF7F8C8D), const Color(0xFFBDC3C7), const Color(0xFF7F8C8D)],
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
