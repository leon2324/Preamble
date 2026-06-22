import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/components/home/v2/home_v2_palette.dart';
import 'package:lawapp/data/mock_data/home/home_v2_mock_data.dart';
import 'package:lawapp/data/mock_data/learning/learning_mock_data.dart';
import 'package:lawapp/data/moj/moj_feed_item.dart';
import 'package:lawapp/data/moj/moj_feed_service.dart';
import 'package:lawapp/pages/home/subpages/home_subpage_primitives.dart';
import 'package:lawapp/pages/learning/know_law_page.dart';
import 'package:lawapp/pages/learning/learning_mock_detail_page.dart';
import 'package:lawapp/pages/learning/statute_database_page.dart';
import 'package:lawapp/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

export 'subpages/home_life_legal_tips_page.dart';
export 'subpages/home_subpage_primitives.dart';

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
          SubpageTopBar(onBack: () => Navigator.of(context).pop()),
          SizedBox(height: 18.h),
          SubpageHero(
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
                return const SubpageStatusCard(message: '正在讀取官方資料...');
              }

              if (snapshot.hasError) {
                return SubpageStatusCard(
                  message: snapshot.error.toString(),
                  actionLabel: '再試一次',
                  onAction: _reload,
                );
              }

              final items = snapshot.data ?? const <MojFeedItem>[];
              if (items.isEmpty) {
                return const SubpageStatusCard(message: '目前沒有可顯示的資料。');
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
          SubpageTopBar(onBack: () => Navigator.of(context).pop()),
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
                TinySourceLabel(label: '${item.badge} · ${item.sourceLabel}'),
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
          const SubpageStatusCard(
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
        builder: (__) => LawAssistantChatPage(
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
          SubpageTopBar(onBack: () => Navigator.of(context).pop()),
          SizedBox(height: 18.h),
          const SubpageHero(
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
          SubpageTopBar(onBack: () => Navigator.of(context).pop()),
          SizedBox(height: 18.h),
          const SubpageHero(
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
                    TinySourceLabel(label: item.badge),
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
              TinySourceLabel(label: label),
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
