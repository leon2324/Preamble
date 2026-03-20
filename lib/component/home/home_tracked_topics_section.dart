import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/component/home/home_content.dart';
import 'package:lawapp/component/home/home_section_title.dart';
import 'package:lawapp/theme/app_colors.dart';

class HomeTrackedTopicsSection extends StatelessWidget {
  const HomeTrackedTopicsSection({
    super.key,
    required this.items,
  });

  static const double _itemGap = 18;

  final List<HomeTrackedTopic> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const HomeSectionTitle(title: '你關心的'),
        SizedBox(height: 20.h),
        ...List.generate(
          items.length,
          (index) => Padding(
            padding: EdgeInsets.only(
                bottom: index == items.length - 1 ? 0 : _itemGap.h),
            child: Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(22.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.chipSurface,
                            borderRadius: BorderRadius.circular(999.r),
                          ),
                          child: Text(
                            items[index].hashtag,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w400,
                              color: AppColors.primarySoft,
                            ),
                          ),
                        ),
                        SizedBox(height: _itemGap.h),
                        Text(
                          items[index].title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16.sp,
                            height: 1.25,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: _itemGap.h),
                        Text(
                          items[index].summary,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
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
            ),
          ),
        ),
      ],
    );
  }
}
