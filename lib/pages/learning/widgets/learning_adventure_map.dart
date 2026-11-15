import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:preamble/data/mock_data/learning/learning_mock_data.dart';
import 'package:preamble/theme/preamble_tokens.dart';

/// 雙重編碼（Dual-Coding）法學修煉節點闖關地圖（Duolingo / Brilliant 風格）
///
/// 將枯燥的單向條列課程轉化為空間感與進度感兼具的 S 型修煉路徑，
/// 並在章節尾端配置「BOSS 關卡：模擬法官終極挑戰」節點。
class LearningAdventureMap extends StatelessWidget {
  const LearningAdventureMap({
    super.key,
    required this.topicTitle,
    required this.units,
    required this.completedSteps,
    required this.onUnitTap,
    required this.onBossChallengeTap,
  });

  final String topicTitle;
  final List<LearningTopicUnit> units;
  final Set<String> completedSteps;
  final ValueChanged<LearningTopicUnit> onUnitTap;
  final VoidCallback onBossChallengeTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final nextIndex = units.indexWhere(
      (unit) => !completedSteps.contains('${topicTitle}_${unit.stepLabel}'),
    );
    final allCompleted = nextIndex == -1 && units.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int index = 0; index < units.length; index++)
          _AdventureNodeRow(
            index: index,
            unit: units[index],
            isDone: completedSteps.contains(
              '${topicTitle}_${units[index].stepLabel}',
            ),
            isNext: index == nextIndex,
            isLastUnit: index == units.length - 1,
            onTap: () => onUnitTap(units[index]),
          ),
        SizedBox(height: 6.h),
        _BossChallengeNodeCard(
          isUnlocked: allCompleted || completedSteps.isNotEmpty,
          allCompleted: allCompleted,
          onTap: onBossChallengeTap,
          tokens: t,
        ),
      ],
    );
  }
}

class _AdventureNodeRow extends StatelessWidget {
  const _AdventureNodeRow({
    required this.index,
    required this.unit,
    required this.isDone,
    required this.isNext,
    required this.isLastUnit,
    required this.onTap,
  });

  final int index;
  final LearningTopicUnit unit;
  final bool isDone;
  final bool isNext;
  final bool isLastUnit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final activeColor = isDone
        ? t.brandPrimary
        : isNext
            ? t.accentBrass
            : t.textMuted;

    // 輕微交錯縮排營造 S-Curve 修煉小徑空間感，同時確保 320px 窄螢幕安全
    final double leftIndent = (index.isOdd ? 8.w : 0.0);

    return Padding(
      padding: EdgeInsets.only(left: leftIndent),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 34.w,
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      width: isNext ? 30.w : 26.w,
                      height: isNext ? 30.w : 26.w,
                      decoration: BoxDecoration(
                        color: isDone
                            ? t.brandPrimary
                            : isNext
                                ? t.accentBrassContainer
                                : t.surfaceSubtle,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: activeColor,
                          width: isNext ? 2.w : 1.4.w,
                        ),
                        boxShadow: isNext
                            ? [
                                BoxShadow(
                                  color: t.accentBrass.withValues(alpha: 0.25),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: isDone
                            ? Icon(
                                PhosphorIconsFill.checkCircle,
                                size: 15.sp,
                                color: Colors.white,
                              )
                            : isNext
                                ? Icon(
                                    PhosphorIconsFill.sparkle,
                                    size: 14.sp,
                                    color: t.accentBrass,
                                  )
                                : Text(
                                    '${index + 1}',
                                    style: t.tabularMetric(
                                      size: 11.sp,
                                      weight: FontWeight.w800,
                                      color: t.textSecondary,
                                    ),
                                  ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        width: 2.w,
                        margin: EdgeInsets.symmetric(vertical: 3.h),
                        decoration: BoxDecoration(
                          color: isDone
                              ? t.brandPrimary.withValues(alpha: 0.45)
                              : t.border,
                          borderRadius: BorderRadius.circular(99.r),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(bottom: 10.h),
                  padding: EdgeInsets.all(11.w),
                  decoration: BoxDecoration(
                    color: isNext
                        ? t.accentBrassContainer.withValues(alpha: 0.38)
                        : t.surface,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isNext
                          ? t.accentBrass.withValues(alpha: 0.65)
                          : isDone
                              ? t.brandPrimary.withValues(alpha: 0.35)
                              : t.border,
                      width: isNext ? 1.4.w : 1.w,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 6.w,
                        runSpacing: 4.h,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: isDone
                                  ? t.brandContainer
                                  : isNext
                                      ? t.accentBrassContainer
                                      : t.surfaceSubtle,
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              unit.stepLabel,
                              style: t.tabularMetric(
                                size: 11.sp,
                                weight: FontWeight.w800,
                                color: activeColor,
                              ),
                            ),
                          ),
                          if (isNext)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: t.accentBrass,
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                '當前關卡',
                                style: t.sansBody(
                                  size: 11.sp,
                                  weight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          Text(
                            unit.readTime,
                            style: t.tabularMetric(
                              size: 11.sp,
                              weight: FontWeight.w600,
                              color: t.textMuted,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${unit.stepLabel}：${unit.title}',
                              style: t.serifTitle(
                                size: 13.5.sp,
                                weight: FontWeight.w700,
                                color: t.textPrimary,
                              ),
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Icon(
                            PhosphorIconsRegular.caretRight,
                            size: 14.sp,
                            color: activeColor,
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        unit.goal,
                        style: t.sansBody(
                          size: 11.5.sp,
                          color: t.textSecondary,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BossChallengeNodeCard extends StatelessWidget {
  const _BossChallengeNodeCard({
    required this.isUnlocked,
    required this.allCompleted,
    required this.onTap,
    required this.tokens,
  });

  final bool isUnlocked;
  final bool allCompleted;
  final VoidCallback onTap;
  final PreambleTokens tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              t.brandPrimary.withValues(alpha: t.isDark ? 0.32 : 0.09),
              t.accentBrassContainer.withValues(alpha: t.isDark ? 0.25 : 0.45),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: allCompleted
                ? t.accentBrass
                : t.brandPrimary.withValues(alpha: 0.35),
            width: 1.3.w,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                color: allCompleted ? t.accentBrass : t.brandPrimary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  PhosphorIconsFill.gavel,
                  size: 18.sp,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 6.w,
                    runSpacing: 4.h,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: t.accentBrass,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          'BOSS 關卡',
                          style: t.tabularMetric(
                            size: 11.sp,
                            weight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Text(
                        allCompleted ? '全章節通關・終極審判解鎖' : '模擬法庭實戰驗收',
                        style: t.sansBody(
                          size: 11.sp,
                          weight: FontWeight.w700,
                          color: t.accentBrass,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '模擬法官終極挑戰：坐上審判席裁決真實爭點',
                    style: t.serifTitle(
                      size: 13.sp,
                      weight: FontWeight.w700,
                      color: t.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 6.w),
            Icon(
              PhosphorIconsRegular.arrowRight,
              size: 16.sp,
              color: t.brandPrimary,
            ),
          ],
        ),
      ),
    );
  }
}
