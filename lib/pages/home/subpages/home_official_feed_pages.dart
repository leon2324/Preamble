import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/components/home/v2/home_v2_palette.dart';
import 'package:lawapp/data/moj/moj_feed_item.dart';
import 'package:lawapp/data/moj/moj_feed_service.dart';
import 'package:lawapp/pages/home/subpages/home_subpage_primitives.dart';
import 'package:lawapp/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

// 首頁子頁的官方消息頁面群。
// 只放法務部公開資料列表、詳細頁與卡片 UI，不放首頁入口或其他子頁邏輯。

/// 法務部公開資料列表頁。
///
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
