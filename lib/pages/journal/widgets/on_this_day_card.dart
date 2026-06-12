import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/features/on_this_day/pages/on_this_day_home_page.dart';
import 'package:lawapp/pages/journal/data/journal_page_items.dart';
import 'package:lawapp/pages/journal/widgets/journal_palette.dart';

const _onThisDayCardRadius = 20.0;

class OnThisDayCard extends StatelessWidget {
  const OnThisDayCard({super.key, required this.palette});

  final JournalPalette palette;

  @override
  Widget build(BuildContext context) {
    final item = onThisDayItem;
    final textScale = MediaQuery.textScalerOf(context).scale(1);

    return LayoutBuilder(
      builder: (context, constraints) {
        final useStackedLayout = constraints.maxWidth < 338 || textScale > 1.1;

        // 台灣繁體中文教學註解：
        // 這張卡改成完全由 Flutter 自己畫紙張、外框與插圖，
        // 不再依賴固定構圖的 PNG，之後想調留白、圓角或插圖透明度都能直接改程式。
        return _OnThisDayPaperCard(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 14.h),
            child: useStackedLayout
                ? _OnThisDayStackedLayout(item: item)
                : _OnThisDayFlowLayout(item: item),
          ),
        );
      },
    );
  }
}

class _OnThisDayPaperCard extends StatelessWidget {
  const _OnThisDayPaperCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_onThisDayCardRadius.r),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFCF6),
            Color(0xFFFDF6E7),
            Color(0xFFF8EEDB),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE4CFA7).withValues(alpha: 0.95),
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.85, -0.85),
                  radius: 1.25,
                  colors: [
                    const Color(0xFFF6E6C2).withValues(alpha: 0.34),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _PaperCardFramePainter(),
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            top: 48.h,
            width: 132.w,
            child: IgnorePointer(
              child: CustomPaint(
                painter: _MemoryCornerIllustrationPainter(),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _OnThisDayFlowLayout extends StatelessWidget {
  const _OnThisDayFlowLayout({required this.item});

  final OnThisDayItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.label,
          style: TextStyle(
            fontSize: 15.5.sp,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF43372A),
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 112.w,
              child: _MemoryDateBadge(
                item: item,
                yearSize: 10.sp,
                monthDaySize: 32.sp,
                locationSize: 10.1.sp,
                padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 14.h),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _MemoryStoryFlow(
                item: item,
                titleSize: 19.sp,
                bodySize: 11.8.sp,
                quoteSize: 11.1.sp,
                buttonSize: 11.5.sp,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _OnThisDayStackedLayout extends StatelessWidget {
  const _OnThisDayStackedLayout({required this.item});

  final OnThisDayItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.label,
          style: TextStyle(
            fontSize: 14.2.sp,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF43372A),
          ),
        ),
        SizedBox(height: 10.h),
        _MemoryDateBadge(
          item: item,
          yearSize: 9.6.sp,
          monthDaySize: 28.sp,
          locationSize: 9.8.sp,
          padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 14.h),
        ),
        SizedBox(height: 12.h),
        _MemoryStoryFlow(
          item: item,
          titleSize: 17.2.sp,
          bodySize: 10.9.sp,
          quoteSize: 10.5.sp,
          buttonSize: 10.9.sp,
        ),
      ],
    );
  }
}

class _MemoryDateBadge extends StatelessWidget {
  const _MemoryDateBadge({
    required this.item,
    required this.yearSize,
    required this.monthDaySize,
    required this.locationSize,
    required this.padding,
  });

  final OnThisDayItem item;
  final double yearSize;
  final double monthDaySize;
  final double locationSize;
  final EdgeInsets padding;

