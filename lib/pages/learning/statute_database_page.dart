import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/app/app_state.dart';
import 'package:lawapp/components/shared/mvp_state_widgets.dart';
import 'package:lawapp/data/common/app_loading_quotes.dart';
import 'package:lawapp/data/statutes/statute_item.dart';
import 'package:lawapp/data/statutes/statute_repository.dart';
import 'package:lawapp/pages/learning/know_law_page.dart';
import 'package:lawapp/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class StatuteDatabasePage extends StatefulWidget {
  const StatuteDatabasePage({
    super.key,
    this.initialQuery = '',
    StatuteRepository? repository,
  }) : _repository = repository;

  final String initialQuery;
  final StatuteRepository? _repository;

  @override
  State<StatuteDatabasePage> createState() => _StatuteDatabasePageState();
}

class _StatuteDatabasePageState extends State<StatuteDatabasePage> {
  static const List<String> _quickFilters = [
    '全部',
    '法律',
    '法規命令',
    '行政規則',
    '解釋函令',
  ];
  static const List<_StatuteQueryEntry> _popularQueries = [
    _StatuteQueryEntry(
      title: '民法第 184 條',
      subtitle: '侵權行為',
      query: '民法 184',
    ),
    _StatuteQueryEntry(
      title: '租賃契約相關法條',
      subtitle: '租賃、押金、修繕',
      query: '租賃',
    ),
    _StatuteQueryEntry(
      title: '勞動基準法第 24 條',
      subtitle: '工資、工時、加班',
      query: '勞動基準法 24',
    ),
  ];
  static const List<_StatuteQueryEntry> _defaultRecentEntries = [
    _StatuteQueryEntry(
      title: '民法第 184 條',
      subtitle: '最後瀏覽：2026/04/23',
      query: '民法 184',
    ),
    _StatuteQueryEntry(
      title: '消費者保護法第 7 條',
      subtitle: '最後瀏覽：2026/04/22',
      query: '消費者保護法 7',
    ),
    _StatuteQueryEntry(
      title: '道路交通管理處罰條例第 56 條',
      subtitle: '最後瀏覽：2026/04/22',
      query: '道路交通管理處罰條例 56',
    ),
  ];

  late final StatuteRepository _repository;
  late final bool _ownsRepository;
  late final TextEditingController _searchController;
  Future<StatuteSearchResult>? _searchFuture;
  late List<_StatuteQueryEntry> _recentEntries;
  String _query = '';
  String _selectedFilter = '全部';

  @override
  void initState() {
    super.initState();
    _ownsRepository = widget._repository == null;
    _repository = widget._repository ?? StatuteRepository();
    _query = widget.initialQuery;
    _searchController = TextEditingController(text: widget.initialQuery);
    if (widget.initialQuery.trim().isNotEmpty) {
      _searchFuture = _searchStatutes();
    }
    _recentEntries = List<_StatuteQueryEntry>.from(_defaultRecentEntries);
  }

  @override
  void dispose() {
    _searchController.dispose();
    if (_ownsRepository) {
      _repository.dispose();
    }
    super.dispose();
  }

  void _reload() {
    setState(() {
      _searchFuture = _searchStatutes(forceRefresh: true);
    });
  }

  Future<StatuteSearchResult> _ensureSearchFuture() {
    return _searchFuture ??= _searchStatutes();
  }

  Future<StatuteSearchResult> _searchStatutes({bool forceRefresh = false}) {
    final category = _selectedFilter == '全部' ? '' : _selectedFilter;
    return _repository.searchStatutes(
      query: _query,
      category: category,
      forceRefresh: forceRefresh,
    );
  }

