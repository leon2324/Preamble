enum LawAssistantMessageRole {
  user,
  assistant,
}

/// 小法助回覆的三段式資料。
///
/// 後端可以換不同 AI provider，但 Flutter 端先固定吃這三個欄位，讓畫面
/// 穩定呈現「問題方向、相關內容、下一步」。
class LawAssistantAnswer {
  const LawAssistantAnswer({
    required this.problemDirection,
    required this.relatedContent,
    required this.nextStep,
  });

  final String problemDirection;
  final String relatedContent;
  final String nextStep;

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
      nextStep: _stringValue(
        json,
        const ['nextStep', 'next_step', 'next'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'problemDirection': problemDirection,
      'relatedContent': relatedContent,
      'nextStep': nextStep,
    };
  }

  bool get isEmpty =>
      problemDirection.isEmpty && relatedContent.isEmpty && nextStep.isEmpty;
}

class LawAssistantMessage {
  const LawAssistantMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
    this.answer,
  });

  final String id;
  final LawAssistantMessageRole role;
  final String content;
  final DateTime createdAt;
  final LawAssistantAnswer? answer;

  factory LawAssistantMessage.fromJson(Map<String, dynamic> json) {
    final answerJson = json['answer'];
    final roleText = _stringValue(json, const ['role']).toLowerCase();

    return LawAssistantMessage(
      id: _stringValue(json, const ['id', 'messageId', 'message_id']),
      role: roleText == 'assistant'
          ? LawAssistantMessageRole.assistant
          : LawAssistantMessageRole.user,
      content: _stringValue(json, const ['content', 'text', 'message']),
      createdAt: _dateTimeValue(json, const ['createdAt', 'created_at']),
      answer: answerJson is Map<String, dynamic>
          ? LawAssistantAnswer.fromJson(answerJson)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role.name,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      if (answer != null) 'answer': answer!.toJson(),
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
    this.isGuest = false,
  });

  final String id;
  final String title;
  final String preview;
  final DateTime updatedAt;
  final String categoryLabel;
  final List<LawAssistantMessage> messages;
  final bool isGuest;

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
      isGuest: json['isGuest'] == true,
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
      'isGuest': isGuest,
    };
  }

  LawAssistantConversation copyWith({
    String? id,
    String? title,
    String? preview,
    DateTime? updatedAt,
    String? categoryLabel,
    List<LawAssistantMessage>? messages,
    bool? isGuest,
  }) {
    return LawAssistantConversation(
      id: id ?? this.id,
      title: title ?? this.title,
      preview: preview ?? this.preview,
      updatedAt: updatedAt ?? this.updatedAt,
      categoryLabel: categoryLabel ?? this.categoryLabel,
      messages: messages ?? this.messages,
      isGuest: isGuest ?? this.isGuest,
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

DateTime _dateTimeValue(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    final parsed = DateTime.tryParse(value.toString());
    if (parsed != null) return parsed;
  }
  return DateTime.now();
}
