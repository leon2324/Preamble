import 'package:lawapp/data/user/law_app_access_tier.dart';

/// LawApp 使用者資料。
///
/// 台灣繁體中文教學註解：
/// 這個 model 是 Flutter 端的「會員快照」，不是正式 auth token；
/// token 仍應由 AuthService/後端處理，UI 只透過這份資料判斷顯示與權限提示。
class LawAppUser {
  const LawAppUser({
    required this.id,
    required this.displayName,
    required this.email,
    required this.accessTier,
    required this.createdAt,
    required this.updatedAt,
    this.avatarUrl,
    this.savedCaseIds = const [],
    this.followedTopicIds = const [],
    this.usageQuota = 1,
    this.usedQuotaToday = 0,
    this.profession = 'citizen',
    this.aiStyle = 'simple',
  });

  final String id;
  final String displayName;
  final String email;
  final LawAppAccessTier accessTier;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? avatarUrl;
  final List<String> savedCaseIds;
  final List<String> followedTopicIds;
  final int usageQuota;
  final int usedQuotaToday;
  final String profession;
  final String aiStyle;

  int get remainingAiQuota {
    final remaining = usageQuota - usedQuotaToday;
    return remaining < 0 ? 0 : remaining;
  }

  bool get isGuest => accessTier == LawAppAccessTier.guest;

  factory LawAppUser.guest() {
    final now = DateTime.now();
    return LawAppUser(
      id: 'guest',
      displayName: '訪客',
      email: '',
      accessTier: LawAppAccessTier.guest,
      createdAt: now,
      updatedAt: now,
      usageQuota: LawAppAccessTier.guest.defaultDailyAiQuota,
      profession: 'citizen',
      aiStyle: 'simple',
    );
  }

  factory LawAppUser.demoMember() {
    final now = DateTime.now();
    return LawAppUser(
      id: 'demo-member',
      displayName: 'Demo 會員',
      email: 'member@lawapp.demo',
      accessTier: LawAppAccessTier.member,
      createdAt: now,
      updatedAt: now,
      usageQuota: LawAppAccessTier.member.defaultDailyAiQuota,
      profession: 'citizen',
      aiStyle: 'simple',
    );
  }

  factory LawAppUser.demoSubscriber() {
    final now = DateTime.now();
    return LawAppUser(
      id: 'demo-subscriber',
      displayName: 'Demo 訂閱者',
      email: 'subscriber@lawapp.demo',
      accessTier: LawAppAccessTier.subscriber,
      createdAt: now,
      updatedAt: now,
      usageQuota: LawAppAccessTier.subscriber.defaultDailyAiQuota,
      profession: 'lawyer',
      aiStyle: 'pro_analysis',
    );
  }

  factory LawAppUser.fromJson(Map<String, dynamic> json) {
    final tierText = _stringValue(json, const ['accessTier', 'access_tier']);
    final tier = LawAppAccessTier.values.firstWhere(
      (value) => value.name == tierText,
      orElse: () => LawAppAccessTier.guest,
    );

    final prof = _stringValue(json, const ['profession']);
    final style = _stringValue(json, const ['aiStyle', 'ai_style']);

    return LawAppUser(
      id: _stringValue(json, const ['id', 'userId', 'user_id']),
      displayName: _stringValue(json, const ['displayName', 'display_name']),
      email: _stringValue(json, const ['email']),
      accessTier: tier,
      createdAt: _dateTimeValue(json, const ['createdAt', 'created_at']),
      updatedAt: _dateTimeValue(json, const ['updatedAt', 'updated_at']),
      avatarUrl: _nullableString(json, const ['avatarUrl', 'avatar_url']),
      savedCaseIds: _stringList(json['savedCaseIds'] ?? json['saved_case_ids']),
      followedTopicIds: _stringList(
        json['followedTopicIds'] ?? json['followed_topic_ids'],
      ),
      usageQuota: _intValue(
        json,
        const ['usageQuota', 'usage_quota'],
        tier.defaultDailyAiQuota,
      ),
      usedQuotaToday: _intValue(
        json,
        const ['usedQuotaToday', 'used_quota_today'],
        0,
      ),
      profession: prof.isEmpty ? 'citizen' : prof,
      aiStyle: style.isEmpty ? 'simple' : style,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'email': email,
      'accessTier': accessTier.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (avatarUrl != null && avatarUrl!.isNotEmpty) 'avatarUrl': avatarUrl,
      'savedCaseIds': savedCaseIds,
      'followedTopicIds': followedTopicIds,
      'usageQuota': usageQuota,
      'usedQuotaToday': usedQuotaToday,
      'profession': profession,
      'aiStyle': aiStyle,
    };
  }

  LawAppUser copyWith({
    String? id,
    String? displayName,
    String? email,
    LawAppAccessTier? accessTier,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? avatarUrl,
    List<String>? savedCaseIds,
    List<String>? followedTopicIds,
    int? usageQuota,
    int? usedQuotaToday,
    String? profession,
    String? aiStyle,
  }) {
    return LawAppUser(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      accessTier: accessTier ?? this.accessTier,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      savedCaseIds: savedCaseIds ?? this.savedCaseIds,
      followedTopicIds: followedTopicIds ?? this.followedTopicIds,
      usageQuota: usageQuota ?? this.usageQuota,
      usedQuotaToday: usedQuotaToday ?? this.usedQuotaToday,
      profession: profession ?? this.profession,
      aiStyle: aiStyle ?? this.aiStyle,
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

String? _nullableString(Map<String, dynamic> json, List<String> keys) {
  final value = _stringValue(json, keys);
  return value.isEmpty ? null : value;
}

DateTime _dateTimeValue(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    final parsed = DateTime.tryParse(value.toString());
    if (parsed != null) return parsed;
  }
  return DateTime.now();
}

int _intValue(Map<String, dynamic> json, List<String> keys, int fallback) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    final parsed = int.tryParse(value.toString());
    if (parsed != null) return parsed;
  }
  return fallback;
}

List<String> _stringList(Object? value) {
  if (value is! List) return const [];
  return value
      .map((item) => item.toString().trim())
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}
