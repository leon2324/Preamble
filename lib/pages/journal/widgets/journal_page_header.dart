import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:preamble/pages/journal/widgets/journal_palette.dart';
import 'package:preamble/theme/preamble_tokens.dart';

/// 紀事策展頁靜奢編輯刊頭 (Quiet Luxury Editorial Masthead)。
class JournalPageHeader extends StatelessWidget {
  const JournalPageHeader({
    super.key,
    required this.palette,
    this.isSearchOpen = false,
    this.onToggleSearch,
  });

  final JournalPalette palette;
  final bool isSearchOpen;
  final VoidCallback? onToggleSearch;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: t.accentBrassContainer,
                  borderRadius: BorderRadius.circular(99.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      PhosphorIconsRegular.bookOpenText,
                      size: 13.sp,
                      color: t.accentOnBrassContainer,
                    ),
                    SizedBox(width: 5.w),
                    Flexible(
                      child: Text(
                        '生活故事與紀錄',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.sansTitle(
                          size: 11.sp,
                          color: t.accentOnBrassContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 8.w),
            if (onToggleSearch != null)
              GestureDetector(
                onTap: onToggleSearch,
                child: Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: isSearchOpen ? t.brandContainer : t.surface,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: t.shadowAmbient,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    isSearchOpen
                        ? PhosphorIconsRegular.x
                        : PhosphorIconsRegular.magnifyingGlass,
                    size: 17.sp,
                    color: isSearchOpen ? t.brandPrimary : t.textSecondary,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 8.h),
        Text(
          '紀事與案件夾',
          style: t.serifTitle(
            size: 25.sp,
            weight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          '看看台灣發生過的真實案例故事，也能把自己的處理進度整理在這裡。',
          style: t.sansBody(
            size: 12.5.sp,
            color: t.textSecondary,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}