  void _applyGuideQuery(String query) {
    // 教學註解：首頁型入口會同時更新搜尋欄文字、篩選膠囊與查詢字串，
    // 讓使用者點入口後，看到的列表、搜尋欄狀態與選中的分類保持一致。
    setState(() {
      _searchController.text = query;
      _query = query;
      _selectedFilter = _quickFilters.contains(query) ? query : '全部';
      _rememberQuery(query);
      _searchFuture = _searchStatutes();
    });
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _submitSearch(String value) {
    final query = value.trim();
    if (query.isEmpty) return;
    // 台灣繁體中文教學註解：
    // TextField 的 onChanged 只負責即時篩選；使用者按鍵盤搜尋或點入口時，
    // 才把關鍵字記進最近查詢，避免每打一個字都產生一筆假瀏覽紀錄。
    setState(() {
      _query = query;
      _searchController.text = query;
      _searchController.selection = TextSelection.collapsed(
        offset: query.length,
      );
      _selectedFilter = _quickFilters.contains(query) ? query : '全部';
      _rememberQuery(query);
      _searchFuture = _searchStatutes();
    });
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _rememberQuery(String query) {
    if (query.trim().isEmpty) return;
    _recentEntries.removeWhere((entry) => entry.query == query);
    _recentEntries.insert(
      0,
      _StatuteQueryEntry(
        title: query,
        subtitle: '剛剛瀏覽',
        query: query,
      ),
    );
    if (_recentEntries.length > 5) {
      _recentEntries = _recentEntries.take(5).toList(growable: true);
    }
  }

  void _clearRecentEntries() {
    setState(() {
      _recentEntries = [];
    });
  }

  void _openFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26.r)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 22.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '篩選資料類型',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 12.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: _quickFilters.map((label) {
                    return _FilterChipButton(
                      label: label,
                      isSelected: label == _selectedFilter,
                      onTap: () {
                        Navigator.of(context).pop();
                        setState(() {
                          _selectedFilter = label;
                          _searchFuture = _searchStatutes();
                        });
                      },
                    );
                  }).toList(growable: false),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    final hasActiveSearch = _query.trim().isNotEmpty || _selectedFilter != '全部';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F0),
      body: Padding(
        padding: EdgeInsets.fromLTRB(16.w, topPadding + 14.h, 16.w, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StatuteTopBar(
              onBack: () => Navigator.of(context).pop(),
            ),
            SizedBox(height: 18.h),
            Row(
              children: [
                Expanded(
                  child: _StatuteSearchField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _query = value;
                        _searchFuture =
                            hasActiveSearch ? _searchStatutes() : _searchFuture;
                      });
                    },
                    onClear: () {
                      // 教學註解：清除按鈕要同時清 TextField 與本頁用來篩選資料的 `_query`，
                      // 否則畫面看起來清空了，列表仍會被舊關鍵字過濾。
                      setState(() {
                        _searchController.clear();
                        _query = '';
                        _searchFuture = null;
                      });
                    },
                    onSubmitted: _submitSearch,
                  ),
                ),
                SizedBox(width: 10.w),
                _FilterSquareButton(onTap: _openFilterSheet),
              ],
            ),
            SizedBox(height: 14.h),
            _StatuteFilterRail(
              filters: _quickFilters,
              selectedFilter: _selectedFilter,
              onFilterTap: (label) {
                setState(() {
                  _selectedFilter = label;
                  _searchFuture = _searchStatutes();
                });
              },
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: hasActiveSearch
                  ? FutureBuilder<StatuteSearchResult>(
                      future: _ensureSearchFuture(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const _StatuteLoadingState();
                        }

                        if (snapshot.hasError) {
                          return _StatuteErrorState(
                            message: snapshot.error.toString(),
                            onRetry: _reload,
                          );
                        }

                        final result = snapshot.data ??
                            const StatuteSearchResult(
                              items: [],
                              isMock: false,
                            );
                        final items = result.items.take(50).toList();
                        if (items.isEmpty) {
                          return const _StatuteEmptyState();
                        }

                        return ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: EdgeInsets.only(bottom: 28.h),
                          itemCount: items.length,
                          separatorBuilder: (_, __) => SizedBox(height: 10.h),
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return _StatuteResultCard(
                              item: item,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (__) =>
                                        StatuteDetailPage(item: item),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    )
                  : _StatuteLandingBody(
                      popularQueries: _popularQueries,
                      recentEntries: _recentEntries,
                      onQueryTap: _applyGuideQuery,
                      onClearRecent: _clearRecentEntries,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatuteQueryEntry {
  const _StatuteQueryEntry({
    required this.title,
    required this.subtitle,
    required this.query,
  });

  final String title;
  final String subtitle;
  final String query;
}

class StatuteDetailPage extends StatefulWidget {
  const StatuteDetailPage({super.key, required this.item});

  final StatuteItem item;

  @override
  State<StatuteDetailPage> createState() => _StatuteDetailPageState();
}

class _StatuteDetailPageState extends State<StatuteDetailPage> {
  StatuteItem get item => widget.item;

  Future<void> _toggleFollow(bool isFollowed) async {
    final appState = LawAppScope.of(context);
    // 台灣繁體中文教學註解：
    // 法規頁的追蹤不是本頁自己的暫存 bool，而是寫進 App 共用的 FollowingSummary；
    // 這樣從全站搜尋追蹤、從法規頁追蹤、到我的 LawApp 查看，都會看到同一份資料。
    await appState.setStatuteFollowed(_statuteInteractionId(item), !isFollowed);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(isFollowed ? '已取消追蹤。' : '已加入追蹤法條。')),
    );
  }

  Future<void> _toggleSaved(bool isSaved) async {
    final appState = LawAppScope.of(context);
    await appState.setStatuteSaved(_statuteInteractionId(item), !isSaved);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(isSaved ? '已取消收藏。' : '已收藏法條。')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final appState = LawAppScope.of(context);
    final statuteId = _statuteInteractionId(item);
    final isFollowed = appState.isStatuteFollowed(statuteId);
    final isSaved = appState.isStatuteSaved(statuteId);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F0),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, topPadding + 14.h, 16.w, 32.h),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: _RoundToolButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            item.codeName,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF64715A),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            item.articleNumber.isEmpty ? '條文內容' : item.articleNumber,
            style: TextStyle(
              fontSize: 26.sp,
              height: 1.15,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          _DetailSectionCard(
            title: '條文原文',
            child: SelectableText(
              item.articleText,
              style: TextStyle(
                fontSize: 16.sp,
                height: 1.65,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          _DetailSectionCard(
            title: '白話文解釋',
            child: Text(
              item.plainSummary,
              style: TextStyle(
                fontSize: 14.sp,
                height: 1.6,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          _DetailSectionCard(
            title: '生活例子',
            child: Text(
              _lifeExampleFor(item),
              style: TextStyle(
                fontSize: 14.sp,
                height: 1.6,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          _DetailSectionCard(
            title: '可能相關情境',
            child: Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: _scenarioChipsFor(item)
                  .map((label) => Chip(label: Text(label)))
                  .toList(growable: false),
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (__) => LawAssistantSearchPage(
                          initialPrompt:
                              '我想了解「${item.displayTitle}」在生活案例中怎麼使用？',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.smart_toy_outlined),
                  label: const Text('用這條法規問小法助'),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _toggleFollow(isFollowed),
                  icon: Icon(isFollowed
                      ? Icons.notifications_active_rounded
                      : Icons.notifications_none_rounded),
                  label: Text(isFollowed ? '已追蹤' : '加入追蹤'),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _toggleSaved(isSaved),
                  icon: Icon(isSaved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded),
                  label: Text(isSaved ? '已收藏' : '收藏法條'),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _DetailSectionCard(
            title: '資料資訊',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DetailMetaRow(label: '法規類別', value: item.category),
                _DetailMetaRow(label: '最新異動', value: item.updatedDate),
                _DetailMetaRow(
                  label: '資料來源',
                  value: item.sourceName,
                ),
                if (item.lawUrl.isNotEmpty) ...[
                  SizedBox(height: 10.h),
                  OutlinedButton.icon(
                    onPressed: () {
                      launchUrl(
                        Uri.parse(item.lawUrl),
                        mode: LaunchMode.externalApplication,
                      );
                    },
                    icon: Icon(Icons.open_in_new_rounded, size: 16.sp),
                    label: const Text('前往全國法規資料庫'),
                  ),
                  SizedBox(height: 4.h),
                  SelectableText(
                    item.lawUrl,
                    style: TextStyle(
                      fontSize: 12.sp,
                      height: 1.45,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 12.h),
          const LegalDisclaimerBox(),
        ],
      ),
    );
  }
}

String _statuteInteractionId(StatuteItem item) {
  final raw = '${item.codeName}-${item.articleNumber}';
  return 'statute-${raw.trim().replaceAll(RegExp(r'\s+'), '').replaceAll(RegExp(r'[^a-zA-Z0-9\u4e00-\u9fff]+'), '').toLowerCase()}';
}

String _lifeExampleFor(StatuteItem item) {
  final text =
      '${item.codeName} ${item.articleNumber} ${item.articleText} ${item.tags.join(' ')}';
  if (text.contains('勞') || text.contains('加班')) {
    return '例如公司要求你下班後繼續工作，卻只說「之後補休」而沒有清楚記錄工時與加班費，這時就可以先回到條文確認工時與工資計算方向。';
  }
  if (text.contains('消費') || text.contains('網購')) {
    return '例如網購商品收到後發現不符合期待，是否能退貨、是否有例外商品，就需要同時看條文、交易紀錄與店家公告。';
  }
  if (text.contains('租') || text.contains('押金')) {
    return '例如退租後房東主張扣押金，但沒有提供修繕明細，你可以先整理租約、點交照片與對話紀錄，再判斷是否進入調解或訴訟。';
  }
  if (text.contains('刑') || text.contains('詐')) {
    return '例如收到不明款項或被要求提供帳戶時，是否涉及詐欺或洗錢風險，不能只看單一行為，還要看你是否知情與資金流向。';
  }
  return '例如車禍、網路言論或日常交易造成損害時，除了看條文，也要整理時間線、對方行為、損害證明與你希望請求的結果。';
}

List<String> _scenarioChipsFor(StatuteItem item) {
  final text = '${item.codeName} ${item.articleText} ${item.tags.join(' ')}';
  final chips = <String>{};
  if (text.contains('租') || text.contains('押金')) chips.add('租屋');
  if (text.contains('車') || text.contains('損害')) chips.add('車禍');
  if (text.contains('消費') || text.contains('網購')) chips.add('消費');
  if (text.contains('勞') || text.contains('工資')) chips.add('勞資');
  if (text.contains('刑') || text.contains('詐')) chips.add('刑事');
  chips.addAll(['生活證據', '調解前準備']);
  return chips.take(6).toList(growable: false);
}

class _RoundToolButton extends StatelessWidget {
  const _RoundToolButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // 台灣繁體中文教學註解：
    // 返回鍵統一改成 iOS 簡潔箭頭，不再加底色圓框；
    // 點擊範圍仍保留 42.w，避免視覺變輕後手指不好點。
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 42.w,
          height: 42.w,
          child: Icon(
            icon,
            size: 20.sp,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _StatuteTopBar extends StatelessWidget {
  const _StatuteTopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: _RoundToolButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: onBack,
            ),
          ),
          Text(
            '法規資料庫',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(width: 42.w),
        ],
      ),
    );
  }
}

class _StatuteSearchField extends StatelessWidget {
  const _StatuteSearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13.r),
        border: Border.all(color: const Color(0xFFE7E9DF)),
      ),
      child: TextField(
        controller: controller,
        onTapOutside: (event) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        onChanged: onChanged,
        onSubmitted: (value) => onSubmitted(value.trim()),
        textInputAction: TextInputAction.search,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: '搜尋法條、關鍵字或法規名稱',
          hintStyle: TextStyle(
            fontSize: 13.sp,
            color: const Color(0xFF9AA19A),
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 21.sp,
            color: const Color(0xFF7E877B),
          ),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  onPressed: onClear,
                  tooltip: '清除搜尋關鍵字',
                  icon: Icon(
                    Icons.close_rounded,
                    size: 18.sp,
                    color: const Color(0xFF4B5647),
                  ),
                ),
          border: InputBorder.none,
          isCollapsed: true,
          contentPadding: EdgeInsets.symmetric(vertical: 13.h),
        ),
      ),
    );
  }
}

