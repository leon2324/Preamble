import 'package:preamble/data/cases/case_models.dart';
import 'package:preamble/data/cases/case_repository.dart';
import 'package:preamble/data/journal/journal_repository.dart';
import 'package:preamble/data/search/search_api_service.dart';
import 'package:preamble/data/search/search_models.dart';
import 'package:preamble/data/statutes/statute_repository.dart';

class SearchRepository {
  SearchRepository({
    CaseRepository? caseRepository,
    JournalRepository? journalRepository,
    StatuteRepository? statuteRepository,
    SearchApiService? searchApiService,
    List<SearchResultItem>? seedResults,
  })  : _caseRepository = caseRepository ?? CaseRepository(),
        _journalRepository = journalRepository ?? const JournalRepository(),
        _statuteRepository = statuteRepository ?? StatuteRepository(),
        _searchApiService = searchApiService ?? SearchApiService(),
        _ownsCaseRepository = caseRepository == null,
        _ownsStatuteRepository = statuteRepository == null,
        _ownsSearchApiService = searchApiService == null,
        _seedResults = seedResults ?? _mockResults;

  final CaseRepository _caseRepository;
  final JournalRepository _journalRepository;
  final StatuteRepository _statuteRepository;
  final SearchApiService _searchApiService;
  // 台灣繁體中文教學註解：搜尋會組合多個資料來源；只釋放自己建立的依賴，
  // 並記得釋放自建的案件 repository，避免其 HTTP client 長期佔用資源。
  final bool _ownsCaseRepository;
  final bool _ownsStatuteRepository;
  final bool _ownsSearchApiService;
  final List<SearchResultItem> _seedResults;

  Future<List<SearchResultItem>> searchAll(String query) async {
    if (_searchApiService.hasConfiguredBackend) {
      try {
        final remoteResults = await _searchApiService.searchAll(query);
        if (remoteResults.isNotEmpty) return remoteResults;
      } catch (__) {
        // 降級回本機多庫聯合檢索
      }
    }

    final mixed = <SearchResultItem>[
      ...await searchStatutes(query),
      ...await searchCases(query),
      ...await searchJournal(query),
      ...await searchAssistantHistory(query),
      ...await searchNews(query),
      ..._seedResults.where((item) => item.matches(query)),
    ];

    final unique = <String, SearchResultItem>{};
    for (final item in mixed) {
      unique[item.id] = item;
    }
    final results = unique.values.toList(growable: false)
      ..sort((a, b) => b.score.compareTo(a.score));
    return results;
  }

  Future<List<SearchResultItem>> searchStatutes(String query) async {
    final result = await _statuteRepository.searchStatutes(query: query);
    return result.items.take(8).map((item) {
      return SearchResultItem(
        id: 'statute-${item.codeName}-${item.articleNumber}',
        title: item.displayTitle,
        subtitle: item.category,
        snippet: item.plainSummary,
        type: SearchResultType.statute,
        destination: 'statutes:${item.codeName}:${item.articleNumber}',
        score: 80,
        source: item.sourceName,
        updatedAt: DateTime.tryParse(item.updatedDate) ?? DateTime(2026, 5, 5),
        sourceUrl: item.lawUrl,
        officialUrl: item.lawUrl,
        tags: item.tags,
      );
    }).toList(growable: false);
  }

  Future<List<SearchResultItem>> searchCases(String query) async {
    final cases = await _caseRepository.searchCases(query);
    return cases.take(8).map((item) {
      final caseSourceUrl = _officialSourceUrlForCase(item);
      return SearchResultItem(
        id: 'case-${item.id}',
        title: item.title,
        subtitle: item.category,
        snippet: item.summary,
        type: SearchResultType.caseItem,
        destination: 'case:${item.id}',
        score: 75,
        source:
            item.isMockData ? '緒言 Preamble mock data' : '緒言 Preamble case API',
        updatedAt: item.updatedAt,
        sourceUrl: caseSourceUrl,
        officialUrl: caseSourceUrl,
        tags: item.tags,
      );
    }).toList(growable: false);
  }

