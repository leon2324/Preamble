import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/component/home/home_content.dart';
import 'package:lawapp/component/home/home_section_title.dart';
import 'package:lawapp/theme/app_colors.dart';

class HomeNewsletterSection extends StatelessWidget {
  const HomeNewsletterSection({
    super.key,
    required this.controller,
    required this.items,
    required this.currentPage,
    required this.onPageChanged,
  });

  static const double _itemGap = 14;
  static const double _cardHeight = 225;

  final PageController controller;
  final List<HomeNewsletterItem> items;
  final int currentPage;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const HomeSectionTitle(title: '法律新知小報'),
        SizedBox(height: 20.h),
        SizedBox(
          height: _cardHeight.h,
          child: PageView.builder(
            controller: controller,
            itemCount: items.length,
            onPageChanged: onPageChanged,
            itemBuilder: (context, index) =>
                _NewsletterCard(item: items[index]),
          ),
        ),
        SizedBox(height: _itemGap.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            items.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              margin: EdgeInsets.symmetric(horizontal: 3.w),
              width: currentPage == index ? 14.w : 6.w,
              height: 6.w,
              decoration: BoxDecoration(
                color: currentPage == index
                    ? AppColors.accent.withValues(alpha: 0.7)
                    : const Color(0xFFD8D0C4),
                borderRadius: BorderRadius.circular(999.r),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NewsletterCard extends StatelessWidget {
  const _NewsletterCard({required this.item});

  final HomeNewsletterItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 4.w),
      padding: EdgeInsets.fromLTRB(12.w, 16.w, 10.w, 10.w),
      decoration: BoxDecoration(
        color: AppColors.newsletterSurface,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B6A3C).withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 19.sp,
                    height: 1.15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2B4499),
                  ),
                ),
                SizedBox(height: 12.h),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.summary,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13.sp,
                                height: 1.45,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF8A8A8A),
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              item.tip,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.sp,
                                height: 1.2,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF46A01E),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 14.w),
                      Padding(
                        padding: EdgeInsets.only(top: 4.h),
                        child: const _NewsletterImageCard(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _Action(
                  icon: Icons.favorite_border_rounded,
                  color: const Color(0xFFD85A53),
                  label: item.likes,
                ),
                _Action(
                  icon: Icons.share_outlined,
                  color: const Color(0xFF9B874A),
                  label: item.shares,
                ),
                _Action(
                  icon: Icons.comment_rounded,
                  color: const Color(0xFF4F8F36),
                  label: item.comments,
                ),
                _Action(
                  icon: Icons.download_rounded,
                  color: const Color(0xFF4A8E88),
                  label: item.downloads,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NewsletterImageCard extends StatelessWidget {
  const _NewsletterImageCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130.w,
      height: 110.h,
      decoration: BoxDecoration(
        color: const Color(0xFFB9B4B4),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Text(
            '跟內容有關的小插圖',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.icon,
    required this.color,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color.withValues(alpha: 0.92), size: 19.sp),
        SizedBox(width: 5.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary.withValues(alpha: 0.72),
          ),
        ),
      ],
    );
  }
}
