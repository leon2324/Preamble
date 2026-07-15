import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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

  Future<void> pumpNav(
    WidgetTester tester, {
    required Size size,
    required double textScale,
    required ValueChanged<int> onTap,
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
            padding: const EdgeInsets.only(bottom: 34),
            textScaler: TextScaler.linear(textScale),
          ),
          child: Scaffold(
            body: Stack(
              children: [
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 17,
                  child: SafeArea(
                    top: false,
                    child: IslandBottomNav(
                      selectedIndex: 0,
                      items: items,
                      onTap: onTap,
                      showLabels: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  void expectAllItemsVisible() {
    for (final item in items) {
      expect(find.text(item.label), findsOneWidget);
    }
  }

  Future<void> expectAllItemsUsable(WidgetTester tester) async {
    for (final item in items) {
      final label = find.text(item.label);
      expect(label.hitTestable(), findsOneWidget);
      final text = tester.widget<Text>(label);
      expect(text.overflow, isNull);
      await tester.tap(label);
      await tester.pump();
    }
  }

  testWidgets('393pt at normal text keeps every island navigation item visible',
      (tester) async {
    await pumpNav(
      tester,
      size: const Size(393, 852),
      textScale: 1,
      onTap: (_) {},
    );

    expectAllItemsVisible();
    expect(tester.getSize(find.byType(IslandBottomNav)).height, lessThan(80));
    expect(tester.takeException(), isNull);
  });

  testWidgets('393pt at 120 percent has no island navigation overflow',
      (tester) async {
    final tapped = <int>[];
    await pumpNav(
      tester,
      size: const Size(393, 852),
      textScale: 1.2,
      onTap: tapped.add,
    );

    expectAllItemsVisible();
    for (var index = 0; index < items.length; index++) {
      await tester.tap(find.text(items[index].label));
    }
    expect(tapped, [0, 1, 2, 3, 4]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('393pt at 140 percent remains above the bottom safe area',
      (tester) async {
    await pumpNav(
      tester,
      size: const Size(393, 852),
      textScale: 1.4,
      onTap: (_) {},
    );

    expectAllItemsVisible();
    expect(tester.getSize(find.byType(IslandBottomNav)).height, lessThan(96));
    final navBottom = tester.getBottomRight(find.byType(IslandBottomNav)).dy;
    expect(navBottom, lessThanOrEqualTo(852 - 17 - 34));
    expect(tester.takeException(), isNull);
  });

  testWidgets('320pt at 120 percent keeps every island navigation item usable',
      (tester) async {
    final tapped = <int>[];
    await pumpNav(
      tester,
      size: const Size(320, 568),
      textScale: 1.2,
      onTap: tapped.add,
    );

    expectAllItemsVisible();
    for (var index = 0; index < items.length; index++) {
      await tester.tap(find.text(items[index].label));
    }
    expect(tapped, [0, 1, 2, 3, 4]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('393pt at 200 percent keeps all labels visible and tappable',
      (tester) async {
    final tapped = <int>[];
    await pumpNav(
      tester,
      size: const Size(393, 852),
      textScale: 2,
      onTap: tapped.add,
    );

    expectAllItemsVisible();
    await expectAllItemsUsable(tester);
    expect(tapped, [0, 1, 2, 3, 4]);
    expect(
      tester.getBottomRight(find.byType(IslandBottomNav)).dy,
      lessThanOrEqualTo(852 - 17 - 34),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('320pt at 200 percent keeps all navigation items usable',
      (tester) async {
    final tapped = <int>[];
    await pumpNav(
      tester,
      size: const Size(320, 568),
      textScale: 2,
      onTap: tapped.add,
    );

    expectAllItemsVisible();
    await expectAllItemsUsable(tester);
    expect(tapped, [0, 1, 2, 3, 4]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('320pt at 300 percent reflows labels without overflow',
      (tester) async {
    final tapped = <int>[];
    await pumpNav(
      tester,
      size: const Size(320, 568),
      textScale: 3,
      onTap: tapped.add,
    );

    expectAllItemsVisible();
    await expectAllItemsUsable(tester);
    expect(tapped, [0, 1, 2, 3, 4]);
    expect(tester.takeException(), isNull);
  });
}
