import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/features/case_library/data/case_library_data.dart';
import 'package:preamble/features/case_library/theme/case_library_theme.dart';
import 'package:preamble/features/case_library/widgets/_case_library_surface.dart';

Future<void> showLoginPromptBottomSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => Padding(
      padding: EdgeInsets.all(CaseLibrarySpacing.spaceL.w),
      child: CaseLibrarySurface(
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
                  color:
                      CaseLibraryColors.libraryMidnight.withValues(alpha: .82),
                  border: Border.all(
                    color: CaseLibraryColors.libraryBorderGold,
                  ),
                ),
                child: ClipOval(
                  child: Image.asset(
                    caseLibraryV2LoginLockEmblemAsset,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SizedBox(height: CaseLibrarySpacing.spaceL.h),
            Text('建立你的案件書櫃',
                style: CaseLibraryTextStyles.pageTitle(context)
                    .copyWith(fontSize: 23.sp)),
            SizedBox(height: CaseLibrarySpacing.spaceM.h),
            Text('登入後可以收藏案件、追蹤卷宗更新，並繼續閱讀你看過的案件。',
                style: CaseLibraryTextStyles.body(context)),
            SizedBox(height: CaseLibrarySpacing.spaceL.h),
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
