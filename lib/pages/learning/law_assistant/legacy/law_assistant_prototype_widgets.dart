part of '../../know_law_page.dart';

/// 小法助 Prototype 共用 UI 元件與示範資料。
///
/// 這個檔案集中放 Prototype 卡片、Tab、插圖、按鈕與 mock 對話資料；
/// 搜尋頁只組流程，不直接塞大量樣式細節，後續要替換正式圖像或資料也比較好找。
class _AssistantFrozenAppBar extends StatelessWidget {
  const _AssistantFrozenAppBar({
    required this.title,
    required this.showBack,
    required this.onBack,
    this.trailing,
  });

  final String title;
  final bool showBack;
  final VoidCallback onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final palette = _LawAssistantPalette.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.pageBackground,
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 58.h,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                if (showBack)
                  _AssistantIconButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    tooltip: '返回',
                    onTap: onBack,
                  ),
                Expanded(
                  child: Text(
                    title,
                    textAlign: showBack ? TextAlign.center : TextAlign.start,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _AssistantText.navTitle(context),
                  ),
                ),
                SizedBox(
                  width: trailing == null ? 42.w : 90.w,
                  child: trailing == null ? const SizedBox.shrink() : trailing!,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AssistantIconButton extends StatelessWidget {
  const _AssistantIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = _LawAssistantPalette.of(context);
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999.r),
        child: SizedBox(
          width: 42.w,
          height: 42.w,
          child: Icon(icon, size: 20.sp, color: palette.primaryText),
        ),
      ),
    );
  }
}

class _AssistantHero extends StatelessWidget {
  const _AssistantHero();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/images/assistant/law_assistant_home.png',
          width: 156.w,
          height: 132.h,
          fit: BoxFit.contain,
        ),
        SizedBox(height: 8.h),
        Text('你好，我是小法助', style: _AssistantText.section(context)),
        SizedBox(height: 4.h),
        Text(
          '有法律問題？我來幫你整理！',
          style: _AssistantText.body(context),
        ),
      ],
    );
  }
}

class _AssistantInputLauncher extends StatelessWidget {
  const _AssistantInputLauncher({
    required this.onTap,
    required this.onMic,
  });

  final VoidCallback onTap;
  final VoidCallback onMic;

  @override
  Widget build(BuildContext context) {
    return _AssistantCard(
      padding: EdgeInsets.fromLTRB(14.w, 10.h, 8.w, 10.h),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onTap,
              child: Text(
                '描述你的法律問題...',
                style: _AssistantText.caption(context),
              ),
            ),
          ),
          _AssistantRoundAction(icon: Icons.mic_none_rounded, onTap: onMic),
          SizedBox(width: 6.w),
          _AssistantRoundAction(
            icon: Icons.north_east_rounded,
            filled: true,
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}

class _AssistantTextArea extends StatelessWidget {
  const _AssistantTextArea({
    required this.controller,
    required this.focusNode,
    required this.onClear,
    required this.canSubmit,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onClear;
  final bool canSubmit;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final palette = _LawAssistantPalette.of(context);
    return _AssistantCard(
      padding: EdgeInsets.all(14.w),
      child: Column(
        children: [
          TextField(
            controller: controller,
            focusNode: focusNode,
            minLines: 6,
            maxLines: 8,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: '我在租屋退租後，房東說要扣押金，我覺得不合理，怎麼辦？',
              hintStyle: _AssistantText.body(context)
                  .copyWith(color: palette.mutedText),
              border: InputBorder.none,
              counterStyle: _AssistantText.caption(context),
              isCollapsed: true,
            ),
          ),
          Row(
            children: [
              const Spacer(),
              if (controller.text.isNotEmpty)
                _AssistantRoundAction(
                  icon: Icons.close_rounded,
                  onTap: onClear,
                ),
              SizedBox(width: 6.w),
              _AssistantRoundAction(
                icon: isSubmitting
                    ? Icons.hourglass_empty_rounded
                    : Icons.north_east_rounded,
                filled: canSubmit,
                onTap: canSubmit ? onSubmit : () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AssistantRoundAction extends StatelessWidget {
  const _AssistantRoundAction({
    required this.icon,
    required this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final palette = _LawAssistantPalette.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999.r),
      child: Container(
        width: 34.w,
        height: 34.w,
        decoration: BoxDecoration(
          color: filled ? palette.accent : palette.subtleSurface,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18.sp,
          color: filled ? palette.inverseText : palette.primaryText,
        ),
      ),
    );
  }
}

class _AssistantSectionHeader extends StatelessWidget {
  const _AssistantSectionHeader({
    required this.title,
    this.action,
    this.onTap,
  });

  final String title;
  final String? action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: _AssistantText.section(context))),
        if (action != null)
          TextButton(
            onPressed: onTap,
            child: Text(action!, style: _AssistantText.action(context)),
          ),
      ],
    );
  }
}

class _AssistantQuestionRow extends StatelessWidget {
  const _AssistantQuestionRow({
    required this.question,
    required this.onTap,
  });

  final String question;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = _LawAssistantPalette.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        height: 34.h,
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: palette.divider)),
        ),
        child: Row(
          children: [
            Icon(Icons.help_outline_rounded,
                color: palette.secondary, size: 16.sp),
            SizedBox(width: 8.w),
            Expanded(
                child: Text(question, style: _AssistantText.body(context))),
          ],
        ),
      ),
    );
  }
}

