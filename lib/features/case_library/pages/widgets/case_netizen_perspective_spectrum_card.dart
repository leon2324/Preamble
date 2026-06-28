import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// 這個 widget 是案件討論室的觀點光譜摘要卡，只負責展示三種立場的代表留言。
// 它不擁有 controller、route、投票或留言寫入狀態；主頁仍負責資料來源與頁面流程。
class CaseNetizenPerspectiveSpectrumCard extends StatelessWidget {
  const CaseNetizenPerspectiveSpectrumCard({
    super.key,
    required this.comments,
  });

  final List<Map<String, dynamic>> comments;

  @override
  Widget build(BuildContext context) {
    final support = _topCommentForStance(comments, '合理派');
    final neutral = _topCommentForStance(comments, '中立派');
    final opposition = _topCommentForStance(comments, '不合理派');

    // 觀點光譜把留言串先整理成「程序正義／中間思考／社會法感」三個閱讀入口。
    // 使用者不用先被大量留言淹沒，也能快速理解本案討論的主要分歧。
    return Container(
      padding: EdgeInsets.all(13.w),
      decoration: BoxDecoration(
        color: _ChatPastels.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: _ChatPastels.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _labelPill(
                '觀點光譜',
                _ChatPastels.lavender,
                _ChatPastels.lavenderText,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  '先看三種判斷位置，再進入細節',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w800,
                    color: _ChatPastels.muted,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _spectrumLabel('程序正義', _ChatPastels.mintText),
              const Spacer(),
              _spectrumLabel('中間思考', _ChatPastels.neutralText),
              const Spacer(),
              _spectrumLabel('社會法感', _ChatPastels.roseText),
            ],
          ),
          SizedBox(height: 7.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 8.h,
              child: Row(
                children: [
                  Expanded(child: Container(color: _ChatPastels.mint)),
                  Expanded(child: Container(color: _ChatPastels.neutral)),
                  Expanded(child: Container(color: _ChatPastels.rose)),
                ],
              ),
            ),
          ),
          SizedBox(height: 10.h),
          _spectrumComment(
            title: '最強支持理由',
            comment: support,
            stance: '合理派',
          ),
          SizedBox(height: 7.h),
          _spectrumComment(
            title: '中線提醒',
            comment: neutral,
            stance: '中立派',
          ),
          SizedBox(height: 7.h),
          _spectrumComment(
            title: '最強反對理由',
            comment: opposition,
            stance: '不合理派',
          ),
        ],
      ),
    );
  }

  Widget _spectrumLabel(String label, Color color) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 9.5.sp,
        fontWeight: FontWeight.w900,
        color: color,
      ),
    );
  }

  Widget _spectrumComment({
    required String title,
    required Map<String, dynamic>? comment,
    required String stance,
  }) {
    final colors = _stanceColors(stance);
    final content = comment?['content'] as String? ?? '目前還沒有代表觀點，等你補上第一個理由。';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 9.h),
      decoration: BoxDecoration(
        color: colors.background.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24.w,
            height: 24.w,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                stance.substring(0, 1),
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w900,
                  color: colors.foreground,
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w900,
                        color: colors.foreground,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    if (comment != null)
                      Text(
                        comment['name'] as String? ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w700,
                          color: _ChatPastels.muted,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    height: 1.38,
                    fontWeight: FontWeight.w600,
                    color: _ChatPastels.ink,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _labelPill(String label, Color background, Color foreground) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 9.sp,
          fontWeight: FontWeight.w900,
          color: foreground,
        ),
      ),
    );
  }

  Map<String, dynamic>? _topCommentForStance(
    List<Map<String, dynamic>> comments,
    String stance,
  ) {
    final stanceComments = comments
        .where((comment) => (comment['stance'] as String?) == stance)
        .toList()
      ..sort(
        (a, b) => (b['likes'] as int? ?? 0).compareTo(
          a['likes'] as int? ?? 0,
        ),
      );
    return stanceComments.isEmpty ? null : stanceComments.first;
  }

  _StanceColors _stanceColors(String stance) {
    return switch (stance) {
      '合理派' => const _StanceColors(
          background: _ChatPastels.mint,
          foreground: _ChatPastels.mintText,
        ),
      '不合理派' => const _StanceColors(
          background: _ChatPastels.rose,
          foreground: _ChatPastels.roseText,
        ),
      _ => const _StanceColors(
          background: _ChatPastels.neutral,
          foreground: _ChatPastels.neutralText,
        ),
    };
  }
}

abstract final class _ChatPastels {
  static const surface = Color(0xFFFFFEFA);
  static const mint = Color(0xFFEAF6EF);
  static const mintText = Color(0xFF357A53);
  static const rose = Color(0xFFFBECEC);
  static const roseText = Color(0xFFC84E55);
  static const lavender = Color(0xFFF0EEF9);
  static const lavenderText = Color(0xFF6D649A);
  static const neutral = Color(0xFFEDEEEA);
  static const neutralText = Color(0xFF73766F);
  static const ink = Color(0xFF1A332F);
  static const muted = Color(0xFF7A8179);
  static const border = Color(0xFFE8DFD0);
}

class _StanceColors {
  const _StanceColors({
    required this.background,
    required this.foreground,
  });

  final Color background;
  final Color foreground;
}
