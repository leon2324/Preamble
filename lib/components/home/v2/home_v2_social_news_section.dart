import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/components/home/home_content.dart';
import 'package:preamble/components/home/home_news_section.dart';
import 'package:preamble/data/journal/discussion_feed_service.dart';
import 'package:preamble/components/home/v2/home_v2_palette.dart';
import 'package:preamble/theme/app_colors.dart';
import 'package:preamble/pages/home/subpages/home_official_feed_pages.dart';
import 'package:preamble/data/moj/moj_feed_item.dart';
import 'dart:ui' show ImageFilter;

// 首頁 V2 的時事新聞與社群熱議切換區。
// 只保留首頁預覽 UI 與本地分頁狀態，完整導航由 HomePage callback 控制。

class HomeV2SocialNewsSection extends StatefulWidget {
  const HomeV2SocialNewsSection({
    super.key,
    required this.newsItems,
    required this.discussionFeed,
    this.onMoreNewsTap,
    this.onMoreDiscussionTap,
  });

  final List<HomeNewsItem> newsItems;
  final HomeDiscussionFeed discussionFeed;
  final VoidCallback? onMoreNewsTap;
  final VoidCallback? onMoreDiscussionTap;

  @override
  State<HomeV2SocialNewsSection> createState() =>
      _HomeV2SocialNewsSectionState();
}

class _HomeV2SocialNewsSectionState extends State<HomeV2SocialNewsSection> {
  int _activeTab = 0; // 0: 時事新聞, 1: 社群熱議

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 頂部分頁切換 Header
        Row(
          children: [
            // Pill Tabs
            Container(
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF161C23) : const Color(0xFFEFECE6),
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.all(3.w),
              child: Row(
                children: [
                  _buildTabButton(0, '法務部新聞', isDark),
                  SizedBox(width: 4.w),
                  _buildTabButton(1, '社群熱議', isDark),
                ],
              ),
            ),
            const Spacer(),
            // 「看全部」按鈕，對應當前 Tab 的行為
            GestureDetector(
              onTap: _activeTab == 0
                  ? widget.onMoreNewsTap
                  : widget.onMoreDiscussionTap,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '看全部',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: HomeV2Palette.trustGreen,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 10.sp,
                      color: HomeV2Palette.trustGreen,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        // 切換的內容
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _activeTab == 0
              ? HomeNewsSection(
                  key: const ValueKey('tab_news'),
                  items: widget.newsItems,
                  showHeader: false,
                  onItemTap: (item) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (__) => OfficialFeedDetailPage(
                          item: MojFeedItem(
                            title: item.title,
                            url: item.url ??
                                'https://www.moj.gov.tw/2204/2795/2796/',
                            category: MojFeedCategory.news,
                            index: 1,
                          ),
                        ),
                      ),
                    );
                  },
                )
              : _HomeV2DiscussionPreview(
                  key: const ValueKey('tab_discussion'),
                  feed: widget.discussionFeed,
                  onMoreTap: widget.onMoreDiscussionTap,
                ),
        ),
      ],
    );
  }

  Widget _buildTabButton(int index, String label, bool isDark) {
    final isSelected = _activeTab == index;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = index),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF232B35) : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(9.r),
          border: isSelected
              ? Border.all(
                  color: isDark
                      ? const Color(0xFF2D3845)
                      : const Color(0xFFECE6DB),
                  width: 1.w,
                )
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5.sp,
            fontWeight: FontWeight.bold,
            color:
                isSelected ? HomeV2Palette.trustGreen : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _HomeV2DiscussionPreview extends StatelessWidget {
  const _HomeV2DiscussionPreview({
    super.key,
    required this.feed,
    this.onMoreTap,
  });

  final HomeDiscussionFeed feed;
  final VoidCallback? onMoreTap;

  @override
  Widget build(BuildContext context) {
    final topics = feed.topics.take(3).toList(growable: false);
    if (topics.isEmpty) {
      return _HomeV2DiscussionEmpty(onMoreTap: onMoreTap);
    }

    // Step 2 Legacy 隔離後，首頁「社群熱議」只保留輕量 v2 預覽卡，
    // 完整互動流程交給紀事頁，避免正式首頁重新 import 舊版討論元件。
    return SizedBox(
      height: 188.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: topics.length,
        separatorBuilder: (_, __) => SizedBox(width: 10.w),
        itemBuilder: (context, index) {
          final topic = topics[index];
          return _HomeV2DiscussionPreviewCard(
            topic: topic,
            onTap: onMoreTap,
          );
        },
      ),
    );
  }
}

