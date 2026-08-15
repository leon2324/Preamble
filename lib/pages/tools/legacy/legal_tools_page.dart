import 'package:flutter/material.dart';
import 'package:preamble/components/shared/custom_toast.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:preamble/app/app_state.dart';
import 'package:preamble/components/shared/mvp_state_widgets.dart';
import 'package:preamble/data/documents/document_models.dart';
import 'package:preamble/pages/tools/widgets/document_form_stepper.dart';

enum _ToolPage {
  home,
  scenario,
  details,
  preview,
  drafts,
  evidence,
  pro,
  notice
}

enum _ToolStep { scenario, details, preview }

enum _DraftTone { friendly, formal }

enum _DocumentScenario {
  depositDemand,
  overtimeNegotiation,
  carAccidentMemo,
  consumerComplaint,
  laborDisputeMessage,
}

extension _DocumentScenarioInfo on _DocumentScenario {
  String get title {
    switch (this) {
      case _DocumentScenario.depositDemand:
        return '押金返還通知';
      case _DocumentScenario.overtimeNegotiation:
        return '加班費協商';
      case _DocumentScenario.carAccidentMemo:
        return '車禍紀錄備忘';
      case _DocumentScenario.consumerComplaint:
        return '消費爭議申訴';
      case _DocumentScenario.laborDisputeMessage:
        return '勞資爭議溝通草稿';
    }
  }

  String get subtitle {
    switch (this) {
      case _DocumentScenario.depositDemand:
        return '租屋退租、押金扣款、修繕明細';
      case _DocumentScenario.overtimeNegotiation:
        return '工時、補休、加班費與薪資明細';
      case _DocumentScenario.carAccidentMemo:
        return '事故時間、照片、保險與調解資料';
      case _DocumentScenario.consumerComplaint:
        return '網購退貨、瑕疵商品與客服紀錄';
      case _DocumentScenario.laborDisputeMessage:
        return '離職、排班、工資與職場溝通';
    }
  }

  String get sampleIssue {
    switch (this) {
      case _DocumentScenario.depositDemand:
        return '退租後對方表示要全額扣押金，但尚未提供修繕明細。';
      case _DocumentScenario.overtimeNegotiation:
        return '公司要求加班只能補休，尚未說明加班費計算方式。';
      case _DocumentScenario.carAccidentMemo:
        return '事故後雙方對肇責與修車費有不同說法，需要先整理紀錄。';
      case _DocumentScenario.consumerComplaint:
        return '商品有瑕疵但客服尚未提出退款或補償方式。';
      case _DocumentScenario.laborDisputeMessage:
        return '離職前後的薪資與排班紀錄需要請公司確認。';
    }
  }

  String get sampleRequest {
    switch (this) {
      case _DocumentScenario.depositDemand:
        return '請提供扣款明細；若無具體依據，請安排返還押金。';
      case _DocumentScenario.overtimeNegotiation:
        return '請協助確認工時紀錄、補休與加班費計算方式。';
      case _DocumentScenario.carAccidentMemo:
        return '請確認事故資料與後續是否申請調解。';
      case _DocumentScenario.consumerComplaint:
        return '請說明退款、補寄或補償方案，以及預計回覆時間。';
      case _DocumentScenario.laborDisputeMessage:
        return '請提供薪資、排班或離職相關爭議的公司認定依據。';
    }
  }

  String get sampleEvidence {
    switch (this) {
      case _DocumentScenario.depositDemand:
        return '租約、匯款紀錄、點交照片、LINE 對話紀錄。';
      case _DocumentScenario.overtimeNegotiation:
        return '班表、打卡紀錄、薪資單、工作訊息、補休紀錄。';
      case _DocumentScenario.carAccidentMemo:
        return '現場照片、行車紀錄器、初判表、報案三聯單、保險聯絡紀錄。';
      case _DocumentScenario.consumerComplaint:
        return '訂單、發票、商品照片、客服對話、付款紀錄。';
      case _DocumentScenario.laborDisputeMessage:
        return '薪資單、排班表、離職通知、通訊軟體紀錄。';
    }
  }

  IconData get icon {
    switch (this) {
      case _DocumentScenario.depositDemand:
        return Icons.description_outlined;
      case _DocumentScenario.overtimeNegotiation:
        return Icons.balance_outlined;
      case _DocumentScenario.carAccidentMemo:
        return Icons.directions_car_outlined;
      case _DocumentScenario.consumerComplaint:
        return Icons.local_mall_outlined;
      case _DocumentScenario.laborDisputeMessage:
        return Icons.engineering_outlined;
    }
  }

  Color get accent {
    switch (this) {
      case _DocumentScenario.depositDemand:
        return _ToolColors.paperGold;
      case _DocumentScenario.overtimeNegotiation:
        return _ToolColors.orange;
      case _DocumentScenario.carAccidentMemo:
        return const Color(0xFF8FB7B9);
      case _DocumentScenario.consumerComplaint:
        return const Color(0xFFFF8A65);
      case _DocumentScenario.laborDisputeMessage:
        return const Color(0xFF90A88D);
    }
  }

  DocumentTemplateType get templateType {
    switch (this) {
      case _DocumentScenario.depositDemand:
        return DocumentTemplateType.rentalDepositNegotiation;
      case _DocumentScenario.overtimeNegotiation:
      case _DocumentScenario.laborDisputeMessage:
        return DocumentTemplateType.laborDisputeMessage;
      case _DocumentScenario.carAccidentMemo:
        return DocumentTemplateType.carAccidentChecklist;
      case _DocumentScenario.consumerComplaint:
        return DocumentTemplateType.consumerComplaint;
    }
  }
}

class _ToolAsset {
  static const hero = 'assets/images/tools/legal_tool_hero.svg';
  static const clipboard = 'assets/images/tools/document_clipboard.svg';
  static const locked = 'assets/images/tools/locked_document.svg';
  static const notice = 'assets/images/tools/legal_notice_badge.svg';
}

const _defaultEvidenceItems = <_EvidenceItem>[
  _EvidenceItem('租賃契約.jpg', '上傳於 2026/05/20'),
  _EvidenceItem('點交照片.jpg', '上傳於 2026/05/20'),
  _EvidenceItem('水電帳單.pdf', '上傳於 2026/05/20'),
  _EvidenceItem('對話紀錄截圖.png', '上傳於 2026/05/20'),
];

class LegalToolsPage extends StatefulWidget {
  const LegalToolsPage({super.key, this.initialScenarioKey});

  final String? initialScenarioKey;

  @override
  State<LegalToolsPage> createState() => _LegalToolsPageState();
}

