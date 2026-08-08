import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:preamble/components/shared/mvp_state_widgets.dart';
import 'package:preamble/data/law_assistant/law_assistant_api_service.dart';
import 'package:preamble/data/documents/document_models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:preamble/utils/offline_request_queue.dart';
import 'package:preamble/utils/idempotency_manager.dart';

class DocumentTemplateOption {
  const DocumentTemplateOption({
    required this.type,
    required this.label,
    required this.hint,
  });

  final DocumentTemplateType type;
  final String label;
  final String hint;
}

class DocumentRepository extends ChangeNotifier {
  DocumentRepository({
    http.Client? client,
    AuthTokenProvider authTokenProvider = const GuestAuthTokenProvider(),
    String? baseUrl,
    List<DocumentDraft>? initialDrafts,
    SharedPreferences? prefs,
    this.isIncognito = false,
  })  : _client = client ?? http.Client(),
        _authTokenProvider = authTokenProvider,
        _baseUrl = baseUrl ??
            const String.fromEnvironment('PREAMBLE_API_BASE_URL').trim(),
        _prefs = prefs,
        _drafts = [
          ...?initialDrafts,
          if (initialDrafts == null) ..._seedDrafts
        ] {
    loadLocalDraftsFromDisk();
  }

  static const String _prefsKey = 'preamble_local_document_drafts_v1';
  final http.Client _client;
  final AuthTokenProvider _authTokenProvider;
  final String _baseUrl;
  SharedPreferences? _prefs;
  final List<DocumentDraft> _drafts;
  final bool isIncognito;
  String _backendMessage = '';

  bool get isBackendConfigured => _baseUrl.trim().isNotEmpty;

  List<DocumentTemplateOption> get templates => _templates;
  List<DocumentDraft> get drafts {
    final sortedDrafts = [..._drafts]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(sortedDrafts);
  }

  String get backendStatusLabel {
    if (_backendMessage.isNotEmpty) return _backendMessage;
    if (isBackendConfigured) return '文件後端已設定，草稿會同步到 /documents/drafts。';
    return '目前使用本機共用草稿來源；設定 PREAMBLE_API_BASE_URL 後會改走文件後端。';
  }

