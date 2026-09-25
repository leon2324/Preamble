import 'package:flutter_test/flutter_test.dart';
import 'package:preamble/data/documents/dynamic_legal_drafter_brain.dart';
import 'package:preamble/data/law_assistant/law_assistant_models.dart';
import 'package:preamble/data/law_assistant/law_assistant_repository.dart';
import 'package:preamble/data/legal_brain/legal_ai_prompt_builder.dart';
import 'package:preamble/data/legal_brain/legal_statute_validator.dart';
import 'package:preamble/data/legal_brain/legal_syllogism_engine.dart';
import 'package:preamble/data/legal_brain/structured_legal_document_schemas.dart';
import 'package:preamble/data/legal_brain/taiwan_statute_canon.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 19: Taiwan Legal AI Brain & Syllogism Engine Tests', () {
    // -------------------------------------------------------------
    // 1. TaiwanStatuteCanon 典籍庫檢索測試
    // -------------------------------------------------------------
    test('TaiwanStatuteCanon retrieves correct statutes by ID and citation', () {
      final rentalStatute = TaiwanStatuteCanon.findByStatuteId('rental_act_34');
      expect(rentalStatute, isNotNull);
      expect(rentalStatute!.lawName, contains('租賃住宅市場發展及管理條例'));
      expect(rentalStatute.articleNumber, '第 34 條');
      expect(rentalStatute.limitationPeriodYears, 15.0);
      expect(rentalStatute.constituentElements, isNotEmpty);
      expect(rentalStatute.defenseAndEvidenceGuide, isNotEmpty);

      final tortStatute =
          TaiwanStatuteCanon.findByStatuteId('civil_184_1');
      expect(tortStatute, isNotNull);
      expect(tortStatute!.lawName, contains('民法'));
      expect(tortStatute.limitationPeriodYears, 2.0);

      final laborStatute =
          TaiwanStatuteCanon.findByCitation('勞動基準法', '第 14 條');
      expect(laborStatute, isNotNull);
      expect(laborStatute!.statuteId, anyOf('labor_14', 'labor_14_1_5'));
    });

    test('TaiwanStatuteCanon findBestMatchingStatutes correctly matches diverse facts', () {
      // 租賃事實
      final rentalMatches = TaiwanStatuteCanon.findBestMatchingStatutes(
        '租約期滿房東以油漆泛黃扣留押金兩萬元不肯退還',
      );
      expect(rentalMatches, isNotEmpty);
      expect(
        rentalMatches.any((s) => s.statuteId == 'rental_act_34' || s.statuteId == 'civil_423'),
        isTrue,
      );

      // 車禍事實
      final trafficMatches = TaiwanStatuteCanon.findBestMatchingStatutes(
        '停等紅燈遭後方車輛追撞致機車受損與右膝擦挫傷',
      );
      expect(trafficMatches, isNotEmpty);
      expect(trafficMatches.any((s) => s.statuteId == 'civil_184_1'), isTrue);

      // 欠款事實
      final loanMatches = TaiwanStatuteCanon.findBestMatchingStatutes(
        '借朋友三十萬元有匯款單借據但無約定明確還款期限',
      );
      expect(loanMatches, isNotEmpty);
      expect(loanMatches.any((s) => s.statuteId == 'civil_474' || s.statuteId == 'civil_478'), isTrue);

      // 勞資欠薪
      final laborMatches = TaiwanStatuteCanon.findBestMatchingStatutes(
        '公司連續兩個月欠發工資且平日延長工時均未給付加班費',
      );
      expect(laborMatches, isNotEmpty);
      expect(laborMatches.any((s) => s.statuteId == 'labor_14' || s.statuteId == 'labor_24' || s.statuteId == 'labor_14_1_5'), isTrue);
    });

    // -------------------------------------------------------------
    // 2. LegalSyllogismEngine 法學三段論推導測試
    // -------------------------------------------------------------
    test('LegalSyllogismEngine executes complete syllogism on rental deposit dispute', () {
      final analysis = LegalSyllogismEngine.analyze(
        rawFacts: '租期屆滿退租點交後，房東藉故房屋自然泛黃扣留兩個月押金兩萬四千元。',
        customClaimant: '陳小美',
        customOpponent: '林大房東',
      );

      expect(analysis.claimantName, '陳小美');
      expect(analysis.opponentName, '林大房東');
      expect(analysis.disputeCategory, contains('租賃'));
      expect(analysis.identifiedIssues, isNotEmpty);
      expect(analysis.majorPremiseStatutes, isNotEmpty);
      expect(analysis.subsumptionFindings.length, greaterThanOrEqualTo(2));
      expect(analysis.demands, isNotEmpty);
      expect(analysis.recommendedDeadlineDays, 7);
      expect(analysis.evidenceChecklist.any((e) => e.contains('租賃契約')), isTrue);
      expect(analysis.escalationPath.any((p) => p.contains('支付命令') || p.contains('存證信函')), isTrue);

      final report = analysis.toDetailedReport();
      expect(report, contains('三段論法'));
      expect(report, contains('大前提'));
      expect(report, contains('小前提'));
      expect(report, contains('裁判結論'));
      expect(report, contains('訴求主張'));
    });

    test('LegalSyllogismEngine executes syllogism on traffic collision accident', () {
      final analysis = LegalSyllogismEngine.analyze(
        rawFacts: '在基隆路停等紅燈被後方小客車追撞，初判表載明對方未注意車前狀況，要求修車費八萬元與醫療損失。',
      );

      expect(analysis.disputeCategory, anyOf(contains('交通'), contains('侵權')));
      expect(analysis.majorPremiseStatutes.any((s) => s.statuteId == 'civil_184_1'), isTrue);
      expect(analysis.demands.any((d) => d.contains('車輛受損') || d.contains('醫療')), isTrue);
      expect(analysis.evidenceChecklist.any((e) => e.contains('初判表')), isTrue);
      expect(analysis.recommendedDeadlineDays, anyOf(7, 10));
    });

    test('LegalSyllogismEngine executes syllogism on loan default with Art. 478 30-day notice', () {
      final analysis = LegalSyllogismEngine.analyze(
        rawFacts: '借給前同事二十萬元，有銀行跨行轉帳水單，雙方未約定確切清償期限。',
      );

      expect(analysis.disputeCategory, anyOf(contains('借貸'), contains('清償')));
      expect(analysis.recommendedDeadlineDays, 30); // 民法第 478 條法定一個月催告期
      expect(analysis.majorPremiseStatutes.any((s) => s.statuteId == 'civil_478'), isTrue);
    });


    // -------------------------------------------------------------
    // 3. StructuredLegalDocumentSchemas 結構化公文測試
    // -------------------------------------------------------------
    test('AttestedDemandLetter generates post office 20x20 grid formatted text', () {
      const letter = AttestedDemandLetter(
        senderName: '王大明',
        senderAddress: '台北市大安區新生南路一段100號',
        receiverName: '李小華',
        receiverAddress: '台北市中山區南京東路二段200號',
        subject: '為返還借貸款項事，限期清償，請查照。',
        factsAndReasons: [
          '緣相對人於民國114年1月向發函人借款新台幣十萬元整。',
          '經多次催告迄未清償，特此催告限期履行。',
        ],
        demands: ['請於文到後 7 日內將借款本金匯入指定帳戶。'],
        legalBasis: ['《民法》第 474 條', '《民法》第 478 條'],
        deadlineDays: 7,
      );

      final formalText = letter.toFormalText();
      expect(formalText, contains('【郵局存證信函】'));
      expect(formalText, contains('寄件人：王大明'));
      expect(formalText, contains('收件人：李小華'));
      expect(formalText, contains('【主旨】'));

      final gridText = letter.toPostOfficeGridText();
      expect(gridText, contains('=== 中華郵政存證信函 第 1 頁（每頁 20 行，每行 20 字）==='));
      expect(gridText, contains('[第01行]'));

      // 驗證轉為動態公文相容性
      final dynamicDoc = letter.toDynamicLegalDocument();
      expect(dynamicDoc.title, contains('存證信函'));
      expect(dynamicDoc.senderName, '王大明');
      expect(dynamicDoc.sections.length, 3); // 主旨 + 2段事實理由
    });

    test('SettlementAgreement generates comprehensive mutual release contract', () {
      const agreement = SettlementAgreement(
        title: '車禍損害賠償和解協議書',
        partyA: SettlementParty(
          name: '張三（甲方）',
          idNumber: 'A123456789',
          address: '台北市信義區信義路五段7號',
          phone: '0912345678',
        ),
        partyB: SettlementParty(
          name: '李四（乙方）',
          idNumber: 'B987654321',
          address: '新北市板橋區縣民大道二段1號',
          phone: '0987654321',
        ),
        incidentBackground: '雙方於民國115年5月1日在台北市忠孝東路發生車輛擦撞事故致生損害。',
        settlementAmount: 35000,
        paymentTerms: '乙方於簽署本協議書時以現金一次交付完畢。',
      );

      final formalText = agreement.toFormalText();
      expect(formalText, contains('車禍損害賠償和解協議書'));
      expect(formalText, contains('新台幣 35000 元整'));
      expect(formalText, anyOf(contains('斷尾條款'), contains('拋棄請求權與撤回告訴')));
      expect(formalText, contains('立書人甲方（簽名蓋章）'));


      final dynamicDoc = agreement.toDynamicLegalDocument();
      expect(dynamicDoc.title, contains('車禍'));
      expect(dynamicDoc.demands, isNotEmpty);
    });

    test('PaymentOrderPetition generates court-compliant summary order petition', () {
      const petition = PaymentOrderPetition(
        courtName: '臺灣臺北地方法院民事庭',
        petitionerName: '陳大明',
        petitionerId: 'C123456789',
        petitionerAddress: '台北市中正區重慶南路一段',
        respondentName: '林阿財',
        respondentId: 'D987654321',
        respondentAddress: '台北市大安區忠孝東路四段',
        claimAmount: 150000,
        interestStartDateDescription: '支付命令送達翌日',
        causeAndFacts: '相對人向聲請人借款十五萬元，屆期未清償。',
        evidenceList: ['借據原本', '匯款申請書回條'],
      );

      final formalText = petition.toFormalText();
      expect(formalText, contains('民事支付命令聲請狀'));
      expect(formalText, contains('臺灣臺北地方法院民事庭'));
      expect(formalText, contains('新台幣 150000 元整'));
      expect(formalText, contains('週年利率百分之 5.0 計算之利息'));
      expect(formalText, contains('督促程序費用由相對人負擔'));
      expect(formalText, contains('附繳證物'));
    });

    // -------------------------------------------------------------
    // 4. LegalStatuteValidator 防法條幻覺審計測試
    // -------------------------------------------------------------
    test('LegalStatuteValidator approves authentic Taiwan statutes', () {
      const genuineText = '依《民法》第 184 條第 1 項前段及《民法》第 193 條規定，請求損害賠償；並依《勞動基準法》第 14 條終止勞動契約。';
      final report = LegalStatuteValidator.validateText(genuineText);

      expect(report.isValid, isTrue);
      expect(report.totalCitationsFound, 3);
      expect(report.hallucinatedCitations, isEmpty);
      expect(report.verifiedCitations.length, 3);
    });

    test('LegalStatuteValidator catches and flags out-of-range hallucinated statutes', () {
      // 民法最高僅 1225 條，1840 條必屬幻覺；勞基法最高 86 條，888 條必屬幻覺
      const hallucinatedText = '依《民法》第 1840 條及《勞動基準法》第 888 條規定，請求全額賠償。';
      final report = LegalStatuteValidator.validateText(hallucinatedText);

      expect(report.isValid, isFalse);
      expect(report.totalCitationsFound, 2);
      expect(report.hallucinatedCitations.length, 2);
      expect(report.hallucinatedCitations.first.isOutOfRange, isTrue);
      expect(report.warnings.first, contains('抓獲法條幻覺'));
      expect(report.warnings.first, contains('第 184 條')); // 建議校正為民法第184條

      final corrected = LegalStatuteValidator.sanitizeAndCorrectText(hallucinatedText);
      expect(corrected, contains('《民法》 第 184 條'));
    });

    // -------------------------------------------------------------
    // 5. LegalAiPromptBuilder 提示詞建構測試
    // -------------------------------------------------------------
    test('LegalAiPromptBuilder creates compliant system prompt and schema', () {
      final systemPrompt = LegalAiPromptBuilder.buildSystemPrompt();
      expect(systemPrompt, contains('法學三段論法'));
      expect(systemPrompt, contains('零幻覺'));
      expect(systemPrompt, contains('律師法'));
      expect(systemPrompt, contains('127'));


      final casePrompt = LegalAiPromptBuilder.buildCaseAnalysisPrompt(
        rawFacts: '租屋處押金被房東扣款不退',
      );
      expect(casePrompt, contains('RAG 上下文'));
      expect(casePrompt, contains('租賃住宅市場發展及管理條例'));

      final schema = LegalAiPromptBuilder.dynamicDocumentJsonSchema;
      expect(schema['type'], 'object');
      expect((schema['required'] as List).contains('title'), isTrue);
      expect((schema['required'] as List).contains('legalBasis'), isTrue);
    });

    // -------------------------------------------------------------
    // 6. DynamicLegalDrafterBrain 端到端整合測試
    // -------------------------------------------------------------
    test('DynamicLegalDrafterBrain creates validated documents and specialized formats', () {
      final doc = DynamicLegalDrafterBrain.generateFromFactDescription(
        rawFacts: '房客租期屆滿退租，房東藉口牆壁泛黃扣留押金兩萬元。',
      );
      expect(doc.title, anyOf(contains('租賃'), contains('押金')));
      expect(doc.legalBasis, isNotEmpty);

      // 生成郵局存證信函
      final letter = DynamicLegalDrafterBrain.generateAttestedDemandLetter(
        rawFacts: '車禍被撞機車毀損，初判表對方全責，催討維修費三萬元。',
      );
      expect(letter.subject, contains('催告'));
      expect(letter.demands, isNotEmpty);

      // 生成和解書
      final agreement = DynamicLegalDrafterBrain.generateSettlementAgreement(
        rawFacts: '車禍輕微擦撞，雙方合意新台幣一萬元和解撤回告訴。',
        partyA: const SettlementParty(name: '張先生'),
        partyB: const SettlementParty(name: '王先生'),
        settlementAmount: 10000,
      );
      expect(agreement.settlementAmount, 10000);

      // 生成支付命令
      final petition = DynamicLegalDrafterBrain.generatePaymentOrderPetition(
        rawFacts: '借款五萬元有借據匯款單，催討不還。',
        petitionerName: '債權人甲',
        petitionerId: 'A123456789',
        petitionerAddress: '台北市',
        respondentName: '債務人乙',
        respondentId: 'B987654321',
        respondentAddress: '新北市',
        claimAmount: 50000,
      );
      expect(petition.claimAmount, 50000);
      expect(petition.courtName, contains('地方法院'));
    });

    // -------------------------------------------------------------
    // 7. LawAssistantRepository 深度推理與防禦洞察整合測試
    // -------------------------------------------------------------
    test('LawAssistantRepository produces deep syllogism analysis in mock/offline mode', () async {
      final repo = LawAssistantRepository();
      final conversation = await repo.createConversation(
        prompt: '我被後車追撞，初判表對方全責，我想求償修車費跟受傷薪資損失。',
      );

      expect(conversation.messages.length, 2);
      final assistantMsg = conversation.messages.last;
      expect(assistantMsg.content, contains('三段論法'));
      expect(assistantMsg.answer?.problemDirection, anyOf(contains('交通事故'), contains('交通')));
      expect(assistantMsg.citations?.any((c) => c.title.contains('民法')), isTrue);
      expect(assistantMsg.insight, isNotNull);
      expect(assistantMsg.insight!.disputeCategory, anyOf(contains('交通'), contains('侵權')));
      expect(assistantMsg.insight!.keyEvidences, isNotEmpty);
      expect(assistantMsg.insight!.defensePoints, isNotEmpty);
    });

    // -------------------------------------------------------------
    // 8. 臺灣 17 大法律爭議領域全光譜窮盡性測試 (Universal 17-Domain Coverage)
    // -------------------------------------------------------------
    test('TaiwanDisputeDomain contains exactly 17 major legal dispute categories', () {
      expect(TaiwanDisputeDomain.values.length, 17);
    });

    test('All 17 legal dispute domains route correctly and generate complete syllogisms', () {
      final domainTestCases = <TaiwanDisputeDomain, String>{
        TaiwanDisputeDomain.rentalAndHousing: '租約到期房東以牆壁泛黃扣留押金兩萬元不還',
        TaiwanDisputeDomain.trafficAndTort: '十字路口被違規左轉車輛撞倒機車受損且骨折送醫',
        TaiwanDisputeDomain.loanAndDebt: '朋友借款五十萬元有匯款單借據但無約定還款期',
        TaiwanDisputeDomain.laborAndEmployment: '公司積欠三個月加班費與全勤且無預警口頭資遣拒發非自願離職證明',
        TaiwanDisputeDomain.consumerProtection: '網路購物收到瑕疵筆電於七天猶豫期內要求退貨賣家拒絕退款',
        TaiwanDisputeDomain.constructionAndContract: '新家室內裝潢統包工程嚴重瑕疵漏水逾期未修補拒退工程款',
        TaiwanDisputeDomain.defamationAndPrivacy: '在社群網路公開社團指名道姓誹謗辱罵本人詐欺侵占',
        TaiwanDisputeDomain.familyAndDivorce: '配偶長期外遇家暴分居兩年訴請裁判離婚與爭取未成年子女監護權',
        TaiwanDisputeDomain.inheritanceAndWills: '父親過世遺囑指定遺產由長兄單獨繼承侵害其他繼承人特留分',
        TaiwanDisputeDomain.corporateAndPartnership: '合夥開飲料店合夥人私吞公款且拒絕查帳聲明退夥請求結算',
        TaiwanDisputeDomain.intellectualProperty: '對手廠商未經授權在蝦皮電商平台仿冒我註冊商標販售衣服',
        TaiwanDisputeDomain.fraudAndCybercrime: '求職遭詐騙集團騙取銀行存摺提款卡導致帳戶被警示凍結',
        TaiwanDisputeDomain.propertyAndNeighbor: '樓上住戶浴室防水層滲漏水造成我家天花板發霉拒不開門配合修繕',
        TaiwanDisputeDomain.insuranceAndMedical: '投保醫療險開刀住院申請理賠保險公司藉故拒賠解除契約',
        TaiwanDisputeDomain.compulsoryEnforcement: '持有法院民事確定判決聲請強制執行扣押債務人銀行存款與薪資',
        TaiwanDisputeDomain.administrativeAndPublic: '路面大坑洞未設警告標誌導致車輛翻覆車損請求國家賠償',
        TaiwanDisputeDomain.generalCivilAndContract: '受託代辦事務代墊款項對方事後翻臉不認依不當得利無因管理請求返還',
      };

      for (final entry in domainTestCases.entries) {
        final expectedDomain = entry.key;
        final prompt = entry.value;

        // 1. 檢驗爭議領域路由判定
        final detected = TaiwanStatuteCanon.detectDisputeDomain(prompt);
        expect(
          detected,
          expectedDomain,
          reason: 'Prompt "$prompt" should be detected as $expectedDomain but got $detected',
        );

        // 2. 檢驗三段論法大腦推導
        final syllogism = LegalSyllogismEngine.analyze(rawFacts: prompt);
        expect(syllogism.disputeCategory, isNotEmpty);
        expect(syllogism.majorPremiseStatutes, isNotEmpty,
            reason: '$expectedDomain must have major premise statutes');
        expect(syllogism.subsumptionFindings, isNotEmpty,
            reason: '$expectedDomain must produce subsumption findings');
        expect(syllogism.demands, isNotEmpty,
            reason: '$expectedDomain must specify clear demands');
        expect(syllogism.evidenceChecklist, isNotEmpty,
            reason: '$expectedDomain must provide evidence checklist');
        expect(syllogism.recommendedDeadlineDays, greaterThan(0));

        // 3. 檢驗防禦洞察模型生成
        final insight = LawAssistantDefenseInsight.fromContext(text: prompt);
        expect(insight.disputeCategory, isNotEmpty);
        expect(insight.defensePoints.length, greaterThanOrEqualTo(2));
        expect(insight.keyEvidences.length, greaterThanOrEqualTo(2));
        expect(insight.suggestedFollowUps, isNotEmpty);
        expect(insight.statuteDeadline, isNotNull,
            reason: '$expectedDomain must have statuteDeadline info');
        expect(insight.negotiationKit, isNotNull,
            reason: '$expectedDomain must have negotiationKit defense');
      }
    });

    // -------------------------------------------------------------
    // 8. 動態事實實體感知與即時金句插值測試 (Dynamic Entity Extraction)
    // -------------------------------------------------------------
    test('LawAssistantDefenseInsight dynamically extracts entities and customizes tactical golden phrase', () {
      // 租賃案例：房東、32,000元
      final rentalInsight = LawAssistantDefenseInsight.fromContext(
        text: '房東不退我 32,000元 押金，說有壁癌要扣錢',
      );
      expect(rentalInsight.detectedAmount, '32,000元');
      expect(rentalInsight.detectedCounterparty, '房東');
      expect(rentalInsight.tacticalGoldenPhrase, contains('房東您好'));
      expect(rentalInsight.tacticalGoldenPhrase, contains('新台幣 32,000元'));
      expect(rentalInsight.immediateReassurance, contains('32,000元'));
      expect(rentalInsight.suggestedFollowUps.first, contains('32,000元'));

      // 交通事故案例：對方駕駛、初估50萬
      final trafficInsight = LawAssistantDefenseInsight.fromContext(
        text: '被對方駕駛撞到，修車初估要 50萬元，對方不賠',
      );
      expect(trafficInsight.detectedAmount, '50萬元');
      expect(trafficInsight.detectedCounterparty, '對方駕駛');
      expect(trafficInsight.tacticalGoldenPhrase, contains('對方駕駛您好'));
      expect(trafficInsight.tacticalGoldenPhrase, contains('50萬元'));
      expect(trafficInsight.immediateReassurance, contains('50萬元'));

      // 裝潢工程案例：統包工程/設計師、80萬
      final constructionInsight = LawAssistantDefenseInsight.fromContext(
        text: '設計師裝潢工程延宕且有重大瑕疵，尾款 80萬元 該付嗎',
      );
      expect(constructionInsight.detectedAmount, '80萬元');
      expect(constructionInsight.detectedCounterparty, '統包工程/設計師');
      expect(constructionInsight.tacticalGoldenPhrase, contains('統包工程/設計師您好'));

      // 勞資爭議案例：公司主管/人資、65,000元
      final laborInsight = LawAssistantDefenseInsight.fromContext(
        text: '老闆突然口頭開除我，還欠我 65,000元 加班費不給',
      );
      expect(laborInsight.detectedAmount, '65,000元');
      expect(laborInsight.detectedCounterparty, '公司主管/人資');
      expect(laborInsight.tacticalGoldenPhrase, contains('公司主管/人資您好'));
      expect(laborInsight.tacticalGoldenPhrase, contains('65,000元'));
    });

  });
}

