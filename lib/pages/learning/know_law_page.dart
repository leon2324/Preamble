import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/data/law_assistant/guest_law_assistant_usage.dart';
import 'package:lawapp/data/law_assistant/law_assistant_api_service.dart';
import 'package:lawapp/data/law_assistant/law_assistant_models.dart';
import 'package:lawapp/data/mock_data/learning/learning_mock_data.dart';
import 'package:lawapp/pages/learning/learning_mock_detail_page.dart';
import 'package:lawapp/pages/learning/learning_quiz_page.dart';
import 'package:lawapp/pages/learning/statute_database_page.dart';
import 'package:lawapp/theme/adaptive_layout.dart';
import 'package:lawapp/theme/app_colors.dart';

/// 學習頁改成向下滑動的長頁版型。
///
/// 左上角先放主專題與最近案件，往下滑會接到常見主題與法條翻譯機，
/// 這樣就能對齊設計稿裡「往下捲到下一個畫面」的節奏。
class KnowLawPage extends StatefulWidget {
  const KnowLawPage({super.key});

  @override
  KnowLawPageState createState() => KnowLawPageState();
}

class KnowLawPageState extends State<KnowLawPage> {
  static const List<String> _learningCategories = [
    '租屋',
    '勞資',
    '交通',
    '刑事',
    '消費',
  ];

  void _openArticle(LearningMockArticle article) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LearningMockDetailPage(article: article),
      ),
    );
  }

  void _openLearningSearch() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const _LearningSearchPage(),
      ),
    );
  }

  void _openStatuteDatabase({String initialQuery = ''}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StatuteDatabasePage(initialQuery: initialQuery),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final layout = context.homeSearchLayout;
    final assistantPalette = _LawAssistantPalette.of(context);
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;
    final compactHeaderTop = layout.searchBarTopOffset.h + 8.h;
    final compactHeaderHeight = 98.h;
    final contentStartPadding = compactHeaderTop + compactHeaderHeight + 34.h;
    // 這裡維持學習頁自己的固定頂部，不再依賴共用搜尋列，
    // 讓搜尋入口可以縮成一顆 icon，避免佔掉太多學習內容空間。
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                16.w,
                contentStartPadding,
                16.w,
                context.pageContentBottomPadding + 52.h + keyboardInset,
              ),
              children: [
                const _LearningSectionTitle(title: '專題'),
                SizedBox(height: 10.h),
                _FeaturedTopicCard(
                  topic: learningTopic,
                  onTap: () => _openArticle(learningTopic.heroArticle),
                ),
                SizedBox(height: 10.h),
                const _PageDots(activeIndex: 0, count: 6),
                SizedBox(height: 18.h),
                const _LearningSectionTitle(title: '根據你最近查看的案件'),
                SizedBox(height: 12.h),
                _RecentCaseGrid(
                  items: _recentCases,
                  onTap: (item) => _openArticle(item.article),
                ),
                SizedBox(height: 26.h),
                const _LearningSectionTitle(title: '常見法律學習主題'),
                SizedBox(height: 12.h),
                _CommonTopicGrid(
                  items: _commonTopics,
                  onTap: (item) => _openArticle(item.article),
                ),
                SizedBox(height: 22.h),
                const _LearningSectionTitle(title: '法條資料庫'),
                SizedBox(height: 12.h),
                _StatuteDatabaseEntryCard(
                  onTap: _openStatuteDatabase,
                  onChipTap: (query) => _openStatuteDatabase(
                    initialQuery: query,
                  ),
                ),
                SizedBox(height: 24.h),
                const _LearningSectionTitle(title: '法律翻譯機'),
                SizedBox(height: 12.h),
                _TranslatorCard(
                  article: learningTopic.supportItems[1].article,
                  onTap: () =>
                      _openArticle(learningTopic.supportItems[1].article),
                ),
                SizedBox(height: 18.h),
                _TranslatorCard(
                  article: learningTopic.supportItems[2].article,
                  onTap: () =>
                      _openArticle(learningTopic.supportItems[2].article),
                  variant: _TranslatorCardVariant.compact,
                ),
                SizedBox(height: 16.h),
                _QuizEntryCard(
                  entry: learningTopic.quizEntry,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const LearningQuizPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Container(
                height: contentStartPadding - 6.h,
                color: assistantPalette.pageBackground,
              ),
            ),
          ),
          Positioned(
            top: compactHeaderTop,
            left: 16.w,
            right: 16.w,
            child: _LearningFrozenToolbar(
              categories: _learningCategories,
              onSearchTap: _openLearningSearch,
            ),
          ),
          Positioned(
            right: 18.w,
            bottom: 108.h,
            child: _FaqFloatingChip(
              onTap: () =>
                  _openArticle(learningTopic.supportItems.first.article),
            ),
          ),
        ],
      ),
    );
  }
}

