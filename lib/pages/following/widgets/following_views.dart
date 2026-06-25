part of '../following_page.dart';

// 台灣繁體中文教學註解：
// 這個 part 檔只收納 Following Page 的各個頁面 view 組裝。
// 頁面狀態、AppState 寫入與 route/navigation 仍保留在 following_page.dart。

class _HomeView extends StatelessWidget {
  const _HomeView({
    required this.appState,
    required this.summary,
    required this.onUpdates,
    required this.onTrackTab,
    required this.onCollections,
    required this.onNotes,
    required this.onQuestions,
    required this.onDrafts,
    required this.onPlan,
    required this.onSettings,
  });

  final LawAppState appState;
  final FollowingSummary summary;
  final VoidCallback onUpdates;
  final ValueChanged<_FollowTab> onTrackTab;
  final VoidCallback onCollections;
  final VoidCallback onNotes;
  final VoidCallback onQuestions;
  final VoidCallback onDrafts;
  final VoidCallback onPlan;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MemberCard(appState: appState, onPlan: onPlan),
        SizedBox(height: 14.h),
        _SectionHeader(title: '今天的重點動態', action: '查看全部', onTap: onUpdates),
        SizedBox(height: 10.h),
        for (final update in _updates.take(3)) ...[
          _UpdateCompactTile(update: update, onTap: onUpdates),
          SizedBox(height: 9.h),
        ],
        SizedBox(height: 18.h),
        _SectionHeader(title: '我的追蹤總覽', action: '查看全部', onTap: onUpdates),
        SizedBox(height: 10.h),
        _SummaryGrid(summary: summary, onTrackTab: onTrackTab),
        SizedBox(height: 18.h),
        Text('常用捷徑', style: _FollowText.section()),
        SizedBox(height: 10.h),
        _ShortcutGrid(
          onCollections: onCollections,
          onNotes: onNotes,
          onQuestions: onQuestions,
          onDrafts: onDrafts,
        ),
        SizedBox(height: 12.h),
        _NavigationGuide(
          onUpdates: onUpdates,
          onCollections: onCollections,
          onNotes: onNotes,
          onSettings: onSettings,
        ),
        SizedBox(height: 12.h),
        _DemoUpsellCard(appState: appState, onPlan: onPlan),
        SizedBox(height: 8.h),
        _FooterIllustration(),
      ],
    );
  }
}

class _UpdatesView extends StatelessWidget {
  const _UpdatesView({
    required this.items,
    required this.selectedTabIndex,
    required this.onTabChanged,
    required this.onOpen,
    required this.onReadAll,
    required this.onTrackTab,
  });

  final List<_UpdateItem> items;
  final int selectedTabIndex;
  final ValueChanged<int> onTabChanged;
  final ValueChanged<_UpdateItem> onOpen;
  final VoidCallback onReadAll;
  final ValueChanged<_FollowTab> onTrackTab;

  @override
  Widget build(BuildContext context) {
    final filteredItems = _itemsForTab();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TabStrip(
          labels: const ['全部', '案件', '法條', '主題', '關鍵字'],
          selectedIndex: selectedTabIndex,
          onChanged: onTabChanged,
        ),
        SizedBox(height: 18.h),
        _SectionHeader(
          title: '今日更新',
          action: '查看全部',
          onTap: () => onTabChanged(0),
        ),
        SizedBox(height: 10.h),
        Text('2026 / 05 / 01', style: _FollowText.captionStrong()),
        SizedBox(height: 10.h),
        if (filteredItems.isEmpty)
          const _EmptyStateCard(message: '這個分類目前沒有新動態。')
        else
          for (final item in filteredItems) ...[
            _UpdateFullTile(item: item, onTap: () => onOpen(item)),
            SizedBox(height: 10.h),
          ],
        SizedBox(height: 16.h),
        Text('追蹤中', style: _FollowText.section()),
        SizedBox(height: 10.h),
        _TrackSummaryRow(
          icon: Icons.inventory_2_outlined,
          label: '案件',
          value: '12',
          onTap: () => onTrackTab(_FollowTab.cases),
        ),
        _TrackSummaryRow(
          icon: Icons.menu_book_outlined,
          label: '法條',
          value: '9',
          onTap: () => onTrackTab(_FollowTab.statutes),
        ),
        _TrackSummaryRow(
          icon: Icons.label_outline_rounded,
          label: '主題',
          value: '6',
          onTap: () => onTrackTab(_FollowTab.topics),
        ),
        _TrackSummaryRow(
          icon: Icons.tag_rounded,
          label: '關鍵字',
          value: '5',
          onTap: () => onTrackTab(_FollowTab.keywords),
        ),
        SizedBox(height: 12.h),
        _PrimaryButton(label: '全部標示為已讀', onPressed: onReadAll),
      ],
    );
  }

  List<_UpdateItem> _itemsForTab() {
    if (selectedTabIndex == 0) return items.take(4).toList();
    final label = const ['全部', '案件', '法條', '主題', '關鍵字'][selectedTabIndex];
    return items.where((item) => item.category == label).toList();
  }
}

