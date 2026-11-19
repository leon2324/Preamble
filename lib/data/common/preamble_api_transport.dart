import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:preamble/data/common/auth_token_provider.dart';

/// 台灣繁體中文教學註解：集中 API 服務共用的「請求外殼」。
/// 這個物件不建立或關閉 HTTP client；各服務仍自行決定端點、JSON 模型、
/// 例外型別與 client 所有權，避免共用層吞掉各領域的業務差異。
class PreambleApiTransport {
  const PreambleApiTransport({
    required this.baseUrl,
    required this.authTokenProvider,
  });

  final String baseUrl;
  final AuthTokenProvider authTokenProvider;

  bool get hasConfiguredBackend => baseUrl.isNotEmpty;

  /// 沿用原本的 URI 組合規則，保留含路徑的 base URL 與 query 編碼行為。
  Uri uri(String path, {Map<String, String>? queryParams}) {
    final normalizedBaseUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final result = Uri.parse('$normalizedBaseUrl$path');
    if (queryParams != null && queryParams.isNotEmpty) {
      return result.replace(queryParameters: queryParams);
    }
    return result;
  }

  /// 每次請求都重新取 Token，避免服務建立時的舊 Token 被長期快取。
  Future<Map<String, String>> headers() async {
    final token = await authTokenProvider.getAuthToken();
    return {
      'Content-Type': 'application/json; charset=utf-8',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  /// 後端訊息不是可靠 JSON 時維持原本的預設文案，並附上 HTTP 狀態碼。
  String errorMessage(http.Response response, String fallbackMessage) {
    var message = fallbackMessage;
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is Map && decoded['message'] != null) {
        message = decoded['message'].toString();
      }
    } catch (__) {
      // 台灣繁體中文教學註解：錯誤頁可能是純文字或 HTML，解析失敗屬預期降級。
    }
    return '$message（HTTP ${response.statusCode}）';
  }
}
