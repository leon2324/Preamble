part of '../global_search_page.dart';

// 台灣繁體中文教學註解：
// 本檔集中放搜尋詳情頁會共用的輔助展示 UI，例如情境追問、語音朗讀、裁判時間軸與關聯法條。
// 搜尋 state、route 切換與 repository 呼叫仍留在 GlobalSearchPage 或詳情頁本體，避免 UI 拆分改變資料流程。

class _ScenarioFollowUps extends StatelessWidget {
  const _ScenarioFollowUps({required this.title, required this.onAsk});
  final String title;
  final ValueChanged<String> onAsk;

  @override
  Widget build(BuildContext context) {
    final List<String> questions = [];
    if (title.contains('消保') || title.contains('19') || title.contains('鑑賞期')) {
      questions.addAll([
        '個人二手賣家也適用嗎？',
        '如果是客製化商品還能退嗎？',
        '商品拆封後還能主張鑑賞期退貨嗎？',
      ]);
    } else if (title.contains('詐') || title.contains('339')) {
      questions.addAll([
        '遊戲點數詐騙怎麼要回錢？',
        '被騙走的身分證件怎麼預防被盜用？',
        '借錢不還算不算詐欺罪？',
      ]);
    } else if (title.contains('租') ||
        title.contains('房') ||
        title.contains('421')) {
      questions.addAll([
        '退租時房東無理扣押金怎麼辦？',
        '房屋漏水房東不修我可以少繳房租嗎？',
        '租約沒到期提早搬走會扣多少違約金？',
      ]);
    } else {
      questions.addAll([
        '這個條款在訴訟上怎麼舉證？',
        '如果遇到糾紛該去哪裡聲請調解？',
        '有免費的法律諮詢管道嗎？',
      ]);
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? const Color(0xFF33A88D) : _SearchColors.primary;
    final chipBg = isDark ? const Color(0xFF1A3831) : _SearchColors.mint;
    final textColor = isDark ? const Color(0xFF33A88D) : _SearchColors.text;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.assistant_rounded, color: primaryColor, size: 16.sp),
            SizedBox(width: 6.w),
            Text('小法助推薦情境追問', style: _SearchText.captionStrong(context)),
          ],
        ),
        SizedBox(height: 8.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: questions.map((q) {
              return Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: InkWell(
                  onTap: () => onAsk(q),
                  borderRadius: BorderRadius.circular(999.r),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
                    decoration: BoxDecoration(
                      color: chipBg.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(999.r),
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.25),
                        width: 0.6.w,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(q,
                            style: _SearchText.captionStrong(context)
                                .copyWith(color: textColor, fontSize: 10.5.sp)),
                        SizedBox(width: 4.w),
                        Icon(Icons.arrow_forward_rounded,
                            color: primaryColor, size: 10.sp),
                      ],
                    ),
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

class _WaveformPlayer extends StatefulWidget {
  const _WaveformPlayer({required this.isPlaying});
  final bool isPlaying;

  @override
  State<_WaveformPlayer> createState() => _WaveformPlayerState();
}

class _WaveformPlayerState extends State<_WaveformPlayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<double> _baseHeights = [0.2, 0.5, 0.8, 0.4, 0.7, 0.3, 0.6, 0.2];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.isPlaying) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _WaveformPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final barColor = isDark ? const Color(0xFF33A88D) : _SearchColors.primary;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_baseHeights.length, (index) {
            double value = _baseHeights[index];
            if (widget.isPlaying) {
              final phase = (index / _baseHeights.length) * 2 * math.pi;
              value = (value +
                      0.3 *
                          (0.5 +
                              0.5 *
                                  (math.sin(_controller.value * 2 * math.pi +
                                      phase))))
                  .clamp(0.1, 1.0);
            }
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 1.5.w),
              width: 3.w,
              height: (16.h * value).clamp(3.h, 16.h),
              decoration: BoxDecoration(
                color: barColor.withValues(alpha: widget.isPlaying ? 1.0 : 0.4),
                borderRadius: BorderRadius.circular(1.5.r),
              ),
            );
          }),
        );
      },
    );
  }
}

class _VoiceReader extends StatefulWidget {
  const _VoiceReader({required this.text});
  final String text;

  @override
  State<_VoiceReader> createState() => _VoiceReaderState();
}

