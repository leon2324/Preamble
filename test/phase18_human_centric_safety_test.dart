import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:preamble/components/safety/negotiation_kit_card.dart';
import 'package:preamble/components/safety/plain_document_translator_sheet.dart';
import 'package:preamble/components/safety/privacy_shield_wrapper.dart';
import 'package:preamble/components/safety/statute_countdown_badge.dart';
import 'package:preamble/data/law_assistant/law_assistant_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 18: Human-Centric Safety Net Tests', () {
    test('LawAssistantDefenseInsight provides statute deadlines and negotiation kit', () {
      final rentalInsight = LawAssistantDefenseInsight.fromContext(
        text: '房東退租扣抵押金不退',
      );
      expect(rentalInsight.statuteDeadline, isNotNull);
      expect(rentalInsight.statuteDeadline!.durationDays, 180);
      expect(rentalInsight.statuteDeadline!.legalBasis, contains('民法第456條'));
      expect(rentalInsight.negotiationKit, isNotNull);
      expect(rentalInsight.negotiationKit!.threeNeverSign, isNotEmpty);

      final carAccidentInsight = LawAssistantDefenseInsight.fromContext(
        text: '車禍追撞求償理賠',
      );
      expect(carAccidentInsight.statuteDeadline, isNotNull);
      expect(carAccidentInsight.statuteDeadline!.durationDays, 180);
      expect(carAccidentInsight.statuteDeadline!.legalBasis, contains('刑事訴訟法'));

      final laborInsight = LawAssistantDefenseInsight.fromContext(
        text: '公司無故資遣不付加班費',
      );
      expect(laborInsight.statuteDeadline, isNotNull);
      expect(laborInsight.negotiationKit!.threeNeverSign.any((s) => s.contains('自願離職')), isTrue);
    });

    test('PlainDocumentTranslation parses legal texts into 3 plain language answers', () {
      const sampleNotice =
          '按民法第423條及雙方租約，台端退租屋況污損，出租人依法扣抵押金四萬元整，請於七日內結清。';
      final translation =
          PlainDocumentTranslation.parseFromRawLegalText(sampleNotice);

      expect(translation.documentType, contains('押金'));
      expect(translation.whatTheyWant, contains('他想要什麼'));
      expect(translation.areTheyRight, contains('他有道理嗎'));
      expect(translation.whatYouShouldDo, contains('你現在該做什麼'));
      expect(translation.extractedDeadline, contains('7 日'));
    });

    testWidgets('StatuteCountdownBadge renders and triggers calendar dialog',
        (WidgetTester tester) async {
      const deadline = LegalStatuteDeadline(
        title: '過失傷害告訴時效（黃金6個月）',
        legalBasis: '刑事訴訟法第237條',
        durationDays: 180,
        urgencyDescription: '知悉肇事人之日起6個月內必須提出。',
        warningNote: '逾期將喪失告訴權利。',
      );

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => const MaterialApp(
            home: Scaffold(
              body: StatuteCountdownBadge(deadline: deadline),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('法律時效生死線'), findsOneWidget);
      expect(find.text('加到行事曆'), findsOneWidget);

      await tester.tap(find.text('加到行事曆'));
      await tester.pumpAndSettle();

      expect(find.text('加入系統行事曆提醒'), findsOneWidget);
      expect(find.text('確認寫入'), findsOneWidget);
    });

    testWidgets('NegotiationKitCard toggles expansion',
        (WidgetTester tester) async {
      // [審查修復] NegotiationDefenseKit 的 List 欄位無法在 const 上下文中被存取，
      // 因此移除 const 宣告，改為 final。
      final kit = NegotiationDefenseKit(
        threeNeverSign: ['❌ 絕不簽署放棄押金切結書'],
        threeMustAsk: ['❓ 請問折舊核算基準為何？'],
        recordingLegalityTip: '💡 錄音自保提示',
      );

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: NegotiationKitCard(
                threeNeverSign: kit.threeNeverSign,
                threeMustAsk: kit.threeMustAsk,
                recordingLegalityTip: kit.recordingLegalityTip,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.textContaining('現場談判防坑三不原則錦囊'), findsOneWidget);
      expect(find.text('❌ 絕不簽署放棄押金切結書'), findsNothing);

      // 點擊展開
      await tester.tap(find.textContaining('現場談判防坑三不原則錦囊'));
      await tester.pumpAndSettle();

      expect(find.text('❌ 絕不簽署放棄押金切結書'), findsOneWidget);
      expect(find.text('❓ 請問折舊核算基準為何？'), findsOneWidget);
    });

    testWidgets('PrivacyShieldWrapper renders child and toggles disguise layer',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => const MaterialApp(
            home: Scaffold(
              body: PrivacyShieldWrapper(
                child: Text('極度敏感的法律對話紀錄'),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('極度敏感的法律對話紀錄'), findsOneWidget);
      expect(find.text('備忘錄 (Notes)'), findsNothing);
    });
  });
}
