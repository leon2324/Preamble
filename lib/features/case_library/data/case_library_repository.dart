import 'package:preamble/features/case_library/models/case_library_models.dart';
import 'package:preamble/features/case_library/data/case_dossier_sqlite_db.dart';
import 'package:preamble/features/case_library/data/case_library_data.dart';
import 'package:preamble/features/case_library/data/supabase_case_service.dart';

class CaseLibraryRepository {
  CaseLibraryRepository._privateConstructor();
  static final CaseLibraryRepository instance =
      CaseLibraryRepository._privateConstructor();

  final List<CaseBook> _casesCache = [];
  bool _initialized = false;

  List<CaseBook> get cases => _casesCache;

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      // 確保 SQLite 初始化
      final db = CaseDossierSqliteDb.instance;
      await db.database; // 觸發 onCreate

      // 清除本地 SQLite 中可能殘留的 Legacy 舊案件資料
      await db.clearLegacyCases();

      // 載入所有真實快取案件到記憶體快取
      final all = await db.getAllCases();
      _casesCache.clear();
      _casesCache.addAll(all);
    } catch (e) {
      // 在單元測試或不支援 sqflite 的平台上，捕獲異常並降級使用記憶體 Mock Seed
      print('SQLite initialization bypassed (expected in unit tests): $e');
      _casesCache.clear();
      _casesCache.addAll(caseLibraryCasesSeed);
    }
    _initialized = true;
  }

  // 對應舊有的 caseLibraryCaseById 同步取得
  CaseBook getCaseById(String id) {
    final foundIndex = _casesCache.indexWhere((c) => c.id == id);
    if (foundIndex != -1) {
      return _casesCache[foundIndex];
    }

    // 當本機 SQLite 快取尚未載入時，從案件種子資料庫中檢索
    final seedIndex = caseLibraryCasesSeed.indexWhere((c) => c.id == id);
    if (seedIndex != -1) {
      return caseLibraryCasesSeed[seedIndex];
    }

    // 找不到時，不應隨便回傳第一個 Legacy 元素。
    // 建立一個 Placeholder CaseBook，使 UI 在跳轉詳情頁時能正確透過該 ID 向 Supabase 獲取真實資料。
    return CaseBook(
      id: id,
      titleZh: '案件載入中...',
      titleEn: '',
      shortTitleZh: '',
      shortTitleEn: '',
      displayCode: '',
      year: 0,
      location: '',
      status: '',
      category: '',
      tags: const [],
      memoryLine: '',
      shortDescription: '正在調閱雲端案件詳情，請稍候...',
      basicInfo: const CaseBasicInfo(
        caseType: '',
        procedureStage: '',
        courtLevel: '',
        updatedAt: '',
      ),
      oneSentenceSummary: '',
      background: '',
      fullStory: '',
      timeline: const [],
      people: const [],
      legalIssues: const [],
      investigationAndTrial: '',
      courtReasoning: '',
      judgmentResult: '',
      relatedLaws: const [],
      socialImpact: '',
      relatedCases: const [],
      sources: const [],
    );
  }

  // 異步分頁查詢以支援 10 萬案高階搜尋與目錄
  Future<List<CaseBook>> getCasesPaginated(
    int limit,
    int offset, {
    String? category,
    String? query,
  }) async {
    if (!_initialized) {
      await initialize();
    }
    // 優先判定是否使用 Supabase 雲端資料庫
    if (SupabaseCaseService.instance.isConfigured) {
      try {
        final cloudCases = await SupabaseCaseService.instance.fetchCases(
          limit,
          offset,
          category: category,
          query: query,
        );

        final List<CaseBook> merged = [];
        for (final c in cloudCases) {
          // 查詢本地 SQLite 是否有追蹤/收藏標記，並進行合併
          try {
            final local = await CaseDossierSqliteDb.instance.getCaseById(c.id);
            if (local != null) {
              final mergedCase = c.copyWith(
                isFavorite: local.isFavorite,
                isFollowing: local.isFollowing,
              );
              merged.add(mergedCase);
              // 同步寫入本地 SQLite 快取中繼資料
              await CaseDossierSqliteDb.instance.insertCase(mergedCase);
            } else {
              merged.add(c);
              await CaseDossierSqliteDb.instance.insertCase(c);
            }
          } catch (__) {
            merged.add(c);
          }
        }
        if (query != null && query.trim().isNotEmpty) {
          final q = query.trim().toLowerCase();
          merged.sort((a, b) {
            if (a.id.toLowerCase() == q && b.id.toLowerCase() != q) return -1;
            if (b.id.toLowerCase() == q && a.id.toLowerCase() != q) return 1;
            return 0;
          });
        }
        return merged;
      } catch (e) {
        print('Supabase fetch query failed, fallback to local: $e');
      }
    }

    try {
      final localResults = await CaseDossierSqliteDb.instance.getCasesPaginated(
        limit,
        offset,
        category: category,
        query: query,
      );
      if (query != null && query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        localResults.sort((a, b) {
          if (a.id.toLowerCase() == q && b.id.toLowerCase() != q) return -1;
          if (b.id.toLowerCase() == q && a.id.toLowerCase() != q) return 1;
          return 0;
        });
      }
      return localResults;
    } catch (e) {
      // 若在不支援 SQLite 的測試環境中，降級由記憶體快取進行過濾與分頁切片
      print('SQLite query failed, falling back to cache: $e');
      Iterable<CaseBook> filtered = _casesCache;

      if (category != null && category != '全部') {
        filtered = filtered.where((c) => c.category == category);
      }

      if (query != null && query.trim().isNotEmpty) {
        final lowerQuery = query.toLowerCase();
        filtered = filtered.where((c) =>
            c.titleZh.toLowerCase().contains(lowerQuery) ||
            c.category.toLowerCase().contains(lowerQuery) ||
            c.shortDescription.toLowerCase().contains(lowerQuery) ||
            c.background.toLowerCase().contains(lowerQuery));
      }

      final sorted = filtered.toList()
        ..sort((a, b) {
          final yearCompare = b.year.compareTo(a.year);
          if (yearCompare != 0) return yearCompare;
          return b.id.compareTo(a.id);
        });

      if (offset >= sorted.length) return [];
      final end =
          (offset + limit) < sorted.length ? (offset + limit) : sorted.length;
      return sorted.sublist(offset, end);
    }
  }

  // 異步載入完整案件詳情，支援本地快取同步（Phase 2 核心）
  Future<CaseBook> getCaseDetail(String id) async {
    if (!_initialized) {
      await initialize();
    }
    // 1. 先從本地 SQLite 查詢是否有快取
    try {
      final local = await CaseDossierSqliteDb.instance.getCaseById(id);
      // 必須確認該快取包含完整的詳情資料（如 background 或 fullStory 不為空），
      // 否則可能只是列表查詢時存入的輕量中繼資料（metadata）。
      if (local != null &&
          local.fullStory.isNotEmpty &&
          local.timeline.isNotEmpty) {
        return local;
      }
    } catch (e) {
      print('Local cache read failed: $e');
    }

    // 2. 本地無快取或資料不完整，從 Supabase（或本地模擬）載入完整詳情
    final fetched = await SupabaseCaseService.instance.fetchCaseDetail(id);

    // 3. 異步寫入本地 SQLite 快取（快取同步）
    try {
      // 合併本地收藏與追蹤狀態，確保寫入時狀態不被覆蓋
      bool localFavorite = fetched.isFavorite;
      bool localFollowing = fetched.isFollowing;
      try {
        final local = await CaseDossierSqliteDb.instance.getCaseById(id);
        if (local != null) {
          localFavorite = local.isFavorite;
          localFollowing = local.isFollowing;
        }
      } catch (__) {}

      final finalBook = fetched.copyWith(
        isFavorite: localFavorite,
        isFollowing: localFollowing,
      );

      await CaseDossierSqliteDb.instance.insertCase(finalBook);

      // 同步更新記憶體 cache 陣列以確保同步 UI 同步
      final cacheIndex = _casesCache.indexWhere((c) => c.id == id);
      if (cacheIndex != -1) {
        _casesCache[cacheIndex] = finalBook;
      } else {
        _casesCache.add(finalBook);
      }
      return finalBook;
    } catch (e) {
      print('Failed to cache case detail: $e');
      return fetched;
    }
  }

  // [審查修復] toggleFavorite / toggleFollowing 原本手動逐一複製 CaseBook 的 30+ 個屬性，
  // 這種寫法非常脆弱：只要 CaseBook model 新增欄位，這裡忘記加就會造成資料遺失。
  // 同一個檔案的 getCaseDetail() 已經正確使用 copyWith()，這裡也統一改用。
  // 教學重點：永遠優先使用 copyWith() 做不可變物件的部分更新，避免手動屬性複製。
  Future<void> toggleFavorite(String id, bool isFavorite) async {
    await CaseDossierSqliteDb.instance.updateFavorite(id, isFavorite);
    // 同步更新記憶體快取
    final index = _casesCache.indexWhere((c) => c.id == id);
    if (index != -1) {
      _casesCache[index] = _casesCache[index].copyWith(isFavorite: isFavorite);
    }
  }

  Future<void> toggleFollowing(String id, bool isFollowing) async {
    await CaseDossierSqliteDb.instance.updateFollowing(id, isFollowing);
    // 同步更新記憶體快取
    final index = _casesCache.indexWhere((c) => c.id == id);
    if (index != -1) {
      _casesCache[index] = _casesCache[index].copyWith(isFollowing: isFollowing);
    }
  }
}