  Future<List<SearchResultItem>> searchJournal(String query) async {
    final results = await _journalRepository.searchJournal(query);
    return results.take(8).map((item) {
      final isLifeNote = item.typeLabel == '生活避坑' ||
          item.typeLabel == '防詐筆記' ||
          item.typeLabel == '社會討論' ||
          item.tags.contains('生活避坑') ||
          item.tags.contains('防詐筆記');
      return SearchResultItem(
        id: 'journal-${item.id}',
        title: item.title,
        subtitle: item.typeLabel,
        snippet: item.summary,
        type:
            isLifeNote ? SearchResultType.document : SearchResultType.caseItem,
        destination: 'journal:${item.id}',
        score: item.score.toDouble(),
        source: item.source,
        updatedAt: DateTime(2026, 5, 5),
        sourceUrl: _sourceUrlForJournalResult(item),
        tags: item.tags,
      );
    }).toList(growable: false);
  }

  Future<List<SearchResultItem>> searchAssistantHistory(String query) async {
    return _seedResults
        .where((item) =>
            item.type == SearchResultType.assistant && item.matches(query))
        .toList(growable: false);
  }

  Future<List<SearchResultItem>> searchNews(String query) async {
    return _seedResults
        .where(
            (item) => item.type == SearchResultType.news && item.matches(query))
        .toList(growable: false);
  }

  void dispose() {
    if (_ownsCaseRepository) _caseRepository.dispose();
    if (_ownsStatuteRepository) _statuteRepository.dispose();
    if (_ownsSearchApiService) _searchApiService.dispose();
  }
}

final _mockResults = [
  SearchResultItem(
    id: 'tool-law-assistant',
    title: '小法助',
    subtitle: 'AI 法律知識整理',
    snippet: '輸入生活情境，整理可能法律方向、證據與下一步。',
    type: SearchResultType.assistant,
    destination: 'assistant',
    score: 60,
    source: '緒言 Preamble',
    updatedAt: DateTime(2026, 5, 5),
    tags: ['AI', '法律助理', '問答'],
  ),
  SearchResultItem(
    id: 'document-deposit',
    title: '押金返還通知草稿',
    subtitle: '文件產生',
    snippet: '用本地模板產生租屋押金協商訊息。',
    type: SearchResultType.document,
    destination: 'documents:deposit',
    score: 55,
    source: '緒言 Preamble local template',
    updatedAt: DateTime(2026, 5, 5),
    tags: ['租屋', '押金', '文件'],
  ),
  SearchResultItem(
    id: 'official-moj',
    title: '法務部公開資料',
    subtitle: '官方資料',
    snippet: '顯示標題、來源與官方連結，不複製新聞全文。',
    type: SearchResultType.news,
    destination: 'official:moj',
    score: 40,
    source: '法務部',
    updatedAt: DateTime(2026, 5, 5),
    sourceUrl: 'https://www.moj.gov.tw/',
    officialUrl: 'https://www.moj.gov.tw/',
    tags: ['官方', '新聞', '公告'],
  ),
];

String _officialSourceUrlForCase(LawCase item) {
  // 案件 mock 可能帶 example.local 這種示範 URL，不能當成真官方來源。
  // 這裡只把看起來可公開查核的 http(s) 來源帶到搜尋結果；沒有就讓頁面退回司法院查詢入口。
  for (final link in item.sourceLinks) {
    final url = link.url.trim();
    if (!_isUsablePublicUrl(url)) continue;
    if (link.sourceType == 'official' ||
        link.publisher.contains('法院') ||
        link.publisher.contains('司法院')) {
      return url;
    }
  }
  return '';
}

String _sourceUrlForJournalResult(JournalSearchResult item) {
  switch (item.type) {
    case JournalSearchResultType.trend:
    case JournalSearchResultType.archiveUpdate:
    case JournalSearchResultType.archiveDossier:
    case JournalSearchResultType.onThisDay:
    case JournalSearchResultType.caseBook:
      return '';
  }
}

bool _isUsablePublicUrl(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null || !uri.hasScheme || uri.host.isEmpty) return false;
  if (uri.scheme != 'https' && uri.scheme != 'http') return false;
  if (uri.host.contains('example.')) return false;
  if (uri.host.endsWith('.local')) return false;
  return true;
}
