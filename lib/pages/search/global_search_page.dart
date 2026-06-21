import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lawapp/app/app_state.dart';
import 'package:lawapp/data/search/search_models.dart';
import 'package:lawapp/data/search/search_repository.dart';
import 'package:lawapp/pages/learning/know_law_page.dart';
import 'package:lawapp/data/cases/case_models.dart';
import 'package:lawapp/data/cases/case_repository.dart';
import 'package:lawapp/data/statutes/statute_item.dart';
import 'package:lawapp/data/statutes/statute_repository.dart';
import 'package:lawapp/pages/journal/data/journal_page_items.dart';
import 'package:url_launcher/url_launcher.dart';

part 'widgets/ai_overview_card.dart';
part 'widgets/search_result_cards.dart';
part 'widgets/search_state_and_filter_widgets.dart';
part 'widgets/search_home_widgets.dart';

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

  // AI Assistant Overview state variables
  bool _aiIsThinking = false;
  String _aiTone = '白話'; // '白話' or '專業'
  String _aiLength = '精簡'; // '精簡' or '詳細'
  String _aiGeneratedSummary = '';

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

  // 模擬 AI 根據語氣與長度重新生成內容
  void _triggerAiOverviewGeneration(String query) {
    if (query.isEmpty) return;
    setState(() {
      _aiIsThinking = true;
    });

    // 模擬網路延遲與 AI 思考過程
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted || _query != query) return;

      String summaryBase = '';
      if (query.contains('詐欺')) {
        if (_aiTone == '白話') {
          summaryBase = _aiLength == '精簡'
              ? '「詐欺罪」就是用騙人的手段，讓對方做出錯誤決定而把財物交出來，導致對方受損。不履行合約如果一開始沒有騙人的意思，通常只是民事問題，不一定構成犯罪喔！'
              : '「詐欺罪」是指用欺騙的手段，使他人陷入錯誤判斷，因而處分財產並造成損害。主要成立條件包括：\n1. 行為人有欺罔行為（說謊或刻意隱瞞）。\n2. 被害人因此產生錯誤認知。\n3. 被害人因為錯誤而交付財產。\n4. 造成財產上的損害。\n5. 行為人主觀上有故意及不法所有意圖。如果只是事後不履行契約，但一開始沒有騙人意圖，通常屬民事債務糾紛，不構成刑事詐欺罪。';
        } else {
          summaryBase = _aiLength == '精簡'
              ? '依刑法第339條，本罪構成要件需具備施用詐術、被害人陷於錯誤、處分財產、財產損害及因果關係。契約不履行若欠缺主觀不法所有意圖，則屬民事不法而非刑事詐欺。'
              : '刑事詐欺取財罪（刑法第339條）之成立，客觀要件須行為人施用詐術（欺罔手段），使相對人陷於錯誤，並因而為財產處分，致相對人或第三人受有財產上之損害，且各要件間具有相當因果關係；主觀要件則須具備詐欺故意及「意圖為自己或第三人不法之所有」。若係單純契約不履行，而無法證明行為人於締約之初即有詐欺故意及不法所有意圖，即屬民事債務不履行範疇，應循民事程序救濟。';
        }
      } else if (query.contains('瑕疵') ||
          query.contains('退貨') ||
          query.contains('消費') ||
          query.contains('鑑賞期') ||
          query.contains('7天')) {
        if (_aiTone == '白話') {
          summaryBase = _aiLength == '精簡'
              ? '買到瑕疵商品，如果是網購可在7天內無條件退貨退款。若是一般實體店面，則需符合民法瑕疵擔保，要求退款或換貨，但要儘快通知賣家喔！'
              : '買到瑕疵商品的權利依購買管道而定：\n1. 網路購物（郵購買賣）：享有消費者保護法第19條規定，7天鑑賞期內無條件退貨解約，不需說明理由或負擔任何費用。\n2. 實體店面購物：不適用7天鑑賞期。但如果商品有物理或價值上的瑕疵，可主張民法第354條瑕疵擔保責任，要求減少價金（打折）或解除契約（退款），若屬重大瑕疵甚至可請求損害賠償。提醒：收到貨後應立刻檢查，發現瑕疵須即時通知賣家。';
        } else {
          summaryBase = _aiLength == '精簡'
              ? '消保法第19條賦予通訊交易消費者7日解約權。實體買賣則依民法第359條，買受人得主張物之瑕疵擔保，請求解除契約或減少價金；若受有損害且可歸責於出賣人，得依同法第360條請求不履行之損害賠償。'
              : '就買受人物之瑕疵擔保權利分析如下：\n1. 特殊交易型態：若屬消費者保護法第2條之通訊交易（如網路購物），消費者得依同法第19條，於收受商品後7日內無條件解除契約，退回商品並請求返還價金。\n2. 一般買賣契約：依民法第354條規定，出賣人應負物之瑕疵擔保責任。買受人得依同法第359條，請求解除契約（退貨退款）或減少價金（折讓）。惟若瑕疵程度輕微，解除契約顯失公平者，買受人僅得請求減少價金。若商品欠缺出賣人所保證之品質，或出賣人故意不告知瑕疵者，買受人得依同法第360條，不請求減少價金或解除契約，而逕行請求不履行之損害賠償。買受人應依民法第356條負即時檢查與通知義務，以免喪失權利。';
        }
      } else {
        if (_aiTone == '白話') {
          summaryBase = _aiLength == '精簡'
              ? '針對「$query」，建議您詳查相關民刑事責任。如有具體爭議，可善用我的法律摘錄本記錄重點，或進一步與小法助聊聊！'
              : '針對您查詢的「$query」：\n我們已為您彙整了相關法規與裁判案例。法律問題的判定高度依賴個案具體事實與證據。建議您可以將有用的資訊「📌 摘錄」到您的筆記本中，或者點擊下方按鈕開啟與小法助的多輪深入對話，以獲得更精確的分析與解答。';
        } else {
          summaryBase = _aiLength == '精簡'
              ? '關於「$query」之法律爭議，須視具體客觀構成要件與因果關係而定。建議保存實體證據並依法主張瑕疵擔保或侵權損害賠償責任。'
              : '關於「$query」之研析：\n本件法律關係之釐清，端視具體事實是否符合特定法規之構成要件。建議關係人應預先整理並留存相關契約、對話紀錄或匯款憑證等書證。您可藉由「📌 摘錄」功能彙整檢索所得之法規與判決要旨，或點選「繼續與小法助聊聊」開啟完整問答介面進行法律實務與救濟途徑之深入剖析。';
        }
      }

      setState(() {
        _aiGeneratedSummary = summaryBase;
        _aiIsThinking = false;
      });
    });
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

    // 觸發 AI 摘要生成
    _triggerAiOverviewGeneration(query);

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
      _aiGeneratedSummary = '';
      _aiIsThinking = false;
    });
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _clearRecent() {
    setState(_recent.clear);
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final showTopBar = _page == _SearchPage.assistant ||
        _page == _SearchPage.statuteDetail ||
        _page == _SearchPage.caseDetail ||
        _page == _SearchPage.lifeDetail ||
        _page == _SearchPage.filters;
    final showSearchField = _page == _SearchPage.results ||
        _page == _SearchPage.statutes ||
        _page == _SearchPage.cases ||
        _page == _SearchPage.lifeNotes ||
        _page == _SearchPage.official;

    // Calculate header height to offset the scrollable body padding
    double headerHeight = topPadding;
    if (showTopBar) {
      headerHeight += 64.h;
    } else if (showSearchField) {
      headerHeight += 76.h;
    }

    return Scaffold(
      backgroundColor: _SearchColors.background,
      body: Stack(
        children: [
          // 1. Ambient Background Gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          const Color(0xFF0F1216),
                          const Color(0xFF141922),
                          const Color(0xFF1C1310),
                        ]
                      : [
                          const Color(0xFFFAF7F2),
                          const Color(0xFFF3EFE9),
                          const Color(0xFFE8F2EC),
                        ],
                ),
              ),
            ),
          ),

          // 2. Scrollable Body Content
          Positioned.fill(
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding:
                  EdgeInsets.fromLTRB(16.w, headerHeight + 12.h, 16.w, 112.h),
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: KeyedSubtree(
                    key: ValueKey(
                        '${_page.name}-${_tab.name}-${_selected.title}'),
                    child: _contentFor(_page),
                  ),
                ),
              ],
            ),
          ),

          // 3. Fixed Glassmorphic Header
          if (showTopBar || showSearchField)
            Positioned(
              left: 0,
              top: 0,
              right: 0,
              height: headerHeight,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    padding:
                        EdgeInsets.fromLTRB(16.w, topPadding + 4.h, 16.w, 8.h),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF0F1216).withValues(alpha: 0.8)
                          : const Color(0xFFFAF7F2).withValues(alpha: 0.85),
                      border: Border(
                        bottom: BorderSide(
                          color: isDark
                              ? const Color(0xFF2C3545).withValues(alpha: 0.4)
                              : const Color(0xFFE2D7C9).withValues(alpha: 0.5),
                          width: 0.8.w,
                        ),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (showTopBar)
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
                        if (showSearchField) _buildSearchHeader(),
                      ],
                    ),
                  ),
                ),
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
      onVoice: _showVoiceSearchBottomSheet,
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
        return '法規詳情';
      case _SearchPage.cases:
        return '案件搜尋結果';
      case _SearchPage.caseDetail:
        return '判決詳情';
      case _SearchPage.lifeNotes:
        return '生活避坑筆記';
      case _SearchPage.lifeDetail:
        return '避坑指南';
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
          controller: _controller,
          onVoice: _showVoiceSearchBottomSheet,
        );
      case _SearchPage.results:
        if (_isSearching) {
          return const _SearchStateCard(
              message: '正在彙整全站搜尋結果...', showMascot: false);
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
          aiIsThinking: _aiIsThinking,
          aiTone: _aiTone,
          aiLength: _aiLength,
          aiSummary: _aiGeneratedSummary,
          onToneChanged: (newTone) {
            setState(() => _aiTone = newTone);
            _triggerAiOverviewGeneration(_query);
          },
          onLengthChanged: (newLength) {
            setState(() => _aiLength = newLength);
            _triggerAiOverviewGeneration(_query);
          },
          onNotebookSave: _saveAssistantSummaryToNotebook,
          onContinueChat: _continueWithAssistant,
        );
      case _SearchPage.assistant:
        return _AssistantDetail(
          query: _query,
          onOpen: _openList,
          onContinue: _continueWithAssistant,
        );
      case _SearchPage.statutes:
        if (_isSearching) {
          return const _SearchStateCard(
              message: '正在搜尋法規資料...', showMascot: false);
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
          onSaved: () => _showArchiveBottomSheet(context, _selected),
          onAssistant: () => _openAssistant(_selected.query),
          onNavigateResult: _openResult,
          onAskScenario: _openAssistant,
        );
      case _SearchPage.cases:
        if (_isSearching) {
          return const _SearchStateCard(
              message: '正在搜尋案件資料...', showMascot: false);
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
          onSaved: () => _showArchiveBottomSheet(context, _selected),
          onOpenFullText: () => _openCaseJudgment(_selected),
          onAskScenario: _openAssistant,
        );
      case _SearchPage.lifeNotes:
        if (_isSearching) {
          return const _SearchStateCard(
              message: '正在搜尋生活筆記...', showMascot: false);
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
          onSaved: () => _showArchiveBottomSheet(context, _selected),
          onAskScenario: _openAssistant,
        );
      case _SearchPage.official:
        if (_isSearching) {
          return const _SearchStateCard(
              message: '正在搜尋官方資料...', showMascot: false);
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

  void _showArchiveBottomSheet(BuildContext context, _SearchResult item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final folders = ['📁 租屋押金爭議', '📁 網購退貨權益', '📁 防詐騙金流紀錄', '📁 一般法律備忘'];
    int selectedIndex = 0;
    final noteController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(builder: (context, setSheetState) {
          return Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2430) : const Color(0xFFFAF7F2),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF2C3545).withValues(alpha: 0.8)
                    : _SearchColors.border.withValues(alpha: 0.5),
                width: 1.w,
              ),
            ),
            padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w,
                MediaQuery.of(context).viewInsets.bottom + 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF2C3545)
                          : const Color(0xFFE2D7C9),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('儲存至案件夾', style: _SearchText.section(context)),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      color: isDark ? Colors.white70 : _SearchColors.mutedText,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Text('選擇歸檔目錄', style: _SearchText.captionStrong(context)),
                SizedBox(height: 8.h),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 180.h),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: folders.length + 1,
                    itemBuilder: (context, index) {
                      if (index == folders.length) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.add_circle_outline_rounded,
                              color: isDark
                                  ? const Color(0xFF33A88D)
                                  : _SearchColors.primary),
                          title: Text('新增自訂案件夾...',
                              style: _SearchText.body(context).copyWith(
                                  color: isDark
                                      ? const Color(0xFF33A88D)
                                      : _SearchColors.primary)),
                          onTap: () {
                            setSheetState(() {
                              folders.add('📁 自訂案件夾 ${folders.length - 3}');
                              selectedIndex = folders.length - 1;
                            });
                          },
                        );
                      }
                      final isSelected = selectedIndex == index;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          isSelected
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_off_rounded,
                          color: isSelected
                              ? (isDark
                                  ? const Color(0xFF33A88D)
                                  : _SearchColors.primary)
                              : (isDark ? Colors.white30 : Colors.black26),
                        ),
                        title: Text(folders[index],
                            style: _SearchText.bodyStrong(context)),
                        onTap: () => setSheetState(() => selectedIndex = index),
                      );
                    },
                  ),
                ),
                SizedBox(height: 16.h),
                Text('備忘註記 (選填)', style: _SearchText.captionStrong(context)),
                SizedBox(height: 8.h),
                TextField(
                  controller: noteController,
                  style: _SearchText.bodyStrong(context),
                  decoration: InputDecoration(
                    hintText: '輸入與本案相關的備註事項...',
                    hintStyle: _SearchText.body(context),
                    filled: true,
                    fillColor: isDark
                        ? const Color(0xFF141922)
                        : const Color(0xFFF2ECE4),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                _PrimaryButton(
                  label: '確認歸檔',
                  onPressed: () {
                    Navigator.pop(context);
                    _toggleSaved(item);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        content: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 12.h),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1A3831)
                                : const Color(0xFFEAF7F2),
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF33A88D)
                                      .withValues(alpha: 0.6)
                                  : _SearchColors.primary
                                      .withValues(alpha: 0.3),
                              width: 1.w,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle_rounded,
                                  color: isDark
                                      ? const Color(0xFF33A88D)
                                      : _SearchColors.primary),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Text(
                                  '🎉 成功歸檔至「${folders[selectedIndex].substring(2)}」！',
                                  style:
                                      _SearchText.bodyStrong(context).copyWith(
                                    color: isDark
                                        ? const Color(0xFF33A88D)
                                        : _SearchColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        });
      },
    );
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.88,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            child: LawAssistantChatPage(initialPrompt: keyword),
          ),
        );
      },
    );
  }

  Future<void> _saveAssistantSummaryToNotebook() async {
    final appState = LawAppScope.of(context);
    final keyword = _query.trim().isEmpty ? 'AI 法律摘要' : _query.trim();
    final interactionId = 'assistant-${_slugFor(keyword)}';
    await appState.setArticleSaved(interactionId, true);
    _showSnack('📌 已將「$keyword」的 AI 釋義摘要儲存至您的法律摘錄本！');
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

  void _showVoiceSearchBottomSheet() {
    showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => const _SearchVoiceBottomSheet(),
    ).then((recognizedText) {
      if (recognizedText != null && recognizedText.isNotEmpty) {
        _submit(recognizedText);
      }
    });
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
    required this.aiIsThinking,
    required this.aiTone,
    required this.aiLength,
    required this.aiSummary,
    required this.onToneChanged,
    required this.onLengthChanged,
    required this.onNotebookSave,
    required this.onContinueChat,
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

  final bool aiIsThinking;
  final String aiTone;
  final String aiLength;
  final String aiSummary;
  final ValueChanged<String> onToneChanged;
  final ValueChanged<String> onLengthChanged;
  final VoidCallback onNotebookSave;
  final VoidCallback onContinueChat;

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
          _AssistantOverviewCard(
            query: query,
            summary: aiSummary.isNotEmpty ? aiSummary : assistantResult.summary,
            isThinking: aiIsThinking,
            tone: aiTone,
            length: aiLength,
            onToneChanged: onToneChanged,
            onLengthChanged: onLengthChanged,
            onNotebookSave: onNotebookSave,
            onContinueChat: onContinueChat,
          ),
          SizedBox(height: 14.h),
          _ResultSection(
            title: '法規',
            items: statutes.take(2).toList(),
            onOpen: onOpen,
            isSaved: isSaved,
            onSaved: onSaved,
          ),
          _ResultSection(
            title: '案件 / 判例',
            items: cases.take(3).toList(),
            onOpen: onOpen,
            isSaved: isSaved,
            onSaved: onSaved,
            isCarousel: true,
          ),
          _ResultSection(
            title: '生活避坑筆記',
            items: lifeNotes.take(3).toList(),
            onOpen: onOpen,
            isSaved: isSaved,
            onSaved: onSaved,
            isCarousel: true,
          ),
          _ResultSection(
            title: '官方資料',
            items: official.take(2).toList(),
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
        if (tab == _SearchTab.assistant) ...[
          _AssistantOverviewCard(
            query: query,
            summary: aiSummary.isNotEmpty ? aiSummary : assistantResult.summary,
            isThinking: aiIsThinking,
            tone: aiTone,
            length: aiLength,
            onToneChanged: onToneChanged,
            onLengthChanged: onLengthChanged,
            onNotebookSave: onNotebookSave,
            onContinueChat: onContinueChat,
          ),
          SizedBox(height: 14.h),
        ],
        if (visible.isEmpty && tab != _SearchTab.assistant)
          const _SearchStateCard(message: '這個分類目前沒有符合的結果。')
        else
          for (final item in visible.take(5)) ...[
            if (item.type != _ResultType.assistant) ...[
              _ResultTile(
                item: item,
                onTap: () => onOpen(item),
                showBookmark: item.type != _ResultType.official,
                isSaved: isSaved(item),
                onBookmark: () => onSaved(item),
              ),
              SizedBox(height: 10.h),
            ],
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
    required this.onNavigateResult,
    required this.onAskScenario,
  });

  final _SearchResult item;
  final bool isFollowed;
  final bool isSaved;
  final VoidCallback onFollow;
  final VoidCallback onSaved;
  final VoidCallback onAssistant;
  final ValueChanged<_SearchResult> onNavigateResult;
  final ValueChanged<String> onAskScenario;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<StatuteItem>>(
        future: StatuteRepository().fetchAllStatutes(),
        builder: (context, snapshot) {
          final statuteList = snapshot.data ?? [];
          StatuteItem? statute;
          for (final s in statuteList) {
            final key = 'statute-${s.codeName}-${s.articleNumber}';
            if (item.id == key ||
                item.title.contains(s.codeName) &&
                    item.title.contains(s.articleNumber)) {
              statute = s;
              break;
            }
          }

          final displayTitle = statute != null
              ? '${statute.codeName} ${statute.articleNumber}'
              : item.title;
          final displayText = statute?.articleText ?? item.summary;
          final displaySummary = statute?.plainLanguageSummary ?? '本條文之白話解析。';
          final displayCategory = statute?.category ?? '法律';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(displayTitle, style: _SearchText.heroSmall(context)),
              SizedBox(height: 4.h),
              Text('$displayCategory・施行中', style: _SearchText.caption(context)),
              SizedBox(height: 14.h),
              _TabStrip(labels: const ['條文內容', '白話解析']),
              SizedBox(height: 16.h),
              Text('條文本文', style: _SearchText.section(context)),
              SizedBox(height: 8.h),
              _ProtoCard(
                child:
                    Text(displayText, style: _SearchText.bodyStrong(context)),
              ),
              SizedBox(height: 14.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('白話解讀', style: _SearchText.section(context)),
                  _VoiceReader(text: displaySummary),
                ],
              ),
              SizedBox(height: 8.h),
              _ProtoCard(
                background: _SearchColors.softPaper,
                child: Text(displaySummary, style: _SearchText.body(context)),
              ),
              if (statute != null && statute.tags.isNotEmpty) ...[
                SizedBox(height: 14.h),
                Text('關聯標籤', style: _SearchText.section(context)),
                SizedBox(height: 10.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children:
                      statute.tags.map((tag) => _SmallTag(label: tag)).toList(),
                ),
              ],
              SizedBox(height: 16.h),
              _RelatedStatuteChips(
                statuteTitle: displayTitle,
                onNavigate: onNavigateResult,
              ),
              SizedBox(height: 16.h),
              _ScenarioFollowUps(
                title: displayTitle,
                onAsk: onAskScenario,
              ),
              SizedBox(height: 16.h),
              _ProtoCard(
                background: _SearchColors.mint,
                onTap: onAssistant,
                child: Row(
                  children: [
                    Icon(Icons.search_rounded,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF33A88D)
                            : _SearchColors.primary,
                        size: 18.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text('小法助問：${item.title}可以怎麼用？',
                          style: _SearchText.captionStrong(context)),
                    ),
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
        });
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
    required this.onAskScenario,
  });

  final _SearchResult item;
  final bool isFollowed;
  final bool isSaved;
  final VoidCallback onFollow;
  final VoidCallback onSaved;
  final VoidCallback onOpenFullText;
  final ValueChanged<String> onAskScenario;

  @override
  Widget build(BuildContext context) {
    final caseId = item.id.replaceFirst('case-', '');

    return FutureBuilder<LawCase?>(
        future: CaseRepository().getCaseDetail(caseId),
        builder: (context, snapshot) {
          final lawCase = snapshot.data;

          final displaySummary = lawCase?.summary ?? item.summary;
          final displaySubtitle = lawCase?.subtitle ?? item.source;
          final displayTitle = lawCase?.title ?? item.title;
          final happenedAt = lawCase?.happenedAt;
          final dateStr = happenedAt != null
              ? '${happenedAt.year}.${happenedAt.month.toString().padLeft(2, '0')}.${happenedAt.day.toString().padLeft(2, '0')}'
              : '近期';
          final caseNo =
              lawCase != null ? '（114）年民事小額第 321 號' : '109 年台上字第 123 號';
          final caseResult = lawCase?.status ?? '上訴駁回';
          final caseCategory = lawCase?.category ?? '刑事';

          final takeaway = lawCase?.oneSentenceTakeaway;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(displayTitle, style: _SearchText.heroSmall(context)),
              SizedBox(height: 10.h),
              _TabStrip(labels: const ['案件資訊', '相關資料']),
              SizedBox(height: 14.h),
              _ProtoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('判決要旨', style: _SearchText.section(context)),
                        _VoiceReader(text: displaySummary),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Text(displaySummary,
                        style: _SearchText.bodyStrong(context)),
                    if (takeaway != null) ...[
                      SizedBox(height: 12.h),
                      Text('核心要旨', style: _SearchText.section(context)),
                      SizedBox(height: 6.h),
                      Text(takeaway,
                          style: _SearchText.body(context).copyWith(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? const Color(0xFF33A88D)
                                  : _SearchColors.primary)),
                    ],
                    SizedBox(height: 12.h),
                    _CaseTimelineVisualizer(
                        caseId: caseId, title: displayTitle),
                    if (lawCase != null && lawCase.tags.isNotEmpty) ...[
                      SizedBox(height: 12.h),
                      Text('關鍵字', style: _SearchText.section(context)),
                      SizedBox(height: 8.h),
                      Wrap(
                        spacing: 6.w,
                        runSpacing: 6.h,
                        children: lawCase.tags
                            .map((tag) => _SmallTag(label: tag))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              _ScenarioFollowUps(
                title: displayTitle,
                onAsk: onAskScenario,
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
        });
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
    required this.onAskScenario,
  });

  final _SearchResult item;
  final bool isSaved;
  final VoidCallback onSaved;
  final ValueChanged<String> onAskScenario;

  @override
  Widget build(BuildContext context) {
    ArchiveUpdateItem? note;
    for (final update in archiveUpdateItems) {
      if (update.title == item.title || item.title.contains(update.title)) {
        note = update;
        break;
      }
    }

    final displayTitle = note?.title ?? item.title;
    final displaySummary = note?.summary ?? item.summary;
    final displayTime = note?.timeLabel ?? '近期';

    final List<String> checks = [];
    if (displayTitle.contains('租屋') || displaySummary.contains('租屋')) {
      checks.addAll([
        '點交拍照存證：退租點交時對每面牆與設備詳細拍照或錄影存證。',
        '確認折舊計算：民法折舊有一定公式，房東不得以自然折舊為由要求全額賠新。',
        '調解或申訴：若遭無理扣減押金，可向鄉鎮市區公所聲請調解或發函催告。',
      ]);
    } else if (displayTitle.contains('詐騙') || displaySummary.contains('詐騙')) {
      checks.addAll([
        '保留完整對話：截圖社群或網拍通訊軟體上的買賣溝通與合約紀錄。',
        '保存金流單據：將匯款單、網路轉帳成功明細等金流截圖列印或備份存檔。',
        '撥打 165 專線：第一時間透過警政署 165 反詐騙專線進行求證或完成報案。',
      ]);
    } else if (displayTitle.contains('退貨') ||
        displayTitle.contains('鑑賞期') ||
        displaySummary.contains('退貨') ||
        displaySummary.contains('鑑賞期')) {
      checks.addAll([
        '通知解除契約：七日內透過訊息或書面明確向賣家發出無條件退貨通知。',
        '保持商品原樣：妥善留存包裝、本體及贈品，切勿任意毀損或使用。',
        '向消保處申訴：賣家若刁難，可至行政院消保處進行線上消費申訴。',
      ]);
    } else {
      checks.addAll([
        '保留證據：完整留存與本案相關之契約、對話紀錄、交易單據及照片。',
        '事實釐清：以條列或心智圖形式將爭議事實、時序列表備忘，以利後續說明。',
        '調解管道：善用各地區調解委員會或消保中心提起低成本糾紛協商。',
      ]);
    }

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
                    Text(displayTitle, style: _SearchText.section(context)),
                    SizedBox(height: 8.h),
                    Text('10 分鐘閱讀・5 分鐘摘要・$displayTime 更新',
                        style: _SearchText.caption(context)),
                  ],
                ),
              ),
              SvgPicture.asset(_SearchAsset.clipboard,
                  width: 94.w, height: 94.w),
            ],
          ),
        ),
        SizedBox(height: 14.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('生活避坑錦囊', style: _SearchText.section(context)),
            _VoiceReader(text: checks.join(' ')),
          ],
        ),
        SizedBox(height: 10.h),
        for (final check in checks) ...[
          _CheckLine(text: check),
          SizedBox(height: 6.h),
        ],
        SizedBox(height: 16.h),
        _ScenarioFollowUps(
          title: displayTitle,
          onAsk: onAskScenario,
        ),
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
    this.onVoice,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;
  final bool showFilter;
  final VoidCallback? onFilter;
  final VoidCallback? onVoice;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(
          color: _SearchColors.primary.withValues(alpha: 0.28),
          width: 1.2.w,
        ),
        boxShadow: [
          BoxShadow(
            color: _SearchColors.primary.withValues(alpha: 0.08),
            blurRadius: 18.r,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onTapOutside: (event) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
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
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onVoice != null && controller.text.isEmpty)
                IconButton(
                  tooltip: '語音搜尋',
                  icon: Icon(
                    Icons.mic_rounded,
                    color: _SearchColors.primary,
                    size: 21.sp,
                  ),
                  onPressed: onVoice,
                ),
              if (showFilter)
                IconButton(
                  tooltip: '篩選',
                  icon: Icon(
                    Icons.tune_rounded,
                    color: _SearchColors.primary,
                    size: 21.sp,
                  ),
                  onPressed: onFilter,
                ),
              if (!showFilter && controller.text.isNotEmpty)
                IconButton(
                  tooltip: '清除搜尋',
                  icon: Icon(
                    Icons.close_rounded,
                    color: _SearchColors.mutedText,
                    size: 18.sp,
                  ),
                  onPressed: onClear,
                ),
            ],
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

