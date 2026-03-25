import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/components/home/home_section_title.dart';
import 'package:lawapp/theme/app_colors.dart';

class HomeDiscussionSection extends StatelessWidget {
  const HomeDiscussionSection({super.key});

  static const double _itemGap = 18;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const HomeSectionTitle(title: '大家都在討論'),
        SizedBox(height: 20.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.discussionSurface,
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '即將釋憲，究竟廢死還是維持死刑？',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF16243D),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.trending_up_rounded,
                    color: AppColors.info,
                    size: 24.sp,
                  ),
                ],
              ),
              SizedBox(height: _itemGap.h),
              Container(
                height: 118.h,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: Center(
                  child: Text(
                    '趨勢圖與討論熱度預覽',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF52607A),
                    ),
                  ),
                ),
              ),
              SizedBox(height: _itemGap.h),
              Text(
                '近日因死刑釋憲案再度成為焦點，相關新聞、社群討論與留言量同步升高，成為最近最多人想表態的議題。',
                style: TextStyle(
                  fontSize: 13.sp,
                  height: 1.55,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF23314D),
                ),
              ),
              SizedBox(height: _itemGap.h),
              Wrap(
                spacing: _itemGap.w,
                runSpacing: _itemGap.h,
                children: const [
                  _DiscussionButton(
                      label: '查看更多留言', backgroundColor: Color(0xFFA8B9F2)),
                  _DiscussionButton(
                      label: '追蹤', backgroundColor: Color(0xFF9AB6E3)),
                  _DiscussionButton(
                      label: '進入議題', backgroundColor: Color(0xFFE8C98F)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DiscussionButton extends StatelessWidget {
  const _DiscussionButton({
    required this.label,
    required this.backgroundColor,
  });

  final String label;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