class _LearningSectionTitle extends StatelessWidget {
  const _LearningSectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20.sp,
        height: 1.08,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _LawAssistantPalette {
  const _LawAssistantPalette({
    required this.pageBackground,
    required this.cardSurface,
    required this.introSurface,
    required this.subtleSurface,
    required this.chipSurface,
    required this.border,
    required this.neutralBorder,
    required this.accent,
    required this.secondary,
    required this.highlight,
    required this.primaryText,
    required this.mutedText,
    required this.inverseText,
  });

  final Color pageBackground;
  final Color cardSurface;
  final Color introSurface;
  final Color subtleSurface;
  final Color chipSurface;
  final Color border;
  final Color neutralBorder;
  // 主題主色：用在機器人 icon、送出按鈕、使用者泡泡等「主要強調」。
  final Color accent;
  // 輔色：用在較弱的 icon/標籤，讓畫面有溫度但不搶戲。
  final Color secondary;
  // 點綴色：只用在極小面積（例如徽章），避免整頁變成金色系。
  final Color highlight;
  final Color primaryText;
  final Color mutedText;
  final Color inverseText;

  static _LawAssistantPalette of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 教學註解：小法助配色用「深藍灰 + 灰綠 + 暖米金」。
    // 深色模式則提升明度與對比，避免主色在暗底上看起來灰掉。
    if (isDark) {
      return const _LawAssistantPalette(
        pageBackground: Color(0xFF0F1216),
        cardSurface: Color(0xFF151A20),
        introSurface: Color(0xFF17202A),
        subtleSurface: Color(0xFF131820),
        chipSurface: Color(0xFF182029),
        border: Color(0xFF2A3340),
        neutralBorder: Color(0xFF2A3340),
        // 深色模式下將主色提亮，確保按鈕/泡泡有足夠對比。
        accent: Color(0xFF9FB0C6),
        secondary: Color(0xFF9EB19A),
        // 深色模式的米金點綴：提高亮度，讓小徽章在暗底上更清楚。
        highlight: Color(0xFFE5CD93),
        primaryText: Color(0xFFF2F4F7),
        mutedText: Color(0xFFA3ABB6),
        inverseText: Color(0xFF0B0F14),
      );
    }

    return const _LawAssistantPalette(
      // 亮色模式：保持專業、乾淨、略帶溫度。
      pageBackground: Color(0xFFFCFCFA),
      cardSurface: Colors.white,
      introSurface: Color(0xFFF3F6F1),
      subtleSurface: Color(0xFFF3F6F1),
      chipSurface: Color(0xFFF3F6F1),
      border: Color(0xFFD9DDD8),
      neutralBorder: Color(0xFFD9DDD8),
      // 主色：深藍灰
      accent: Color(0xFF2F3A4A),
      // 輔色：灰綠
      secondary: Color(0xFF7E8F7A),
      // 點綴：暖米金
      // 教學註解：點綴色刻意比主色亮一階，讓徽章有溫度但不搶戲。
      highlight: Color(0xFFE2C77C),
      primaryText: Color(0xFF2F3A4A),
      mutedText: Color(0xFF7A7F87),
      inverseText: Color(0xFFFCFCFA),
    );
  }
}

class _LearningSearchPage extends StatefulWidget {
  const _LearningSearchPage();

  @override
  State<_LearningSearchPage> createState() => _LearningSearchPageState();
}