class _SearchVoiceBottomSheet extends StatefulWidget {
  const _SearchVoiceBottomSheet();

  @override
  State<_SearchVoiceBottomSheet> createState() =>
      _SearchVoiceBottomSheetState();
}

class _SearchVoiceBottomSheetState extends State<_SearchVoiceBottomSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _waveController;
  String _statusText = '正在聆聽中...';
  String _recognizedText = '';
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // 模擬語音辨識過程：1.5秒後開始顯示辨識文字，3秒後自動送出
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() {
        _statusText = '語音辨識中...';
      });
      _simulateTyping('我買到瑕疵商品想要退貨，可以要求退款或賠償嗎？', 0);
    });
  }

  void _simulateTyping(String fullText, int index) {
    if (!mounted) return;
    if (index <= fullText.length) {
      setState(() {
        _recognizedText = fullText.substring(0, index);
      });
      Future.delayed(const Duration(milliseconds: 50), () {
        _simulateTyping(fullText, index + 1);
      });
    } else {
      setState(() {
        _isFinished = true;
        _statusText = '辨識完成！即時搜尋';
      });
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        Navigator.of(context).pop(fullText);
      });
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 40.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 46.w,
            height: 5.h,
            decoration: BoxDecoration(
              color: _SearchColors.border,
              borderRadius: BorderRadius.circular(999.r),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            _statusText,
            style: _SearchText.section().copyWith(color: _SearchColors.primary),
          ),
          SizedBox(height: 18.h),
          Container(
            height: 120.h,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _SearchColors.background,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(
                  color: _SearchColors.border.withValues(alpha: 0.5)),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: _recognizedText.isEmpty
                ? AnimatedBuilder(
                    animation: _waveController,
                    builder: (context, child) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          final value =
                              (_waveController.value + (index * 0.2)) % 1.0;
                          final height =
                              15.h + (45.h * (0.5 - (0.5 - value).abs()));
                          return Container(
                            width: 6.w,
                            height: height,
                            margin: EdgeInsets.symmetric(horizontal: 4.w),
                            decoration: BoxDecoration(
                              color: _SearchColors.primary
                                  .withValues(alpha: 0.2 + (0.8 * value)),
                              borderRadius: BorderRadius.circular(999.r),
                            ),
                          );
                        }),
                      );
                    },
                  )
                : Text(
                    _recognizedText,
                    textAlign: TextAlign.center,
                    style: _SearchText.heroSmall().copyWith(
                      color: _SearchColors.text,
                      height: 1.4,
                    ),
                  ),
          ),
          SizedBox(height: 28.h),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: _SearchColors.softPaper,
                borderRadius: BorderRadius.circular(999.r),
              ),
              child: Text(
                '取消',
                style: _SearchText.captionStrong()
                    .copyWith(color: _SearchColors.mutedText),
              ),
            ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        if (showBack) ...[
          _RoundIcon(icon: Icons.arrow_back_ios_new_rounded, onTap: onBack),
          SizedBox(width: 10.w),
        ],
        Expanded(
          child: Text(
            title,
            style: _SearchText.navTitle(context),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999.r),
      child: Container(
        width: 38.w,
        height: 38.w,
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF2C3545).withValues(alpha: 0.8)
              : Colors.white,
          shape: BoxShape.circle,
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4.r,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Icon(icon,
            color: isDark ? Colors.white : _SearchColors.text, size: 20.sp),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Adapt backgrounds for dark mode
    Color cardBg = background;
    if (cardBg == Colors.white) {
      cardBg = isDark ? const Color(0xFF1E2430) : Colors.white;
    } else if (cardBg == _SearchColors.softPaper) {
      cardBg = isDark ? const Color(0xFF282F3E) : _SearchColors.softPaper;
    } else if (cardBg == _SearchColors.mint) {
      cardBg = isDark ? const Color(0xFF1A3831) : _SearchColors.mint;
    }

    const radius = 14.0;
    final card = Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius.r),
        boxShadow: [
          BoxShadow(
            color: _getAdaptiveShadowColor(cardBg),
            blurRadius: 14.r,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius.r),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: double.infinity,
            padding: padding ?? EdgeInsets.all(13.w),
            decoration: BoxDecoration(
              color: cardBg.withValues(alpha: isDark ? 0.92 : 0.88),
              borderRadius: BorderRadius.circular(radius.r),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF2C3545).withValues(alpha: 0.5)
                    : _SearchColors.border.withValues(alpha: 0.35),
                width: 0.8.w,
              ),
            ),
            child: child,
          ),
        ),
      ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A3831) : _SearchColors.mint,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        label,
        style: _SearchText.captionStrong(context).copyWith(
          color: isDark ? const Color(0xFF33A88D) : _SearchColors.text,
        ),
      ),
    );
  }
}

