import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

typedef StatuteSpotlightQueryHandler = void Function(String query);

/// iOS Core Spotlight 法規資料庫橋接層。
///
/// Flutter 負責整理「哪些法條值得被系統搜尋」，iOS 原生端負責把資料寫進
/// Core Spotlight。這樣法規資料庫可以出現在 iPhone 搜尋結果中，又不需要
/// 讓 Spotlight 直接理解 Flutter 頁面或 Dart model。
class IosStatuteSpotlightBridge {
  const IosStatuteSpotlightBridge._();

  static const _channel = MethodChannel('lawapp/statute_spotlight');

  static bool get _isSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  static Future<void> syncDefaultIndex() async {
    if (!_isSupported) return;

    try {
      await _channel.invokeMethod<void>(
        'indexStatuteSpotlightItems',
        <String, Object>{'items': _defaultSpotlightItems},
      );
    } on MissingPluginException {
      // 測試環境或 Android 不會註冊 iOS Spotlight channel；這是加分入口，
      // 失敗時不應影響主 App 啟動。
    } on PlatformException {
      // Core Spotlight 可能因模擬器狀態、權限或系統索引服務暫時失敗；
      // 保持靜默，讓使用者仍能正常使用法規資料庫頁。
    }
  }

  static void registerQueryHandler(StatuteSpotlightQueryHandler onQuery) {
    if (!_isSupported) return;

    _channel.setMethodCallHandler((call) async {
      if (call.method != 'openStatuteDatabase') return null;

      final query = _queryFrom(call.arguments);
      if (query == null) return null;
      onQuery(query);
      return null;
    });
  }

  static Future<String?> consumeInitialQuery() async {
    if (!_isSupported) return null;

    try {
      final result = await _channel.invokeMethod<Object?>(
        'consumeInitialStatuteQuery',
      );
      return _queryFrom(result);
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  static void unregisterQueryHandler() {
    if (!_isSupported) return;
    _channel.setMethodCallHandler(null);
  }

  static String? _queryFrom(Object? value) {
    if (value is String) {
      final query = value.trim();
      return query.isEmpty ? null : query;
    }

    if (value is Map) {
      final rawQuery = value['query'];
      if (rawQuery is! String) return null;
      final query = rawQuery.trim();
      return query.isEmpty ? null : query;
    }

    return null;
  }
}

List<Map<String, Object>> get _defaultSpotlightItems {
  return _defaultSpotlightSeeds.map((item) {
    final query = item['query'] as String;
    return <String, Object>{
      ...item,
      'id': 'lawapp.statute.${Uri.encodeComponent(query)}',
    };
  }).toList(growable: false);
}

const _defaultSpotlightSeeds = [
  {
    'title': '民法第 184 條',
    'query': '民法 184',
    'summary': '侵權行為損害賠償責任。車禍、傷害、隱私侵害等民事求償常會用到。',
    'keywords': ['民法', '184', '侵權行為', '損害賠償', '車禍', '精神慰撫金'],
  },
  {
    'title': '民法第 421 條',
    'query': '民法 421 租賃',
    'summary': '租賃契約的基本定義。租屋、押金、退租與修繕爭議可從這裡切入。',
    'keywords': ['民法', '421', '租賃', '租屋', '押金', '退租', '房東'],
  },
  {
    'title': '民法租賃押金相關條文',
    'query': '租屋 押金 退租',
    'summary': '快速回到法規資料庫查租屋押金、修繕、退租與回復原狀相關規範。',
    'keywords': ['租屋', '押金', '退租', '回復原狀', '修繕'],
  },
  {
    'title': '勞動基準法第 24 條',
    'query': '勞動基準法 24 加班費',
    'summary': '延長工時與加班費計算基礎。加班、補休、薪資爭議可先查這條。',
    'keywords': ['勞基法', '勞動基準法', '24', '加班費', '工時', '補休'],
  },
  {
    'title': '消費者保護法第 19 條',
    'query': '消費者保護法 19 七日鑑賞期',
    'summary': '通訊交易或訪問交易的七日解除權。網購退貨與消費爭議常用。',
    'keywords': ['消保法', '消費者保護法', '19', '七日鑑賞期', '網購', '退貨'],
  },
  {
    'title': '中華民國刑法第 339 條',
    'query': '刑法 339 詐欺',
    'summary': '普通詐欺罪。詐騙、騙錢、網路交易糾紛可用來判斷刑事風險。',
    'keywords': ['刑法', '339', '詐欺', '詐騙', '騙錢', '財產犯罪'],
  },
];
