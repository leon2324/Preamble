import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:lawapp/features/case_time_machine/models/case_time_machine_models.dart';

class CaseDossierSqliteDb {
  CaseDossierSqliteDb._privateConstructor();
  static final CaseDossierSqliteDb instance =
      CaseDossierSqliteDb._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final pathString = join(dbPath, 'case_dossier.db');

    return await openDatabase(
      pathString,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 建立 cases 主表，將複雜關聯以 JSON 字串儲存（極適合本地離線唯讀/標記結構）
    await db.execute('''
      CREATE TABLE cases (
        id TEXT PRIMARY KEY,
        titleZh TEXT NOT NULL,
        titleEn TEXT,
        shortTitleZh TEXT,
        shortTitleEn TEXT,
        displayCode TEXT,
        year INTEGER NOT NULL,
        location TEXT,
        status TEXT,
        category TEXT,
        tags TEXT,
        memoryLine TEXT,
        shortDescription TEXT,
        oneSentenceSummary TEXT,
        background TEXT,
        fullStory TEXT,
        investigationAndTrial TEXT,
        courtReasoning TEXT,
        judgmentResult TEXT,
        socialImpact TEXT,
        isFavorite INTEGER DEFAULT 0,
        isFollowing INTEGER DEFAULT 0,
        caseType TEXT,
        procedureStage TEXT,
        courtLevel TEXT,
        updatedAt TEXT,
        timeline TEXT,
        people TEXT,
        legalIssues TEXT,
        relatedLaws TEXT,
        relatedCases TEXT,
        sources TEXT,
        concurringDissentingOpinions TEXT,
        courtArguments TEXT,
        expertOpinions TEXT,
        mediaReferences TEXT,
        images TEXT
      )
    ''');

    // 建立索引加速搜尋
    await db.execute('CREATE INDEX idx_cases_category ON cases(category)');
    await db.execute('CREATE INDEX idx_cases_year ON cases(year)');

    // 第一次建庫時自動寫入 15 案高品質真實案件作為種子資料 (Seeding)
    await _seedDatabase(db);
  }

  Future<void> _seedDatabase(Database db) async {
    // 配合 Supabase 10,000 筆真實案件計畫，不再向本地 SQLite 寫入任何 Legacy 寫死 Mock 案件。
    // 本地 SQLite 僅做為 Supabase 雲端裁判資料之唯讀與標記快取。
  }

  /// 清除 SQLite 中已存在的 Legacy 舊案件資料
  Future<void> clearLegacyCases() async {
    final db = await database;
    final legacyIds = [
      '318',
      '799',
      '499',
      '520',
      'hung-2013',
      'ding-2015',
      '101',
      '102',
      '103',
      '104',
      '105',
      '106',
      '124',
      '161',
      '228',
      'cheng-2021'
    ];
    final batch = db.batch();
    for (final id in legacyIds) {
      batch.delete('cases', where: 'id = ?', whereArgs: [id]);
    }
    await batch.commit(noResult: true);
  }

