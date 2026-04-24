import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/components/home/home_content.dart';
import 'package:lawapp/components/home/home_section_title.dart';
import 'package:lawapp/theme/app_colors.dart';

/// 首頁「你關心的」區塊，用較短的清單形式呈現追蹤議題。
class HomeTrackedTopicsSection extends StatelessWidget {
  const HomeTrackedTopicsSection({
    super.key,
    required this.items,
    required this.onMoreTap,
  });

  static const double _itemGap = 16;

  final List<HomeTrackedTopic> items;
  final VoidCallback onMoreTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeSectionTitle(title: '你關心的', onTap: onMoreTap),
        SizedBox(height: 15.h),
        ...List.generate(
          items.length,
          (index) => Padding(
            padding: EdgeInsets.only(
                bottom: index == items.length - 1 ? 0 : _itemGap.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 15.w),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.chipSurface.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                    child: Text(
                      items[index].hashtag,
                      style: TextStyle(
                        fontSize: 10.sp,
                        height: 1,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primarySoft.withValues(alpha: 0.88),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Padding(
                        padding:
                            EdgeInsets.only(top: 2.h, right: 10.w, left: 15.w),
                        child: Text(
                          items[index].title,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15.sp,
                            height: 1.28,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: _itemGap.w),
                    Container(
                      width: 116.w,
                      height: 84.h,
                      decoration: BoxDecoration(
                        color: AppColors.placeholder,
                        borderRadius: BorderRadius.circular(18.r),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
