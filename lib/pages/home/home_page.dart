import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/components/home/home_content.dart';
import 'package:preamble/components/home/v2/home_v2_header.dart';
import 'package:preamble/components/home/v2/home_v2_primitives.dart';
import 'package:preamble/components/home/v2/home_v2_sections.dart';
import 'package:preamble/components/home/v2/home_v2_bento_cards.dart';
import 'package:preamble/components/navigation/app_shell_content_insets.dart';
import 'package:preamble/components/shared/liquid_glass_widgets.dart';
import 'package:preamble/data/mock_data/home/home_mock_data.dart';
import 'package:preamble/data/mock_data/home/home_v2_mock_data.dart';
import 'package:preamble/data/mock_data/home/legacy/home_mock_data_legacy.dart';
import 'package:preamble/data/mock_data/learning/learning_mock_data.dart';
import 'package:preamble/pages/learning/learning_mock_detail_page.dart';
import 'package:preamble/data/moj/moj_feed_item.dart';
import 'package:preamble/pages/home/home_subpages.dart';
import 'package:preamble/pages/learning/statute_database_page.dart';
import 'package:preamble/pages/profile/profile_page.dart';
import 'package:preamble/pages/following/following_page.dart';
import 'package:preamble/app/app_state.dart';
import 'package:preamble/theme/adaptive_layout.dart';
import 'package:preamble/theme/app_colors.dart';
import 'package:preamble/features/case_library/pages/case_dossier_detail_page.dart';
import 'package:preamble/features/case_library/data/case_library_data.dart';
import 'package:preamble/features/case_library/data/case_library_repository.dart';

