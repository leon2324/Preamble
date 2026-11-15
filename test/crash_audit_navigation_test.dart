import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:preamble/app/app_state.dart';
import 'package:preamble/data/mock_data/home/legacy/home_mock_data_legacy.dart';
import 'package:preamble/features/case_library/data/case_library_repository.dart';
import 'package:preamble/features/case_library/pages/case_dossier_detail_page.dart';
import 'package:preamble/features/case_library/pages/case_legal_vocabulary_page.dart';
import 'package:preamble/features/case_library/pages/case_library_entry_page.dart';
import 'package:preamble/features/case_library/pages/case_library_search_page.dart';
import 'package:preamble/features/case_library/pages/case_opinion_board_page.dart';
import 'package:preamble/features/case_library/pages/case_opinion_spectrum_page.dart';
import 'package:preamble/features/case_library/theme/case_library_theme.dart';
import 'package:preamble/features/on_this_day/data/on_this_day_mock_data.dart';
import 'package:preamble/features/on_this_day/pages/on_this_day_detail_page.dart';
import 'package:preamble/main.dart';
import 'package:preamble/pages/home/subpages/home_life_legal_tips_page.dart';
import 'package:preamble/pages/journal/data/journal_page_items.dart';
import 'package:preamble/pages/journal/journal_page.dart';
import 'package:preamble/pages/journal/widgets/discussion_detail_page.dart';
import 'package:preamble/pages/journal/widgets/journal_palette.dart';
import 'package:preamble/pages/learning/know_law_page.dart';
import 'package:preamble/pages/tools/legal_toolkit_hub_page.dart';
import 'package:preamble/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pumpPage(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(1179, 2556);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    PreambleScope(
      state: PreambleState(),
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        builder: (_, __) => MaterialApp(
          theme: AppTheme.light(),
          home: child,
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Audit 1: MylawApp boots and taps newly wired Home routes',
      (tester) async {
    tester.view.physicalSize = const Size(1179, 2556);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        builder: (_, __) => const MylawApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.takeException(), isNull);

    // Open notification bell & tap first notification
    final bell = find.byIcon(Icons.notifications_none_rounded);
    if (bell.evaluate().isNotEmpty) {
      await tester.tap(bell.first);
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull);
      final notif1 = find.textContaining('住宅租賃定型化契約電費新制');
      if (notif1.evaluate().isNotEmpty) {
        await tester.tap(notif1.first);
        await tester.pump(const Duration(milliseconds: 400));
        expect(tester.takeException(), isNull);
        Navigator.of(tester.element(find.byType(Scaffold).last)).pop();
        await tester.pump(const Duration(milliseconds: 300));
      }
    }
  });

  testWidgets('Audit 2: LifeLegalTipDetailPage interactions & 1+2 discussion',
      (tester) async {
    await _pumpPage(
      tester,
      LifeLegalTipDetailPage(item: homeNewsletterItems.first),
    );
    expect(tester.takeException(), isNull);

    // 1. Tap 儲存 -> 已儲存
    await tester.tap(find.text('儲存').first);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('已儲存'), findsOneWidget);
    // Verify duplicate bottom '收藏' button was removed
    expect(find.text('收藏'), findsNothing);
    expect(tester.takeException(), isNull);

    // 2. Embedded discussion section exists
    await tester.scrollUntilVisible(
      find.text('過來人討論區'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('過來人討論區'), findsOneWidget);
    expect(find.text('參與討論'), findsOneWidget);

    // 3. Open 85% discussion sheet
    await tester.tap(find.text('參與討論'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.takeException(), isNull);

    // Simulate iOS keyboard open (300pt * 3.0 dpr = 900px) and submit a comment
    tester.view.viewInsets = const FakeViewPadding(bottom: 900);
    await tester.pump(const Duration(milliseconds: 250));
    expect(tester.takeException(), isNull);

    final textField = find.byType(TextField).last;
    await tester.enterText(textField, '實測：已經先拍照並傳訊息留存紀錄！');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.byIcon(Icons.arrow_upward_rounded).last);
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
    expect(find.text('實測：已經先拍照並傳訊息留存紀錄！'), findsWidgets);

    // Close keyboard & sheet
    tester.view.viewInsets = FakeViewPadding.zero;
    await tester.tap(find.byIcon(Icons.close_rounded).last);
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Audit 3: CaseDossierDetailPage, CaseLibraryEntryPage, OnThisDayDetailPage',
      (tester) async {
    for (final id in ['case-029', 'case-045', 'case-delivery-labor-2152', '318']) {
      final book = CaseLibraryRepository.instance.getCaseById(id);
      await _pumpPage(tester, CaseDossierDetailPage(book: book));
      expect(tester.takeException(), isNull, reason: 'Failed on case $id');
    }

    await _pumpPage(tester, const CaseLibraryEntryPage());
    expect(tester.takeException(), isNull);

    for (final item in onThisDayCases.take(5)) {
      await _pumpPage(tester, OnThisDayDetailPage(caseId: item.id));
      expect(tester.takeException(), isNull,
          reason: 'Failed on OnThisDay ${item.id}');
    }
  });

  testWidgets('Audit 4: DiscussionDetailPage, JournalPage, LawAssistantChatPage, LegalToolkitHubPage',
      (tester) async {
    for (final topic in discussionTrendItems) {
      await _pumpPage(
        tester,
        Builder(
          builder: (ctx) => DiscussionDetailPage(
            item: topic,
            palette: JournalPalette.of(ctx),
          ),
        ),
      );
      expect(tester.takeException(), isNull,
          reason: 'Failed on topic ${topic.title}');
    }

    await _pumpPage(
      tester,
      const JournalPage(initialLensTab: 1, lensSelectionVersion: 1),
    );
    expect(tester.takeException(), isNull);

    await _pumpPage(
      tester,
      const LawAssistantChatPage(initialPrompt: '測試提問'),
    );
    expect(tester.takeException(), isNull);

    await _pumpPage(
      tester,
      const LegalToolkitHubPage(initialToolKey: '租屋催告'),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Audit 5: CaseLibrarySearchPage hashtag search & legible AppBar',
      (tester) async {
    await _pumpPage(
      tester,
      const CaseLibrarySearchPage(initialQuery: '實質從屬性'),
    );
    await tester.pump(const Duration(milliseconds: 300));

    final titleFinder = find.text('搜尋司法案件');
    expect(titleFinder, findsOneWidget);
    final titleWidget = tester.widget<Text>(titleFinder);
    expect(titleWidget.style?.color, CaseLibraryColors.primaryGreen);
    expect(find.text('未找到相關案件'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'Audit 6: CaseDossierDetailPage dual-coding issues, 3-step journey, refresh & font scaling',
      (tester) async {
    final book =
        CaseLibraryRepository.instance.getCaseById('case-delivery-labor-2152');
    await _pumpPage(tester, CaseDossierDetailPage(book: book));

    expect(find.textContaining('雙重編碼拆解'), findsOneWidget);
    expect(find.text('白話核心重點'), findsWidgets);
    expect(find.text('問小法助拆解'), findsWidgets);
    expect(find.text('進模擬法庭判這題'), findsWidgets);
    expect(find.text('已探索 0 / 6'), findsOneWidget);
    expect(find.text('STEP 1'), findsOneWidget);
    expect(find.text('STEP 2'), findsOneWidget);
    expect(find.text('STEP 3'), findsOneWidget);

    // Tapping a deliberation step card updates progress counter
    await tester.dragUntilVisible(
      find.text('法律詞卡'),
      find.byType(NestedScrollView),
      const Offset(0, -400),
    );
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.text('法律詞卡'));
    await tester.pump(const Duration(milliseconds: 500));
    Navigator.of(tester.element(find.byType(Scaffold).last)).pop();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('已探索 1 / 6'), findsOneWidget);

    // Bottom refresh & scroll-to-top actions
    await tester.dragUntilVisible(
      find.text('重新整理'),
      find.byType(NestedScrollView),
      const Offset(0, -400),
    );
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('回到頂部'), findsOneWidget);
    await tester.tap(find.text('重新整理'));
    await tester.pump(const Duration(seconds: 4));

    // Font size scaling via NestedScrollView MediaQuery
    final nestedContext = tester.element(find.byType(NestedScrollView));
    expect(MediaQuery.textScalerOf(nestedContext), const TextScaler.linear(1.0));

    await tester.tap(find.byIcon(Icons.text_format_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    Navigator.of(tester.element(find.byType(Slider))).pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    final scaledContext = tester.element(find.byType(NestedScrollView));
    expect(
      MediaQuery.textScalerOf(scaledContext).scale(14),
      closeTo(15.4, 0.2),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'Audit 7: CaseLegalVocabularyPage isolation & no overflow, CaseOpinionSpectrumPage redesign, CaseOpinionBoardPage & Timeline filters',
      (tester) async {
    final laborBook =
        CaseLibraryRepository.instance.getCaseById('case-delivery-labor-2152');

    // 1. Legal vocabulary page only shows case-specific cards (no 318 card leak)
    await _pumpPage(tester, CaseLegalVocabularyPage(book: laborBook));
    expect(find.text('法律詞卡'), findsOneWidget);
    expect(find.text('公民不服從'), findsNothing);
    expect(tester.takeException(), isNull);

    // 2. Spectrum redesign: single integrated stance view + in-place distribution
    await _pumpPage(tester, CaseOpinionSpectrumPage(book: laborBook));
    expect(find.textContaining('法理核心論據'), findsOneWidget);
    await tester.dragUntilVisible(
      find.text('確認我的立場並查看民意分佈'),
      find.byType(ListView),
      const Offset(0, -300),
    );
    await tester.tap(find.text('確認我的立場並查看民意分佈'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.textContaining('已記錄你的立場'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // 3. Opinion board keyboard & submit
    await _pumpPage(tester, CaseOpinionBoardPage(book: laborBook));
    await tester.enterText(find.byType(TextField), '外送員應享有職災與勞健保保障');
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pump();
    await tester.pump(const Duration(seconds: 4));
    expect(find.text('外送員應享有職災與勞健保保障'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // 4. Timeline segmented filter on CaseDossierDetailPage
    await _pumpPage(
      tester,
      CaseDossierDetailPage(book: laborBook, initialTab: '事件與訴訟脈絡'),
    );
    await tester.dragUntilVisible(
      find.text('完整事件與訴訟脈絡'),
      find.byType(NestedScrollView),
      const Offset(0, -400),
    );
    expect(find.textContaining('社會事件'), findsOneWidget);
    expect(find.textContaining('司法審理'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
