import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lawapp/app/app_state.dart';
import 'package:lawapp/data/search/search_models.dart';
import 'package:lawapp/data/search/search_repository.dart';
import 'package:lawapp/pages/learning/know_law_page.dart';
import 'package:url_launcher/url_launcher.dart';

// 台灣繁體中文教學註解：
// 搜尋 Prototype 採用單一頁面狀態機，讓底部 Nav 只負責進入「搜尋」入口；
// 搜尋首頁、混合結果、各分類列表、詳情與篩選面板都在這裡切換，避免子頁再長出自己的 Nav。
enum _SearchPage {
  home,
  results,
  assistant,
  statutes,
  statuteDetail,
  cases,
  caseDetail,
  lifeNotes,
  lifeDetail,
  official,
  filters
}

enum _ResultType { assistant, statute, caseItem, lifeNote, official }

// 台灣繁體中文教學註解：
// Tab 只控制結果內容的分類呈現；真正的子頁瀏覽由 _SearchPage 負責，
// 之後如果要新增資料類型，請同步補 _SearchTab、_ResultType 與 mock 清單。
enum _SearchTab { all, assistant, statutes, cases, lifeNotes, official }

class GlobalSearchPage extends StatefulWidget {
  const GlobalSearchPage({super.key, SearchRepository? searchRepository})
      : _searchRepository = searchRepository;

  final SearchRepository? _searchRepository;

  @override
  State<GlobalSearchPage> createState() => _GlobalSearchPageState();
}

class _GlobalSearchPageState extends State<GlobalSearchPage> {
  final _controller = TextEditingController();
  final List<String> _recent = [];
  late final SearchRepository _searchRepository;
  late final bool _ownsSearchRepository;
  String _query = '';
  _SearchPage _page = _SearchPage.home;
  _SearchTab _tab = _SearchTab.all;
  _SearchResult _selected = _mockResults.first;
  List<_SearchResult> _results = const [];
  var _isSearching = false;
  String? _searchError;
  var _searchRevision = 0;

  @override
  void initState() {
    super.initState();
    _ownsSearchRepository = widget._searchRepository == null;
    _searchRepository = widget._searchRepository ?? SearchRepository();
  }

  @override
  void dispose() {
    _controller.dispose();
    if (_ownsSearchRepository) {
      _searchRepository.dispose();
    }
    super.dispose();
  }

  void _submit(String value, {_SearchPage nextPage = _SearchPage.results}) {
    final query = value.trim();
    if (query.isEmpty) return;
    final revision = ++_searchRevision;
    setState(() {
      _query = query;
      _controller.text = query;
      _controller.selection = TextSelection.collapsed(offset: query.length);
      _recent.remove(query);
      _recent.insert(0, query);
      if (_recent.length > 5) _recent.removeLast();
      _page = nextPage;
      _tab = _SearchTab.all;
      _isSearching = true;
      _searchError = null;
    });
    FocusManager.instance.primaryFocus?.unfocus();

    // 台灣繁體中文教學註解：
    // 全站搜尋的 UI 保留 prototype 的分頁與子頁，但資料來源改由
    // SearchRepository 統一彙整；這裡用 revision 避免較慢的舊查詢蓋掉新查詢。
    _searchRepository.searchAll(query).then((items) {
      if (!mounted || revision != _searchRevision) return;
      final results =
          items.map(_SearchResult.fromRepository).toList(growable: false);
      setState(() {
        _results = results;
        _selected =
            results.isEmpty ? _assistantResultFor(query) : results.first;
        _isSearching = false;
      });
    }).catchError((Object error) {
      if (!mounted || revision != _searchRevision) return;
      setState(() {
        _results = const [];
        _selected = _assistantResultFor(query);
        _isSearching = false;
        _searchError = '搜尋資料暫時無法讀取，請稍後再試。';
      });
    });
  }

