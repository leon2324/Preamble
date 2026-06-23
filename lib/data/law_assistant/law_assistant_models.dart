import 'package:lawapp/components/shared/mvp_state_widgets.dart';

enum LawAssistantMessageRole {
  user,
  assistant,
  system,
}

enum LawAssistantCitationSourceType {
  statute,
  judgment,
  official,
  news,
  other,
}

/// AI 回答的引用來源。
///
/// 台灣繁體中文教學註解：
/// 引用來源要和回答一起被保存，避免 UI 只顯示 AI 文字卻看不到法規、判決或官方資料來源。
class LawAssistantCitation {
  const LawAssistantCitation({
    required this.title,
    required this.sourceType,
    this.url = '',
    this.publishedAt,
    this.updatedAt,
    this.lawName = '',
    this.articleNumber = '',
  });

  final String title;
  final LawAssistantCitationSourceType sourceType;
  final String url;
  final DateTime? publishedAt;
  final DateTime? updatedAt;
  final String lawName;
  final String articleNumber;

  factory LawAssistantCitation.fromJson(Map<String, dynamic> json) {
    return LawAssistantCitation(
      title: _stringValue(json, const ['title', 'name']),
      sourceType: _citationType(
        _stringValue(json, const ['sourceType', 'source_type']),
      ),
      url: _stringValue(json, const ['url', 'sourceUrl', 'source_url']),
      publishedAt: _nullableDateTime(json, const ['publishedAt']),
      updatedAt: _nullableDateTime(json, const ['updatedAt', 'updated_at']),
      lawName: _stringValue(json, const ['lawName', 'law_name']),
      articleNumber: _stringValue(
        json,
        const ['articleNumber', 'article_number'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'sourceType': sourceType.name,
      if (url.isNotEmpty) 'url': url,
      if (publishedAt != null) 'publishedAt': publishedAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      if (lawName.isNotEmpty) 'lawName': lawName,
      if (articleNumber.isNotEmpty) 'articleNumber': articleNumber,
    };
  }

  SourceCitationViewData toViewData() {
    return SourceCitationViewData(
      title: title,
      sourceType: sourceType.name,
      url: url,
      updatedAt: updatedAt,
      lawName: lawName,
      articleNumber: articleNumber,
    );
  }
}

/// 小法助回覆的分段資料。
class LawAssistantAnswer {
  const LawAssistantAnswer({
    required this.problemDirection,
    required this.relatedContent,
    required this.nextStep,
    this.evidenceNeeded = '',
    this.possibleLegalIssues = '',
    this.recommendedActions = '',
    this.disclaimer = lawAppLegalDisclaimer,
  });

  final String problemDirection;
  final String relatedContent;
  final String nextStep;
  final String evidenceNeeded;
  final String possibleLegalIssues;
  final String recommendedActions;
  final String disclaimer;

  factory LawAssistantAnswer.fromJson(Map<String, dynamic> json) {
    return LawAssistantAnswer(
      problemDirection: _stringValue(
        json,
        const ['problemDirection', 'problem_direction', 'direction'],
      ),
      relatedContent: _stringValue(
        json,
        const ['relatedContent', 'related_content', 'related'],
      ),
      nextStep: _stringValue(json, const ['nextStep', 'next_step', 'next']),
      evidenceNeeded: _stringValue(
        json,
        const ['evidenceNeeded', 'evidence_needed'],
      ),
      possibleLegalIssues: _stringValue(
        json,
        const ['possibleLegalIssues', 'possible_legal_issues'],
      ),
      recommendedActions: _stringValue(
        json,
        const ['recommendedActions', 'recommended_actions'],
      ),
      disclaimer: _stringValue(json, const ['disclaimer']).isEmpty
          ? lawAppLegalDisclaimer
          : _stringValue(json, const ['disclaimer']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'problemDirection': problemDirection,
      'relatedContent': relatedContent,
      'nextStep': nextStep,
      if (evidenceNeeded.isNotEmpty) 'evidenceNeeded': evidenceNeeded,
      if (possibleLegalIssues.isNotEmpty)
        'possibleLegalIssues': possibleLegalIssues,
      if (recommendedActions.isNotEmpty)
        'recommendedActions': recommendedActions,
      'disclaimer': disclaimer,
    };
  }

  bool get isEmpty =>
      problemDirection.isEmpty &&
      relatedContent.isEmpty &&
      nextStep.isEmpty &&
      evidenceNeeded.isEmpty &&
      possibleLegalIssues.isEmpty &&
      recommendedActions.isEmpty;
}

class LawAssistantMessage {
  const LawAssistantMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
    this.answer,
    this.citations = const [],
    this.warningText = '',
  });

  final String id;
  final LawAssistantMessageRole role;
  final String content;
  final DateTime createdAt;
  final LawAssistantAnswer? answer;
  final List<LawAssistantCitation> citations;
  final String warningText;

  factory LawAssistantMessage.fromJson(Map<String, dynamic> json) {
    final answerJson = json['answer'] ?? json['answerSections'];
    final roleText = _stringValue(json, const ['role']).toLowerCase();

    return LawAssistantMessage(
      id: _stringValue(json, const ['id', 'messageId', 'message_id']),
      role: LawAssistantMessageRole.values.firstWhere(
        (role) => role.name == roleText,
        orElse: () => LawAssistantMessageRole.user,
      ),
      content: _stringValue(json, const ['content', 'text', 'message']),
      createdAt: _dateTimeValue(json, const ['createdAt', 'created_at']),
      answer: answerJson is Map<String, dynamic>
          ? LawAssistantAnswer.fromJson(answerJson)
          : null,
      citations: _citations(json['citations']),
      warningText: _stringValue(json, const ['warningText', 'warning_text']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role.name,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      if (answer != null) 'answer': answer!.toJson(),
      if (citations.isNotEmpty)
        'citations': citations.map((citation) => citation.toJson()).toList(),
      if (warningText.isNotEmpty) 'warningText': warningText,
    };
  }
}

class LawAssistantConversation {
  const LawAssistantConversation({
    required this.id,
    required this.title,
    required this.preview,
    required this.updatedAt,
    required this.categoryLabel,
    this.messages = const [],
    this.sourceCitations = const [],
    this.disclaimer = lawAppLegalDisclaimer,
    this.isGuest = false,
    this.isMock = false,
  });

  final String id;
  final String title;
  final String preview;
  final DateTime updatedAt;
  final String categoryLabel;
  final List<LawAssistantMessage> messages;
  final List<LawAssistantCitation> sourceCitations;
  final String disclaimer;
  final bool isGuest;
  final bool isMock;

  factory LawAssistantConversation.fromJson(Map<String, dynamic> json) {
    final messagesJson = json['messages'];

    return LawAssistantConversation(
      id: _stringValue(json, const ['id', 'conversationId', 'conversation_id']),
      title: _stringValue(json, const ['title']),
      preview: _stringValue(json, const ['preview', 'summary']),
      updatedAt: _dateTimeValue(json, const ['updatedAt', 'updated_at']),
      categoryLabel: _stringValue(
        json,
        const ['categoryLabel', 'category_label', 'category'],
      ),
      messages: messagesJson is List
          ? messagesJson
              .whereType<Map<String, dynamic>>()
              .map(LawAssistantMessage.fromJson)
              .toList(growable: false)
          : const [],
      sourceCitations: _citations(
        json['sourceCitations'] ?? json['source_citations'],
      ),
      disclaimer: _stringValue(json, const ['disclaimer']).isEmpty
          ? lawAppLegalDisclaimer
          : _stringValue(json, const ['disclaimer']),
      isGuest: json['isGuest'] == true,
      isMock: json['isMock'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'preview': preview,
      'updatedAt': updatedAt.toIso8601String(),
      'categoryLabel': categoryLabel,
      'messages': messages.map((message) => message.toJson()).toList(),
      if (sourceCitations.isNotEmpty)
        'sourceCitations': sourceCitations
            .map((citation) => citation.toJson())
            .toList(growable: false),
      'disclaimer': disclaimer,
      'isGuest': isGuest,
      'isMock': isMock,
    };
  }

  LawAssistantConversation copyWith({
    String? id,
    String? title,
    String? preview,
    DateTime? updatedAt,
    String? categoryLabel,
    List<LawAssistantMessage>? messages,
    List<LawAssistantCitation>? sourceCitations,
    String? disclaimer,
    bool? isGuest,
    bool? isMock,
  }) {
    return LawAssistantConversation(
      id: id ?? this.id,
      title: title ?? this.title,
      preview: preview ?? this.preview,
      updatedAt: updatedAt ?? this.updatedAt,
      categoryLabel: categoryLabel ?? this.categoryLabel,
      messages: messages ?? this.messages,
      sourceCitations: sourceCitations ?? this.sourceCitations,
      disclaimer: disclaimer ?? this.disclaimer,
      isGuest: isGuest ?? this.isGuest,
      isMock: isMock ?? this.isMock,
    );
  }
}

List<LawAssistantCitation> _citations(Object? value) {
  if (value is! List) return const [];
  return value
      .whereType<Map<String, dynamic>>()
      .map(LawAssistantCitation.fromJson)
      .toList(growable: false);
}

LawAssistantCitationSourceType _citationType(String value) {
  return LawAssistantCitationSourceType.values.firstWhere(
    (type) => type.name == value,
    orElse: () => LawAssistantCitationSourceType.other,
  );
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

DateTime _dateTimeValue(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    final parsed = DateTime.tryParse(value.toString());
    if (parsed != null) return parsed;
  }
  return DateTime.now();
}

DateTime? _nullableDateTime(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    final parsed = DateTime.tryParse(value.toString());
    if (parsed != null) return parsed;
  }
  return null;
}