class _TabsView extends StatelessWidget {
  const _TabsView({
    required this.summary,
    required this.tab,
    required this.selectedSegmentIndex,
    required this.onTab,
    required this.onSegmentChanged,
    required this.onOpen,
    required this.onAddTrack,
  });

  final FollowingSummary summary;
  final _FollowTab tab;
  final int selectedSegmentIndex;
  final ValueChanged<_FollowTab> onTab;
  final ValueChanged<int> onSegmentChanged;
  final ValueChanged<_FollowItem> onOpen;
  final VoidCallback onAddTrack;

  @override
  Widget build(BuildContext context) {
    final items = _itemsForTab(tab, summary);
    final filteredItems = _filteredItems(items);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FollowTabBar(tab: tab, onTab: onTab),
        SizedBox(height: 12.h),
        _TabStrip(
          labels: _segmentLabels(tab),
          selectedIndex: selectedSegmentIndex,
          onChanged: onSegmentChanged,
        ),
        SizedBox(height: 18.h),
        Row(
          children: [
            Expanded(
              child: Text('${_tabTitle(tab)} ${filteredItems.length} 個',
                  style: _FollowText.section()),
            ),
            Text('編輯', style: _FollowText.action()),
          ],
        ),
        SizedBox(height: 10.h),
        if (filteredItems.isEmpty)
          const _EmptyStateCard(message: '目前沒有符合這個分類的追蹤項目。')
        else
          for (final item in filteredItems) ...[
            _FollowItemTile(item: item, onTap: () => onOpen(item)),
            SizedBox(height: 10.h),
          ],
        SizedBox(height: 12.h),
        _SecondaryButton(
          label: tab == _FollowTab.statutes ? '+ 新增追蹤法條' : '+ 新增追蹤案件',
          onPressed: onAddTrack,
        ),
      ],
    );
  }

  List<String> _segmentLabels(_FollowTab tab) {
    switch (tab) {
      case _FollowTab.cases:
        return const ['全部 12', '更新中 6', '已結案 6'];
      case _FollowTab.statutes:
        return const ['全部 9', '最近更新', '我關注的'];
      case _FollowTab.topics:
        return const ['全部 6', '最近更新', '生活分類'];
      case _FollowTab.keywords:
        return const ['全部 5', '高頻', '低頻'];
    }
  }

  List<_FollowItem> _filteredItems(List<_FollowItem> items) {
    if (selectedSegmentIndex == 0) return items;
    if (selectedSegmentIndex == 1) {
      return items.where((item) => item.unread).toList();
    }
    return items.where((item) => !item.unread).toList();
  }

  List<_FollowItem> _itemsForTab(_FollowTab tab, FollowingSummary summary) {
    switch (tab) {
      case _FollowTab.cases:
        return _mergeFollowItems(_caseItems, _caseItemsForSummary(summary));
      case _FollowTab.statutes:
        return _mergeFollowItems(
            _statuteItems, _statuteItemsForSummary(summary));
      case _FollowTab.topics:
        return _mergeFollowItems(_topicItems, _topicItemsForSummary(summary));
      case _FollowTab.keywords:
        return _keywordItems;
    }
  }

  String _tabTitle(_FollowTab tab) {
    switch (tab) {
      case _FollowTab.cases:
        return '追蹤的案件';
      case _FollowTab.statutes:
        return '追蹤的法條';
      case _FollowTab.topics:
        return '追蹤的主題';
      case _FollowTab.keywords:
        return '追蹤的關鍵字';
    }
  }
}