  Map<String, dynamic> _caseBookToMap(CaseBook book) {
    return {
      'id': book.id,
      'titleZh': book.titleZh,
      'titleEn': book.titleEn,
      'shortTitleZh': book.shortTitleZh,
      'shortTitleEn': book.shortTitleEn,
      'displayCode': book.displayCode,
      'year': book.year,
      'location': book.location,
      'status': book.status,
      'category': book.category,
      'tags': jsonEncode(book.tags),
      'memoryLine': book.memoryLine,
      'shortDescription': book.shortDescription,
      'oneSentenceSummary': book.oneSentenceSummary,
      'background': book.background,
      'fullStory': book.fullStory,
      'investigationAndTrial': book.investigationAndTrial,
      'courtReasoning': book.courtReasoning,
      'judgmentResult': book.judgmentResult,
      'socialImpact': book.socialImpact,
      'isFavorite': book.isFavorite ? 1 : 0,
      'isFollowing': book.isFollowing ? 1 : 0,
      'caseType': book.basicInfo.caseType,
      'procedureStage': book.basicInfo.procedureStage,
      'courtLevel': book.basicInfo.courtLevel,
      'updatedAt': book.basicInfo.updatedAt,
      'timeline': jsonEncode(book.timeline
          .map((item) => {
                'dateLabel': item.dateLabel,
                'title': item.title,
                'description': item.description,
              })
          .toList()),
      'people': jsonEncode(book.people
          .map((p) => {
                'role': p.role,
                'description': p.description,
              })
          .toList()),
      'legalIssues': jsonEncode(book.legalIssues
          .map((issue) => {
                'title': issue.title,
                'plainExplanation': issue.plainExplanation,
                'relationToCase': issue.relationToCase,
                'relatedLawIds': issue.relatedLawIds,
              })
          .toList()),
      'relatedLaws': jsonEncode(book.relatedLaws
          .map((law) => {
                'lawName': law.lawName,
                'articleNumber': law.articleNumber,
                'plainSummary': law.plainSummary,
                'relationToCase': law.relationToCase,
              })
          .toList()),
      'relatedCases': jsonEncode(book.relatedCases
          .map((rc) => {
                'caseId': rc.caseId,
                'title': rc.title,
                'yearLabel': rc.yearLabel,
                'reason': rc.reason,
              })
          .toList()),
      'sources': jsonEncode(book.sources
          .map((s) => {
                'title': s.title,
                'sourceType': s.sourceType,
                'updatedAt': s.updatedAt,
                'url': s.url,
              })
          .toList()),
      'concurringDissentingOpinions':
          jsonEncode(book.concurringDissentingOpinions
              .map((o) => {
                    'justiceName': o.justiceName,
                    'opinionType': o.opinionType,
                    'summary': o.summary,
                  })
              .toList()),
      'courtArguments': jsonEncode(book.courtArguments
          .map((a) => {
                'partyName': a.partyName,
                'mainPoint': a.mainPoint,
              })
          .toList()),
      'expertOpinions': jsonEncode(book.expertOpinions
          .map((o) => {
                'expertName': o.expertName,
                'title': o.title,
                'summary': o.summary,
              })
          .toList()),
      'mediaReferences': jsonEncode(book.mediaReferences
          .map((m) => {
                'title': m.title,
                'platform': m.platform,
                'url': m.url,
                'mediaType': m.mediaType,
              })
          .toList()),
      'images': jsonEncode(book.images
          .map((img) => {
                'url': img.url,
                'source': img.source,
              })
          .toList()),
    };
  }

