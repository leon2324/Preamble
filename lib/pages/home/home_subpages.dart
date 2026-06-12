import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/components/home/home_content.dart';
import 'package:lawapp/components/home/v2/home_v2_palette.dart';
import 'package:lawapp/data/mock_data/home/home_mock_data.dart';
import 'package:lawapp/data/mock_data/home/home_v2_mock_data.dart';
import 'package:lawapp/data/mock_data/learning/learning_mock_data.dart';
import 'package:lawapp/data/moj/moj_feed_item.dart';
import 'package:lawapp/data/moj/moj_feed_service.dart';
import 'package:lawapp/pages/learning/know_law_page.dart';
import 'package:lawapp/pages/learning/learning_mock_detail_page.dart';
import 'package:lawapp/pages/learning/statute_database_page.dart';
import 'package:lawapp/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

/// 法務部公開資料列表頁。
///
/// 台灣繁體中文教學註解：
/// 首頁「今日新聞」與官方最新消息類入口會導到這裡，差別只在 category。
/// 這樣之後若改成後端 RAG/資料庫同步，只要替換 MojFeedService 即可。
class OfficialFeedPage extends StatefulWidget {
  const OfficialFeedPage({
    super.key,
    required this.category,
  });

  final MojFeedCategory category;

  @override
  State<OfficialFeedPage> createState() => _OfficialFeedPageState();
}

class _OfficialFeedPageState extends State<OfficialFeedPage> {
  late final MojFeedService _service;
  late Future<List<MojFeedItem>> _itemsFuture;

  @override
  void initState() {
    super.initState();
    _service = MojFeedService();
    _itemsFuture = _service.fetchItems(widget.category);
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() {
      _itemsFuture = _service.fetchItems(widget.category);
    });
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, topPadding + 14.h, 16.w, 30.h),
        children: [
          _SubpageTopBar(onBack: () => Navigator.of(context).pop()),
          SizedBox(height: 18.h),
          _SubpageHero(
            title: widget.category.title,
            subtitle:
                '資料來源：${widget.category.sourceLabel}。列表會即時讀取公開頁面，點進去可查看官方連結。',
            icon: widget.category == MojFeedCategory.news
                ? Icons.campaign_outlined
                : Icons.rule_folder_outlined,
            color: widget.category == MojFeedCategory.news
                ? HomeV2Palette.mint
                : HomeV2Palette.lawBlue,
          ),
          SizedBox(height: 16.h),
          FutureBuilder<List<MojFeedItem>>(
            future: _itemsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const _SubpageStatusCard(message: '正在讀取官方資料...');
              }

              if (snapshot.hasError) {
                return _SubpageStatusCard(
                  message: snapshot.error.toString(),
                  actionLabel: '再試一次',
                  onAction: _reload,
                );
              }

              final items = snapshot.data ?? const <MojFeedItem>[];
              if (items.isEmpty) {
                return const _SubpageStatusCard(message: '目前沒有可顯示的資料。');
              }

              return Column(
                children: items.map((item) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: _OfficialFeedCard(
                      item: item,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (__) => OfficialFeedDetailPage(item: item),
                          ),
                        );
                      },
                    ),
                  );
                }).toList(growable: false),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// 官方清單項目的輕量詳細頁。
///
/// 台灣繁體中文教學註解：
/// App 先顯示來源、標題與風險提醒，完整附件或修正理由仍以官方頁面為準；
/// 這能避免在前端硬解析每種政府頁面，同時保留可追溯來源。
class OfficialFeedDetailPage extends StatelessWidget {
  const OfficialFeedDetailPage({
    super.key,
    required this.item,
  });

  final MojFeedItem item;

  Future<void> _openOfficialUrl() async {
    final uri = Uri.parse(item.url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, topPadding + 14.h, 16.w, 30.h),
        children: [
          _SubpageTopBar(onBack: () => Navigator.of(context).pop()),
          SizedBox(height: 18.h),
          Container(
            padding: EdgeInsets.all(18.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: AppColors.border),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x10000000),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TinySourceLabel(label: '${item.badge} · ${item.sourceLabel}'),
                SizedBox(height: 14.h),
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 24.sp,
                    height: 1.2,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 14.h),
                Text(
                  '這筆資料來自官方公開頁面。App 先整理標題與來源，完整內容、附件或日期請以官方頁面為準。',
                  style: TextStyle(
                    fontSize: 13.sp,
                    height: 1.55,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 18.h),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _openOfficialUrl,
                    icon: const Icon(Icons.open_in_new_rounded),
                    label: const Text('開啟官方頁面'),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          const _SubpageStatusCard(
            message: '提醒：官方資料與 App 整理均不構成律師正式法律意見；遇到期限或重大權益，請諮詢律師或法律扶助。',
          ),
        ],
      ),
    );
  }
}