  void _goHome() {
    setState(() {
      _controller.clear();
      _query = '';
      _tab = _SearchTab.all;
      _page = _SearchPage.home;
      _results = const [];
      _isSearching = false;
      _searchError = null;
    });
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _clearRecent() {
    setState(_recent.clear);
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final showTopBar = _page == _SearchPage.assistant ||
        _page == _SearchPage.statuteDetail ||
        _page == _SearchPage.caseDetail ||
        _page == _SearchPage.lifeDetail ||
        _page == _SearchPage.filters;
    final showSearchField = _page == _SearchPage.home ||
        _page == _SearchPage.results ||
        _page == _SearchPage.statutes ||
        _page == _SearchPage.cases ||
        _page == _SearchPage.lifeNotes ||
        _page == _SearchPage.official;

    return Scaffold(
      backgroundColor: _SearchColors.background,
      body: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(16.w, topPadding + 14.h, 16.w, 112.h),
        children: [
          if (showTopBar) ...[
            _TopBar(
              title: _titleFor(_page),
              showBack: true,
              onBack: _handleBack,
              trailing: _page == _SearchPage.assistant
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _RoundIcon(
                          icon: Icons.ios_share_rounded,
                          onTap: _shareAssistantSummary,
                        ),
                        SizedBox(width: 8.w),
                        _RoundIcon(
                          icon: _isSaved(
                            LawAppScope.of(context),
                            _selected,
                          )
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          onTap: () => _toggleSaved(_selected),
                        ),
                      ],
                    )
                  : null,
            ),
            SizedBox(height: 14.h),
          ],
          if (_page == _SearchPage.home) ...[
            SizedBox(height: 12.h),
            Center(child: Text('全站搜尋', style: _SearchText.hero())),
            SizedBox(height: 18.h),
          ],
          if (showSearchField) _buildSearchHeader(),
          if (showSearchField) SizedBox(height: 16.h),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: KeyedSubtree(
              key: ValueKey('${_page.name}-${_tab.name}-${_selected.title}'),
              child: _contentFor(_page),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader() {
    final searchField = _SearchField(
      controller: _controller,
      onSubmitted: _submit,
      showFilter: _page != _SearchPage.home,
      onFilter: () => setState(() => _page = _SearchPage.filters),
      onClear: _goHome,
    );

    if (_page == _SearchPage.home) return searchField;

    return Row(
      children: [
        _RoundIcon(icon: Icons.arrow_back_ios_new_rounded, onTap: _goHome),
        SizedBox(width: 10.w),
        Expanded(child: searchField),
      ],
    );
  }

  String _titleFor(_SearchPage page) {
    switch (page) {
      case _SearchPage.home:
        return '全站搜尋';
      case _SearchPage.results:
        return '搜尋結果';
      case _SearchPage.assistant:
        return '';
      case _SearchPage.statutes:
        return '法規結果';
      case _SearchPage.statuteDetail:
        return _selected.title;
      case _SearchPage.cases:
        return '案件搜尋結果';
      case _SearchPage.caseDetail:
        return _selected.title;
      case _SearchPage.lifeNotes:
        return '生活避坑筆記';
      case _SearchPage.lifeDetail:
        return _selected.title;
      case _SearchPage.official:
        return '官方資料結果';
      case _SearchPage.filters:
        return '篩選條件';
    }
  }

  Widget _contentFor(_SearchPage page) {
    final assistantResult = _assistantResultFor(_query);
    final statuteResults = _resultsOfType(_ResultType.statute);
    final caseResults = _resultsOfType(_ResultType.caseItem);
    final lifeResults = _resultsOfType(_ResultType.lifeNote);
    final officialResults = _resultsOfType(_ResultType.official);

    switch (page) {
      case _SearchPage.home:
        return _SearchHome(
          recent: _recent,
          onQuery: _submit,
          onAssistant: () => _submit('詐欺'),
          onStatutes: () => _openList(_SearchPage.statutes),
          onCases: () => _openList(_SearchPage.cases),
          onOfficial: () => _openList(_SearchPage.official),
          onClearRecent: _clearRecent,
        );
      case _SearchPage.results:
        if (_isSearching) {
          return const _SearchStateCard(message: '正在彙整全站搜尋結果...');
        }
        if (_searchError != null) {
          return _SearchStateCard(message: _searchError!);
        }
        return _MixedResults(
          query: _query,
          tab: _tab,
          results: _results,
          assistantResult: assistantResult,
          onTab: (tab) => setState(() => _tab = tab),
          onOpen: _openResult,
          onOpenList: _openList,
          isSaved: (item) => _isSaved(LawAppScope.of(context), item),
          onSaved: _toggleSaved,
        );
      case _SearchPage.assistant:
        return _AssistantDetail(
          query: _query,
          onOpen: _openList,
          onContinue: _continueWithAssistant,
        );
      case _SearchPage.statutes:
        if (_isSearching) {
          return const _SearchStateCard(message: '正在搜尋法規資料...');
        }
        return _ResultList(
          tabLabels: const ['全部', '最近更新', '我關注的'],
          items: statuteResults,
          onOpen: _openResult,
          actionLabel: '+ 新增追蹤法條',
          isSaved: (item) => _isSaved(LawAppScope.of(context), item),
          onSaved: _toggleSaved,
          onAction: statuteResults.isEmpty
              ? () => _showSnack('目前沒有可追蹤的法規搜尋結果。')
              : () => _toggleFollow(statuteResults.first),
        );
      case _SearchPage.statuteDetail:
        return _StatuteDetail(
          item: _selected,
          isFollowed: _isFollowed(LawAppScope.of(context), _selected),
          isSaved: _isSaved(LawAppScope.of(context), _selected),
          onFollow: () => _toggleFollow(_selected),
          onSaved: () => _toggleSaved(_selected),
          onAssistant: () => _openAssistant(_selected.query),
        );
      case _SearchPage.cases:
        if (_isSearching) {
          return const _SearchStateCard(message: '正在搜尋案件資料...');
        }
        return _ResultList(
          tabLabels: const ['全部', '小法助', '法規', '案件', '生活避坑', '官方資料'],
          items: caseResults,
          onOpen: _openResult,
          actionLabel: '查看更多案件',
          isSaved: (item) => _isSaved(LawAppScope.of(context), item),
          onSaved: _toggleSaved,
          onAction: caseResults.isEmpty
              ? () => _showSnack('目前沒有可追蹤的案件搜尋結果。')
              : () => _toggleFollow(caseResults.first),
        );
      case _SearchPage.caseDetail:
        return _CaseDetail(
          item: _selected,
          isFollowed: _isFollowed(LawAppScope.of(context), _selected),
          isSaved: _isSaved(LawAppScope.of(context), _selected),
          onFollow: () => _toggleFollow(_selected),
          onSaved: () => _toggleSaved(_selected),
          onOpenFullText: () => _openCaseJudgment(_selected),
        );
      case _SearchPage.lifeNotes:
        if (_isSearching) {
          return const _SearchStateCard(message: '正在搜尋生活筆記...');
        }
        return _LifeNoteList(
          items: lifeResults,
          onOpen: _openResult,
          onMore: _showLifeNoteExplorer,
        );
      case _SearchPage.lifeDetail:
        return _LifeNoteDetail(
          item: _selected,
          isSaved: _isSaved(LawAppScope.of(context), _selected),
          onSaved: () => _toggleSaved(_selected),
        );
      case _SearchPage.official:
        if (_isSearching) {
          return const _SearchStateCard(message: '正在搜尋官方資料...');
        }
        return _OfficialList(
          items: officialResults,
          onOpen: _openOfficialSource,
          onMore: _showOfficialExplorer,
        );
      case _SearchPage.filters:
        return _FilterPanel(
            onApply: () => setState(() => _page = _SearchPage.results));
    }
  }

  void _openList(_SearchPage page) {
    if (_query.isEmpty) {
      _submit('詐欺', nextPage: page);
      return;
    }
    setState(() {
      _page = page;
    });
  }

  void _openResult(_SearchResult result) {
    setState(() {
      _selected = result;
      switch (result.type) {
        case _ResultType.assistant:
          _page = _SearchPage.assistant;
        case _ResultType.statute:
          _page = _SearchPage.statuteDetail;
        case _ResultType.caseItem:
          _page = _SearchPage.caseDetail;
        case _ResultType.lifeNote:
          _page = _SearchPage.lifeDetail;
        case _ResultType.official:
          _page = _SearchPage.official;
      }
    });
  }

  void _openAssistant(String query) {
    setState(() {
      _query = query;
      _controller.text = query;
      _selected = _assistantResultFor(query);
      _page = _SearchPage.assistant;
    });
  }

  void _handleBack() {
    setState(() {
      switch (_page) {
        case _SearchPage.results:
          _page = _SearchPage.home;
        case _SearchPage.assistant:
        case _SearchPage.statutes:
        case _SearchPage.cases:
        case _SearchPage.lifeNotes:
        case _SearchPage.official:
        case _SearchPage.filters:
          _page = _SearchPage.results;
        case _SearchPage.statuteDetail:
          _page = _SearchPage.statutes;
        case _SearchPage.caseDetail:
          _page = _SearchPage.cases;
        case _SearchPage.lifeDetail:
          _page = _SearchPage.lifeNotes;
        case _SearchPage.home:
          break;
      }
    });
  }

  bool _isFollowed(LawAppState appState, _SearchResult item) {
    final id = _interactionIdFor(item);
    return switch (item.type) {
      _ResultType.statute => appState.isStatuteFollowed(id),
      _ResultType.caseItem => appState.isCaseFollowed(id),
      _ResultType.lifeNote => appState.isTopicFollowed(id),
      _ => false,
    };
  }

  bool _isSaved(LawAppState appState, _SearchResult item) {
    final id = _interactionIdFor(item);
    return switch (item.type) {
      _ResultType.statute => appState.isStatuteSaved(id),
      _ResultType.caseItem => appState.isCaseSaved(id),
      _ResultType.lifeNote ||
      _ResultType.assistant =>
        appState.isArticleSaved(id),
      _ResultType.official => false,
    };
  }

  Future<void> _toggleFollow(_SearchResult item) async {
    final appState = LawAppScope.of(context);
    final id = _interactionIdFor(item);
    final next = !_isFollowed(appState, item);

    // 台灣繁體中文教學註解：
    // 全站搜尋的追蹤按鈕不再只改 icon，而是寫進 LawAppState 的共用 summary；
    // 我的 LawApp 會讀同一份 summary，所以這裡按下後切到個人頁即可看到。
    switch (item.type) {
      case _ResultType.statute:
        await appState.setStatuteFollowed(id, next);
      case _ResultType.caseItem:
        await appState.setCaseFollowed(id, next);
      case _ResultType.lifeNote:
        await appState.setTopicFollowed(id, next);
      case _ResultType.assistant:
      case _ResultType.official:
        _showSnack('這個結果目前不能追蹤，請改用收藏。');
        return;
    }
    if (!mounted) return;
    _showSnack(next ? '已加入我的 LawApp 追蹤。' : '已從我的 LawApp 取消追蹤。');
  }

  Future<void> _toggleSaved(_SearchResult item) async {
    final appState = LawAppScope.of(context);
    final id = _interactionIdFor(item);
    final next = !_isSaved(appState, item);

    switch (item.type) {
      case _ResultType.statute:
        await appState.setStatuteSaved(id, next);
      case _ResultType.caseItem:
        await appState.setCaseSaved(id, next);
      case _ResultType.lifeNote:
      case _ResultType.assistant:
        await appState.setArticleSaved(id, next);
      case _ResultType.official:
        _showSnack('官方資料先保留原始連結，不加入收藏。');
        return;
    }
    if (!mounted) return;
    setState(() {});
    _showSnack(next ? '已加入我的 LawApp 收藏。' : '已從我的 LawApp 收藏移除。');
  }

  Future<void> _shareAssistantSummary() async {
    final keyword = _query.trim().isEmpty ? _selected.query : _query.trim();
    final text = [
      '小法助搜尋整理：$keyword',
      _selected.summary,
      '來源：LawApp 全站搜尋',
    ].where((line) => line.trim().isNotEmpty).join('\n\n');
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    _showSnack('已複製小法助搜尋整理。');
  }

  void _continueWithAssistant() {
    final keyword = _query.trim().isEmpty ? _selected.query : _query.trim();

    // 台灣繁體中文教學註解：
    // 搜尋頁只負責把使用者正在查的關鍵字帶到小法助完整問答流程；
    // 真正的額度、訪客限制與追問記錄仍集中在 LawAssistantSearchPage 維護。
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (__) => LawAssistantSearchPage(initialPrompt: keyword),
      ),
    );
  }

  Future<void> _openCaseJudgment(_SearchResult item) async {
    final lookupText = _caseLookupText(item);
    await Clipboard.setData(ClipboardData(text: lookupText));

    final directUri = _sourceUriFor(item);
    if (directUri != null) {
      final launched = await _openExternalUri(directUri);
      if (!mounted) return;
      _showSnack(
        launched
            ? '已開啟判決來源，並複製「$lookupText」供查核。'
            : '無法開啟判決來源，已先複製「$lookupText」。',
      );
      return;
    }

    // 台灣繁體中文教學註解：
    // 目前搜尋結果沒有穩定保存每一筆裁判全文 URL，所以不要假裝直達全文；
    // 先開司法院官方裁判查詢並複製查詢字串，讓使用者能在官方站完成確認。
    final launched = await _openExternalUri(
      Uri.parse('https://judgment.judicial.gov.tw/FJUD/default.aspx'),
    );
    if (!mounted) return;
    _showSnack(
      launched
          ? '已開啟司法院裁判查詢，並複製「$lookupText」供貼上搜尋。'
          : '無法開啟司法院裁判查詢，已先複製「$lookupText」。',
    );
  }

  Future<void> _openOfficialSource(_SearchResult item) async {
    final uri = _sourceUriFor(item) ?? _officialUriFor(item);
    await Clipboard.setData(ClipboardData(text: item.title));
    final launched = await _openExternalUri(uri);
    if (!mounted) return;
    _showSnack(
      launched
          ? '已開啟官方來源，並複製「${item.title}」供站內搜尋。'
          : '無法開啟官方來源，已先複製「${item.title}」。',
    );
  }

  void _showLifeNoteExplorer() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _SearchActionSheet(
          title: '查看更多生活避坑筆記',
          message: '生活筆記目前依搜尋字即時彙整；選一個常見情境後，會把關鍵字帶回搜尋並只顯示生活筆記結果。',
          actions: [
            _SheetAction(
              icon: Icons.home_work_outlined,
              title: '租屋押金與修繕',
              subtitle: '押金、點交、扣款明細',
              onTap: () {
                Navigator.of(sheetContext).pop();
                _submit('租屋 押金', nextPage: _SearchPage.lifeNotes);
              },
            ),
            _SheetAction(
              icon: Icons.badge_outlined,
              title: '勞資工時與薪資',
              subtitle: '加班費、補休、離職薪資',
              onTap: () {
                Navigator.of(sheetContext).pop();
                _submit('勞資 加班', nextPage: _SearchPage.lifeNotes);
              },
            ),
            _SheetAction(
              icon: Icons.shopping_bag_outlined,
              title: '消費退貨與申訴',
              subtitle: '瑕疵商品、退款、客服紀錄',
              onTap: () {
                Navigator.of(sheetContext).pop();
                _submit('消費 退貨', nextPage: _SearchPage.lifeNotes);
              },
            ),
          ],
        );
      },
    );
  }

  void _showOfficialExplorer() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _SearchActionSheet(
          title: '查看更多官方資料',
          message: '官方資料保留原始來源，不在 App 內重製全文；可開啟官方網站後，用已複製的搜尋字繼續查核。',
          actions: [
            _SheetAction(
              icon: Icons.account_balance_outlined,
              title: '法務部',
              subtitle: '法規宣導、新聞與公開資料',
              onTap: () {
                Navigator.of(sheetContext).pop();
                _copyQueryAndOpenOfficial(
                  Uri.parse('https://www.moj.gov.tw/'),
                  '法務部',
                );
              },
            ),
            _SheetAction(
              icon: Icons.gavel_outlined,
              title: '司法院',
              subtitle: '裁判、司法公告與查詢系統',
              onTap: () {
                Navigator.of(sheetContext).pop();
                _copyQueryAndOpenOfficial(
                  Uri.parse('https://www.judicial.gov.tw/'),
                  '司法院',
                );
              },
            ),
            _SheetAction(
              icon: Icons.public_outlined,
              title: '政府入口網',
              subtitle: '跨部會服務與公開資訊',
              onTap: () {
                Navigator.of(sheetContext).pop();
                _copyQueryAndOpenOfficial(
                  Uri.parse('https://www.gov.tw/'),
                  '政府入口網',
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _copyQueryAndOpenOfficial(Uri uri, String label) async {
    final keyword = _query.trim().isEmpty ? '法律資料' : _query.trim();
    await Clipboard.setData(ClipboardData(text: keyword));
    final launched = await _openExternalUri(uri);
    if (!mounted) return;
    _showSnack(
      launched
          ? '已開啟$label，並複製「$keyword」供官方站內搜尋。'
          : '無法開啟$label，已先複製「$keyword」。',
    );
  }

  Future<bool> _openExternalUri(Uri uri) {
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Uri? _sourceUriFor(_SearchResult item) {
    final url = item.preferredSourceUrl;
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) return null;
    if (uri.scheme != 'https' && uri.scheme != 'http') return null;
    if (uri.host.contains('example.') || uri.host.endsWith('.local')) {
      return null;
    }
    return uri;
  }

  String _caseLookupText(_SearchResult item) {
    final title = item.title.trim();
    if (title.isNotEmpty) return title;
    return item.query.trim().isEmpty ? '裁判全文' : item.query.trim();
  }

  Uri _officialUriFor(_SearchResult item) {
    final source = '${item.title} ${item.source}'.toLowerCase();
    if (source.contains('法務部') || source.contains('moj')) {
      return Uri.parse('https://www.moj.gov.tw/');
    }
    if (source.contains('司法院') || source.contains('judicial')) {
      return Uri.parse('https://www.judicial.gov.tw/');
    }
    if (source.contains('行政院')) {
      return Uri.parse('https://www.ey.gov.tw/');
    }
    return Uri.parse('https://www.gov.tw/');
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  List<_SearchResult> _resultsOfType(_ResultType type) {
    return _results.where((item) => item.type == type).toList(growable: false);
  }
}

class _SearchHome extends StatelessWidget {
  const _SearchHome({
    required this.recent,
    required this.onQuery,
    required this.onAssistant,
    required this.onStatutes,
    required this.onCases,
    required this.onOfficial,
    required this.onClearRecent,
  });

  final List<String> recent;
  final ValueChanged<String> onQuery;
  final VoidCallback onAssistant;
  final VoidCallback onStatutes;
  final VoidCallback onCases;
  final VoidCallback onOfficial;
  final VoidCallback onClearRecent;

  @override
  Widget build(BuildContext context) {
    final popular = ['詐欺', '租屋糾紛', '民法 184', '勞資爭議', '交通違規'];
    final quick = [
      _QuickAction('AI\n小法助搜尋', Icons.support_agent_rounded, onAssistant),
      _QuickAction('法規\n檢索重點', Icons.menu_book_outlined, onStatutes),
      _QuickAction('案件\n搜尋案例', Icons.description_outlined, onCases),
      _QuickAction('官方資料', Icons.verified_outlined, onOfficial),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: '最近搜尋',
          action: '清除',
          onAction: onClearRecent,
        ),
        SizedBox(height: 9.h),
        _PrototypeChipGrid(
          labels: recent.isEmpty ? popular.take(4).toList() : recent,
          onTap: onQuery,
        ),
        SizedBox(height: 18.h),
        const _SectionHeader(title: '熱門搜尋'),
        SizedBox(height: 9.h),
        _PrototypeChipGrid(labels: popular, onTap: onQuery),
        SizedBox(height: 18.h),
        const _SectionHeader(title: '快速操作'),
        SizedBox(height: 10.h),
        Row(
          children: [
            for (final item in quick)
              Expanded(child: _QuickActionTile(item: item)),
          ],
        ),
        SizedBox(height: 18.h),
        _ProtoCard(
          background: _SearchColors.softMint,
          padding: EdgeInsets.fromLTRB(16.w, 14.h, 0, 0),
          child: SizedBox(
            height: 116.h,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 0,
                  top: 2.h,
                  right: 112.w,
                  child: Text(
                    '在 LawApp 搜尋，\n整合多元法律資料，快速找到答案。',
                    style: _SearchText.bodyStrong(),
                  ),
                ),
                Positioned(
                  right: -2.w,
                  bottom: 0,
                  child: SvgPicture.asset(_SearchAsset.plant, width: 126.w),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.action, this.onAction});

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: _SearchText.section())),
        if (action != null)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onAction,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 4.h),
              child: Text(action!, style: _SearchText.action()),
            ),
          ),
      ],
    );
  }
}

