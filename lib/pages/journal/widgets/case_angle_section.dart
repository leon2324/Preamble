import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lawapp/pages/journal/data/journal_page_items.dart';
import 'package:lawapp/pages/journal/widgets/journal_palette.dart';

const _caseAngleCardRadius = 18.0;

class CaseAngleSection extends StatelessWidget {
  const CaseAngleSection({super.key, required this.palette});

  final JournalPalette palette;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CaseAngleTitle(palette: palette),
        SizedBox(height: 14.h),
        LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 10.0;
            const minWideTileSize = 72.0;
            final textScale = MediaQuery.textScalerOf(context).scale(1);
            final useTwoByTwoForLargeText = textScale > 1.08;
            final useFourColumns = !useTwoByTwoForLargeText &&
                constraints.maxWidth >= (minWideTileSize * 4) + (spacing * 3);
            final columnCount = useFourColumns ? 4 : 2;
            final tileSize =
                (constraints.maxWidth - (spacing * (columnCount - 1))) /
                    columnCount;

            // 台灣繁體中文教學註解：
            // 這一區刻意改成正方形卡片，讓四張紙質底圖在不同螢幕下都能維持一致比例。
            // 版寬夠時直接四欄橫排，不夠時退成 2x2；另外若使用者把系統字體放大，
            // 也優先改成 2x2，避免四欄卡片的可用寬度太窄而把標題與副標擠爆。
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: caseAngleItems
                  .map(
                    (item) => SizedBox(
                      width: tileSize,
                      height: tileSize,
                      child: _CaseAngleCard(item: item),
                    ),
                  )
                  .toList(growable: false),
            );
          },
        ),
      ],
    );
  }
}

class _CaseAngleTitle extends StatelessWidget {
  const _CaseAngleTitle({required this.palette});

  final JournalPalette palette;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '從哪種案件開始？',
          style: TextStyle(
            fontSize: 19.sp,
            height: 1.05,
            fontWeight: FontWeight.w900,
            color: palette.primaryText,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

class _CaseAngleCard extends StatelessWidget {
  const _CaseAngleCard({required this.item});

  final CaseAngleItem item;

  @override
  Widget build(BuildContext context) {
    final cappedScale = MediaQuery.textScalerOf(context).scale(1).clamp(
          1.0,
          1.02,
        );

    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(cappedScale)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_caseAngleCardRadius.r),
        child: Material(
          color: Colors.transparent,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _CaseAngleBackground(assetPath: item.backgroundAssetPath),
              _CaseAngleContent(item: item),
              Positioned.fill(
                child: InkWell(
                  onTap: () {},
                  splashColor: Colors.white.withValues(alpha: 0.08),
                  highlightColor: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CaseAngleBackground extends StatelessWidget {
  const _CaseAngleBackground({required this.assetPath});

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.high,
      errorBuilder: (context, error, stackTrace) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFFD4C1A0),
            borderRadius: BorderRadius.circular(_caseAngleCardRadius.r),
          ),
        );
      },
    );
  }
}

class _CaseAngleContent extends StatelessWidget {
  const _CaseAngleContent({required this.item});

  final CaseAngleItem item;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        final useCompactContent = textScale > 1.08;
        final iconSize =
            constraints.maxWidth * (useCompactContent ? 0.27 : 0.31);
        final titleSize =
            constraints.maxWidth * (useCompactContent ? 0.118 : 0.14);
        final descriptionSize =
            constraints.maxWidth * (useCompactContent ? 0.068 : 0.088);
        final sidePadding =
            constraints.maxWidth * (useCompactContent ? 0.07 : 0.08);
        final verticalPadding =
            constraints.maxHeight * (useCompactContent ? 0.09 : 0.12);

        // 台灣繁體中文教學註解：
        // 第二層只負責 icon 與文案排版，不混進點擊處理，
        // 這樣之後若要換成不同導頁邏輯，只要改最上層 InkWell 即可。
        // 另外這裡會偵測較大的系統字級，主動縮一點 icon、字級與內距，
        // 避免 2x2 卡片在 iPhone 大字模式下仍然因高度不足而 overflow。
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: sidePadding,
            vertical: verticalPadding,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: iconSize,
                height: iconSize,
                child: Center(
                  child: Transform.scale(
                    scale: item.iconScale,
                    child: SvgPicture.asset(
                      item.assetPath,
                      width: iconSize,
                      height: iconSize,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFFF8EDD1),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                  height: constraints.maxHeight *
                      (useCompactContent ? 0.055 : 0.08)),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: titleSize.sp,
                  height: 1.1,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFF7E9CB),
                  shadows: const [
                    Shadow(
                      color: Color(0x33000000),
                      offset: Offset(0, 1),
                      blurRadius: 3,
                    ),
                  ],
                ),
              ),
              SizedBox(height: constraints.maxHeight * 0.02),
              Text(
                item.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: descriptionSize.sp,
                  height: 1.25,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFF4E7C6),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
