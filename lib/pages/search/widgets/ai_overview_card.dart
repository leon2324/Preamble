part of '../global_search_page.dart';

// AI 摘要卡只負責呈現已生成的摘要、引用來源與風格切換按鈕；
// 真正的 AI 生成與狀態更新仍留在 GlobalSearchPage，避免 UI 拆分改到搜尋流程。

class _AssistantThinkingIndicator extends StatefulWidget {
  const _AssistantThinkingIndicator();

  @override
  State<_AssistantThinkingIndicator> createState() =>
      _AssistantThinkingIndicatorState();
}

class _AssistantThinkingIndicatorState
    extends State<_AssistantThinkingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final delay = index * 0.2;
            final val = (_controller.value + delay) % 1.0;
            final scale = 0.6 + 0.4 * (0.5 - (0.5 - val).abs());
            return Transform.scale(
              scale: scale,
              child: Container(
                width: 9.w,
                height: 9.w,
                margin: EdgeInsets.symmetric(horizontal: 3.w),
                decoration: const BoxDecoration(
                  color: _SearchColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class TypewriterText extends StatefulWidget {
  const TypewriterText({
    super.key,
    required this.text,
    this.speed = const Duration(milliseconds: 15),
  });

  final String text;
  final Duration speed;

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  String _displayedText = '';
  int _currentIndex = 0;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  @override
  void didUpdateWidget(TypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _startTyping();
    }
  }

  void _startTyping() {
    setState(() {
      _displayedText = '';
      _currentIndex = 0;
      _isTyping = true;
    });
    _type();
  }

  void _type() {
    if (!mounted || !_isTyping) return;
    if (_currentIndex < widget.text.length) {
      setState(() {
        _currentIndex++;
        _displayedText = widget.text.substring(0, _currentIndex);
      });
      Future.delayed(widget.speed, _type);
    } else {
      setState(() {
        _isTyping = false;
      });
    }
  }

  @override
  void dispose() {
    _isTyping = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayedText,
      style: _SearchText.bodyStrong().copyWith(
        height: 1.6,
        color: _SearchColors.text,
      ),
    );
  }
}

class _DottedLine extends StatelessWidget {
  const _DottedLine({
    this.height = 1,
    this.color = Colors.black,
    this.dashWidth = 3,
    this.dashSpace = 4,
  });

  final double height;
  final Color color;
  final double dashWidth;
  final double dashSpace;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: height,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
        );
      },
    );
  }
}

class _BreathingMascot extends StatefulWidget {
  const _BreathingMascot({
    required this.imagePath,
    required this.width,
    required this.height,
  });

  final String imagePath;
  final double width;
  final double height;

  @override
  State<_BreathingMascot> createState() => _BreathingMascotState();
}

