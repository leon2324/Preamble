import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/components/home/home_content.dart';
import 'package:lawapp/components/home/v2/home_v2_palette.dart';
import 'package:lawapp/theme/app_colors.dart';
import 'package:lawapp/components/shared/share_sheet.dart';

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
    ShareSheet.show(context, title: item.title);
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
    final radius = BorderRadius.circular(16.r);
    final icon = _iconForItem(item);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color cardBg = isDark ? const Color(0xFF262422) : const Color(0xFFFAF7F2);
    final Color cardBorder = isDark ? const Color(0xFF3B3835) : const Color(0xFFEBE6DB);
    final Color titleColor = isDark ? const Color(0xFFE8B95F) : const Color(0xFF6B4B14);
    final Color tipColor = isDark ? const Color(0xFF8CAF96) : const Color(0xFF4E7D5B);
    final Color imageBg = isDark ? const Color(0xFF383531) : const Color(0xFFECE6DB);
    final Color iconColor = isDark ? const Color(0xFFE8B95F) : const Color(0xFF6B4B14);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: radius,
        child: Ink(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(14.w, 16.h, 14.w, 12.h),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: radius,
            border: Border.all(color: cardBorder, width: 1.w),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black.withValues(alpha: 0.1) : const Color(0x0A8B6A3C),
                blurRadius: 12,
                offset: const Offset(0, 6),
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
                  color: titleColor,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w900,
                  height: 1.25,
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
                            fontSize: 11.5.sp,
                            height: 1.45,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          item.tip,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: tipColor,
                            fontSize: 10.5.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Container(
                    width: 90.w,
                    height: 84.h,
                    decoration: BoxDecoration(
                      color: imageBg,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor.withValues(alpha: 0.8),
                      size: 32.sp,
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
                    color: isDark ? const Color(0xFFC7AF72) : const Color(0xFF9B874A),
                    label: _metricText(item.shares, _shareCountDelta),
                    onTap: _share,
                  ),
                  _NewsletterMetric(
                    icon: Icons.comment_rounded,
                    color: isDark ? const Color(0xFF70B15B) : const Color(0xFF4F8F36),
                    label: _metricText(item.comments, _commentCountDelta),
                    onTap: _comment,
                  ),
                  _NewsletterMetric(
                    icon: _isBookmarked
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    color: isDark ? const Color(0xFF67B0AA) : const Color(0xFF4A8E88),
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
    ShareSheet.show(context, title: item.title);
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
    final radius = BorderRadius.circular(16.r); // 統一使用 16.r
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final icon = _iconForItem(item);

    // 莫蘭迪綠漸層與高質感色彩設計
    final List<Color> gradientColors = isDark
        ? [const Color(0xFF1E2D24), const Color(0xFF141F1A)]
        : [const Color(0xFFEAF2ED), const Color(0xFFD3E5D9)];
    final Color borderCol = isDark ? const Color(0xFF2D4436) : const Color(0xFFC4DCD0);
    final Color titleColor = isDark ? const Color(0xFF76BA8B) : const Color(0xFF275435);
    final Color tipBg = isDark ? const Color(0xFF1E3525) : const Color(0xFFDCECE1);
    final Color tipTextCol = isDark ? const Color(0xFF76BA8B) : const Color(0xFF275435);

    final List<Color> imageGradient = isDark
        ? [const Color(0xFF2B4436), const Color(0xFF1E3227)]
        : [const Color(0xFFB9D8C6), const Color(0xFF9EBFAC)];

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
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: radius,
            border: Border.all(
              color: borderCol,
              width: 1.2.w,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black.withValues(alpha: 0.15) : const Color(0x0A275435),
                blurRadius: 16,
                offset: const Offset(0, 6),
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
                            color: titleColor,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w900,
                            height: 1.25,
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
                        colors: imageGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14.r),
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
                  color: tipBg,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  item.tip,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: tipTextCol,
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
                    color: isDark ? const Color(0xFF76BA8B) : const Color(0xFF275435),
                    label: _metricText(item.shares, _shareCountDelta),
                    onTap: _share,
                  ),
                  _NewsletterMetric(
                    icon: Icons.comment_rounded,
                    color: isDark ? const Color(0xFF76BA8B) : const Color(0xFF275435),
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