class _LearningSearchPageState extends State<_LearningSearchPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final LawAssistantApiService _assistantApiService = LawAssistantApiService();
  final GuestLawAssistantUsage _guestUsage = const GuestLawAssistantUsage();
  late Future<List<LawAssistantConversation>> _recentConversationsFuture;
  var _hasGuestUsed = false;
  var _isCheckingGuestUsage = true;

  @override
  void initState() {
    super.initState();
    // 教學註解：這頁是小法助入口與說明頁，先不要自動叫出鍵盤，
    // 才能讓使用者完整看到上方引導、常見提問與後續整理方式。
    _controller.addListener(() => setState(() {}));
    _recentConversationsFuture =
        _assistantApiService.fetchRecentConversations();
    _loadGuestUsage();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _assistantApiService.dispose();
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
    // 教學註解：常見提問膠囊不是直接送出答案，而是先填進輸入框，
    // 讓使用者可以沿用範例語氣，再補自己的情境細節。
    _controller.text = prompt;
    _controller.selection = TextSelection.collapsed(offset: prompt.length);
    _focusNode.requestFocus();
  }

  void _clearPrompt() {
    setState(() {
      _controller.clear();
    });
    _focusNode.requestFocus();
  }

  void _openConversation(LawAssistantConversation conversation) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LawAssistantChatPage(
          conversationId: conversation.id,
          fallbackConversation: conversation,
        ),
      ),
    );
  }

  void _submitPrompt() {
    final prompt = _controller.text.trim();
    if (prompt.isEmpty || _isCheckingGuestUsage) return;

    if (_hasGuestUsed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('未登入使用者只能先問一次；登入後可以保存更多對話。')),
      );
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => LawAssistantChatPage(initialPrompt: prompt),
          ),
        )
        .then((_) => _loadGuestUsage());
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final assistantPalette = _LawAssistantPalette.of(context);

    return Scaffold(
      backgroundColor: assistantPalette.pageBackground,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(16.w, topPadding + 14.h, 16.w, 24.h),
          children: [
            _LearningSearchTopBar(
              onBack: () => Navigator.of(context).pop(),
            ),
            SizedBox(height: 18.h),
            const _LawBuddyIntroBubble(),
            SizedBox(height: 14.h),
            Container(
              padding: EdgeInsets.fromLTRB(14.w, 12.h, 10.w, 8.h),
              decoration: BoxDecoration(
                color: assistantPalette.cardSurface,
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(color: assistantPalette.border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      minLines: 3,
                      maxLines: 4,
                      textInputAction: TextInputAction.newline,
                      decoration: InputDecoration(
                        hintText: '例如：房東說提前解約押金不能退，我該先看什麼？',
                        hintStyle: TextStyle(
                          fontSize: 13.sp,
                          height: 1.45,
                          color: assistantPalette.mutedText,
                        ),
                        border: InputBorder.none,
                        isCollapsed: true,
                      ),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_controller.text.isNotEmpty)
                        IconButton(
                          onPressed: _clearPrompt,
                          tooltip: '清除目前輸入',
                          visualDensity: VisualDensity.compact,
                          icon: Icon(
                            Icons.close_rounded,
                            size: 18.sp,
                            color: assistantPalette.secondary,
                          ),
                        ),
                      IconButton(
                        onPressed: () {},
                        tooltip: '語音輸入',
                        visualDensity: VisualDensity.compact,
                        icon: Icon(
                          Icons.mic_rounded,
                          size: 20.sp,
                          color: assistantPalette.secondary,
                        ),
                      ),
                      IconButton(
                        onPressed: _controller.text.trim().isEmpty
                            ? null
                            : _submitPrompt,
                        tooltip: '送出問題',
                        visualDensity: VisualDensity.compact,
                        icon: Icon(
                          Icons.arrow_upward_rounded,
                          size: 20.sp,
                          color: _controller.text.trim().isEmpty
                              ? assistantPalette.mutedText
                              : assistantPalette.accent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_hasGuestUsed) ...[
              SizedBox(height: 8.h),
              Text(
                '未登入使用者已使用一次提問；登入後可以繼續追問並保存對話。',
                style: TextStyle(
                  fontSize: 11.sp,
                  height: 1.4,
                  color: assistantPalette.mutedText,
                ),
              ),
            ],
            SizedBox(height: 20.h),
            Text(
              '也可以先這樣問',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: assistantPalette.primaryText,
              ),
            ),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 10.h,
              children: [
                _LearningSearchSuggestion(
                  label: '押金被扣怎麼辦？',
                  onTap: () => _usePrompt('房東說押金不能退，我可以先確認哪些事情？'),
                ),
                _LearningSearchSuggestion(
                  label: '加班費怎麼算？',
                  onTap: () => _usePrompt('公司說加班只能補休，不能領加班費，這樣合理嗎？'),
                ),
                _LearningSearchSuggestion(
                  label: '車禍先做什麼？',
                  onTap: () => _usePrompt('發生車禍後，我要先保存哪些資料和紀錄？'),
                ),
                _LearningSearchSuggestion(
                  label: '網購可以退貨嗎？',
                  onTap: () => _usePrompt('網購商品收到後不想要了，我可以主張退貨嗎？'),
                ),
              ],
            ),
            SizedBox(height: 22.h),
            // 教學註解：最近對話放在提問範例後方，取代原本的功能說明卡，
            // 讓使用者先完成提問，再往下看到可以接續的舊對話。
            _RecentLawAssistantConversations(
              conversationsFuture: _recentConversationsFuture,
              onConversationTap: _openConversation,
            ),
          ],
        ),
      ),
    );
  }
}

