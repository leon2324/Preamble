import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/theme/app_colors.dart';

/// 首頁各區塊共用的標題列。
///
/// 若有 `onTap`，整列都會變成可點擊區塊，右側自動補一顆箭頭。
class HomeSectionTitle extends StatelessWidget {
  const HomeSectionTitle({
    super.key,
    required this.title,
    this.onTap,
  });

  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // 首頁區塊標題和學習頁標題統一使用較重的字重，
    // 讓使用者掃視頁面時可以更快辨認每個內容分區。
    final titleText = Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
        height: 1,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      strutStyle: const StrutStyle(
        height: 1,
        forceStrutHeight: true,
        leading: 0,
      ),
      textHeightBehavior: const TextHeightBehavior(
        applyHeightToFirstAscent: false,
        applyHeightToLastDescent: false,
      ),
    );

    return Transform.translate(
      offset: Offset(0, -7.h),
      child: onTap == null
          ? titleText
          : Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(12.r),
                splashFactory: NoSplash.splashFactory,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                focusColor: Colors.transparent,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.h),
                  child: Row(
                    children: [
                      titleText,
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 20.sp,
                        color: AppColors.textPrimary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
