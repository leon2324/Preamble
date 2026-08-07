import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:preamble/components/shared/citation_popover_dialog.dart';
import 'package:preamble/data/statutes/statute_item.dart';
import 'package:preamble/pages/learning/widgets/law_assistant_suggested_prompts.dart';
import 'package:preamble/pages/learning/widgets/pdf_style_builder.dart';
import 'package:preamble/pages/tools/widgets/document_form_stepper.dart';
import 'package:preamble/pages/tools/widgets/document_signature_canvas.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 6 Citation Popover & Suggested Prompts Tests', () {
    testWidgets('CitationPopoverDialog renders statute summary and action button', (tester) async {
      final statuteItem = StatuteItem(
        codeName: '民法',
        articleNumber: '184',
        articleText: '因故意或過失，不法侵害他人之權利者，負損害賠償責任。',
        lawUrl: 'https://law.moj.gov.tw',
        category: '民事法',
        updatedDate: '2026/01/01',
        isRepealed: false,
        tags: ['侵權', '損害賠償'],
      );

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(393, 852),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () => CitationPopoverDialog.show(context, statuteItem),
                    child: const Text('Open Popover'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Popover'));
      await tester.pumpAndSettle();

      expect(find.text(statuteItem.displayTitle), findsOneWidget);
      expect(find.text('閱讀完整法規條文'), findsOneWidget);
    });

    testWidgets('LawAssistantSuggestedPrompts triggers callback on prompt selection', (tester) async {
      String? selectedPrompt;

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(393, 852),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: LawAssistantSuggestedPrompts(
                onSelectPrompt: (prompt) => selectedPrompt = prompt,
              ),
            ),
          ),
        ),
      );

      expect(find.text('延伸追問建議'), findsOneWidget);
      expect(find.text('該如何蒐集與保存相關證據？'), findsOneWidget);

      await tester.tap(find.text('該如何蒐集與保存相關證據？'));
      expect(selectedPrompt, '該如何蒐集與保存相關證據？');
    });
  });

  group('Phase 6 Signature Canvas & Form Completeness Tests', () {
    testWidgets('DocumentFormCompletenessBar renders percentage correctly', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(393, 852),
          builder: (context, child) => const MaterialApp(
            home: Scaffold(
              body: DocumentFormCompletenessBar(completenessRatio: 0.85),
            ),
          ),
        ),
      );

      expect(find.text('填表完成度'), findsOneWidget);
      expect(find.text('85 %'), findsOneWidget);
    });

    testWidgets('DocumentSignatureCanvas renders and clears correctly', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(393, 852),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: DocumentSignatureCanvas(
                onSignatureSaved: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('手繪親筆簽名板'), findsOneWidget);
      expect(find.text('清除重簽'), findsOneWidget);

      await tester.tap(find.text('清除重簽'));
      await tester.pump();
    });

    test('PdfStyleBuilder supports optional signaturePngBytes embedding', () async {
      final pdfBytes = await PdfStyleBuilder.buildDocumentPdf(
        title: '簽名版存證信函',
        content: '本人已簽章確認具結。',
        themeStyle: PdfThemeStyle.morandiGreen,
        signaturePngBytes: null,
      );

      expect(pdfBytes, isNotNull);
      expect(pdfBytes.isNotEmpty, true);
    });
  });
}