  String get _yearLabel => item.fullDate.split('.').first;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.82,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 6.w,
            right: 0,
            bottom: -5.h,
            top: 12.h,
            child: _MemoryDateBadgeLayer(
              offsetTint: const Color(0xFFE4C995),
              rotation: -0.04,
            ),
          ),
          Positioned(
            left: 3.w,
            right: 3.w,
            bottom: -2.h,
            top: 6.h,
            child: _MemoryDateBadgeLayer(
              offsetTint: const Color(0xFFECD7AE),
              rotation: -0.02,
            ),
          ),
          Positioned.fill(
            child: _MemoryDateBadgeSheet(
              yearLabel: _yearLabel,
              monthDay: item.monthDay,
              location: item.location,
              yearSize: yearSize,
              monthDaySize: monthDaySize,
              locationSize: locationSize,
              padding: padding,
            ),
          ),
          Positioned(
            top: -2.h,
            left: 18.w,
            child: const _MemoryBindingRing(),
          ),
          Positioned(
            top: -2.h,
            right: 18.w,
            child: const _MemoryBindingRing(),
          ),
        ],
      ),
    );
  }
}

class _MemoryDateBadgeLayer extends StatelessWidget {
  const _MemoryDateBadgeLayer({
    required this.offsetTint,
    required this.rotation,
  });

