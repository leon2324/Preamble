part of '../know_law_page.dart';

class _LearningSearchTopBar extends StatelessWidget {
  const _LearningSearchTopBar({required this.onBack});

  final VoidCallback onBack;

  void _showHistoryDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '諮詢歷史紀錄',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF17231F),
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(Icons.close_rounded,
                            size: 20.sp, color: Colors.grey),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Color(0xFFE9DFD2), height: 1),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    children: [
                      _buildHistoryItem(
                          context, '租約提前解約與房東權益', '2026/06/20', '我租約下個月到期...'),
                      _buildHistoryItem(
                          context, '車禍賠償範圍與調解程序', '2026/06/15', '車禍對方受傷拖延...'),
                      _buildHistoryItem(
                          context, '公司無預警裁員與資遣費', '2026/06/10', '公司突然宣布裁員...'),
                      _buildHistoryItem(
                          context, '網購特價品瑕疵退換爭議', '2026/06/05', '網購特價商品有瑕疵...'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryItem(
      BuildContext context, String title, String date, String preview) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已載入歷史紀錄：「$title」')),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF17231F),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: const Color(0xFF8B928D),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              preview,
              style: TextStyle(
                fontSize: 11.sp,
                color: const Color(0xFF5A615C),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48.w,
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
                  color: const Color(0xFF2C5E43),
                ),
              ),
            ),
          ),
          Text(
            '問問小法助',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.normal,
              color: const Color(0xFF2C5E43),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 42.w,
              height: 42.w,
              child: InkWell(
                onTap: () => _showHistoryDialog(context),
                child: Icon(
                  Icons.history,
                  size: 24.sp,
                  color: const Color(0xFF2C5E43),
                ),
              ),
            ),
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

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5), // 暖米色背景
      body: GestureDetector(
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
            _buildSuggestionPills(),
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

  Widget _buildSuggestionPills() {
    final suggestions = const [
      '房東違約會怎麼算？',
      '押金不退還怎麼辦？',
      '寄存證信函範本',
    ];
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100.r),
                  border: Border.all(color: const Color(0xFFEDE4D8)),
                ),
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: const Color(0xFF2C5E43),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }).toList(),
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
      return Padding(
        padding: EdgeInsets.only(bottom: 16.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Container(
                constraints: BoxConstraints(maxWidth: 270.w),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFDF9), // 暖米白/白色
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.r),
                    topRight: Radius.circular(16.r),
                    bottomLeft: Radius.circular(16.r),
                    bottomRight: Radius.zero,
                  ),
                  border: Border.all(color: const Color(0xFFEDE4D8)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
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
                    color: const Color(0xFF17231F), // 深色文字
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Container(
              width: 32.w,
              height: 32.w,
              decoration: const BoxDecoration(
                color: Color(0xFFF2994A), // 橘色頭像
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 20.sp,
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
          // Mascot Avatar (吉祥物頭像)
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
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
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1500),
        ),
      );
  }

  // 台灣繁體中文教學註解：
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
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
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
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF17231F),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12.sp,
                      height: 1.45,
                      color: const Color(0xFF5A615C),
                    ),
                  ),
                  SizedBox(height: 14.h),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    minLines: 4,
                    maxLines: 8,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      labelText: fieldLabel,
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          child: const Text('取消'),
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
                          child: const Text('加入脈絡'),
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
        Widget field(String label, TextEditingController controller,
            {int maxLines = 1}) {
          return TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
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
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF17231F),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '把事件基本資料整理進輸入框，小法助會更容易先拆出爭點與需要補充的資料。',
                      style: TextStyle(
                        fontSize: 12.sp,
                        height: 1.45,
                        color: const Color(0xFF5A615C),
                      ),
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
                            child: const Text('取消'),
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
                            child: const Text('加入脈絡'),
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
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '補充問題資料',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF17231F),
                ),
              ),
              SizedBox(height: 16.h),
              Wrap(
                spacing: 14.w,
                runSpacing: 14.h,
                alignment: WrapAlignment.center,
                children: [
                  _buildPlusMenuItem(
                    context,
                    icon: Icons.photo_library_outlined,
                    label: '加入照片',
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _pickPhotoAttachment();
                    },
                  ),
                  _buildPlusMenuItem(
                    context,
                    icon: Icons.attach_file_rounded,
                    label: '匯入文件',
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _pickDocumentAttachment();
                    },
                  ),
                  _buildPlusMenuItem(
                    context,
                    icon: Icons.event_note_outlined,
                    label: '補充案件背景',
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _showCaseBackgroundSheet(parentContext);
                    },
                  ),
                  _buildPlusMenuItem(
                    sheetContext,
                    icon: Icons.article_outlined,
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
                    icon: Icons.bookmark_outline_rounded,
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
                    icon: Icons.format_list_numbered_rounded,
                    label: '整理提問',
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _appendQuestionStructure(parentContext);
                    },
                  ),
                ],
              ),
              SizedBox(height: 16.h),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: SizedBox(
        width: 80.w,
        child: Column(
          children: [
            CircleAvatar(
              radius: 24.r,
              backgroundColor: const Color(0xFFF3FAF6),
              child: Icon(icon, color: const Color(0xFF2EA26F), size: 22.sp),
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              style:
                  TextStyle(fontSize: 10.5.sp, color: const Color(0xFF5A615C)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canSend = widget.controller.text.trim().isNotEmpty &&
        !widget.isSending &&
        (widget.isFirstMessage || !widget.isGuest);

    final showDisabled = widget.isGuest && !widget.isFirstMessage;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, widget.bottomInset + 16.h),
      child: Container(
        padding: EdgeInsets.fromLTRB(14.w, 8.h, 12.w, 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: const Color(0xFFEDE4D8)),
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
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    Icons.add,
                    size: 24.sp,
                    color: const Color(0xFF5A615C),
                  ),
                  onPressed: () => _showPlusMenu(context),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    enabled: !showDisabled,
                    minLines: 1,
                    maxLines: 3,
                    style: TextStyle(
                        fontSize: 13.sp, color: const Color(0xFF17231F)),
                    decoration: InputDecoration(
                      hintText: widget.isFirstMessage
                          ? '請輸入您的法律問題，例如：車禍和解...'
                          : (widget.isGuest ? '登入後可以繼續追問' : '繼續追問...'),
                      border: InputBorder.none,
                      isCollapsed: true,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: canSend ? _handleSend : null,
                  child: Opacity(
                    opacity: canSend ? 1.0 : 0.4,
                    child: CircleAvatar(
                      backgroundColor: const Color(0xFF2EA26F),
                      radius: 16.r,
                      child: widget.isSending
                          ? SizedBox(
                              width: 14.w,
                              height: 14.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Icon(
                              Icons.arrow_upward_rounded,
                              color: Colors.white,
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
          '附件只作為問題脈絡，圖片與 PDF/Word 內容仍需以文字補充說明。',
          style: TextStyle(
            fontSize: 10.sp,
            height: 1.3,
            color: const Color(0xFF7B817D),
          ),
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
    final isImage = attachment.kind == _AssistantAttachmentKind.image;
    return Container(
      width: 178.w,
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF4FAF6),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFD8EEE3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: isImage && attachment.canShowPreview
                ? Image.memory(
                    attachment.previewBytes!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.image_outlined,
                      size: 20.sp,
                      color: const Color(0xFF2EA26F),
                    ),
                  )
                : Icon(
                    isImage ? Icons.image_outlined : Icons.description_outlined,
                    size: 20.sp,
                    color: const Color(0xFF2EA26F),
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
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF17231F),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  isImage
                      ? attachment.typeLabel
                      : '${attachment.typeLabel} · $sizeLabel',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9.5.sp,
                    color: const Color(0xFF6B736E),
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
                Icons.close_rounded,
                size: 16.sp,
                color: const Color(0xFF5A615C),
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
        // 4. 使用範圍與免責說明卡片
        const _AssistantBentoPlanCard(),
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

  void _showUsageDialog(BuildContext context) {
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
                  '小法助使用說明',
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
                  '法律學習輔助',
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.bold,
                    color: assistantPalette.secondary,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '僅供學習參考',
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
                      value: 1,
                      color: assistantPalette.accent,
                      backgroundColor: assistantPalette.cardSurface,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                '請查核官方來源',
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
                '小法助會協助整理問題方向、證據與可能爭點。',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: assistantPalette.mutedText,
                ),
              ),
              GestureDetector(
                onTap: () => _showUsageDialog(context),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: assistantPalette.accent,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    '使用說明',
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
      ['適用範圍', '法律學習、案件理解與資料整理'],
      ['資料限制', '畫面未標示即時更新時，請以官方來源為準'],
      ['實際個案', '請諮詢合格律師或相關專業人士'],
      ['法律效果', '不構成法律意見或委任關係'],
    ];

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1.1),
        1: FlexColumnWidth(2.2),
      },
      border: TableBorder(
        horizontalInside: BorderSide(
          color: assistantPalette.neutralBorder,
          width: 0.8.w,
        ),
      ),
      children: [
        TableRow(
          children: ['項目', '說明']
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