class _LawBuddyIntroBubble extends StatelessWidget {
  const _LawBuddyIntroBubble();

  @override
  Widget build(BuildContext context) {
    final assistantPalette = _LawAssistantPalette.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _LawBuddyAvatar(),
        SizedBox(width: 4.w),
        _CloudBubbleTrail(
          color: assistantPalette.border,
          fillColor: assistantPalette.introSurface,
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: _CloudChatBubble(
            fillColor: assistantPalette.introSurface,
            borderColor: assistantPalette.border,
            padding: EdgeInsets.fromLTRB(22.w, 18.h, 20.w, 18.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '把情況說清楚，我先幫你找方向',
                  style: TextStyle(
                    fontSize: 15.sp,
                    height: 1.35,
                    fontWeight: FontWeight.w900,
                    color: assistantPalette.primaryText,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  '我會整理可能的法律主題、相關法條，以及下一步可以看的學習內容。',
                  style: TextStyle(
                    fontSize: 12.sp,
                    height: 1.45,
                    color: assistantPalette.mutedText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CloudBubbleTrail extends StatelessWidget {
  const _CloudBubbleTrail({
    required this.color,
    required this.fillColor,
  });

  final Color color;
  final Color fillColor;

  @override
  Widget build(BuildContext context) {
    // 教學註解：用逐漸變大的小圓把機器人和雲朵泡泡連起來，
    // 讓視覺像「想法冒出來」，而不是傳統尖尾巴 chat bubble。
    return Padding(
      padding: EdgeInsets.only(top: 26.h),
      child: SizedBox(
        width: 28.w,
        height: 16.h,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 0,
              top: 6.h,
              child: _CloudTrailDot(
                size: 5.w,
                color: color,
                fillColor: fillColor,
              ),
            ),
            Positioned(
              left: 8.w,
              top: 4.h,
              child: _CloudTrailDot(
                size: 7.w,
                color: color,
                fillColor: fillColor,
              ),
            ),
            Positioned(
              right: 0,
              top: 1.h,
              child: _CloudTrailDot(
                size: 11.w,
                color: color,
                fillColor: fillColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CloudTrailDot extends StatelessWidget {
  const _CloudTrailDot({
    required this.size,
    required this.color,
    required this.fillColor,
  });

  final double size;
  final Color color;
  final Color fillColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: fillColor,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1),
      ),
    );
  }
}

class _CloudChatBubble extends StatelessWidget {
  const _CloudChatBubble({
    required this.child,
    required this.fillColor,
    required this.borderColor,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final Color fillColor;
  final Color borderColor;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    // 教學註解：雲朵泡泡用 CustomPaint 畫出輪廓，再把內容當作 child 放進去，
    // 外層保留 cloudInset 給雲朵圓弧伸展，避免文字貼到雲邊或被輪廓壓住。
    final cloudInset = EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h);

    return CustomPaint(
      painter: _CloudBubblePainter(
        fillColor: fillColor,
        borderColor: borderColor,
      ),
      child: Padding(
        padding: cloudInset.add(padding),
        child: child,
      ),
    );
  }
}

class _CloudBubblePainter extends CustomPainter {
  const _CloudBubblePainter({
    required this.fillColor,
    required this.borderColor,
  });

  final Color fillColor;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final borderWidth = 1.0;
    final puff = (size.shortestSide * 0.28).clamp(14.0, 30.0);
    final horizontalMargin = puff * 0.82;
    final verticalMargin = puff * 0.72;
    final baseRect = Rect.fromLTWH(
      horizontalMargin,
      verticalMargin,
      (size.width - horizontalMargin * 2).clamp(0.0, size.width),
      (size.height - verticalMargin * 2).clamp(0.0, size.height),
    );
    final baseRadius = (puff * 1.6).clamp(24.0, 42.0);

    Path path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          baseRect,
          Radius.circular(baseRadius),
        ),
      );

    // 教學註解：這裡用多個大圓和圓角底座做 union，形成真正外擴的雲朵邊界；
    // 圓心刻意落在底座邊緣附近，讓雲朵能包住較長引文而不是只像圓角卡片。
    path = Path.combine(
      PathOperation.union,
      path,
      Path()
        ..addOval(
          Rect.fromCircle(
            center: Offset(baseRect.left + baseRect.width * 0.12, baseRect.top),
            radius: puff * 1.08,
          ),
        )
        ..addOval(
          Rect.fromCircle(
            center: Offset(baseRect.left + baseRect.width * 0.46, baseRect.top),
            radius: puff * 1.32,
          ),
        )
        ..addOval(
          Rect.fromCircle(
            center: Offset(baseRect.left + baseRect.width * 0.76, baseRect.top),
            radius: puff * 1.12,
          ),
        )
        ..addOval(
          Rect.fromCircle(
            center:
                Offset(baseRect.left, baseRect.top + baseRect.height * 0.48),
            radius: puff * 1.02,
          ),
        )
        ..addOval(
          Rect.fromCircle(
            center:
                Offset(baseRect.right, baseRect.top + baseRect.height * 0.46),
            radius: puff * 1.12,
          ),
        )
        ..addOval(
          Rect.fromCircle(
            center:
                Offset(baseRect.left + baseRect.width * 0.24, baseRect.bottom),
            radius: puff * 1.1,
          ),
        )
        ..addOval(
          Rect.fromCircle(
            center:
                Offset(baseRect.left + baseRect.width * 0.58, baseRect.bottom),
            radius: puff * 1.28,
          ),
        )
        ..addOval(
          Rect.fromCircle(
            center:
                Offset(baseRect.left + baseRect.width * 0.86, baseRect.bottom),
            radius: puff * 1.08,
          ),
        ),
    );

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = fillColor;
    canvas.drawPath(path, fillPaint);

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..color = borderColor;
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _CloudBubblePainter oldDelegate) {
    return oldDelegate.fillColor != fillColor ||
        oldDelegate.borderColor != borderColor;
  }
}

class _RecentLawAssistantConversations extends StatelessWidget {
  const _RecentLawAssistantConversations({
    required this.conversationsFuture,
    required this.onConversationTap,
  });

  final Future<List<LawAssistantConversation>> conversationsFuture;
  final ValueChanged<LawAssistantConversation> onConversationTap;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<LawAssistantConversation>>(
      future: conversationsFuture,
      builder: (context, snapshot) {
        final conversations = snapshot.data ?? const [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '最近對話',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: _LawAssistantPalette.of(context).primaryText,
              ),
            ),
            SizedBox(height: 10.h),
            if (snapshot.connectionState == ConnectionState.waiting)
              const _RecentConversationPlaceholder()
            else if (conversations.isEmpty)
              const _RecentConversationEmptyState()
            else
              Column(
                children: conversations.take(3).map((conversation) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: _RecentConversationCard(
                      conversation: conversation,
                      onTap: () => onConversationTap(conversation),
                    ),
                  );
                }).toList(growable: false),
              ),
          ],
        );
      },
    );
  }
}

