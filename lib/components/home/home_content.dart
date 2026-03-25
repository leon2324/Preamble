class HomeNewsItem {
  const HomeNewsItem({
    required this.badge,
    required this.title,
  });

  final String badge;
  final String title;
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
  });

  final String title;
  final String summary;
  final String tip;
  final String likes;
  final String shares;
  final String comments;
  final String downloads;
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
