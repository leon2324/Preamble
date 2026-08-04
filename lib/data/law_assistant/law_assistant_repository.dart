import 'package:preamble/components/shared/mvp_state_widgets.dart';
import 'package:preamble/data/law_assistant/law_assistant_api_service.dart';
import 'package:preamble/data/law_assistant/law_assistant_models.dart';

/// 小法助資料存取層。
///
/// UI 不直接判斷「要打後端還是 mock」，全部交給 repository；
/// 這樣後端尚未設定時 App 仍可展示完整流程，而且不會把 AI provider key 放在 Flutter。
class LawAssistantRepository {
  LawAssistantRepository({LawAssistantApiService? apiService})
      : _apiService = apiService ?? LawAssistantApiService();

  final LawAssistantApiService _apiService;
  final Map<String, LawAssistantConversation> _mockConversations = {};

  bool get isBackendConfigured => _apiService.hasConfiguredBackend;

  Future<List<LawAssistantConversation>> fetchRecentConversations() async {
    if (isBackendConfigured) {
      return _apiService.fetchRecentConversations();
    }

    return _mockConversations.values.toList(growable: false)
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<LawAssistantConversation> createConversation({
    required String prompt,
    bool isGuestSession = false,
  }) async {
    if (isBackendConfigured) {
      final conversation = await _apiService.createConversation(prompt: prompt);
      return conversation.copyWith(isGuest: isGuestSession);
    }

    final conversation = _mockConversation(prompt, isGuestSession);
    _mockConversations[conversation.id] = conversation;
    return conversation;
  }

  Future<LawAssistantConversation> fetchConversation(String id) async {
    if (isBackendConfigured) {
      return _apiService.fetchConversation(id);
    }

    return _mockConversations[id] ?? _mockConversation('租屋押金可以怎麼處理？', false);
  }

  Future<LawAssistantConversation> sendMessage({
    required String conversationId,
    required String prompt,
  }) async {
    if (isBackendConfigured) {
      return _apiService.sendMessage(
        conversationId: conversationId,
        prompt: prompt,
      );
    }

    final existing =
        _mockConversations[conversationId] ?? _mockConversation(prompt, false);
    final now = DateTime.now();
    final messages = [
      ...existing.messages,
      LawAssistantMessage(
        id: 'mock-user-${now.microsecondsSinceEpoch}',
        role: LawAssistantMessageRole.user,
        content: prompt,
        createdAt: now,
      ),
      _mockAssistantMessage(prompt, now.add(const Duration(milliseconds: 1))),
    ];
    final updated = existing.copyWith(
      preview: prompt,
      updatedAt: now,
      messages: messages,
      isMock: true,
    );
    _mockConversations[updated.id] = updated;
    return updated;
  }

  Stream<LawAssistantStreamChunk> sendMessageStream({
    required String conversationId,
    required String prompt,
  }) async* {
    if (isBackendConfigured) {
      yield* _apiService.sendMessageStream(
        conversationId: conversationId,
        prompt: prompt,
      );
      return;
    }

    // 離線/Mock 打字機模擬：每 30ms 輸出 2~4 個中文字
    final now = DateTime.now();
    final assistantMessage = _mockAssistantMessage(prompt, now);
    final answer = assistantMessage.answer;

    final fullTextParts = [
      if (answer != null) ...[
        '【問題方向】\n${answer.problemDirection}',
        '【相關內容】\n${answer.relatedContent}',
        '【可能法律爭點】\n${answer.possibleLegalIssues}',
        '【先準備的證據】\n${answer.evidenceNeeded}',
        '【建議行動】\n${answer.recommendedActions}',
      ] else
        assistantMessage.content,
    ];

    final fullText = fullTextParts.join('\n\n');
    const chunkSize = 3;

    for (var i = 0; i < fullText.length; i += chunkSize) {
      final end = (i + chunkSize < fullText.length) ? i + chunkSize : fullText.length;
      final chunk = fullText.substring(i, end);
      yield LawAssistantStreamChunk(
        textChunk: chunk,
        isFinished: false,
        citations: _mockCitations,
        fullAnswer: answer,
      );
      await Future<void>.delayed(const Duration(milliseconds: 30));
    }

    yield LawAssistantStreamChunk(
      textChunk: '',
      isFinished: true,
      citations: _mockCitations,
      fullAnswer: answer,
    );
  }

  void dispose() {
    _apiService.dispose();
  }

  LawAssistantConversation _mockConversation(
    String prompt,
    bool isGuestSession,
  ) {
    final now = DateTime.now();
    final id = 'mock-${now.microsecondsSinceEpoch}';
    return LawAssistantConversation(
      id: id,
      title: prompt.length > 18 ? '${prompt.substring(0, 18)}...' : prompt,
      preview: prompt,
      updatedAt: now,
      categoryLabel: _categoryForPrompt(prompt),
      isGuest: isGuestSession,
      isMock: true,
      sourceCitations: _mockCitations,
      messages: [
        LawAssistantMessage(
          id: '$id-user',
          role: LawAssistantMessageRole.user,
          content: prompt,
          createdAt: now,
        ),
        _mockAssistantMessage(prompt, now.add(const Duration(milliseconds: 1))),
      ],
    );
  }

  LawAssistantMessage _mockAssistantMessage(String prompt, DateTime createdAt) {
    return LawAssistantMessage(
      id: 'mock-assistant-${createdAt.microsecondsSinceEpoch}',
      role: LawAssistantMessageRole.assistant,
      content: '這是後端未設定時的本機示範回答。',
      createdAt: createdAt,
      answer: LawAssistantAnswer(
        problemDirection: _directionForPrompt(prompt),
        relatedContent: '請先整理契約、對話紀錄、付款紀錄、照片與日期時間軸。若牽涉期限或訴訟，應優先諮詢律師。',
        nextStep: '你可以補充：事件日期、對方主張、你手上有哪些證據、目前想達成的結果。',
        evidenceNeeded: '合約、收據、LINE 對話、照片、錄音錄影、官方文件或通知。',
        possibleLegalIssues: '契約責任、侵權責任、消費爭議、勞資爭議或刑事風險會依具體事實不同。',
        recommendedActions: '先保存證據，再用書面提出具體請求；重大案件請找律師或法律扶助。',
        disclaimer: lawAppLegalDisclaimer,
      ),
      citations: _mockCitations,
      warningText: '目前為 mock mode，正式回答需由後端 RAG 與資料來源回傳。',
    );
  }

  String _categoryForPrompt(String prompt) {
    if (prompt.contains('租') || prompt.contains('押金')) return '租屋';
    if (prompt.contains('加班') || prompt.contains('公司')) return '勞資';
    if (prompt.contains('車禍') || prompt.contains('事故')) return '交通';
    if (prompt.contains('網購') || prompt.contains('退貨')) return '消費';
    return '一般法律知識';
  }

  String _directionForPrompt(String prompt) {
    final category = _categoryForPrompt(prompt);
    return '這看起來可能是「$category」相關問題。小法助會先幫你拆成事實、證據、可能法規與下一步行動。';
  }
}

final _mockCitations = [
  LawAssistantCitation(
    title: '全國法規資料庫',
    sourceType: LawAssistantCitationSourceType.official,
    url: 'https://law.moj.gov.tw/',
    updatedAt: DateTime(2026, 1, 1),
  ),
  LawAssistantCitation(
    title: '緒言 Preamble 示範回答模板',
    sourceType: LawAssistantCitationSourceType.other,
    updatedAt: DateTime(2026, 5, 5),
  ),
];
