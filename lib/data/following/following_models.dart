class FollowingSummary {
  const FollowingSummary({
    this.followedTopicIds = const [],
    this.followedCaseIds = const [],
    this.followedStatuteIds = const [],
    this.followedKeywords = const [],
    this.savedCaseIds = const [],
    this.savedStatuteIds = const [],
    this.savedArticleIds = const [],
    this.notificationEnabled = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 追蹤與收藏都放在同一份 summary，是為了讓「全站搜尋」、「法規頁」與
  /// 「我的 Preamble」不用各自維護一份 bool。UI 只要看這個模型，就能知道
  /// 目前使用者追蹤/收藏了哪些案件、法條、主題、關鍵字或文章。
  final List<String> followedTopicIds;
  final List<String> followedCaseIds;
  final List<String> followedStatuteIds;
  final List<String> followedKeywords;
  final List<String> savedCaseIds;
  final List<String> savedStatuteIds;
  final List<String> savedArticleIds;
  final bool notificationEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory FollowingSummary.empty() {
    final now = DateTime.now();
    return FollowingSummary(createdAt: now, updatedAt: now);
  }

  factory FollowingSummary.fromJson(Map<String, dynamic> json) {
    return FollowingSummary(
      followedTopicIds: _stringList(json['followedTopicIds']),
      followedCaseIds: _stringList(json['followedCaseIds']),
      followedStatuteIds: _stringList(json['followedStatuteIds']),
      followedKeywords: _stringList(json['followedKeywords']),
      savedCaseIds: _stringList(json['savedCaseIds']),
      savedStatuteIds: _stringList(json['savedStatuteIds']),
      savedArticleIds: _stringList(json['savedArticleIds']),
      notificationEnabled: json['notificationEnabled'] == true,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'followedTopicIds': followedTopicIds,
        'followedCaseIds': followedCaseIds,
        'followedStatuteIds': followedStatuteIds,
        'followedKeywords': followedKeywords,
        'savedCaseIds': savedCaseIds,
        'savedStatuteIds': savedStatuteIds,
        'savedArticleIds': savedArticleIds,
        'notificationEnabled': notificationEnabled,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  FollowingSummary copyWith({
    List<String>? followedTopicIds,
    List<String>? followedCaseIds,
    List<String>? followedStatuteIds,
    List<String>? followedKeywords,
    List<String>? savedCaseIds,
    List<String>? savedStatuteIds,
    List<String>? savedArticleIds,
    bool? notificationEnabled,
    DateTime? updatedAt,
  }) {
    return FollowingSummary(
      followedTopicIds: followedTopicIds ?? this.followedTopicIds,
      followedCaseIds: followedCaseIds ?? this.followedCaseIds,
      followedStatuteIds: followedStatuteIds ?? this.followedStatuteIds,
      followedKeywords: followedKeywords ?? this.followedKeywords,
      savedCaseIds: savedCaseIds ?? this.savedCaseIds,
      savedStatuteIds: savedStatuteIds ?? this.savedStatuteIds,
      savedArticleIds: savedArticleIds ?? this.savedArticleIds,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class FollowedUpdateItem {
  const FollowedUpdateItem({
    required this.id,
    required this.title,
    required this.summary,
    required this.source,
    required this.updatedAt,
    required this.type,
  });

  final String id;
  final String title;
  final String summary;
  final String source;
  final DateTime updatedAt;
  final String type;

  factory FollowedUpdateItem.fromJson(Map<String, dynamic> json) {
    return FollowedUpdateItem(
      id: _stringValue(json, const ['id', 'updateId', 'update_id']),
      title: _stringValue(json, const ['title']),
      summary: _stringValue(json, const ['summary', 'description']),
      source: _stringValue(json, const ['source']),
      updatedAt: DateTime.tryParse(
            _stringValue(json, const ['updatedAt', 'updated_at']),
          ) ??
          DateTime.now(),
      type: _stringValue(json, const ['type', 'category']),
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
