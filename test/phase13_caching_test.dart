import 'package:flutter_test/flutter_test.dart';
import 'package:preamble/data/documents/document_models.dart';
import 'package:preamble/data/documents/document_repository.dart';
import 'package:preamble/features/case_library/data/case_dossier_sqlite_db.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 13: Caching, Indexing, and UI Interactions', () {
    test('CaseDossierSqliteDb instance is accessible', () {
      final dbHelper = CaseDossierSqliteDb.instance;
      expect(dbHelper, isNotNull);
    });

    test('DocumentRepository allows creating and deleting draft', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = DocumentRepository(prefs: prefs, initialDrafts: []);

      final draft = await repo.createDraft(
        templateType: DocumentTemplateType.depositDemand,
        input: const DocumentTemplateInput(
          senderName: '測試發信人',
          receiverName: '測試收信人',
          facts: '測試事實摘要',
        ),
      );

      expect(repo.drafts, isNotEmpty);
      final draftId = draft.id;

      await repo.deleteDraft(draftId);
      expect(repo.drafts.where((d) => d.id == draftId), isEmpty);
    });
  });
}