class _RecentConversationEmptyState extends StatelessWidget {
  const _RecentConversationEmptyState();

  @override
  Widget build(BuildContext context) {
    final assistantPalette = _LawAssistantPalette.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: assistantPalette.subtleSurface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: assistantPalette.neutralBorder),
      ),
      child: Text(
        '登入後可以保存對話，之後回來就能接著問。',
        style: TextStyle(
          fontSize: 12.sp,
          height: 1.45,
          color: assistantPalette.mutedText,
        ),
      ),
    );
  }
}

class _RecentConversationPlaceholder extends StatelessWidget {
  const _RecentConversationPlaceholder();

  @override
  Widget build(BuildContext context) {
    final assistantPalette = _LawAssistantPalette.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: assistantPalette.subtleSurface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: assistantPalette.neutralBorder),
      ),
      child: Text(
        '正在讀取最近對話...',
        style: TextStyle(fontSize: 12.sp, color: assistantPalette.mutedText),
      ),
    );
  }
}

class _RecentConversationCard extends StatelessWidget {
  const _RecentConversationCard({
    required this.conversation,
    required this.onTap,
  });

  final LawAssistantConversation conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final assistantPalette = _LawAssistantPalette.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: assistantPalette.cardSurface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: assistantPalette.neutralBorder),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      conversation.title.isEmpty ? '未命名對話' : conversation.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w900,
                        color: assistantPalette.primaryText,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      conversation.preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        color: assistantPalette.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                conversation.categoryLabel.isEmpty
                    ? '對話'
                    : conversation.categoryLabel,
                style: TextStyle(
                  fontSize: 10.5.sp,
                  fontWeight: FontWeight.w800,
                  color: assistantPalette.secondary,
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20.sp,
                color: assistantPalette.mutedText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
                borderRadius: BorderRadius.circular(8.r),
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 28.sp,
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
  });

  final String? initialPrompt;
  final String? conversationId;
  final LawAssistantConversation? fallbackConversation;

  @override
  State<LawAssistantChatPage> createState() => _LawAssistantChatPageState();
}

