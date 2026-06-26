import 'package:preamble/data/following/following_api_service.dart';
import 'package:preamble/data/following/following_models.dart';

class FollowingRepository {
  FollowingRepository({FollowingApiService? apiService})
      : _apiService = apiService ?? FollowingApiService();

  final FollowingApiService _apiService;
  FollowingSummary _summary = FollowingSummary.empty();

  bool get isBackendConfigured => _apiService.hasConfiguredBackend;

  Future<FollowingSummary> getFollowingSummary() async {
    if (isBackendConfigured) {
      _summary = await _apiService.getFollowingSummary();
    }
    return _summary;
  }

  Future<void> followCase(String id) async {
    await _setFollowed(collection: 'cases', id: id, isFollowed: true);
  }

  Future<void> unfollowCase(String id) async {
    await _setFollowed(collection: 'cases', id: id, isFollowed: false);
  }

  Future<void> followTopic(String id) async {
    await _setFollowed(collection: 'topics', id: id, isFollowed: true);
  }

  Future<void> unfollowTopic(String id) async {
    await _setFollowed(collection: 'topics', id: id, isFollowed: false);
  }

  Future<void> followStatute(String id) async {
    await _setFollowed(collection: 'statutes', id: id, isFollowed: true);
  }

  Future<void> unfollowStatute(String id) async {
    await _setFollowed(collection: 'statutes', id: id, isFollowed: false);
  }

  Future<void> saveCase(String id) async {
    await _setSaved(collection: 'cases', id: id, isSaved: true);
  }

  Future<void> unsaveCase(String id) async {
    await _setSaved(collection: 'cases', id: id, isSaved: false);
  }

  Future<void> saveStatute(String id) async {
    await _setSaved(collection: 'statutes', id: id, isSaved: true);
  }

  Future<void> unsaveStatute(String id) async {
    await _setSaved(collection: 'statutes', id: id, isSaved: false);
  }

  Future<void> saveArticle(String id) async {
    await _setSaved(collection: 'articles', id: id, isSaved: true);
  }

  Future<void> unsaveArticle(String id) async {
    await _setSaved(collection: 'articles', id: id, isSaved: false);
  }

  Future<List<FollowedUpdateItem>> getFollowedUpdates() async {
    if (isBackendConfigured) {
      return _apiService.getFollowedUpdates();
    }

    if (_summary.followedCaseIds.isEmpty &&
        _summary.followedTopicIds.isEmpty &&
        _summary.followedStatuteIds.isEmpty) {
      return const [];
    }

    return [
      FollowedUpdateItem(
        id: 'mock-update-1',
        title: '追蹤案件有新資料',
        summary: '你追蹤的案件或主題已有 mock 更新，正式後端會回傳實際異動。',
        source: '緒言 Preamble mock mode',
        updatedAt: DateTime.now(),
        type: 'mock',
      ),
    ];
  }

  void dispose() {
    _apiService.dispose();
  }

  Future<void> _setFollowed({
    required String collection,
    required String id,
    required bool isFollowed,
  }) async {
    if (isBackendConfigured) {
      _summary = await _apiService.setFollowed(
        collection: collection,
        id: id,
        isFollowed: isFollowed,
      );
      return;
    }

    // mock mode 直接改記憶體 summary，讓前端可立即驗證流程；正式後端設定後，
    // 同一個 public method 會改走 API，不需要再改頁面上的按鈕。
    switch (collection) {
      case 'cases':
        _summary = _summary.copyWith(
          followedCaseIds: isFollowed
              ? _add(_summary.followedCaseIds, id)
              : _remove(_summary.followedCaseIds, id),
          updatedAt: DateTime.now(),
        );
      case 'topics':
        _summary = _summary.copyWith(
          followedTopicIds: isFollowed
              ? _add(_summary.followedTopicIds, id)
              : _remove(_summary.followedTopicIds, id),
          updatedAt: DateTime.now(),
        );
      case 'statutes':
        _summary = _summary.copyWith(
          followedStatuteIds: isFollowed
              ? _add(_summary.followedStatuteIds, id)
              : _remove(_summary.followedStatuteIds, id),
          updatedAt: DateTime.now(),
        );
    }
  }

  Future<void> _setSaved({
    required String collection,
    required String id,
    required bool isSaved,
  }) async {
    if (isBackendConfigured) {
      _summary = await _apiService.setSaved(
        collection: collection,
        id: id,
        isSaved: isSaved,
      );
      return;
    }

    switch (collection) {
      case 'cases':
        _summary = _summary.copyWith(
          savedCaseIds: isSaved
              ? _add(_summary.savedCaseIds, id)
              : _remove(_summary.savedCaseIds, id),
          updatedAt: DateTime.now(),
        );
      case 'statutes':
        _summary = _summary.copyWith(
          savedStatuteIds: isSaved
              ? _add(_summary.savedStatuteIds, id)
              : _remove(_summary.savedStatuteIds, id),
          updatedAt: DateTime.now(),
        );
      case 'articles':
        _summary = _summary.copyWith(
          savedArticleIds: isSaved
              ? _add(_summary.savedArticleIds, id)
              : _remove(_summary.savedArticleIds, id),
          updatedAt: DateTime.now(),
        );
    }
  }

  List<String> _add(List<String> current, String id) {
    final set = {...current, id};
    return set.toList(growable: false)..sort();
  }

  List<String> _remove(List<String> current, String id) {
    final set = {...current}..remove(id);
    return set.toList(growable: false)..sort();
  }
}