class _FilterSquareButton extends StatelessWidget {
  const _FilterSquareButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13.r),
        child: Container(
          width: 44.w,
          height: 44.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(13.r),
            border: Border.all(color: const Color(0xFFE7E9DF)),
          ),
          child: Icon(
            Icons.tune_rounded,
            size: 20.sp,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _StatuteFilterRail extends StatelessWidget {
  const _StatuteFilterRail({
    required this.filters,
    required this.selectedFilter,
    required this.onFilterTap,
  });

  final List<String> filters;
  final String selectedFilter;
  final ValueChanged<String> onFilterTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final label = filters[index];
          return _FilterChipButton(
            label: label,
            isSelected: label == selectedFilter,
            onTap: () => onFilterTap(label),
          );
        },
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemCount: filters.length,
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 7.h),
          decoration: BoxDecoration(
            color:
                isSelected ? const Color(0xFFE4F0E8) : const Color(0xFFF1F2EE),
            borderRadius: BorderRadius.circular(999.r),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w800,
              color: isSelected
                  ? const Color(0xFF386249)
                  : const Color(0xFF6C746C),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatuteLandingBody extends StatelessWidget {
  const _StatuteLandingBody({
    required this.popularQueries,
    required this.recentEntries,
    required this.onQueryTap,
    required this.onClearRecent,
  });

  final List<_StatuteQueryEntry> popularQueries;
  final List<_StatuteQueryEntry> recentEntries;
  final ValueChanged<String> onQueryTap;
  final VoidCallback onClearRecent;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(bottom: 32.h),
      children: [
        _StatuteSectionTitle(title: '熱門查詢'),
        SizedBox(height: 10.h),
        _StatuteQueryPanel(
          entries: popularQueries,
          numbered: true,
          onQueryTap: onQueryTap,
        ),
        SizedBox(height: 22.h),
        _StatuteSectionTitle(title: '最近瀏覽'),
        SizedBox(height: 10.h),
        if (recentEntries.isEmpty)
          const _StatuteQuietCard(message: '目前沒有瀏覽記錄。')
        else ...[
          _StatuteQueryPanel(
            entries: recentEntries,
            numbered: false,
            onQueryTap: onQueryTap,
          ),
          SizedBox(height: 12.h),
          Center(
            child: TextButton(
              onPressed: onClearRecent,
              child: const Text('清除瀏覽記錄'),
            ),
          ),
        ],
        SizedBox(height: 10.h),
        const _StatuteQuietCard(
          message: '資料來源：全國法規資料庫法律與命令資料。本頁只呈現公開法規資料，不構成法律意見。',
        ),
      ],
    );
  }
}

