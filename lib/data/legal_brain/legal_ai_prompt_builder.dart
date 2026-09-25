import 'package:preamble/data/legal_brain/taiwan_statute_canon.dart';

/// 專業臺灣法律 AI 提示詞工程與結構化輸出建構器
class LegalAiPromptBuilder {
  const LegalAiPromptBuilder._();

  /// 臺灣執業律師級核心 System Prompt
  static String buildSystemPrompt() {
    return '''
你是由臺灣資深執業律師與法學專家團隊指導打造的「緒言 Preamble 法律智囊大腦」。
你的職責是協助遭遇生活法律糾紛的民眾，將口語化、混亂情緒的案件事實，梳理為嚴謹、客觀且具備法庭攻防力度的法律論述與正式公文書狀。

【核心執業準則與法學方法】
1. 嚴格遵循「法學三段論法」：
   - 大前提：精準援引中華民國現行有效法律（如民法、勞基法、租賃專法、消保法、刑法、民事訴訟法）之構成要件與消滅時效。
   - 小前提：將當事人陳述之具體人事物事實，逐一涵攝進法條構成要件中，指明哪些已滿足、哪些尚需補強佐證。
   - 結論：推導出具備實體法基礎之法律效果（如損害賠償、物上請求、返還押金、給付資遣費、終止契約）。

2. 零幻覺（Zero Hallucination）鐵律：
   - 嚴禁捏造不存在的法條條號（例如：民法條號最高僅至 1225 條，絕無 1840 條）。
   - 嚴禁混淆民事債權與刑事責任（例如：單純借貸欠款不還未涉及詐術者，不得輕率建構刑事詐欺，應引導督促程序支付命令）。
   - 若事實資訊不足以確立要件，應明確指出「待補強佐證」而非擅自腦補。

3. 實務公文格式標準：
   - 存證信函：符合中華郵政存證信函格式（具備主旨、事實理由段、定相當履行期限通常為 7 或 15 日、逾期追究法律責任警告、立書人簽章）。
   - 和解協議書：具備賠償金額、給付方式、拋棄其餘請求權之斷尾條款（免生後患）、違約金及撤告條款。
   - 支付命令聲請狀：符合民事訴訟法第 508 條及第 511 條規定。

4. 臺灣《律師法》第 127 條合規聲明：
   - 本系統定位為「法律資訊梳理、格式校對與事前協商之輔助工具」，產出內容供當事人瞭解自身權益；涉及重大個案訴訟與出庭代理，應提醒當事人諮詢或轉介中華民國合法登錄之執業律師。
'''.trim();
  }

  /// 結合 RAG 檢索法規之案件深度診斷 Prompt
  static String buildCaseAnalysisPrompt({
    required String rawFacts,
    List<TaiwanStatuteCanonEntry>? retrievedStatutes,
  }) {
    final statutes = retrievedStatutes ??
        TaiwanStatuteCanon.findBestMatchingStatutes(rawFacts, limit: 3);

    final buffer = StringBuffer();
    buffer.writeln('請根據下列當事人陳述事實，結合已檢索之臺灣現行法律依據，執行完整的法學案件診斷：');
    buffer.writeln();
    buffer.writeln('【當事人案件口語陳述】');
    buffer.writeln(rawFacts);
    buffer.writeln();

    buffer.writeln('【知識庫檢索匹配之權威法律規範（RAG 上下文）】');
    for (final s in statutes) {
      buffer.writeln('• ${s.fullCitation}：');
      buffer.writeln('  條文內容：${s.officialText}');
      buffer.writeln('  構成要件：${s.constituentElements.join("、")}');
      buffer.writeln('  法律效果：${s.legalEffects.join("、")}');
      buffer.writeln('  時效說明：${s.limitationPeriodDescription}');
      buffer.writeln('  舉證指南：${s.defenseAndEvidenceGuide.join("；")}');
      buffer.writeln();
    }

    buffer.writeln('【輸出要求】');
    buffer.writeln('請以繁體中文（台灣標準法律用語）輸出包含下列欄位的結構化分析：');
    buffer.writeln('1. disputeCategory：案件核心領域');
    buffer.writeln('2. identifiedIssues：關鍵法律爭點（條列）');
    buffer.writeln('3. subsumptionAnalysis：小前提事實涵攝（檢視構成要件滿足狀況與欠缺要素）');
    buffer.writeln('4. conclusionRemedies：法律救濟結論與請求主張');
    buffer.writeln('5. demands：具體履行催告清單（含建議寬限期日數）');
    buffer.writeln('6. evidenceChecklist：當事人立即應蒐集之舉證清單');
    buffer.writeln('7. escalationPath：逾期不獲理會之司法救濟步驟（如調解、支付命令、訴訟）');

    return buffer.toString().trim();
  }

  /// 標準公文 JSON 結構化輸出規範（供 OpenAI Function Calling / Claude Tool Use / Gemini Structured Output）
  static Map<String, dynamic> get dynamicDocumentJsonSchema => {
        'type': 'object',
        'properties': {
          'title': {
            'type': 'string',
            'description': '公文書狀名稱，例如：存證信函、民事支付命令聲請狀、民事和解協議書',
          },
          'subtitle': {
            'type': 'string',
            'description': '副標題或案由摘要',
          },
          'senderName': {
            'type': 'string',
            'description': '發函人（聲請人/甲方）完整姓名或法人名稱',
          },
          'receiverName': {
            'type': 'string',
            'description': '相對人（債務人/乙方）完整姓名或法人名稱',
          },
          'sections': {
            'type': 'array',
            'items': {
              'type': 'object',
              'properties': {
                'heading': {'type': 'string', 'description': '段落標題'},
                'body': {'type': 'string', 'description': '段落內文'},
                'subPoints': {
                  'type': 'array',
                  'items': {'type': 'string'},
                  'description': '子項目清單',
                },
              },
              'required': ['heading', 'body'],
            },
          },
          'demands': {
            'type': 'array',
            'items': {'type': 'string'},
            'description': '具體要求相對人履行之請求事項',
          },
          'evidences': {
            'type': 'array',
            'items': {'type': 'string'},
            'description': '隨函檢附之附件或佐證清單',
          },
          'legalBasis': {
            'type': 'array',
            'items': {'type': 'string'},
            'description': '所援引之精確臺灣法規條號',
          },
          'warningClause': {
            'type': 'string',
            'description': '逾期追究法律責任與保留訴追權之警告文句',
          },
          'deadlineDays': {
            'type': 'integer',
            'description': '催告履行限期（通常為 7、15 或 30 日）',
          },
        },
        'required': [
          'title',
          'senderName',
          'receiverName',
          'sections',
          'demands',
          'legalBasis',
          'warningClause',
          'deadlineDays',
        ],
      };
}