class _AssistantMemberCard extends StatelessWidget {
  const _AssistantMemberCard({
    required this.quota,
    required this.onPlan,
  });

  final String quota;
  final VoidCallback onPlan;

  @override
  Widget build(BuildContext context) {
    final palette = _LawAssistantPalette.of(context);
    return _AssistantCard(
      background: palette.softPaper,
      child: Row(
        children: [
          const _LawBuddyAvatar(),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Demo 會員', style: _AssistantText.tile(context)),
                SizedBox(height: 3.h),
                Text('今日提問額度：$quota', style: _AssistantText.caption(context)),
              ],
            ),
          ),
          _AssistantMiniButton(label: '升級 Pro', onTap: onPlan),
        ],
      ),
    );
  }
}

class _AssistantLinkRow extends StatelessWidget {
  const _AssistantLinkRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = _LawAssistantPalette.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 11.h),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: palette.divider)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20.sp, color: palette.accent),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: _AssistantText.tile(context)),
                  SizedBox(height: 2.h),
                  Text(subtitle, style: _AssistantText.caption(context)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 18.sp, color: palette.mutedText),
          ],
        ),
      ),
    );
  }
}

class _AssistantActionRow extends StatelessWidget {
  const _AssistantActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _AssistantLinkRow(
      icon: icon,
      title: title,
      subtitle: subtitle,
      onTap: onTap,
    );
  }
}

class _AssistantUserPromptBubble extends StatelessWidget {
  const _AssistantUserPromptBubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = _LawAssistantPalette.of(context);
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(maxWidth: 284.w),
        padding: EdgeInsets.all(13.w),
        decoration: BoxDecoration(
          color: palette.subtleSurface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(14.r),
            topRight: Radius.circular(14.r),
            bottomLeft: Radius.circular(14.r),
          ),
        ),
        child: Text(text, style: _AssistantText.body(context)),
      ),
    );
  }
}

class _AssistantBotBubble extends StatelessWidget {
  const _AssistantBotBubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const _LawBuddyAvatar(),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(text, style: _AssistantText.tile(context)),
        ),
      ],
    );
  }
}

class _AssistantResultCard extends StatelessWidget {
  const _AssistantResultCard({
    required this.title,
    required this.body,
    this.leading,
    this.motif = false,
  });

  final String title;
  final String body;
  final IconData? leading;
  final bool motif;

  @override
  Widget build(BuildContext context) {
    final palette = _LawAssistantPalette.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: _AssistantCard(
        background: motif ? palette.softPaper : palette.cardSurface,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (leading != null) ...[
              Icon(leading, color: palette.accent, size: 22.sp),
              SizedBox(width: 10.w),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: _AssistantText.tile(context)),
                  SizedBox(height: 7.h),
                  Text(body, style: _AssistantText.body(context)),
                ],
              ),
            ),
            if (motif)
              Icon(Icons.eco_outlined,
                  color: palette.secondary.withValues(alpha: 0.45),
                  size: 34.sp),
          ],
        ),
      ),
    );
  }
}

