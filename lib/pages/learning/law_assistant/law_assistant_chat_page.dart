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
    if (prompt.isEmpty || _isSending) return;

    if (_conversation == null) {
      _replyController.clear();
      await _createConversation(prompt);
      return;
    }

    final conversation = _conversation!;
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
                    _AssistantBentoIntro(
                      onPromptSelected: (prompt) {
                        _replyController.text = prompt;
                        _sendFollowUp();
                      },
                    ),
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
              isFirstMessage: messages.isEmpty,
              onSend: _sendFollowUp,
            ),
          ],
        ),
      ),
    );
  }
}

const String _svgSparkles = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M9.9 4.2 8.7 7.1 5.8 8.3l2.9 1.2 1.2 2.9 1.2-2.9 2.9-1.2-2.9-1.2-1.2-2.9Z"></path>
  <path d="M17.6 11.4 16.8 13l-1.6.8 1.6.8.8 1.6.8-1.6 1.6-.8-1.6-.8-.8-1.6Z"></path>
  <path d="M6.5 15.5 5.8 17l-1.5.7 1.5.7.7 1.5.7-1.5 1.5-.7-1.5-.7-.7-1.5Z"></path>
</svg>
''';

class _LawAssistantChatBubble extends StatelessWidget {
  const _LawAssistantChatBubble({required this.message});

  final LawAssistantMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == LawAssistantMessageRole.user;
    final assistantPalette = _LawAssistantPalette.of(context);

    if (isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          constraints: BoxConstraints(maxWidth: 270.w),
          margin: EdgeInsets.only(bottom: 16.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: assistantPalette.accent,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.r),
              topRight: Radius.circular(16.r),
              bottomLeft: Radius.circular(16.r),
              bottomRight: Radius.zero,
            ),
            boxShadow: [
              BoxShadow(
                color: assistantPalette.accent.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            message.content,
            style: TextStyle(
              fontSize: 13.sp,
              height: 1.5,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    // AI Chat Bubble (Assistant)
    return Padding(
      padding: EdgeInsets.only(bottom: 18.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Premium AI Sparkle Avatar
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE6BA79), Color(0xFFC8A261)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFC8A261).withValues(alpha: 0.22),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: SvgPicture.string(
                _svgSparkles,
                width: 15.w,
                height: 15.w,
                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Small Sparkle tag name
                Row(
                  children: [
                    Text(
                      '小法助',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: assistantPalette.accent,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: assistantPalette.subtleSurface,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        'AI 助理',
                        style: TextStyle(
                          fontSize: 8.sp,
                          fontWeight: FontWeight.bold,
                          color: assistantPalette.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Container(
                  constraints: BoxConstraints(maxWidth: 280.w),
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: assistantPalette.cardSurface,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.zero,
                      topRight: Radius.circular(16.r),
                      bottomLeft: Radius.circular(16.r),
                      bottomRight: Radius.circular(16.r),
                    ),
                    border: Border.all(color: assistantPalette.neutralBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _AssistantAnswerContent(message: message),
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
        (widget.isFirstMessage || !widget.isGuest);

    final showDisabled = widget.isGuest && !widget.isFirstMessage;

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
                enabled: !showDisabled,
                minLines: 1,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: widget.isFirstMessage
                      ? '請輸入您的法律問題，例如：車禍和解...'
                      : (widget.isGuest ? '登入後可以繼續追問' : '繼續追問...'),
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

class _AssistantBentoIntro extends StatelessWidget {
  const _AssistantBentoIntro({required this.onPromptSelected});

  final ValueChanged<String> onPromptSelected;

  @override
  Widget build(BuildContext context) {
    final assistantPalette = _LawAssistantPalette.of(context);
    final appState = LawAppScope.of(context);
    final user = appState.currentUser;
    final nameText = user.isGuest ? '您好' : user.displayName;

    final prompts = const [
      _PromptItem(
        title: '車禍理賠',
        desc: '車禍受傷對方拖延不談和解，我該如何保障權益？',
        icon: Icons.directions_car_outlined,
      ),
      _PromptItem(
        title: '租屋糾紛',
        desc: '房東拒絕退還押金，還扣除清潔費，這合法嗎？',
        icon: Icons.home_work_outlined,
      ),
      _PromptItem(
        title: '職場權益',
        desc: '公司無預警裁員，我能爭取哪些非自願離職補償？',
        icon: Icons.work_outline_rounded,
      ),
      _PromptItem(
        title: '網購消保',
        desc: '網購商品收到後發現瑕疵，商家卻說特價品不退換？',
        icon: Icons.shopping_bag_outlined,
      ),
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 16.h),
        // 1. AI 星星 Logo 區塊
        Container(
          width: 56.w,
          height: 56.w,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                assistantPalette.accent,
                assistantPalette.secondary.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: [
              BoxShadow(
                color: assistantPalette.accent
                    .withValues(alpha: isDark ? 0.3 : 0.15),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.auto_awesome_rounded,
            color: Colors.white,
            size: 26.sp,
          ),
        ),
        SizedBox(height: 16.h),
        // 2. 歡迎語與簡介
        Text(
          '$nameText，今天想諮詢什麼法律問題？',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w900,
            color: assistantPalette.primaryText,
            height: 1.25,
          ),
        ),
        SizedBox(height: 6.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            '「小法助」將為您梳理問題方向、整理可能爭點與證據建議',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5.sp,
              color: assistantPalette.mutedText,
              height: 1.4,
            ),
          ),
        ),
        SizedBox(height: 24.h),
        // 3. 2x2 Bento 推薦 Prompt 卡片
        Column(
          children: [
            Row(
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
            SizedBox(height: 10.h),
            Row(
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
          ],
        ),
        SizedBox(height: 24.h),
        // 4. 會員與額度卡片
        const _AssistantBentoPlanCard(),
        // 5. API 狀態提醒卡片
        if (const String.fromEnvironment('LAWAPP_API_BASE_URL')
            .trim()
            .isEmpty) ...[
          SizedBox(height: 12.h),
          const _ApiNotConfiguredCard(),
        ],
        SizedBox(height: 24.h),
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
    final assistantPalette = _LawAssistantPalette.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Ink(
          padding: EdgeInsets.all(12.w),
          height: 110.h,
          decoration: BoxDecoration(
            color: assistantPalette.cardSurface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: assistantPalette.neutralBorder,
              width: 1.2.w,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.05 : 0.015),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                item.icon,
                color: assistantPalette.accent,
                size: 18.sp,
              ),
              SizedBox(height: 6.h),
              Text(
                item.title,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w900,
                  color: assistantPalette.primaryText,
                ),
              ),
              SizedBox(height: 3.h),
              Expanded(
                child: Text(
                  item.desc,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.sp,
                    height: 1.35,
                    color: assistantPalette.mutedText,
                  ),
                ),
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

  void _showUpgradeDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        final assistantPalette = _LawAssistantPalette.of(context);
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
          backgroundColor: assistantPalette.cardSurface,
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '小法助方案對比',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                    color: assistantPalette.primaryText,
                  ),
                ),
                SizedBox(height: 16.h),
                const _PlanCompareTable(),
                SizedBox(height: 20.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: FilledButton.styleFrom(
                      backgroundColor: assistantPalette.accent,
                    ),
                    child: const Text('我知道了'),
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
    final assistantPalette = _LawAssistantPalette.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: assistantPalette.introSurface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: assistantPalette.border.withValues(alpha: isDark ? 0.3 : 0.5),
          width: 1.2.w,
        ),
        boxShadow: [
          BoxShadow(
            color: assistantPalette.secondary
                .withValues(alpha: isDark ? 0.05 : 0.02),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: assistantPalette.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'Demo 會員',
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.bold,
                    color: assistantPalette.secondary,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '每日提問額度剩餘 80%',
                style: TextStyle(
                  fontSize: 10.5.sp,
                  color: assistantPalette.mutedText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99.r),
                  child: SizedBox(
                    height: 6.h,
                    child: LinearProgressIndicator(
                      value: 0.8,
                      color: assistantPalette.accent,
                      backgroundColor: assistantPalette.cardSurface,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                '200 / 200',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: assistantPalette.primaryText,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '每日可提問次數上限為 200 次。',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: assistantPalette.mutedText,
                ),
              ),
              GestureDetector(
                onTap: () => _showUpgradeDialog(context),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: assistantPalette.accent,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    '升級 Pro',
                    style: TextStyle(
                      fontSize: 10.5.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
    final assistantPalette = _LawAssistantPalette.of(context);
    final rows = const [
      ['每日提問次數', '3 次', '5 次', '無限次'],
      ['小法助記憶', '有限', '完整', '完整'],
      ['引用法條數', '3 則', '5 則', '無限'],
      ['追蹤法條提醒', '-', '-', '✓'],
    ];

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1.5),
        1: FlexColumnWidth(),
        2: FlexColumnWidth(),
        3: FlexColumnWidth(),
      },
      border: TableBorder(
        horizontalInside: BorderSide(
          color: assistantPalette.neutralBorder,
          width: 0.8.w,
        ),
      ),
      children: [
        TableRow(
          children: ['功能', '訪客', 'Demo', 'Pro']
              .map(
                (text) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w900,
                      color: assistantPalette.primaryText,
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
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Text(
                      text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        color: assistantPalette.mutedText,
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

class _ApiNotConfiguredCard extends StatelessWidget {
  const _ApiNotConfiguredCard();

  @override
  Widget build(BuildContext context) {
    final assistantPalette = _LawAssistantPalette.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9EE),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFFE8B95F).withValues(alpha: 0.4),
          width: 1.w,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: const Color(0xFF94610D),
            size: 16.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              '小法助 尚未設定 LAWAPP_API_BASE_URL，目前使用本機 mock data，不會連到正式後端。',
              style: TextStyle(
                fontSize: 10.sp,
                height: 1.4,
                color: const Color(0xFF94610D),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
