import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:preamble/app/app_state.dart';
import 'package:preamble/features/case_library/data/case_library_data.dart';
import 'package:preamble/features/case_library/models/case_library_models.dart';
import 'package:preamble/features/case_library/pages/case_library_entry_page.dart';
import 'package:preamble/features/case_library/pages/case_library_hall_page.dart';
import 'package:preamble/features/case_library/pages/case_library_hall_selection_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Wikipedia Legal Portals Data Model Tests', () {
    test('caseLibraryHalls contains all 6 Wikipedia Portals and status hall', () {
      final portalHalls = caseLibraryHalls
          .where((h) => h.type == CaseLibraryHallType.portal)
          .toList();

      expect(portalHalls.length, 6);

      final portalIds = portalHalls.map((h) => h.id).toSet();
      expect(
        portalIds,
        containsAll([
          'portal-constitutional',
          'portal-innocence',
          'portal-labor-pollution',
          'portal-criminal-safety',
          'portal-tech-ip',
          'portal-family-rights',
        ]),
      );

      // Verify constitutional review portal details
      final constPortal = caseLibraryHallById('portal-constitutional');
      expect(constPortal.name, '憲政審查與基本人權門戶');
      expect(constPortal.badge, '憲政司法審查');
      expect(constPortal.featuredCaseId, '101');
      expect(constPortal.portalTags, contains('釋字第748號'));
      expect(constPortal.shelves.length, 3);
      expect(constPortal.shelves.first.name, '人身自由與正當法律程序');

      // Verify status hall
      final statusHall = caseLibraryHallById('status');
      expect(statusHall.type, CaseLibraryHallType.status);
      expect(statusHall.shelves.length, 3);
      expect(statusHall.shelves.any((s) => s.name == '終局判決確定'), isTrue);
      expect(statusHall.shelves.any((s) => s.name == '違憲宣告與憲法判決'), isTrue);
    });
  });

  group('Wikipedia Legal Portals Widget Tests', () {
    Widget createTestWidget(Widget child) {
      return ScreenUtilInit(
        designSize: const Size(393, 852),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, _) => MaterialApp(
          home: child,
        ),
      );
    }

    testWidgets('CaseLibraryHallSelectionPage renders all 6 portals and taxonomy dimensions',
        (WidgetTester tester) async {
      tester.view.devicePixelRatio = 3.0;
      tester.view.physicalSize = const Size(1179, 2556);
      addTearDown(() {
        tester.view.resetDevicePixelRatio();
        tester.view.resetPhysicalSize();
      });

      await tester.pumpWidget(createTestWidget(const CaseLibraryHallSelectionPage()));
      await tester.pumpAndSettle();

      // Verify Page Title and Wikipedia Portals Section Header
      expect(find.text('司法專題館藏與分類目錄'), findsOneWidget);
      expect(find.text('🏛️ 司法領域專題館藏'), findsOneWidget);
      expect(find.text('6 大核心專題'), findsOneWidget);

      // Verify Portals are listed (on screen)
      expect(find.text('憲政審查與基本人權門戶'), findsOneWidget);
      expect(find.text('司法冤案平反與程序防線門戶'), findsOneWidget);
      expect(find.text('環境公害、勞資爭議與集體訴訟門戶'), findsOneWidget);
      expect(find.text('重大社會刑案與公共安全門戶'), findsOneWidget);

      // Scroll down to view remaining portals and taxonomy dimensions
      await tester.scrollUntilVisible(find.text('數位科技、營業秘密與智財門戶'), 300);
      expect(find.text('數位科技、營業秘密與智財門戶'), findsOneWidget);

      await tester.scrollUntilVisible(find.text('家事親權、特留分與弱勢保護門戶'), 300);
      expect(find.text('家事親權、特留分與弱勢保護門戶'), findsOneWidget);

      // Verify Taxonomy Dimensions Section Header and Items
      await tester.scrollUntilVisible(find.text('⏳ 多維司法檢索維度'), 300);
      expect(find.text('⏳ 多維司法檢索維度'), findsOneWidget);

      await tester.scrollUntilVisible(find.text('年代大事紀館'), 300);
      expect(find.text('年代大事紀館'), findsOneWidget);

      await tester.scrollUntilVisible(find.text('生活爭端實務館'), 300);
      expect(find.text('生活爭端實務館'), findsOneWidget);
    });

    testWidgets('CaseLibraryHallPage renders portal view with lead card, tabs, and featured case',
        (WidgetTester tester) async {
      tester.view.devicePixelRatio = 3.0;
      tester.view.physicalSize = const Size(1179, 2556);
      addTearDown(() {
        tester.view.resetDevicePixelRatio();
        tester.view.resetPhysicalSize();
      });

      final portal = caseLibraryHallById('portal-constitutional');
      await tester.pumpWidget(createTestWidget(CaseLibraryHallPage(hall: portal)));
      // Pump past CupertinoActivityIndicator loading phase
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify Header & Portal Lead Card
      expect(find.text('憲政審查與基本人權門戶'), findsWidgets);
      expect(find.text('憲政司法審查'), findsOneWidget);
      expect(find.text('#釋字第748號'), findsOneWidget);
      expect(find.text('#憲法第23條'), findsOneWidget);

      // Verify Sub-shelves Tabs (visible in horizontal list)
      expect(find.textContaining('全部典藏'), findsOneWidget);
      expect(find.textContaining('人身自由與正當法律程序'), findsOneWidget);

      // Verify Featured Landmark Case Card
      expect(find.text('⭐ 焦點指標大案'), findsOneWidget);
      expect(find.text('同性婚姻釋憲案（司法院釋字第 748 號）'), findsOneWidget);
      expect(find.text('研讀判決檔案詳情 ➔'), findsOneWidget);

      // Tap on specific sub-shelf: "人身自由與正當法律程序"
      final libertyShelfTab = find.textContaining('人身自由與正當法律程序');
      expect(libertyShelfTab, findsOneWidget);
      await tester.tap(libertyShelfTab);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify that sub-shelf header is displayed
      expect(find.text('人身自由與正當法律程序'), findsWidgets);
      expect(find.text('搜索扣押、臨檢、刑事人身強制治療與程序正義'), findsOneWidget);
    });

    testWidgets('CaseLibraryEntryPage renders Wikipedia Portals carousel',
        (WidgetTester tester) async {
      tester.view.devicePixelRatio = 3.0;
      tester.view.physicalSize = const Size(1179, 2556);
      addTearDown(() {
        tester.view.resetDevicePixelRatio();
        tester.view.resetPhysicalSize();
      });

      final appState = PreambleState();
      addTearDown(appState.dispose);
      await appState.load();

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(393, 852),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, _) => PreambleScope(
            state: appState,
            child: const MaterialApp(
              home: CaseLibraryEntryPage(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Section Header
      expect(find.text('🏛️ 司法專題館藏'), findsOneWidget);
      expect(find.text('全部專題 (6)'), findsOneWidget);

      // Verify Wikipedia Portal Cards in Carousel
      expect(find.text('憲政審查與基本人權門戶'), findsOneWidget);
      expect(find.text('司法冤案平反與程序防線門戶'), findsOneWidget);

      // Verify Taxonomy Dimension Action Buttons
      expect(find.text('年代大事紀'), findsOneWidget);
      expect(find.text('重大刑案館'), findsOneWidget);
      expect(find.text('憲政人權館'), findsOneWidget);
    });
  });
}