class _PrototypeChipGrid extends StatelessWidget {
  const _PrototypeChipGrid({required this.labels, required this.onTap});

  final List<String> labels;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6.w,
      runSpacing: 7.h,
      children: labels
          .map((label) => _Pill(label: label, onTap: () => onTap(label)))
          .toList(growable: false),
    );
  }
}

class _MixedResults extends StatelessWidget {
  const _MixedResults({
    required this.query,
    required this.tab,
    required this.results,
    required this.assistantResult,
    required this.onTab,
    required this.onOpen,
    required this.onOpenList,
    required this.isSaved,
    required this.onSaved,
  });

  final String query;
  final _SearchTab tab;
  final List<_SearchResult> results;
  final _SearchResult assistantResult;
  final ValueChanged<_SearchTab> onTab;
  final ValueChanged<_SearchResult> onOpen;
  final ValueChanged<_SearchPage> onOpenList;
  final bool Function(_SearchResult item) isSaved;
  final ValueChanged<_SearchResult> onSaved;

  @override
  Widget build(BuildContext context) {
    final visible = _resultsForTab(tab);
    if (tab == _SearchTab.all) {
      final statutes = _resultsByType(_ResultType.statute);
      final cases = _resultsByType(_ResultType.caseItem);
      final lifeNotes = _resultsByType(_ResultType.lifeNote);
      final official = _resultsByType(_ResultType.official);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SearchTabs(tab: tab, onTab: onTab),
          SizedBox(height: 14.h),
          _AssistantHint(query: query, onTap: () => onOpen(assistantResult)),
          SizedBox(height: 14.h),
          _ResultSection(
            title: '法規',
            items: statutes.take(1).toList(),
            onOpen: onOpen,
            isSaved: isSaved,
            onSaved: onSaved,
          ),
          _ResultSection(
            title: '案件 / 判例',
            items: cases.take(1).toList(),
            onOpen: onOpen,
            isSaved: isSaved,
            onSaved: onSaved,
          ),
          _ResultSection(
            title: '生活避坑筆記',
            items: lifeNotes.take(1).toList(),
            onOpen: onOpen,
            isSaved: isSaved,
            onSaved: onSaved,
          ),
          _ResultSection(
            title: '官方資料',
            items: official.take(1).toList(),
            onOpen: onOpen,
            isSaved: isSaved,
            onSaved: onSaved,
          ),
          SizedBox(height: 8.h),
          _AdvancedRoutes(onOpen: onOpenList),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SearchTabs(tab: tab, onTab: onTab),
        SizedBox(height: 14.h),
        if (visible.isEmpty)
          const _SearchStateCard(message: '這個分類目前沒有符合的結果。')
        else
          for (final item in visible.take(5)) ...[
            _ResultTile(
              item: item,
              onTap: () => onOpen(item),
              showBookmark: item.type != _ResultType.official,
              isSaved: isSaved(item),
              onBookmark: () => onSaved(item),
            ),
            SizedBox(height: 10.h),
          ],
        SizedBox(height: 10.h),
        _AdvancedRoutes(onOpen: onOpenList),
      ],
    );
  }

  List<_SearchResult> _resultsForTab(_SearchTab tab) {
    switch (tab) {
      case _SearchTab.all:
        return [assistantResult, ...results];
      case _SearchTab.assistant:
        return [assistantResult, ..._resultsByType(_ResultType.assistant)];
      case _SearchTab.statutes:
        return _resultsByType(_ResultType.statute);
      case _SearchTab.cases:
        return _resultsByType(_ResultType.caseItem);
      case _SearchTab.lifeNotes:
        return _resultsByType(_ResultType.lifeNote);
      case _SearchTab.official:
        return _resultsByType(_ResultType.official);
    }
  }

  List<_SearchResult> _resultsByType(_ResultType type) {
    return results.where((item) => item.type == type).toList(growable: false);
  }
}

