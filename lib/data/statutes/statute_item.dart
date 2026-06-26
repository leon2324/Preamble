/// 法條資料庫頁使用的條文資料模型。
///
/// 這個模型刻意只保留 App 需要呈現與搜尋的欄位，避免 UI 直接依賴
/// 全國法規資料庫 API 的原始 JSON 結構；之後若來源欄位調整，優先改
/// service 的轉換邏輯即可。
class StatuteItem {
  const StatuteItem({
    required this.codeName,
    required this.articleNumber,
    required this.articleText,
    required this.lawUrl,
    required this.category,
    required this.updatedDate,
    required this.isRepealed,
    required this.tags,
    this.sourceName = '全國法規資料庫',
    this.sourceType = 'official',
    this.plainLanguageSummary = '',
    this.relatedKeywords = const [],
  });

  final String codeName;
  final String articleNumber;
  final String articleText;
  final String lawUrl;
  final String category;
  final String updatedDate;
  final bool isRepealed;
  final List<String> tags;
  final String sourceName;
  final String sourceType;
  final String plainLanguageSummary;
  final List<String> relatedKeywords;

  String get displayTitle {
    if (articleNumber.isEmpty) return codeName;
    return '$codeName $articleNumber';
  }

  String get plainSummary {
    if (plainLanguageSummary.isNotEmpty) return plainLanguageSummary;
    final normalized = articleText.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.length <= 72) return normalized;
    return '${normalized.substring(0, 72)}...';
  }

  factory StatuteItem.fromJson(Map<String, dynamic> json) {
    return StatuteItem(
      codeName: _stringValue(json, const ['codeName', 'code_name']),
      articleNumber: _stringValue(
        json,
        const ['articleNumber', 'article_number'],
      ),
      articleText: _stringValue(json, const ['articleText', 'article_text']),
      lawUrl: _stringValue(json, const ['lawUrl', 'law_url', 'url']),
      category: _stringValue(json, const ['category']),
      updatedDate: _stringValue(json, const ['updatedDate', 'updated_date']),
      isRepealed: json['isRepealed'] == true || json['is_repealed'] == true,
      tags: _stringList(json['tags']),
      sourceName:
          _stringValue(json, const ['sourceName', 'source_name']).isEmpty
              ? '全國法規資料庫'
              : _stringValue(json, const ['sourceName', 'source_name']),
      sourceType:
          _stringValue(json, const ['sourceType', 'source_type']).isEmpty
              ? 'official'
              : _stringValue(json, const ['sourceType', 'source_type']),
      plainLanguageSummary: _stringValue(
        json,
        const ['plainLanguageSummary', 'plain_language_summary'],
      ),
      relatedKeywords: _stringList(
        json['relatedKeywords'] ?? json['related_keywords'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codeName': codeName,
      'articleNumber': articleNumber,
      'articleText': articleText,
      'lawUrl': lawUrl,
      'category': category,
      'updatedDate': updatedDate,
      'isRepealed': isRepealed,
      'tags': tags,
      'sourceName': sourceName,
      'sourceType': sourceType,
      'plainLanguageSummary': plainLanguageSummary,
      'relatedKeywords': relatedKeywords,
    };
  }

  bool matches(String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return true;
    final tokens = normalizedQuery
        .split(RegExp(r'\s+'))
        .where((token) => token.isNotEmpty)
        .toList(growable: false);

    final haystacks = [
      codeName,
      articleNumber,
      articleText,
      category,
      ...tags,
      ...relatedKeywords,
    ].map((value) => value.toLowerCase());

    // 使用者常會輸入「民法 184」這種多段式關鍵字；如果只拿整串字做
    // contains，比對不到「民法」與「第184條」分散在不同欄位的資料。
    // 因此改成每個 token 都要在任一搜尋欄位中出現，讓前端查詢更接近真搜尋。
    return tokens.every(
      (token) => haystacks.any((value) => value.contains(token)),
    );
  }
}

String _stringValue(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty) return text;
  }
  return '';
}

List<String> _stringList(Object? value) {
  if (value is! List) return const [];
  return value
      .map((item) => item.toString().trim())
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}
