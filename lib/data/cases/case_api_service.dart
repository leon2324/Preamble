import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:preamble/data/cases/case_models.dart';
import 'package:preamble/data/law_assistant/law_assistant_api_service.dart';

/// Preamble 案件資料庫 API 服務。
///
/// Flutter 只呼叫後端 API 代理；未設定 PREAMBLE_API_BASE_URL 時，
/// CaseRepository 會備援至本機靜態案件資料。
class CaseApiService {
  CaseApiService({
    http.Client? client,
    AuthTokenProvider authTokenProvider = const GuestAuthTokenProvider(),
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _ownsClient = client == null,
        _authTokenProvider = authTokenProvider,
        _baseUrl = baseUrl ??
            const String.fromEnvironment('PREAMBLE_API_BASE_URL').trim();

  final http.Client _client;
  // 台灣繁體中文教學註解：外部注入的 client 可能被多個服務共用，只有本服務建立的才由本服務關閉。
  final bool _ownsClient;
  final AuthTokenProvider _authTokenProvider;
  final String _baseUrl;

  bool get hasConfiguredBackend => _baseUrl.isNotEmpty;

  Future<List<LawCase>> fetchFeaturedCases() async {
    _ensureConfigured();
    final response = await _client.get(
      _uri('/cases/featured'),
      headers: await _headers(),
    );
    _ensureSuccess(response, '精選案件讀取失敗');

    return _parseCaseList(response);
  }

  Future<List<LawCase>> fetchArchiveCases({
    String? era,
    String? category,
  }) async {
    _ensureConfigured();
    final queryParams = <String, String>{
      if (era != null && era.isNotEmpty) 'era': era,
      if (category != null && category.isNotEmpty) 'category': category,
    };
    final response = await _client.get(
      _uri('/cases/archive',
          queryParams: queryParams.isEmpty ? null : queryParams),
      headers: await _headers(),
    );
    _ensureSuccess(response, '案件檔案讀取失敗');

    return _parseCaseList(response);
  }

  Future<List<LawCase>> searchCases(String query) async {
    _ensureConfigured();
    final response = await _client.get(
      _uri('/cases/search', queryParams: {'q': query}),
      headers: await _headers(),
    );
    _ensureSuccess(response, '案件搜尋失敗');

    return _parseCaseList(response);
  }

  Future<LawCase> getCaseDetail(String id) async {
    _ensureConfigured();
    final response = await _client.get(
      _uri('/cases/$id'),
      headers: await _headers(),
    );
    _ensureSuccess(response, '案件詳情讀取失敗');

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    final json = decoded is Map<String, dynamic> && decoded['case'] is Map
        ? Map<String, dynamic>.from(decoded['case'] as Map)
        : decoded as Map<String, dynamic>;
    return LawCase.fromJson(json);
  }

  List<LawCase> _parseCaseList(http.Response response) {
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    final list = decoded is List ? decoded : decoded['cases'];
    if (list is! List) return const [];

    return list
        .whereType<Map<String, dynamic>>()
        .map(LawCase.fromJson)
        .toList(growable: false);
  }

  void dispose() {
    if (_ownsClient) _client.close();
  }

  Uri _uri(String path, {Map<String, String>? queryParams}) {
    final normalizedBaseUrl = _baseUrl.endsWith('/')
        ? _baseUrl.substring(0, _baseUrl.length - 1)
        : _baseUrl;
    final uri = Uri.parse('$normalizedBaseUrl$path');
    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(queryParameters: queryParams);
    }
    return uri;
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
      throw const CaseApiException(
        '尚未設定 PREAMBLE_API_BASE_URL，暫時無法連線至案件後端。',
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

    throw CaseApiException('$message（HTTP ${response.statusCode}）');
  }
}

class CaseApiException implements Exception {
  const CaseApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
