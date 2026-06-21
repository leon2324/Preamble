part of '../following_page.dart';

// 台灣繁體中文教學註解：
// 這個 part 檔集中放追蹤頁的卡片、列表 tile 與小型展示 helper。
// 事件處理都透過 callback 傳入，不在這裡修改追蹤、收藏或 AppState 邏輯。

class _MemberCard extends StatelessWidget {
  const _MemberCard({required this.appState});

  final LawAppState appState;

  @override
  Widget build(BuildContext context) {
    final isPro = appState.isSubscriber;
    return _ProtoCard(
      child: Row(
        children: [
          SvgPicture.asset(_ProfileAsset.avatar, width: 52.w, height: 52.w),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        isPro ? 'Pro 會員' : 'Demo 會員',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _FollowText.tileTitle(),
                      ),
                    ),
                    if (!isPro) ...[
                      SizedBox(width: 6.w),
                      const _TinyBadge(label: 'Demo'),
                    ],
                  ],
                ),
                SizedBox(height: 4.h),
                Text('每日 AI 提問額度\n4 / 5 次', style: _FollowText.caption()),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: _FollowColors.primary,
              borderRadius: BorderRadius.circular(99.r),
            ),
            child: Text(isPro ? '已啟用' : '升級 Pro',
                style: _FollowText.buttonSmall()),
          ),
        ],
      ),
    );
  }
}

class _DemoUpsellCard extends StatelessWidget {
  const _DemoUpsellCard({required this.appState});

  final LawAppState appState;

  @override
  Widget build(BuildContext context) {
    if (appState.isSubscriber) {
      return const SizedBox.shrink();
    }

    return _ProtoCard(
      background: _FollowColors.softPaper,
      child: Row(
        children: [
          _IconTile(
              icon: Icons.workspace_premium_rounded, color: _FollowColors.gold),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Demo 會員專屬功能', style: _FollowText.tileTitle()),
                SizedBox(height: 4.h),
                Text('升級 Pro 會員，解鎖更多追蹤與整理功能', style: _FollowText.caption()),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              color: _FollowColors.text, size: 20.sp),
        ],
      ),
    );
  }
}

class _ShortcutGrid extends StatelessWidget {
  const _ShortcutGrid({
    required this.onCollections,
    required this.onNotes,
    required this.onQuestions,
    required this.onDrafts,
  });

  final VoidCallback onCollections;
  final VoidCallback onNotes;
  final VoidCallback onQuestions;
  final VoidCallback onDrafts;

  @override
  Widget build(BuildContext context) {
    final items = [
      _ShortcutItem('我的收藏', '', Icons.star_border_rounded, onCollections),
      _ShortcutItem('我的筆記', '', Icons.note_alt_outlined, onNotes),
      _ShortcutItem('文件草稿', '', Icons.description_outlined, onDrafts),
      _ShortcutItem('提問紀錄', '', Icons.chat_bubble_outline_rounded, onQuestions),
    ];

    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          Expanded(child: _ShortcutCard(item: items[i])),
          if (i != items.length - 1) SizedBox(width: 8.w),
        ],
      ],
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  const _ShortcutCard({required this.item});

  final _ShortcutItem item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: SizedBox(
        height: 70.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 34.w,
              height: 34.w,
              decoration: const BoxDecoration(
                color: _FollowColors.softMist,
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, color: _FollowColors.text, size: 19.sp),
            ),
            SizedBox(height: 7.h),
            Text(
              item.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: _FollowText.captionStrong(),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationGuide extends StatelessWidget {
  const _NavigationGuide({
    required this.onUpdates,
    required this.onCollections,
    required this.onNotes,
    required this.onSettings,
  });

  final VoidCallback onUpdates;
  final VoidCallback onCollections;
  final VoidCallback onNotes;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavGuideItem(
          '查看動態', '今日更新與提醒', Icons.notifications_none_rounded, onUpdates),
      _NavGuideItem(
          '整理收藏', '案件、法條與文章', Icons.star_border_rounded, onCollections),
      _NavGuideItem('維護筆記', '個人備忘與重點', Icons.edit_note_rounded, onNotes),
      _NavGuideItem('通知設定', '提醒與會員說明', Icons.tune_rounded, onSettings),
    ];

    return _ProtoCard(
      background: _FollowColors.softPaper,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            _NavigationGuideRow(item: items[i]),
            if (i != items.length - 1) const _SoftDivider(),
          ],
        ],
      ),
    );
  }
}

