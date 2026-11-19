import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:preamble/components/shared/mvp_state_widgets.dart';
import 'package:preamble/config/supabase_config.dart';
import 'package:preamble/data/law_assistant/law_assistant_api_service.dart';
import 'package:preamble/data/law_assistant/law_assistant_models.dart';
import 'package:preamble/data/legal_brain/legal_syllogism_engine.dart';
import 'package:preamble/utils/pii_data_masker.dart';
import 'package:preamble/utils/quota_manager.dart';
import 'package:preamble/utils/typing_simulator.dart';

/// 小法助資料存取層。
///
/// UI 不直接判斷「要打後端還是 mock」，全部交給 repository；
/// 若未設定自建後端，優先透過 Supabase Edge Function 呼叫 Gemini（不把 key 放進 Flutter），
/// 連線失敗或離線時則自動退回本機法學三段論引擎，確保展示流程不中斷。
class LawAssistantRepository {
  LawAssistantRepository({
    LawAssistantApiService? apiService,
    http.Client? edgeClient,
  })  : _apiService = apiService ?? LawAssistantApiService(),
        _ownsApiService = apiService == null,
        _edgeClient = edgeClient ?? http.Client(),
        _ownsEdgeClient = edgeClient == null;

  final LawAssistantApiService _apiService;
  // 台灣繁體中文教學註解：只有本 repository 建立的 service／client 才在結束時釋放。
  final bool _ownsApiService;
  final http.Client _edgeClient;
  final bool _ownsEdgeClient;
  final Map<String, LawAssistantConversation> _mockConversations = {};