/// 新版首頁。
///
/// 這個版本承接先前 prototype 的方向，已拆成多個 v2 元件檔案，
/// 之後若要逐步接 API、補上會員狀態與互動流程，可以從各 section 分別替換。
class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.onNavigateToTab,
  });

  final void Function(int targetOriginalIndex,
      {int? subTabIndex, String? toolTab}) onNavigateToTab;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // 參賽版本改用穩定的靜態時事話題，因此不調用自動更新機制，保留在架構中不調用
    // DiscussionFeedService.instance.startAutoRefresh();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // void _onFeedChanged() {
  //   if (mounted) {
  //     setState(() {});
  //   }
  // }

  void _openStatuteDatabase() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (__) => const StatuteDatabasePage()),
    );
  }

  void _handleTickerTap(HomeV2TickerItem item) {
    if (item.type == 'news') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (__) => OfficialFeedDetailPage(
            item: MojFeedItem(
              title: item.title,
              url: item.targetUrl ?? 'https://www.moj.gov.tw/',
              category: MojFeedCategory.news,
              index: 0,
            ),
          ),
        ),
      );
    } else if (item.type == 'learning') {
      final topic = featuredLearningTopics[item.targetId];
      if (topic != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (__) => LearningMockDetailPage(article: topic.heroArticle),
          ),
        );
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (__) =>
                const StatuteDatabasePage(initialQuery: '勞動基準法 加班費'),
          ),
        );
      }
    } else if (item.type == 'tip') {
      final tip = homeNewsletterItems.firstWhere(
        (n) => n.title == item.targetId,
        orElse: () => homeNewsletterItems.first,
      );
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (__) => LifeLegalTipDetailPage(item: tip),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (__) => StatuteDatabasePage(initialQuery: item.query),
        ),
      );
    }
  }

  void _openFollowingUpdates() {
    // 「早安」卡片的法律更新摘要要能回到完整清單；這裡直接開啟追蹤頁的更新分頁，
    // 讓使用者從首頁看到數字後，有明確地方可以驗收與繼續閱讀。
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (__) => const FollowingPage(initialTab: 'updates'),
      ),
    );
  }

  void _openOfficialFeed(MojFeedCategory category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (__) => OfficialFeedPage(category: category),
      ),
    );
  }

  void _openLifeLegalTips() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (__) => const LifeLegalTipsPage()),
    );
  }

  void _openLifeLegalTip(HomeNewsletterItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (__) => LifeLegalTipDetailPage(item: item)),
    );
  }

  void _openLearningTopics() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (__) => const HomeLearningTopicsPage()),
    );
  }

  void _openProfilePage() {
    // 首頁的「我的」現在直接開會員頁，不再依賴底部第 5 個 tab；
    // 這樣底部導覽可以改成新的「追蹤」，同時保留原本會員功能入口。
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (__) => const ProfilePage(showBackButton: true),
      ),
    );
  }

  void _openQuickSettingsPanel() {
    final appState = PreambleScope.of(context);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return AnimatedBuilder(
          animation: appState,
          builder: (context, _) {
            final isDark = appState.isDarkMode;
            final bg =
                isDark ? const Color(0xFF171C22) : const Color(0xFFFAF6F0);
            final card = isDark ? const Color(0xFF1F262F) : Colors.white;
            final border =
                isDark ? const Color(0xFF2D3748) : const Color(0xFFEDE4D8);
            final text =
                isDark ? const Color(0xFFFAF6F0) : const Color(0xFF234D3B);
            final muted =
                isDark ? const Color(0xFFA0AEC0) : const Color(0xFF828078);

            return Container(
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                border: Border.all(color: border, width: 1.5.w),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
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
                  SizedBox(height: 20.h),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28.r,
                        backgroundColor: const Color(0xFF234D3B),
                        child: Text(
                          appState.currentUser.isGuest
                              ? '訪'
                              : appState.currentUser.displayName
                                  .substring(0, 1),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appState.currentUser.isGuest
                                  ? '訪客中心'
                                  : appState.currentUser.displayName,
                              style: TextStyle(
                                  color: text,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w800),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              '${appState.accessTier.label}方案 ｜ 今日 AI 額度：${appState.remainingAiQuota}',
                              style: TextStyle(
                                  color: muted,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Divider(color: border),
                  SizedBox(height: 10.h),
                  Text(
                    '快速設定',
                    style: TextStyle(
                        color: text,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12.h),
                  // Dark Mode Row
                  Container(
                    decoration: BoxDecoration(
                      color: card,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: border),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    child: Row(
                      children: [
                        Icon(Icons.dark_mode_rounded,
                            color: Colors.purple, size: 22.sp),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '深色模式',
                                style: TextStyle(
                                    color: text,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '調整介面明暗以利夜間閱讀',
                                style: TextStyle(color: muted, fontSize: 11.sp),
                              ),
                            ],
                          ),
                        ),
                        Switch.adaptive(
                          value: appState.isDarkMode,
                          onChanged: (val) {
                            appState.setDarkMode(val);
                          },
                          activeThumbColor: const Color(0xFF234D3B),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _openProfilePage();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF234D3B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_outline_rounded,
                              color: Colors.white, size: 20.sp),
                          SizedBox(width: 8.w),
                          Text(
                            '前往『我的』個人中心',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showNotificationBubble() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final bg = isDark ? const Color(0xFF171C22) : const Color(0xFFFAF6F0);
        final border =
            isDark ? const Color(0xFF2D3748) : const Color(0xFFEDE4D8);
        final text = isDark ? const Color(0xFFFAF6F0) : const Color(0xFF234D3B);
        final muted =
            isDark ? const Color(0xFFA0AEC0) : const Color(0xFF828078);

        return Dialog(
          backgroundColor: bg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
            side: BorderSide(color: border, width: 1.5.w),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.notifications_active_rounded,
                        color: const Color(0xFFD6A04D), size: 24.sp),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        '最新通知',
                        style: TextStyle(
                          color: text,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: text, size: 22.sp),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
                // Simulated notifications in Morandi style
                _buildSimulatedNotificationItem(
                  category: '系統公告',
                  title: '小法助 AI 模型已升級為 2.0 版，回覆品質提升 40%！',
                  time: '2 分鐘前',
                  icon: Icons.auto_awesome,
                  iconColor: const Color(0xFF6D649A),
                  bg: const Color(0xFFF0EEF9),
                  textColor: text,
                  mutedColor: muted,
                  border: border,
                ),
                SizedBox(height: 10.h),
                _buildSimulatedNotificationItem(
                  category: '關注更新',
                  title: '您追蹤的「太陽花學運案件」有 1 筆新的判決書摘要更新。',
                  time: '1 小時前',
                  icon: Icons.gavel_rounded,
                  iconColor: const Color(0xFF357A53),
                  bg: const Color(0xFFEAF6EF),
                  textColor: text,
                  mutedColor: muted,
                  border: border,
                ),
                SizedBox(height: 10.h),
                _buildSimulatedNotificationItem(
                  category: '避坑提醒',
                  title: '今日推薦避坑筆記：『租屋押金返還爭議的 3 個關鍵自保步驟』',
                  time: '今天',
                  icon: Icons.lightbulb_outline_rounded,
                  iconColor: const Color(0xFF9E7B2D),
                  bg: const Color(0xFFFFF2CF),
                  textColor: text,
                  mutedColor: muted,
                  border: border,
                ),
                SizedBox(height: 20.h),
                SizedBox(
                  width: double.infinity,
                  height: 40.h,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (__) =>
                              const FollowingPage(initialTab: 'updates'),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      '查看所有動態與通知',
                      style: TextStyle(
                        color: text,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSimulatedNotificationItem({
    required String category,
    required String title,
    required String time,
    required IconData icon,
    required Color iconColor,
    required Color bg,
    required Color textColor,
    required Color mutedColor,
    required Color border,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: border.withValues(alpha: 0.5)),
      ),
      padding: EdgeInsets.all(12.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      category,
                      style: TextStyle(
                        color: iconColor,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        color: mutedColor,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final layout = context.homeSearchLayout;
    final additionalBottom = AppShellContentInsets.additionalBottomOf(context);
    final topContentPadding =
        context.hasLargeTopInset ? context.topSafeInset + 10.h : 18.h;
    final isCompactWidth = MediaQuery.sizeOf(context).width < 360;
    final dailyDockHeight = isCompactWidth ? 174.h : 158.h;

    return Stack(
      children: [
        const LiquidGlassBackground(),
        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        EdgeInsets.fromLTRB(16.w, topContentPadding, 16.w, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HomeV2HeroHeader(
                          onProfileTap: _openQuickSettingsPanel,
                          onNotificationTap: _showNotificationBubble,
                          onTickerTap: _handleTickerTap,
                        ),
                        SizedBox(height: 14.h),
                        HomeV2GreetingCard(onTap: _openFollowingUpdates),
                        SizedBox(height: 16.h),
                        const HomeV2QuickAskSection(),
                        SizedBox(height: 18.h),
                        const HomeV2WatchlistCard(),
                        SizedBox(height: 18.h),
                        SizedBox(
                          // iPhone SE 寬度較窄，雙卡內容容易因字級換算被壓縮；
                          // 這裡只加一點固定高度，不改 Prototype 的卡片比例與視覺語言。
                          height: dailyDockHeight,
                          child: Row(
                            children: [
                              const Expanded(child: HomeV2DailyCaseStoryCard()),
                              SizedBox(width: 12.w),
                              const Expanded(child: HomeV2AchievementCard()),
                            ],
                          ),
                        ),
                        SizedBox(height: 18.h),
                        // MAIC Demo 的主線是「快問 → 今日判決 → 法規搜尋」；
                        // 因此法規資料庫放在工具捷徑前，之後接 Spotlight 深連結時也較自然。
                        HomeV2LawDatabaseCard(
                          onTap: _openStatuteDatabase,
                        ),
                        SizedBox(height: 18.h),
                        HomeV2ToolsDrawer(
                            onNavigateToTab: widget.onNavigateToTab),
                        SizedBox(height: 20.h),
                        HomeV2SectionHeader(
                          title: '本日焦點議題對決',
                          action: '進入思辨',
                          onTap: () {
                            final rentalCase = caseLibraryCases.firstWhere(
                              (c) => c.id == 'case-029',
                              orElse: () => CaseLibraryRepository.instance
                                  .getCaseById('case-029'),
                            );
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (__) =>
                                    CaseDossierDetailPage(book: rentalCase),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 10.h),
                        HomeV2TopicBentoGrid(
                          onTopicTap: (__) => _openLearningTopics(),
                        ),
                        SizedBox(height: 18.h),
                        HomeV2SectionHeader(
                          title: '生活避坑筆記',
                          action: '更多提醒',
                          onTap: _openLifeLegalTips,
                        ),
                        SizedBox(height: 10.h),
                        HomeV2NewsletterFocusCarousel(
                          items: homeNewsletterItems,
                          onItemTap: _openLifeLegalTip,
                        ),
                        SizedBox(height: 18.h),
                        HomeV2SocialNewsSection(
                          newsItems: homeNewsItems,
                          discussionFeed: homeDiscussionFeed,
                          onMoreNewsTap: () =>
                              _openOfficialFeed(MojFeedCategory.news),
                          onMoreDiscussionTap: () => widget.onNavigateToTab(3),
                        ),
                        SizedBox(height: 132.h + additionalBottom),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (layout.hasLargeTopInset)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Container(
                height: layout.topMaskHeight.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0, 0.12, 0.28, 0.52, 1],
                    colors: [
                      AppColors.background,
                      AppColors.background.withValues(alpha: 0.92),
                      AppColors.background.withValues(alpha: 0.56),
                      AppColors.background.withValues(alpha: 0.18),
                      AppColors.background.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
