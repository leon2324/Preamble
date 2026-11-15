import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:preamble/app/app_state.dart';
import 'package:preamble/components/home/home_news_section.dart';
import 'package:preamble/components/home/v2/home_v2_bento_cards.dart';
import 'package:preamble/components/home/v2/home_v2_dashboard_dock.dart';
import 'package:preamble/components/home/v2/home_v2_newsletter_cards.dart';
import 'package:preamble/components/home/v2/home_v2_social_news_section.dart';
import 'package:preamble/data/mock_data/home/legacy/home_mock_data_legacy.dart';
import 'package:preamble/pages/home/home_page.dart';
import 'package:preamble/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/responsive_error_collector.dart';

void main() {
  const scenarios = <_CardScenario>[
    _CardScenario('compact 140%', Size(320, 568), 1.4),
    _CardScenario('phone 200%', Size(393, 852), 2),
    _CardScenario('landscape 140%', Size(852, 393), 1.4),
  ];

  group('Home V2 cards large-text layout', () {
    for (final scenario in scenarios) {
      testWidgets('Quick Ask stays inside its section at ${scenario.name}',
          (tester) async {
        final collector = ResponsiveErrorCollector()..install();
        try {
          await _pumpCard(
            tester,
            scenario: scenario,
            child: const HomeV2QuickAskSection(),
          );
          _expectWithinViewport(
            tester,
            section: find.byType(HomeV2QuickAskSection),
            primary: find.byType(TextField),
          );
        } finally {
          collector.captureTesterException(tester);
          collector.restore();
        }

        expect(
          collector.layoutFailures,
          isEmpty,
          reason: _failureReason('Quick Ask', scenario, collector),
        );
      });

      testWidgets('Watchlist stays inside its card at ${scenario.name}',
          (tester) async {
        final collector = ResponsiveErrorCollector()..install();
        try {
          await _pumpCard(
            tester,
            scenario: scenario,
            child: const HomeV2WatchlistCard(),
          );
          _expectWithinViewport(
            tester,
            section: find.byType(HomeV2WatchlistCard),
            primary: find.text('管理關注'),
          );
        } finally {
          collector.captureTesterException(tester);
          collector.restore();
        }

        expect(
          collector.layoutFailures,
          isEmpty,
          reason: _failureReason('Watchlist', scenario, collector),
        );
      });

      testWidgets('Tools drawer stays usable at ${scenario.name}',
          (tester) async {
        final collector = ResponsiveErrorCollector()..install();
        try {
          await _pumpCard(
            tester,
            scenario: scenario,
            child: HomeV2ToolsDrawer(
              onNavigateToTab: (_, {int? subTabIndex, String? toolTab}) {},
            ),
          );
          _expectWithinViewport(
            tester,
            section: find.byType(HomeV2ToolsDrawer),
            primary: find.text('押金返還通知'),
          );
        } finally {
          collector.captureTesterException(tester);
          collector.restore();
        }

        expect(
          collector.layoutFailures,
          isEmpty,
          reason: _failureReason('Tools drawer', scenario, collector),
        );
      });

      testWidgets(
          'daily cards keep both primary actions reachable at ${scenario.name}',
          (tester) async {
        final collector = ResponsiveErrorCollector()..install();
        try {
          await _pumpCard(
            tester,
            scenario: scenario,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: scenario.size.width < 360 ? 174.h : 158.h,
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Expanded(child: HomeV2DailyCaseStoryCard()),
                    SizedBox(width: 12.w),
                    const Expanded(child: HomeV2AchievementCard()),
                  ],
                ),
              ),
            ),
          );
          for (final item in [
            (
              find.text('看 AI 白話解說'),
              find.byType(HomeV2DailyCaseStoryCard),
            ),
            (
              find.text('挑戰今日測驗'),
              find.byType(HomeV2AchievementCard),
            ),
          ]) {
            await tester.ensureVisible(item.$1);
            await tester.pump();
            _expectWithinViewport(
              tester,
              section: item.$2,
              primary: item.$1,
            );
          }
        } finally {
          collector.captureTesterException(tester);
          collector.restore();
        }

        expect(
          collector.layoutFailures,
          isEmpty,
          reason: _failureReason('Daily cards', scenario, collector),
        );
      });
    }
  });

  group('Home V2 residual RSA-002 regression coverage', () {
    const compactLarge = _CardScenario('compact 140%', Size(320, 568), 1.4);
    const phoneLarge = _CardScenario('phone 200%', Size(393, 852), 2);
    const landscapeLarge = _CardScenario('landscape 140%', Size(852, 393), 1.4);

    testWidgets('newsletter focus carousel grows for its content',
        (tester) async {
      final collector = ResponsiveErrorCollector()..install();
      try {
        await _pumpCard(
          tester,
          scenario: landscapeLarge,
          child: HomeV2NewsletterFocusCarousel(items: homeNewsletterItems),
        );
        _expectWithinViewport(
          tester,
          section: find.byType(HomeV2NewsletterFocusCarousel),
          primary: find.text(homeNewsletterItems.first.title),
        );
      } finally {
        collector.captureTesterException(tester);
        collector.restore();
      }
      expect(collector.layoutFailures, isEmpty,
          reason:
              _failureReason('Newsletter focus', landscapeLarge, collector));
    });

    testWidgets('news cards reserve their measured title height',
        (tester) async {
      final collector = ResponsiveErrorCollector()..install();
      try {
        await _pumpCard(
          tester,
          scenario: compactLarge,
          child: const HomeNewsSection(items: homeNewsItems, showHeader: false),
        );
      } finally {
        collector.captureTesterException(tester);
        collector.restore();
      }
      expect(collector.layoutFailures, isEmpty,
          reason: _failureReason('News cards', compactLarge, collector));
    });

    testWidgets('social header reflows without hiding its action',
        (tester) async {
      final collector = ResponsiveErrorCollector()..install();
      try {
        await _pumpCard(
          tester,
          scenario: phoneLarge,
          child: HomeV2SocialNewsSection(
            newsItems: homeNewsItems,
            discussionFeed: homeDiscussionFeed,
            onMoreNewsTap: () {},
          ),
        );
        _expectWithinViewport(
          tester,
          section: find.byType(HomeV2SocialNewsSection),
          primary: find.text('看全部'),
        );
      } finally {
        collector.captureTesterException(tester);
        collector.restore();
      }
      expect(collector.layoutFailures, isEmpty,
          reason: _failureReason('Social header', phoneLarge, collector));
    });

    testWidgets('real Quick Ask input and submit action are reachable',
        (tester) async {
      await _pumpCard(
        tester,
        scenario: landscapeLarge,
        child: HomePage(
          onNavigateToTab: (_, {int? subTabIndex, String? toolTab}) {},
        ),
        wrapInScrollView: false,
      );
      final section = find.byType(HomeDashboardDock);
      await tester.ensureVisible(section);
      await tester.pump();
      final input =
          find.descendant(of: section, matching: find.byType(TextField));
      expect(input, findsOneWidget);
      await tester.enterText(input, '測試法律問題');
      await tester.pump();
      final submit = find.descendant(
        of: section,
        matching: find.text('問診'),
      );
      expect(submit, findsOneWidget);
      expect(tester.getRect(input).overlaps(Offset.zero & landscapeLarge.size),
          isTrue);
      expect(tester.getRect(submit).overlaps(Offset.zero & landscapeLarge.size),
          isTrue);
      expect(submit.hitTestable(), findsOneWidget);
    });
  });
}

