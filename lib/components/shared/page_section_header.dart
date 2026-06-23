import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 搜尋頁上方的大標題區塊。
///
/// `stretch` 會隨 overscroll 微幅放大標題，讓頁首更有彈性手感。
class PageSectionHeader extends StatelessWidget {
  const PageSectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.stretch = 0,
    this.titleColor = const Color(0xFF101828),
    this.titleSize = 28,
    this.subtitleColor = const Color(0xFF667085),
  });

  final String title;
  final String subtitle;
  final double stretch;
  final Color titleColor;
  final double titleSize;
  final Color subtitleColor;

  @override
  Widget build(BuildContext context) {
    final clampedStretch = stretch.clamp(0.0, 36.0);
    final titleScale = 1 + (clampedStretch / 240);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Transform.scale(
          scale: titleScale,
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: TextStyle(
              fontSize: titleSize.sp,
              fontWeight: FontWeight.w800,
              color: titleColor,
            ),
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14.sp,
            height: 1.5,
            color: subtitleColor,
          ),
        ),
      ],
    );
  }
}
