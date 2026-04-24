import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/data/mock_data/home/home_v2_mock_data.dart';
import 'package:lawapp/theme/app_colors.dart';

/// 首頁小任務延伸出的完整測驗頁。
///
/// 台灣繁體中文教學註解：
/// 這裡使用卡牌堆疊的互動節奏：左右滑動會把頂層卡抽走換下一題，
/// 點選答案後則翻到背面顯示解析。首頁負責引導，深入體驗集中在這裡。
class HomeMissionQuizPage extends StatefulWidget {
  const HomeMissionQuizPage({super.key});

  @override
  State<HomeMissionQuizPage> createState() => _HomeMissionQuizPageState();
}

class _HomeMissionQuizPageState extends State<HomeMissionQuizPage> {
  final Map<int, int> _selectedByIndex = <int, int>{};
  final Set<int> _revealedIndices = <int>{};
  double _dragDx = 0;
  bool _animatingOut = false;
  bool _animatingBackToCenter = false;
  int _currentIndex = 0;

  int get _totalCount => homeV2MissionItems.length;

  void _selectAnswer(int answerIndex) {
    if (_revealedIndices.contains(_currentIndex)) return;

    setState(() {
      _selectedByIndex[_currentIndex] = answerIndex;
      _revealedIndices.add(_currentIndex);
    });
  }

  void _handleHorizontalDragUpdate(DragUpdateDetails details) {
    if (_animatingOut) return;
    setState(() {
      _animatingBackToCenter = false;
      _dragDx += details.delta.dx;
    });
  }

  void _handleHorizontalDragEnd(DragEndDetails details) {
    if (_animatingOut) return;

    final velocity = details.primaryVelocity ?? 0;
    final shouldAdvance = _dragDx.abs() > 80.w || velocity.abs() > 700;

    if (!shouldAdvance) {
      setState(() {
        _animatingBackToCenter = true;
        _dragDx = 0;
      });
      return;
    }

    if (_currentIndex >= _totalCount - 1) {
      setState(() {
        _animatingBackToCenter = true;
        _dragDx = 0;
      });
      return;
    }

    final double direction =
        _dragDx != 0 ? _dragDx.sign : (velocity >= 0 ? 1 : -1).toDouble();
    _advanceToNextCard(direction: direction);
  }

  void _goToNextCard() {
    _advanceToNextCard(direction: -1);
  }

