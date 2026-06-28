import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/features/case_library/models/case_library_models.dart';
import 'package:preamble/features/case_library/theme/case_library_theme.dart';

// Hero 大卡元件 — 案件圖書館首頁的主視覺輪播卡片。
// V2：加入分類漸層色帶（頂部裝飾條）和右下角半透明裝飾 icon，
// 讓視覺更加豐富不單調。每個分類有獨立配色和 emoji。

// 分類→色系+emoji 對照表
const _categoryAccents = <String, ({Color color, Color bgTint, String emoji})>{
  '集會遊行': (color: Color(0xFF4A7C8C), bgTint: Color(0xFFEAF4F7), emoji: '🪧'),
  '強制治療': (color: Color(0xFF6D649A), bgTint: Color(0xFFF0EEF9), emoji: '🏥'),
  '死刑制度': (color: Color(0xFF8C4A5A), bgTint: Color(0xFFF8EEF0), emoji: '⚖️'),
  '婚姻平權': (color: Color(0xFF357A53), bgTint: Color(0xFFEAF6EF), emoji: '🌈'),
  '新聞自由': (color: Color(0xFF9E7B2D), bgTint: Color(0xFFFFF2CF), emoji: '📰'),
  '修憲程序': (color: Color(0xFF4A7C8C), bgTint: Color(0xFFEAF4F7), emoji: '📜'),
  '軍事司法': (color: Color(0xFF5A6B4F), bgTint: Color(0xFFEFF4EA), emoji: '🎖️'),
  '詐欺犯罪': (color: Color(0xFF8C642B), bgTint: Color(0xFFFFF2CF), emoji: '🚨'),
};

({Color color, Color bgTint, String emoji}) _getAccent(CaseBook book) {
  // 先查分類，再查 tags，最後用預設值
  final cat = _categoryAccents[book.category];
  if (cat != null) return cat;
  for (final tag in book.tags) {
    final t = _categoryAccents[tag];
    if (t != null) return t;
  }
  return (
    color: const Color(0xFF4A7C8C),
    bgTint: const Color(0xFFEAF4F7),
    emoji: '📂',
  );
}

class CaseLibraryHeroCard extends StatelessWidget {
  const CaseLibraryHeroCard({
    super.key,
    required this.book,
    required this.onReadDossierTap,
    required this.onJoinDiscussionTap,
    this.discussionCount = 0,
    this.hasActiveVote = false,
  });

  final CaseBook book;
  final VoidCallback onReadDossierTap;
  final VoidCallback onJoinDiscussionTap;
  final int discussionCount;
  final bool hasActiveVote;

  @override
  Widget build(BuildContext context) {
    final primaryTag = book.tags.isNotEmpty ? book.tags.first : book.category;
    final accent = _getAccent(book);

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        // 白底 + 極淡的分類色漸層，讓不同案件的 Hero 卡有不同色調
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            accent.bgTint.withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: accent.color.withValues(alpha: 0.15),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.color.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 右下角半透明大 emoji，作為裝飾元素，讓卡片不單調
          Positioned(
            right: -8.w,
            bottom: -4.h,
            child: Text(
              accent.emoji,
              style: TextStyle(
                fontSize: 72.sp,
                height: 1,
              ),
            ),
          ),
          Positioned(
            right: -8.w,
            bottom: -4.h,
            child: Container(
              width: 80.w,
              height: 80.h,
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
          // 頂部彩色裝飾條 — 用分類主色做 4px 高的漸層色帶
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 4.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accent.color,
                    accent.color.withValues(alpha: 0.3),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18.r),
                  topRight: Radius.circular(18.r),
                ),
              ),
            ),
          ),

          // 主要內容
          Padding(
            padding: EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 頂部標籤列 — emoji + 分類 + 年代
                Row(
                  children: [
                    Text(accent.emoji, style: TextStyle(fontSize: 14.sp)),
                    SizedBox(width: 5.w),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: accent.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(
                          color: accent.color.withValues(alpha: 0.25),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        primaryTag,
                        style: TextStyle(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.bold,
                          color: accent.color,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '${book.year} 年',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: CaseLibraryColors.textMuted,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: accent.bgTint,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        '精選案件',
                        style: TextStyle(
                          fontSize: 8.5.sp,
                          fontWeight: FontWeight.bold,
                          color: accent.color,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // 案件主標題，使用宋體強調歷史感
                Text(
                  book.titleZh,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Songti TC',
                    fontFamilyFallback: const [
                      'Songti SC',
                      'STSong',
                      'BiauKai',
                      'PingFang TC'
                    ],
                    fontSize: 19.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF173C37),
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 8.h),

                // 一句摘要
                Text(
                  book.oneSentenceSummary.isNotEmpty
                      ? book.oneSentenceSummary
                      : book.memoryLine,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF4A5654),
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 12.h),

                // 討論熱度徽章列
                Row(
                  children: [
                    _buildBadge(
                      icon: Icons.chat_bubble_outline_rounded,
                      label:
                          discussionCount > 0 ? '$discussionCount 則討論' : '加入討論',
                      color: accent.color,
                      bg: accent.bgTint,
                    ),
                    SizedBox(width: 8.w),
                    if (hasActiveVote)
                      _buildBadge(
                        icon: Icons.how_to_vote_outlined,
                        label: '投票進行中',
                        color: const Color(0xFF8C642B),
                        bg: const Color(0xFFFFF2CF),
                      ),
                  ],
                ),
                SizedBox(height: 14.h),

                Divider(
                    color: accent.color.withValues(alpha: 0.12), height: 1.h),
                SizedBox(height: 12.h),

                // 雙 CTA 按鈕
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: accent.color, width: 1.2),
                          foregroundColor: accent.color,
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        onPressed: onReadDossierTap,
                        child: Text(
                          '研讀卷宗',
                          style: TextStyle(
                              fontSize: 12.sp, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent.color,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        onPressed: onJoinDiscussionTap,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '加入討論',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            const Icon(Icons.chat_bubble_outline_rounded,
                                size: 13),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required String label,
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 9.5.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