class _LawAssistantChatPageState extends State<LawAssistantChatPage> {
  final LawAssistantApiService _assistantApiService = LawAssistantApiService();
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
    _assistantApiService.dispose();
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
          await _assistantApiService.fetchConversation(conversationId);
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
      final conversation =
          await _assistantApiService.createConversation(prompt: prompt);
      await _guestUsage.markUsed();
      if (!mounted) return;
      setState(() {
        _conversation = conversation.copyWith(isGuest: true);
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
      isGuest: true,
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
      final updatedConversation = await _assistantApiService.sendMessage(
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

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F0),
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
      return Text(
        message.content,
        style: TextStyle(
          fontSize: 13.sp,
          height: 1.45,
          color: assistantPalette.primaryText,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AssistantAnswerBlock(title: '問題方向', text: answer.problemDirection),
        _AssistantAnswerBlock(title: '相關內容', text: answer.relatedContent),
        _AssistantAnswerBlock(title: '下一步可以補充什麼', text: answer.nextStep),
      ],
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

class _LearningFrozenToolbar extends StatelessWidget {
  const _LearningFrozenToolbar({
    required this.categories,
    required this.onSearchTap,
  });

  final List<String> categories;
  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    final assistantPalette = _LawAssistantPalette.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: assistantPalette.introSurface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: assistantPalette.border),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const _LawBuddyAvatar(),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onSearchTap,
                        borderRadius: BorderRadius.circular(8.r),
                        child: Container(
                          height: 36.h,
                          padding: EdgeInsets.symmetric(horizontal: 2.w),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: assistantPalette.border,
                                width: 1.2.w,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search_rounded,
                                size: 18.sp,
                                color: assistantPalette.accent,
                              ),
                              SizedBox(width: 7.w),
                              Expanded(
                                child: Text(
                                  '說說你遇到的情況，我們一起解決',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w800,
                                    color: assistantPalette.primaryText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        SizedBox(
          height: 34.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return _LearningCategoryChip(label: categories[index]);
            },
            separatorBuilder: (_, __) => SizedBox(width: 8.w),
            itemCount: categories.length,
          ),
        ),
      ],
    );
  }
}

class _LawBuddyAvatar extends StatelessWidget {
  const _LawBuddyAvatar();

  @override
  Widget build(BuildContext context) {
    final assistantPalette = _LawAssistantPalette.of(context);

    // 教學註解：小法助先用內建 icon 組出 IP 雛形，刻意不加外框，
    // 讓角色像直接出現在 Header 裡；未來可整段替換成正式角色圖。
    return SizedBox(
      width: 42.w,
      height: 42.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.smart_toy_rounded,
            size: 35.sp,
            color: assistantPalette.accent,
          ),
          Positioned(
            right: 3.w,
            bottom: 2.w,
            child: Container(
              width: 15.w,
              height: 15.w,
              decoration: BoxDecoration(
                color: assistantPalette.highlight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.balance_rounded,
                size: 10.sp,
                color: assistantPalette.primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LearningCategoryChip extends StatelessWidget {
  const _LearningCategoryChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAEC),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: const Color(0xFFE2D7B8)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.5.sp,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF5C5C45),
        ),
      ),
    );
  }
}

class _FeaturedTopicCard extends StatelessWidget {
  const _FeaturedTopicCard({
    required this.topic,
    required this.onTap,
  });