  Future<void> loadLocalDraftsFromDisk() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      final rawJson = _prefs?.getString(_prefsKey);
      if (rawJson != null && rawJson.isNotEmpty) {
        final decoded = await Isolate.run(() => jsonDecode(rawJson));
        if (decoded is List) {
          final loadedDrafts = decoded
              .whereType<Map<String, dynamic>>()
              .map(DocumentDraft.fromJson)
              .toList();

          for (final draft in loadedDrafts) {
            _upsertDraft(draft);
          }
          notifyListeners();
        }
      }
    } catch (__) {
      // 容錯防護，避免本機快取損毀導致崩潰
    }
  }

  Future<void> saveLocalDraftsToDisk() async {
    if (isIncognito) return;
    try {
      _prefs ??= await SharedPreferences.getInstance();
      final rawList = _drafts.map((d) => d.toJson()).toList();
      final encodedStr = await Isolate.run(() => jsonEncode(rawList));
      await _prefs?.setString(_prefsKey, encodedStr);
    } catch (__) {
      // 容錯防護
    }
  }

  Future<List<DocumentDraft>> fetchDrafts() async {
    if (!isBackendConfigured) {
      _backendMessage = '本機暫存模式：尚未設定 PREAMBLE_API_BASE_URL。';
      await loadLocalDraftsFromDisk();
      return drafts;
    }

    try {
      final response = await _client.get(
        _uri('/documents/drafts'),
        headers: await _headers(),
      );
      _ensureSuccess(response, '文件草稿讀取失敗');
      final remoteDrafts = _draftListFromResponse(response);
      _drafts
        ..clear()
        ..addAll(remoteDrafts);

      // 自動背景同步：若有本機未同步之草稿，嘗試自動上傳
      await _syncUnsyncedDrafts();

      _backendMessage = '文件後端同步完成：${_drafts.length} 份草稿。';
      await saveLocalDraftsToDisk();
      notifyListeners();
    } on Object catch (error) {
      _backendMessage = '文件後端暫時無法同步，先保留本機草稿：$error';
      await loadLocalDraftsFromDisk();
      notifyListeners();
    }

    return drafts;
  }

  Future<void> deleteDraft(String id) async {
    _drafts.removeWhere((d) => d.id == id);
    await saveLocalDraftsToDisk();
    notifyListeners();

    if (isBackendConfigured) {
      try {
        OfflineRequestQueue.instance.enqueue(
          method: 'DELETE',
          url: _uri('/documents/drafts/$id').toString(),
        );
      } catch (__) {
        // Ignored
      }
    }
  }

  Future<void> _syncUnsyncedDrafts() async {
    final unsynced = _drafts.where((d) => !d.isSyncedToBackend).toList();
    for (final draft in unsynced) {
      try {
        final response = await _client.post(
          _uri('/documents/drafts'),
          headers: await _headers(),
          body: jsonEncode({
            'templateType': draft.templateType.name,
            'title': draft.title,
            'input': {'facts': draft.content},
            'advanced': false,
          }),
        );
        if (response.statusCode >= 200 && response.statusCode < 300) {
          final updated = DocumentDraft(
            id: draft.id,
            title: draft.title,
            content: draft.content,
            templateType: draft.templateType,
            createdAt: draft.createdAt,
            isMock: draft.isMock,
            disclaimer: draft.disclaimer,
            isSyncedToBackend: true,
            sourceLabel: '後端同步',
          );
          _upsertDraft(updated);
        }
      } catch (__) {
        // 個別草稿同步失敗時保持離線狀態
      }
    }
  }

  Future<DocumentDraft> createDraft({
    required DocumentTemplateType templateType,
    required DocumentTemplateInput input,
    bool advanced = false,
    String? title,
  }) async {
    // 產生並檢查防重發 Key
    final idempotencyKey = IdempotencyManager.instance.generateKey();
    if (!IdempotencyManager.instance.markAsUsed(idempotencyKey)) {
      throw Exception('重複的請求已被阻擋');
    }

    if (isBackendConfigured && !isIncognito) {
      try {
        final draft = await _createBackendDraft(
          templateType: templateType,
          input: input,
          advanced: advanced,
          title: title,
        );
        _upsertDraft(draft);
        await saveLocalDraftsToDisk();
        _backendMessage = '文件後端同步完成：已保存「${draft.title}」。';
        notifyListeners();
        return draft;
      } on Object catch (error) {
        // 將請求放入離線佇列
        OfflineRequestQueue.instance.enqueue(
          endpoint: '/documents/drafts',
          payload: {
            'templateType': templateType.name,
            'input': input.toJson(),
            'advanced': advanced,
            'title': title,
            'idempotencyKey': idempotencyKey,
          },
        );
        _backendMessage = '文件後端暫時無法保存，已先寫入本機草稿與離線佇列：$error';
      }
    } else {
      _backendMessage = '本機暫存模式：尚未設定 PREAMBLE_API_BASE_URL。';
    }

    final draft = _localDraft(
      templateType,
      input,
      advanced: advanced,
      title: title,
    );
    _upsertDraft(draft);
    await saveLocalDraftsToDisk();
    notifyListeners();
    return draft;
  }

  /// 更新草稿，並將當前狀態存入版本紀錄
  Future<void> updateDraft(
    String draftId, {
    required String newContent,
    String? newTitle,
    Uint8List? newSignatureBytes,
  }) async {
    final index = _drafts.indexWhere((d) => d.id == draftId);
    if (index == -1) return;

    final currentDraft = _drafts[index];
    final version = DocumentVersion(
      content: currentDraft.content,
      savedAt: DateTime.now(),
    );

    final updatedDraft = DocumentDraft(
      id: currentDraft.id,
      title: newTitle ?? currentDraft.title,
      content: newContent,
      templateType: currentDraft.templateType,
      createdAt: currentDraft.createdAt,
      isMock: currentDraft.isMock,
      disclaimer: currentDraft.disclaimer,
      isSyncedToBackend: currentDraft.isSyncedToBackend,
      sourceLabel: currentDraft.sourceLabel,
      versions: [...currentDraft.versions, version],
      signatureBytes: newSignatureBytes ?? currentDraft.signatureBytes,
    );

    _drafts[index] = updatedDraft;
    
    if (!isIncognito) {
      await saveLocalDraftsToDisk();
      if (isBackendConfigured) {
        await _syncUnsyncedDrafts(); // 也可以寫入 queue，簡化處理
      }
    }
    
    notifyListeners();
  }

  /// 匯出草稿為 PNG 圖片並儲存至本機，回傳檔案路徑
  Future<String?> exportDraftAsImage(String draftId) async {
    final draft = _drafts.firstWhere((d) => d.id == draftId);
    
    // 建立畫布
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    const width = 800.0;
    
    // 白色背景
    canvas.drawRect(const ui.Rect.fromLTWH(0, 0, width, 2000), ui.Paint()..color = const ui.Color(0xFFFFFFFF));
    
    var yOffset = 40.0;
    
    // 繪製標題
    final titleStyle = ui.TextStyle(color: const ui.Color(0xFF000000), fontSize: 24, fontWeight: ui.FontWeight.bold);
    final titleParagraphBuilder = ui.ParagraphBuilder(ui.ParagraphStyle(textAlign: ui.TextAlign.center))
      ..pushStyle(titleStyle)
      ..addText(draft.title);
    final titleParagraph = titleParagraphBuilder.build()
      ..layout(const ui.ParagraphConstraints(width: width - 80));
    canvas.drawParagraph(titleParagraph, ui.Offset(40, yOffset));
    yOffset += titleParagraph.height + 40;
    
    // 繪製內文
    final bodyStyle = ui.TextStyle(color: const ui.Color(0xFF000000), fontSize: 18);
    final bodyParagraphBuilder = ui.ParagraphBuilder(ui.ParagraphStyle())
      ..pushStyle(bodyStyle)
      ..addText(draft.content);
    final bodyParagraph = bodyParagraphBuilder.build()
      ..layout(const ui.ParagraphConstraints(width: width - 80));
    canvas.drawParagraph(bodyParagraph, ui.Offset(40, yOffset));
    yOffset += bodyParagraph.height + 40;
    
    // 若有簽名，繪製簽名
    if (draft.signatureBytes != null) {
      try {
        final codec = await ui.instantiateImageCodec(draft.signatureBytes!);
        final frame = await codec.getNextFrame();
        final signatureImage = frame.image;
        
        final srcRect = ui.Rect.fromLTWH(0, 0, signatureImage.width.toDouble(), signatureImage.height.toDouble());
        final dstRect = ui.Rect.fromLTWH(40, yOffset, signatureImage.width.toDouble() * 0.5, signatureImage.height.toDouble() * 0.5);
        canvas.drawImageRect(signatureImage, srcRect, dstRect, ui.Paint());
        yOffset += dstRect.height + 40;
      } catch (__) {
        // ignore signature parsing errors
      }
    }
    
    // 輸出成圖片
    final picture = recorder.endRecording();
    final img = await picture.toImage(width.toInt(), yOffset.toInt());
    final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);
    if (pngBytes == null) return null;
    
    // 寫入檔案
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/draft_${draft.id}.png');
    await file.writeAsBytes(pngBytes.buffer.asUint8List());
    
    return file.path;
  }

  DocumentDraft _localDraft(
    DocumentTemplateType type,
    DocumentTemplateInput input, {
    required bool advanced,
    String? title,
  }) {
    final now = DateTime.now();
    final template = _templates.firstWhere((item) => item.type == type);
    final sender = input.senderName.trim().isEmpty ? '本人' : input.senderName;
    final receiver =
        input.receiverName.trim().isEmpty ? '相對人' : input.receiverName;
    final facts = input.facts.trim().isEmpty
        ? '請補充事件時間、地點、雙方約定、目前爭議與已保存證據。'
        : input.facts.trim();
    final request = input.extraRequest.trim().isEmpty
        ? _defaultRequest(type)
        : input.extraRequest.trim();
    final eventDate = input.eventDate.trim();
    final eventPlace = input.eventPlace.trim();
    final evidence = input.evidence.trim().isEmpty
        ? _attachments(type)
        : input.evidence.trim();
    final tone = input.toneLabel.trim();

    final content = [
      '【${title ?? template.label}】',
      '',
      '$receiver 您好：',
      '我是 $sender，為避免雙方誤會擴大，先將目前狀況整理如下。',
      '',
      '一、發生時間與地點',
      [
        if (eventDate.isNotEmpty) eventDate,
        if (eventPlace.isNotEmpty) eventPlace,
      ].join('｜').ifEmpty('請補充事件時間與地點。'),
      '',
      '二、事實摘要',
      facts,
      '',
      '三、希望回覆或處理事項',
      request,
      '',
      '四、建議附件',
      evidence,
      '',
      '五、提醒',
      if (tone.isNotEmpty) '目前草稿語氣：$tone。',
      advanced ? '此為進階語氣草稿，正式寄發前仍建議由律師依完整資料審閱。' : '此為本地模板草稿，僅適合初步溝通與整理。'
    ].join('\n');

    return DocumentDraft(
      id: 'local-${type.name}-${now.microsecondsSinceEpoch}',
      title: title ?? template.label,
      content: content,
      templateType: type,
      createdAt: now,
      isMock: true,
      disclaimer: lawAppLegalDisclaimer,
      isSyncedToBackend: false,
      sourceLabel: '本機暫存',
    );
  }

  Future<DocumentDraft> _createBackendDraft({
    required DocumentTemplateType templateType,
    required DocumentTemplateInput input,
    required bool advanced,
    String? title,
  }) async {
    final response = await _client.post(
      _uri('/documents/drafts'),
      headers: await _headers(),
      body: jsonEncode({
        'templateType': templateType.name,
        'title': title,
        'input': input.toJson(),
        'advanced': advanced,
      }),
    );
    _ensureSuccess(response, '文件草稿建立失敗');

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    final draftJson = decoded is Map<String, dynamic> && decoded['draft'] is Map
        ? Map<String, dynamic>.from(decoded['draft'] as Map)
        : decoded as Map<String, dynamic>;
    final draft = DocumentDraft.fromJson(draftJson);
    return DocumentDraft(
      id: draft.id,
      title:
          draft.title.isEmpty ? title ?? _labelFor(templateType) : draft.title,
      content: draft.content,
      templateType: draft.templateType,
      createdAt: draft.createdAt,
      isMock: false,
      disclaimer:
          draft.disclaimer.isEmpty ? lawAppLegalDisclaimer : draft.disclaimer,
      isSyncedToBackend: true,
      sourceLabel: '後端同步',
    );
  }

  List<DocumentDraft> _draftListFromResponse(http.Response response) {
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    final list = decoded is List ? decoded : decoded['drafts'];
    if (list is! List) return const [];
    return list.whereType<Map>().map((item) {
      final draft = DocumentDraft.fromJson(Map<String, dynamic>.from(item));
      return DocumentDraft(
        id: draft.id,
        title: draft.title,
        content: draft.content,
        templateType: draft.templateType,
        createdAt: draft.createdAt,
        isMock: draft.isMock,
        disclaimer:
            draft.disclaimer.isEmpty ? lawAppLegalDisclaimer : draft.disclaimer,
        isSyncedToBackend: true,
        sourceLabel: draft.sourceLabel,
      );
    }).toList(growable: false);
  }

  void _upsertDraft(DocumentDraft draft) {
    final index = _drafts.indexWhere((item) => item.id == draft.id);
    if (index == -1) {
      _drafts.insert(0, draft);
    } else {
      _drafts[index] = draft;
    }
  }

  String _labelFor(DocumentTemplateType type) {
    return _templates.firstWhere((item) => item.type == type).label;
  }

  Uri _uri(String path) {
    final normalizedBaseUrl = _baseUrl.endsWith('/')
        ? _baseUrl.substring(0, _baseUrl.length - 1)
        : _baseUrl;
    return Uri.parse('$normalizedBaseUrl$path');
  }

  Future<Map<String, String>> _headers() async {
    final token = await _authTokenProvider.getAuthToken();
    return {
      'Content-Type': 'application/json; charset=utf-8',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  void _ensureSuccess(http.Response response, String fallbackMessage) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;

    var message = fallbackMessage;
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is Map && decoded['message'] != null) {
        message = decoded['message'].toString();
      }
    } catch (__) {
      // 後端錯誤格式可能隨部署版本變動，解析失敗時保留預設文案讓 UI 可讀。
    }

    throw DocumentRepositoryException('$message（HTTP ${response.statusCode}）');
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }

  String _defaultRequest(DocumentTemplateType type) {
    switch (type) {
      case DocumentTemplateType.depositDemand:
      case DocumentTemplateType.rentalDepositNegotiation:
        return '請提供扣款項目、金額、照片或收據等明細；若無具體依據，請安排返還押金。';
      case DocumentTemplateType.carAccidentChecklist:
        return '請確認事故時間、地點、車號、保險資訊，以及後續是否申請調解。';
      case DocumentTemplateType.consumerComplaint:
        return '請說明商品或服務處理方案、退款或補償方式，以及預計回覆時間。';
      case DocumentTemplateType.laborDisputeMessage:
        return '請協助確認工時、薪資、加班費或離職相關爭議的公司認定依據。';
    }
  }

  String _attachments(DocumentTemplateType type) {
    switch (type) {
      case DocumentTemplateType.depositDemand:
      case DocumentTemplateType.rentalDepositNegotiation:
        return '租約、匯款紀錄、點交照片、對話紀錄、修繕報價或收據。';
      case DocumentTemplateType.carAccidentChecklist:
        return '現場照片、行車紀錄器、初判表、報案三聯單、醫療單據、保險聯絡紀錄。';
      case DocumentTemplateType.consumerComplaint:
        return '訂單、發票、商品照片、客服對話、退貨紀錄、付款紀錄。';
      case DocumentTemplateType.laborDisputeMessage:
        return '班表、打卡紀錄、薪資單、通訊軟體指派工作紀錄、補休紀錄。';
    }
  }
}

