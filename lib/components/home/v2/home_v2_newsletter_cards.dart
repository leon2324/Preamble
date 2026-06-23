import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/components/home/home_content.dart';
import 'package:lawapp/theme/app_colors.dart';
import 'package:lawapp/components/shared/share_sheet.dart';

// 台灣繁體中文教學註解：
// 首頁 V2 避坑筆記入口卡片群。
// 完全對齊設計圖與「扁平多彩雜誌風」視覺：
// 採用極細 `0.8.w` 灰色外框的純平白底卡片（無陰影、無厚重底色），
// 左側邊緣嵌入 `4.w` 類別彩虹邊條，右側圓框填充實心莫蘭迪雙色漸層，
// 頂部帶有高對比雙色編輯特色標籤，底部保留讚數、分享、留言與書籤的平面化按鈕列。

class ProtoColors {
  static const Color sageGreen = Color(0xFFAFC3B4);
  static const Color blueGray = Color(0xFFA9B4C4);
  static const Color warmBeige = Color(0xFFF2EDE6);
  static const Color softTaupe = Color(0xFFD7CEC2);
  static const Color clay = Color(0xFFC48A7A);
  static const Color charcoal = Color(0xFF3E454D);
}

class EditorialBadge {
  final String label;
  final Color textColor;
  final Color bgColor;
  const EditorialBadge(this.label, this.textColor, this.bgColor);
}

EditorialBadge _getEditorialBadge(String title) {
  if (title.contains('租屋') || title.contains('購') || title.contains('退貨')) {
    return const EditorialBadge('編輯精選', ProtoColors.clay, Color(0xFFFFF0EC));
  }
  if (title.contains('狗') || title.contains('拍') || title.contains('隱私') || title.contains('自拍')) {
    return const EditorialBadge('官方整理', Color(0xFF2C5E43), Color(0xFFEEF7F2));
  }
  return const EditorialBadge('開發者推薦', Color(0xFF1976D2), Color(0xFFEEF3F8));
}

Color _getCategoryColor(String category) {
  if (category.contains('狗') || category.contains('寵物')) {
    return const Color(0xFF2C5E43); // 森林深綠
  }
  if (category.contains('租')) {
    return ProtoColors.clay; // 陶土紅
  }
  if (category.contains('拍照') || category.contains('隱私')) {
    return const Color(0xFF4C2A75); // 皇家紫
  }
  if (category.contains('網購')) {
    return const Color(0xFF752434); // 酒紅
  }
  if (category.contains('交通')) {
    return const Color(0xFF754318); // 琥珀褐
  }
  return ProtoColors.charcoal;
}

