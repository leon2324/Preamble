enum CaseLibraryHallType { timeline, theme, classic }

/// 案件圖書館第一層：館別。
///
/// 台灣繁體中文教學註解：
/// 這個 feature 的資訊架構不是「案件列表」，而是三層館藏：館 → 書架 → 案件之書。
/// 所以 Hall/Shelf/Book 都要有獨立模型，未來接後端時也能維持同一個資料語意。
class CaseLibraryHall {
  const CaseLibraryHall({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.shelves,
  });

  final String id;
  final String name;
  final String description;
  final CaseLibraryHallType type;
  final List<CaseShelf> shelves;
}

class CaseShelf {
  const CaseShelf({
    required this.id,
    required this.hallId,
    required this.name,
    required this.description,
    required this.coverStyle,
    required this.caseIds,
  });

  final String id;
  final String hallId;
  final String name;
  final String description;
  final String coverStyle;
  final List<String> caseIds;
}

class CaseBook {
  const CaseBook({
    required this.id,
    required this.titleZh,
    required this.titleEn,
    required this.shortTitleZh,
    required this.shortTitleEn,
    required this.displayCode,
    required this.year,
    required this.location,
    required this.status,
    required this.category,
    required this.tags,
    required this.memoryLine,
    required this.shortDescription,
    required this.basicInfo,
    required this.oneSentenceSummary,
    required this.background,
    required this.fullStory,
    required this.timeline,
    required this.people,
    required this.legalIssues,
    required this.investigationAndTrial,
    required this.courtReasoning,
    required this.judgmentResult,
    required this.relatedLaws,
    required this.socialImpact,
    required this.relatedCases,
    required this.sources,
    this.isFavorite = false,
    this.isFollowing = false,
  });

  final String id;
  final String titleZh;
  final String titleEn;
  final String shortTitleZh;
  final String shortTitleEn;
  final String displayCode;
  final int year;
  final String location;
  final String status;
  final String category;
  final List<String> tags;
  final String memoryLine;
  final String shortDescription;
  final CaseBasicInfo basicInfo;
  final String oneSentenceSummary;
  final String background;
  final String fullStory;
  final List<CaseTimelineItem> timeline;
  final List<CasePersonRole> people;
  final List<LegalIssue> legalIssues;
  final String investigationAndTrial;
  final String courtReasoning;
  final String judgmentResult;
  final List<RelatedLaw> relatedLaws;
  final String socialImpact;
  final List<RelatedCase> relatedCases;
  final List<CaseSource> sources;
  final bool isFavorite;
  final bool isFollowing;
}

class CaseBasicInfo {
  const CaseBasicInfo({
    required this.caseType,
    required this.procedureStage,
    required this.courtLevel,
    required this.updatedAt,
  });

  final String caseType;
  final String procedureStage;
  final String courtLevel;
  final String updatedAt;
}

class CaseTimelineItem {
  const CaseTimelineItem({
    required this.dateLabel,
    required this.title,
    required this.description,
  });

  final String dateLabel;
  final String title;
  final String description;
}

class CasePersonRole {
  const CasePersonRole({
    required this.role,
    required this.description,
  });

  final String role;
  final String description;
}

class LegalIssue {
  const LegalIssue({
    required this.title,
    required this.plainExplanation,
    required this.relationToCase,
    required this.relatedLawIds,
  });

  final String title;
  final String plainExplanation;
  final String relationToCase;
  final List<String> relatedLawIds;
}

class RelatedLaw {
  const RelatedLaw({
    required this.lawName,
    required this.articleNumber,
    required this.plainSummary,
    required this.relationToCase,
  });

  final String lawName;
  final String articleNumber;
  final String plainSummary;
  final String relationToCase;
}

class RelatedCase {
  const RelatedCase({
    required this.caseId,
    required this.title,
    required this.yearLabel,
    required this.reason,
  });

  final String caseId;
  final String title;
  final String yearLabel;
  final String reason;
}

class CaseSource {
  const CaseSource({
    required this.title,
    required this.sourceType,
    required this.updatedAt,
  });

  final String title;
  final String sourceType;
  final String updatedAt;
}
