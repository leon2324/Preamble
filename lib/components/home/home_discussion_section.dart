import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/components/home/home_content.dart';
import 'package:lawapp/components/home/home_section_title.dart';
import 'package:lawapp/theme/app_colors.dart';

class HomeDiscussionSection extends StatefulWidget {
  const HomeDiscussionSection({
    super.key,
    required this.onMoreTap,
    required this.feed,
  });

  final VoidCallback onMoreTap;
  final HomeDiscussionFeed feed;

  @override
  State<HomeDiscussionSection> createState() => _HomeDiscussionSectionState();
}

class _HomeDiscussionSectionState extends State<HomeDiscussionSection> {
  static const double _itemGap = 18;
  static const double _timelineItemWidth = 176;
  static const double _timelineItemGap = 8;
  int? _expandedIndex;
  int _activeIndex = 0;
  int _activeTimelineIndex = 0;
  bool _isTimelineExpanded = false;
  final Map<int, int> _selectedPollOptionByTopic = <int, int>{};
  final Set<int> _submittedPollTopics = <int>{};
  final ScrollController _timelineScrollController = ScrollController();
  final FocusNode _commentFocusNode = FocusNode();
  final GlobalKey _commentFieldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _commentFocusNode.addListener(_handleCommentFocus);
  }

  @override
  void dispose() {
    _timelineScrollController.dispose();
    _commentFocusNode
      ..removeListener(_handleCommentFocus)
      ..dispose();
    super.dispose();
  }

  void _handleCommentFocus() {
    if (!_commentFocusNode.hasFocus) return;
    _ensureCommentVisible();
  }

  void _ensureCommentVisible() {
    final targetContext = _commentFieldKey.currentContext;
    if (targetContext == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        alignment: 0.25,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final buttonColors = <Color>[
      const Color(0xFFA8B9F2),
      const Color(0xFF9AB6E3),
      const Color(0xFFE8C98F),
    ];

    final topics = widget.feed.topics;
    if (topics.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeSectionTitle(title: '大家都在討論', onTap: widget.onMoreTap),
          SizedBox(height: 15.h),
        ],
      );
    }

    final activeIndex = _activeIndex.clamp(0, topics.length - 1);
    final activeTopic = topics[activeIndex];
    final activePoll = activeTopic.poll;
    final selectedPollOptionIndex = _selectedPollOptionByTopic[activeIndex];
    final hasSubmittedPoll = _submittedPollTopics.contains(activeIndex);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeSectionTitle(title: '大家都在討論', onTap: widget.onMoreTap),
        SizedBox(height: 15.h),
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: AppColors.discussionSurface,
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 6.w),
                child: Column(
                  children: List.generate(topics.length, (index) {
                    final topic = topics[index];
                    final isExpanded = index == _expandedIndex;

                    return Padding(
                      padding: EdgeInsets.only(
                          bottom: index == topics.length - 1 ? 0 : 6.h),
                      child: Column(
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(10.r),
                            onTap: () {
                              setState(() {
                                _activeIndex = index;
                                _activeTimelineIndex = 0;
                                _isTimelineExpanded = false;
                                if (_expandedIndex == index) {
                                  _expandedIndex = null;
                                } else {
                                  _expandedIndex = index;
                                }
                              });
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _scrollTimelineToIndex(0);
                              });
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 4.h, horizontal: 2.w),
                              child: Row(
                                children: [
                                  Text(
                                    '•',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: const Color(0xFF16243D),
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      topic.headline,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF16243D),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 6.w),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 7.w,
                                      vertical: 3.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD2DEEF),
                                      borderRadius:
                                          BorderRadius.circular(999.r),
                                    ),
                                    child: Text(
                                      '#${topic.rank} / ${topic.heatScore}分',
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        color: const Color(0xFF31486F),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  Icon(
                                    topic.dayChangePercent >= 0
                                        ? Icons.arrow_drop_up_rounded
                                        : Icons.arrow_drop_down_rounded,
                                    size: 18.sp,
                                    color: topic.dayChangePercent >= 0
                                        ? const Color(0xFFB45309)
                                        : const Color(0xFF9F1239),
                                  ),
                                  SizedBox(width: 2.w),
                                  Icon(
                                    isExpanded
                                        ? Icons.keyboard_arrow_up_rounded
                                        : Icons.keyboard_arrow_down_rounded,
                                    size: 18.sp,
                                    color: const Color(0xFF16243D),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          AnimatedCrossFade(
                            duration: const Duration(milliseconds: 160),
                            crossFadeState: isExpanded
                                ? CrossFadeState.showFirst
                                : CrossFadeState.showSecond,
                            firstChild: Padding(
                              padding: EdgeInsets.only(
                                  left: 20.w, right: 6.w, top: 4.h),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD2DEEF),
                                    borderRadius: BorderRadius.circular(999.r),
                                  ),
                                  child: Text(
                                    '${topic.heatScore}分｜24h ${_signedPercent(topic.dayChangePercent)}｜${_weekRankText(topic.weekRankDelta)}',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: const Color(0xFF31486F),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            secondChild: const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              if (_expandedIndex != null) ...[
                SizedBox(height: _itemGap.h),
                Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.28),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.45),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              activeTopic.title,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF16243D),
                              ),
                            ),
                          ),
                          Icon(
                            Icons.trending_up_rounded,
                            color: AppColors.info,
                            size: 24.sp,
                          ),
                        ],
                      ),
                      SizedBox(height: _itemGap.h),
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(18.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activeTopic.heatLabel,
                              softWrap: true,
                              overflow: TextOverflow.visible,
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF7E8BA3),
                              ),
                            ),
                            SizedBox(height: 10.h),
                            SizedBox(
                              height: 178.h,
                              width: double.infinity,
                              child: _DiscussionLineChart(
                                points: activeTopic.trendPoints,
                                selectedIndex: _isTimelineExpanded
                                    ? _selectedTrendPointIndex(
                                        activeTopic.timelineEvents,
                                        activeTopic.trendPoints.length,
                                      )
                                    : null,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(999.r),
                                onTap: () {
                                  setState(() {
                                    _isTimelineExpanded = !_isTimelineExpanded;
                                  });
                                  if (_isTimelineExpanded) {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      _scrollTimelineToIndex(
                                          _activeTimelineIndex);
                                    });
                                  }
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  curve: Curves.easeOutCubic,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                    vertical: 6.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _isTimelineExpanded
                                        ? const Color(0xFFE0ECFF)
                                        : const Color(0xFFEAF0FA),
                                    borderRadius: BorderRadius.circular(999.r),
                                    border: Border.all(
                                      color: _isTimelineExpanded
                                          ? const Color(0xFF9BB8E8)
                                          : const Color(0xFFD3DEEE),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.timeline_rounded,
                                        size: 15.sp,
                                        color: const Color(0xFF355486),
                                      ),
                                      SizedBox(width: 6.w),
                                      Text(
                                        '時間脈絡',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF355486),
                                        ),
                                      ),
                                      SizedBox(width: 4.w),
                                      Icon(
                                        _isTimelineExpanded
                                            ? Icons.remove_rounded
                                            : Icons.add_rounded,
                                        size: 16.sp,
                                        color: const Color(0xFF355486),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            AnimatedCrossFade(
                              duration: const Duration(milliseconds: 180),
                              crossFadeState: _isTimelineExpanded
                                  ? CrossFadeState.showFirst
                                  : CrossFadeState.showSecond,
                              firstChild: Padding(
                                padding: EdgeInsets.only(top: 8.h),
                                child: SizedBox(
                                  height: 86.h,
                                  child: NotificationListener<
                                      ScrollUpdateNotification>(
                                    onNotification: (notification) {
                                      final itemExtent = _timelineItemWidth.w +
                                          _timelineItemGap.w;
                                      final nextIndex = (notification
                                                  .metrics.pixels /
                                              itemExtent)
                                          .round()
                                          .clamp(
                                            0,
                                            activeTopic.timelineEvents.length -
                                                1,
                                          );
                                      if (nextIndex != _activeTimelineIndex) {
                                        setState(() {
                                          _activeTimelineIndex = nextIndex;
                                        });
                                      }
                                      return false;
                                    },
                                    child: ListView.separated(
                                      controller: _timelineScrollController,
                                      scrollDirection: Axis.horizontal,
                                      itemCount:
                                          activeTopic.timelineEvents.length,
                                      separatorBuilder: (_, __) =>
                                          SizedBox(width: _timelineItemGap.w),
                                      itemBuilder: (context, index) {
                                        final event =
                                            activeTopic.timelineEvents[index];
                                        final isActive =
                                            index == _activeTimelineIndex;
                                        return InkWell(
                                          onTap: () {
                                            setState(() {
                                              _activeTimelineIndex = index;
                                            });
                                            _scrollTimelineToIndex(index);
                                          },
                                          borderRadius:
                                              BorderRadius.circular(12.r),
                                          child: Container(
                                            width: _timelineItemWidth.w,
                                            padding: EdgeInsets.all(10.w),
                                            decoration: BoxDecoration(
                                              color: isActive
                                                  ? const Color(0xFFEFF6FF)
                                                  : const Color(0xFFF8FAFC),
                                              borderRadius:
                                                  BorderRadius.circular(12.r),
                                              border: Border.all(
                                                color: isActive
                                                    ? const Color(0xFF93C5FD)
                                                    : const Color(0xFFE2E8F0),
                                              ),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        event.timeLabel,
                                                        style: TextStyle(
                                                          fontSize: 10.sp,
                                                          color: const Color(
                                                              0xFF64748B),
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      event.impactLabel,
                                                      style: TextStyle(
                                                        fontSize: 10.sp,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: const Color(
                                                            0xFFB45309),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 6.h),
                                                Text(
                                                  event.description,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 11.sp,
                                                    height: 1.35,
                                                    color:
                                                        const Color(0xFF334155),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              secondChild: const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: _itemGap.h),
                      Text(
                        activeTopic.overview,
                        style: TextStyle(
                          fontSize: 13.sp,
                          height: 1.55,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF23314D),
                        ),
                      ),
                      if (activePoll != null) ...[
                        SizedBox(height: _itemGap.h),
                        _DiscussionPollCard(
                          poll: activePoll,
                          selectedOptionIndex: selectedPollOptionIndex,
                          isSubmitted: hasSubmittedPoll,
                          onSelectOption: (index) {
                            if (hasSubmittedPoll) return;
                            setState(() {
                              _selectedPollOptionByTopic[activeIndex] = index;
                            });
                          },
                          onSubmit: selectedPollOptionIndex == null ||
                                  hasSubmittedPoll
                              ? null
                              : () {
                                  setState(() {
                                    _submittedPollTopics.add(activeIndex);
                                  });
                                },
                        ),
                      ],
                      SizedBox(height: _itemGap.h),
                      Text(
                        '最新留言：',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: const Color(0xFF16243D),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 16.w),
                            child: Text(
                              activeTopic.latestComment.content,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: const Color(0xFF1D2C45),
                              ),
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Row(
                            children: [
                              const Spacer(),
                              Text(
                                '${activeTopic.latestComment.submittedAt} 由 ${activeTopic.latestComment.userHandle} 提出',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: const Color(0xFF7D879A),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        key: _commentFieldKey,
                        children: [
                          Container(
                            width: 28.w,
                            height: 28.w,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD5D9E3),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF1E1E1E),
                                width: 1,
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: const Color(0xFF2B2B2B)
                                        .withValues(alpha: 0.55),
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: TextField(
                                focusNode: _commentFocusNode,
                                onTap: _ensureCommentVisible,
                                decoration: InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                  hintText: '請保持理性思考，若衝動發言可能會被系統強制刪除留言',
                                  hintStyle: TextStyle(
                                    fontSize: 10.sp,
                                    color: const Color(0xFF7A8192),
                                  ),
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 8.h),
                                ),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: const Color(0xFF1D2C45),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Icon(
                            Icons.send,
                            size: 18.sp,
                            color: const Color(0xFF1E3A8A),
                          ),
                        ],
                      ),
                      SizedBox(height: _itemGap.h),
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: activeTopic.tags
                            .map(
                              (tag) => Text(
                                tag,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: const Color(0xFF2D5A35),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      SizedBox(height: _itemGap.h),
                      Row(
                        children: List.generate(
                          widget.feed.actionLabels.length,
                          (index) {
                            final label = widget.feed.actionLabels[index];
                            final color =
                                buttonColors[index % buttonColors.length];
                            final icon = _actionIconForLabel(label);
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right: index ==
                                          widget.feed.actionLabels.length - 1
                                      ? 0
                                      : 8.w,
                                ),
                                child: _DiscussionButton(
                                  icon: icon,
                                  semanticsLabel: label,
                                  backgroundColor: color,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _signedPercent(int value) {
    final sign = value >= 0 ? '+' : '';
    return '$sign$value%';
  }

  String _weekRankText(int delta) {
    if (delta > 0) return '7日上升$delta名';
    if (delta < 0) return '7日下降${delta.abs()}名';
    return '7日排名持平';
  }

  IconData _actionIconForLabel(String label) {
    if (label.contains('留言')) return Icons.chat_bubble_outline_rounded;
    if (label.contains('追蹤')) return Icons.bookmark_border_rounded;
    return Icons.arrow_forward_rounded;
  }

  int? _selectedTrendPointIndex(
    List<HomeDiscussionTimelineEvent> events,
    int trendPointCount,
  ) {
    if (events.isEmpty || trendPointCount <= 0) return null;
    final safeTimelineIndex = _activeTimelineIndex.clamp(0, events.length - 1);
    final pointIndex = events[safeTimelineIndex].pointIndex;
    if (pointIndex < 0 || pointIndex >= trendPointCount) return null;
    return pointIndex;
  }

  void _scrollTimelineToIndex(int index) {
    if (!_timelineScrollController.hasClients) return;
    final targetOffset =
        (index * (_timelineItemWidth.w + _timelineItemGap.w)).clamp(
      0.0,
      _timelineScrollController.position.maxScrollExtent,
    );
    _timelineScrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
  }
}

class _DiscussionLineChart extends StatelessWidget {
  const _DiscussionLineChart({
    required this.points,
    required this.selectedIndex,
  });

  final List<HomeDiscussionTrendPoint> points;
  final int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DiscussionLineChartPainter(
        points: points,
        selectedIndex: selectedIndex,
      ),
    );
  }
}

class _DiscussionLineChartPainter extends CustomPainter {
  _DiscussionLineChartPainter({
    required this.points,
    required this.selectedIndex,
  });

  final List<HomeDiscussionTrendPoint> points;
  final int? selectedIndex;
  static const _yAxisTicks = [800, 500, 200, 50, 10];
  static const _plotWidthFactor = 0.82;
  static const _yAxisTightness = 0.86;
  static const leftPadding = 40.0;
  static const rightPadding = 4.0;
  static const topPadding = 10.0;
  static const bottomPadding = 18.0;

  @override
  void paint(Canvas canvas, Size size) {
    final chartWidth = size.width - leftPadding - rightPadding;
    final plotWidth = chartWidth * _plotWidthFactor;
    final plotLeft = leftPadding + ((chartWidth - plotWidth) / 2);
    final plotRight = plotLeft + plotWidth;
    final chartHeight = size.height - topPadding - bottomPadding;
    final baselineY = topPadding + chartHeight;

    for (final tick in _yAxisTicks) {
      final y = _tickY(
        tick: tick.toDouble(),
        topPadding: topPadding,
        chartHeight: chartHeight,
      );
      final tickPainter = TextPainter(
        text: TextSpan(
          text: '$tick次',
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF111111),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tickPainter.paint(canvas, Offset(0, y - (tickPainter.height / 2)));
    }

    if (points.isEmpty) return;
    final graphPoints = calculateGraphPoints(size, points);
    if (graphPoints.isEmpty) return;

    final linePath = Path()..moveTo(graphPoints.first.dx, graphPoints.first.dy);
    for (var i = 1; i < graphPoints.length; i++) {
      linePath.lineTo(graphPoints[i].dx, graphPoints[i].dy);
    }

    final linePaint = Paint()
      ..color = const Color(0xFFE37B7B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(linePath, linePaint);

    final pointPaint = Paint()
      ..color = const Color(0xFFE37B7B)
      ..style = PaintingStyle.fill;
    final selectedRingPaint = Paint()
      ..color = const Color(0xFFB94A4A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    for (var i = 0; i < graphPoints.length; i++) {
      final point = graphPoints[i];
      final isSelected = i == selectedIndex;
      canvas.drawCircle(point, isSelected ? 3.9 : 3.2, pointPaint);
      if (isSelected) {
        canvas.drawCircle(point, 6.2, selectedRingPaint);
      }

      final dateTextPainter = TextPainter(
        text: TextSpan(
          text: points[i].dateLabel,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF111111),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      dateTextPainter.paint(
        canvas,
        Offset(
          point.dx - (dateTextPainter.width / 2),
          size.height - dateTextPainter.height,
        ),
      );
    }

    if (selectedIndex == null ||
        selectedIndex! < 0 ||
        selectedIndex! >= graphPoints.length) {
      return;
    }

    final annotation = points[selectedIndex!].annotation;
    if (annotation == null || annotation.isEmpty) return;

    final labelPainter = TextPainter(
      text: TextSpan(
        text: annotation,
        style: const TextStyle(
          fontSize: 9.2,
          color: Color(0xFF4B5563),
        ),
      ),
      maxLines: 2,
      ellipsis: '…',
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 120);

    const bubbleHPadding = 7.0;
    const bubbleVPadding = 5.0;
    final bubbleWidth = labelPainter.width + (bubbleHPadding * 2);
    final bubbleHeight = labelPainter.height + (bubbleVPadding * 2);

    final selectedPoint = graphPoints[selectedIndex!];
    var bubbleLeft = selectedPoint.dx - (bubbleWidth / 2);
    var bubbleTop = selectedPoint.dy - bubbleHeight - 14;

    final minLeft = plotLeft;
    final maxLeft = plotRight - bubbleWidth;
    bubbleLeft = bubbleLeft.clamp(minLeft, maxLeft);
    if (bubbleTop < topPadding) {
      bubbleTop = (selectedPoint.dy + 10)
          .clamp(topPadding, baselineY - bubbleHeight - 4);
    }

    final bubbleRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(bubbleLeft, bubbleTop, bubbleWidth, bubbleHeight),
      const Radius.circular(8),
    );
    final bubbleFill = Paint()
      ..color = const Color(0xFFF8FAFC).withValues(alpha: 0.95);
    final bubbleBorder = Paint()
      ..color = const Color(0xFFD5DEE9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(bubbleRect, bubbleFill);
    canvas.drawRRect(bubbleRect, bubbleBorder);

    labelPainter.paint(
      canvas,
      Offset(bubbleLeft + bubbleHPadding, bubbleTop + bubbleVPadding),
    );
  }

  @override
  bool shouldRepaint(covariant _DiscussionLineChartPainter oldDelegate) {
    if (oldDelegate.selectedIndex != selectedIndex) return true;
    if (oldDelegate.points.length != points.length) return true;
    for (var i = 0; i < points.length; i++) {
      final oldPoint = oldDelegate.points[i];
      final newPoint = points[i];
      if (oldPoint.dateLabel != newPoint.dateLabel ||
          oldPoint.volumeLabel != newPoint.volumeLabel ||
          oldPoint.annotation != newPoint.annotation) {
        return true;
      }
    }
    return false;
  }

  static List<Offset> calculateGraphPoints(
    Size size,
    List<HomeDiscussionTrendPoint> points,
  ) {
    if (points.isEmpty || size.width <= 0 || size.height <= 0) return const [];
    final chartWidth = size.width - leftPadding - rightPadding;
    final plotWidth = chartWidth * _plotWidthFactor;
    final plotLeft = leftPadding + ((chartWidth - plotWidth) / 2);
    final chartHeight = size.height - topPadding - bottomPadding;
    final stepX = points.length == 1 ? 0.0 : plotWidth / (points.length - 1);

    final values = points
        .map((point) =>
            int.tryParse(point.volumeLabel.replaceAll(RegExp(r'[^0-9]'), '')) ??
            0)
        .toList(growable: false);

    final graphPoints = <Offset>[];
    for (var i = 0; i < points.length; i++) {
      final x = plotLeft + (stepX * i);
      final y = _tickY(
        tick: values[i].toDouble(),
        topPadding: topPadding,
        chartHeight: chartHeight,
      );
      graphPoints.add(Offset(x, y));
    }
    return graphPoints;
  }

  static double _tickY({
    required double tick,
    required double topPadding,
    required double chartHeight,
  }) {
    final effectiveHeight = chartHeight * _yAxisTightness;
    final effectiveTop = topPadding + ((chartHeight - effectiveHeight) / 2);
    final baselineY = effectiveTop + effectiveHeight;
    final segments = _yAxisTicks.length - 1;
    if (segments <= 0) return baselineY;
    final segmentHeight = effectiveHeight / segments;

    final maxTick = _yAxisTicks.first.toDouble();
    final minTick = _yAxisTicks.last.toDouble();
    final clamped = tick.clamp(minTick, maxTick);

    for (var i = 0; i < segments; i++) {
      final upper = _yAxisTicks[i].toDouble();
      final lower = _yAxisTicks[i + 1].toDouble();
      if (clamped <= upper && clamped >= lower) {
        final ratio = ((upper - clamped) / (upper - lower)).clamp(0.0, 1.0);
        return effectiveTop + (i * segmentHeight) + (ratio * segmentHeight);
      }
    }
    return baselineY;
  }
}

class _DiscussionPollCard extends StatelessWidget {
  const _DiscussionPollCard({
    required this.poll,
    required this.selectedOptionIndex,
    required this.isSubmitted,
    required this.onSelectOption,
    required this.onSubmit,
  });

  final HomeDiscussionPoll poll;
  final int? selectedOptionIndex;
  final bool isSubmitted;
  final ValueChanged<int> onSelectOption;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    final totalVotes = poll.options.fold<int>(
      0,
      (sum, option) => sum + option.votes,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '我要表態',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F3352),
          ),
        ),
        SizedBox(height: 10.h),
        ...List.generate(
          poll.options.length,
          (index) {
            final option = poll.options[index];
            final isSelected = selectedOptionIndex == index;
            final ratio = totalVotes == 0 ? 0.0 : option.votes / totalVotes;
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == poll.options.length - 1 ? 0 : 8.h,
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(10.r),
                onTap: () => onSelectOption(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 9.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFE8F1FF)
                        : const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF7CA5E8)
                          : const Color(0xFFD7E0EE),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              option.label,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: const Color(0xFF1A2F4A),
                              ),
                            ),
                          ),
                          if (isSelected && !isSubmitted)
                            Icon(
                              Icons.check_circle_rounded,
                              size: 16.sp,
                              color: const Color(0xFF3E77CF),
                            ),
                          if (isSubmitted) ...[
                            SizedBox(width: 8.w),
                            Text(
                              '${(ratio * 100).toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1F3B67),
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              _formatPollVotes(option.votes),
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: const Color(0xFF5B6D86),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (isSubmitted) ...[
                        SizedBox(height: 7.h),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999.r),
                          child: LinearProgressIndicator(
                            value: ratio,
                            minHeight: 6.h,
                            backgroundColor: const Color(0xFFE3EAF5),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isSelected
                                  ? const Color(0xFF5B8DDB)
                                  : const Color(0xFF9DB6DD),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        SizedBox(height: 10.h),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onSubmit,
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: onSubmit == null
                  ? const Color(0xFFCFD8E6)
                  : const Color(0xFF4D7FD3),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 10.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: Text(
              isSubmitted ? '已送出投票' : '送出投票',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatPollVotes(int votes) {
    if (votes >= 1000) {
      final compact = (votes / 1000).toStringAsFixed(1).replaceAll('.0', '');
      return '${compact}k票';
    }
    return '$votes票';
  }
}

class _DiscussionButton extends StatelessWidget {
  const _DiscussionButton({
    required this.icon,
    required this.semanticsLabel,
    required this.backgroundColor,
  });

  final IconData icon;
  final String semanticsLabel;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38.h,
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      alignment: Alignment.center,
      child: Semantics(
        label: semanticsLabel,
        child: Icon(
          icon,
          size: 18.sp,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
