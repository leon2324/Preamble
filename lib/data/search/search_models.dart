enum SearchResultType {
  assistant,
  statute,
  caseItem,
  news,
  document,
  tool,
}

class SearchResultItem {
  const SearchResultItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.snippet,
    required this.type,
    required this.destination,
    required this.score,
    required this.source,
    required this.updatedAt,
    this.sourceUrl = '',
    this.officialUrl = '',
    this.tags = const [],
  });

  final String id;
  final String title;
  final String subtitle;
  final String snippet;
  final SearchResultType type;
  final String destination;
  final double score;
  final String source;
  final DateTime updatedAt;
  final String sourceUrl;
  final String officialUrl;
  final List<String> tags;

  String get preferredSourceUrl =>
      officialUrl.trim().isNotEmpty ? officialUrl.trim() : sourceUrl.trim();

  factory SearchResultItem.fromJson(Map<String, dynamic> json) {
    return SearchResultItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      snippet: json['snippet']?.toString() ?? '',
      type: SearchResultType.values.firstWhere(
        (type) =>
            type.name == json['type']?.toString() ||
            (type == SearchResultType.caseItem &&
                json['type']?.toString() == 'case'),
        orElse: () => SearchResultType.tool,
      ),
      destination: json['destination']?.toString() ?? '',
      score: double.tryParse(json['score']?.toString() ?? '') ?? 0,
      source: json['source']?.toString() ?? '',
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
      sourceUrl: _stringValue(
        json,
        const ['sourceUrl', 'source_url', 'url'],
      ),
      officialUrl: _stringValue(
        json,
        const ['officialUrl', 'official_url', 'originalUrl', 'original_url'],
      ),
      tags: _stringList(json['tags']),
    );
  }

  // 台灣繁體中文教學註解：
  // sourceUrl 是資料索引或來源頁，officialUrl 是可直接查核的官方原文；
  // 序列化時保留兩者，讓搜尋頁、我的收藏與小法助引用未來能共用同一套來源資訊。
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'snippet': snippet,
        'type': type == SearchResultType.caseItem ? 'case' : type.name,
        'destination': destination,
        'score': score,
        'source': source,
        'updatedAt': updatedAt.toIso8601String(),
        if (sourceUrl.isNotEmpty) 'sourceUrl': sourceUrl,
        if (officialUrl.isNotEmpty) 'officialUrl': officialUrl,
        'tags': tags,
      };

  bool matches(String query) {
    final tokens = query
        .trim()
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((token) => token.isNotEmpty);
    final fields = [
      title,
      subtitle,
      snippet,
      source,
      sourceUrl,
      officialUrl,
      ...tags,
    ].map((value) => value.toLowerCase());
    return tokens.every(
      (token) => fields.any((value) => value.contains(token)),
    );
  }
}

List<String> _stringList(Object? value) {
  if (value is! List) return const [];
  return value
      .map((item) => item.toString().trim())
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
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
