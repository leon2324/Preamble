import 'package:preamble/data/moj/moj_feed_item.dart';
import 'package:preamble/data/moj/moj_feed_service.dart';
import 'package:preamble/data/official/official_feed_api_service.dart';

class OfficialFeedRepository {
  OfficialFeedRepository({
    MojFeedService? mojFeedService,
    OfficialFeedApiService? apiService,
  })  : _mojFeedService = mojFeedService ?? MojFeedService(),
        _apiService = apiService ?? OfficialFeedApiService();

  final MojFeedService _mojFeedService;
  final OfficialFeedApiService _apiService;

  Future<List<MojFeedItem>> fetchOfficialNews() async {
    if (_apiService.hasConfiguredBackend) {
      try {
        final remote = await _apiService.fetchNews();
        if (remote.isNotEmpty) return remote;
      } catch (__) {
        // 降級回 MojFeedService / 本機示範項
      }
    }
    try {
      return await _mojFeedService.fetchItems(MojFeedCategory.news);
    } catch (__) {
      return _mockOfficialItems;
    }
  }

  Future<List<MojFeedItem>> fetchPressReleases() async {
    if (_apiService.hasConfiguredBackend) {
      try {
        final remote = await _apiService.fetchPressReleases();
        if (remote.isNotEmpty) return remote;
      } catch (__) {
        // 降級回 MojFeedService / 本機示範項
      }
    }
    return fetchOfficialNews();
  }

  Future<List<MojFeedItem>> fetchAnnouncements() async {
    if (_apiService.hasConfiguredBackend) {
      try {
        final remote = await _apiService.fetchAnnouncements();
        if (remote.isNotEmpty) return remote;
      } catch (__) {
        // 降級回 MojFeedService / 本機示範項
      }
    }
    try {
      return await _mojFeedService.fetchItems(MojFeedCategory.lawUpdates);
    } catch (__) {
      return _mockOfficialItems;
    }
  }

  void dispose() {
    _mojFeedService.dispose();
    _apiService.dispose();
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
