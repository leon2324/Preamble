import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:preamble/data/common/auth_token_provider.dart';
import 'package:preamble/data/common/preamble_api_transport.dart';
import 'package:preamble/data/search/search_models.dart';

/// Preamble 全局搜尋 API 服務。
///
/// 對接後端 `/search?q=&type=` 混合搜尋端點。未設定 Base URL 時由
/// SearchRepository 回退至本機多來源檢索。
class SearchApiService {
  SearchApiService({
    http.Client? client,
    AuthTokenProvider authTokenProvider = const GuestAuthTokenProvider(),
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _ownsClient = client == null,
        _authTokenProvider = authTokenProvider,
        _baseUrl = baseUrl ??
            const String.fromEnvironment('PREAMBLE_API_BASE_URL').trim();

  final http.Client _client;
  // 台灣繁體中文教學註解：呼叫端注入的 client 由呼叫端管理，避免共用連線被提早關閉。
  final bool _ownsClient;
  final AuthTokenProvider _authTokenProvider;
  final String _baseUrl;
  // 台灣繁體中文教學註解：請求外殼集中管理，領域服務保留自己的端點與例外型別。
  late final PreambleApiTransport _transport = PreambleApiTransport(
    baseUrl: _baseUrl,
    authTokenProvider: _authTokenProvider,
  );

  bool get hasConfiguredBackend => _baseUrl.isNotEmpty;

  Future<List<SearchResultItem>> searchAll(String query, {String? type}) async {
    _ensureConfigured();
    final queryParams = <String, String>{
      'q': query,
      if (type != null && type.isNotEmpty) 'type': type,
    };

    final response = await _client.get(
      _uri('/search', queryParams: queryParams),
      headers: await _headers(),
    );
    _ensureSuccess(response, '全站搜尋失敗');

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    final list = decoded is List ? decoded : decoded['results'];
    if (list is! List) return const [];

    return list
        .whereType<Map<String, dynamic>>()
        .map(SearchResultItem.fromJson)
        .toList(growable: false);
  }

  void dispose() {
    if (_ownsClient) _client.close();
  }

  Uri _uri(String path, {Map<String, String>? queryParams}) =>
      _transport.uri(path, queryParams: queryParams);

  Future<Map<String, String>> _headers() => _transport.headers();

  void _ensureConfigured() {
    if (!hasConfiguredBackend) {
      throw const SearchApiException(
        '尚未設定 PREAMBLE_API_BASE_URL，暫時無法連線至全站搜尋後端。',
      );
    }
  }

  void _ensureSuccess(http.Response response, String fallbackMessage) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    throw SearchApiException(
      _transport.errorMessage(response, fallbackMessage),
    );
  }
}

class SearchApiException implements Exception {
  const SearchApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
