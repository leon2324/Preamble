import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/components/home/v2/home_v2_palette.dart';
import 'package:lawapp/components/home/v2/home_v2_primitives.dart';
import 'package:lawapp/data/mock_data/home/home_v2_mock_data.dart';
import 'package:lawapp/theme/app_colors.dart';

// 首頁 V2 的每日任務卡。
// 只放首頁輕量答題 UI 與本地答題狀態，不放完整測驗頁路由邏輯。

class HomeV2DailyMissionCard extends StatefulWidget {
  const HomeV2DailyMissionCard({
    super.key,
    required this.onAnsweredStateChanged,
    required this.onOpenMore,
  });

  final ValueChanged<bool> onAnsweredStateChanged;
  final VoidCallback onOpenMore;

  @override
  State<HomeV2DailyMissionCard> createState() => _HomeV2DailyMissionCardState();
}

/// 首頁版的小任務卡。
///
/// 台灣繁體中文教學註解：
/// 這裡刻意只放二選一與短回饋，讓首頁維持輕盈；
/// 若之後要做完整測驗，可另開子頁面承接。
class _HomeV2DailyMissionCardState extends State<HomeV2DailyMissionCard> {
  int _questionIndex = 0;
  int? _selectedIndex;
  bool _hasAnswered = false;

  HomeV2MissionItem get _question => homeV2MissionItems[_questionIndex];

  void _selectOption(int index) {
    if (_hasAnswered) return;

    HapticFeedback.selectionClick();

    setState(() {
      _selectedIndex = index;
      _hasAnswered = true;
    });
    widget.onAnsweredStateChanged(true);
  }

  void _showNextQuestion() {
    HapticFeedback.selectionClick();

    setState(() {
      _questionIndex = (_questionIndex + 1) % homeV2MissionItems.length;
      _selectedIndex = null;
      _hasAnswered = false;
    });
    widget.onAnsweredStateChanged(false);
  }

  @override
  Widget build(BuildContext context) {
    final question = _question;
    final isCorrect = _selectedIndex == question.correctIndex;
    final String? feedback = !_hasAnswered
        ? null
        : (isCorrect ? question.correctFeedback : question.incorrectFeedback);

    return HomeV2SurfaceCard(
      color: HomeV2Palette.lavender,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.question,
            style: TextStyle(
              color: HomeV2Palette.ink,
              fontSize: 15.sp,
              fontWeight: FontWeight.w900,
              height: 1.35,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: List.generate(question.options.length, (index) {
              final option = question.options[index];
              final isSelected = _selectedIndex == index;

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index == 0 ? 8.w : 0,
                  ),
                  child: _AnswerPill(
                    label: option,
                    isSelected: isSelected,
                    isCorrect: index == question.correctIndex,
                    showResult: _hasAnswered,
                    onTap: () => _selectOption(index),
                  ),
                ),
              );
            }),
          ),
          if (_hasAnswered && feedback != null) ...[
            SizedBox(height: 12.h),
            _MissionFeedbackCard(
              title: isCorrect ? '答對了' : '再想一下',
              message: feedback,
              background:
                  isCorrect ? const Color(0xFFF8F6FF) : const Color(0xFFFFF7F1),
              borderColor:
                  isCorrect ? const Color(0xFFD9CDFB) : const Color(0xFFF2D2B7),
              accent:
                  isCorrect ? const Color(0xFF5940BC) : const Color(0xFFC47A42),
              icon: isCorrect
                  ? Icons.check_circle_outline_rounded
                  : Icons.tips_and_updates_outlined,
            ),
          ],
          SizedBox(height: 10.h),
          if (_hasAnswered)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _showNextQuestion,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF8A7BD3),
                    visualDensity: VisualDensity.compact,
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                  ),
                  child: const Text('換一題'),
                ),
                SizedBox(width: 6.w),
                TextButton.icon(
                  onPressed: widget.onOpenMore,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF6B55C8),
                    visualDensity: VisualDensity.compact,
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  ),
                  icon: Icon(Icons.arrow_forward_rounded, size: 18.sp),
                  label: const Text('進入完整測驗'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _AnswerPill extends StatelessWidget {
  const _AnswerPill({
    required this.label,
    required this.onTap,
    this.isSelected = false,
    this.isCorrect = false,
    this.showResult = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool isSelected;
  final bool isCorrect;
  final bool showResult;

  @override
  Widget build(BuildContext context) {
    final Color background;
    final Color borderColor;
    final Color textColor;

    if (showResult && isSelected && isCorrect) {
      background = const Color(0xFFE7F7EB);
      borderColor = const Color(0xFF8AC89B);
      textColor = const Color(0xFF2E7D4D);
    } else if (showResult && isSelected && !isCorrect) {
      background = const Color(0xFFFFF0F0);
      borderColor = const Color(0xFFE4A3A3);
      textColor = const Color(0xFFB24C4C);
    } else {
      background = Colors.white;
      borderColor =
          isSelected ? const Color(0xFFBDAAF7) : const Color(0xFFD6CDF8);
      textColor = const Color(0xFF5D4AB5);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: borderColor),
          ),
          child: Text(
            label,
            textAlign: TextAlign.left,
            style: TextStyle(
              color: textColor,
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
              height: 1.4,
            ),
          ),
        ),
      ),
    );
  }
}

class _MissionFeedbackCard extends StatelessWidget {
  const _MissionFeedbackCard({
    required this.title,
    required this.message,
    required this.background,
    required this.borderColor,
    required this.accent,
    required this.icon,
  });

  final String title;
  final String message;
  final Color background;
  final Color borderColor;
  final Color accent;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(12.w, 11.h, 12.w, 11.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent, size: 18.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: accent,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  message,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11.sp,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
