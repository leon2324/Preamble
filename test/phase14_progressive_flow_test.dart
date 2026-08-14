import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:preamble/components/assistant/law_assistant_insight_card.dart';
import 'package:preamble/data/documents/document_models.dart';
import 'package:preamble/data/law_assistant/law_assistant_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 14: Progressive Legal Action Flow Tests', () {
    test('LawAssistantDefenseInsight correctly parses rental dispute context', () {
      final insight = LawAssistantDefenseInsight.fromContext(
        text: '房東退租時以房間污損為由拒絕退還兩個月押金',
      );

      expect(insight.disputeCategory, contains('租賃'));
      expect(insight.suggestedTemplateType, DocumentTemplateType.rentalDepositNegotiation);
      expect(insight.defensePoints, isNotEmpty);
      expect(insight.keyEvidences, isNotEmpty);
      expect(insight.suggestedFollowUps, isNotEmpty);
    });

    test('LawAssistantDefenseInsight correctly parses car accident context', () {
      final insight = LawAssistantDefenseInsight.fromContext(
        text: '在十字路口被後方車輛追撞，對方主張過失相抵且要求折舊',
      );

      expect(insight.disputeCategory, contains('交通事故'));
      expect(insight.suggestedTemplateType, DocumentTemplateType.carAccidentChecklist);
      expect(insight.defensePoints.any((p) => p.contains('過失')), isTrue);
    });

    test('LawAssistantDefenseInsight correctly parses labor dispute context', () {
      final insight = LawAssistantDefenseInsight.fromContext(
        text: '公司老闆要求責任制天天加班且不給加班費，最後資遣也不給非自願離職證明',
      );

      expect(insight.disputeCategory, contains('勞資'));
      expect(insight.suggestedTemplateType, DocumentTemplateType.laborDisputeMessage);
    });

    test('LawAssistantMessage attaches insight when assistant responds', () {
      final message = LawAssistantMessage(
        id: 'msg-1',
        role: LawAssistantMessageRole.assistant,
        content: '建議您先發函給房東催告返還押金。',
        createdAt: DateTime.now(),
        insight: LawAssistantDefenseInsight.fromContext(
          text: '建議您先發函給房東催告返還押金。',
        ),
      );

      expect(message.insight, isNotNull);
      expect(message.insight!.suggestedActionLabel, isNotEmpty);
    });

    testWidgets('LawAssistantInsightCard renders and triggers document conversion callback',
        (WidgetTester tester) async {
      DocumentTemplateType? convertedType;
      String? convertedFacts;

      final testInsight = LawAssistantDefenseInsight.fromContext(
        text: '房東拒絕退還押金',
      );

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: LawAssistantInsightCard(
                insight: testInsight,
                onConvertToDocument: (type, facts) {
                  convertedType = type;
                  convertedFacts = facts;
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('攻防洞察與舉證指引'), findsOneWidget);
      expect(find.text(testInsight.disputeCategory), findsOneWidget);

      // Find and tap conversion button
      final button = find.text(testInsight.suggestedActionLabel);
      expect(button, findsOneWidget);

      await tester.tap(button);
      await tester.pumpAndSettle();

      expect(convertedType, testInsight.suggestedTemplateType);
      expect(convertedFacts, isNotNull);
    });
  });
}
