enum MojFeedCategory {
  news,
  lawUpdates,
}

extension MojFeedCategoryInfo on MojFeedCategory {
  Uri get uri {
    switch (this) {
      case MojFeedCategory.news:
        return Uri.parse('https://www.moj.gov.tw/2204/2795/2796/');
      case MojFeedCategory.lawUpdates:
        return Uri.parse('https://www.moj.gov.tw/2204/2795/2798/');
    }
  }

  String get title {
    switch (this) {
      case MojFeedCategory.news:
        return '法務部新聞';
      case MojFeedCategory.lawUpdates:
        return '全國法規最新消息';
    }
  }

  String get badge {
    switch (this) {
      case MojFeedCategory.news:
        return '新聞';
      case MojFeedCategory.lawUpdates:
        return '法規';
    }
  }

  String get sourceLabel => '法務部全球資訊網';
}

class MojFeedItem {
  const MojFeedItem({
    required this.title,
    required this.url,
    required this.category,
    required this.index,
  });

  final String title;
  final String url;
  final MojFeedCategory category;
  final int index;

  String get badge => category.badge;
  String get sourceLabel => category.sourceLabel;
}
