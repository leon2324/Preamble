import 'package:lawapp/data/moj/moj_feed_item.dart';
import 'package:lawapp/data/moj/moj_feed_service.dart';

class OfficialFeedRepository {
  OfficialFeedRepository({MojFeedService? mojFeedService})
      : _mojFeedService = mojFeedService ?? MojFeedService();

  final MojFeedService _mojFeedService;

  Future<List<MojFeedItem>> fetchOfficialNews() async {
    try {
      return _mojFeedService.fetchItems(MojFeedCategory.news);
    } catch (__) {
      return _mockOfficialItems;
    }
  }

  Future<List<MojFeedItem>> fetchPressReleases() => fetchOfficialNews();

  Future<List<MojFeedItem>> fetchAnnouncements() async {
    try {
      return _mojFeedService.fetchItems(MojFeedCategory.lawUpdates);
    } catch (__) {
      return _mockOfficialItems;
    }
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