class _AssistantLawTile extends StatelessWidget {
  const _AssistantLawTile({
    required this.title,
    required this.onTap,
  });

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = _LawAssistantPalette.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: palette.divider)),
        ),
        child: Row(
          children: [
            Icon(Icons.article_outlined, color: palette.accent, size: 18.sp),
            SizedBox(width: 9.w),
            Expanded(child: Text(title, style: _AssistantText.body(context))),
            Icon(Icons.chevron_right_rounded,
                color: palette.mutedText, size: 18.sp),
          ],
        ),
      ),
    );
  }
}

class _AssistantStepLine extends StatelessWidget {
  const _AssistantStepLine(this.number, this.text);

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = _LawAssistantPalette.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20.w,
            height: 20.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: palette.subtleSurface,
              shape: BoxShape.circle,
            ),
            child: Text(number, style: _AssistantText.caption(context)),
          ),
          SizedBox(width: 8.w),
          Expanded(child: Text(text, style: _AssistantText.body(context))),
        ],
      ),
    );
  }
}

class _AssistantFollowUpInput extends StatelessWidget {
  const _AssistantFollowUpInput({
    required this.onTap,
    this.hint = '還有其他問題嗎？',
    this.controller,
    this.enabled = true,
    this.isSending = false,
  });

  final VoidCallback onTap;
  final String hint;
  final TextEditingController? controller;
  final bool enabled;
  final bool isSending;

  @override
  Widget build(BuildContext context) {
    return _AssistantCard(
      padding: EdgeInsets.fromLTRB(14.w, 8.h, 8.w, 8.h),
      child: Row(
        children: [
          Expanded(
            child: controller == null
                ? Text(hint, style: _AssistantText.caption(context))
                : TextField(
                    controller: controller,
                    enabled: enabled && !isSending,
                    minLines: 1,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: _AssistantText.caption(context),
                      border: InputBorder.none,
                      isCollapsed: true,
                    ),
                    style: _AssistantText.body(context),
                  ),
          ),
          _AssistantRoundAction(
            icon: isSending
                ? Icons.hourglass_empty_rounded
                : Icons.north_east_rounded,
            filled: true,
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}

class _AssistantInlineTabs extends StatelessWidget {
  const _AssistantInlineTabs({required this.labels});

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return _AssistantSegmentTabs(
      labels: labels,
      selectedIndex: 0,
      onChanged: (__) {},
    );
  }
}

class _AssistantSegmentTabs extends StatelessWidget {
  const _AssistantSegmentTabs({
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = _LawAssistantPalette.of(context);
    return Container(
      height: 39.h,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: palette.divider)),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemBuilder: (context, index) {
          final active = selectedIndex == index;
          return InkWell(
            onTap: () => onChanged(index),
            child: Container(
              constraints: BoxConstraints(minWidth: 42.w),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: active ? palette.accent : Colors.transparent,
                    width: 1.4,
                  ),
                ),
              ),
              child: Text(
                labels[index],
                style: _AssistantText.caption(context).copyWith(
                  color: active ? palette.accent : palette.primaryText,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AssistantBulletCard extends StatelessWidget {
  const _AssistantBulletCard({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return _AssistantCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final item in items)
            Padding(
              padding: EdgeInsets.only(bottom: 6.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: _AssistantText.body(context)),
                  Expanded(
                      child: Text(item, style: _AssistantText.body(context))),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _AssistantSearchField extends StatelessWidget {
  const _AssistantSearchField({
    required this.hint,
    this.controller,
  });

  final String hint;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    final palette = _LawAssistantPalette.of(context);
    return Container(
      height: 42.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: palette.softMist,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: palette.mutedText, size: 18.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: controller == null
                ? Text(hint, style: _AssistantText.caption(context))
                : TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: _AssistantText.caption(context),
                      border: InputBorder.none,
                      isCollapsed: true,
                    ),
                    style: _AssistantText.body(context),
                  ),
          ),
        ],
      ),
    );
  }
}

class _AssistantRecordTile extends StatelessWidget {
  const _AssistantRecordTile({
    required this.conversation,
    required this.onTap,
  });

  final LawAssistantConversation conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: _AssistantCard(
        margin: EdgeInsets.only(bottom: 9.h),
        child: Row(
          children: [
            Icon(Icons.notes_rounded,
                color: _LawAssistantPalette.of(context).accent, size: 22.sp),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(conversation.title, style: _AssistantText.tile(context)),
                  SizedBox(height: 3.h),
                  Text(conversation.preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _AssistantText.caption(context)),
                ],
              ),
            ),
            Text(_assistantDateLabel(conversation.updatedAt),
                style: _AssistantText.caption(context)),
          ],
        ),
      ),
    );
  }
}

