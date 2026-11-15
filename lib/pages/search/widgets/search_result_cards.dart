part of '../global_search_page.dart';

// 雙重編碼檢索結果卡片（無 BackdropFilter GPU 疊加模糊，維持 120fps 順滑滾動）。
// - 法規與裁判案卷：採用宋體（SourceHanSerifTW）呈現條文與判決原文權威語氣。
// - 避坑實務與法務動態：採用黑體（Inter + SourceHanSansTW）呈現白話行動語氣。

class _ResultSection extends StatelessWidget {
  const _ResultSection({
    required this.title,
    required this.items,
    required this.onOpen,
    required this.isSaved,
    required this.onSaved,
    this.isCarousel = false,
    this.onMore,
  });

  final String title;
  final List<_SearchResult> items;
  final ValueChanged<_SearchResult> onOpen;
  final bool Function(_SearchResult item) isSaved;
  final ValueChanged<_SearchResult> onSaved;
  final bool isCarousel;
  final VoidCallback? onMore;

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
          crossAxisAlignment: CrossAxisAlignment.start,
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
          _SectionHeader(
            title: title,
            action: onMore != null ? '查看全部' : null,
            onAction: onMore,
          ),
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
    this.background,
    this.padding,
    this.borderColor,
    this.width = double.infinity,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color? background;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;
  final double? width;

  @override
  State<_InteractiveCard> createState() => _InteractiveCardState();
}

