import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/components/home/home_content.dart';
import 'package:lawapp/components/home/home_section_title.dart';
import 'package:lawapp/theme/app_colors.dart';

class HomeQuizSection extends StatefulWidget {
  const HomeQuizSection({
    super.key,
    required this.question,
    required this.selectedQuizIndex,
    required this.incorrectQuizIndices,
    required this.isSolved,
    required this.onNextQuestion,
    required this.onSelect,
  });

  static const double _itemGap = 12;

  final HomeQuizQuestion question;
  final int? selectedQuizIndex;
  final Set<int> incorrectQuizIndices;
  final bool isSolved;
  final VoidCallback onNextQuestion;
  final ValueChanged<int> onSelect;

  @override
  State<HomeQuizSection> createState() => _HomeQuizSectionState();
}

class _HomeQuizSectionState extends State<HomeQuizSection> {
  final Set<String> _activeTerms = <String>{};

  bool get _showHint =>
      widget.incorrectQuizIndices.isNotEmpty && !widget.isSolved;

  bool get _showExplanation {
    return widget.isSolved;
  }

  void _toggleTerm(String term) {
    setState(() {
      if (_activeTerms.contains(term)) {
        _activeTerms.remove(term);
      } else {
        _activeTerms.add(term);
      }
    });
  }

  void _selectOption(int index) {
    if (widget.isSolved) return;

    HapticFeedback.selectionClick();

    widget.onSelect(index);
  }

  void _showNextQuestion() {
    HapticFeedback.selectionClick();
    widget.onNextQuestion();
  }

  @override
  void didUpdateWidget(covariant HomeQuizSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    if ((oldWidget.question != widget.question || !_showExplanation) &&
        _activeTerms.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _activeTerms.clear();
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const HomeSectionTitle(title: '給你的小任務(*¯︶¯*)'),
        SizedBox(height: 20.h),
        Container(
          padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 16.h),
          decoration: BoxDecoration(
            color: const Color(0xFFD0BFE4),
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 36.w),
                      child: Text(
                        widget.question.question,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16.sp,
                          height: 1.3,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1F1B2D),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: _showNextQuestion,
                        child: Padding(
                          padding: EdgeInsets.only(left: 8.w),
                          child: Icon(
                            Icons.autorenew_rounded,
                            size: 22.sp,
                            color: const Color(0xFF1F1B2D),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14.h),
              ...List.generate(
                widget.question.options.length,
                (index) => Padding(
                  padding: EdgeInsets.only(
                    bottom: index == widget.question.options.length - 1
                        ? 0
                        : HomeQuizSection._itemGap.h,
                  ),
                  child: _QuizOptionTile(
                    option: widget.question.options[index],
                    isSolved: widget.isSolved,
                    isSelected: widget.selectedQuizIndex == index,
                    isIncorrect: widget.incorrectQuizIndices.contains(index),
                    onTap: () => _selectOption(index),
                  ),
                ),
              ),
              if (_showHint) ...[
                SizedBox(height: 12.h),
                Text(
                  '提示：',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  widget.question.hint,
                  style: TextStyle(
                    fontSize: 13.sp,
                    height: 1.45,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF271F38),
                  ),
                ),
              ],
              if (_showExplanation) ...[
                SizedBox(height: 12.h),
                Text(
                  '解析：',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: widget.question.termExplainMap.keys.map((term) {
                    final isActive = _activeTerms.contains(term);
                    return GestureDetector(
                      onTap: () => _toggleTerm(term),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFFD9DBE1)
                              : const Color(0xFFF1F2F6),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          term,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (_activeTerms.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: _activeTerms.map((term) {
                      return _TermBubble(
                        text: widget.question.termExplainMap[term]!,
                        onClose: () => _toggleTerm(term),
                      );
                    }).toList(),
                  ),
                ],
                SizedBox(height: 10.h),
                Text(
                  widget.question.explanation,
                  style: TextStyle(
                    fontSize: 13.sp,
                    height: 1.45,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF271F38),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _QuizOptionTile extends StatelessWidget {
  const _QuizOptionTile({
    required this.option,
    required this.isSolved,
    required this.isSelected,
    required this.isIncorrect,
    required this.onTap,
  });

  final HomeQuizOption option;
  final bool isSolved;
  final bool isSelected;
  final bool isIncorrect;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isSolved && isSelected
        ? AppColors.success
        : isIncorrect
            ? AppColors.danger
            : const Color(0xFFF1F1F1);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: 48.h),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                option.title,
                style: TextStyle(
                  fontSize: 12.sp,
                  height: 1.35,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF1F1B2D),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TermBubble extends StatelessWidget {
  const _TermBubble({
    required this.text,
    required this.onClose,
  });

  final String text;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104.w,
      padding: EdgeInsets.fromLTRB(10.w, 8.h, 8.w, 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFFD9DBE1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 8.5.sp,
                height: 1.25,
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          GestureDetector(
            onTap: onClose,
            child: Padding(
              padding: EdgeInsets.only(left: 6.w),
              child: Text(
                'x',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary.withValues(alpha: 0.8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
