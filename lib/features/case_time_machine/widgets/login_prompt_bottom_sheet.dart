import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/features/case_time_machine/data/case_time_machine_mock_data.dart';
import 'package:lawapp/features/case_time_machine/theme/case_time_machine_theme.dart';
import 'package:lawapp/features/case_time_machine/widgets/_ctm_surface.dart';

Future<void> showLoginPromptBottomSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => Padding(
      padding: EdgeInsets.all(CaseTimeMachineSpacing.spaceL.w),
      child: CtmSurface(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 118.w,
                height: 118.w,
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: CaseTimeMachineColors.libraryMidnight
                      .withValues(alpha: .82),
                  border: Border.all(
                    color: CaseTimeMachineColors.libraryBorderGold,
                  ),
                ),
                child: ClipOval(
                  child: Image.asset(
                    caseTimeMachineV2LoginLockEmblemAsset,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SizedBox(height: CaseTimeMachineSpacing.spaceL.h),
            Text('建立你的案件書櫃',
                style: CaseTimeMachineTextStyles.pageTitle(context)
                    .copyWith(fontSize: 23.sp)),
            SizedBox(height: CaseTimeMachineSpacing.spaceM.h),
            Text('登入後可以收藏案件、追蹤卷宗更新，並繼續閱讀你看過的案件。',
                style: CaseTimeMachineTextStyles.body(context)),
            SizedBox(height: CaseTimeMachineSpacing.spaceL.h),
            FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('登入 / 註冊')),
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('稍後再說')),
          ],
        ),
      ),
    ),
  );
}
