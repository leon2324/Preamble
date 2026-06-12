import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/features/case_time_machine/theme/case_time_machine_theme.dart';
import 'package:lawapp/features/case_time_machine/widgets/case_time_machine_svg_icon.dart';

// 台灣繁體中文教學註解：
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
          style: CaseTimeMachineTextStyles.sectionTitle(context).copyWith(
            fontSize: 15.sp,
            fontWeight: FontWeight.w900,
            color: CaseTimeMachineColors.primaryGreen,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onActionTap,
          child: Row(
            children: [
              Text(
                actionText,
                style: CaseTimeMachineTextStyles.caption(context).copyWith(
                  color: CaseTimeMachineColors.textMuted,
                  fontWeight: FontWeight.w800,
                ),
              ),
              CtmSvgIcon(
                CtmSvgIcons.chevronRight,
                size: 16.sp,
                color: CaseTimeMachineColors.textMuted,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
