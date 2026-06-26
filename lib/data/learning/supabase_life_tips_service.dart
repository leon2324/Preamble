import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:lawapp/config/supabase_config.dart';
import 'package:lawapp/components/home/home_content.dart';
import 'package:lawapp/data/mock_data/home/legacy/home_mock_data_legacy.dart';

/// 負責對接 Supabase 雲端資料庫抓取「生活避坑筆記」的服務類別。
class SupabaseLifeTipsService {
  SupabaseLifeTipsService._privateConstructor();
  static final SupabaseLifeTipsService instance =
      SupabaseLifeTipsService._privateConstructor();

  bool get isConfigured {
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

  /// 依據分類與搜尋關鍵字，向 Supabase 進行生活避坑筆記查詢。
  Future<List<HomeNewsletterItem>> fetchLifeTips({
    String? category,
    String? query,
    int limit = 500,
    int offset = 0,
  }) async {
    if (!isConfigured) {
      return _getLocalFallbackTips(
          category: category, query: query, limit: limit, offset: offset);
    }

    try {
      final queryParams = <String>[
        'select=*',
        'limit=$limit',
        'offset=$offset',
        'order=id.asc',
      ];

      if (category != null && category != '全部') {
        queryParams.add('category=eq.${Uri.encodeComponent(category)}');
      }

      if (query != null && query.trim().isNotEmpty) {
        final trimmed = query.trim();
        final escapedQuery = '%$trimmed%';
        queryParams.add(
            'or=(title.ilike.${Uri.encodeComponent(escapedQuery)},summary.ilike.${Uri.encodeComponent(escapedQuery)},tip.ilike.${Uri.encodeComponent(escapedQuery)})');
      }

      final url = Uri.parse(
          '$supabaseUrl/rest/v1/life_legal_tips?${queryParams.join('&')}');
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body) as List<dynamic>;
        return list
            .map((item) => _mapJsonToTip(item as Map<String, dynamic>))
            .toList();
      } else {
        debugPrint(
            'Supabase fetch life tips error: ${response.statusCode} ${response.body}');
        return _getLocalFallbackTips(
            category: category, query: query, limit: limit, offset: offset);
      }
    } catch (e) {
      debugPrint('Supabase fetch life tips failed: $e');
      return _getLocalFallbackTips(
          category: category, query: query, limit: limit, offset: offset);
    }
  }

  HomeNewsletterItem _mapJsonToTip(Map<String, dynamic> json) {
    return HomeNewsletterItem(
      title: json['title'] ?? '',
      summary: json['summary'] ?? '',
      tip: json['tip'] ?? '',
      likes: json['likes'] ?? '0+',
      shares: json['shares'] ?? '0+',
      comments: json['comments'] ?? '0+',
      downloads: json['downloads'] ?? '0+',
      category: json['category'] ?? '生活',
    );
  }

  List<HomeNewsletterItem> _getLocalFallbackTips({
    String? category,
    String? query,
    int limit = 500,
    int offset = 0,
  }) {
    List<HomeNewsletterItem> filtered = homeNewsletterItems;

    if (category != null && category != '全部') {
      filtered = filtered.where((item) => item.category == category).toList();
    }

    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      filtered = filtered
          .where((item) =>
              item.title.toLowerCase().contains(q) ||
              item.summary.toLowerCase().contains(q) ||
              item.tip.toLowerCase().contains(q))
          .toList();
    }

    if (offset >= filtered.length) return [];
    final end =
        (offset + limit) < filtered.length ? (offset + limit) : filtered.length;
    return filtered.sublist(offset, end);
  }
}