/// 法律文件工具箱的 Prototype 版流程容器。
///
/// 這裡刻意用 `_ToolPage` 在同一個 StatefulWidget 裡切換首頁、三步驟、
/// 草稿列表、證據清單、會員狀態與免責說明，因為法律工具箱是 push 進來的子頁面；
/// 子頁不建立自己的 Nav 欄，只保留上方返回與頁內流程狀態。等正式後端草稿 ID、
/// 深層連結與雲端同步都穩定後，再拆成獨立路由。
class _LegalToolsPageState extends State<LegalToolsPage> {
  final _nameController = TextEditingController(text: '王小明');
  final _targetController = TextEditingController(text: '陳房東');
  final _dateController = TextEditingController(text: '2026/04/30');
  final _placeController = TextEditingController(text: '台北市大安區');
  final _issueController =
      TextEditingController(text: _DocumentScenario.depositDemand.sampleIssue);
  final _requestController = TextEditingController(
      text: _DocumentScenario.depositDemand.sampleRequest);
  final _evidenceController = TextEditingController(
      text: _DocumentScenario.depositDemand.sampleEvidence);

  _ToolPage _page = _ToolPage.home;
  _DocumentScenario _scenario = _DocumentScenario.depositDemand;
  _DraftTone _tone = _DraftTone.friendly;
  String _draft = '';
  final List<_EvidenceItem> _evidenceItems =
      List<_EvidenceItem>.of(_defaultEvidenceItems);
  final Set<int> _selectedEvidence = {0, 1};

  @override
  void initState() {
    super.initState();
    if (widget.initialScenarioKey != null) {
      if (widget.initialScenarioKey == 'depositDemand') {
        _scenario = _DocumentScenario.depositDemand;
        _page = _ToolPage.scenario;
      } else if (widget.initialScenarioKey == 'overtimeNegotiation') {
        _scenario = _DocumentScenario.overtimeNegotiation;
        _page = _ToolPage.scenario;
      } else if (widget.initialScenarioKey == 'carAccidentMemo') {
        _scenario = _DocumentScenario.carAccidentMemo;
        _page = _ToolPage.scenario;
      } else if (widget.initialScenarioKey == 'consumerComplaint') {
        _scenario = _DocumentScenario.consumerComplaint;
        _page = _ToolPage.scenario;
      } else if (widget.initialScenarioKey == 'laborDisputeMessage') {
        _scenario = _DocumentScenario.laborDisputeMessage;
        _page = _ToolPage.scenario;
      }
      _issueController.text = _scenario.sampleIssue;
      _requestController.text = _scenario.sampleRequest;
      _evidenceController.text = _scenario.sampleEvidence;
    }
    _draft = _buildDraft(isSample: true);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _dateController.dispose();
    _placeController.dispose();
    _issueController.dispose();
    _requestController.dispose();
    _evidenceController.dispose();
    super.dispose();
  }

  void _openPage(_ToolPage page) {
    setState(() => _page = page);
  }

  void _goToStep(_ToolStep step) {
    setState(() {
      _page = switch (step) {
        _ToolStep.scenario => _ToolPage.scenario,
        _ToolStep.details => _ToolPage.details,
        _ToolStep.preview => _ToolPage.preview,
      };
    });
  }

  void _selectScenario(_DocumentScenario scenario) {
    setState(() {
      _scenario = scenario;
      _issueController.text = scenario.sampleIssue;
      _requestController.text = scenario.sampleRequest;
      _evidenceController.text = scenario.sampleEvidence;
      _draft = _buildDraft(isSample: true);
    });
  }

  Future<void> _generateDraft() async {
    final appState = PreambleScope.of(context);
    final isSample = appState.isGuest;
    if (appState.isGuest) _showAccessSheet();

    final draft = await appState.documentRepository.createDraft(
      templateType: _scenario.templateType,
      input: DocumentTemplateInput(
        senderName: _fallback(_nameController.text, '王先生'),
        receiverName: _fallback(_targetController.text, '相對人'),
        facts: _fallback(_issueController.text, _scenario.sampleIssue),
        extraRequest:
            _fallback(_requestController.text, _scenario.sampleRequest),
        eventDate: _fallback(_dateController.text, '2026/04/30'),
        eventPlace: _fallback(_placeController.text, '事件地點'),
        evidence: _fallback(_evidenceController.text, _scenario.sampleEvidence),
        toneLabel: _tone == _DraftTone.formal ? '正式語氣' : '協商語氣',
      ),
      advanced: _tone == _DraftTone.formal,
      title: _scenario.title,
    );
    if (!mounted) return;

    setState(() {
      _draft = isSample ? _buildDraft(isSample: true) : draft.content;
      _page = _ToolPage.preview;
    });
  }

  Future<void> _copyDraft(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    CustomToast.show(context, '已複製草稿。');
  }

  Future<void> _copyShareText(String text) async {
    final shareText = [
      '緒言 Preamble 法律文件草稿',
      text,
      '提醒：$lawAppLegalDisclaimer',
    ].where((line) => line.trim().isNotEmpty).join('\n\n');
    await Clipboard.setData(ClipboardData(text: shareText));
    if (!mounted) return;
    _showSnack('已複製分享文字。');
  }

  void _toggleEvidence(int index) {
    setState(() {
      if (!_selectedEvidence.add(index)) {
        _selectedEvidence.remove(index);
      }
      _syncEvidenceControllerFromSelection();
    });
  }