class _VoiceReaderState extends State<_VoiceReader> {
  bool _isPlaying = false;
  int _secondsElapsed = 0;
  final int _totalSeconds = 25;
  Timer? _timer;

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsElapsed < _totalSeconds) {
          _secondsElapsed++;
        } else {
          _isPlaying = false;
          _secondsElapsed = 0;
          _timer?.cancel();
        }
      });
    });
  }

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _startTimer();
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? const Color(0xFF33A88D) : _SearchColors.primary;

    final String elapsedStr =
        '00:${_secondsElapsed.toString().padLeft(2, '0')}';
    final String totalStr = '00:$_totalSeconds';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141922) : const Color(0xFFFAF7F2),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: isDark
              ? const Color(0xFF2C3545).withValues(alpha: 0.5)
              : _SearchColors.border.withValues(alpha: 0.3),
          width: 0.6.w,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: _togglePlay,
            borderRadius: BorderRadius.circular(999.r),
            child: Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: primaryColor,
                size: 14.sp,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Text('$elapsedStr / $totalStr', style: _SearchText.caption(context)),
          SizedBox(width: 8.w),
          _WaveformPlayer(isPlaying: _isPlaying),
        ],
      ),
    );
  }
}

class _CaseTimelineVisualizer extends StatelessWidget {
  const _CaseTimelineVisualizer({required this.caseId, required this.title});
  final String caseId;
  final String title;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? const Color(0xFF33A88D) : _SearchColors.primary;
    final dotColor = isDark ? const Color(0xFF33A88D) : _SearchColors.primary;
    final lineColor = isDark ? const Color(0xFF2C3545) : _SearchColors.border;

