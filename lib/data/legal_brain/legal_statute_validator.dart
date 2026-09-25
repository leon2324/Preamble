import 'package:preamble/data/legal_brain/taiwan_statute_canon.dart';

/// 單筆法條驗證判定結果
class StatuteCitationValidationResult {
  const StatuteCitationValidationResult({
    required this.rawCitation,
    required this.lawName,
    required this.articleNumber,
    required this.isValid,
    required this.isKnownCanonStatute,
    required this.isOutOfRange,
    required this.reason,
    this.suggestedStatute,
  });

  final String rawCitation;
  final String lawName;
  final int articleNumber;
  final bool isValid;
  final bool isKnownCanonStatute;
  final bool isOutOfRange;
  final String reason;
  final TaiwanStatuteCanonEntry? suggestedStatute;

  Map<String, dynamic> toJson() => {
        'rawCitation': rawCitation,
        'lawName': lawName,
        'articleNumber': articleNumber,
        'isValid': isValid,
        'isKnownCanonStatute': isKnownCanonStatute,
        'isOutOfRange': isOutOfRange,
        'reason': reason,
        if (suggestedStatute != null)
          'suggestedStatute': suggestedStatute!.fullCitation,
      };
}

/// 全文法條防幻覺檢核報告
class StatuteValidationReport {
  const StatuteValidationReport({
    required this.isValid,
    required this.totalCitationsFound,
    required this.results,
    required this.hallucinatedCitations,
    required this.verifiedCitations,
    required this.warnings,
  });

  /// 是否全數合法無幻覺
  final bool isValid;

  /// 偵測到的引述法條總數
  final int totalCitationsFound;

  /// 各條目詳細審核清單
  final List<StatuteCitationValidationResult> results;

  /// 被抓包的虛構或溢位法條
  final List<StatuteCitationValidationResult> hallucinatedCitations;

  /// 經核實有效之法條
  final List<StatuteCitationValidationResult> verifiedCitations;

  /// 警示與修改建議清單
  final List<String> warnings;

  Map<String, dynamic> toJson() => {
        'isValid': isValid,
        'totalCitationsFound': totalCitationsFound,
        'results': results.map((r) => r.toJson()).toList(),
        'hallucinatedCitations':
            hallucinatedCitations.map((r) => r.toJson()).toList(),
        'verifiedCitations': verifiedCitations.map((r) => r.toJson()).toList(),
        'warnings': warnings,
      };
}

/// 臺灣法規防幻覺審計器 (Anti-Hallucination Guardrail)
///
/// 專門攔截並修正常見的 AI 法條幻覺（例如編造不存在的條號、混淆民刑法規、溢位條號）。
class LegalStatuteValidator {
  const LegalStatuteValidator._();

  /// 臺灣核心法規之最高有效條號上限表（超過即必屬 AI 幻覺虛構）
  static const Map<String, int> _statuteMaxArticleRange = {
    '民法': 1225, // 民法親屬繼承編止於 1225 條
    '勞動基準法': 86, // 勞基法止於 86 條
    '勞基法': 86,
    '消費者保護法': 64, // 消保法止於 64 條
    '消保法': 64,
    '租賃住宅市場發展及管理條例': 47, // 租賃條例止於 47 條
    '租賃條例': 47,
    '刑法': 363, // 刑法分則止於 363 條
    '中華民國刑法': 363,
    '民事訴訟法': 631, // 民訴止於 631 條
    '民訴': 631,
    '刑事訴訟法': 512,
    '刑訴': 512,
    '強制執行法': 142,
    '道路交通管理處罰條例': 93, // 處罰條例止於 93 條
    '道交條例': 93,
    '公寓大廈管理條例': 63,
    '勞工退休金條例': 58,
    '公司法': 449,
    '票據法': 144,
    '保險法': 178,
    '著作權法': 117,
    '商標法': 111,
    '專利法': 159,
    '營業秘密法': 15,
    '個人資料保護法': 56,
    '個資法': 56,
    '家庭暴力防治法': 66,
    '家暴法': 66,
    '家事事件法': 200,
    '醫療法': 123,
    '國家賠償法': 17,
    '國賠法': 17,
    '行政程序法': 175,
    '訴願法': 101,
    '行政訴訟法': 312,
    '洗錢防制法': 23,
    '涉外民事法律適用法': 63,
  };