class _ResultSection extends StatelessWidget {
  const _ResultSection({
    required this.title,
    required this.items,
    required this.onOpen,
    required this.isSaved,
    required this.onSaved,
  });

  final String title;
  final List<_SearchResult> items;
  final ValueChanged<_SearchResult> onOpen;
  final bool Function(_SearchResult item) isSaved;
  final ValueChanged<_SearchResult> onSaved;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: title),
          SizedBox(height: 8.h),
          for (final item in items)
            _ResultTile(
              item: item,
              onTap: () => onOpen(item),
              showBookmark: item.type != _ResultType.official,
              isSaved: isSaved(item),
              onBookmark: () => onSaved(item),
            ),
        ],
      ),
    );
  }
}

class _SearchStateCard extends StatelessWidget {
  const _SearchStateCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return _ProtoCard(
      background: _SearchColors.softPaper,
      child: Text(message, style: _SearchText.bodyStrong()),
    );
  }
}

class _AssistantDetail extends StatelessWidget {
  const _AssistantDetail({
    required this.query,
    required this.onOpen,
    required this.onContinue,
  });

  final String query;
  final ValueChanged<_SearchPage> onOpen;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final keyword = query.trim().isEmpty ? '詐欺罪' : query.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            constraints: BoxConstraints(maxWidth: 250.w),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: _SearchColors.primary,
              borderRadius: BorderRadius.circular(18.r),
            ),
            child: Text('請整理「$keyword」的法律重點與下一步。', style: _SearchText.bubble()),
          ),
        ),
        SizedBox(height: 14.h),
        _ProtoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('小法助重點回答', style: _SearchText.section()),
              SizedBox(height: 10.h),
              Text('詐欺罪是指以欺罔方式，使他人陷入錯誤而處分財產，並造成財產損害。',
                  style: _SearchText.bodyStrong()),
              SizedBox(height: 12.h),
              const _CheckLine(text: '以不實之表示或隱匿重要事實'),
              const _CheckLine(text: '使對方陷於錯誤'),
              const _CheckLine(text: '因錯誤而為財產處分'),
              const _CheckLine(text: '發生財產損害'),
              SizedBox(height: 12.h),
              Text('不構成詐欺的情形（例）', style: _SearchText.section()),
              SizedBox(height: 8.h),
              Text('契約不履行若沒有一開始的欺罔意圖，可能是民事債務不履行，不一定構成刑事詐欺。',
                  style: _SearchText.body()),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        _NextStep(label: '查看相關法條', onTap: () => onOpen(_SearchPage.statutes)),
        _NextStep(label: '查看相關案件判例', onTap: () => onOpen(_SearchPage.cases)),
        _NextStep(
            label: '查看生活避坑筆記', onTap: () => onOpen(_SearchPage.lifeNotes)),
        SizedBox(height: 14.h),
        _PrimaryButton(label: '繼續向小法助提問', onPressed: onContinue),
      ],
    );
  }
}

