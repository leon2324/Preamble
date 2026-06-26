import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/features/case_time_machine/models/case_time_machine_models.dart';
import 'package:preamble/features/case_time_machine/pages/case_judge_practice_page.dart';
import 'package:preamble/features/case_time_machine/pages/case_legal_vocabulary_page.dart';
import 'package:preamble/features/case_time_machine/pages/case_opinion_spectrum_page.dart';
import 'package:preamble/features/case_time_machine/pages/case_witness_cross_page.dart';
import 'package:preamble/features/case_time_machine/pages/case_social_graph_page.dart';
import 'package:preamble/features/case_time_machine/pages/case_opinion_board_page.dart';
import 'package:preamble/features/case_time_machine/widgets/case_library_section_header.dart';
import 'package:preamble/features/case_time_machine/widgets/case_time_machine_svg_icon.dart';

// 現代清新的「思辨與探索專區」2x3 宮格元件。使用圓角卡片與淡淡的莫蘭迪主題色底色，
// 移除時間軸入口（已搬至詳細Tab），加入虛擬詰問室、社會效應圖譜與意見塗鴉牆。
class CaseLibraryInteractiveGrid extends StatelessWidget {
  const CaseLibraryInteractiveGrid({
    super.key,
    required this.selectedCase,
    required this.onSearchTap,
  });

  final CaseBook selectedCase;
  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CaseLibrarySectionHeader(
          title: '思辨與探索專區',
          actionText: '查找卷宗',
          onActionTap: onSearchTap,
        ),
        SizedBox(height: 9.h),
        _FeatureShowcaseGrid(
          shortcuts: [
            // Row 1: 理性與法理
            _FeatureShortcut(
              iconSvg: CtmSvgIcons.scale,
              title: '如果你是法官',
              subtitle: '模擬司法天平裁判',
              backgroundColor: const Color(0xFFEAF6EF), // 莫蘭迪綠
              foregroundColor: const Color(0xFF357A53),
              onTap: () {
                Navigator.of(context).push(
                  CupertinoPageRoute<void>(
                    builder: (__) => CaseJudgePracticePage(book: selectedCase),
                  ),
                );
              },
            ),
            _FeatureShortcut(
              iconSvg: CtmSvgIcons.sparkles,
              title: '觀點光譜',
              subtitle: '透視各界爭議光譜',
              backgroundColor: const Color(0xFFF0EEF9), // 莫蘭迪紫
              foregroundColor: const Color(0xFF6D649A),
              onTap: () {
                Navigator.of(context).push(
                  CupertinoPageRoute<void>(
                    builder: (__) =>
                        CaseOpinionSpectrumPage(book: selectedCase),
                  ),
                );
              },
            ),
            // Row 2: 攻防與釋義
            _FeatureShortcut(
              iconSvg: CtmSvgIcons.message, // 對答圖示
              title: '虛擬詰問室',
              subtitle: 'AI詰問關係人證詞',
              backgroundColor: const Color(0xFFEAF4F7), // 莫蘭迪藍
              foregroundColor: const Color(0xFF4A7C8C),
              onTap: () {
                Navigator.of(context).push(
                  CupertinoPageRoute<void>(
                    builder: (__) => CaseWitnessCrossPage(book: selectedCase),
                  ),
                );
              },
            ),
            _FeatureShortcut(
              iconSvg: CtmSvgIcons.bookOpen,
              title: '法律詞卡',
              subtitle: '翻閱基礎法律釋義',
              backgroundColor: const Color(0xFFFFF2CF), // 莫蘭迪黃
              foregroundColor: const Color(0xFF9E7B2D),
              onTap: () {
                Navigator.of(context).push(
                  CupertinoPageRoute<void>(
                    builder: (__) => const CaseLegalVocabularyPage(),
                  ),
                );
              },
            ),
            // Row 3: 效應與輿情
            _FeatureShortcut(
              iconSvg: CtmSvgIcons.brain, // 連鎖效應圖示
              title: '社會效應圖譜',
              subtitle: '探索本案社會變革',
              backgroundColor: const Color(0xFFFAF7F0), // 莫蘭迪灰
              foregroundColor: const Color(0xFF8B928D),
              onTap: () {
                Navigator.of(context).push(
                  CupertinoPageRoute<void>(
                    builder: (__) => CaseSocialGraphPage(book: selectedCase),
                  ),
                );
              },
            ),
            _FeatureShortcut(
              iconSvg: CtmSvgIcons.filePen, // 塗鴉鉛筆圖示
              title: '意見塗鴉牆',
              subtitle: '發表你的理性見解',
              backgroundColor: const Color(0xFFFDECEE), // 莫蘭迪紅
              foregroundColor: const Color(0xFFCD5C5C),
              onTap: () {
                Navigator.of(context).push(
                  CupertinoPageRoute<void>(
                    builder: (__) => CaseOpinionBoardPage(book: selectedCase),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _FeatureShowcaseGrid extends StatelessWidget {
  const _FeatureShowcaseGrid({required this.shortcuts});

  final List<_FeatureShortcut> shortcuts;

  @override
  Widget build(BuildContext context) {
    // 2x3 佈局，每排兩張卡片，共三排
    final firstRow = shortcuts.take(2).toList();
    final secondRow = shortcuts.skip(2).take(2).toList();
    final thirdRow = shortcuts.skip(4).take(2).toList();

    return Column(
      children: [
        _FeatureRow(shortcuts: firstRow),
        SizedBox(height: 8.h),
        _FeatureRow(shortcuts: secondRow),
        SizedBox(height: 8.h),
        _FeatureRow(shortcuts: thirdRow),
      ],
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.shortcuts});

  final List<_FeatureShortcut> shortcuts;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final entry in shortcuts.indexed) ...[
          Expanded(child: _FeatureTile(shortcut: entry.$2)),
          if (entry.$1 != shortcuts.length - 1) SizedBox(width: 8.w),
        ],
      ],
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({required this.shortcut});

  final _FeatureShortcut shortcut;

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final double iconSize = isLandscape ? 15.sp : 21.sp;
    final double titleSize = isLandscape ? 10.5.sp : 12.5.sp;
    final double subtitleSize = isLandscape ? 8.5.sp : 9.8.sp;

    return GestureDetector(
      onTap: shortcut.onTap,
      child: Container(
        height: (88.w).clamp(88.0, 150.0),
        padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 8.h),
        decoration: BoxDecoration(
          color: shortcut.backgroundColor,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: shortcut.foregroundColor.withValues(alpha: 0.12),
            width: 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.65),
                shape: BoxShape.circle,
              ),
              child: CtmSvgIcon(
                shortcut.iconSvg,
                size: iconSize,
                color: shortcut.foregroundColor,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shortcut.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w900,
                    color: shortcut.foregroundColor,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  shortcut.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: subtitleSize,
                    fontWeight: FontWeight.w700,
                    color: shortcut.foregroundColor.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureShortcut {
  const _FeatureShortcut({
    required this.iconSvg,
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onTap,
  });

  final String iconSvg;
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onTap;
}
