import 'package:flutter_test/flutter_test.dart';
import 'package:preamble/data/documents/document_models.dart';
import 'package:preamble/data/documents/dynamic_legal_drafter_brain.dart';
import 'package:preamble/pages/learning/widgets/pdf_style_builder.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 15: Autonomous Dynamic Legal Drafter Brain Tests', () {
    test('DynamicLegalDrafterBrain autonomously drafts partnership dissolution without templates', () {
      final doc = DynamicLegalDrafterBrain.generateFromFactDescription(
        rawFacts: '我和朋友合資開美甲店，各出資50萬，但他私自把公款轉進自己戶頭，我要退夥查帳退款。',
      );

      expect(doc.title, contains('合夥'));
      expect(doc.sections.length, greaterThanOrEqualTo(2));
      expect(doc.legalBasis.any((b) => b.contains('民法第686條')), isTrue);
      expect(doc.demands, isNotEmpty);
      expect(doc.warningClause, contains('侵占'));

      final fullText = doc.toFormalDocumentText();
      expect(fullText, contains('合夥出資與經營背景'));
      expect(fullText, contains('履行事項'));
    });

    test('DynamicLegalDrafterBrain autonomously drafts construction defect demand', () {
      final doc = DynamicLegalDrafterBrain.generateFromFactDescription(
        rawFacts: '請設計師裝潢浴室，結果地磚嚴重積水且水管漏水，設計師拖延一個月不來修，還要求付尾款。',
      );

      expect(doc.title, contains('裝修'));
      expect(doc.legalBasis.any((b) => b.contains('民法第492條')), isTrue);
      expect(doc.demands.any((d) => d.contains('進場')), isTrue);
    });

    test('DynamicLegalDrafterBrain autonomously drafts loan default demand', () {
      final doc = DynamicLegalDrafterBrain.generateFromFactDescription(
        rawFacts: '去年借給前同事20萬元，約定今年6月還款，有簽借據，但現在打電話不接訊息不回。',
      );

      expect(doc.title, contains('借貸'));
      expect(doc.legalBasis.any((b) => b.contains('民法第474條')), isTrue);
      expect(doc.demands.any((d) => d.contains('本金')), isTrue);
    });

    test('DynamicLegalDrafterBrain autonomously drafts nuisance noise demand', () {
      final doc = DynamicLegalDrafterBrain.generateFromFactDescription(
        rawFacts: '樓上鄰居半夜兩點常常在客廳打籃球跟重物拖拉，造成嚴重噪音干擾睡眠。',
      );

      expect(doc.title, contains('侵害安寧'));
      expect(doc.legalBasis.any((b) => b.contains('民法第793條')), isTrue);
    });

    test('DynamicLegalDrafterBrain autonomously drafts IP copyright infringement warning', () {
      final doc = DynamicLegalDrafterBrain.generateFromFactDescription(
        rawFacts: '某賣家未經授權在蝦皮盜用我原創拍攝的商品展示照片跟文案銷售同款商品。',
      );

      expect(doc.title, contains('著作權'));
      expect(doc.legalBasis.any((b) => b.contains('著作權法')), isTrue);
      expect(doc.demands.any((d) => d.contains('下架')), isTrue);
    });

    test('DynamicLegalDocument correctly converts to structured JSON and back', () {
      final doc = DynamicLegalDrafterBrain.generateFromFactDescription(
        rawFacts: '房東退租時以房間自然折舊為由扣押金2萬元不還。',
      );

      final json = doc.toJson();
      final restored = DynamicLegalDocument.fromJson(json);

      expect(restored.title, doc.title);
      expect(restored.sections.length, doc.sections.length);
      expect(restored.demands.length, doc.demands.length);
    });

    test('PdfStyleBuilder supports DynamicLegalDocument structured rendering', () async {
      final doc = DynamicLegalDrafterBrain.generateFromFactDescription(
        rawFacts: '我和朋友合開公司鬧拆夥，請求依法查帳結算。',
      );

      // Verify the PDF builder handles the dynamicDocument model
      final pdfBytes = await PdfStyleBuilder.buildDocumentPdf(
        title: doc.title,
        content: doc.toFormalDocumentText(),
        dynamicDocument: doc,
      );

      expect(pdfBytes, isNotNull);
      expect(pdfBytes.length, greaterThan(0));
    });
  });
}
