import 'package:flutter/cupertino.dart';
import 'package:preamble/components/shared/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/components/home/home_content.dart';
import 'package:preamble/data/mock_data/home/home_mock_data.dart';
import 'package:preamble/features/case_library/data/case_library_data.dart';
import 'package:preamble/features/case_library/models/case_library_models.dart';
import 'package:preamble/features/case_library/pages/case_dossier_detail_page.dart';
import 'package:preamble/pages/journal/data/journal_page_items.dart';
import 'package:preamble/pages/journal/widgets/journal_palette.dart';
import 'package:preamble/data/legal_brain/legal_syllogism_engine.dart';
import 'package:preamble/pages/learning/know_law_page.dart';
import 'package:url_launcher/url_launcher.dart';

class DiscussionDetailPage extends StatefulWidget {
  const DiscussionDetailPage({
    super.key,
    required this.item,
    required this.palette,
    this.liveArticleCount,
    this.liveArticles = const [],
  });

  final DiscussionTrendItem item;
  final JournalPalette palette;
  final int? liveArticleCount;
  final List<LiveNewsArticle> liveArticles;

  @override
  State<DiscussionDetailPage> createState() => _DiscussionDetailPageState();
}

class _DiscussionDetailPageState extends State<DiscussionDetailPage> {
  bool _isFollowing = false;