class _CheckLine extends StatelessWidget {
  const _CheckLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.only(bottom: 7.h),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded,
              color: isDark ? const Color(0xFF33A88D) : _SearchColors.primary,
              size: 16.sp),
          SizedBox(width: 8.w),
          Expanded(child: Text(text, style: _SearchText.bodyStrong(context))),
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
          Text('• ', style: _SearchText.bodyStrong(context)),
          Expanded(child: Text(text, style: _SearchText.bodyStrong(context))),
        ],
      ),
    );
  }
}

// ==========================================
// NEW PREMIUM INTERACTIVE WIDGETS
// ==========================================

class _ScenarioFollowUps extends StatelessWidget {
  const _ScenarioFollowUps({required this.title, required this.onAsk});
  final String title;
  final ValueChanged<String> onAsk;

  @override
  Widget build(BuildContext context) {
    final List<String> questions = [];
    if (title.contains('消保') || title.contains('19') || title.contains('鑑賞期')) {
      questions.addAll([
        '個人二手賣家也適用嗎？',
        '如果是客製化商品還能退嗎？',
        '商品拆封後還能主張鑑賞期退貨嗎？',
      ]);
    } else if (title.contains('詐') || title.contains('339')) {
      questions.addAll([
        '遊戲點數詐騙怎麼要回錢？',
        '被騙走的身分證件怎麼預防被盜用？',
        '借錢不還算不算詐欺罪？',
      ]);
    } else if (title.contains('租') ||
        title.contains('房') ||
        title.contains('421')) {
      questions.addAll([
        '退租時房東無理扣押金怎麼辦？',
        '房屋漏水房東不修我可以少繳房租嗎？',
        '租約沒到期提早搬走會扣多少違約金？',
      ]);
    } else {
      questions.addAll([
        '這個條款在訴訟上怎麼舉證？',
        '如果遇到糾紛該去哪裡聲請調解？',
        '有免費的法律諮詢管道嗎？',
      ]);
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? const Color(0xFF33A88D) : _SearchColors.primary;
    final chipBg = isDark ? const Color(0xFF1A3831) : _SearchColors.mint;
    final textColor = isDark ? const Color(0xFF33A88D) : _SearchColors.text;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.assistant_rounded, color: primaryColor, size: 16.sp),
            SizedBox(width: 6.w),
            Text('小法助推薦情境追問', style: _SearchText.captionStrong(context)),
          ],
        ),
        SizedBox(height: 8.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: questions.map((q) {
              return Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: InkWell(
                  onTap: () => onAsk(q),
                  borderRadius: BorderRadius.circular(999.r),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
                    decoration: BoxDecoration(
                      color: chipBg.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(999.r),
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.25),
                        width: 0.6.w,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(q,
                            style: _SearchText.captionStrong(context)
                                .copyWith(color: textColor, fontSize: 10.5.sp)),
                        SizedBox(width: 4.w),
                        Icon(Icons.arrow_forward_rounded,
                            color: primaryColor, size: 10.sp),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _WaveformPlayer extends StatefulWidget {
  const _WaveformPlayer({required this.isPlaying});
  final bool isPlaying;

  @override
  State<_WaveformPlayer> createState() => _WaveformPlayerState();
}

class _WaveformPlayerState extends State<_WaveformPlayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<double> _baseHeights = [0.2, 0.5, 0.8, 0.4, 0.7, 0.3, 0.6, 0.2];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.isPlaying) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _WaveformPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final barColor = isDark ? const Color(0xFF33A88D) : _SearchColors.primary;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_baseHeights.length, (index) {
            double value = _baseHeights[index];
            if (widget.isPlaying) {
              final phase = (index / _baseHeights.length) * 2 * math.pi;
              value = (value +
                      0.3 *
                          (0.5 +
                              0.5 *
                                  (math.sin(_controller.value * 2 * math.pi +
                                      phase))))
                  .clamp(0.1, 1.0);
            }
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 1.5.w),
              width: 3.w,
              height: (16.h * value).clamp(3.h, 16.h),
              decoration: BoxDecoration(
                color: barColor.withValues(alpha: widget.isPlaying ? 1.0 : 0.4),
                borderRadius: BorderRadius.circular(1.5.r),
              ),
            );
          }),
        );
      },
    );
  }
}

