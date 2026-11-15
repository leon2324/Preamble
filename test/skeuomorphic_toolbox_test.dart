import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:preamble/app/app_state.dart';
import 'package:preamble/pages/tools/legal_toolkit_hub_page.dart';
import 'package:preamble/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/responsive_error_collector.dart';

void main() {
  testWidgets(
      'LegalToolkitHubPage handles car/motorcycle depreciation formulas, rent notice templates, and contract risk scanner',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1179, 6000);
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
        builder: (context, __) => PreambleScope(
          state: appState,
          child: MaterialApp(
            theme: AppTheme.light(),
            home: const LegalToolkitHubPage(initialToolKey: 'car'),
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 400));

    // 1. 驗證車禍折舊試算工作區與欄位
    expect(find.text('法務實戰工具館'), findsOneWidget);
    expect(find.text('車禍折舊試算'), findsOneWidget);

    final partsField = find.byWidgetPredicate(
      (w) => w is TextField && w.decoration?.hintText == '15000',
    );
    final laborField = find.byWidgetPredicate(
      (w) => w is TextField && w.decoration?.hintText == '8000',
    );
    final yearsField = find.byWidgetPredicate(
      (w) => w is TextField && w.decoration?.hintText == '3',
    );
    final monthsField = find.byWidgetPredicate(
      (w) => w is TextField && w.decoration?.hintText == '6',
    );

    await tester.enterText(partsField, '10000');
    await tester.enterText(laborField, '5000');
    await tester.enterText(yearsField, '3');
    await tester.enterText(monthsField, '0');
    await tester.pump();

    // 預設：自用汽車（耐用 5 年）+ 定率遞減法
    await tester.tap(find.text('試算法院合理判賠額'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.textContaining('零件折舊後殘值：NT\$ 2512 元'), findsOneWidget);
    expect(find.textContaining('法院實務認定合理請求總額：NT\$ 7512 元'), findsOneWidget);

    // 2. 切換為「機車（耐用 3 年）」驗證殘值保底下限 1/4 = 2500
    await tester.tap(find.text('機車（耐用 3 年）'));
    await tester.pump(const Duration(milliseconds: 200));

    await tester.tap(find.text('試算法院合理判賠額'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.textContaining('零件折舊後殘值：NT\$ 2500 元'), findsOneWidget);
    expect(find.textContaining('法院實務認定合理請求總額：NT\$ 7500 元'), findsOneWidget);

    // 3. 切換至「租屋存證信函」起草器
    final rentChip = find.text('租屋存證信函');
    await tester.ensureVisible(rentChip);
    await tester.tap(rentChip);
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('租屋催告存證信函起草器'), findsOneWidget);

    final landlordField = find.byWidgetPredicate(
      (w) => w is TextField && w.decoration?.hintText == '例如：王大明',
    );
    final addrField = find.byWidgetPredicate(
      (w) =>
          w is TextField &&
          w.decoration?.hintText == '例如：台北市大安區仁愛路四段 XX 號 X 樓',
    );
    final brokenField = find.byWidgetPredicate(
      (w) => w is TextField && w.decoration?.hintText == '例如：熱水器無法點火',
    );

    await tester.enterText(landlordField, '王房東');
    await tester.enterText(addrField, '台北市大安區新生南路');
    await tester.enterText(brokenField, '天花板漏水');
    await tester.pump();

    await tester.tap(find.text('生成正式催告草稿'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.textContaining('郵局存證信函草稿（設備修繕定期催告）'), findsOneWidget);
    expect(find.textContaining('天花板漏水'), findsWidgets);

    // 4. 切換至「租約期滿退還押金」模式
    await tester.tap(find.text('租約期滿退還押金'));
    await tester.pump(const Duration(milliseconds: 300));

    final expiryField = find.byWidgetPredicate(
      (w) => w is TextField && w.decoration?.hintText == '例如：2026年10月31日',
    );
    final depositField = find.byWidgetPredicate(
      (w) => w is TextField && w.decoration?.hintText == '例如：32000',
    );

    await tester.enterText(expiryField, '2026年10月31日');
    await tester.enterText(depositField, '32000');
    await tester.pump();

    await tester.tap(find.text('生成正式催告草稿'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.textContaining('郵局存證信函草稿（期滿返還押租金催告）'), findsOneWidget);
    expect(find.textContaining('32000 元整'), findsWidgets);
  });

  testWidgets('LegalToolkitHubPage does not overflow at 320x568 @ 1.4x and 393x852 @ 2.0x',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final appState = PreambleState();
    addTearDown(appState.dispose);

    for (final scenario in const [
      (Size(320, 568), 1.4),
      (Size(393, 852), 2.0),
    ]) {
      final collector = ResponsiveErrorCollector()..install();
      try {
        await tester.pumpWidget(
          MediaQuery(
            data: MediaQueryData(
              size: scenario.$1,
              textScaler: TextScaler.linear(scenario.$2),
            ),
            child: ScreenUtilInit(
              designSize: const Size(375, 812),
              minTextAdapt: true,
              splitScreenMode: true,
              builder: (_, __) => PreambleScope(
                state: appState,
                child: MaterialApp(
                  theme: AppTheme.dark(),
                  home: const LegalToolkitHubPage(initialToolKey: 'contract'),
                ),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 300));
      } finally {
        collector.captureTesterException(tester);
        collector.restore();
      }
      expect(collector.layoutFailures, isEmpty);
    }
  });
}