class _BreathingMascotState extends State<_BreathingMascot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
              color: _SearchColors.primary.withValues(alpha: 0.15),
              width: 1.5.w),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.asset(
            widget.imagePath,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class _AssistantReportHeader extends StatelessWidget {
  const _AssistantReportHeader({
    required this.docId,
    required this.isThinking,
  });

  final String docId;
  final bool isThinking;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              docId,
              style: _SearchText.caption().copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
                color: _SearchColors.mutedText.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: const BoxDecoration(
                color: _SearchColors.primary,
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                'assets/images/search/search_clipboard.svg',
                colorFilter:
                    const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                width: 13.w,
                height: 13.w,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              '小法助法律研析報告',
              style: _SearchText.section().copyWith(
                color: _SearchColors.primary,
                fontSize: 14.5.sp,
                letterSpacing: 0.5,
              ),
            ),
            const Spacer(),
            if (isThinking)
              const _AssistantThinkingIndicator()
            else
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: _SearchColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  '已完成',
                  style: _SearchText.caption().copyWith(
                    color: _SearchColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _AssistantOverviewCard extends StatelessWidget {
  const _AssistantOverviewCard({
    required this.query,
    required this.summary,
    required this.isThinking,
    required this.tone,
    required this.length,
    required this.onToneChanged,
    required this.onLengthChanged,
    required this.onNotebookSave,
    required this.onContinueChat,
  });

  final String query;
  final String summary;
  final bool isThinking;
  final String tone;
  final String length;
  final ValueChanged<String> onToneChanged;
  final ValueChanged<String> onLengthChanged;
  final VoidCallback onNotebookSave;
  final VoidCallback onContinueChat;

  @override
  Widget build(BuildContext context) {
    final docId = 'DOC-2026-${(query.hashCode % 9000 + 1000).abs()}';

    return _ProtoCard(
      background: _SearchColors.softMint,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AssistantReportHeader(docId: docId, isThinking: isThinking),
          SizedBox(height: 12.h),
          _DottedLine(
            height: 1.5.h,
            color: _SearchColors.border.withValues(alpha: 0.7),
            dashWidth: 3.w,
            dashSpace: 3.w,
          ),
          SizedBox(height: 14.h),
          if (isThinking)
            Container(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _BreathingMascot(
                    imagePath:
                        'assets/images/assistant/law_assistant_empty.png',
                    width: 70.w,
                    height: 75.h,
                  ),
                  SizedBox(height: 12.h),
                  const _AssistantThinkingIndicator(),
                  SizedBox(height: 8.h),
                  Text(
                    '正在彙整法律重點與實務裁判...',
                    style: _SearchText.caption().copyWith(
                      color: _SearchColors.mutedText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _MascotFloatingWrapper(
                  child: Container(
                    width: 50.w,
                    height: 50.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: _SearchColors.primary.withValues(alpha: 0.15),
                          width: 1.5.w),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 6,
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
                ),
                SizedBox(width: 8.w),
                const Expanded(
                  child: _AssistantSpeechBubble(
                    text: '研析報告已產生！以下為您摘要相關要點：',
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            TypewriterText(text: summary),
            SizedBox(height: 14.h),
            _AssistantCitationsRow(query: query),
            SizedBox(height: 16.h),
            Wrap(
              spacing: 6.w,
              runSpacing: 8.h,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('回答風格：',
                    style: _SearchText.caption()
                        .copyWith(fontWeight: FontWeight.bold)),
                _StyleChip(
                  label: '白話',
                  selected: tone == '白話',
                  onTap: () => onToneChanged('白話'),
                ),
                _StyleChip(
                  label: '專業',
                  selected: tone == '專業',
                  onTap: () => onToneChanged('專業'),
                ),
                SizedBox(width: 6.w),
                Text('大綱長度：',
                    style: _SearchText.caption()
                        .copyWith(fontWeight: FontWeight.bold)),
                _StyleChip(
                  label: '精簡',
                  selected: length == '精簡',
                  onTap: () => onLengthChanged('精簡'),
                ),
                _StyleChip(
                  label: '詳細',
                  selected: length == '詳細',
                  onTap: () => onLengthChanged('詳細'),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _SearchColors.primary,
                      side: const BorderSide(color: _SearchColors.border),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r)),
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                    ),
                    icon: SvgPicture.asset(
                      'assets/images/journal/book_icon.svg',
                      colorFilter: const ColorFilter.mode(
                          _SearchColors.primary, BlendMode.srcIn),
                      width: 14.w,
                      height: 14.w,
                    ),
                    label: Text('📌 摘錄筆記', style: _SearchText.captionStrong()),
                    onPressed: onNotebookSave,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: _SearchColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r)),
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                    ),
                    icon: SvgPicture.asset(
                      'assets/images/journal/scale_icon.svg',
                      colorFilter:
                          const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      width: 14.w,
                      height: 14.w,
                    ),
                    label: Text('💬 繼續聊聊',
                        style: _SearchText.captionStrong()
                            .copyWith(color: Colors.white)),
                    onPressed: onContinueChat,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _AssistantCitationsRow extends StatelessWidget {
  const _AssistantCitationsRow({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    // 依據搜尋詞動態決定引用來源
    final List<Map<String, String>> citations = [];
    if (query.contains('詐欺')) {
      citations.addAll([
        {'id': '[1]', 'title': '刑法第 339 條 (普通詐欺罪)', 'tag': '法規'},
        {'id': '[2]', 'title': '最高法院 109 年台上字第 123 號判決', 'tag': '判例'},
        {'id': '[3]', 'title': '警政署 165 全民防騙網', 'tag': '官方'},
      ]);
    } else if (query.contains('瑕疵') ||
        query.contains('退貨') ||
        query.contains('消費') ||
        query.contains('鑑賞期') ||
        query.contains('7天')) {
      citations.addAll([
        {'id': '[1]', 'title': '消保法第 19 條 (鑑賞期退貨)', 'tag': '法規'},
        {'id': '[2]', 'title': '民法第 354 條 (物之瑕疵擔保)', 'tag': '法規'},
        {'id': '[3]', 'title': '行政院消保處 消費申訴指南', 'tag': '官方'},
      ]);
    } else {
      citations.addAll([
        {'id': '[1]', 'title': '民法第 184 條 (獨立侵權責任)', 'tag': '法規'},
        {'id': '[2]', 'title': '司法院法規檢索系統', 'tag': '官方'},
      ]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset(
              'assets/images/journal/book_icon.svg',
              colorFilter: const ColorFilter.mode(
                  _SearchColors.primary, BlendMode.srcIn),
              width: 12.w,
              height: 12.w,
            ),
            SizedBox(width: 4.w),
            Text(
              '參考資料引用來源',
              style: _SearchText.captionStrong().copyWith(
                color: _SearchColors.primary,
                fontSize: 10.sp,
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: citations.map((citation) {
              return Container(
                margin: EdgeInsets.only(right: 8.w),
                child: ActionChip(
                  avatar: Text(
                    citation['id']!,
                    style: TextStyle(
                      color: _SearchColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 9.sp,
                    ),
                  ),
                  label: Text(citation['title']!),
                  onPressed: () {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          behavior: SnackBarBehavior.floating,
                          content: Text(
                              '已為您定位引用來源：${citation['title']} (${citation['tag']})'),
                        ),
                      );
                  },
                  backgroundColor: Colors.white.withValues(alpha: 0.6),
                  side: const BorderSide(color: _SearchColors.border),
                  visualDensity:
                      const VisualDensity(horizontal: -4, vertical: -4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r)),
                  labelStyle: _SearchText.caption().copyWith(
                    color: _SearchColors.text,
                    fontSize: 9.5.sp,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _StyleChip extends StatelessWidget {
  const _StyleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: selected ? _SearchColors.primary : Colors.white,
          border: Border.all(
              color: selected ? _SearchColors.primary : _SearchColors.border),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          label,
          style: _SearchText.caption().copyWith(
            color: selected ? Colors.white : _SearchColors.text,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