class _VoiceReader extends StatefulWidget {
  const _VoiceReader({required this.text});
  final String text;

  @override
  State<_VoiceReader> createState() => _VoiceReaderState();
}

class _VoiceReaderState extends State<_VoiceReader> {
  bool _isPlaying = false;
  int _secondsElapsed = 0;
  final int _totalSeconds = 25;
  Timer? _timer;

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsElapsed < _totalSeconds) {
          _secondsElapsed++;
        } else {
          _isPlaying = false;
          _secondsElapsed = 0;
          _timer?.cancel();
        }
      });
    });
  }

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _startTimer();
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? const Color(0xFF33A88D) : _SearchColors.primary;

    final String elapsedStr =
        '00:${_secondsElapsed.toString().padLeft(2, '0')}';
    final String totalStr = '00:$_totalSeconds';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141922) : const Color(0xFFFAF7F2),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: isDark
              ? const Color(0xFF2C3545).withValues(alpha: 0.5)
              : _SearchColors.border.withValues(alpha: 0.3),
          width: 0.6.w,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: _togglePlay,
            borderRadius: BorderRadius.circular(999.r),
            child: Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: primaryColor,
                size: 14.sp,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Text('$elapsedStr / $totalStr', style: _SearchText.caption(context)),
          SizedBox(width: 8.w),
          _WaveformPlayer(isPlaying: _isPlaying),
        ],
      ),
    );
  }
}

