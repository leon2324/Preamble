import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/components/home/legacy/home_discussion_section_legacy.dart'
    as legacy_home;
import 'package:lawapp/data/mock_data/home/home_mock_data.dart';
import 'package:lawapp/pages/journal/data/journal_page_items.dart';
import 'package:lawapp/pages/journal/widgets/journal_palette.dart';
import 'package:lawapp/pages/journal/widgets/journal_section_header.dart';
import 'package:lawapp/theme/app_colors.dart';

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
        // 台灣繁體中文教學註解：
        // 完整版內容直接重用首頁既有討論元件，讓記事頁只負責入口與節奏，
        // 不需要再維護第二套長內容 UI。
        return FractionallySizedBox(
          heightFactor: 0.88,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  SizedBox(height: 10.h),
                  Container(
                    width: 42.w,
                    height: 5.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD2DBD7),
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 28.h),
                      children: [
                        Text(
                          '完整討論',
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF173C37),
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          '往下看熱度圖、時間線、留言與投票脈絡。',
                          style: TextStyle(
                            fontSize: 12.sp,
                            height: 1.4,
                            color: const Color(0xFF6F7774),
                          ),
                        ),
                        SizedBox(height: 14.h),
                        legacy_home.HomeDiscussionSection(
                          onMoreTap: () {},
                          feed: homeDiscussionFeed,
                          showHeader: false,
                          initialExpandedIndex: topicIndex,
                          initialActiveIndex: topicIndex,
                        ),
                      ],
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
