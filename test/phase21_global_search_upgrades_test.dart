import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:preamble/app/app_state.dart';
import 'package:preamble/data/journal/user_case_journal_repository.dart';
import 'package:preamble/data/search/search_repository.dart';
import 'package:preamble/data/statutes/statute_api_service.dart';
import 'package:preamble/data/statutes/statute_item.dart';
import 'package:preamble/data/statutes/statute_repository.dart';
import 'package:preamble/pages/search/global_search_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeStatuteApiService extends StatuteApiService {
  @override
  Future<List<StatuteItem>> fetchChineseLawItems() async => const [];

  @override
  void dispose() {}
}

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
    UserCaseJournalRepository.resetInstanceForTesting();
  });

  tearDown(() {
    UserCaseJournalRepository.resetInstanceForTesting();
  });

  SearchRepository createTestSearchRepo() {
    return SearchRepository(
      statuteRepository: StatuteRepository(
        apiService: _FakeStatuteApiService(),
      ),
    );
  }

  Widget createSearchTestWidget(PreambleState appState, SearchRepository searchRepo) {
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, _) => PreambleScope(
        state: appState,
        child: MaterialApp(
          home: Scaffold(
            body: GlobalSearchPage(searchRepository: searchRepo),
          ),
        ),
      ),
    );
  }

  testWidgets(
      'GlobalSearchPage searching "押金不退" shows AI instant defense, tactical phrase, and saves to journal',
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

    final searchRepo = createTestSearchRepo();
    addTearDown(searchRepo.dispose);

    await tester.pumpWidget(createSearchTestWidget(appState, searchRepo));
    await tester.pumpForVerification();

    // 1. Verify Home search inspirations contain rental and severance
    expect(find.text('🔥 法律探索靈感'), findsOneWidget);
    expect(find.text('租屋押金扣款'), findsOneWidget);
    expect(find.text('公司無預警資遣'), findsOneWidget);

    // 2. Enter "押金不退" into search field and submit
    final searchInput = find.byType(TextField);
    expect(searchInput, findsOneWidget);
    await tester.enterText(searchInput, '押金不退');
    await tester.testTextInput.receiveAction(TextInputAction.search);

    // Wait for async search and AI overview generation (300ms)
    await tester.pumpForVerification(const Duration(milliseconds: 600));

    // 3. Verify AI Instant Defense module renders
    expect(find.text('小法助即時解方'), findsOneWidget);
    expect(find.text('租賃住宅與不動產點交爭議'), findsOneWidget);
    expect(find.text('談判自保防禦金句'), findsOneWidget);
    expect(find.text('📁 建立「自救記事」進度追蹤'), findsOneWidget);

    // 4. Tap "📁 建立「自救記事」進度追蹤"
    final saveButton = find.text('📁 建立「自救記事」進度追蹤');
    expect(saveButton, findsOneWidget);
    await tester.tap(saveButton);
    await tester.pumpForVerification();
    // Allow CustomToast 1.5s timer to complete
    await tester.pump(const Duration(milliseconds: 1600));

    // 5. Verify UserCaseJournalRepository has the newly added rental dispute
    final repo = UserCaseJournalRepository();
    expect(repo.entries.any((e) => e.title.contains('租賃住宅')), isTrue);
  });

  testWidgets(
      'GlobalSearchPage searching "被資遣" shows labor defense insight, deadline, and creates case',
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

    final searchRepo = createTestSearchRepo();
    addTearDown(searchRepo.dispose);

    await tester.pumpWidget(createSearchTestWidget(appState, searchRepo));
    await tester.pumpForVerification();

    // 1. Enter "被資遣" and submit
    final searchInput = find.byType(TextField);
    await tester.enterText(searchInput, '被資遣');
    await tester.testTextInput.receiveAction(TextInputAction.search);

    // Wait for AI overview generation
    await tester.pumpForVerification(const Duration(milliseconds: 600));

    // 2. Verify labor dispute defense insight
    expect(find.text('小法助即時解方'), findsOneWidget);
    expect(find.text('勞資爭議、加班費與資遣解僱'), findsOneWidget);
    expect(find.text('談判自保防禦金句'), findsOneWidget);
    expect(find.textContaining('非自願離職證明書'), findsWidgets);

    // 3. Tap "📁 建立「自救記事」進度追蹤"
    final saveButton = find.text('📁 建立「自救記事」進度追蹤');
    await tester.tap(saveButton);
    await tester.pumpForVerification();
    // Allow CustomToast 1.5s timer to complete
    await tester.pump(const Duration(milliseconds: 1600));

    // 4. Verify UserCaseJournalRepository contains severance case
    final repo = UserCaseJournalRepository();
    expect(repo.entries.any((e) => e.title.contains('勞資爭議')), isTrue);
    final severanceCase =
        repo.entries.firstWhere((e) => e.title.contains('勞資爭議'));
    expect(severanceCase.counterparty, '公司主管/人資');
    expect(severanceCase.evidences.isNotEmpty, isTrue);
  });
}
