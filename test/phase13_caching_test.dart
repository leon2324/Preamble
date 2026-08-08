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

    test('DocumentRepository allows deleting draft', () async {
      SharedPreferences.setMockInitialValues({});
      final repo = DocumentRepository();
      
      final draft = DocumentDraft(
        id: 'test_draft_1',
        title: '測試草稿',
        content: '草稿內容',
        templateType: DocumentTemplateType.depositDemand,
        createdAt: DateTime.now(),
      );

      await repo.init();
      repo.drafts.add(draft);
      expect(repo.drafts.length, 1);

      await repo.deleteDraft('test_draft_1');
      expect(repo.drafts.where((d) => d.id == 'test_draft_1'), isEmpty);
    });
  });
}
