import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/features/case_time_machine/theme/case_time_machine_theme.dart';
import 'package:lawapp/features/case_time_machine/widgets/case_library_section_header.dart';
import 'package:lawapp/features/case_time_machine/widgets/case_time_machine_svg_icon.dart';

// 台灣繁體中文教學註解：
// 圖書館分館探索區塊。採用現代橫向扁平膠囊卡片設計：
// 移除木質卡片櫃抽屜拉手與標籤紙，改為乾淨的圓角色塊卡片，
// 頂部為圓底白色 icon，中間為粗體分類標題，底部為副標說明。
class CaseLibraryCategoryExploration extends StatelessWidget {
  const CaseLibraryCategoryExploration({
    super.key,
    required this.onOpenHall,
    required this.onViewAllTap,
  });

  final ValueChanged<String> onOpenHall;
  final VoidCallback onViewAllTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CaseLibrarySectionHeader(
          title: '圖書館分館',
          actionText: '查看全部',
          onActionTap: onViewAllTap,
        ),
        SizedBox(height: 9.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              SizedBox(
                width: 108.w,
                child: _CategoryPillButton(
                  backgroundColor: const Color(0xFFE9F2F1),
                  iconSvg: CtmSvgIcons.clock,
                  iconColor: const Color(0xFF1B5E55),
                  title: '依時間',
                  subtitle: '沿年代看案件',
                  onTap: () => onOpenHall('timeline'),
                ),
              ),
              SizedBox(width: 8.w),
              SizedBox(
                width: 108.w,
                child: _CategoryPillButton(
                  backgroundColor: const Color(0xFFEAF2F6),
                  iconSvg: CtmSvgIcons.grid,
                  iconColor: const Color(0xFF1F4E5B),
                  title: '依議題',
                  subtitle: '從爭點切入',
                  onTap: () => onOpenHall('theme'),
                ),
              ),
              SizedBox(width: 8.w),
              SizedBox(
                width: 108.w,
                child: _CategoryPillButton(
                  backgroundColor: const Color(0xFFFFF2CF),
                  iconSvg: CtmSvgIcons.star,
                  iconColor: const Color(0xFF8C642B),
                  title: '精選',
                  subtitle: '必看的案件',
                  onTap: () => onOpenHall('classic'),
                ),
              ),
              SizedBox(width: 8.w),
              SizedBox(
                width: 108.w,
                child: _CategoryPillButton(
                  backgroundColor: const Color(0xFFF3EAF6),
                  iconSvg: CtmSvgIcons.scale,
                  iconColor: const Color(0xFF6B457B),
                  title: '依狀態',
                  subtitle: '看發酵或落幕',
                  onTap: () => onOpenHall('status'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CategoryPillButton extends StatelessWidget {
  const _CategoryPillButton({
    required this.backgroundColor,
    required this.iconSvg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final Color backgroundColor;
  final String iconSvg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: iconColor.withValues(alpha: 0.15),
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 台灣繁體中文教學註解：圓底白色 icon 容器
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.75),
                  shape: BoxShape.circle,
                ),
                child: CtmSvgIcon(
                  iconSvg,
                  size: 16.sp,
                  color: iconColor,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w900,
                  color: CaseTimeMachineColors.primaryGreen,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9.5.sp,
                  fontWeight: FontWeight.w600,
                  color: iconColor.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
