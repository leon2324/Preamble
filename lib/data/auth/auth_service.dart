import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:preamble/data/user/law_app_user.dart';

/// App 登入服務介面。
abstract class AuthService {
  Future<PreambleUser?> currentUser();
  Future<PreambleUser> signInDemoMember();
  Future<PreambleUser> signInDemoSubscriber();
  Future<void> signOut();
  Future<PreambleUser?> refreshUser();
}

class DemoAuthService implements AuthService {
  PreambleUser? _currentUser;

  @override
  Future<PreambleUser?> currentUser() async => _currentUser;

  @override
  Future<PreambleUser> signInDemoMember() async {
    _currentUser = PreambleUser.demoMember();
    return _currentUser!;
  }

  @override
  Future<PreambleUser> signInDemoSubscriber() async {
    _currentUser = PreambleUser.demoSubscriber();
    return _currentUser!;
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
  }

  @override
  Future<PreambleUser?> refreshUser() async => _currentUser;
}

/// 正式後端登入服務與 401 Token 刷新攔截器。
///
/// Flutter 端不保存任何第三方 API Key；對接 Preamble 後端 `/auth/*` 與 `/users/me` 端點。
class BackendAuthService implements AuthService {
  BackendAuthService({
    http.Client? client,
    String? baseUrl,
    String? initialToken,
  })  : _baseUrl = baseUrl ??
            const String.fromEnvironment('PREAMBLE_API_BASE_URL').trim(),
        _token = initialToken,
        _rawClient = client ?? http.Client() {
    _client = AuthHttpClient(
      inner: _rawClient,
      tokenGetter: () => _token,
      onRefreshToken: refreshToken,
    );
  }

  final String _baseUrl;
  final http.Client _rawClient;
  late final http.Client _client;
  String? _token;
  PreambleUser? _currentUser;

  String? get token => _token;
  bool get isBackendConfigured => _baseUrl.isNotEmpty;

  @override
  Future<PreambleUser?> currentUser() async {
    if (_currentUser != null) return _currentUser;
    if (_token != null && _token!.isNotEmpty) {
      return refreshUser();
    }
    return null;
  }

  @override
  Future<PreambleUser> signInDemoMember() async {
    return _authenticate('/auth/demo/member');
  }

  @override
  Future<PreambleUser> signInDemoSubscriber() async {
    return _authenticate('/auth/demo/subscriber');
  }

  @override
  Future<void> signOut() async {
    if (isBackendConfigured && _token != null) {
      try {
        await _client.post(
          _uri('/auth/sign-out'),
          headers: _headers(),
        );
      } catch (__) {
        // 忽略網路登出失敗，仍本機登出
      }
    }
    _token = null;
    _currentUser = null;
  }

  @override
  Future<PreambleUser?> refreshUser() async {
    if (!isBackendConfigured) return _currentUser;
    try {
      final response = await _client.get(
        _uri('/users/me'),
        headers: _headers(),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        final userJson =
            decoded is Map<String, dynamic> && decoded['user'] is Map
                ? Map<String, dynamic>.from(decoded['user'] as Map)
                : decoded as Map<String, dynamic>;
        _currentUser = PreambleUser.fromJson(userJson);
        return _currentUser;
      }
    } catch (__) {
      // API 連線失敗時傳回本機快取
    }
    return _currentUser;
  }

  Future<String?> refreshToken() async {
    if (!isBackendConfigured || _token == null) return null;
    try {
      final response = await _rawClient.post(
        _uri('/auth/refresh'),
        headers: _headers(),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        if (decoded is Map && decoded['token'] != null) {
          _token = decoded['token'].toString();
          return _token;
        }
      }
    } catch (__) {
      // 刷新失敗
    }
    _token = null;
    _currentUser = null;
    return null;
  }