class _ResultList extends StatelessWidget {
  const _ResultList({
    required this.tabLabels,
    required this.items,
    required this.onOpen,
    required this.actionLabel,
    required this.isSaved,
    required this.onSaved,
    required this.onAction,
  });

  final List<String> tabLabels;
  final List<_SearchResult> items;
  final ValueChanged<_SearchResult> onOpen;
  final String actionLabel;
  final bool Function(_SearchResult item) isSaved;
  final ValueChanged<_SearchResult> onSaved;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TabStrip(labels: tabLabels),
        SizedBox(height: 12.h),
        _FilterRow(),
        SizedBox(height: 12.h),
        if (items.isEmpty)
          const _SearchStateCard(message: '目前沒有符合的搜尋結果。')
        else
          for (final item in items) ...[
            _ResultTile(
              item: item,
              onTap: () => onOpen(item),
              showBookmark: true,
              isSaved: isSaved(item),
              onBookmark: () => onSaved(item),
            ),
            SizedBox(height: 10.h),
          ],
        SizedBox(height: 14.h),
        _SecondaryButton(label: actionLabel, onPressed: onAction),
      ],
    );
  }
}

class _StatuteDetail extends StatelessWidget {
  const _StatuteDetail({
    required this.item,
    required this.isFollowed,
    required this.isSaved,
    required this.onFollow,
    required this.onSaved,
    required this.onAssistant,
  });

  final _SearchResult item;
  final bool isFollowed;
  final bool isSaved;
  final VoidCallback onFollow;
  final VoidCallback onSaved;
  final VoidCallback onAssistant;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(item.title, style: _SearchText.heroSmall()),
        SizedBox(height: 4.h),
        Text('侵權成立之基礎', style: _SearchText.caption()),
        SizedBox(height: 14.h),
        const _TabStrip(labels: ['條文內容', '相關解釋']),
        SizedBox(height: 16.h),
        _ProtoCard(
          child: Text('侵權行為成立時，行為人可能需要負損害賠償責任。實際仍要看故意過失、權利侵害、損害與因果關係。',
              style: _SearchText.bodyStrong()),
        ),
        SizedBox(height: 14.h),
        Text('相關法條', style: _SearchText.section()),
        SizedBox(height: 10.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: const [
            _SmallTag(label: '民法 第444條'),
            _SmallTag(label: '民法 第445條'),
          ],
        ),
        SizedBox(height: 16.h),
        _ProtoCard(
          background: _SearchColors.mint,
          onTap: onAssistant,
          child: Row(
            children: [
              Icon(Icons.search_rounded,
                  color: _SearchColors.primary, size: 18.sp),
              SizedBox(width: 8.w),
              Expanded(
                  child: Text('小法助問：${item.title}可以怎麼用？',
                      style: _SearchText.captionStrong())),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _SecondaryButton(
                label: isFollowed ? '已追蹤法條' : '加入追蹤',
                onPressed: onFollow,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _SecondaryButton(
                label: isSaved ? '已收藏法條' : '收藏法條',
                onPressed: onSaved,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CaseDetail extends StatelessWidget {
  const _CaseDetail({
    required this.item,
    required this.isFollowed,
    required this.isSaved,
    required this.onFollow,
    required this.onSaved,
    required this.onOpenFullText,
  });

  final _SearchResult item;
  final bool isFollowed;
  final bool isSaved;
  final VoidCallback onFollow;
  final VoidCallback onSaved;
  final VoidCallback onOpenFullText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(item.title, style: _SearchText.heroSmall()),
        SizedBox(height: 10.h),
        const _TabStrip(labels: ['案件資訊', '相關資料']),
        SizedBox(height: 14.h),
        _ProtoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('判決要旨', style: _SearchText.section()),
              SizedBox(height: 10.h),
              Text(item.summary, style: _SearchText.bodyStrong()),
              SizedBox(height: 12.h),
              Text('案件資訊', style: _SearchText.section()),
              SizedBox(height: 8.h),
              const _Bullet(text: '裁判字號：109 年台上字第 123 號'),
              const _Bullet(text: '裁判日期：110.08.18'),
              const _Bullet(text: '案件類別：刑事'),
              const _Bullet(text: '結果：上訴駁回'),
            ],
          ),
        ),
        SizedBox(height: 14.h),
        _SecondaryButton(label: '查看判決全文', onPressed: onOpenFullText),
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(
              child: _SecondaryButton(
                label: isFollowed ? '已追蹤案件' : '加入追蹤',
                onPressed: onFollow,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _SecondaryButton(
                label: isSaved ? '已收藏案件' : '收藏案件',
                onPressed: onSaved,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LifeNoteList extends StatelessWidget {
  const _LifeNoteList({
    required this.items,
    required this.onOpen,
    required this.onMore,
  });

  final List<_SearchResult> items;
  final ValueChanged<_SearchResult> onOpen;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _TabStrip(labels: ['全部', '小法助', '法規', '案件', '生活避坑', '官方資料']),
        SizedBox(height: 14.h),
        if (items.isEmpty)
          const _SearchStateCard(message: '目前沒有符合的生活筆記。')
        else
          for (final item in items) ...[
            _LifeCard(item: item, onTap: () => onOpen(item)),
            SizedBox(height: 10.h),
          ],
        SizedBox(height: 14.h),
        _SecondaryButton(label: '查看更多生活避坑筆記', onPressed: onMore),
      ],
    );
  }
}

class _LifeNoteDetail extends StatelessWidget {
  const _LifeNoteDetail({
    required this.item,
    required this.isSaved,
    required this.onSaved,
  });

  final _SearchResult item;
  final bool isSaved;
  final VoidCallback onSaved;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ProtoCard(
          background: _SearchColors.mint,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title, style: _SearchText.section()),
                    SizedBox(height: 8.h),
                    Text('10 分鐘閱讀・5 分鐘摘要・112.02.10 更新',
                        style: _SearchText.caption()),
                  ],
                ),
              ),
              SvgPicture.asset(_SearchAsset.clipboard,
                  width: 94.w, height: 94.w),
            ],
          ),
        ),
        SizedBox(height: 14.h),
        Text('多數解說', style: _SearchText.section()),
        SizedBox(height: 10.h),
        const _CheckLine(text: '保留證據：保存對話、訂單、匯款紀錄'),
        const _CheckLine(text: '事實背景：要求說明扣款明細'),
        const _CheckLine(text: '內平台申訴：提出申訴或調解'),
        const _CheckLine(text: '向主管機關申訴：如消保官或勞工局'),
        SizedBox(height: 14.h),
        _PrimaryButton(label: isSaved ? '已收藏此筆記' : '收藏此筆記', onPressed: onSaved),
      ],
    );
  }
}

class _OfficialList extends StatelessWidget {
  const _OfficialList({
    required this.items,
    required this.onOpen,
    required this.onMore,
  });

  final List<_SearchResult> items;
  final ValueChanged<_SearchResult> onOpen;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _TabStrip(labels: ['全部', '小法助', '法規', '案件', '官方資料']),
        SizedBox(height: 14.h),
        if (items.isEmpty)
          const _SearchStateCard(message: '目前沒有符合的官方資料。')
        else
          for (final item in items) ...[
            _ResultTile(
              item: item,
              onTap: () => onOpen(item),
              showBookmark: false,
            ),
            SizedBox(height: 10.h),
          ],
        SizedBox(height: 14.h),
        _SecondaryButton(label: '查看更多官方資料', onPressed: onMore),
      ],
    );
  }
}