  /// 掃描文字內容，進行嚴格的法條防幻覺審計
  static StatuteValidationReport validateText(String text) {
    if (text.isEmpty) {
      return const StatuteValidationReport(
        isValid: true,
        totalCitationsFound: 0,
        results: [],
        hallucinatedCitations: [],
        verifiedCitations: [],
        warnings: [],
      );
    }

    // 正則匹配法規引用，如：《民法》第184條、勞動基準法第14條、民法1840條
    final regex = RegExp(
      r'《?([^\s《》]+?(?:法|條例))》?\s*第?\s*(\d{1,5})\s*條?',
      caseSensitive: false,
    );

    final matches = regex.allMatches(text);
    final results = <StatuteCitationValidationResult>[];
    final hallucinations = <StatuteCitationValidationResult>[];
    final verified = <StatuteCitationValidationResult>[];
    final warnings = <String>[];

    for (final m in matches) {
      final raw = m.group(0) ?? '';
      final rawLaw = m.group(1) ?? '';
      final articleStr = m.group(2) ?? '';
      final articleNum = int.tryParse(articleStr) ?? 0;

      // 正規化法規簡稱
      final normalizedLaw = _normalizeLawName(rawLaw);

      // 1. 檢查是否在法定最大條號上限內
      final maxArticle = _statuteMaxArticleRange[normalizedLaw];
      var isOutOfRange = false;
      var isValid = true;
      String reason = '法條條號於法定有效編制範圍內。';
      TaiwanStatuteCanonEntry? suggestion;

      if (maxArticle != null) {
        if (articleNum <= 0 || articleNum > maxArticle) {
          isValid = false;
          isOutOfRange = true;
          reason = '《$normalizedLaw》現行法規全文僅有 $maxArticle 條，查無「第 $articleNum 條」，此條號確定為 AI 幻覺編造！';
          suggestion = _findProbableCorrectStatute(normalizedLaw, articleNum);
        }
      }

      // 2. 檢查是否為典籍庫收錄之高頻黃金條文
      final canonEntry = TaiwanStatuteCanon.findByCitation(
        normalizedLaw,
        '第 $articleNum 條',
      );

      final r = StatuteCitationValidationResult(
        rawCitation: raw,
        lawName: normalizedLaw,
        articleNumber: articleNum,
        isValid: isValid,
        isKnownCanonStatute: canonEntry != null,
        isOutOfRange: isOutOfRange,
        reason: reason,
        suggestedStatute: suggestion ?? canonEntry,
      );

      results.add(r);
      if (!isValid) {
        hallucinations.add(r);
        warnings.add('【抓獲法條幻覺】$raw ➔ $reason${suggestion != null ? " 建議校正為：${suggestion.fullCitation}" : ""}');
      } else {
        verified.add(r);
      }
    }

    return StatuteValidationReport(
      isValid: hallucinations.isEmpty,
      totalCitationsFound: results.length,
      results: results,
      hallucinatedCitations: hallucinations,
      verifiedCitations: verified,
      warnings: warnings,
    );
  }

  /// 自動校正文本中的法條幻覺
  static String sanitizeAndCorrectText(String text) {
    var sanitized = text;
    final report = validateText(text);

    for (final h in report.hallucinatedCitations) {
      if (h.suggestedStatute != null) {
        sanitized = sanitized.replaceAll(
          h.rawCitation,
          h.suggestedStatute!.fullCitation,
        );
      }
    }

    return sanitized;
  }

  static String _normalizeLawName(String name) {
    final clean = name.replaceAll('《', '').replaceAll('》', '').trim();
    if (clean == '民訴') return '民事訴訟法';
    if (clean == '刑訴') return '刑事訴訟法';
    if (clean == '勞基法') return '勞動基準法';
    if (clean == '消保法') return '消費者保護法';
    if (clean == '租賃條例') return '租賃住宅市場發展及管理條例';
    if (clean == '刑法') return '中華民國刑法';
    if (clean == '道交條例') return '道路交通管理處罰條例';
    if (clean == '個資法') return '個人資料保護法';
    if (clean == '家暴法') return '家庭暴力防治法';
    if (clean == '國賠法') return '國家賠償法';
    return clean;
  }

  static TaiwanStatuteCanonEntry? _findProbableCorrectStatute(
    String lawName,
    int hallucinatedNum,
  ) {
    // 常見筆誤或位數幻覺修正（例如把 184 誤擴增成 1840，修正回 184）
    if (lawName == '民法') {
      if (hallucinatedNum.toString().startsWith('184')) {
        return TaiwanStatuteCanon.findByStatuteId('civil_184_1');
      }
      if (hallucinatedNum.toString().startsWith('423') ||
          hallucinatedNum.toString().startsWith('430')) {
        return TaiwanStatuteCanon.findByStatuteId('civil_423');
      }
      if (hallucinatedNum.toString().startsWith('474') ||
          hallucinatedNum.toString().startsWith('478')) {
        return TaiwanStatuteCanon.findByStatuteId('civil_474');
      }
    } else if (lawName == '勞動基準法') {
      return TaiwanStatuteCanon.findByStatuteId('labor_14_1_5');
    }
    return null;
  }
}
