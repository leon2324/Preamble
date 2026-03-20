import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/theme/app_colors.dart';

class HomeSectionTitle extends StatelessWidget {
  const HomeSectionTitle({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, -2.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 22.sp,
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
      ),
    );
  }
}
