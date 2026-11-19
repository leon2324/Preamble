import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:preamble/data/law_assistant/law_assistant_api_service.dart';

class QuotaInfo {
  const QuotaInfo({
    required this.usageQuota,
    required this.usedQuotaToday,
  });

  final int usageQuota;
  final int usedQuotaToday;

  int get remainingQuota => (usageQuota - usedQuotaToday).clamp(0, usageQuota);

  factory QuotaInfo.fromJson(Map<String, dynamic> json) {
    return QuotaInfo(
      usageQuota: (json['usageQuota'] as num?)?.toInt() ?? 20,
      usedQuotaToday: (json['usedQuotaToday'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'usageQuota': usageQuota,
        'usedQuotaToday': usedQuotaToday,
      };
}

/// Preamble 用戶 AI 配額 API 服務。
///
/// 對接 `/quota` 與 `/quota/consume` 端點。額度由後端強制執行；
/// 未設定 Base URL 時由 UI 層依權限層級作本機倒數提示。
class QuotaApiService {
  QuotaApiService({
    http.Client? client,
    AuthTokenProvider authTokenProvider = const GuestAuthTokenProvider(),
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _ownsClient = client == null,
        _authTokenProvider = authTokenProvider,
        _baseUrl = baseUrl ??
            const String.fromEnvironment('PREAMBLE_API_BASE_URL').trim();

  final http.Client _client;
  // 台灣繁體中文教學註解：注入的 client 由上層管理；本服務只釋放自己建立的連線。
  final bool _ownsClient;
  final AuthTokenProvider _authTokenProvider;
  final String _baseUrl;

  bool get hasConfiguredBackend => _baseUrl.isNotEmpty;

  Future<QuotaInfo> fetchQuota() async {
    _ensureConfigured();
    final response = await _client.get(
      _uri('/quota'),
      headers: await _headers(),
    );
    _ensureSuccess(response, '配額資訊讀取失敗');

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    final json = decoded is Map<String, dynamic> && decoded['quota'] is Map
        ? Map<String, dynamic>.from(decoded['quota'] as Map)
        : decoded as Map<String, dynamic>;
    return QuotaInfo.fromJson(json);
  }

  Future<QuotaInfo> consumeQuota({int count = 1}) async {
    _ensureConfigured();
    final response = await _client.post(
      _uri('/quota/consume'),
      headers: await _headers(),
      body: jsonEncode({'count': count}),
    );
    _ensureSuccess(response, '配額扣減失敗');

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    final json = decoded is Map<String, dynamic> && decoded['quota'] is Map
        ? Map<String, dynamic>.from(decoded['quota'] as Map)
        : decoded as Map<String, dynamic>;
    return QuotaInfo.fromJson(json);
  }

  void dispose() {
    if (_ownsClient) _client.close();
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
      throw const QuotaApiException(
        '尚未設定 PREAMBLE_API_BASE_URL，暫時無法連線至配額後端。',
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
    } catch (__) {
      // 保持 fallback 訊息
    }

    throw QuotaApiException('$message（HTTP ${response.statusCode}）');
  }
}

class QuotaApiException implements Exception {
  const QuotaApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