Future<void> _pumpCard(
  WidgetTester tester, {
  required _CardScenario scenario,
  required Widget child,
  bool wrapInScrollView = true,
}) async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = scenario.size;
  addTearDown(() {
    tester.view.resetDevicePixelRatio();
    tester.view.resetPhysicalSize();
  });

  final appState = PreambleState();
  addTearDown(appState.dispose);
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
          state: appState,
          child: MaterialApp(
            theme: AppTheme.light(),
            home: Scaffold(
              body: wrapInScrollView
                  ? SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: child,
                      ),
                    )
                  : child,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 500));
}

void _expectWithinViewport(
  WidgetTester tester, {
  required Finder section,
  required Finder primary,
}) {
  final viewport = Offset.zero & tester.view.physicalSize;
  final sectionRect = tester.getRect(section);
  final primaryRect = tester.getRect(primary);

  expect(sectionRect.width, greaterThan(0));
  expect(primaryRect.width, greaterThan(0));
  expect(sectionRect.contains(primaryRect.topLeft), isTrue);
  expect(sectionRect.contains(primaryRect.bottomRight), isTrue);
  expect(primaryRect.overlaps(viewport), isTrue);
  expect(primary.hitTestable(), findsOneWidget);
}

String _failureReason(
  String component,
  _CardScenario scenario,
  ResponsiveErrorCollector collector,
) {
  return '$component at ${scenario.name}: '
      '${collector.layoutFailures.map((failure) => failure.message).join('\n')}';
}

class _CardScenario {
  const _CardScenario(this.name, this.size, this.textScale);

  final String name;
  final Size size;
  final double textScale;
}