  CaseBook _mapToCaseBook(Map<String, dynamic> map) {
    final tagsList =
        List<String>.from(jsonDecode(map['tags'] as String? ?? '[]'));

    final timelineList =
        (jsonDecode(map['timeline'] as String? ?? '[]') as List)
            .map((item) => CaseTimelineItem(
                  dateLabel: item['dateLabel'] as String? ?? '',
                  title: item['title'] as String? ?? '',
                  description: item['description'] as String? ?? '',
                ))
            .toList();

    final peopleList = (jsonDecode(map['people'] as String? ?? '[]') as List)
        .map((item) => CasePersonRole(
              role: item['role'] as String? ?? '',
              description: item['description'] as String? ?? '',
            ))
        .toList();

    final legalIssuesList =
        (jsonDecode(map['legalIssues'] as String? ?? '[]') as List)
            .map((item) => LegalIssue(
                  title: item['title'] as String? ?? '',
                  plainExplanation: item['plainExplanation'] as String? ?? '',
                  relationToCase: item['relationToCase'] as String? ?? '',
                  relatedLawIds:
                      List<String>.from(item['relatedLawIds'] as List? ?? []),
                ))
            .toList();

    final relatedLawsList =
        (jsonDecode(map['relatedLaws'] as String? ?? '[]') as List)
            .map((item) => RelatedLaw(
                  lawName: item['lawName'] as String? ?? '',
                  articleNumber: item['articleNumber'] as String? ?? '',
                  plainSummary: item['plainSummary'] as String? ?? '',
                  relationToCase: item['relationToCase'] as String? ?? '',
                ))
            .toList();

    final relatedCasesList =
        (jsonDecode(map['relatedCases'] as String? ?? '[]') as List)
            .map((item) => RelatedCase(
                  caseId: item['caseId'] as String? ?? '',
                  title: item['title'] as String? ?? '',
                  yearLabel: item['yearLabel'] as String? ?? '',
                  reason: item['reason'] as String? ?? '',
                ))
            .toList();

    final sourcesList = (jsonDecode(map['sources'] as String? ?? '[]') as List)
        .map((item) => CaseSource(
              title: item['title'] as String? ?? '',
              sourceType: item['sourceType'] as String? ?? '',
              updatedAt: item['updatedAt'] as String? ?? '',
              url: item['url'] as String?,
            ))
        .toList();

    final concurringDissentingOpinionsList =
        (jsonDecode(map['concurringDissentingOpinions'] as String? ?? '[]')
                as List)
            .map((item) => CaseOpinion(
                  justiceName: item['justiceName'] as String? ?? '',
                  opinionType: item['opinionType'] as String? ?? '',
                  summary: item['summary'] as String? ?? '',
                ))
            .toList();

    final courtArgumentsList =
        (jsonDecode(map['courtArguments'] as String? ?? '[]') as List)
            .map((item) => CourtArgument(
                  partyName: item['partyName'] as String? ?? '',
                  mainPoint: item['mainPoint'] as String? ?? '',
                ))
            .toList();

    final expertOpinionsList =
        (jsonDecode(map['expertOpinions'] as String? ?? '[]') as List)
            .map((item) => ExpertOpinion(
                  expertName: item['expertName'] as String? ?? '',
                  title: item['title'] as String? ?? '',
                  summary: item['summary'] as String? ?? '',
                ))
            .toList();

    final mediaReferencesList =
        (jsonDecode(map['mediaReferences'] as String? ?? '[]') as List)
            .map((item) => MediaReference(
                  title: item['title'] as String? ?? '',
                  platform: item['platform'] as String? ?? '',
                  url: item['url'] as String? ?? '',
                  mediaType: item['mediaType'] as String? ?? '',
                ))
            .toList();

    final imagesList = (jsonDecode(map['images'] as String? ?? '[]') as List)
        .map((item) => CaseImage(
              url: item['url'] as String? ?? '',
              source: item['source'] as String? ?? '',
            ))
        .toList();

    return CaseBook(
      id: map['id'] as String,
      titleZh: map['titleZh'] as String,
      titleEn: map['titleEn'] as String? ?? '',
      shortTitleZh: map['shortTitleZh'] as String? ?? '',
      shortTitleEn: map['shortTitleEn'] as String? ?? '',
      displayCode: map['displayCode'] as String? ?? '',
      year: map['year'] as int,
      location: map['location'] as String? ?? '',
      status: map['status'] as String? ?? '',
      category: map['category'] as String? ?? '',
      tags: tagsList,
      memoryLine: map['memoryLine'] as String? ?? '',
      shortDescription: map['shortDescription'] as String? ?? '',
      oneSentenceSummary: map['oneSentenceSummary'] as String? ?? '',
      background: map['background'] as String? ?? '',
      fullStory: map['fullStory'] as String? ?? '',
      investigationAndTrial: map['investigationAndTrial'] as String? ?? '',
      courtReasoning: map['courtReasoning'] as String? ?? '',
      judgmentResult: map['judgmentResult'] as String? ?? '',
      socialImpact: map['socialImpact'] as String? ?? '',
      isFavorite: (map['isFavorite'] as int? ?? 0) == 1,
      isFollowing: (map['isFollowing'] as int? ?? 0) == 1,
      basicInfo: CaseBasicInfo(
        caseType: map['caseType'] as String? ?? '',
        procedureStage: map['procedureStage'] as String? ?? '',
        courtLevel: map['courtLevel'] as String? ?? '',
        updatedAt: map['updatedAt'] as String? ?? '',
      ),
      timeline: timelineList,
      people: peopleList,
      legalIssues: legalIssuesList,
      relatedLaws: relatedLawsList,
      relatedCases: relatedCasesList,
      sources: sourcesList,
      concurringDissentingOpinions: concurringDissentingOpinionsList,
      courtArguments: courtArgumentsList,
      expertOpinions: expertOpinionsList,
      mediaReferences: mediaReferencesList,
      images: imagesList,
    );
  }