class _NavigationGuideRow extends StatelessWidget {
  const _NavigationGuideRow({required this.item});

  final _NavGuideItem item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 9.h),
        child: Row(
          children: [
            Icon(item.icon, color: _FollowColors.primary, size: 19.sp),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: _FollowText.tileTitle()),
                  SizedBox(height: 2.h),
                  Text(item.subtitle, style: _FollowText.caption()),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: _FollowColors.mutedText, size: 18.sp),
          ],
        ),
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.summary, required this.onTrackTab});

  final FollowingSummary summary;
  final ValueChanged<_FollowTab> onTrackTab;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryBox(
            label: '案件',
            value: '${12 + summary.followedCaseIds.length}',
            onTap: () => onTrackTab(_FollowTab.cases),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _SummaryBox(
            label: '法條',
            value: '${9 + summary.followedStatuteIds.length}',
            onTap: () => onTrackTab(_FollowTab.statutes),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _SummaryBox(
            label: '主題',
            value: '${6 + summary.followedTopicIds.length}',
            onTap: () => onTrackTab(_FollowTab.topics),
          ),
        ),
      ],
    );
  }
}

class _SummaryBox extends StatelessWidget {
  const _SummaryBox({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _ProtoCard(
      onTap: onTap,
      child: Column(
        children: [
          Text(label, style: _FollowText.captionStrong()),
          SizedBox(height: 4.h),
          Text(value, style: _FollowText.section()),
        ],
      ),
    );
  }
}

class _TrackSummaryRow extends StatelessWidget {
  const _TrackSummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: _ProtoCard(
        onTap: onTap,
        child: Row(
          children: [
            _IconTile(icon: icon, color: _FollowColors.secondary),
            SizedBox(width: 12.w),
            Expanded(child: Text(label, style: _FollowText.tileTitle())),
            Text(value, style: _FollowText.tileTitle()),
            SizedBox(width: 8.w),
            Icon(Icons.chevron_right_rounded,
                color: _FollowColors.text, size: 20.sp),
          ],
        ),
      ),
    );
  }
}

class _UpdateCompactTile extends StatelessWidget {
  const _UpdateCompactTile({required this.update, required this.onTap});

  final _UpdateItem update;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _ProtoCard(
      onTap: onTap,
      child: Row(
        children: [
          _IconTile(icon: update.icon, color: update.color),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(update.type, style: _FollowText.captionStrong()),
                SizedBox(height: 4.h),
                Text(update.title, style: _FollowText.tileTitle()),
                SizedBox(height: 4.h),
                Text(update.subtitle, style: _FollowText.caption()),
              ],
            ),
          ),
          Text(update.timeLabel, style: _FollowText.caption()),
          SizedBox(width: 6.w),
          if (update.unread)
            Container(
              width: 6.w,
              height: 6.w,
              decoration: const BoxDecoration(
                color: _FollowColors.orange,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}

class _UpdateFullTile extends StatelessWidget {
  const _UpdateFullTile({required this.item, required this.onTap});

  final _UpdateItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _ProtoCard(
      onTap: onTap,
      child: Row(
        children: [
          _IconTile(icon: item.icon, color: item.color),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.type, style: _FollowText.captionStrong()),
                SizedBox(height: 5.h),
                Text(item.title, style: _FollowText.tileTitle()),
                SizedBox(height: 4.h),
                Text(item.subtitle, style: _FollowText.caption()),
              ],
            ),
          ),
          if (item.unread) const _NewBadge(),
        ],
      ),
    );
  }
}

class _FollowItemTile extends StatelessWidget {
  const _FollowItemTile({required this.item, required this.onTap});

  final _FollowItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _ProtoCard(
      onTap: onTap,
      child: Row(
        children: [
          _Thumbnail(icon: item.icon),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: _FollowText.tileTitle()),
                SizedBox(height: 4.h),
                Text(item.meta, style: _FollowText.caption()),
              ],
            ),
          ),
          if (item.unread) const _NewBadge(),
        ],
      ),
    );
  }
}

class _LatestUpdateCard extends StatelessWidget {
  const _LatestUpdateCard({required this.item});

  final _FollowItem item;

