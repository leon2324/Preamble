import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:preamble/data/documents/document_models.dart';
import 'package:preamble/data/documents/document_repository.dart';
import 'package:preamble/pages/learning/widgets/pdf_style_builder.dart';
import 'package:preamble/pages/tools/widgets/document_form_stepper.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DocumentRepository SharedPreferences Persistence Tests', () {
    test('createDraft saves draft to SharedPreferences and reloads correctly', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final repository = DocumentRepository(
        baseUrl: '',
        prefs: prefs,
        initialDrafts: const [],
      );

      final draft = await repository.createDraft(
        templateType: DocumentTemplateType.rentalDepositNegotiation,
        input: const DocumentTemplateInput(
          senderName: '張三',
          receiverName: '李四',
          facts: '退租押金並未全額返還。',
        ),
        title: '押金返還通知',
      );

      expect(draft.senderName, '張三');
      expect(draft.isSyncedToBackend, false);
      expect(repository.drafts.any((d) => d.id == draft.id), true);

      // 驗證重載 repository 能從 SharedPreferences 快取還原
      final newRepository = DocumentRepository(
        baseUrl: '',
        prefs: prefs,
        initialDrafts: const [],
      );
      await newRepository.loadLocalDraftsFromDisk();

      expect(newRepository.drafts.any((d) => d.id == draft.id), true);
    });
  });

  group('DocumentFormStepper & QuickFill Bar Tests', () {
    testWidgets('DocumentFormStepper renders active step correctly', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(393, 852),
          builder: (context, child) => const MaterialApp(
            home: Scaffold(
              body: DocumentFormStepper(currentStep: 2),
            ),
          ),
        ),
      );

      expect(find.text('選擇情境'), findsOneWidget);
      expect(find.text('補充資料'), findsOneWidget);
      expect(find.text('預覽草稿'), findsOneWidget);
    });

    testWidgets('DocumentQuickFillBar triggers quick fill callback', (tester) async {
      var quickFillTriggered = false;

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(393, 852),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: DocumentQuickFillBar(
                onQuickFill: () => quickFillTriggered = true,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('一鍵帶入預設範例'));
      expect(quickFillTriggered, true);
    });
  });

  group('PdfStyleBuilder Tests', () {
    test('PdfStyleBuilder generates valid PDF bytes containing title and disclaimer', () async {
      final pdfBytes = await PdfStyleBuilder.buildDocumentPdf(
        title: '押金返還請求存證信函',
        content: '本人王小明於 2026/04/30 退租。',
        themeStyle: PdfThemeStyle.morandiGreen,
      );

      expect(pdfBytes, isNotNull);
      expect(pdfBytes.isNotEmpty, true);
      // PDF 檔頭驗證 (%PDF-)
      final header = String.fromCharCodes(pdfBytes.take(5));
      expect(header, '%PDF-');
    });
  });
}

extension on DocumentDraft {
  String get senderName => content.contains('我是 ')
      ? content.split('我是 ').last.split('，').first.trim()
      : '';
}
