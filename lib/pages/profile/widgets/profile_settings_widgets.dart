import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:preamble/theme/preamble_tokens.dart';

/// 群組化設定列表組件（全面採用 `context.tokens` 靜奢 `20.r` 卡片與淺深色模式）。
class GroupedSettingsList extends StatelessWidget {
  const GroupedSettingsList({
    super.key,
    required this.title,
    required this.tiles,
  });

  final String title;
  final List<SettingsTile> tiles;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
          child: Text(
            title,
            style: t.sansBody(
              size: 12.5.sp,
              weight: FontWeight.w700,
              color: t.textSecondary,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          decoration: t.cardDecoration(radius: 20.r, elevated: false),
          child: Column(
            children: List.generate(tiles.length, (index) {
              final tile = tiles[index];
              final isLast = index == tiles.length - 1;
              return Column(
                children: [
                  tile,
                  if (!isLast)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: t.border,
                      indent: 52.w,
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

/// 個別設定項目（支援 Dynamic Type 大字級零溢位與深淺色高對比圖示）。
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.iconColor,
    this.iconBgColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color? iconBgColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.5.h),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: iconBgColor ?? iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11.r),
                ),
                child: Icon(icon, color: iconColor, size: 18.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: t.sansTitle(size: 14.sp),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: 2.h),
                      Text(
                        subtitle!,
                        style: t.sansBody(
                          size: 11.5.sp,
                          color: t.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                SizedBox(width: 8.w),
                trailing!,
              ] else if (onTap != null) ...[
                SizedBox(width: 8.w),
                Icon(
                  PhosphorIconsRegular.caretRight,
                  color: t.textMuted,
                  size: 15.sp,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
