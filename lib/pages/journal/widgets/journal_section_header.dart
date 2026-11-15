import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:preamble/pages/journal/widgets/journal_palette.dart';
import 'package:preamble/theme/preamble_tokens.dart';

class JournalSectionHeader extends StatelessWidget {
  const JournalSectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.palette,
    this.actionLabel,
    this.onActionTap,
  });

  final String title;
  final String subtitle;
  final JournalPalette palette;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: t.serifTitle(
                  size: 18.sp,
                  weight: FontWeight.w800,
                  color: t.textPrimary,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                subtitle,
                style: t.sansBody(
                  size: 12.sp,
                  color: t.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        if (actionLabel != null) ...[
          SizedBox(width: 12.w),
          GestureDetector(
            onTap: onActionTap,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.only(top: 3.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    actionLabel!,
                    style: t.sansBody(
                      size: 12.sp,
                      weight: FontWeight.w700,
                      color: t.accentBrass,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Icon(
                    PhosphorIconsRegular.caretRight,
                    size: 14.sp,
                    color: t.accentBrass,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
