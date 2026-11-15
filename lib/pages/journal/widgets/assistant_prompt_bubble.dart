import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:preamble/pages/journal/widgets/journal_palette.dart';
import 'package:preamble/pages/learning/know_law_page.dart';
import 'package:preamble/theme/preamble_tokens.dart';

/// 智慧小法助時事提問導引列（統一採用 `PreambleTokens` 靜奢設計語彙）。
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
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
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
    final t = context.tokens;
    final currentPrompt = _prompts[_currentIndex];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) =>
                  LawAssistantChatPage(initialPrompt: currentPrompt),
            ),
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: t.cardDecoration(
            radius: 16.r,
            fill: t.surface,
            elevated: false,
          ),
          child: Row(
            children: [
              ClipOval(
                child: Container(
                  width: 38.w,
                  height: 38.w,
                  color: t.brandContainer,
                  padding: EdgeInsets.all(2.w),
                  child: Image.asset(
                    'assets/images/assistant/law_assistant_home.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(
                          PhosphorIconsFill.sparkle,
                          size: 11.sp,
                          color: t.accentBrass,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '小法助實務熱問',
                          style: t.sansBody(
                            size: 10.5.sp,
                            weight: FontWeight.w700,
                            color: t.accentBrass,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 3.h),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      child: Align(
                        key: ValueKey<int>(_currentIndex),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          currentPrompt,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: t.sansTitle(
                            size: 13.sp,
                            weight: FontWeight.w700,
                            color: t.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                PhosphorIconsRegular.arrowUpRight,
                size: 16.sp,
                color: t.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
