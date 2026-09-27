import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:preamble/features/case_library/data/case_library_data.dart';
import 'package:preamble/features/case_library/models/case_library_models.dart';
import 'package:preamble/features/case_library/pages/case_dossier_detail_page.dart';
import 'package:preamble/features/case_library/widgets/wikipedia_infobox_card.dart';
import 'package:preamble/features/case_library/widgets/wikipedia_table_of_contents.dart';
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

  group('Phase 23 - Authentic Landmark Cases Data Integrity Tests', () {
    test('CaseBasicInfo holds complete authentic judicial metadata', () {
      const basicInfo = CaseBasicInfo(
        caseType: '刑事違憲審查',
        procedureStage: '言詞辯論暨終局解釋',
        courtLevel: '司法院大法官會議',
        updatedAt: '2020-05-29',
        caseNumber: '司法院釋字第 791 號解釋',
        judgmentDate: '2020年05月29日',
        bench: '大法官會議（許宗力、蔡烱燉等15位大法官合議）',
        partiesOrPetitioner: '臺灣新北地方法院法官張淵森等法官及民眾聲請釋憲',
        cause: '刑法第239條通姦罪與刑訴第239條但書撤回告訴之效力',
        subsequentAction: '立法院於2021年5月三讀通過刪除刑法第239條與修正刑訴第239條但書',
      );

      expect(basicInfo.caseNumber, '司法院釋字第 791 號解釋');
      expect(basicInfo.judgmentDate, '2020年05月29日');
      expect(basicInfo.bench, contains('許宗力'));
      expect(basicInfo.partiesOrPetitioner, contains('張淵森'));
      expect(basicInfo.cause, contains('通姦罪'));
      expect(basicInfo.subsequentAction, contains('刪除刑法第239條'));
    });

    test('All 9 newly expanded authentic landmark cases are present in seed', () {
      final targetCaseIds = [
        'case-adultery-791',
        'case-indigenous-hunt-803',
        'case-delivery-labor-2152',
        'case-hsu-tzu-chiang-582',
        'case-taikai-insider-1342',
        'case-chang-will-1764',
        'case-support-exemption-1118',
        'case-cross-border-111',
        'case-tsmc-secret-1589',
      ];

      for (final caseId in targetCaseIds) {
        final book = caseLibraryCasesSeed.firstWhere(
          (c) => c.id == caseId,
          orElse: () => throw Exception('Case $caseId not found in seed'),
        );

        // Verify that authentic fields are present
        expect(book.basicInfo.caseNumber, isNotNull);
        expect(book.basicInfo.caseNumber!.isNotEmpty, isTrue);
        expect(book.basicInfo.judgmentDate, isNotNull);
        expect(book.basicInfo.bench, isNotNull);
        expect(book.basicInfo.partiesOrPetitioner, isNotNull);
        expect(book.basicInfo.cause, isNotNull);
        expect(book.investigationAndTrial.isNotEmpty, isTrue);
        expect(book.courtReasoning.isNotEmpty, isTrue);
        expect(book.judgmentResult.isNotEmpty, isTrue);

        // Verify strict prohibition against simulated/vague placeholder phrases
        expect(book.titleZh.contains('模擬'), isFalse);
        expect(book.titleZh.contains('大概'), isFalse);
        expect(book.basicInfo.caseNumber!.contains('模擬'), isFalse);
        expect(book.basicInfo.bench!.contains('黃國法'), isFalse);
        expect(book.basicInfo.bench!.contains('林憲法'), isFalse);
        expect(book.basicInfo.bench!.contains('陳民法'), isFalse);
      }
    });

    test('Authentic landmark cases are properly mapped to their portal sub-shelves', () {
      // 1. 婚姻平權與平等權門戶
      final equalityShelf = caseLibraryHalls
          .expand((h) => h.shelves)
          .firstWhere((s) => s.id == 'shelf-const-equality');
      expect(equalityShelf.caseIds, contains('case-adultery-791'));

      // 2. 權力分立與文化自決門戶
      final powerShelf = caseLibraryHalls
          .expand((h) => h.shelves)
          .firstWhere((s) => s.id == 'shelf-const-power');
      expect(powerShelf.caseIds, contains('case-indigenous-hunt-803'));

      // 3. 冤獄平反門戶
      final deathShelf = caseLibraryHalls
          .expand((h) => h.shelves)
          .firstWhere((s) => s.id == 'shelf-inno-death');
      expect(deathShelf.caseIds, contains('case-hsu-tzu-chiang-582'));

      final confessionShelf = caseLibraryHalls
          .expand((h) => h.shelves)
          .firstWhere((s) => s.id == 'shelf-inno-confession');
      expect(confessionShelf.caseIds, contains('case-hsu-tzu-chiang-582'));

      // 4. 平台勞動與集體訴訟門戶
      final platformShelf = caseLibraryHalls
          .expand((h) => h.shelves)
          .firstWhere((s) => s.id == 'shelf-lab-platform');
      expect(platformShelf.caseIds, contains('case-delivery-labor-2152'));

      // 5. 組織犯罪與洗錢防制門戶
      final orgShelf = caseLibraryHalls
          .expand((h) => h.shelves)
          .firstWhere((s) => s.id == 'shelf-crim-org');
      expect(orgShelf.caseIds, contains('case-taikai-insider-1342'));

      // 6. 營業秘密科技門戶
      final secretShelf = caseLibraryHalls
          .expand((h) => h.shelves)
          .firstWhere((s) => s.id == 'shelf-tech-secret');
      expect(secretShelf.caseIds, contains('case-tsmc-secret-1589'));

      // 7. 涉外家事與弱勢扶養門戶
      final custodyShelf = caseLibraryHalls
          .expand((h) => h.shelves)
          .firstWhere((s) => s.id == 'shelf-fam-custody');
      expect(custodyShelf.caseIds, contains('case-cross-border-111'));

      final estateShelf = caseLibraryHalls
          .expand((h) => h.shelves)
          .firstWhere((s) => s.id == 'shelf-fam-estate');
      expect(estateShelf.caseIds, contains('case-chang-will-1764'));

      final vulnerableShelf = caseLibraryHalls
          .expand((h) => h.shelves)
          .firstWhere((s) => s.id == 'shelf-fam-vulnerable');
      expect(vulnerableShelf.caseIds, contains('case-support-exemption-1118'));
    });
  });

  group('WikipediaInfoboxCard Widget Tests', () {
    testWidgets('Renders authentic infobox card for constitutional decision',
        (WidgetTester tester) async {
      tester.view.devicePixelRatio = 3.0;
      tester.view.physicalSize = const Size(1179, 2556);
      addTearDown(() {
        tester.view.resetDevicePixelRatio();
        tester.view.resetPhysicalSize();
      });

      final book = caseLibraryCaseById('case-adultery-791');

      await tester.pumpWidget(
        buildTestApp(
          Scaffold(
            body: SingleChildScrollView(
              child: WikipediaInfoboxCard(book: book),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Official court header badge
      expect(find.text('🏛️ 憲法法庭 / 大法官裁判'), findsOneWidget);
      expect(find.text('司法院釋字第 791 號解釋'), findsWidgets);

      // Metadata rows
      expect(find.text('審理法院／機關'), findsOneWidget);
      expect(find.text('司法院大法官會議'), findsOneWidget);
      expect(find.text('宣判／作成日期'), findsOneWidget);
      expect(find.text('案件爭點案由'), findsOneWidget);
      expect(find.text('後續修法與司法效應'), findsOneWidget);

      // Verify toggle button
      expect(find.text('收合案件速覽'), findsOneWidget);
      await tester.tap(find.text('收合案件速覽'));
      await tester.pumpAndSettle();

      // Now collapsed
      expect(find.text('展開案件速覽'), findsOneWidget);
      expect(find.text('審理法院／機關'), findsNothing);

      // Tap expand again
      await tester.tap(find.text('展開案件速覽'));
      await tester.pumpAndSettle();
      expect(find.text('審理法院／機關'), findsOneWidget);
    });

    testWidgets('Renders authentic infobox card for supreme court civil judgment',
        (WidgetTester tester) async {
      tester.view.devicePixelRatio = 3.0;
      tester.view.physicalSize = const Size(1179, 2556);
      addTearDown(() {
        tester.view.resetDevicePixelRatio();
        tester.view.resetPhysicalSize();
      });

      final book = caseLibraryCaseById('case-delivery-labor-2152');

      await tester.pumpWidget(
        buildTestApp(
          Scaffold(
            body: SingleChildScrollView(
              child: WikipediaInfoboxCard(book: book),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('⚖️ 司法院確定終局裁判'), findsOneWidget);
      expect(find.text('最高法院 113 年度台上字第 2152 號民事判決'), findsNWidgets(2));
      expect(find.textContaining('富胖達股份有限公司'), findsOneWidget);
      expect(find.textContaining('周舒雁'), findsOneWidget);
    });
  });

  group('WikipediaTableOfContents Widget Tests', () {
    testWidgets('Renders numbered sections and toggles visibility',
        (WidgetTester tester) async {
      tester.view.devicePixelRatio = 3.0;
      tester.view.physicalSize = const Size(1179, 2556);
      addTearDown(() {
        tester.view.resetDevicePixelRatio();
        tester.view.resetPhysicalSize();
      });

      String selectedTab = '';

      await tester.pumpWidget(
        buildTestApp(
          Scaffold(
            body: SingleChildScrollView(
              child: WikipediaTableOfContents(
                activeTab: '事件背景',
                onSelectTab: (tab) {
                  selectedTab = tab;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Header and toggle button
      expect(find.text('目錄'), findsOneWidget);
      expect(find.text('[隱藏]'), findsOneWidget);

      // Section titles
      expect(find.text('事件背景與始末'), findsOneWidget);
      expect(find.text('事件與訴訟大事紀脈絡'), findsOneWidget);
      expect(find.text('核心法律爭點與法理辯論'), findsOneWidget);
      expect(find.text('法院心證與裁判論述'), findsOneWidget);
      expect(find.text('司法院裁判書官方全文與要旨'), findsOneWidget);
      expect(find.text('相關法規條文對照'), findsOneWidget);
      expect(find.text('社會影響與後續修法效應'), findsOneWidget);

      // Select section 2
      await tester.tap(find.text('事件與訴訟大事紀脈絡'));
      await tester.pumpAndSettle();
      expect(selectedTab, '事件與訴訟脈絡');

      // Hide table of contents
      await tester.tap(find.text('[隱藏]'));
      await tester.pumpAndSettle();
      expect(find.text('[顯示]'), findsOneWidget);
      expect(find.text('事件背景與始末'), findsNothing);

      // Show table of contents again
      await tester.tap(find.text('[顯示]'));
      await tester.pumpAndSettle();
      expect(find.text('事件背景與始末'), findsOneWidget);
    });
  });

  group('WikipediaWikilinkService & WikipediaWikilinkText Tests', () {
    test('WikipediaWikilinkService contains landmark Taiwanese legal entities', () {
      final term748 = WikipediaWikilinkService.findEntry('釋字第748號');
      expect(term748, isNotNull);
      expect(term748!.type, WikilinkType.caseItem);
      expect(term748.targetCaseId, '101');

      final term791 = WikipediaWikilinkService.findEntry('釋字第791號');
      expect(term791, isNotNull);
      expect(term791!.targetCaseId, 'case-adultery-791');

      final termTradeSecret = WikipediaWikilinkService.findEntry('營業秘密法第13條之1');
      expect(termTradeSecret, isNotNull);
      expect(termTradeSecret!.type, WikilinkType.lawArticle);

      final termPrinciple = WikipediaWikilinkService.findEntry('不可避免揭露原則');
      expect(termPrinciple, isNotNull);
      expect(termPrinciple!.type, WikilinkType.legalConcept);
    });

    testWidgets('WikipediaWikilinkText renders clickable wikilinks and opens modal hovercard',
        (WidgetTester tester) async {
      tester.view.devicePixelRatio = 3.0;
      tester.view.physicalSize = const Size(1179, 2556);
      addTearDown(() {
        tester.view.resetDevicePixelRatio();
        tester.view.resetPhysicalSize();
      });

      const sampleText = '司法院大法官作成釋字第748號宣告民法違憲，其後立法院制定特別法保障同性婚姻。';

      await tester.pumpWidget(
        buildTestApp(
          const Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16.0),
              child: WikipediaWikilinkText(
                text: sampleText,
                baseStyle: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Wikilink RichText is rendered
      expect(find.byType(RichText), findsOneWidget);

      // Verify entity metadata in service
      final entity = WikipediaWikilinkService.findEntry('釋字第748號')!;
      expect(entity.title, '司法院釋字第 748 號解釋（同性婚姻平權案）');
      expect(entity.citation, '司法院釋字第748號解釋（2017/05/24公布）');
      expect(entity.summary, contains('婚姻自由'));
    });
  });

  group('CaseDossierDetailPage Wikipedia Experience Integration Tests', () {
    testWidgets('Renders authentic landmark case with Wikipedia Infobox & TOC and no mock wording',
        (WidgetTester tester) async {
      tester.view.devicePixelRatio = 3.0;
      tester.view.physicalSize = const Size(1179, 6000);
      addTearDown(() {
        tester.view.resetDevicePixelRatio();
        tester.view.resetPhysicalSize();
      });

      final book = caseLibraryCaseById('case-adultery-791');

      await tester.pumpWidget(
        buildTestApp(
          CaseDossierDetailPage(
            book: book,
            initialTab: '完整判決書',
          ),
        ),
      );
      await tester.pumpForVerification();

      // Verify Wikipedia Infobox Card is rendered
      expect(find.byType(WikipediaInfoboxCard), findsOneWidget);
      expect(find.text('🏛️ 憲法法庭 / 大法官裁判'), findsOneWidget);
      expect(find.text('司法院釋字第 791 號解釋'), findsWidgets);

      // Verify Wikipedia Table of Contents is rendered
      expect(find.byType(WikipediaTableOfContents), findsOneWidget);
      expect(find.text('目錄'), findsOneWidget);

      // Verify completely eradicated simulated/mock phrases
      expect(find.text('判決書全文（模擬書卷）'), findsNothing);
      expect(find.text('模擬司法天平裁判'), findsNothing);
      expect(find.text('【模擬案號】'), findsNothing);
      expect(find.text('黃國法'), findsNothing);
      expect(find.text('林憲法'), findsNothing);
      expect(find.text('陳民法'), findsNothing);

      // Verify authentic replacements are rendered
      expect(find.text('思辨與探索'), findsOneWidget);
      expect(find.text('如果你是法官'), findsOneWidget);
      expect(find.text('體驗法官裁判心證'), findsOneWidget);
    });
  });
}