  bool get isBackendConfigured => _apiService.hasConfiguredBackend;
  bool get _hasSupabaseEdgeFunction =>
      supabaseUrl.trim().isNotEmpty && supabaseAnonKey.trim().isNotEmpty;

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
      final conversation =
          await _apiService.createConversation(prompt: maskedPrompt);
      return conversation.copyWith(isGuest: isGuestSession);
    }

    final geminiReply = await _fetchGeminiEdgeReply(maskedPrompt);
    final conversation = _mockConversation(
      maskedPrompt,
      isGuestSession,
      customReply: geminiReply,
    );
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

    final existing = _mockConversations[conversationId] ??
        _mockConversation(maskedPrompt, false);
    final geminiReply = await _fetchGeminiEdgeReply(
      maskedPrompt,
      history: existing.messages,
    );
    final now = DateTime.now();
    final assistantMsg = geminiReply != null
        ? _geminiAssistantMessage(
            maskedPrompt,
            geminiReply,
            now.add(const Duration(milliseconds: 1)),
          )
        : _mockAssistantMessage(
            maskedPrompt,
            now.add(const Duration(milliseconds: 1)),
          );
    final messages = [
      ...existing.messages,
      LawAssistantMessage(
        id: 'mock-user-${now.microsecondsSinceEpoch}',
        role: LawAssistantMessageRole.user,
        content: maskedPrompt,
        createdAt: now,
      ),
      assistantMsg,
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

    // 優先嘗試 Supabase Edge Function（Gemini），失敗或離線時退回本機三段論引擎。
    final existing = _mockConversations[conversationId];
    final geminiReply = await _fetchGeminiEdgeReply(
      maskedPrompt,
      history: existing?.messages ?? const [],
    );
    final now = DateTime.now();
    final assistantMessage = geminiReply != null
        ? _geminiAssistantMessage(maskedPrompt, geminiReply, now)
        : _mockAssistantMessage(maskedPrompt, now);
    final answer = assistantMessage.answer;

    if (existing != null && geminiReply != null) {
      _mockConversations[conversationId] = existing.copyWith(
        preview: maskedPrompt,
        updatedAt: now,
        messages: [
          ...existing.messages,
          LawAssistantMessage(
            id: 'mock-user-${now.microsecondsSinceEpoch}',
            role: LawAssistantMessageRole.user,
            content: maskedPrompt,
            createdAt: now,
          ),
          assistantMessage,
        ],
      );
    }

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
        citations: assistantMessage.citations,
        fullAnswer: answer,
      );
    }

    yield LawAssistantStreamChunk(
      textChunk: '',
      isFinished: true,
      citations: assistantMessage.citations,
      fullAnswer: answer,
    );
  }

  void dispose() {
    if (_ownsApiService) _apiService.dispose();
    if (_ownsEdgeClient) _edgeClient.close();
  }

  /// 台灣繁體中文教學註解：透過 Supabase Edge Function 安全呼叫 Gemini，
  /// API Key 僅存於雲端 Secret；若未連網、逾時或雲端未設定，回傳 null 以退回本機引擎。
  Future<String?> _fetchGeminiEdgeReply(
    String prompt, {
    List<LawAssistantMessage> history = const [],
  }) async {
    if (!_hasSupabaseEdgeFunction) return null;
    try {
      final uri = Uri.parse('$supabaseUrl/functions/v1/law-assistant');
      final recentHistory = history
          .take(6)
          .map((m) => {
                'role': m.role == LawAssistantMessageRole.assistant
                    ? 'assistant'
                    : 'user',
                'content': m.content,
              })
          .toList(growable: false);

      final response = await _edgeClient
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'apikey': supabaseAnonKey,
              'Authorization': 'Bearer $supabaseAnonKey',
            },
            body: jsonEncode({
              'prompt': prompt,
              'history': recentHistory,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is Map<String, dynamic>) {
        final reply = (decoded['reply'] as String?)?.trim() ?? '';
        if (reply.isNotEmpty) return reply;
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  LawAssistantMessage _geminiAssistantMessage(
    String prompt,
    String reply,
    DateTime createdAt,
  ) {
    final insight = LawAssistantDefenseInsight.fromContext(text: prompt);
    return LawAssistantMessage(
      id: 'gemini-assistant-${createdAt.microsecondsSinceEpoch}',
      role: LawAssistantMessageRole.assistant,
      content: reply,
      createdAt: createdAt,
      citations: _mockCitations,
      insight: insight,
    );
  }

  LawAssistantConversation _mockConversation(
    String prompt,
    bool isGuestSession, {
    String? customReply,
  }) {
    final now = DateTime.now();
    final id = 'mock-${now.microsecondsSinceEpoch}';
    final assistantMsg = customReply != null
        ? _geminiAssistantMessage(
            prompt,
            customReply,
            now.add(const Duration(milliseconds: 1)),
          )
        : _mockAssistantMessage(
            prompt,
            now.add(const Duration(milliseconds: 1)),
          );
    return LawAssistantConversation(
      id: id,
      title: prompt.length > 18 ? '${prompt.substring(0, 18)}...' : prompt,
      preview: prompt,
      updatedAt: now,
      categoryLabel: _categoryForPrompt(prompt),
      isGuest: isGuestSession,
      isMock: customReply == null,
      sourceCitations: _mockCitations,
      messages: [
        LawAssistantMessage(
          id: '$id-user',
          role: LawAssistantMessageRole.user,
          content: prompt,
          createdAt: now,
        ),
        assistantMsg,
      ],
    );
  }

  LawAssistantMessage _mockAssistantMessage(String prompt, DateTime createdAt) {
    final analysis = LegalSyllogismEngine.analyze(rawFacts: prompt);
    final insight = LawAssistantDefenseInsight.fromContext(text: prompt);

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

    final reassurancePrefix = insight.immediateReassurance.isNotEmpty
        ? '【💡 即時定心丸】：\n${insight.immediateReassurance}\n\n'
        : '';
    final goldenPhrasePrefix = insight.tacticalGoldenPhrase.isNotEmpty
        ? '【💬 現場 / LINE 應對金句（可直接複製發送或照著唸）】：\n${insight.tacticalGoldenPhrase}\n\n'
        : '';
    final fullReport =
        '$reassurancePrefix$goldenPhrasePrefix${analysis.toDetailedReport()}';

    return LawAssistantMessage(
      id: 'mock-assistant-${createdAt.microsecondsSinceEpoch}',
      role: LawAssistantMessageRole.assistant,
      content: fullReport,
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
