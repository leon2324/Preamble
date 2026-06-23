import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/components/home/v2/home_v2_palette.dart';
import 'package:lawapp/theme/app_colors.dart';

class HomeV2SectionHeader extends StatelessWidget {
  const HomeV2SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onTap,
  });

  final String title;
  final String? action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: HomeV2Palette.ink,
              fontSize: 16.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        if (action != null && onTap != null)
          Semantics(
            button: true,
            label: action,
            onTap: onTap,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(99.r),
                child: SizedBox(
                  width: 28.w,
                  height: 28.w,
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textPrimary,
                    size: 24.sp,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class HomeV2SurfaceCard extends StatelessWidget {
  const HomeV2SurfaceCard({
    super.key,
    required this.child,
    this.color = Colors.white,
    this.padding,
  });

  final Widget child;
  final Color color;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.72)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class HomeV2TinyLabel extends StatelessWidget {
  const HomeV2TinyLabel({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16.sp),
        SizedBox(width: 5.w),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class HomeV2SmallPill extends StatelessWidget {
  const HomeV2SmallPill({
    super.key,
    required this.label,
    this.icon,
    this.background = const Color(0xFFF1F5F9),
    this.borderColor,
    this.textColor = AppColors.textSecondary,
  });

  final String label;
  final IconData? icon;
  final Color background;
  final Color? borderColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10.w,
        vertical: textScale > 1.15 ? 7.h : 6.h,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(99.r),
        border: borderColor == null ? null : Border.all(color: borderColor!),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 3.w,
        children: [
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 10.sp,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          if (icon != null) Icon(icon, color: textColor, size: 15.sp),
        ],
      ),
    );
  }
}
