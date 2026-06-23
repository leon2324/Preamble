part of '../global_search_page.dart';

// 台灣繁體中文教學註解：
// 搜尋結果卡片集中在此檔，維持 prototype 原本的顏色、間距與互動動畫；
// 父層只傳入 _SearchResult 與 callback，因此不會影響搜尋資料來源或導頁判斷。

class _ResultSection extends StatelessWidget {
  const _ResultSection({
    required this.title,
    required this.items,
    required this.onOpen,
    required this.isSaved,
    required this.onSaved,
    this.isCarousel = false,
  });

  final String title;
  final List<_SearchResult> items;
  final ValueChanged<_SearchResult> onOpen;
  final bool Function(_SearchResult item) isSaved;
  final ValueChanged<_SearchResult> onSaved;
  final bool isCarousel;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    Widget itemsContent;
    if (isCarousel && items.length > 1) {
      itemsContent = SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        clipBehavior: Clip.none,
        child: Row(
          children: items.map((item) {
            return _ResultTile(
              item: item,
              onTap: () => onOpen(item),
              showBookmark: item.type != _ResultType.official,
              isSaved: isSaved(item),
              onBookmark: () => onSaved(item),
              isCarouselCard: true,
            );
          }).toList(),
        ),
      );
    } else {
      itemsContent = Column(
        mainAxisSize: MainAxisSize.min,
        children: items.map((item) {
          return Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: _ResultTile(
              item: item,
              onTap: () => onOpen(item),
              showBookmark: item.type != _ResultType.official,
              isSaved: isSaved(item),
              onBookmark: () => onSaved(item),
            ),
          );
        }).toList(),
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _SectionHeader(title: title),
          SizedBox(height: 8.h),
          itemsContent,
        ],
      ),
    );
  }
}

