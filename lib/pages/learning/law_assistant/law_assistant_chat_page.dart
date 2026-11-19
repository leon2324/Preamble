part of '../know_law_page.dart';

// 本機諮詢歷史紀錄條目，只存在 LawAssistantChatPage 的 local state，
// 不寫入後端或 SharedPreferences，App 重開後清除。
// 足以在 MAIC / TestFlight 展示真實功能流程。
class _LocalHistoryRecord {
  const _LocalHistoryRecord({
    required this.prompt,
    required this.createdAt,
    this.hasAttachment = false,
  });

  final String prompt;
  final DateTime createdAt;
  final bool hasAttachment;

  // 顯示用的時間標籤：今天的紀錄顯示 HH:mm，其他顯示 MM/dd
  String get timeLabel {
    final now = DateTime.now();
    final isToday = createdAt.year == now.year &&
        createdAt.month == now.month &&
        createdAt.day == now.day;
    if (isToday) {
      final h = createdAt.hour.toString().padLeft(2, '0');
      final m = createdAt.minute.toString().padLeft(2, '0');
      return '今天 $h:$m';
    }
    final mo = createdAt.month.toString().padLeft(2, '0');
    final d = createdAt.day.toString().padLeft(2, '0');
    return '$mo/$d';
  }

  // 預覽文字：最多 40 字
  String get preview {
    if (prompt.length <= 40) return prompt;
    return '${prompt.substring(0, 40)}...';
  }
}

class _LearningSearchTopBar extends StatelessWidget {
  const _LearningSearchTopBar({
    required this.onBack,
    required this.onShowHistory,
  });

  final VoidCallback onBack;
  final VoidCallback onShowHistory;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Row(
      children: [
        SizedBox(
          width: 40.w,
          height: 40.w,
          child: InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(12.r),
            child: Icon(
              PhosphorIconsRegular.caretLeft,
              size: 20.sp,
              color: t.textPrimary,
            ),
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '問問小法助',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: t.serifTitle(size: 17.5.sp),
              ),
              Text(
                '攻防爭點梳理 × 法源雙重編碼',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: t.sansBody(size: 11.sp, color: t.textMuted),
              ),
            ],
          ),
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          tooltip: '法務實戰工具',
          icon: Icon(
            PhosphorIconsRegular.toolbox,
            size: 20.sp,
            color: t.brandPrimary,
          ),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const LegalToolkitHubPage(),
              ),
            );
          },
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          tooltip: '對造公文白話翻譯',
          icon: Icon(
            PhosphorIconsRegular.translate,
            size: 20.sp,
            color: t.brandPrimary,
          ),
          onPressed: () => PlainDocumentTranslatorSheet.show(context),
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          tooltip: '諮詢歷史紀錄',
          icon: Icon(
            PhosphorIconsRegular.clockCounterClockwise,
            size: 20.sp,
            color: t.textPrimary,
          ),
          onPressed: onShowHistory,
        ),
      ],
    );
  }
}

class LawAssistantChatPage extends StatefulWidget {
  const LawAssistantChatPage({
    super.key,
    this.initialPrompt,
    this.conversationId,
    this.fallbackConversation,
    this.isGuestSession = false,
  });

  final String? initialPrompt;
  final String? conversationId;
  final LawAssistantConversation? fallbackConversation;
  final bool isGuestSession;

  @override
  State<LawAssistantChatPage> createState() => _LawAssistantChatPageState();
}

class _LawAssistantChatPageState extends State<LawAssistantChatPage> {
  final LawAssistantRepository _assistantRepository = LawAssistantRepository();
  final GuestLawAssistantUsage _guestUsage = const GuestLawAssistantUsage();
  final TextEditingController _replyController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  LawAssistantConversation? _conversation;
  String? _errorMessage;
  var _isLoading = false;
  var _isSending = false;
  StreamSubscription<LawAssistantStreamChunk>? _streamSubscription;

  // 本機諮詢歷史，存在 local state。每次送出新問題時新增一筆。
  // 不寫後端、不寫 SharedPreferences，App 重開後清除。
  // MAIC / TestFlight 展示時，在同一次 session 內完整呈現新增與查看流程。
  final List<_LocalHistoryRecord> _localHistory = [];

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _assistantRepository.dispose();
    _replyController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // 送出問題時呼叫此方法，把問題文字加入本機歷史 list。
  // 相同文字在短時間內不重複記錄（1 秒內視為重複）。
  void _addLocalHistory(String prompt, {bool hasAttachment = false}) {
    final trimmed = prompt.trim();
    if (trimmed.isEmpty) return;
    final now = DateTime.now();
    // 防止 1 秒內同一問題重複記錄
    if (_localHistory.isNotEmpty) {
      final last = _localHistory.first;
      if (last.prompt == trimmed &&
          now.difference(last.createdAt).inSeconds < 1) {
        return;
      }
    }
    setState(() {
      _localHistory.insert(
        0,
        _LocalHistoryRecord(
          prompt: trimmed,
          createdAt: now,
          hasAttachment: hasAttachment,
        ),
      );
      // 最多保留 20 筆，避免 list 無限成長
      if (_localHistory.length > 20) {
        _localHistory.removeRange(20, _localHistory.length);
      }
    });
  }

