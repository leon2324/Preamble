import 'package:preamble/data/user/law_app_user.dart';

/// App 登入服務介面。
///
/// 目前先用 DemoAuthService，但頁面與 AppState 只依賴 AuthService；
/// 未來接 Firebase、Apple、Google 或自家後端時，新增實作即可，不要把登入 SDK 散在 UI。
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

/// 正式後端登入服務預留點。
///
/// 這個 class 先不實作真網路登入，避免 Flutter 端偷放 provider API key；
/// 接後端時請只使用 Preamble 自家 API base URL 與後端核發的 session/token。
class BackendAuthService implements AuthService {
  const BackendAuthService();

  @override
  Future<PreambleUser?> currentUser() async => null;

  @override
  Future<PreambleUser?> refreshUser() async => null;

  @override
  Future<PreambleUser> signInDemoMember() {
    throw UnimplementedError('正式後端登入尚未串接，請使用 DemoAuthService。');
  }

  @override
  Future<PreambleUser> signInDemoSubscriber() {
    throw UnimplementedError('正式後端訂閱登入尚未串接，請使用 DemoAuthService。');
  }

  @override
  Future<void> signOut() async {}
}
