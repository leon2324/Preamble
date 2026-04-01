import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/theme/app_colors.dart';

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
    final titleText = Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
        height: 1,
        fontWeight: FontWeight.w400,
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