  final LearningTopicData topic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24.r),
        child: Container(
          height: 254.h,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: const [
              BoxShadow(
                color: Color(0x18000000),
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              const _RoomSceneBackground(),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.05),
                      Colors.transparent,
                      const Color(0x3A000000),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 5.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.76),
                            borderRadius: BorderRadius.circular(999.r),
                          ),
                          child: Text(
                            '主專題',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primarySoft,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '2026/04/12',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF74685D),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      '租屋糾紛怎麼看懂',
                      style: TextStyle(
                        fontSize: 18.sp,
                        height: 1.05,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      topic.summary,
                      style: TextStyle(
                        fontSize: 12.sp,
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF2D261F),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      '從押金、解約到修繕責任，這個主專題會帶你用一條完整順序理解租屋爭議。',
                      style: TextStyle(
                        fontSize: 12.sp,
                        height: 1.45,
                        color: const Color(0xFF2F2A23),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        Text(
                          '往下滑還有更多主題',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF4D5A8A),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 24.sp,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoomSceneBackground extends StatelessWidget {
  const _RoomSceneBackground();

  @override
  Widget build(BuildContext context) {
    // 這裡不是要真的畫出照片，而是用暖色漸層與幾何塊模擬
    // 設計稿裡那種柔和、偏居家室內的主視覺質感。
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF3ECE1),
            Color(0xFFE4CBAE),
            Color(0xFFC8A377),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 18.w,
            top: 16.h,
            width: 120.w,
            height: 152.h,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.38),
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.4),
                ),
              ),
            ),
          ),
          Positioned(
            right: -18.w,
            top: 28.h,
            width: 120.w,
            height: 26.h,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(999.r),
              ),
            ),
          ),
          Positioned(
            right: 22.w,
            top: 48.h,
            width: 52.w,
            height: 10.h,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.42),
                borderRadius: BorderRadius.circular(999.r),
              ),
            ),
          ),
          Positioned(
            right: 24.w,
            bottom: 42.h,
            width: 82.w,
            height: 34.h,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFB98E5C).withValues(alpha: 0.32),
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 122.h,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Color(0x2D000000),
                    Color(0x52000000),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({
    required this.activeIndex,
    required this.count,
  });

  final int activeIndex;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == activeIndex;
        return Container(
          width: isActive ? 10.w : 8.w,
          height: isActive ? 10.w : 8.w,
          margin: EdgeInsets.symmetric(horizontal: 3.w),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFD8C7E8) : const Color(0xFFD8D8D8),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}

class _RecentCaseGrid extends StatelessWidget {
  const _RecentCaseGrid({
    required this.items,
    required this.onTap,
  });

  final List<_RecentCaseItem> items;
  final ValueChanged<_RecentCaseItem> onTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10.h,
        crossAxisSpacing: 10.w,
        childAspectRatio: 2.45,
      ),
      itemBuilder: (context, index) {
        final item = items[index];

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onTap(item),
            borderRadius: BorderRadius.circular(16.r),
            child: Container(
              padding: EdgeInsets.fromLTRB(12.w, 11.h, 12.w, 10.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F1F0),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 1.h,
                    right: 28.w,
                    child: Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        height: 1.25,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    bottom: 1.h,
                    right: 28.w,
                    child: Text(
                      item.lastViewedLabel,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: 20.sp,
                        color: const Color(0xFF4B5563),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CommonTopicGrid extends StatelessWidget {
  const _CommonTopicGrid({
    required this.items,
    required this.onTap,
  });

  final List<_CommonTopicItem> items;
  final ValueChanged<_CommonTopicItem> onTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10.h,
        crossAxisSpacing: 10.w,
        childAspectRatio: 1.18,
      ),
      itemBuilder: (context, index) {
        final item = items[index];

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onTap(item),
            borderRadius: BorderRadius.circular(14.r),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.icon,
                    style: TextStyle(fontSize: 26.sp, height: 1),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 14.sp,
                      height: 1.1,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

enum _TranslatorCardVariant { defaultStyle, compact }

class _StatuteDatabaseEntryCard extends StatelessWidget {
  const _StatuteDatabaseEntryCard({
    required this.onTap,
    required this.onChipTap,
  });

  final VoidCallback onTap;
  final ValueChanged<String> onChipTap;

  static const List<String> _quickQueries = [
    '民法',
    '刑法',
    '勞動基準法',
  ];

  @override
  Widget build(BuildContext context) {
    // 法條資料庫放在學習頁裡，是讓使用者從生活情境往正式條文查證；
    // 入口本身保持輕量，避免把整個資料庫直接塞進首頁造成閱讀負擔。
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: const Color(0xFFEFEFE8),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFE4E0D5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16.r),
              child: Row(
                children: [
                  Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFFDDE7D4),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.gavel_rounded,
                      size: 22.sp,
                      color: const Color(0xFF405238),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      '查民法、刑法、勞基法與常用條文',
                      style: TextStyle(
                        fontSize: 15.sp,
                        height: 1.35,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 22.sp,
                    color: const Color(0xFF4B5563),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 14.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: _quickQueries.map((query) {
              return _StatuteQuickQueryChip(
                label: query == '勞動基準法' ? '勞基法' : query,
                onTap: () => onChipTap(query),
              );
            }).toList(growable: false),
          ),
        ],
      ),
    );
  }
}

class _StatuteQuickQueryChip extends StatelessWidget {
  const _StatuteQuickQueryChip({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 7.h),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFAEC),
            borderRadius: BorderRadius.circular(999.r),
            border: Border.all(color: const Color(0xFFE2D7B8)),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF5C5C45),
            ),
          ),
        ),
      ),
    );
  }
}

class _TranslatorCard extends StatelessWidget {
  const _TranslatorCard({
    required this.article,
    required this.onTap,
    this.variant = _TranslatorCardVariant.defaultStyle,
  });

