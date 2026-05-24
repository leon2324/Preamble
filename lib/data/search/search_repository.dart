import 'package:lawapp/data/cases/case_models.dart';
import 'package:lawapp/data/cases/case_repository.dart';
import 'package:lawapp/data/journal/journal_repository.dart';
import 'package:lawapp/data/search/search_models.dart';
import 'package:lawapp/data/statutes/statute_repository.dart';

class SearchRepository {
  SearchRepository({
    CaseRepository? caseRepository,
    JournalRepository? journalRepository,
    StatuteRepository? statuteRepository,
    List<SearchResultItem>? seedResults,
  })  : _caseRepository = caseRepository ?? CaseRepository(),
        _journalRepository = journalRepository ?? const JournalRepository(),
        _statuteRepository = statuteRepository ?? StatuteRepository(),
        _seedResults = seedResults ?? _mockResults;

  final CaseRepository _caseRepository;
  final JournalRepository _journalRepository;
  final StatuteRepository _statuteRepository;
  final List<SearchResultItem> _seedResults;

  Future<List<SearchResultItem>> searchAll(String query) async {
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
        source: item.isMockData ? 'LawApp mock data' : 'LawApp case API',
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
      return SearchResultItem(
        id: 'journal-${item.id}',
        title: item.title,
        subtitle: item.typeLabel,
        snippet: item.summary,
        type: SearchResultType.caseItem,
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
    // 台灣繁體中文教學註解：
    // SearchRepository 目前只擁有法規資料 repository 的 HTTP client；
    // 之後若全站搜尋改接獨立後端 API，也把關閉連線的責任集中在這裡。
    _statuteRepository.dispose();
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
    source: 'LawApp',
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
    source: 'LawApp local template',
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
  // 台灣繁體中文教學註解：
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
