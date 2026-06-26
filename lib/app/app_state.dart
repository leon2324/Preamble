import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lawapp/data/auth/auth_service.dart';
import 'package:lawapp/data/documents/document_repository.dart';
import 'package:lawapp/data/following/following_models.dart';
import 'package:lawapp/data/law_assistant/law_assistant_api_service.dart';
import 'package:lawapp/data/user/law_app_access_tier.dart';
import 'package:lawapp/data/user/law_app_user.dart';
import 'package:lawapp/theme/app_colors.dart'; // 匯入色票以利動態設定主題色 index
import 'package:shared_preferences/shared_preferences.dart';

export 'package:lawapp/data/user/law_app_access_tier.dart';

/// App 層級狀態：會員層級、深色模式與後端 token 預留點。
///
/// 第一版先用 SharedPreferences 保存 demo 狀態，讓 UI 可以完整演示三種權限；
/// 之後要接 Firebase Auth、Sign in with Apple、Google 登入或正式訂閱，只要把
/// `signInDemo` / `activateSubscriberDemo` 改成真正的 SDK 呼叫即可。
class PreambleState extends ChangeNotifier implements AuthTokenProvider {
  static const _tierKey = 'lawAppAccessTier';
  static const _darkModeKey = 'lawAppDarkMode';
  static const _demoTokenKey = 'lawAppDemoToken';
  static const _savedCaseIdsKey = 'lawAppSavedCaseIds';
  static const _followingSummaryKey = 'lawAppFollowingSummary';
  static const _caseNoteDraftsKey = 'lawAppCaseNoteDrafts';
  static const _currentUserKey = 'lawAppCurrentUser';
  static const _fontSizeScaleKey = 'lawAppFontSizeScale';
  static const _notifyFrequencyKey = 'lawAppNotifyFrequency';
  static const _notifyChannelKey = 'lawAppNotifyChannel';
  static const _navbarOrderKey = 'lawAppNavbarOrder';
  static const _showNavbarLabelsKey = 'lawAppShowNavbarLabels';
  static const _accentColorIndexKey = 'lawAppAccentColorIndex';

  PreambleState({AuthService? authService})
      : _authService = authService ?? DemoAuthService() {
    documentRepository = DocumentRepository(authTokenProvider: this);
    documentRepository.addListener(notifyListeners);
  }

  PreambleAccessTier _accessTier = PreambleAccessTier.guest;
  PreambleUser _currentUser = PreambleUser.guest();
  final AuthService _authService;
  late final DocumentRepository documentRepository;
  bool _isDarkMode = false;
  String? _authToken;
  bool _isLoaded = false;
  final Set<String> _savedCaseIds = <String>{};
  FollowingSummary _followingSummary = FollowingSummary.empty();
  Map<String, String> _caseNoteDrafts = <String, String>{};
  double _fontSizeScale = 1.0;
  String _notifyFrequency = 'instant';
  String _notifyChannel = 'push';
  List<int> _navbarOrder = [0, 1, 2, 3, 4];
  bool _showNavbarLabels = true;
  int _accentColorIndex = 0;

  PreambleAccessTier get accessTier => _accessTier;
  PreambleUser get currentUser => _currentUser;
  bool get isLoaded => _isLoaded;
  bool get isDarkMode => _isDarkMode;
  bool get isGuest => _accessTier == PreambleAccessTier.guest;
  bool get isSignedIn => _accessTier != PreambleAccessTier.guest;
  bool get isSubscriber => _accessTier == PreambleAccessTier.subscriber;
  double get fontSizeScale => _fontSizeScale;
  String get notifyFrequency => _notifyFrequency;
  String get notifyChannel => _notifyChannel;
  List<int> get navbarOrder => _navbarOrder;
  bool get showNavbarLabels => _showNavbarLabels;
  int get accentColorIndex => _accentColorIndex;

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
  Map<String, String> get caseNoteDrafts => Map.unmodifiable(_caseNoteDrafts);

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
      _accessTier = PreambleAccessTier.values.firstWhere(
        (tier) => tier.name == tierName,
        orElse: () => PreambleAccessTier.guest,
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
      _fontSizeScale = preferences.getDouble(_fontSizeScaleKey) ?? 1.0;
      _notifyFrequency =
          preferences.getString(_notifyFrequencyKey) ?? 'instant';
      _notifyChannel = preferences.getString(_notifyChannelKey) ?? 'push';
      final orderList = preferences.getStringList(_navbarOrderKey);
      if (orderList != null) {
        _navbarOrder = orderList.map(int.parse).toList();
      } else {
        _navbarOrder = [0, 1, 2, 3, 4];
      }
      _showNavbarLabels = preferences.getBool(_showNavbarLabelsKey) ?? true;
      _accentColorIndex = preferences.getInt(_accentColorIndexKey) ?? 0;
      AppColors.accentColorIndex =
          _accentColorIndex; // 載入時同步給 AppColors 設定動態主題色
      await documentRepository.fetchDrafts();
    } on MissingPluginException {
      // Widget test 或 hot restart 的 plugin 註冊空窗期可能取不到偏好設定；
      // 這裡回退成訪客狀態，讓 App 不會因本機儲存尚未就緒而無法啟動。
      _accessTier = PreambleAccessTier.guest;
      _currentUser = PreambleUser.guest();
      _isDarkMode = false;
      _authToken = null;
      _savedCaseIds.clear();
      _followingSummary = FollowingSummary.empty();
      _caseNoteDrafts = <String, String>{};
      _fontSizeScale = 1.0;
      _notifyFrequency = 'instant';
      _notifyChannel = 'push';
      _navbarOrder = [0, 1, 2, 3, 4];
      _showNavbarLabels = true;
      _accentColorIndex = 0;
      AppColors.accentColorIndex = 0;
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
    _accessTier = PreambleAccessTier.guest;
    _currentUser = PreambleUser.guest();
    _authToken = null;
    await _persist();
    notifyListeners();
  }

