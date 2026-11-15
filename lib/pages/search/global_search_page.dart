import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:preamble/app/app_state.dart';
import 'package:preamble/components/navigation/app_shell_content_insets.dart';
import 'package:preamble/components/safety/plain_document_translator_sheet.dart';
import 'package:preamble/components/shared/custom_toast.dart';
import 'package:preamble/data/cases/case_models.dart';
import 'package:preamble/data/cases/case_repository.dart';
import 'package:preamble/data/journal/user_case_journal_repository.dart';
import 'package:preamble/data/law_assistant/law_assistant_models.dart';
import 'package:preamble/data/legal_brain/legal_syllogism_engine.dart';
import 'package:preamble/data/legal_brain/taiwan_statute_canon.dart';
import 'package:preamble/data/search/search_models.dart';
import 'package:preamble/data/search/search_repository.dart';
import 'package:preamble/data/statutes/statute_item.dart';
import 'package:preamble/data/statutes/statute_repository.dart';
import 'package:preamble/pages/journal/data/journal_page_items.dart';
import 'package:preamble/pages/learning/know_law_page.dart';
import 'package:preamble/pages/tools/legal_toolkit_hub_page.dart';
import 'package:preamble/theme/preamble_tokens.dart';
import 'package:preamble/utils/safe_text_editing_controller.dart';
import 'package:url_launcher/url_launcher.dart';

part 'widgets/ai_overview_card.dart';
part 'widgets/search_result_cards.dart';
part 'widgets/search_state_and_filter_widgets.dart';
part 'widgets/search_home_widgets.dart';
part 'widgets/search_detail_support_widgets.dart';
part 'widgets/search_bottom_sheets.dart';
part 'widgets/search_helper_widgets.dart';

/// Tab 3「問診」雙軌中樞模式：
/// - [consultation]：AI 法律問診（情境問題輸入、六大爭議領域問診卡、公文白話翻譯與實戰工具）
/// - [legalSearch]：法規・裁判檢索（條號與案由精準檢索、四大法源分類庫、熱門條文與歷史紀錄）
enum _HubMode { consultation, legalSearch }

// 單一頁面狀態機：所有子頁、混合結果、詳情與篩選皆在同頁無縫切換，避免巢狀底部導覽列。
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
  filters,
}

enum _ResultType { assistant, statute, caseItem, lifeNote, official }

enum _SearchTab { all, assistant, statutes, cases, lifeNotes, official }

enum _SearchSortMode {
  relevance('相關度優先'),
  newest('最新年度');

  const _SearchSortMode(this.label);
  final String label;
}

enum _SearchDomainFilter {
  all('全部領域'),
  civil('民事'),
  criminal('刑事'),
  labor('勞動'),
  rental('租屋');

  const _SearchDomainFilter(this.label);
  final String label;
}

enum _SubListFilter {
  all('全部'),
  followed('我關注的'),
  saved('已收藏');

  const _SubListFilter(this.label);
  final String label;
}

class GlobalSearchPage extends StatefulWidget {
  const GlobalSearchPage({
    super.key,
    SearchRepository? searchRepository,
    this.quickAskPromptListenable,
  }) : _searchRepository = searchRepository;

  final SearchRepository? _searchRepository;
  final ValueListenable<String?>? quickAskPromptListenable;

  @override
  State<GlobalSearchPage> createState() => _GlobalSearchPageState();
}

class _GlobalSearchPageState extends State<GlobalSearchPage> {
  final _controller = SafeTextEditingController();
  final List<String> _recent = [];
  late final SearchRepository _searchRepository;
  late final bool _ownsSearchRepository;

  _HubMode _hubMode = _HubMode.consultation;
  String _query = '';
  _SearchPage _page = _SearchPage.home;
  _SearchTab _tab = _SearchTab.all;
  _SearchResult _selected = _mockResults.first;
  List<_SearchResult> _results = const [];
  var _isSearching = false;
  String? _searchError;
  var _searchRevision = 0;
  String? _lastExternalQuickAskPrompt;

  // 真實生效之檢索篩選與排序狀態
  _SearchSortMode _sortMode = _SearchSortMode.relevance;
  _SearchDomainFilter _domainFilter = _SearchDomainFilter.all;
  final Set<_ResultType> _enabledTypes = {..._ResultType.values};
  int? _recentYearsFilter;
  _SubListFilter _subListFilter = _SubListFilter.all;

  // AI 三段論法理總覽與防禦分析狀態
  bool _aiIsThinking = false;
  String _aiTone = '白話'; // '白話' or '專業'
  String _aiLength = '精簡'; // '精簡' or '詳細'
  String _aiGeneratedSummary = '';
  LegalSyllogismAnalysis? _syllogismAnalysis;
  LawAssistantDefenseInsight? _currentDefenseInsight;

