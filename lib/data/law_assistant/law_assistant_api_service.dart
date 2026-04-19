import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:lawapp/data/law_assistant/law_assistant_models.dart';

abstract class AuthTokenProvider {
  Future<String?> getAuthToken();
}

class GuestAuthTokenProvider implements AuthTokenProvider {
  const GuestAuthTokenProvider();

  @override
  Future<String?> getAuthToken() async => null;
}

/// 小法助 API 代理服務。
///
/// Flutter 只呼叫現有後端，不直接保存或使用任何 AI provider key；未來要換
/// OpenAI、Gemini 或其他模型時，應該在後端 provider 抽象層處理。
class LawAssistantApiService {
  LawAssistantApiService({
    http.Client? client,
    AuthTokenProvider authTokenProvider = const GuestAuthTokenProvider(),
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _authTokenProvider = authTokenProvider,
        _baseUrl = baseUrl ??
            const String.fromEnvironment('LAWAPP_API_BASE_URL').trim();

  final http.Client _client;
  final AuthTokenProvider _authTokenProvider;
  final String _baseUrl;

  bool get hasConfiguredBackend => _baseUrl.isNotEmpty;

  Future<List<LawAssistantConversation>> fetchRecentConversations() async {
    if (!hasConfiguredBackend) return const [];

    final response = await _client.get(
      _uri('/law-assistant/conversations'),
      headers: await _headers(),
    );
    _ensureSuccess(response, '最近對話讀取失敗');

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    final list = decoded is List ? decoded : decoded['conversations'];
    if (list is! List) return const [];

    return list
        .whereType<Map<String, dynamic>>()
        .map(LawAssistantConversation.fromJson)
        .toList(growable: false);
  }

  Future<LawAssistantConversation> createConversation({
    required String prompt,
  }) async {
    _ensureConfigured();
    final response = await _client.post(
      _uri('/law-assistant/conversations'),
      headers: await _headers(),
      body: jsonEncode({'prompt': prompt}),
    );
    _ensureSuccess(response, '小法助暫時無法回覆');

    return LawAssistantConversation.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
  }

  Future<LawAssistantConversation> fetchConversation(String id) async {
    _ensureConfigured();
    final response = await _client.get(
      _uri('/law-assistant/conversations/$id'),
      headers: await _headers(),
    );
    _ensureSuccess(response, '對話讀取失敗');

    return LawAssistantConversation.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
  }

  Future<LawAssistantConversation> sendMessage({
    required String conversationId,
    required String prompt,
  }) async {
    _ensureConfigured();
    final response = await _client.post(
      _uri('/law-assistant/conversations/$conversationId/messages'),
      headers: await _headers(),
      body: jsonEncode({'prompt': prompt}),
    );
    _ensureSuccess(response, '追問暫時送不出去');

    return LawAssistantConversation.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
  }

  void dispose() {
    _client.close();
  }

  Uri _uri(String path) {
    final normalizedBaseUrl = _baseUrl.endsWith('/')
        ? _baseUrl.substring(0, _baseUrl.length - 1)
        : _baseUrl;
    return Uri.parse('$normalizedBaseUrl$path');
  }

  Future<Map<String, String>> _headers() async {
    final token = await _authTokenProvider.getAuthToken();
    return {
      'Content-Type': 'application/json; charset=utf-8',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  void _ensureConfigured() {
    if (!hasConfiguredBackend) {
      throw const LawAssistantApiException(
        '尚未設定 LAWAPP_API_BASE_URL，暫時無法連線到小法助後端。',
      );
    }
  }

  void _ensureSuccess(http.Response response, String fallbackMessage) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;

    var message = fallbackMessage;
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is Map && decoded['message'] != null) {
        message = decoded['message'].toString();
      }
    } catch (_) {
      // 後端錯誤格式不可控，解析失敗時使用給 UI 的預設訊息即可。
    }

    throw LawAssistantApiException('$message（HTTP ${response.statusCode}）');
  }
}

class LawAssistantApiException implements Exception {
  const LawAssistantApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