  Future<void> _showAddEvidenceSheet() async {
    final titleController = TextEditingController();
    final noteController = TextEditingController();

    // 證據清單先做成頁內本機資料，不假裝已上傳檔案；使用者新增的名稱與備註
    // 會立即被勾選並同步回「你手上有哪些證據」欄位，產生草稿時就能帶入。
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _AddEvidenceSheet(
          titleController: titleController,
          noteController: noteController,
          onAdd: () => _addEvidenceFromSheet(
            sheetContext,
            titleController,
            noteController,
          ),
        );
      },
    );

    titleController.dispose();
    noteController.dispose();
  }

  void _addEvidenceFromSheet(
    BuildContext sheetContext,
    TextEditingController titleController,
    TextEditingController noteController,
  ) {
    final title = titleController.text.trim();
    final note = noteController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(sheetContext)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('請先輸入證據名稱。')));
      return;
    }

    setState(() {
      final index = _evidenceItems.length;
      _evidenceItems.add(
        _EvidenceItem(title, note.isEmpty ? '使用者新增，尚未上傳檔案' : note),
      );
      _selectedEvidence.add(index);
      _syncEvidenceControllerFromSelection();
    });
    Navigator.of(sheetContext).pop();
    _showSnack('已新增證據並帶入草稿資料。');
  }

  void _syncEvidenceControllerFromSelection() {
    final indexes = _selectedEvidence.toList()..sort();
    final selected = indexes
        .where((index) => index >= 0 && index < _evidenceItems.length)
        .map((index) => _evidenceItems[index])
        .map((item) => '${item.title}（${item.subtitle}）')
        .toList(growable: false);
    _evidenceController.text = selected.isEmpty ? '' : selected.join('、');
  }

  void _showProUpgradeSheet() {
    final appState = PreambleScope.of(context);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _ProUpgradeSheet(
          appState: appState,
          onDemo: () async {
            Navigator.of(sheetContext).pop();
            await appState.signInDemo();
            if (!mounted) return;
            _showSnack('已切換成 Demo 會員。');
          },
          onProDemo: () async {
            Navigator.of(sheetContext).pop();
            await appState.activateSubscriberDemo();
            if (!mounted) return;
            _showSnack('已啟用 Pro Demo；這不是正式付款。');
          },
        );
      },
    );
  }

  void _showSnack(String message) {
    CustomToast.show(context, message);
  }

  void _showAccessSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.all(16.w),
        child: PermissionGateCard(
          title: '登入後可產生完整內容',
          message: '訪客可預覽範例；Demo 會員可產生草稿，Pro 會員可解鎖匯出 PDF、更多語氣與雲端同步。',
          requireSubscriber: false,
        ),
      ),
    );
  }

  String _buildDraft({required bool isSample}) {
    final name = _fallback(_nameController.text, '王先生');
    final target = _fallback(_targetController.text, '相對人');
    final date = _fallback(_dateController.text, '2026/04/30');
    final place = _fallback(_placeController.text, '事件地點');
    final issue = _fallback(_issueController.text, _scenario.sampleIssue);
    final request = _fallback(_requestController.text, _scenario.sampleRequest);
    final evidence =
        _fallback(_evidenceController.text, _scenario.sampleEvidence);
    final greeting = _tone == _DraftTone.formal ? '敬啟者：' : '$target 您好：';
    final opening = _tone == _DraftTone.formal
        ? '$name 就「${_scenario.title}」相關事項，為避免爭議擴大，謹先整理如下。'
        : '我是 $name，想先把「${_scenario.title}」這件事整理清楚，請您協助回覆。';

    return [
      if (isSample) '【範例草稿】',
      '【${_scenario.title}】',
      '',
      greeting,
      opening,
      '',
      '一、發生時間與地點',
      '$date｜$place',
      '',
      '二、目前爭議',
      issue,
      '',
      '三、希望處理方式',
      request,
      '',
      '四、我手上的資料',
      evidence,
      '',
      '五、提醒',
      lawAppLegalDisclaimer,
    ].join('\n');
  }

  String _fallback(String value, String fallback) {
    final text = value.trim();
    return text.isEmpty ? fallback : text;
  }

  @override
  Widget build(BuildContext context) {
    final appState = PreambleScope.of(context);
    final topPadding = MediaQuery.paddingOf(context).top;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: _ToolColors.background,
        body: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(16.w, topPadding + 8.h, 16.w, 32.h),
          children: [
            _TopBar(
              title: _headerTitle,
              stepLabel: _stepLabel,
              onBack: _handleBack,
              actions: _page == _ToolPage.home
                  ? [
                      _MiniTopAction(
                        icon: Icons.description_outlined,
                        label: '草稿',
                        onTap: () => _openPage(_ToolPage.drafts),
                      ),
                      SizedBox(width: 8.w),
                      _MiniTopAction(
                        icon: Icons.info_outline_rounded,
                        label: '說明',
                        onTap: () => _openPage(_ToolPage.notice),
                      ),
                    ]
                  : const [],
            ),
            SizedBox(height: 14.h),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: KeyedSubtree(
                key: ValueKey(_page),
                child: _currentPage(appState),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _headerTitle {
    switch (_page) {
      case _ToolPage.home:
        return '法律工具箱';
      case _ToolPage.scenario:
        return '選擇情境';
      case _ToolPage.details:
        return '補充資料';
      case _ToolPage.preview:
        return _scenario.title;
      case _ToolPage.drafts:
        return '我的文件草稿';
      case _ToolPage.evidence:
        return '證據清單';
      case _ToolPage.pro:
        return 'Pro 功能預覽';
      case _ToolPage.notice:
        return '法律免責說明';
    }
  }

  String? get _stepLabel {
    switch (_page) {
      case _ToolPage.scenario:
        return 'Step 1 / 3';
      case _ToolPage.details:
        return 'Step 2 / 3';
      case _ToolPage.preview:
        return 'Step 3 / 3';
      default:
        return null;
    }
  }

  Widget _currentPage(PreambleState appState) {
    switch (_page) {
      case _ToolPage.home:
        return _HomePanel(
          appState: appState,
          selected: _scenario,
          onScenarioTap: (scenario) {
            _selectScenario(scenario);
            _goToStep(_ToolStep.scenario);
          },
          onStart: () => _goToStep(_ToolStep.scenario),
          onOpenDrafts: () => _openPage(_ToolPage.drafts),
          onOpenPro: () => _openPage(_ToolPage.pro),
          onOpenNotice: () => _openPage(_ToolPage.notice),
        );
      case _ToolPage.scenario:
        return _ScenarioPanel(
          selected: _scenario,
          onSelected: _selectScenario,
          onNext: () => _goToStep(_ToolStep.details),
        );
      case _ToolPage.details:
        return _DetailsPanel(
          nameController: _nameController,
          targetController: _targetController,
          dateController: _dateController,
          placeController: _placeController,
          issueController: _issueController,
          requestController: _requestController,
          evidenceController: _evidenceController,
          onEvidence: () => _openPage(_ToolPage.evidence),
          onBack: () => _goToStep(_ToolStep.scenario),
          onGenerate: _generateDraft,
        );
      case _ToolPage.preview:
        return _PreviewPanel(
          appState: appState,
          tone: _tone,
          draft: _draft,
          onToneChanged: (tone) {
            setState(() {
              _tone = tone;
              _draft = _buildDraft(isSample: appState.isGuest);
            });
          },
          onEdit: () => _goToStep(_ToolStep.details),
          onCopy: () => _copyDraft(_draft),
          onShare: () => _copyShareText(_draft),
          onDrafts: () => _openPage(_ToolPage.drafts),
          onPro: () => _openPage(_ToolPage.pro),
        );
      case _ToolPage.drafts:
        return _DraftsPanel(
          drafts: appState.documentRepository.drafts
              .map(_DraftListItem.fromDocument)
              .toList(growable: false),
          backendStatus: appState.documentRepository.backendStatusLabel,
          onNew: () => _goToStep(_ToolStep.scenario),
          onOpen: (item) {
            setState(() {
              _draft = item.content;
              _page = _ToolPage.preview;
            });
          },
        );
      case _ToolPage.evidence:
        return _EvidencePanel(
          items: _evidenceItems,
          selectedEvidence: _selectedEvidence,
          onToggle: _toggleEvidence,
          onAdd: _showAddEvidenceSheet,
          onBack: () => _goToStep(_ToolStep.details),
        );
      case _ToolPage.pro:
        return _ProPanel(
          appState: appState,
          onUpgrade: _showProUpgradeSheet,
          onNotice: () => _openPage(_ToolPage.notice),
        );
      case _ToolPage.notice:
        return _NoticePanel(onDone: () => _openPage(_ToolPage.home));
    }
  }

  void _handleBack() {
    switch (_page) {
      case _ToolPage.home:
        Navigator.of(context).pop();
      case _ToolPage.scenario:
        _openPage(_ToolPage.home);
      case _ToolPage.details:
        _goToStep(_ToolStep.scenario);
      case _ToolPage.preview:
        _goToStep(_ToolStep.details);
      case _ToolPage.drafts:
      case _ToolPage.pro:
      case _ToolPage.notice:
        _openPage(_ToolPage.home);
      case _ToolPage.evidence:
        _goToStep(_ToolStep.details);
    }
  }
}

class _HomePanel extends StatelessWidget {
  const _HomePanel({
    required this.appState,
    required this.selected,
    required this.onScenarioTap,
    required this.onStart,
    required this.onOpenDrafts,
    required this.onOpenPro,
    required this.onOpenNotice,
  });

  final PreambleState appState;
  final _DocumentScenario selected;
  final ValueChanged<_DocumentScenario> onScenarioTap;
  final VoidCallback onStart;
  final VoidCallback onOpenDrafts;
  final VoidCallback onOpenPro;
  final VoidCallback onOpenNotice;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '法律文件工具箱',
                    style: _ToolText.hero(),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '幫你把複雜的法律問題整理成清楚的文字',
                    style: _ToolText.body(),
                  ),
                ],
              ),
            ),
            const _ToolIllustration(),
          ],
        ),
        SizedBox(height: 18.h),
        _InfoBand(
          title: '3-step 輕鬆產生法律文件',
          subtitle: '選情境 → 補資料 → 看草稿',
          asset: _ToolAsset.clipboard,
        ),
        SizedBox(height: 18.h),
        Text('選擇你需要的情境', style: _ToolText.section()),
        SizedBox(height: 10.h),
        for (final scenario in _DocumentScenario.values) ...[
          _ScenarioTile(
            scenario: scenario,
            selected: selected == scenario,
            onTap: () => onScenarioTap(scenario),
          ),
          SizedBox(height: 8.h),
        ],
        SizedBox(height: 6.h),
        _LockPrompt(appState: appState, onTap: onOpenPro),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _SecondaryButton(label: '查看草稿', onPressed: onOpenDrafts),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _SecondaryButton(label: '法律說明', onPressed: onOpenNotice),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        _PrimaryButton(label: '開始產生草稿', onPressed: onStart),
      ],
    );
  }
}

