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

  group('Phase 24 - Wave 2 Landmark Cases Seed & Portal Shelf Tests', () {
    test('Wave 2 landmark cases are present in caseLibraryCases with authentic metadata', () {
      final wave2Ids = [
        'case-su-chien-ho',
        'case-rca-pollution',
        'case-tang-ying-shen',
        'case-cross-marriage-1445',
        'case-prison-selection-13',
      ];

      for (final id in wave2Ids) {
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
      }
    });

    test('Wave 2 landmark cases are properly mapped to portal sub-shelves', () {
      final constHall = caseLibraryHallById('portal-constitutional');
      final innoHall = caseLibraryHallById('portal-innocence');
      final labHall = caseLibraryHallById('portal-labor-pollution');
      final famHall = caseLibraryHallById('portal-family-rights');
      final timelineHall = caseLibraryHallById('timeline');

      // 跨國同婚與湯英伸案在憲法平等棚
      final constEqualityShelf =
          constHall.shelves.firstWhere((s) => s.id == 'shelf-const-equality');
      expect(constEqualityShelf.caseIds, contains('case-cross-marriage-1445'));
      expect(constEqualityShelf.caseIds, contains('case-tang-ying-shen'));

      // 外役監條例在權力防線棚
      final constPowerShelf =
          constHall.shelves.firstWhere((s) => s.id == 'shelf-const-power');
      expect(constPowerShelf.caseIds, contains('case-prison-selection-13'));

      // 蘇建和案在冤案平反棚
      final innoDeathShelf =
          innoHall.shelves.firstWhere((s) => s.id == 'shelf-inno-death');
      final innoConfessionShelf =
          innoHall.shelves.firstWhere((s) => s.id == 'shelf-inno-confession');
      expect(innoDeathShelf.caseIds, contains('case-su-chien-ho'));
      expect(innoConfessionShelf.caseIds, contains('case-su-chien-ho'));

      // RCA案在公害毒物棚
      final labToxicShelf =
          labHall.shelves.firstWhere((s) => s.id == 'shelf-lab-toxic');
      expect(labToxicShelf.caseIds, contains('case-rca-pollution'));

      // 跨國同婚在家事親權棚
      final famCustodyShelf =
          famHall.shelves.firstWhere((s) => s.id == 'shelf-fam-custody');
      expect(famCustodyShelf.caseIds, contains('case-cross-marriage-1445'));

      // 年代棚
      final shelf2020s =
          timelineHall.shelves.firstWhere((s) => s.id == '2020s');
      final shelf2010s =
          timelineHall.shelves.firstWhere((s) => s.id == '2010s');
      final shelf1980s =
          timelineHall.shelves.firstWhere((s) => s.id == '1980s');

      expect(shelf2020s.caseIds, contains('case-cross-marriage-1445'));
      expect(shelf2020s.caseIds, contains('case-prison-selection-13'));
      expect(shelf2010s.caseIds, contains('case-su-chien-ho'));
      expect(shelf2010s.caseIds, contains('case-rca-pollution'));
      expect(shelf1980s.caseIds, contains('case-tang-ying-shen'));
    });

    test('WikipediaWikilinkService contains newly registered Wave 2 terms', () {
      final terms = [
        '蘇建和案',
        '最高法院101年度台上字第4500號',
        'RCA公害案',
        '最高法院107年度台上字第267號',
        '湯英伸案',
        '最高法院75年度台上字第5006號',
        '跨國同婚首例勝訴',
        '臺北高等行政法院109年度訴字第1445號',
        '112年憲判字第13號',
        '外役監條例第4條',
        '疫學因果關係',
        '消極公序良俗',
        '反致原則',
        '自白補強法則',
      ];

      for (final term in terms) {
        final entry = WikipediaWikilinkService.findEntry(term);
        expect(entry, isNotNull, reason: 'Term $term should be registered');
        expect(entry!.citation, isNotEmpty);
        expect(entry.summary, isNotEmpty);
      }
    });
  });

  group('Phase 24 - CaseInteractiveProfiles Independent Content Tests', () {
    test('Every landmark case has independent non-shared Judge Stances', () {
      final cases = [
        caseLibraryCaseById('case-su-chien-ho'),
        caseLibraryCaseById('case-rca-pollution'),
        caseLibraryCaseById('case-tang-ying-shen'),
        caseLibraryCaseById('case-cross-marriage-1445'),
        caseLibraryCaseById('case-prison-selection-13'),
        caseLibraryCaseById('case-delivery-labor-2152'),
        caseLibraryCaseById('case-tsmc-secret-1589'),
      ];

      for (final c in cases) {
        final stances = CaseInteractiveProfiles.getJudgeStances(c);
        expect(stances, isNotEmpty);
        expect(stances.length, greaterThanOrEqualTo(2));
        for (final s in stances) {
          expect(s['title'], isNotEmpty);
          expect(s['description'], isNotEmpty);
          expect(s['analysis'], isNotEmpty);
          expect(s['analysis'], isNot(contains('模擬')));
          expect(s['analysis'], isNot(contains('大概')));
        }
      }
    });

    test('Every landmark case has independent Spectrum Nodes without generic strings', () {
      final cases = [
        caseLibraryCaseById('case-su-chien-ho'),
        caseLibraryCaseById('case-rca-pollution'),
        caseLibraryCaseById('case-tang-ying-shen'),
        caseLibraryCaseById('case-cross-marriage-1445'),
        caseLibraryCaseById('case-prison-selection-13'),
      ];

      for (final c in cases) {
        final nodes = CaseInteractiveProfiles.getSpectrumNodes(c);
        expect(nodes.length, 3);
        final labels = nodes.map((n) => n['label']).toSet();
        expect(labels.length, 3, reason: 'Labels must be distinct');
        for (final n in nodes) {
          expect(n['fullText'], isNotEmpty);
          expect(n['color'], isNotNull);
        }
      }
    });

    test('Virtual Witness Cross examination returns authentic role-specific replies', () {
      final suChienHo = caseLibraryCaseById('case-su-chien-ho');
      final rca = caseLibraryCaseById('case-rca-pollution');
      final tang = caseLibraryCaseById('case-tang-ying-shen');

      // 蘇建和案
      final suQuestions =
          CaseInteractiveProfiles.getWitnessQuickQuestions(suChienHo, '被告/蘇建和');
      expect(suQuestions, isNotEmpty);
      expect(suQuestions.any((q) => q.contains('刑訊逼供') || q.contains('不在場')), isTrue);

      final suReply = CaseInteractiveProfiles.getWitnessReply(
          suChienHo, '被告', '你在汐止分局偵訊時，是否真的遭到辦案員警刑訊逼供？');
      expect(suReply, contains('打火機'));
      expect(suReply, isNot(contains('服貿')));

      // RCA案
      final rcaReply = CaseInteractiveProfiles.getWitnessReply(
          rca, '原告', 'RCA員工在廠區工作時，所接觸的化學溶劑具體情況為何？');
      expect(rcaReply, contains('三氯乙烯'));
      expect(rcaReply, contains('地下水'));
      expect(rcaReply, isNot(contains('服貿')));

      // 湯英伸案
      final tangReply = CaseInteractiveProfiles.getWitnessReply(
          tang, '被告', '湯英伸，你從阿里山來到台北求職時，具體遭遇了什麼剝削困境？');
      expect(tangReply, contains('阿里山'));
      expect(tangReply, contains('身分證'));
      expect(tangReply, isNot(contains('服貿')));
    });

    test('Opinion Board stickers and AI Grooming are bespoke and case-specific', () {
      final suChienHo = caseLibraryCaseById('case-su-chien-ho');
      final crossMarriage = caseLibraryCaseById('case-cross-marriage-1445');

      final suStickers = CaseInteractiveProfiles.getOpinionStickers(suChienHo);
      expect(suStickers, isNotEmpty);
      expect(suStickers.any((s) => s['text'].toString().contains('無罪推定')), isTrue);
      expect(suStickers.any((s) => s['text'].toString().contains('食品溯源')), isFalse);

      final cmStickers = CaseInteractiveProfiles.getOpinionStickers(crossMarriage);
      expect(cmStickers, isNotEmpty);
      expect(cmStickers.any((s) => s['text'].toString().contains('公序良俗')), isTrue);

      final suGrooming =
          CaseInteractiveProfiles.getAiGroomingSuggestion(suChienHo, '這根本是恐龍法官');
      expect(suGrooming, contains('蘇建和案'));
      expect(suGrooming, contains('無罪推定'));
    });

    test('Social Graph Ripple effects reflect authentic legislative and judicial reforms', () {
      final prisonCase = caseLibraryCaseById('case-prison-selection-13');
      final rcaCase = caseLibraryCaseById('case-rca-pollution');

      final prisonEffects = CaseInteractiveProfiles.getSocialEffects(prisonCase);
      expect(prisonEffects.length, greaterThanOrEqualTo(4));
      expect(prisonEffects.any((e) => e['title'].toString().contains('外役監條例')), isTrue);

      final rcaEffects = CaseInteractiveProfiles.getSocialEffects(rcaCase);
      expect(rcaEffects.length, greaterThanOrEqualTo(4));
      expect(rcaEffects.any((e) => e['title'].toString().contains('疫學因果')), isTrue);
      expect(rcaEffects.any((e) => e['title'].toString().contains('揭穿公司面紗')), isTrue);
    });

    test('Poll questions and comments reflect real legal controversies', () {
      final tang = caseLibraryCaseById('case-tang-ying-shen');
      final pollQuestion = CaseInteractiveProfiles.getPollQuestion(tang);
      expect(pollQuestion, contains('湯英伸案'));
      expect(pollQuestion, contains('死刑'));

      final votes = CaseInteractiveProfiles.getPollVotes(tang);
      expect(votes.length, 2);
      expect(votes[0] + votes[1], greaterThan(0));

      final comments = CaseInteractiveProfiles.getNetizenComments(tang);
      expect(comments.length, greaterThanOrEqualTo(3));
      expect(comments.any((c) => c['stance'] == '合理派'), isTrue);
      expect(comments.any((c) => c['stance'] == '不合理派'), isTrue);
    });
  });

  group('Phase 24 - Widget Integration Tests for Deliberation Pages', () {
    testWidgets('CaseJudgePracticePage renders tailored stances for Su Chien-ho case',
        (tester) async {
      final caseBook = caseLibraryCaseById('case-su-chien-ho');
      await tester.pumpWidget(buildTestApp(CaseJudgePracticePage(book: caseBook)));
      await tester.pumpForVerification();

      expect(find.text('如果你是法官'), findsOneWidget);

      final stanceFinder = find.textContaining('不正訊問自白無證據能力');
      await tester.scrollUntilVisible(stanceFinder, 200);
      expect(stanceFinder, findsOneWidget);

      // Tap on first stance
      await tester.tap(stanceFinder);
      await tester.pumpForVerification();

      final resultFinder = find.textContaining('高度一致');
      await tester.scrollUntilVisible(resultFinder, 200);
      expect(resultFinder, findsOneWidget);
      expect(find.textContaining('最高法院101年度台上字第4500號判決'), findsOneWidget);
    });

    testWidgets('CaseOpinionSpectrumPage renders tailored spectrum nodes for RCA case',
        (tester) async {
      final caseBook = caseLibraryCaseById('case-rca-pollution');
      await tester.pumpWidget(buildTestApp(CaseOpinionSpectrumPage(book: caseBook)));
      await tester.pumpForVerification();

      expect(find.text('觀點光譜'), findsOneWidget);
      // Nodes shortTitles on spectrum track
      expect(find.text('微觀科學嚴格舉證'), findsOneWidget);
      expect(find.text('疫學因果倒置面紗穿透'), findsOneWidget);
      // Initial closest node (50%) label
      expect(find.text('損害衡平派'), findsOneWidget);

      // Drag Slider to the right (towards 85% - 100%)
      await tester.drag(find.byType(Slider), const Offset(200, 0));
      await tester.pumpForVerification();

      // Now closest node is node 2 (環境公害正義派)
      expect(find.text('環境公害正義派'), findsOneWidget);

      // Verify that generic terms like 實質法條派 are NOT present
      expect(find.text('實質法條派'), findsNothing);
    });

    testWidgets('CaseWitnessCrossPage renders bespoke Q&A for Tang Ying-shen case',
        (tester) async {
      final caseBook = caseLibraryCaseById('case-tang-ying-shen');
      await tester.pumpWidget(buildTestApp(CaseWitnessCrossPage(book: caseBook)));
      await tester.pumpForVerification();

      expect(find.text('虛擬詰問室'), findsOneWidget);
      expect(find.textContaining('阿里山'), findsWidgets);

      // Tap on quick question
      await tester.tap(find.textContaining('阿里山').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.textContaining('鄒族'), findsWidgets);
      // Verify no sunflower student movement content
      expect(find.textContaining('服貿'), findsNothing);
    });

    testWidgets('CaseOpinionBoardPage renders Morandi sticky notes for Cross Marriage case',
        (tester) async {
      final caseBook = caseLibraryCaseById('case-cross-marriage-1445');
      await tester.pumpWidget(buildTestApp(CaseOpinionBoardPage(book: caseBook)));
      await tester.pumpForVerification();

      expect(find.text('意見塗鴉牆'), findsOneWidget);
      expect(find.textContaining('消極公序良俗'), findsOneWidget);
      expect(find.textContaining('祁家威'), findsOneWidget);
      // Verify no food safety text
      expect(find.textContaining('食品溯源'), findsNothing);
    });

    testWidgets('CaseSocialGraphPage renders authentic ripple effects for Prison Selection case',
        (tester) async {
      final caseBook = caseLibraryCaseById('case-prison-selection-13');
      await tester.pumpWidget(buildTestApp(CaseSocialGraphPage(book: caseBook)));
      await tester.pumpForVerification();

      expect(find.text('社會效應圖譜'), findsOneWidget);
      expect(find.textContaining('受刑人實質平等權之確立'), findsOneWidget);
      expect(find.textContaining('外役監條例第4條全面三讀修訂'), findsOneWidget);
    });
  });
}