class _FilterPanel extends StatelessWidget {
  const _FilterPanel({required this.onApply});

  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return _ProtoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('篩選條件', style: _SearchText.section())),
              Text('重設', style: _SearchText.action()),
            ],
          ),
          SizedBox(height: 16.h),
          Text('資料來源', style: _SearchText.captionStrong()),
          SizedBox(height: 8.h),
          const _CheckLine(text: '小法助'),
          const _CheckLine(text: '法規'),
          const _CheckLine(text: '案件'),
          const _CheckLine(text: '生活避坑'),
          const _CheckLine(text: '官方資料'),
          SizedBox(height: 14.h),
          Text('時間範圍', style: _SearchText.captionStrong()),
          SizedBox(height: 8.h),
          const _RadioLine(text: '不限時間', selected: true),
          const _RadioLine(text: '近一年'),
          const _RadioLine(text: '近三年'),
          const _RadioLine(text: '自訂區間'),
          SizedBox(height: 14.h),
          Text('排序方式', style: _SearchText.captionStrong()),
          SizedBox(height: 8.h),
          const _RadioLine(text: '相關性', selected: true),
          const _RadioLine(text: '最新'),
          SizedBox(height: 16.h),
          _PrimaryButton(label: '套用篩選', onPressed: onApply),
        ],
      ),
    );
  }
}

class _SearchActionSheet extends StatelessWidget {
  const _SearchActionSheet({
    required this.title,
    required this.message,
    required this.actions,
  });

  final String title;
  final String message;
  final List<_SheetAction> actions;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        child: _ProtoCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: _SearchText.section()),
              SizedBox(height: 8.h),
              Text(message, style: _SearchText.body()),
              SizedBox(height: 14.h),
              for (final action in actions) ...[
                _SheetActionTile(action: action),
                SizedBox(height: 8.h),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetActionTile extends StatelessWidget {
  const _SheetActionTile({required this.action});

  final _SheetAction action;

  @override
  Widget build(BuildContext context) {
    return _ProtoCard(
      onTap: action.onTap,
      background: _SearchColors.softMint,
      child: Row(
        children: [
          _IconBox(icon: action.icon, color: _SearchColors.primary),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(action.title, style: _SearchText.tileTitle()),
                SizedBox(height: 4.h),
                Text(action.subtitle, style: _SearchText.caption()),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              color: _SearchColors.mutedText, size: 20.sp),
        ],
      ),
    );
  }
}

class _SheetAction {
  const _SheetAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onSubmitted,
    required this.onClear,
    this.showFilter = false,
    this.onFilter,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;
  final bool showFilter;
  final VoidCallback? onFilter;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: _SearchColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.search,
        onSubmitted: onSubmitted,
        textAlignVertical: TextAlignVertical.center,
        style: _SearchText.bodyStrong(),
        decoration: InputDecoration(
          hintText: '搜尋法條、案件、生活筆記、官方資料',
          hintStyle: _SearchText.bodyStrong().copyWith(
            color: _SearchColors.mutedText,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: _SearchColors.mutedText,
            size: 22.sp,
          ),
          suffixIcon: showFilter
              ? IconButton(
                  tooltip: '篩選',
                  icon: Icon(
                    Icons.tune_rounded,
                    color: _SearchColors.primary,
                    size: 21.sp,
                  ),
                  onPressed: onFilter,
                )
              : controller.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: '清除搜尋',
                      icon: Icon(
                        Icons.close_rounded,
                        color: _SearchColors.mutedText,
                        size: 18.sp,
                      ),
                      onPressed: onClear,
                    ),
          filled: false,
          isCollapsed: true,
          contentPadding: EdgeInsets.zero,
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class _SearchTabs extends StatelessWidget {
  const _SearchTabs({required this.tab, required this.onTab});

  final _SearchTab tab;
  final ValueChanged<_SearchTab> onTab;

  @override
  Widget build(BuildContext context) {
    final labels = {
      _SearchTab.all: '全部',
      _SearchTab.assistant: '小法助',
      _SearchTab.statutes: '法規',
      _SearchTab.cases: '案件',
      _SearchTab.lifeNotes: '生活避坑',
      _SearchTab.official: '官方資料',
    };
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: labels.entries.map((entry) {
          final active = entry.key == tab;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onTab(entry.key),
            child: Padding(
              padding: EdgeInsets.only(right: 19.w, top: 8.h),
              child: Container(
                padding: EdgeInsets.only(bottom: 9.h),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color:
                          active ? _SearchColors.primary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  entry.value,
                  style: _SearchText.tab().copyWith(
                    color: active
                        ? _SearchColors.primary
                        : _SearchColors.mutedText,
                  ),
                ),
              ),
            ),
          );
        }).toList(growable: false),
      ),
    );
  }
}

class _TabStrip extends StatelessWidget {
  const _TabStrip({required this.labels});

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Container(
              margin: EdgeInsets.only(right: 18.w),
              padding: EdgeInsets.only(bottom: 8.h),
              decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color:
                            i == 0 ? _SearchColors.primary : Colors.transparent,
                        width: 1.5)),
              ),
              child: Text(labels[i],
                  style: _SearchText.captionStrong().copyWith(
                      color: i == 0
                          ? _SearchColors.primary
                          : _SearchColors.mutedText)),
            ),
        ],
      ),
    );
  }
}

class _AssistantHint extends StatelessWidget {
  const _AssistantHint({required this.query, required this.onTap});

  final String query;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _ProtoCard(
      background: _SearchColors.softMint,
      onTap: onTap,
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 4.w, 4.h),
      child: SizedBox(
        height: 100.h,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              right: 104.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('小法助總結', style: _SearchText.section()),
                  SizedBox(height: 8.h),
                  Text(
                    '針對「$query」整理相關法規、案件與生活避坑重點。',
                    style: _SearchText.body(),
                  ),
                  SizedBox(height: 8.h),
                  Text('查看說明・2 分鐘前', style: _SearchText.caption()),
                ],
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: SvgPicture.asset(_SearchAsset.plant, width: 112.w),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({
    required this.item,
    required this.onTap,
    this.showBookmark = false,
    this.isSaved = false,
    this.onBookmark,
  });

  final _SearchResult item;
  final VoidCallback onTap;
  final bool showBookmark;
  final bool isSaved;
  final VoidCallback? onBookmark;

  @override
  Widget build(BuildContext context) {
    return _ProtoCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _IconBox(icon: _iconFor(item.type), color: _colorFor(item.type)),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: _SearchText.tileTitle()),
                SizedBox(height: 5.h),
                Text(item.summary, style: _SearchText.body()),
                SizedBox(height: 7.h),
                Text(item.source, style: _SearchText.caption()),
              ],
            ),
          ),
          if (showBookmark)
            InkWell(
              onTap: onBookmark,
              borderRadius: BorderRadius.circular(999.r),
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Icon(
                  isSaved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: _SearchColors.primary,
                  size: 20.sp,
                ),
              ),
            )
          else
            Icon(Icons.chevron_right_rounded,
                color: _SearchColors.mutedText, size: 20.sp),
        ],
      ),
    );
  }
}

class _AdvancedRoutes extends StatelessWidget {
  const _AdvancedRoutes({required this.onOpen});

  final ValueChanged<_SearchPage> onOpen;

  @override
  Widget build(BuildContext context) {
    return _ProtoCard(
      background: _SearchColors.softPaper,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('進階查詢路徑', style: _SearchText.section()),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _Pill(label: '小法助搜尋', onTap: () => onOpen(_SearchPage.assistant)),
              _Pill(label: '法規搜尋子頁', onTap: () => onOpen(_SearchPage.statutes)),
              _Pill(label: '案件搜尋子頁', onTap: () => onOpen(_SearchPage.cases)),
              _Pill(label: '官方資料', onTap: () => onOpen(_SearchPage.official)),
            ],
          ),
        ],
      ),
    );
  }
}

class _LifeCard extends StatelessWidget {
  const _LifeCard({required this.item, required this.onTap});

