import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:lawapp/config/supabase_config.dart';
import 'package:lawapp/features/case_time_machine/models/case_time_machine_models.dart';
import 'package:lawapp/features/case_time_machine/data/case_time_machine_mock_data.dart';

class SupabaseCaseService {
  SupabaseCaseService._privateConstructor();
  static final SupabaseCaseService instance = SupabaseCaseService._privateConstructor();

  bool get isConfigured {
    // 偵測是否在單元測試環境中，若是，則降級返回 false 避免發送真實網路請求
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return false;
    }
    return supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
  }

  Map<String, String> get _headers => {
        'apikey': supabaseAnonKey,
        'Authorization': 'Bearer $supabaseAnonKey',
        'Content-Type': 'application/json',
      };

  /// 從雲端或模擬層獲取分頁與篩選案件列表
  Future<List<CaseBook>> fetchCases(
    int limit,
    int offset, {
    String? category,
    String? query,
  }) async {
    if (!isConfigured) {
      // 降級為模擬雲端服務，讀取高品質本地真實案件
      if (!Platform.environment.containsKey('FLUTTER_TEST')) {
        await Future<void>.delayed(const Duration(milliseconds: 300)); // 模擬網路延遲
      }
      Iterable<CaseBook> filtered = caseTimeMachineCasesSeed;

      if (category != null && category != '全部') {
        filtered = filtered.where((c) => c.category == category);
      }

      if (query != null && query.trim().isNotEmpty) {
        final lowerQuery = query.toLowerCase();
        filtered = filtered.where((c) =>
            c.titleZh.toLowerCase().contains(lowerQuery) ||
            c.shortDescription.toLowerCase().contains(lowerQuery) ||
            c.memoryLine.toLowerCase().contains(lowerQuery) ||
            c.tags.any((tag) => tag.toLowerCase().contains(lowerQuery)));
      }

      final sorted = filtered.toList()
        ..sort((a, b) {
          final yearCompare = b.year.compareTo(a.year);
          if (yearCompare != 0) return yearCompare;
          return b.id.compareTo(a.id);
        });

      if (offset >= sorted.length) return [];
      final end = (offset + limit) < sorted.length ? (offset + limit) : sorted.length;
      return sorted.sublist(offset, end);
    }

    // 真實 Supabase 雲端查詢
    try {
      final queryParams = <String>[
        'select=id,titleZh,titleEn,shortTitleZh,shortTitleEn,displayCode,year,location,status,category,tags,memoryLine,shortDescription,oneSentenceSummary,caseType,procedureStage,courtLevel,updatedAt,images',
        'limit=$limit',
        'offset=$offset',
        'order=year.desc,id.desc',
      ];

      if (category != null && category != '全部') {
        queryParams.add('category=eq.${Uri.encodeComponent(category)}');
      }

      if (query != null && query.trim().isNotEmpty) {
        final escapedQuery = '%${query.trim()}%';
        // 使用 Postgres 的 or 條件做模糊搜尋
        queryParams.add(
            'or=(titleZh.ilike.${Uri.encodeComponent(escapedQuery)},shortDescription.ilike.${Uri.encodeComponent(escapedQuery)},memoryLine.ilike.${Uri.encodeComponent(escapedQuery)})');
      }

      final url = Uri.parse('$supabaseUrl/rest/v1/cases?${queryParams.join('&')}');
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body) as List<dynamic>;
        return list.map((item) => _mapJsonToCaseBook(item as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Supabase fetch error: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Supabase fetch failed, error propagated: $e');
      rethrow;
    }
  }

  /// 從雲端或模擬層獲取案件完整詳情
  Future<CaseBook> fetchCaseDetail(String id) async {
    if (!isConfigured) {
      if (!Platform.environment.containsKey('FLUTTER_TEST')) {
        await Future<void>.delayed(const Duration(milliseconds: 250)); // 模擬網路延遲
      }
      final found = caseTimeMachineCasesSeed.firstWhere(
        (c) => c.id == id,
        orElse: () => caseTimeMachineCasesSeed.first,
      );
      return found;
    }

    try {
      final url = Uri.parse('$supabaseUrl/rest/v1/cases?id=eq.${Uri.encodeComponent(id)}&select=*');
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body) as List<dynamic>;
        if (list.isNotEmpty) {
          return _mapJsonToCaseBook(list.first as Map<String, dynamic>);
        } else {
          throw Exception('Case not found on Supabase: $id');
        }
      } else {
        throw Exception('Supabase fetch detail error: ${response.statusCode}');
      }
    } catch (e) {
      print('Supabase fetch detail failed, error propagated: $e');
      rethrow;
    }
  }

  /// 將 Supabase 回傳的 JSON Map 轉換為 Dart Model CaseBook
  CaseBook _mapJsonToCaseBook(Map<String, dynamic> map) {
    // 處理 tags，因為可能為 String（來自 SQLite）、List（來自 JSONB）或空
    List<String> tagsList = [];
    if (map['tags'] != null) {
      if (map['tags'] is String) {
        try {
          tagsList = List<String>.from(jsonDecode(map['tags'] as String) as List);
        } catch (__) {}
      } else if (map['tags'] is List) {
        tagsList = List<String>.from(map['tags'] as List);
      }
    }

    // 處理各個 JSONB/JSON 欄位
    List<CaseTimelineItem> timelineList = [];
    if (map['timeline'] != null) {
      final timelineData = map['timeline'] is String
          ? jsonDecode(map['timeline'] as String)
          : map['timeline'];
      if (timelineData is List) {
        timelineList = timelineData
            .map((item) => CaseTimelineItem(
                  dateLabel: item['dateLabel'] as String? ?? '',
                  title: item['title'] as String? ?? '',
                  description: item['description'] as String? ?? '',
                ))
            .toList();
      }
    }

    List<CasePersonRole> peopleList = [];
    if (map['people'] != null) {
      final peopleData = map['people'] is String
          ? jsonDecode(map['people'] as String)
          : map['people'];
      if (peopleData is List) {
        peopleList = peopleData
            .map((item) => CasePersonRole(
                  role: item['role'] as String? ?? '',
                  description: item['description'] as String? ?? '',
                ))
            .toList();
      }
    }

    List<LegalIssue> legalIssuesList = [];
    if (map['legalIssues'] != null) {
      final data = map['legalIssues'] is String
          ? jsonDecode(map['legalIssues'] as String)
          : map['legalIssues'];
      if (data is List) {
        legalIssuesList = data
            .map((item) => LegalIssue(
                  title: item['title'] as String? ?? '',
                  plainExplanation: item['plainExplanation'] as String? ?? '',
                  relationToCase: item['relationToCase'] as String? ?? '',
                  relatedLawIds: List<String>.from(item['relatedLawIds'] as List? ?? []),
                ))
            .toList();
      }
    }

    List<RelatedLaw> relatedLawsList = [];
    if (map['relatedLaws'] != null) {
      final data = map['relatedLaws'] is String
          ? jsonDecode(map['relatedLaws'] as String)
          : map['relatedLaws'];
      if (data is List) {
        relatedLawsList = data
            .map((item) => RelatedLaw(
                  lawName: item['lawName'] as String? ?? '',
                  articleNumber: item['articleNumber'] as String? ?? '',
                  plainSummary: item['plainSummary'] as String? ?? '',
                  relationToCase: item['relationToCase'] as String? ?? '',
                ))
            .toList();
      }
    }

    List<RelatedCase> relatedCasesList = [];
    if (map['relatedCases'] != null) {
      final data = map['relatedCases'] is String
          ? jsonDecode(map['relatedCases'] as String)
          : map['relatedCases'];
      if (data is List) {
        relatedCasesList = data
            .map((item) => RelatedCase(
                  caseId: item['caseId'] as String? ?? '',
                  title: item['title'] as String? ?? '',
                  yearLabel: item['yearLabel'] as String? ?? '',
                  reason: item['reason'] as String? ?? '',
                ))
            .toList();
      }
    }

    List<CaseSource> sourcesList = [];
    if (map['sources'] != null) {
      final data = map['sources'] is String
          ? jsonDecode(map['sources'] as String)
          : map['sources'];
      if (data is List) {
        sourcesList = data
            .map((item) => CaseSource(
                  title: item['title'] as String? ?? '',
                  sourceType: item['sourceType'] as String? ?? '',
                  updatedAt: item['updatedAt'] as String? ?? '',
                  url: item['url'] as String?,
                ))
            .toList();
      }
    }

    List<CaseOpinion> concurringDissentingOpinionsList = [];
    if (map['concurringDissentingOpinions'] != null) {
      final data = map['concurringDissentingOpinions'] is String
          ? jsonDecode(map['concurringDissentingOpinions'] as String)
          : map['concurringDissentingOpinions'];
      if (data is List) {
        concurringDissentingOpinionsList = data
            .map((item) => CaseOpinion(
                  justiceName: item['justiceName'] as String? ?? '',
                  opinionType: item['opinionType'] as String? ?? '',
                  summary: item['summary'] as String? ?? '',
                ))
            .toList();
      }
    }

    List<CourtArgument> courtArgumentsList = [];
    if (map['courtArguments'] != null) {
      final data = map['courtArguments'] is String
          ? jsonDecode(map['courtArguments'] as String)
          : map['courtArguments'];
      if (data is List) {
        courtArgumentsList = data
            .map((item) => CourtArgument(
                  partyName: item['partyName'] as String? ?? '',
                  mainPoint: item['mainPoint'] as String? ?? '',
                ))
            .toList();
      }
    }

    List<ExpertOpinion> expertOpinionsList = [];
    if (map['expertOpinions'] != null) {
      final data = map['expertOpinions'] is String
          ? jsonDecode(map['expertOpinions'] as String)
          : map['expertOpinions'];
      if (data is List) {
        expertOpinionsList = data
            .map((item) => ExpertOpinion(
                  expertName: item['expertName'] as String? ?? '',
                  title: item['title'] as String? ?? '',
                  summary: item['summary'] as String? ?? '',
                ))
            .toList();
      }
    }

    List<MediaReference> mediaReferencesList = [];
    if (map['mediaReferences'] != null) {
      final data = map['mediaReferences'] is String
          ? jsonDecode(map['mediaReferences'] as String)
          : map['mediaReferences'];
      if (data is List) {
        mediaReferencesList = data
            .map((item) => MediaReference(
                  title: item['title'] as String? ?? '',
                  platform: item['platform'] as String? ?? '',
                  url: item['url'] as String? ?? '',
                  mediaType: item['mediaType'] as String? ?? '',
                ))
            .toList();
      }
    }

    List<CaseImage> imagesList = [];
    if (map['images'] != null) {
      final data = map['images'] is String
          ? jsonDecode(map['images'] as String)
          : map['images'];
      if (data is List) {
        imagesList = data
            .map((item) => CaseImage(
                  url: item['url'] as String? ?? '',
                  source: item['source'] as String? ?? '',
                ))
            .toList();
      }
    }

    return CaseBook(
      id: map['id'] as String? ?? '',
      titleZh: map['titleZh'] as String? ?? '',
      titleEn: map['titleEn'] as String? ?? '',
      shortTitleZh: map['shortTitleZh'] as String? ?? '',
      shortTitleEn: map['shortTitleEn'] as String? ?? '',
      displayCode: map['displayCode'] as String? ?? '',
      year: map['year'] is int ? map['year'] as int : int.tryParse(map['year']?.toString() ?? '0') ?? 0,
      location: map['location'] as String? ?? '',
      status: map['status'] as String? ?? '',
      category: map['category'] as String? ?? '',
      tags: tagsList,
      memoryLine: map['memoryLine'] as String? ?? '',
      shortDescription: map['shortDescription'] as String? ?? '',
      oneSentenceSummary: map['oneSentenceSummary'] as String? ?? '',
      background: map['background'] as String? ?? '',
      fullStory: map['fullStory'] as String? ?? '',
      investigationAndTrial: map['investigationAndTrial'] as String? ?? '',
      courtReasoning: map['courtReasoning'] as String? ?? '',
      judgmentResult: map['judgmentResult'] as String? ?? '',
      socialImpact: map['socialImpact'] as String? ?? '',
      isFavorite: map['isFavorite'] == true || map['isFavorite'] == 1,
      isFollowing: map['isFollowing'] == true || map['isFollowing'] == 1,
      basicInfo: CaseBasicInfo(
        caseType: map['caseType'] as String? ?? '',
        procedureStage: map['procedureStage'] as String? ?? '',
        courtLevel: map['courtLevel'] as String? ?? '',
        updatedAt: map['updatedAt'] as String? ?? '',
      ),
      timeline: timelineList,
      people: peopleList,
      legalIssues: legalIssuesList,
      relatedLaws: relatedLawsList,
      relatedCases: relatedCasesList,
      sources: sourcesList,
      concurringDissentingOpinions: concurringDissentingOpinionsList,
      courtArguments: courtArgumentsList,
      expertOpinions: expertOpinionsList,
      mediaReferences: mediaReferencesList,
      images: imagesList,
    );
  }
}
