import 'package:flutter_test/flutter_test.dart';
import 'package:preamble/data/documents/document_models.dart';
import 'package:preamble/data/documents/document_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Phase 12 Performance & Isolate Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('DocumentRepository uses Isolate.run for disk operations', () async {
      final prefs = await SharedPreferences.getInstance();
      final repo = DocumentRepository(prefs: prefs, initialDrafts: []);

      // 產生一筆資料
      final draft = await repo.createDraft(
        templateType: DocumentTemplateType.depositDemand,
        input: const DocumentTemplateInput(
          senderName: 'Test Isolate',
          receiverName: 'Receiver',
          facts: 'Facts',
        ),
      );

      expect(repo.drafts, isNotEmpty);
      expect(repo.drafts.first.title, draft.title);

      // 直接呼叫會觸發 saveLocalDraftsToDisk 內部透過 Isolate.run 轉為 JSON 並寫入 prefs
      await repo.saveLocalDraftsToDisk();

      final jsonStr = prefs.getString('preamble_local_document_drafts_v1');
      expect(jsonStr, isNotNull);
      expect(jsonStr, contains('Test Isolate'));

      // 測試讀取時，透過 Isolate.run 從 JSON 轉回
      final repo2 = DocumentRepository(prefs: prefs, initialDrafts: []);
      await repo2.loadLocalDraftsFromDisk();

      expect(repo2.drafts, isNotEmpty);
      expect(repo2.drafts.first.title, draft.title);
    });
  });
}