  void _showHistoryDialog() {
    final history = List<_LocalHistoryRecord>.unmodifiable(_localHistory);
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final dt = dialogContext.tokens;
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
          child: Container(
            constraints: BoxConstraints(maxHeight: 480.h),
            decoration: dt.cardDecoration(
              radius: 20.r,
              fill: dt.surfaceElevated,
              borderColor: dt.borderStrong,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 標題列
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 12.w, 10.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '諮詢歷史紀錄',
                        style: dt.serifTitle(size: 16.sp),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          PhosphorIconsRegular.x,
                          size: 19.sp,
                          color: dt.textSecondary,
                        ),
                        onPressed: () => Navigator.of(dialogContext).pop(),
                      ),
                    ],
                  ),
                ),
                Divider(color: dt.border, height: 1),
                // 列表區 or 空狀態
                if (history.isEmpty)
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 24.w, vertical: 36.h),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          PhosphorIconsRegular.chatTeardropDots,
                          size: 38.sp,
                          color: dt.textMuted,
                        ),
                        SizedBox(height: 14.h),
                        Text(
                          '尚無諮詢紀錄',
                          style: dt.sansTitle(size: 14.sp),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          '送出第一個問題後，\n這裡會自動保存本次會話的提問脈絡。',
                          textAlign: TextAlign.center,
                          style: dt.sansBody(size: 12.sp, height: 1.5),
                        ),
                      ],
                    ),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      itemCount: history.length,
                      separatorBuilder: (_, __) => Divider(
                        color: dt.border,
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                      ),
                      itemBuilder: (_, index) {
                        final record = history[index];
                        return InkWell(
                          onTap: () {
                            // 點擊歷史紀錄，把問題文字帶回輸入框，讓使用者可再次編輯或送出。
                            Navigator.of(dialogContext).pop();
                            _replyController.text = record.prompt;
                            _replyController.selection =
                                TextSelection.collapsed(
                              offset: record.prompt.length,
                            );
                            _showAssistantToast('已帶入這筆提問，可再補充細節。');
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 12.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        record.preview,
                                        style: dt.sansBody(
                                          size: 13.sp,
                                          weight: FontWeight.w600,
                                          color: dt.textPrimary,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      record.timeLabel,
                                      style: dt.tabularMetric(
                                        size: 11.sp,
                                        weight: FontWeight.w600,
                                        color: dt.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                                if (record.hasAttachment) ...[
                                  SizedBox(height: 4.h),
                                  Row(
                                    children: [
                                      Icon(
                                        PhosphorIconsRegular.paperclip,
                                        size: 12.sp,
                                        color: dt.textMuted,
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        '含附件脈絡',
                                        style: dt.sansBody(
                                          size: 11.sp,
                                          color: dt.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                SizedBox(height: 8.h),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAssistantToast(String message) {
    if (!mounted) return;
    CustomToast.show(context, message);
  }

  Future<void> _bootstrap() async {
    final initialPrompt = widget.initialPrompt?.trim();
    if (initialPrompt != null && initialPrompt.isNotEmpty) {
      await _createConversation(initialPrompt);
      return;
    }

    final conversationId = widget.conversationId;
    if (conversationId == null || conversationId.isEmpty) {
      setState(() {
        _conversation = widget.fallbackConversation;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _conversation = widget.fallbackConversation;
    });

    try {
      final conversation =
          await _assistantRepository.fetchConversation(conversationId);
      if (!mounted) return;
      setState(() {
        _conversation = conversation;
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = error.toString();
      });
    }
  }

  Future<void> _createConversation(String prompt) async {
    // 使用者送出第一則問題時，先把問題文字存入本機歷史。
    // 無論 API 是否成功，都先記錄，確保歷史紀錄不會因為 API 失敗而消失。
    _addLocalHistory(prompt);

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _conversation = _guestDraftConversation(prompt);
    });

    try {
      final conversation = await _assistantRepository.createConversation(
        prompt: prompt,
        isGuestSession: widget.isGuestSession,
      );
      if (widget.isGuestSession) {
        await _guestUsage.markUsed();
      }
      if (!mounted) return;
      setState(() {
        _conversation = conversation.copyWith(isGuest: widget.isGuestSession);
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = error.toString();
      });
    }
  }

  LawAssistantConversation _guestDraftConversation(String prompt) {
    final now = DateTime.now();
    return LawAssistantConversation(
      id: 'guest-draft',
      title: prompt.length > 18 ? '${prompt.substring(0, 18)}...' : prompt,
      preview: prompt,
      updatedAt: now,
      categoryLabel: '臨時',
      isGuest: widget.isGuestSession,
      isMock: true,
      messages: [
        LawAssistantMessage(
          id: 'guest-user-message',
          role: LawAssistantMessageRole.user,
          content: prompt,
          createdAt: now,
        ),
      ],
    );
  }

  Future<void> _sendFollowUp() async {
    final prompt = _replyController.text.trim();
    if (prompt.isEmpty || _isSending) return;

    if (_conversation == null) {
      _replyController.clear();
      await _createConversation(prompt);
      return;
    }

    final conversation = _conversation!;
    if (conversation.isGuest) {
      CustomToast.show(context, '登入後可以在同一段對話中繼續追問。');
      return;
    }

    final appState = PreambleScope.of(context);
    final allowed = await appState.subscriptionService.consumeAiQuota();
    if (!allowed) {
      if (!mounted) return;
      MorandiPaywallSheet.show(
        context,
        headline: '今日免費問診次數已達上限',
        subHeadline: '升級 PRO 專業會員，立即享有無限次 AI 深度法律諮詢與全功能書狀生成！',
      );
      return;
    }

    _replyController.clear();
    final now = DateTime.now();

    final userMsg = LawAssistantMessage(
      id: 'user-${now.microsecondsSinceEpoch}',
      role: LawAssistantMessageRole.user,
      content: prompt,
      createdAt: now,
    );

    final streamAssistantId = 'assistant-stream-${now.microsecondsSinceEpoch}';
    final initialAssistantMsg = LawAssistantMessage(
      id: streamAssistantId,
      role: LawAssistantMessageRole.assistant,
      content: '',
      createdAt: now.add(const Duration(milliseconds: 1)),
    );

    setState(() {
      _isSending = true;
      _errorMessage = null;
      _conversation = conversation.copyWith(
        preview: prompt,
        updatedAt: now,
        messages: [...conversation.messages, userMsg, initialAssistantMsg],
      );
    });
    _scrollToBottom();

    await _streamSubscription?.cancel();

    var streamingContent = '';
    List<LawAssistantCitation> streamingCitations = const [];
    LawAssistantAnswer? streamingAnswer;

    _streamSubscription = _assistantRepository
        .sendMessageStream(
          conversationId: conversation.id,
          prompt: prompt,
        )
        .listen(
      (chunk) {
        if (!mounted) return;
        streamingContent += chunk.textChunk;
        if (chunk.citations?.isNotEmpty == true) {
          streamingCitations = chunk.citations ?? [];
        }
        if (chunk.fullAnswer != null) {
          streamingAnswer = chunk.fullAnswer;
        }

        final currentMessages = List<LawAssistantMessage>.from(
          _conversation?.messages ?? const [],
        );
        final index = currentMessages.indexWhere((m) => m.id == streamAssistantId);

        if (index != -1) {
          currentMessages[index] = LawAssistantMessage(
            id: streamAssistantId,
            role: LawAssistantMessageRole.assistant,
            content: streamingContent,
            createdAt: now.add(const Duration(milliseconds: 1)),
            answer: streamingAnswer,
            citations: streamingCitations,
          );
        }

        setState(() {
          _conversation = _conversation?.copyWith(messages: currentMessages);
        });
        _scrollToBottom();
      },
      onDone: () {
        if (!mounted) return;
        setState(() {
          _isSending = false;
        });
        _scrollToBottom();
      },
      onError: (Object error) {
        if (!mounted) return;
        setState(() {
          _isSending = false;
          _errorMessage = error.toString();
        });
      },
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((__) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final conversation = _conversation;
    final messages = conversation?.messages ?? const <LawAssistantMessage>[];

    return Scaffold(
      // 台灣繁體中文教學註解：本頁輸入框已用 viewInsets 手動避開鍵盤，這裡關閉 Scaffold 自動縮高，避免鍵盤高度被重複計算造成底部 overflow。
      resizeToAvoidBottomInset: false,
      backgroundColor: t.canvas,
      body: PrivacyShieldWrapper(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Column(
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 8.h),
                child: _LearningSearchTopBar(
                  onBack: () => Navigator.of(context).pop(),
                  onShowHistory: _showHistoryDialog,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                controller: _scrollController,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 18.h),
                children: [
                  if (messages.isEmpty && !_isLoading)
                    _AssistantBentoIntro(
                      onPromptSelected: (prompt) {
                        _replyController.text = prompt;
                        _sendFollowUp();
                      },
                    ),
                  for (final message in messages)
                    _LawAssistantChatBubble(
                      message: message,
                      onConvertToDocument: (templateType, facts) =>
                          _handleConvertToDocument(templateType, facts, message),
                      onConsultLawyer: () {
                        final brief = CaseBriefPackager.fromAssistantMessage(message);
                        LawyerReferralSheet.show(context, caseBrief: brief);
                      },
                      onSaveToJournal: () async {
                        final insight = message.insight;
                        if (insight == null) return;
                        final facts = message.answer?.problemDirection.isNotEmpty == true
                            ? '${message.answer!.problemDirection}\n${message.answer!.relatedContent}'
                            : message.content;
                        final entry = UserCaseJournalRepository.fromAssistantInsight(
                          insight: insight,
                          rawFacts: facts,
                        );
                        final repo = UserCaseJournalRepository();
                        await repo.addEntry(entry);
                        if (context.mounted) {
                          CustomToast.show(
                            context,
                            '已將本案收錄至「紀事」自救進度追蹤！',
                            icon: Icons.check_circle_rounded,
                          );
                        }
                      },
                    ),
                  if (_isLoading)
                    const _AssistantStatusCard(message: '小法助正在整理方向...'),
                  if (_errorMessage != null)
                    _AssistantErrorCard(
                      message: _errorMessage!,
                      onRetry: () {
                        final initialPrompt = widget.initialPrompt?.trim();
                        if (initialPrompt != null && initialPrompt.isNotEmpty) {
                          _createConversation(initialPrompt);
                        } else {
                          _bootstrap();
                        }
                      },
                    ),
                ],
              ),
            ),
            _buildSuggestionPills(messages),
            _LawAssistantReplyBox(
              controller: _replyController,
              bottomInset: bottomInset,
              isSending: _isSending,
              isGuest: conversation?.isGuest ?? false,
              isFirstMessage: messages.isEmpty,
              onSend: _sendFollowUp,
            ),
          ],
        ),
      ),
      ),
    );
  }

  Future<void> _handleConvertToDocument(
    DocumentTemplateType templateType,
    String suggestedFacts,
    LawAssistantMessage message,
  ) async {
    final facts = suggestedFacts.isNotEmpty
        ? suggestedFacts
        : (message.answer?.problemDirection.isNotEmpty == true
            ? '${message.answer!.problemDirection}\n${message.answer!.relatedContent}'
            : message.content);

    // 🧠 透過後台大腦 100% 自主生成量身打造之動態公文結構
    final dynamicDoc = DynamicLegalDrafterBrain.generateFromFactDescription(
      rawFacts: facts,
    );

    final title = dynamicDoc.title;
    final formalContent = dynamicDoc.toFormalDocumentText();

    try {
      final appState = PreambleScope.of(context);
      final draft = await appState.documentRepository.createDraft(
        templateType: DocumentTemplateType.dynamicCustom,
        title: title,
        input: DocumentTemplateInput(
          senderName: dynamicDoc.senderName,
          receiverName: dynamicDoc.receiverName,
          facts: facts,
          evidence: dynamicDoc.evidences.join('、'),
          dynamicDocument: dynamicDoc,
        ),
      );

      if (!mounted) return;
      CustomToast.show(
        context,
        '已由 AI 大腦自主編排法律條款並生成草稿！',
        icon: Icons.auto_awesome_rounded,
      );

      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => LegalDocumentExportPage(
            title: draft.title,
            content: draft.content,
            dynamicDocument: dynamicDoc,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => LegalDocumentExportPage(
            title: title,
            content: formalContent,
            dynamicDocument: dynamicDoc,
          ),
        ),
      );
    }
  }

  Widget _buildSuggestionPills(List<LawAssistantMessage> messages) {
    final t = context.tokens;
    // 優先使用最後一則 Assistant 訊息的智慧追問，若無則展示通用建議
    List<String> suggestions = const [
      '房東違約會怎麼算？',
      '押金不退還怎麼辦？',
      '寄存證信函範本',
    ];

    if (messages.isNotEmpty) {
      final lastAssistant = messages.lastWhere(
        (m) => m.role == LawAssistantMessageRole.assistant,
        orElse: () => messages.last,
      );
      if (lastAssistant.insight?.suggestedFollowUps.isNotEmpty == true) {
        suggestions = lastAssistant.insight!.suggestedFollowUps;
      }
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: suggestions.map((text) {
            return GestureDetector(
              onTap: () {
                _replyController.text = text;
                _sendFollowUp();
              },
              child: Container(
                margin: EdgeInsets.only(right: 8.w),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: t.surface,
                  borderRadius: BorderRadius.circular(100.r),
                  border: Border.all(color: t.borderStrong),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      PhosphorIconsRegular.sparkle,
                      size: 13.sp,
                      color: t.brandPrimary,
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      text,
                      style: t.sansBody(
                        size: 11.5.sp,
                        weight: FontWeight.w700,
                        color: t.brandPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _LawAssistantChatBubble extends StatelessWidget {
  const _LawAssistantChatBubble({
    required this.message,
    this.onConvertToDocument,
    this.onConsultLawyer,
    this.onSaveToJournal,
  });

  final LawAssistantMessage message;
  final void Function(DocumentTemplateType, String)? onConvertToDocument;
  final VoidCallback? onConsultLawyer;
  final VoidCallback? onSaveToJournal;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == LawAssistantMessageRole.user;
    final t = context.tokens;

    if (isUser) {
      return Padding(
        padding: EdgeInsets.only(bottom: 16.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Container(
                constraints: BoxConstraints(maxWidth: 276.w),
                padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: t.brandContainer,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.r),
                    topRight: Radius.circular(16.r),
                    bottomLeft: Radius.circular(16.r),
                    bottomRight: Radius.circular(4.r),
                  ),
                  border: Border.all(
                    color: t.brandPrimary.withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  message.content,
                  style: t.sansBody(
                    size: 13.5.sp,
                    height: 1.5,
                    color: t.brandOnContainer,
                  ),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: t.accentBrassContainer,
                shape: BoxShape.circle,
                border: Border.all(
                  color: t.accentBrass.withValues(alpha: 0.4),
                ),
              ),
              child: Center(
                child: Icon(
                  PhosphorIconsFill.user,
                  color: t.accentOnBrassContainer,
                  size: 17.sp,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // AI Chat Bubble (Assistant)
    return Padding(
      padding: EdgeInsets.only(bottom: 18.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: t.borderStrong),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/assistant/law_assistant_home.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6.w,
                  runSpacing: 4.h,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      '小法助',
                      style: t.serifTitle(size: 13.sp, color: t.brandPrimary),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: t.accentBrassContainer,
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                      child: Text(
                        'AI 法務助理',
                        style: t.sansBody(
                          size: 11.sp,
                          weight: FontWeight.w700,
                          color: t.accentOnBrassContainer,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                // 台灣繁體中文教學註解：AI 回覆改以無框線、柔和底色的閱讀容器呈現，減少多層框線壓迫感。
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: t.surfaceSubtle.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4.r),
                      topRight: Radius.circular(16.r),
                      bottomLeft: Radius.circular(16.r),
                      bottomRight: Radius.circular(16.r),
                    ),
                  ),
                  child: _AssistantAnswerContent(
                    message: message,
                    onConvertToDocument: onConvertToDocument,
                    onConsultLawyer: onConsultLawyer,
                    onSaveToJournal: onSaveToJournal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AssistantAnswerContent extends StatelessWidget {
  const _AssistantAnswerContent({
    required this.message,
    this.onConvertToDocument,
    this.onConsultLawyer,
    this.onSaveToJournal,
  });

  final LawAssistantMessage message;
  final void Function(DocumentTemplateType, String)? onConvertToDocument;
  final VoidCallback? onConsultLawyer;
  final VoidCallback? onSaveToJournal;

  @override
  Widget build(BuildContext context) {
    final assistantPalette = _LawAssistantPalette.of(context);
    final answer = message.answer;
    final insight = message.insight;

    if (answer == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InlineCitationText(
            text: message.content,
            style: TextStyle(
              fontSize: 13.sp,
              height: 1.45,
              color: assistantPalette.primaryText,
            ),
          ),
          if (insight != null && onConvertToDocument != null) ...[
            LawAssistantInsightCard(
              insight: insight,
              initiallyExpanded: false,
              onConvertToDocument: onConvertToDocument!,
              onConsultLawyer: onConsultLawyer,
              onSaveToJournal: onSaveToJournal,
            ),
          ],
          SizedBox(height: 10.h),
          const _AssistantLegalDisclaimer(),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AssistantAnswerBlock(title: '問題方向', text: answer.problemDirection),
        _AssistantAnswerBlock(title: '相關內容', text: answer.relatedContent),
        _AssistantAnswerBlock(
            title: '可能法律爭點', text: answer.possibleLegalIssues),
        _AssistantAnswerBlock(title: '先準備的證據', text: answer.evidenceNeeded),
        _AssistantAnswerBlock(title: '下一步可以補充什麼', text: answer.nextStep),
        _AssistantAnswerBlock(title: '建議行動', text: answer.recommendedActions),
        if (message.citations?.isNotEmpty == true) ...[
          SourceCitationList(
            items: message.citations!
                .map((citation) => citation.toViewData())
                .toList(growable: false),
          ),
          SizedBox(height: 10.h),
        ],
        if (insight != null && onConvertToDocument != null) ...[
          LawAssistantInsightCard(
            insight: insight,
            initiallyExpanded: false,
            onConvertToDocument: onConvertToDocument!,
            onConsultLawyer: onConsultLawyer,
            onSaveToJournal: onSaveToJournal,
          ),
          SizedBox(height: 8.h),
        ],
        _AssistantLegalDisclaimer(message: answer.disclaimer),
      ],
    );
  }
}

class _AssistantLegalDisclaimer extends StatelessWidget {
  const _AssistantLegalDisclaimer({this.message = lawAppLegalDisclaimer});

  final String message;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    // AI 回覆固定補上免責與求助提醒，避免使用者把初步整理誤認為律師正式意見。
    return Text(
      message,
      style: t.sansBody(
        size: 11.sp,
        height: 1.48,
        color: t.textMuted,
      ),
    );
  }
}

class _AssistantAnswerBlock extends StatelessWidget {
  const _AssistantAnswerBlock({
    required this.title,
    required this.text,
  });

  static final RegExp _leadingBracketLabelRegex = RegExp(r'^【[^】]+】[:：]?\s*');

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final cleanedText =
        text.trim().replaceFirst(_leadingBracketLabelRegex, '').trim();
    if (cleanedText.isEmpty) return const SizedBox.shrink();
    final assistantPalette = _LawAssistantPalette.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w800,
              color: assistantPalette.primaryText,
            ),
          ),
          SizedBox(height: 4.h),
          InlineCitationText(
            text: cleanedText,
            style: TextStyle(
              fontSize: 13.sp,
              height: 1.5,
              color: assistantPalette.mutedText,
            ),
          ),
        ],
      ),
    );
  }
}

class _AssistantStatusCard extends StatelessWidget {
  const _AssistantStatusCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final assistantPalette = _LawAssistantPalette.of(context);

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: assistantPalette.subtleSurface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: assistantPalette.neutralBorder),
      ),
      child: Text(
        message,
        style: TextStyle(fontSize: 12.sp, color: assistantPalette.mutedText),
      ),
    );
  }
}

class _AssistantErrorCard extends StatelessWidget {
  const _AssistantErrorCard({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final assistantPalette = _LawAssistantPalette.of(context);

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: assistantPalette.cardSurface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: assistantPalette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: TextStyle(
              fontSize: 12.sp,
              height: 1.45,
              color: assistantPalette.mutedText,
            ),
          ),
          SizedBox(height: 8.h),
          TextButton(
            onPressed: onRetry,
            child: const Text('再試一次'),
          ),
        ],
      ),
    );
  }
}

class _LawAssistantReplyBox extends StatefulWidget {
  const _LawAssistantReplyBox({
    required this.controller,
    required this.bottomInset,
    required this.isSending,
    required this.isGuest,
    required this.isFirstMessage,
    required this.onSend,
  });

  final TextEditingController controller;
  final double bottomInset;
  final bool isSending;
  final bool isGuest;
  final bool isFirstMessage;
  final VoidCallback onSend;

  @override
  State<_LawAssistantReplyBox> createState() => _LawAssistantReplyBoxState();
}

class _LawAssistantReplyBoxState extends State<_LawAssistantReplyBox> {
  final ImagePicker _imagePicker = ImagePicker();
  final List<_AssistantLocalAttachment> _attachments = [];

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_refresh);
  }

  @override
  void didUpdateWidget(covariant _LawAssistantReplyBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;
    oldWidget.controller.removeListener(_refresh);
    widget.controller.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() => setState(() {});

  void _showAssistantToast(String message) {
    if (!mounted) return;
    CustomToast.show(context, message);
  }

  // Release 版的「＋」選單只做本機問題脈絡整理與本機附件狀態，
  // 不宣稱 OCR、PDF/Word 解析、雲端上傳或 AI 已理解附件內容。
  void _insertContextText(BuildContext context, String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final currentText = widget.controller.text;
    final selection = widget.controller.selection;
    final separator = currentText.trim().isEmpty ? '' : '\n\n';
    final insertion = '$separator$trimmed';

    if (selection.isValid && !selection.isCollapsed) {
      final nextText = currentText.replaceRange(
        selection.start,
        selection.end,
        insertion,
      );
      widget.controller.value = TextEditingValue(
        text: nextText,
        selection: TextSelection.collapsed(
          offset: selection.start + insertion.length,
        ),
      );
    } else if (selection.isValid &&
        selection.baseOffset >= 0 &&
        selection.baseOffset <= currentText.length) {
      final cursor = selection.baseOffset;
      final nextText = currentText.replaceRange(cursor, cursor, insertion);
      widget.controller.value = TextEditingValue(
        text: nextText,
        selection: TextSelection.collapsed(offset: cursor + insertion.length),
      );
    } else {
      final nextText = '$currentText$insertion';
      widget.controller.value = TextEditingValue(
        text: nextText,
        selection: TextSelection.collapsed(offset: nextText.length),
      );
    }

    _showAssistantToast('已加入目前問題脈絡，可確認後送出。');
  }

  String _formatFileSize(int? bytes) {
    if (bytes == null || bytes <= 0) return '大小未提供';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _attachmentSendNote() {
    if (_attachments.isEmpty) return '';
    final lines = <String>['【附件脈絡】'];
    for (final attachment in _attachments) {
      if (attachment.kind == _AssistantAttachmentKind.image) {
        lines.add(
          '- 圖片：${attachment.name}（已加入圖片作為問題脈絡附件；目前圖片內容仍需以文字補充說明。）',
        );
      } else {
        lines.add(
          '- 文件：${attachment.name}（已加入文件作為問題附件。若需要小法助整理內容，請貼上文件中的重點文字。）',
        );
      }
    }
    return lines.join('\n');
  }

  void _handleSend() {
    if (_attachments.isNotEmpty) {
      final note = _attachmentSendNote();
      if (note.isNotEmpty && !widget.controller.text.contains(note)) {
        _insertContextText(context, note);
      }
    }
    widget.onSend();
    if (_attachments.isNotEmpty && mounted) {
      setState(_attachments.clear);
    }
  }

  Future<void> _pickPhotoAttachment() async {
    XFile? image;
    try {
      image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 92,
      );
    } catch (_) {
      _showAssistantToast('目前無法開啟相簿，請確認照片權限後再試。');
      return;
    }

    final pickedImage = image;
    if (pickedImage == null) return;

    Uint8List? previewBytes;
    int? sizeBytes;
    var canShowPreview = true;
    try {
      previewBytes = await pickedImage.readAsBytes();
      sizeBytes = previewBytes.length;
    } catch (_) {
      canShowPreview = false;
      try {
        sizeBytes = await pickedImage.length();
      } catch (_) {
        sizeBytes = null;
      }
    }
    if (!mounted) return;

    final displayName =
        pickedImage.name.trim().isEmpty ? '已加入照片' : pickedImage.name;
    setState(() {
      _attachments.add(
        _AssistantLocalAttachment(
          id: 'image_${DateTime.now().microsecondsSinceEpoch}',
          name: displayName,
          typeLabel: '照片',
          path: pickedImage.path,
          previewBytes: previewBytes,
          sizeBytes: sizeBytes,
          canShowPreview: canShowPreview && previewBytes != null,
          kind: _AssistantAttachmentKind.image,
        ),
      );
    });

    _showAssistantToast(
      previewBytes == null ? '已加入照片，但無法顯示縮圖。' : '已加入照片，可再補充文字描述。',
    );
  }

  void _addDocumentAttachment(
      PlatformFile file, String extension, String? path) {
    setState(() {
      _attachments.add(
        _AssistantLocalAttachment(
          id: 'document_${DateTime.now().microsecondsSinceEpoch}',
          name: file.name,
          typeLabel: extension.isEmpty ? '文件' : extension.toUpperCase(),
          path: path,
          sizeBytes: file.size,
          canShowPreview: false,
          kind: _AssistantAttachmentKind.document,
        ),
      );
    });
  }

  void _showAttachmentReadFailedToast() {
    _showAssistantToast('無法讀取文件，請稍後再試或貼上文字重點。');
  }

  Future<void> _pickDocumentAttachment() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['txt', 'pdf', 'doc', 'docx'],
        allowMultiple: false,
        withData: false,
      );
      if (result == null || result.files.isEmpty) return;

      final file = result.files.single;
      final extension = (file.extension ?? p.extension(file.name))
          .replaceFirst('.', '')
          .toLowerCase();
      final path = file.path;
      if (!mounted) return;

      _addDocumentAttachment(file, extension, path);

      if (extension == 'txt' && path != null) {
        final content = await File(path).readAsString();
        if (!mounted) return;
        final trimmed = content.trim();
        if (trimmed.isEmpty) {
          _showAssistantToast('已加入文字文件，但文件內容為空。');
          return;
        }
        final safeContent = trimmed.length > 6000
            ? '${trimmed.substring(0, 6000)}\n\n（文字內容較長，已先帶入前 6000 字；可視需要再補充重點。）'
            : trimmed;
        _insertContextText(
          context,
          '''
【文件文字內容：${file.name}】
$safeContent

請根據以上資料，幫我整理重點與可能的法律爭點。''',
        );
        return;
      }

      _showAssistantToast('已加入文件；PDF / Word 內容需貼上重點文字。');
    } catch (_) {
      _showAttachmentReadFailedToast();
    }
  }

  void _removeAttachment(String id) {
    setState(() {
      _attachments.removeWhere((attachment) => attachment.id == id);
    });
    _showAssistantToast('附件已移除。');
  }

  void _showTextContextSheet({
    required BuildContext context,
    required String title,
    required String description,
    required String fieldLabel,
    required String emptyMessage,
    required String Function(String value) buildPrompt,
  }) {
    final controller = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final st = sheetContext.tokens;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: st.surfaceElevated,
              borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
              border: Border(top: BorderSide(color: st.borderStrong)),
            ),
            padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 20.h),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: st.serifTitle(size: 16.5.sp),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    description,
                    style: st.sansBody(size: 12.sp, height: 1.48),
                  ),
                  SizedBox(height: 14.h),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    minLines: 4,
                    maxLines: 8,
                    textInputAction: TextInputAction.newline,
                    style: st.sansBody(size: 13.sp, color: st.textPrimary),
                    decoration: InputDecoration(
                      labelText: fieldLabel,
                      labelStyle:
                          st.sansBody(size: 12.sp, color: st.textSecondary),
                      alignLabelWithHint: true,
                      filled: true,
                      fillColor: st.surface,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.r),
                        borderSide: BorderSide(color: st.borderStrong),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.r),
                        borderSide:
                            BorderSide(color: st.brandPrimary, width: 1.5),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: st.borderStrong),
                          ),
                          child: Text(
                            '取消',
                            style: st.sansBody(
                              size: 12.5.sp,
                              weight: FontWeight.w600,
                              color: st.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            final value = controller.text.trim();
                            if (value.isEmpty) {
                              _showAssistantToast(emptyMessage);
                              return;
                            }
                            Navigator.of(sheetContext).pop();
                            _insertContextText(context, buildPrompt(value));
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: st.brandPrimary,
                            foregroundColor: st.brandOnPrimary,
                          ),
                          child: Text(
                            '加入脈絡',
                            style: st.sansBody(
                              size: 12.5.sp,
                              weight: FontWeight.w700,
                              color: st.brandOnPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).whenComplete(controller.dispose);
  }

  void _showCaseBackgroundSheet(BuildContext context) {
    final timeController = TextEditingController();
    final peopleController = TextEditingController();
    final storyController = TextEditingController();
    final questionController = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final st = sheetContext.tokens;
        Widget field(String label, TextEditingController controller,
            {int maxLines = 1}) {
          return TextField(
            controller: controller,
            maxLines: maxLines,
            style: st.sansBody(size: 13.sp, color: st.textPrimary),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: st.sansBody(size: 12.sp, color: st.textSecondary),
              filled: true,
              fillColor: st.surface,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide(color: st.borderStrong),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide(color: st.brandPrimary, width: 1.5),
              ),
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: st.surfaceElevated,
              borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
              border: Border(top: BorderSide(color: st.borderStrong)),
            ),
            padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 20.h),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '補充案件背景',
                      style: st.serifTitle(size: 16.5.sp),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '把事件基本資料整理進輸入框，小法助會更容易先拆出爭點與需要補充的資料。',
                      style: st.sansBody(size: 12.sp, height: 1.48),
                    ),
                    SizedBox(height: 14.h),
                    field('事件時間', timeController),
                    SizedBox(height: 10.h),
                    field('涉及人物', peopleController),
                    SizedBox(height: 10.h),
                    field('發生經過', storyController, maxLines: 3),
                    SizedBox(height: 10.h),
                    field('目前疑問', questionController, maxLines: 2),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(sheetContext).pop(),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: st.borderStrong),
                            ),
                            child: Text(
                              '取消',
                              style: st.sansBody(
                                size: 12.5.sp,
                                weight: FontWeight.w600,
                                color: st.textPrimary,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              final time = timeController.text.trim();
                              final people = peopleController.text.trim();
                              final story = storyController.text.trim();
                              final question = questionController.text.trim();
                              final hasAny = [
                                time,
                                people,
                                story,
                                question,
                              ].any((value) => value.isNotEmpty);
                              if (!hasAny) {
                                _showAssistantToast('請先輸入要補充的案件背景。');
                                return;
                              }

                              Navigator.of(sheetContext).pop();
                              _insertContextText(
                                context,
                                '''
【案件背景】
時間：${time.isEmpty ? '（待補）' : time}
人物：${people.isEmpty ? '（待補）' : people}
經過：${story.isEmpty ? '（待補）' : story}
目前疑問：${question.isEmpty ? '（待補）' : question}

請先幫我整理這個問題的法律爭點。''',
                              );
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: st.brandPrimary,
                              foregroundColor: st.brandOnPrimary,
                            ),
                            child: Text(
                              '加入脈絡',
                              style: st.sansBody(
                                size: 12.5.sp,
                                weight: FontWeight.w700,
                                color: st.brandOnPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ).whenComplete(() {
      timeController.dispose();
      peopleController.dispose();
      storyController.dispose();
      questionController.dispose();
    });
  }

  void _appendQuestionStructure(BuildContext context) {
    final current = widget.controller.text.trim();
    if (current.isEmpty) {
      _showAssistantToast('請先輸入想詢問的問題。');
      return;
    }

    _insertContextText(
      context,
      '''
請幫我把上面的問題整理成：
1. 事件背景
2. 主要爭點
3. 可能涉及的法律概念
4. 我還需要補充哪些資料''',
    );
  }

  void _showPlusMenu(BuildContext context) {
    final parentContext = context;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final st = sheetContext.tokens;
        return Container(
          decoration: BoxDecoration(
            color: st.surfaceElevated,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
            border: Border(top: BorderSide(color: st.borderStrong)),
          ),
          padding: EdgeInsets.fromLTRB(
            20.w,
            18.h,
            20.w,
            MediaQuery.viewPaddingOf(sheetContext).bottom + 20.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: st.borderStrong,
                  borderRadius: BorderRadius.circular(99.r),
                ),
              ),
              SizedBox(height: 14.h),
              Text(
                '補充案件資料與脈絡',
                style: st.serifTitle(size: 15.5.sp),
              ),
              SizedBox(height: 16.h),
              Wrap(
                spacing: 14.w,
                runSpacing: 14.h,
                alignment: WrapAlignment.center,
                children: [
                  _buildPlusMenuItem(
                    sheetContext,
                    icon: PhosphorIconsRegular.image,
                    label: '加入照片',
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _pickPhotoAttachment();
                    },
                  ),
                  _buildPlusMenuItem(
                    sheetContext,
                    icon: PhosphorIconsRegular.paperclip,
                    label: '匯入文件',
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _pickDocumentAttachment();
                    },
                  ),
                  _buildPlusMenuItem(
                    sheetContext,
                    icon: PhosphorIconsRegular.notebook,
                    label: '補充案件背景',
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _showCaseBackgroundSheet(parentContext);
                    },
                  ),
                  _buildPlusMenuItem(
                    sheetContext,
                    icon: PhosphorIconsRegular.article,
                    label: '貼上參考資料',
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _showTextContextSheet(
                        context: parentContext,
                        title: '貼上參考資料',
                        description: '可貼上法條、判決、新聞、契約或對話文字；本功能只整理你貼上的文字，不會讀取檔案。',
                        fieldLabel: '參考資料文字',
                        emptyMessage: '請先貼上要補充的參考資料。',
                        buildPrompt: (value) => '''
【參考資料】
$value

請根據以上資料，幫我整理重點與可能的法律爭點。''',
                      );
                    },
                  ),
                  _buildPlusMenuItem(
                    sheetContext,
                    icon: PhosphorIconsRegular.bookmarkSimple,
                    label: '貼上過去問題',
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _showTextContextSheet(
                        context: parentContext,
                        title: '貼上過去問題重點',
                        description: '把先前問過或整理過的問題重點貼上，會回填到目前輸入框作為背景。',
                        fieldLabel: '過去問題重點',
                        emptyMessage: '請先輸入要補充的問題重點。',
                        buildPrompt: (value) => '''
【過去問題重點】
$value

請根據以上背景，協助我整理目前問題。''',
                      );
                    },
                  ),
                  _buildPlusMenuItem(
                    sheetContext,
                    icon: PhosphorIconsRegular.listNumbers,
                    label: '結構化提問',
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _appendQuestionStructure(parentContext);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlusMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final t = context.tokens;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: SizedBox(
        width: 84.w,
        child: Column(
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: t.brandContainer,
                shape: BoxShape.circle,
                border: Border.all(
                  color: t.brandPrimary.withValues(alpha: 0.22),
                ),
              ),
              child: Icon(icon, color: t.brandPrimary, size: 21.sp),
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              style: t.sansBody(
                size: 11.5.sp,
                weight: FontWeight.w600,
                color: t.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final safeBottom = MediaQuery.viewPaddingOf(context).bottom;
    final effectiveBottomPadding = widget.bottomInset > 0
        ? widget.bottomInset + 10.h
        : safeBottom + 12.h;

    final canSend = widget.controller.text.trim().isNotEmpty &&
        !widget.isSending &&
        (widget.isFirstMessage || !widget.isGuest);

    final showDisabled = widget.isGuest && !widget.isFirstMessage;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, effectiveBottomPadding),
      child: Container(
        padding: EdgeInsets.fromLTRB(12.w, 8.h, 10.w, 8.h),
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: t.borderStrong),
          boxShadow: [
            BoxShadow(
              color: t.shadowAmbient,
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_attachments.isNotEmpty) ...[
              _AssistantAttachmentTray(
                attachments: _attachments,
                onRemove: _removeAttachment,
                formatFileSize: _formatFileSize,
              ),
              SizedBox(height: 8.h),
            ],
            Row(
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(
                    minWidth: 34.w,
                    minHeight: 34.w,
                  ),
                  tooltip: '補充問題資料',
                  icon: Icon(
                    PhosphorIconsRegular.plusCircle,
                    size: 23.sp,
                    color: t.brandPrimary,
                  ),
                  onPressed: () => _showPlusMenu(context),
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    enabled: !showDisabled,
                    minLines: 1,
                    maxLines: 4,
                    style: t.sansBody(size: 13.5.sp, color: t.textPrimary),
                    decoration: InputDecoration(
                      hintText: widget.isFirstMessage
                          ? '請描述您的法律困擾，例如：退租被扣押金...'
                          : (widget.isGuest ? '登入後可以繼續追問' : '繼續追問或補充細節...'),
                      hintStyle: t.sansBody(size: 13.sp, color: t.textMuted),
                      border: InputBorder.none,
                      isCollapsed: true,
                    ),
                  ),
                ),
                SizedBox(width: 6.w),
                GestureDetector(
                  onTap: canSend ? _handleSend : null,
                  child: Opacity(
                    opacity: canSend ? 1.0 : 0.38,
                    child: Container(
                      width: 34.w,
                      height: 34.w,
                      decoration: BoxDecoration(
                        color: t.brandPrimary,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: widget.isSending
                          ? SizedBox(
                              width: 15.w,
                              height: 15.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: t.brandOnPrimary,
                              ),
                            )
                          : Icon(
                              PhosphorIconsBold.arrowUp,
                              color: t.brandOnPrimary,
                              size: 16.sp,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum _AssistantAttachmentKind { image, document }

class _AssistantLocalAttachment {
  const _AssistantLocalAttachment({
    required this.id,
    required this.name,
    required this.typeLabel,
    required this.kind,
    this.path,
    this.previewBytes,
    this.sizeBytes,
    this.canShowPreview = false,
  });

  final String id;
  final String name;
  final String typeLabel;
  final _AssistantAttachmentKind kind;
  final String? path;
  final Uint8List? previewBytes;
  final int? sizeBytes;
  final bool canShowPreview;
}

class _AssistantAttachmentTray extends StatelessWidget {
  const _AssistantAttachmentTray({
    required this.attachments,
    required this.onRemove,
    required this.formatFileSize,
  });

  final List<_AssistantLocalAttachment> attachments;
  final ValueChanged<String> onRemove;
  final String Function(int? bytes) formatFileSize;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: attachments
                .map(
                  (attachment) => Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: _AssistantAttachmentChip(
                      attachment: attachment,
                      onRemove: () => onRemove(attachment.id),
                      sizeLabel: formatFileSize(attachment.sizeBytes),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          '附件僅作為問題脈絡索引，圖片與 PDF / Word 重點仍建議以文字補充。',
          style: t.sansBody(size: 11.sp, color: t.textMuted),
        ),
      ],
    );
  }
}

class _AssistantAttachmentChip extends StatelessWidget {
  const _AssistantAttachmentChip({
    required this.attachment,
    required this.onRemove,
    required this.sizeLabel,
  });

  final _AssistantLocalAttachment attachment;
  final VoidCallback onRemove;
  final String sizeLabel;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final isImage = attachment.kind == _AssistantAttachmentKind.image;
    return Container(
      width: 184.w,
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: t.surfaceSubtle,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: t.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: t.surface,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: isImage && attachment.canShowPreview
                ? Image.memory(
                    attachment.previewBytes!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      PhosphorIconsRegular.image,
                      size: 20.sp,
                      color: t.brandPrimary,
                    ),
                  )
                : Icon(
                    isImage
                        ? PhosphorIconsRegular.image
                        : PhosphorIconsRegular.fileText,
                    size: 20.sp,
                    color: t.brandPrimary,
                  ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  attachment.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.sansBody(
                    size: 11.5.sp,
                    weight: FontWeight.w700,
                    color: t.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  isImage
                      ? attachment.typeLabel
                      : '${attachment.typeLabel} · $sizeLabel',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.tabularMetric(
                    size: 11.sp,
                    weight: FontWeight.w500,
                    color: t.textMuted,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 4.w),
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(999.r),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Icon(
                PhosphorIconsRegular.x,
                size: 15.sp,
                color: t.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AssistantBentoIntro extends StatelessWidget {
  const _AssistantBentoIntro({required this.onPromptSelected});

  final ValueChanged<String> onPromptSelected;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final appState = PreambleScope.of(context);
    final user = appState.currentUser;
    final nameText = user.isGuest ? '您好' : user.displayName;

    const prompts = [
      _PromptItem(
        title: '車禍理賠',
        desc: '車禍受傷對方拖延不談和解，我該如何保障權益？',
        icon: PhosphorIconsRegular.carProfile,
      ),
      _PromptItem(
        title: '租屋糾紛',
        desc: '房東拒絕退還押金，還扣除清潔費，這合法嗎？',
        icon: PhosphorIconsRegular.houseLine,
      ),
      _PromptItem(
        title: '職場權益',
        desc: '公司無預警裁員，我能爭取哪些非自願離職補償？',
        icon: PhosphorIconsRegular.briefcase,
      ),
      _PromptItem(
        title: '網購消保',
        desc: '網購商品收到後發現瑕疵，商家卻說特價品不退換？',
        icon: PhosphorIconsRegular.shoppingBagOpen,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 12.h),
        Container(
          width: 54.w,
          height: 54.w,
          decoration: BoxDecoration(
            color: t.brandPrimaryStrong,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: t.accentBrass.withValues(alpha: 0.55),
            ),
            boxShadow: [
              BoxShadow(
                color: t.shadowAmbient,
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Icon(
            PhosphorIconsFill.scales,
            color: t.accentBrass,
            size: 25.sp,
          ),
        ),
        SizedBox(height: 14.h),
        Text(
          '$nameText，今天想釐清哪一項法律爭點？',
          textAlign: TextAlign.center,
          style: t.serifTitle(size: 18.sp, height: 1.32),
        ),
        SizedBox(height: 6.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Text(
            '小法助將以「爭點核心 × 法條依據 × 下一步行動」雙重編碼為您梳理脈絡',
            textAlign: TextAlign.center,
            style: t.sansBody(size: 12.sp, height: 1.45),
          ),
        ),
        SizedBox(height: 20.h),
        LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 310 ||
                MediaQuery.textScalerOf(context).scale(1.0) > 1.35;
            if (isCompact) {
              return Column(
                children: [
                  for (var i = 0; i < prompts.length; i++) ...[
                    if (i > 0) SizedBox(height: 10.h),
                    _PromptBentoCard(
                      item: prompts[i],
                      onTap: () => onPromptSelected(prompts[i].desc),
                    ),
                  ],
                ],
              );
            }
            return Column(
              children: [
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _PromptBentoCard(
                          item: prompts[0],
                          onTap: () => onPromptSelected(prompts[0].desc),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: _PromptBentoCard(
                          item: prompts[1],
                          onTap: () => onPromptSelected(prompts[1].desc),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.h),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _PromptBentoCard(
                          item: prompts[2],
                          onTap: () => onPromptSelected(prompts[2].desc),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: _PromptBentoCard(
                          item: prompts[3],
                          onTap: () => onPromptSelected(prompts[3].desc),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        SizedBox(height: 20.h),
        const _AssistantBentoPlanCard(),
        SizedBox(height: 20.h),
      ],
    );
  }
}

class _PromptItem {
  const _PromptItem({
    required this.title,
    required this.desc,
    required this.icon,
  });

  final String title;
  final String desc;
  final IconData icon;
}

class _PromptBentoCard extends StatelessWidget {
  const _PromptBentoCard({
    required this.item,
    required this.onTap,
  });

  final _PromptItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Ink(
          padding: EdgeInsets.all(13.w),
          decoration: t.cardDecoration(radius: 16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: t.brandContainer,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  item.icon,
                  color: t.brandPrimary,
                  size: 17.sp,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                item.title,
                style: t.sansTitle(size: 13.sp),
              ),
              SizedBox(height: 4.h),
              Text(
                item.desc,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: t.sansBody(size: 11.5.sp, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AssistantBentoPlanCard extends StatelessWidget {
  const _AssistantBentoPlanCard();

  void _showUsageDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        final dt = dialogCtx.tokens;
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22.r),
            side: BorderSide(color: dt.borderStrong),
          ),
          backgroundColor: dt.surfaceElevated,
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '小法助法源查核與使用說明',
                  style: dt.serifTitle(size: 17.sp),
                ),
                SizedBox(height: 16.h),
                const _PlanCompareTable(),
                SizedBox(height: 20.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: () => Navigator.of(dialogCtx).pop(),
                    style: FilledButton.styleFrom(
                      backgroundColor: dt.brandPrimary,
                      foregroundColor: dt.brandOnPrimary,
                    ),
                    child: Text(
                      '我知道了',
                      style: dt.sansBody(
                        size: 12.5.sp,
                        weight: FontWeight.w700,
                        color: dt.brandOnPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: t.subtleBoxDecoration(
        radius: 18.r,
        fill: t.surfaceSubtle,
        borderColor: t.borderStrong,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8.w,
            runSpacing: 6.h,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: t.brandContainer,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      PhosphorIconsRegular.shieldCheck,
                      size: 13.sp,
                      color: t.brandPrimary,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '雙重編碼法源查核機制',
                      style: t.sansBody(
                        size: 11.sp,
                        weight: FontWeight.w700,
                        color: t.brandOnContainer,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '僅供法學參考 · 非正式委任意見',
                style: t.sansBody(
                  size: 11.sp,
                  weight: FontWeight.w600,
                  color: t.textMuted,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          // 雙重編碼法源檢核狀態徽章（取代原先誤導性的 100% 滿格進度條）
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: t.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: t.border),
            ),
            child: Wrap(
              spacing: 8.w,
              runSpacing: 6.h,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: t.accentBrassContainer,
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(
                      color: t.accentBrass.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        PhosphorIconsRegular.sealWarning,
                        size: 13.sp,
                        color: t.accentOnBrassContainer,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '待核對法源依據',
                        style: t.sansBody(
                          size: 11.sp,
                          weight: FontWeight.w700,
                          color: t.accentOnBrassContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: t.semanticSuccessContainer,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        PhosphorIconsRegular.sealCheck,
                        size: 13.sp,
                        color: t.semanticSuccess,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '已附法條引證',
                        style: t.sansBody(
                          size: 11.sp,
                          weight: FontWeight.w700,
                          color: t.semanticSuccess,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '引用條文請點擊引證編號或全國法規資料庫進行最終核對',
                  style: t.sansBody(size: 11.5.sp, color: t.textSecondary),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 10.w,
            runSpacing: 8.h,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                '協助梳理案件爭點、舉證清單與應對話術。',
                style: t.sansBody(size: 11.5.sp, color: t.textSecondary),
              ),
              InkWell(
                onTap: () => _showUsageDialog(context),
                borderRadius: BorderRadius.circular(10.r),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: t.brandPrimary,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    '使用說明',
                    style: t.sansBody(
                      size: 11.sp,
                      weight: FontWeight.w700,
                      color: t.brandOnPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlanCompareTable extends StatelessWidget {
  const _PlanCompareTable();

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    const rows = [
      ['適用範圍', '法律學習、案件爭點理解與舉證整理'],
      ['法源查核', '已附法條引證處可點擊核對全國法規資料庫原文'],
      ['實際個案', '涉及訴訟或重大權益請委任合格執業律師'],
      ['法律效果', '系統整理結果不構成正式法律意見或委任關係'],
    ];

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1.1),
        1: FlexColumnWidth(2.2),
      },
      border: TableBorder(
        horizontalInside: BorderSide(
          color: t.border,
          width: 1,
        ),
      ),
      children: [
        TableRow(
          children: ['項目', '說明']
              .map(
                (text) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
                  child: Text(
                    text,
                    textAlign: TextAlign.left,
                    style: t.sansBody(
                      size: 11.5.sp,
                      weight: FontWeight.w700,
                      color: t.textPrimary,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        for (final row in rows)
          TableRow(
            children: row
                .map(
                  (text) => Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
                    child: Text(
                      text,
                      textAlign: TextAlign.left,
                      style: t.sansBody(
                        size: 11.5.sp,
                        color: t.textSecondary,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}
