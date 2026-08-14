import 'dart:async';
import 'package:flutter/foundation.dart';

// =============================================================================
// 教學型註解：AuthInterceptor — HTTP 401 無感刷新攔截器
// =============================================================================
// 在真實專案中，通常會使用 Dio Interceptor 或 http.Client 的包裝類別。
// 這個模擬版本示範了以下架構觀念：
//   1. Singleton 模式確保全域唯一攔截器
//   2. 透過 Completer 實現「多個併發請求共享同一次 Token 刷新」
//   3. 刷新成功後自動重發原始請求（對使用者來說是無感的）
//
// [審查修復] 原實作的競態條件說明：
// 原本使用 bool _isRefreshing + 固定 500ms delay 讓併發請求等待刷新完成。
// 問題是：刷新需要 800ms，但等待方只等 500ms 就返回，此時拿到的仍是舊 Token。
// 修復方式：改用 Completer<String?> 讓所有併發等待者共享同一個 Future，
// 確保刷新完成後才統一返回新 Token。
// =============================================================================
class AuthInterceptor {
  AuthInterceptor._privateConstructor();
  static final AuthInterceptor instance = AuthInterceptor._privateConstructor();

  // [審查修復] 移除原本的 bool _isRefreshing 旗標，改用 Completer 做併發控制。
  // Completer 的好處是：所有等待者都 await 同一個 Future，
  // 不需要猜測「要等多久」，刷新一完成就全部繼續。
  Completer<String?>? _refreshCompleter;
  String _mockAccessToken = 'access_token_v1';
  final String _mockRefreshToken = 'refresh_token_v1';

  /// 模擬發送 API 請求，若遇到 401 則嘗試刷新 Token 並重發。
  /// [endpoint] 是目標 API 路徑，[requestAction] 接收 Token 並執行實際請求。
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

  /// [審查修復] Token 刷新核心邏輯（已修復併發競態條件）。
  /// 使用 Completer 確保同一時間只會有一次刷新 API 呼叫，
  /// 其他併發請求會 await 同一個 Completer.future，
  /// 刷新完成後全部拿到相同的新 Token。
  Future<String?> _refreshToken() async {
    // 如果已有刷新正在進行，直接共享它的結果
    if (_refreshCompleter != null) {
      debugPrint('AuthInterceptor: 已有刷新進行中，等待共享結果...');
      return _refreshCompleter!.future;
    }

    // 建立新的 Completer，標記「刷新正在進行」
    _refreshCompleter = Completer<String?>();
    try {
      // 模擬打 API 換發 Token（實際專案中替換為真正的 refresh API）
      await Future.delayed(const Duration(milliseconds: 800));
      _mockAccessToken =
          'access_token_v2_${DateTime.now().millisecondsSinceEpoch}';
      _refreshCompleter!.complete(_mockAccessToken);
      return _mockAccessToken;
    } catch (e) {
      // 刷新失敗時也要通知所有等待者
      _refreshCompleter!.complete(null);
      return null;
    } finally {
      // 無論成功失敗，都要清除 Completer，允許下次重新刷新
      _refreshCompleter = null;
    }
  }
}

/// 自訂認證例外，攜帶 HTTP 狀態碼方便攔截器判斷是否需要刷新。
class AuthException implements Exception {
  AuthException(this.message, this.statusCode);
  final String message;
  final int statusCode;

  @override
  String toString() => 'AuthException($statusCode): $message';
}
