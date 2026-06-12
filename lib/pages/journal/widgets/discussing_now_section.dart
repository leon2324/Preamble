import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/components/home/home_content.dart';
import 'package:lawapp/data/mock_data/home/home_mock_data.dart';
import 'package:lawapp/features/case_time_machine/pages/case_time_machine_entry_page.dart';
import 'package:lawapp/features/case_time_machine/theme/case_time_machine_theme.dart';
import 'package:lawapp/pages/journal/data/journal_page_items.dart';
import 'package:lawapp/pages/journal/widgets/journal_palette.dart';
import 'package:lawapp/pages/journal/widgets/journal_section_header.dart';

class DiscussingNowSection extends StatelessWidget {
  const DiscussingNowSection({super.key, required this.palette});

  final JournalPalette palette;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        JournalSectionHeader(
          title: '大家都在討論',
          subtitle: '先看排行榜，再從底部展開單一議題的熱度摘要。',
          palette: palette,
          actionLabel: '查看全部',
        ),
        SizedBox(height: 10.h),
        ...discussionTrendItems.map(
          (item) => Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: _DiscussionTrendCard(
              item: item,
              palette: palette,
              isPrimary: item.rank == 1,
            ),
          ),
        ),
      ],
    );
  }
}

class _DiscussionTrendCard extends StatelessWidget {
  const _DiscussionTrendCard({
    required this.item,
    required this.palette,
    required this.isPrimary,
  });

  final DiscussionTrendItem item;
  final JournalPalette palette;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final baseHeight = 50.h < 50 ? 50.0 : 50.h;
    final adaptiveHeight = MediaQuery.textScalerOf(context).scale(baseHeight);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: () => _openPreviewSheet(context),
        child: Ink(
          height: adaptiveHeight,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: isPrimary ? const Color(0xFFEAF7F2) : palette.surface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isPrimary
                  ? const Color(0xFFAACFC3)
                  : palette.border.withValues(alpha: 0.75),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isPrimary ? 0.05 : 0.028),
                blurRadius: isPrimary ? 14 : 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              _CompactRankBadge(rank: item.rank, tint: item.tint),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.8.sp,
                    fontWeight: FontWeight.w900,
                    color: palette.primaryText,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              ConstrainedBox(
                constraints: BoxConstraints(minWidth: 84.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      item.score.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 15.sp,
                        height: 1,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFFF7A1A),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      item.delta,
                      style: TextStyle(
                        fontSize: 9.8.sp,
                        height: 1,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF146B50),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 6.w),
              Icon(
                CupertinoIcons.chevron_right,
                size: 15.sp,
                color: palette.primaryText.withValues(alpha: 0.62),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openPreviewSheet(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.18),
      builder: (sheetContext) {
        return _DiscussionPreviewSheet(
          item: item,
          onShowFullDiscussion: () {
            Navigator.of(sheetContext).pop();
            Future<void>.delayed(const Duration(milliseconds: 180), () {
              if (!context.mounted) return;
              _openFullDiscussionSheet(context, item.fullTopicIndex);
            });
          },
        );
      },
    );
  }

  void _openFullDiscussionSheet(BuildContext context, int topicIndex) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final topic = homeDiscussionFeed.topics[topicIndex];
        return _DiscussionDetailSheet(
          topic: topic,
          palette: palette,
        );
      },
    );
  }
}

class _CompactRankBadge extends StatelessWidget {
  const _CompactRankBadge({
    required this.rank,
    required this.tint,
  });

  final int rank;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final isTopRank = rank == 1;
    return Container(
      width: 28.w,
      height: 28.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color:
            isTopRank ? const Color(0xFFF3E0AD) : tint.withValues(alpha: 0.12),
        border: Border.all(
          color: isTopRank
              ? const Color(0xFFD6A85F).withValues(alpha: 0.62)
              : tint.withValues(alpha: 0.24),
        ),
      ),
      child: Text(
        '$rank',
        style: TextStyle(
          fontSize: 12.5.sp,
          fontWeight: FontWeight.w900,
          color: isTopRank ? const Color(0xFF93611F) : tint,
        ),
      ),
    );
  }
}

