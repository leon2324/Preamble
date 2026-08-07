import 'package:flutter_test/flutter_test.dart';
import 'package:preamble/components/documents/form_completeness_indicator.dart';
import 'package:preamble/data/documents/document_models.dart';
import 'package:preamble/data/documents/document_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:typed_data';

void main() {
  group('Phase 11 Form Completeness Tests', () {
    test('completenessScore calculates correctly', () {
      const input0 = DocumentTemplateInput(senderName: '', receiverName: '', facts: '');
      var indicator = FormCompletenessIndicator(input: input0);
      expect(indicator.completenessScore, 0.0);

      const input1 = DocumentTemplateInput(senderName: 'Sender', receiverName: '', facts: '');
      indicator = FormCompletenessIndicator(input: input1);
      expect(indicator.completenessScore, 0.2); // 1/5

      const inputAll = DocumentTemplateInput(
        senderName: 'Sender', 
        receiverName: 'Receiver', 
        facts: 'Facts',
        eventDate: 'Date',
        evidence: 'Evidence',
      );
      indicator = FormCompletenessIndicator(input: inputAll);
      expect(indicator.completenessScore, 1.0);
    });
  });

  group('Phase 11 DocumentRepository Signature Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('updateDraft handles signatureBytes correctly', () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = DocumentRepository(prefs: prefs, initialDrafts: []);

      final draft = await repo.createDraft(
        templateType: DocumentTemplateType.depositDemand,
        input: const DocumentTemplateInput(
          senderName: 'Test',
          receiverName: 'Test',
          facts: 'Test',
        ),
      );

      expect(repo.drafts.first.signatureBytes, isNull);

      // Update draft with signature
      final mockSignature = Uint8List.fromList([1, 2, 3]);
      await repo.updateDraft(
        draft.id, 
        newContent: draft.content, 
        newSignatureBytes: mockSignature,
      );

      final updatedDraft = repo.drafts.first;
      expect(updatedDraft.signatureBytes, isNotNull);
      expect(updatedDraft.signatureBytes, equals(mockSignature));

      final json = updatedDraft.toJson();
      final parsed = DocumentDraft.fromJson(json);

      expect(parsed.signatureBytes, isNotNull);
      expect(parsed.signatureBytes, equals(mockSignature));
    });
  });
}