class _DetailView extends StatelessWidget {
  const _DetailView({
    required this.item,
    required this.updateNotification,
    required this.caseNotification,
    required this.onUpdateChanged,
    required this.onSecondaryChanged,
    required this.onExternal,
  });

  final _FollowItem item;
  final bool updateNotification;
  final bool caseNotification;
  final ValueChanged<bool> onUpdateChanged;
  final ValueChanged<bool> onSecondaryChanged;
  final VoidCallback onExternal;

  @override
  Widget build(BuildContext context) {
    final isStatute = item.kind == _FollowDetailKind.statute;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LatestUpdateCard(item: item, onPressed: onExternal),
        SizedBox(height: 14.h),
        _InfoCard(
          title: isStatute ? '法條內容重點' : '案件簡介',
          body: item.description,
        ),
        SizedBox(height: 14.h),
        _SettingsCard(
          isStatute: isStatute,
          updateNotification: updateNotification,
          secondaryNotification: caseNotification,
          onUpdateChanged: onUpdateChanged,
          onSecondaryChanged: onSecondaryChanged,
        ),
        SizedBox(height: 18.h),
        _PrimaryButton(
          label: isStatute ? '前往法條頁面' : '前往案件頁面',
          onPressed: onExternal,
        ),
      ],
    );
  }
}

class _NotesView extends StatelessWidget {
  const _NotesView({
    required this.notes,
    required this.selectedTabIndex,
    required this.onTabChanged,
    required this.onOpen,
    required this.onCreateNote,
  });

  final List<_NoteItem> notes;
  final int selectedTabIndex;
  final ValueChanged<int> onTabChanged;
  final ValueChanged<_NoteItem> onOpen;
  final VoidCallback onCreateNote;

  @override
  Widget build(BuildContext context) {
    final filteredNotes = _notesForTab();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TabStrip(
          labels: const ['全部', '案件', '法條', '一般'],
          selectedIndex: selectedTabIndex,
          onChanged: onTabChanged,
        ),
        SizedBox(height: 14.h),
        if (filteredNotes.isEmpty)
          const _EmptyStateCard(message: '這個分類還沒有筆記。')
        else
          for (final note in filteredNotes) ...[
            _NoteTile(
              note: note,
              onTap: () => onOpen(note),
              background: _noteBackground(note),
            ),
            SizedBox(height: 10.h),
          ],
        SizedBox(height: 18.h),
        Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            width: 142.w,
            child: _PrimaryButton(label: '+  新增筆記', onPressed: onCreateNote),
          ),
        ),
      ],
    );
  }

  List<_NoteItem> _notesForTab() {
    if (selectedTabIndex == 0) return notes;
    if (selectedTabIndex == 1) {
      return notes.where((note) => !note.tag.contains('法條')).toList();
    }
    if (selectedTabIndex == 2) {
      return notes.where((note) => note.tag.contains('法條')).toList();
    }
    return notes.where((note) => note.tag.contains('租屋')).toList();
  }

  Color _noteBackground(_NoteItem note) {
    if (note.tag.contains('租屋')) return const Color(0xFFFFF3CC);
    if (note.tag.contains('交通')) return const Color(0xFFEFF7E9);
    if (note.tag.contains('勞資')) return const Color(0xFFFFE7E2);
    return const Color(0xFFE6F4F5);
  }
}