    final List<_TimelineEvent> events = [];
    if (caseId.contains('2') || title.contains('租') || title.contains('押金')) {
      events.addAll([
        _TimelineEvent('2025.03.15', '簽訂契約', '起租並給付押金二個月。'),
        _TimelineEvent('2026.03.14', '約滿點交', '租約到期房屋點交，房東主張自然折舊扣押金。'),
        _TimelineEvent('2026.04.10', '調解不成立', '向公所聲請調解，房東執意扣除清潔與油漆費，協商破局。'),
        _TimelineEvent('2026.06.15', '法院宣判', '小額判決認定自然折舊應由房東負擔，判決房東全額返還押金。'),
      ]);
    } else if (caseId.contains('1') || title.contains('詐')) {
      events.addAll([
        _TimelineEvent('2025.02.10', '三方詐騙成立', '買家匯款至被害賣家，詐騙人拿走商品。'),
        _TimelineEvent('2025.02.12', '警示帳戶凍結', '金流遭警示鎖定，賣家名下所有帳戶無法提款。'),
        _TimelineEvent('2025.08.12', '檢察官不起訴', '查明三方詐騙始末，賣家無詐欺故意，不起訴處分確定。'),
        _TimelineEvent('2026.02.18', '免賠定讞', '民事庭判決賣家無侵權責任，無須賠償被害買家，返還定讞。'),
      ]);
    } else {
      events.addAll([
        _TimelineEvent('2025.10.15', '商品到貨', '網路下單通訊交易收到商品，開箱點收。'),
        _TimelineEvent('2025.10.18', '主張解除契約', '7 日內書面通知退貨，賣家以「已拆封」為由拒退。'),
        _TimelineEvent('2025.11.05', '消保官申訴', '向行政院消保處進行線上申訴，消保官發函要求賣家說明。'),
        _TimelineEvent('2026.01.12', '調解成立', '召開調解會議，賣家同意收回商品並全額退款。'),
      ]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.timeline_rounded, color: primaryColor, size: 16.sp),
            SizedBox(width: 6.w),
            Text('裁判時序時間軸 (Timeline)',
                style: _SearchText.captionStrong(context)),
          ],
        ),
        SizedBox(height: 12.h),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final e = events[index];
            final isLast = index == events.length - 1;
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: BoxDecoration(
                          color: dotColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 1.5.w,
                            color: lineColor,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(e.date,
                                  style: _SearchText.captionStrong(context)
                                      .copyWith(
                                          color: primaryColor,
                                          fontSize: 10.sp)),
                              SizedBox(width: 8.w),
                              Text(e.title,
                                  style: _SearchText.bodyStrong(context)),
                            ],
                          ),
                          SizedBox(height: 3.h),
                          Text(e.desc, style: _SearchText.body(context)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _TimelineEvent {
  const _TimelineEvent(this.date, this.title, this.desc);
  final String date;
  final String title;
  final String desc;
}

class _RelatedStatuteChips extends StatelessWidget {
  const _RelatedStatuteChips(
      {required this.statuteTitle, required this.onNavigate});
  final String statuteTitle;
  final ValueChanged<_SearchResult> onNavigate;

  @override
  Widget build(BuildContext context) {
    final List<_RelatedStatuteInfo> list = [];
    if (statuteTitle.contains('消費者保護法') &&
        statuteTitle.contains('19') &&
        !statuteTitle.contains('19之2')) {
      list.addAll([
        _RelatedStatuteInfo(
            '民法第 259 條', '契約解除時雙方回復原狀義務之細節規範。', 'statute-民法-259'),
        _RelatedStatuteInfo(
            '消保法第 19 條之 2', '通訊交易退款程序與期限之施行細則。', 'statute-消費者保護法-19之2'),
      ]);
    } else if (statuteTitle.contains('19之2')) {
      list.addAll([
        _RelatedStatuteInfo(
            '消保法第 19 條', '通訊交易 7 天無條件解除契約之本權利。', 'statute-消費者保護法-19'),
        _RelatedStatuteInfo(
            '民法第 259 條', '契約解除時雙方回復原狀義務之細節規範。', 'statute-民法-259'),
      ]);
    } else if (statuteTitle.contains('民法') && statuteTitle.contains('259')) {
      list.addAll([
        _RelatedStatuteInfo(
            '消保法第 19 條', '通訊交易 7 天無條件解除契約之本權利。', 'statute-消費者保護法-19'),
        _RelatedStatuteInfo(
            '民法第 260 條', '解除契約妨礙損害賠償請求權之適用界限。', 'statute-民法-260'),
      ]);
    } else if (statuteTitle.contains('刑法') && statuteTitle.contains('339')) {
      list.addAll([
        _RelatedStatuteInfo(
            '民法第 184 條', '因故意或過失不法侵害他人權利之侵權行為損害賠償義務。', 'statute-民法-184'),
        _RelatedStatuteInfo(
            '民法第 179 條', '無法律上原因受有利益致他人受損之不當得利返還義務。', 'statute-民法-179'),
      ]);
    } else if (statuteTitle.contains('民法') && statuteTitle.contains('421')) {
      list.addAll([
        _RelatedStatuteInfo(
            '民法第 440 條', '承租人租金支付遲延時，出租人終止契約之限制。', 'statute-民法-440'),
        _RelatedStatuteInfo(
            '民法第 429 條', '租賃物修繕義務之歸屬與費用負擔之預設規定。', 'statute-民法-429'),
      ]);
    } else {
      list.addAll([
        _RelatedStatuteInfo(
            '民法第 184 條', '一般侵權行為之基本損害賠償請求權依據。', 'statute-民法-184'),
        _RelatedStatuteInfo('民法第 179 條', '一般不當得利之返還請求權依據。', 'statute-民法-179'),
      ]);
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? const Color(0xFF33A88D) : _SearchColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.alt_route_rounded, color: primaryColor, size: 16.sp),
            SizedBox(width: 6.w),
            Text('關聯互補條文推薦 (Links)', style: _SearchText.captionStrong(context)),
          ],
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: list.map((info) {
            return InkWell(
              onTap: () {
                onNavigate(_SearchResult(
                  type: _ResultType.statute,
                  title: info.title,
                  summary: info.summary,
                  source: '法規詳情・施行中',
                  query: info.title.replaceAll(' ', ''),
                  id: info.id,
                ));
              },
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E2430) : Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF2C3545)
                        : _SearchColors.border.withValues(alpha: 0.6),
                    width: 0.6.w,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.link_rounded, color: primaryColor, size: 12.sp),
                    SizedBox(width: 4.w),
                    Text(info.title,
                        style: _SearchText.captionStrong(context)
                            .copyWith(fontSize: 11.sp)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _RelatedStatuteInfo {
  const _RelatedStatuteInfo(this.title, this.summary, this.id);
  final String title;
  final String summary;
  final String id;
}
