import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/components/home/v2/home_v2_palette.dart';
import 'package:lawapp/components/home/v2/home_v2_primitives.dart';
import 'package:lawapp/theme/app_colors.dart';

class HomeV2HeroHeader extends StatelessWidget {
  const HomeV2HeroHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'The Law App',
                    style: TextStyle(
                      color: HomeV2Palette.ink,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                      height: 1.05,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '讓法律更懂你',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const _HeaderIcon(icon: Icons.notifications_none_rounded),
            SizedBox(width: 10.w),
            const _HeaderAvatar(),
          ],
        ),
        SizedBox(height: 16.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 10.h),
          decoration: BoxDecoration(
            color: HomeV2Palette.trustGreen,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(99.r),
                ),
                child: Text(
                  '新修正',
                  style: TextStyle(
                    color: const Color(0xFFFFD36D),
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  '道路交通管理處罰條例修正',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.white.withValues(alpha: 0.9),
                size: 20.sp,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class HomeV2GreetingCard extends StatelessWidget {
  const HomeV2GreetingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return HomeV2SurfaceCard(
      padding: EdgeInsets.fromLTRB(18.w, 16.h, 14.w, 16.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '早安，Leon',
                  style: TextStyle(
                    color: HomeV2Palette.ink,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '今天有 3 則與你相關的法律更新',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const HomeV2SmallPill(
            label: '查看全部',
            icon: Icons.chevron_right_rounded,
            background: Colors.white,
            borderColor: AppColors.border,
            textColor: HomeV2Palette.ink,
          ),
        ],
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38.w,
      height: 38.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Icon(icon, color: HomeV2Palette.trustGreen, size: 21.sp),
    );
  }
}

class _HeaderAvatar extends StatelessWidget {
  const _HeaderAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: const BoxDecoration(
        color: HomeV2Palette.trustGreen,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.person_rounded, color: Colors.white, size: 25.sp),
    );
  }
}
