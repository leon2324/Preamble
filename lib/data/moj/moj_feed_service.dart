import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:lawapp/data/moj/moj_feed_item.dart';

/// 讀取法務部公開列表頁的服務。
///
/// 法務部有 RSS 說明頁，但實務上公開列表頁的資料更容易穩定取得標題與官方連結；
/// 這裡只抓首頁可見的清單項目，裁判書與全文檢索仍應交給後端同步處理。
class MojFeedService {
  MojFeedService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<MojFeedItem>> fetchItems(MojFeedCategory category) async {
    late final http.Response response;

    try {
      response =
          await _client.get(category.uri).timeout(const Duration(seconds: 10));
    } on TimeoutException {
      throw const MojFeedException('法務部資料讀取逾時，請稍後再試。');
    } on http.ClientException {
      throw const MojFeedException('暫時連不上法務部公開資料，請稍後再試。');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw MojFeedException('法務部資料讀取失敗：HTTP ${response.statusCode}');
    }

    final html = utf8.decode(response.bodyBytes);
    final items = _parseListItems(html, category);
    if (items.isEmpty) {
      throw const MojFeedException('暫時無法解析法務部公開清單。');
    }

    return items;
  }

  void dispose() {
    _client.close();
  }

  List<MojFeedItem> _parseListItems(String html, MojFeedCategory category) {
    final anchorPattern = RegExp(
      r'<a\b[^>]*href="([^"]+)"[^>]*>(.*?)</a>',
      caseSensitive: false,
      dotAll: true,
    );
    final numberPattern = RegExp(r'^(\d{1,2})\s+(.+)$');
    final seen = <String>{};
    final items = <MojFeedItem>[];

    for (final match in anchorPattern.allMatches(html)) {
      final href = match.group(1)?.trim() ?? '';
      final rawLabel = match.group(2) ?? '';
      final label = _normalizeHtmlText(rawLabel);
      final numbered = numberPattern.firstMatch(label);
      if (href.isEmpty || numbered == null) continue;

      final index = int.tryParse(numbered.group(1) ?? '');
      final title = (numbered.group(2) ?? '').trim();
      if (index == null || title.length < 6 || seen.contains(title)) continue;

      seen.add(title);
      items.add(
        MojFeedItem(
          title: title,
          url: category.uri.resolve(href).toString(),
          category: category,
          index: index,
        ),
      );
    }

    items.sort((a, b) => a.index.compareTo(b.index));
    return items.take(20).toList(growable: false);
  }

  String _normalizeHtmlText(String html) {
    final withoutTags = html.replaceAll(RegExp(r'<[^>]+>'), ' ');
    return withoutTags
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}

class MojFeedException implements Exception {
  const MojFeedException(this.message);

  final String message;

  @override
  String toString() => message;
}
