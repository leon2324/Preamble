import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:http/http.dart' as http;
import 'package:preamble/data/statutes/statute_item.dart';

/// 讀取全國法規資料庫中文法律資料的服務。
///
/// API 的欄位可能因版本或資料類型出現大小寫與命名差異，所以這裡用
/// 多組候選 key 做寬鬆解析，讓 UI 不需要知道來源 JSON 的細節。
class StatuteApiService {
  StatuteApiService({http.Client? client})
      : _client = client ?? http.Client(),
        _ownsClient = client == null;

  static final Uri chineseLawUri = Uri.parse(
    'https://law.moj.gov.tw/api/ch/law/json',
  );
  static final Uri chineseOrderUri = Uri.parse(
    'https://law.moj.gov.tw/api/ch/order/json',
  );

  final http.Client _client;
  // 台灣繁體中文教學註解：外部注入的 client 可供其他法規服務共用，只有自建時才關閉。
  final bool _ownsClient;

  Future<List<StatuteItem>> fetchChineseLawItems() async {
    // 使用者期待的是「台灣法規大全」，不只法律，也包含行政命令。
    // 因此第一版直接合併 MOJ 的 law 與 order 兩個官方 JSON 端點。
    final itemGroups = await Future.wait([
      _fetchItemsFromUri(chineseLawUri),
      _fetchItemsFromUri(chineseOrderUri),
    ]);

    final uniqueItems = <String, StatuteItem>{};
    for (final item in itemGroups.expand((items) => items)) {
      final key = '${item.codeName}-${item.articleNumber}-${item.articleText}';
      uniqueItems.putIfAbsent(key, () => item);
    }

    if (uniqueItems.isEmpty) {
      throw const StatuteApiException('法規資料格式暫時無法解析，請稍後再試。');
    }

    return uniqueItems.values.toList(growable: false);
  }

  Future<List<StatuteItem>> _fetchItemsFromUri(Uri uri) async {
    final response = await _client.get(uri);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StatuteApiException('法規資料讀取失敗：HTTP ${response.statusCode}');
    }

    final decoded = jsonDecode(_decodeBody(response.bodyBytes));
    final items = <StatuteItem>[];
    _collectItems(decoded, const _LawParseContext(), items);

    return items;
  }

  void dispose() {
    if (_ownsClient) _client.close();
  }

  String _decodeBody(List<int> bytes) {
    // 全國法規資料庫的 `/json` endpoint 實際回傳 ZIP 檔，
    // ZIP 內才放 ChLaw.json；這裡同時支援 ZIP 與純 JSON，
    // 讓日後若官方調整傳輸格式時 UI 不需要跟著改。
    final isZip = bytes.length >= 2 && bytes[0] == 0x50 && bytes[1] == 0x4B;
    if (!isZip) return _decodeUtf8(bytes);

    final archive = ZipDecoder().decodeBytes(bytes);
    final jsonFile = archive.files.firstWhere(
      (file) => file.isFile && file.name.toLowerCase().endsWith('.json'),
      orElse: () => throw const StatuteApiException('法規 ZIP 內找不到 JSON 資料。'),
    );

    // archive 4.x 會把檔案內容穩定提供為 bytes，統一交給 UTF-8 解碼，
    // 避免日後套件型別變嚴格時又出現不必要的型別判斷警告。
    return _decodeUtf8(jsonFile.content);
  }

  String _decodeUtf8(List<int> bytes) {
    final text = utf8.decode(bytes);
    return text.startsWith('\uFEFF') ? text.substring(1) : text;
  }

  void _collectItems(
    Object? node,
    _LawParseContext context,
    List<StatuteItem> output,
  ) {
    if (node is List) {
      for (final child in node) {
        _collectItems(child, context, output);
      }
      return;
    }

    if (node is! Map) return;

    final map = node.cast<Object?, Object?>();
    final nextContext = context.merge(
      codeName: _firstString(map, const [
        '法規名稱',
        '中文法規名稱',
        'LawName',
        'lawName',
        'Name',
        'name',
      ]),
      lawUrl: _firstString(map, const [
        '法規網址',
        'LawURL',
        'LawUrl',
        'lawUrl',
        'URL',
        'url',
      ]),
      category: _firstString(map, const [
        '法規類別',
        '法規體系',
        'LawCategory',
        'category',
      ]),
      updatedDate: _firstString(map, const [
        '最新異動日期',
        'UpdateDate',
        'LawModifiedDate',
        'updatedDate',
        'LatestUpdateDate',
      ]),
      repealNote: _firstString(map, const [
        '廢止註記',
        'AbolishNote',
        'LawAbandonNote',
        'abolishNote',
        'isRepealed',
      ]),
    );

    final articleText = _firstString(map, const [
      '條文內容',
      'ArticleContent',
      'articleContent',
      'Content',
      'content',
      'Text',
      'text',
    ]);
    final articleNumber = _firstString(map, const [
      '條號',
      'ArticleNo',
      'ArticleNumber',
      'articleNumber',
      'LawNo',
      'lawNo',
      'No',
      'no',
    ]);
    final articleType = _firstString(map, const [
      'ArticleType',
      'articleType',
      '條文型態',
    ]);

    final shouldCreateItem = articleText.isNotEmpty &&
        nextContext.codeName.isNotEmpty &&
        (articleType.isEmpty || articleType == 'A' || articleNumber.isNotEmpty);

    if (shouldCreateItem) {
      output.add(
        StatuteItem(
          codeName: nextContext.codeName,
          articleNumber: articleNumber,
          articleText: articleText,
          lawUrl: nextContext.lawUrl,
          category: nextContext.category,
          updatedDate: nextContext.updatedDate,
          isRepealed: nextContext.repealNote.contains('廢'),
          tags: [
            if (nextContext.category.isNotEmpty) nextContext.category,
            if (nextContext.codeName.isNotEmpty) nextContext.codeName,
          ],
        ),
      );
    }

    for (final value in map.values) {
      if (value is List || value is Map) {
        _collectItems(value, nextContext, output);
      }
    }
  }

  String _firstString(Map<Object?, Object?> map, List<String> keys) {
    for (final key in keys) {
      if (!map.containsKey(key)) continue;
      final value = map[key];
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }
    return '';
  }
}

class StatuteApiException implements Exception {
  const StatuteApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class _LawParseContext {
  const _LawParseContext({
    this.codeName = '',
    this.lawUrl = '',
    this.category = '',
    this.updatedDate = '',
    this.repealNote = '',
  });

  final String codeName;
  final String lawUrl;
  final String category;
  final String updatedDate;
  final String repealNote;

  _LawParseContext merge({
    required String codeName,
    required String lawUrl,
    required String category,
    required String updatedDate,
    required String repealNote,
  }) {
    return _LawParseContext(
      codeName: codeName.isEmpty ? this.codeName : codeName,
      lawUrl: lawUrl.isEmpty ? this.lawUrl : lawUrl,
      category: category.isEmpty ? this.category : category,
      updatedDate: updatedDate.isEmpty ? this.updatedDate : updatedDate,
      repealNote: repealNote.isEmpty ? this.repealNote : repealNote,
    );
  }
}