class _AssistantSavedTile extends StatelessWidget {
  const _AssistantSavedTile({
    required this.item,
    required this.onTap,
    required this.onRemove,
    required this.isManaging,
  });

  final _AssistantSavedItem item;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final bool isManaging;

  @override
  Widget build(BuildContext context) {
    final palette = _LawAssistantPalette.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: _AssistantCard(
        margin: EdgeInsets.only(bottom: 9.h),
        child: Row(
          children: [
            Icon(item.icon, color: palette.accent, size: 22.sp),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: _AssistantText.tile(context)),
                  SizedBox(height: 3.h),
                  Text('收藏於 ${item.date}',
                      style: _AssistantText.caption(context)),
                ],
              ),
            ),
            if (isManaging)
              _AssistantRoundAction(
                icon: Icons.close_rounded,
                onTap: onRemove,
              ),
          ],
        ),
      ),
    );
  }
}

class _AssistantSettingRow extends StatelessWidget {
  const _AssistantSettingRow({
    required this.title,
    this.value,
    required this.onTap,
  });

  final String title;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = _LawAssistantPalette.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: palette.divider)),
        ),
        child: Row(
          children: [
            Expanded(child: Text(title, style: _AssistantText.body(context))),
            if (value != null)
              Text(value!, style: _AssistantText.caption(context)),
            SizedBox(width: 8.w),
            Icon(Icons.chevron_right_rounded,
                color: palette.mutedText, size: 18.sp),
          ],
        ),
      ),
    );
  }
}

class _AssistantSwitchRow extends StatelessWidget {
  const _AssistantSwitchRow({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = _LawAssistantPalette.of(context);
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: palette.divider)),
      ),
      child: Row(
        children: [
          Expanded(child: Text(title, style: _AssistantText.body(context))),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: palette.accent,
          ),
        ],
      ),
    );
  }
}

class _AssistantPlanCard extends StatelessWidget {
  const _AssistantPlanCard({
    required this.quota,
    required this.onUpgrade,
  });

  final String quota;
  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    final palette = _LawAssistantPalette.of(context);
    return _AssistantCard(
      background: palette.softPaper,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Demo 會員', style: _AssistantText.section(context)),
          SizedBox(height: 8.h),
          Text('每日可提問 5 次', style: _AssistantText.body(context)),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: 0.8,
                  color: palette.accent,
                  backgroundColor: palette.cardSurface,
                ),
              ),
              SizedBox(width: 12.w),
              Text(quota, style: _AssistantText.caption(context)),
            ],
          ),
          SizedBox(height: 12.h),
          Align(
            alignment: Alignment.centerRight,
            child: _AssistantMiniButton(label: '升級 Pro', onTap: onUpgrade),
          ),
        ],
      ),
    );
  }
}

class _AssistantPlanTable extends StatelessWidget {
  const _AssistantPlanTable();

  @override
  Widget build(BuildContext context) {
    final rows = const [
      ['每日提問次數', '3 次', '5 次', '無限次'],
      ['小法助記憶', '有限', '完整', '完整'],
      ['引用法條數', '3 則', '5 則', '無限'],
      ['追蹤法條提醒', '-', '-', '✓'],
    ];

    return _AssistantCard(
      padding: EdgeInsets.all(10.w),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1.5),
          1: FlexColumnWidth(),
          2: FlexColumnWidth(),
          3: FlexColumnWidth(),
        },
        children: [
          TableRow(
            children: ['功能', '訪客', 'Demo', 'Pro']
                .map((text) => _PlanCell(text: text, header: true))
                .toList(),
          ),
          for (final row in rows)
            TableRow(
              children: row.map((text) => _PlanCell(text: text)).toList(),
            ),
        ],
      ),
    );
  }
}

class _PlanCell extends StatelessWidget {
  const _PlanCell({required this.text, this.header = false});

  final String text;
  final bool header;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 3.w),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: _AssistantText.caption(context).copyWith(
          fontWeight: header ? FontWeight.w900 : FontWeight.w600,
        ),
      ),
    );
  }
}

