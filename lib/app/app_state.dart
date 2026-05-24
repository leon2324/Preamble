import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lawapp/data/auth/auth_service.dart';
import 'package:lawapp/data/documents/document_repository.dart';
import 'package:lawapp/data/following/following_models.dart';
import 'package:lawapp/data/law_assistant/law_assistant_api_service.dart';
import 'package:lawapp/data/user/law_app_access_tier.dart';
import 'package:lawapp/data/user/law_app_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

export 'package:lawapp/data/user/law_app_access_tier.dart';

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
  static const _savedCaseIdsKey = 'lawAppSavedCaseIds';
  static const _followingSummaryKey = 'lawAppFollowingSummary';
  static const _caseNoteDraftsKey = 'lawAppCaseNoteDrafts';
  static const _currentUserKey = 'lawAppCurrentUser';

  LawAppState({AuthService? authService})
      : _authService = authService ?? DemoAuthService() {
    documentRepository = DocumentRepository(authTokenProvider: this);
    documentRepository.addListener(notifyListeners);
  }

  LawAppAccessTier _accessTier = LawAppAccessTier.guest;
  LawAppUser _currentUser = LawAppUser.guest();
  final AuthService _authService;
  late final DocumentRepository documentRepository;
  bool _isDarkMode = false;
  String? _authToken;
  bool _isLoaded = false;
  final Set<String> _savedCaseIds = <String>{};
  FollowingSummary _followingSummary = FollowingSummary.empty();
  Map<String, String> _caseNoteDrafts = <String, String>{};

  LawAppAccessTier get accessTier => _accessTier;
  LawAppUser get currentUser => _currentUser;
  bool get isLoaded => _isLoaded;
  bool get isDarkMode => _isDarkMode;
  bool get isGuest => _accessTier == LawAppAccessTier.guest;
  bool get isSignedIn => _accessTier != LawAppAccessTier.guest;
  bool get isSubscriber => _accessTier == LawAppAccessTier.subscriber;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  bool get canUseLawAssistant => remainingAiQuota > 0;
  bool get canSaveCase => isSignedIn;
  bool get canWriteCaseNote => isSignedIn;
  bool get canGenerateDocument => isSubscriber;
  bool get canViewFullCaseDossier => isSubscriber;
  bool get canUseAdvancedSearch => isSubscriber;
  int get remainingAiQuota => _currentUser.remainingAiQuota;
  bool get canSaveConversations => isSignedIn;
  bool get canTrackTopics => isSignedIn;
  bool get canUsePremiumDocuments => isSubscriber;
  bool get canSeeFullCaseDossiers => isSubscriber;
  Set<String> get savedCaseIds => Set.unmodifiable(_savedCaseIds);
  FollowingSummary get followingSummary => _followingSummary;

  bool isCaseSaved(String caseId) => _savedCaseIds.contains(caseId);
  bool isCaseFollowed(String caseId) =>
      _followingSummary.followedCaseIds.contains(caseId);
  bool isStatuteFollowed(String statuteId) =>
      _followingSummary.followedStatuteIds.contains(statuteId);
  bool isTopicFollowed(String topicId) =>
      _followingSummary.followedTopicIds.contains(topicId);
  bool isStatuteSaved(String statuteId) =>
      _followingSummary.savedStatuteIds.contains(statuteId);
  bool isArticleSaved(String articleId) =>
      _followingSummary.savedArticleIds.contains(articleId);

  String? caseNoteDraft(String caseId) {
    final note = _caseNoteDrafts[caseId]?.trim();
    return note == null || note.isEmpty ? null : note;
  }

  bool hasCaseNoteDraft(String caseId) => caseNoteDraft(caseId) != null;

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
      _currentUser = _decodeUser(
        preferences.getString(_currentUserKey),
        _accessTier,
      );
      _savedCaseIds
        ..clear()
        ..addAll(preferences.getStringList(_savedCaseIdsKey) ?? const []);
      _followingSummary = _decodeFollowingSummary(
        preferences.getString(_followingSummaryKey),
      );
      if (_savedCaseIds.isNotEmpty) {
        _followingSummary = _followingSummary.copyWith(
          savedCaseIds: _setListValueMany(
            _followingSummary.savedCaseIds,
            _savedCaseIds,
          ),
        );
      }
      _caseNoteDrafts = _decodeCaseNotes(
        preferences.getString(_caseNoteDraftsKey),
      );
      await documentRepository.fetchDrafts();
    } on MissingPluginException {
      // 台灣繁體中文教學註解：
      // Widget test 或 hot restart 的 plugin 註冊空窗期可能取不到偏好設定；
      // 這裡回退成訪客狀態，讓 App 不會因本機儲存尚未就緒而無法啟動。
      _accessTier = LawAppAccessTier.guest;
      _currentUser = LawAppUser.guest();
      _isDarkMode = false;
      _authToken = null;
      _savedCaseIds.clear();
      _followingSummary = FollowingSummary.empty();
      _caseNoteDrafts = <String, String>{};
      await documentRepository.fetchDrafts();
    }

    _isLoaded = true;
    notifyListeners();
  }

  Future<void> setCaseSaved(String caseId, bool isSaved) async {
    final didChange =
        isSaved ? _savedCaseIds.add(caseId) : _savedCaseIds.remove(caseId);
    final oldSavedCaseIds = _followingSummary.savedCaseIds;
    _followingSummary = _followingSummary.copyWith(
      savedCaseIds:
          _setListValue(_followingSummary.savedCaseIds, caseId, isSaved),
      updatedAt: DateTime.now(),
    );
    final followingChanged =
        oldSavedCaseIds.join('|') != _followingSummary.savedCaseIds.join('|');
    if (!didChange && !followingChanged) {
      return;
    }

    await _persistCaseInteractions();
    notifyListeners();
  }

  Future<void> setCaseFollowed(String caseId, bool isFollowed) async {
    _followingSummary = _followingSummary.copyWith(
      followedCaseIds:
          _setListValue(_followingSummary.followedCaseIds, caseId, isFollowed),
      updatedAt: DateTime.now(),
    );
    await _persistCaseInteractions();
    notifyListeners();
  }

  Future<void> setStatuteFollowed(String statuteId, bool isFollowed) async {
    _followingSummary = _followingSummary.copyWith(
      followedStatuteIds: _setListValue(
        _followingSummary.followedStatuteIds,
        statuteId,
        isFollowed,
      ),
      updatedAt: DateTime.now(),
    );
    await _persistCaseInteractions();
    notifyListeners();
  }

  Future<void> setTopicFollowed(String topicId, bool isFollowed) async {
    _followingSummary = _followingSummary.copyWith(
      followedTopicIds: _setListValue(
          _followingSummary.followedTopicIds, topicId, isFollowed),
      updatedAt: DateTime.now(),
    );
    await _persistCaseInteractions();
    notifyListeners();
  }

  Future<void> setStatuteSaved(String statuteId, bool isSaved) async {
    _followingSummary = _followingSummary.copyWith(
      savedStatuteIds:
          _setListValue(_followingSummary.savedStatuteIds, statuteId, isSaved),
      updatedAt: DateTime.now(),
    );
    await _persistCaseInteractions();
    notifyListeners();
  }

  Future<void> setArticleSaved(String articleId, bool isSaved) async {
    _followingSummary = _followingSummary.copyWith(
      savedArticleIds:
          _setListValue(_followingSummary.savedArticleIds, articleId, isSaved),
      updatedAt: DateTime.now(),
    );
    await _persistCaseInteractions();
    notifyListeners();
  }

  Future<void> saveCaseNoteDraft(String caseId, String note) async {
    // 台灣繁體中文教學註解：
    // 案件筆記目前先做「本機草稿」而不是假裝已同步雲端；等會員後端完成後，
    // 只要把這個方法換成 API 呼叫，頁面端的互動狀態就能維持同一套介面。
    final trimmedNote = note.trim();
    if (trimmedNote.isEmpty) {
      _caseNoteDrafts.remove(caseId);
    } else {
      _caseNoteDrafts[caseId] = trimmedNote;
    }

    await _persistCaseInteractions();
    notifyListeners();
  }

  Future<void> signInDemo() async {
    _currentUser = await _authService.signInDemoMember();
    _accessTier = _currentUser.accessTier;
    _authToken = 'demo-member-token';
    await _persist();
    notifyListeners();
  }

  Future<void> activateSubscriberDemo() async {
    _currentUser = await _authService.signInDemoSubscriber();
    _accessTier = _currentUser.accessTier;
    _authToken = 'demo-subscriber-token';
    await _persist();
    notifyListeners();
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _accessTier = LawAppAccessTier.guest;
    _currentUser = LawAppUser.guest();
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
      await preferences.setString(_currentUserKey, jsonEncode(_currentUser));
    } on MissingPluginException {
      // 測試環境沒有 SharedPreferences plugin 時略過寫入即可；
      // 記憶體內狀態仍會讓目前畫面即時更新。
    }
  }

  Future<void> _persistCaseInteractions() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final savedIds = _savedCaseIds.toList()..sort();
      await preferences.setStringList(_savedCaseIdsKey, savedIds);
      await preferences.setString(
        _followingSummaryKey,
        jsonEncode(_followingSummary),
      );
      if (_caseNoteDrafts.isEmpty) {
        await preferences.remove(_caseNoteDraftsKey);
      } else {
        await preferences.setString(
          _caseNoteDraftsKey,
          jsonEncode(_caseNoteDrafts),
        );
      }
    } on MissingPluginException {
      // 台灣繁體中文教學註解：
      // 測試環境無法寫入 SharedPreferences 時保留記憶體狀態即可，
      // 避免因平台 plugin 缺席讓收藏或筆記流程中斷。
    }
  }

  List<String> _setListValue(List<String> current, String id, bool enabled) {
    final normalizedId = id.trim();
    if (normalizedId.isEmpty) return current;
    final values = {...current};
    enabled ? values.add(normalizedId) : values.remove(normalizedId);
    return values.toList(growable: false)..sort();
  }

  List<String> _setListValueMany(List<String> current, Iterable<String> ids) {
    final values = {...current};
    for (final id in ids) {
      final normalizedId = id.trim();
      if (normalizedId.isNotEmpty) values.add(normalizedId);
    }
    return values.toList(growable: false)..sort();
  }

  FollowingSummary _decodeFollowingSummary(String? rawSummary) {
    if (rawSummary == null || rawSummary.isEmpty) {
      return FollowingSummary.empty();
    }

    try {
      final decoded = jsonDecode(rawSummary);
      if (decoded is Map<String, dynamic>) {
        return FollowingSummary.fromJson(decoded);
      }
    } on FormatException {
      // 台灣繁體中文教學註解：
      // 本機追蹤資料若因舊版格式壞掉，回到空 summary，避免我的 LawApp 開不起來。
    }
    return FollowingSummary.empty();
  }

  Map<String, String> _decodeCaseNotes(String? rawNotes) {
    if (rawNotes == null || rawNotes.isEmpty) return <String, String>{};

    try {
      final decoded = jsonDecode(rawNotes);
      if (decoded is! Map<String, dynamic>) return <String, String>{};
      return decoded.map(
        (key, value) => MapEntry(key, value?.toString() ?? ''),
      );
    } on FormatException {
      return <String, String>{};
    }
  }

  LawAppUser _decodeUser(String? rawUser, LawAppAccessTier fallbackTier) {
    if (rawUser == null || rawUser.isEmpty) {
      return _fallbackUserForTier(fallbackTier);
    }

    try {
      final decoded = jsonDecode(rawUser);
      if (decoded is Map<String, dynamic>) {
        return LawAppUser.fromJson(decoded);
      }
    } on FormatException {
      // 使用者資料壞掉時回退權限層級即可，避免 App 啟動失敗。
    }
    return _fallbackUserForTier(fallbackTier);
  }

  LawAppUser _fallbackUserForTier(LawAppAccessTier tier) {
    switch (tier) {
      case LawAppAccessTier.guest:
        return LawAppUser.guest();
      case LawAppAccessTier.member:
        return LawAppUser.demoMember();
      case LawAppAccessTier.subscriber:
        return LawAppUser.demoSubscriber();
    }
  }

  @override
  void dispose() {
    documentRepository.removeListener(notifyListeners);
    documentRepository.dispose();
    super.dispose();
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
