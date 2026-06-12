enum CaseLibraryHallType { timeline, theme, classic, status }

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
    this.concurringDissentingOpinions = const [],
    this.courtArguments = const [],
    this.expertOpinions = const [],
    this.mediaReferences = const [],
    this.images = const [],
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
  final List<CaseOpinion> concurringDissentingOpinions;
  final List<CourtArgument> courtArguments;
  final List<ExpertOpinion> expertOpinions;
  final List<MediaReference> mediaReferences;
  final List<CaseImage> images;

  // Getter to filter image sources for display
  List<CaseSource> get displayImages => sources.where((s) => s.sourceType == 'image').toList();

  CaseBook copyWith({
    String? id,
    String? titleZh,
    String? titleEn,
    String? shortTitleZh,
    String? shortTitleEn,
    String? displayCode,
    int? year,
    String? location,
    String? status,
    String? category,
    List<String>? tags,
    String? memoryLine,
    String? shortDescription,
    CaseBasicInfo? basicInfo,
    String? oneSentenceSummary,
    String? background,
    String? fullStory,
    List<CaseTimelineItem>? timeline,
    List<CasePersonRole>? people,
    List<LegalIssue>? legalIssues,
    String? investigationAndTrial,
    String? courtReasoning,
    String? judgmentResult,
    List<RelatedLaw>? relatedLaws,
    String? socialImpact,
    List<RelatedCase>? relatedCases,
    List<CaseSource>? sources,
    bool? isFavorite,
    bool? isFollowing,
    List<CaseOpinion>? concurringDissentingOpinions,
    List<CourtArgument>? courtArguments,
    List<ExpertOpinion>? expertOpinions,
    List<MediaReference>? mediaReferences,
    List<CaseImage>? images,
  }) {
    return CaseBook(
      id: id ?? this.id,
      titleZh: titleZh ?? this.titleZh,
      titleEn: titleEn ?? this.titleEn,
      shortTitleZh: shortTitleZh ?? this.shortTitleZh,
      shortTitleEn: shortTitleEn ?? this.shortTitleEn,
      displayCode: displayCode ?? this.displayCode,
      year: year ?? this.year,
      location: location ?? this.location,
      status: status ?? this.status,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      memoryLine: memoryLine ?? this.memoryLine,
      shortDescription: shortDescription ?? this.shortDescription,
      basicInfo: basicInfo ?? this.basicInfo,
      oneSentenceSummary: oneSentenceSummary ?? this.oneSentenceSummary,
      background: background ?? this.background,
      fullStory: fullStory ?? this.fullStory,
      timeline: timeline ?? this.timeline,
      people: people ?? this.people,
      legalIssues: legalIssues ?? this.legalIssues,
      investigationAndTrial: investigationAndTrial ?? this.investigationAndTrial,
      courtReasoning: courtReasoning ?? this.courtReasoning,
      judgmentResult: judgmentResult ?? this.judgmentResult,
      relatedLaws: relatedLaws ?? this.relatedLaws,
      socialImpact: socialImpact ?? this.socialImpact,
      relatedCases: relatedCases ?? this.relatedCases,
      sources: sources ?? this.sources,
      isFavorite: isFavorite ?? this.isFavorite,
      isFollowing: isFollowing ?? this.isFollowing,
      concurringDissentingOpinions: concurringDissentingOpinions ?? this.concurringDissentingOpinions,
      courtArguments: courtArguments ?? this.courtArguments,
      expertOpinions: expertOpinions ?? this.expertOpinions,
      mediaReferences: mediaReferences ?? this.mediaReferences,
      images: images ?? this.images,
    );
  }
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
    this.url,
  });

  final String title;
  final String sourceType;
  final String updatedAt;
  final String? url;
}

class CaseOpinion {
  const CaseOpinion({
    required this.justiceName,
    required this.opinionType,
    required this.summary,
  });

  final String justiceName;
  final String opinionType;
  final String summary;
}

class CourtArgument {
  const CourtArgument({
    required this.partyName,
    required this.mainPoint,
  });

  final String partyName;
  final String mainPoint;
}

class ExpertOpinion {
  const ExpertOpinion({
    required this.expertName,
    required this.title,
    required this.summary,
  });

  final String expertName;
  final String title;
  final String summary;
}

class MediaReference {
  const MediaReference({
    required this.title,
    required this.platform,
    required this.url,
    required this.mediaType,
  });

  final String title;
  final String platform;
  final String url;
  final String mediaType;
}

class CaseImage {
  const CaseImage({
    required this.url,
    required this.source,
  });

  final String url;
  final String source;
}
