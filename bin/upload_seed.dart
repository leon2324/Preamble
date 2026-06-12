import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lawapp/config/supabase_config.dart';
import 'package:lawapp/features/case_time_machine/models/case_time_machine_models.dart';
import 'package:lawapp/features/case_time_machine/data/case_time_machine_mock_data.dart';

void main() async {
  print('========================================');
  print('🚀 開始將 15 案高品質真實案件種子資料上傳至 Supabase...');
  print('雲端 URL: $supabaseUrl');
  print('========================================');

  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    print('❌ 錯誤: 請先在 lib/config/supabase_config.dart 中填寫您的 Supabase 設定。');
    return;
  }

  final supabaseSecretKey = 'sb_secret_c2K2Ycrj1eaPibn_0N2ypw_LVYP3jnd';
  final headers = {
    'apikey': supabaseSecretKey,
    'Authorization': 'Bearer $supabaseSecretKey',
    'Content-Type': 'application/json',
    'Prefer': 'resolution=merge-duplicates', // 當 ID 重複時自動覆蓋/更新
  };

  int successCount = 0;
  int failCount = 0;

  for (final book in caseTimeMachineCasesSeed) {
    final payload = _caseBookToSupabaseJson(book);
    final url = Uri.parse('$supabaseUrl/rest/v1/cases');

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ 成功上傳案件 [${book.id}] - ${book.titleZh}');
        successCount++;
      } else {
        print('❌ 失敗上傳案件 [${book.id}] - ${book.titleZh}: ${response.statusCode} ${response.body}');
        failCount++;
      }
    } catch (e) {
      print('❌ 上傳例外錯誤 [${book.id}] - ${book.titleZh}: $e');
      failCount++;
    }
  }

  print('========================================');
  print('🎉 上傳完成！成功: $successCount 案，失敗: $failCount 案。');
  print('========================================');
}

Map<String, dynamic> _caseBookToSupabaseJson(CaseBook book) {
  return {
    'id': book.id,
    'titleZh': book.titleZh,
    'titleEn': book.titleEn,
    'shortTitleZh': book.shortTitleZh,
    'shortTitleEn': book.shortTitleEn,
    'displayCode': book.displayCode,
    'year': book.year,
    'location': book.location,
    'status': book.status,
    'category': book.category,
    'tags': book.tags, // 直接作為 JSON 陣列
    'memoryLine': book.memoryLine,
    'shortDescription': book.shortDescription,
    'oneSentenceSummary': book.oneSentenceSummary,
    'background': book.background,
    'fullStory': book.fullStory,
    'investigationAndTrial': book.investigationAndTrial,
    'courtReasoning': book.courtReasoning,
    'judgmentResult': book.judgmentResult,
    'socialImpact': book.socialImpact,
    'isFavorite': book.isFavorite,
    'isFollowing': book.isFollowing,
    'caseType': book.basicInfo.caseType,
    'procedureStage': book.basicInfo.procedureStage,
    'courtLevel': book.basicInfo.courtLevel,
    'updatedAt': book.basicInfo.updatedAt,
    'timeline': book.timeline.map((item) => {
      'dateLabel': item.dateLabel,
      'title': item.title,
      'description': item.description,
    }).toList(),
    'people': book.people.map((p) => {
      'role': p.role,
      'description': p.description,
    }).toList(),
    'legalIssues': book.legalIssues.map((issue) => {
      'title': issue.title,
      'plainExplanation': issue.plainExplanation,
      'relationToCase': issue.relationToCase,
      'relatedLawIds': issue.relatedLawIds,
    }).toList(),
    'relatedLaws': book.relatedLaws.map((law) => {
      'lawName': law.lawName,
      'articleNumber': law.articleNumber,
      'plainSummary': law.plainSummary,
      'relationToCase': law.relationToCase,
    }).toList(),
    'relatedCases': book.relatedCases.map((rc) => {
      'caseId': rc.caseId,
      'title': rc.title,
      'yearLabel': rc.yearLabel,
      'reason': rc.reason,
    }).toList(),
    'sources': book.sources.map((s) => {
      'title': s.title,
      'sourceType': s.sourceType,
      'updatedAt': s.updatedAt,
      'url': s.url,
    }).toList(),
    'concurringDissentingOpinions': book.concurringDissentingOpinions.map((o) => {
      'justiceName': o.justiceName,
      'opinionType': o.opinionType,
      'summary': o.summary,
    }).toList(),
    'courtArguments': book.courtArguments.map((a) => {
      'partyName': a.partyName,
      'mainPoint': a.mainPoint,
    }).toList(),
    'expertOpinions': book.expertOpinions.map((o) => {
      'expertName': o.expertName,
      'title': o.title,
      'summary': o.summary,
    }).toList(),
    'mediaReferences': book.mediaReferences.map((m) => {
      'title': m.title,
      'platform': m.platform,
      'url': m.url,
      'mediaType': m.mediaType,
    }).toList(),
    'images': book.images.map((img) => {
      'url': img.url,
      'source': img.source,
    }).toList(),
  };
}