  @override
  void initState() {
    super.initState();
    _ownsSearchRepository = widget._searchRepository == null;
    _searchRepository = widget._searchRepository ?? SearchRepository();
    widget.quickAskPromptListenable?.addListener(_handleExternalQuickAskPrompt);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _handleExternalQuickAskPrompt();
    });
  }

  @override
  void didUpdateWidget(covariant GlobalSearchPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.quickAskPromptListenable == widget.quickAskPromptListenable) {
      return;
    }
    oldWidget.quickAskPromptListenable
        ?.removeListener(_handleExternalQuickAskPrompt);
    widget.quickAskPromptListenable?.addListener(_handleExternalQuickAskPrompt);
  }

  @override
  void dispose() {
    widget.quickAskPromptListenable
        ?.removeListener(_handleExternalQuickAskPrompt);
    _controller.dispose();
    if (_ownsSearchRepository) {
      _searchRepository.dispose();
    }
    super.dispose();
  }

  void _handleExternalQuickAskPrompt() {
    final prompt = widget.quickAskPromptListenable?.value?.trim();
    if (prompt == null || prompt.isEmpty) {
      _lastExternalQuickAskPrompt = null;
      return;
    }
    if (prompt == _lastExternalQuickAskPrompt) return;

    _lastExternalQuickAskPrompt = prompt;
    // 原生 Siri / Shortcuts 入口只提供問題文字；先同步開啟三段論問診狀態，再彈起多輪小法助對話。
    _openAssistant(prompt);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _continueWithAssistant();
      }
    });
  }

  bool _isNaturalLanguageQuery(String rawQuery) {
    final q = rawQuery.trim();
    if (q.isEmpty) return _hubMode == _HubMode.consultation;
    if (q.length >= 7) return true;
    return RegExp(r'[？?嗎怎麼如何什麼辦不退被可否該能賠扣欠]').hasMatch(q);
  }

  int get _activeFilterCount {
    var count = 0;
    if (_domainFilter != _SearchDomainFilter.all) count++;
    if (_sortMode != _SearchSortMode.relevance) count++;
    if (_recentYearsFilter != null) count++;
    if (_enabledTypes.length < _ResultType.values.length) count++;
    return count;
  }

  void _resetFilters() {
    setState(() {
      _sortMode = _SearchSortMode.relevance;
      _domainFilter = _SearchDomainFilter.all;
      _enabledTypes
        ..clear()
        ..addAll(_ResultType.values);
      _recentYearsFilter = null;
      _subListFilter = _SubListFilter.all;
    });
  }

  void _toggleTypeFilter(_ResultType type) {
    setState(() {
      if (_enabledTypes.contains(type)) {
        if (_enabledTypes.length > 1) {
          _enabledTypes.remove(type);
        }
      } else {
        _enabledTypes.add(type);
      }
    });
  }

  List<_SearchResult> _filteredResults(
    PreambleState appState, {
    _ResultType? forceType,
    bool applySubListFilter = false,
  }) {
    final filtered = _results.where((item) {
      if (forceType != null) {
        if (item.type != forceType) return false;
      } else if (!_enabledTypes.contains(item.type)) {
        return false;
      }

      if (!_matchesDomain(item, _domainFilter)) {
        return false;
      }

      if (_recentYearsFilter != null &&
          !_matchesRecentYears(item, _recentYearsFilter!)) {
        return false;
      }

      if (applySubListFilter) {
        switch (_subListFilter) {
          case _SubListFilter.all:
            break;
          case _SubListFilter.followed:
            if (!_isFollowed(appState, item)) return false;
          case _SubListFilter.saved:
            if (!_isSaved(appState, item)) return false;
        }
      }

      return true;
    }).toList();

    if (_sortMode == _SearchSortMode.newest) {
      filtered.sort((a, b) => _extractTimestamp(b).compareTo(_extractTimestamp(a)));
    } else if (_query.trim().isNotEmpty) {
      final keyword = _query.trim().toLowerCase();
      filtered.sort((a, b) {
        final aExact = a.title.toLowerCase().contains(keyword) ? 0 : 1;
        final bExact = b.title.toLowerCase().contains(keyword) ? 0 : 1;
        return aExact.compareTo(bExact);
      });
    }

    return filtered;
  }

  bool _matchesDomain(_SearchResult item, _SearchDomainFilter domain) {
    if (domain == _SearchDomainFilter.all) return true;
    final corpus =
        '${item.title} ${item.summary} ${item.source} ${item.query}'.toLowerCase();
    return switch (domain) {
      _SearchDomainFilter.all => true,
      _SearchDomainFilter.civil => RegExp(
          r'民法|民事|侵權|契約|賠償|車禍|折舊|債權|本票|繼承|財產|鄰損|漏水|消保|消費|退貨|鑑賞|定金|違約',
        ).hasMatch(corpus),
      _SearchDomainFilter.criminal => RegExp(
          r'刑法|刑事|詐|洗錢|告訴|不起訴|過失傷害|竊盜|妨害|165|警政|車手|警示帳戶|偵查',
        ).hasMatch(corpus),
      _SearchDomainFilter.labor => RegExp(
          r'勞|工資|加班|資遣|解僱|離職|職場|工時|職災|雇主',
        ).hasMatch(corpus),
      _SearchDomainFilter.rental => RegExp(
          r'租|押金|房東|房客|點交|修繕|住宅|421|423|429|430|440|444',
        ).hasMatch(corpus),
    };
  }

  bool _matchesRecentYears(_SearchResult item, int maxYears) {
    final dt = _extractTimestamp(item);
    final nowYear = DateTime.now().year;
    return (nowYear - dt.year) <= maxYears;
  }

  DateTime _extractTimestamp(_SearchResult item) {
    if (item.updatedAt != null) return item.updatedAt!;
    final text = '${item.source} ${item.title}';

    final adMatch = RegExp(r'(20\d{2})[./\-年](\d{1,2})?[./\-月]?(\d{1,2})?')
        .firstMatch(text);
    if (adMatch != null) {
      final y = int.tryParse(adMatch.group(1) ?? '') ?? DateTime.now().year;
      final m = int.tryParse(adMatch.group(2) ?? '') ?? 6;
      final d = int.tryParse(adMatch.group(3) ?? '') ?? 15;
      return DateTime(y, m.clamp(1, 12), d.clamp(1, 28));
    }

    final rocDateMatch =
        RegExp(r'(\d{3})\.(\d{1,2})\.(\d{1,2})').firstMatch(text);
    if (rocDateMatch != null) {
      final rocYear = int.tryParse(rocDateMatch.group(1) ?? '') ?? 114;
      final m = int.tryParse(rocDateMatch.group(2) ?? '') ?? 6;
      final d = int.tryParse(rocDateMatch.group(3) ?? '') ?? 15;
      return DateTime(rocYear + 1911, m.clamp(1, 12), d.clamp(1, 28));
    }

    final rocYearMatch = RegExp(r'(\d{3})\s*年').firstMatch(text);
    if (rocYearMatch != null) {
      final rocYear = int.tryParse(rocYearMatch.group(1) ?? '') ?? 114;
      return DateTime(rocYear + 1911, 6, 15);
    }

    return DateTime(DateTime.now().year, 1, 1);
  }

  // 啟動 AI 根據爭議事實、三段論與自救防禦模型生成內容
  void _triggerAiOverviewGeneration(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    setState(() {
      _aiIsThinking = true;
    });

    Future.delayed(const Duration(milliseconds: 260), () {
      if (!mounted || _query != trimmed) return;

      final insight = LawAssistantDefenseInsight.fromContext(text: trimmed);
      final analysis =
          LegalSyllogismEngine.analyzeDispute(rawDisputeFacts: trimmed);

      String summaryBase = '';
      if (_aiTone == '白話') {
        if (_aiLength == '精簡') {
          summaryBase = analysis.conclusionRemedy;
          if (insight.statuteDeadline != null) {
            summaryBase +=
                '\n\n【法定時效提醒】${insight.statuteDeadline!.title}（${insight.statuteDeadline!.durationDays}天），依${insight.statuteDeadline!.legalBasis}。';
          }
        } else {
          final issues =
              analysis.identifiedIssues.take(2).map((i) => '• $i').join('\n');
          final steps =
              analysis.escalationPath.take(3).map((e) => '• $e').join('\n');
          final statutes = analysis.majorPremiseStatutes
              .map((s) => '• ${s.fullCitation}：${s.plainSummary}')
              .join('\n');
          summaryBase = '【案情與爭點透視】\n$issues\n\n'
              '【核心法律依據】\n$statutes\n\n'
              '【自保維權行動路徑】\n$steps\n\n'
              '【救濟結論與建議】\n${analysis.conclusionRemedy}';
        }
      } else {
        if (_aiLength == '精簡') {
          final statuteRef = analysis.majorPremiseStatutes.isNotEmpty
              ? '依${analysis.majorPremiseStatutes.first.fullCitation}規定，'
              : '';
          summaryBase =
              '$statuteRef${analysis.conclusionRemedy} 建議保全相關書證依法進行權利主張。';
        } else {
          final statutesText = analysis.majorPremiseStatutes
              .take(2)
              .map((s) => '• ${s.fullCitation}：${s.officialText}')
              .join('\n');
          final subsumptions = analysis.subsumptionFindings
              .take(3)
              .map(
                (f) =>
                    '• ${f.elementName}：${f.factualBasis}（舉證建議：${f.evidentiaryAdvice}）',
              )
              .join('\n');
          summaryBase = '【大前提（規範基礎）】\n$statutesText\n\n'
              '【小前提（事實要件涵攝）】\n$subsumptions\n\n'
              '【裁判結論與法律效果】\n${analysis.conclusionRemedy}\n\n'
              '【訴訟與實務攻防策略】\n${analysis.escalationPath.join(' → ')}';
        }
      }

      setState(() {
        _syllogismAnalysis = analysis;
        _currentDefenseInsight = insight;
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
      if (_recent.length > 6) _recent.removeLast();
      _page = nextPage;
      _tab = _SearchTab.all;
      _subListFilter = _SubListFilter.all;
      _isSearching = true;
      _searchError = null;
    });
    FocusManager.instance.primaryFocus?.unfocus();

    _triggerAiOverviewGeneration(query);

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
      _syllogismAnalysis = null;
      _currentDefenseInsight = null;
    });
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _openToolkit([String? toolKey]) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LegalToolkitHubPage(initialToolKey: toolKey),
      ),
    );
  }

  void _openTranslator() {
    PlainDocumentTranslatorSheet.show(context);
  }

  Future<void> _saveAssistantToJournal() async {
    final keyword = _query.trim().isEmpty ? '生活法律自救案件' : _query.trim();
    final insight = _currentDefenseInsight ??
        LawAssistantDefenseInsight.fromContext(text: keyword);
    final entry = UserCaseJournalRepository.fromAssistantInsight(
      insight: insight,
      rawFacts: keyword,
    );
    final repo = UserCaseJournalRepository();
    await repo.addEntry(entry);
    if (!mounted) return;
    CustomToast.show(
      context,
      '已在「紀事」建立「${entry.title}」自救案卷，含證據清單與時效追蹤。',
    );
  }

  void _clearRecent() {
    setState(_recent.clear);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
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
      backgroundColor: t.canvas,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            if (showTopBar || showSearchField)
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 10.h),
                decoration: BoxDecoration(
                  color: t.canvas,
                  border: Border(
                    bottom: BorderSide(color: t.border, width: 1),
                  ),
                ),
                child: showTopBar
                    ? _TopBar(
                        title: _titleFor(_page),
                        showBack: true,
                        onBack: _handleBack,
                        trailing: _page == _SearchPage.assistant
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _RoundIcon(
                                    icon: PhosphorIconsRegular.shareNetwork,
                                    tooltip: '複製問診摘要',
                                    onTap: _shareAssistantSummary,
                                  ),
                                  SizedBox(width: 8.w),
                                  _RoundIcon(
                                    icon: _isSaved(
                                      PreambleScope.of(context),
                                      _selected,
                                    )
                                        ? PhosphorIconsFill.bookmarkSimple
                                        : PhosphorIconsRegular.bookmarkSimple,
                                    tooltip: '收藏問診摘要',
                                    active: _isSaved(
                                      PreambleScope.of(context),
                                      _selected,
                                    ),
                                    onTap: () => _toggleSaved(_selected),
                                  ),
                                ],
                              )
                            : null,
                      )
                    : _buildSearchHeader(),
              ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(
                  16.w,
                  12.h,
                  16.w,
                  112.h + AppShellContentInsets.additionalBottomOf(context),
                ),
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 160),
                    child: KeyedSubtree(
                      key: ValueKey(
                        '${_page.name}-${_hubMode.name}-${_tab.name}-${_selected.title}',
                      ),
                      child: _contentFor(_page),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    final searchField = _SearchField(
      controller: _controller,
      onSubmitted: _submit,
      showFilter: _page != _SearchPage.home,
      activeFilterCount: _activeFilterCount,
      onFilter: () => setState(() => _page = _SearchPage.filters),
      onClear: _goHome,
    );

    if (_page == _SearchPage.home) return searchField;

    return Row(
      children: [
        _RoundIcon(
          icon: Icons.arrow_back_ios_new_rounded,
          tooltip: '返回問診與檢索首頁',
          onTap: _goHome,
        ),
        SizedBox(width: 10.w),
        Expanded(child: searchField),
      ],
    );
  }

  String _titleFor(_SearchPage page) {
    switch (page) {
      case _SearchPage.home:
        return '法律問診與檢索';
      case _SearchPage.results:
        return '檢索與問診結果';
      case _SearchPage.assistant:
        return 'AI 法律問診摘要';
      case _SearchPage.statutes:
        return '法規檢索結果';
      case _SearchPage.statuteDetail:
        return '法規雙重編碼詳情';
      case _SearchPage.cases:
        return '裁判案卷結果';
      case _SearchPage.caseDetail:
        return '裁判案卷詳情';
      case _SearchPage.lifeNotes:
        return '避坑實務指南';
      case _SearchPage.lifeDetail:
        return '避坑實務詳情';
      case _SearchPage.official:
        return '法務動態與官方資料';
      case _SearchPage.filters:
        return '檢索篩選條件';
    }
  }

  Widget _contentFor(_SearchPage page) {
    final appState = PreambleScope.of(context);
    final assistantResult = _assistantResultFor(_query);
    final filteredAll = _filteredResults(appState);
    final statuteResults = _filteredResults(
      appState,
      forceType: _ResultType.statute,
      applySubListFilter: page == _SearchPage.statutes,
    );
    final caseResults = _filteredResults(
      appState,
      forceType: _ResultType.caseItem,
      applySubListFilter: page == _SearchPage.cases,
    );
    final lifeResults = _filteredResults(
      appState,
      forceType: _ResultType.lifeNote,
    );
    final officialResults = _filteredResults(
      appState,
      forceType: _ResultType.official,
    );

    switch (page) {
      case _SearchPage.home:
        return _SearchHome(
          mode: _hubMode,
          onModeChanged: (next) => setState(() => _hubMode = next),
          recent: _recent,
          onQuery: _submit,
          onLaunchChat: _launchAssistantChat,
          onOpenTranslator: _openTranslator,
          onOpenToolkit: () => _openToolkit(),
          onStatutes: () => _openList(_SearchPage.statutes),
          onCases: () => _openList(_SearchPage.cases),
          onLifeNotes: () => _openList(_SearchPage.lifeNotes),
          onOfficial: () => _openList(_SearchPage.official),
          onOpenFilters: () => setState(() => _page = _SearchPage.filters),
          onClearRecent: _clearRecent,
          controller: _controller,
        );
      case _SearchPage.results:
        if (_isSearching) {
          return const _SearchStateCard(
            message: '正在同步檢索六法條文、裁判案卷與三段論分析...',
          );
        }
        if (_searchError != null) {
          return _SearchStateCard(
            message: _searchError!,
            icon: PhosphorIconsRegular.warningCircle,
          );
        }
        return _MixedResults(
          query: _query,
          tab: _tab,
          results: filteredAll,
          assistantResult: assistantResult,
          isNaturalQuestion: _isNaturalLanguageQuery(_query),
          sortMode: _sortMode,
          domainFilter: _domainFilter,
          activeFilterCount: _activeFilterCount,
          onSortChanged: (mode) => setState(() => _sortMode = mode),
          onDomainChanged: (domain) => setState(() => _domainFilter = domain),
          onOpenFilterPanel: () => setState(() => _page = _SearchPage.filters),
          onResetFilters: _resetFilters,
          onTab: (tab) => setState(() => _tab = tab),
          onOpen: _openResult,
          onOpenList: _openList,
          isSaved: (item) => _isSaved(appState, item),
          onSaved: _toggleSaved,
          aiIsThinking: _aiIsThinking,
          aiTone: _aiTone,
          aiLength: _aiLength,
          aiSummary: _aiGeneratedSummary,
          syllogismAnalysis: _syllogismAnalysis,
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
          defenseInsight: _currentDefenseInsight,
          onSaveToJournal: _saveAssistantToJournal,
        );
      case _SearchPage.assistant:
        return _AssistantDetail(
          query: _query,
          onOpen: _openList,
          onContinue: _continueWithAssistant,
          syllogismAnalysis: _syllogismAnalysis,
          defenseInsight: _currentDefenseInsight,
          onSaveToJournal: _saveAssistantToJournal,
        );
      case _SearchPage.statutes:
        if (_isSearching) {
          return const _SearchStateCard(message: '正在檢索法規資料庫...');
        }
        return _ResultList(
          subListFilter: _subListFilter,
          onSubListChanged: (f) => setState(() => _subListFilter = f),
          sortMode: _sortMode,
          domainFilter: _domainFilter,
          activeFilterCount: _activeFilterCount,
          onSortChanged: (m) => setState(() => _sortMode = m),
          onDomainChanged: (d) => setState(() => _domainFilter = d),
          onOpenFilterPanel: () => setState(() => _page = _SearchPage.filters),
          onResetFilters: _resetFilters,
          items: statuteResults,
          onOpen: _openResult,
          actionLabel: '追蹤首筆法條異動',
          isSaved: (item) => _isSaved(appState, item),
          onSaved: _toggleSaved,
          onAction: statuteResults.isEmpty
              ? () => _showSnack('目前沒有可追蹤的法規搜尋結果。')
              : () => _toggleFollow(statuteResults.first),
        );
      case _SearchPage.statuteDetail:
        return _StatuteDetail(
          item: _selected,
          isFollowed: _isFollowed(appState, _selected),
          isSaved: _isSaved(appState, _selected),
          onFollow: () => _toggleFollow(_selected),
          onSaved: () => _showArchiveBottomSheet(context, _selected),
          onAssistant: () => _openAssistant(_selected.query),
          onNavigateResult: _openResult,
          onAskScenario: _openAssistant,
        );
      case _SearchPage.cases:
        if (_isSearching) {
          return const _SearchStateCard(message: '正在檢索裁判案卷...');
        }
        return _ResultList(
          subListFilter: _subListFilter,
          onSubListChanged: (f) => setState(() => _subListFilter = f),
          sortMode: _sortMode,
          domainFilter: _domainFilter,
          activeFilterCount: _activeFilterCount,
          onSortChanged: (m) => setState(() => _sortMode = m),
          onDomainChanged: (d) => setState(() => _domainFilter = d),
          onOpenFilterPanel: () => setState(() => _page = _SearchPage.filters),
          onResetFilters: _resetFilters,
          items: caseResults,
          onOpen: _openResult,
          actionLabel: '追蹤首筆裁判案卷',
          isSaved: (item) => _isSaved(appState, item),
          onSaved: _toggleSaved,
          onAction: caseResults.isEmpty
              ? () => _showSnack('目前沒有可追蹤的案件搜尋結果。')
              : () => _toggleFollow(caseResults.first),
        );
      case _SearchPage.caseDetail:
        return _CaseDetail(
          item: _selected,
          isFollowed: _isFollowed(appState, _selected),
          isSaved: _isSaved(appState, _selected),
          onFollow: () => _toggleFollow(_selected),
          onSaved: () => _showArchiveBottomSheet(context, _selected),
          onOpenFullText: () => _openCaseJudgment(_selected),
          onAskScenario: _openAssistant,
        );
      case _SearchPage.lifeNotes:
        if (_isSearching) {
          return const _SearchStateCard(message: '正在檢索避坑實務指南...');
        }
        return _LifeNoteList(
          items: lifeResults,
          sortMode: _sortMode,
          domainFilter: _domainFilter,
          activeFilterCount: _activeFilterCount,
          onSortChanged: (m) => setState(() => _sortMode = m),
          onDomainChanged: (d) => setState(() => _domainFilter = d),
          onOpenFilterPanel: () => setState(() => _page = _SearchPage.filters),
          onResetFilters: _resetFilters,
          onOpen: _openResult,
          onMore: _showLifeNoteExplorer,
        );
      case _SearchPage.lifeDetail:
        return _LifeNoteDetail(
          item: _selected,
          isSaved: _isSaved(appState, _selected),
          onSaved: () => _showArchiveBottomSheet(context, _selected),
          onAskScenario: _openAssistant,
        );
      case _SearchPage.official:
        if (_isSearching) {
          return const _SearchStateCard(message: '正在檢索官方公開資料...');
        }
        return _OfficialList(
          items: officialResults,
          sortMode: _sortMode,
          domainFilter: _domainFilter,
          activeFilterCount: _activeFilterCount,
          onSortChanged: (m) => setState(() => _sortMode = m),
          onDomainChanged: (d) => setState(() => _domainFilter = d),
          onOpenFilterPanel: () => setState(() => _page = _SearchPage.filters),
          onResetFilters: _resetFilters,
          onOpen: _openOfficialSource,
          onMore: _showOfficialExplorer,
        );
      case _SearchPage.filters:
        return _FilterPanel(
          enabledTypes: _enabledTypes,
          domainFilter: _domainFilter,
          recentYearsFilter: _recentYearsFilter,
          sortMode: _sortMode,
          onToggleType: _toggleTypeFilter,
          onDomainChanged: (d) => setState(() => _domainFilter = d),
          onRecentYearsChanged: (y) => setState(() => _recentYearsFilter = y),
          onSortChanged: (m) => setState(() => _sortMode = m),
          onReset: _resetFilters,
          onApply: () {
            setState(() {
              if (_query.trim().isEmpty) {
                _page = _SearchPage.home;
              } else {
                _page = _SearchPage.results;
              }
            });
          },
        );
    }
  }

  void _openList(_SearchPage page) {
    if (_query.isEmpty) {
      final defaultQuery = switch (page) {
        _SearchPage.statutes => '民法',
        _SearchPage.cases => '詐欺',
        _SearchPage.lifeNotes => '租屋',
        _SearchPage.official => '防詐騙',
        _ => '詐欺',
      };
      _submit(defaultQuery, nextPage: page);
      return;
    }
    setState(() {
      _subListFilter = _SubListFilter.all;
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
    final trimmed = query.trim();
    final insight = LawAssistantDefenseInsight.fromContext(
      text: trimmed.isEmpty ? '一般法律爭議' : trimmed,
    );
    final analysis = LegalSyllogismEngine.analyzeDispute(
      rawDisputeFacts: trimmed.isEmpty ? '一般法律爭議' : trimmed,
    );
    setState(() {
      _query = trimmed;
      _controller.text = trimmed;
      _selected = _assistantResultFor(trimmed);
      _currentDefenseInsight = insight;
      _syllogismAnalysis = analysis;
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
          _page = _query.isEmpty ? _SearchPage.home : _SearchPage.results;
        case _SearchPage.filters:
          _page = _query.isEmpty ? _SearchPage.home : _SearchPage.results;
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

  bool _isFollowed(PreambleState appState, _SearchResult item) {
    final id = _interactionIdFor(item);
    return switch (item.type) {
      _ResultType.statute => appState.isStatuteFollowed(id),
      _ResultType.caseItem => appState.isCaseFollowed(id),
      _ResultType.lifeNote => appState.isTopicFollowed(id),
      _ => false,
    };
  }

  bool _isSaved(PreambleState appState, _SearchResult item) {
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
    final appState = PreambleScope.of(context);
    final id = _interactionIdFor(item);
    final next = !_isFollowed(appState, item);

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
    setState(() {});
    _showSnack(next ? '已加入我的 緒言 Preamble 追蹤。' : '已從我的 緒言 Preamble 取消追蹤。');
  }

  Future<void> _toggleSaved(_SearchResult item) async {
    final appState = PreambleScope.of(context);
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
    _showSnack(next ? '已加入我的 緒言 Preamble 收藏。' : '已從我的 緒言 Preamble 收藏移除。');
  }

  void _showArchiveBottomSheet(BuildContext context, _SearchResult item) {
    final folders = ['租屋押金爭議', '網購退貨權益', '防詐騙金流紀錄', '一般法律備忘'];
    int selectedIndex = 0;
    final noteController = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final t = sheetContext.tokens;
            return Container(
              decoration: BoxDecoration(
                color: t.surfaceElevated,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                border: Border(
                  top: BorderSide(color: t.borderStrong, width: 1),
                ),
              ),
              padding: EdgeInsets.fromLTRB(
                18.w,
                16.h,
                18.w,
                MediaQuery.viewInsetsOf(sheetContext).bottom + 24.h,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: t.borderStrong,
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 14.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '歸檔至案件卷宗夾',
                          style: _SearchText.serifSection(sheetContext),
                        ),
                        IconButton(
                          icon: Icon(PhosphorIconsRegular.x, size: 18.sp),
                          color: t.textMuted,
                          onPressed: () => Navigator.pop(sheetContext),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Text('選擇歸檔目錄', style: _SearchText.captionStrong(sheetContext)),
                    SizedBox(height: 8.h),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: 190.h),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: folders.length + 1,
                        itemBuilder: (itemContext, index) {
                          if (index == folders.length) {
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                PhosphorIconsRegular.folderSimplePlus,
                                color: t.brandPrimary,
                                size: 19.sp,
                              ),
                              title: Text(
                                '新增自訂案件夾...',
                                style: _SearchText.bodyStrong(itemContext)
                                    .copyWith(color: t.brandPrimary),
                              ),
                              onTap: () {
                                setSheetState(() {
                                  folders.add('自訂案件夾 ${folders.length - 3}');
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
                                  ? PhosphorIconsFill.radioButton
                                  : PhosphorIconsRegular.folderSimple,
                              color:
                                  isSelected ? t.brandPrimary : t.textMuted,
                              size: 19.sp,
                            ),
                            title: Text(
                              folders[index],
                              style: _SearchText.bodyStrong(itemContext),
                            ),
                            onTap: () =>
                                setSheetState(() => selectedIndex = index),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 14.h),
                    Text(
                      '備忘註記（選填）',
                      style: _SearchText.captionStrong(sheetContext),
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: noteController,
                      style: _SearchText.bodyStrong(sheetContext),
                      decoration: InputDecoration(
                        hintText: '輸入與本案相關的備註事項...',
                        hintStyle: _SearchText.body(sheetContext),
                        filled: true,
                        fillColor: t.surfaceSubtle,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 10.h,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: t.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: t.brandPrimary),
                        ),
                      ),
                    ),
                    SizedBox(height: 18.h),
                    _PrimaryButton(
                      label: '確認歸檔收藏',
                      icon: PhosphorIconsRegular.bookmarkSimple,
                      onPressed: () {
                        final folderName = folders[selectedIndex];
                        Navigator.pop(sheetContext);
                        _toggleSaved(item);
                        CustomToast.show(
                          this.context,
                          '已成功歸檔至「$folderName」卷宗夾。',
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(noteController.dispose);
  }

  Future<void> _shareAssistantSummary() async {
    final keyword = _query.trim().isEmpty ? _selected.query : _query.trim();
    final text = [
      '小法助三段論整理：$keyword',
      _aiGeneratedSummary.isNotEmpty ? _aiGeneratedSummary : _selected.summary,
      '來源：緒言 Preamble 法律問診與檢索',
    ].where((line) => line.trim().isNotEmpty).join('\n\n');
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    _showSnack('已複製小法助問診摘要。');
  }

  void _launchAssistantChat([String? promptOverride]) {
    final resolved = (promptOverride != null && promptOverride.trim().isNotEmpty)
        ? promptOverride.trim()
        : (_query.trim().isNotEmpty ? _query.trim() : _selected.query);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final t = sheetContext.tokens;
        return Container(
          height: MediaQuery.sizeOf(sheetContext).height * 0.88,
          decoration: BoxDecoration(
            color: t.surfaceElevated,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            border: Border(top: BorderSide(color: t.borderStrong)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            child: LawAssistantChatPage(
              initialPrompt: resolved.isEmpty ? null : resolved,
            ),
          ),
        );
      },
    );
  }

  void _continueWithAssistant() {
    _launchAssistantChat();
  }

  Future<void> _saveAssistantSummaryToNotebook() async {
    final appState = PreambleScope.of(context);
    final keyword = _query.trim().isEmpty ? 'AI 法律摘要' : _query.trim();
    final interactionId = 'assistant-${_slugFor(keyword)}';
    await appState.setArticleSaved(interactionId, true);
    if (!mounted) return;
    _showSnack('已將「$keyword」的三段論釋義摘要儲存至法律摘錄本。');
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
          title: '瀏覽更多避坑實務主題',
          message: '選擇常見生活爭議主題，系統將帶入精準關鍵字並列出對應蒐證與自保指南。',
          actions: [
            _SheetAction(
              icon: PhosphorIconsRegular.houseLine,
              title: '租屋押金與修繕',
              subtitle: '押金扣抵、退租點交、修繕責任歸屬',
              onTap: () {
                Navigator.of(sheetContext).pop();
                _submit('租屋 押金', nextPage: _SearchPage.lifeNotes);
              },
            ),
            _SheetAction(
              icon: PhosphorIconsRegular.briefcase,
              title: '勞資工時與資遣',
              subtitle: '加班費計算、預告工資、非自願離職證明',
              onTap: () {
                Navigator.of(sheetContext).pop();
                _submit('勞資 加班', nextPage: _SearchPage.lifeNotes);
              },
            ),
            _SheetAction(
              icon: PhosphorIconsRegular.shoppingBagOpen,
              title: '消費退貨與申訴',
              subtitle: '七日猶豫期、瑕疵擔保、線上消費申訴',
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
          title: '前往權威司法與行政機關網站',
          message: '官方資料保留原始權威出處；開啟網站時將自動複製當前檢索詞方便查核。',
          actions: [
            _SheetAction(
              icon: PhosphorIconsRegular.bank,
              title: '全國法規資料庫／法務部',
              subtitle: '最新修正法規、函釋與法務動態',
              onTap: () {
                Navigator.of(sheetContext).pop();
                _copyQueryAndOpenOfficial(
                  Uri.parse('https://www.moj.gov.tw/'),
                  '法務部',
                );
              },
            ),
            _SheetAction(
              icon: PhosphorIconsRegular.gavel,
              title: '司法院裁判書查詢系統',
              subtitle: '各級法院歷年裁判全文與司法公告',
              onTap: () {
                Navigator.of(sheetContext).pop();
                _copyQueryAndOpenOfficial(
                  Uri.parse('https://www.judicial.gov.tw/'),
                  '司法院',
                );
              },
            ),
            _SheetAction(
              icon: PhosphorIconsRegular.shieldCheck,
              title: '內政部警政署 165 全民防騙網',
              subtitle: '最新詐騙手法公告、通報與緊急止付指引',
              onTap: () {
                Navigator.of(sheetContext).pop();
                _copyQueryAndOpenOfficial(
                  Uri.parse('https://165.npa.gov.tw/'),
                  '165 全民防騙網',
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
    if (source.contains('165') || source.contains('警政')) {
      return Uri.parse('https://165.npa.gov.tw/');
    }
    if (source.contains('行政院')) {
      return Uri.parse('https://www.ey.gov.tw/');
    }
    return Uri.parse('https://www.gov.tw/');
  }

  void _showSnack(String message) {
    CustomToast.show(context, message);
  }
}

class _MixedResults extends StatelessWidget {
  const _MixedResults({
    required this.query,
    required this.tab,
    required this.results,
    required this.assistantResult,
    required this.isNaturalQuestion,
    required this.sortMode,
    required this.domainFilter,
    required this.activeFilterCount,
    required this.onSortChanged,
    required this.onDomainChanged,
    required this.onOpenFilterPanel,
    required this.onResetFilters,
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
    this.syllogismAnalysis,
    this.defenseInsight,
    this.onSaveToJournal,
  });

  final String query;
  final _SearchTab tab;
  final List<_SearchResult> results;
  final _SearchResult assistantResult;
  final bool isNaturalQuestion;
  final _SearchSortMode sortMode;
  final _SearchDomainFilter domainFilter;
  final int activeFilterCount;
  final ValueChanged<_SearchSortMode> onSortChanged;
  final ValueChanged<_SearchDomainFilter> onDomainChanged;
  final VoidCallback onOpenFilterPanel;
  final VoidCallback onResetFilters;
  final ValueChanged<_SearchTab> onTab;
  final ValueChanged<_SearchResult> onOpen;
  final ValueChanged<_SearchPage> onOpenList;
  final bool Function(_SearchResult item) isSaved;
  final ValueChanged<_SearchResult> onSaved;

  final bool aiIsThinking;
  final String aiTone;
  final String aiLength;
  final String aiSummary;
  final LegalSyllogismAnalysis? syllogismAnalysis;
  final ValueChanged<String> onToneChanged;
  final ValueChanged<String> onLengthChanged;
  final VoidCallback onNotebookSave;
  final VoidCallback onContinueChat;
  final LawAssistantDefenseInsight? defenseInsight;
  final VoidCallback? onSaveToJournal;

  @override
  Widget build(BuildContext context) {
    final visible = _resultsForTab(tab);
    if (tab == _SearchTab.all) {
      final statutes = _resultsByType(_ResultType.statute);
      final cases = _resultsByType(_ResultType.caseItem);
      final lifeNotes = _resultsByType(_ResultType.lifeNote);
      final official = _resultsByType(_ResultType.official);
      final allFilteredEmpty = statutes.isEmpty &&
          cases.isEmpty &&
          lifeNotes.isEmpty &&
          official.isEmpty;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SearchTabs(tab: tab, onTab: onTab),
          SizedBox(height: 10.h),
          _InteractiveFilterBar(
            sortMode: sortMode,
            domainFilter: domainFilter,
            activeFilterCount: activeFilterCount,
            onSortChanged: onSortChanged,
            onDomainChanged: onDomainChanged,
            onOpenFilterPanel: onOpenFilterPanel,
          ),
          SizedBox(height: 14.h),
          _AssistantOverviewCard(
            query: query,
            summary: aiSummary.isNotEmpty ? aiSummary : assistantResult.summary,
            isThinking: aiIsThinking,
            isNaturalQuestion: isNaturalQuestion,
            tone: aiTone,
            length: aiLength,
            syllogismAnalysis: syllogismAnalysis,
            onToneChanged: onToneChanged,
            onLengthChanged: onLengthChanged,
            onNotebookSave: onNotebookSave,
            onContinueChat: onContinueChat,
            defenseInsight: defenseInsight,
            onSaveToJournal: onSaveToJournal,
          ),
          SizedBox(height: 16.h),
          if (allFilteredEmpty && activeFilterCount > 0) ...[
            _SearchStateCard(
              message: '目前篩選條件下無相符條文或案卷，建議放寬領域或年度條件。',
              actionLabel: '重設篩選條件',
              onAction: onResetFilters,
            ),
            SizedBox(height: 14.h),
          ],
          _ResultSection(
            title: '法規',
            items: statutes.take(3).toList(),
            onOpen: onOpen,
            isSaved: isSaved,
            onSaved: onSaved,
            onMore: statutes.length > 3
                ? () => onOpenList(_SearchPage.statutes)
                : null,
          ),
          _ResultSection(
            title: '裁判案卷',
            items: cases.take(3).toList(),
            onOpen: onOpen,
            isSaved: isSaved,
            onSaved: onSaved,
            isCarousel: true,
            onMore:
                cases.length > 3 ? () => onOpenList(_SearchPage.cases) : null,
          ),
          _ResultSection(
            title: '避坑實務',
            items: lifeNotes.take(3).toList(),
            onOpen: onOpen,
            isSaved: isSaved,
            onSaved: onSaved,
            isCarousel: true,
            onMore: lifeNotes.length > 3
                ? () => onOpenList(_SearchPage.lifeNotes)
                : null,
          ),
          _ResultSection(
            title: '法務動態',
            items: official.take(2).toList(),
            onOpen: onOpen,
            isSaved: isSaved,
            onSaved: onSaved,
            onMore: official.length > 2
                ? () => onOpenList(_SearchPage.official)
                : null,
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
        SizedBox(height: 10.h),
        if (tab != _SearchTab.assistant) ...[
          _InteractiveFilterBar(
            sortMode: sortMode,
            domainFilter: domainFilter,
            activeFilterCount: activeFilterCount,
            onSortChanged: onSortChanged,
            onDomainChanged: onDomainChanged,
            onOpenFilterPanel: onOpenFilterPanel,
          ),
          SizedBox(height: 12.h),
        ],
        if (tab == _SearchTab.assistant) ...[
          _AssistantOverviewCard(
            query: query,
            summary: aiSummary.isNotEmpty ? aiSummary : assistantResult.summary,
            isThinking: aiIsThinking,
            isNaturalQuestion: isNaturalQuestion,
            tone: aiTone,
            length: aiLength,
            syllogismAnalysis: syllogismAnalysis,
            onToneChanged: onToneChanged,
            onLengthChanged: onLengthChanged,
            onNotebookSave: onNotebookSave,
            onContinueChat: onContinueChat,
            defenseInsight: defenseInsight,
            onSaveToJournal: onSaveToJournal,
          ),
          SizedBox(height: 14.h),
        ],
        if (visible.isEmpty && tab != _SearchTab.assistant)
          _SearchStateCard(
            message: '這個分類目前沒有符合條件的結果。',
            actionLabel: activeFilterCount > 0 ? '重設篩選條件' : null,
            onAction: activeFilterCount > 0 ? onResetFilters : null,
          )
        else
          for (final item in visible.take(10)) ...[
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
    this.syllogismAnalysis,
    this.defenseInsight,
    this.onSaveToJournal,
  });

  final String query;
  final ValueChanged<_SearchPage> onOpen;
  final VoidCallback onContinue;
  final LegalSyllogismAnalysis? syllogismAnalysis;
  final LawAssistantDefenseInsight? defenseInsight;
  final VoidCallback? onSaveToJournal;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final keyword = query.trim().isEmpty ? '生活法律爭議' : query.trim();
    final insight =
        defenseInsight ?? LawAssistantDefenseInsight.fromContext(text: keyword);
    final analysis = syllogismAnalysis ??
        LegalSyllogismEngine.analyzeDispute(rawDisputeFacts: keyword);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.78,
            ),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
            decoration: BoxDecoration(
              color: t.brandPrimaryStrong,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: t.accentBrass.withValues(alpha: 0.35),
              ),
            ),
            child: Text(
              '請依三段論整理「$keyword」的法理依據與自保下一步。',
              style: _SearchText.bodyStrong(context).copyWith(
                color: const Color(0xFFFAF8F4),
              ),
            ),
          ),
        ),
        SizedBox(height: 14.h),
        _ProtoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    PhosphorIconsFill.scales,
                    size: 18.sp,
                    color: t.accentBrass,
                  ),
                  SizedBox(width: 7.w),
                  Expanded(
                    child: Text(
                      '小法助即時解方：${insight.disputeCategory}',
                      style: _SearchText.serifSection(context),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              _SyllogismStepsFlow(
                analysis: analysis,
                summary: analysis.conclusionRemedy,
              ),
              SizedBox(height: 14.h),
              Text('關鍵自保與蒐證清單', style: _SearchText.captionStrong(context)),
              SizedBox(height: 6.h),
              for (final ev in insight.keyEvidences) _CheckLine(text: ev),
              if (insight.statuteDeadline != null) ...[
                SizedBox(height: 12.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(11.w),
                  decoration: BoxDecoration(
                    color: t.semanticUrgentContainer,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: t.semanticUrgent.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        PhosphorIconsFill.clockCountdown,
                        size: 16.sp,
                        color: t.semanticUrgent,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          '${insight.statuteDeadline!.title}（${insight.statuteDeadline!.durationDays} 天）｜依據：${insight.statuteDeadline!.legalBasis}',
                          style: _SearchText.bodyStrong(context).copyWith(
                            color: t.semanticUrgent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: 12.h),
        _NextStep(
          label: '檢視相關法規條文',
          icon: PhosphorIconsRegular.bookBookmark,
          onTap: () => onOpen(_SearchPage.statutes),
        ),
        _NextStep(
          label: '檢視相關裁判案卷',
          icon: PhosphorIconsRegular.gavel,
          onTap: () => onOpen(_SearchPage.cases),
        ),
        _NextStep(
          label: '檢視生活避坑實務指南',
          icon: PhosphorIconsRegular.lightbulbFilament,
          onTap: () => onOpen(_SearchPage.lifeNotes),
        ),
        SizedBox(height: 14.h),
        if (onSaveToJournal != null) ...[
          _SecondaryButton(
            label: '建立「自救記事」進度追蹤',
            icon: PhosphorIconsRegular.folderSimplePlus,
            onPressed: onSaveToJournal!,
          ),
          SizedBox(height: 10.h),
        ],
        _PrimaryButton(
          label: '開啟多輪對話深入問診',
          icon: PhosphorIconsRegular.chatsCircle,
          onPressed: onContinue,
        ),
      ],
    );
  }
}

class _ResultList extends StatelessWidget {
  const _ResultList({
    required this.subListFilter,
    required this.onSubListChanged,
    required this.sortMode,
    required this.domainFilter,
    required this.activeFilterCount,
    required this.onSortChanged,
    required this.onDomainChanged,
    required this.onOpenFilterPanel,
    required this.onResetFilters,
    required this.items,
    required this.onOpen,
    required this.actionLabel,
    required this.isSaved,
    required this.onSaved,
    required this.onAction,
  });

  final _SubListFilter subListFilter;
  final ValueChanged<_SubListFilter> onSubListChanged;
  final _SearchSortMode sortMode;
  final _SearchDomainFilter domainFilter;
  final int activeFilterCount;
  final ValueChanged<_SearchSortMode> onSortChanged;
  final ValueChanged<_SearchDomainFilter> onDomainChanged;
  final VoidCallback onOpenFilterPanel;
  final VoidCallback onResetFilters;
  final List<_SearchResult> items;
  final ValueChanged<_SearchResult> onOpen;
  final String actionLabel;
  final bool Function(_SearchResult item) isSaved;
  final ValueChanged<_SearchResult> onSaved;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final hasAnyFilter =
        activeFilterCount > 0 || subListFilter != _SubListFilter.all;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SubListFilterStrip(
          selected: subListFilter,
          onChanged: onSubListChanged,
        ),
        SizedBox(height: 10.h),
        _InteractiveFilterBar(
          sortMode: sortMode,
          domainFilter: domainFilter,
          activeFilterCount: activeFilterCount,
          onSortChanged: onSortChanged,
          onDomainChanged: onDomainChanged,
          onOpenFilterPanel: onOpenFilterPanel,
        ),
        SizedBox(height: 14.h),
        if (items.isEmpty)
          _SearchStateCard(
            message: subListFilter != _SubListFilter.all
                ? '目前在「${subListFilter.label}」清單中尚無符合項目。'
                : '目前沒有符合條件的檢索結果。',
            actionLabel: hasAnyFilter ? '重設篩選條件' : null,
            onAction: hasAnyFilter ? onResetFilters : null,
          )
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
        _SecondaryButton(
          label: actionLabel,
          icon: PhosphorIconsRegular.bellRinging,
          onPressed: onAction,
        ),
      ],
    );
  }
}

class _StatuteDetail extends StatefulWidget {
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
  State<_StatuteDetail> createState() => _StatuteDetailState();
}

class _StatuteDetailState extends State<_StatuteDetail> {
  int _sectionIndex = 0; // 0: 雙重對照, 1: 條文原文, 2: 實務追問

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return FutureBuilder<List<StatuteItem>>(
      future: StatuteRepository().fetchAllStatutes(),
      builder: (context, snapshot) {
        final statuteList = snapshot.data ?? const [];
        StatuteItem? statute;
        for (final s in statuteList) {
          final key = 'statute-${s.codeName}-${s.articleNumber}';
          if (widget.item.id == key ||
              (widget.item.title.contains(s.codeName) &&
                  widget.item.title.contains(s.articleNumber))) {
            statute = s;
            break;
          }
        }

        final displayTitle = statute != null
            ? '${statute.codeName} ${statute.articleNumber}'
            : widget.item.title;
        final displayText = statute?.articleText ?? widget.item.summary;
        final displaySummary = statute?.plainLanguageSummary ??
            '本條文規範當事人間之法定權利義務要件，建議留存書面憑證以保障請求權。';
        final displayCategory = statute?.category ?? '現行法律';
        final copyPayload =
            '【$displayTitle】\n條文原文：$displayText\n白話結論：$displaySummary';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8.w,
              runSpacing: 6.h,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _SmallTag(label: '$displayCategory・施行中'),
                if (statute?.updatedDate.isNotEmpty == true)
                  Text(
                    '修正公布：${statute!.updatedDate}',
                    style: _SearchText.metric(
                      context,
                      size: 11.5.sp,
                      color: t.textMuted,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 10.h),
            Text(displayTitle, style: _SearchText.heroSmall(context)),
            SizedBox(height: 14.h),
            _DetailSectionSwitch(
              labels: const ['雙重對照', '條文原文', '實務追問'],
              selectedIndex: _sectionIndex,
              onSelected: (idx) => setState(() => _sectionIndex = idx),
            ),
            SizedBox(height: 16.h),
            if (_sectionIndex == 0 || _sectionIndex == 1) ...[
              Text('法定條文本文', style: _SearchText.section(context)),
              SizedBox(height: 8.h),
              _ProtoCard(
                child: Container(
                  padding: EdgeInsets.only(left: 10.w),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: t.brandPrimary, width: 3.w),
                    ),
                  ),
                  child: Text(
                    displayText,
                    style: _SearchText.serifBody(context).copyWith(
                      fontSize: 15.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 14.h),
            ],
            if (_sectionIndex == 0) ...[
              _DualCodedSummaryCard(
                plainConclusion: displaySummary,
                copyPayload: copyPayload,
                sectionLabel: '白話核心結論',
                copyLabel: '一鍵複製引用條文',
              ),
              SizedBox(height: 16.h),
            ],
            if (_sectionIndex == 1) ...[
              Align(
                alignment: Alignment.centerRight,
                child: _SecondaryButton(
                  label: '一鍵複製完整條文引用',
                  icon: PhosphorIconsRegular.copy,
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(text: '【$displayTitle】\n$displayText'),
                    );
                    CustomToast.show(context, '已複製 $displayTitle 條文原文');
                  },
                ),
              ),
              SizedBox(height: 16.h),
            ],
            if (statute != null && statute.tags.isNotEmpty) ...[
              Text('關聯爭點標籤', style: _SearchText.section(context)),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children:
                    statute.tags.map((tag) => _SmallTag(label: tag)).toList(),
              ),
              SizedBox(height: 16.h),
            ],
            if (_sectionIndex == 0 || _sectionIndex == 2) ...[
              _RelatedStatuteChips(
                statuteTitle: displayTitle,
                onNavigate: widget.onNavigateResult,
              ),
              SizedBox(height: 16.h),
              _ScenarioFollowUps(
                title: displayTitle,
                onAsk: widget.onAskScenario,
              ),
              SizedBox(height: 16.h),
            ],
            _ProtoCard(
              background: t.brandContainer,
              borderColor: t.brandPrimary.withValues(alpha: 0.28),
              elevated: false,
              onTap: widget.onAssistant,
              child: Row(
                children: [
                  Icon(
                    PhosphorIconsFill.chatsCircle,
                    color: t.brandPrimary,
                    size: 19.sp,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      '向小法助問診：${widget.item.title}在實際糾紛中怎麼主張？',
                      style: _SearchText.bodyStrong(context).copyWith(
                        color: t.brandOnContainer,
                      ),
                    ),
                  ),
                  Icon(
                    PhosphorIconsRegular.caretRight,
                    color: t.brandPrimary,
                    size: 16.sp,
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: _SecondaryButton(
                    label: widget.isFollowed ? '已追蹤法條' : '加入追蹤',
                    icon: widget.isFollowed
                        ? PhosphorIconsFill.bellRinging
                        : PhosphorIconsRegular.bell,
                    onPressed: widget.onFollow,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _SecondaryButton(
                    label: widget.isSaved ? '已收藏法條' : '歸檔收藏',
                    icon: widget.isSaved
                        ? PhosphorIconsFill.bookmarkSimple
                        : PhosphorIconsRegular.bookmarkSimple,
                    onPressed: widget.onSaved,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _CaseDetail extends StatefulWidget {
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
  State<_CaseDetail> createState() => _CaseDetailState();
}

class _CaseDetailState extends State<_CaseDetail> {
  int _sectionIndex = 0; // 0: 裁判要旨與對照, 1: 時序與延伸追問

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final caseId = widget.item.id.replaceFirst('case-', '');

    return FutureBuilder<LawCase?>(
      future: CaseRepository().getCaseDetail(caseId),
      builder: (context, snapshot) {
        final lawCase = snapshot.data;
        final displaySummary = lawCase?.summary ?? widget.item.summary;
        final displaySubtitle = lawCase?.subtitle ?? widget.item.source;
        final displayTitle = lawCase?.title ?? widget.item.title;
        final happenedAt = lawCase?.happenedAt;
        final dateStr = happenedAt != null
            ? '${happenedAt.year}.${happenedAt.month.toString().padLeft(2, '0')}.${happenedAt.day.toString().padLeft(2, '0')}'
            : '近期裁判';
        final caseResult = lawCase?.status ?? '實務見解';
        final caseCategory = lawCase?.category ?? '司法裁判';
        final takeaway = lawCase?.oneSentenceTakeaway ??
            '法院針對構成要件、契約義務與舉證責任進行實質審認，建議比對下方時序整理對話與金流憑證。';
        final copyPayload =
            '【$displayTitle】\n出處：$displaySubtitle\n判決要旨：$displaySummary\n白話核心結論：$takeaway';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8.w,
              runSpacing: 6.h,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _SmallTag(label: caseCategory),
                _SmallTag(label: caseResult, accent: true),
                Text(
                  dateStr,
                  style: _SearchText.metric(
                    context,
                    size: 11.5.sp,
                    color: t.textMuted,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Text(displayTitle, style: _SearchText.heroSmall(context)),
            if (displaySubtitle.trim().isNotEmpty) ...[
              SizedBox(height: 4.h),
              Text(displaySubtitle, style: _SearchText.caption(context)),
            ],
            SizedBox(height: 14.h),
            _DetailSectionSwitch(
              labels: const ['判決要旨對照', '時序與延伸追問'],
              selectedIndex: _sectionIndex,
              onSelected: (idx) => setState(() => _sectionIndex = idx),
            ),
            SizedBox(height: 14.h),
            if (_sectionIndex == 0) ...[
              _DualCodedSummaryCard(
                authoritativeExcerpt: displaySummary,
                plainConclusion: takeaway,
                copyPayload: copyPayload,
                sectionLabel: '白話核心結論',
                copyLabel: '一鍵複製引用要旨',
              ),
              SizedBox(height: 14.h),
            ],
            _ProtoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CaseTimelineVisualizer(
                    caseId: caseId,
                    title: displayTitle,
                  ),
                  if (lawCase != null && lawCase.tags.isNotEmpty) ...[
                    SizedBox(height: 12.h),
                    Text('爭點關鍵字', style: _SearchText.section(context)),
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
              onAsk: widget.onAskScenario,
            ),
            SizedBox(height: 14.h),
            _SecondaryButton(
              label: '前往司法院查詢裁判全文',
              icon: PhosphorIconsRegular.arrowSquareOut,
              onPressed: widget.onOpenFullText,
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Expanded(
                  child: _SecondaryButton(
                    label: widget.isFollowed ? '已追蹤案件' : '加入追蹤',
                    icon: widget.isFollowed
                        ? PhosphorIconsFill.bellRinging
                        : PhosphorIconsRegular.bell,
                    onPressed: widget.onFollow,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _SecondaryButton(
                    label: widget.isSaved ? '已收藏案件' : '歸檔收藏',
                    icon: widget.isSaved
                        ? PhosphorIconsFill.bookmarkSimple
                        : PhosphorIconsRegular.bookmarkSimple,
                    onPressed: widget.onSaved,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _LifeNoteList extends StatelessWidget {
  const _LifeNoteList({
    required this.items,
    required this.sortMode,
    required this.domainFilter,
    required this.activeFilterCount,
    required this.onSortChanged,
    required this.onDomainChanged,
    required this.onOpenFilterPanel,
    required this.onResetFilters,
    required this.onOpen,
    required this.onMore,
  });

  final List<_SearchResult> items;
  final _SearchSortMode sortMode;
  final _SearchDomainFilter domainFilter;
  final int activeFilterCount;
  final ValueChanged<_SearchSortMode> onSortChanged;
  final ValueChanged<_SearchDomainFilter> onDomainChanged;
  final VoidCallback onOpenFilterPanel;
  final VoidCallback onResetFilters;
  final ValueChanged<_SearchResult> onOpen;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InteractiveFilterBar(
          sortMode: sortMode,
          domainFilter: domainFilter,
          activeFilterCount: activeFilterCount,
          onSortChanged: onSortChanged,
          onDomainChanged: onDomainChanged,
          onOpenFilterPanel: onOpenFilterPanel,
        ),
        SizedBox(height: 14.h),
        if (items.isEmpty)
          _SearchStateCard(
            message: '目前沒有符合條件的避坑實務指南。',
            actionLabel: activeFilterCount > 0 ? '重設篩選條件' : null,
            onAction: activeFilterCount > 0 ? onResetFilters : null,
          )
        else
          for (final item in items) ...[
            _LifeCard(item: item, onTap: () => onOpen(item)),
            SizedBox(height: 10.h),
          ],
        SizedBox(height: 14.h),
        _SecondaryButton(
          label: '探索更多避坑實務主題',
          icon: PhosphorIconsRegular.compass,
          onPressed: onMore,
        ),
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
    final t = context.tokens;
    ArchiveUpdateItem? note;
    for (final update in archiveUpdateItems) {
      if (update.title == item.title || item.title.contains(update.title)) {
        note = update;
        break;
      }
    }

    final displayTitle = note?.title ?? item.title;
    final displaySummary = note?.summary ?? item.summary;
    final displayTime = note?.timeLabel ?? '近期整理';

    final List<String> checks = [];
    if (displayTitle.contains('租屋') || displaySummary.contains('租屋')) {
      checks.addAll([
        '點交拍照存證：退租點交時對牆面、地板與設備逐一拍照錄影並標記日期。',
        '區分自然折舊：正常使用老化依法由出租人承擔，不得要求承租人全額賠新。',
        '書面催告調解：若遭無理扣押金，可發送催告函或向鄉鎮市區公所聲請調解。',
      ]);
    } else if (displayTitle.contains('詐騙') || displaySummary.contains('詐騙')) {
      checks.addAll([
        '完整備份對話：截圖社群、通訊軟體或拍賣平台的對話紀錄與收款帳號。',
        '保存金流憑證：留存轉帳明細、匯款單與交易時間，切勿刪除原始紀錄。',
        '啟動 165 止付：黃金時間內撥打 165 專線並赴派出所完成報案筆錄。',
      ]);
    } else if (displayTitle.contains('退貨') ||
        displayTitle.contains('鑑賞期') ||
        displaySummary.contains('退貨') ||
        displaySummary.contains('鑑賞期')) {
      checks.addAll([
        '七日內書面通知：收受商品後七日內以訊息或存證方式明確表示解除契約。',
        '維持商品完整：僅作必要檢視，妥善保留原包裝、配件與贈品。',
        '線上消費申訴：業者若違法拒退，可向行政院消保處提出線上申訴。',
      ]);
    } else {
      checks.addAll([
        '保全原始證據：完整留存契約、對話紀錄、匯款單據與現場影像。',
        '整理事實時序：依發生日期條列人事時地物與金額，提升調解與訴訟效率。',
        '善用調解制度：優先透過公所調解委員會或消保／勞資管道低成本解決爭議。',
      ]);
    }

    final copyPayload =
        '【$displayTitle】\n核心摘要：$displaySummary\n實務自保步驟：\n${checks.map((c) => '- $c').join('\n')}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ProtoCard(
          background: t.brandContainer,
          borderColor: t.brandPrimary.withValues(alpha: 0.25),
          elevated: false,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _IconBox(
                icon: PhosphorIconsRegular.lightbulbFilament,
                color: t.brandPrimary,
                backgroundColor: t.surface,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayTitle,
                      style: _SearchText.serifSection(context).copyWith(
                        color: t.brandOnContainer,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      '實務自保指南・3 分鐘掌握・$displayTime',
                      style: _SearchText.caption(context).copyWith(
                        color: t.brandOnContainer.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 14.h),
        _DualCodedSummaryCard(
          plainConclusion: displaySummary,
          copyPayload: copyPayload,
          sectionLabel: '白話核心結論',
          copyLabel: '一鍵複製避坑重點',
        ),
        SizedBox(height: 16.h),
        Text('行動檢核清單', style: _SearchText.section(context)),
        SizedBox(height: 8.h),
        _ProtoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final check in checks) _CheckLine(text: check),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        _ScenarioFollowUps(
          title: displayTitle,
          onAsk: onAskScenario,
        ),
        SizedBox(height: 14.h),
        _PrimaryButton(
          label: isSaved ? '已收藏此避坑指南' : '歸檔收藏此指南',
          icon: isSaved
              ? PhosphorIconsFill.bookmarkSimple
              : PhosphorIconsRegular.bookmarkSimple,
          onPressed: onSaved,
        ),
      ],
    );
  }
}

class _OfficialList extends StatelessWidget {
  const _OfficialList({
    required this.items,
    required this.sortMode,
    required this.domainFilter,
    required this.activeFilterCount,
    required this.onSortChanged,
    required this.onDomainChanged,
    required this.onOpenFilterPanel,
    required this.onResetFilters,
    required this.onOpen,
    required this.onMore,
  });

  final List<_SearchResult> items;
  final _SearchSortMode sortMode;
  final _SearchDomainFilter domainFilter;
  final int activeFilterCount;
  final ValueChanged<_SearchSortMode> onSortChanged;
  final ValueChanged<_SearchDomainFilter> onDomainChanged;
  final VoidCallback onOpenFilterPanel;
  final VoidCallback onResetFilters;
  final ValueChanged<_SearchResult> onOpen;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InteractiveFilterBar(
          sortMode: sortMode,
          domainFilter: domainFilter,
          activeFilterCount: activeFilterCount,
          onSortChanged: onSortChanged,
          onDomainChanged: onDomainChanged,
          onOpenFilterPanel: onOpenFilterPanel,
        ),
        SizedBox(height: 14.h),
        if (items.isEmpty)
          _SearchStateCard(
            message: '目前沒有符合條件的官方公開資料。',
            actionLabel: activeFilterCount > 0 ? '重設篩選條件' : null,
            onAction: activeFilterCount > 0 ? onResetFilters : null,
          )
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
        _SecondaryButton(
          label: '前往司法與行政機關入口',
          icon: PhosphorIconsRegular.bank,
          onPressed: onMore,
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onSubmitted,
    required this.onClear,
    this.hintText,
    this.showFilter = false,
    this.activeFilterCount = 0,
    this.onFilter,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;
  final String? hintText;
  final bool showFilter;
  final int activeFilterCount;
  final VoidCallback? onFilter;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
      decoration: t.cardDecoration(
        radius: 999.r,
        fill: t.surface,
        borderColor: t.borderStrong,
      ),
      child: Row(
        children: [
          Icon(
            PhosphorIconsRegular.magnifyingGlass,
            color: t.brandPrimary,
            size: 19.sp,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: TextField(
              controller: controller,
              onTapOutside: (_) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              textInputAction: TextInputAction.search,
              onSubmitted: onSubmitted,
              style: _SearchText.bodyStrong(context),
              decoration: InputDecoration(
                hintText: hintText ?? '搜尋法條、裁判案卷、避坑實務或直接問診...',
                hintStyle: _SearchText.body(context).copyWith(
                  color: t.textMuted,
                ),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                border: InputBorder.none,
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                tooltip: '清除搜尋',
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  PhosphorIconsRegular.x,
                  color: t.textMuted,
                  size: 16.sp,
                ),
                onPressed: onClear,
              );
            },
          ),
          if (showFilter && onFilter != null)
            Tooltip(
              message: '進階篩選',
              child: InkWell(
                onTap: onFilter,
                borderRadius: BorderRadius.circular(999.r),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: activeFilterCount > 0
                        ? t.accentBrassContainer
                        : t.surfaceSubtle,
                    borderRadius: BorderRadius.circular(999.r),
                    border: Border.all(
                      color: activeFilterCount > 0
                          ? t.accentBrass.withValues(alpha: 0.45)
                          : t.border,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        PhosphorIconsRegular.slidersHorizontal,
                        color: activeFilterCount > 0
                            ? t.accentOnBrassContainer
                            : t.brandPrimary,
                        size: 15.sp,
                      ),
                      if (activeFilterCount > 0) ...[
                        SizedBox(width: 4.w),
                        Text(
                          '$activeFilterCount',
                          style: _SearchText.metric(
                            context,
                            size: 11.sp,
                            color: t.accentOnBrassContainer,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
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
      source: sourceParts.isEmpty ? '緒言 Preamble' : sourceParts.join('・'),
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
    title: '請小法助依三段論解析「$keyword」',
    summary: '自動比對相關法條、實務裁判與法定時效，整理具體自保行動步驟。',
    source: '緒言 Preamble 小法助',
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

/// 強制以必填 [BuildContext] 衍生所有文字樣式，徹底根除舊版省略 context 時在深色模式退回深墨色之對比度缺陷。
class _SearchText {
  static TextStyle serifHero(BuildContext context) =>
      context.tokens.serifTitle(size: 22.sp, weight: FontWeight.w700);

  static TextStyle heroSmall(BuildContext context) =>
      context.tokens.serifTitle(size: 19.sp, weight: FontWeight.w700);

  static TextStyle navTitle(BuildContext context) =>
      context.tokens.serifTitle(size: 17.sp, weight: FontWeight.w700);

  static TextStyle serifSection(BuildContext context) =>
      context.tokens.serifTitle(size: 15.5.sp, weight: FontWeight.w700);

  static TextStyle section(BuildContext context) =>
      context.tokens.sansTitle(size: 15.5.sp, weight: FontWeight.w700);

  static TextStyle serifTileTitle(BuildContext context) =>
      context.tokens.serifTitle(size: 14.5.sp, weight: FontWeight.w700);

  static TextStyle tileTitle(BuildContext context) =>
      context.tokens.sansTitle(size: 14.sp, weight: FontWeight.w700);

  static TextStyle serifBody(BuildContext context) =>
      context.tokens.serifBody(size: 14.sp, weight: FontWeight.w500);

  static TextStyle bodyStrong(BuildContext context) => context.tokens.sansBody(
        size: 13.sp,
        weight: FontWeight.w600,
        color: context.tokens.textPrimary,
        height: 1.52,
      );

  static TextStyle body(BuildContext context) => context.tokens.sansBody(
        size: 12.5.sp,
        weight: FontWeight.w500,
        color: context.tokens.textSecondary,
        height: 1.48,
      );

  static TextStyle caption(BuildContext context) => context.tokens.sansBody(
        size: 11.5.sp,
        weight: FontWeight.w500,
        color: context.tokens.textMuted,
        height: 1.36,
      );

  static TextStyle captionStrong(BuildContext context) =>
      context.tokens.sansBody(
        size: 11.5.sp,
        weight: FontWeight.w700,
        color: context.tokens.textPrimary,
        height: 1.32,
      );

  static TextStyle metric(
    BuildContext context, {
    double? size,
    Color? color,
  }) =>
      context.tokens.tabularMetric(
        size: size ?? 12.sp,
        weight: FontWeight.w700,
        color: color ?? context.tokens.textPrimary,
      );

  static TextStyle tab(BuildContext context) => context.tokens.sansBody(
        size: 13.sp,
        weight: FontWeight.w700,
        color: context.tokens.textPrimary,
        height: 1.25,
      );

  static TextStyle action(BuildContext context) => context.tokens.sansBody(
        size: 12.sp,
        weight: FontWeight.w700,
        color: context.tokens.brandPrimary,
        height: 1.25,
      );
}

const _assistantResults = [
  _SearchResult(
    type: _ResultType.assistant,
    title: '詐欺罪的成立要件是什麼？',
    summary: '依刑法第 339 條拆解施用詐術、陷於錯誤、處分財產與財產損害四大要件。',
    source: '緒言 Preamble 小法助',
    query: '詐欺',
  ),
];

const _statuteResults = [
  _SearchResult(
    type: _ResultType.statute,
    title: '民法第 184 條',
    summary: '因故意或過失，不法侵害他人之權利者，負損害賠償責任。',
    source: '民法・第 184 條・112.06.21 更新',
    query: '民法 184',
    sourceUrl: 'https://law.moj.gov.tw/LawClass/LawAll.aspx?pcode=B0000001',
    officialUrl: 'https://law.moj.gov.tw/LawClass/LawAll.aspx?pcode=B0000001',
  ),
  _SearchResult(
    type: _ResultType.statute,
    title: '民法第 429 條',
    summary: '租賃物之修繕，除契約另有訂定或另有習慣外，由出租人負擔。',
    source: '民法・第 429 條・112.06.21 更新',
    query: '民法 429',
    sourceUrl: 'https://law.moj.gov.tw/LawClass/LawAll.aspx?pcode=B0000001',
    officialUrl: 'https://law.moj.gov.tw/LawClass/LawAll.aspx?pcode=B0000001',
  ),
  _SearchResult(
    type: _ResultType.statute,
    title: '刑法第 339 條',
    summary: '意圖為自己或第三人不法之所有，以詐術使人將本人或第三人之物交付者。',
    source: '刑法・第 339 條・112.07.01 更新',
    query: '刑法 339',
    sourceUrl: 'https://law.moj.gov.tw/LawClass/LawAll.aspx?pcode=C0000001',
    officialUrl: 'https://law.moj.gov.tw/LawClass/LawAll.aspx?pcode=C0000001',
  ),
  _SearchResult(
    type: _ResultType.statute,
    title: '勞動基準法第 24 條',
    summary: '雇主延長勞工工作時間者，其延長工作時間之工資依本條標準加給。',
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
    summary: '被告以虛假投資資訊誘使被害人匯款，法院審認詐欺故意與相當因果關係。',
    source: '刑事・109 年・上訴・110.08.18',
    query: '詐欺案件',
  ),
  _SearchResult(
    type: _ResultType.caseItem,
    title: '臺灣高院 110 年台上字第 455 號',
    summary: '投資詐騙取款分工與共同正犯責任認定案例。',
    source: '刑事・110 年・上訴・111.10.25',
    query: '投資詐騙',
  ),
  _SearchResult(
    type: _ResultType.caseItem,
    title: '臺灣高等法院 111 年訴字第 760 號',
    summary: '帳戶提供與洗錢防制法幫助犯主觀認識爭點。',
    source: '刑事・111 年・一審・111.10.22',
    query: '洗錢',
  ),
];

const _lifeResults = [
  _SearchResult(
    type: _ResultType.lifeNote,
    title: '網購詐騙怎麼辦？5 步驟保全金流與報案',
    summary: '保存對話、訂單與轉帳明細，第一時間撥打 165 啟動緊急圈存。',
    source: '避坑實務・5 分鐘閱讀',
    query: '網購詐騙',
  ),
  _SearchResult(
    type: _ResultType.lifeNote,
    title: '退租點交押金遭扣？自然折舊與催告實務',
    summary: '區分自然耗損與人為毀損，掌握點交錄影與定相當期限催告流程。',
    source: '避坑實務・3 分鐘閱讀',
    query: '租屋押金',
  ),
];

const _officialResults = [
  _SearchResult(
    type: _ResultType.official,
    title: '內政部警政署 165 防詐騙通報與問答專區',
    summary: '最新詐欺手法通報、警示帳戶解除流程與防範指引彙整。',
    source: '警政署・官方防詐資訊',
    query: '防詐騙',
    sourceUrl: 'https://165.npa.gov.tw/',
    officialUrl: 'https://165.npa.gov.tw/',
  ),
  _SearchResult(
    type: _ResultType.official,
    title: '法務部反詐騙與民刑法宣導專區',
    summary: '司法機關整理常見法律爭議處理管道與防制宣導。',
    source: '法務部',
    query: '法務部 反詐騙',
    sourceUrl: 'https://www.moj.gov.tw/',
    officialUrl: 'https://www.moj.gov.tw/',
  ),
];

const _mockResults = [
  ..._assistantResults,
  ..._statuteResults,
  ..._caseResults,
  ..._lifeResults,
  ..._officialResults,
];