class _NoteDetailView extends StatelessWidget {
  const _NoteDetailView({
    required this.note,
    required this.onEdit,
    required this.onDelete,
  });

  final _NoteItem note;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SmallPill(label: '一般筆記'),
        SizedBox(height: 10.h),
        Text('建立於 ${note.date} 10:30', style: _FollowText.caption()),
        SizedBox(height: 18.h),
        Text('情境', style: _FollowText.section()),
        SizedBox(height: 8.h),
        Text(note.content, style: _FollowText.bodyStrong()),
        SizedBox(height: 18.h),
        Text('我可以怎麼做', style: _FollowText.section()),
        SizedBox(height: 8.h),
        const _NumberedLine(text: '1. 保留交屋時的照片或影片'),
        const _NumberedLine(text: '2. 提出租賃契約、押金收據與對話紀錄'),
        const _NumberedLine(text: '3. 先要求房東明列扣款理由'),
        const _NumberedLine(text: '4. 必要時申請調解或提出小額訴訟'),
        SizedBox(height: 18.h),
        Text('相關法條', style: _FollowText.section()),
        SizedBox(height: 8.h),
        _BulletLine(text: note.relatedLaw),
        _BulletLine(text: note.relatedTopic),
        SizedBox(height: 26.h),
        Row(
          children: [
            Expanded(
              child: _BottomAction(
                icon: Icons.edit_outlined,
                label: '編輯',
                onTap: onEdit,
              ),
            ),
            Expanded(
              child: _BottomAction(
                icon: Icons.share_outlined,
                label: '分享',
                onTap: () {
                  ShareSheet.show(context, title: note.title);
                },
              ),
            ),
            Expanded(
              child: _BottomAction(
                icon: Icons.delete_outline_rounded,
                label: '刪除',
                onTap: onDelete,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SearchView extends StatelessWidget {
  const _SearchView({required this.onOpen});

  final ValueChanged<_FollowItem> onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          onTapOutside: (event) {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          decoration: InputDecoration(
            hintText: '搜尋你追蹤的內容',
            prefixIcon: const Icon(Icons.search_rounded),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18.r),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        SizedBox(height: 18.h),
        Text('最近搜尋', style: _FollowText.section()),
        SizedBox(height: 10.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: const [
            _SmallPill(label: '詐騙'),
            _SmallPill(label: '民法184條'),
            _SmallPill(label: '租屋糾紛'),
            _SmallPill(label: '太陽花'),
          ],
        ),
        SizedBox(height: 18.h),
        Text('熱門追蹤建議', style: _FollowText.section()),
        SizedBox(height: 10.h),
        for (final item in _suggestedItems) ...[
          _SuggestTile(item: item, onTap: () => onOpen(item)),
          SizedBox(height: 10.h),
        ],
      ],
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView({
    required this.appState,
    required this.onTrackTab,
    required this.onPlan,
  });

  final LawAppState appState;
  final ValueChanged<_FollowTab> onTrackTab;
  final VoidCallback onPlan;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MemberCard(appState: appState, onPlan: onPlan),
        SizedBox(height: 14.h),
        _SummaryGrid(
            summary: appState.followingSummary, onTrackTab: onTrackTab),
        SizedBox(height: 14.h),
        _InfoCard(
          title: '自前為 ${appState.accessTier.label}',
          body:
              '每日 AI 提問額度：${appState.remainingAiQuota} / ${appState.accessTier.defaultDailyAiQuota} 次。收藏、筆記與追蹤資料目前先以示範資料呈現，正式同步後會改由會員後端提供。',
        ),
      ],
    );
  }
}

class _CollectionsView extends StatelessWidget {
  const _CollectionsView({
    required this.summary,
    required this.selectedTabIndex,
    required this.onTabChanged,
    required this.onOpen,
  });

  final FollowingSummary summary;
  final int selectedTabIndex;
  final ValueChanged<int> onTabChanged;
  final ValueChanged<_FollowItem> onOpen;

  @override
  Widget build(BuildContext context) {
    final items = _collectionItemsForTab(summary);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TabStrip(
          labels: const ['全部', '案件', '法條', '主題', '文章'],
          selectedIndex: selectedTabIndex,
          onChanged: onTabChanged,
        ),
        SizedBox(height: 14.h),
        if (items.isEmpty)
          const _EmptyStateCard(message: '這個分類目前沒有收藏。')
        else
          for (final item in items) ...[
            _CollectionTile(item: item, onTap: () => onOpen(_followFor(item))),
            SizedBox(height: 10.h),
          ],
        SizedBox(height: 18.h),
        _HintText('共 ${items.length} 個收藏；點擊項目可開啟詳情。'),
      ],
    );
  }

