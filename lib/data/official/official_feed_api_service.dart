import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:preamble/data/law_assistant/law_assistant_api_service.dart';
import 'package:preamble/data/moj/moj_feed_item.dart';

/// 官方訊息/新聞後端代理服務。
///
/// 對接 `/official-feeds/news`、`/official-feeds/press-releases` 及 `/official-feeds/announcements`。
class OfficialFeedApiService {
  OfficialFeedApiService({
    http.Client? client,
    AuthTokenProvider authTokenProvider = const GuestAuthTokenProvider(),
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _ownsClient = client == null,
        _authTokenProvider = authTokenProvider,
        _baseUrl = baseUrl ??
            const String.fromEnvironment('PREAMBLE_API_BASE_URL').trim();

  final http.Client _client;
  // 台灣繁體中文教學註解：外部提供的 HTTP client 不屬於本服務，釋放時需保留給原持有者。
  final bool _ownsClient;
  final AuthTokenProvider _authTokenProvider;
  final String _baseUrl;

  bool get hasConfiguredBackend => _baseUrl.isNotEmpty;

  Future<List<MojFeedItem>> fetchNews() async {
    return _fetchItems('/official-feeds/news', MojFeedCategory.news);
  }

  Future<List<MojFeedItem>> fetchPressReleases() async {
    return _fetchItems('/official-feeds/press-releases', MojFeedCategory.news);
  }

  Future<List<MojFeedItem>> fetchAnnouncements() async {
    return _fetchItems(
        '/official-feeds/announcements', MojFeedCategory.lawUpdates);
  }

  Future<List<MojFeedItem>> _fetchItems(
    String path,
    MojFeedCategory category,
  ) async {
    _ensureConfigured();
    final response = await _client.get(
      _uri(path),
      headers: await _headers(),
    );
    _ensureSuccess(response, '官方訊息讀取失敗');

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    final list = decoded is List ? decoded : decoded['items'];
    if (list is! List) return const [];

    return list.whereType<Map<String, dynamic>>().map((json) {
      return MojFeedItem(
        title: json['title']?.toString() ?? '',
        url: json['url']?.toString() ?? '',
        category: category,
        index: (json['index'] as num?)?.toInt() ?? 0,
      );
    }).toList(growable: false);
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
      throw const OfficialFeedApiException(
        '尚未設定 PREAMBLE_API_BASE_URL，暫時無法連線至官方訊息後端。',
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

    throw OfficialFeedApiException('$message（HTTP ${response.statusCode}）');
  }
}

class OfficialFeedApiException implements Exception {
  const OfficialFeedApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
