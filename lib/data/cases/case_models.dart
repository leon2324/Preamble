enum CasePrivacyLevel {
  public,
  limited,
  sensitive,
}

class LawCaseTimelineItem {
  const LawCaseTimelineItem({
    required this.date,
    required this.title,
    required this.description,
    this.sourceUrl = '',
  });

  final DateTime? date;
  final String title;
  final String description;
  final String sourceUrl;

  factory LawCaseTimelineItem.fromJson(Map<String, dynamic> json) {
    return LawCaseTimelineItem(
      date: DateTime.tryParse(json['date']?.toString() ?? ''),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      sourceUrl: json['sourceUrl']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        if (date != null) 'date': date!.toIso8601String(),
        'title': title,
        'description': description,
        if (sourceUrl.isNotEmpty) 'sourceUrl': sourceUrl,
      };
}

class LawCaseLegalIssue {
  const LawCaseLegalIssue({
    required this.title,
    required this.explanation,
    this.relatedLawName = '',
    this.relatedArticleNumber = '',
    this.riskLevel = 'medium',
  });

  final String title;
  final String explanation;
  final String relatedLawName;
  final String relatedArticleNumber;
  final String riskLevel;

  factory LawCaseLegalIssue.fromJson(Map<String, dynamic> json) {
    return LawCaseLegalIssue(
      title: json['title']?.toString() ?? '',
      explanation: json['explanation']?.toString() ?? '',
      relatedLawName: json['relatedLawName']?.toString() ?? '',
      relatedArticleNumber: json['relatedArticleNumber']?.toString() ?? '',
      riskLevel: json['riskLevel']?.toString() ?? 'medium',
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'explanation': explanation,
        if (relatedLawName.isNotEmpty) 'relatedLawName': relatedLawName,
        if (relatedArticleNumber.isNotEmpty)
          'relatedArticleNumber': relatedArticleNumber,
        'riskLevel': riskLevel,
      };
}

class LawCaseSourceLink {
  const LawCaseSourceLink({
    required this.title,
    required this.url,
    required this.sourceType,
    this.publisher = '',
    this.publishedAt,
    this.accessedAt,
  });

  final String title;
  final String url;
  final String sourceType;
  final String publisher;
  final DateTime? publishedAt;
  final DateTime? accessedAt;

  factory LawCaseSourceLink.fromJson(Map<String, dynamic> json) {
    return LawCaseSourceLink(
      title: json['title']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      sourceType: json['sourceType']?.toString() ?? 'other',
      publisher: json['publisher']?.toString() ?? '',
      publishedAt: DateTime.tryParse(json['publishedAt']?.toString() ?? ''),
      accessedAt: DateTime.tryParse(json['accessedAt']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'url': url,
        'sourceType': sourceType,
        if (publisher.isNotEmpty) 'publisher': publisher,
        if (publishedAt != null) 'publishedAt': publishedAt!.toIso8601String(),
        if (accessedAt != null) 'accessedAt': accessedAt!.toIso8601String(),
      };
}

/// 正式案件資料模型。
///
/// 舊的 CaseStoryItem 偏 UI 示範；LawCase 是資料庫與後端要對齊的 MVP 模型，
/// 欄位包含來源、是否 mock、隱私層級與可供搜尋/篩選的 era/category/tags。
class LawCase {
  const LawCase({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.summary,
    required this.oneSentenceTakeaway,
    required this.country,
    required this.location,
    required this.happenedAt,
    required this.updatedAt,
    required this.status,
    required this.category,
    this.tags = const [],
    this.timeline = const [],
    this.legalIssues = const [],
    this.relatedStatutes = const [],
    this.sourceLinks = const [],
    this.privacyLevel = CasePrivacyLevel.public,
    this.isMockData = true,
    this.imageAsset = '',
    this.era = '',
    this.discussionPoints = const [],
    this.learningPoints = const [],
  });

  final String id;
  final String title;
  final String subtitle;
  final String summary;
  final String oneSentenceTakeaway;
  final String country;
  final String location;
  final DateTime? happenedAt;
  final DateTime updatedAt;
  final String status;
  final String category;
  final List<String> tags;
  final List<LawCaseTimelineItem> timeline;
  final List<LawCaseLegalIssue> legalIssues;
  final List<String> relatedStatutes;
  final List<LawCaseSourceLink> sourceLinks;
  final CasePrivacyLevel privacyLevel;
  final bool isMockData;
  final String imageAsset;
  final String era;
  final List<String> discussionPoints;
  final List<String> learningPoints;

  factory LawCase.fromJson(Map<String, dynamic> json) {
    return LawCase(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      summary: json['summary']?.toString() ?? '',
      oneSentenceTakeaway: json['oneSentenceTakeaway']?.toString() ??
          json['one_sentence_takeaway']?.toString() ??
          '',
      country: json['country']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      happenedAt: DateTime.tryParse(json['happenedAt']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
      status: json['status']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      tags: _stringList(json['tags']),
      timeline: _modelList(json['timeline'], LawCaseTimelineItem.fromJson),
      legalIssues: _modelList(json['legalIssues'], LawCaseLegalIssue.fromJson),
      relatedStatutes: _stringList(json['relatedStatutes']),
      sourceLinks: _modelList(json['sourceLinks'], LawCaseSourceLink.fromJson),
      privacyLevel: CasePrivacyLevel.values.firstWhere(
        (level) => level.name == json['privacyLevel']?.toString(),
        orElse: () => CasePrivacyLevel.public,
      ),
      isMockData: json['isMockData'] != false,
      imageAsset: json['imageAsset']?.toString() ?? '',
      era: json['era']?.toString() ?? '',
      discussionPoints: _stringList(json['discussionPoints']),
      learningPoints: _stringList(json['learningPoints']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'summary': summary,
        'oneSentenceTakeaway': oneSentenceTakeaway,
        'country': country,
        'location': location,
        if (happenedAt != null) 'happenedAt': happenedAt!.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'status': status,
        'category': category,
        'tags': tags,
        'timeline': timeline.map((item) => item.toJson()).toList(),
        'legalIssues': legalIssues.map((item) => item.toJson()).toList(),
        'relatedStatutes': relatedStatutes,
        'sourceLinks': sourceLinks.map((item) => item.toJson()).toList(),
        'privacyLevel': privacyLevel.name,
        'isMockData': isMockData,
        if (imageAsset.isNotEmpty) 'imageAsset': imageAsset,
        'era': era,
        'discussionPoints': discussionPoints,
        'learningPoints': learningPoints,
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
      summary,
      oneSentenceTakeaway,
      category,
      era,
      ...tags,
      ...discussionPoints,
      ...learningPoints,
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

List<T> _modelList<T>(
  Object? value,
  T Function(Map<String, dynamic>) parser,
) {
  if (value is! List) return const [];
  return value.whereType<Map<String, dynamic>>().map(parser).toList();
}
