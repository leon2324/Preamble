import 'dart:convert';
import 'dart:math';
import 'dart:io' show HttpException, Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:preamble/config/supabase_config.dart';
import 'package:preamble/data/mock_data/learning/learning_mock_data.dart';

/// 負責對接 Supabase 雲端資料庫抓取精選與日常法律情境專題的服務類別
class SupabaseLearningService {
  SupabaseLearningService({http.Client? client, bool? configured})
      : _client = client ?? http.Client(),
        _ownsClient = client == null,
        _configuredOverride = configured;
  static final SupabaseLearningService instance = SupabaseLearningService();

  final http.Client _client;
  final bool _ownsClient;
  final bool? _configuredOverride;

  void dispose() {
    if (_ownsClient) _client.close();
  }

  bool get isConfigured {
    // 台灣繁體中文教學註解：測試可注入來源狀態與 HTTP client，正式單例仍依環境判斷。
    if (_configuredOverride != null) return _configuredOverride;
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

  /// 根據分類、關鍵字搜尋，向 Supabase 進行分頁查詢
  Future<List<LearningMockArticle>> fetchArticles({
    String? category,
    String? query,
    int limit = 20,
    int offset = 0,
  }) async {
    if (!isConfigured) {
      return _getLocalFallbackArticles(
          category: category, query: query, limit: limit, offset: offset);
    }

    try {
      final queryParams = <String>[
        'select=*',
        'limit=$limit',
        'offset=$offset',
        'order=title.asc',
      ];

      if (category != null && category != '全部') {
        queryParams.add('category=eq.${Uri.encodeComponent(category)}');
      }

      if (query != null && query.trim().isNotEmpty) {
        final trimmed = query.trim();
        final escapedQuery = '%$trimmed%';
        queryParams.add(
            'or=(title.ilike.${Uri.encodeComponent(escapedQuery)},summary.ilike.${Uri.encodeComponent(escapedQuery)})');
      }

      final url = Uri.parse(
          '$supabaseUrl/rest/v1/learning_articles?${queryParams.join('&')}');
      final response = await _client.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body) as List<dynamic>;
        return list
            .map((item) => _mapJsonToArticle(item as Map<String, dynamic>))
            .toList();
      }
      // 台灣繁體中文教學註解：已設定正式來源時，HTTP 錯誤必須交給呼叫端處理，
      // 不能以示範文章偽裝成雲端查詢結果。
      throw HttpException(
          'Supabase learning articles: HTTP ${response.statusCode}');
    } catch (e) {
      debugPrint('Supabase fetch learning failed: $e');
      rethrow;
    }
  }

  LearningMockArticle _mapJsonToArticle(Map<String, dynamic> json) {
    final List<dynamic> sectionsJson = json['sections'] ?? [];
    final sections = sectionsJson
        .map((sec) => LearningMockSection(
              title: sec['title'] ?? '',
              body: sec['body'] ?? '',
            ))
        .toList();

    final List<dynamic> keyPointsJson = json['key_points'] ?? [];
    final keyPoints = keyPointsJson.map((kp) => kp.toString()).toList();

    Map<String, dynamic>? quizData;
    if (json['quiz_data'] != null) {
      quizData = Map<String, dynamic>.from(json['quiz_data']);
    }

    return LearningMockArticle(
      badge: json['badge'] ?? '學習單元',
      title: json['title'] ?? '',
      summary: json['summary'] ?? '',
      readTime: json['read_time'] ?? '3 分鐘',
      heroNote: json['hero_note'] ?? '',
      keyPoints: keyPoints,
      sections: sections,
      category: json['category'] ?? '法律常識',
      quizData: quizData,
      topicId: json['topic_id'],
      stepNumber: json['step_number'],
      heroImageUrl: json['hero_image_url'],
    );
  }

  /// 依據日期隨機獲取 5 組專題 (共 25 筆單元)
  Future<List<LearningTopicData>> fetchDailyFeaturedTopics(
      DateTime date) async {
    if (!isConfigured) {
      return _getLocalFallbackFeaturedTopics();
    }

    try {
      // 台灣繁體中文教學註解：先列出雲端確實存在的專題 ID，再以日期當種子選取。
      // 原本從 1–1000 猜 ID，資料稀疏時會把「有資料」誤判為「空結果」。
      final availableTopicIds = await _fetchAvailableTopicIds();
      if (availableTopicIds.isEmpty) return const [];

      // 1. 使用日期產生確定性的隨機種子
      final seed = date.year * 10000 + date.month * 100 + date.day;
      final rand = Random(seed);
      final selectedTopicIds = availableTopicIds.toList()..shuffle(rand);
      final featuredIds = selectedTopicIds.take(5).toList();

      // 2. 向 Supabase 查詢這 5 個專題的所有文章，依 topic_id 和 step_number 排序
      final idParams = featuredIds.map((id) => id.toString()).join(',');
      final url = Uri.parse(
          '$supabaseUrl/rest/v1/learning_articles?topic_id=in.($idParams)&order=topic_id.asc,step_number.asc');

      final response = await _client.get(url, headers: _headers);
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body) as List<dynamic>;
        final allArticles = list
            .map((item) => _mapJsonToArticle(item as Map<String, dynamic>))
            .toList();

        // 3. 依 topic_id 將文章分群成 5 個專題
        final Map<int, List<LearningMockArticle>> grouped = {};
        for (final article in allArticles) {
          final tId = article.topicId ?? 0;
          if (tId > 0) {
            grouped.putIfAbsent(tId, () => []).add(article);
          }
        }

        final List<LearningTopicData> topics = [];
        // 保留原有的 topic_id 順序，確保每次選出來的專題顯示順序一致
        for (final topicId in featuredIds) {
          final articles = grouped[topicId] ?? [];
          if (articles.isNotEmpty) {
            final category = articles.first.category ?? '法律情境';

            // 建立該專題的所有學習單元
            final List<LearningTopicUnit> units = [];
            for (final article in articles) {
              final stepNum = article.stepNumber ?? 1;
              units.add(LearningTopicUnit(
                stepLabel: 'STEP $stepNum',
                title: article.title,
                goal: article.summary,
                readTime: article.readTime,
                article: article,
              ));
            }

            topics.add(LearningTopicData(
              title: '$category實務防身術第 $topicId 號',
              summary: '從具體生活案例出發，帶你釐清關於 $category 的 $topicId 號核心法律權益。',
              reasonToLearn: '涉及 $category 的糾紛在日常生活中相當常見，提前做足知識防身能省去大部分的訴訟成本。',
              unitSummary: '${articles.length} 個學習單元',
              heroArticle: LearningMockArticle(
                badge: '主專題',
                title: '$category實務防身術第 $topicId 號：情境拆解與應對技巧',
                summary:
                    '本專案由 ${articles.length} 個單元組成，帶你循序漸進建立關於 $category 的精準判斷架構。',
                readTime: '${articles.length} 個學習單元',
                heroNote: '不要憑直覺解決爭議。先搞懂權利，再掌握證據，最後才談具體求償。',
                keyPoints: [
                  '了解 $category 的法律請求權基礎與核心規範。',
                  '透過具體案例學習實務中的折舊、修繕或賠償界線。',
                  '學會如何保存有效對話與單據作為法律證據。',
                ],
                sections: const [
                  LearningMockSection(
                    title: '這個專題在學什麼',
                    body: '它會帶你建立該法律情境的核心概念、剖析最容易犯的盲點，並提供實務談判與求償指南。',
                  ),
                  LearningMockSection(
                    title: '為什麼值得先學',
                    body: '預防勝於治療，懂點法律能在糾紛發生的當下保全最有利的證據，掌握主動權。',
                  ),
                ],
                heroImageUrl: articles.first.heroImageUrl,
              ),
              units: units,
              relatedTopics: const [],
              supportItems: const [],
              quizEntry: const LearningQuizEntryData(
                title: '專題測驗',
                subtitle: '用 1 題小測驗確認你能不能分辨此情境的法律責任。',
                actionLabel: '開始測驗',
              ),
            ));
          }
        }

        // 台灣繁體中文教學註解：成功查詢卻沒有完整專題時，照實回傳空清單。
        return topics;
      }
      throw HttpException('Supabase daily topics: HTTP ${response.statusCode}');
    } catch (e) {
      debugPrint('Supabase fetch daily topics failed: $e');
      rethrow;
    }
  }

  Future<List<int>> _fetchAvailableTopicIds() async {
    final ids = <int>{};
    const pageSize = 1000;
    var offset = 0;
    while (true) {
      final url = Uri.parse(
        '$supabaseUrl/rest/v1/learning_articles?select=topic_id&topic_id=not.is.null&order=topic_id.asc&limit=$pageSize&offset=$offset',
      );
      final response = await _client.get(url, headers: _headers);
      if (response.statusCode != 200) {
        throw HttpException('Supabase topic IDs: HTTP ${response.statusCode}');
      }
      final rows = jsonDecode(response.body) as List<dynamic>;
      for (final row in rows) {
        final id = (row as Map<String, dynamic>)['topic_id'];
        if (id is int) ids.add(id);
      }
      // 台灣繁體中文教學註解：PostgREST 單次最多回傳一頁，滿頁就繼續查，
      // 避免資料庫超過 1000 筆時漏掉後面的專題。
      if (rows.length < pageSize) break;
      offset += pageSize;
    }
    return ids.toList()..sort();
  }

  /// 本地降級備份：若沒有設定 Supabase，返回原有的 5 個本地寫死專題
  List<LearningTopicData> _getLocalFallbackFeaturedTopics() {
    return [
      featuredLearningTopics['租屋糾紛']!,
      featuredLearningTopics['車禍事故']!,
      featuredLearningTopics['職場權益']!,
      featuredLearningTopics['網購消費']!,
      featuredLearningTopics['個資隱私']!,
    ];
  }

  /// 根據專題標題向 Supabase 查詢整個專題資料
  Future<LearningTopicData?> fetchTopicByTitle(String title) async {
    final regExp = RegExp(r'^(.*?)實務防身術第 (\d+) 號$');
    final match = regExp.firstMatch(title);
    if (match == null) return null;

    final category = match.group(1);
    final topicIdStr = match.group(2);
    if (topicIdStr == null) return null;
    final topicId = int.tryParse(topicIdStr);
    if (topicId == null) return null;

    if (!isConfigured) return null;

    try {
      final url = Uri.parse(
          '$supabaseUrl/rest/v1/learning_articles?topic_id=eq.$topicId&order=step_number.asc');
      final response = await _client.get(url, headers: _headers);
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body) as List<dynamic>;
        final articles = list
            .map((item) => _mapJsonToArticle(item as Map<String, dynamic>))
            .toList();
        if (articles.isNotEmpty) {
          final List<LearningTopicUnit> units = [];
          for (final article in articles) {
            final stepNum = article.stepNumber ?? 1;
            units.add(LearningTopicUnit(
              stepLabel: 'STEP $stepNum',
              title: article.title,
              goal: article.summary,
              readTime: article.readTime,
              article: article,
            ));
          }

          return LearningTopicData(
            title: title,
            summary: '從具體生活案例出發，帶你釐清關於 $category 的 $topicId 號核心法律權益。',
            reasonToLearn: '涉及 $category 的糾紛在日常生活中相當常見，提前做足知識防身能省去大部分的訴訟成本。',
            unitSummary: '${articles.length} 個學習單元',
            heroArticle: LearningMockArticle(
              badge: '主專題',
              title: '$category實務防身術第 $topicId 號：情境拆解與應對技巧',
              summary:
                  '本專案由 ${articles.length} 個單元組成，帶你循序漸進建立關於 $category 的精準判斷架構。',
              readTime: '${articles.length} 個學習單元',
              heroNote: '不要憑直覺解決爭議。先搞懂權利，再掌握證據，最後才談具體求償。',
              keyPoints: [
                '了解 $category 的法律請求權基礎與核心規範。',
                '透過具體案例學習實務中的折舊、修繕或賠償界線。',
                '學會如何保存有效對話與單據作為法律證據。',
              ],
              sections: const [
                LearningMockSection(
                  title: '這個專題在學什麼',
                  body: '它會帶你建立該法律情境的核心概念、剖析最容易犯的盲點，並提供實務談判與求償指南。',
                ),
                LearningMockSection(
                  title: '為什麼值得先學',
                  body: '預防勝於治療，懂點法律能在糾紛發生的當下保全最有利的證據，掌握主動權。',
                ),
              ],
            ),
            units: units,
            relatedTopics: const [],
            supportItems: const [],
            quizEntry: const LearningQuizEntryData(
              title: '專題測驗',
              subtitle: '用 1 題小測驗確認你能不能分辨此情境的法律責任。',
              actionLabel: '開始測驗',
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Supabase fetch topic by title failed: $e');
    }
    return null;
  }

  /// 根據標題向 Supabase 查詢特定的文章
  Future<LearningMockArticle?> fetchArticleByTitle(String title) async {
    if (!isConfigured) return null;
    try {
      final url = Uri.parse(
          '$supabaseUrl/rest/v1/learning_articles?title=eq.${Uri.encodeComponent(title)}&limit=1');
      final response = await _client.get(url, headers: _headers);
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body) as List<dynamic>;
        if (list.isNotEmpty) {
          return _mapJsonToArticle(list.first as Map<String, dynamic>);
        }
      }
    } catch (e) {
      debugPrint('Supabase fetch article by title failed: $e');
    }
    return null;
  }

  List<LearningMockArticle> _getLocalFallbackArticles({
    String? category,
    String? query,
    int limit = 20,
    int offset = 0,
  }) {
    final allMockArticles = [
      learningTopic.heroArticle,
      ...learningTopic.units.map((u) => u.article),
      ...learningTopic.relatedTopics.map((r) => r.article),
      ...learningTopic.supportItems.map((s) => s.article),
    ];

    List<LearningMockArticle> filtered = allMockArticles;

    if (category != null && category != '全部') {
      filtered = filtered.where((a) {
        final cat = a.category ?? _guessCategory(a.title);
        return cat == category;
      }).toList();
    }

    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      filtered = filtered
          .where((a) =>
              a.title.toLowerCase().contains(q) ||
              a.summary.toLowerCase().contains(q))
          .toList();
    }

    if (offset >= filtered.length) return [];
    final end =
        (offset + limit) < filtered.length ? (offset + limit) : filtered.length;
    return filtered.sublist(offset, end);
  }

  String _guessCategory(String title) {
    if (title.contains('租屋') ||
        title.contains('押金') ||
        title.contains('房東') ||
        title.contains('房客')) {
      return '租屋糾紛';
    }
    if (title.contains('職場') ||
        title.contains('加班') ||
        title.contains('工時') ||
        title.contains('離職')) {
      return '職場權益';
    }
    if (title.contains('網購') ||
        title.contains('退貨') ||
        title.contains('消保') ||
        title.contains('消費')) {
      return '網購消費';
    }
    if (title.contains('肖像') ||
        title.contains('發文') ||
        title.contains('個資') ||
        title.contains('隱私')) {
      return '個資隱私';
    }
    if (title.contains('車禍') ||
        title.contains('事故') ||
        title.contains('碰撞') ||
        title.contains('交通')) {
      return '車禍事故';
    }
    return '法律常識';
  }
}
