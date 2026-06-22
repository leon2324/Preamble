import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/data/learning/learning_game_state.dart';
import 'package:lawapp/pages/learning/widgets/notebook_aesthetics.dart';
import 'package:lawapp/theme/app_colors.dart';

// 成就室的解答與學習歷史區塊。
// 只放統計、最近紀錄與空狀態 UI，不放 bottom sheet、Supabase 或導頁 mapping。

class AchievementHistorySection extends StatelessWidget {
  const AchievementHistorySection({
    super.key,
    required this.gameState,
    required this.onHistoryTap,
    required this.onShowAllHistory,
  });

  final LearningGameState gameState;
  final void Function(Map<String, dynamic> record) onHistoryTap;
  final VoidCallback onShowAllHistory;

  @override
  Widget build(BuildContext context) {
    final history = gameState.quizHistory;
    final totalCount = history.length;
    final correctCount =
        history.where((item) => item['isCorrect'] == true).length;
    final accuracy = totalCount == 0 ? 0.0 : (correctCount / totalCount) * 100;

    return NotebookCard(
      hasBinderRings: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history, color: const Color(0xFF5F9EA0), size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                '解答與學習歷史',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          if (history.isNotEmpty) ...[
            // 數據儀表板
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatChip(context, '總解答題數', '$totalCount 題', Colors.blue),
                _buildStatChip(
                    context,
                    '答對率',
                    '${accuracy.toStringAsFixed(0)}%',
                    accuracy >= 70 ? Colors.green : Colors.orange),
                _buildStatChip(context, '錯題本',
                    '${gameState.incorrectQuestions.length} 題', Colors.red),
              ],
            ),
            SizedBox(height: 12.h),

            // 最近 5 筆紀錄
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: history.length > 5 ? 5 : history.length,
              itemBuilder: (context, index) {
                return AchievementHistoryItem(
                  record: history[index],
                  onTap: () => onHistoryTap(history[index]),
                );
              },
            ),

            if (history.length > 5) ...[
              SizedBox(height: 8.h),
              Center(
                child: TextButton(
                  onPressed: () => onShowAllHistory(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '查看全部解答歷史 (${history.length})',
                        style: TextStyle(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_right, size: 16.sp),
                    ],
                  ),
                ),
              ),
            ],
          ] else ...[
            // 空白佔位
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.history_edu,
                      size: 40.sp,
                      color: Colors.grey.withValues(alpha: 0.5),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '尚未開始挑戰測驗，快去學堂答題吧！🌱',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatChip(
      BuildContext context, String label, String value, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 6.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.15 : 0.08),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                color: isDark ? Colors.grey[400] : Colors.grey[700],
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AchievementHistoryItem extends StatelessWidget {
  const AchievementHistoryItem({
    super.key,
    required this.record,
    required this.onTap,
  });

  final Map<String, dynamic> record;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isCorrect = record['isCorrect'] as bool? ?? false;
    final category = record['category'] as String? ?? '法學知識';
    final stepLabel = record['stepLabel'] as String? ?? '專題測驗';
    final timestampStr = record['timestamp'] as String? ?? '';
    final question = record['question'] as String? ?? '';

    // 格式化時間印記
    String formattedTime = '';
    if (timestampStr.isNotEmpty) {
      try {
        final dt = DateTime.parse(timestampStr);
        formattedTime =
            '${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      } catch (_) {
        formattedTime = timestampStr;
      }
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeColor = achievementHistoryCategoryColor(category);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 6.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.grey[50],
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: isDark ? const Color(0xFF374151) : Colors.grey[200]!,
          width: 0.5,
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: themeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                category,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  color: themeColor,
                ),
              ),
            ),
            SizedBox(width: 6.w),
            Text(
              stepLabel,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const Spacer(),
            Text(
              formattedTime,
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 6.h),
          child: Text(
            question,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: isCorrect
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            isCorrect ? '答對' : '答錯',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              color: isCorrect ? Colors.green : Colors.red,
            ),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

Color achievementHistoryCategoryColor(String category) {
  switch (category) {
    case '租屋糾紛':
      return const Color(0xFFD4A373);
    case '車禍事故':
      return const Color(0xFFE07A5F);
    case '職場權益':
      return const Color(0xFF3D5A80);
    case '網購消費':
      return const Color(0xFFE63946);
    case '個資隱私':
      return const Color(0xFF8338EC);
    default:
      return const Color(0xFF457B9D);
  }
}
