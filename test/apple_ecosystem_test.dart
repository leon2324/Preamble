import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:preamble/platform/calendar_sync_service.dart';
import 'package:preamble/platform/ios_intent_router.dart';
import 'package:preamble/platform/ios_statute_spotlight_bridge.dart';
import 'package:preamble/platform/ios_today_case_widget_bridge.dart';
import 'package:preamble/platform/native_share_bridge.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Apple Ecosystem Channel Graceful Fallback Tests', () {
    test('IosTodayCaseWidgetBridge handles missing plugin without throwing', () async {
      await expectLater(
        IosTodayCaseWidgetBridge.syncDefaultStory(),
        completes,
      );

      await expectLater(
        IosTodayCaseWidgetBridge.syncTodoList(['完成存證信函草稿', '查詢民法 184']),
        completes,
      );
    });

    test('IosStatuteSpotlightBridge handles missing plugin without throwing', () async {
      await expectLater(
        IosStatuteSpotlightBridge.syncDefaultIndex(),
        completes,
      );

      await expectLater(
        IosStatuteSpotlightBridge.indexCustomStatute(
          codeName: '民法',
          articleNumber: '184',
          articleText: '因故意或過失，不法侵害他人之權利者，負損害賠償責任。',
          tags: ['侵權', '損害賠償'],
        ),
        completes,
      );
    });

    test('NativeShareBridge returns false gracefully in test environment', () async {
      final textShareResult = await NativeShareBridge.shareText(
        title: '分享法規',
        text: '民法第 184 條侵權行為',
      );
      expect(textShareResult, false);

      final cardShareResult = await NativeShareBridge.shareTipCard(
        title: '每日判決卡片',
        summary: '罵人「毒瘤」相關實務判決整理',
        source: '緒言 Preamble 法律團隊',
      );
      expect(cardShareResult, false);
    });
  });

  group('CalendarSyncService RFC 5545 iCalendar Generation Tests', () {
    test('syncToCalendar triggers haptic and handles URI parsing', () async {
      final now = DateTime(2026, 5, 20, 10, 30);
      final result = await CalendarSyncService.syncToCalendar(
        title: '台北地方法院開庭預備',
        dateTime: now,
        location: '台北地方法院第 3 法庭',
        description: '民事聲請退還押金訴訟案。',
      );

      // 測試環境中無法實際 launchUrl，應安全傳回 false 不引發異常
      expect(result, false);
    });
  });

  group('IosIntentRouter Dispatch Tests', () {
    testWidgets('IosIntentRouter handles initial cold start check cleanly', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(393, 852),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  // ignore: deprecated_member_use_from_same_package
                  IosIntentRouter.register(context);
                  return const Text('Intent Router Ready');
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('Intent Router Ready'), findsOneWidget);

      final BuildContext context = tester.element(find.text('Intent Router Ready'));
      // ignore: deprecated_member_use_from_same_package
      await IosIntentRouter.checkInitialIntents(context);
      // ignore: deprecated_member_use_from_same_package
      IosIntentRouter.unregister();
    });
  });
}
