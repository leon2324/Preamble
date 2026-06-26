import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/features/case_time_machine/widgets/case_time_machine_svg_icon.dart';

// 這個 widget 是案件討論室的單則留言卡，只負責顯示留言內容、立場、引用資訊與按讚入口。
// 它不擁有排序、送出留言、投票或 controller 狀態；主頁仍負責資料來源、按讚 mutation 與頁面流程。
class CaseNetizenOpinionCard extends StatelessWidget {
  const CaseNetizenOpinionCard({
    super.key,
    required this.comment,
    required this.index,
    required this.onLike,
  });

  final Map<String, dynamic> comment;
  final int index;
  final VoidCallback onLike;

  @override
  Widget build(BuildContext context) {
    final isMe = comment['isMe'] == true || comment['avatar'] == '我';
    final stance = comment['stance'] as String? ?? '中立派';
    final liked = comment['liked'] as bool? ?? false;
    final hasCitation = _hasCitation(comment);
    final stanceColors = _stanceColors(stance);

    return Container(
      padding: EdgeInsets.all(13.w),
      decoration: BoxDecoration(
        color: isMe ? const Color(0xFFF8FFF8) : _ChatPastels.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isMe ? const Color(0xFFD7ECDD) : _ChatPastels.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 15.r,
                backgroundColor: stanceColors.background,
                child: Text(
                  comment['avatar'] as String? ?? '論',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w900,
                    color: stanceColors.foreground,
                  ),
                ),
              ),
              SizedBox(width: 9.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            comment['name'] as String? ?? '思辨參與者',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w900,
                              color: _ChatPastels.ink,
                            ),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        _labelPill(
                          stance,
                          stanceColors.background,
                          stanceColors.foreground,
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      comment['time'] as String? ?? '剛剛',
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w700,
                        color: _ChatPastels.muted,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasCitation)
                _labelPill(
                  '有引用',
                  _ChatPastels.lavender,
                  _ChatPastels.lavenderText,
                ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            comment['content'] as String? ?? '',
            style: TextStyle(
              fontSize: 12.sp,
              height: 1.55,
              fontWeight: FontWeight.w600,
              color: _ChatPastels.ink,
            ),
          ),
          SizedBox(height: 9.h),
          Row(
            children: [
              _cardAction(
                iconSvg: liked ? CtmSvgIcons.heartFilled : CtmSvgIcons.heart,
                label: '${comment['likes'] ?? 0}',
                color: _ChatPastels.roseText,
                onTap: onLike,
              ),
              const Spacer(),
              if (hasCitation)
                Text(
                  comment['source'] as String? ?? '有來源',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w800,
                    color: _ChatPastels.lavenderText,
                  ),
                ),
              SizedBox(width: 8.w),
              Text(
                '#${index + 1}',
                style: TextStyle(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w800,
                  color: _ChatPastels.muted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cardAction({
    required String iconSvg,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CtmSvgIcon(iconSvg, size: 14.sp, color: color),
          SizedBox(width: 3.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w900,
              color: color,
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

  bool _hasCitation(Map<String, dynamic> comment) {
    final content = comment['content'] as String? ?? '';
    return comment['hasCitation'] == true ||
        content.contains('法條') ||
        content.contains('判決') ||
        content.contains('刑法') ||
        content.contains('憲法') ||
        content.contains('比例原則') ||
        content.contains('程序正義');
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
