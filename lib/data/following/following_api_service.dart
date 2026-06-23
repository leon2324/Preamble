import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:lawapp/data/following/following_models.dart';
import 'package:lawapp/data/law_assistant/law_assistant_api_service.dart';

/// LawApp 追蹤/收藏後端代理服務。
///
/// 台灣繁體中文教學介紹型註解：
/// Flutter 端只知道「我要追蹤/收藏哪個 id」，不直接碰資料庫；正式同步時由
/// `LAWAPP_API_BASE_URL` 指到後端，未設定時 repository 會回到本機 mock 狀態。
/// 這樣全站搜尋、法規頁與我的 LawApp 可以共用同一套資料契約。
class FollowingApiService {
  FollowingApiService({
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

  Future<FollowingSummary> getFollowingSummary() async {
    if (!hasConfiguredBackend) return FollowingSummary.empty();

    final response = await _client.get(
      _uri('/following'),
      headers: await _headers(),
    );
    _ensureSuccess(response, '追蹤與收藏資料讀取失敗');

    return FollowingSummary.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
  }

  Future<FollowingSummary> setFollowed({
    required String collection,
    required String id,
    required bool isFollowed,
  }) async {
    _ensureConfigured();
    final response = isFollowed
        ? await _client.post(
            _uri('/following/$collection/$id'),
            headers: await _headers(),
          )
        : await _client.delete(
            _uri('/following/$collection/$id'),
            headers: await _headers(),
          );
    _ensureSuccess(response, isFollowed ? '加入追蹤失敗' : '取消追蹤失敗');
    return _summaryFromResponse(response);
  }

  Future<FollowingSummary> setSaved({
    required String collection,
    required String id,
    required bool isSaved,
  }) async {
    _ensureConfigured();
    final response = isSaved
        ? await _client.post(
            _uri('/following/saved/$collection/$id'),
            headers: await _headers(),
          )
        : await _client.delete(
            _uri('/following/saved/$collection/$id'),
            headers: await _headers(),
          );
    _ensureSuccess(response, isSaved ? '加入收藏失敗' : '取消收藏失敗');
    return _summaryFromResponse(response);
  }

  Future<List<FollowedUpdateItem>> getFollowedUpdates() async {
    if (!hasConfiguredBackend) return const [];

    final response = await _client.get(
      _uri('/following/updates'),
      headers: await _headers(),
    );
    _ensureSuccess(response, '追蹤更新讀取失敗');

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    final list = decoded is List ? decoded : decoded['updates'];
    if (list is! List) return const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(FollowedUpdateItem.fromJson)
        .toList(growable: false);
  }

  void dispose() {
    _client.close();
  }

  FollowingSummary _summaryFromResponse(http.Response response) {
    if (response.bodyBytes.isEmpty) return FollowingSummary.empty();
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is Map<String, dynamic>) {
      final summary = decoded['summary'];
      if (summary is Map<String, dynamic>) {
        return FollowingSummary.fromJson(summary);
      }
      return FollowingSummary.fromJson(decoded);
    }
    return FollowingSummary.empty();
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
      throw const FollowingApiException(
        '尚未設定 LAWAPP_API_BASE_URL，暫時無法同步追蹤與收藏後端。',
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
      // 台灣繁體中文教學註解：
      // 後端錯誤格式不可控，解析失敗時保留 UI 可讀的預設訊息即可。
    }

    throw FollowingApiException('$message（HTTP ${response.statusCode}）');
  }
}

class FollowingApiException implements Exception {
  const FollowingApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