class _CaseTimelineVisualizer extends StatelessWidget {
  const _CaseTimelineVisualizer({required this.caseId, required this.title});
  final String caseId;
  final String title;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? const Color(0xFF33A88D) : _SearchColors.primary;
    final dotColor = isDark ? const Color(0xFF33A88D) : _SearchColors.primary;
    final lineColor = isDark ? const Color(0xFF2C3545) : _SearchColors.border;

    final List<_TimelineEvent> events = [];
    if (caseId.contains('2') || title.contains('租') || title.contains('押金')) {
      events.addAll([
        _TimelineEvent('2025.03.15', '簽訂契約', '起租並給付押金二個月。'),
        _TimelineEvent('2026.03.14', '約滿點交', '租約到期房屋點交，房東主張自然折舊扣押金。'),
        _TimelineEvent('2026.04.10', '調解不成立', '向公所聲請調解，房東執意扣除清潔與油漆費，協商破局。'),
        _TimelineEvent('2026.06.15', '法院宣判', '小額判決認定自然折舊應由房東負擔，判決房東全額返還押金。'),
      ]);
    } else if (caseId.contains('1') || title.contains('詐')) {
      events.addAll([
        _TimelineEvent('2025.02.10', '三方詐騙成立', '買家匯款至被害賣家，詐騙人拿走商品。'),
        _TimelineEvent('2025.02.12', '警示帳戶凍結', '金流遭警示鎖定，賣家名下所有帳戶無法提款。'),
        _TimelineEvent('2025.08.12', '檢察官不起訴', '查明三方詐騙始末，賣家無詐欺故意，不起訴處分確定。'),
        _TimelineEvent('2026.02.18', '免賠定讞', '民事庭判決賣家無侵權責任，無須賠償被害買家，返還定讞。'),
      ]);
    } else {
      events.addAll([
        _TimelineEvent('2025.10.15', '商品到貨', '網路下單通訊交易收到商品，開箱點收。'),
        _TimelineEvent('2025.10.18', '主張解除契約', '7 日內書面通知退貨，賣家以「已拆封」為由拒退。'),
        _TimelineEvent('2025.11.05', '消保官申訴', '向行政院消保處進行線上申訴，消保官發函要求賣家說明。'),
        _TimelineEvent('2026.01.12', '調解成立', '召開調解會議，賣家同意收回商品並全額退款。'),
      ]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.timeline_rounded, color: primaryColor, size: 16.sp),
            SizedBox(width: 6.w),
            Text('裁判時序時間軸 (Timeline)',
                style: _SearchText.captionStrong(context)),
          ],
        ),
        SizedBox(height: 12.h),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final e = events[index];
            final isLast = index == events.length - 1;
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: BoxDecoration(
                          color: dotColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 1.5.w,
                            color: lineColor,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(e.date,
                                  style: _SearchText.captionStrong(context)
                                      .copyWith(
                                          color: primaryColor,
                                          fontSize: 10.sp)),
                              SizedBox(width: 8.w),
                              Text(e.title,
                                  style: _SearchText.bodyStrong(context)),
                            ],
                          ),
                          SizedBox(height: 3.h),
                          Text(e.desc, style: _SearchText.body(context)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _TimelineEvent {
  const _TimelineEvent(this.date, this.title, this.desc);
  final String date;
  final String title;
  final String desc;
}

class _RelatedStatuteChips extends StatelessWidget {
  const _RelatedStatuteChips(
      {required this.statuteTitle, required this.onNavigate});
  final String statuteTitle;
  final ValueChanged<_SearchResult> onNavigate;

  @override
  Widget build(BuildContext context) {
    final List<_RelatedStatuteInfo> list = [];
    if (statuteTitle.contains('消費者保護法') &&
        statuteTitle.contains('19') &&
        !statuteTitle.contains('19之2')) {
      list.addAll([
        _RelatedStatuteInfo(
            '民法第 259 條', '契約解除時雙方回復原狀義務之細節規範。', 'statute-民法-259'),
        _RelatedStatuteInfo(
            '消保法第 19 條之 2', '通訊交易退款程序與期限之施行細則。', 'statute-消費者保護法-19之2'),
      ]);
    } else if (statuteTitle.contains('19之2')) {
      list.addAll([
        _RelatedStatuteInfo(
            '消保法第 19 條', '通訊交易 7 天無條件解除契約之本權利。', 'statute-消費者保護法-19'),
        _RelatedStatuteInfo(
            '民法第 259 條', '契約解除時雙方回復原狀義務之細節規範。', 'statute-民法-259'),
      ]);
    } else if (statuteTitle.contains('民法') && statuteTitle.contains('259')) {
      list.addAll([
        _RelatedStatuteInfo(
            '消保法第 19 條', '通訊交易 7 天無條件解除契約之本權利。', 'statute-消費者保護法-19'),
        _RelatedStatuteInfo(
            '民法第 260 條', '解除契約妨礙損害賠償請求權之適用界限。', 'statute-民法-260'),
      ]);
    } else if (statuteTitle.contains('刑法') && statuteTitle.contains('339')) {
      list.addAll([
        _RelatedStatuteInfo(
            '民法第 184 條', '因故意或過失不法侵害他人權利之侵權行為損害賠償義務。', 'statute-民法-184'),
        _RelatedStatuteInfo(
            '民法第 179 條', '無法律上原因受有利益致他人受損之不當得利返還義務。', 'statute-民法-179'),
      ]);
    } else if (statuteTitle.contains('民法') && statuteTitle.contains('421')) {
      list.addAll([
        _RelatedStatuteInfo(
            '民法第 440 條', '承租人租金支付遲延時，出租人終止契約之限制。', 'statute-民法-440'),
        _RelatedStatuteInfo(
            '民法第 429 條', '租賃物修繕義務之歸屬與費用負擔之預設規定。', 'statute-民法-429'),
      ]);
    } else {
      list.addAll([
        _RelatedStatuteInfo(
            '民法第 184 條', '一般侵權行為之基本損害賠償請求權依據。', 'statute-民法-184'),
        _RelatedStatuteInfo('民法第 179 條', '一般不當得利之返還請求權依據。', 'statute-民法-179'),
      ]);
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? const Color(0xFF33A88D) : _SearchColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.alt_route_rounded, color: primaryColor, size: 16.sp),
            SizedBox(width: 6.w),
            Text('關聯互補條文推薦 (Links)', style: _SearchText.captionStrong(context)),
          ],
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: list.map((info) {
            return InkWell(
              onTap: () {
                onNavigate(_SearchResult(
                  type: _ResultType.statute,
                  title: info.title,
                  summary: info.summary,
                  source: '法規詳情・施行中',
                  query: info.title.replaceAll(' ', ''),
                  id: info.id,
                ));
              },
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E2430) : Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF2C3545)
                        : _SearchColors.border.withValues(alpha: 0.6),
                    width: 0.6.w,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.link_rounded, color: primaryColor, size: 12.sp),
                    SizedBox(width: 4.w),
                    Text(info.title,
                        style: _SearchText.captionStrong(context)
                            .copyWith(fontSize: 11.sp)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _RelatedStatuteInfo {
  const _RelatedStatuteInfo(this.title, this.summary, this.id);
  final String title;
  final String summary;
  final String id;
}

class _IconBox extends StatelessWidget {
  const _IconBox({
    this.icon,
    required this.color,
    this.svgAsset,
  });

  final IconData? icon;
  final Color color;
  final String? svgAsset;

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (svgAsset != null) {
      child = Padding(
        padding: EdgeInsets.all(10.w),
        child: SvgPicture.asset(
          svgAsset!,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          fit: BoxFit.contain,
        ),
      );
    } else {
      child = Icon(icon ?? Icons.help_outline, color: color, size: 22.sp);
    }

    return Container(
      width: 42.w,
      height: 42.w,
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(12.r)),
      alignment: Alignment.center,
      child: child,
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryBg = isDark ? const Color(0xFF33A88D) : _SearchColors.primary;
    return SizedBox(
      width: double.infinity,
      height: 46.h,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: primaryBg,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? const Color(0xFF33A88D) : _SearchColors.primary;
    final borderColor = isDark ? const Color(0xFF2C3545) : _SearchColors.border;
    return SizedBox(
      width: double.infinity,
      height: 42.h,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: borderColor),
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
    this.destination = '',
    this.id = '',
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
      destination: item.destination,
      id: item.id,
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
  final String destination;
  final String id;

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
  if (item.id.isNotEmpty) return item.id;
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
  static Color _textColor(BuildContext? context) {
    if (context == null) return _SearchColors.text;
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFE5E9E6)
        : _SearchColors.text;
  }

  static Color _mutedTextColor(BuildContext? context) {
    if (context == null) return _SearchColors.mutedText;
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFA4B2AB)
        : _SearchColors.mutedText;
  }

  static Color _primaryColor(BuildContext? context) {
    if (context == null) return _SearchColors.primary;
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF33A88D)
        : _SearchColors.primary;
  }

  static TextStyle hero([BuildContext? context]) => TextStyle(
      color: _primaryColor(context),
      fontSize: 28.sp,
      fontWeight: FontWeight.w900,
      height: 1.05);
  static TextStyle heroSmall([BuildContext? context]) => TextStyle(
      color: _textColor(context),
      fontSize: 20.sp,
      fontWeight: FontWeight.w900,
      height: 1.22);
  static TextStyle navTitle([BuildContext? context]) => TextStyle(
      color: _textColor(context), fontSize: 19.sp, fontWeight: FontWeight.w900);
  static TextStyle section([BuildContext? context]) => TextStyle(
      color: _textColor(context),
      fontSize: 16.sp,
      fontWeight: FontWeight.w900,
      height: 1.3);
  static TextStyle tileTitle([BuildContext? context]) => TextStyle(
      color: _textColor(context),
      fontSize: 13.sp,
      fontWeight: FontWeight.w900,
      height: 1.3);
  static TextStyle bodyStrong([BuildContext? context]) => TextStyle(
      color: _textColor(context),
      fontSize: 12.sp,
      fontWeight: FontWeight.w700,
      height: 1.55);
  static TextStyle body([BuildContext? context]) => TextStyle(
      color: _mutedTextColor(context),
      fontSize: 12.sp,
      fontWeight: FontWeight.w600,
      height: 1.45);
  static TextStyle caption([BuildContext? context]) => TextStyle(
      color: _mutedTextColor(context),
      fontSize: 10.8.sp,
      fontWeight: FontWeight.w600,
      height: 1.3);
  static TextStyle captionStrong([BuildContext? context]) => TextStyle(
      color: _textColor(context),
      fontSize: 11.sp,
      fontWeight: FontWeight.w900,
      height: 1.25);
  static TextStyle tab([BuildContext? context]) => TextStyle(
      color: _textColor(context),
      fontSize: 13.sp,
      fontWeight: FontWeight.w900,
      height: 1.2);
  static TextStyle action([BuildContext? context]) => TextStyle(
      color: _primaryColor(context),
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