List<Color> _getIconGradient(String category) {
  if (category.contains('狗') || category.contains('寵物')) {
    return const [Color(0xFF2C5E43), Color(0xFFAFC3B4)];
  }
  if (category.contains('租')) {
    return const [ProtoColors.clay, Color(0xFFE2B265)];
  }
  if (category.contains('拍照') || category.contains('隱私')) {
    return const [Color(0xFF4C2A75), Color(0xFFA9B4C4)];
  }
  if (category.contains('網購')) {
    return const [Color(0xFF752434), ProtoColors.clay];
  }
  if (category.contains('交通')) {
    return const [Color(0xFF754318), Color(0xFFD7CEC2)];
  }
  return const [ProtoColors.charcoal, Color(0xFF888888)];
}

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final badge = _getEditorialBadge(item.title);
    final accentColor = _getCategoryColor(item.category);
    final iconGradient = _getIconGradient(item.category);
    
    final isLikedColor = _isLiked ? const Color(0xFFC48A7A) : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF667085));
    final isBookmarkColor = _isBookmarked ? const Color(0xFFAFC3B4) : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF667085));
    final cleanTip = item.tip.replaceFirst(RegExp(r'^小提醒：'), '').replaceFirst(RegExp(r'^💡\s*'), '');

    return Material(
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2228) : Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isDark ? const Color(0xFF2D333F) : const Color(0xFFE5E7EB),
              width: 0.8.w,
            ),
          ),
          child: Stack(
            children: [
              // 左側類別彩虹邊條
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 4.w,
                child: Container(color: accentColor),
              ),
              InkWell(
                onTap: widget.onTap,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 頂部列：編輯特色標籤與類別
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color: badge.bgColor,
                              borderRadius: BorderRadius.circular(4.r),
                              border: Border.all(color: badge.textColor.withOpacity(0.2), width: 0.8.w),
                            ),
                            child: Text(
                              badge.label,
                              style: TextStyle(
                                color: badge.textColor,
                                fontSize: 9.5.sp,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 5.w,
                                height: 5.w,
                                decoration: BoxDecoration(
                                  color: accentColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 5.w),
                              Text(
                                item.category,
                                style: TextStyle(
                                  color: accentColor,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      // 標題與簡介 + 右側漸層圖示
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
                                    color: isDark ? Colors.white : const Color(0xFF3E454D),
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w900,
                                    height: 1.35,
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                Text(
                                  item.summary,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF667085),
                                    fontSize: 12.sp,
                                    height: 1.45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 14.w),
                          // 實心漸層圖示圈
                          Container(
                            width: 44.w,
                            height: 44.w,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: iconGradient,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _iconForItem(item),
                              color: Colors.white,
                              size: 20.sp,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      // 簡潔的小提醒
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E2228) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: isDark ? const Color(0xFF2D333F) : const Color(0xFFF1F5F9),
                            width: 0.8.w,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.lightbulb_outline_rounded,
                              color: accentColor,
                              size: 14.sp,
                            ),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Text(
                                cleanTip,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475467),
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w800,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12.h),
                      // 底部平面化社群操作列
                      Row(
                        children: [
                          _NewsletterMetric(
                            icon: _isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: isLikedColor,
                            label: _metricText(item.likes, _isLiked ? 1 : 0),
                            onTap: _toggleLike,
                          ),
                          _NewsletterMetric(
                            icon: Icons.share_rounded,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF667085),
                            label: _metricText(item.shares, _shareCountDelta),
                            onTap: _share,
                          ),
                          _NewsletterMetric(
                            icon: Icons.chat_bubble_outline_rounded,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF667085),
                            label: _metricText(item.comments, _commentCountDelta),
                            onTap: _comment,
                          ),
                          _NewsletterMetric(
                            icon: _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                            color: isBookmarkColor,
                            label: '儲存',
                            onTap: _toggleBookmark,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final badge = _getEditorialBadge(item.title);
    final accentColor = _getCategoryColor(item.category);
    final iconGradient = _getIconGradient(item.category);
    
    final isLikedColor = _isLiked ? const Color(0xFFC48A7A) : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF667085));
    final isBookmarkColor = _isBookmarked ? const Color(0xFFAFC3B4) : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF667085));

    return Material(
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2228) : Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: isDark ? const Color(0xFF2D333F) : const Color(0xFFE5E7EB),
              width: 0.8.w,
            ),
          ),
          child: Stack(
            children: [
              // 左側類別彩虹邊條
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 4.w,
                child: Container(color: accentColor),
              ),
              InkWell(
                onTap: widget.onTap,
                child: Padding(
                  padding: EdgeInsets.all(18.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 頂部列：編輯特色標籤與類別
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color: badge.bgColor,
                              borderRadius: BorderRadius.circular(4.r),
                              border: Border.all(color: badge.textColor.withOpacity(0.2), width: 0.8.w),
                            ),
                            child: Text(
                              badge.label,
                              style: TextStyle(
                                color: badge.textColor,
                                fontSize: 9.5.sp,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 5.w,
                                height: 5.w,
                                decoration: BoxDecoration(
                                  color: accentColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 5.w),
                              Text(
                                item.category,
                                style: TextStyle(
                                  color: accentColor,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      // 標題與簡介 + 右側實心漸層圖示
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
                                    color: isDark ? Colors.white : const Color(0xFF3E454D),
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w900,
                                    height: 1.35,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  item.summary,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF667085),
                                    fontSize: 12.sp,
                                    height: 1.45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 14.w),
                          // 實心漸層圖示圈
                          Container(
                            width: 44.w,
                            height: 44.w,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: iconGradient,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _iconForItem(item),
                              color: Colors.white,
                              size: 20.sp,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 14.h),
                      // 底部極簡平面化社群操作列
                      Row(
                        children: [
                          _NewsletterMetric(
                            icon: _isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: isLikedColor,
                            label: _metricText(item.likes, _isLiked ? 1 : 0),
                            onTap: _toggleLike,
                          ),
                          _NewsletterMetric(
                            icon: Icons.share_rounded,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF667085),
                            label: _metricText(item.shares, _shareCountDelta),
                            onTap: _share,
                          ),
                          _NewsletterMetric(
                            icon: Icons.chat_bubble_outline_rounded,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF667085),
                            label: _metricText(item.comments, _commentCountDelta),
                            onTap: _comment,
                          ),
                          _NewsletterMetric(
                            icon: _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                            color: isBookmarkColor,
                            label: '儲存',
                            onTap: _toggleBookmark,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10.r),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 6.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 16.sp),
                SizedBox(width: 6.w),
                Text(
                  label,
                  style: TextStyle(
                    color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w800,
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