class _ScenarioPanel extends StatelessWidget {
  const _ScenarioPanel({
    required this.selected,
    required this.onSelected,
    required this.onNext,
  });

  final _DocumentScenario selected;
  final ValueChanged<_DocumentScenario> onSelected;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return _WizardShell(
      step: _ToolStep.scenario,
      title: '你想產生哪一種文件？',
      child: Column(
        children: [
          for (final scenario in _DocumentScenario.values) ...[
            _ScenarioChoice(
              scenario: scenario,
              selected: selected == scenario,
              onTap: () => onSelected(scenario),
            ),
            SizedBox(height: 10.h),
          ],
          SizedBox(height: 26.h),
          _PrimaryButton(label: '下一步', onPressed: onNext),
          SizedBox(height: 18.h),
          const _HelperText('你的資料會在裝置中處理，不會上傳雲端。'),
        ],
      ),
    );
  }
}

class _DetailsPanel extends StatelessWidget {
  const _DetailsPanel({
    required this.nameController,
    required this.targetController,
    required this.dateController,
    required this.placeController,
    required this.issueController,
    required this.requestController,
    required this.evidenceController,
    required this.onEvidence,
    required this.onBack,
    required this.onGenerate,
  });

  final TextEditingController nameController;
  final TextEditingController targetController;
  final TextEditingController dateController;
  final TextEditingController placeController;
  final TextEditingController issueController;
  final TextEditingController requestController;
  final TextEditingController evidenceController;
  final VoidCallback onEvidence;
  final VoidCallback onBack;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    return _WizardShell(
      step: _ToolStep.details,
      title: '請補充相關資料',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '填寫表單欄位',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2C5E43),
                ),
              ),
              DocumentQuickFillBar(
                onQuickFill: () {
                  if (nameController.text.trim().isEmpty) {
                    nameController.text = '王小明';
                  }
                  if (targetController.text.trim().isEmpty) {
                    targetController.text = '陳房東';
                  }
                  if (dateController.text.trim().isEmpty) {
                    dateController.text = '2026/04/30';
                  }
                  if (placeController.text.trim().isEmpty) {
                    placeController.text = '台北市大安區';
                  }
                },
              ),
            ],
          ),
          SizedBox(height: 10.h),
          _QuestionField(
            label: '對方是誰？',
            hint: '例如：房東、公司、店家',
            controller: targetController,
          ),
          _QuestionField(
            label: '事件發生時間',
            hint: '例如：2026/04/30',
            controller: dateController,
          ),
          _QuestionField(
            label: '事件地點',
            hint: '例如：台北市大安區',
            controller: placeController,
          ),
          _QuestionField(
            label: '你的稱呼',
            hint: '例如：王先生',
            controller: nameController,
          ),
          _QuestionField(
            label: '目前爭議',
            hint: '請簡單描述對方主張或卡住的地方',
            controller: issueController,
            minLines: 3,
          ),
          _QuestionField(
            label: '希望處理方式',
            hint: '例如：請對方提供明細、退款、安排協商',
            controller: requestController,
            minLines: 3,
          ),
          _QuestionField(
            label: '你手上有哪些證據',
            hint: '例如：契約、照片、對話紀錄、收據',
            controller: evidenceController,
            minLines: 3,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onEvidence,
              icon: const Icon(Icons.add_rounded),
              label: const Text('新增更多證據（選填）'),
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                  child: _SecondaryButton(label: '上一步', onPressed: onBack)),
              SizedBox(width: 10.w),
              Expanded(
                  child: _PrimaryButton(label: '下一步', onPressed: onGenerate)),
            ],
          ),
          SizedBox(height: 18.h),
          const _HelperText('你的資料會在裝置中處理，不會上傳雲端。'),
        ],
      ),
    );
  }
}