class _StatuteSectionTitle extends StatelessWidget {
  const _StatuteSectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 15.sp,
        fontWeight: FontWeight.w900,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _StatuteQueryPanel extends StatelessWidget {
  const _StatuteQueryPanel({
    required this.entries,
    required this.numbered,
    required this.onQueryTap,
  });

  final List<_StatuteQueryEntry> entries;
  final bool numbered;
  final ValueChanged<String> onQueryTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE7E9DF)),
      ),
      child: Column(
        children: [
          for (var index = 0; index < entries.length; index++) ...[
            if (index > 0) Divider(height: 1.h, color: const Color(0xFFE9EBE3)),
            _StatuteQueryRow(
              entry: entries[index],
              index: index,
              numbered: numbered,
              onTap: () => onQueryTap(entries[index].query),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatuteQueryRow extends StatelessWidget {
  const _StatuteQueryRow({
    required this.entry,
    required this.index,
    required this.numbered,
    required this.onTap,
  });

  final _StatuteQueryEntry entry;
  final int index;
  final bool numbered;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final leading = numbered
        ? Container(
            width: 18.w,
            height: 18.w,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFF315D47),
              shape: BoxShape.circle,
            ),
            child: Text(
              '${index + 1}',
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          )
        : Icon(
            Icons.history_rounded,
            size: 18.sp,
            color: const Color(0xFF637063),
          );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          child: Row(
            children: [
              leading,
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      entry.subtitle,
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
                size: 20.sp,
                color: const Color(0xFF5F665F),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatuteQuietCard extends StatelessWidget {
  const _StatuteQuietCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF5),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE7E0D2)),
      ),
      child: Text(
        message,
        style: TextStyle(
          fontSize: 11.5.sp,
          height: 1.45,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _StatuteResultCard extends StatelessWidget {
  const _StatuteResultCard({
    required this.item,
    required this.onTap,
  });

  final StatuteItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Container(
          padding: EdgeInsets.all(15.w),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFAEC),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: const Color(0xFFE7DFC7)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.displayTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 20.sp,
                    color: const Color(0xFF4B5563),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                item.plainSummary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.sp,
                  height: 1.45,
                  color: AppColors.textSecondary,
                ),
              ),
              if (item.updatedDate.isNotEmpty) ...[
                SizedBox(height: 8.h),
                Text(
                  '最新異動：${item.updatedDate}',
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    color: const Color(0xFF8A8372),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailSectionCard extends StatelessWidget {
  const _DetailSectionCard({
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
        color: const Color(0xFFFFFAEC),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFE7DFC7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF5D5A38),
            ),
          ),
          SizedBox(height: 10.h),
          child,
        ],
      ),
    );
  }
}

class _DetailMetaRow extends StatelessWidget {
  const _DetailMetaRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.sp,
                height: 1.45,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatuteLoadingState extends StatefulWidget {
  const _StatuteLoadingState();

  @override
  State<_StatuteLoadingState> createState() => _StatuteLoadingStateState();
}

class _StatuteLoadingStateState extends State<_StatuteLoadingState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _typewriterController;
  var _quoteIndex = 0;

  @override
  void initState() {
    super.initState();
    // 教學註解：這裡用 AnimationController 模擬打字機節奏。
    // 每輪動畫結束後切換下一句金句，再重新播放，讓等待資料時畫面不會僵住。
    _typewriterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _quoteIndex = (_quoteIndex + 1) % appLoadingQuotes.length;
          });
          _typewriterController.forward(from: 0);
        }
      });
    _typewriterController.forward();
  }

  @override
  void dispose() {
    _typewriterController.dispose();
    super.dispose();
  }

  String _visibleQuote(String quote, double progress) {
    final runes = quote.runes.toList(growable: false);
    final visibleCount =
        (runes.length * progress.clamp(0.0, 1.0)).ceil().clamp(0, runes.length);
    return String.fromCharCodes(runes.take(visibleCount));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _typewriterController,
        builder: (context, _) {
          final quote = appLoadingQuotes[_quoteIndex];
          final typingProgress =
              (_typewriterController.value / 0.78).clamp(0.0, 1.0);
          final cursorIsVisible =
              (_typewriterController.value * 12).floor().isEven;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.balance_rounded,
                size: 42.sp,
                color: AppColors.primary,
              ),
              SizedBox(height: 16.h),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: '「${_visibleQuote(quote, typingProgress)}'),
                    TextSpan(
                      text: cursorIsVisible ? '｜' : ' ',
                      style: TextStyle(color: AppColors.accent),
                    ),
                    TextSpan(
                      text: typingProgress >= 1 ? '」' : '',
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15.sp,
                  height: 1.45,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                '正在整理全國法規資料...',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatuteErrorState extends StatelessWidget {
  const _StatuteErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFAEC),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: const Color(0xFFE7DFC7)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 32.sp,
              color: const Color(0xFF8A6E2F),
            ),
            SizedBox(height: 10.h),
            Text(
              '暫時讀不到法規資料',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                height: 1.45,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 14.h),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('重新讀取'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatuteEmptyState extends StatelessWidget {
  const _StatuteEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '找不到符合條件的條文，試試換一個關鍵字。',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13.sp,
          height: 1.45,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
