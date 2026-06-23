/// 首頁各區塊共用的資料模型定義。
///
/// 目前專案多數畫面仍以假資料驅動，先把資料形狀集中在這裡，
/// 之後接後端資料時只要對應這些型別即可。
class HomeNewsItem {
  const HomeNewsItem({
    required this.badge,
    required this.title,
    this.sourceLabel,
    this.url,
  });

  final String badge;
  final String title;
  final String? sourceLabel;
  final String? url;
}

class HomeNewsletterItem {
  const HomeNewsletterItem({
    required this.title,
    required this.summary,
    required this.tip,
    required this.likes,
    required this.shares,
    required this.comments,
    required this.downloads,
    this.category = '生活',
  });

  final String title;
  final String summary;
  final String tip;
  final String likes;
  final String shares;
  final String comments;
  final String downloads;
  final String category;
}

class HomeTrackedTopic {
  const HomeTrackedTopic({
    required this.hashtag,
    required this.title,
    required this.summary,
  });

  final String hashtag;
  final String title;
  final String summary;
}

class HomeQuizOption {
  const HomeQuizOption({
    required this.title,
    required this.isCorrect,
  });

  final String title;
  final bool isCorrect;
}

class HomeQuizQuestion {
  const HomeQuizQuestion({
    required this.question,
    required this.options,
    required this.hint,
    required this.explanation,
    required this.termExplainMap,
  });

  final String question;
  final List<HomeQuizOption> options;
  final String hint;
  final String explanation;
  final Map<String, String> termExplainMap;
}

class HomeDiscussionTrendPoint {
  const HomeDiscussionTrendPoint({
    required this.dateLabel,
    required this.volumeLabel,
    this.annotation,
  });

  final String dateLabel;
  final String volumeLabel;
  final String? annotation;
}

class HomeDiscussionPollOption {
  const HomeDiscussionPollOption({
    required this.label,
    required this.votes,
  });

  final String label;
  final int votes;
}

class HomeDiscussionPoll {
  const HomeDiscussionPoll({
    required this.prompt,
    required this.options,
  });

  final String prompt;
  final List<HomeDiscussionPollOption> options;
}

class HomeDiscussionComment {
  const HomeDiscussionComment({
    required this.content,
    required this.submittedAt,
    required this.userHandle,
  });

  final String content;
  final String submittedAt;
  final String userHandle;
}

class HomeDiscussionTimelineEvent {
  const HomeDiscussionTimelineEvent({
    required this.pointIndex,
    required this.timeLabel,
    required this.description,
    required this.impactLabel,
  });

  final int pointIndex;
  final String timeLabel;
  final String description;
  final String impactLabel;
}

class HomeDiscussionTopic {
  const HomeDiscussionTopic({
    required this.headline,
    required this.title,
    required this.heatScore,
    required this.rank,
    required this.dayChangePercent,
    required this.weekRankDelta,
    required this.overview,
    required this.heatLabel,
    required this.trendPoints,
    required this.timelineEvents,
    required this.poll,
    required this.latestComment,
    required this.tags,
  });

  final String headline;
  final String title;
  final int heatScore;
  final int rank;
  final int dayChangePercent;
  final int weekRankDelta;
  final String overview;
  final String heatLabel;
  final List<HomeDiscussionTrendPoint> trendPoints;
  final List<HomeDiscussionTimelineEvent> timelineEvents;
  final HomeDiscussionPoll? poll;
  final HomeDiscussionComment latestComment;
  final List<String> tags;
}

class HomeDiscussionFeed {
  const HomeDiscussionFeed({
    required this.collectionSlogan,
    required this.topics,
    required this.actionLabels,
  });

  final String collectionSlogan;
  final List<HomeDiscussionTopic> topics;
  final List<String> actionLabels;
}
