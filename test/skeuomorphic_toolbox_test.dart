import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lawapp/app/app_state.dart';
import 'package:lawapp/pages/learning/know_law_page.dart';

void main() {
  testWidgets('Skeuomorphic toolbox handles car/motorcycle formulas and rent notice templates correctly', (WidgetTester tester) async {
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
            home: const KnowLawPage(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // 1. 切換至生活工具箱 Tab
    expect(find.text('生活工具箱'), findsOneWidget);
    await tester.tap(find.text('生活工具箱'));
    await tester.pumpAndSettle();

    // 2. 驗證預設呈現的白話文翻譯機
    expect(find.text('法律術語白話翻譯機'), findsOneWidget);

    // 3. 點擊頂部車禍計算標籤
    expect(find.text('車禍計算'), findsOneWidget);
    await tester.tap(find.text('車禍計算'));
    await tester.pumpAndSettle();

    expect(find.text('車禍零件折舊與工資計算機'), findsOneWidget);
    expect(find.textContaining('💡 法律小常識'), findsWidgets);

    // 4. 輸入汽車折舊試算資料 (使用 hintText 搜尋 TextField)
    final partsField = find.byWidgetPredicate((w) => w is TextField && w.decoration?.hintText == '例如：12000');
    final laborField = find.byWidgetPredicate((w) => w is TextField && w.decoration?.hintText == '例如：8000');
    final yearsField = find.byWidgetPredicate((w) => w is TextField && w.decoration?.hintText == '例如：3');
    final monthsField = find.byWidgetPredicate((w) => w is TextField && w.decoration?.hintText == '例如：4');

    expect(partsField, findsOneWidget);
    expect(laborField, findsOneWidget);
    expect(yearsField, findsOneWidget);
    expect(monthsField, findsOneWidget);

    await tester.enterText(partsField, '10000');
    await tester.enterText(laborField, '5000');
    await tester.enterText(yearsField, '3');
    await tester.enterText(monthsField, '0');
    await tester.pump();

    // 預設為：汽車 (5年) + 定律遞減法
    await tester.tap(find.text('試算理賠額'));
    await tester.pumpAndSettle();

    // 驗證汽車折舊計算結果 (Y=3, M=0, r=0.369, 10000 -> Year 1: residual 6310 -> Year 2: residual 3981.6 -> Year 3: residual 2512.4 -> Claim = 2512 + 5000 = 7512)
    expect(find.textContaining('零件折舊後殘值：\$2512 元'), findsOneWidget);
    expect(find.textContaining('法院認定合理請求總額：\$7512 元'), findsOneWidget);

    // 5. 切換車輛種類為「🛵 機車 (耐用3年)」
    await tester.tap(find.text('🛵 機車 (耐用3年)'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('試算理賠額'));
    await tester.pumpAndSettle();

    // 驗證機車折舊結果：耐用年數 3 年，殘值保底下限 1/4 (10000 / 4 = 2500)。
    // 原定律遞減法算 3 年會低於 2500，故會觸發 Floor 殘值，結果應為零件殘值 2500 元。
    expect(find.textContaining('零件折舊後殘值：\$2500 元'), findsOneWidget);
    expect(find.textContaining('法院認定合理請求總額：\$7500 元'), findsOneWidget);

    // 6. 切換至租屋信函起草器 (使用 '租屋催告')
    expect(find.text('租屋催告'), findsOneWidget);
    await tester.tap(find.text('租屋催告'));
    await tester.pumpAndSettle();

    expect(find.text('租屋存證信函起草器'), findsOneWidget);

    // 預設通知類型為「設備損壞修繕」
    final landlordField = find.byWidgetPredicate((w) => w is TextField && w.decoration?.hintText == '例如：王太太');
    final addrField = find.byWidgetPredicate((w) => w is TextField && w.decoration?.hintText == '例如：台北市大安區忠孝東路三段XX號');
    final brokenField = find.byWidgetPredicate((w) => w is TextField && w.decoration?.hintText == '例如：客廳冷氣漏水');
    final daysField = find.byWidgetPredicate((w) => w is TextField && w.decoration?.hintText == '例如：7');

    expect(landlordField, findsOneWidget);
    expect(addrField, findsOneWidget);
    expect(brokenField, findsOneWidget);
    expect(daysField, findsOneWidget);

    await tester.enterText(landlordField, '王房東');
    await tester.enterText(addrField, '台北市大安區新生南路');
    await tester.enterText(brokenField, '天花板漏水');
    await tester.enterText(daysField, '5');
    await tester.pump();

    await tester.tap(find.text('起草催告書'));
    await tester.pumpAndSettle();

    expect(find.textContaining('郵局存證信函草稿 (設備修繕催告)'), findsOneWidget);
    expect(find.textContaining('為請求儘速修繕房屋內「天花板漏水」設備事。'), findsOneWidget);

    // 7. 切換通知類型為「💰 租約期滿退押金」
    await tester.tap(find.text('💰 租約期滿退押金'));
    await tester.pumpAndSettle();

    final expiryField = find.byWidgetPredicate((w) => w is TextField && w.decoration?.hintText == '例如：2026年6月1日');
    final depositField = find.byWidgetPredicate((w) => w is TextField && w.decoration?.hintText == '例如：30000');

    expect(expiryField, findsOneWidget);
    expect(depositField, findsOneWidget);

    await tester.enterText(expiryField, '2026年6月14日');
    await tester.enterText(depositField, '32000');
    await tester.pump();

    await tester.tap(find.text('起草催告書'));
    await tester.pumpAndSettle();

    expect(find.textContaining('郵局存證信函草稿 (期滿退還押金催告)'), findsOneWidget);
    expect(find.textContaining('為請求依法儘速返還租賃房屋押租金新台幣 32000 元整事。'), findsOneWidget);
  });
}