class _AssistantEmptyIllustration extends StatelessWidget {
  const _AssistantEmptyIllustration();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/assistant/law_assistant_empty.png',
      width: 170.w,
      height: 120.h,
      fit: BoxFit.contain,
    );
  }
}

class _AssistantBottomAction extends StatelessWidget {
  const _AssistantBottomAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Column(
        children: [
          Icon(icon,
              size: 22.sp, color: _LawAssistantPalette.of(context).primaryText),
          SizedBox(height: 4.h),
          Text(label, style: _AssistantText.caption(context)),
        ],
      ),
    );
  }
}

class _AssistantCard extends StatelessWidget {
  const _AssistantCard({
    required this.child,
    this.background,
    this.padding,
    this.margin,
  });

  final Widget child;
  final Color? background;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final palette = _LawAssistantPalette.of(context);
    return Container(
      width: double.infinity,
      margin: margin,
      padding: padding ?? EdgeInsets.all(13.w),
      decoration: BoxDecoration(
        color: background ?? palette.cardSurface,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: background == null ? Colors.transparent : palette.cardStroke,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _AssistantPrimaryButton extends StatelessWidget {
  const _AssistantPrimaryButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = _LawAssistantPalette.of(context);
    return SizedBox(
      width: double.infinity,
      height: 46.h,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: palette.accent,
          foregroundColor: palette.inverseText,
          disabledBackgroundColor: palette.subtleSurface,
          disabledForegroundColor: palette.mutedText,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        ),
        child: Text(label),
      ),
    );
  }
}

class _AssistantSecondaryButton extends StatelessWidget {
  const _AssistantSecondaryButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = _LawAssistantPalette.of(context);
    return SizedBox(
      width: double.infinity,
      height: 42.h,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.accent,
          side: BorderSide(color: palette.cardStroke),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        ),
        child: Text(label),
      ),
    );
  }
}

class _AssistantMiniButton extends StatelessWidget {
  const _AssistantMiniButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = _LawAssistantPalette.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: palette.accent,
          borderRadius: BorderRadius.circular(999.r),
        ),
        child: Text(label, style: _AssistantText.button(context)),
      ),
    );
  }
}

class _AssistantText {
  static TextStyle navTitle(BuildContext context) => TextStyle(
        color: _LawAssistantPalette.of(context).primaryText,
        fontSize: 17.sp,
        height: 1.2,
        fontWeight: FontWeight.w900,
      );

  static TextStyle section(BuildContext context) => TextStyle(
        color: _LawAssistantPalette.of(context).primaryText,
        fontSize: 16.sp,
        height: 1.32,
        fontWeight: FontWeight.w900,
      );

  static TextStyle tile(BuildContext context) => TextStyle(
        color: _LawAssistantPalette.of(context).primaryText,
        fontSize: 13.sp,
        height: 1.34,
        fontWeight: FontWeight.w900,
      );

  static TextStyle body(BuildContext context) => TextStyle(
        color: _LawAssistantPalette.of(context).primaryText,
        fontSize: 12.sp,
        height: 1.55,
        fontWeight: FontWeight.w600,
      );

  static TextStyle caption(BuildContext context) => TextStyle(
        color: _LawAssistantPalette.of(context).mutedText,
        fontSize: 11.sp,
        height: 1.35,
        fontWeight: FontWeight.w600,
      );

  static TextStyle action(BuildContext context) => TextStyle(
        color: _LawAssistantPalette.of(context).accent,
        fontSize: 11.sp,
        fontWeight: FontWeight.w900,
      );

  static TextStyle button(BuildContext context) => TextStyle(
        color: _LawAssistantPalette.of(context).inverseText,
        fontSize: 11.sp,
        fontWeight: FontWeight.w900,
      );
}

class _AssistantSavedItem {
  const _AssistantSavedItem({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.icon,
  });

  final String id;
  final String title;
  final String category;
  final String date;
  final IconData icon;
}

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

String _assistantDateLabel(DateTime date) {
  final now = DateTime.now();
  if (date.year == now.year && date.month == now.month && date.day == now.day) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
  return '${date.month}/${date.day}';
}

String _assistantFullDateLabel(DateTime date) {
  return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
}

