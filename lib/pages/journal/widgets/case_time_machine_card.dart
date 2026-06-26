import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lawapp/features/case_time_machine/data/case_time_machine_mock_data.dart';
import 'package:lawapp/features/case_time_machine/pages/case_time_machine_entry_page.dart';
import 'package:lawapp/pages/journal/widgets/journal_palette.dart';

class CaseTimeMachineCard extends StatelessWidget {
  const CaseTimeMachineCard({super.key, required this.palette});

  final JournalPalette palette;
  static const _imageAspectRatio = 1.0;
  static const _posterFontFamily = 'Songti TC';
  static const _posterFallbacks = ['Songti SC', 'STSong', 'PingFang TC'];

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: const TextScaler.linear(1.0)),
      child: AspectRatio(
        aspectRatio: _imageAspectRatio,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18.r),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;

              // 這張卡是接近海報式的視覺稿，所以不用一般 Column 平均排版，
              // 而是改用相對座標去對齊標題、圖騰、副標和按鈕位置，
              // 之後若要微調只要改各個 fraction，不必回去動圖檔。
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    caseTimeMachineV2BackgroundAsset,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.48),
                          Colors.black.withValues(alpha: 0.18),
                          Colors.transparent,
                        ],
                        stops: const [0, 0.3, 0.7],
                      ),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18.r),
                      border: Border.all(
                        color: const Color(0xFFD0AC68).withValues(alpha: 0.8),
                        width: 1.15,
                      ),
                    ),
                  ),
                  Positioned(
                    top: height * 0.09,
                    left: width * 0.26,
                    right: width * 0.26,
                    child: SvgPicture.asset(
                      'assets/images/journal/library_motif_yellow.svg',
                      height: height * 0.06,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Positioned(
                    top: height * 0.145,
                    left: width * 0.08,
                    right: width * 0.08,
                    child: _GradientPosterText(
                      text: '案件圖書館',
                      fontSize: width * 0.128,
                      letterSpacing: width * 0.006,
                    ),
                  ),
                  Positioned(
                    top: height * 0.265,
                    left: width * 0.23,
                    right: width * 0.23,
                    child: SvgPicture.asset(
                      'assets/images/journal/library_motif_yellow.svg',
                      height: height * 0.052,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Positioned(
                    top: height * 0.36,
                    left: width * 0.14,
                    right: width * 0.14,
                    child: Column(
                      children: [
                        _PosterBodyLine(
                          text: '走進案件圖書館',
                          fontSize: width * 0.05,
                        ),
                        SizedBox(height: height * 0.018),
                        _PosterBodyLine(
                          text: '回到那些曾經震動社會的案件現場',
                          fontSize: width * 0.043,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: width * 0.26,
                    right: width * 0.26,
                    bottom: height * 0.1,
                    height: height * 0.09,
                    child: _ArchiveEntryButton(
                      onTap: () => Navigator.of(context).push(
                        CupertinoPageRoute<void>(
                          builder: (__) => const CaseTimeMachineEntryPage(),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _GradientPosterText extends StatelessWidget {
  const _GradientPosterText({
    required this.text,
    required this.fontSize,
    required this.letterSpacing,
  });

  final String text;
  final double fontSize;
  final double letterSpacing;

  @override
  Widget build(BuildContext context) {
    final textWidget = Text(
      text,
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.visible,
      style: TextStyle(
        fontFamily: CaseTimeMachineCard._posterFontFamily,
        fontFamilyFallback: CaseTimeMachineCard._posterFallbacks,
        fontSize: fontSize,
        height: 1.04,
        fontWeight: FontWeight.w700,
        letterSpacing: letterSpacing,
        foreground: (Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFE9B5),
              Color(0xFFF0CD86),
              Color(0xFFC89443),
            ],
          ).createShader(const Rect.fromLTWH(0, 0, 800, 180))
          ..style = PaintingStyle.fill),
        shadows: [
          Shadow(
            color: Colors.black.withValues(alpha: 0.32),
            offset: const Offset(0, 3),
            blurRadius: 10,
          ),
        ],
      ),
    );

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: textWidget,
    );
  }
}

class _PosterBodyLine extends StatelessWidget {
  const _PosterBodyLine({
    required this.text,
    required this.fontSize,
  });

  final String text;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontFamily: CaseTimeMachineCard._posterFontFamily,
        fontFamilyFallback: CaseTimeMachineCard._posterFallbacks,
        fontSize: fontSize,
        height: 1.15,
        fontWeight: FontWeight.w700,
        letterSpacing: fontSize * 0.08,
        color: const Color(0xFFF4F1EA),
        shadows: [
          Shadow(
            color: Colors.black.withValues(alpha: 0.35),
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
    );
  }
}

class _ArchiveEntryButton extends StatelessWidget {
  const _ArchiveEntryButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '進入案件圖書館',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18.r),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(
                color: const Color(0xFFD1A95C).withValues(alpha: 0.88),
                width: 1.25,
              ),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1C4A3F),
                  Color(0xFF0F2E28),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.16),
                  blurRadius: 12,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18.r),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.topCenter,
                        radius: 1.2,
                        colors: [
                          const Color(0xFF79D8CF).withValues(alpha: .22),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 0.2, sigmaY: 0.2),
                    child: const SizedBox.expand(),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '進入案件圖書館',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: CaseTimeMachineCard._posterFontFamily,
                              fontFamilyFallback:
                                  CaseTimeMachineCard._posterFallbacks,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2.4,
                              color: const Color(0xFFF0CD86),
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.22),
                                  offset: const Offset(0, 2),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Icon(
                          CupertinoIcons.arrow_right,
                          size: 21.sp,
                          color: const Color(0xFFF0CD86),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
