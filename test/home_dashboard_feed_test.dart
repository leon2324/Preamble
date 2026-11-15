import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:preamble/app/app_state.dart';
import 'package:preamble/components/home/v2/home_v2_dashboard_dock.dart';
import 'package:preamble/components/home/v2/home_v2_feed_stream.dart';
import 'package:preamble/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/responsive_error_collector.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('HomeDashboardDock 1+2 Hybrid tests', () {
    testWidgets(
        'renders editorial masthead, progressive command bar, legal radar sheet, and 4 action tiles',
        (tester) async {
      var profileTapped = false;
      var notificationTapped = false;
      var scanTapped = false;
      String? submittedPrompt;
      String? metricTapped;
      String? toolTapped;

      await _pumpTestWidget(
        tester,
        child: HomeDashboardDock(
          onProfileTap: () => profileTapped = true,
          onNotificationTap: () => notificationTapped = true,
          onSearchOrAiTap: () {},
          onSubmitPrompt: (prompt) => submittedPrompt = prompt,
          onScanDocumentTap: () => scanTapped = true,
          onMetricTap: (metric) => metricTapped = metric,
          onToolTap: (tool) => toolTapped = tool,
        ),
      );

      // 驗證親切問候刊頭與生活小幫手文案
      expect(find.text('緒言 Preamble'), findsOneWidget);
      expect(find.text('嗨！遇到什麼困擾嗎？'), findsOneWidget);
      expect(find.text('儀表板資訊流'), findsNothing);

      // 驗證小法助問問框與公文解讀按鈕
      expect(find.text('問問小法助，或貼上看不懂的訊息...'), findsOneWidget);
      expect(find.text('公文解讀'), findsOneWidget);

      // 驗證四大生活情境粉彩大按鈕
      expect(find.text('租屋大小事'), findsOneWidget);
      expect(find.text('職場與薪資'), findsOneWidget);
      expect(find.text('網購與消費'), findsOneWidget);
      expect(find.text('車禍與賠償'), findsOneWidget);

      // 驗證 4 枚粉彩圓圈常用小工具
      expect(find.text('存證信函'), findsOneWidget);
      expect(find.text('契約審查'), findsOneWidget);
      expect(find.text('六法文庫'), findsOneWidget);
      expect(find.text('實戰工具'), findsOneWidget);

      // 測試通知與個人頭像點擊
      await tester.tap(find.byIcon(PhosphorIconsRegular.bell));
      await tester.pump();
      expect(notificationTapped, isTrue);

      await tester.tap(find.text('訪'));
      await tester.pump();
      expect(profileTapped, isTrue);

      // 測試公文解讀點擊
      await tester.tap(find.text('公文解讀'));
      await tester.pump();
      expect(scanTapped, isTrue);

      // 點擊輸入框展開漸進式情境膠囊，並點選情境直接送出
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      expect(find.text('退租押金不退'), findsOneWidget);
      await tester.tap(find.text('退租押金不退'));
      await tester.pumpAndSettle();
      expect(submittedPrompt, contains('押金'));

      // 點擊「提醒 1」微膠囊開啟小提醒 BottomSheet 並驗證回呼
      await tester.tap(find.text('提醒 1'));
      await tester.pumpAndSettle();
      expect(find.text('我的權益小提醒 🌱'), findsOneWidget);
      await tester.ensureVisible(find.text('進行中的生活案件'));
      await tester.tap(find.text('進行中的生活案件'));
      await tester.pumpAndSettle();
      expect(metricTapped, equals('cases'));

      // 測試 4 枚工具圓圈回呼
      await tester.tap(find.text('存證信函'));
      await tester.pump();
      expect(toolTapped, equals('notice'));

      await tester.tap(find.text('六法文庫'));
      await tester.pump();
      expect(toolTapped, equals('database'));

      await tester.tap(find.text('實戰工具'));
      await tester.pump();
      expect(toolTapped, equals('all_tools'));
    });
  });

  group('HomeFeedStreamView Friendly Pastel tests', () {
    testWidgets(
        'renders pastel featured card, friendly filter pills, 4 card types, direct stance vote, and real bookmarking',
        (tester) async {
      String? caseNavigated;
      final appState = PreambleState();
      addTearDown(appState.dispose);

      await _pumpTestWidget(
        tester,
        appState: appState,
        child: HomeFeedStreamView(
          onNavigateToCase: (id) => caseNavigated = id,
          onNavigateToOfficialNews: () {},
          onNavigateToTipDetail: (_) {},
          onNavigateToStatuteDatabase: () {},
          onNavigateToDiscussion: () {},
        ),
      );

      // 驗證今日生活話題粉彩卡片
      expect(find.text('今日生活話題 💡'), findsOneWidget);
      expect(find.textContaining('跑外送算員工還是自己接案'), findsOneWidget);

      // 驗證白話分類標籤
      expect(find.text('全部'), findsOneWidget);
      expect(find.text('生活案例'), findsWidgets);
      expect(find.text('大家怎麼看'), findsWidgets);
      expect(find.text('新規定'), findsWidgets);
      expect(find.text('避坑指南'), findsWidgets);

      // 切換至「生活案例」篩選
      await tester.tap(find.text('生活案例').first);
      await tester.pumpAndSettle();
      expect(find.textContaining('長榮張榮發遺囑效力定讞解析'), findsOneWidget);
      expect(find.textContaining('數位平台外送員應定性為'), findsNothing);

      // 點擊案例標題進入詳情
      final changCaseTitle = find.textContaining('長榮張榮發遺囑效力定讞解析');
      await tester.ensureVisible(changCaseTitle);
      await tester.tap(changCaseTitle);
      await tester.pump();
      expect(caseNavigated, equals('case-chang-will-1764'));

      // 切換至「大家怎麼看」並測試一體式立場卡直接點擊表態
      final debateFilter = find.text('大家怎麼看').first;
      await tester.ensureVisible(debateFilter);
      await tester.tap(debateFilter);
      await tester.pumpAndSettle();

      expect(find.text('認定僱傭關係'), findsOneWidget);
      await tester.ensureVisible(find.text('認定僱傭關係'));
      await tester.tap(find.text('認定僱傭關係'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('已計入您的法理表態'), findsOneWidget);
    });
  });

  group('Dashboard & Dual-Coding Feed responsive layout tests (Light & Dark)',
      () {
    const scenarios = [
      _Scenario('compact 140%', Size(320, 568), 1.4),
      _Scenario('phone 200%', Size(393, 852), 2.0),
      _Scenario('landscape 140%', Size(852, 393), 1.4),
    ];

    for (final isDark in [false, true]) {
      for (final scenario in scenarios) {
        testWidgets(
            'Dock & Feed do not overflow at ${scenario.name} (dark=$isDark)',
            (tester) async {
          final collector = ResponsiveErrorCollector()..install();
          try {
            await _pumpTestWidget(
              tester,
              scenario: scenario,
              isDark: isDark,
              child: Column(
                children: [
                  HomeDashboardDock(
                    onProfileTap: () {},
                    onNotificationTap: () {},
                    onSearchOrAiTap: () {},
                    onMetricTap: (_) {},
                    onToolTap: (_) {},
                  ),
                  const SizedBox(height: 16),
                  HomeFeedStreamView(
                    onNavigateToCase: (_) {},
                    onNavigateToOfficialNews: () {},
                    onNavigateToTipDetail: (_) {},
                    onNavigateToStatuteDatabase: () {},
                    onNavigateToDiscussion: () {},
                  ),
                ],
              ),
            );
          } finally {
            collector.captureTesterException(tester);
            collector.restore();
          }

          expect(
            collector.layoutFailures,
            isEmpty,
            reason:
                'Layout failure in scenario ${scenario.name} (dark=$isDark): '
                '${collector.layoutFailures.map((e) => "${e.message} [sig: ${e.layoutSignature?.description}]").join('\n')}',
          );
        });
      }
    }
  });
}

class _Scenario {
  const _Scenario(this.name, this.size, this.textScale);

  final String name;
  final Size size;
  final double textScale;
}

Future<void> _pumpTestWidget(
  WidgetTester tester, {
  required Widget child,
  PreambleState? appState,
  bool isDark = false,
  _Scenario scenario = const _Scenario('default', Size(375, 812), 1.0),
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = scenario.size;
  addTearDown(() {
    tester.view.resetDevicePixelRatio();
    tester.view.resetPhysicalSize();
  });

  final state = appState ?? PreambleState();
  if (appState == null) {
    addTearDown(state.dispose);
  }

  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(
        size: scenario.size,
        textScaler: TextScaler.linear(scenario.textScale),
      ),
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, __) => PreambleScope(
          state: state,
          child: MaterialApp(
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
            home: Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 300));
}