String _assistantDateTimeLabel(DateTime date) {
  return '${_assistantFullDateLabel(date)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}

const _assistantHotQuestions = [
  '房東不退押金怎麼辦？',
  '被公司要求加班但沒有加班費？',
  '網路上被罵可以提告嗎？',
  '車禍對方不理賠怎麼處理？',
];

final _mockPrototypeConversation = _assistantMockRecords.first;

final _assistantMockRecords = [
  LawAssistantConversation(
    id: 'mock-record-rent',
    title: '租屋退租押金問題',
    preview: '房東說要扣押金，但我覺得沒有依據，怎麼辦？',
    updatedAt: DateTime(2024, 6, 21, 9, 41),
    categoryLabel: '租屋',
    messages: [
      LawAssistantMessage(
        id: 'mock-record-rent-user',
        role: LawAssistantMessageRole.user,
        content: '我在租屋退租後，房東說要扣押金，我覺得不合理，怎麼辦？',
        createdAt: DateTime(2024, 6, 21, 9, 41),
      ),
      LawAssistantMessage(
        id: 'mock-record-rent-assistant',
        role: LawAssistantMessageRole.assistant,
        content: '小法助的整理結果',
        createdAt: DateTime(2024, 6, 21, 9, 42),
        answer: const LawAssistantAnswer(
          problemDirection: '房東如扣押金沒有合理依據，你有權要求返還押金。',
          relatedContent: '請先整理租約、押金收據、點交照片、修繕明細與對話紀錄。',
          nextStep: '若房東仍不回覆，可考慮寄存證信函或申請調解。',
          evidenceNeeded: '租約、押金收據、匯款紀錄、照片、LINE 對話。',
          possibleLegalIssues: '租賃契約、損害賠償、押金返還。',
          recommendedActions: '先書面要求房東說明扣款理由，再保存所有往來紀錄。',
        ),
      ),
    ],
  ),
  LawAssistantConversation(
    id: 'mock-record-work',
    title: '被公司要求加班但無加班費',
    preview: '公司說加班只能補休，不能領加班費。',
    updatedAt: DateTime(2024, 6, 20, 18, 10),
    categoryLabel: '勞資',
  ),
  LawAssistantConversation(
    id: 'mock-record-online',
    title: '網路留言可以提告嗎？',
    preview: '在社群被辱罵，可以蒐證嗎？',
    updatedAt: DateTime(2024, 6, 19, 12, 30),
    categoryLabel: '刑事',
  ),
];

final _assistantPrototypeCitations = [
  LawAssistantCitation(
    title: '民法 第 425 條（債務不履行）',
    sourceType: LawAssistantCitationSourceType.official,
    url: 'https://law.moj.gov.tw/',
    updatedAt: DateTime(2026, 1, 1),
    lawName: '民法',
    articleNumber: '第 425 條',
  ),
  LawAssistantCitation(
    title: '民法 第 183 條（損害賠償）',
    sourceType: LawAssistantCitationSourceType.official,
    url: 'https://law.moj.gov.tw/',
    updatedAt: DateTime(2026, 1, 1),
    lawName: '民法',
    articleNumber: '第 183 條',
  ),
  LawAssistantCitation(
    title: '租賃住宅市場發展及管理條例 第 16 條',
    sourceType: LawAssistantCitationSourceType.statute,
    url: 'https://law.moj.gov.tw/',
    updatedAt: DateTime(2026, 1, 1),
    lawName: '租賃住宅市場發展及管理條例',
    articleNumber: '第 16 條',
  ),
];

const _assistantSavedItems = [
  _AssistantSavedItem(
    id: 'mock-law-425',
    title: '民法 第 425 條',
    category: '法條',
    date: '2024/06/21',
    icon: Icons.article_outlined,
  ),
  _AssistantSavedItem(
    id: 'mock-conversation-rent',
    title: '租屋退租押金問題',
    category: '對話',
    date: '2024/06/21',
    icon: Icons.chat_bubble_outline_rounded,
  ),
  _AssistantSavedItem(
    id: 'mock-case-rent',
    title: '來真的租屋糾紛案例',
    category: '案例',
    date: '2024/06/19',
    icon: Icons.folder_open_outlined,
  ),
  _AssistantSavedItem(
    id: 'mock-law-183',
    title: '民法 第 183 條',
    category: '法條',
    date: '2024/06/18',
    icon: Icons.article_outlined,
  ),
];
