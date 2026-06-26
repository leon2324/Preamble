part of '../following_page.dart';

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

  final PreambleState appState;
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
        _PlanInfoCard(appState: appState, onPlan: onPlan),
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
    this.showTabs = true,
    required this.onTabChanged,
    required this.onOpen,
    required this.onReadAll,
    required this.onTrackTab,
  });

  final List<_UpdateItem> items;
  final int selectedTabIndex;
  final bool showTabs;
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
        if (showTabs) ...[
          _TabStrip(
            labels: const ['全部', '案件', '法條', '主題', '關鍵字'],
            selectedIndex: selectedTabIndex,
            onChanged: onTabChanged,
          ),
          SizedBox(height: 18.h),
        ],
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

  final PreambleState appState;
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
          title: '目前為 ${appState.accessTier.label}',
          body:
              '每日 AI 輔助額度：${appState.remainingAiQuota} / ${appState.accessTier.defaultDailyAiQuota} 次。收藏、筆記與追蹤資料會先保存在此裝置；如涉及實際個案，請諮詢合格律師或相關專業人士。',
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
        description: '這是你收藏的法條；從我的 緒言 Preamble 開啟時會保留同一份收藏狀態。',
        latestUpdate: '已收藏於我的 緒言 Preamble',
        icon: item.icon,
      );
    }
    if (item.category == '案件' || item.category == '文章') {
      return _FollowItem(
        kind: _FollowDetailKind.caseItem,
        title: item.title,
        meta: item.subtitle,
        description: '這是你收藏的內容；目前先以本機收藏狀態呈現，後端同步後會補上正式摘要。',
        latestUpdate: '已收藏於我的 緒言 Preamble',
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
        const _HintText('文件草稿會先保存在此裝置，可用來整理溝通內容與證據。正式寄出或送件前，仍建議由專業人士確認。'),
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

  final PreambleState appState;
  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ProtoCard(
          background: _FollowColors.softPaper,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('進階功能規劃', style: _FollowText.section()),
              SizedBox(height: 8.h),
              Text(
                '目前已開放收藏、筆記、追蹤與文件草稿的本機整理流程。跨裝置同步、進階提醒與正式訂閱方案會在完成審查與驗證後再推出。',
                style: _FollowText.bodyStrong(),
              ),
              SizedBox(height: 12.h),
              LinearProgressIndicator(
                value: 0.6,
                color: _FollowColors.primary,
                backgroundColor: Colors.white,
              ),
            ],
          ),
        ),
        SizedBox(height: 14.h),
        const _CheckLine(text: '收藏、筆記與追蹤保存在此裝置'),
        const _CheckLine(text: '案件、法條與學習內容會標示來源與限制'),
        const _CheckLine(text: '法律資訊僅供學習參考，不構成法律意見'),
        SizedBox(height: 18.h),
        _PrimaryButton(
          label: '了解目前方案',
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
          value: '基礎使用',
          trailing: Icons.chevron_right_rounded,
          onTap: onPlan,
        ),
        _SettingRow(
          title: '資料來源',
          trailing: Icons.chevron_right_rounded,
          onTap: () => _showSettingsInfo(
            context,
            '資料來源',
            '法規內容以全國法規資料庫與公開資料為主要查核來源；案件、學習與生活法律內容包含內建整理資料。畫面若未標示即時更新，代表內容不保證為最新狀態，請以官方來源為準。',
          ),
        ),
        _SettingRow(
          title: '法律免責聲明',
          trailing: Icons.chevron_right_rounded,
          onTap: () => _showSettingsInfo(
            context,
            '法律免責聲明',
            '本 App 提供的案件整理、法律知識與 AI 輔助說明，僅供學習與資訊參考，不構成法律意見。如涉及實際個案，請諮詢合格律師或相關專業人士。',
          ),
        ),
        _SettingRow(
          title: '隱私權政策',
          trailing: Icons.chevron_right_rounded,
          onTap: () => _showSettingsInfo(
            context,
            '隱私權政策',
            '緒言 Preamble 會將你在裝置上建立的收藏、筆記、偏好設定與草稿保存在本機，以便下次開啟時延續使用。若你開啟外部官方網站或分享內容，資料會依該服務的規範處理。請避免在筆記或提問中輸入不必要的敏感個資。',
          ),
        ),
        _SettingRow(
          title: '關於 緒言 Preamble',
          value: '版本 1.0.0',
          trailing: Icons.chevron_right_rounded,
          onTap: () => _showSettingsInfo(
            context,
            '關於 緒言 Preamble',
            '緒言 Preamble 是以台灣日常法律情境為核心的法律學習與自我整理工具，協助使用者用案件、法規與筆記理解生活中的法律問題。',
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
          title: 'AI 摘要偏好',
          locked: true,
          onTap: () => _showSettingsInfo(
            context,
            'AI 摘要偏好',
            '進階摘要偏好需要更完整的帳號、隱私與資料保存流程。正式開放前，本頁會以固定的學習輔助說明呈現。',
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
          value: '本機保存',
          trailing: Icons.chevron_right_rounded,
          onTap: () => _showSettingsInfo(
            context,
            '同步設定',
            '收藏、追蹤與筆記目前會保存在此裝置。更換裝置或清除 App 資料前，請先自行備份重要筆記。',
          ),
        ),
        _SettingRow(
          title: '清除快取',
          value: '32.4 MB',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('本機暫存狀態已重新整理。')),
            );
          },
        ),
        _SettingRow(
          title: '關於法律動態',
          trailing: Icons.chevron_right_rounded,
          onTap: () => _showSettingsInfo(
            context,
            '關於法律動態',
            '法律動態會整理你在 App 內追蹤的案件、法條與生活法律內容。若需要確認最新法規或判決，請再回到官方來源查核。',
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
                '清除本機使用狀態',
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
  const _GuestView({required this.onEnter, required this.onLearnMore});

  final VoidCallback onEnter;
  final VoidCallback onLearnMore;

  @override
  Widget build(BuildContext context) {
    return _ProtoCard(
      child: Column(
        children: [
          SizedBox(height: 32.h),
          SvgPicture.asset(_ProfileAsset.lock, width: 112.w, height: 112.w),
          SizedBox(height: 22.h),
          Text('開啟完整追蹤整理',
              style: _FollowText.section(), textAlign: TextAlign.center),
          SizedBox(height: 18.h),
          const _CheckLine(text: '追蹤案件、法條、主題與關鍵字'),
          const _CheckLine(text: '建立本機筆記與收藏'),
          const _CheckLine(text: '重要資料請以官方來源再查核'),
          SizedBox(height: 22.h),
          _PrimaryButton(label: '進入追蹤中心', onPressed: onEnter),
          SizedBox(height: 12.h),
          _SecondaryButton(label: '了解更多', onPressed: onLearnMore),
          SizedBox(height: 18.h),
        ],
      ),
    );
  }
}