class _PreviewPanel extends StatelessWidget {
  const _PreviewPanel({
    required this.appState,
    required this.tone,
    required this.draft,
    required this.onToneChanged,
    required this.onEdit,
    required this.onCopy,
    required this.onShare,
    required this.onDrafts,
    required this.onPro,
  });

  final PreambleState appState;
  final _DraftTone tone;
  final String draft;
  final ValueChanged<_DraftTone> onToneChanged;
  final VoidCallback onEdit;
  final VoidCallback onCopy;
  final VoidCallback onShare;
  final VoidCallback onDrafts;
  final VoidCallback onPro;

  @override
  Widget build(BuildContext context) {
    return _WizardShell(
      step: _ToolStep.preview,
      title: '你的文件草稿已完成！',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('選擇語氣風格', style: _ToolText.label()),
          SizedBox(height: 10.h),
          _ToneSelector(tone: tone, onChanged: onToneChanged),
          SizedBox(height: 16.h),
          _DraftPaper(draft: draft),
          SizedBox(height: 14.h),
          if (appState.isGuest) ...[
            _AccessNotice(
              title: '訪客可預覽範例內容',
              message: '登入後即可產生完整草稿，Demo 會員可以先體驗主要流程。',
              actionLabel: '登入 / 註冊',
              onTap: onPro,
            ),
            SizedBox(height: 14.h),
          ],
          Row(
            children: [
              Expanded(
                  child: _IconAction(
                      icon: Icons.copy_outlined, label: '複製', onTap: onCopy)),
              Expanded(
                  child: _IconAction(
                      icon: Icons.ios_share_outlined,
                      label: '分享',
                      onTap: onShare)),
              Expanded(
                  child: _IconAction(
                      icon: Icons.lock_outline_rounded,
                      label: '匯出 PDF\n(Pro)',
                      onTap: onPro)),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                  child: _SecondaryButton(label: '重新編輯', onPressed: onEdit)),
              SizedBox(width: 10.w),
              Expanded(
                  child: _PrimaryButton(label: '儲存到我的草稿', onPressed: onDrafts)),
            ],
          ),
          SizedBox(height: 18.h),
          const _HelperText('你的資料會在裝置中處理，不會上傳雲端。'),
        ],
      ),
    );
  }
}

class _DraftsPanel extends StatelessWidget {
  const _DraftsPanel({
    required this.drafts,
    required this.backendStatus,
    required this.onNew,
    required this.onOpen,
  });

  final List<_DraftListItem> drafts;
  final String backendStatus;
  final VoidCallback onNew;
  final ValueChanged<_DraftListItem> onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TabHeader(labels: const ['全部', '進行中', '已完成']),
        SizedBox(height: 12.h),
        _HelperText(backendStatus),
        SizedBox(height: 12.h),
        for (final item in drafts) ...[
          _DraftTile(item: item, onTap: () => onOpen(item)),
          SizedBox(height: 10.h),
        ],
        SizedBox(height: 12.h),
        _PrimaryButton(label: '+ 新增文件草稿', onPressed: onNew),
      ],
    );
  }
}

class _EvidencePanel extends StatelessWidget {
  const _EvidencePanel({
    required this.items,
    required this.selectedEvidence,
    required this.onToggle,
    required this.onAdd,
    required this.onBack,
  });

  final List<_EvidenceItem> items;
  final Set<int> selectedEvidence;
  final ValueChanged<int> onToggle;
  final VoidCallback onAdd;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '上傳或記錄你手上的證據，目前先把資料一起帶進草稿。',
          style: _ToolText.body(),
        ),
        SizedBox(height: 14.h),
        for (var i = 0; i < items.length; i++) ...[
          _EvidenceTile(
            item: items[i],
            selected: selectedEvidence.contains(i),
            onTap: () => onToggle(i),
          ),
          SizedBox(height: 10.h),
        ],
        SizedBox(height: 8.h),
        _SecondaryButton(label: '+ 新增證據', onPressed: onAdd),
        SizedBox(height: 14.h),
        _PrimaryButton(label: '下一步', onPressed: onBack),
      ],
    );
  }
}

class _ProPanel extends StatelessWidget {
  const _ProPanel({
    required this.appState,
    required this.onUpgrade,
    required this.onNotice,
  });

  final PreambleState appState;
  final VoidCallback onUpgrade;
  final VoidCallback onNotice;

  @override
  Widget build(BuildContext context) {
    final isPro = appState.isSubscriber;
    return Column(
      children: [
        _StatusHero(
          asset: isPro ? _ToolAsset.notice : _ToolAsset.locked,
          title: isPro
              ? 'Pro 會員可完整使用'
              : appState.isGuest
                  ? '訪客可預覽範例內容'
                  : 'Demo 會員可產生草稿',
          message: isPro
              ? '你已可使用進階語氣、PDF 匯出與更多草稿整理工具。'
              : appState.isGuest
                  ? '登入後可產生完整草稿；Pro 會解鎖匯出與雲端同步。'
                  : 'Demo 會員可產生草稿和編輯內容，升級 Pro 後可使用進階功能。',
        ),
        SizedBox(height: 16.h),
        _FeatureTile(title: '存證信函產生器', subtitle: '一鍵產生正式律師語氣', locked: !isPro),
        _FeatureTile(title: '更多草稿模板', subtitle: '律師語、契約審閱提醒模板', locked: !isPro),
        _FeatureTile(
            title: 'PDF 匯出', subtitle: '匯出標準格式 PDF 檔案', locked: !isPro),
        _FeatureTile(title: '雲端備份與同步', subtitle: '跨裝置保存你的草稿', locked: !isPro),
        SizedBox(height: 12.h),
        _PrimaryButton(
          label: isPro ? '已啟用 Pro 功能' : '升級 Pro 會員',
          onPressed: onUpgrade,
        ),
        SizedBox(height: 14.h),
        _DisclaimerCard(onDone: onNotice),
      ],
    );
  }
}

class _NoticePanel extends StatelessWidget {
  const _NoticePanel({required this.onDone});

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _StatusHero(
          asset: _ToolAsset.notice,
          title: '法律免責聲明',
          message: lawAppLegalDisclaimer,
        ),
        SizedBox(height: 14.h),
        _ProtoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('會員狀態說明', style: _ToolText.section()),
              SizedBox(height: 12.h),
              _AccessRow(
                icon: Icons.person_outline_rounded,
                title: '訪客（Guest）',
                message: '可預覽範例，產生完整草稿需登入。',
              ),
              _AccessRow(
                icon: Icons.workspace_premium_outlined,
                title: 'Demo 會員',
                message: '可產生草稿，但無 Pro 功能。',
              ),
              _AccessRow(
                icon: Icons.lock_open_rounded,
                title: 'Pro 會員',
                message: '可使用所有模板與 Pro 功能。',
              ),
            ],
          ),
        ),
        SizedBox(height: 14.h),
        _PrimaryButton(label: '我已了解', onPressed: onDone),
      ],
    );
  }
}

