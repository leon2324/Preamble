import 'package:flutter_test/flutter_test.dart';
import 'package:preamble/data/documents/document_models.dart';
import 'package:preamble/data/documents/document_repository.dart';
import 'package:preamble/utils/typing_simulator.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Phase 10 TypingSimulator Tests', () {
    test('simulateString yields all characters', () async {
      final stream = TypingSimulator.simulateString('你好，世界。');
      final result = await stream.toList();
      expect(result.join(''), '你好，世界。');
    });
  });

  group('Phase 10 DocumentRepository Incognito & Version Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('Incognito mode prevents saving to disk', () async {
      final prefs = await SharedPreferences.getInstance();
      final incognitoRepo = DocumentRepository(
        prefs: prefs, 
        isIncognito: true,
        initialDrafts: [],
      );

      final draft = await incognitoRepo.createDraft(
        templateType: DocumentTemplateType.depositDemand,
        input: const DocumentTemplateInput(
          senderName: 'Test',
          receiverName: 'Test',
          facts: 'Test',
        ),
      );

      expect(incognitoRepo.drafts.length, 1);
      expect(incognitoRepo.drafts.first.id, draft.id);

      // Verify prefs are empty
      expect(prefs.getString('preamble_local_document_drafts_v1'), isNull);
    });

    test('updateDraft creates version history', () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = DocumentRepository(
        prefs: prefs,
        initialDrafts: [],
      );

      final draft = await repo.createDraft(
        templateType: DocumentTemplateType.depositDemand,
        input: const DocumentTemplateInput(
          senderName: 'VersionTest',
          receiverName: 'Test',
          facts: 'V1 content',
        ),
      );

      expect(repo.drafts.first.versions, isEmpty);

      // Update draft
      await repo.updateDraft(draft.id, newContent: 'V2 content');

      final updatedDraft = repo.drafts.first;
      expect(updatedDraft.content, 'V2 content');
      expect(updatedDraft.versions.length, 1);
      expect(updatedDraft.versions.first.content, draft.content);
    });
  });
}
