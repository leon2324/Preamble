import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:preamble/app/app_state.dart';
import 'package:preamble/components/shared/custom_toast.dart';
import 'package:preamble/components/shared/mvp_state_widgets.dart';
import 'package:preamble/data/common/app_loading_quotes.dart';
import 'package:preamble/data/statutes/statute_item.dart';
import 'package:preamble/data/statutes/statute_repository.dart';
import 'package:preamble/pages/learning/know_law_page.dart';
import 'package:preamble/theme/preamble_tokens.dart';
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
      articleBadge: '第 184 條',
      subtitle: '侵權行為損害賠償請求權基礎',
      query: '民法 184',
    ),
    _StatuteQueryEntry(
      title: '租賃契約相關法條',
      articleBadge: '民法債編',
      subtitle: '房屋修繕義務、押金抵扣與終止租約',
      query: '租賃',
    ),
    _StatuteQueryEntry(
      title: '勞動基準法第 24 條',
      articleBadge: '第 24 條',
      subtitle: '平日與休息日延長工時加班費加成標準',
      query: '勞動基準法 24',
    ),
  ];
  static const List<_StatuteQueryEntry> _defaultRecentEntries = [
    _StatuteQueryEntry(
      title: '民法第 184 條',
      articleBadge: '第 184 條',
      subtitle: '最後瀏覽：2026/04/23',
      query: '民法 184',
    ),
    _StatuteQueryEntry(
      title: '消費者保護法第 7 條',
      articleBadge: '第 7 條',
      subtitle: '最後瀏覽：2026/04/22',
      query: '消費者保護法 7',
    ),
    _StatuteQueryEntry(
      title: '道路交通管理處罰條例第 56 條',
      articleBadge: '第 56 條',
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
        articleBadge: '檢索',
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
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        final st = sheetCtx.tokens;
        return Container(
          decoration: BoxDecoration(
            color: st.surfaceElevated,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            border: Border(top: BorderSide(color: st.borderStrong)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: st.borderStrong,
                        borderRadius: BorderRadius.circular(99.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    '篩選法規位階與資料類型',
                    style: st.serifTitle(size: 17.sp),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    '可依中央法規標準法位階快速過濾條文與函釋',
                    style: st.sansBody(size: 12.sp),
                  ),
                  SizedBox(height: 14.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: _quickFilters.map((label) {
                      return _FilterChipButton(
                        label: label,
                        isSelected: label == _selectedFilter,
                        onTap: () {
                          Navigator.of(sheetCtx).pop();
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
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final padding = MediaQuery.paddingOf(context);
    final hasActiveSearch = _query.trim().isNotEmpty || _selectedFilter != '全部';

    final Widget resultsSection = hasActiveSearch
        ? FutureBuilder<StatuteSearchResult>(
            future: _ensureSearchFuture(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
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
                padding: EdgeInsets.only(
                  bottom: padding.bottom + 28.h,
                ),
                itemCount: items.length,
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _StatuteResultCard(
                    item: item,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (__) => StatuteDetailPage(item: item),
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
            bottomPadding: padding.bottom + 28.h,
            onQueryTap: _applyGuideQuery,
            onClearRecent: _clearRecentEntries,
          );

    final headerWidgets = <Widget>[
      _StatuteTopBar(
        onBack: () => Navigator.of(context).pop(),
      ),
      SizedBox(height: 14.h),
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
          _FilterSquareButton(
            hasActiveFilter: _selectedFilter != '全部',
            onTap: _openFilterSheet,
          ),
        ],
      ),
      SizedBox(height: 12.h),
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
      SizedBox(height: 16.h),
    ];

    return Scaffold(
      backgroundColor: t.canvas,
      body: Padding(
        padding: EdgeInsets.fromLTRB(16.w, padding.top + 12.h, 16.w, 0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxHeight < 480) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...headerWidgets,
                    SizedBox(
                      height: 280,
                      child: resultsSection,
                    ),
                  ],
                ),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...headerWidgets,
                Expanded(child: resultsSection),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatuteQueryEntry {
  const _StatuteQueryEntry({
    required this.title,
    required this.articleBadge,
    required this.subtitle,
    required this.query,
  });

  final String title;
  final String articleBadge;
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
  late final ScrollController _scrollController;
  bool _showTitle = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        if (!mounted) return;
        final offset = _scrollController.offset;
        final show = offset > 35.h;
        if (show != _showTitle) {
          setState(() {
            _showTitle = show;
          });
        }
      });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _toggleFollow(bool isFollowed) async {
    final appState = PreambleScope.of(context);
    await appState.setStatuteFollowed(
      _statuteInteractionId(item),
      !isFollowed,
    );
    if (!mounted) return;
    CustomToast.show(context, isFollowed ? '已取消追蹤。' : '已加入追蹤法條。');
  }

  Future<void> _toggleSaved(bool isSaved) async {
    final appState = PreambleScope.of(context);
    await appState.setStatuteSaved(_statuteInteractionId(item), !isSaved);
    if (!mounted) return;
    CustomToast.show(context, isSaved ? '已取消收藏。' : '已收藏法條。');
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final padding = MediaQuery.paddingOf(context);
    final appState = PreambleScope.of(context);
    final statuteId = _statuteInteractionId(item);
    final isFollowed = appState.isStatuteFollowed(statuteId);
    final isSaved = appState.isStatuteSaved(statuteId);

    return Scaffold(
      backgroundColor: t.canvas,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor:
            _showTitle ? t.canvas.withValues(alpha: 0.96) : Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Align(
          alignment: Alignment.center,
          child: _RoundToolButton(
            icon: PhosphorIconsRegular.caretLeft,
            onTap: () => Navigator.of(context).pop(),
          ),
        ),
        title: AnimatedOpacity(
          opacity: _showTitle ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: Text(
            item.displayTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: t.serifTitle(size: 16.sp),
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          16.w,
          padding.top + kToolbarHeight + 8.h,
          16.w,
          padding.bottom + 36.h,
        ),
        children: [
          // 頂部法典位階與古銅金條號雙重編碼識別
          Wrap(
            spacing: 8.w,
            runSpacing: 6.h,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: t.brandContainer,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  item.category.isEmpty ? '中華民國法規' : item.category,
                  style: t.sansBody(
                    size: 11.5.sp,
                    weight: FontWeight.w700,
                    color: t.brandOnContainer,
                  ),
                ),
              ),
              if (item.articleNumber.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: t.accentBrassContainer,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: t.accentBrass.withValues(alpha: 0.45),
                    ),
                  ),
                  child: Text(
                    item.articleNumber,
                    style: t.tabularMetric(
                      size: 12.sp,
                      color: t.accentOnBrassContainer,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            item.codeName,
            style: t.serifTitle(size: 22.sp, height: 1.28),
          ),
          if (item.articleNumber.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(
              item.articleNumber,
              style: t.tabularMetric(
                size: 15.sp,
                color: t.accentOnBrassContainer,
              ),
            ),
          ],
          SizedBox(height: 16.h),

          // 1. 權威宋體：條文原文
          _DetailSectionCard(
            title: '法定條文原文',
            subtitle: '權威宋體呈現 · 長按可自由選取或一鍵複製引證',
            icon: PhosphorIconsRegular.scroll,
            accentColor: t.accentBrass,
            trailing: IconButton(
              onPressed: () {
                Clipboard.setData(
                  ClipboardData(
                    text: '${item.displayTitle}\n${item.articleText}',
                  ),
                );
                HapticFeedback.lightImpact();
                CustomToast.show(context, '已複製完整法條原文與條號');
              },
              tooltip: '複製條文',
              icon: Icon(
                PhosphorIconsRegular.copy,
                size: 18.sp,
                color: t.textSecondary,
              ),
            ),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 10.h),
              decoration: BoxDecoration(
                color: t.surfaceSubtle,
                borderRadius: BorderRadius.circular(12.r),
                border: Border(
                  left: BorderSide(color: t.accentBrass, width: 3.w),
                ),
              ),
              child: SelectableText(
                item.articleText,
                style: t.serifBody(
                  size: 15.sp,
                  height: 1.75,
                  color: t.textPrimary,
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),

          // 2. 現代黑體：白話文解析
          _DetailSectionCard(
            title: '白話構成要件解析',
            subtitle: '現代黑體轉譯 · 一眼掌握法律效果',
            icon: PhosphorIconsRegular.translate,
            accentColor: t.brandPrimary,
            child: Text(
              item.plainSummary,
              style: t.sansBody(
                size: 14.sp,
                height: 1.62,
                color: t.textPrimary,
              ),
            ),
          ),
          SizedBox(height: 12.h),

          // 3. 生活實務舉隅
          _DetailSectionCard(
            title: '日常實務情境舉隅',
            icon: PhosphorIconsRegular.lightbulb,
            accentColor: t.semanticInfo,
            child: Text(
              _lifeExampleFor(item),
              style: t.sansBody(
                size: 13.5.sp,
                height: 1.6,
                color: t.textPrimary,
              ),
            ),
          ),
          SizedBox(height: 12.h),

          // 4. 可能相關情境標籤
          _DetailSectionCard(
            title: '常見關聯生活爭點',
            icon: PhosphorIconsRegular.tag,
            accentColor: t.brandPrimary,
            child: Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: _scenarioChipsFor(item)
                  .map(
                    (label) => Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 11.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: t.surfaceSubtle,
                        borderRadius: BorderRadius.circular(99.r),
                        border: Border.all(color: t.border),
                      ),
                      child: Text(
                        label,
                        style: t.sansBody(
                          size: 12.sp,
                          weight: FontWeight.w600,
                          color: t.textPrimary,
                        ),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
          SizedBox(height: 14.h),

          // 互動按鈕組
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (__) => LawAssistantChatPage(
                      initialPrompt:
                          '我想了解「${item.displayTitle}」在生活案例中怎麼使用？',
                    ),
                  ),
                );
              },
              icon: Icon(
                PhosphorIconsRegular.chatTeardropDots,
                size: 18.sp,
                color: t.brandOnPrimary,
              ),
              label: Text(
                '帶入這條法規向小法助諮詢個案',
                style: t.sansBody(
                  size: 13.sp,
                  weight: FontWeight.w700,
                  color: t.brandOnPrimary,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: t.brandPrimary,
                foregroundColor: t.brandOnPrimary,
                padding: EdgeInsets.symmetric(vertical: 13.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _toggleFollow(isFollowed),
                  icon: Icon(
                    isFollowed
                        ? PhosphorIconsFill.bellRinging
                        : PhosphorIconsRegular.bell,
                    size: 16.sp,
                    color: isFollowed ? t.brandPrimary : t.textPrimary,
                  ),
                  label: Text(
                    isFollowed ? '已追蹤異動' : '追蹤異動',
                    style: t.sansBody(
                      size: 12.5.sp,
                      weight: FontWeight.w700,
                      color: isFollowed ? t.brandPrimary : t.textPrimary,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: isFollowed ? t.brandContainer : t.surface,
                    side: BorderSide(
                      color: isFollowed ? t.brandPrimary : t.borderStrong,
                    ),
                    padding: EdgeInsets.symmetric(vertical: 11.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _toggleSaved(isSaved),
                  icon: Icon(
                    isSaved
                        ? PhosphorIconsFill.bookmarkSimple
                        : PhosphorIconsRegular.bookmarkSimple,
                    size: 16.sp,
                    color: isSaved ? t.accentOnBrassContainer : t.textPrimary,
                  ),
                  label: Text(
                    isSaved ? '已典藏法條' : '典藏法條',
                    style: t.sansBody(
                      size: 12.5.sp,
                      weight: FontWeight.w700,
                      color: isSaved ? t.accentOnBrassContainer : t.textPrimary,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor:
                        isSaved ? t.accentBrassContainer : t.surface,
                    side: BorderSide(
                      color: isSaved ? t.accentBrass : t.borderStrong,
                    ),
                    padding: EdgeInsets.symmetric(vertical: 11.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // 資料來源與版本資訊
          _DetailSectionCard(
            title: '法源出處與修訂紀錄',
            icon: PhosphorIconsRegular.bank,
            accentColor: t.textSecondary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DetailMetaRow(label: '法規位階', value: item.category),
                _DetailMetaRow(
                  label: '最新異動',
                  value: item.updatedDate,
                  useTabular: true,
                ),
                _DetailMetaRow(label: '權責來源', value: item.sourceName),
                if (item.lawUrl.isNotEmpty) ...[
                  SizedBox(height: 10.h),
                  OutlinedButton.icon(
                    onPressed: () {
                      launchUrl(
                        Uri.parse(item.lawUrl),
                        // 台灣繁體中文教學註解：改用 App 內建瀏覽器視圖（iOS SFSafariViewController），讓使用者留在 App 內瀏覽。
                        mode: LaunchMode.inAppBrowserView,
                      );
                    },
                    icon: Icon(
                      PhosphorIconsRegular.arrowSquareOut,
                      size: 16.sp,
                      color: t.brandPrimary,
                    ),
                    label: Text(
                      '前往全國法規資料庫核對官版原文',
                      style: t.sansBody(
                        size: 12.sp,
                        weight: FontWeight.w700,
                        color: t.brandPrimary,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: t.borderStrong),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  SelectableText(
                    item.lawUrl,
                    style: t.sansBody(
                      size: 11.5.sp,
                      color: t.brandPrimary,
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
  if (text.contains('租') || text.contains('押金')) chips.add('租屋點交');
  if (text.contains('車') || text.contains('損害')) chips.add('車禍求償');
  if (text.contains('消費') || text.contains('網購')) chips.add('消費契約');
  if (text.contains('勞') || text.contains('工資')) chips.add('勞資權益');
  if (text.contains('刑') || text.contains('詐')) chips.add('刑事風險');
  chips.addAll(['舉證準備', '調解前檢核']);
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
    final t = context.tokens;
    // 返回鍵維持簡潔輕盈，同時保留 42.w 觸控熱區。
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: SizedBox(
          width: 42.w,
          height: 42.w,
          child: Icon(
            icon,
            size: 20.sp,
            color: t.textPrimary,
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
    final t = context.tokens;
    return Row(
      children: [
        _RoundToolButton(
          icon: PhosphorIconsRegular.caretLeft,
          onTap: onBack,
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                '六法法規資料庫',
                textAlign: TextAlign.center,
                style: t.serifTitle(size: 18.sp),
              ),
              Text(
                '宋體原文引證 × 白話要件雙重編碼',
                textAlign: TextAlign.center,
                style: t.sansBody(size: 11.sp, color: t.textMuted),
              ),
            ],
          ),
        ),
        SizedBox(width: 42.w),
      ],
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
    final t = context.tokens;
    return Container(
      constraints: BoxConstraints(minHeight: 46.h),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: t.borderStrong),
      ),
      child: TextField(
        controller: controller,
        onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        onChanged: onChanged,
        onSubmitted: (value) => onSubmitted(value.trim()),
        textInputAction: TextInputAction.search,
        textAlignVertical: TextAlignVertical.center,
        style: t.sansBody(size: 13.5.sp, color: t.textPrimary),
        decoration: InputDecoration(
          hintText: '搜尋法典名稱、條號（如：民法 184）或白話關鍵字',
          hintStyle: t.sansBody(size: 12.5.sp, color: t.textMuted),
          prefixIcon: Icon(
            PhosphorIconsRegular.magnifyingGlass,
            size: 19.sp,
            color: t.textSecondary,
          ),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  onPressed: onClear,
                  tooltip: '清除搜尋關鍵字',
                  icon: Icon(
                    PhosphorIconsRegular.xCircle,
                    size: 18.sp,
                    color: t.textSecondary,
                  ),
                ),
          border: InputBorder.none,
          isCollapsed: true,
          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
        ),
      ),
    );
  }
}

class _FilterSquareButton extends StatelessWidget {
  const _FilterSquareButton({
    required this.hasActiveFilter,
    required this.onTap,
  });

  final bool hasActiveFilter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          width: 46.w,
          height: 46.h,
          decoration: BoxDecoration(
            color: hasActiveFilter ? t.brandContainer : t.surface,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: hasActiveFilter ? t.brandPrimary : t.borderStrong,
            ),
          ),
          child: Icon(
            PhosphorIconsRegular.slidersHorizontal,
            size: 19.sp,
            color: hasActiveFilter ? t.brandPrimary : t.textPrimary,
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          for (var i = 0; i < filters.length; i++) ...[
            if (i > 0) SizedBox(width: 8.w),
            _FilterChipButton(
              label: filters[i],
              isSelected: filters[i] == selectedFilter,
              onTap: () => onFilterTap(filters[i]),
            ),
          ],
        ],
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
    final t = context.tokens;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 7.h),
          decoration: BoxDecoration(
            color: isSelected ? t.brandPrimary : t.surface,
            borderRadius: BorderRadius.circular(999.r),
            border: Border.all(
              color: isSelected ? t.brandPrimary : t.border,
            ),
          ),
          child: Text(
            label,
            style: t.sansBody(
              size: 12.sp,
              weight: FontWeight.w700,
              color: isSelected ? t.brandOnPrimary : t.textSecondary,
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
    required this.bottomPadding,
    required this.onQueryTap,
    required this.onClearRecent,
  });

  final List<_StatuteQueryEntry> popularQueries;
  final List<_StatuteQueryEntry> recentEntries;
  final double bottomPadding;
  final ValueChanged<String> onQueryTap;
  final VoidCallback onClearRecent;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(bottom: bottomPadding),
      children: [
        const _StatuteSectionTitle(
          title: '常備核心條文索引',
          subtitle: '日常契約、侵權與勞動爭議最常援引之請求權基礎',
        ),
        SizedBox(height: 10.h),
        _StatuteQueryPanel(
          entries: popularQueries,
          numbered: true,
          onQueryTap: onQueryTap,
        ),
        SizedBox(height: 22.h),
        Row(
          children: [
            const Expanded(
              child: _StatuteSectionTitle(
                title: '最近檢索紀錄',
                subtitle: '快速重返近期查閱過的法規與條號',
              ),
            ),
            if (recentEntries.isNotEmpty)
              TextButton.icon(
                onPressed: onClearRecent,
                icon: Icon(
                  PhosphorIconsRegular.trash,
                  size: 14.sp,
                  color: t.textMuted,
                ),
                label: Text(
                  '清除',
                  style: t.sansBody(size: 11.5.sp, color: t.textMuted),
                ),
              ),
          ],
        ),
        SizedBox(height: 10.h),
        if (recentEntries.isEmpty)
          const _StatuteQuietCard(message: '目前沒有最近檢索紀錄。')
        else
          _StatuteQueryPanel(
            entries: recentEntries,
            numbered: false,
            onQueryTap: onQueryTap,
          ),
        SizedBox(height: 14.h),
        const _StatuteQuietCard(
          message:
              '資料來源：全國法規資料庫公開法律與命令資料。本頁採「宋體法定原文 × 黑體白話摘要」雙重編碼呈現，僅供法學檢索參考，不構成正式法律意見。',
        ),
      ],
    );
  }
}

class _StatuteSectionTitle extends StatelessWidget {
  const _StatuteSectionTitle({
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: t.serifTitle(size: 16.sp),
        ),
        if (subtitle != null) ...[
          SizedBox(height: 2.h),
          Text(
            subtitle!,
            style: t.sansBody(size: 11.5.sp, color: t.textMuted),
          ),
        ],
      ],
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
    final t = context.tokens;
    return Container(
      decoration: t.cardDecoration(radius: 16.r),
      child: Column(
        children: [
          for (var index = 0; index < entries.length; index++) ...[
            if (index > 0) Divider(height: 1, color: t.border),
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
    final t = context.tokens;
    final leading = numbered
        ? Container(
            width: 24.w,
            height: 24.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: t.brandContainer,
              borderRadius: BorderRadius.circular(7.r),
            ),
            child: Text(
              '0${index + 1}',
              style: t.tabularMetric(
                size: 11.sp,
                color: t.brandPrimary,
              ),
            ),
          )
        : Icon(
            PhosphorIconsRegular.clockCounterClockwise,
            size: 18.sp,
            color: t.textMuted,
          );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
          child: Row(
            children: [
              leading,
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 4.h,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          entry.title,
                          style: t.serifTitle(size: 14.5.sp),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 7.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: t.accentBrassContainer,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            entry.articleBadge,
                            style: t.tabularMetric(
                              size: 11.sp,
                              color: t.accentOnBrassContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      entry.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.sansBody(size: 12.sp, color: t.textSecondary),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 6.w),
              Icon(
                PhosphorIconsRegular.caretRight,
                size: 16.sp,
                color: t.textMuted,
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
    final t = context.tokens;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: t.subtleBoxDecoration(radius: 14.r),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 2.h),
            child: Icon(
              PhosphorIconsRegular.info,
              size: 16.sp,
              color: t.textMuted,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message,
              style: t.sansBody(
                size: 11.5.sp,
                height: 1.5,
                color: t.textSecondary,
              ),
            ),
          ),
        ],
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
    final t = context.tokens;
    final badgeLabel =
        item.articleNumber.isNotEmpty ? item.articleNumber : item.category;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: t.cardDecoration(radius: 18.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 頂部：法典名稱（宋體） + 古銅金等寬條號徽章（Tabular Metric）
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 8.w,
                      runSpacing: 6.h,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (badgeLabel.isNotEmpty)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 3.h,
                            ),
                            decoration: BoxDecoration(
                              color: t.accentBrassContainer,
                              borderRadius: BorderRadius.circular(7.r),
                              border: Border.all(
                                color: t.accentBrass.withValues(alpha: 0.42),
                              ),
                            ),
                            child: Text(
                              badgeLabel,
                              style: t.tabularMetric(
                                size: 11.5.sp,
                                color: t.accentOnBrassContainer,
                              ),
                            ),
                          ),
                        Text(
                          item.codeName.isNotEmpty
                              ? item.codeName
                              : item.displayTitle,
                          style: t.serifTitle(size: 15.5.sp),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(
                    PhosphorIconsRegular.arrowUpRight,
                    size: 18.sp,
                    color: t.brandPrimary,
                  ),
                ],
              ),

              // 中段：法條原文節錄（權威宋體 15.sp, 1.75 行高）
              if (item.articleText.trim().isNotEmpty) ...[
                SizedBox(height: 10.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 11.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: t.surfaceSubtle,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border(
                      left: BorderSide(color: t.accentBrass, width: 2.5.w),
                    ),
                  ),
                  child: Text(
                    item.articleText.trim(),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: t.serifBody(
                      size: 15.sp,
                      height: 1.75,
                      color: t.textPrimary,
                    ),
                  ),
                ),
              ],

              // 下段：白話摘要與標籤（現代黑體）
              if (item.plainSummary.trim().isNotEmpty) ...[
                SizedBox(height: 9.h),
                Text(
                  item.plainSummary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: t.sansBody(
                    size: 12.5.sp,
                    height: 1.5,
                    color: t.textSecondary,
                  ),
                ),
              ],

              SizedBox(height: 10.h),
              Wrap(
                spacing: 6.w,
                runSpacing: 6.h,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  for (final tag in item.tags.take(3))
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 7.w,
                        vertical: 2.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: t.brandContainer,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        tag,
                        style: t.sansBody(
                          size: 11.sp,
                          weight: FontWeight.w600,
                          color: t.brandOnContainer,
                        ),
                      ),
                    ),
                  if (item.updatedDate.isNotEmpty)
                    Text(
                      '異動 ${item.updatedDate}',
                      style: t.tabularMetric(
                        size: 11.sp,
                        weight: FontWeight.w600,
                        color: t.textMuted,
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

class _DetailSectionCard extends StatelessWidget {
  const _DetailSectionCard({
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.child,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final Color accentColor;
  final Widget? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: t.cardDecoration(radius: 18.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 17.sp, color: accentColor),
              SizedBox(width: 7.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: t.sansTitle(size: 14.sp),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: t.sansBody(size: 11.sp, color: t.textMuted),
                      ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          SizedBox(height: 12.h),
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
    this.useTabular = false,
  });

  final String label;
  final String value;
  final bool useTabular;

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();
    final t = context.tokens;

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 76.w,
            child: Text(
              label,
              style: t.sansBody(
                size: 12.sp,
                weight: FontWeight.w700,
                color: t.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: useTabular
                  ? t.tabularMetric(size: 12.sp, color: t.textPrimary)
                  : t.sansBody(
                      size: 12.sp,
                      height: 1.45,
                      color: t.textPrimary,
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
    final t = context.tokens;
    return Center(
      child: AnimatedBuilder(
        animation: _typewriterController,
        builder: (context, _) {
          final quote = appLoadingQuotes[_quoteIndex];
          final typingProgress =
              (_typewriterController.value / 0.78).clamp(0.0, 1.0);
          final cursorIsVisible =
              (_typewriterController.value * 12).floor().isEven;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  PhosphorIconsRegular.scales,
                  size: 40.sp,
                  color: t.brandPrimary,
                ),
                SizedBox(height: 16.h),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: '「${_visibleQuote(quote, typingProgress)}'),
                      TextSpan(
                        text: cursorIsVisible ? '｜' : ' ',
                        style: TextStyle(color: t.accentBrass),
                      ),
                      TextSpan(
                        text: typingProgress >= 1 ? '」' : '',
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  style: t.serifTitle(size: 15.sp, height: 1.5),
                ),
                SizedBox(height: 8.h),
                Text(
                  '正在檢索並校對全國法規資料庫...',
                  style: t.sansBody(size: 12.sp, color: t.textSecondary),
                ),
              ],
            ),
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
    final t = context.tokens;
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: t.cardDecoration(radius: 20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                PhosphorIconsRegular.cloudSlash,
                size: 32.sp,
                color: t.accentBrass,
              ),
              SizedBox(height: 10.h),
              Text(
                '暫時無法讀取法規資料',
                style: t.serifTitle(size: 16.sp),
              ),
              SizedBox(height: 8.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: t.sansBody(size: 12.sp, height: 1.45),
              ),
              SizedBox(height: 14.h),
              FilledButton.icon(
                onPressed: onRetry,
                icon: Icon(
                  PhosphorIconsRegular.arrowClockwise,
                  size: 16.sp,
                  color: t.brandOnPrimary,
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: t.brandPrimary,
                  foregroundColor: t.brandOnPrimary,
                ),
                label: Text(
                  '重新讀取',
                  style: t.sansBody(
                    size: 12.5.sp,
                    weight: FontWeight.w700,
                    color: t.brandOnPrimary,
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

class _StatuteEmptyState extends StatelessWidget {
  const _StatuteEmptyState();

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              PhosphorIconsRegular.magnifyingGlass,
              size: 32.sp,
              color: t.textMuted,
            ),
            SizedBox(height: 10.h),
            Text(
              '找不到符合條件的條文，請試試更換法典名稱或白話關鍵字。',
              textAlign: TextAlign.center,
              style: t.sansBody(size: 13.sp, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