  @override
  Widget build(BuildContext context) {
    final topic = homeDiscussionFeed.topics[widget.item.fullTopicIndex];

    return Scaffold(
      backgroundColor: widget.palette.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: widget.palette.surface,
        leading: IconButton(
          icon: Icon(CupertinoIcons.back, color: widget.palette.primaryText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '議題討論詳情',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w900,
            color: widget.palette.primaryText,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFollowing ? CupertinoIcons.bell_fill : CupertinoIcons.bell,
              color: _isFollowing
                  ? const Color(0xFFFF7A1A)
                  : widget.palette.primaryText,
            ),
            onPressed: () {
              setState(() {
                _isFollowing = !_isFollowing;
              });
              CustomToast.show(context, _isFollowing ? '已追蹤此議題！' : '已取消追蹤');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Section Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: 'discussion-rank-${widget.item.rank}',
                    child: _CompactRankBadge(
                        rank: widget.item.rank, tint: widget.item.tint),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Hero(
                      tag: 'discussion-title-${widget.item.rank}',
                      child: Material(
                        color: Colors.transparent,
                        child: Text(
                          widget.item.title,
                          style: TextStyle(
                            fontSize: 20.sp,
                            height: 1.25,
                            fontWeight: FontWeight.w900,
                            color: widget.palette.primaryText,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              // Tags list
              Wrap(
                spacing: 6.w,
                runSpacing: 6.h,
                children: topic.tags
                    .map((tag) => Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 5.h),
                          decoration: BoxDecoration(
                            color: widget.item.tint.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                                color: widget.item.tint.withValues(alpha: 0.2)),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                              color: widget.item.tint,
                            ),
                          ),
                        ))
                    .toList(),
              ),
              SizedBox(height: 16.h),

              // Heat Summary Card
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: widget.palette.surface,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: widget.palette.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    if (widget.liveArticleCount != null)
                      _buildStatItem('近期報導量', '${widget.liveArticleCount} 則',
                          Icons.newspaper_rounded)
                    else
                      _buildStatItem(
                          '議題索引', '#${topic.rank}', Icons.assessment_rounded),
                    _buildStatItem('關聯案例', '${widget.item.relatedCases.length} 案',
                        Icons.library_books_rounded),
                    _buildStatItem(
                      '資料來源',
                      widget.liveArticles.isNotEmpty
                          ? 'Google News'
                          : '案件圖書館',
                      Icons.public_rounded,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),

              // 即時台灣公開新聞報導（App 內建瀏覽器開啟）
              if (widget.liveArticles.isNotEmpty) ...[
                _buildSectionTitle(
                    '近期公開新聞報導（Google News 台灣）', Icons.newspaper_rounded),
                SizedBox(height: 10.h),
                for (final article in widget.liveArticles)
                  Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14.r),
                        onTap: () {
                          final uri = Uri.tryParse(article.url);
                          if (uri != null) {
                            launchUrl(uri, mode: LaunchMode.inAppBrowserView);
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: widget.palette.surface,
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(color: widget.palette.border),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      article.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w700,
                                        height: 1.4,
                                        color: widget.palette.primaryText,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      article.source,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color: widget.item.tint,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Icon(
                                CupertinoIcons.arrow_up_right_square,
                                size: 17.sp,
                                color: widget.palette.secondaryText,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                SizedBox(height: 16.h),
              ],

              // 小法助 AI 法律焦點透視卡
              _buildAiLegalInsightCard(topic),
              SizedBox(height: 20.h),

              // Related Cases Horizontal Carousel
              _buildSectionTitle(
                  '關聯歷史卷宗 (進入案件圖書館)', Icons.library_books_outlined),
              SizedBox(height: 10.h),
              RelatedCasesCarousel(
                topicIndex: widget.item.fullTopicIndex,
                palette: widget.palette,
              ),
              SizedBox(height: 24.h),
            ],
          ),
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
            fontSize: 15.sp,
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
            fontSize: 13.5.sp,
            fontWeight: FontWeight.w900,
            color: widget.palette.primaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildCommentCard(
      HomeDiscussionComment comment, JournalPalette palette) {
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
                backgroundColor: widget.item.tint.withValues(alpha: 0.1),
                child: Text(
                  comment.userHandle.isNotEmpty
                      ? comment.userHandle.substring(1, 2).toUpperCase()
                      : 'U',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: widget.item.tint,
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

  Widget _buildAiLegalInsightCard(HomeDiscussionTopic topic) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryGreen =
        isDark ? const Color(0xFF68B28B) : const Color(0xFF2C5E43);
    final cardBg =
        isDark ? const Color(0xFF1E2822) : const Color(0xFFF2F8F5);
    final borderColor =
        isDark ? const Color(0xFF2D3E35) : const Color(0xFFD0E4DC);

    // 透過台灣法學三段論大腦對該時事議題進行即時法理涵攝
    final facts = '${topic.title}。${topic.overview}。${widget.item.whyHot}';
    final analysis = LegalSyllogismEngine.analyze(rawFacts: facts);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: borderColor, width: 1.2.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 頂部吉祥物與標題
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/assistant/law_assistant_home.png',
                  width: 32.w,
                  height: 32.w,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '小法助法律焦點透視',
                          style: TextStyle(
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w900,
                            color: widget.palette.primaryText,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 6.w, vertical: 1.5.h),
                          decoration: BoxDecoration(
                            color: primaryGreen.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            'AI 即時法理涵攝',
                            style: TextStyle(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.bold,
                              color: primaryGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '爭議領域：${analysis.disputeCategory}',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: widget.palette.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),

          // 核心法條依據
          if (analysis.majorPremiseStatutes.isNotEmpty) ...[
            Text(
              '⚖️ 涉及核心法條依據：',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
                color: widget.palette.primaryText,
              ),
            ),
            SizedBox(height: 5.h),
            Wrap(
              spacing: 6.w,
              runSpacing: 4.h,
              children: analysis.majorPremiseStatutes.take(3).map((statute) {
                return Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: primaryGreen.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(
                      color: primaryGreen.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    '${statute.lawName} 第 ${statute.articleNumber} 條',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w800,
                      color: primaryGreen,
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 10.h),
          ],

          // 法律爭點本質
          Text(
            '💡 本案法律爭點白話解讀：',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
              color: widget.palette.primaryText,
            ),
          ),
          SizedBox(height: 4.h),
          ...analysis.identifiedIssues.take(2).map(
                (issue) => Padding(
                  padding: EdgeInsets.only(bottom: 3.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• ',
                          style: TextStyle(
                              color: primaryGreen,
                              fontWeight: FontWeight.bold)),
                      Expanded(
                        child: Text(
                          issue,
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            height: 1.35,
                            color: widget.palette.primaryText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          SizedBox(height: 10.h),

          // 民眾生活自保建議
          Text(
            '🛡️ 若一般民眾遇到類似情況之自保提醒：',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
              color: widget.palette.primaryText,
            ),
          ),
          SizedBox(height: 4.h),
          ...analysis.demands.take(2).map(
                (demand) => Padding(
                  padding: EdgeInsets.only(bottom: 3.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('✓ ',
                          style: TextStyle(
                              color: primaryGreen,
                              fontWeight: FontWeight.bold)),
                      Expanded(
                        child: Text(
                          demand,
                          style: TextStyle(
                            fontSize: 11.sp,
                            height: 1.35,
                            color: widget.palette.secondaryText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          SizedBox(height: 12.h),

          // 互動引導按鈕
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                final prompt =
                    '我想請教關於「${topic.title}」的法律問題：一般民眾如果面臨類似爭議，在法律上該如何主張權益與自保？';
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        LawAssistantChatPage(initialPrompt: prompt),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: isDark
                    ? const Color(0xFF2C4438)
                    : const Color(0xFF2C5E43),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 10.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              icon: Icon(Icons.chat_bubble_outline_rounded, size: 14.sp),
              label: Text(
                '向小法助詢問此議題 / 若我遇到如何自保？',
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
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

// ---------------------------------------------------------------------------
// Interactive Trend Chart
// ---------------------------------------------------------------------------
class InteractiveTrendChart extends StatefulWidget {
  const InteractiveTrendChart({
    super.key,
    required this.topic,
    required this.palette,
  });

  final HomeDiscussionTopic topic;
  final JournalPalette palette;

  @override
  State<InteractiveTrendChart> createState() => _InteractiveTrendChartState();
}

class _InteractiveTrendChartState extends State<InteractiveTrendChart> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    final points = widget.topic.trendPoints;
    final lineColor = const Color(0xFFFF7A1A);

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: widget.palette.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: widget.palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '聲量走勢 (滑動或長按看細節)',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                  color: widget.palette.secondaryText,
                ),
              ),
              Text(
                _hoveredIndex != null
                    ? '已選: ${points[_hoveredIndex!].dateLabel}'
                    : '本週聲量',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  color: lineColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          LayoutBuilder(
            builder: (context, constraints) {
              final chartWidth = constraints.maxWidth;
              final chartHeight = 120.h;

              final volumes = points.map((p) {
                final match = RegExp(r'\d+').firstMatch(p.volumeLabel);
                if (match != null) {
                  return double.tryParse(match.group(0)!) ?? 0.0;
                }
                return 0.0;
              }).toList();

              final maxVal = volumes
                  .reduce((a, b) => a > b ? a : b)
                  .clamp(1.0, double.infinity);
              final minVal = volumes.reduce((a, b) => a < b ? a : b);
              final range = maxVal - minVal;

              final drawingPoints = <Offset>[];
              final stepX = chartWidth / (points.length - 1);
              for (var i = 0; i < points.length; i++) {
                final x = i * stepX;
                final ratio = range == 0 ? 0.5 : (volumes[i] - minVal) / range;
                final y = chartHeight - (ratio * (chartHeight - 20.h) + 10.h);
                drawingPoints.add(Offset(x, y));
              }

              void updateHoverIndex(double localX) {
                final idx =
                    (localX / stepX).round().clamp(0, points.length - 1);
                if (_hoveredIndex != idx) {
                  setState(() {
                    _hoveredIndex = idx;
                  });
                }
              }

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  GestureDetector(
                    onPanDown: (details) =>
                        updateHoverIndex(details.localPosition.dx),
                    onPanUpdate: (details) =>
                        updateHoverIndex(details.localPosition.dx),
                    onPanEnd: (_) => setState(() => _hoveredIndex = null),
                    onTapDown: (details) =>
                        updateHoverIndex(details.localPosition.dx),
                    onTapUp: (_) => setState(() => _hoveredIndex = null),
                    onTapCancel: () => setState(() => _hoveredIndex = null),
                    child: SizedBox(
                      height: chartHeight,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: _InteractiveHeatChartPainter(
                          points: points,
                          lineColor: lineColor,
                          palette: widget.palette,
                          hoveredIndex: _hoveredIndex,
                        ),
                      ),
                    ),
                  ),
                  if (_hoveredIndex != null &&
                      _hoveredIndex! < drawingPoints.length)
                    () {
                      final selectedPt = drawingPoints[_hoveredIndex!];
                      final ptData = points[_hoveredIndex!];

                      final isLeft = selectedPt.dx < chartWidth / 2;
                      final tooltipWidth = 120.w;
                      final tooltipX = isLeft
                          ? (selectedPt.dx + 10.w)
                              .clamp(0.0, chartWidth - tooltipWidth)
                          : (selectedPt.dx - tooltipWidth - 10.w)
                              .clamp(0.0, chartWidth);

                      final tooltipY =
                          (selectedPt.dy - 50.h).clamp(0.0, chartHeight - 60.h);

                      return Positioned(
                        left: tooltipX,
                        top: tooltipY,
                        child: Container(
                          width: tooltipWidth,
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(8.r),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                ptData.dateLabel,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                ptData.volumeLabel,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              if (ptData.annotation != null &&
                                  ptData.annotation!.isNotEmpty) ...[
                                SizedBox(height: 2.h),
                                Text(
                                  ptData.annotation!,
                                  style: TextStyle(
                                    color: lineColor,
                                    fontSize: 8.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }(),
                ],
              );
            },
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: points.map((pt) {
              return Text(
                pt.dateLabel,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  color: widget.palette.secondaryText,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _InteractiveHeatChartPainter extends CustomPainter {
  _InteractiveHeatChartPainter({
    required this.points,
    required this.lineColor,
    required this.palette,
    required this.hoveredIndex,
  });

  final List<HomeDiscussionTrendPoint> points;
  final Color lineColor;
  final JournalPalette palette;
  final int? hoveredIndex;

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

    final maxVal =
        volumes.reduce((a, b) => a > b ? a : b).clamp(1.0, double.infinity);
    final minVal = volumes.reduce((a, b) => a < b ? a : b);
    final range = maxVal - minVal;

    final gridPaint = Paint()
      ..color = palette.border.withValues(alpha: 0.5)
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

    // Gradient fill
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

    // Main line (smooth curve)
    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final curvePath = Path()
      ..moveTo(drawingPoints.first.dx, drawingPoints.first.dy);
    for (var i = 1; i < drawingPoints.length; i++) {
      final prev = drawingPoints[i - 1];
      final curr = drawingPoints[i];
      final cp1 = Offset(prev.dx + (curr.dx - prev.dx) / 2, prev.dy);
      final cp2 = Offset(prev.dx + (curr.dx - prev.dx) / 2, curr.dy);
      curvePath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, curr.dx, curr.dy);
    }
    canvas.drawPath(curvePath, linePaint);

    // Draw interaction details
    if (hoveredIndex != null && hoveredIndex! < drawingPoints.length) {
      final selectedPt = drawingPoints[hoveredIndex!];

      // Draw vertical guide line
      final guidePaint = Paint()
        ..color = lineColor.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      double startY = selectedPt.dy;
      while (startY < size.height) {
        canvas.drawLine(
          Offset(selectedPt.dx, startY),
          Offset(selectedPt.dx, (startY + 4.h).clamp(0, size.height)),
          guidePaint,
        );
        startY += 8.h;
      }

      // Highlighted selected node
      canvas.drawCircle(
          selectedPt, 8.0, Paint()..color = lineColor.withValues(alpha: 0.2));
      canvas.drawCircle(selectedPt, 4.0, Paint()..color = lineColor);
    }

    // Draw basic circles on other nodes
    for (var i = 0; i < drawingPoints.length; i++) {
      if (i == hoveredIndex) continue;
      final pt = drawingPoints[i];
      canvas.drawCircle(pt, 4.0, Paint()..color = Colors.white);
      canvas.drawCircle(
        pt,
        4.0,
        Paint()
          ..color = lineColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _InteractiveHeatChartPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.palette != palette ||
        oldDelegate.hoveredIndex != hoveredIndex;
  }
}

// ---------------------------------------------------------------------------
// Interactive Timeline Section
// ---------------------------------------------------------------------------
class InteractiveTimelineSection extends StatefulWidget {
  const InteractiveTimelineSection({
    super.key,
    required this.events,
    required this.palette,
    required this.tint,
  });

  final List<HomeDiscussionTimelineEvent> events;
  final JournalPalette palette;
  final Color tint;

  @override
  State<InteractiveTimelineSection> createState() =>
      _InteractiveTimelineSectionState();
}

class _InteractiveTimelineSectionState
    extends State<InteractiveTimelineSection> {
  final Set<int> _expandedIndices = {0};

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(widget.events.length, (index) {
        final ev = widget.events[index];
        final isLast = index == widget.events.length - 1;
        final isPositive = ev.impactLabel.startsWith('+');
        final isExpanded = _expandedIndices.contains(index);

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isExpanded) {
                          _expandedIndices.remove(index);
                        } else {
                          _expandedIndices.add(index);
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 14.w,
                      height: 14.w,
                      decoration: BoxDecoration(
                        color: isExpanded
                            ? widget.tint
                            : (isPositive
                                ? const Color(0xFF146B50)
                                : const Color(0xFFC62828)),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isExpanded ? Colors.white : Colors.transparent,
                          width: 2.w,
                        ),
                        boxShadow: isExpanded
                            ? [
                                BoxShadow(
                                  color: widget.tint.withValues(alpha: 0.4),
                                  blurRadius: 6,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2.w,
                        color: isExpanded ? widget.tint : widget.palette.border,
                      ),
                    ),
                ],
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.palette.surface,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isExpanded
                            ? widget.tint.withValues(alpha: 0.5)
                            : widget.palette.border,
                        width: isExpanded ? 1.5.w : 1.0.w,
                      ),
                      boxShadow: isExpanded
                          ? [
                              BoxShadow(
                                color: widget.tint.withValues(alpha: 0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ]
                          : null,
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12.r),
                      onTap: () {
                        setState(() {
                          if (isExpanded) {
                            _expandedIndices.remove(index);
                          } else {
                            _expandedIndices.add(index);
                          }
                        });
                      },
                      child: Padding(
                        padding: EdgeInsets.all(12.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  ev.timeLabel,
                                  style: TextStyle(
                                    fontSize: 11.5.sp,
                                    fontWeight: FontWeight.bold,
                                    color: isExpanded
                                        ? widget.tint
                                        : widget.palette.secondaryText,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 6.w, vertical: 2.h),
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
                            AnimatedCrossFade(
                              duration: const Duration(milliseconds: 220),
                              crossFadeState: isExpanded
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,
                              firstChild:
                                  const SizedBox(width: double.infinity),
                              secondChild: Padding(
                                padding: EdgeInsets.only(top: 8.h),
                                child: Text(
                                  ev.description,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    height: 1.5,
                                    color: widget.palette.primaryText,
                                  ),
                                ),
                              ),
                            ),
                            if (!isExpanded) ...[
                              SizedBox(height: 4.h),
                              Text(
                                '點擊展開詳情...',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: widget.palette.secondaryText
                                      .withValues(alpha: 0.7),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Interactive Poll/Quiz Card
// ---------------------------------------------------------------------------
class InteractivePollQuizCard extends StatefulWidget {
  const InteractivePollQuizCard({
    super.key,
    required this.topic,
    required this.palette,
    required this.tint,
  });

  final HomeDiscussionTopic topic;
  final JournalPalette palette;
  final Color tint;

  @override
  State<InteractivePollQuizCard> createState() =>
      _InteractivePollQuizCardState();
}

class _InteractivePollQuizCardState extends State<InteractivePollQuizCard> {
  int? _selectedPollOption;
  int? _selectedQuizOption;
  bool _showExplanation = false;

  late final HomeQuizQuestion _quiz;

  @override
  void initState() {
    super.initState();
    final quizIndex = widget.topic.rank % homeQuizQuestions.length;
    _quiz = homeQuizQuestions[quizIndex];
  }

  @override
  Widget build(BuildContext context) {
    final poll = widget.topic.poll;
    if (poll != null) {
      final totalVotes =
          poll.options.fold<int>(0, (sum, opt) => sum + opt.votes);
      return Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: widget.palette.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: widget.palette.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              poll.prompt,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w900,
                color: widget.palette.primaryText,
              ),
            ),
            SizedBox(height: 12.h),
            ...List.generate(poll.options.length, (index) {
              final opt = poll.options[index];
              final isSelected = _selectedPollOption == index;
              final adjustedVotes = isSelected ? opt.votes + 1 : opt.votes;
              final adjustedTotal =
                  _selectedPollOption != null ? totalVotes + 1 : totalVotes;
              final percent =
                  adjustedTotal > 0 ? (adjustedVotes / adjustedTotal) : 0.0;

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
                      color: isSelected
                          ? widget.tint.withValues(alpha: 0.1)
                          : widget.palette.background,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: isSelected ? widget.tint : widget.palette.border,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                opt.label,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: isSelected
                                      ? FontWeight.w900
                                      : FontWeight.bold,
                                  color: isSelected
                                      ? widget.tint
                                      : widget.palette.primaryText,
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              '${(percent * 100).toStringAsFixed(1)}% ($adjustedVotes 票)',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? widget.tint
                                    : widget.palette.secondaryText,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: percent),
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(4.r),
                              child: LinearProgressIndicator(
                                value: value,
                                backgroundColor: widget.palette.border,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isSelected
                                      ? widget.tint
                                      : const Color(0xFFFF7A1A),
                                ),
                                minHeight: 6.h,
                              ),
                            );
                          },
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
    } else {
      return Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: widget.palette.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: widget.palette.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline_rounded,
                    color: Colors.amber[700], size: 20.sp),
                SizedBox(width: 6.w),
                Text(
                  '法律知識小學堂',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w900,
                    color: widget.palette.primaryText,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              _quiz.question,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: widget.palette.primaryText,
                height: 1.4,
              ),
            ),
            SizedBox(height: 12.h),
            ...List.generate(_quiz.options.length, (index) {
              final opt = _quiz.options[index];
              final isSelected = _selectedQuizOption == index;

              Color getBgColor() {
                if (!isSelected) return widget.palette.background;
                return opt.isCorrect
                    ? const Color(0xFFEAF7F2)
                    : const Color(0xFFFFF0F0);
              }

              Color getBorderColor() {
                if (!isSelected) return widget.palette.border;
                return opt.isCorrect
                    ? const Color(0xFF146B50)
                    : const Color(0xFFC62828);
              }

              return Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: InkWell(
                  onTap: _showExplanation
                      ? null
                      : () {
                          setState(() {
                            _selectedQuizOption = index;
                            _showExplanation = true;
                          });
                        },
                  borderRadius: BorderRadius.circular(10.r),
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: getBgColor(),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: getBorderColor(),
                        width: isSelected ? 1.5.w : 1.0.w,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            opt.title,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: isSelected
                                  ? FontWeight.w900
                                  : FontWeight.bold,
                              color: isSelected
                                  ? (opt.isCorrect
                                      ? const Color(0xFF146B50)
                                      : const Color(0xFFC62828))
                                  : widget.palette.primaryText,
                            ),
                          ),
                        ),
                        if (isSelected) ...[
                          SizedBox(width: 8.w),
                          Icon(
                            opt.isCorrect
                                ? Icons.check_circle_rounded
                                : Icons.cancel_rounded,
                            color: opt.isCorrect
                                ? const Color(0xFF146B50)
                                : const Color(0xFFC62828),
                            size: 18.sp,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState: _showExplanation
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: const SizedBox(width: double.infinity),
              secondChild: Padding(
                padding: EdgeInsets.only(top: 12.h),
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F9FB),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: widget.palette.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '解答說明：',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF173C37),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        _quiz.explanation,
                        style: TextStyle(
                          fontSize: 12.sp,
                          height: 1.5,
                          color: widget.palette.primaryText,
                        ),
                      ),
                      if (_quiz.termExplainMap.isNotEmpty) ...[
                        SizedBox(height: 10.h),
                        Text(
                          '法律名詞釋義：',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF173C37),
                          ),
                        ),
                        SizedBox(height: 6.h),
                        ..._quiz.termExplainMap.entries.map((entry) => Padding(
                              padding: EdgeInsets.only(bottom: 6.h),
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    height: 1.4,
                                    color: widget.palette.primaryText,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: '【${entry.key}】',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFFF7A1A)),
                                    ),
                                    TextSpan(text: entry.value),
                                  ],
                                ),
                              ),
                            )),
                      ],
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
}

// ---------------------------------------------------------------------------
// Related Cases Carousel (links to Case Library dossiers)
// ---------------------------------------------------------------------------
class RelatedCasesCarousel extends StatelessWidget {
  const RelatedCasesCarousel({
    super.key,
    required this.topicIndex,
    required this.palette,
  });

  final int topicIndex;
  final JournalPalette palette;

  List<CaseBook> _getRelatedCaseBooks() {
    final allCases = caseLibraryCases;

    String title = '';
    if (topicIndex >= 0 && topicIndex < homeDiscussionFeed.topics.length) {
      title = homeDiscussionFeed.topics[topicIndex].title;
    }

    if (title.contains('國會') ||
        title.contains('釋憲') ||
        title.contains('憲法') ||
        title.contains('違憲') ||
        title.contains('立院')) {
      return allCases
          .where((c) => ['318', '799', '499'].contains(c.id))
          .toList();
    }
    if (title.contains('詐騙') ||
        title.contains('洗錢') ||
        title.contains('吸金') ||
        title.contains('im.B')) {
      return allCases.where((c) => ['case-006'].contains(c.id)).toList();
    }
    if (title.contains('勞基法') ||
        title.contains('工時') ||
        title.contains('加班') ||
        title.contains('勞資') ||
        title.contains('責任制') ||
        title.contains('解雇')) {
      return allCases.where((c) => ['case-031'].contains(c.id)).toList();
    }
    if (title.contains('性騷') ||
        title.contains('騷擾') ||
        title.contains('職場')) {
      return allCases
          .where((c) => ['case-031', 'case-delivery-labor-2152'].contains(c.id))
          .toList();
    }
    if (title.contains('外送') ||
        title.contains('承攬') ||
        title.contains('僱傭') ||
        title.contains('從屬性')) {
      return allCases
          .where((c) => ['case-delivery-labor-2152', 'case-031'].contains(c.id))
          .toList();
    }
    if (title.contains('街拍') ||
        title.contains('肖像') ||
        title.contains('隱私') ||
        title.contains('跟拍')) {
      return allCases
          .where((c) => ['102', 'case-adultery-791'].contains(c.id))
          .toList();
    }
    if (title.contains('AI') ||
        title.contains('著作權') ||
        title.contains('合理使用') ||
        title.contains('轉載')) {
      return allCases
          .where((c) => ['case-045', 'case-044', 'case-046'].contains(c.id))
          .toList();
    }
    if (title.contains('租屋') ||
        title.contains('押金') ||
        title.contains('房東') ||
        title.contains('租賃') ||
        title.contains('退租') ||
        title.contains('扣抵')) {
      return allCases.where((c) => ['case-029'].contains(c.id)).toList();
    }

    switch (topicIndex) {
      case 0:
        return allCases
            .where((c) => ['318', '799', '499'].contains(c.id))
            .toList();
      case 1:
        return allCases.where((c) => ['case-006'].contains(c.id)).toList();
      case 2:
        return allCases.where((c) => ['case-031'].contains(c.id)).toList();
      case 3:
        return allCases
            .where(
              (c) => ['case-031', 'case-delivery-labor-2152'].contains(c.id),
            )
            .toList();
      case 4:
        return allCases.where((c) => ['case-029'].contains(c.id)).toList();
      case 5:
        return allCases
            .where(
              (c) => ['case-delivery-labor-2152', 'case-031'].contains(c.id),
            )
            .toList();
      case 6:
        return allCases
            .where((c) => ['102', 'case-adultery-791'].contains(c.id))
            .toList();
      case 7:
        return allCases
            .where((c) => ['case-045', 'case-044', 'case-046'].contains(c.id))
            .toList();
      default:
        return allCases.take(3).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cases = _getRelatedCaseBooks();
    if (cases.isEmpty) return const SizedBox.shrink();

    final baseHeight = 140.h < 140 ? 140.0 : 140.h;
    final adaptiveHeight =
        MediaQuery.textScalerOf(context).scale(baseHeight) + 12.h;

    return SizedBox(
      height: adaptiveHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cases.length,
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemBuilder: (context, index) {
          final book = cases[index];
          return Container(
            width: 250.w,
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: palette.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16.r),
              onTap: () {
                Navigator.of(context).push(
                  CupertinoPageRoute<void>(
                    builder: (context) => CaseDossierDetailPage(book: book),
                  ),
                );
              },
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF1E7B66).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            book.category,
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E7B66),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${book.year} 年',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: palette.secondaryText,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      book.titleZh,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: palette.primaryText,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Expanded(
                      child: Text(
                        book.oneSentenceSummary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.sp,
                          height: 1.4,
                          color: palette.secondaryText,
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '進入卷宗',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E7B66),
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Icon(
                            CupertinoIcons.chevron_right,
                            size: 10.sp,
                            color: const Color(0xFF1E7B66),
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
      ),
    );
  }
}