class _WizardShell extends StatelessWidget {
  const _WizardShell({
    required this.step,
    required this.title,
    required this.child,
  });

  final _ToolStep step;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final currentStep = _ToolStep.values.indexOf(step) + 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DocumentFormStepper(currentStep: currentStep),
        SizedBox(height: 18.h),
        Text(title, style: _ToolText.section()),
        SizedBox(height: 14.h),
        child,
      ],
    );
  }
}

class _ProgressDots extends StatelessWidget {
  const _ProgressDots({required this.step});

  final _ToolStep step;

  @override
  Widget build(BuildContext context) {
    final current = _ToolStep.values.indexOf(step);
    return Row(
      children: List.generate(3, (index) {
        final active = index <= current;
        return Container(
          width: index == current ? 26.w : 10.w,
          height: 10.h,
          margin: EdgeInsets.only(right: 7.w),
          decoration: BoxDecoration(
            color: active ? _ToolColors.primary : _ToolColors.border,
            borderRadius: BorderRadius.circular(99.r),
          ),
        );
      }),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.title,
    required this.stepLabel,
    required this.onBack,
    this.actions = const [],
  });

  final String title;
  final String? stepLabel;
  final VoidCallback onBack;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _RoundIconButton(icon: Icons.arrow_back_ios_new_rounded, onTap: onBack),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _ToolText.navTitle(),
          ),
        ),
        if (stepLabel != null)
          Text(stepLabel!,
              style: _ToolText.caption().copyWith(fontWeight: FontWeight.w800)),
        if (actions.isNotEmpty) ...[
          SizedBox(width: 8.w),
          ...actions,
        ],
      ],
    );
  }
}

class _MiniTopAction extends StatelessWidget {
  const _MiniTopAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: _ToolColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: _ToolColors.primary, size: 15.sp),
            SizedBox(height: 2.h),
            Text(label, style: _ToolText.caption().copyWith(fontSize: 8.5.sp)),
          ],
        ),
      ),
    );
  }
}

class _ScenarioTile extends StatelessWidget {
  const _ScenarioTile(
      {required this.scenario, required this.selected, required this.onTap});

  final _DocumentScenario scenario;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _ProtoCard(
      onTap: onTap,
      background: selected ? _ToolColors.selected : Colors.white,
      borderColor: selected ? _ToolColors.paperGold : _ToolColors.border,
      child: Row(
        children: [
          _IconBadge(icon: scenario.icon, color: scenario.accent),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(scenario.title, style: _ToolText.tileTitle()),
                SizedBox(height: 3.h),
                Text(scenario.subtitle, style: _ToolText.caption()),
              ],
            ),
          ),
          if (selected)
            Icon(Icons.check_circle_rounded,
                color: _ToolColors.primary, size: 20.sp),
        ],
      ),
    );
  }
}

class _ScenarioChoice extends StatelessWidget {
  const _ScenarioChoice(
      {required this.scenario, required this.selected, required this.onTap});

  final _DocumentScenario scenario;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _ProtoCard(
      onTap: onTap,
      background: selected ? _ToolColors.selected : Colors.white,
      borderColor: selected ? _ToolColors.paperGold : _ToolColors.border,
      child: Row(
        children: [
          _IconBadge(icon: scenario.icon, color: scenario.accent),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(scenario.title, style: _ToolText.tileTitle()),
          ),
          Icon(
            selected
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color: selected ? _ToolColors.primary : _ToolColors.borderDark,
            size: 20.sp,
          ),
        ],
      ),
    );
  }
}

class _InfoBand extends StatelessWidget {
  const _InfoBand({
    required this.title,
    required this.subtitle,
    required this.asset,
  });

  final String title;
  final String subtitle;
  final String asset;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: _ToolColors.softPaper,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          SvgPicture.asset(asset, width: 34.w, height: 34.w),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: _ToolText.tileTitle()),
                SizedBox(height: 5.h),
                Text(subtitle, style: _ToolText.bodyStrong()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LockPrompt extends StatelessWidget {
  const _LockPrompt({required this.appState, required this.onTap});

  final PreambleState appState;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title = appState.isSubscriber ? 'Pro 功能已啟用' : '想要更完整的法律文件？';
    final subtitle =
        appState.isSubscriber ? '你已可使用 PDF 匯出與進階語氣。' : '升級 Pro 會員解鎖更多功能';
    return _ProtoCard(
      onTap: onTap,
      background: _ToolColors.mint,
      borderColor: Colors.transparent,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: _ToolText.tileTitle()),
                SizedBox(height: 4.h),
                Text(subtitle, style: _ToolText.caption()),
              ],
            ),
          ),
          _IconBadge(
              icon: appState.isSubscriber
                  ? Icons.check_rounded
                  : Icons.lock_outline_rounded,
              color: _ToolColors.mutedGreen),
        ],
      ),
    );
  }
}

class _ToneSelector extends StatelessWidget {
  const _ToneSelector({required this.tone, required this.onChanged});

  final _DraftTone tone;
  final ValueChanged<_DraftTone> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: _ToolColors.softPaper,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          _ToneOption(
              label: '協商語氣',
              selected: tone == _DraftTone.friendly,
              onTap: () => onChanged(_DraftTone.friendly)),
          _ToneOption(
              label: '正式語氣',
              selected: tone == _DraftTone.formal,
              onTap: () => onChanged(_DraftTone.formal)),
        ],
      ),
    );
  }
}

class _ToneOption extends StatelessWidget {
  const _ToneOption(
      {required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? _ToolColors.primary : Colors.transparent,
                width: 1.5,
              ),
            ),
          ),
          child: Text(label,
              style: _ToolText.bodyStrong().copyWith(
                  color:
                      selected ? _ToolColors.primary : _ToolColors.mutedText)),
        ),
      ),
    );
  }
}

class _DraftPaper extends StatelessWidget {
  const _DraftPaper({required this.draft});

