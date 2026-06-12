class OnThisDayCase {
  const OnThisDayCase({
    required this.id,
    required this.year,
    required this.month,
    required this.day,
    required this.location,
    required this.title,
    required this.category,
    required this.tags,
    required this.summary,
    required this.quote,
    required this.background,
    required this.backgroundDetails,
    required this.socialImpact,
    required this.status,
    required this.timeline,
    required this.photos,
    required this.relatedCaseTitles,
    required this.relatedReadings,
    required this.sources,
  });

  final String id;
  final int year;
  final int month;
  final int day;
  final String location;
  final String title;
  final String category;
  final List<String> tags;
  final String summary;
  final String quote;
  final String background;
  final String backgroundDetails;
  final String socialImpact;
  final String status;
  final List<OnThisDayTimelineNode> timeline;
  final List<OnThisDayPhoto> photos;
  final List<String> relatedCaseTitles;
  final List<OnThisDayReading> relatedReadings;
  final List<OnThisDaySource> sources;

  String get monthDayLabel => '$month / $day';
  String get fullDateLabel => '$year.${month.toString().padLeft(2, '0')}.${day.toString().padLeft(2, '0')}';
}

class OnThisDayTimelineNode {
  const OnThisDayTimelineNode({
    required this.dateLabel,
    required this.title,
    required this.description,
  });

  final String dateLabel;
  final String title;
  final String description;
}

class OnThisDayPhoto {
  const OnThisDayPhoto({
    required this.photoUrl,
    required this.caption,
  });

  final String photoUrl;
  final String caption;
}

class OnThisDayReading {
  const OnThisDayReading({
    required this.title,
    required this.url,
  });

  final String title;
  final String url;
}

class OnThisDaySource {
  const OnThisDaySource({
    required this.title,
    required this.url,
    required this.updatedAt,
  });

  final String title;
  final String url;
  final String updatedAt;
}
