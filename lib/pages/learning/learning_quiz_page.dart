import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/components/home/home_content.dart';
import 'package:lawapp/data/mock_data/learning/learning_mock_data.dart';
import 'package:lawapp/theme/app_colors.dart';

class LearningQuizPage extends StatefulWidget {
  const LearningQuizPage({super.key});

  @override
  State<LearningQuizPage> createState() => _LearningQuizPageState();
}

class _LearningQuizPageState extends State<LearningQuizPage> {
  int _currentQuestionIndex = 0;
  int? _selectedOptionIndex;
  bool _isAnsweredCorrectly = false;

  HomeQuizQuestion get _question =>
      learningQuizQuestions[_currentQuestionIndex];

  void _selectOption(int index) {
    if (_isAnsweredCorrectly) return;

    setState(() {
      _selectedOptionIndex = index;
      _isAnsweredCorrectly = _question.options[index].isCorrect;
    });
  }

  void _nextQuestion() {
    setState(() {
      _currentQuestionIndex =
          ((_currentQuestionIndex + 1) % learningQuizQuestions.length).toInt();
      _selectedOptionIndex = null;
      _isAnsweredCorrectly = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('學習小測驗'),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 28.h),
        children: [
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26.r),
              color: const Color(0xFFF6E8BF),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mock Quiz',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF6B5439),
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  _question.question,
                  style: TextStyle(
                    fontSize: 24.sp,
                    height: 1.3,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  '第 ${_currentQuestionIndex + 1} / ${learningQuizQuestions.length} 題',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          ...List.generate(
            _question.options.length,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: _QuizOptionCard(
                option: _question.options[index],
                isSelected: _selectedOptionIndex == index,
                isLocked: _selectedOptionIndex != null,
                onTap: () => _selectOption(index),
              ),
            ),
          ),
          if (_selectedOptionIndex != null) ...[
            SizedBox(height: 8.h),
            _InfoCard(
              title: _isAnsweredCorrectly ? '答對了' : '再看一次提示',
              body:
                  _isAnsweredCorrectly ? _question.explanation : _question.hint,
              accent: _isAnsweredCorrectly
                  ? const Color(0xFFEAF6E2)
                  : const Color(0xFFF9EED7),
            ),
          ],
          if (_isAnsweredCorrectly) ...[
            SizedBox(height: 16.h),
            _InfoCard(
              title: '術語小抄',
              body: _question.termExplainMap.entries
                  .map((entry) => '${entry.key}：${entry.value}')
                  .join('\n\n'),
              accent: const Color(0xFFEAF0F8),
            ),
          ],
          SizedBox(height: 20.h),
          FilledButton(
            onPressed: _nextQuestion,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.textPrimary,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.r),
              ),
            ),
            child: Text(
              _isAnsweredCorrectly ? '下一題' : '換一題看看',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuizOptionCard extends StatelessWidget {
  const _QuizOptionCard({
    required this.option,
    required this.isSelected,
    required this.isLocked,
    required this.onTap,
  });

  final HomeQuizOption option;
  final bool isSelected;
  final bool isLocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isCorrect = isLocked && option.isCorrect;
    final backgroundColor = isCorrect
        ? const Color(0xFFEAF6E2)
        : isSelected
            ? const Color(0xFFFBE8E7)
            : Colors.white;
    final borderColor = isCorrect
        ? const Color(0xFF9EC979)
        : isSelected
            ? const Color(0xFFE4A29D)
            : const Color(0xFFE8E4DC);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLocked ? null : onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: borderColor),
          ),
          child: Text(
            option.title,
            style: TextStyle(
              fontSize: 15.sp,
              height: 1.55,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.body,
    required this.accent,
  });

  final String title;
  final String body;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: accent,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            body,
            style: TextStyle(
              fontSize: 14.sp,
              height: 1.65,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