  final String draft;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: _ToolColors.border),
        boxShadow: const [
          BoxShadow(
              color: Color(0x10000000), blurRadius: 18, offset: Offset(0, 8)),
        ],
      ),
      child: SelectableText(
        draft,
        style: TextStyle(
          color: _ToolColors.text,
          fontSize: 13.sp,
          height: 1.75,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DraftTile extends StatelessWidget {
  const _DraftTile({required this.item, required this.onTap});

  final _DraftListItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _ProtoCard(
      onTap: onTap,
      child: Row(
        children: [
          _IconBadge(icon: item.icon, color: _ToolColors.mutedGreen),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: _ToolText.tileTitle()),
                SizedBox(height: 3.h),
                Text(item.time, style: _ToolText.caption()),
                SizedBox(height: 3.h),
                Text(item.status,
                    style: _ToolText.caption()
                        .copyWith(color: _ToolColors.primary)),
              ],
            ),
          ),
          Icon(Icons.more_horiz_rounded, color: _ToolColors.text, size: 20.sp),
        ],
      ),
    );
  }
}

class _EvidenceTile extends StatelessWidget {
  const _EvidenceTile(
      {required this.item, required this.selected, required this.onTap});

  final _EvidenceItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _ProtoCard(
      onTap: onTap,
      background: selected ? _ToolColors.selected : Colors.white,
      child: Row(
        children: [
          _IconBadge(
              icon: Icons.insert_drive_file_outlined,
              color: _ToolColors.paperGold),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: _ToolText.tileTitle()),
                SizedBox(height: 3.h),
                Text(item.subtitle, style: _ToolText.caption()),
              ],
            ),
          ),
          Icon(
            selected
                ? Icons.check_box_rounded
                : Icons.check_box_outline_blank_rounded,
            color: selected ? _ToolColors.primary : _ToolColors.borderDark,
            size: 20.sp,
          ),
        ],
      ),
    );
  }
}

class _AddEvidenceSheet extends StatelessWidget {
  const _AddEvidenceSheet({
    required this.titleController,
    required this.noteController,
    required this.onAdd,
  });

