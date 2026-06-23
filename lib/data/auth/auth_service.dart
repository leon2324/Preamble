import 'package:lawapp/data/user/law_app_user.dart';

/// App 登入服務介面。
///
/// 台灣繁體中文教學註解：
/// 目前先用 DemoAuthService，但頁面與 AppState 只依賴 AuthService；
/// 未來接 Firebase、Apple、Google 或自家後端時，新增實作即可，不要把登入 SDK 散在 UI。
abstract class AuthService {
  Future<LawAppUser?> currentUser();
  Future<LawAppUser> signInDemoMember();
  Future<LawAppUser> signInDemoSubscriber();
  Future<void> signOut();
  Future<LawAppUser?> refreshUser();
}

class DemoAuthService implements AuthService {
  LawAppUser? _currentUser;

  @override
  Future<LawAppUser?> currentUser() async => _currentUser;

  @override
  Future<LawAppUser> signInDemoMember() async {
    _currentUser = LawAppUser.demoMember();
    return _currentUser!;
  }

  @override
  Future<LawAppUser> signInDemoSubscriber() async {
    _currentUser = LawAppUser.demoSubscriber();
    return _currentUser!;
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
  }

  @override
  Future<LawAppUser?> refreshUser() async => _currentUser;
}

/// 正式後端登入服務預留點。
///
/// 台灣繁體中文教學註解：
/// 這個 class 先不實作真網路登入，避免 Flutter 端偷放 provider API key；
/// 接後端時請只使用 LawApp 自家 API base URL 與後端核發的 session/token。
class BackendAuthService implements AuthService {
  const BackendAuthService();

  @override
  Future<LawAppUser?> currentUser() async => null;

  @override
  Future<LawAppUser?> refreshUser() async => null;

  @override
  Future<LawAppUser> signInDemoMember() {
    throw UnimplementedError('正式後端登入尚未串接，請使用 DemoAuthService。');
  }

  @override
  Future<LawAppUser> signInDemoSubscriber() {
    throw UnimplementedError('正式後端訂閱登入尚未串接，請使用 DemoAuthService。');
  }

  @override
  Future<void> signOut() async {}
}
