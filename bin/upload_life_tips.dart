import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:preamble/config/supabase_config.dart';
import 'package:preamble/data/mock_data/home/legacy/home_mock_data_legacy.dart';

void main() async {
  print('========================================');
  print('🚀 開始將 500 則高品質生活避坑筆記上傳至 Supabase...');
  print('雲端 URL: $supabaseUrl');
  print('========================================');

  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    print('❌ 錯誤: 請先在 lib/config/supabase_config.dart 中填寫您的 Supabase 設定。');
    return;
  }

  // 使用 service_role secret key 繞過 RLS 安全檢查以寫入資料
  final supabaseSecretKey = 'sb_secret_c2K2Ycrj1eaPibn_0N2ypw_LVYP3jnd';
  final headers = {
    'apikey': supabaseSecretKey,
    'Authorization': 'Bearer $supabaseSecretKey',
    'Content-Type': 'application/json',
    'Prefer': 'resolution=merge-duplicates', // 重複時覆蓋/合併
  };

  final List<Map<String, dynamic>> payloads = [];
  var index = 1;
  for (final item in homeNewsletterItems) {
    payloads.add({
      'id': index, // 使用固定整數 ID 支援快訊 Banner 精確跳轉定位
      'title': item.title,
      'summary': item.summary,
      'tip': item.tip,
      'likes': item.likes,
      'shares': item.shares,
      'comments': item.comments,
      'downloads': item.downloads,
      'category': item.category,
    });
    index++;
  }

  final url = Uri.parse('$supabaseUrl/rest/v1/life_legal_tips');

  // 每批 100 筆分段上傳
  final int batchSize = 100;
  int successCount = 0;
  int failCount = 0;

  for (int i = 0; i < payloads.length; i += batchSize) {
    final end =
        (i + batchSize < payloads.length) ? i + batchSize : payloads.length;
    final batch = payloads.sublist(i, end);
    final batchNum = (i ~/ batchSize) + 1;
    final totalBatches = (payloads.length + batchSize - 1) ~/ batchSize;

    print('⏳ 正在上傳第 $batchNum/$totalBatches 批 ($i ~ ${end - 1})...');

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(batch),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ 成功上傳第 $batchNum 批');
        successCount += batch.length;
      } else {
        print('❌ 失敗上傳第 $batchNum 批: ${response.statusCode} ${response.body}');
        failCount += batch.length;
      }
    } catch (e) {
      print('❌ 上傳例外錯誤: $e');
      failCount += batch.length;
    }
  }

  print('========================================');
  print('🎉 上傳完成！成功: $successCount 則，失敗: $failCount 則。');
  print('========================================');
}