  List<_CollectionItem> _collectionItemsForTab(FollowingSummary summary) {
    final allItems = [
      ..._collectionItemsForSummary(summary),
      ..._collectionItems,
    ];
    if (selectedTabIndex == 0) return allItems;
    final category = const ['全部', '案件', '法條', '主題', '文章'][selectedTabIndex];
    return allItems.where((item) => item.category == category).toList();
  }

  _FollowItem _followFor(_CollectionItem item) {
    if (item.category == '法條') {
      return _FollowItem(
        kind: _FollowDetailKind.statute,
        title: item.title,
        meta: item.subtitle,
        description: '這是你收藏的法條；從我的 LawApp 開啟時會保留同一份收藏狀態。',
        latestUpdate: '已收藏於我的 LawApp',
        icon: item.icon,
      );
    }
    if (item.category == '案件' || item.category == '文章') {
      return _FollowItem(
        kind: _FollowDetailKind.caseItem,
        title: item.title,
        meta: item.subtitle,
        description: '這是你收藏的內容；目前先以本機收藏狀態呈現，後端同步後會補上正式摘要。',
        latestUpdate: '已收藏於我的 LawApp',
        icon: item.icon,
      );
    }
    if (item.title.contains('184')) return _statuteItems.first;
    if (item.title.contains('太陽花')) return _caseItems[1];
    if (item.title.contains('詐欺')) return _caseItems.first;
    return _topicItems.first;
  }
}

class _QuestionsView extends StatelessWidget {
  const _QuestionsView({
    required this.questions,
    required this.selectedTabIndex,
    required this.onTabChanged,
    required this.onClear,
  });

  final List<_QuestionItem> questions;
  final int selectedTabIndex;
  final ValueChanged<int> onTabChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final visibleQuestions = _questionsForTab();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TabStrip(
          labels: const ['全部', '已回答', '未回答'],
          selectedIndex: selectedTabIndex,
          onChanged: onTabChanged,
        ),
        SizedBox(height: 14.h),
        if (visibleQuestions.isEmpty)
          const _EmptyStateCard(message: '目前沒有提問紀錄。')
        else
          for (final item in visibleQuestions) ...[
            _QuestionTile(item: item),
            SizedBox(height: 10.h),
          ],
        SizedBox(height: 18.h),
        _SecondaryButton(label: '清除紀錄', onPressed: onClear),
      ],
    );
  }

  List<_QuestionItem> _questionsForTab() {
    if (selectedTabIndex == 0) return questions;
    final status = selectedTabIndex == 1 ? '已回答' : '未回答';
    return questions.where((item) => item.status == status).toList();
  }
}

class _DraftsView extends StatelessWidget {
  const _DraftsView({
    required this.selectedTabIndex,
    required this.onTabChanged,
    required this.drafts,
    required this.backendStatus,
    required this.onCreateDraft,
    required this.onOpenDraft,
  });

  final int selectedTabIndex;
  final ValueChanged<int> onTabChanged;
  final List<DocumentDraft> drafts;
  final String backendStatus;
  final VoidCallback onCreateDraft;
  final ValueChanged<_DraftItem> onOpenDraft;

