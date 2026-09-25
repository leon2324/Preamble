import 'package:preamble/components/shared/mvp_state_widgets.dart';
import 'package:preamble/data/documents/document_models.dart';
import 'package:preamble/data/law_assistant/law_assistant_api_service.dart';
import 'package:preamble/data/law_assistant/law_assistant_models.dart';
import 'package:preamble/data/legal_brain/legal_syllogism_engine.dart';
import 'package:preamble/utils/pii_data_masker.dart';
import 'package:preamble/utils/quota_manager.dart';
import 'package:preamble/utils/typing_simulator.dart';

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
    QuotaManager.instance.consumeQuota();
    final maskedPrompt = PiiDataMasker.mask(prompt);

    if (isBackendConfigured) {
      final conversation = await _apiService.createConversation(prompt: maskedPrompt);
      return conversation.copyWith(isGuest: isGuestSession);
    }

    final conversation = _mockConversation(maskedPrompt, isGuestSession);
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
    QuotaManager.instance.consumeQuota();
    final maskedPrompt = PiiDataMasker.mask(prompt);

    if (isBackendConfigured) {
      return _apiService.sendMessage(
        conversationId: conversationId,
        prompt: maskedPrompt,
      );
    }

    final existing =
        _mockConversations[conversationId] ?? _mockConversation(maskedPrompt, false);
    final now = DateTime.now();
    final messages = [
      ...existing.messages,
      LawAssistantMessage(
        id: 'mock-user-${now.microsecondsSinceEpoch}',
        role: LawAssistantMessageRole.user,
        content: maskedPrompt,
        createdAt: now,
      ),
      _mockAssistantMessage(maskedPrompt, now.add(const Duration(milliseconds: 1))),
    ];
    final updated = existing.copyWith(
      preview: maskedPrompt,
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
    QuotaManager.instance.consumeQuota();
    final maskedPrompt = PiiDataMasker.mask(prompt);

    if (isBackendConfigured) {
      yield* _apiService.sendMessageStream(
        conversationId: conversationId,
        prompt: maskedPrompt,
      );
      return;
    }

    // 離線/Mock 打字機模擬：每 30ms 輸出 2~4 個中文字
    final now = DateTime.now();
    final assistantMessage = _mockAssistantMessage(maskedPrompt, now);
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

    await for (final char in TypingSimulator.simulateString(fullText)) {
      yield LawAssistantStreamChunk(
        textChunk: char,
        isFinished: false,
        citations: _mockCitations,
        fullAnswer: answer,
      );
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
    final analysis = LegalSyllogismEngine.analyze(rawFacts: prompt);
    final insight = LawAssistantDefenseInsight(
      disputeCategory: analysis.disputeCategory,
      defensePoints: analysis.identifiedIssues,
      keyEvidences: analysis.evidenceChecklist,
      suggestedTemplateType: DocumentTemplateType.dynamicCustom,
      suggestedActionLabel: '生成${analysis.disputeCategory}公文書狀',
      extractedFacts: analysis.summaryOfFacts,
    );

    final citations = analysis.majorPremiseStatutes.map((s) {
      return LawAssistantCitation(
        title: s.fullCitation,
        sourceType: LawAssistantCitationSourceType.official,
        url: 'https://law.moj.gov.tw/',
        updatedAt: DateTime(2026, 1, 1),
      );
    }).toList();

    final statuteSummary = analysis.majorPremiseStatutes
        .map((s) => '• ${s.fullCitation}：${s.plainSummary}')
        .join('\n');
    final escalationSummary =
        analysis.escalationPath.map((e) => '➔ $e').join('\n');
    final evidenceSummary =
        analysis.evidenceChecklist.map((e) => '□ $e').join('\n');
    final issuesSummary =
        analysis.identifiedIssues.map((e) => '• $e').join('\n');
    final demandsSummary = analysis.demands.map((e) => '• $e').join('\n');

    return LawAssistantMessage(
      id: 'mock-assistant-${createdAt.microsecondsSinceEpoch}',
      role: LawAssistantMessageRole.assistant,
      content: analysis.toDetailedReport(),
      createdAt: createdAt,
      answer: LawAssistantAnswer(
        problemDirection:
            '【案件核心方向】：${analysis.disputeCategory}\n${analysis.summaryOfFacts}',
        relatedContent: '【大前提法規要件】：\n$statuteSummary',
        nextStep: '【後續司法救濟步驟】：\n$escalationSummary',
        evidenceNeeded: '【必備舉證清冊】：\n$evidenceSummary',
        possibleLegalIssues: '【關鍵法理爭點】：\n$issuesSummary',
        recommendedActions:
            '【具體請求主張（限期 ${analysis.recommendedDeadlineDays} 日）】：\n$demandsSummary',
        disclaimer: lawAppLegalDisclaimer,
      ),
      citations: citations.isNotEmpty ? citations : _mockCitations,
      warningText: '本分析由緒言法學三段論法大腦自主推導，已通過防幻覺法規校驗。',
      insight: insight,
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