  final _SearchResult item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _ProtoCard(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: _SearchText.tileTitle()),
                SizedBox(height: 6.h),
                Text(item.summary, style: _SearchText.body()),
                SizedBox(height: 6.h),
                Text('小法助・3 分鐘閱讀', style: _SearchText.caption()),
              ],
            ),
          ),
          SvgPicture.asset(_SearchAsset.clipboard, width: 74.w, height: 74.w),
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _MiniFilter(label: '排序：相關性'),
        SizedBox(width: 8.w),
        _MiniFilter(label: '時間：全部'),
        const Spacer(),
        _MiniFilter(label: '篩選'),
      ],
    );
  }
}

class _MiniFilter extends StatelessWidget {
  const _MiniFilter({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _SearchColors.border),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(label, style: _SearchText.captionStrong()),
    );
  }
}

class _NextStep extends StatelessWidget {
  const _NextStep({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: _ProtoCard(
        onTap: onTap,
        child: Row(
          children: [
            Icon(Icons.open_in_new_rounded,
                color: _SearchColors.primary, size: 18.sp),
            SizedBox(width: 8.w),
            Expanded(child: Text(label, style: _SearchText.captionStrong())),
          ],
        ),
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({required this.item});

  final _QuickAction item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: SizedBox(
        height: 98.h,
        child: _ProtoCard(
          onTap: item.onTap,
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, color: _SearchColors.primary, size: 27.sp),
              SizedBox(height: 8.h),
              Text(
                item.label,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: _SearchText.captionStrong(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar(
      {required this.title,
      required this.showBack,
      required this.onBack,
      this.trailing});

  final String title;
  final bool showBack;
  final VoidCallback onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showBack) ...[
          _RoundIcon(icon: Icons.arrow_back_ios_new_rounded, onTap: onBack),
          SizedBox(width: 10.w),
        ],
        Expanded(child: Text(title, style: _SearchText.navTitle())),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999.r),
      child: Container(
        width: 38.w,
        height: 38.w,
        decoration:
            const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: Icon(icon, color: _SearchColors.text, size: 20.sp),
      ),
    );
  }
}

class _ProtoCard extends StatelessWidget {
  const _ProtoCard({
    required this.child,
    this.onTap,
    this.background = Colors.white,
    this.padding,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color background;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    const radius = 14.0;
    final card = Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(13.w),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius.r),
        border: Border.all(color: _SearchColors.border),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0D000000), blurRadius: 14, offset: Offset(0, 6))
        ],
      ),
      child: child,
    );
    if (onTap == null) return card;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius.r),
      child: card,
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: Colors.white,
      side: const BorderSide(color: _SearchColors.border),
      visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 8.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999.r)),
      labelStyle: _SearchText.captionStrong(),
    );
  }
}

class _SmallTag extends StatelessWidget {
  const _SmallTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: _SearchColors.mint,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(label, style: _SearchText.captionStrong()),
    );
  }
}

class _CheckLine extends StatelessWidget {
  const _CheckLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 7.h),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded,
              color: _SearchColors.primary, size: 16.sp),
          SizedBox(width: 8.w),
          Expanded(child: Text(text, style: _SearchText.bodyStrong())),
        ],
      ),
    );
  }
}

class _RadioLine extends StatelessWidget {
  const _RadioLine({required this.text, this.selected = false});

  final String text;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: _SearchColors.primary,
              size: 17.sp),
          SizedBox(width: 8.w),
          Text(text, style: _SearchText.bodyStrong()),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 7.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: _SearchText.bodyStrong()),
          Expanded(child: Text(text, style: _SearchText.bodyStrong())),
        ],
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42.w,
      height: 42.w,
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(12.r)),
      child: Icon(icon, color: color, size: 22.sp),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 46.h,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: _SearchColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999.r)),
        ),
        child: Text(label),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 42.h,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: _SearchColors.primary,
          side: const BorderSide(color: _SearchColors.border),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
        ),
        child: Text(label),
      ),
    );
  }
}

class _QuickAction {
  const _QuickAction(this.label, this.icon, this.onTap);

  final String label;
  final IconData icon;
  final VoidCallback onTap;
}

class _SearchResult {
  const _SearchResult({
    required this.type,
    required this.title,
    required this.summary,
    required this.source,
    required this.query,
    this.sourceUrl = '',
    this.officialUrl = '',
    this.updatedAt,
  });

  factory _SearchResult.fromRepository(SearchResultItem item) {
    final sourceParts = [
      item.subtitle,
      item.source,
    ].where((value) => value.trim().isNotEmpty).toList(growable: false);

    return _SearchResult(
      type: _resultTypeFor(item.type),
      title: item.title,
      summary: item.snippet.isEmpty ? item.subtitle : item.snippet,
      source: sourceParts.isEmpty ? 'LawApp' : sourceParts.join('・'),
      query: item.title,
      sourceUrl: item.sourceUrl,
      officialUrl: item.officialUrl,
      updatedAt: item.updatedAt,
    );
  }

  final _ResultType type;
  final String title;
  final String summary;
  final String source;
  final String query;
  final String sourceUrl;
  final String officialUrl;
  final DateTime? updatedAt;

  String get preferredSourceUrl =>
      officialUrl.trim().isNotEmpty ? officialUrl.trim() : sourceUrl.trim();
}

_SearchResult _assistantResultFor(String query) {
  final keyword = query.trim().isEmpty ? '你的問題' : query.trim();
  return _SearchResult(
    type: _ResultType.assistant,
    title: '請小法助整理「$keyword」',
    summary: '把這次搜尋字帶入 AI 法律輔助，整理相關法規、案件與下一步。',
    source: 'LawApp 小法助',
    query: keyword,
  );
}

_ResultType _resultTypeFor(SearchResultType type) {
  switch (type) {
    case SearchResultType.assistant:
      return _ResultType.assistant;
    case SearchResultType.statute:
      return _ResultType.statute;
    case SearchResultType.caseItem:
      return _ResultType.caseItem;
    case SearchResultType.news:
      return _ResultType.official;
    case SearchResultType.document:
    case SearchResultType.tool:
      return _ResultType.lifeNote;
  }
}

String _interactionIdFor(_SearchResult item) {
  final prefix = switch (item.type) {
    _ResultType.assistant => 'assistant',
    _ResultType.statute => 'statute',
    _ResultType.caseItem => 'case',
    _ResultType.lifeNote => 'article',
    _ResultType.official => 'official',
  };
  return '$prefix-${_slugFor(item.title)}';
}

String _slugFor(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'\s+'), '')
      .replaceAll(RegExp(r'[^a-z0-9\u4e00-\u9fff]+'), '')
      .replaceAll(RegExp(r'-+'), '-');
}

class _SearchAsset {
  static const plant = 'assets/images/search/search_plant.svg';
  static const clipboard = 'assets/images/search/search_clipboard.svg';
}

class _SearchText {
  static TextStyle hero() => TextStyle(
      color: _SearchColors.primary,
      fontSize: 28.sp,
      fontWeight: FontWeight.w900,
      height: 1.05);
  static TextStyle heroSmall() => TextStyle(
      color: _SearchColors.text,
      fontSize: 20.sp,
      fontWeight: FontWeight.w900,
      height: 1.22);
  static TextStyle navTitle() => TextStyle(
      color: _SearchColors.text, fontSize: 19.sp, fontWeight: FontWeight.w900);
  static TextStyle section() => TextStyle(
      color: _SearchColors.text,
      fontSize: 16.sp,
      fontWeight: FontWeight.w900,
      height: 1.3);
  static TextStyle tileTitle() => TextStyle(
      color: _SearchColors.text,
      fontSize: 13.sp,
      fontWeight: FontWeight.w900,
      height: 1.3);
  static TextStyle bodyStrong() => TextStyle(
      color: _SearchColors.text,
      fontSize: 12.sp,
      fontWeight: FontWeight.w700,
      height: 1.55);
  static TextStyle body() => TextStyle(
      color: _SearchColors.mutedText,
      fontSize: 12.sp,
      fontWeight: FontWeight.w600,
      height: 1.45);
  static TextStyle caption() => TextStyle(
      color: _SearchColors.mutedText,
      fontSize: 10.8.sp,
      fontWeight: FontWeight.w600,
      height: 1.3);
  static TextStyle captionStrong() => TextStyle(
      color: _SearchColors.text,
      fontSize: 11.sp,
      fontWeight: FontWeight.w900,
      height: 1.25);
  static TextStyle tab() => TextStyle(
      color: _SearchColors.text,
      fontSize: 13.sp,
      fontWeight: FontWeight.w900,
      height: 1.2);
  static TextStyle action() => TextStyle(
      color: _SearchColors.primary,
      fontSize: 12.sp,
      fontWeight: FontWeight.w900);
  static TextStyle bubble() => TextStyle(
      color: Colors.white,
      fontSize: 12.sp,
      fontWeight: FontWeight.w700,
      height: 1.45);
}

