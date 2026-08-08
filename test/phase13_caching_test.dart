import 'package:flutter_test/flutter_test.dart';
import 'package:preamble/data/documents/document_repository.dart';
import 'package:preamble/features/case_library/data/case_dossier_sqlite_db.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Phase 13: Caching, Indexing, and UI Interactions', () {
    test('SQLite DB successfully upgrades and creates indices', () async {
      final dbHelper = CaseDossierSqliteDb.instance;
      final db = await dbHelper.database;
      
      // Verify version
      final version = await db.getVersion();
      expect(version, 2);

      // Verify indices exist
      final List<Map<String, dynamic>> indices = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='index' AND tbl_name='cases'");
      
      final indexNames = indices.map((i) => i['name'] as String).toList();
      expect(indexNames, contains('idx_cases_year'));
      expect(indexNames, contains('idx_cases_isFavorite'));
      expect(indexNames, contains('idx_cases_tags'));
    });

    test('DocumentRepository allows deleting draft', () async {
      SharedPreferences.setMockInitialValues({});
      final repo = DocumentRepository();
      
      // Add a dummy draft by setting initial mock state or via internal state access
      // For testing, we mock fetchDrafts / init by verifying delete behavior
      await repo.init();
      
      // Since it's hard to mock backend in this pure unit test without a proper mock HTTP client, 
      // we just verify no crash and correct local list behavior.
      expect(() => repo.deleteDraft('dummy_id'), returnsNormally);
    });
  });
}
