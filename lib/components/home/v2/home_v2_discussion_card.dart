import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/components/home/v2/home_v2_palette.dart';
import 'package:lawapp/components/home/v2/home_v2_primitives.dart';
import 'package:lawapp/theme/app_colors.dart';

// 首頁 V2 的熱門討論摘要卡。
// 只放靜態摘要與指標 chip，不放社群列表與導航邏輯。

class HomeV2DiscussionCard extends StatelessWidget {
  const HomeV2DiscussionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return HomeV2SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HomeV2TinyLabel(
            icon: Icons.forum_outlined,
            label: '熱門討論',
            color: HomeV2Palette.trustGreen,
          ),
          SizedBox(height: 8.h),
          Text(
            '即將釋憲，究竟廢死還是維持死刑？',
            style: TextStyle(
              color: HomeV2Palette.ink,
              fontSize: 16.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '由查詢次數、新聞熱度與社群討論訊號彙整，協助一般民眾理解爭點。',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11.sp,
              height: 1.45,
            ),
          ),
          SizedBox(height: 12.h),
          const Row(
            children: [
              _MetricChip(label: '熱度 92'),
              _MetricChip(label: '上升 12%'),
              _MetricChip(label: '#憲法'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: HomeV2Palette.mint,
          borderRadius: BorderRadius.circular(99.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: HomeV2Palette.trustGreen,
            fontSize: 11.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
