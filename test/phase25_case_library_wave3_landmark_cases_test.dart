import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:preamble/features/case_library/data/case_interactive_profiles.dart';
import 'package:preamble/features/case_library/data/case_library_data.dart';
import 'package:preamble/features/case_library/pages/case_judge_practice_page.dart';
import 'package:preamble/features/case_library/pages/case_opinion_board_page.dart';
import 'package:preamble/features/case_library/pages/case_opinion_spectrum_page.dart';
import 'package:preamble/features/case_library/pages/case_social_graph_page.dart';
import 'package:preamble/features/case_library/pages/case_witness_cross_page.dart';
import 'package:preamble/features/case_library/widgets/wikipedia_wikilink_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

extension _VerificationPump on WidgetTester {
  Future<void> pumpForVerification([
    Duration duration = const Duration(milliseconds: 500),
  ]) async {
    await pump();
    await pump(duration);
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildTestApp(Widget child) {
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, _) => MaterialApp(
        theme: ThemeData(fontFamily: 'SF Pro Text'),
        home: child,
      ),
    );
  }

  group('Phase 25 - Wave 3 Landmark Cases Seed & Portal Shelf Tests', () {
    test('Wave 3 landmark cases are present in caseLibraryCases with authentic metadata', () {
      final wave3Ids = [
        'case-chiang-kuo-ching',
        'case-formosa-incident',
        'case-ting-hsin-oil',
        'case-dapu-expropriation',
        'case-chiu-ho-shun',
      ];

      for (final id in wave3Ids) {
        final caseBook = caseLibraryCaseById(id);
        expect(caseBook.id, id);
        expect(caseBook.basicInfo, isNotNull);
        expect(caseBook.basicInfo.caseNumber, isNotEmpty);
        expect(caseBook.basicInfo.bench, isNotEmpty);
        expect(caseBook.basicInfo.partiesOrPetitioner, isNotEmpty);
        expect(caseBook.basicInfo.cause, isNotEmpty);
        expect(caseBook.basicInfo.subsequentAction, isNotEmpty);
        expect(caseBook.background, isNot(contains('模擬')));
        expect(caseBook.background, isNot(contains('大概')));
        expect(caseBook.fullStory, isNot(contains('模擬')));
        expect(caseBook.fullStory, isNot(contains('大概')));
        expect(caseBook.timeline, isNotEmpty);
        expect(caseBook.people, isNotEmpty);
        expect(caseBook.legalIssues, isNotEmpty);
        expect(caseBook.courtReasoning, isNotEmpty);
        expect(caseBook.relatedLaws, isNotEmpty);
        expect(caseBook.socialImpact, isNotEmpty);
      }
    });

    test('Wave 3 landmark cases are properly mapped to portal sub-shelves', () {
      final constHall = caseLibraryHallById('portal-constitutional');
      final innoHall = caseLibraryHallById('portal-innocence');
      final labHall = caseLibraryHallById('portal-labor-pollution');
      final crimHall = caseLibraryHallById('portal-criminal-safety');
      final timelineHall = caseLibraryHallById('timeline');

      // 權力防線棚
      final constPowerShelf =
          constHall.shelves.firstWhere((s) => s.id == 'shelf-const-power');
      expect(constPowerShelf.caseIds, contains('case-formosa-incident'));
      expect(constPowerShelf.caseIds, contains('case-dapu-expropriation'));

      // 冤案平反系列棚
      final innoDeathShelf =
          innoHall.shelves.firstWhere((s) => s.id == 'shelf-inno-death');
      final innoConfessionShelf =
          innoHall.shelves.firstWhere((s) => s.id == 'shelf-inno-confession');
      final innoMilitaryShelf =
          innoHall.shelves.firstWhere((s) => s.id == 'shelf-inno-military');

      expect(innoDeathShelf.caseIds, contains('case-chiang-kuo-ching'));
      expect(innoDeathShelf.caseIds, contains('case-chiu-ho-shun'));
      expect(innoConfessionShelf.caseIds, contains('case-chiang-kuo-ching'));
      expect(innoConfessionShelf.caseIds, contains('case-chiu-ho-shun'));
      expect(innoMilitaryShelf.caseIds, contains('case-chiang-kuo-ching'));
      expect(innoMilitaryShelf.caseIds, contains('case-formosa-incident'));

      // 勞動與公害: 食品安全與勞檢棚
      final labSafetyShelf =
          labHall.shelves.firstWhere((s) => s.id == 'shelf-lab-safety');
      expect(labSafetyShelf.caseIds, contains('case-ting-hsin-oil'));

      // 刑事正義棚
      final crimCivilShelf =
          crimHall.shelves.firstWhere((s) => s.id == 'shelf-crim-civil');
      final crimOrgShelf =
          crimHall.shelves.firstWhere((s) => s.id == 'shelf-crim-org');
      expect(crimCivilShelf.caseIds, contains('case-formosa-incident'));
      expect(crimCivilShelf.caseIds, contains('case-dapu-expropriation'));
      expect(crimOrgShelf.caseIds, contains('case-ting-hsin-oil'));

      // 年代棚
      final shelf1980s =
          timelineHall.shelves.firstWhere((s) => s.id == '1980s');
      final shelf1990s =
          timelineHall.shelves.firstWhere((s) => s.id == '1990s');
      final shelf2010s =
          timelineHall.shelves.firstWhere((s) => s.id == '2010s');

      expect(shelf1980s.caseIds, contains('case-formosa-incident'));
      expect(shelf1980s.caseIds, contains('case-chiu-ho-shun'));
      expect(shelf1990s.caseIds, contains('case-chiang-kuo-ching'));
      expect(shelf2010s.caseIds, contains('case-ting-hsin-oil'));
      expect(shelf2010s.caseIds, contains('case-dapu-expropriation'));
    });

    test('WikipediaWikilinkService contains newly registered Wave 3 terms and concepts', () {
      final terms = [
        '江國慶案',
        '國防部北部地方軍事法院100年度再字第001號',
        '美麗島事件',
        '國防部軍事法庭69年度裁字第001號',
        '頂新黑心油案',
        '最高法院108年度台上字第3324號',
        '大埔徵收事件',
        '臺中高等行政法院101年度訴更一字第47號',
        '邱和順案',
        '最高法院100年度台上字第4177號',
        '抽象危險犯',
        '土地徵收條例第3條之2',
        '唯一死刑二條一',
        '毒樹果實法則',
        '刑事補償法',
      ];

      for (final term in terms) {
        final entry = WikipediaWikilinkService.findEntry(term);
        expect(entry, isNotNull, reason: 'Term $term should be registered');
        expect(entry!.citation, isNotEmpty);
        expect(entry.summary, isNotEmpty);
      }
    });
  });

  group('Phase 25 - CaseInteractiveProfiles Independent Wave 3 Content Tests', () {
    test('Every Wave 3 landmark case has independent non-shared Judge Stances', () {
      final wave3Cases = [
        caseLibraryCaseById('case-chiang-kuo-ching'),
        caseLibraryCaseById('case-formosa-incident'),
        caseLibraryCaseById('case-ting-hsin-oil'),
        caseLibraryCaseById('case-dapu-expropriation'),
        caseLibraryCaseById('case-chiu-ho-shun'),
      ];

      for (final c in wave3Cases) {
        final stances = CaseInteractiveProfiles.getJudgeStances(c);
        expect(stances, isNotEmpty);
        expect(stances.length, 3);
        for (final s in stances) {
          expect(s['title'], isNotEmpty);
          expect(s['description'], isNotEmpty);
          expect(s['analysis'], isNotEmpty);
          expect(s['analysis'], isNot(contains('模擬')));
          expect(s['analysis'], isNot(contains('大概')));
        }
      }
    });

    test('Every Wave 3 landmark case has independent Spectrum Nodes without generic strings', () {
      final wave3Cases = [
        caseLibraryCaseById('case-chiang-kuo-ching'),
        caseLibraryCaseById('case-formosa-incident'),
        caseLibraryCaseById('case-ting-hsin-oil'),
        caseLibraryCaseById('case-dapu-expropriation'),
        caseLibraryCaseById('case-chiu-ho-shun'),
      ];

      for (final c in wave3Cases) {
        final nodes = CaseInteractiveProfiles.getSpectrumNodes(c);
        expect(nodes.length, 3);
        final labels = nodes.map((n) => n['label']).toSet();
        expect(labels.length, 3, reason: 'Labels must be distinct');
        for (final n in nodes) {
          expect(n['fullText'], isNotEmpty);
          expect(n['color'], isNotNull);
          expect(n['fullText'], isNot(contains('模擬')));
          expect(n['fullText'], isNot(contains('大概')));
        }
      }
    });

    test('Virtual Witness Cross examination returns authentic role-specific replies for Wave 3', () {
      final chiang = caseLibraryCaseById('case-chiang-kuo-ching');
      final formosa = caseLibraryCaseById('case-formosa-incident');
      final tingHsin = caseLibraryCaseById('case-ting-hsin-oil');
      final dapu = caseLibraryCaseById('case-dapu-expropriation');
      final chiu = caseLibraryCaseById('case-chiu-ho-shun');

      // 江國慶案
      final chiangQuestions =
          CaseInteractiveProfiles.getWitnessQuickQuestions(chiang, '被害被告');
      expect(chiangQuestions, isNotEmpty);
      expect(chiangQuestions.any((q) => q.contains('自白') || q.contains('反情報隊') || q.contains('私刑')), isTrue);
      final chiangReply = CaseInteractiveProfiles.getWitnessReply(
          chiang, '被害被告', '江國慶，你在反情報隊被逼自白的過程究竟如何？');
      expect(chiangReply, contains('簽字畫押'));

      // 美麗島事件
      final formosaReply = CaseInteractiveProfiles.getWitnessReply(
          formosa, '被告領袖', '施明德先生，美麗島雜誌社在全台宣揚民主訴求是否真有叛亂意圖？');
      expect(formosaReply.contains('訴求') || formosaReply.contains('戒嚴') || formosaReply.contains('言論'), isTrue);

      // 頂新劣質油案
      final tingHsinReply = CaseInteractiveProfiles.getWitnessReply(
          tingHsin, '被告負責人', '魏應充董事長，頂新為何透過越南大幸福進口未經食用認證之飼料油脂？');
      expect(tingHsinReply.contains('大幸福') || tingHsinReply.contains('精煉') || tingHsinReply.contains('產銷履歷'), isTrue);

      // 大埔徵收案
      final dapuReply = CaseInteractiveProfiles.getWitnessReply(
          dapu, '原告家屬', '彭秀春女士，在張森文先生離世後，是什麼信念支撐您一人堅持把行政訴訟打到底？');
      expect(dapuReply.contains('森文') || dapuReply.contains('小藥房') || dapuReply.contains('公道'), isTrue);

      // 邱和順案
      final chiuReply = CaseInteractiveProfiles.getWitnessReply(
          chiu, '死刑被告', '邱和順先生，在台北市刑大被拘留審訊時，您究竟遭遇了怎樣的刑求逼供？');
      expect(chiuReply.contains('酷刑') || chiuReply.contains('電擊') || chiuReply.contains('辣椒水'), isTrue);
    });

    test('Opinion Board stickers and AI Grooming are bespoke for Wave 3 cases', () {
      final chiang = caseLibraryCaseById('case-chiang-kuo-ching');
      final tingHsin = caseLibraryCaseById('case-ting-hsin-oil');

      final chiangStickers = CaseInteractiveProfiles.getOpinionStickers(chiang);
      expect(chiangStickers, isNotEmpty);
      expect(chiangStickers.any((s) => s['text'].toString().contains('正當程序') || s['text'].toString().contains('刑求')), isTrue);

      final tingHsinStickers = CaseInteractiveProfiles.getOpinionStickers(tingHsin);
      expect(tingHsinStickers, isNotEmpty);
      expect(tingHsinStickers.any((s) => s['text'].toString().contains('抽象危險犯')), isTrue);

      final chiangGrooming =
          CaseInteractiveProfiles.getAiGroomingSuggestion(chiang, '草菅人命的冤案');
      expect(chiangGrooming, contains('江國慶案'));
      expect(chiangGrooming, contains('程序正義'));

      final tingHsinGrooming =
          CaseInteractiveProfiles.getAiGroomingSuggestion(tingHsin, '黑心商人無罪太扯了');
      expect(tingHsinGrooming, contains('頂新'));
      expect(tingHsinGrooming, contains('抽象危險犯'));
    });

    test('Social Graph Ripple effects reflect authentic reforms for Wave 3 cases', () {
      final chiang = caseLibraryCaseById('case-chiang-kuo-ching');
      final dapu = caseLibraryCaseById('case-dapu-expropriation');

      final chiangEffects = CaseInteractiveProfiles.getSocialEffects(chiang);
      expect(chiangEffects.length, greaterThanOrEqualTo(4));
      expect(chiangEffects.any((e) => e['title'].toString().contains('刑事補償法') || e['title'].toString().contains('平時軍法審判')), isTrue);

      final dapuEffects = CaseInteractiveProfiles.getSocialEffects(dapu);
      expect(dapuEffects.length, greaterThanOrEqualTo(4));
      expect(dapuEffects.any((e) => e['description'].toString().contains('土地徵收條例') || e['title'].toString().contains('土地徵收')), isTrue);
    });

    test('Poll questions and netizen salon comments reflect authentic controversies for Wave 3', () {
      final formosa = caseLibraryCaseById('case-formosa-incident');
      final chiu = caseLibraryCaseById('case-chiu-ho-shun');

      final formosaPoll = CaseInteractiveProfiles.getPollQuestion(formosa);
      expect(formosaPoll, contains('美麗島事件'));
      expect(formosaPoll, contains('叛亂罪'));

      final chiuPoll = CaseInteractiveProfiles.getPollQuestion(chiu);
      expect(chiuPoll, contains('邱和順'));
      expect(chiuPoll.contains('刑求') || chiuPoll.contains('特赦'), isTrue);

      final formosaComments = CaseInteractiveProfiles.getNetizenComments(formosa);
      expect(formosaComments.length, 3);
      expect(formosaComments.any((c) => c['stance'] == '合理派'), isTrue);
      expect(formosaComments.any((c) => c['stance'] == '不合理派'), isTrue);
      expect(formosaComments.any((c) => c['stance'] == '中立派'), isTrue);

      final chiuComments = CaseInteractiveProfiles.getNetizenComments(chiu);
      expect(chiuComments.length, 3);
      expect(chiuComments.any((c) => c['stance'] == '合理派'), isTrue);
      expect(chiuComments.any((c) => c['stance'] == '不合理派'), isTrue);
      expect(chiuComments.any((c) => c['stance'] == '中立派'), isTrue);
    });
  });

  group('Phase 25 - Widget Integration Tests for Wave 3 Deliberation Pages', () {
    testWidgets('CaseJudgePracticePage renders tailored stances for Chiang Kuo-ching case',
        (tester) async {
      final caseBook = caseLibraryCaseById('case-chiang-kuo-ching');
      await tester.pumpWidget(buildTestApp(CaseJudgePracticePage(book: caseBook)));
      await tester.pumpForVerification();

      expect(find.text('如果你是法官'), findsOneWidget);

      final stanceFinder = find.textContaining('排除非法刑求自白');
      await tester.scrollUntilVisible(stanceFinder, 200);
      expect(stanceFinder, findsOneWidget);

      // Tap on first stance
      await tester.tap(stanceFinder);
      await tester.pumpForVerification();

      final resultFinder = find.textContaining('高度一致');
      await tester.scrollUntilVisible(resultFinder, 200);
      expect(resultFinder, findsOneWidget);
      expect(find.textContaining('100年度再字第001號判決'), findsOneWidget);
    });

    testWidgets('CaseOpinionSpectrumPage renders tailored spectrum nodes for Ting Hsin case',
        (tester) async {
      final caseBook = caseLibraryCaseById('case-ting-hsin-oil');
      await tester.pumpWidget(buildTestApp(CaseOpinionSpectrumPage(book: caseBook)));
      await tester.pumpForVerification();

      expect(find.text('觀點光譜'), findsOneWidget);
      // Nodes shortTitles on spectrum track
      expect(find.text('具體實害與科學檢測'), findsOneWidget);
      expect(find.text('原料零容忍沒收不法'), findsOneWidget);
      // Initial closest node (50%) label
      expect(find.text('消費誠信保護派'), findsOneWidget);

      // Drag Slider to the right (towards 85% - 100%)
      await tester.drag(find.byType(Slider), const Offset(200, 0));
      await tester.pumpForVerification();

      // Now closest node is node 2 (抽象危險嚴格食安派)
      expect(find.text('抽象危險嚴格食安派'), findsOneWidget);

      // Verify that generic terms like 實質法條派 are NOT present
      expect(find.text('實質法條派'), findsNothing);
    });

    testWidgets('CaseWitnessCrossPage renders bespoke Q&A for Formosa Incident',
        (tester) async {
      final caseBook = caseLibraryCaseById('case-formosa-incident');
      await tester.pumpWidget(buildTestApp(CaseWitnessCrossPage(book: caseBook)));
      await tester.pumpForVerification();

      expect(find.text('虛擬詰問室'), findsOneWidget);
      expect(find.textContaining('施明德'), findsWidgets);

      // Tap on quick question
      await tester.tap(find.textContaining('施明德').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.textContaining('微笑'), findsWidgets);
      // Verify no sunflower student movement content
      expect(find.textContaining('服貿'), findsNothing);
    });

    testWidgets('CaseOpinionBoardPage renders Morandi sticky notes for Dapu Expropriation case',
        (tester) async {
      final caseBook = caseLibraryCaseById('case-dapu-expropriation');
      await tester.pumpWidget(buildTestApp(CaseOpinionBoardPage(book: caseBook)));
      await tester.pumpForVerification();

      expect(find.text('意見塗鴉牆'), findsOneWidget);
      expect(find.textContaining('張藥房'), findsOneWidget);
      expect(find.textContaining('土地徵收必須恪遵公益與必要'), findsOneWidget);
      // Verify no unrelated case text
      expect(find.textContaining('黑心油'), findsNothing);
    });

    testWidgets('CaseSocialGraphPage renders authentic ripple effects for Chiu Ho-shun case',
        (tester) async {
      final caseBook = caseLibraryCaseById('case-chiu-ho-shun');
      await tester.pumpWidget(buildTestApp(CaseSocialGraphPage(book: caseBook)));
      await tester.pumpForVerification();

      expect(find.text('社會效應圖譜'), findsOneWidget);
      expect(find.textContaining('鑑識鑑真：推動刑事證物監管鏈法制化'), findsOneWidget);
      expect(find.textContaining('偵訊正義：警詢全程連續錄音錄影立法'), findsOneWidget);
    });
  });
}