  Future<void> updateUserProfile({
    String? displayName,
    String? avatarUrl,
    String? profession,
    String? aiStyle,
  }) async {
    // 更新使用者的專業身分與 AI 對話偏好，並持久化保存。
    _currentUser = _currentUser.copyWith(
      displayName: displayName ?? _currentUser.displayName,
      avatarUrl: avatarUrl ?? _currentUser.avatarUrl,
      profession: profession ?? _currentUser.profession,
      aiStyle: aiStyle ?? _currentUser.aiStyle,
    );
    await _persist();
    notifyListeners();
  }

  Future<void> updateSettings({
    double? fontSizeScale,
    String? notifyFrequency,
    String? notifyChannel,
  }) async {
    // 更新字型大小比例、通知頻率與通知管道設定，並寫入本機偏好設定中。
    _fontSizeScale = fontSizeScale ?? _fontSizeScale;
    _notifyFrequency = notifyFrequency ?? _notifyFrequency;
    _notifyChannel = notifyChannel ?? _notifyChannel;
    await _persist();
    notifyListeners();
  }

  Future<void> updateInterfaceSettings({
    List<int>? navbarOrder,
    bool? showNavbarLabels,
    int? accentColorIndex,
  }) async {
    // 更新導覽列順序、文字標籤開關與品牌 Accent 配色索引，並寫入 SharedPreferences 保存。
    _navbarOrder = navbarOrder ?? _navbarOrder;
    _showNavbarLabels = showNavbarLabels ?? _showNavbarLabels;
    if (accentColorIndex != null) {
      _accentColorIndex = accentColorIndex;
      AppColors.accentColorIndex = accentColorIndex;
    }
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
      await preferences.setDouble(_fontSizeScaleKey, _fontSizeScale);
      await preferences.setString(_notifyFrequencyKey, _notifyFrequency);
      await preferences.setString(_notifyChannelKey, _notifyChannel);
      await preferences.setStringList(
        _navbarOrderKey,
        _navbarOrder.map((e) => e.toString()).toList(),
      );
      await preferences.setBool(_showNavbarLabelsKey, _showNavbarLabels);
      await preferences.setInt(_accentColorIndexKey, _accentColorIndex);
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
      // 本機追蹤資料若因舊版格式壞掉，回到空 summary，避免我的 Preamble 開不起來。
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

  PreambleUser _decodeUser(String? rawUser, PreambleAccessTier fallbackTier) {
    if (rawUser == null || rawUser.isEmpty) {
      return _fallbackUserForTier(fallbackTier);
    }

    try {
      final decoded = jsonDecode(rawUser);
      if (decoded is Map<String, dynamic>) {
        return PreambleUser.fromJson(decoded);
      }
    } on FormatException {
      // 使用者資料壞掉時回退權限層級即可，避免 App 啟動失敗。
    }
    return _fallbackUserForTier(fallbackTier);
  }

  PreambleUser _fallbackUserForTier(PreambleAccessTier tier) {
    switch (tier) {
      case PreambleAccessTier.guest:
        return PreambleUser.guest();
      case PreambleAccessTier.member:
        return PreambleUser.demoMember();
      case PreambleAccessTier.subscriber:
        return PreambleUser.demoSubscriber();
    }
  }

  @override
  void dispose() {
    documentRepository.removeListener(notifyListeners);
    documentRepository.dispose();
    super.dispose();
  }
}

class PreambleScope extends InheritedNotifier<PreambleState> {
  const PreambleScope({
    super.key,
    required PreambleState state,
    required super.child,
  }) : super(notifier: state);

  static PreambleState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<PreambleScope>();
    assert(scope != null, '緒言 PreambleScope was not found in the widget tree.');
    return scope!.notifier!;
  }
}