class _InteractiveCardState extends State<_InteractiveCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.98,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      _scaleController.animateTo(0.98, curve: Curves.easeOut);
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      _scaleController.animateTo(1.0, curve: Curves.easeOut);
    }
  }

  void _handleTapCancel() {
    if (widget.onTap != null) {
      _scaleController.animateTo(1.0, curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final card = Container(
      width: widget.width,
      padding: widget.padding ?? EdgeInsets.all(14.w),
      decoration: t.cardDecoration(
        radius: 16.r,
        fill: widget.background ?? t.surface,
        borderColor: widget.borderColor ?? t.border,
      ),
      child: widget.child,
    );

    if (widget.onTap == null) return card;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleController,
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
    final t = context.tokens;
    late final Color accentColor;
    late final Color badgeBg;
    late final Color badgeFg;
    late final String badgeText;
    late final IconData typeIcon;
    late final bool useAuthoritativeSerif;

    switch (item.type) {
      case _ResultType.statute:
        accentColor = t.brandPrimary;
        badgeBg = t.brandContainer;
        badgeFg = t.brandOnContainer;
        badgeText = item.title.contains('刑法')
            ? '刑事法規'
            : (item.title.contains('勞') ? '勞動法規' : '現行法規');
        typeIcon = PhosphorIconsRegular.bookBookmark;
        useAuthoritativeSerif = true;
      case _ResultType.caseItem:
        accentColor = t.semanticInfo;
        badgeBg = t.semanticInfoContainer;
        badgeFg = t.semanticInfo;
        badgeText = '裁判案卷';
        typeIcon = PhosphorIconsRegular.gavel;
        useAuthoritativeSerif = true;
      case _ResultType.lifeNote:
        accentColor = t.accentBrass;
        badgeBg = t.accentBrassContainer;
        badgeFg = t.accentOnBrassContainer;
        badgeText = '避坑實務';
        typeIcon = PhosphorIconsRegular.lightbulbFilament;
        useAuthoritativeSerif = false;
      case _ResultType.official:
        accentColor = t.semanticSuccess;
        badgeBg = t.semanticSuccessContainer;
        badgeFg = t.semanticSuccess;
        badgeText = '法務動態';
        typeIcon = PhosphorIconsRegular.sealCheck;
        useAuthoritativeSerif = false;
      case _ResultType.assistant:
        accentColor = t.brandPrimary;
        badgeBg = t.brandContainer;
        badgeFg = t.brandOnContainer;
        badgeText = 'AI 問診';
        typeIcon = PhosphorIconsRegular.chatsCircle;
        useAuthoritativeSerif = false;
    }

    final cardContent = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _IconBox(
          icon: typeIcon,
          color: accentColor,
          backgroundColor: badgeBg,
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: 8.w,
                runSpacing: 4.h,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      badgeText,
                      style: _SearchText.captionStrong(context).copyWith(
                        color: badgeFg,
                        fontSize: 11.sp,
                      ),
                    ),
                  ),
                  if (item.type == _ResultType.lifeNote)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          PhosphorIconsRegular.clock,
                          size: 12.sp,
                          color: t.textMuted,
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          '3 分鐘實務',
                          style: _SearchText.caption(context),
                        ),
                      ],
                    ),
                ],
              ),
              SizedBox(height: 7.h),
              Text(
                item.title,
                maxLines: isCarouselCard ? 2 : 2,
                overflow: TextOverflow.ellipsis,
                style: useAuthoritativeSerif
                    ? _SearchText.serifTileTitle(context)
                    : _SearchText.tileTitle(context),
              ),
              SizedBox(height: 5.h),
              Text(
                item.summary,
                maxLines: isCarouselCard ? 2 : 3,
                overflow: TextOverflow.ellipsis,
                style: useAuthoritativeSerif
                    ? _SearchText.serifBody(context).copyWith(
                        fontSize: 13.sp,
                        color: t.textSecondary,
                        height: 1.55,
                      )
                    : _SearchText.body(context),
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(
                    item.type == _ResultType.official
                        ? PhosphorIconsRegular.arrowSquareOut
                        : PhosphorIconsRegular.link,
                    size: 12.sp,
                    color: t.textMuted,
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(
                      item.source,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _SearchText.caption(context),
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
                padding: EdgeInsets.all(5.r),
                child: Icon(
                  isSaved
                      ? PhosphorIconsFill.bookmarkSimple
                      : PhosphorIconsRegular.bookmarkSimple,
                  color: isSaved ? t.accentBrass : t.textMuted,
                  size: 19.sp,
                ),
              ),
            ),
          )
        else if (item.type == _ResultType.official)
          Padding(
            padding: EdgeInsets.only(top: 2.h, left: 4.w),
            child: Icon(
              PhosphorIconsRegular.arrowUpRight,
              color: t.textMuted,
              size: 16.sp,
            ),
          )
        else
          Padding(
            padding: EdgeInsets.only(top: 2.h, left: 4.w),
            child: Icon(
              PhosphorIconsRegular.caretRight,
              color: t.textMuted,
              size: 16.sp,
            ),
          ),
      ],
    );

    if (isCarouselCard) {
      final screenWidth = MediaQuery.sizeOf(context).width;
      final cardWidth = (screenWidth * 0.78).clamp(220.0, 290.0);
      return Container(
        width: cardWidth,
        margin: EdgeInsets.only(right: 12.w),
        child: _InteractiveCard(
          onTap: onTap,
          width: null,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
          child: cardContent,
        ),
      );
    }

    return _InteractiveCard(
      onTap: onTap,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
      child: cardContent,
    );
  }
}

class _LifeCard extends StatelessWidget {
  const _LifeCard({
    required this.item,
    required this.onTap,
  });

  final _SearchResult item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return _ProtoCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _IconBox(
            icon: PhosphorIconsRegular.lightbulbFilament,
            color: t.accentOnBrassContainer,
            backgroundColor: t.accentBrassContainer,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: _SearchText.tileTitle(context)),
                SizedBox(height: 5.h),
                Text(item.summary, style: _SearchText.body(context)),
                SizedBox(height: 6.h),
                Text(
                  item.source.isNotEmpty ? item.source : '緒言避坑實務・3 分鐘閱讀',
                  style: _SearchText.caption(context),
                ),
              ],
            ),
          ),
          Icon(
            PhosphorIconsRegular.caretRight,
            size: 16.sp,
            color: t.textMuted,
          ),
        ],
      ),
    );
  }
}