  void _advanceToNextCard({required double direction}) {
    if (_animatingOut || _currentIndex >= _totalCount - 1) return;

    final double resolvedDirection = direction == 0 ? -1 : direction.sign;

    setState(() {
      // 台灣繁體中文教學註解：
      // 換題時讓頂卡先水平滑出，同步讓後方卡片往前補位，
      // 這樣視覺會是「下一張從深處浮上來」，而不是內容偷換後退回原位。
      _animatingOut = true;
      _animatingBackToCenter = false;
      _dragDx = resolvedDirection * 480.w;
    });

    Future<void>.delayed(const Duration(milliseconds: 260), () {
      if (!mounted) return;
      setState(() {
        _currentIndex += 1;
        _dragDx = 0;
        _animatingOut = false;
        _animatingBackToCenter = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentItem = homeV2MissionItems[_currentIndex];
    final nextItem = _currentIndex + 1 < _totalCount
        ? homeV2MissionItems[_currentIndex + 1]
        : null;
    final thirdItem = _currentIndex + 2 < _totalCount
        ? homeV2MissionItems[_currentIndex + 2]
        : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          '小任務測驗',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(18.w, 8.h, 18.w, 18.h),
          child: Column(
            children: [
              _MissionProgressHeader(
                currentIndex: _currentIndex,
                totalCount: _totalCount,
              ),
              SizedBox(height: 12.h),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // 台灣繁體中文教學註解：
                    // 這個頁面暫時保留卡堆補位動畫，但抽牌深度感仍待後續微調，
                    // 目前先優先處理主要互動正確性。
                    // 台灣繁體中文教學註解：
                    // 主要卡片改以可用區域的中心點對齊，這樣能穩定落在
                    // 進度點點與頁面底部邊界之間的視覺中線。
                    final double mainCardWidth = constraints.maxWidth * 0.9;
                    final double mainCardHeight = constraints.maxHeight * 0.78;
                    final _DeckLayerStyle nextLayerStyle = _animatingOut
                        ? _DeckLayerStyle(
                            width: mainCardWidth,
                            height: mainCardHeight,
                            verticalOffset: 0,
                            opacity: 0.96,
                            scale: 1,
                          )
                        : _DeckLayerStyle(
                            width: mainCardWidth,
                            height: mainCardHeight,
                            verticalOffset: 30.h,
                            opacity: 0.5,
                            scale: 1,
                          );
                    final _DeckLayerStyle thirdLayerStyle = _animatingOut
                        ? _DeckLayerStyle(
                            width: mainCardWidth,
                            height: mainCardHeight,
                            verticalOffset: 30.h,
                            opacity: 0.5,
                            scale: 1,
                          )
                        : _DeckLayerStyle(
                            width: mainCardWidth,
                            height: mainCardHeight,
                            verticalOffset: 56.h,
                            opacity: 0.28,
                            scale: 1,
                          );

                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        if (thirdItem != null)
                          IgnorePointer(
                            child: _AnimatedDeckLayer(
                              style: thirdLayerStyle,
                              child: _DeckPreviewCard(
                                item: thirdItem,
                                width: thirdLayerStyle.width,
                                height: thirdLayerStyle.height,
                              ),
                            ),
                          ),
                        if (nextItem != null)
                          IgnorePointer(
                            child: _AnimatedDeckLayer(
                              style: nextLayerStyle,
                              child: _MissionCardShell(
                                width: nextLayerStyle.width,
                                height: nextLayerStyle.height,
                                child: _MissionFrontFace(
                                  item: nextItem,
                                  selectedIndex: null,
                                  onAnswerTap: (_) {},
                                  showHint: false,
                                ),
                              ),
                            ),
                          ),
                        GestureDetector(
                          onHorizontalDragUpdate: _handleHorizontalDragUpdate,
                          onHorizontalDragEnd: _handleHorizontalDragEnd,
                          child: AnimatedContainer(
                            duration: Duration(
                              milliseconds: _animatingOut
                                  ? 260
                                  : _animatingBackToCenter
                                      ? 240
                                      : 0,
                            ),
                            curve: Curves.easeOutCubic,
                            width: mainCardWidth,
                            height: mainCardHeight,
                            transform: Matrix4.identity()
                              ..translateByDouble(_dragDx, 0, 0, 1)
                              ..rotateZ(_dragDx / 1400)
                              ..scaleByDouble(1 - (_dragDx.abs() / 5000),
                                  1 - (_dragDx.abs() / 5000), 1, 1),
                            child: _MissionDeckCard(
                              key: ValueKey<int>(_currentIndex),
                              item: currentItem,
                              selectedIndex: _selectedByIndex[_currentIndex],
                              isRevealed:
                                  _revealedIndices.contains(_currentIndex),
                              onAnswerTap: _selectAnswer,
                              onNext: _goToNextCard,
                              isLastCard: _currentIndex == _totalCount - 1,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeckLayerStyle {
  const _DeckLayerStyle({
    required this.width,
    required this.height,
    required this.verticalOffset,
    required this.opacity,
    required this.scale,
  });

  final double width;
  final double height;
  final double verticalOffset;
  final double opacity;
  final double scale;
}

class _AnimatedDeckLayer extends StatelessWidget {
  const _AnimatedDeckLayer({
    required this.style,
    required this.child,
  });

  final _DeckLayerStyle style;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      opacity: style.opacity,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        width: style.width,
        height: style.height,
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..translateByDouble(0, style.verticalOffset, 0, 1)
            ..scaleByDouble(style.scale, style.scale, 1, 1),
          child: child,
        ),
      ),
    );
  }
}

class _DeckPreviewCard extends StatelessWidget {
  const _DeckPreviewCard({
    required this.item,
    required this.width,
    required this.height,
  });

  final HomeV2MissionItem item;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return _MissionCardShell(
      width: width,
      height: height,
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          item.question,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 18.sp,
            height: 1.32,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _MissionProgressHeader extends StatelessWidget {
  const _MissionProgressHeader({
    required this.currentIndex,
    required this.totalCount,
  });

  final int currentIndex;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              '第 ${currentIndex + 1} 題 / 共 $totalCount 題',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(totalCount, (index) {
            final isActive = index == currentIndex;
            final isPast = index < currentIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: EdgeInsets.symmetric(horizontal: 3.w),
              width: isActive ? 18.w : 8.w,
              height: 8.w,
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF6B55C8)
                    : isPast
                        ? const Color(0xFFB9ABE9)
                        : const Color(0xFFE2DBF5),
                borderRadius: BorderRadius.circular(999.r),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _MissionDeckCard extends StatelessWidget {
  const _MissionDeckCard({
    super.key,
    required this.item,
    required this.selectedIndex,
    required this.isRevealed,
    required this.onAnswerTap,
    required this.onNext,
    required this.isLastCard,
  });

  final HomeV2MissionItem item;
  final int? selectedIndex;
  final bool isRevealed;
  final ValueChanged<int> onAnswerTap;
  final VoidCallback onNext;
  final bool isLastCard;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: isRevealed ? 1 : 0),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeInOutCubic,
      builder: (context, value, child) {
        final angle = value * math.pi;
        final showingBack = value >= 0.5;
        final effectiveAngle = showingBack ? angle - math.pi : angle;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(effectiveAngle),
          child: showingBack
              ? _MissionBackFace(
                  item: item,
                  selectedIndex: selectedIndex,
                  onNext: onNext,
                  isLastCard: isLastCard,
                )
              : _MissionFrontFace(
                  item: item,
                  selectedIndex: selectedIndex,
                  onAnswerTap: onAnswerTap,
                ),
        );
      },
    );
  }
}

class _MissionFrontFace extends StatelessWidget {
  const _MissionFrontFace({
    required this.item,
    required this.selectedIndex,
    required this.onAnswerTap,
    this.showHint = true,
  });

  final HomeV2MissionItem item;
  final int? selectedIndex;
  final ValueChanged<int> onAnswerTap;
  final bool showHint;

  @override
  Widget build(BuildContext context) {
    return _MissionCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.question,
            style: TextStyle(
              fontSize: 22.sp,
              height: 1.34,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          Row(
            children: List.generate(item.options.length, (index) {
              final bool isSelected = selectedIndex == index;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: index == 0 ? 10.w : 0),
                  child: _MissionChoiceButton(
                    label: item.options[index],
                    isSelected: isSelected,
                    onTap: () => onAnswerTap(index),
                  ),
                ),
              );
            }),
          ),
          const Spacer(),
          if (showHint)
            Center(
              child: Text(
                '左右滑動抽到下一題，點選作答',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MissionBackFace extends StatelessWidget {
  const _MissionBackFace({
    required this.item,
    required this.selectedIndex,
    required this.onNext,
    required this.isLastCard,
  });

  final HomeV2MissionItem item;
  final int? selectedIndex;
  final VoidCallback onNext;
  final bool isLastCard;

  @override
  Widget build(BuildContext context) {
    final bool answeredCorrectly = selectedIndex == item.correctIndex;
    final String selectedLabel =
        selectedIndex == null ? '未作答' : item.options[selectedIndex!];
    final String correctLabel = item.options[item.correctIndex];

    return _MissionCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.center,
            child: _MissionBadge(
              label: answeredCorrectly ? '答對了' : '再想一下',
              background: answeredCorrectly
                  ? const Color(0xFFE7F4EB)
                  : const Color(0xFFFFF2E8),
              textColor: answeredCorrectly
                  ? const Color(0xFF2E7D4D)
                  : const Color(0xFFB76A2E),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            item.question,
            style: TextStyle(
              fontSize: 20.sp,
              height: 1.35,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          _AnswerSummaryRow(label: '你的答案', value: selectedLabel),
          SizedBox(height: 8.h),
          _AnswerSummaryRow(label: '正確答案', value: correctLabel),
          SizedBox(height: 12.h),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.84),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: const Color(0xFFD7C9FF)),
              ),
              child: SingleChildScrollView(
                // 台灣繁體中文教學註解：
                // 翻面後的解析文字高度不固定，這裡用可捲動容器承接，
                // 就不會在 SE 等較矮螢幕上把底部按鈕推出卡片造成 overflow。
                child: Text(
                  item.detailExplanation,
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    height: 1.55,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 14.h),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: isLastCard ? null : onNext,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF6B55C8),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.r),
                ),
              ),
              icon: Icon(Icons.arrow_forward_rounded, size: 18.sp),
              label: Text(
                isLastCard ? '最後一題' : '下一題',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionCardShell extends StatelessWidget {
  const _MissionCardShell({
    required this.child,
    this.width,
    this.height,
  });

  final Widget child;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.fromLTRB(22.w, 22.h, 22.w, 20.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF7F2FF), Color(0xFFEDE7FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(color: const Color(0xFFD8CAFF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 20,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _MissionBadge extends StatelessWidget {
  const _MissionBadge({
    required this.label,
    this.background = const Color(0xFFFFFFFF),
    this.textColor = const Color(0xFF6B55C8),
  });

  final String label;
  final Color background;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w800,
          color: textColor,
        ),
      ),
    );
  }
}

class _MissionChoiceButton extends StatelessWidget {
  const _MissionChoiceButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Ink(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 18.h),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFE7DEFF) : Colors.white,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFB7A1F5)
                  : const Color(0xFFD8CAFF),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF5E4CB8),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnswerSummaryRow extends StatelessWidget {
  const _AnswerSummaryRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 13.sp,
            height: 1.35,
            color: AppColors.textPrimary,
          ),
          children: [
            TextSpan(
              text: '$label：',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