/// 首頁常見法律問題的完整子頁。
///
/// 台灣繁體中文教學註解：
/// 這頁把首頁橫向小入口展開成完整情境選單；一般生活問題交給小法助，
/// 法規查詢則直接進資料庫頁，讓使用者不用理解背後功能分工。
class CommonLegalIssuesPage extends StatelessWidget {
  const CommonLegalIssuesPage({super.key});

  void _openIssue(BuildContext context, HomeV2IssueItem item) {
    if (item.label == '法規查詢') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (__) => const StatuteDatabasePage()),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (__) => LawAssistantSearchPage(
          initialPrompt: '我想了解${item.label}常見法律問題，可以先看哪些方向？',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, topPadding + 14.h, 16.w, 30.h),
        children: [
          _SubpageTopBar(onBack: () => Navigator.of(context).pop()),
          SizedBox(height: 18.h),
          const _SubpageHero(
            title: '常見法律問題',
            subtitle: '先選情境，再交給小法助整理方向、相關法條與下一步。未登入仍可試用一次。',
            icon: Icons.psychology_alt_outlined,
            color: HomeV2Palette.aiYellow,
          ),
          SizedBox(height: 16.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: homeV2IssueItems.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10.h,
              crossAxisSpacing: 10.w,
              childAspectRatio: 1.25,
            ),
            itemBuilder: (context, index) {
              final item = homeV2IssueItems[index];
              return _IssueCard(
                item: item,
                onTap: () => _openIssue(context, item),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// 生活避坑筆記列表頁。
///
/// 台灣繁體中文教學註解：
/// 這個區塊不是官方最新消息，而是給一般民眾的「情境型小知識」。
/// 例如養狗、租屋、拍照、網購這類日常情境，先用短文幫使用者建立風險意識。
class LifeLegalTipsPage extends StatefulWidget {
  const LifeLegalTipsPage({super.key});

  @override
  State<LifeLegalTipsPage> createState() => _LifeLegalTipsPageState();
}

class _LifeLegalTipsPageState extends State<LifeLegalTipsPage> {
  static const _categories = ['最近', '養狗', '租屋', '拍照隱私', '網購', '交通'];

  late final PageController _featuredController;
  late final TextEditingController _searchController;
  Timer? _featuredTimer;
  var _selectedCategory = '最近';
  var _featuredIndex = 0;
  var _query = '';

  @override
  void initState() {
    super.initState();
    _featuredController = PageController();
    _searchController = TextEditingController();
    _searchController.addListener(() {
      setState(() {
        _query = _searchController.text.trim();
      });
    });
    // 台灣繁體中文教學註解：本週精選固定取前五則，之後改接 API 時可改成後端排序結果。
    _featuredTimer = Timer.periodic(const Duration(seconds: 4), (__) {
      if (!_featuredController.hasClients) return;
      final next = (_featuredIndex + 1) % 5;
      _featuredController.animateToPage(
        next,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _featuredTimer?.cancel();
    _featuredController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final featuredItems = homeNewsletterItems.take(5).toList(growable: false);
    final filteredItems = homeNewsletterItems.where((item) {
      final matchesCategory =
          _selectedCategory == '最近' || item.category == _selectedCategory;
      final matchesQuery = _query.isEmpty ||
          item.title.contains(_query) ||
          item.summary.contains(_query) ||
          item.tip.contains(_query) ||
          item.category.contains(_query);
      return matchesCategory && matchesQuery;
    }).toList(growable: false);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16.w, topPadding + 132.h, 16.w, 30.h),
            children: [
              _LifeTipCategoryRail(
                labels: _categories,
                selectedLabel: _selectedCategory,
                onSelected: (label) {
                  setState(() => _selectedCategory = label);
                },
              ),
              SizedBox(height: 18.h),
              _SubpageInlineHeader(title: '本週精選', count: featuredItems.length),
              SizedBox(height: 10.h),
              SizedBox(
                height: 214.h,
                child: PageView.builder(
                  controller: _featuredController,
                  physics: const BouncingScrollPhysics(),
                  itemCount: featuredItems.length,
                  onPageChanged: (index) {
                    setState(() => _featuredIndex = index);
                  },
                  itemBuilder: (context, index) {
                    final item = featuredItems[index];
                    return Padding(
                      padding: EdgeInsets.only(right: index == 4 ? 0 : 8.w),
                      child: _LifeTipFeaturedCard(
                        item: item,
                        onTap: () => _openTip(context, item),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 10.h),
              _LifeTipPageDots(
                count: featuredItems.length,
                activeIndex: _featuredIndex,
              ),
              SizedBox(height: 18.h),
              _SubpageInlineHeader(
                title: _selectedCategory == '最近' ? '最近筆記' : _selectedCategory,
                count: filteredItems.length,
              ),
              SizedBox(height: 10.h),
              if (filteredItems.isEmpty)
                const _SubpageStatusCard(message: '目前沒有符合條件的筆記，換個關鍵字試試看。')
              else
                ...filteredItems.map(
                  (item) => Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: _LifeTipListCard(
                      item: item,
                      onTap: () => _openTip(context, item),
                    ),
                  ),
                ),
              SizedBox(height: 8.h),
              const _SubpageStatusCard(
                message: '內容是一般法律知識與風險提醒，不等於律師正式法律意見；遇到具體爭議，請保留證據並諮詢專業人士。',
              ),
            ],
          ),
          _LifeTrapTopFrostMask(topPadding: topPadding),
          Positioned(
            top: topPadding + 8.h,
            left: 16.w,
            right: 16.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LifeTrapAppBar(onBack: () => Navigator.of(context).pop()),
                SizedBox(height: 12.h),
                _LifeTrapSearchBar(controller: _searchController),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openTip(BuildContext context, HomeNewsletterItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (__) => LifeLegalTipDetailPage(item: item)),
    );
  }
}

class LifeLegalTipDetailPage extends StatelessWidget {
  const LifeLegalTipDetailPage({
    super.key,
    required this.item,
  });

  final HomeNewsletterItem item;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final detailGap = 10.h;
    final detailHeroHeight = 180.h;
    final reactionBarHeight = 58.h;
    final pinnedHeaderHeight = topPadding +
        8.h +
        42.h +
        detailGap +
        detailHeroHeight +
        detailGap +
        reactionBarHeight +
        detailGap;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              16.w,
              pinnedHeaderHeight,
              16.w,
              30.h,
            ),
            children: _buildScrollableContent(context),
          ),
          _LifeTipDetailTopFrost(height: pinnedHeaderHeight),
          Positioned(
            top: topPadding + 8.h,
            left: 16.w,
            right: 16.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SubpageTopBar(onBack: () => Navigator.of(context).pop()),
                SizedBox(height: detailGap),
                _LifeTipDetailHero(
                  item: item,
                  height: detailHeroHeight,
                ),
                SizedBox(height: detailGap),
                _LifeTipReactionBar(
                  item: item,
                  height: reactionBarHeight,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildScrollableContent(BuildContext context) {
    // 台灣繁體中文教學註解：
    // 所有生活避坑筆記詳細頁共用這份版型；Hero 與互動列固定在上方，
    // 這裡只放可以上下閱讀的補充內容。
    return [
      _LifeTipSectionCard(
        title: '你需要先知道',
        child: Text(
          item.summary,
          style: TextStyle(
            fontSize: 14.sp,
            height: 1.6,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      SizedBox(height: 12.h),
      _LifeTipSectionCard(
        title: '可以先怎麼做',
        child: Column(
          children: _buildActionSteps(item).map((step) {
            return Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    size: 18.sp,
                    color: HomeV2Palette.trustGreen,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      step,
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        height: 1.45,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(growable: false),
        ),
      ),
      SizedBox(height: 12.h),
      _LifeTipSectionCard(
        title: '小提醒',
        child: Text(
          item.tip,
          style: TextStyle(
            fontSize: 13.sp,
            height: 1.55,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF3F8B2A),
          ),
        ),
      ),
      SizedBox(height: 14.h),
      Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (__) => LawAssistantSearchPage(
                      initialPrompt: '我想了解「${item.title}」這個生活法律問題，可以怎麼處理？',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.psychology_alt_outlined),
              label: const Text('問小法助'),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (__) => StatuteDatabasePage(
                      initialQuery: _statuteQueryForTip(item),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.manage_search_rounded),
              label: const Text('查相關法規'),
            ),
          ),
        ],
      ),
    ];
  }

  static List<String> _buildActionSteps(HomeNewsletterItem item) {
    if (item.title.contains('狗')) {
      return const [
        '先確認是否有受傷與就醫紀錄。',
        '保留現場照片、監視器、牽繩或飼主資訊。',
        '若要協商賠償，先整理醫藥費與其他損失單據。'
      ];
    }
    if (item.title.contains('自拍')) {
      return const [
        '上傳前確認畫面中是否有可辨識的路人。',
        '避免把他人臉部、車牌或住家資訊放大作為主角。',
        '若涉及商業用途，應特別注意肖像權與授權。'
      ];
    }
    return const [
      '先翻出契約，確認提前解約、押金與修繕條款。',
      '退租前後拍照錄影，保留點交與對話紀錄。',
      '若對方扣押金，請對方提出明細、照片或收據。'
    ];
  }

  static String _statuteQueryForTip(HomeNewsletterItem item) {
    if (item.title.contains('狗')) return '民法 動物';
    if (item.title.contains('自拍')) return '肖像權';
    return '租賃 押金';
  }
}

/// 首頁專題的完整列表頁。
///
/// 台灣繁體中文教學註解：
/// 這頁復用 learning mock data，等學習 API 完成時，只要把資料來源換成 repository，
/// 卡片與導頁方式可以沿用。
class HomeLearningTopicsPage extends StatelessWidget {
  const HomeLearningTopicsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final units = learningTopic.units;
    final related = learningTopic.relatedTopics;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, topPadding + 14.h, 16.w, 30.h),
        children: [
          _SubpageTopBar(onBack: () => Navigator.of(context).pop()),
          SizedBox(height: 18.h),
          const _SubpageHero(
            title: '法律學習專題',
            subtitle: '沿用首頁淡色卡片，把課程單元、相關主題與測驗入口整理成完整列表。',
            icon: Icons.menu_book_outlined,
            color: HomeV2Palette.mint,
          ),
          SizedBox(height: 16.h),
          _LearningArticleCard(
            title: learningTopic.heroArticle.title,
            summary: learningTopic.heroArticle.summary,
            label: '主專題',
            onTap: () => _openArticle(context, learningTopic.heroArticle),
          ),
          SizedBox(height: 12.h),
          ...units.map(
            (unit) => Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: _LearningArticleCard(
                title: unit.title,
                summary: unit.goal,
                label: unit.stepLabel,
                onTap: () => _openArticle(context, unit.article),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '延伸主題',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 10.h),
          ...related.map(
            (topic) => Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: _LearningArticleCard(
                title: topic.title,
                summary: topic.summary,
                label: topic.focusLabel,
                onTap: () => _openArticle(context, topic.article),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openArticle(BuildContext context, LearningMockArticle article) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (__) => LearningMockDetailPage(article: article),
      ),
    );
  }
}

class _OfficialFeedCard extends StatelessWidget {
  const _OfficialFeedCard({
    required this.item,
    required this.onTap,
  });

  final MojFeedItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Ink(
          padding: EdgeInsets.all(15.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  color: HomeV2Palette.mint,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(
                  item.category == MojFeedCategory.news
                      ? Icons.campaign_outlined
                      : Icons.rule_folder_outlined,
                  color: HomeV2Palette.trustGreen,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TinySourceLabel(label: item.badge),
                    SizedBox(height: 6.h),
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        height: 1.35,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
                size: 22.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IssueCard extends StatelessWidget {
  const _IssueCard({
    required this.item,
    required this.onTap,
  });

  final HomeV2IssueItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Ink(
          padding: EdgeInsets.all(15.w),
          decoration: BoxDecoration(
            color: item.color,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(item.icon, color: HomeV2Palette.trustGreen, size: 28.sp),
              const Spacer(),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w900,
                  color: HomeV2Palette.ink,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                item.label == '法規查詢' ? '進入官方法規庫' : '整理常見爭點',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LearningArticleCard extends StatelessWidget {
  const _LearningArticleCard({
    required this.title,
    required this.summary,
    required this.label,
    required this.onTap,
  });

  final String title;
  final String summary;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Ink(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TinySourceLabel(label: label),
              SizedBox(height: 8.h),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  height: 1.28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                summary,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.sp,
                  height: 1.45,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LifeTrapTopFrostMask extends StatelessWidget {
  const _LifeTrapTopFrostMask({required this.topPadding});

  final double topPadding;

  @override
  Widget build(BuildContext context) {
    // 台灣繁體中文教學註解：上方霧面遮罩固定在 SafeArea 外圍，
    // 內容滑到頂端時會像首頁一樣被柔和收進標題列後方。
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              height: topPadding + 130.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.background.withValues(alpha: 0.96),
                    AppColors.background.withValues(alpha: 0.86),
                    AppColors.background.withValues(alpha: 0),
                  ],
                  stops: const [0, 0.72, 1],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LifeTipDetailTopFrost extends StatelessWidget {
  const _LifeTipDetailTopFrost({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    // 台灣繁體中文教學註解：固定區只負責遮住上方 pinned header，
    // 不再往下做大範圍漸層，避免第一張內容卡被霧面吃掉。
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(
              height: height,
              color: AppColors.background.withValues(alpha: 0.96),
            ),
          ),
        ),
      ),
    );
  }
}

class _LifeTrapAppBar extends StatelessWidget {
  const _LifeTrapAppBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    // 台灣繁體中文教學註解：這裡做成真正的 AppBar 結構，
    // 返回箭頭與頁面標題同列；搜尋欄則放在下一列，避免把標題做成內容卡片。
    return SizedBox(
      height: 42.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: _SubpageTopBar(onBack: onBack),
          ),
          Text(
            '生活避坑筆記',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _LifeTrapSearchBar extends StatelessWidget {
  const _LifeTrapSearchBar({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: '搜尋租屋、網購、養狗、交通...',
          border: InputBorder.none,
          icon: Icon(
            Icons.search_rounded,
            color: AppColors.textMuted,
            size: 21.sp,
          ),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  onPressed: controller.clear,
                  icon: Icon(Icons.close_rounded, size: 19.sp),
                ),
        ),
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _SubpageInlineHeader extends StatelessWidget {
  const _SubpageInlineHeader({
    required this.title,
    required this.count,
  });

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Text(
          '$count 則',
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _LifeTipPageDots extends StatelessWidget {
  const _LifeTipPageDots({
    required this.count,
    required this.activeIndex,
  });

  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: isActive ? 18.w : 6.w,
          height: 6.h,
          margin: EdgeInsets.symmetric(horizontal: 3.w),
          decoration: BoxDecoration(
            color: isActive
                ? HomeV2Palette.trustGreen
                : AppColors.border.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(99.r),
          ),
        );
      }),
    );
  }
}

IconData _lifeTipIconForCategory(String category) {
  return switch (category) {
    '養狗' => Icons.pets_rounded,
    '租屋' => Icons.home_work_outlined,
    '拍照隱私' => Icons.photo_camera_outlined,
    '網購' => Icons.shopping_bag_outlined,
    '交通' => Icons.traffic_rounded,
    _ => Icons.lightbulb_outline_rounded,
  };
}

class _LifeTipFeaturedCard extends StatelessWidget {
  const _LifeTipFeaturedCard({
    required this.item,
    required this.onTap,
  });

  final HomeNewsletterItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22.r),
        child: Ink(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF6E8D7),
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TinySourceLabel(label: '本週精選'),
                    SizedBox(height: 10.h),
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 18.sp,
                        height: 1.22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      item.summary,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.sp,
                        height: 1.45,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                width: 82.w,
                height: 92.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFD7C8A6),
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: Icon(
                  _lifeTipIconForCategory(item.category),
                  color: Colors.white,
                  size: 34.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LifeTipCategoryRail extends StatelessWidget {
  const _LifeTipCategoryRail({
    required this.labels,
    required this.selectedLabel,
    required this.onSelected,
  });

  final List<String> labels;
  final String selectedLabel;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final label = labels[index];
          final isSelected = label == selectedLabel;
          return InkWell(
            onTap: () => onSelected(label),
            borderRadius: BorderRadius.circular(999.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isSelected ? HomeV2Palette.mint : Colors.white,
                borderRadius: BorderRadius.circular(999.r),
                border: Border.all(
                  color: isSelected
                      ? HomeV2Palette.trustGreen.withValues(alpha: 0.28)
                      : AppColors.border,
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w800,
                  color: isSelected
                      ? HomeV2Palette.trustGreen
                      : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemCount: labels.length,
      ),
    );
  }
}

class _LifeTipListCard extends StatelessWidget {
  const _LifeTipListCard({
    required this.item,
    required this.onTap,
  });

  final HomeNewsletterItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Ink(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: HomeV2Palette.mint,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(
                  _lifeTipIconForCategory(item.category),
                  color: HomeV2Palette.trustGreen,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      item.tip,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
                size: 22.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LifeTipDetailHero extends StatelessWidget {
  const _LifeTipDetailHero({
    required this.item,
    required this.height,
  });

  final HomeNewsletterItem item;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF6E8D7),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TinySourceLabel(label: '生活避坑筆記'),
          SizedBox(height: 12.h),
          Text(
            item.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 24.sp,
              height: 1.18,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            '適合在事情發生前先看懂，也適合在遇到狀況時拿來整理下一步。',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.sp,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _LifeTipReactionBar extends StatefulWidget {
  const _LifeTipReactionBar({
    required this.item,
    required this.height,
  });

  final HomeNewsletterItem item;
  final double height;

  @override
  State<_LifeTipReactionBar> createState() => _LifeTipReactionBarState();
}

class _LifeTipReactionBarState extends State<_LifeTipReactionBar> {
  var _isLiked = false;
  var _isBookmarked = false;
  var _shareDelta = 0;
  var _commentDelta = 0;

  int _countBase(String value) {
    final digits = RegExp(r'\d+').firstMatch(value)?.group(0);
    return int.tryParse(digits ?? '') ?? 0;
  }

  String _countLabel(String value, int delta) {
    final next = _countBase(value) + delta;
    if (next >= 1000) return '${(next / 1000).toStringAsFixed(1)}k';
    return '$next';
  }

  String _plainCountLabel(int value) {
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}k';
    return '$value';
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Container(
      height: widget.height,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _LifeTipReactionButton(
            icon: _isLiked ? Icons.favorite_rounded : Icons.favorite_border,
            label: _countLabel(item.likes, _isLiked ? 1 : 0),
            color: const Color(0xFFE65E64),
            onTap: () => setState(() => _isLiked = !_isLiked),
          ),
          _LifeTipReactionButton(
            icon: Icons.ios_share_rounded,
            label: _countLabel(item.shares, _shareDelta),
            color: const Color(0xFF9B7A2E),
            onTap: () {
              setState(() => _shareDelta += 1);
              _showSnack('已準備分享「${item.title}」');
            },
          ),
          _LifeTipReactionButton(
            icon: Icons.mode_comment_outlined,
            label: _countLabel(item.comments, _commentDelta),
            color: const Color(0xFF4F9B55),
            onTap: () {
              setState(() => _commentDelta += 1);
              _showSnack('留言功能已記錄，之後可接會員留言 API。');
            },
          ),
          _LifeTipReactionButton(
            icon: _isBookmarked
                ? Icons.bookmark_rounded
                : Icons.bookmark_border_rounded,
            label: _plainCountLabel(
              _countBase(item.downloads) + (_isBookmarked ? 1 : 0),
            ),
            color: const Color(0xFF58AAA6),
            onTap: () => setState(() => _isBookmarked = !_isBookmarked),
          ),
        ],
      ),
    );
  }
}

class _LifeTipReactionButton extends StatelessWidget {
  const _LifeTipReactionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 18.sp),
                SizedBox(width: 5.w),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
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

class _LifeTipSectionCard extends StatelessWidget {
  const _LifeTipSectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 10.h),
          child,
        ],
      ),
    );
  }
}

class _SubpageHero extends StatelessWidget {
  const _SubpageHero({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final shouldStack = MediaQuery.sizeOf(context).width < 340 ||
        MediaQuery.textScalerOf(context).scale(1) > 1.18;
    final iconWidget = Icon(icon, color: HomeV2Palette.trustGreen, size: 30.sp);

    Widget buildTextColumn() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 22.sp,
              height: 1.16,
              fontWeight: FontWeight.w900,
              color: HomeV2Palette.ink,
            ),
          ),
          SizedBox(height: 7.h),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12.sp,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      );
    }

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
      ),
      child: shouldStack
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                iconWidget,
                SizedBox(height: 10.h),
                buildTextColumn(),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                iconWidget,
                SizedBox(width: 12.w),
                Expanded(child: buildTextColumn()),
              ],
            ),
    );
  }
}

class _SubpageTopBar extends StatelessWidget {
  const _SubpageTopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: onBack,
          child: SizedBox(
            width: 42.w,
            height: 42.w,
            child: Icon(Icons.arrow_back_ios_new_rounded, size: 20.sp),
          ),
        ),
      ],
    );
  }
}

class _SubpageStatusCard extends StatelessWidget {
  const _SubpageStatusCard({
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: TextStyle(
              fontSize: 13.sp,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            SizedBox(height: 10.h),
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

class _TinySourceLabel extends StatelessWidget {
  const _TinySourceLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: HomeV2Palette.mint,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5.sp,
          fontWeight: FontWeight.w800,
          color: HomeV2Palette.trustGreen,
        ),
      ),
    );
  }
}
