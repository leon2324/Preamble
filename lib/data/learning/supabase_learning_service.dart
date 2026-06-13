import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:lawapp/config/supabase_config.dart';
import 'package:lawapp/data/mock_data/learning/learning_mock_data.dart';

/// 負責對接 Supabase 雲端資料庫抓取精選與日常法律情境專題的服務類別
class SupabaseLearningService {
  SupabaseLearningService._privateConstructor();
  static final SupabaseLearningService instance = SupabaseLearningService._privateConstructor();

  bool get isConfigured => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

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
      return _getLocalFallbackArticles(category: category, query: query, limit: limit, offset: offset);
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

      final url = Uri.parse('$supabaseUrl/rest/v1/learning_articles?${queryParams.join('&')}');
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body) as List<dynamic>;
        return list.map((item) => _mapJsonToArticle(item as Map<String, dynamic>)).toList();
      } else {
        debugPrint('Supabase fetch learning error: ${response.statusCode} ${response.body}');
        return _getLocalFallbackArticles(category: category, query: query, limit: limit, offset: offset);
      }
    } catch (e) {
      debugPrint('Supabase fetch learning failed: $e');
      return _getLocalFallbackArticles(category: category, query: query, limit: limit, offset: offset);
    }
  }

  LearningMockArticle _mapJsonToArticle(Map<String, dynamic> json) {
    final List<dynamic> sectionsJson = json['sections'] ?? [];
    final sections = sectionsJson.map((sec) => LearningMockSection(
      title: sec['title'] ?? '',
      body: sec['body'] ?? '',
    )).toList();

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
    );
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
      filtered = filtered.where((a) =>
          a.title.toLowerCase().contains(q) || a.summary.toLowerCase().contains(q)).toList();
    }

    if (offset >= filtered.length) return [];
    final end = (offset + limit) < filtered.length ? (offset + limit) : filtered.length;
    return filtered.sublist(offset, end);
  }

  String _guessCategory(String title) {
    if (title.contains('租屋') || title.contains('押金') || title.contains('房東') || title.contains('房客')) return '租屋糾紛';
    if (title.contains('職場') || title.contains('加班') || title.contains('工時') || title.contains('離職')) return '職場權益';
    if (title.contains('網購') || title.contains('退貨') || title.contains('消保') || title.contains('消費')) return '網購消費';
    if (title.contains('肖像') || title.contains('發文') || title.contains('個資') || title.contains('隱私')) return '個資隱私';
    if (title.contains('車禍') || title.contains('事故') || title.contains('碰撞') || title.contains('交通')) return '車禍事故';
    return '法律常識';
  }
}