  final LearningMockArticle article;
  final VoidCallback onTap;
  final _TranslatorCardVariant variant;

  @override
  Widget build(BuildContext context) {
    final isCompact = variant == _TranslatorCardVariant.compact;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          padding: EdgeInsets.all(isCompact ? 14.w : 16.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F1DF),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '法條',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF8C8B59),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 22.w,
                    height: 22.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF3C3B31),
                        width: 1.2.w,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: isCompact ? 8.h : 10.h),
              Text(
                '民法第184條第1項前段：',
                style: TextStyle(
                  fontSize: isCompact ? 13.sp : 14.sp,
                  height: 1.32,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF5D5A38),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                article.summary,
                style: TextStyle(
                  fontSize: isCompact ? 12.sp : 13.sp,
                  height: 1.45,
                  color: const Color(0xFF524E35),
                ),
              ),
              if (!isCompact) ...[
                SizedBox(height: 10.h),
                Text(
                  '因故意或過失，不法侵害他人之權利者，負損害賠償責任。',
                  style: TextStyle(
                    fontSize: 13.sp,
                    height: 1.45,
                    color: const Color(0xFF524E35),
                  ),
                ),
              ],
              SizedBox(height: isCompact ? 10.h : 14.h),
              Align(
                alignment: Alignment.center,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD7D09D),
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Text(
                    '開始翻譯',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF433F24),
                    ),
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

class _QuizEntryCard extends StatelessWidget {
  const _QuizEntryCard({
    required this.entry,
    required this.onTap,
  });

  final LearningQuizEntryData entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Container(
          padding: EdgeInsets.fromLTRB(16.w, 14.h, 14.w, 14.h),
          decoration: BoxDecoration(
            color: const Color(0xFFEFEFE8),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: const Color(0xFFE4E0D5)),
          ),
          child: Row(
            children: [
              Container(
                width: 42.w,
                height: 42.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFD46A),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.quiz_outlined,
                  size: 22.sp,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '快速測驗',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      entry.subtitle,
                      style: TextStyle(
                        fontSize: 11.sp,
                        height: 1.35,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              Icon(
                Icons.arrow_forward_rounded,
                size: 22.sp,
                color: const Color(0xFF4B5563),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FaqFloatingChip extends StatelessWidget {
  const _FaqFloatingChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 46.w,
          height: 46.w,
          decoration: const BoxDecoration(
            color: Color(0xFFF1CB69),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0x19000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'FAQ',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RecentCaseItem {
  const _RecentCaseItem({
    required this.title,
    required this.lastViewedLabel,
    required this.article,
  });

  final String title;
  final String lastViewedLabel;
  final LearningMockArticle article;
}

class _CommonTopicItem {
  const _CommonTopicItem({
    required this.icon,
    required this.label,
    required this.article,
  });

  final String icon;
  final String label;
  final LearningMockArticle article;
}

final List<_RecentCaseItem> _recentCases = [
  _RecentCaseItem(
    title: '道路交通管理條例',
    lastViewedLabel: '最近一次查看：10分鐘前',
    article: learningTopic.heroArticle,
  ),
  _RecentCaseItem(
    title: '證券交易法',
    lastViewedLabel: '最近一次查看：15分鐘前',
    article: learningTopic.relatedTopics[0].article,
  ),
  _RecentCaseItem(
    title: '銀行法',
    lastViewedLabel: '最近一次查看：23分鐘前',
    article: learningTopic.supportItems[1].article,
  ),
  _RecentCaseItem(
    title: '少年事件處理法',
    lastViewedLabel: '最近一次查看：昨天',
    article: learningTopic.supportItems[2].article,
  ),
];

final List<_CommonTopicItem> _commonTopics = [
  _CommonTopicItem(
    icon: '🏠',
    label: '租屋',
    article: learningTopic.heroArticle,
  ),
  _CommonTopicItem(
    icon: '💼',
    label: '勞資',
    article: learningTopic.relatedTopics[0].article,
  ),
  _CommonTopicItem(
    icon: '🚗',
    label: '車禍',
    article: learningTopic.supportItems[2].article,
  ),
  _CommonTopicItem(
    icon: '📱',
    label: '網路',
    article: learningTopic.relatedTopics[1].article,
  ),
  _CommonTopicItem(
    icon: '👪',
    label: '家事',
    article: learningTopic.supportItems.first.article,
  ),
  _CommonTopicItem(
    icon: '⚖️',
    label: '刑事',
    article: learningTopic.supportItems[1].article,
  ),
];