class _DiscussionPreviewSheet extends StatelessWidget {
  const _DiscussionPreviewSheet({
    required this.item,
    required this.onShowFullDiscussion,
  });

  final DiscussionTrendItem item;
  final VoidCallback onShowFullDiscussion;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.fromLTRB(10.w, 0, 10.w, 8.h),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28.r),
            clipBehavior: Clip.antiAlias,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 0.72.sh),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 42.w,
                        height: 5.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD5DCD8),
                          borderRadius: BorderRadius.circular(999.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 14.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 20.sp,
                              height: 1.18,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF173C37),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: item.tint.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          child: Column(
                            children: [
                              Text(
                                item.score.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFFFF7A1A),
                                ),
                              ),
                              Text(
                                item.delta,
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF146B50),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    _MiniHeatChart(item: item),
                    SizedBox(height: 16.h),
                    _SheetLabel(title: '升溫原因'),
                    SizedBox(height: 6.h),
                    Text(
                      item.whyHot,
                      style: TextStyle(
                        fontSize: 12.2.sp,
                        height: 1.6,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF5E6663),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _SheetLabel(title: '相關案件'),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: item.relatedCases
                          .map(
                            (label) => Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 11.w,
                                vertical: 7.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF4F7F5),
                                borderRadius: BorderRadius.circular(999.r),
                                border: Border.all(
                                  color: item.tint.withValues(alpha: 0.22),
                                ),
                              ),
                              child: Text(
                                label,
                                style: TextStyle(
                                  fontSize: 10.8.sp,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF35514B),
                                ),
                              ),
                            ),
                          )
                          .toList(growable: false),
                    ),
                    SizedBox(height: 18.h),
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoButton(
                        color: const Color(0xFF173C37),
                        borderRadius: BorderRadius.circular(16.r),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        onPressed: onShowFullDiscussion,
                        child: Text(
                          '看完整討論',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetLabel extends StatelessWidget {
  const _SheetLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w900,
        color: const Color(0xFF173C37),
      ),
    );
  }
}

class _MiniHeatChart extends StatelessWidget {
  const _MiniHeatChart({required this.item});

