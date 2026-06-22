import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/components/home/v2/home_v2_palette.dart';
import 'package:lawapp/theme/app_colors.dart';

// 首頁子頁共用的基礎 UI 元件。
// 只放跨子頁使用的標題、返回列、狀態卡與小標籤，不放頁面資料或導航流程。

class SubpageHero extends StatelessWidget {
  const SubpageHero({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final shouldStack = MediaQuery.sizeOf(context).width < 340 ||
        MediaQuery.textScalerOf(context).scale(1) > 1.18;
    final iconWidget = Icon(icon, color: HomeV2Palette.trustGreen, size: 30.sp);

    Widget buildTextColumn() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 22.sp,
              height: 1.16,
              fontWeight: FontWeight.w900,
              color: HomeV2Palette.ink,
            ),
          ),
          SizedBox(height: 7.h),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12.sp,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      );
    }

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
      ),
      child: shouldStack
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                iconWidget,
                SizedBox(height: 10.h),
                buildTextColumn(),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                iconWidget,
                SizedBox(width: 12.w),
                Expanded(child: buildTextColumn()),
              ],
            ),
    );
  }
}

class SubpageTopBar extends StatelessWidget {
  const SubpageTopBar({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: onBack,
          child: SizedBox(
            width: 42.w,
            height: 42.w,
            child: Icon(Icons.arrow_back_ios_new_rounded, size: 20.sp),
          ),
        ),
      ],
    );
  }
}

class SubpageStatusCard extends StatelessWidget {
  const SubpageStatusCard({
    super.key,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: TextStyle(
              fontSize: 13.sp,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            SizedBox(height: 10.h),
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

class TinySourceLabel extends StatelessWidget {
  const TinySourceLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: HomeV2Palette.mint,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5.sp,
          fontWeight: FontWeight.w800,
          color: HomeV2Palette.trustGreen,
        ),
      ),
    );
  }
}
