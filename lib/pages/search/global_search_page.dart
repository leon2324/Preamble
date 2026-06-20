import 'dart:math' as math;
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
      } else if (query.contains('瑕疵') || query.contains('退貨') || query.contains('消費')) {
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
          controller: _controller,
          onVoice: _showVoiceSearchBottomSheet,
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

class _MascotFloatingWrapper extends StatefulWidget {
  const _MascotFloatingWrapper({required this.child});
  final Widget child;

  @override
  State<_MascotFloatingWrapper> createState() => _MascotFloatingWrapperState();
}

class _MascotFloatingWrapperState extends State<_MascotFloatingWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final offset = math.sin(_controller.value * 2 * math.pi) * 4.h;
        return Transform.translate(
          offset: Offset(0, offset),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SpeechBubblePainter extends CustomPainter {
  const _SpeechBubblePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final double radius = 12.r;
    final double arrowWidth = 8.w;
    final double arrowHeight = 10.h;

    // Body of the bubble, starting after the arrow on the left
    path.moveTo(arrowWidth + radius, 0);
    path.lineTo(size.width - radius, 0);
    path.arcToPoint(Offset(size.width, radius), radius: Radius.circular(radius));
    path.lineTo(size.width, size.height - radius);
    path.arcToPoint(Offset(size.width - radius, size.height), radius: Radius.circular(radius));
    path.lineTo(arrowWidth + radius, size.height);
    path.arcToPoint(Offset(arrowWidth, size.height - radius), radius: Radius.circular(radius));

    // Draw the left-pointing arrow centered vertically
    final double arrowCenterY = size.height / 2;
    path.lineTo(arrowWidth, arrowCenterY + arrowHeight / 2);
    path.lineTo(0, arrowCenterY);
    path.lineTo(arrowWidth, arrowCenterY - arrowHeight / 2);

    path.lineTo(arrowWidth, radius);
    path.arcToPoint(Offset(arrowWidth + radius, 0), radius: Radius.circular(radius));
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SpeechBubblePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _AssistantSpeechBubble extends StatelessWidget {
  const _AssistantSpeechBubble({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SpeechBubblePainter(color: const Color(0xFFE8F1EC)),
      child: Container(
        padding: EdgeInsets.fromLTRB(16.w + 8.w, 12.h, 16.w, 12.h),
        child: Text(
          text,
          style: _SearchText.body().copyWith(
            color: const Color(0xFF2E5E4E),
            fontSize: 12.5.sp,
            height: 1.45,
          ),
        ),
      ),
    );
  }
}

class _AssistantQuotaCapsule extends StatelessWidget {
  const _AssistantQuotaCapsule({required this.quotaText, this.onTap});
  final String quotaText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: _SearchColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(color: _SearchColors.primary.withValues(alpha: 0.18)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 5.w,
              height: 5.w,
              decoration: const BoxDecoration(
                color: _SearchColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 6.w),
            Text(
              quotaText,
              style: _SearchText.caption().copyWith(
                color: _SearchColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 10.sp,
              ),
            ),
            SizedBox(width: 4.w),
            Icon(
              Icons.chevron_right_rounded,
              size: 11.sp,
              color: _SearchColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _HorizontalRecentFootprints extends StatelessWidget {
  const _HorizontalRecentFootprints({required this.recent, required this.onQuery});
  final List<String> recent;
  final ValueChanged<String> onQuery;

  @override
  Widget build(BuildContext context) {
    if (recent.isEmpty) return const SizedBox.shrink();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      clipBehavior: Clip.none,
      child: Row(
        children: recent.map((query) {
          return Container(
            margin: EdgeInsets.only(right: 8.w),
            child: ActionChip(
              avatar: Icon(Icons.history_rounded, size: 12.sp, color: _SearchColors.mutedText),
              label: Text(query),
              onPressed: () => onQuery(query),
              backgroundColor: Colors.white,
              side: const BorderSide(color: _SearchColors.border),
              visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999.r)),
              labelStyle: _SearchText.caption().copyWith(color: _SearchColors.text),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _InspirationItem {
  const _InspirationItem(this.query, this.subtitle, this.gradient, this.textColor, this.icon);
  final String query;
  final String subtitle;
  final List<Color> gradient;
  final Color textColor;
  final IconData icon;

  String get title => query;
}

class _InspirationCarousel extends StatelessWidget {
  const _InspirationCarousel({required this.onQuery});
  final ValueChanged<String> onQuery;

  @override
  Widget build(BuildContext context) {
    final inspirations = [
      _InspirationItem(
        '租屋押金扣款',
        '退租時房東扣減押金該如何爭取？',
        const [Color(0xFFE8F1EC), Color(0xFFD6E6DE)],
        const Color(0xFF2E5E4E),
        Icons.home_work_outlined,
      ),
      _InspirationItem(
        '車禍折舊估算',
        '車損維修零件折舊的法律計算公式？',
        const [Color(0xFFF7EFE5), Color(0xFFECDDC5)],
        const Color(0xFF7A583A),
        Icons.directions_car_filled_outlined,
      ),
      _InspirationItem(
        '網購7天鑑賞期',
        '消保法鑑賞期適用範圍與退貨規定。',
        const [Color(0xFFECF0F7), Color(0xFFD3DFEF)],
        const Color(0xFF38527A),
        Icons.shopping_bag_outlined,
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      clipBehavior: Clip.none,
      child: Row(
        children: inspirations.map((item) {
          return Container(
            width: 220.w,
            margin: EdgeInsets.only(right: 12.w),
            child: _InteractiveCard(
              onTap: () => onQuery(item.query),
              background: Colors.transparent,
              borderColor: item.textColor.withValues(alpha: 0.15),
              padding: EdgeInsets.zero,
              width: null,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: item.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(item.icon, color: item.textColor, size: 16.sp),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            item.title,
                            style: _SearchText.captionStrong().copyWith(
                              color: item.textColor,
                              fontSize: 12.sp,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      item.subtitle,
                      style: _SearchText.caption().copyWith(
                        color: item.textColor.withValues(alpha: 0.8),
                        fontSize: 10.5.sp,
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
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
    required this.controller,
    required this.onVoice,
  });

  final List<String> recent;
  final ValueChanged<String> onQuery;
  final VoidCallback onAssistant;
  final VoidCallback onStatutes;
  final VoidCallback onCases;
  final VoidCallback onOfficial;
  final VoidCallback onClearRecent;
  final TextEditingController controller;
  final VoidCallback onVoice;

  @override
  Widget build(BuildContext context) {
    final appState = LawAppScope.of(context);
    final quick = [
      _QuickAction('AI小法助', Icons.support_agent_rounded, onAssistant),
      _QuickAction('法規速查', Icons.menu_book_outlined, onStatutes),
      _QuickAction('判例檢索', Icons.description_outlined, onCases),
      _QuickAction('官方資料', Icons.verified_outlined, onOfficial),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. 吉祥物互動迎賓區 (呼吸浮動動畫與對話氣泡)
        SizedBox(height: 12.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _MascotFloatingWrapper(
              child: Image.asset(
                'assets/images/assistant/law_assistant_home.png',
                width: 78.w,
                height: 84.h,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(width: 8.w),
            const Expanded(
              child: _AssistantSpeechBubble(
                text: '嗨！我是小法助。今天想聊點什麼？我已為您接通了法規庫、裁判書與生活避坑指南，隨時為您分析！',
              ),
            ),
          ],
        ),
        SizedBox(height: 22.h),

        // 2. 聚光燈搜尋欄
        _SearchField(
          controller: controller,
          onSubmitted: onQuery,
          onClear: () => controller.clear(),
          onVoice: onVoice,
        ),
        SizedBox(height: 12.h),

        // 3. 提問額度小膠囊
        Center(
          child: _AssistantQuotaCapsule(
            quotaText: '今日 AI 提問剩餘：${appState.remainingAiQuota} / ${appState.accessTier.defaultDailyAiQuota} 次',
            onTap: () {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(content: Text('已為您開啟升級 PRO 特惠方案！')),
                );
            },
          ),
        ),
        SizedBox(height: 26.h),

        // 4. 歷史足跡標籤 (最近搜尋晶片列)
        if (recent.isNotEmpty) ...[
          _SectionHeader(
            title: '最近搜尋',
            action: '清除歷史',
            onAction: onClearRecent,
          ),
          SizedBox(height: 8.h),
          _HorizontalRecentFootprints(recent: recent, onQuery: onQuery),
          SizedBox(height: 22.h),
        ],

        // 5. 法律探索靈感 (橫向漸層卡片)
        const _SectionHeader(title: '🔥 法律探索靈感'),
        SizedBox(height: 10.h),
        _InspirationCarousel(onQuery: onQuery),
        SizedBox(height: 22.h),

        // 6. 快捷導航按鈕列 (扁平微晶片)
        const _SectionHeader(title: '🧭 快捷助理導航'),
        SizedBox(height: 10.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          clipBehavior: Clip.none,
          child: Row(
            children: quick.map((action) {
              return Container(
                margin: EdgeInsets.only(right: 8.w),
                child: _InteractiveCard(
                  onTap: action.onTap,
                  background: Colors.white,
                  borderColor: _SearchColors.border.withValues(alpha: 0.6),
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                  width: null,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(action.icon, color: _SearchColors.primary, size: 14.sp),
                      SizedBox(width: 6.w),
                      Text(
                        action.label,
                        style: _SearchText.captionStrong().copyWith(
                          fontSize: 11.sp,
                          color: _SearchColors.text,
                        ),
                      ),
                    ],
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

class _ResultSection extends StatelessWidget {
  const _ResultSection({
    required this.title,
    required this.items,
    required this.onOpen,
    required this.isSaved,
    required this.onSaved,
    this.isCarousel = false,
  });

  final String title;
  final List<_SearchResult> items;
  final ValueChanged<_SearchResult> onOpen;
  final bool Function(_SearchResult item) isSaved;
  final ValueChanged<_SearchResult> onSaved;
  final bool isCarousel;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    Widget itemsContent;
    if (isCarousel) {
      itemsContent = SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        clipBehavior: Clip.none,
        child: Row(
          children: items.map((item) {
            return _ResultTile(
              item: item,
              onTap: () => onOpen(item),
              showBookmark: item.type != _ResultType.official,
              isSaved: isSaved(item),
              onBookmark: () => onSaved(item),
              isCarouselCard: true,
            );
          }).toList(),
        ),
      );
    } else {
      itemsContent = Column(
        mainAxisSize: MainAxisSize.min,
        children: items.map((item) {
          return Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: _ResultTile(
              item: item,
              onTap: () => onOpen(item),
              showBookmark: item.type != _ResultType.official,
              isSaved: isSaved(item),
              onBookmark: () => onSaved(item),
            ),
          );
        }).toList(),
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _SectionHeader(title: title),
          SizedBox(height: 8.h),
          itemsContent,
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
  State<_SearchVoiceBottomSheet> createState() => _SearchVoiceBottomSheetState();
}

class _SearchVoiceBottomSheetState extends State<_SearchVoiceBottomSheet> with SingleTickerProviderStateMixin {
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
              border: Border.all(color: _SearchColors.border.withValues(alpha: 0.5)),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: _recognizedText.isEmpty
                ? AnimatedBuilder(
                    animation: _waveController,
                    builder: (context, child) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          final value = (_waveController.value + (index * 0.2)) % 1.0;
                          final height = 15.h + (45.h * (0.5 - (0.5 - value).abs()));
                          return Container(
                            width: 6.w,
                            height: height,
                            margin: EdgeInsets.symmetric(horizontal: 4.w),
                            decoration: BoxDecoration(
                              color: _SearchColors.primary.withValues(alpha: 0.2 + (0.8 * value)),
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
                style: _SearchText.captionStrong().copyWith(color: _SearchColors.mutedText),
              ),
            ),
          ),
        ],
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

class _AssistantThinkingIndicator extends StatefulWidget {
  const _AssistantThinkingIndicator();

  @override
  State<_AssistantThinkingIndicator> createState() => _AssistantThinkingIndicatorState();
}

class _AssistantThinkingIndicatorState extends State<_AssistantThinkingIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final delay = index * 0.2;
            final val = (_controller.value + delay) % 1.0;
            final scale = 0.6 + 0.4 * (0.5 - (0.5 - val).abs());
            return Transform.scale(
              scale: scale,
              child: Container(
                width: 9.w,
                height: 9.w,
                margin: EdgeInsets.symmetric(horizontal: 3.w),
                decoration: const BoxDecoration(
                  color: _SearchColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class TypewriterText extends StatefulWidget {
  const TypewriterText({
    super.key,
    required this.text,
    this.speed = const Duration(milliseconds: 15),
  });

  final String text;
  final Duration speed;

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  String _displayedText = '';
  int _currentIndex = 0;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  @override
  void didUpdateWidget(TypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _startTyping();
    }
  }

  void _startTyping() {
    setState(() {
      _displayedText = '';
      _currentIndex = 0;
      _isTyping = true;
    });
    _type();
  }

  void _type() {
    if (!mounted || !_isTyping) return;
    if (_currentIndex < widget.text.length) {
      setState(() {
        _currentIndex++;
        _displayedText = widget.text.substring(0, _currentIndex);
      });
      Future.delayed(widget.speed, _type);
    } else {
      setState(() {
        _isTyping = false;
      });
    }
  }

  @override
  void dispose() {
    _isTyping = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayedText,
      style: _SearchText.bodyStrong().copyWith(
        height: 1.6,
        color: _SearchColors.text,
      ),
    );
  }
}

class _AssistantOverviewCard extends StatelessWidget {
  const _AssistantOverviewCard({
    required this.query,
    required this.summary,
    required this.isThinking,
    required this.tone,
    required this.length,
    required this.onToneChanged,
    required this.onLengthChanged,
    required this.onNotebookSave,
    required this.onContinueChat,
  });

  final String query;
  final String summary;
  final bool isThinking;
  final String tone;
  final String length;
  final ValueChanged<String> onToneChanged;
  final ValueChanged<String> onLengthChanged;
  final VoidCallback onNotebookSave;
  final VoidCallback onContinueChat;

  @override
  Widget build(BuildContext context) {
    return _ProtoCard(
      background: _SearchColors.softMint,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: const BoxDecoration(
                  color: _SearchColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.support_agent_rounded, color: Colors.white, size: 16.sp),
              ),
              SizedBox(width: 8.w),
              Text(
                '小法助 AI 法律整理',
                style: _SearchText.section().copyWith(color: _SearchColors.primary),
              ),
              const Spacer(),
              if (isThinking)
                const _AssistantThinkingIndicator()
              else
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _SearchColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    '已生成',
                    style: _SearchText.caption().copyWith(
                      color: _SearchColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 14.h),
          Divider(color: _SearchColors.border.withValues(alpha: 0.5), height: 1),
          SizedBox(height: 14.h),
          if (isThinking)
            Container(
              height: 100.h,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const _AssistantThinkingIndicator(),
                  SizedBox(height: 12.h),
                  Text(
                    '正在彙整法律重點與實務裁判...',
                    style: _SearchText.caption().copyWith(color: _SearchColors.mutedText),
                  ),
                ],
              ),
            )
          else ...[
            TypewriterText(text: summary),
            SizedBox(height: 14.h),
            _AssistantCitationsRow(query: query),
            SizedBox(height: 16.h),
            Row(
              children: [
                Text('回答風格：', style: _SearchText.caption().copyWith(fontWeight: FontWeight.bold)),
                _StyleChip(
                  label: '白話',
                  selected: tone == '白話',
                  onTap: () => onToneChanged('白話'),
                ),
                SizedBox(width: 6.w),
                _StyleChip(
                  label: '專業',
                  selected: tone == '專業',
                  onTap: () => onToneChanged('專業'),
                ),
                SizedBox(width: 12.w),
                Text('大綱長度：', style: _SearchText.caption().copyWith(fontWeight: FontWeight.bold)),
                _StyleChip(
                  label: '精簡',
                  selected: length == '精簡',
                  onTap: () => onLengthChanged('精簡'),
                ),
                SizedBox(width: 6.w),
                _StyleChip(
                  label: '詳細',
                  selected: length == '詳細',
                  onTap: () => onLengthChanged('詳細'),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _SearchColors.primary,
                      side: const BorderSide(color: _SearchColors.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                    ),
                    icon: Icon(Icons.bookmark_add_outlined, size: 16.sp),
                    label: Text('📌 摘錄筆記', style: _SearchText.captionStrong()),
                    onPressed: onNotebookSave,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: _SearchColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                    ),
                    icon: Icon(Icons.forum_outlined, size: 16.sp),
                    label: Text('💬 繼續聊聊', style: _SearchText.captionStrong().copyWith(color: Colors.white)),
                    onPressed: onContinueChat,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _AssistantCitationsRow extends StatelessWidget {
  const _AssistantCitationsRow({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    // 依據搜尋詞動態決定引用來源
    final List<Map<String, String>> citations = [];
    if (query.contains('詐欺')) {
      citations.addAll([
        {'id': '[1]', 'title': '刑法第 339 條 (普通詐欺罪)', 'tag': '法規'},
        {'id': '[2]', 'title': '最高法院 109 年台上字第 123 號判決', 'tag': '判例'},
        {'id': '[3]', 'title': '警政署 165 全民防騙網', 'tag': '官方'},
      ]);
    } else if (query.contains('瑕疵') || query.contains('退貨') || query.contains('消費')) {
      citations.addAll([
        {'id': '[1]', 'title': '消保法第 19 條 (鑑賞期退貨)', 'tag': '法規'},
        {'id': '[2]', 'title': '民法第 354 條 (物之瑕疵擔保)', 'tag': '法規'},
        {'id': '[3]', 'title': '行政院消保處 消費申訴指南', 'tag': '官方'},
      ]);
    } else {
      citations.addAll([
        {'id': '[1]', 'title': '民法第 184 條 (獨立侵權責任)', 'tag': '法規'},
        {'id': '[2]', 'title': '司法院法規檢索系統', 'tag': '官方'},
      ]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.library_books_outlined, size: 12.sp, color: _SearchColors.primary),
            SizedBox(width: 4.w),
            Text(
              '參考資料引用來源',
              style: _SearchText.captionStrong().copyWith(
                color: _SearchColors.primary,
                fontSize: 10.sp,
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: citations.map((citation) {
              return Container(
                margin: EdgeInsets.only(right: 8.w),
                child: ActionChip(
                  avatar: Text(
                    citation['id']!,
                    style: TextStyle(
                      color: _SearchColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 9.sp,
                    ),
                  ),
                  label: Text(citation['title']!),
                  onPressed: () {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          behavior: SnackBarBehavior.floating,
                          content: Text('已為您定位引用來源：${citation['title']} (${citation['tag']})'),
                        ),
                      );
                  },
                  backgroundColor: Colors.white.withValues(alpha: 0.6),
                  side: const BorderSide(color: _SearchColors.border),
                  visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                  labelStyle: _SearchText.caption().copyWith(
                    color: _SearchColors.text,
                    fontSize: 9.5.sp,
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

class _StyleChip extends StatelessWidget {
  const _StyleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: selected ? _SearchColors.primary : Colors.white,
          border: Border.all(color: selected ? _SearchColors.primary : _SearchColors.border),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          label,
          style: _SearchText.caption().copyWith(
            color: selected ? Colors.white : _SearchColors.text,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
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

class _InteractiveCard extends StatefulWidget {
  const _InteractiveCard({
    required this.child,
    this.onTap,
    this.background = Colors.white,
    this.padding,
    this.borderColor,
    this.width = double.infinity,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color background;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;
  final double? width;

  @override
  State<_InteractiveCard> createState() => _InteractiveCardState();
}

class _InteractiveCardState extends State<_InteractiveCard> with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.97,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnimation = _scaleController;
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      _scaleController.animateTo(0.97, curve: Curves.easeInOut);
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      _scaleController.animateTo(1.0, curve: Curves.easeInOut);
    }
  }

  void _handleTapCancel() {
    if (widget.onTap != null) {
      _scaleController.animateTo(1.0, curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderCol = widget.borderColor ?? _SearchColors.border;

    final card = Container(
      width: widget.width,
      padding: widget.padding ?? EdgeInsets.all(13.w),
      decoration: BoxDecoration(
        color: widget.background,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: borderCol),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 5),
          )
        ],
      ),
      child: widget.child,
    );

    if (widget.onTap == null) return card;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: card,
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
    this.isCarouselCard = false,
  });

  final _SearchResult item;
  final VoidCallback onTap;
  final bool showBookmark;
  final bool isSaved;
  final VoidCallback? onBookmark;
  final bool isCarouselCard;

  @override
  Widget build(BuildContext context) {
    // 依據不同的結果類別設計高級莫蘭迪色系與視覺細節
    Color cardBg;
    Color borderCol;
    Color iconColor;
    String badgeText;
    IconData typeIcon;

    switch (item.type) {
      case _ResultType.statute:
        cardBg = const Color(0xFFEAF7F2); // 莫蘭迪薄荷綠
        borderCol = const Color(0xFFD0E6DC);
        iconColor = const Color(0xFF1E6D5A);
        badgeText = item.title.contains('刑法') ? '⚖️ 刑事法規' : '⚖️ 民事法規';
        typeIcon = Icons.menu_book_outlined;
        break;
      case _ResultType.caseItem:
        cardBg = const Color(0xFFEBF2F7); // 莫蘭迪灰藍
        borderCol = const Color(0xFFD2DFE6);
        iconColor = const Color(0xFF4A7C9D);
        badgeText = '💼 實務裁判';
        typeIcon = Icons.gavel_outlined;
        break;
      case _ResultType.lifeNote:
        cardBg = const Color(0xFFFCF6EA); // 莫蘭迪柔沙暖黃
        borderCol = const Color(0xFFEFE2CB);
        iconColor = const Color(0xFFC69C55);
        badgeText = '💡 避坑指南';
        typeIcon = Icons.explore_outlined;
        break;
      case _ResultType.official:
        cardBg = const Color(0xFFEFF3F1); // 莫蘭迪茶綠
        borderCol = const Color(0xFFDCE4E1);
        iconColor = const Color(0xFF6B8A7E);
        badgeText = '🛡️ 官方認證';
        typeIcon = Icons.verified_user_outlined;
        break;
      case _ResultType.assistant:
        cardBg = const Color(0xFFF9F6F0);
        borderCol = const Color(0xFFEAE2D5);
        iconColor = const Color(0xFFE7B76D);
        badgeText = '🤖 AI 小法助';
        typeIcon = Icons.support_agent_rounded;
        break;
    }

    final cardContent = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _IconBox(icon: typeIcon, color: iconColor),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      badgeText,
                      style: _SearchText.captionStrong().copyWith(
                        color: iconColor,
                        fontSize: 9.5.sp,
                      ),
                    ),
                  ),
                  if (item.type == _ResultType.lifeNote)
                    Text(
                      '⏱️ 3分閱讀',
                      style: _SearchText.caption().copyWith(fontSize: 9.sp),
                    ),
                ],
              ),
              SizedBox(height: 7.h),
              Text(
                item.title,
                maxLines: isCarouselCard ? 1 : 2,
                overflow: TextOverflow.ellipsis,
                style: _SearchText.tileTitle().copyWith(
                  color: _SearchColors.text,
                  fontSize: 13.5.sp,
                ),
              ),
              SizedBox(height: 5.h),
              Text(
                item.summary,
                maxLines: isCarouselCard ? 2 : 3,
                overflow: TextOverflow.ellipsis,
                style: _SearchText.body().copyWith(
                  color: _SearchColors.mutedText,
                  height: 1.45,
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(
                    item.type == _ResultType.official ? Icons.verified_outlined : Icons.link_rounded,
                    size: 11.sp,
                    color: _SearchColors.mutedText.withValues(alpha: 0.7),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(
                      item.source,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _SearchText.caption().copyWith(
                        color: _SearchColors.mutedText.withValues(alpha: 0.8),
                        fontSize: 9.8.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (showBookmark)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onBookmark,
              borderRadius: BorderRadius.circular(999.r),
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Icon(
                  isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  color: _SearchColors.primary,
                  size: 21.sp,
                ),
              ),
            ),
          )
        else if (item.type != _ResultType.official)
          Padding(
            padding: EdgeInsets.only(top: 2.h),
            child: Icon(
              Icons.chevron_right_rounded,
              color: _SearchColors.mutedText,
              size: 20.sp,
            ),
          ),
      ],
    );

    if (isCarouselCard) {
      return Container(
        width: 250.w,
        margin: EdgeInsets.only(right: 12.w),
        child: _InteractiveCard(
          onTap: onTap,
          background: cardBg,
          borderColor: borderCol,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          width: null,
          child: cardContent,
        ),
      );
    }

    return _InteractiveCard(
      onTap: onTap,
      background: cardBg,
      borderColor: borderCol,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
      child: cardContent,
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
