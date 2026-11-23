import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:preamble/app/app_state.dart';
import 'package:preamble/features/case_library/data/case_library_data.dart';
import 'package:preamble/features/case_library/pages/case_dossier_detail_page.dart';
import 'package:preamble/pages/home/subpages/editorial_story_page.dart';
import 'package:preamble/pages/home/subpages/life_situation_guide_page.dart';
import 'package:preamble/pages/learning/know_law_page.dart';
import 'package:preamble/pages/profile/profile_page.dart';
import 'package:preamble/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 針對先前未納入自動化矩陣的手動頁面（案件詳情、小法助對話、個人頁、情境閱讀、專題報導）
/// 驗證在 140% 大字級與緊湊螢幕（375x812 與 320x568）下不發生版面溢出或元件錯誤。
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpScaledScreen(
    WidgetTester tester, {
    required Size size,
    required double textScale,
    required Widget child,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final appState = PreambleState();
    addTearDown(appState.dispose);
    await appState.load();

    final errors = <FlutterErrorDetails>[];
    final previousOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      errors.add(details);
    };
    addTearDown(() {
      FlutterError.onError = previousOnError;
    });

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, _) => PreambleScope(
          state: appState,
          child: MaterialApp(
            theme: AppTheme.light(),
            builder: (ctx, c) => MediaQuery(
              data: MediaQuery.of(ctx).copyWith(
                textScaler: TextScaler.linear(textScale),
              ),
              child: c!,
            ),
            home: child,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 600));

    expect(
      errors.map((e) => e.exceptionAsString()).toList(),
      isEmpty,
      reason: 'Screen ${child.runtimeType} at $size / $textScale overflowed or threw',
    );
  }

  testWidgets('ProfilePage handles 140% text scale on 320x568 without overflow',
      (tester) async {
    await pumpScaledScreen(
      tester,
      size: const Size(320, 568),
      textScale: 1.4,
      child: const ProfilePage(showBackButton: false),
    );
  });

  testWidgets('LifeSituationGuidePage handles 140% text scale on 320x568',
      (tester) async {
    await pumpScaledScreen(
      tester,
      size: const Size(320, 568),
      textScale: 1.4,
      child: const LifeSituationGuidePage(domainId: 'rental'),
    );
  });

  testWidgets('EditorialStoryPage handles 140% text scale on 320x568',
      (tester) async {
    await pumpScaledScreen(
      tester,
      size: const Size(320, 568),
      textScale: 1.4,
      child: EditorialStoryPage(
        categoryLabel: '生活案例',
        subtitleBadge: '最高法院民事判決',
        title: '跑外送算員工還是自己接案？法院這樣看平台跟外送員的關係',
        leftLabel: '平台怎麼說',
        leftSummary: '自由上下線、沒底薪，簽的是接案合約',
        rightLabel: '法院怎麼看',
        rightSummary: '派單與報酬都受演算法規定，其實就像員工一樣',
        caseId: 'case-delivery-labor-2152',
        onOpenCaseDossier: (_) {},
      ),
    );
  });

  testWidgets('LawAssistantChatPage handles 140% text scale on 375x812',
      (tester) async {
    await pumpScaledScreen(
      tester,
      size: const Size(375, 812),
      textScale: 1.4,
      child: const LawAssistantChatPage(),
    );
  });

  testWidgets('CaseDossierDetailPage handles 140% text scale on 375x812',
      (tester) async {
    await pumpScaledScreen(
      tester,
      size: const Size(375, 812),
      textScale: 1.4,
      child: CaseDossierDetailPage(book: caseLibraryCasesSeed.first),
    );
  });
}
