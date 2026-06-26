import 'package:preamble/features/case_time_machine/data/case_time_machine_mock_data.dart';
import 'package:preamble/pages/journal/data/journal_page_items.dart';

enum JournalSearchResultType {
  trend,
  archiveUpdate,
  archiveDossier,
  onThisDay,
  caseBook,
}

class JournalSearchResult {
  const JournalSearchResult({
    required this.id,
    required this.type,
    required this.typeLabel,
    required this.title,
    required this.summary,
    required this.source,
    required this.score,
    this.tags = const [],
  });

  final String id;
  final JournalSearchResultType type;
  final String typeLabel;
  final String title;
  final String summary;
  final String source;
  final int score;
  final List<String> tags;
}

/// 記事與案件資料館搜尋 repository。
///
/// 記事頁、案件圖書館與全站搜尋最終都應該讀同一個案件/卷宗索引。
/// 目前資料仍來自 app 內建 mock data，但先集中在 repository，日後接後端
/// 只要把這裡改成 API 或本機索引，頁面就不用重寫搜尋比對規則。
class JournalRepository {
  const JournalRepository();

  Future<List<JournalSearchResult>> searchJournal(String query) async {
    final tokens = _tokensFor(query);
    if (tokens.isEmpty) return const [];

    final results = <JournalSearchResult>[];
    _addTrendResults(tokens, results);
    _addArchiveUpdateResults(tokens, results);
    _addArchiveDossierResults(tokens, results);
    _addOnThisDayResult(tokens, results);
    _addCaseBookResults(tokens, results);

    final unique = <String, JournalSearchResult>{};
    for (final result in results) {
      unique[result.id] = result;
    }
    final sorted = unique.values.toList(growable: false)
      ..sort((a, b) => b.score.compareTo(a.score));
    return sorted;
  }

  void _addTrendResults(
    List<String> tokens,
    List<JournalSearchResult> results,
  ) {
    for (final item in discussionTrendItems) {
      final fields = [item.title, item.whyHot, ...item.relatedCases];
      final score = _score(tokens, fields) + (100 - item.rank);
      if (score <= 0 || !_matches(tokens, fields)) continue;
      results.add(
        JournalSearchResult(
          id: 'trend-${item.rank}-${_slugFor(item.title)}',
          type: JournalSearchResultType.trend,
          typeLabel: '社會討論',
          title: item.title,
          summary: item.whyHot,
          source: '記事趨勢排行',
          score: score,
          tags: item.relatedCases,
        ),
      );
    }
  }

  void _addArchiveUpdateResults(
    List<String> tokens,
    List<JournalSearchResult> results,
  ) {
    for (final item in archiveUpdateItems) {
      final fields = [item.type, item.title, item.summary, item.timeLabel];
      final score = _score(tokens, fields) + 70;
      if (score <= 0 || !_matches(tokens, fields)) continue;
      results.add(
        JournalSearchResult(
          id: 'archive-update-${_slugFor(item.type)}-${_slugFor(item.title)}',
          type: JournalSearchResultType.archiveUpdate,
          typeLabel: item.type,
          title: item.title,
          summary: item.summary,
          source: '資料館動態・${item.timeLabel}',
          score: score,
          tags: [item.type],
        ),
      );
    }
  }

  void _addArchiveDossierResults(
    List<String> tokens,
    List<JournalSearchResult> results,
  ) {
    for (final item in archiveDossierItems) {
      final fields = [
        item.era,
        item.title,
        item.summary,
        item.tag,
        item.fullDate,
        item.location,
        item.statusLabel,
        item.lead,
        ...item.keyPoints,
        ...item.sources,
      ];
      final score = _score(tokens, fields) + 80;
      if (score <= 0 || !_matches(tokens, fields)) continue;
      results.add(
        JournalSearchResult(
          id: 'archive-dossier-${item.id}',
          type: JournalSearchResultType.archiveDossier,
          typeLabel: item.tag,
          title: item.title,
          summary: item.summary,
          source: '資料館卷宗・${item.era}',
          score: score,
          tags: [item.era, item.tag, ...item.keyPoints],
        ),
      );
    }
  }

  void _addOnThisDayResult(
    List<String> tokens,
    List<JournalSearchResult> results,
  ) {
    final fields = [
      onThisDayItem.label,
      onThisDayItem.title,
      onThisDayItem.summary,
      onThisDayItem.quote,
      onThisDayItem.location,
      onThisDayItem.fullDate,
    ];
    final score = _score(tokens, fields) + 65;
    if (score <= 0 || !_matches(tokens, fields)) return;
    results.add(
      JournalSearchResult(
        id: 'on-this-day-${_slugFor(onThisDayItem.title)}',
        type: JournalSearchResultType.onThisDay,
        typeLabel: onThisDayItem.label,
        title: onThisDayItem.title,
        summary: onThisDayItem.summary,
        source: '${onThisDayItem.fullDate}・${onThisDayItem.location}',
        score: score,
        tags: [onThisDayItem.label, onThisDayItem.location],
      ),
    );
  }

  void _addCaseBookResults(
    List<String> tokens,
    List<JournalSearchResult> results,
  ) {
    for (final book in caseTimeMachineCases) {
      final fields = [
        book.titleZh,
        book.titleEn,
        book.shortTitleZh,
        '${book.year}',
        book.category,
        book.shortDescription,
        book.location,
        book.memoryLine,
        book.background,
        book.fullStory,
        ...book.tags,
        ...book.legalIssues.map((issue) => issue.title),
        ...book.legalIssues.map((issue) => issue.plainExplanation),
        ...book.sources.map((source) => source.title),
        ...book.timeline.map((item) => item.description),
      ];
      final score = _score(tokens, fields) + 60;
      if (score <= 0 || !_matches(tokens, fields)) continue;
      results.add(
        JournalSearchResult(
          id: 'case-book-${book.id}',
          type: JournalSearchResultType.caseBook,
          typeLabel: book.category,
          title: book.titleZh,
          summary: book.shortDescription,
          source: '案件圖書館・${book.year}',
          score: score,
          tags: ['${book.year}', book.category, ...book.tags],
        ),
      );
    }
  }
}

List<String> _tokensFor(String query) {
  return query
      .trim()
      .toLowerCase()
      .split(RegExp(r'\s+'))
      .where((token) => token.isNotEmpty)
      .toList(growable: false);
}

bool _matches(List<String> tokens, List<String> fields) {
  final normalizedFields = fields.map((value) => value.toLowerCase()).toList();
  return tokens.every(
    (token) => normalizedFields.any((value) => value.contains(token)),
  );
}

int _score(List<String> tokens, List<String> fields) {
  final normalizedFields = fields.map((value) => value.toLowerCase()).toList();
  var score = 0;
  for (final token in tokens) {
    for (final field in normalizedFields) {
      if (field == token) {
        score += 20;
      } else if (field.startsWith(token)) {
        score += 12;
      } else if (field.contains(token)) {
        score += 6;
      }
    }
  }
  return score;
}

String _slugFor(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'\s+'), '')
      .replaceAll(RegExp(r'[^a-z0-9\u4e00-\u9fff]+'), '');
}