class _InteractiveCard extends StatefulWidget {
  const _InteractiveCard({
    required this.child,
    this.onTap,
    this.background = Colors.white,
    this.padding,
    this.borderColor,
    this.width = double.infinity,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color background;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;
  final double? width;

  @override
  State<_InteractiveCard> createState() => _InteractiveCardState();
}

class _InteractiveCardState extends State<_InteractiveCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.97,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnimation = _scaleController;
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      _scaleController.animateTo(0.97, curve: Curves.easeInOut);
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      _scaleController.animateTo(1.0, curve: Curves.easeInOut);
    }
  }

  void _handleTapCancel() {
    if (widget.onTap != null) {
      _scaleController.animateTo(1.0, curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderCol =
        (widget.borderColor ?? _SearchColors.border).withValues(alpha: 0.35);

    final card = Container(
      width: widget.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: _getAdaptiveShadowColor(widget.background),
            blurRadius: 12.r,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14.r),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: widget.padding ?? EdgeInsets.all(13.w),
            decoration: BoxDecoration(
              color: widget.background.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: borderCol, width: 0.8.w),
            ),
            child: widget.child,
          ),
        ),
      ),
    );

    if (widget.onTap == null) return card;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: card,
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({
    required this.item,
    required this.onTap,
    this.showBookmark = false,
    this.isSaved = false,
    this.onBookmark,
    this.isCarouselCard = false,
  });

  final _SearchResult item;
  final VoidCallback onTap;
  final bool showBookmark;
  final bool isSaved;
  final VoidCallback? onBookmark;
  final bool isCarouselCard;

  @override
  Widget build(BuildContext context) {
    // 依據不同的結果類別設計高級莫蘭迪色系與視覺細節
    Color cardBg;
    Color borderCol;
    Color iconColor;
    String badgeText;
    IconData typeIcon;
    String? svgPath;

    switch (item.type) {
      case _ResultType.statute:
        cardBg = const Color(0xFFEAF7F2); // 莫蘭迪薄荷綠
        borderCol = const Color(0xFFD0E6DC);
        iconColor = const Color(0xFF1E6D5A);
        badgeText = item.title.contains('刑法') ? '⚖️ 刑事法規' : '⚖️ 民事法規';
        typeIcon = Icons.menu_book_outlined;
        svgPath = 'assets/images/journal/book_icon.svg';
        break;
      case _ResultType.caseItem:
        cardBg = const Color(0xFFEBF2F7); // 莫蘭迪灰藍
        borderCol = const Color(0xFFD2DFE6);
        iconColor = const Color(0xFF4A7C9D);
        badgeText = '💼 實務裁判';
        typeIcon = Icons.gavel_outlined;
        svgPath = 'assets/images/journal/scale_icon.svg';
        break;
      case _ResultType.lifeNote:
        cardBg = const Color(0xFFFCF6EA); // 莫蘭迪柔沙暖黃
        borderCol = const Color(0xFFEFE2CB);
        iconColor = const Color(0xFFC69C55);
        badgeText = '💡 避坑指南';
        typeIcon = Icons.explore_outlined;
        svgPath = 'assets/images/search/search_plant.svg';
        break;
      case _ResultType.official:
        cardBg = const Color(0xFFEFF3F1); // 莫蘭迪茶綠
        borderCol = const Color(0xFFDCE4E1);
        iconColor = const Color(0xFF6B8A7E);
        badgeText = '🛡️ 官方認證';
        typeIcon = Icons.verified_user_outlined;
        svgPath = 'assets/images/search/search_clipboard.svg';
        break;
      case _ResultType.assistant:
        cardBg = const Color(0xFFF9F6F0);
        borderCol = const Color(0xFFEAE2D5);
        iconColor = const Color(0xFFE7B76D);
        badgeText = '🤖 AI 小法助';
        typeIcon = Icons.support_agent_rounded;
        svgPath = null;
        break;
    }

    final cardContent = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _IconBox(icon: typeIcon, color: iconColor, svgAsset: svgPath),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      badgeText,
                      style: _SearchText.captionStrong().copyWith(
                        color: iconColor,
                        fontSize: 9.5.sp,
                      ),
                    ),
                  ),
                  if (item.type == _ResultType.lifeNote)
                    Text(
                      '⏱️ 3分閱讀',
                      style: _SearchText.caption().copyWith(fontSize: 9.sp),
                    ),
                ],
              ),
              SizedBox(height: 7.h),
              Text(
                item.title,
                maxLines: isCarouselCard ? 1 : 2,
                overflow: TextOverflow.ellipsis,
                style: _SearchText.tileTitle().copyWith(
                  color: _SearchColors.text,
                  fontSize: 13.5.sp,
                ),
              ),
              SizedBox(height: 5.h),
              Text(
                item.summary,
                maxLines: isCarouselCard ? 2 : 3,
                overflow: TextOverflow.ellipsis,
                style: _SearchText.body().copyWith(
                  color: _SearchColors.mutedText,
                  height: 1.45,
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(
                    item.type == _ResultType.official
                        ? Icons.verified_outlined
                        : Icons.link_rounded,
                    size: 11.sp,
                    color: _SearchColors.mutedText.withValues(alpha: 0.7),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(
                      item.source,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _SearchText.caption().copyWith(
                        color: _SearchColors.mutedText.withValues(alpha: 0.8),
                        fontSize: 9.8.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (showBookmark)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onBookmark,
              borderRadius: BorderRadius.circular(999.r),
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Icon(
                  isSaved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: _SearchColors.primary,
                  size: 21.sp,
                ),
              ),
            ),
          )
        else if (item.type != _ResultType.official)
          Padding(
            padding: EdgeInsets.only(top: 2.h),
            child: Icon(
              Icons.chevron_right_rounded,
              color: _SearchColors.mutedText,
              size: 20.sp,
            ),
          ),
      ],
    );

    if (isCarouselCard) {
      return Container(
        width: 250.w,
        margin: EdgeInsets.only(right: 12.w),
        child: _InteractiveCard(
          onTap: onTap,
          background: cardBg,
          borderColor: borderCol,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          width: null,
          child: cardContent,
        ),
      );
    }

    return _InteractiveCard(
      onTap: onTap,
      background: cardBg,
      borderColor: borderCol,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
      child: cardContent,
    );
  }
}

class _LifeCard extends StatelessWidget {
  const _LifeCard({required this.item, required this.onTap});

  final _SearchResult item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _ProtoCard(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: _SearchText.tileTitle()),
                SizedBox(height: 6.h),
                Text(item.summary, style: _SearchText.body()),
                SizedBox(height: 6.h),
                Text('小法助・3 分鐘閱讀', style: _SearchText.caption()),
              ],
            ),
          ),
          SvgPicture.asset(_SearchAsset.clipboard, width: 74.w, height: 74.w),
        ],
      ),
    );
  }
}

Color _getAdaptiveShadowColor(Color background) {
  final val = background.toARGB32();
  if (val == 0xFFEAF7F2) return const Color(0x081E6D5A);
  if (val == 0xFFEBF2F7) return const Color(0x084A7C9D);
  if (val == 0xFFFCF6EA) return const Color(0x08C69C55);
  if (val == 0xFFEFF3F1) return const Color(0x086B8A7E);
  if (val == 0xFFFAF7F2 || val == 0xFFF9F6F0) return const Color(0x081E6D5A);
  if (val == 0xFFE8F1EC || val == 0xFFD6E6DE) return const Color(0x082E5E4E);
  if (val == 0xFFF7EFE5 || val == 0xFFECDDC5) return const Color(0x087A583A);
  if (val == 0xFFECF0F7 || val == 0xFFD3DFEF) return const Color(0x0838527A);
  return const Color(0x0A2E3D34);
}
