import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/pages/journal/widgets/journal_palette.dart';
import 'package:preamble/pages/learning/know_law_page.dart';

/// 智慧小法助時事提問氣泡元件。
///
/// 本元件展示在記事頁頂部，左側為小法助頭像，右側為對話氣泡，
/// 氣泡內會定期輪播熱門時事與生活法律痛點提問。點擊後可將當前問題自動帶入
/// 「小法助提問頁」 (LawAssistantChatPage) 進行深度整理。
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
    '租約到期房東扣押金不退，如何用法律自保？',
    '車禍初判表何時能申請？如何主張過失相抵？',
    '雇主口頭開除我不給資遣費，該怎麼辦？',
    '網購拆封被賣家拒絕退貨，消保法如何規定？',
    '裝潢工期延宕還留下一堆瑕疵，尾款能扣嗎？',
    '在網路社群被指名道姓辱罵，如何提告妨害名譽？',
    '收到法院支付命令，為什麼一定要在20天內異議？',
    '樓上住戶漏水拒不開門配合修繕，能求償多少？',
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
        ? const Color(0xFF1E2822)
        : const Color(0xFFF1F8F5); // Soft Morandi pastel green
    final bubbleBorderColor = isDark
        ? const Color(0xFF2C3E36)
        : const Color(0xFFCFE4DC); // Subtle Morandi border
    final textColor = isDark
        ? const Color(0xFFA5D1C0)
        : const Color(0xFF1B4D3E); // Elegant dark Morandi green
    final badgeBgColor = isDark
        ? const Color(0xFF283A32)
        : const Color(0xFFDCEFE7);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => LawAssistantChatPage(initialPrompt: currentPrompt),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 2.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left: Mascot head icon with soft shadow
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/assistant/law_assistant_home.png',
                  width: 44.w,
                  height: 44.w,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(width: 8.w),
              // Right: Dialogue bubble with AI Badge
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
                  decoration: BoxDecoration(
                    color: bubbleBgColor,
                    border: Border.all(color: bubbleBorderColor, width: 1.2.w),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4.r),
                      topRight: Radius.circular(16.r),
                      bottomLeft: Radius.circular(16.r),
                      bottomRight: Radius.circular(16.r),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: badgeBgColor,
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.auto_awesome,
                                    size: 10.sp,
                                    color: textColor,
                                  ),
                                  SizedBox(width: 3.w),
                                  Flexible(
                                    child: Text(
                                      '小法助熱問問診',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 9.5.sp,
                                        fontWeight: FontWeight.w800,
                                        color: textColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 9.sp,
                            color: textColor.withValues(alpha: 0.7),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.0, 0.25),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: Text(
                          currentPrompt,
                          key: ValueKey<int>(_currentIndex),
                          style: TextStyle(
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                            height: 1.25,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
