part of '../know_law_page.dart';

/// 小法助 Prototype 入口與頁內流程狀態機。
///
/// 台灣繁體中文教學介紹型註解：
/// 這裡負責首頁、輸入、回答整理、法條、追問、來源、紀錄、收藏、設定與方案的頁內切換；
/// 視覺元件與 mock 內容拆到其他檔案，讓流程邏輯保持可讀。
///
/// 小法助提問入口頁。
///
/// 台灣繁體中文教學註解：
/// 這個頁面刻意做成公開 widget，讓首頁新版「AI 法律輔助」卡片與學習頁
/// 搜尋列都共用同一套提問流程。未來若要調整 guest 額度、後端設定提示或
/// 最近對話載入，只要改這裡，不需要追兩個入口。
class LawAssistantSearchPage extends StatefulWidget {
  const LawAssistantSearchPage({
    super.key,
    this.initialPrompt,
  });

  final String? initialPrompt;

  @override
  State<LawAssistantSearchPage> createState() => _LawAssistantSearchPageState();
}

enum _AssistantPrototypePage {
  home,
  input,
  answer,
  statute,
  followUp,
  sources,
  records,
  recordDetail,
  saved,
  settings,
  plan,
  empty,
}

class _LawAssistantSearchPageState extends State<LawAssistantSearchPage> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _followUpController = TextEditingController();
  final TextEditingController _recordSearchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final LawAssistantRepository _assistantRepository = LawAssistantRepository();
  final GuestLawAssistantUsage _guestUsage = const GuestLawAssistantUsage();
  late Future<List<LawAssistantConversation>> _recentConversationsFuture;
  _AssistantPrototypePage _page = _AssistantPrototypePage.home;
  LawAssistantConversation? _conversation;
  var _hotQuestionOffset = 0;
  var _savedTabIndex = 0;
  var _recordTabIndex = 0;
  var _selectedLawTitle = '民法 第 425 條（債務不履行）';
  var _answerTone = '白話易懂';
  var _answerLength = '一般';
  var _selectedIssueType = '租屋糾紛';
  var _supplementText = '';
  var _documentNote = '';
  var _isManagingSaved = false;
  var _provideExamples = true;
  var _newFeatureNotice = true;
  var _chatReminder = false;
  var _isSendingFollowUp = false;
  var _hasGuestUsed = false;
  var _isCheckingGuestUsage = true;
  var _isCreating = false;
  final Set<String> _hiddenRecordIds = <String>{};
  late final List<_AssistantSavedItem> _savedItems;

  @override
  void initState() {
    super.initState();
    // 台灣繁體中文教學註解：
    // Prototype 版把「首頁、輸入、整理、紀錄、設定」都收在同一個頁內狀態機，
    // 讓首頁與所有子頁共用配色、卡片、分類 Tab 與返回邏輯，不再散落成不同樣式。
    _controller.addListener(() => setState(() {}));
    _followUpController.addListener(() => setState(() {}));
    _recordSearchController.addListener(() => setState(() {}));
    _savedItems = List<_AssistantSavedItem>.of(_assistantSavedItems);
    final initialPrompt = widget.initialPrompt?.trim();
    if (initialPrompt != null && initialPrompt.isNotEmpty) {
      _controller.text = initialPrompt;
      _controller.selection = TextSelection.collapsed(
        offset: initialPrompt.length,
      );
      _page = _AssistantPrototypePage.input;
    }
    _recentConversationsFuture =
        _assistantRepository.fetchRecentConversations();
    _loadGuestUsage();
  }

  @override
  void dispose() {
    _controller.dispose();
    _followUpController.dispose();
    _recordSearchController.dispose();
    _focusNode.dispose();
    _assistantRepository.dispose();
    super.dispose();
  }

  Future<void> _loadGuestUsage() async {
    final hasUsed = await _guestUsage.hasUsed();
    if (!mounted) return;
    setState(() {
      _hasGuestUsed = hasUsed;
      _isCheckingGuestUsage = false;
    });
  }

  void _usePrompt(String prompt) {
    _controller.text = prompt;
    _controller.selection = TextSelection.collapsed(offset: prompt.length);
    setState(() => _page = _AssistantPrototypePage.input);
  }

  void _clearPrompt() {
    setState(() {
      _controller.clear();
    });
    _focusNode.requestFocus();
  }

  void _openConversation(LawAssistantConversation conversation) {
    setState(() {
      _conversation = conversation;
      _page = _AssistantPrototypePage.recordDetail;
    });
  }

  LawAssistantConversation get _activeConversation =>
      _conversation ?? _mockPrototypeConversation;

  LawAssistantAnswer? get _activeAnswer => _activeConversation.messages
      .where((message) => message.role == LawAssistantMessageRole.assistant)
      .map((message) => message.answer)
      .whereType<LawAssistantAnswer>()
      .firstOrNull;

  List<LawAssistantCitation> get _activeCitations {
    final messageCitations = _activeConversation.messages
        .where((message) => message.role == LawAssistantMessageRole.assistant)
        .expand((message) => message.citations)
        .toList(growable: false);
    if (messageCitations.isNotEmpty) return messageCitations;
    if (_activeConversation.sourceCitations.isNotEmpty) {
      return _activeConversation.sourceCitations;
    }
    return _assistantPrototypeCitations;
  }

  String get _activePrompt {
    final rawPrompt = _activeConversation.messages
            .where((message) => message.role == LawAssistantMessageRole.user)
            .map((message) => message.content)
            .firstOrNull ??
        _activeConversation.preview;
    return rawPrompt.split('\n\n問題類型：').first;
  }

  /// 台灣繁體中文教學註解：
  /// 小法助 Prototype 頁不假裝有完整後端時也能追問；正式環境走 repository，
  /// mock 環境則由同一個 repository 補一則本機示範回覆，UI 流程保持一致。
  Future<void> _sendFollowUp([String? presetPrompt]) async {
    final prompt = (presetPrompt ?? _followUpController.text).trim();
    final conversation = _conversation;
    if (prompt.isEmpty || conversation == null || _isSendingFollowUp) return;

    final appState = LawAppScope.of(context);
    if (conversation.isGuest && appState.isGuest) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('登入後可以在同一段對話中繼續追問並保存紀錄。'),
          action: SnackBarAction(
            label: '登入 Demo',
            onPressed: appState.signInDemo,
          ),
        ),
      );
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _isSendingFollowUp = true);
    _followUpController.clear();

    try {
      final updatedConversation = await _assistantRepository.sendMessage(
        conversationId: conversation.id,
        prompt: prompt,
      );
      if (!mounted) return;
      setState(() {
        _conversation = updatedConversation;
        _recentConversationsFuture =
            _assistantRepository.fetchRecentConversations();
        _page = _AssistantPrototypePage.answer;
        _isSendingFollowUp = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已送出追問，小法助已更新整理結果。')),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSendingFollowUp = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('追問暫時無法送出：$error')),
      );
    }
  }

  Future<void> _shareCurrentAnswer() async {
    final answer = _activeAnswer;
    final text = [
      '小法助整理：$_activePrompt',
      if (answer != null) answer.problemDirection,
      if (answer != null && answer.nextStep.isNotEmpty) answer.nextStep,
      '提醒：${_activeConversation.disclaimer}',
    ].where((line) => line.trim().isNotEmpty).join('\n\n');
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已複製小法助整理結果。')),
    );
  }

  void _saveConversation() {
    final conversation = _activeConversation;
    final item = _AssistantSavedItem(
      id: 'conversation-${conversation.id}',
      title: conversation.title,
      category: '對話',
      date: _assistantFullDateLabel(conversation.updatedAt),
      icon: Icons.chat_bubble_outline_rounded,
    );
    _addSavedItem(item, message: '已加入收藏對話。');
  }

  void _trackSelectedLaw() {
    _addSavedItem(
      _AssistantSavedItem(
        id: 'law-$_selectedLawTitle',
        title: _selectedLawTitle,
        category: '法條',
        date: _assistantFullDateLabel(DateTime.now()),
        icon: Icons.article_outlined,
      ),
      message: '已加入追蹤法條。你可以在收藏 / 追蹤查看。',
    );
  }

  void _addSavedItem(_AssistantSavedItem item, {required String message}) {
    final exists = _savedItems.any((saved) => saved.id == item.id);
    setState(() {
      if (!exists) _savedItems.insert(0, item);
      _savedTabIndex = 0;
      _page = _AssistantPrototypePage.saved;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(exists ? '這個項目已經在收藏 / 追蹤裡。' : message)),
    );
  }

  void _removeSavedItem(_AssistantSavedItem item) {
    setState(() => _savedItems.removeWhere((saved) => saved.id == item.id));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已從收藏 / 追蹤移除。')),
    );
  }

  void _openSavedItem(_AssistantSavedItem item) {
    if (item.category == '對話') {
      final matched = [
        if (_conversation != null) _conversation!,
        ..._assistantMockRecords,
      ].where((record) => item.title == record.title).firstOrNull;
      if (matched != null) _conversation = matched;
      setState(() => _page = _AssistantPrototypePage.recordDetail);
      return;
    }

    if (item.category == '法條') {
      setState(() {
        _selectedLawTitle = item.title;
        _page = _AssistantPrototypePage.statute;
      });
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已開啟「${item.title}」的本機收藏項目。')),
    );
  }

  Future<void> _submitPrompt() async {
    final prompt = _controller.text.trim();
    if (prompt.isEmpty || _isCheckingGuestUsage || _isCreating) return;
    final appState = LawAppScope.of(context);

    if (appState.isGuest && _hasGuestUsed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('未登入使用者只能先問一次；登入後可以保存更多對話。')),
      );
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _isCreating = true);
    try {
      // 台灣繁體中文教學註解：
      // 使用者在 Prototype 裡選的案件類型、文件備註與補充資訊都要一起送進資料層；
      // 這樣前端不是只改畫面文字，而是讓 AI 或 mock 回答真的能收到完整問題脈絡。
      final enrichedPrompt = _composePromptForAssistant(prompt);
      final conversation = await _assistantRepository.createConversation(
        prompt: enrichedPrompt,
        isGuestSession: appState.isGuest,
      );
      if (appState.isGuest) await _guestUsage.markUsed();
      if (!mounted) return;
      setState(() {
        _conversation = conversation.copyWith(isGuest: appState.isGuest);
        _recentConversationsFuture =
            _assistantRepository.fetchRecentConversations();
        _page = _AssistantPrototypePage.answer;
        _isCreating = false;
      });
      _loadGuestUsage();
    } catch (error) {
      if (!mounted) return;
      setState(() => _isCreating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('小法助暫時無法整理：$error')),
      );
    }
  }

  String _composePromptForAssistant(String prompt) {
    final contextLines = <String>[
      '問題類型：$_selectedIssueType',
      if (_documentNote.trim().isNotEmpty) '相關文件備註：$_documentNote',
      if (_supplementText.trim().isNotEmpty) '補充資訊：$_supplementText',
      '回答偏好：$_answerTone，$_answerLength',
      if (_provideExamples) '請提供生活案例協助理解。',
    ];
    return '$prompt\n\n${contextLines.join('\n')}';
  }

  @override
  Widget build(BuildContext context) {
    final assistantPalette = _LawAssistantPalette.of(context);

    return Scaffold(
      backgroundColor: assistantPalette.pageBackground,
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(58.h + MediaQuery.paddingOf(context).top),
        child: _AssistantFrozenAppBar(
          title: _titleForPage(),
          showBack: _page != _AssistantPrototypePage.home,
          onBack: _handleBack,
          trailing: _page == _AssistantPrototypePage.home
              ? _AssistantIconButton(
                  icon: Icons.history_rounded,
                  tooltip: '對話紀錄',
                  onTap: () =>
                      setState(() => _page = _AssistantPrototypePage.records),
                )
              : _topTrailing(),
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: KeyedSubtree(
                key: ValueKey(_page),
                child: _contentForPage(),
              ),
            ),
            if (!_assistantRepository.isBackendConfigured) ...[
              SizedBox(height: 10.h),
              const BackendNotConfiguredBanner(featureName: '小法助'),
            ],
          ],
        ),
      ),
    );
  }

  String _titleForPage() {
    switch (_page) {
      case _AssistantPrototypePage.home:
        return '小法助';
      case _AssistantPrototypePage.input:
        return '輸入問題';
      case _AssistantPrototypePage.answer:
        return '回答整理';
      case _AssistantPrototypePage.statute:
        return '法條詳情';
      case _AssistantPrototypePage.followUp:
        return '追問建議';
      case _AssistantPrototypePage.sources:
        return '來源與參考資料';
      case _AssistantPrototypePage.records:
        return '對話記錄';
      case _AssistantPrototypePage.recordDetail:
        return _conversation?.title ?? '對話詳情';
      case _AssistantPrototypePage.saved:
        return '我的收藏 / 追蹤';
      case _AssistantPrototypePage.settings:
        return '小法助設定';
      case _AssistantPrototypePage.plan:
        return '我的方案';
      case _AssistantPrototypePage.empty:
        return '開始提問吧！';
    }
  }

  Widget? _topTrailing() {
    if (_page == _AssistantPrototypePage.answer) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _AssistantIconButton(
            icon: Icons.ios_share_rounded,
            tooltip: '分享',
            onTap: _shareCurrentAnswer,
          ),
          SizedBox(width: 6.w),
          _AssistantIconButton(
            icon: Icons.bookmark_border_rounded,
            tooltip: '加入收藏',
            onTap: _saveConversation,
          ),
        ],
      );
    }
    return null;
  }

  void _handleBack() {
    if (_page == _AssistantPrototypePage.home) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      switch (_page) {
        case _AssistantPrototypePage.answer:
        case _AssistantPrototypePage.records:
        case _AssistantPrototypePage.saved:
        case _AssistantPrototypePage.settings:
        case _AssistantPrototypePage.plan:
        case _AssistantPrototypePage.empty:
        case _AssistantPrototypePage.input:
          _page = _AssistantPrototypePage.home;
        case _AssistantPrototypePage.statute:
        case _AssistantPrototypePage.followUp:
        case _AssistantPrototypePage.sources:
        case _AssistantPrototypePage.recordDetail:
          _page = _AssistantPrototypePage.answer;
        case _AssistantPrototypePage.home:
          break;
      }
    });
  }

  Widget _contentForPage() {
    switch (_page) {
      case _AssistantPrototypePage.home:
        return _homeContent();
      case _AssistantPrototypePage.input:
        return _inputContent();
      case _AssistantPrototypePage.answer:
        return _answerContent();
      case _AssistantPrototypePage.statute:
        return _statuteContent();
      case _AssistantPrototypePage.followUp:
        return _followUpContent();
      case _AssistantPrototypePage.sources:
        return _sourcesContent();
      case _AssistantPrototypePage.records:
        return _recordsContent();
      case _AssistantPrototypePage.recordDetail:
        return _recordDetailContent();
      case _AssistantPrototypePage.saved:
        return _savedContent();
      case _AssistantPrototypePage.settings:
        return _settingsContent();
      case _AssistantPrototypePage.plan:
        return _planContent();
      case _AssistantPrototypePage.empty:
        return _emptyContent();
    }
  }

  Widget _homeContent() {
    final appState = LawAppScope.of(context);
    return Column(
      children: [
        const _AssistantHero(),
        SizedBox(height: 14.h),
        _AssistantInputLauncher(
          onTap: () => setState(() => _page = _AssistantPrototypePage.input),
          onMic: () => _showVoiceSnack(),
        ),
        SizedBox(height: 18.h),
        _AssistantSectionHeader(
          title: '熱門提問',
          action: '換一換',
          onTap: () => setState(() {
            _hotQuestionOffset =
                (_hotQuestionOffset + 1) % _assistantHotQuestions.length;
          }),
        ),
        SizedBox(height: 8.h),
        for (final question in _rotatedHotQuestions())
          _AssistantQuestionRow(
              question: question, onTap: () => _usePrompt(question)),
        SizedBox(height: 18.h),
        _AssistantMemberCard(
          quota:
              '${appState.remainingAiQuota} / ${appState.accessTier.defaultDailyAiQuota}',
          onPlan: () => setState(() => _page = _AssistantPrototypePage.plan),
        ),
      ],
    );
  }

  Widget _inputContent() {
    final canSubmit = _controller.text.trim().isNotEmpty &&
        !_isCheckingGuestUsage &&
        !_isCreating;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AssistantTextArea(
          controller: _controller,
          focusNode: _focusNode,
          onClear: _clearPrompt,
          canSubmit: canSubmit,
          isSubmitting: _isCreating,
          onSubmit: _submitPrompt,
        ),
        if (_hasGuestUsed) ...[
          SizedBox(height: 8.h),
          Text(
            '未登入使用者已使用一次提問；登入後可以繼續追問並保存對話。',
            style: _AssistantText.caption(context),
          ),
        ],
        SizedBox(height: 18.h),
        Text('你也可以...', style: _AssistantText.section(context)),
        SizedBox(height: 8.h),
        _AssistantActionRow(
          icon: Icons.upload_file_outlined,
          title: '上傳相關文件',
          subtitle: _documentNote.isEmpty ? '附件、合約、對話紀錄等' : _documentNote,
          onTap: _editDocumentNote,
        ),
        _AssistantActionRow(
          icon: Icons.manage_search_rounded,
          title: '選擇問題類型',
          subtitle: _selectedIssueType,
          onTap: _chooseIssueType,
        ),
        _AssistantActionRow(
          icon: Icons.folder_copy_outlined,
          title: '補充更多資訊',
          subtitle: _supplementText.isEmpty ? '讓小法助更精準評估' : _supplementText,
          onTap: _editSupplementText,
        ),
        SizedBox(height: 20.h),
        Text(
          '小法助可能需要 10-20 秒整理答案。',
          textAlign: TextAlign.center,
          style: _AssistantText.caption(context),
        ),
        SizedBox(height: 10.h),
        _AssistantPrimaryButton(
          label: _isCreating ? '整理中...' : '開始整理',
          onPressed: canSubmit ? _submitPrompt : null,
        ),
      ],
    );
  }

  Widget _answerContent() {
    final answer = _activeAnswer;
    final lawTitles = _lawTitlesForCitations(_activeCitations);
    final actionSteps = _actionStepsForAnswer(answer);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AssistantUserPromptBubble(text: _activePrompt),
        SizedBox(height: 14.h),
        Text('小法助的整理結果', style: _AssistantText.section(context)),
        SizedBox(height: 10.h),
        _AssistantResultCard(
          title: '結論先了解',
          body: answer?.problemDirection ?? '房東如扣押金沒有合理依據，你有權要求返還押金。',
          motif: true,
        ),
        SizedBox(height: 12.h),
        Text('相關法條', style: _AssistantText.section(context)),
        SizedBox(height: 8.h),
        for (final title in lawTitles.take(3))
          _AssistantLawTile(
            title: title,
            onTap: () => setState(() {
              _selectedLawTitle = title;
              _page = _AssistantPrototypePage.statute;
            }),
          ),
        _AssistantSecondaryButton(
          label: '查看更多法條',
          onPressed: () =>
              setState(() => _page = _AssistantPrototypePage.sources),
        ),
        SizedBox(height: 14.h),
        Text('你可以採取的行動', style: _AssistantText.section(context)),
        SizedBox(height: 8.h),
        for (var index = 0; index < actionSteps.length; index++)
          _AssistantStepLine('${index + 1}', actionSteps[index]),
        SizedBox(height: 14.h),
        if (_provideExamples)
          _AssistantResultCard(
            title: '生活案例參考',
            body:
                answer?.relatedContent ?? '租客退租後房東以清潔費名義扣款，法院會看扣款是否有明確契約或實際支出。',
          ),
        if (answer?.disclaimer.isNotEmpty ??
            _activeConversation.disclaimer.isNotEmpty)
          _AssistantResultCard(
            title: '法律免責提醒',
            body: answer?.disclaimer ?? _activeConversation.disclaimer,
            leading: Icons.info_outline_rounded,
          ),
        SizedBox(height: 12.h),
        _AssistantFollowUpInput(
          onTap: () => setState(() => _page = _AssistantPrototypePage.followUp),
        ),
      ],
    );
  }

  Widget _statuteContent() {
    final answer = _activeAnswer;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_selectedLawTitle.replaceFirst('（', '\n（'),
            style: _AssistantText.section(context)),
        SizedBox(height: 12.h),
        const _AssistantInlineTabs(labels: ['條文內容', '白話解釋']),
        SizedBox(height: 12.h),
        _AssistantResultCard(
          title: '條文內容',
          body: _lawSummaryForTitle(_selectedLawTitle),
        ),
        SizedBox(height: 12.h),
        _AssistantResultCard(
          title: '白話解釋',
          body: answer?.problemDirection ?? '這裡先用白話整理法條與你的問題關聯；正式內容會依資料來源回傳更新。',
        ),
        SizedBox(height: 12.h),
        _AssistantResultCard(
          title: '生活案例',
          body: answer?.relatedContent ?? '房東沒有合理理由扣押金，房客可以要求返還押金或提出調解。',
        ),
        SizedBox(height: 14.h),
        _AssistantSecondaryButton(label: '加入追蹤', onPressed: _trackSelectedLaw),
      ],
    );
  }

  Widget _followUpContent() {
    final canFollowUp = _followUpController.text.trim().isNotEmpty &&
        !_isSendingFollowUp &&
        _conversation != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AssistantBotBubble(text: '小法助繼續幫你可以！'),
        SizedBox(height: 12.h),
        _AssistantResultCard(
          title: '寄存證信函',
          body: '正式要求房東提出扣款明細，並保留日後調解或訴訟的書面證據。',
          leading: Icons.mark_email_read_outlined,
        ),
        _AssistantResultCard(
          title: '向消保官申訴',
          body: '退租押金爭議可先由主管機關協助確認流程。',
          leading: Icons.account_balance_outlined,
        ),
        _AssistantResultCard(
          title: '申請調解',
          body: '向鄉鎮市區調解委員會申請，整理租約、照片、對話紀錄。',
          leading: Icons.groups_2_outlined,
        ),
        _AssistantResultCard(
          title: '提起訴訟',
          body: '若金額明確，可評估小額訴訟或支付命令。',
          leading: Icons.gavel_outlined,
        ),
        SizedBox(height: 14.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            _LearningSearchSuggestion(
              label: '存證信函怎麼寫？',
              onTap: () => _sendFollowUp('存證信函怎麼寫？'),
            ),
            _LearningSearchSuggestion(
              label: '調解流程需要多久？',
              onTap: () => _sendFollowUp('調解流程需要多久？'),
            ),
            _LearningSearchSuggestion(
              label: '我需要準備什麼證據？',
              onTap: () => _sendFollowUp('我需要準備什麼證據？'),
            ),
          ],
        ),
        SizedBox(height: 14.h),
        _AssistantFollowUpInput(
          controller: _followUpController,
          enabled: _conversation != null,
          isSending: _isSendingFollowUp,
          onTap: canFollowUp
              ? () => _sendFollowUp()
              : () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_conversation == null
                          ? '請先完成一次提問，再繼續追問。'
                          : '請先輸入追問內容。'),
                    ),
                  );
                },
          hint: '還有其他問題嗎？',
        ),
      ],
    );
  }

  Widget _sourcesContent() {
    final citations = _activeCitations;
    final lawTitles = _lawTitlesForCitations(citations);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AssistantResultCard(
          title: '本次回答的主要依據',
          body: lawTitles.join('、'),
          leading: Icons.article_outlined,
        ),
        SizedBox(height: 12.h),
        _AssistantSecondaryButton(
          label: '查看法條',
          onPressed: () => setState(() {
            _selectedLawTitle = lawTitles.first;
            _page = _AssistantPrototypePage.statute;
          }),
        ),
        SizedBox(height: 14.h),
        Text('延伸閱讀', style: _AssistantText.section(context)),
        SizedBox(height: 8.h),
        _AssistantBulletCard(
          items: citations
              .map((citation) => _citationLabel(citation))
              .toList(growable: false),
        ),
        SizedBox(height: 14.h),
        Text('資料來源', style: _AssistantText.section(context)),
        SizedBox(height: 8.h),
        _AssistantBulletCard(
          items: citations
              .map((citation) => _sourceTypeLabel(citation.sourceType))
              .toSet()
              .toList(growable: false),
        ),
        SizedBox(height: 14.h),
        Text(
          '資料更新時間：${_latestCitationDate(citations)}',
          style: _AssistantText.caption(context),
        ),
      ],
    );
  }

  Widget _recordsContent() {
    return FutureBuilder<List<LawAssistantConversation>>(
      future: _recentConversationsFuture,
      builder: (context, snapshot) {
        final records = [
          if (_conversation != null) _conversation!,
          ...snapshot.data ?? const <LawAssistantConversation>[],
          ..._assistantMockRecords,
        ]
            .where((record) => !_hiddenRecordIds.contains(record.id))
            .fold(<String, LawAssistantConversation>{}, (map, record) {
              map.putIfAbsent(record.id, () => record);
              return map;
            })
            .values
            .where(_recordMatchesSearch)
            .where(_recordMatchesTab)
            .toList(growable: false);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AssistantSearchField(
              hint: '搜尋對話紀錄',
              controller: _recordSearchController,
            ),
            SizedBox(height: 14.h),
            _AssistantSegmentTabs(
              labels: const ['全部', '今天', '近 7 天', '近 30 天'],
              selectedIndex: _recordTabIndex,
              onChanged: (index) => setState(() => _recordTabIndex = index),
            ),
            SizedBox(height: 12.h),
            if (records.isEmpty)
              const _AssistantResultCard(
                title: '找不到對話',
                body: '換個關鍵字或切回「全部」就能重新查看紀錄。',
                leading: Icons.search_off_rounded,
              )
            else
              for (final record in records.take(8))
                _AssistantRecordTile(
                  conversation: record,
                  onTap: () => _openConversation(record),
                ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '已使用 ${records.length} 次對話記錄',
                    style: _AssistantText.caption(context),
                  ),
                ),
                _AssistantIconButton(
                  icon: Icons.delete_outline_rounded,
                  tooltip: '清除目前紀錄列表',
                  onTap: _clearVisibleRecords,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _recordDetailContent() {
    final conversation = _conversation ?? _assistantMockRecords.first;
    final answer = conversation.messages
        .where((message) => message.role == LawAssistantMessageRole.assistant)
        .map((message) => message.answer)
        .whereType<LawAssistantAnswer>()
        .firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_assistantDateTimeLabel(conversation.updatedAt),
            style: _AssistantText.caption(context)),
        SizedBox(height: 12.h),
        _AssistantUserPromptBubble(text: conversation.preview),
        SizedBox(height: 14.h),
        Text('小法助的整理結果', style: _AssistantText.section(context)),
        SizedBox(height: 10.h),
        _AssistantResultCard(
          title: '結論先了解',
          body: answer?.problemDirection ?? '房東如扣押金沒有合理依據，你有權要求返還押金。',
        ),
        _AssistantBulletCard(items: _lawTitlesForCitations(_activeCitations)),
        SizedBox(height: 12.h),
        _AssistantSecondaryButton(
          label: '查看完整回答',
          onPressed: () =>
              setState(() => _page = _AssistantPrototypePage.answer),
        ),
        SizedBox(height: 20.h),
        Row(
          children: [
            Expanded(
                child: _AssistantBottomAction(
                    icon: Icons.ios_share_rounded,
                    label: '分享',
                    onTap: _shareCurrentAnswer)),
            Expanded(
                child: _AssistantBottomAction(
                    icon: Icons.star_border_rounded,
                    label: '加入收藏',
                    onTap: _saveConversation)),
            Expanded(
                child: _AssistantBottomAction(
                    icon: Icons.more_vert_rounded,
                    label: '更多',
                    onTap: () => _showRecordMore(conversation))),
          ],
        ),
      ],
    );
  }

  Widget _savedContent() {
    final labels = const ['全部', '對話', '法條', '案例', '筆記'];
    final items = _savedItems
        .where((item) =>
            _savedTabIndex == 0 || item.category == labels[_savedTabIndex])
        .toList(growable: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AssistantSegmentTabs(
          labels: labels,
          selectedIndex: _savedTabIndex,
          onChanged: (index) => setState(() => _savedTabIndex = index),
        ),
        SizedBox(height: 12.h),
        if (items.isEmpty)
          const _AssistantResultCard(
            title: '還沒有收藏項目',
            body: '在回答、法條或對話詳情按下收藏，就會出現在這裡。',
            leading: Icons.bookmark_border_rounded,
          )
        else
          for (final item in items)
            _AssistantSavedTile(
              item: item,
              isManaging: _isManagingSaved,
              onTap: () => _openSavedItem(item),
              onRemove: () => _removeSavedItem(item),
            ),
        SizedBox(height: 12.h),
        _AssistantSecondaryButton(
          label: _isManagingSaved ? '完成管理' : '管理收藏',
          onPressed: () => setState(() => _isManagingSaved = !_isManagingSaved),
        ),
      ],
    );
  }

  Widget _settingsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('回答偏好', style: _AssistantText.section(context)),
        SizedBox(height: 8.h),
        _AssistantSettingRow(
          title: '回答風格',
          value: _answerTone,
          onTap: () => _chooseSettingValue(
            title: '回答風格',
            values: const ['白話易懂', '條列整理', '正式精準'],
            currentValue: _answerTone,
            onSelected: (value) => setState(() => _answerTone = value),
          ),
        ),
        _AssistantSettingRow(
          title: '回答長度',
          value: _answerLength,
          onTap: () => _chooseSettingValue(
            title: '回答長度',
            values: const ['精簡', '一般', '詳細'],
            currentValue: _answerLength,
            onSelected: (value) => setState(() => _answerLength = value),
          ),
        ),
        _AssistantSwitchRow(
          title: '提供生活案例（幫助更容易理解）',
          value: _provideExamples,
          onChanged: (value) => setState(() => _provideExamples = value),
        ),
        SizedBox(height: 14.h),
        Text('通知設定', style: _AssistantText.section(context)),
        SizedBox(height: 8.h),
        _AssistantSwitchRow(
          title: '新功能通知',
          value: _newFeatureNotice,
          onChanged: (value) => setState(() => _newFeatureNotice = value),
        ),
        _AssistantSwitchRow(
          title: '對話結果提醒',
          value: _chatReminder,
          onChanged: (value) => setState(() => _chatReminder = value),
        ),
        SizedBox(height: 14.h),
        Text('其他', style: _AssistantText.section(context)),
        SizedBox(height: 8.h),
        _AssistantSettingRow(title: '清除對話紀錄', onTap: _clearVisibleRecords),
        _AssistantSettingRow(
          title: '隱私與資料使用說明',
          onTap: () => _showInfoSheet(
            title: '隱私與資料使用說明',
            body:
                '目前前端只會把你的提問、補充資訊與偏好送到小法助資料層。後端未設定時，回答會使用本機 mock，不會假裝已連到正式 AI 服務。',
          ),
        ),
        _AssistantSettingRow(
          title: '關於小法助',
          onTap: () => _showInfoSheet(
            title: '關於小法助',
            body: '小法助會協助整理法律問題、可能依據與下一步，但不取代律師意見。遇到急迫或重大權益事項，仍建議諮詢專業律師。',
          ),
        ),
      ],
    );
  }

  Widget _planContent() {
    final appState = LawAppScope.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AssistantPlanCard(
          quota:
              '${appState.remainingAiQuota} / ${appState.accessTier.defaultDailyAiQuota}',
          onUpgrade: appState.activateSubscriberDemo,
        ),
        SizedBox(height: 16.h),
        Text('方案比較', style: _AssistantText.section(context)),
        SizedBox(height: 8.h),
        const _AssistantPlanTable(),
        SizedBox(height: 14.h),
        _AssistantSecondaryButton(
          label: '查看 Pro 方案詳情',
          onPressed: () => _showInfoSheet(
            title: 'Pro 方案詳情',
            body: 'Demo 版會直接切換成 Pro 會員狀態，方便測試無限提問、完整記憶與追蹤提醒流程。',
          ),
        ),
      ],
    );
  }

  Widget _emptyContent() {
    return Column(
      children: [
        SizedBox(height: 28.h),
        const _AssistantEmptyIllustration(),
        SizedBox(height: 18.h),
        Text('還沒有對話記錄', style: _AssistantText.section(context)),
        SizedBox(height: 8.h),
        Text(
          '有任何法律問題，都可以問我。我會盡力幫你整理與解答。',
          textAlign: TextAlign.center,
          style: _AssistantText.body(context),
        ),
        SizedBox(height: 18.h),
        for (final question in _assistantHotQuestions.take(3))
          _AssistantQuestionRow(
              question: question, onTap: () => _usePrompt(question)),
        SizedBox(height: 12.h),
        _AssistantInputLauncher(
          onTap: () => setState(() => _page = _AssistantPrototypePage.input),
          onMic: _showVoiceSnack,
        ),
      ],
    );
  }

  List<String> _lawTitlesForCitations(List<LawAssistantCitation> citations) {
    final titles = citations
        .map((citation) {
          if (citation.lawName.isNotEmpty ||
              citation.articleNumber.isNotEmpty) {
            return '${citation.lawName} ${citation.articleNumber}'.trim();
          }
          return citation.title;
        })
        .where((title) => title.isNotEmpty)
        .toSet()
        .toList(growable: false);

    if (titles.isNotEmpty) return titles;
    return const ['民法 第 425 條（債務不履行）', '民法 第 183 條（損害賠償）'];
  }

  List<String> _rotatedHotQuestions() {
    return [
      for (var index = 0; index < _assistantHotQuestions.length; index++)
        _assistantHotQuestions[
            (index + _hotQuestionOffset) % _assistantHotQuestions.length],
    ];
  }

  List<String> _actionStepsForAnswer(LawAssistantAnswer? answer) {
    final recommended = answer?.recommendedActions.trim();
    if (recommended != null && recommended.isNotEmpty) {
      return recommended
          .split(RegExp(r'[；;。]\s*'))
          .map((step) => step.trim())
          .where((step) => step.isNotEmpty)
          .take(4)
          .toList(growable: false);
    }
    return const [
      '與對方溝通，要求說明具體依據',
      '保存對話紀錄、契約與付款證據',
      '必要時寄發存證信函或申請調解',
      '金額或風險較高時諮詢律師',
    ];
  }

  String _lawSummaryForTitle(String title) {
    if (title.contains('183')) {
      return '沒有法律上原因而受利益、致他人受損害時，可能需要返還利益。';
    }
    if (title.contains('425')) {
      return '租賃或契約關係裡，雙方仍要依約履行；若對方沒有合理依據扣款，可以要求說明與返還。';
    }
    return '這筆法條或來源會依目前回答的引用資料顯示；後端接上正式資料後會回傳更完整條文。';
  }

  String _citationLabel(LawAssistantCitation citation) {
    final date = citation.updatedAt ?? citation.publishedAt;
    final dateLabel =
        date == null ? '' : '・${_assistantFullDateLabel(date)} 更新';
    final urlLabel = citation.url.isEmpty ? '' : '・${citation.url}';
    return '${citation.title}$dateLabel$urlLabel';
  }

  String _sourceTypeLabel(LawAssistantCitationSourceType type) {
    switch (type) {
      case LawAssistantCitationSourceType.statute:
        return '法規資料';
      case LawAssistantCitationSourceType.judgment:
        return '法院裁判資料';
      case LawAssistantCitationSourceType.official:
        return '政府官方資料';
      case LawAssistantCitationSourceType.news:
        return '新聞與公開資訊';
      case LawAssistantCitationSourceType.other:
        return 'LawApp 本機示範資料';
    }
  }

  String _latestCitationDate(List<LawAssistantCitation> citations) {
    final dates = citations
        .map((citation) => citation.updatedAt ?? citation.publishedAt)
        .whereType<DateTime>()
        .toList(growable: false)
      ..sort((a, b) => b.compareTo(a));
    if (dates.isEmpty) return _assistantFullDateLabel(DateTime.now());
    return _assistantFullDateLabel(dates.first);
  }

  bool _recordMatchesSearch(LawAssistantConversation record) {
    final keyword = _recordSearchController.text.trim();
    if (keyword.isEmpty) return true;
    return '${record.title} ${record.preview} ${record.categoryLabel}'
        .contains(keyword);
  }

  bool _recordMatchesTab(LawAssistantConversation record) {
    final now = DateTime.now();
    final age = now.difference(record.updatedAt);
    switch (_recordTabIndex) {
      case 1:
        return record.updatedAt.year == now.year &&
            record.updatedAt.month == now.month &&
            record.updatedAt.day == now.day;
      case 2:
        return age.inDays < 7;
      case 3:
        return age.inDays < 30;
      default:
        return true;
    }
  }

  void _clearVisibleRecords() {
    // 台灣繁體中文教學註解：
    // 目前沒有正式刪除對話 API，所以 Prototype 先做「前端隱藏」；
    // 這比假裝已刪除伺服器資料誠實，後續接 API 時只要把這段換成 delete endpoint。
    final ids = <String>[
      if (_conversation != null) _conversation!.id,
      ..._assistantMockRecords.map((record) => record.id),
    ];
    setState(() {
      _hiddenRecordIds.addAll(ids);
      _conversation = null;
      _page = _AssistantPrototypePage.empty;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已在本機隱藏目前對話紀錄。')),
    );
  }

  Future<void> _chooseIssueType() async {
    await _chooseSettingValue(
      title: '選擇問題類型',
      values: const ['租屋糾紛', '勞資爭議', '交通事故', '消費退費', '網路言論', '其他法律問題'],
      currentValue: _selectedIssueType,
      onSelected: (value) => setState(() => _selectedIssueType = value),
    );
  }

  Future<void> _editDocumentNote() async {
    final value = await _showTextInputSheet(
      title: '上傳相關文件',
      hint: '例如：我有租約、押金收據、退租照片，尚未接正式檔案上傳。',
      initialValue: _documentNote,
    );
    if (value == null) return;
    setState(() => _documentNote = value);
  }

  Future<void> _editSupplementText() async {
    final value = await _showTextInputSheet(
      title: '補充更多資訊',
      hint: '例如：退租日期、房東扣款理由、你希望拿回多少押金。',
      initialValue: _supplementText,
    );
    if (value == null) return;
    setState(() => _supplementText = value);
  }

  Future<void> _chooseSettingValue({
    required String title,
    required List<String> values,
    required String currentValue,
    required ValueChanged<String> onSelected,
  }) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: _LawAssistantPalette.of(context).pageBackground,
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 18.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: _AssistantText.section(context)),
              SizedBox(height: 8.h),
              for (final value in values)
                _AssistantSettingRow(
                  title: value,
                  value: value == currentValue ? '目前' : null,
                  onTap: () => Navigator.of(context).pop(value),
                ),
            ],
          ),
        ),
      ),
    );
    if (selected == null) return;
    onSelected(selected);
  }

  Future<String?> _showTextInputSheet({
    required String title,
    required String hint,
    required String initialValue,
  }) async {
    final controller = TextEditingController(text: initialValue);
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _LawAssistantPalette.of(context).pageBackground,
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16.w,
            12.h,
            16.w,
            18.h + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: _AssistantText.section(context)),
              SizedBox(height: 10.h),
              _AssistantCard(
                padding: EdgeInsets.all(12.w),
                child: TextField(
                  controller: controller,
                  minLines: 3,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: _AssistantText.caption(context),
                    border: InputBorder.none,
                    isCollapsed: true,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              _AssistantPrimaryButton(
                label: '完成',
                onPressed: () =>
                    Navigator.of(context).pop(controller.text.trim()),
              ),
            ],
          ),
        ),
      ),
    );
    controller.dispose();
    return result;
  }

  void _showRecordMore(LawAssistantConversation conversation) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _LawAssistantPalette.of(context).pageBackground,
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 18.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _AssistantSettingRow(
                title: '複製整理結果',
                onTap: () {
                  Navigator.of(context).pop();
                  _shareCurrentAnswer();
                },
              ),
              _AssistantSettingRow(
                title: '隱藏這筆紀錄',
                onTap: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _hiddenRecordIds.add(conversation.id);
                    _page = _AssistantPrototypePage.records;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInfoSheet({required String title, required String body}) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _LawAssistantPalette.of(context).pageBackground,
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 18.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: _AssistantText.section(context)),
              SizedBox(height: 10.h),
              Text(body, style: _AssistantText.body(context)),
              SizedBox(height: 12.h),
              _AssistantSecondaryButton(
                label: '我知道了',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showVoiceSnack() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('語音輸入開發中；目前請先用文字描述問題。')),
    );
  }
}
