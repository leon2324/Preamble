import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:preamble/components/navigation/app_shell_content_insets.dart';
import 'package:preamble/components/navigation/island_bottom_nav.dart';

void main() {
  const items = [
    BottomNavItemData(
      label: '首頁',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
    ),
    BottomNavItemData(
      label: '學習',
      icon: Icons.menu_book_outlined,
      selectedIcon: Icons.menu_book_rounded,
    ),
    BottomNavItemData(
      label: '小法助',
      icon: Icons.support_agent_outlined,
      selectedIcon: Icons.support_agent_rounded,
    ),
    BottomNavItemData(
      label: '紀事',
      icon: Icons.inventory_2_outlined,
      selectedIcon: Icons.inventory_2_rounded,
    ),
    BottomNavItemData(
      label: '我的',
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
    ),
  ];

  Future<void> pumpShell(
    WidgetTester tester, {
    required Size size,
    required double textScale,
    required bool reserveDynamicGrowth,
    bool simulateLegacyA2BackgroundShrink = false,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: size,
            padding: const EdgeInsets.only(top: 59, bottom: 34),
            textScaler: TextScaler.linear(textScale),
          ),
          child: Scaffold(
            body: LayoutBuilder(
              builder: (context, constraints) {
                final metrics = IslandBottomNavLayoutMetrics.compute(
                  context,
                  availableWidth: constraints.maxWidth - 24,
                  items: items,
                  showLabels: true,
                  bottomOffset: 17,
                );
                final reservation = reserveDynamicGrowth
                    ? metrics.additionalBodyReservation
                    : 0.0;
                final existingFootprint = metrics.minimumNavShellHeight +
                    metrics.safeBottom +
                    metrics.bottomOffset;

                return Stack(
                  children: [
                    if (simulateLegacyA2BackgroundShrink)
                      // 台灣繁體中文教學註解：舊 A2 將整個 Tab layer
                      // 放在 bottom reservation 之上，因此連背景也會被截短。
                      Positioned(
                        left: 0,
                        top: 0,
                        right: 0,
                        bottom: reservation,
                        child: const ColoredBox(
                          key: Key('shell-body'),
                          color: Colors.white,
                        ),
                      )
                    else
                      Positioned.fill(
                        child: AppShellContentInsets(
                          additionalBottom: reservation,
                          child: Stack(
                            children: [
                              const Positioned.fill(
                                child: ColoredBox(
                                  key: Key('shell-body'),
                                  color: Colors.white,
                                ),
                              ),
                              // 台灣繁體中文教學註解：內容只讀取共用
                              // Dynamic Type 增量；背景仍由 Positioned.fill
                              // 取得完整螢幕範圍。
                              Builder(
                                builder: (context) => Positioned(
                                  left: 16,
                                  right: 16,
                                  bottom: existingFootprint +
                                      AppShellContentInsets.additionalBottomOf(
                                        context,
                                      ),
                                  height: 40,
                                  child: const ColoredBox(
                                    key: Key('bottom-sentinel'),
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 17,
                      child: SafeArea(
                        top: false,
                        child: IslandBottomNav(
                          selectedIndex: 0,
                          items: items,
                          showLabels: true,
                          layoutMetrics: metrics,
                          onTap: (_) {},
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  for (final scenario in [
    (const Size(393, 852), 1.6),
    (const Size(393, 852), 2.0),
    (const Size(393, 852), 2.35),
    (const Size(320, 568), 3.0),
  ]) {
    testWidgets(
        'old A2 reservation shortens the tab background at ${scenario.$1} / ${scenario.$2}',
        (tester) async {
      await pumpShell(
        tester,
        size: scenario.$1,
        textScale: scenario.$2,
        reserveDynamicGrowth: true,
        simulateLegacyA2BackgroundShrink: true,
      );

      final bodyRect = tester.getRect(find.byKey(const Key('shell-body')));
      final nav = tester.widget<IslandBottomNav>(find.byType(IslandBottomNav));
      final reservation = nav.layoutMetrics!.additionalBodyReservation;

      expect(reservation, greaterThan(0));
      expect(bodyRect.bottom, closeTo(scenario.$1.height - reservation, 0.01));
      expect(tester.takeException(), isNull);
    });
  }

  for (final scenario in [
    (const Size(393, 852), 1.6),
    (const Size(393, 852), 2.0),
    (const Size(393, 852), 2.35),
    (const Size(320, 568), 3.0),
  ]) {
    testWidgets(
        'legacy stack shell overlaps bottom content at ${scenario.$1} / ${scenario.$2}',
        (tester) async {
      await pumpShell(
        tester,
        size: scenario.$1,
        textScale: scenario.$2,
        reserveDynamicGrowth: false,
      );

      final bodyRect = tester.getRect(find.byKey(const Key('shell-body')));
      final navRect = tester.getRect(find.byType(IslandBottomNav));
      final sentinelRect =
          tester.getRect(find.byKey(const Key('bottom-sentinel')));

      expect(bodyRect.height, greaterThan(0));
      expect(navRect.overlaps(sentinelRect), isTrue);
      expect(tester.takeException(), isNull);
    });
  }

  for (final scenario in [
    (const Size(393, 852), 1.0),
    (const Size(393, 852), 1.4),
    (const Size(393, 852), 1.6),
    (const Size(393, 852), 2.0),
    (const Size(393, 852), 2.35),
    (const Size(320, 568), 3.0),
  ]) {
    testWidgets(
        'shared shell reservation keeps bottom content reachable at ${scenario.$1} / ${scenario.$2}',
        (tester) async {
      await pumpShell(
        tester,
        size: scenario.$1,
        textScale: scenario.$2,
        reserveDynamicGrowth: true,
      );

      final bodyRect = tester.getRect(find.byKey(const Key('shell-body')));
      final navRect = tester.getRect(find.byType(IslandBottomNav));
      final sentinelRect =
          tester.getRect(find.byKey(const Key('bottom-sentinel')));
      final nav = tester.widget<IslandBottomNav>(find.byType(IslandBottomNav));
      final metrics = nav.layoutMetrics!;

      expect(bodyRect.height, greaterThan(0));
      expect(
        bodyRect.bottom,
        closeTo(scenario.$1.height, 0.01),
      );
      expect(navRect.overlaps(sentinelRect), isFalse);
      expect(tester.takeException(), isNull);
    });
  }
}
