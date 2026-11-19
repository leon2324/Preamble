import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:preamble/data/common/auth_token_provider.dart';
import 'package:preamble/data/common/preamble_api_transport.dart';

// 台灣繁體中文教學註解：可變的假 Token 用來確認每次送出請求都取得最新值，
// 避免登入或刷新後仍帶著建立 service 時的舊憑證。
class _ChangingTokenProvider implements AuthTokenProvider {
  String? token;

  @override
  Future<String?> getAuthToken() async => token;
}

void main() {
  test('共用傳輸層保留 base path 並正確編碼查詢參數', () {
    final transport = PreambleApiTransport(
      baseUrl: 'https://example.test/api/',
      authTokenProvider: const GuestAuthTokenProvider(),
    );
    final uri = transport.uri('/cases/search', queryParams: {'q': '租屋 押金'});
    expect(uri.path, '/api/cases/search');
    expect(uri.queryParameters['q'], '租屋 押金');
    expect(transport.hasConfiguredBackend, isTrue);
  });

  test('授權標頭每次取最新 Token，訪客不帶 Authorization', () async {
    final provider = _ChangingTokenProvider();
    final transport = PreambleApiTransport(
      baseUrl: 'https://example.test',
      authTokenProvider: provider,
    );
    expect((await transport.headers())['Authorization'], isNull);
    provider.token = 'first-token';
    expect((await transport.headers())['Authorization'], 'Bearer first-token');
    provider.token = 'second-token';
    expect((await transport.headers())['Authorization'], 'Bearer second-token');
    expect((await transport.headers())['Content-Type'],
        'application/json; charset=utf-8');
  });

  test('錯誤回應優先使用後端訊息，格式損壞時保留預設文案', () {
    const transport = PreambleApiTransport(
      baseUrl: 'https://example.test',
      authTokenProvider: GuestAuthTokenProvider(),
    );
    final jsonError = http.Response.bytes(
      utf8.encode(jsonEncode({'message': '權限不足'})),
      403,
    );
    expect(transport.errorMessage(jsonError, '讀取失敗'), '權限不足（HTTP 403）');
    expect(transport.errorMessage(http.Response('<html>', 502), '讀取失敗'),
        '讀取失敗（HTTP 502）');
  });
}
