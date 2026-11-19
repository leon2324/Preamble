import 'package:preamble/data/moj/moj_feed_item.dart';
import 'package:preamble/data/moj/moj_feed_service.dart';
import 'package:preamble/data/official/official_feed_api_service.dart';
import 'package:preamble/data/common/data_fallback_policy.dart';

class OfficialFeedRepository {
  OfficialFeedRepository({
    MojFeedService? mojFeedService,
    OfficialFeedApiService? apiService,
    this.fallbackPolicy = DataFallbackPolicy.demo,
  })  : _mojFeedService = mojFeedService ?? MojFeedService(),
        _apiService = apiService ?? OfficialFeedApiService(),
        _ownsMojFeedService = mojFeedService == null,
        _ownsApiService = apiService == null;

  final MojFeedService _mojFeedService;
  final OfficialFeedApiService _apiService;
  final DataFallbackPolicy fallbackPolicy;
  // 台灣繁體中文教學註解：兩個來源各自追蹤所有權，避免關閉外部注入的共用服務。
  final bool _ownsMojFeedService;
  final bool _ownsApiService;

  Future<List<MojFeedItem>> fetchOfficialNews() async {
    return _readItems(_apiService.fetchNews, _localNews);
  }

  Future<List<MojFeedItem>> _localNews() async {
    try {
      return await _mojFeedService.fetchItems(MojFeedCategory.news);
    } catch (__) {
      return _mockOfficialItems;
    }
  }

  Future<List<MojFeedItem>> fetchPressReleases() async {
    return _readItems(_apiService.fetchPressReleases, fetchOfficialNews);
  }

  Future<List<MojFeedItem>> fetchAnnouncements() async {
    return _readItems(_apiService.fetchAnnouncements, _localAnnouncements);
  }

  Future<List<MojFeedItem>> _localAnnouncements() async {
    try {
      return await _mojFeedService.fetchItems(MojFeedCategory.lawUpdates);
    } catch (__) {
      return _mockOfficialItems;
    }
  }

  /// 台灣繁體中文教學註解：後端空清單、後端錯誤與未設定是不同原因；
  /// 預設維持 MOJ／示範資料回退，strict 模式則照實回空或把錯誤傳上去。
  Future<List<MojFeedItem>> _readItems(
    Future<List<MojFeedItem>> Function() fetchRemote,
    Future<List<MojFeedItem>> Function() fetchFallback,
  ) async {
    if (_apiService.hasConfiguredBackend) {
      try {
        final remote = await fetchRemote();
        if (remote.isNotEmpty || !fallbackPolicy.onRemoteEmpty) return remote;
      } catch (__) {
        if (!fallbackPolicy.onRemoteError) rethrow;
      }
    } else if (!fallbackPolicy.onUnconfigured) {
      throw const DataSourceUnavailableException('官方訊息後端');
    }
    return fetchFallback();
  }

  void dispose() {
    if (_ownsMojFeedService) _mojFeedService.dispose();
    if (_ownsApiService) _apiService.dispose();
  }
}

final _mockOfficialItems = [
  MojFeedItem(
    title: '法務部公開資料示範項目',
    url: 'https://www.moj.gov.tw/',
    category: MojFeedCategory.news,
    index: 0,
  ),
];