class _SearchColors {
  static const background = Color(0xFFFAF7F2);
  static const primary = Color(0xFF1E6D5A);
  static const secondary = Color(0xFFA8CBB3);
  static const text = Color(0xFF2E3D34);
  static const mutedText = Color(0xFF687B72);
  static const border = Color(0xFFE2D7C9);
  static const softPaper = Color(0xFFF2ECE4);
  static const softMint = Color(0xFFEAF5EC);
  static const mint = Color(0xFFEAF7F2);
  static const orange = Color(0xFFE7B76D);
}

IconData _iconFor(_ResultType type) {
  switch (type) {
    case _ResultType.assistant:
      return Icons.support_agent_rounded;
    case _ResultType.statute:
      return Icons.menu_book_outlined;
    case _ResultType.caseItem:
      return Icons.inventory_2_outlined;
    case _ResultType.lifeNote:
      return Icons.lightbulb_outline_rounded;
    case _ResultType.official:
      return Icons.verified_outlined;
  }
}

Color _colorFor(_ResultType type) {
  switch (type) {
    case _ResultType.assistant:
      return _SearchColors.orange;
    case _ResultType.statute:
      return _SearchColors.primary;
    case _ResultType.caseItem:
      return _SearchColors.secondary;
    case _ResultType.lifeNote:
      return const Color(0xFFE7B76D);
    case _ResultType.official:
      return const Color(0xFF8AA79B);
  }
}

const _assistantResults = [
  _SearchResult(
    type: _ResultType.assistant,
    title: '詐欺罪的成立要件是什麼？',
    summary: '小法助會拆成欺罔、錯誤、處分、損害與不法所有意圖。',
    source: 'LawApp 小法助',
    query: '詐欺',
  ),
];

const _statuteResults = [
  _SearchResult(
    type: _ResultType.statute,
    title: '民法第 184 條',
    summary: '侵權行為與損害賠償，常見於車禍、網路言論與消費糾紛。',
    source: '民法・第 184 條・112.06.21 更新',
    query: '民法 184',
    sourceUrl: 'https://law.moj.gov.tw/LawClass/LawAll.aspx?pcode=B0000001',
    officialUrl: 'https://law.moj.gov.tw/LawClass/LawAll.aspx?pcode=B0000001',
  ),
  _SearchResult(
    type: _ResultType.statute,
    title: '民法第 444 條',
    summary: '租賃關係中，承租人使用收益與返還義務的相關規定。',
    source: '民法・第 444 條・112.06.21 更新',
    query: '民法 444',
    sourceUrl: 'https://law.moj.gov.tw/LawClass/LawAll.aspx?pcode=B0000001',
    officialUrl: 'https://law.moj.gov.tw/LawClass/LawAll.aspx?pcode=B0000001',
  ),
  _SearchResult(
    type: _ResultType.statute,
    title: '刑法第 339 條',
    summary: '詐欺取財罪的基本規定。',
    source: '刑法・第 339 條・112.07.01 更新',
    query: '刑法 339',
    sourceUrl: 'https://law.moj.gov.tw/LawClass/LawAll.aspx?pcode=C0000001',
    officialUrl: 'https://law.moj.gov.tw/LawClass/LawAll.aspx?pcode=C0000001',
  ),
  _SearchResult(
    type: _ResultType.statute,
    title: '勞動基準法第 24 條',
    summary: '延長工時與加班費計算。',
    source: '勞基法・第 24 條・112.06.21 更新',
    query: '勞動基準法 24',
    sourceUrl: 'https://law.moj.gov.tw/LawClass/LawAll.aspx?pcode=N0030001',
    officialUrl: 'https://law.moj.gov.tw/LawClass/LawAll.aspx?pcode=N0030001',
  ),
];

const _caseResults = [
  _SearchResult(
    type: _ResultType.caseItem,
    title: '臺灣高等法院 109 年重上字第 123 號詐欺案件',
    summary: '被告以虛假投資資訊誘使被害人匯款，法院討論詐欺故意與因果關係。',
    source: '刑事・109 年・上訴・110.08.18',
    query: '詐欺案件',
  ),
  _SearchResult(
    type: _ResultType.caseItem,
    title: '臺灣高院 110 年台上字第 455 號',
    summary: '投資詐騙與取款分工案例。',
    source: '刑事・110 年・上訴・111.10.25',
    query: '投資詐騙',
  ),
  _SearchResult(
    type: _ResultType.caseItem,
    title: '臺灣高等法院 111 年訴字第 760 號',
    summary: '詐欺集團車手提款與洗錢防制爭點。',
    source: '刑事・111 年・一審・111.10.22',
    query: '洗錢',
  ),
];

const _lifeResults = [
  _SearchResult(
    type: _ResultType.lifeNote,
    title: '網購詐騙怎麼辦？5 步驟保護你的錢',
    summary: '保存對話、訂單、匯款紀錄，並儘快聯繫平台與銀行。',
    source: '生活避坑・10 分鐘閱讀',
    query: '網購詐騙',
  ),
  _SearchResult(
    type: _ResultType.lifeNote,
    title: '遇到詐騙電話怎麼處理？3 個關鍵自保原則',
    summary: '不要提供驗證碼、帳戶資料或遠端操作權限。',
    source: '小法助・3 分鐘閱讀',
    query: '詐騙電話',
  ),
  _SearchResult(
    type: _ResultType.lifeNote,
    title: '投資詐騙常見手法與防範重點',
    summary: '高報酬、保證獲利、要求私下轉帳都是警訊。',
    source: '知識整理・6 分鐘閱讀',
    query: '投資詐騙',
  ),
];

const _officialResults = [
  _SearchResult(
    type: _ResultType.official,
    title: '內政部警政署防詐騙 Q&A',
    summary: '詐欺案件常見通報與防範方式彙整。',
    source: '警政署・最新防詐資訊',
    query: '防詐騙',
    sourceUrl: 'https://165.npa.gov.tw/',
    officialUrl: 'https://165.npa.gov.tw/',
  ),
  _SearchResult(
    type: _ResultType.official,
    title: '法務部反詐騙宣導專區',
    summary: '司法機關整理常見詐騙手法與防制宣導。',
    source: '法務部',
    query: '法務部 反詐騙',
    sourceUrl: 'https://www.moj.gov.tw/',
    officialUrl: 'https://www.moj.gov.tw/',
  ),
  _SearchResult(
    type: _ResultType.official,
    title: '金融監督管理委員會防詐騙專區',
    summary: '金融投資與帳戶安全相關防詐資訊。',
    source: '金管會',
    query: '金融詐騙',
    sourceUrl: 'https://www.fsc.gov.tw/',
    officialUrl: 'https://www.fsc.gov.tw/',
  ),
];

const _mockResults = [
  ..._assistantResults,
  ..._statuteResults,
  ..._caseResults,
  ..._lifeResults,
  ..._officialResults,
];
