import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/components/home/home_content.dart';
import 'package:preamble/components/home/home_section_title.dart';
import 'package:preamble/components/home/v2/home_v2_layout_policy.dart';
import 'package:preamble/theme/adaptive_layout.dart';
import 'package:preamble/theme/app_colors.dart';

/// 首頁「今日新聞」橫向卡片區塊。
class HomeNewsSection extends StatelessWidget {
  const HomeNewsSection({
    super.key,
    required this.items,
    this.onMoreTap,
    this.onItemTap,
    this.showHeader = true,
  });

  static const double _itemGap = 14;

  final List<HomeNewsItem> items;
  final VoidCallback? onMoreTap;
  final ValueChanged<HomeNewsItem>? onItemTap;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader) ...[
          _SectionHeader(
            title: '今日新聞',
            onMoreTap: onMoreTap,
          ),
          SizedBox(height: 15.h),
        ],
        LayoutBuilder(
          builder: (context, constraints) {
            final titleStyle = _newsTitleStyle(context);
            final longestTitle = items
                .map((item) => item.title)
                .reduce((a, b) => a.length >= b.length ? a : b);
            final minimumWidth = HomeV2LayoutPolicy.minimumReadableCardWidth(
              context,
              primaryTitle: longestTitle,
              titleStyle: titleStyle,
              horizontalPadding: 26.w,
              readableCharacters: 8,
            );
            return _HomeNewsPager(
              items: items,
              availableWidth: constraints.maxWidth,
              minimumReadableWidth: minimumWidth,
              onItemTap: onItemTap,
            );
          },
        ),
      ],
    );
  }
}

/// 保持新聞為可探索的水平 pager，並以目前頁與相鄰預覽的同步高度排版。
class _HomeNewsPager extends StatefulWidget {
  const _HomeNewsPager({
    required this.items,
    required this.availableWidth,
    required this.minimumReadableWidth,
    required this.onItemTap,
  });

  final List<HomeNewsItem> items;
  final double availableWidth;
  final double minimumReadableWidth;
  final ValueChanged<HomeNewsItem>? onItemTap;

  @override
  State<_HomeNewsPager> createState() => _HomeNewsPagerState();
}

