import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/components/home/home_content.dart';
import 'package:preamble/theme/app_colors.dart';
import 'package:preamble/components/shared/share_sheet.dart';
import 'package:preamble/features/case_library/widgets/case_library_svg_icon.dart';

const String _svgPets = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
  <circle cx="12" cy="5" r="2"></circle>
  <circle cx="7" cy="7" r="2"></circle>
  <circle cx="17" cy="7" r="2"></circle>
  <path d="M12 21c-2.8 0-5-2.2-5-5 0-1.7 1-3.2 2.5-4 .8-.4 1.7-.6 2.5-.6s1.7.2 2.5.6c1.5.8 2.5 2.3 2.5 4 0 2.8-2.2 5-5 5Z"></path>
</svg>
''';

const String _svgShareNetwork = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
  <circle cx="18" cy="5" r="3"></circle>
  <circle cx="6" cy="12" r="3"></circle>
  <circle cx="18" cy="19" r="3"></circle>
  <line x1="8.59" y1="13.51" x2="15.42" y2="17.49"></line>
  <line x1="15.41" y1="6.51" x2="8.59" y2="10.49"></line>
</svg>
''';

const String _svgDownload = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path>
  <polyline points="7 10 12 15 17 10"></polyline>
  <line x1="12" y1="15" x2="12" y2="3"></line>