  final DiscussionTrendItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF5FAF8),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: item.tint.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '簡短熱度圖',
            style: TextStyle(
              fontSize: 11.4.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF35514B),
            ),
          ),
          SizedBox(height: 10.h),
          SizedBox(
            height: 86.h,
            child: CustomPaint(
              painter: _MiniHeatChartPainter(
                values: item.heatCurve,
                color: item.tint,
              ),
              child: const SizedBox.expand(),
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: List.generate(item.heatLabels.length, (index) {
              return Expanded(
                child: Text(
                  item.heatLabels[index],
                  textAlign: index == item.heatLabels.length - 1
                      ? TextAlign.right
                      : index == 0
                          ? TextAlign.left
                          : TextAlign.center,
                  style: TextStyle(
                    fontSize: 9.7.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF6E7874),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _MiniHeatChartPainter extends CustomPainter {
  _MiniHeatChartPainter({
    required this.values,
    required this.color,
  });

  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final range = (maxValue - minValue).clamp(1, double.infinity).toDouble();

    final gridPaint = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (var i = 0; i < 3; i++) {
      final y = size.height * (i + 1) / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final points = <Offset>[];
    for (var i = 0; i < values.length; i++) {
      final x = size.width * i / (values.length - 1);
      final normalized = (values[i] - minValue) / range;
      final y = size.height - normalized * (size.height - 10.h) - 6.h;
      points.add(Offset(x, y));
    }

    final fillPath = Path()..moveTo(points.first.dx, size.height);
    for (final point in points) {
      fillPath.lineTo(point.dx, point.dy);
    }
    fillPath
      ..lineTo(points.last.dx, size.height)
      ..close();
    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.18),
            color.withValues(alpha: 0.02),
          ],
        ).createShader(Offset.zero & size),
    );

    final strokePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      strokePath.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(
      strokePath,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    canvas.drawCircle(
      points.last,
      4.5,
      Paint()..color = color,
    );
    canvas.drawCircle(
      points.last,
      8,
      Paint()..color = color.withValues(alpha: 0.16),
    );
  }

  @override
  bool shouldRepaint(covariant _MiniHeatChartPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.color != color;
  }
}

class _DiscussionDetailSheet extends StatefulWidget {
  const _DiscussionDetailSheet({
    required this.topic,
    required this.palette,
  });

  final HomeDiscussionTopic topic;
  final JournalPalette palette;

  @override
  State<_DiscussionDetailSheet> createState() => _DiscussionDetailSheetState();
}

class _DiscussionDetailSheetState extends State<_DiscussionDetailSheet> {
  int? _selectedPollOption;
  bool _isFollowing = false;

  @override
  Widget build(BuildContext context) {
    final topic = widget.topic;
    final palette = widget.palette;
    final totalVotes = topic.poll != null
        ? topic.poll!.options.fold<int>(0, (sum, opt) => sum + opt.votes)
        : 0;

    return FractionallySizedBox(
      heightFactor: 0.9,
      child: Container(
        decoration: BoxDecoration(
          color: palette.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          border: Border.all(color: palette.border, width: 1.5),
        ),
        child: Column(
          children: [
            // Top Drag Bar
            SizedBox(height: 10.h),
            Container(
              width: 42.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: palette.border,
                borderRadius: BorderRadius.circular(999.r),
              ),
            ),
            // Header with title and close button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '議題討論詳情',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                        color: palette.primaryText,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: palette.primaryText),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: palette.border),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
                children: [
                  // Topic Title
                  Text(
                    topic.title,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w900,
                      color: palette.primaryText,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  // Tags
                  Wrap(
                    spacing: 6.w,
                    runSpacing: 6.h,
                    children: topic.tags.map((tag) => Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: CaseTimeMachineColors.primaryGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: CaseTimeMachineColors.primaryGreen.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: CaseTimeMachineColors.primaryGreen,
                        ),
                      ),
                    )).toList(),
                  ),
                  SizedBox(height: 16.h),
                  // Heat Summary Card
                  Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: palette.surface,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: palette.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem('本週排名', '#${topic.rank}', Icons.assessment_rounded),
                        _buildStatItem('熱度分數', '${topic.heatScore}', Icons.local_fire_department_rounded),
                        _buildStatItem('今日升幅', '+${topic.dayChangePercent}%', Icons.trending_up_rounded),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  // Overview
                  _buildSectionTitle('議題簡介', Icons.info_outline_rounded),
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: palette.surface,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: palette.border),
                    ),
                    child: Text(
                      topic.overview,
                      style: TextStyle(
                        fontSize: 13.sp,
                        height: 1.5,
                        color: palette.primaryText,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  // Trend Chart
                  _buildSectionTitle('社群聲量趨勢', Icons.analytics_outlined),
                  SizedBox(height: 8.h),
                  _DetailHeatChart(topic: topic, palette: palette),
                  SizedBox(height: 20.h),
                  // Timeline events
                  _buildSectionTitle('事件關鍵節點', Icons.history_edu_rounded),
                  SizedBox(height: 12.h),
                  _buildTimelineList(topic.timelineEvents, palette),
                  SizedBox(height: 20.h),
                  // Poll / Quiz
                  if (topic.poll != null) ...[
                    _buildSectionTitle('社群意向調查', Icons.how_to_vote_rounded),
                    SizedBox(height: 8.h),
                    _buildPollCard(topic.poll!, totalVotes, palette),
                    SizedBox(height: 20.h),
                  ],
                  // Latest Comment
                  _buildSectionTitle('最新社群觀點', Icons.chat_bubble_outline_rounded),
                  SizedBox(height: 8.h),
                  _buildCommentCard(topic.latestComment, palette),
                  SizedBox(height: 24.h),
                  // Actions Row
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              _isFollowing = !_isFollowing;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(_isFollowing ? '已追蹤此議題！' : '已取消追蹤'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          icon: Icon(
                            _isFollowing ? Icons.notifications_active_rounded : Icons.notifications_none_rounded,
                            size: 18.sp,
                          ),
                          label: Text(_isFollowing ? '追蹤中' : '追蹤議題'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _isFollowing ? CaseTimeMachineColors.primaryGreen : palette.primaryText,
                            side: BorderSide(
                              color: _isFollowing ? CaseTimeMachineColors.primaryGreen : palette.border,
                              width: 1.5,
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).push(
                              CupertinoPageRoute<void>(
                                builder: (__) => const CaseTimeMachineEntryPage(),
                              ),
                            );
                          },
                          icon: Icon(Icons.auto_stories_rounded, size: 18.sp),
                          label: const Text('進入案件圖書館'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF173C37),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFFF7A1A), size: 20.sp),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w900,
            color: widget.palette.primaryText,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: widget.palette.secondaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF173C37), size: 18.sp),
        SizedBox(width: 6.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w900,
            color: widget.palette.primaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineList(List<HomeDiscussionTimelineEvent> events, JournalPalette palette) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final ev = events[index];
        final isLast = index == events.length - 1;
        final isPositive = ev.impactLabel.startsWith('+');

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Timeline line and dot
              Column(
                children: [
                  Container(
                    width: 10.w,
                    height: 10.w,
                    decoration: BoxDecoration(
                      color: isPositive ? const Color(0xFF146B50) : const Color(0xFFC62828),
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2.w,
                        color: palette.border,
                      ),
                    ),
                ],
              ),
              SizedBox(width: 12.w),
              // Content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: palette.surface,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: palette.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              ev.timeLabel,
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                                color: palette.secondaryText,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: isPositive
                                    ? const Color(0xFFEAF7F2)
                                    : const Color(0xFFFFF0F0),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                ev.impactLabel,
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w900,
                                  color: isPositive
                                      ? const Color(0xFF146B50)
                                      : const Color(0xFFC62828),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          ev.description,
                          style: TextStyle(
                            fontSize: 12.sp,
                            height: 1.4,
                            color: palette.primaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPollCard(HomeDiscussionPoll poll, int totalVotes, JournalPalette palette) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            poll.prompt,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w900,
              color: palette.primaryText,
            ),
          ),
          SizedBox(height: 12.h),
          ...List.generate(poll.options.length, (index) {
            final opt = poll.options[index];
            final percent = totalVotes > 0 ? (opt.votes / totalVotes) : 0.0;
            final isSelected = _selectedPollOption == index;

            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedPollOption = index;
                  });
                },
                borderRadius: BorderRadius.circular(10.r),
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFEAF7F2) : palette.background,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF146B50) : palette.border,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            opt.label,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                              color: isSelected ? const Color(0xFF146B50) : palette.primaryText,
                            ),
                          ),
                          Text(
                            '${(percent * 100).toStringAsFixed(1)}% (${opt.votes} 票)',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? const Color(0xFF146B50) : palette.secondaryText,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4.r),
                        child: LinearProgressIndicator(
                          value: percent,
                          backgroundColor: palette.border,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isSelected ? const Color(0xFF146B50) : const Color(0xFFFF7A1A),
                          ),
                          minHeight: 6.h,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCommentCard(HomeDiscussionComment comment, JournalPalette palette) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16.r,
                backgroundColor: CaseTimeMachineColors.primaryGreen.withValues(alpha: 0.1),
                child: Text(
                  comment.userHandle.isNotEmpty ? comment.userHandle.substring(1, 2).toUpperCase() : 'U',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: CaseTimeMachineColors.primaryGreen,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.userHandle,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: palette.primaryText,
                      ),
                    ),
                    Text(
                      comment.submittedAt,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: palette.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            comment.content,
            style: TextStyle(
              fontSize: 13.sp,
              height: 1.45,
              color: palette.primaryText,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailHeatChart extends StatelessWidget {
  const _DetailHeatChart({
    required this.topic,
    required this.palette,
  });

  final HomeDiscussionTopic topic;
  final JournalPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '討論聲量走勢 (近期)',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                  color: palette.secondaryText,
                ),
              ),
              Text(
                topic.heatLabel,
                style: TextStyle(
                  fontSize: 9.sp,
                  color: palette.secondaryText.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          SizedBox(
            height: 120.h,
            width: double.infinity,
            child: CustomPaint(
              painter: _DetailHeatChartPainter(
                points: topic.trendPoints,
                lineColor: const Color(0xFFFF7A1A),
                palette: palette,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: topic.trendPoints.map((pt) {
              return Text(
                pt.dateLabel,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  color: palette.secondaryText,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _DetailHeatChartPainter extends CustomPainter {
  _DetailHeatChartPainter({
    required this.points,
    required this.lineColor,
    required this.palette,
  });

  final List<HomeDiscussionTrendPoint> points;
  final Color lineColor;
  final JournalPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final volumes = points.map((p) {
      final match = RegExp(r'\d+').firstMatch(p.volumeLabel);
      if (match != null) {
        return double.tryParse(match.group(0)!) ?? 0.0;
      }
      return 0.0;
    }).toList();

    final maxVal = volumes.reduce((a, b) => a > b ? a : b).clamp(1.0, double.infinity);
    final minVal = volumes.reduce((a, b) => a < b ? a : b);
    final range = maxVal - minVal;

    final gridPaint = Paint()
      ..color = palette.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    for (var i = 0; i <= 3; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final drawingPoints = <Offset>[];
    final stepX = size.width / (points.length - 1);
    for (var i = 0; i < points.length; i++) {
      final x = i * stepX;
      final ratio = range == 0 ? 0.5 : (volumes[i] - minVal) / range;
      final y = size.height - (ratio * (size.height - 20.h) + 10.h);
      drawingPoints.add(Offset(x, y));
    }

    final path = Path()..moveTo(drawingPoints.first.dx, size.height);
    for (final pt in drawingPoints) {
      path.lineTo(pt.dx, pt.dy);
    }
    path.lineTo(drawingPoints.last.dx, size.height);
    path.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          lineColor.withValues(alpha: 0.25),
          lineColor.withValues(alpha: 0.01),
        ],
      ).createShader(Offset.zero & size)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final curvePath = Path()..moveTo(drawingPoints.first.dx, drawingPoints.first.dy);
    for (var i = 1; i < drawingPoints.length; i++) {
      final prev = drawingPoints[i - 1];
      final curr = drawingPoints[i];
      final cp1 = Offset(prev.dx + (curr.dx - prev.dx) / 2, prev.dy);
      final cp2 = Offset(prev.dx + (curr.dx - prev.dx) / 2, curr.dy);
      curvePath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, curr.dx, curr.dy);
    }
    canvas.drawPath(curvePath, linePaint);

    for (var i = 0; i < drawingPoints.length; i++) {
      final pt = drawingPoints[i];
      canvas.drawCircle(pt, 5.0, Paint()..color = Colors.white);
      canvas.drawCircle(pt, 5.0, Paint()..color = lineColor..style = PaintingStyle.stroke..strokeWidth = 2.0);

      final annotation = points[i].annotation;
      if (annotation != null && annotation.isNotEmpty) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: annotation,
            style: TextStyle(
              fontSize: 8.sp,
              fontWeight: FontWeight.bold,
              color: lineColor,
              backgroundColor: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(
          canvas,
          Offset(pt.dx - textPainter.width / 2, pt.dy - textPainter.height - 4.h),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DetailHeatChartPainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.lineColor != lineColor || oldDelegate.palette != palette;
  }
}
