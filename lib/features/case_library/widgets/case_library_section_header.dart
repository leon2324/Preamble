import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/features/case_library/theme/case_library_theme.dart';
import 'package:preamble/features/case_library/widgets/case_library_svg_icon.dart';

// 獨立出來的區塊標題元件，帶有右側的「查看全部」或「查找卷宗」等點擊動作按鈕。
class CaseLibrarySectionHeader extends StatelessWidget {
  const CaseLibrarySectionHeader({
    super.key,
    required this.title,
    required this.actionText,
    required this.onActionTap,
  });

  final String title;
  final String actionText;
  final VoidCallback onActionTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: CaseLibraryTextStyles.sectionTitle(context).copyWith(
            fontSize: 15.sp,
            fontWeight: FontWeight.w900,
            color: CaseLibraryColors.primaryGreen,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onActionTap,
          child: Row(
            children: [
              Text(
                actionText,
                style: CaseLibraryTextStyles.caption(context).copyWith(
                  color: CaseLibraryColors.textMuted,
                  fontWeight: FontWeight.w800,
                ),
              ),
              CaseLibrarySvgIcon(
                CaseLibrarySvgIcons.chevronRight,
                size: 16.sp,
                color: CaseLibraryColors.textMuted,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
