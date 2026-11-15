import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:preamble/app/app_state.dart';
import 'package:preamble/data/journal/user_case_journal_models.dart';
import 'package:preamble/data/journal/user_case_journal_repository.dart';
import 'package:preamble/data/law_assistant/law_assistant_models.dart';
import 'package:preamble/data/legal_brain/taiwan_statute_canon.dart';
import 'package:preamble/data/mock_data/home/home_mock_data.dart';
import 'package:preamble/pages/journal/data/journal_page_items.dart';
import 'package:preamble/pages/journal/journal_page.dart';
import 'package:preamble/pages/journal/widgets/assistant_prompt_bubble.dart';
import 'package:preamble/pages/journal/widgets/discussion_detail_page.dart';
import 'package:preamble/pages/journal/widgets/journal_palette.dart';
import 'package:preamble/pages/journal/widgets/user_case_journal_section.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 20: User Case Journal & Journal Page Upgrade Tests', () {
    test('UserCaseJournalRepository loads seed case and calculates progress correctly', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = UserCaseJournalRepository(prefs: prefs);

      // Verify seed case loaded
      expect(repo.entries, isNotEmpty);
      final seed = repo.entries.first;
      expect(seed.counterparty, '房東');
      expect(seed.disputedAmount, '32,000元');
      expect(seed.remainingDays, greaterThan(0));
      expect(seed.evidenceProgress, closeTo(0.75, 0.01)); // 3 out of 4
      expect(seed.logs.length, 3);

      // Toggle 4th evidence
      await repo.toggleEvidence(seed.id, 3);
      expect(repo.entries.first.evidenceProgress, 1.0); // 4 out of 4

      // Add a new log
      await repo.addLog(
        seed.id,
        CaseJournalLogEntry(
          id: 'log-new',
          timestamp: DateTime.now(),
          title: '已寄出存證信函',
          note: '郵局雙掛號交寄，取得交寄執據備存。',
          tag: '存證信函',
        ),
      );
      expect(repo.entries.first.logs.length, 4);
      expect(repo.entries.first.logs.first.title, '已寄出存證信函');
    });

    test('UserCaseJournalRepository.fromAssistantInsight correctly converts AI insight into journal case', () {
      final insight = LawAssistantDefenseInsight.fromContext(
        text: '被對方駕駛撞到，修車初估要 50萬元，對方不賠',
      );

      final entry = UserCaseJournalRepository.fromAssistantInsight(
        insight: insight,
        rawFacts: '被對方駕駛撞到，修車初估要 50萬元，對方不賠',
      );

      expect(entry.domain, TaiwanDisputeDomain.trafficAndTort);
      expect(entry.counterparty, '對方駕駛');
      expect(entry.disputedAmount, '50萬元');
      expect(entry.statuteDeadlineTitle, contains('過失傷害'));
      expect(entry.evidences, isNotEmpty);
      expect(entry.tacticalGoldenPhrase, contains('對方駕駛您好'));
      expect(entry.logs.first.tag, 'AI 診斷');
    });

    testWidgets('JournalPage mounts AssistantPromptBubble and allows tab switching',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
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
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, _) => PreambleScope(
            state: appState,
            child: const MaterialApp(
              home: JournalPage(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 1. Verify AssistantPromptBubble is present
      expect(find.byType(AssistantPromptBubble), findsOneWidget);
      expect(find.text('小法助實務熱問'), findsOneWidget);

      // 2. Verify Tab Selector is present
      expect(find.text('公共法治策展'), findsOneWidget);
      expect(find.text('個人自救案件夾'), findsOneWidget);

      // Default tab (0: 公共法治策展) shows discussions
      expect(find.text('大家都在討論'), findsOneWidget);

      // 3. Switch to Tab 1: 個人自救案件夾
      await tester.tap(find.text('個人自救案件夾'));
      await tester.pumpAndSettle();

      // Verify UserCaseJournalSection is shown
      expect(find.byType(UserCaseJournalSection), findsOneWidget);
      expect(find.text('問診建檔'), findsOneWidget);
      expect(find.text('租賃住宅退租押金返還請求案'), findsOneWidget);
      expect(find.text('相對人：房東'), findsOneWidget);
      expect(find.text('32,000元'), findsOneWidget);
      expect(find.text('建議交涉應對金句'), findsOneWidget);

      // 4. Switch back to Tab 0: 公共法治策展
      await tester.tap(find.text('公共法治策展'));
      await tester.pumpAndSettle();
      expect(find.text('大家都在討論'), findsOneWidget);
    });

    testWidgets('DiscussionDetailPage renders AI Legal Insight Card',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.devicePixelRatio = 3.0;
      tester.view.physicalSize = const Size(1179, 2556);
      addTearDown(() {
        tester.view.resetDevicePixelRatio();
        tester.view.resetPhysicalSize();
      });

      final appState = PreambleState();
      addTearDown(appState.dispose);
      await appState.load();

      final firstTopic = homeDiscussionFeed.topics.first;
      final trendItem = discussionTrendItems.first;

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, _) => PreambleScope(
            state: appState,
            child: MaterialApp(
              home: Builder(
                builder: (context) {
                  final palette = JournalPalette.of(context);
                  return DiscussionDetailPage(
                    item: trendItem,
                    palette: palette,
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify AI Legal Perspective Card
      expect(find.text('小法助法律焦點透視'), findsOneWidget);
      expect(find.text('AI 即時法理涵攝'), findsOneWidget);
      expect(find.text('向小法助詢問此議題 / 若我遇到如何自保？'), findsOneWidget);
    });
  });
}
