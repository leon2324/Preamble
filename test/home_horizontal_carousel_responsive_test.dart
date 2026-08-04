import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:preamble/components/home/home_news_section.dart';
import 'package:preamble/components/home/v2/home_v2_header.dart';
import 'package:preamble/components/home/v2/home_v2_newsletter_cards.dart';
import 'package:preamble/data/mock_data/home/legacy/home_mock_data_legacy.dart';
import 'package:preamble/data/mock_data/home/home_v2_mock_data.dart';
import 'package:preamble/theme/app_theme.dart';

import 'support/responsive_error_collector.dart';

/// 水平探索首頁區塊的 responsive 守門。
///
/// 台灣繁體中文教學註解：這份測試不只確認沒有 overflow；它也確認極大字體
/// 下仍保有 PageView、下一張預覽與可拖曳行為，避免日後又退化成垂直長列表。
void main() {
  const scenarios = <_Scenario>[
    _Scenario(Size(393, 852), 1),
    _Scenario(Size(393, 852), 2),
    _Scenario(Size(393, 852), 2.35),
    _Scenario(Size(393, 852), 3),
    _Scenario(Size(320, 568), 2.35),
    _Scenario(Size(320, 568), 3),
    _Scenario(Size(852, 393), 2.35),
  ];

  for (final scenario in scenarios) {
    testWidgets('newsletter stays horizontally pageable at $scenario',
        (tester) async {
      final collector = ResponsiveErrorCollector()..install();
      var tapped = false;
      try {
        await _pump(
          tester,
          scenario,
          child: HomeV2NewsletterFocusCarousel(
            items: homeNewsletterItems,
            onItemTap: (_) => tapped = true,
          ),
        );
        final newsletterPager =
            find.byKey(const ValueKey('newsletter-focus-horizontal-pager'));
        expect(newsletterPager, findsOneWidget);
        expect(find.byType(PageView), findsOneWidget);
        final firstNewsletterCard =
            find.byType(HomeV2NewsletterFocusCard).first;
        expect(
          tester.getRect(firstNewsletterCard).right,
          lessThan(tester.getRect(newsletterPager).right),
        );
        final newsletterTitle = find.text(homeNewsletterItems.first.title);
        expect(newsletterTitle, findsOneWidget);
        expect(
          tester.getRect(newsletterTitle).bottom,
          lessThanOrEqualTo(tester.getRect(firstNewsletterCard).bottom),
        );
        await tester.ensureVisible(firstNewsletterCard);
        final newsletterCardRect = tester.getRect(firstNewsletterCard);
        await tester.tapAt(Offset(
          newsletterCardRect.left + 16,
          (newsletterCardRect.top + 16)
              .clamp(1, scenario.size.height - 1)
              .toDouble(),
        ));
        expect(tapped, isTrue);

        await tester.ensureVisible(newsletterPager);
        await tester.pump();
        final newsletterScrollable = find.descendant(
          of: newsletterPager,
          matching: find.byType(Scrollable),
        );
        final before =
            tester.state<ScrollableState>(newsletterScrollable).position.pixels;
        final newsletterRect = tester.getRect(newsletterPager);
        await tester.flingFrom(
          Offset(newsletterRect.center.dx, newsletterRect.top + 16),
          const Offset(-500, 0),
          1200,
        );
        await tester.pumpAndSettle();
        expect(
          tester.state<ScrollableState>(newsletterScrollable).position.pixels,
          greaterThan(before),
        );
      } finally {
        collector.captureTesterException(tester);
        collector.restore();
      }
      expect(
        collector.layoutFailures,
        isEmpty,
        reason: collector.layoutFailures
            .map((failure) => failure.message)
            .join('\n'),
      );
    });

    testWidgets('news stays horizontally pageable at $scenario',
        (tester) async {
      final collector = ResponsiveErrorCollector()..install();
      var tapped = false;
      try {
        await _pump(
          tester,
          scenario,
          child: HomeNewsSection(
            items: homeNewsItems,
            showHeader: false,
            onItemTap: (_) => tapped = true,
          ),
        );
        final newsPager =
            find.byKey(const ValueKey('home-news-horizontal-pager'));
        expect(newsPager, findsOneWidget);
        expect(find.byType(PageView), findsOneWidget);

        final newsViewport = tester.getRect(newsPager);
        final firstNewsTitle = find.text(homeNewsItems.first.title);
        expect(firstNewsTitle, findsOneWidget);
        expect(
          tester.getRect(firstNewsTitle).right,
          lessThan(newsViewport.right),
        );
        await tester.ensureVisible(firstNewsTitle);
        final newsTitleRect = tester.getRect(firstNewsTitle);
        await tester.tapAt(Offset(
          newsTitleRect.left + 4,
          newsTitleRect.top.clamp(1, scenario.size.height - 1).toDouble(),
        ));
        expect(tapped, isTrue);
        expect(find.text(homeNewsItems[1].title), findsWidgets);

        await tester.ensureVisible(newsPager);
        await tester.pump();
        final newsScrollable = find.descendant(
          of: newsPager,
          matching: find.byType(Scrollable),
        );
        final before =
            tester.state<ScrollableState>(newsScrollable).position.pixels;
        final newsRect = tester.getRect(newsPager);
        await tester.flingFrom(
          Offset(newsRect.center.dx, newsRect.top + 16),
          const Offset(-500, 0),
          1200,
        );
        await tester.pumpAndSettle();
        expect(
          tester.state<ScrollableState>(newsScrollable).position.pixels,
          greaterThan(before),
        );
      } finally {
        collector.captureTesterException(tester);
        collector.restore();
      }
      expect(
        collector.layoutFailures,
        isEmpty,
        reason: collector.layoutFailures
            .map((failure) => failure.message)
            .join('\n'),
      );
    });
  }

  testWidgets('header keeps the complete wordmark at 300%', (tester) async {
    final collector = ResponsiveErrorCollector()..install();
    try {
      await _pump(
        tester,
        const _Scenario(Size(320, 568), 3),
        child: const HomeV2HeroHeader(
          onProfileTap: _noop,
          onNotificationTap: _noop,
          onTickerTap: _noopTicker,
        ),
      );
      expect(find.bySemanticsLabel('Preamble 緒言'), findsOneWidget);
      expect(find.text(homeV2TickerItems.first.title), findsOneWidget);
      expect(
        find.byIcon(Icons.notifications_none_rounded).hitTestable(),
        findsOneWidget,
      );
    } finally {
      collector.captureTesterException(tester);
      collector.restore();
    }
    expect(collector.layoutFailures, isEmpty);
  });
}

void _noop() {}
void _noopTicker(dynamic _) {}

Future<void> _pump(
  WidgetTester tester,
  _Scenario scenario, {
  Widget? child,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = scenario.size;
  addTearDown(() {
    tester.view.resetDevicePixelRatio();
    tester.view.resetPhysicalSize();
  });
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(
        size: scenario.size,
        textScaler: TextScaler.linear(scenario.scale),
      ),
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, __) => MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: child ??
                    Column(
                      children: [
                        HomeV2NewsletterFocusCarousel(
                          items: homeNewsletterItems,
                        ),
                        SizedBox(height: 24),
                        HomeNewsSection(items: homeNewsItems),
                      ],
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

class _Scenario {
  const _Scenario(this.size, this.scale);

  final Size size;
  final double scale;

  @override
  String toString() => '${size.width}x${size.height}/$scale';
}