class _HomeV2DiscussionPreviewCard extends StatelessWidget {
  const _HomeV2DiscussionPreviewCard({
    required this.topic,
    this.onTap,
  });

  final HomeDiscussionTopic topic;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16.r);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color glassColor = isDark
        ? const Color(0xFF1E242B).withValues(alpha: 0.75)
        : const Color(0xFFFAF7F2).withValues(alpha: 0.75);
    final Color glassBorder = isDark
        ? const Color(0xFF2C3845).withValues(alpha: 0.5)
        : const Color(0xFFECE6DB).withValues(alpha: 0.5);

    return SizedBox(
      width: 236.w,
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: glassColor,
              borderRadius: radius,
              border: Border.all(color: glassBorder, width: 1.w),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: radius,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF2B3A2E)
                                : const Color(0xFFE2EDE5),
                            borderRadius: BorderRadius.circular(99.r),
                          ),
                          child: Text(
                            '#${topic.rank}',
                            style: TextStyle(
                              color: isDark
                                  ? const Color(0xFF8CAF96)
                                  : const Color(0xFF4E7D5B),
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Icon(
                          Icons.local_fire_department_rounded,
                          color: const Color(0xFFD68B33),
                          size: 16.sp,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          '${topic.heatScore}',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      topic.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w900,
                        height: 1.25,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Expanded(
                      child: Text(
                        topic.overview,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11.sp,
                          height: 1.35,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            topic.tags.take(2).map((tag) => '#$tag').join('  '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isDark
                                  ? const Color(0xFF8CAF96)
                                  : const Color(0xFF4E7D5B),
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: isDark
                              ? const Color(0xFF8CAF96)
                              : const Color(0xFF4E7D5B),
                          size: 17.sp,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeV2DiscussionEmpty extends StatelessWidget {
  const _HomeV2DiscussionEmpty({this.onMoreTap});

  final VoidCallback? onMoreTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16.r);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color glassColor = isDark
        ? const Color(0xFF1E242B).withValues(alpha: 0.75)
        : const Color(0xFFFAF7F2).withValues(alpha: 0.75);
    final Color glassBorder = isDark
        ? const Color(0xFF2C3845).withValues(alpha: 0.5)
        : const Color(0xFFECE6DB).withValues(alpha: 0.5);

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: glassColor,
            borderRadius: radius,
            border: Border.all(color: glassBorder),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onMoreTap,
              borderRadius: radius,
              child: Row(
                children: [
                  Icon(
                    Icons.forum_outlined,
                    color: isDark
                        ? const Color(0xFF8CAF96)
                        : const Color(0xFF4E7D5B),
                    size: 22.sp,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      '社群熱議整理中，稍後可到紀事頁查看完整議題。',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeV2DiscussionOffline extends StatelessWidget {
  const _HomeV2DiscussionOffline();

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16.r);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color glassColor = isDark
        ? const Color(0xFF1E242B).withValues(alpha: 0.75)
        : const Color(0xFFFAF7F2).withValues(alpha: 0.75);
    final Color glassBorder = isDark
        ? const Color(0xFF2C3845).withValues(alpha: 0.5)
        : const Color(0xFFECE6DB).withValues(alpha: 0.5);

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
          width: double.infinity,
          decoration: BoxDecoration(
            color: glassColor,
            borderRadius: radius,
            border: Border.all(color: glassBorder),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.wifi_off_rounded,
                    color: isDark
                        ? const Color(0xFF8CAF96)
                        : const Color(0xFF4E7D5B),
                    size: 22.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '沒有連線QQ，請連線後再試用一次',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              GestureDetector(
                onTap: () {
                  DiscussionFeedService.instance.refreshFeed();
                },
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: HomeV2Palette.trustGreen,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    '重新嘗試連線',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.bold,
                    ),
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
