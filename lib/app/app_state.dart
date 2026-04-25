import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lawapp/data/law_assistant/law_assistant_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum LawAppAccessTier {
  guest,
  member,
  subscriber,
}

extension LawAppAccessTierLabels on LawAppAccessTier {
  String get label {
    switch (this) {
      case LawAppAccessTier.guest:
        return '訪客';
      case LawAppAccessTier.member:
        return '已登入';
      case LawAppAccessTier.subscriber:
        return '訂閱者';
    }
  }

  String get helperText {
    switch (this) {
      case LawAppAccessTier.guest:
        return '可查詢公開內容與試用小法助一次。';
      case LawAppAccessTier.member:
        return '可保存對話、追蹤主題與記錄學習進度。';
      case LawAppAccessTier.subscriber:
        return '可使用進階文件產生、完整案例整理與高額度 AI。';
    }
  }
}

/// App 層級狀態：會員層級、深色模式與後端 token 預留點。
///
/// 台灣繁體中文教學註解：
/// 第一版先用 SharedPreferences 保存 demo 狀態，讓 UI 可以完整演示三種權限；
/// 之後要接 Firebase Auth、Sign in with Apple、Google 登入或正式訂閱，只要把
/// `signInDemo` / `activateSubscriberDemo` 改成真正的 SDK 呼叫即可。
class LawAppState extends ChangeNotifier implements AuthTokenProvider {
  static const _tierKey = 'lawAppAccessTier';
  static const _darkModeKey = 'lawAppDarkMode';
  static const _demoTokenKey = 'lawAppDemoToken';

  LawAppAccessTier _accessTier = LawAppAccessTier.guest;
  bool _isDarkMode = false;
  String? _authToken;
  bool _isLoaded = false;

  LawAppAccessTier get accessTier => _accessTier;
  bool get isLoaded => _isLoaded;
  bool get isDarkMode => _isDarkMode;
  bool get isGuest => _accessTier == LawAppAccessTier.guest;
  bool get isSignedIn => _accessTier != LawAppAccessTier.guest;
  bool get isSubscriber => _accessTier == LawAppAccessTier.subscriber;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  bool get canSaveConversations => isSignedIn;
  bool get canTrackTopics => isSignedIn;
  bool get canUsePremiumDocuments => isSubscriber;
  bool get canSeeFullCaseDossiers => isSubscriber;

  Future<void> load() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final tierName = preferences.getString(_tierKey);
      _accessTier = LawAppAccessTier.values.firstWhere(
        (tier) => tier.name == tierName,
        orElse: () => LawAppAccessTier.guest,
      );
      _isDarkMode = preferences.getBool(_darkModeKey) ?? false;
      _authToken = preferences.getString(_demoTokenKey);
    } on MissingPluginException {
      // 台灣繁體中文教學註解：
      // Widget test 或 hot restart 的 plugin 註冊空窗期可能取不到偏好設定；
      // 這裡回退成訪客狀態，讓 App 不會因本機儲存尚未就緒而無法啟動。
      _accessTier = LawAppAccessTier.guest;
      _isDarkMode = false;
      _authToken = null;
    }

    _isLoaded = true;
    notifyListeners();
  }

  Future<void> signInDemo() async {
    _accessTier = LawAppAccessTier.member;
    _authToken = 'demo-member-token';
    await _persist();
    notifyListeners();
  }

  Future<void> activateSubscriberDemo() async {
    _accessTier = LawAppAccessTier.subscriber;
    _authToken = 'demo-subscriber-token';
    await _persist();
    notifyListeners();
  }

  Future<void> signOut() async {
    _accessTier = LawAppAccessTier.guest;
    _authToken = null;
    await _persist();
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    if (_isDarkMode == value) return;
    _isDarkMode = value;
    await _persist();
    notifyListeners();
  }

  @override
  Future<String?> getAuthToken() async => _authToken;

  Future<void> _persist() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_tierKey, _accessTier.name);
      await preferences.setBool(_darkModeKey, _isDarkMode);
      if (_authToken == null) {
        await preferences.remove(_demoTokenKey);
      } else {
        await preferences.setString(_demoTokenKey, _authToken!);
      }
    } on MissingPluginException {
      // 測試環境沒有 SharedPreferences plugin 時略過寫入即可；
      // 記憶體內狀態仍會讓目前畫面即時更新。
    }
  }
}

class LawAppScope extends InheritedNotifier<LawAppState> {
  const LawAppScope({
    super.key,
    required LawAppState state,
    required super.child,
  }) : super(notifier: state);

  static LawAppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<LawAppScope>();
    assert(scope != null, 'LawAppScope was not found in the widget tree.');
    return scope!.notifier!;
  }
}
