import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/components/home/home_content.dart';
import 'package:lawapp/components/home/v2/home_v2_palette.dart';
import 'package:lawapp/theme/app_colors.dart';

// 首頁 V2 的生活法律提醒卡片群。
// 只放 Newsletter / 生活避坑筆記相關 UI，不放首頁路由與資料載入邏輯。

class HomeV2NewsletterCard extends StatefulWidget {
  const HomeV2NewsletterCard({
    super.key,
    required this.item,
    this.onTap,
  });

  final HomeNewsletterItem item;
  final VoidCallback? onTap;

  @override
  State<HomeV2NewsletterCard> createState() => _HomeV2NewsletterCardState();
}

class _HomeV2NewsletterCardState extends State<HomeV2NewsletterCard> {
  var _isLiked = false;
  var _isBookmarked = false;
  var _shareCountDelta = 0;
  var _commentCountDelta = 0;

  HomeNewsletterItem get item => widget.item;

  int _metricBase(String value) {
    final digits = RegExp(r'\d+').firstMatch(value)?.group(0);
    return int.tryParse(digits ?? '') ?? 0;
  }

  String _metricText(String value, int delta) {
    final next = _metricBase(value) + delta;
    return '$next+';
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
    });
  }

  void _share() {
    setState(() {
      _shareCountDelta += 1;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已複製分享連結示意。')),
    );
  }

  void _comment() {
    setState(() {
      _commentCountDelta += 1;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('留言功能已預留，先幫你記一筆互動。')),
    );
  }

  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 台灣繁體中文教學註解：
    // 這張卡定位是「一般民眾用得到的生活法律提醒」，不是官方最新消息。
    // 內容先吃 HomeNewsletterItem，未來可由後端依使用者身分或最近查詢推薦。
    final radius = BorderRadius.circular(24.r);
    final icon = _iconForItem(item);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: radius,
        child: Ink(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(14.w, 16.h, 14.w, 12.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF6E8D7),
            borderRadius: radius,
            border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x128B6A3C),
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFF2B4499),
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w900,
                  height: 1.18,
                ),
              ),
              SizedBox(height: 12.h),
              Row(
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
                            color: AppColors.textSecondary,
                            fontSize: 11.sp,
                            height: 1.45,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          item.tip,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: const Color(0xFF3F8B2A),
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Container(
                    width: 112.w,
                    height: 104.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD7C8A6),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 38.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  _NewsletterMetric(
                    icon: _isLiked
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: const Color(0xFFD85A53),
                    label: _metricText(item.likes, _isLiked ? 1 : 0),
                    onTap: _toggleLike,
                  ),
                  _NewsletterMetric(
                    icon: Icons.share_outlined,
                    color: const Color(0xFF9B874A),
                    label: _metricText(item.shares, _shareCountDelta),
                    onTap: _share,
                  ),
                  _NewsletterMetric(
                    icon: Icons.comment_rounded,
                    color: const Color(0xFF4F8F36),
                    label: _metricText(item.comments, _commentCountDelta),
                    onTap: _comment,
                  ),
                  _NewsletterMetric(
                    icon: _isBookmarked
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    color: const Color(0xFF4A8E88),
                    label: _metricText(item.downloads, _isBookmarked ? 1 : 0),
                    onTap: _toggleBookmark,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForItem(HomeNewsletterItem item) {
    if (item.category.contains('狗') || item.category.contains('寵物')) {
      return Icons.pets_rounded;
    }
    if (item.category.contains('租')) return Icons.home_work_outlined;
    if (item.category.contains('拍照') || item.category.contains('隱私')) {
      return Icons.photo_camera_outlined;
    }
    if (item.category.contains('網購')) return Icons.shopping_bag_outlined;
    if (item.category.contains('交通')) return Icons.directions_car_outlined;
    return Icons.lightbulb_outline_rounded;
  }
}

class HomeV2NewsletterFocusCard extends StatefulWidget {
  const HomeV2NewsletterFocusCard({
    super.key,
    required this.item,
    this.onTap,
  });

  final HomeNewsletterItem item;
  final VoidCallback? onTap;

  @override
  State<HomeV2NewsletterFocusCard> createState() =>
      _HomeV2NewsletterFocusCardState();
}

class _HomeV2NewsletterFocusCardState extends State<HomeV2NewsletterFocusCard> {
  var _isLiked = false;
  var _isBookmarked = false;
  var _shareCountDelta = 0;
  var _commentCountDelta = 0;

  HomeNewsletterItem get item => widget.item;

  int _metricBase(String value) {
    final digits = RegExp(r'\d+').firstMatch(value)?.group(0);
    return int.tryParse(digits ?? '') ?? 0;
  }

  String _metricText(String value, int delta) {
    final next = _metricBase(value) + delta;
    return '$next+';
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
    });
  }

  void _share() {
    setState(() {
      _shareCountDelta += 1;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已複製分享連結示意。')),
    );
  }

  void _comment() {
    setState(() {
      _commentCountDelta += 1;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('留言功能已預留，先幫你記一筆互動。')),
    );
  }

  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
  }

  IconData _iconForItem(HomeNewsletterItem item) {
    if (item.category.contains('狗') || item.category.contains('寵物')) {
      return Icons.pets_rounded;
    }
    if (item.category.contains('租')) return Icons.home_work_outlined;
    if (item.category.contains('拍照') || item.category.contains('隱私')) {
      return Icons.photo_camera_outlined;
    }
    if (item.category.contains('網購')) return Icons.shopping_bag_outlined;
    if (item.category.contains('交通')) return Icons.directions_car_outlined;
    return Icons.lightbulb_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(24.r);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final icon = _iconForItem(item);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: radius,
        child: Ink(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 14.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF231F17), const Color(0xFF1B1B18)]
                  : [const Color(0xFFFFF7EE), const Color(0xFFF9EAD3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: radius,
            border: Border.all(
              color: isDark
                  ? const Color(0xFF382F22).withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.72),
              width: 1.2.w,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.15)
                    : const Color(0x128B6A3C),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: const Color(0xFF2B4499),
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w900,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          item.summary,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11.5.sp,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Container(
                    width: 72.w,
                    height: 72.w,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF2C2F36), const Color(0xFF1C1E22)]
                            : [
                                const Color(0xFFE9DFD2),
                                const Color(0xFFD7C8A6)
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: isDark ? 0.15 : 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 28.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1B2B18)
                      : const Color(0xFFE7F0DE),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  item.tip,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFF9ECE90)
                        : const Color(0xFF3F8B2A),
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  _NewsletterMetric(
                    icon: _isLiked
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: const Color(0xFFD85A53),
                    label: _metricText(item.likes, _isLiked ? 1 : 0),
                    onTap: _toggleLike,
                  ),
                  _NewsletterMetric(
                    icon: Icons.share_outlined,
                    color: const Color(0xFF9B874A),
                    label: _metricText(item.shares, _shareCountDelta),
                    onTap: _share,
                  ),
                  _NewsletterMetric(
                    icon: Icons.comment_rounded,
                    color: const Color(0xFF4F8F36),
                    label: _metricText(item.comments, _commentCountDelta),
                    onTap: _comment,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _toggleBookmark,
                    icon: Icon(
                      _isBookmarked
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      color: _isBookmarked
                          ? const Color(0xFFDCA834)
                          : AppColors.textSecondary,
                      size: 18.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NewsletterMetric extends StatelessWidget {
  const _NewsletterMetric({
    required this.icon,
    required this.color,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 4.h),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color.withValues(alpha: 0.92), size: 17.sp),
                SizedBox(width: 4.w),
                Text(
                  label,
                  style: TextStyle(
                    color: HomeV2Palette.ink.withValues(alpha: 0.72),
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