  final Color offsetTint;
  final double rotation;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        decoration: BoxDecoration(
          color: offsetTint.withValues(alpha: 0.54),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: const Color(0xFFD0B27B).withValues(alpha: 0.52),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemoryDateBadgeSheet extends StatelessWidget {
  const _MemoryDateBadgeSheet({
    required this.yearLabel,
    required this.monthDay,
    required this.location,
    required this.yearSize,
    required this.monthDaySize,
    required this.locationSize,
    required this.padding,
  });

  final String yearLabel;
  final String monthDay;
  final String location;
  final double yearSize;
  final double monthDaySize;
  final double locationSize;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFCF7),
            Color(0xFFFBF1D8),
          ],
        ),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: const Color(0xFFD9BC84).withValues(alpha: 0.98),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFCFAE71).withValues(alpha: 0.16),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _MemoryDateBadgePainter(),
            ),
          ),
          Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 12.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFF6E8C1),
                        Color(0xFFEFD7A2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Text(
                    yearLabel,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: yearSize,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF6A5842),
                      letterSpacing: 1.6,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  monthDay,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: monthDaySize,
                    height: 0.94,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF16504A),
                  ),
                ),
                const Spacer(),
                Text(
                  location,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: locationSize,
                    height: 1.35,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF6A5842),
                  ),
                ),
                SizedBox(height: 4.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MemoryBindingRing extends StatelessWidget {
  const _MemoryBindingRing();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18.w,
      height: 46.h,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: 14.w,
            height: 42.h,
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
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(3.w),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF7E8),
                  borderRadius: BorderRadius.circular(999.r),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 4.h,
            child: Container(
              width: 18.w,
              height: 12.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF86642C).withValues(alpha: 0.45),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 3,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MemoryStoryFlow extends StatelessWidget {
  const _MemoryStoryFlow({
    required this.item,
    required this.titleSize,
    required this.bodySize,
    required this.quoteSize,
    required this.buttonSize,
  });

  final OnThisDayItem item;
  final double titleSize;
  final double bodySize;
  final double quoteSize;
  final double buttonSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.title,
          style: TextStyle(
            fontSize: titleSize,
            height: 1.16,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF43372A),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          item.summary,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: bodySize,
            height: 1.55,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF5F5548),
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 10.h),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF9EE).withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: const Color(0xFFD5C3A3).withValues(alpha: 0.8),
            ),
          ),
          child: Text(
            '「${item.quote}」',
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: quoteSize,
              height: 1.55,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF6C5437),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Align(
          alignment: Alignment.centerRight,
          child: _MemoryArrowButton(
            label: item.buttonLabel,
            fontSize: buttonSize,
            onTap: () => Navigator.of(context).push(
              CupertinoPageRoute<void>(
                builder: (__) => const OnThisDayHomePage(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PaperCardFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final outer = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(20.r),
    );
    final inner = RRect.fromRectAndRadius(
      Rect.fromLTWH(10.w, 10.h, size.width - 20.w, size.height - 20.h),
      Radius.circular(18.r),
    );
    final borderPaint = Paint()
      ..color = const Color(0xFFD6BC8F).withValues(alpha: 0.82)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15;
    final innerPaint = Paint()
      ..color = const Color(0xFFEAD6AF).withValues(alpha: 0.76)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.75;

    canvas.drawRRect(outer.deflate(1), borderPaint);
    canvas.drawRRect(inner, innerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MemoryDateBadgePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final dividerY = size.height * 0.42;
    final shadowPaint = Paint()
      ..color = const Color(0xFFE7D7B5).withValues(alpha: 0.72)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2);
    final linePaint = Paint()
      ..color = const Color(0xFFD9C49A).withValues(alpha: 0.92)
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(22, dividerY + 1.5),
      Offset(size.width - 22, dividerY + 1.5),
      shadowPaint,
    );
    canvas.drawLine(
      Offset(22, dividerY),
      Offset(size.width - 22, dividerY),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MemoryCornerIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final branchPaint = Paint()
      ..color = const Color(0xFFCDB38A).withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.1
      ..strokeCap = StrokeCap.round;
    final leafPaint = Paint()
      ..color = const Color(0xFFD9C39A).withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;
    final buildingPaint = Paint()
      ..color = const Color(0xFFC7AE83).withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.7;

    final trunk = Path()
      ..moveTo(size.width * 0.72, size.height)
      ..quadraticBezierTo(
        size.width * 0.66,
        size.height * 0.78,
        size.width * 0.56,
        size.height * 0.52,
      )
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.35,
        size.width * 0.58,
        size.height * 0.08,
      );
    canvas.drawPath(trunk, branchPaint);

    for (final leaf in _leafCenters(size)) {
      canvas.drawOval(
        Rect.fromCenter(
          center: leaf,
          width: size.width * 0.12,
          height: size.height * 0.06,
        ),
        leafPaint,
      );
    }

    final baseY = size.height * 0.84;
    final centerX = size.width * 0.38;
    final width = size.width * 0.34;
    final height = size.height * 0.28;
    final left = centerX - (width / 2);
    final right = centerX + (width / 2);
    final top = baseY - height;

    final building = Path()
      ..moveTo(left, baseY)
      ..lineTo(right, baseY)
      ..moveTo(left + 8, baseY)
      ..lineTo(left + 8, top + 18)
      ..lineTo(right - 8, top + 18)
      ..lineTo(right - 8, baseY)
      ..moveTo(left - 2, top + 18)
      ..lineTo(centerX, top)
      ..lineTo(right + 2, top + 18)
      ..moveTo(centerX - 12, baseY)
      ..lineTo(centerX - 12, top + 32)
      ..lineTo(centerX + 12, top + 32)
      ..lineTo(centerX + 12, baseY);
    canvas.drawPath(building, buildingPaint);

    for (var index = 0; index < 4; index++) {
      final columnX = left + 20 + (index * ((width - 40) / 3));
      canvas.drawLine(
        Offset(columnX, top + 24),
        Offset(columnX, baseY),
        buildingPaint,
      );
    }
  }

  Iterable<Offset> _leafCenters(Size size) {
    return [
      Offset(size.width * 0.46, size.height * 0.18),
      Offset(size.width * 0.58, size.height * 0.24),
      Offset(size.width * 0.72, size.height * 0.16),
      Offset(size.width * 0.68, size.height * 0.3),
      Offset(size.width * 0.82, size.height * 0.26),
      Offset(size.width * 0.64, size.height * 0.4),
      Offset(size.width * 0.8, size.height * 0.42),
    ];
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MemoryArrowButton extends StatelessWidget {
  const _MemoryArrowButton({
    required this.label,
    required this.fontSize,
    required this.onTap,
  });

  final String label;
  final double fontSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999.r),
        onTap: onTap,
        child: Ink(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF4DE).withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(999.r),
            border: Border.all(
              color: const Color(0xFFD0B58A).withValues(alpha: 0.9),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF5D472D),
                ),
              ),
              SizedBox(width: 6.w),
              Icon(
                CupertinoIcons.arrow_right,
                size: 13.sp,
                color: const Color(0xFF5D472D),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