  final TextEditingController titleController;
  final TextEditingController noteController;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h + keyboardInset),
        child: _ProtoCard(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('新增證據', style: _ToolText.section()),
                SizedBox(height: 8.h),
                Text(
                  '先記錄證據名稱與說明；目前不會真的上傳檔案，會把文字帶入草稿。',
                  style: _ToolText.body(),
                ),
                SizedBox(height: 14.h),
                _SheetTextField(
                  label: '證據名稱',
                  hint: '例如：LINE 對話截圖、維修報價單',
                  controller: titleController,
                ),
                _SheetTextField(
                  label: '補充說明',
                  hint: '例如：可證明對方同意退押金',
                  controller: noteController,
                  minLines: 2,
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Expanded(
                      child: _SecondaryButton(
                        label: '取消',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _PrimaryButton(label: '新增並帶入', onPressed: onAdd),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetTextField extends StatelessWidget {
  const _SheetTextField({
    required this.label,
    required this.hint,
    required this.controller,
    this.minLines = 1,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final int minLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: _ToolText.label()),
          SizedBox(height: 6.h),
          TextField(
            controller: controller,
            onTapOutside: (event) {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            minLines: minLines,
            maxLines: minLines + 2,
            style: TextStyle(color: _ToolColors.text, fontSize: 13.sp),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  TextStyle(color: _ToolColors.mutedText, fontSize: 12.sp),
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              border: _sheetFieldBorder(),
              enabledBorder: _sheetFieldBorder(),
              focusedBorder: _sheetFieldBorder(_ToolColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  OutlineInputBorder _sheetFieldBorder([Color color = _ToolColors.border]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.r),
      borderSide: BorderSide(color: color),
    );
  }
}

class _ProUpgradeSheet extends StatelessWidget {
  const _ProUpgradeSheet({
    required this.appState,
    required this.onDemo,
    required this.onProDemo,
  });

  final PreambleState appState;
  final VoidCallback onDemo;
  final VoidCallback onProDemo;

  @override
  Widget build(BuildContext context) {
    final isPro = appState.isSubscriber;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        child: _ProtoCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(isPro ? 'Pro Demo 已啟用' : '升級 Pro 會員',
                  style: _ToolText.section()),
              SizedBox(height: 8.h),
              Text(
                isPro
                    ? '目前已是 Pro Demo 狀態，可預覽 PDF 匯出、進階語氣與雲端同步等受限功能的 UI。'
                    : '正式付款 SDK 尚未串接，這裡只提供開發展示用的 Pro Demo；不會產生實際付款。',
                style: _ToolText.body(),
              ),
              SizedBox(height: 14.h),
              if (!isPro && appState.isGuest) ...[
                _SecondaryButton(label: '先登入 Demo 會員', onPressed: onDemo),
                SizedBox(height: 10.h),
              ],
              _PrimaryButton(
                label: isPro ? '關閉' : '啟用 Pro Demo',
                onPressed:
                    isPro ? () => Navigator.of(context).pop() : onProDemo,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestionField extends StatelessWidget {
  const _QuestionField({
    required this.label,
    required this.hint,
    required this.controller,
    this.minLines = 1,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final int minLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: _ToolText.label()),
          SizedBox(height: 6.h),
          TextField(
            controller: controller,
            minLines: minLines,
            maxLines: minLines + 2,
            style: TextStyle(color: _ToolColors.text, fontSize: 13.sp),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  TextStyle(color: _ToolColors.mutedText, fontSize: 12.sp),
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              border: _fieldBorder(),
              enabledBorder: _fieldBorder(),
              focusedBorder: _fieldBorder(_ToolColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  OutlineInputBorder _fieldBorder([Color color = _ToolColors.border]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.r),
      borderSide: BorderSide(color: color),
    );
  }
}

class _TabHeader extends StatelessWidget {
  const _TabHeader({required this.labels});

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42.h,
      decoration: BoxDecoration(
        color: _ToolColors.background,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: Center(
                child: Text(
                  labels[i],
                  style: _ToolText.caption().copyWith(
                    color: i == 0 ? _ToolColors.primary : _ToolColors.mutedText,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AccessNotice extends StatelessWidget {
  const _AccessNotice({
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onTap,
  });

  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _ProtoCard(
      background: _ToolColors.mint,
      borderColor: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: _ToolText.tileTitle()),
          SizedBox(height: 6.h),
          Text(message, style: _ToolText.body()),
          SizedBox(height: 12.h),
          _PrimaryButton(label: actionLabel, onPressed: onTap),
        ],
      ),
    );
  }
}

class _StatusHero extends StatelessWidget {
  const _StatusHero(
      {required this.asset, required this.title, required this.message});

  final String asset;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return _ProtoCard(
      child: Column(
        children: [
          SvgPicture.asset(asset, width: 104.w, height: 104.w),
          SizedBox(height: 16.h),
          Text(title, textAlign: TextAlign.center, style: _ToolText.section()),
          SizedBox(height: 8.h),
          Text(message, textAlign: TextAlign.center, style: _ToolText.body()),
        ],
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile(
      {required this.title, required this.subtitle, required this.locked});

  final String title;
  final String subtitle;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: _ProtoCard(
        child: Row(
          children: [
            _IconBadge(
                icon: Icons.description_outlined, color: _ToolColors.paperGold),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: _ToolText.tileTitle()),
                  SizedBox(height: 3.h),
                  Text(subtitle, style: _ToolText.caption()),
                ],
              ),
            ),
            Icon(
                locked
                    ? Icons.lock_outline_rounded
                    : Icons.check_circle_outline_rounded,
                color: _ToolColors.mutedText,
                size: 18.sp),
          ],
        ),
      ),
    );
  }
}

class _AccessRow extends StatelessWidget {
  const _AccessRow({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _IconBadge(icon: icon, color: _ToolColors.mutedGreen),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: _ToolText.tileTitle()),
                SizedBox(height: 4.h),
                Text(message, style: _ToolText.caption()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DisclaimerCard extends StatelessWidget {
  const _DisclaimerCard({required this.onDone});

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return _ProtoCard(
      child: Column(
        children: [
          SvgPicture.asset(_ToolAsset.notice, width: 92.w, height: 92.w),
          SizedBox(height: 14.h),
          Text('法律免責聲明', style: _ToolText.section()),
          SizedBox(height: 8.h),
          Text(
            lawAppLegalDisclaimer,
            textAlign: TextAlign.center,
            style: _ToolText.body(),
          ),
          SizedBox(height: 12.h),
          _PrimaryButton(label: '我已了解', onPressed: onDone),
        ],
      ),
    );
  }
}

class _ToolIllustration extends StatelessWidget {
  const _ToolIllustration();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      _ToolAsset.hero,
      width: 108.w,
      height: 90.h,
      fit: BoxFit.contain,
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Icon(icon, color: color, size: 22.sp),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: SizedBox(
        width: 36.w,
        height: 36.w,
        child: Icon(icon, color: _ToolColors.text, size: 18.sp),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction(
      {required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Column(
          children: [
            Icon(icon, color: _ToolColors.text, size: 22.sp),
            SizedBox(height: 4.h),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _ToolColors.text,
                fontSize: 10.sp,
                height: 1.12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProtoCard extends StatelessWidget {
  const _ProtoCard({
    required this.child,
    this.onTap,
    this.background = Colors.white,
    this.borderColor = _ToolColors.border,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color background;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: borderColor),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0D000000), blurRadius: 14, offset: Offset(0, 6)),
        ],
      ),
      child: child,
    );

    if (onTap == null) return card;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: card,
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 46.h,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: _ToolColors.primary,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        ),
        child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 46.h,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: _ToolColors.primary,
          side: const BorderSide(color: _ToolColors.borderDark),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        ),
        child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}

class _HelperText extends StatelessWidget {
  const _HelperText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: _ToolText.caption().copyWith(fontSize: 10.sp),
      ),
    );
  }
}

class _DraftListItem {
  const _DraftListItem({
    required this.title,
    required this.status,
    required this.time,
    required this.icon,
    required this.content,
  });

  factory _DraftListItem.fromDocument(DocumentDraft draft) {
    return _DraftListItem(
      title: draft.title,
      status: draft.sourceLabel,
      time: _formatDraftTime(draft.createdAt),
      icon: _iconForTemplate(draft.templateType),
      content: draft.content,
    );
  }

  final String title;
  final String status;
  final String time;
  final IconData icon;
  final String content;
}

IconData _iconForTemplate(DocumentTemplateType type) {
  switch (type) {
    case DocumentTemplateType.depositDemand:
    case DocumentTemplateType.rentalDepositNegotiation:
      return Icons.description_outlined;
    case DocumentTemplateType.carAccidentChecklist:
      return Icons.directions_car_outlined;
    case DocumentTemplateType.consumerComplaint:
      return Icons.local_mall_outlined;
    case DocumentTemplateType.laborDisputeMessage:
      return Icons.balance_outlined;
    case DocumentTemplateType.dynamicCustom:
      return Icons.auto_awesome_outlined;
  }
}

String _formatDraftTime(DateTime value) {
  String twoDigits(int number) => number.toString().padLeft(2, '0');
  return '建立於 ${value.year}/${twoDigits(value.month)}/${twoDigits(value.day)} '
      '${twoDigits(value.hour)}:${twoDigits(value.minute)}';
}

class _EvidenceItem {
  const _EvidenceItem(this.title, this.subtitle);

  final String title;
  final String subtitle;
}

class _ToolText {
  static TextStyle hero() => TextStyle(
        color: _ToolColors.primary,
        fontSize: 28.sp,
        height: 1.06,
        fontWeight: FontWeight.w900,
      );

  static TextStyle navTitle() => TextStyle(
        color: _ToolColors.text,
        fontSize: 16.sp,
        fontWeight: FontWeight.w900,
      );

  static TextStyle section() => TextStyle(
        color: _ToolColors.text,
        fontSize: 16.sp,
        height: 1.3,
        fontWeight: FontWeight.w900,
      );

  static TextStyle tileTitle() => TextStyle(
        color: _ToolColors.text,
        fontSize: 13.sp,
        height: 1.25,
        fontWeight: FontWeight.w900,
      );

  static TextStyle label() => TextStyle(
        color: _ToolColors.text,
        fontSize: 12.sp,
        fontWeight: FontWeight.w900,
      );

  static TextStyle bodyStrong() => TextStyle(
        color: _ToolColors.text,
        fontSize: 12.sp,
        height: 1.45,
        fontWeight: FontWeight.w800,
      );

  static TextStyle body() => TextStyle(
        color: _ToolColors.mutedText,
        fontSize: 12.sp,
        height: 1.5,
        fontWeight: FontWeight.w600,
      );

  static TextStyle caption() => TextStyle(
        color: _ToolColors.mutedText,
        fontSize: 11.sp,
        height: 1.35,
        fontWeight: FontWeight.w600,
      );
}

class _ToolColors {
  static const background = Color(0xFFF7F5EF);
  static const primary = Color(0xFF314D44);
  static const mutedGreen = Color(0xFF6D8B74);
  static const text = Color(0xFF555555);
  static const mutedText = Color(0xFF818177);
  static const border = Color(0xFFE8DED1);
  static const borderDark = Color(0xFFCFC3B5);
  static const selected = Color(0xFFFFFAEA);
  static const softPaper = Color(0xFFF3EAD7);
  static const mint = Color(0xFFE7EFE5);
  static const paperGold = Color(0xFFE7B76D);
  static const orange = Color(0xFFFF8A65);
}