  @override
  Widget build(BuildContext context) {
    final visibleDrafts = _draftsForTab();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TabStrip(
          labels: const ['全部', '協商草稿', '存證信函', '其他'],
          selectedIndex: selectedTabIndex,
          onChanged: onTabChanged,
        ),
        SizedBox(height: 14.h),
        _HintText(backendStatus),
        SizedBox(height: 14.h),
        if (visibleDrafts.isEmpty)
          const _EmptyStateCard(message: '這個分類還沒有文件草稿。')
        else
          for (final item in visibleDrafts) ...[
            _DraftTile(item: item, onTap: () => onOpenDraft(item)),
            SizedBox(height: 10.h),
          ],
        SizedBox(height: 18.h),
        _SecondaryButton(label: '+ 建立新草稿', onPressed: onCreateDraft),
      ],
    );
  }

  List<_DraftItem> _draftsForTab() {
    final items = drafts.map(_DraftItem.fromDocument).toList(growable: false);
    if (selectedTabIndex == 0) return items;
    final tag = const ['全部', '協商草稿', '存證信函', '其他'][selectedTabIndex];
    return items.where((item) => item.tag == tag).toList();
  }
}

class _PlanView extends StatelessWidget {
  const _PlanView({required this.appState, required this.onUpgrade});

