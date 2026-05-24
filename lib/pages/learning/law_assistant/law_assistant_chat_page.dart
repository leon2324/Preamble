part of '../know_law_page.dart';

class _LearningSearchTopBar extends StatelessWidget {
  const _LearningSearchTopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final assistantPalette = _LawAssistantPalette.of(context);

    return SizedBox(
      height: 42.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 42.w,
              height: 42.w,
              child: InkWell(
                onTap: onBack,
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 20.sp,
                  color: assistantPalette.primaryText,
                ),
              ),
            ),
          ),
          Text(
            '問小法助',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w900,
              color: assistantPalette.primaryText,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(width: 42.w, height: 42.w),
          ),
        ],
      ),
    );
  }
}

class _LearningSearchSuggestion extends StatelessWidget {
  const _LearningSearchSuggestion({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final assistantPalette = _LawAssistantPalette.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: assistantPalette.chipSurface,
            borderRadius: BorderRadius.circular(999.r),
            border: Border.all(color: assistantPalette.border),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: assistantPalette.secondary,
            ),
          ),
        ),
      ),
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

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _assistantRepository.dispose();
    _replyController.dispose();
    _scrollController.dispose();
    super.dispose();
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
    final conversation = _conversation;
    if (prompt.isEmpty || conversation == null || _isSending) return;

    if (conversation.isGuest) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('登入後可以在同一段對話中繼續追問。')),
      );
      return;
    }

    setState(() {
      _isSending = true;
      _errorMessage = null;
    });
    _replyController.clear();

    try {
      final updatedConversation = await _assistantRepository.sendMessage(
        conversationId: conversation.id,
        prompt: prompt,
      );
      if (!mounted) return;
      setState(() {
        _conversation = updatedConversation;
        _isSending = false;
      });
      _scrollToBottom();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSending = false;
        _errorMessage = error.toString();
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    final topPadding = MediaQuery.paddingOf(context).top;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final conversation = _conversation;
    final messages = conversation?.messages ?? const <LawAssistantMessage>[];
    final assistantPalette = _LawAssistantPalette.of(context);

    return Scaffold(
      backgroundColor: assistantPalette.pageBackground,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, topPadding + 14.h, 16.w, 8.h),
              child: _LearningSearchTopBar(
                onBack: () => Navigator.of(context).pop(),
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
                    const _AssistantStatusCard(message: '這段對話還沒有內容。'),
                  for (final message in messages)
                    _LawAssistantChatBubble(message: message),
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
            _LawAssistantReplyBox(
              controller: _replyController,
              bottomInset: bottomInset,
              isSending: _isSending,
              isGuest: conversation?.isGuest ?? false,
              onSend: _sendFollowUp,
            ),
          ],
        ),
      ),
    );
  }
}

class _LawAssistantChatBubble extends StatelessWidget {
  const _LawAssistantChatBubble({required this.message});

  final LawAssistantMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == LawAssistantMessageRole.user;
    final assistantPalette = _LawAssistantPalette.of(context);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: 292.w),
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color:
              isUser ? assistantPalette.accent : assistantPalette.introSurface,
          borderRadius: BorderRadius.circular(18.r),
          border:
              isUser ? null : Border.all(color: assistantPalette.neutralBorder),
        ),
        child: isUser
            ? Text(
                message.content,
                style: TextStyle(
                  fontSize: 13.sp,
                  height: 1.45,
                  color: assistantPalette.inverseText,
                ),
              )
            : _AssistantAnswerContent(message: message),
      ),
    );
  }
}

class _AssistantAnswerContent extends StatelessWidget {
  const _AssistantAnswerContent({required this.message});

  final LawAssistantMessage message;

  @override
  Widget build(BuildContext context) {
    final assistantPalette = _LawAssistantPalette.of(context);
    final answer = message.answer;
    if (answer == null || answer.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.content,
            style: TextStyle(
              fontSize: 13.sp,
              height: 1.45,
              color: assistantPalette.primaryText,
            ),
          ),
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
        if (message.citations.isNotEmpty) ...[
          SourceCitationList(
            items: message.citations
                .map((citation) => citation.toViewData())
                .toList(growable: false),
          ),
          SizedBox(height: 10.h),
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
    final assistantPalette = _LawAssistantPalette.of(context);

    // 台灣繁體中文教學註解：
    // AI 回覆固定補上免責與求助提醒，避免使用者把初步整理誤認為律師正式意見。
    return Text(
      message,
      style: TextStyle(
        fontSize: 10.5.sp,
        height: 1.45,
        color: assistantPalette.mutedText,
      ),
    );
  }
}

class _AssistantAnswerBlock extends StatelessWidget {
  const _AssistantAnswerBlock({
    required this.title,
    required this.text,
  });

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    final assistantPalette = _LawAssistantPalette.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w900,
              color: assistantPalette.primaryText,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
              height: 1.45,
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
    required this.onSend,
  });

  final TextEditingController controller;
  final double bottomInset;
  final bool isSending;
  final bool isGuest;
  final VoidCallback onSend;

  @override
  State<_LawAssistantReplyBox> createState() => _LawAssistantReplyBoxState();
}

class _LawAssistantReplyBoxState extends State<_LawAssistantReplyBox> {
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

  @override
  Widget build(BuildContext context) {
    final assistantPalette = _LawAssistantPalette.of(context);
    final canSend = widget.controller.text.trim().isNotEmpty &&
        !widget.isSending &&
        !widget.isGuest;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, widget.bottomInset + 16.h),
      child: Container(
        padding: EdgeInsets.fromLTRB(14.w, 8.h, 8.w, 8.h),
        decoration: BoxDecoration(
          color: assistantPalette.cardSurface,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: assistantPalette.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: widget.controller,
                enabled: !widget.isGuest,
                minLines: 1,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: widget.isGuest ? '登入後可以繼續追問' : '繼續追問...',
                  border: InputBorder.none,
                  isCollapsed: true,
                ),
              ),
            ),
            IconButton(
              onPressed: canSend ? widget.onSend : null,
              icon: widget.isSending
                  ? SizedBox(
                      width: 18.w,
                      height: 18.w,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      Icons.arrow_upward_rounded,
                      size: 20.sp,
                      color: canSend
                          ? assistantPalette.accent
                          : assistantPalette.mutedText,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