  @override
  Widget build(BuildContext context) {
    return _ProtoCard(
      background: _FollowColors.softPaper,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('最新更新', style: _FollowText.section()),
                SizedBox(height: 6.h),
                Text(item.latestUpdate, style: _FollowText.bodyStrong()),
                SizedBox(height: 14.h),
                _SecondaryButton(
                  label:
                      item.kind == _FollowDetailKind.statute ? '查看內容' : '查看更新',
                  onPressed: () {},
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          _ClipboardIllustration(icon: item.icon),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return _ProtoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: _FollowText.section()),
          SizedBox(height: 10.h),
          Text(body, style: _FollowText.bodyStrong()),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.isStatute,
    required this.updateNotification,
    required this.secondaryNotification,
    required this.onUpdateChanged,
    required this.onSecondaryChanged,
  });

  final bool isStatute;
  final bool updateNotification;
  final bool secondaryNotification;
  final ValueChanged<bool> onUpdateChanged;
  final ValueChanged<bool> onSecondaryChanged;

  @override
  Widget build(BuildContext context) {
    return _ProtoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('追蹤設定', style: _FollowText.section()),
          SizedBox(height: 12.h),
          _SwitchRow(
            title: '更新通知',
            value: updateNotification,
            onChanged: onUpdateChanged,
          ),
          _SwitchRow(
            title: isStatute ? '新增生活案例時通知' : '新增相關案件時通知',
            value: secondaryNotification,
            onChanged: onSecondaryChanged,
          ),
          _LockedRow(title: isStatute ? 'AI 應用情境提醒（Pro）' : 'AI 重點摘要（Pro）'),
        ],
      ),
    );
  }
}

class _NoteTile extends StatelessWidget {
  const _NoteTile({
    required this.note,
    required this.onTap,
    this.background = Colors.white,
  });

  final _NoteItem note;
  final VoidCallback onTap;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return _ProtoCard(
      onTap: onTap,
      background: background,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(note.title, style: _FollowText.tileTitle()),
                SizedBox(height: 4.h),
                Text('建立於 ${note.date}', style: _FollowText.caption()),
              ],
            ),
          ),
          Icon(Icons.star_border_rounded,
              color: _FollowColors.primary, size: 20.sp),
        ],
      ),
    );
  }
}

class _NumberedLine extends StatelessWidget {
  const _NumberedLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 5.h),
      child: Text(text, style: _FollowText.bodyStrong()),
    );
  }
}

class _BulletLine extends StatelessWidget {
  const _BulletLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 5.h),
      child: Text('• $text', style: _FollowText.bodyStrong()),
    );
  }
}

class _SuggestTile extends StatelessWidget {
  const _SuggestTile({required this.item, required this.onTap});

  final _FollowItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _ProtoCard(
      child: Row(
        children: [
          _IconTile(icon: item.icon, color: _FollowColors.gold),
          SizedBox(width: 12.w),
          Expanded(child: Text(item.title, style: _FollowText.tileTitle())),
          SizedBox(
            width: 76.w,
            height: 34.h,
            child: OutlinedButton.icon(
              onPressed: onTap,
              icon: Icon(Icons.add_rounded, size: 15.sp),
              label: const Text('追蹤'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                foregroundColor: _FollowColors.primary,
                side: const BorderSide(color: _FollowColors.borderDark),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CollectionTile extends StatelessWidget {
  const _CollectionTile({required this.item, required this.onTap});

  final _CollectionItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _ProtoCard(
      onTap: onTap,
      child: Row(
        children: [
          _IconTile(icon: item.icon, color: item.color),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: _FollowText.tileTitle()),
                SizedBox(height: 4.h),
                Text(item.subtitle, style: _FollowText.caption()),
              ],
            ),
          ),
          Icon(Icons.more_horiz_rounded,
              color: _FollowColors.text, size: 20.sp),
        ],
      ),
    );
  }
}

class _QuestionTile extends StatelessWidget {
  const _QuestionTile({required this.item});

  final _QuestionItem item;

  @override
  Widget build(BuildContext context) {
    return _ProtoCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: _FollowText.tileTitle()),
                SizedBox(height: 5.h),
                Text(item.time, style: _FollowText.caption()),
              ],
            ),
          ),
          Text(item.status, style: _FollowText.action()),
        ],
      ),
    );
  }
}

class _DraftTile extends StatelessWidget {
  const _DraftTile({required this.item});

  final _DraftItem item;

  @override
  Widget build(BuildContext context) {
    return _ProtoCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: _FollowText.tileTitle()),
                SizedBox(height: 5.h),
                Text(item.time, style: _FollowText.caption()),
                SizedBox(height: 7.h),
                _SmallPill(label: item.tag),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              color: _FollowColors.text, size: 20.sp),
        ],
      ),
    );
  }
}
