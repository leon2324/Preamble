import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/pages/journal/widgets/journal_palette.dart';

class JournalSectionHeader extends StatelessWidget {
  const JournalSectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.palette,
    this.actionLabel,
  });

  final String title;
  final String subtitle;
  final JournalPalette palette;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    // 主頁所有區塊標題都走同一個元件，日後調字級或間距時只要改這裡。
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18.5.sp,
                  fontWeight: FontWeight.w900,
                  color: palette.primaryText,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11.5.sp,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                  color: palette.secondaryText,
                ),
              ),
            ],
          ),
        ),
        if (actionLabel != null) ...[
          SizedBox(width: 12.w),
          Padding(
            padding: EdgeInsets.only(top: 3.h),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  actionLabel!,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: palette.primaryText,
                  ),
                ),
                SizedBox(width: 3.w),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18.sp,
                  color: palette.primaryText,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