class _HomeNewsPagerState extends State<_HomeNewsPager>
    with TickerProviderStateMixin {
  late PageController _controller;
  var _currentIndex = 0;
  late double _viewportFraction;

  @override
  void initState() {
    super.initState();
    _viewportFraction = _fractionFor(widget);
    _controller = PageController(viewportFraction: _viewportFraction);
  }

  @override
  void didUpdateWidget(covariant _HomeNewsPager oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextFraction = _fractionFor(widget);
    if ((nextFraction - _viewportFraction).abs() > .001) {
      final oldController = _controller;
      _viewportFraction = nextFraction;
      _controller = PageController(
        initialPage: _currentIndex.clamp(0, widget.items.length - 1),
        viewportFraction: _viewportFraction,
      );
      oldController.dispose();
    }
    if (_currentIndex >= widget.items.length) _currentIndex = 0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _fractionFor(_HomeNewsPager widget) {
    return HomeV2LayoutPolicy.carouselViewportFraction(
      availableWidth: widget.availableWidth,
      minimumReadableWidth: widget.minimumReadableWidth,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pageWidth = widget.availableWidth * _viewportFraction;
    final cardWidth = pageWidth - HomeNewsSection._itemGap.w;
    final mediaHeight = 92.h + context.adaptiveBuffer(10);
    // 台灣繁體中文教學註解：PageView 同時露出 active card 與相鄰預覽，
    // 所以只把這兩者納入同步量測；不以全清單最高卡片當共同高度，短卡
    // 仍會在切頁後自然縮短。
    final visibleMetricItems = <HomeNewsItem>[
      for (var index = math.max(0, _currentIndex - 1);
          index <= math.min(widget.items.length - 1, _currentIndex + 1);
          index++)
        widget.items[index],
    ];
    final metrics = _NewsCardLayoutMetrics.compute(
      context: context,
      items: visibleMetricItems,
      cardWidth: cardWidth,
      mediaHeight: mediaHeight,
    );

    // 台灣繁體中文教學註解：PageView 需要有界高度；只量測 active card
    // 與相鄰預覽，短新聞不會被全清單最長項目撐出大空白，也不需要
    // post-frame 量測迴圈。
    return AnimatedSize(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      child: SizedBox(
        height: metrics.height,
        child: PageView.builder(
          key: const ValueKey('home-news-horizontal-pager'),
          controller: _controller,
          padEnds: false,
          physics: const BouncingScrollPhysics(),
          itemCount: widget.items.length,
          onPageChanged: (index) => setState(() => _currentIndex = index),
          itemBuilder: (context, index) {
            final item = widget.items[index];
            return Padding(
              padding: EdgeInsets.only(right: HomeNewsSection._itemGap.w),
              child: _NewsCard(
                item: item,
                width: cardWidth,
                mediaHeight: mediaHeight,
                onTap: widget.onItemTap == null
                    ? null
                    : () => widget.onItemTap!(item),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// 新聞輪播需要 bounded height，這份純量測契約讓外層 ListView 與卡片文字
/// 使用同一個內容需求；不依裝置方向或固定文字倍率猜測高度。
class _NewsCardLayoutMetrics {
  const _NewsCardLayoutMetrics({required this.height});

  final double height;

  static _NewsCardLayoutMetrics compute({
    required BuildContext context,
    required List<HomeNewsItem> items,
    required double cardWidth,
    required double mediaHeight,
  }) {
    final tokens = _NewsCardLayoutTokens.of(context);
    final textWidth = tokens.titleWidthFor(cardWidth);
    final textStyle = _newsTitleStyle(context);
    final textScaler = MediaQuery.textScalerOf(context);
    var tallestTitle = 0.0;
    for (final item in items) {
      final painter = TextPainter(
        text: TextSpan(text: item.title, style: textStyle),
        textScaler: textScaler,
        textDirection: Directionality.of(context),
      )..layout(maxWidth: textWidth);
      tallestTitle =
          tallestTitle < painter.height ? painter.height : tallestTitle;
    }

    // 台灣繁體中文教學註解：TextPainter 與 render 共用同一份 inset，避免
    // 極大字體多換一行時少算高度，重現 320×568／300% 的底部 overflow。
    final contentHeight = tokens.contentHeightFor(
      mediaHeight: mediaHeight,
      titleHeight: tallestTitle,
    );
    final minimumHeight = mediaHeight + tokens.minimumHeight;
    return _NewsCardLayoutMetrics(
      height: minimumHeight < contentHeight ? contentHeight : minimumHeight,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.onMoreTap,
  });

  final String title;
  final VoidCallback? onMoreTap;

  @override
  Widget build(BuildContext context) {
    return HomeSectionTitle(
      title: title,
      onTap: onMoreTap,
    );
  }
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({
    required this.item,
    required this.width,
    required this.mediaHeight,
    this.onTap,
  });

  final HomeNewsItem item;
  final double width;
  final double mediaHeight;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // 標籤風格依新聞來源/分類切換，讓相同卡片結構仍有辨識度。
    final cardRadius = 21.r;
    final mediaRadius = 19.r;
    final badgeStyle = _NewsBadgeStyle.fromLabel(item.badge);
    final tokens = _NewsCardLayoutTokens.of(context);

    return SizedBox(
      width: width,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(cardRadius),
          child: Ink(
            padding: tokens.outerPadding,
            decoration: BoxDecoration(
              color: AppColors.newsSurface,
              borderRadius: BorderRadius.circular(cardRadius),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: mediaHeight,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: mediaHeight,
                        width: double.infinity,
                        margin: EdgeInsets.only(
                          top: 4.h,
                          left: 4.w,
                          right: 4.w,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.placeholder,
                          borderRadius: BorderRadius.circular(mediaRadius),
                        ),
                        child: Icon(
                          Icons.article_outlined,
                          color: Colors.white.withValues(alpha: 0.72),
                          size: 34.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: tokens.mediaToTitleGap),
                Padding(
                  padding: tokens.titlePadding,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      item.title,
                      style: _newsTitleStyle(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 新聞卡同步量測與實際渲染共用的 inset 契約。
///
/// 台灣繁體中文教學註解：量測端與畫面端若分別維護 padding，極大字體下只要
/// 少算一行就會造成 bounded pager 的 Column overflow，因此統一由此提供。
class _NewsCardLayoutTokens {
  const _NewsCardLayoutTokens._({
    required this.outerPadding,
    required this.titlePadding,
    required this.mediaToTitleGap,
    required this.minimumHeight,
  });

  final EdgeInsets outerPadding;
  final EdgeInsets titlePadding;
  final double mediaToTitleGap;
  final double minimumHeight;

  factory _NewsCardLayoutTokens.of(BuildContext context) {
    return _NewsCardLayoutTokens._(
      outerPadding: EdgeInsets.fromLTRB(7.w, 7.h, 7.w, 6.h),
      titlePadding: EdgeInsets.fromLTRB(6.w, 8.w, 6.w, 5.h),
      mediaToTitleGap: 2.h,
      minimumHeight: 74.h,
    );
  }

  double titleWidthFor(double cardWidth) => math.max(
        1,
        cardWidth - outerPadding.horizontal - titlePadding.horizontal,
      );

  double contentHeightFor({
    required double mediaHeight,
    required double titleHeight,
  }) {
    return outerPadding.top +
        mediaHeight +
        mediaToTitleGap +
        titlePadding.top +
        titleHeight +
        titlePadding.bottom +
        outerPadding.bottom;
  }
}

/// 新聞標題在量測與渲染時共用同一個已合併主題字型的 style。
///
/// 台灣繁體中文教學註解：Text 會繼承 DefaultTextStyle 的字型設定；若
/// TextPainter 未合併它，中文字型的字寬可能不同而少算一行。因此兩端都
/// 使用此函式，讓同步 pager 高度與真實 RenderParagraph 完全一致。
TextStyle _newsTitleStyle(BuildContext context) {
  return DefaultTextStyle.of(context).style.merge(
        TextStyle(
          fontSize: 15.sp,
          height: 1.05,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      );
}

class _NewsBadgeStyle {
  const _NewsBadgeStyle({
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.shadowColor,
  });

  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final Color shadowColor;

  factory _NewsBadgeStyle.fromLabel(String label) {
    // 目前以假資料標籤做切換，之後若接後端資料可改成列舉會更安全。
    switch (label) {
      case '快訊':
        return const _NewsBadgeStyle(
          backgroundColor: Color(0xFFFFF2EE),
          borderColor: Color(0xFFF4D9D0),
          textColor: Color(0xFF99513E),
          shadowColor: Color(0x26D99A89),
        );
      case '天氣':
        return const _NewsBadgeStyle(
          backgroundColor: Color(0xFFFFF8E8),
          borderColor: Color(0xFFF2E4B9),
          textColor: Color(0xFF907227),
          shadowColor: Color(0x26E0C978),
        );
      case '社會':
        return const _NewsBadgeStyle(
          backgroundColor: Color(0xFFF2F4F7),
          borderColor: Color(0xFFDCE3EA),
          textColor: Color(0xFF56697A),
          shadowColor: Color(0x26485E75),
        );
      default:
        return const _NewsBadgeStyle(
          backgroundColor: Color(0xFFF8F8F8),
          borderColor: Color(0xFFE4E4E4),
          textColor: Color(0xFF444444),
          shadowColor: Color(0x1A000000),
        );
    }
  }
}
