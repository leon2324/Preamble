/// 台灣繁體中文教學註解：後端服務只依賴這個最小介面取得目前 Token。
/// 實作可由 App 狀態或測試替換，不必讓案件、文件等模組反向依賴小法助。
abstract class AuthTokenProvider {
  Future<String?> getAuthToken();
}

/// 尚未登入時的預設實作；不主動附加 Authorization 標頭。
class GuestAuthTokenProvider implements AuthTokenProvider {
  const GuestAuthTokenProvider();

  @override
  Future<String?> getAuthToken() async => null;
}
