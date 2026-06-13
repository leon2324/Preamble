import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/pages/journal/widgets/journal_palette.dart';
import 'package:lawapp/pages/learning/know_law_page.dart';

/// 智慧小法助時事提問氣泡元件。
///
/// 台灣繁體中文教學註解：
/// 本元件展示在記事頁頂部，左側為小法助頭像，右側為對話氣泡，
/// 氣泡內會定期輪播熱門時事法律提問。點擊後可將當前問題自動帶入
/// 「小法助提問頁」 (LawAssistantSearchPage) 進行深度整理。
class AssistantPromptBubble extends StatefulWidget {
  const AssistantPromptBubble({
    super.key,
    required this.palette,
  });

  final JournalPalette palette;

  @override
  State<AssistantPromptBubble> createState() => _AssistantPromptBubbleState();
}

class _AssistantPromptBubbleState extends State<AssistantPromptBubble> {
  late final Timer _timer;
  int _currentIndex = 0;

  static const List<String> _prompts = [
    '死刑釋憲結果如何影響現有案件？',
    '什麼是『信賴保護原則』？',
    '違章建築在法律上如何認定與處理？',
    '網路言論自由與妨害名譽的界線在哪？',
    '什麼是『無罪推定原則』？',
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _prompts.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentPrompt = _prompts[_currentIndex];

    // Morandi colors matching the journal page.
    final bubbleBgColor = isDark
        ? const Color(0xFF1E2622)
        : const Color(0xFFF2FAF6); // Soft Morandi pastel green
    final bubbleBorderColor = isDark
        ? const Color(0xFF2E3C36)
        : const Color(0xFFD2E6DE); // Subtle Morandi border
    final textColor = isDark
        ? const Color(0xFF99C3B3)
        : const Color(0xFF1B4D3E); // Elegant dark Morandi green

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => LawAssistantSearchPage(initialPrompt: currentPrompt),
          ),
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: Mascot head icon
          Image.asset(
            'assets/images/assistant/law_assistant_home.png',
            width: 44.w,
            height: 44.w,
            fit: BoxFit.contain,
          ),
          SizedBox(width: 8.w),
          // Right: Dialogue bubble
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
              decoration: BoxDecoration(
                color: bubbleBgColor,
                border: Border.all(color: bubbleBorderColor, width: 1.2.w),
                // Smooth bubble borders pointing to the left mascot
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4.r),
                  topRight: Radius.circular(16.r),
                  bottomLeft: Radius.circular(16.r),
                  bottomRight: Radius.circular(16.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.0, 0.2),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        '問問小法助：$currentPrompt',
                        key: ValueKey<int>(_currentIndex),
                        style: TextStyle(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12.sp,
                    color: textColor.withValues(alpha: 0.7),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