</svg>
''';

// 首頁 V2 避坑筆記入口卡片群。
//
// `HomeV2NewsletterFocusCard` 是首頁「生活避坑筆記」入口，現在以使用者提供的設計截圖為母版：
// 奶油色大圓角、深色故事標題、灰色風險摘要、綠色小提醒、右側生活情境圖片與底部互動數據列。
// 下方一般 Newsletter 卡仍保留較通用的列表樣式，避免入口改版時連帶影響其他可能復用的小卡。

class ProtoColors {
  static const Color sageGreen = Color(0xFFAFC3B4);
  static const Color blueGray = Color(0xFFA9B4C4);
  static const Color warmBeige = Color(0xFFF2EDE6);
  static const Color softTaupe = Color(0xFFD7CEC2);
  static const Color clay = Color(0xFFC48A7A);
  static const Color deepGreen = Color(0xFF2C5E43);
  static const Color charcoal = Color(0xFF17231F);
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
  if (title.contains('狗') ||
      title.contains('拍') ||
      title.contains('隱私') ||
      title.contains('自拍')) {
    return const EditorialBadge('官方整理', Color(0xFF2C5E43), Color(0xFFEEF7F2));
  }
  return const EditorialBadge('開發者推薦', Color(0xFF1976D2), Color(0xFFEEF3F8));
}

Color _getCategoryColor(String category) {
  if (category.contains('狗') || category.contains('寵物')) {
    return ProtoColors.deepGreen;
  }
  if (category.contains('租')) {
    return const Color(0xFF7A624A);
  }
  if (category.contains('拍照') || category.contains('隱私')) {
    return const Color(0xFF426E9F);
  }
  if (category.contains('網購')) {
    return const Color(0xFFC9877B);
  }
  if (category.contains('交通')) {
    return const Color(0xFF8A7B5C);
  }
  return ProtoColors.charcoal;
}

List<Color> _getIconGradient(String category) {
  if (category.contains('狗') || category.contains('寵物')) {
    return const [ProtoColors.deepGreen, ProtoColors.sageGreen];
  }
  if (category.contains('租')) {
    return const [Color(0xFF7A624A), ProtoColors.softTaupe];
  }
  if (category.contains('拍照') || category.contains('隱私')) {
    return const [Color(0xFF426E9F), ProtoColors.blueGray];
  }
  if (category.contains('網購')) {
    return const [Color(0xFFC9877B), Color(0xFFE8C8BE)];
  }
  if (category.contains('交通')) {
    return const [Color(0xFF8A7B5C), Color(0xFFE5D5A8)];
  }
  return const [ProtoColors.charcoal, Color(0xFF888888)];
}

String _storyImageForCategory(String category) {
  return switch (category) {
    '養狗' => 'assets/images/learning/levels/level_02_article_reader.png',
    '租屋' => 'assets/images/learning/rent_course_room.png',
    '拍照隱私' => 'assets/images/learning/privacy_course_room.png',
    '網購' => 'assets/images/learning/consumer_course_room.png',
    '交通' => 'assets/images/learning/car_course_room.png',
    _ => 'assets/images/learning/levels/level_01_legal_beginner.png',
  };
}

String _issueHintForHomeTip(HomeNewsletterItem item) {
  // 首頁入口只給一行「小動作可能導致什麼法律風險」，
  // 使用者點進去後，詳細頁再展開完整情境與處理步驟。
  if (item.category.contains('養狗') || item.title.contains('狗')) {
    return '可能涉及：動物占有人責任、醫療費、精神損害賠償';
  }
  if (item.category.contains('拍照') ||
      item.category.contains('隱私') ||
      item.title.contains('自拍') ||
      item.title.contains('截圖')) {
    return '可能涉及：肖像權、隱私權、個人資料使用';
  }
  if (item.category.contains('租') || item.title.contains('押金')) {
    return '可能涉及：押金返還、修繕責任、退租點交';
  }
  if (item.category.contains('網購') || item.title.contains('退貨')) {
    return '可能涉及：七日鑑賞期、退款期限、交易證明';
  }
  if (item.category.contains('交通') || item.title.contains('車禍')) {
    return '可能涉及：肇責判斷、和解書、保險理賠';
  }
  return '可能涉及：證據保存、通知方式、協商紀錄';
}

String _readTimeForHomeTip(HomeNewsletterItem item) {
  if (item.category.contains('租')) return '4 分鐘';
  if (item.category.contains('交通')) return '5 分鐘';
  return '3 分鐘';
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
    if (!_isLiked) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }
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
    CommentBottomSheet.show(
      context,
      title: item.title,
      onCommentPosted: () {
        setState(() {
          _commentCountDelta += 1;
        });
      },
    );
  }

  void _toggleBookmark() {
    if (!_isBookmarked) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }
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

    final isLikedColor = _isLiked
        ? const Color(0xFFC48A7A)
        : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF667085));
    final isBookmarkColor = _isBookmarked
        ? const Color(0xFFAFC3B4)
        : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF667085));
    final cleanTip = item.tip
        .replaceFirst(RegExp(r'^小提醒：'), '')
        .replaceFirst(RegExp(r'^💡\s*'), '');

    return Material(
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2228) : const Color(0xFFFAF5EC),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isDark ? const Color(0xFF2D333F) : const Color(0xFFEDE4D8),
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
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color: badge.bgColor,
                              borderRadius: BorderRadius.circular(4.r),
                              border: Border.all(
                                  color: badge.textColor.withValues(alpha: 0.2),
                                  width: 0.8.w),
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
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF243B63),
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
                                    color: isDark
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFF667085),
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
                            child: Center(
                              child: CaseLibrarySvgIcon(
                                _svgPathForItem(item),
                                size: 18.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      // 簡潔的小提醒 (綠色主題)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E2228)
                              : const Color(0xFFEEF7F2),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF2D333F)
                                : const Color(0xFFD0E7D2),
                            width: 0.8.w,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CaseLibrarySvgIcon(
                              CaseLibrarySvgIcons.idea,
                              color: isDark
                                  ? const Color(0xFF8BF45F)
                                  : const Color(0xFF2E7D32),
                              size: 13.sp,
                            ),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Text(
                                cleanTip,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: isDark
                                      ? const Color(0xFFCBD5E1)
                                      : const Color(0xFF2E7D32),
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
                      // 底部平面化社群操作列 (多彩永久配色)
                      Row(
                        children: [
                          _NewsletterMetric(
                            svgPath: _isLiked
                                ? CaseLibrarySvgIcons.heartFilled
                                : CaseLibrarySvgIcons.heart,
                            color: const Color(0xFFE53935),
                            label: _metricText(item.likes, _isLiked ? 1 : 0),
                            onTap: _toggleLike,
                          ),
                          _NewsletterMetric(
                            svgPath: _svgShareNetwork,
                            color: const Color(0xFF8A7712),
                            label: _metricText(item.shares, _shareCountDelta),
                            onTap: _share,
                          ),
                          _NewsletterMetric(
                            svgPath: CaseLibrarySvgIcons.message,
                            color: const Color(0xFF0F7D4B),
                            label:
                                _metricText(item.comments, _commentCountDelta),
                            onTap: _comment,
                          ),
                          _NewsletterMetric(
                            svgPath: _svgDownload,
                            color: const Color(0xFF0A7AA6),
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

  String _svgPathForItem(HomeNewsletterItem item) {
    if (item.category.contains('狗') || item.category.contains('寵物')) {
      return _svgPets;
    }
    if (item.category.contains('租')) return CaseLibrarySvgIcons.home;
    if (item.category.contains('拍照') || item.category.contains('隱私')) {
      return CaseLibrarySvgIcons.smartphone;
    }
    if (item.category.contains('網購')) return CaseLibrarySvgIcons.shoppingBag;
    if (item.category.contains('交通')) return CaseLibrarySvgIcons.car;
    return CaseLibrarySvgIcons.idea;
  }
}

class HomeV2NewsletterFocusCard extends StatefulWidget {
  const HomeV2NewsletterFocusCard({
    super.key,
    required this.item,
    this.onTap,
    this.showDots = true,
  });

  final HomeNewsletterItem item;
  final VoidCallback? onTap;
  final bool showDots;

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
    if (!_isLiked) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }
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
    CommentBottomSheet.show(
      context,
      title: item.title,
      onCommentPosted: () {
        setState(() {
          _commentCountDelta += 1;
        });
      },
    );
  }

  void _toggleBookmark() {
    if (!_isBookmarked) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cleanTip = _cleanFocusTip(item.tip);
    final accentColor = _getCategoryColor(item.category);
    final issue = _issueHintForHomeTip(item);
    final readTime = _readTimeForHomeTip(item);

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(12.r),
            child: Ink(
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF1E2228) : const Color(0xFFFAF5EC),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF2D333F)
                      : const Color(0xFFEDE4D8),
                  width: 0.8.w,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 12.w, 13.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 9.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(999.r),
                        ),
                        child: Text(
                          '日常小動作',
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 10.5.sp,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                                  color: isDark
                                      ? Colors.white
                                      : ProtoColors.charcoal,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w900,
                                  height: 1.25,
                                  letterSpacing: 0,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                issue,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : AppColors.textSecondary,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w800,
                                  height: 1.4,
                                  letterSpacing: 0,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Row(
                                children: [
                                  CaseLibrarySvgIcon(
                                    CaseLibrarySvgIcons.idea,
                                    color: isDark
                                        ? const Color(0xFF8BF45F)
                                        : const Color(0xFF2E7D32),
                                    size: 13.sp,
                                  ),
                                  SizedBox(width: 5.w),
                                  Expanded(
                                    child: Text(
                                      cleanTip,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: isDark
                                            ? const Color(0xFF8BF45F)
                                            : const Color(0xFF2E7D32),
                                        fontSize: 11.5.sp,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.h),
                              Wrap(
                                spacing: 6.w,
                                runSpacing: 4.h,
                                children: [
                                  _NewsletterStoryChip(
                                    label: item.category,
                                    color: accentColor,
                                  ),
                                  _NewsletterStoryChip(
                                    label: '民法',
                                    color: const Color(0xFF426E9F),
                                  ),
                                  _NewsletterStoryChip(
                                    label: readTime,
                                    color: const Color(0xFF8A7B5C),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 12.w),
                        _NewsletterEntryIllustration(category: item.category),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        _NewsletterFocusMetric(
                          svgPath: _isLiked
                              ? CaseLibrarySvgIcons.heartFilled
                              : CaseLibrarySvgIcons.heart,
                          color: const Color(0xFFE53935),
                          label: _metricText(item.likes, _isLiked ? 1 : 0),
                          onTap: _toggleLike,
                        ),
                        _NewsletterFocusMetric(
                          svgPath: _svgShareNetwork,
                          color: const Color(0xFF8A7712),
                          label: _metricText(item.shares, _shareCountDelta),
                          onTap: _share,
                        ),
                        _NewsletterFocusMetric(
                          svgPath: CaseLibrarySvgIcons.message,
                          color: const Color(0xFF0F7D4B),
                          label: _metricText(item.comments, _commentCountDelta),
                          onTap: _comment,
                        ),
                        _NewsletterFocusMetric(
                          svgPath: _isBookmarked
                              ? CaseLibrarySvgIcons.bookmark
                              : _svgDownload,
                          color: _isBookmarked
                              ? ProtoColors.deepGreen
                              : const Color(0xFF0A7AA6),
                          label: '儲存',
                          onTap: _toggleBookmark,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (widget.showDots) ...[
          SizedBox(height: 13.h),
          const _NewsletterFocusDots(count: 7, currentIndex: 0),
        ],
      ],
    );
  }
}

class HomeV2NewsletterFocusCarousel extends StatefulWidget {
  const HomeV2NewsletterFocusCarousel({
    super.key,
    required this.items,
    this.onItemTap,
  });

  final List<HomeNewsletterItem> items;
  final ValueChanged<HomeNewsletterItem>? onItemTap;

  @override
  State<HomeV2NewsletterFocusCarousel> createState() =>
      _HomeV2NewsletterFocusCarouselState();
}

class _HomeV2NewsletterFocusCarouselState
    extends State<HomeV2NewsletterFocusCarousel> {
  late final PageController _pageController;
  var _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visibleItems = widget.items.take(8).toList(growable: false);
    if (visibleItems.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final metrics = NewsletterFocusCardLayoutMetrics.compute(
          context: context,
          availableWidth: constraints.maxWidth - 32.w,
          items: visibleItems,
        );
        return Column(
          children: [
            SizedBox(
              height: metrics.height,
              child: PageView.builder(
                controller: _pageController,
                padEnds: true,
                physics: const BouncingScrollPhysics(),
                itemCount: visibleItems.length,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemBuilder: (context, index) {
                  final item = visibleItems[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: HomeV2NewsletterFocusCard(
                      item: item,
                      showDots: false,
                      onTap: () => widget.onItemTap?.call(item),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 13.h),
            _NewsletterFocusDots(
              count: visibleItems.length,
              currentIndex: _currentIndex,
            ),
          ],
        );
      },
    );
  }
}

/// 焦點輪播的 PageView 必須有界高度。這個同步量測契約以真實卡片寬度、
/// TextScaler 與資料文字取得所有頁面共同所需高度，避免固定高度在大字級
/// 壓住內容，也不需要 post-frame callback 或 setState 迴圈。
class NewsletterFocusCardLayoutMetrics {
  const NewsletterFocusCardLayoutMetrics({required this.height});

  final double height;

  static NewsletterFocusCardLayoutMetrics compute({
    required BuildContext context,
    required double availableWidth,
    required List<HomeNewsletterItem> items,
  }) {
    final width = math.max(1.0, availableWidth);
    final textScaler = MediaQuery.textScalerOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textWidth = math.max(1.0, width - 28.w - 12.w - 100.w);
    final tipWidth = math.max(1.0, textWidth - 13.sp - 5.w);
    final titleStyle = TextStyle(
      color: isDark ? Colors.white : ProtoColors.charcoal,
      fontSize: 18.sp,
      fontWeight: FontWeight.w900,
      height: 1.25,
      letterSpacing: 0,
    );
    final issueStyle = TextStyle(
      color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
      fontSize: 12.sp,
      fontWeight: FontWeight.w800,
      height: 1.4,
      letterSpacing: 0,
    );
    final tipStyle = TextStyle(
      color: isDark ? const Color(0xFF8BF45F) : const Color(0xFF2E7D32),
      fontSize: 11.5.sp,
      fontWeight: FontWeight.w800,
    );
    final chipStyle = TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w900);
    final badgeStyle =
        TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.w900);
    final metricStyle = TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800);

    double measure(String text, TextStyle style, double maxWidth) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: style),
        textScaler: textScaler,
        textDirection: Directionality.of(context),
      )..layout(maxWidth: maxWidth);
      return painter.height;
    }

    double chipHeight(HomeNewsletterItem item) {
      final labels = <String>[item.category, '民法', _readTimeForHomeTip(item)];
      var runWidth = 0.0;
      var completedRunsHeight = 0.0;
      var currentRunHeight = 0.0;
      for (final label in labels) {
        final chipWidth = TextPainter(
          text: TextSpan(text: label, style: chipStyle),
          textScaler: textScaler,
          textDirection: Directionality.of(context),
        )..layout();
        final nextWidth = chipWidth.width + 18.w;
        if (runWidth > 0 && runWidth + 6.w + nextWidth > textWidth) {
          completedRunsHeight += currentRunHeight + 4.h;
          runWidth = nextWidth;
          currentRunHeight = chipWidth.height + 8.h;
        } else {
          runWidth += runWidth == 0 ? nextWidth : 6.w + nextWidth;
          currentRunHeight = math.max(currentRunHeight, chipWidth.height + 8.h);
        }
      }
      return completedRunsHeight + currentRunHeight;
    }

    var requiredHeight = 0.0;
    for (final item in items) {
      final badgeHeight = measure('日常小動作', badgeStyle, width) + 8.h;
      // 卡片本體保留既有一／二／一行的閱讀節奏；量測也套用相同行數，
      // 避免 bounded PageView 的高度與實際渲染規則不一致。
      final textColumnHeight = math.min(
            measure(item.title, titleStyle, textWidth),
            measure('一', titleStyle, textWidth),
          ) +
          8.h +
          math.min(
            measure(_issueHintForHomeTip(item), issueStyle, textWidth),
            measure('一\n二', issueStyle, textWidth),
          ) +
          8.h +
          math.min(
            measure(_cleanFocusTip(item.tip), tipStyle, tipWidth),
            measure('一', tipStyle, tipWidth),
          ) +
          10.h +
          chipHeight(item);
      final middleHeight = math.max(100.w, textColumnHeight);
      final metricsHeight =
          math.max(20.sp, measure('999+', metricStyle, width / 4)) + 8.h;
      // InkWell 的四個互動 metric 會各自建立最小可點擊區；保留一列
      // content padding，避免文字量測只計字框而低估實際 RenderFlex 高度。
      final interactionRowInset = 38.h;
      requiredHeight = math.max(
        requiredHeight,
        16.h +
            badgeHeight +
            10.h +
            middleHeight +
            12.h +
            metricsHeight +
            interactionRowInset +
            13.h,
      );
    }
    return NewsletterFocusCardLayoutMetrics(
      height: math.max(238.h, requiredHeight),
    );
  }
}

class _NewsletterEntryIllustration extends StatelessWidget {
  const _NewsletterEntryIllustration({required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = _getCategoryColor(category);

    return Container(
      width: 100.w,
      height: 100.w,
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF2C323C)
            : accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark
              ? const Color(0xFF3F4756)
              : accentColor.withValues(alpha: 0.16),
          width: 0.8.w,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Image.asset(
          _storyImageForCategory(category),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _NewsletterStoryChip extends StatelessWidget {
  const _NewsletterStoryChip({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 10.sp,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _NewsletterFocusMetric extends StatelessWidget {
  const _NewsletterFocusMetric({
    required this.svgPath,
    required this.color,
    required this.label,
    required this.onTap,
  });

  final String svgPath;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 4.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CaseLibrarySvgIcon(svgPath, color: color, size: 20.sp),
              SizedBox(width: 5.w),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : AppColors.textSecondary,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NewsletterFocusDots extends StatelessWidget {
  const _NewsletterFocusDots({
    required this.count,
    required this.currentIndex,
  });

  final int count;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          width: isActive ? 18.w : 10.w,
          height: 10.w,
          margin: EdgeInsets.symmetric(horizontal: 6.w),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFFFF5E9) : const Color(0xFFD0D0D0),
            borderRadius: BorderRadius.circular(999.r),
          ),
        );
      }),
    );
  }
}

String _cleanFocusTip(String tip) {
  return tip
      .replaceFirst(RegExp(r'^小提醒：'), '')
      .replaceFirst(RegExp(r'^💡\s*'), '')
      .trim();
}

class _NewsletterMetric extends StatelessWidget {
  const _NewsletterMetric({
    required this.svgPath,
    required this.color,
    required this.label,
    this.onTap,
  });

  final String svgPath;
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
                CaseLibrarySvgIcon(svgPath, color: color, size: 16.sp),
                SizedBox(width: 6.w),
                Text(
                  label,
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : AppColors.textSecondary,
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

class CommentBottomSheet {
  const CommentBottomSheet._();

  static void show(BuildContext context,
      {required String title, VoidCallback? onCommentPosted}) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return _CommentBottomSheetContent(
            title: title, onCommentPosted: onCommentPosted);
      },
    );
  }
}

class _CommentBottomSheetContent extends StatefulWidget {
  const _CommentBottomSheetContent({required this.title, this.onCommentPosted});
  final String title;
  final VoidCallback? onCommentPosted;

  @override
  State<_CommentBottomSheetContent> createState() =>
      _CommentBottomSheetContentState();
}

class _CommentBottomSheetContentState
    extends State<_CommentBottomSheetContent> {
  final List<String> _comments = [
    '這篇太實用了！上次退租就被扣了三千元清潔費，超氣！',
    '推！《住宅租賃契約應記載事項》第11點一定要看熟，才不會被房東吃死死。',
    '請問如果是家具自然損壞，房東還是強行扣押金的話，可以直接申訴嗎？',
  ];
  final _controller = TextEditingController();

  void _submitComment() {
    if (_controller.text.trim().isEmpty) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _comments.add(_controller.text.trim());
      _controller.clear();
    });
    widget.onCommentPosted?.call();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    final bg = isDark ? const Color(0xDC171C22) : const Color(0xDCFAF6F0);
    final border = isDark ? const Color(0xFF2D3748) : const Color(0xFFEDE4D8);
    final text = isDark ? const Color(0xFFFAF6F0) : const Color(0xFF234D3B);
    final muted = isDark ? const Color(0xFFA0AEC0) : const Color(0xFF828078);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            border: Border.all(color: border, width: 1.5.w),
          ),
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: border,
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                ),
              ),
              SizedBox(height: 18.h),
              Text(
                '避坑交流區',
                style: TextStyle(
                  color: text,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                widget.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: muted,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16.h),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 220.h),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _comments.length,
                  itemBuilder: (context, index) {
                    final comment = _comments[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 10.h),
                      padding: EdgeInsets.symmetric(
                          horizontal: 12.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1F262F) : Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: border, width: 0.8.w),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24.w,
                            height: 24.w,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              comment,
                              style: TextStyle(
                                color: isDark
                                    ? const Color(0xFFCBD5E1)
                                    : const Color(0xFF334155),
                                fontSize: 12.5.sp,
                                height: 1.45,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: '分享您的避坑心得...',
                        hintStyle: TextStyle(
                          fontSize: 13.sp,
                          color: isDark
                              ? const Color(0xFF64748B)
                              : AppColors.textMuted,
                        ),
                        fillColor:
                            isDark ? const Color(0xFF1F262F) : Colors.white,
                        filled: true,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 14.w, vertical: 12.h),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  SizedBox(
                    height: 44.h,
                    child: ElevatedButton(
                      onPressed: _submitComment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('發佈',
                          style: TextStyle(fontWeight: FontWeight.bold)),
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
