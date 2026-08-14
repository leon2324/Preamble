import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:preamble/app/app_state.dart';
import 'package:preamble/components/subscription/morandi_paywall_sheet.dart';
import 'package:preamble/data/subscription/subscription_models.dart';
import 'package:preamble/data/subscription/subscription_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 16: Subscription & Monetization Tests', () {
    late SharedPreferences prefs;
    late SubscriptionService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      service = SubscriptionService(prefs: prefs);
    });

    test('Initial user status is Free with 3 AI consultations quota', () {
      expect(service.status.tier, SubscriptionTier.free);
      expect(service.isProOrHigher, isFalse);
      expect(service.remainingAiQuota, 3);
    });

    test('Consuming AI quota decrements available count until 0', () async {
      expect(await service.consumeAiQuota(), isTrue);
      expect(service.remainingAiQuota, 2);

      expect(await service.consumeAiQuota(), isTrue);
      expect(service.remainingAiQuota, 1);

      expect(await service.consumeAiQuota(), isTrue);
      expect(service.remainingAiQuota, 0);

      // 4th time should be rejected for Free tier
      expect(await service.consumeAiQuota(), isFalse);
    });

    test('Purchasing PRO plan upgrades tier and unlocks unlimited quota', () async {
      final proPlan = SubscriptionPlan.availablePlans.firstWhere(
        (p) => p.id == 'preamble_pro_monthly',
      );

      final success = await service.purchasePlan(proPlan);
      expect(success, isTrue);
      expect(service.status.tier, SubscriptionTier.pro);
      expect(service.isProOrHigher, isTrue);
      expect(service.status.isPro, isTrue);
      expect(service.remainingAiQuota, 999);
      expect(service.status.expiryDate, isNotNull);

      // Consuming AI quota for PRO always succeeds
      expect(await service.consumeAiQuota(), isTrue);
    });

    test('Restoring purchases recovers saved PRO subscription', () async {
      final proAnnualPlan = SubscriptionPlan.availablePlans.firstWhere(
        (p) => p.id == 'preamble_pro_annual',
      );

      await service.purchasePlan(proAnnualPlan);

      // Create new instance with same storage
      final newService = SubscriptionService(prefs: prefs);
      final restored = await newService.restorePurchases();

      expect(restored, isTrue);
      expect(newService.isProOrHigher, isTrue);
    });

    testWidgets('MorandiPaywallSheet renders with premium options and features',
        (WidgetTester tester) async {
      final appState = PreambleState(subscriptionService: service);

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => PreambleScope(
            state: appState,
            child: const MaterialApp(
              home: Scaffold(
                body: MorandiPaywallSheet(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('升級緒言 PRO 專業會員'), findsOneWidget);
      expect(find.text('恢復購買'), findsOneWidget);
      expect(find.text('選擇最適合您的訂閱方案'), findsOneWidget);
      expect(find.text('專業版 (年繳特惠)'), findsOneWidget);
      expect(find.text('專業版 (月繳)'), findsOneWidget);
      expect(find.text('企業商務版'), findsOneWidget);
      expect(find.text('服務條款 (EULA)'), findsOneWidget);
      expect(find.text('隱私權政策'), findsOneWidget);
    });
  });
}
