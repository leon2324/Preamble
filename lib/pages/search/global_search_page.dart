import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/components/search/search_page_layout.dart';
import 'package:lawapp/pages/learning/know_law_page.dart';
import 'package:lawapp/pages/learning/statute_database_page.dart';
import 'package:lawapp/pages/trending/trending_page.dart';
import 'package:lawapp/theme/app_colors.dart';

/// 全站搜尋頁。
///
/// 台灣繁體中文教學註解：
/// 搜尋現在是底部 Nav 的中間分頁，代表它是跨首頁、學習、案例與會員工具的
/// 全站入口；這頁先沿用既有 SearchPageLayout，日後要接真正搜尋 API 時，
/// 可以把 `_allSearchHints` 換成後端回傳的結果清單。
class GlobalSearchPage extends StatefulWidget {
  const GlobalSearchPage({super.key});

  @override
  State<GlobalSearchPage> createState() => _GlobalSearchPageState();
}

class _GlobalSearchPageState extends State<GlobalSearchPage> {
  final TextEditingController _controller = TextEditingController();

  static const List<_SearchHintItem> _allSearchHints = [
    _SearchHintItem(
      title: '房東不退押金',
      subtitle: '租屋、押金、提前解約',
      icon: Icons.home_work_rounded,
      destination: _SearchDestination.assistant,
      query: '房東不退押金，我可以怎麼處理？',
    ),
    _SearchHintItem(
      title: '加班費怎麼算',
      subtitle: '勞資、工時、補休',
      icon: Icons.badge_rounded,
      destination: _SearchDestination.statutes,
      query: '勞動基準法',
    ),
    _SearchHintItem(
      title: '車禍後先做什麼',
      subtitle: '交通事故、證據保存、和解',
      icon: Icons.directions_car_filled_rounded,
      destination: _SearchDestination.assistant,
      query: '發生車禍後，我要先保存哪些資料？',
    ),
    _SearchHintItem(
      title: '網購七天鑑賞期',
      subtitle: '消費者保護、退貨、例外商品',
      icon: Icons.shopping_bag_rounded,
      destination: _SearchDestination.statutes,
      query: '消費者保護法',
    ),
    _SearchHintItem(
      title: '詐騙車手案件',
      subtitle: '案例庫、洗錢、詐欺',
      icon: Icons.local_library_rounded,
      destination: _SearchDestination.cases,
      query: '詐騙',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // 教學註解：SearchPageLayout 只負責固定搜尋列與頁面骨架；
    // 搜尋字變更後要刷新下方內容，因此在這頁自己監聽 controller。
    _controller.addListener(_refreshResults);
  }

  @override
  void dispose() {
    _controller.removeListener(_refreshResults);
    _controller.dispose();
    super.dispose();
  }

  void _refreshResults() => setState(() {});

  List<_SearchHintItem> get _visibleHints {
    final query = _controller.text.trim();
    if (query.isEmpty) return _allSearchHints;

    return _allSearchHints.where((item) {
      return item.title.contains(query) || item.subtitle.contains(query);
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final visibleHints = _visibleHints;
    final hasQuery = _controller.text.trim().isNotEmpty;

    return SearchPageLayout(
      controller: _controller,
      hintText: '搜尋法條、案例、新聞、關鍵字...',
      headerTitle: '搜尋',
      headerSubtitle: '輸入關鍵字，快速查找學習內容、法條資料與案件紀事。',
      headerTitleSize: 30,
      searchBarSurfaceColor: Colors.white,
      builder: (context, layout, contentTopPadding, contentBottomPadding) {
        return ListView(
          padding: EdgeInsets.fromLTRB(
            16.w,
            contentTopPadding,
            16.w,
            contentBottomPadding,
          ),
          children: [
            Text(
              hasQuery ? '搜尋建議' : '熱門搜尋',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 12.h),
            if (visibleHints.isEmpty)
              const _SearchEmptyState()
            else
              ...visibleHints.map(
                (item) => Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: _SearchHintCard(
                    item: item,
                    onTap: () => _openSearchDestination(item),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _openSearchDestination(_SearchHintItem item) {
    // 台灣繁體中文教學註解：
    // 全站搜尋第一版先把常見查詢導到最適合的既有頁面；
    // 後續接搜尋 API 後，這裡可以改成結果詳情頁或混合搜尋結果。
    switch (item.destination) {
      case _SearchDestination.assistant:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const LawAssistantSearchPage()),
        );
        break;
      case _SearchDestination.statutes:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => StatuteDatabasePage(initialQuery: item.query),
          ),
        );
        break;
      case _SearchDestination.cases:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const TrendingPage()),
        );
        break;
    }
  }
}

enum _SearchDestination {
  assistant,
  statutes,
  cases,
}

class _SearchHintItem {
  const _SearchHintItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.destination,
    required this.query,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final _SearchDestination destination;
  final String query;
}

class _SearchHintCard extends StatelessWidget {
  const _SearchHintCard({
    required this.item,
    required this.onTap,
  });

  final _SearchHintItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Container(
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
                decoration: const BoxDecoration(
                  color: AppColors.chipSurface,
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, color: AppColors.primary, size: 22.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      item.subtitle,
                      style: TextStyle(
                        fontSize: 11.5.sp,
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

class _SearchEmptyState extends StatelessWidget {
  const _SearchEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        '目前沒有符合的建議；之後接上搜尋 API 後，這裡會顯示全站結果。',
        style: TextStyle(
          fontSize: 13.sp,
          height: 1.45,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