  final LawAppState appState;
  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    final isPro = appState.isSubscriber;
    return Column(
      children: [
        _ProtoCard(
          background: _FollowColors.softPaper,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(isPro ? 'Pro 會員' : 'Demo 會員', style: _FollowText.section()),
              SizedBox(height: 8.h),
              Text(
                isPro ? '無限制提問、完整 Pro 功能開放。' : '每日可提問 5 次，部分功能開放。',
                style: _FollowText.bodyStrong(),
              ),
              SizedBox(height: 12.h),
              LinearProgressIndicator(
                value: isPro ? 1 : 0.8,
                color: _FollowColors.primary,
                backgroundColor: Colors.white,
              ),
            ],
          ),
        ),
        SizedBox(height: 14.h),
        const _CheckLine(text: '追蹤、收藏、筆記同步'),
        const _CheckLine(text: '每日更新一目了然'),
        const _CheckLine(text: 'AI 摘要與提醒設定更細緻'),
        SizedBox(height: 18.h),
        _PrimaryButton(
          label: isPro ? '已啟用 Pro' : '升級 Pro 會員',
          onPressed: onUpgrade,
        ),
      ],
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView({
    required this.updateNotification,
    required this.caseNotification,
    required this.onUpdateChanged,
    required this.onCaseChanged,
    required this.onProfile,
    required this.onPlan,
    required this.onSignOut,
  });

  final bool updateNotification;
  final bool caseNotification;
  final ValueChanged<bool> onUpdateChanged;
  final ValueChanged<bool> onCaseChanged;
  final VoidCallback onProfile;
  final VoidCallback onPlan;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SettingRow(
          title: '個人資料',
          trailing: Icons.chevron_right_rounded,
          onTap: onProfile,
        ),
        _SettingRow(title: '深色模式', value: '關閉'),
        _SettingRow(
          title: '會員方案',
          value: 'Demo 會員',
          trailing: Icons.chevron_right_rounded,
          onTap: onPlan,
        ),
        _SettingRow(
          title: '資料來源',
          trailing: Icons.chevron_right_rounded,
          onTap: () => _showSettingsInfo(
            context,
            '資料來源',
            '目前法條以 MOJ 公開資料與本機備援資料呈現，案件與生活內容仍保留部分 mock seed。正式商業化前需要補上資料版本、更新時間與後端同步狀態。',
          ),
        ),
        _SettingRow(
          title: '法律免責聲明',
          trailing: Icons.chevron_right_rounded,
          onTap: () => _showSettingsInfo(
            context,
            '法律免責聲明',
            'LawApp 提供法律知識整理與自我檢查，不取代律師正式法律意見。涉及時效、訴訟或重大權益時，仍應尋求專業協助。',
          ),
        ),
        _SettingRow(
          title: '隱私權政策',
          trailing: Icons.chevron_right_rounded,
          onTap: () => _showSettingsInfo(
            context,
            '隱私權政策',
            '正式版需要在 App 內與 App Store Connect 同步提供隱私權政策，並明確說明 AI 對話、收藏、筆記與裝置資料的保存與刪除方式。',
          ),
        ),
        _SettingRow(
          title: '關於 LawApp',
          value: '版本 1.0.0',
          trailing: Icons.chevron_right_rounded,
          onTap: () => _showSettingsInfo(
            context,
            '關於 LawApp',
            'LawApp 是以台灣日常法律情境為核心的法律學習與自我整理工具，目前正在 MAIC Demo 與 TestFlight 商業化前修補階段。',
          ),
        ),
        SizedBox(height: 18.h),
        Text('通知設定', style: _FollowText.section()),
        SizedBox(height: 8.h),
        _SettingRow(
          title: '更新頻率',
          value: updateNotification ? '即時' : '每日摘要',
          trailing: Icons.chevron_right_rounded,
          onTap: () => onUpdateChanged(!updateNotification),
        ),
        _SettingRow(
          title: 'AI 摘要偏好（Pro）',
          locked: true,
          onTap: () => _showSettingsInfo(
            context,
            'AI 摘要偏好',
            '這是 Pro 權限功能。正式版會接訂閱權限與 AI 摘要設定，目前先保留鎖定狀態。',
          ),
        ),
        _SwitchRow(
            title: '追蹤更新通知',
            value: updateNotification,
            onChanged: onUpdateChanged),
        _SwitchRow(
            title: '案件新增通知', value: caseNotification, onChanged: onCaseChanged),
        _SettingRow(
          title: '同步設定',
          value: '已開啟',
          trailing: Icons.chevron_right_rounded,
          onTap: () => _showSettingsInfo(
            context,
            '同步設定',
            '目前收藏、追蹤與筆記仍以本機狀態為主；正式後端完成後，這裡會顯示跨裝置同步、最後同步時間與衝突處理。',
          ),
        ),
        _SettingRow(
          title: '清除快取',
          value: '32.4 MB',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('已清除本機展示快取。')),
            );
          },
        ),
        _SettingRow(
          title: '關於法律動態',
          trailing: Icons.chevron_right_rounded,
          onTap: () => _showSettingsInfo(
            context,
            '關於法律動態',
            '法律動態會整合追蹤案件、法條修正、生活情境文章與 AI 摘要提醒；正式版需要後端排程與通知服務支援。',
          ),
        ),
        SizedBox(height: 16.h),
        Align(
          alignment: Alignment.centerLeft,
          child: InkWell(
            onTap: onSignOut,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              child: Text(
                '登出 Demo 帳號',
                style:
                    _FollowText.action().copyWith(color: _FollowColors.orange),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showSettingsInfo(BuildContext context, String title, String message) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('知道了'),
            ),
          ],
        );
      },
    );
  }
}

class _GuestView extends StatelessWidget {
  const _GuestView({required this.onDemo, required this.onLearnMore});

  final VoidCallback onDemo;
  final VoidCallback onLearnMore;

  @override
  Widget build(BuildContext context) {
    return _ProtoCard(
      child: Column(
        children: [
          SizedBox(height: 32.h),
          SvgPicture.asset(_ProfileAsset.lock, width: 112.w, height: 112.w),
          SizedBox(height: 22.h),
          Text('登入後開啟完整追蹤功能',
              style: _FollowText.section(), textAlign: TextAlign.center),
          SizedBox(height: 18.h),
          const _CheckLine(text: '追蹤案件、法條、主題與關鍵字'),
          const _CheckLine(text: '接收更新通知與 AI 提醒（Pro）'),
          const _CheckLine(text: '建立筆記與收藏，跨裝置同步'),
          SizedBox(height: 22.h),
          _PrimaryButton(label: 'Demo 登入', onPressed: onDemo),
          SizedBox(height: 12.h),
          _SecondaryButton(label: '了解更多', onPressed: onLearnMore),
          SizedBox(height: 18.h),
        ],
      ),
    );
  }
}