  // --- 資料庫 CRUD API ---

  Future<void> insertCase(CaseBook book) async {
    final db = await database;
    await db.insert(
      'cases',
      _caseBookToMap(book),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertCases(List<CaseBook> books) async {
    final db = await database;
    final batch = db.batch();
    for (final book in books) {
      batch.insert(
        'cases',
        _caseBookToMap(book),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<CaseBook?> getCaseById(String id) async {
    final db = await database;
    final maps = await db.query(
      'cases',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return _mapToCaseBook(maps.first);
  }

  Future<List<CaseBook>> getAllCases() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('cases');
    return maps.map((map) => _mapToCaseBook(map)).toList();
  }

  Future<List<CaseBook>> getCasesForShelf(List<String> caseIds) async {
    if (caseIds.isEmpty) return [];
    final db = await database;
    final placeholders = List.filled(caseIds.length, '?').join(',');
    final List<Map<String, dynamic>> maps = await db.query(
      'cases',
      where: 'id IN ($placeholders)',
      whereArgs: caseIds,
    );
    return maps.map((map) => _mapToCaseBook(map)).toList();
  }

  Future<List<CaseBook>> searchCases(String query) async {
    if (query.trim().isEmpty) return getAllCases();
    final db = await database;
    final likeQuery = '%$query%';
    final List<Map<String, dynamic>> maps = await db.query(
      'cases',
      where:
          'titleZh LIKE ? OR category LIKE ? OR shortDescription LIKE ? OR background LIKE ?',
      whereArgs: [likeQuery, likeQuery, likeQuery, likeQuery],
    );
    return maps.map((map) => _mapToCaseBook(map)).toList();
  }

  Future<void> updateFavorite(String id, bool isFavorite) async {
    final db = await database;
    await db.update(
      'cases',
      {'isFavorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateFollowing(String id, bool isFollowing) async {
    final db = await database;
    await db.update(
      'cases',
      {'isFollowing': isFollowing ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 分頁加載與過濾查詢，支援 10 萬級海量案卷高效讀取
  Future<List<CaseBook>> getCasesPaginated(
    int limit,
    int offset, {
    String? category,
    String? query,
  }) async {
    final db = await database;
    String? whereClause;
    List<dynamic>? whereArgs;

    if (category != null && query != null) {
      whereClause =
          'category = ? AND (id = ? OR titleZh LIKE ? OR shortDescription LIKE ? OR background LIKE ?)';
      final likeQuery = '%$query%';
      whereArgs = [category, query.trim(), likeQuery, likeQuery, likeQuery];
    } else if (category != null) {
      whereClause = 'category = ?';
      whereArgs = [category];
    } else if (query != null) {
      whereClause =
          'id = ? OR titleZh LIKE ? OR category LIKE ? OR shortDescription LIKE ? OR background LIKE ?';
      final likeQuery = '%$query%';
      whereArgs = [query.trim(), likeQuery, likeQuery, likeQuery, likeQuery];
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'cases',
      where: whereClause,
      whereArgs: whereArgs,
      limit: limit,
      offset: offset,
      orderBy: 'year DESC, id DESC',
    );

    return maps.map((map) => _mapToCaseBook(map)).toList();
  }
}