  Future<PreambleUser> _authenticate(String path) async {
    if (!isBackendConfigured) {
      // 無 Base URL 時使用 Mock Fallback
      if (path.contains('subscriber')) {
        _currentUser = PreambleUser.demoSubscriber();
      } else {
        _currentUser = PreambleUser.demoMember();
      }
      _token = 'mock-demo-token';
      return _currentUser!;
    }

    final response = await _client.post(
      _uri(path),
      headers: {'Content-Type': 'application/json; charset=utf-8'},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthApiException('登入失敗：HTTP ${response.statusCode}');
    }

    final decoded =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    _token = decoded['token']?.toString();
    final userJson = decoded['user'] as Map<String, dynamic>? ?? {};
    _currentUser = PreambleUser.fromJson(userJson);
    return _currentUser!;
  }

  Uri _uri(String path) {
    final normalizedBaseUrl = _baseUrl.endsWith('/')
        ? _baseUrl.substring(0, _baseUrl.length - 1)
        : _baseUrl;
    return Uri.parse('$normalizedBaseUrl$path');
  }

  Map<String, String> _headers() {
    return {
      'Content-Type': 'application/json; charset=utf-8',
      if (_token != null && _token!.isNotEmpty)
        'Authorization': 'Bearer $_token',
    };
  }
}

/// HTTP 401 攔截器，自動觸發 Token 刷新並重試原始 Request。
class AuthHttpClient extends http.BaseClient {
  AuthHttpClient({
    required http.Client inner,
    required String? Function() tokenGetter,
    required Future<String?> Function() onRefreshToken,
  })  : _inner = inner,
        _tokenGetter = tokenGetter,
        _onRefreshToken = onRefreshToken;

  final http.Client _inner;
  final String? Function() _tokenGetter;
  final Future<String?> Function() _onRefreshToken;
  Future<String?>? _refreshInFlight;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final token = _tokenGetter();
    final authorization = request.headers['Authorization'];
    // 台灣繁體中文教學註解：BackendAuthService 會先帶入目前 Token；此時仍由
    // 攔截器管理刷新。只有與目前 Token 不同的外部授權才不可擅自替換。
    final hasExternalAuthorization = authorization != null &&
        (token == null || authorization != 'Bearer $token');
    if (token != null && token.isNotEmpty && authorization == null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // 台灣繁體中文教學註解：只有一般 Request 的 body 可安全複製。
    // 串流或 multipart request 消耗後不能重播，遇到 401 應交由呼叫端處理。
    final requestCopy = !hasExternalAuthorization && request is http.Request
        ? _copyRequest(request)
        : null;

    final response = await _inner.send(request);
    if (response.statusCode == 401 && requestCopy != null && token != null) {
      // 台灣繁體中文教學註解：別的請求可能已經刷新成功；先比較目前 Token，
      // 仍是舊值才共用同一個刷新 Future，避免並發請求輪流覆寫新 Token。
      final currentToken = _tokenGetter();
      final newToken = currentToken != null && currentToken != token
          ? currentToken
          : await _refreshOnce();
      if (newToken != null && newToken.isNotEmpty) {
        // 台灣繁體中文教學註解：丟棄舊 401 回應前先讀完 stream，釋放連線資源。
        await response.stream.drain<void>();
        requestCopy.headers['Authorization'] = 'Bearer $newToken';
        return _inner.send(requestCopy);
      }
    }
    return response;
  }

  Future<String?> _refreshOnce() {
    final pending = _refreshInFlight;
    if (pending != null) return pending;
    final refresh = _onRefreshToken();
    _refreshInFlight = refresh;
    return refresh.whenComplete(() {
      if (identical(_refreshInFlight, refresh)) _refreshInFlight = null;
    });
  }

  http.Request _copyRequest(http.Request request) {
    return http.Request(request.method, request.url)
      ..headers.addAll(request.headers)
      ..bodyBytes = request.bodyBytes
      ..encoding = request.encoding
      ..followRedirects = request.followRedirects
      ..maxRedirects = request.maxRedirects
      ..persistentConnection = request.persistentConnection;
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}

class AuthApiException implements Exception {
  const AuthApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