const _templates = [
  DocumentTemplateOption(
    type: DocumentTemplateType.depositDemand,
    label: '存證信函草稿',
    hint: '適合正式寄發前整理請求與附件。',
  ),
  DocumentTemplateOption(
    type: DocumentTemplateType.rentalDepositNegotiation,
    label: '租屋押金協商訊息',
    hint: '適合先用訊息溝通押金返還與扣款明細。',
  ),
  DocumentTemplateOption(
    type: DocumentTemplateType.carAccidentChecklist,
    label: '車禍和解前資料清單',
    hint: '整理事故事實、保險與調解前資料。',
  ),
  DocumentTemplateOption(
    type: DocumentTemplateType.consumerComplaint,
    label: '消費爭議申訴草稿',
    hint: '適合網購、服務瑕疵、退款或客服爭議。',
  ),
  DocumentTemplateOption(
    type: DocumentTemplateType.laborDisputeMessage,
    label: '勞資爭議溝通草稿',
    hint: '適合工時、加班費、薪資與離職溝通。',
  ),
];

extension on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}

class DocumentRepositoryException implements Exception {
  const DocumentRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}

final _seedDrafts = [
  DocumentDraft(
    id: 'seed-rental-deposit',
    title: '押金返還通知（協商語氣）',
    content: [
      '【押金返還通知】',
      '',
      '陳房東 您好：',
      '我是王小明，想先把押金返還這件事整理清楚，請您協助回覆。',
      '',
      '一、目前爭議',
      '退租後對方表示要全額扣押金，但尚未提供修繕明細。',
      '',
      '二、希望處理方式',
      '請提供扣款明細；若無具體依據，請安排返還押金。',
      '',
      '三、提醒',
      lawAppLegalDisclaimer,
    ].join('\n'),
    templateType: DocumentTemplateType.rentalDepositNegotiation,
    createdAt: DateTime(2026, 5, 1, 14, 30),
    isMock: true,
    disclaimer: lawAppLegalDisclaimer,
    sourceLabel: '本機示範',
  ),
  DocumentDraft(
    id: 'seed-labor-overtime',
    title: '加班費協商草稿',
    content: '這是加班費協商的示範草稿，可作為列表視覺與狀態演示。',
    templateType: DocumentTemplateType.laborDisputeMessage,
    createdAt: DateTime(2026, 4, 30, 10, 15),
    isMock: true,
    disclaimer: lawAppLegalDisclaimer,
    sourceLabel: '本機示範',
  ),
  DocumentDraft(
    id: 'seed-car-accident',
    title: '車禍紀錄備忘',
    content: '這是車禍紀錄備忘的示範草稿，可作為列表視覺與狀態演示。',
    templateType: DocumentTemplateType.carAccidentChecklist,
    createdAt: DateTime(2026, 4, 28, 9, 20),
    isMock: true,
    disclaimer: lawAppLegalDisclaimer,
    sourceLabel: '本機示範',
  ),
];
