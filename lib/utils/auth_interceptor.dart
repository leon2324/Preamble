import 'package:flutter/foundation.dart';

/// 模擬 HTTP Client 攔截器 (用於處理 401 無感刷新 Token)
/// 在真實專案中，通常會使用 Dio Interceptor 或是 http.Client 的包裝類別。
class AuthInterceptor {
  AuthInterceptor._privateConstructor();
  static final AuthInterceptor instance = AuthInterceptor._privateConstructor();

  bool _isRefreshing = false;
  String _mockAccessToken = 'access_token_v1';
  final String _mockRefreshToken = 'refresh_token_v1';

  /// 模擬發送 API 請求，若遇到 401 則嘗試刷新 Token 並重發
  Future<Map<String, dynamic>> sendRequest({
    required String endpoint,
    required Future<Map<String, dynamic>> Function(String token) requestAction,
  }) async {
    try {
      return await requestAction(_mockAccessToken);
    } catch (e) {
      if (e is AuthException && e.statusCode == 401) {
        debugPrint('AuthInterceptor: 收到 401 Unauthorized，準備無感刷新...');
        final newToken = await _refreshToken();
        if (newToken != null) {
          debugPrint('AuthInterceptor: 刷新成功，使用新 Token 重發請求...');
          return await requestAction(newToken);
        } else {
          debugPrint('AuthInterceptor: 刷新失敗，強制登出。');
          throw AuthException('Refresh Token 過期，請重新登入', 403);
        }
      }
      rethrow;
    }
  }

  Future<String?> _refreshToken() async {
    if (_isRefreshing) {
      // 避免多個併發請求同時觸發刷新
      await Future.delayed(const Duration(milliseconds: 500));
      return _mockAccessToken;
    }

    _isRefreshing = true;
    try {
      // 模擬打 API 換發 Token
      await Future.delayed(const Duration(milliseconds: 800));
      _mockAccessToken = 'access_token_v2_${DateTime.now().millisecondsSinceEpoch}';
      return _mockAccessToken;
    } catch (e) {
      return null;
    } finally {
      _isRefreshing = false;
    }
  }
}

class AuthException implements Exception {
  AuthException(this.message, this.statusCode);
  final String message;
  final int statusCode;

  @override
  String toString() => 'AuthException($statusCode): $message';
}
