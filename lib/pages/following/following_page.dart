import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lawapp/app/app_state.dart';
import 'package:lawapp/data/documents/document_models.dart';
import 'package:lawapp/data/following/following_models.dart';
import 'package:lawapp/features/case_time_machine/data/case_time_machine_mock_data.dart';
import 'package:lawapp/features/case_time_machine/pages/case_dossier_detail_page.dart';
import 'package:lawapp/pages/learning/statute_database_page.dart';
import 'package:lawapp/pages/tools/legal_tools_page.dart';

enum _FollowPage {
  home,
  updates,
  tabs,
  detail,
  profile,
  collections,
  notes,
  noteDetail,
  questions,
  drafts,
  plan,
  search,
  settings,
  guest
}

enum _FollowTab { cases, statutes, topics, keywords }

enum _FollowDetailKind { caseItem, statute }

class _ProfileAsset {
  static const avatar = 'assets/images/profile/profile_avatar.svg';
  static const footer = 'assets/images/profile/profile_footer.svg';
  static const lock = 'assets/images/profile/profile_lock.svg';
}

class FollowingPage extends StatefulWidget {
  const FollowingPage({super.key});

  @override
  State<FollowingPage> createState() => _FollowingPageState();
}

/// 「我的 LawApp」整合頁的 Prototype 版頁內導航容器。
///
/// 台灣繁體中文教學介紹型註解：
/// 這個分頁把原本「追蹤」與「我的」合併成個人法律中心；prototype 需要首頁、
/// 今日動態、追蹤中心、收藏、筆記、提問、文件草稿、方案與設定都保持同一套視覺。
/// 目前先用 `_FollowPage` 做頁內切換，等後端 ID、通知設定與個人資料 API 穩定後，
/// 再把各子頁抽成獨立路由與資料來源。
class _FollowingPageState extends State<FollowingPage> {
  _FollowPage _page = _FollowPage.home;
  _FollowTab _tab = _FollowTab.cases;
  _FollowItem _selectedItem = _caseItems.first;
  _NoteItem _selectedNote = _notes.first;
  int _updatesTabIndex = 0;
  int _trackingSegmentIndex = 0;
  int _collectionTabIndex = 0;
  int _noteTabIndex = 0;
  int _questionTabIndex = 0;
  int _draftTabIndex = 0;
  bool _updateNotification = true;
  bool _caseNotification = true;
  bool _lifeExampleNotification = true;

  @override
  Widget build(BuildContext context) {
    final appState = LawAppScope.of(context);
    final effectivePage = appState.isGuest && _page == _FollowPage.home
        ? _FollowPage.guest
        : _page;
    final summary = appState.followingSummary;
    final topPadding = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: _FollowColors.background,
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, topPadding + 12.h, 16.w, 32.h),
        children: [
          _TopBar(
            title: _titleFor(effectivePage),
            showBack: effectivePage != _FollowPage.home &&
                effectivePage != _FollowPage.guest,
            onBack: _handleBack,
            trailing: _trailingFor(effectivePage),
          ),
          SizedBox(height: 14.h),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: KeyedSubtree(
              key: ValueKey(effectivePage),
              child: _contentFor(effectivePage, appState, summary),
            ),
          ),
        ],
      ),
    );
  }

  String _titleFor(_FollowPage page) {
    switch (page) {
      case _FollowPage.home:
        return '我的 LawApp';
      case _FollowPage.updates:
        return '我的動態';
      case _FollowPage.tabs:
        return switch (_tab) {
          _FollowTab.cases => '追蹤案件',
          _FollowTab.statutes => '追蹤法條',
          _FollowTab.topics => '追蹤主題',
          _FollowTab.keywords => '追蹤關鍵字',
        };
      case _FollowPage.detail:
        return _selectedItem.title;
      case _FollowPage.profile:
        return '我的資料';
      case _FollowPage.collections:
        return '我的收藏';
      case _FollowPage.notes:
        return '我的筆記';
      case _FollowPage.noteDetail:
        return '筆記詳情';
      case _FollowPage.questions:
        return '提問紀錄';
      case _FollowPage.drafts:
        return '我的文件草稿';
      case _FollowPage.plan:
        return '會員方案';
      case _FollowPage.search:
        return '搜尋追蹤';
      case _FollowPage.settings:
        return '設定與說明';
      case _FollowPage.guest:
        return '我的 LawApp';
    }
  }

  Widget? _trailingFor(_FollowPage page) {
    if (page == _FollowPage.home) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _RoundIcon(
            icon: Icons.notifications_none_rounded,
            onTap: () => setState(() => _page = _FollowPage.updates),
          ),
          SizedBox(width: 8.w),
          _RoundIcon(
            icon: Icons.settings_outlined,
            onTap: () => setState(() => _page = _FollowPage.settings),
          ),
        ],
      );
    }
    if (page == _FollowPage.updates ||
        page == _FollowPage.tabs ||
        page == _FollowPage.collections) {
      return _RoundIcon(
        icon: Icons.search_rounded,
        onTap: () => setState(() => _page = _FollowPage.search),
      );
    }
    if (page == _FollowPage.detail) {
      return const _TrackedPill();
    }
    if (page == _FollowPage.noteDetail) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _RoundIcon(icon: Icons.insights_rounded, onTap: () {}),
          SizedBox(width: 8.w),
          _RoundIcon(icon: Icons.more_vert_rounded, onTap: () {}),
        ],
      );
    }
    return null;
  }

  Widget _contentFor(
    _FollowPage page,
    LawAppState appState,
    FollowingSummary summary,
  ) {
    switch (page) {
      case _FollowPage.home:
        return _HomeView(
          appState: appState,
          summary: summary,
          onUpdates: () => setState(() => _page = _FollowPage.updates),
          onTrackTab: (tab) => setState(() {
            _tab = tab;
            _page = _FollowPage.tabs;
          }),
          onCollections: () => setState(() => _page = _FollowPage.collections),
          onNotes: () => setState(() => _page = _FollowPage.notes),
          onQuestions: () => setState(() => _page = _FollowPage.questions),
          onDrafts: () => setState(() => _page = _FollowPage.drafts),
          onSettings: () => setState(() => _page = _FollowPage.settings),
        );
      case _FollowPage.updates:
        return _UpdatesView(
          items: _updatesForSummary(summary),
          selectedTabIndex: _updatesTabIndex,
          onTabChanged: (index) => setState(() => _updatesTabIndex = index),
          onOpen: (item) => _openItem(item.followItem),
          onReadAll: () => setState(() => _page = _FollowPage.home),
          onTrackTab: (tab) => setState(() {
            _tab = tab;
            _page = _FollowPage.tabs;
          }),
        );
      case _FollowPage.tabs:
        return _TabsView(
          summary: summary,
          tab: _tab,
          selectedSegmentIndex: _trackingSegmentIndex,
          onTab: (tab) => setState(() {
            _tab = tab;
            _trackingSegmentIndex = 0;
          }),
          onSegmentChanged: (index) =>
              setState(() => _trackingSegmentIndex = index),
          onOpen: _openItem,
        );
      case _FollowPage.detail:
        return _DetailView(
          item: _selectedItem,
          updateNotification: _updateNotification,
          caseNotification: _selectedItem.kind == _FollowDetailKind.caseItem
              ? _caseNotification
              : _lifeExampleNotification,
          onUpdateChanged: (value) =>
              setState(() => _updateNotification = value),
          onSecondaryChanged: (value) {
            setState(() {
              if (_selectedItem.kind == _FollowDetailKind.caseItem) {
                _caseNotification = value;
              } else {
                _lifeExampleNotification = value;
              }
            });
          },
          onExternal: _openExternalDetail,
        );
      case _FollowPage.notes:
        return _NotesView(
          notes: _notes,
          selectedTabIndex: _noteTabIndex,
          onTabChanged: (index) => setState(() => _noteTabIndex = index),
          onOpen: (note) {
            setState(() {
              _selectedNote = note;
              _page = _FollowPage.noteDetail;
            });
          },
        );
      case _FollowPage.noteDetail:
        return _NoteDetailView(note: _selectedNote);
      case _FollowPage.profile:
        return _ProfileView(appState: appState);
      case _FollowPage.collections:
        return _CollectionsView(
          summary: summary,
          selectedTabIndex: _collectionTabIndex,
          onTabChanged: (index) => setState(() => _collectionTabIndex = index),
          onOpen: _openItem,
        );
      case _FollowPage.questions:
        return _QuestionsView(
          selectedTabIndex: _questionTabIndex,
          onTabChanged: (index) => setState(() => _questionTabIndex = index),
        );
      case _FollowPage.drafts:
        return _DraftsView(
          selectedTabIndex: _draftTabIndex,
          onTabChanged: (index) => setState(() => _draftTabIndex = index),
          drafts: appState.documentRepository.drafts,
          backendStatus: appState.documentRepository.backendStatusLabel,
          onCreateDraft: _openLegalTools,
        );
      case _FollowPage.plan:
        return _PlanView(appState: appState);
      case _FollowPage.search:
        return _SearchView(
          onOpen: (item) {
            _trackFollowItem(appState, item);
            _openItem(item);
          },
        );
      case _FollowPage.settings:
        return _SettingsView(
          updateNotification: _updateNotification,
          caseNotification: _caseNotification,
          onUpdateChanged: (value) =>
              setState(() => _updateNotification = value),
          onCaseChanged: (value) => setState(() => _caseNotification = value),
        );
      case _FollowPage.guest:
        return _GuestView(
            onDemo: () => setState(() => _page = _FollowPage.home));
    }
  }

  void _openItem(_FollowItem item) {
    setState(() {
      _selectedItem = item;
      _page = _FollowPage.detail;
    });
  }

  Future<void> _trackFollowItem(LawAppState appState, _FollowItem item) async {
    final id = _followIdFor(item);
    if (item.kind == _FollowDetailKind.statute) {
      await appState.setStatuteFollowed(id, true);
    } else {
      await appState.setCaseFollowed(id, true);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已加入我的 LawApp 追蹤。')),
    );
  }

  void _openExternalDetail() {
    if (_selectedItem.kind == _FollowDetailKind.statute) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (__) =>
              StatuteDatabasePage(initialQuery: _selectedItem.title),
        ),
      );
      return;
    }

    // 台灣繁體中文教學註解：
    // 將追蹤的 FollowItem 標題映射至新版案件圖書館的 CaseBook，
    // 以便點選「前往案件頁面」時能直接進入全新設計的 Morandi 風格 Tab 詳情頁，而不是大門入口。
    String caseId = '318';
    final title = _selectedItem.title;
    if (title.contains('太陽花')) {
      caseId = '318';
    } else if (title.contains('鄭性澤')) {
      caseId = 'cheng-2021';
    } else if (title.contains('詐欺') || title.contains('洗錢')) {
      caseId = '228';
    } else if (title.contains('車禍')) {
      caseId = '104';
    } else if (title.contains('租屋')) {
      caseId = '176';
    } else if (title.contains('勞資')) {
      caseId = 'hung-2013';
    }

    final book = caseTimeMachineCaseById(caseId);
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (__) => CaseDossierDetailPage(book: book),
      ),
    );
  }

  void _openLegalTools() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (__) => const LegalToolsPage()),
    );
  }

  void _handleBack() {
    setState(() {
      switch (_page) {
        case _FollowPage.detail:
          _page = _FollowPage.tabs;
        case _FollowPage.noteDetail:
          _page = _FollowPage.notes;
        case _FollowPage.updates:
        case _FollowPage.tabs:
        case _FollowPage.profile:
        case _FollowPage.collections:
        case _FollowPage.notes:
        case _FollowPage.questions:
        case _FollowPage.drafts:
        case _FollowPage.plan:
        case _FollowPage.search:
        case _FollowPage.settings:
          _page = _FollowPage.home;
        case _FollowPage.home:
        case _FollowPage.guest:
          break;
      }
    });
  }
}

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
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MemberCard(appState: appState),
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
        _DemoUpsellCard(appState: appState),
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
        _SectionHeader(title: '今日更新', action: '查看全部', onTap: () {}),
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
  });

  final FollowingSummary summary;
  final _FollowTab tab;
  final int selectedSegmentIndex;
  final ValueChanged<_FollowTab> onTab;
  final ValueChanged<int> onSegmentChanged;
  final ValueChanged<_FollowItem> onOpen;

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
          onPressed: () {},
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
        _LatestUpdateCard(item: item),
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
  });

  final List<_NoteItem> notes;
  final int selectedTabIndex;
  final ValueChanged<int> onTabChanged;
  final ValueChanged<_NoteItem> onOpen;

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
            child: _PrimaryButton(label: '+  新增筆記', onPressed: () {}),
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
  const _NoteDetailView({required this.note});

  final _NoteItem note;

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
        Text('租客退租後，房東以各種理由不退押金。', style: _FollowText.bodyStrong()),
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
        const _BulletLine(text: '民法第 184 條（損害賠償）'),
        const _BulletLine(text: '民法第 440 條（租賃不用行）'),
        SizedBox(height: 26.h),
        Row(
          children: const [
            Expanded(
                child: _BottomAction(icon: Icons.edit_outlined, label: '編輯')),
            Expanded(
                child: _BottomAction(icon: Icons.share_outlined, label: '分享')),
            Expanded(
                child: _BottomAction(
                    icon: Icons.delete_outline_rounded, label: '刪除')),
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
  const _ProfileView({required this.appState});

  final LawAppState appState;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MemberCard(appState: appState),
        SizedBox(height: 14.h),
        _SummaryGrid(summary: appState.followingSummary, onTrackTab: (__) {}),
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
        _SecondaryButton(label: '共 23 個收藏', onPressed: () {}),
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
    required this.selectedTabIndex,
    required this.onTabChanged,
  });

  final int selectedTabIndex;
  final ValueChanged<int> onTabChanged;

  @override
  Widget build(BuildContext context) {
    final questions = _questionsForTab();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TabStrip(
          labels: const ['全部', '已回答', '未回答'],
          selectedIndex: selectedTabIndex,
          onChanged: onTabChanged,
        ),
        SizedBox(height: 14.h),
        for (final item in questions) ...[
          _QuestionTile(item: item),
          SizedBox(height: 10.h),
        ],
        SizedBox(height: 18.h),
        _SecondaryButton(label: '清除紀錄', onPressed: () {}),
      ],
    );
  }

  List<_QuestionItem> _questionsForTab() {
    if (selectedTabIndex == 0) return _questions;
    final status = selectedTabIndex == 1 ? '已回答' : '未回答';
    return _questions.where((item) => item.status == status).toList();
  }
}

class _DraftsView extends StatelessWidget {
  const _DraftsView({
    required this.selectedTabIndex,
    required this.onTabChanged,
    required this.drafts,
    required this.backendStatus,
    required this.onCreateDraft,
  });

  final int selectedTabIndex;
  final ValueChanged<int> onTabChanged;
  final List<DocumentDraft> drafts;
  final String backendStatus;
  final VoidCallback onCreateDraft;

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
            _DraftTile(item: item),
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
  const _PlanView({required this.appState});

  final LawAppState appState;

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
            label: isPro ? '已啟用 Pro' : '升級 Pro 會員', onPressed: () {}),
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
  });

  final bool updateNotification;
  final bool caseNotification;
  final ValueChanged<bool> onUpdateChanged;
  final ValueChanged<bool> onCaseChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SettingRow(title: '個人資料', trailing: Icons.chevron_right_rounded),
        _SettingRow(title: '深色模式', value: '關閉'),
        _SettingRow(
            title: '會員方案',
            value: 'Demo 會員',
            trailing: Icons.chevron_right_rounded),
        _SettingRow(title: '資料來源', trailing: Icons.chevron_right_rounded),
        _SettingRow(title: '法律免責聲明', trailing: Icons.chevron_right_rounded),
        _SettingRow(title: '隱私權政策', trailing: Icons.chevron_right_rounded),
        _SettingRow(
            title: '關於 LawApp',
            value: '版本 1.0.0',
            trailing: Icons.chevron_right_rounded),
        SizedBox(height: 18.h),
        Text('通知設定', style: _FollowText.section()),
        SizedBox(height: 8.h),
        _SettingRow(
          title: '更新頻率',
          value: updateNotification ? '即時' : '每日摘要',
          trailing: Icons.chevron_right_rounded,
        ),
        _SettingRow(title: 'AI 摘要偏好（Pro）', locked: true),
        _SwitchRow(
            title: '追蹤更新通知',
            value: updateNotification,
            onChanged: onUpdateChanged),
        _SwitchRow(
            title: '案件新增通知', value: caseNotification, onChanged: onCaseChanged),
        _SettingRow(
            title: '同步設定', value: '已開啟', trailing: Icons.chevron_right_rounded),
        _SettingRow(title: '清除快取', value: '32.4 MB'),
        _SettingRow(title: '關於法律動態', trailing: Icons.chevron_right_rounded),
        SizedBox(height: 16.h),
        Align(
          alignment: Alignment.centerLeft,
          child: Text('登出 Demo 帳號',
              style:
                  _FollowText.action().copyWith(color: _FollowColors.orange)),
        ),
      ],
    );
  }
}

class _GuestView extends StatelessWidget {
  const _GuestView({required this.onDemo});

  final VoidCallback onDemo;

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
          _SecondaryButton(label: '了解更多', onPressed: () {}),
          SizedBox(height: 18.h),
        ],
      ),
    );
  }
}

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

class _FollowTabBar extends StatelessWidget {
  const _FollowTabBar({required this.tab, required this.onTab});

  final _FollowTab tab;
  final ValueChanged<_FollowTab> onTab;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42.h,
      decoration: const BoxDecoration(),
      child: Row(
        children: [
          _TabButton(
              label: '案件',
              active: tab == _FollowTab.cases,
              onTap: () => onTab(_FollowTab.cases)),
          _TabButton(
              label: '法條',
              active: tab == _FollowTab.statutes,
              onTap: () => onTab(_FollowTab.statutes)),
          _TabButton(
              label: '主題',
              active: tab == _FollowTab.topics,
              onTap: () => onTab(_FollowTab.topics)),
          _TabButton(
              label: '關鍵字',
              active: tab == _FollowTab.keywords,
              onTap: () => onTab(_FollowTab.keywords)),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton(
      {required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: active ? _FollowColors.primary : Colors.transparent,
                width: 1.5,
              ),
            ),
          ),
          child: Text(
            label,
            style: _FollowText.captionStrong().copyWith(
              color: active ? _FollowColors.primary : _FollowColors.text,
            ),
          ),
        ),
      ),
    );
  }
}

class _TabStrip extends StatelessWidget {
  const _TabStrip({
    required this.labels,
    this.selectedIndex = 0,
    this.onChanged,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    // 台灣繁體中文教學註解：
    // Prototype 的分類列不是裝飾底線而已；這裡把選取狀態交給父層，
    // 讓「我的」底下的動態、收藏、筆記與草稿都能用同一個可互動元件切換資料。
    return Container(
      height: 42.h,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _FollowColors.divider)),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: labels.length,
        separatorBuilder: (_, __) => SizedBox(width: 10.w),
        itemBuilder: (context, i) {
          final active = i == selectedIndex;
          return InkWell(
            onTap: onChanged == null ? null : () => onChanged!(i),
            borderRadius: BorderRadius.circular(8.r),
            child: Container(
              constraints: BoxConstraints(minWidth: 58.w),
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: active ? _FollowColors.primary : Colors.transparent,
                    width: 1.5,
                  ),
                ),
              ),
              child: Text(
                labels[i],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _FollowText.captionStrong().copyWith(
                  color: active ? _FollowColors.primary : _FollowColors.text,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
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
    return Row(
      children: [
        if (showBack) ...[
          _RoundIcon(icon: Icons.arrow_back_ios_new_rounded, onTap: onBack),
          SizedBox(width: 10.w),
        ],
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _FollowText.navTitle(),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.action, this.onTap});

  final String title;
  final String? action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: _FollowText.section())),
        if (action != null && onTap != null)
          TextButton(onPressed: onTap, child: Text(action!)),
      ],
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow(
      {required this.title, this.value, this.trailing, this.locked = false});

  final String title;
  final String? value;
  final IconData? trailing;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return _SettingShell(
      child: Row(
        children: [
          Expanded(child: Text(title, style: _FollowText.bodyStrong())),
          if (value != null) Text(value!, style: _FollowText.caption()),
          SizedBox(width: 8.w),
          Icon(locked ? Icons.lock_outline_rounded : trailing,
              color: _FollowColors.mutedText, size: 18.sp),
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow(
      {required this.title, required this.value, required this.onChanged});

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return _SettingShell(
      child: Row(
        children: [
          Expanded(child: Text(title, style: _FollowText.bodyStrong())),
          Switch(
            value: value,
            activeThumbColor: _FollowColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _LockedRow extends StatelessWidget {
  const _LockedRow({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return _SettingShell(
      child: Row(
        children: [
          Expanded(child: Text(title, style: _FollowText.bodyStrong())),
          Icon(Icons.lock_outline_rounded,
              color: _FollowColors.mutedText, size: 18.sp),
        ],
      ),
    );
  }
}

class _SettingShell extends StatelessWidget {
  const _SettingShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 50.h),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _FollowColors.divider)),
      ),
      child: child,
    );
  }
}

class _SoftDivider extends StatelessWidget {
  const _SoftDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      color: _FollowColors.divider,
    );
  }
}

class _CheckLine extends StatelessWidget {
  const _CheckLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Icon(Icons.check_rounded, color: _FollowColors.primary, size: 16.sp),
          SizedBox(width: 8.w),
          Expanded(child: Text(text, style: _FollowText.bodyStrong())),
        ],
      ),
    );
  }
}

class _BottomAction extends StatelessWidget {
  const _BottomAction({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: _FollowColors.text, size: 21.sp),
        SizedBox(height: 5.h),
        Text(label, style: _FollowText.captionStrong()),
      ],
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999.r),
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: _FollowColors.text, size: 19.sp),
      ),
    );
  }
}

class _TrackedPill extends StatelessWidget {
  const _TrackedPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: _FollowColors.softPaper,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text('已追蹤', style: _FollowText.captionStrong()),
    );
  }
}

class _NewBadge extends StatelessWidget {
  const _NewBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
      decoration: const BoxDecoration(
        color: _FollowColors.orange,
        shape: BoxShape.circle,
      ),
      child:
          Text('新', style: _FollowText.buttonSmall().copyWith(fontSize: 9.sp)),
    );
  }
}

class _SmallPill extends StatelessWidget {
  const _SmallPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: _FollowColors.softPaper,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(label, style: _FollowText.captionStrong()),
    );
  }
}

class _HintText extends StatelessWidget {
  const _HintText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: _FollowText.caption().copyWith(height: 1.5),
    );
  }
}

class _TinyBadge extends StatelessWidget {
  const _TinyBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: _FollowColors.primary,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(label,
          style: _FollowText.buttonSmall().copyWith(fontSize: 9.sp)),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42.w,
      height: 42.w,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Icon(icon, color: color, size: 22.sp),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return _ProtoCard(
      background: _FollowColors.softMist,
      child: Row(
        children: [
          Icon(Icons.inbox_outlined,
              color: _FollowColors.mutedText, size: 20.sp),
          SizedBox(width: 10.w),
          Expanded(child: Text(message, style: _FollowText.captionStrong())),
        ],
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        color: _FollowColors.softPaper,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Icon(icon, color: _FollowColors.text, size: 24.sp),
    );
  }
}

class _ClipboardIllustration extends StatelessWidget {
  const _ClipboardIllustration({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 86.w,
      height: 88.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 58.w,
            height: 72.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: _FollowColors.borderDark),
            ),
          ),
          Icon(icon, color: _FollowColors.primary, size: 32.sp),
          Positioned(
            right: 4.w,
            bottom: 8.h,
            child: Icon(Icons.bookmark_border_rounded,
                color: _FollowColors.gold, size: 28.sp),
          ),
        ],
      ),
    );
  }
}

class _FooterIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: SvgPicture.asset(
        _ProfileAsset.footer,
        width: double.infinity,
        height: 76.h,
        fit: BoxFit.cover,
      ),
    );
  }
}

class _ProtoCard extends StatelessWidget {
  const _ProtoCard({
    required this.child,
    this.onTap,
    this.background = Colors.white,
    this.padding,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color background;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(13.w),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: background == Colors.white
              ? Colors.transparent
              : _FollowColors.cardStroke,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );

    if (onTap == null) return card;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: card,
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 46.h,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: _FollowColors.primary,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        ),
        child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 42.h,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: _FollowColors.primary,
          side: const BorderSide(color: _FollowColors.borderDark),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        ),
        child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}

class _FollowItem {
  const _FollowItem({
    required this.kind,
    required this.title,
    required this.meta,
    required this.description,
    required this.latestUpdate,
    required this.icon,
    this.unread = false,
  });

  final _FollowDetailKind kind;
  final String title;
  final String meta;
  final String description;
  final String latestUpdate;
  final IconData icon;
  final bool unread;
}

class _CollectionItem {
  const _CollectionItem({
    required this.title,
    required this.subtitle,
    required this.category,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final String category;
  final IconData icon;
  final Color color;
}

class _UpdateItem {
  const _UpdateItem({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.timeLabel,
    required this.category,
    required this.icon,
    required this.color,
    required this.followItem,
    this.unread = false,
  });

  final String type;
  final String title;
  final String subtitle;
  final String timeLabel;
  final String category;
  final IconData icon;
  final Color color;
  final _FollowItem followItem;
  final bool unread;
}

class _NoteItem {
  const _NoteItem({
    required this.title,
    required this.date,
    required this.tag,
    required this.content,
    required this.relatedLaw,
    required this.relatedTopic,
  });

  final String title;
  final String date;
  final String tag;
  final String content;
  final String relatedLaw;
  final String relatedTopic;
}

class _ShortcutItem {
  const _ShortcutItem(this.title, this.value, this.icon, this.onTap);

  final String title;
  final String value;
  final IconData icon;
  final VoidCallback onTap;
}

class _NavGuideItem {
  const _NavGuideItem(this.title, this.subtitle, this.icon, this.onTap);

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
}

class _QuestionItem {
  const _QuestionItem({
    required this.title,
    required this.time,
    required this.status,
  });

  final String title;
  final String time;
  final String status;
}

class _DraftItem {
  const _DraftItem({
    required this.title,
    required this.time,
    required this.tag,
  });

  factory _DraftItem.fromDocument(DocumentDraft draft) {
    return _DraftItem(
      title: draft.title,
      time: _formatDraftTime(draft.createdAt, draft.sourceLabel),
      tag: _tagForTemplate(draft.templateType),
    );
  }

  final String title;
  final String time;
  final String tag;
}

String _tagForTemplate(DocumentTemplateType type) {
  switch (type) {
    case DocumentTemplateType.depositDemand:
      return '存證信函';
    case DocumentTemplateType.rentalDepositNegotiation:
    case DocumentTemplateType.laborDisputeMessage:
      return '協商草稿';
    case DocumentTemplateType.carAccidentChecklist:
    case DocumentTemplateType.consumerComplaint:
      return '其他';
  }
}

String _formatDraftTime(DateTime value, String sourceLabel) {
  String twoDigits(int number) => number.toString().padLeft(2, '0');
  return '更新於 ${value.year}/${twoDigits(value.month)}/${twoDigits(value.day)} '
      '${twoDigits(value.hour)}:${twoDigits(value.minute)}｜$sourceLabel';
}

class _FollowText {
  static TextStyle navTitle() => TextStyle(
        color: _FollowColors.text,
        fontSize: 18.sp,
        height: 1.16,
        fontWeight: FontWeight.w900,
      );

  static TextStyle section() => TextStyle(
        color: _FollowColors.text,
        fontSize: 16.sp,
        height: 1.3,
        fontWeight: FontWeight.w900,
      );

  static TextStyle tileTitle() => TextStyle(
        color: _FollowColors.text,
        fontSize: 13.sp,
        height: 1.28,
        fontWeight: FontWeight.w900,
      );

  static TextStyle bodyStrong() => TextStyle(
        color: _FollowColors.text,
        fontSize: 12.5.sp,
        height: 1.62,
        fontWeight: FontWeight.w700,
      );

  static TextStyle caption() => TextStyle(
        color: _FollowColors.mutedText,
        fontSize: 11.sp,
        height: 1.35,
        fontWeight: FontWeight.w600,
      );

  static TextStyle captionStrong() => TextStyle(
        color: _FollowColors.text,
        fontSize: 11.sp,
        height: 1.25,
        fontWeight: FontWeight.w900,
      );

  static TextStyle action() => TextStyle(
        color: _FollowColors.primary,
        fontSize: 12.sp,
        fontWeight: FontWeight.w900,
      );

  static TextStyle buttonSmall() => TextStyle(
        color: Colors.white,
        fontSize: 11.sp,
        fontWeight: FontWeight.w900,
      );
}

class _FollowColors {
  static const background = Color(0xFFFAF6F0);
  static const primary = Color(0xFF234D3B);
  static const secondary = Color(0xFF6C8A7A);
  static const text = Color(0xFF222D27);
  static const mutedText = Color(0xFF828078);
  static const divider = Color(0xFFEDE4D8);
  static const cardStroke = Color(0xFFE9DFD2);
  static const borderDark = Color(0xFFCFC4B5);
  static const softPaper = Color(0xFFF3EAD7);
  static const softMist = Color(0xFFF8F2E8);
  static const gold = Color(0xFFD6A04D);
  static const orange = Color(0xFFFF8A4C);
}

List<_FollowItem> _mergeFollowItems(
  List<_FollowItem> baseItems,
  List<_FollowItem> dynamicItems,
) {
  final seen = <String>{};
  final merged = <_FollowItem>[];
  for (final item in [...dynamicItems, ...baseItems]) {
    if (!seen.add(item.title)) continue;
    merged.add(item);
  }
  return merged;
}

List<_FollowItem> _caseItemsForSummary(FollowingSummary summary) {
  return summary.followedCaseIds
      .map((id) => _followItemFromId(
            id: id,
            kind: _FollowDetailKind.caseItem,
            icon: Icons.inventory_2_outlined,
            meta: '從全站搜尋加入追蹤',
          ))
      .toList(growable: false);
}

List<_FollowItem> _statuteItemsForSummary(FollowingSummary summary) {
  return summary.followedStatuteIds
      .map((id) => _followItemFromId(
            id: id,
            kind: _FollowDetailKind.statute,
            icon: Icons.menu_book_outlined,
            meta: '從法規頁或全站搜尋加入追蹤',
          ))
      .toList(growable: false);
}

List<_FollowItem> _topicItemsForSummary(FollowingSummary summary) {
  return summary.followedTopicIds
      .map((id) => _followItemFromId(
            id: id,
            kind: _FollowDetailKind.caseItem,
            icon: Icons.label_outline_rounded,
            meta: '從生活筆記加入追蹤',
          ))
      .toList(growable: false);
}

_FollowItem _followItemFromId({
  required String id,
  required _FollowDetailKind kind,
  required IconData icon,
  required String meta,
}) {
  final title = _titleFromInteractionId(id);
  return _FollowItem(
    kind: kind,
    title: title,
    meta: meta,
    description: '這是你在其他頁面加入的項目；目前先以本機狀態呈現，後端同步後會補上正式摘要與更新紀錄。',
    latestUpdate: '已加入我的 LawApp',
    icon: icon,
    unread: true,
  );
}

List<_CollectionItem> _collectionItemsForSummary(FollowingSummary summary) {
  return [
    for (final id in summary.savedStatuteIds)
      _collectionItemFromId(
        id: id,
        category: '法條',
        icon: Icons.menu_book_outlined,
        color: _FollowColors.secondary,
      ),
    for (final id in summary.savedCaseIds)
      _collectionItemFromId(
        id: id,
        category: '案件',
        icon: Icons.account_balance_outlined,
        color: _FollowColors.gold,
      ),
    for (final id in summary.savedArticleIds)
      _collectionItemFromId(
        id: id,
        category: '文章',
        icon: Icons.description_outlined,
        color: _FollowColors.orange,
      ),
  ];
}

_CollectionItem _collectionItemFromId({
  required String id,
  required String category,
  required IconData icon,
  required Color color,
}) {
  return _CollectionItem(
    title: _titleFromInteractionId(id),
    subtitle: '收藏於本機 LawApp',
    category: category,
    icon: icon,
    color: color,
  );
}

List<_UpdateItem> _updatesForSummary(FollowingSummary summary) {
  final dynamicItems = [
    for (final item in _caseItemsForSummary(summary))
      _updateFromFollowItem(item, '案件'),
    for (final item in _statuteItemsForSummary(summary))
      _updateFromFollowItem(item, '法條'),
    for (final item in _topicItemsForSummary(summary))
      _updateFromFollowItem(item, '主題'),
  ];
  return [...dynamicItems, ..._updates];
}

_UpdateItem _updateFromFollowItem(_FollowItem item, String category) {
  return _UpdateItem(
    type: category,
    title: item.title,
    subtitle: '已串接到我的 LawApp',
    timeLabel: '剛剛',
    category: category,
    icon: item.icon,
    color: _FollowColors.primary,
    followItem: item,
    unread: true,
  );
}

String _followIdFor(_FollowItem item) {
  final prefix = item.kind == _FollowDetailKind.statute ? 'statute' : 'case';
  return '$prefix-${_normalizeInteractionTitle(item.title)}';
}

String _titleFromInteractionId(String id) {
  final withoutPrefix =
      id.replaceFirst(RegExp(r'^(statute|case|article)-'), '');
  if (withoutPrefix.isEmpty) return id;
  return withoutPrefix;
}

String _normalizeInteractionTitle(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'\s+'), '')
      .replaceAll(RegExp(r'[^a-z0-9\u4e00-\u9fff]+'), '');
}

const _caseItems = [
  _FollowItem(
    kind: _FollowDetailKind.caseItem,
    title: '詐欺與洗錢案件整理',
    meta: '最近更新：2 小時前',
    description: '整理近年詐欺與洗錢相關案件的判決與爭點，包含車手角色、帳戶提供、金流異常與實務趨勢。',
    latestUpdate: '有 2 則新整理',
    icon: Icons.account_balance_outlined,
    unread: true,
  ),
  _FollowItem(
    kind: _FollowDetailKind.caseItem,
    title: '太陽花運動',
    meta: '最近更新：昨日 21:30',
    description: '追蹤公民運動後續訴訟與程序爭點，整理抗議行動、執法界線與司法判斷。',
    latestUpdate: '新增 1 則程序整理',
    icon: Icons.groups_2_outlined,
  ),
  _FollowItem(
    kind: _FollowDetailKind.caseItem,
    title: '鄭性澤案件',
    meta: '最近更新：2026/04/28',
    description: '聚焦再審、證據調查與自白任意性問題，整理案件歷程與制度討論。',
    latestUpdate: '新增再審重點摘要',
    icon: Icons.gavel_outlined,
  ),
  _FollowItem(
    kind: _FollowDetailKind.caseItem,
    title: '車禍賠償案例',
    meta: '最近更新：2026/04/25',
    description: '整理車禍肇責、修車費、醫療費、精神慰撫金與調解常見爭議。',
    latestUpdate: '新增調解注意事項',
    icon: Icons.directions_car_outlined,
  ),
];

const _statuteItems = [
  _FollowItem(
    kind: _FollowDetailKind.statute,
    title: '民法 184 條',
    meta: '新增 1 則生活案例',
    description: '因故意或過失，不法侵害他人之權利者，負損害賠償責任。',
    latestUpdate: '新增 1 則生活案例',
    icon: Icons.menu_book_outlined,
    unread: true,
  ),
  _FollowItem(
    kind: _FollowDetailKind.statute,
    title: '勞動基準法 24',
    meta: '加班費與延長工時',
    description: '整理延長工作時間之工資加給計算方向，以及常見加班費與補休爭議。',
    latestUpdate: '更新加班費計算提醒',
    icon: Icons.work_history_outlined,
  ),
];

const _topicItems = [
  _FollowItem(
    kind: _FollowDetailKind.caseItem,
    title: '租屋糾紛',
    meta: '押金、修繕、提前解約',
    description: '追蹤租屋押金、修繕責任、點交紀錄與提前解約的生活案例。',
    latestUpdate: '新增押金返還提醒',
    icon: Icons.home_work_outlined,
  ),
  _FollowItem(
    kind: _FollowDetailKind.caseItem,
    title: '勞資爭議',
    meta: '工時、薪資、離職',
    description: '追蹤工時、加班費、資遣、離職證明與薪資明細相關內容。',
    latestUpdate: '新增補休與加班費案例',
    icon: Icons.badge_outlined,
  ),
];

const _keywordItems = [
  _FollowItem(
    kind: _FollowDetailKind.caseItem,
    title: '押金',
    meta: '最近 7 天有 3 則更新',
    description: '集中追蹤押金扣款、修繕明細、點交照片與返還通知。',
    latestUpdate: '新增扣款明細檢查表',
    icon: Icons.key_outlined,
  ),
  _FollowItem(
    kind: _FollowDetailKind.caseItem,
    title: '加班費',
    meta: '法條與生活案例更新中',
    description: '集中追蹤加班費、補休、工時紀錄與薪資單常見爭議。',
    latestUpdate: '新增工時紀錄保存提醒',
    icon: Icons.schedule_outlined,
  ),
];

const _collectionItems = [
  _CollectionItem(
    title: '民法第 184 條',
    subtitle: '收藏於 2026/05/01',
    category: '法條',
    icon: Icons.menu_book_outlined,
    color: _FollowColors.secondary,
  ),
  _CollectionItem(
    title: '詐欺與洗錢案件整理',
    subtitle: '收藏於 2026/04/30',
    category: '案件',
    icon: Icons.account_balance_outlined,
    color: _FollowColors.gold,
  ),
  _CollectionItem(
    title: '消費者保護法第 19 條',
    subtitle: '收藏於 2026/04/28',
    category: '法條',
    icon: Icons.receipt_long_outlined,
    color: _FollowColors.secondary,
  ),
  _CollectionItem(
    title: '押金返還的法律重點',
    subtitle: '收藏於 2026/04/27',
    category: '文章',
    icon: Icons.description_outlined,
    color: _FollowColors.orange,
  ),
  _CollectionItem(
    title: '太陽花運動事件整理',
    subtitle: '收藏於 2026/04/26',
    category: '主題',
    icon: Icons.groups_2_outlined,
    color: _FollowColors.gold,
  ),
];

const _suggestedItems = [
  _FollowItem(
    kind: _FollowDetailKind.caseItem,
    title: '詐欺與洗錢',
    meta: '熱門追蹤',
    description: '追蹤詐欺、車手、人頭帳戶與洗錢防制相關內容。',
    latestUpdate: '新增帳戶提供案例',
    icon: Icons.account_balance_wallet_outlined,
  ),
  _FollowItem(
    kind: _FollowDetailKind.caseItem,
    title: '交通事故',
    meta: '熱門追蹤',
    description: '追蹤車禍肇責、調解、修車費與醫療費。',
    latestUpdate: '新增調解資料清單',
    icon: Icons.car_crash_outlined,
  ),
  _FollowItem(
    kind: _FollowDetailKind.caseItem,
    title: '消費爭議',
    meta: '熱門追蹤',
    description: '追蹤網購退貨、瑕疵商品、退款與客服紀錄。',
    latestUpdate: '新增申訴草稿提示',
    icon: Icons.shopping_bag_outlined,
  ),
];

final _updates = [
  _UpdateItem(
    type: '案件',
    title: '詐欺與洗錢案件整理',
    subtitle: '有 2 則新整理',
    timeLabel: '2 小時前',
    category: '案件',
    icon: Icons.description_outlined,
    color: _FollowColors.gold,
    followItem: _caseItems[0],
    unread: true,
  ),
  _UpdateItem(
    type: '法條',
    title: '民法第 184 條',
    subtitle: '新增 1 則生活案例',
    timeLabel: '5 小時前',
    category: '法條',
    icon: Icons.menu_book_outlined,
    color: _FollowColors.secondary,
    followItem: _statuteItems[0],
    unread: true,
  ),
  _UpdateItem(
    type: '案件信箱',
    title: '太陽花運動卷宗',
    subtitle: '新增時間軸事件',
    timeLabel: '昨日 21:30',
    category: '主題',
    icon: Icons.archive_outlined,
    color: Color(0xFF8FB7B9),
    followItem: _caseItems[1],
    unread: true,
  ),
  _UpdateItem(
    type: '你的文件草稿',
    title: '押金返還通知（草稿）',
    subtitle: '尚未完成，點擊繼續',
    timeLabel: '昨日 18:14',
    category: '關鍵字',
    icon: Icons.feed_outlined,
    color: _FollowColors.orange,
    followItem: _keywordItems[0],
  ),
];

const _questions = [
  _QuestionItem(
    title: '房東不退押金怎麼辦？',
    time: '2026/05/01 14:20',
    status: '已回答',
  ),
  _QuestionItem(
    title: '加班費怎麼計算？',
    time: '2026/04/30 10:10',
    status: '已回答',
  ),
  _QuestionItem(
    title: '車禍對方遲遲不處理怎麼辦？',
    time: '2026/04/28 16:45',
    status: '已回答',
  ),
  _QuestionItem(
    title: '網路留言可以追回賠償嗎？',
    time: '2026/04/27 08:30',
    status: '未回答',
  ),
];

const _notes = [
  _NoteItem(
    title: '押金爭議處理注意事項',
    date: '2026/04/30',
    tag: '租屋糾紛',
    content: '退租前後要保留點交照片、修繕明細、水電帳單與雙方對話紀錄；若房東扣款，應請對方提出具體項目與金額。',
    relatedLaw: '民法第 423 條（租賃）、民法第 184 條（損害賠償）',
    relatedTopic: '租屋糾紛注意事項',
  ),
  _NoteItem(
    title: '車禍賠償重點筆記',
    date: '2026/04/28',
    tag: '交通事故',
    content: '先確認初判表、現場照片、醫療單據、修車報價與保險聯絡紀錄，再進入和解或調解。',
    relatedLaw: '民法第 184 條、民法第 193 條',
    relatedTopic: '車禍賠償案例',
  ),
  _NoteItem(
    title: '加班費計算重點整理',
    date: '2026/04/25',
    tag: '勞資爭議',
    content: '整理工時紀錄、薪資單、加班申請與主管指示紀錄，才能判斷加班費或補休是否合理。',
    relatedLaw: '勞動基準法第 24 條',
    relatedTopic: '勞資爭議合集',
  ),
  _NoteItem(
    title: '民法第 184 條使用情境',
    date: '2026/04/20',
    tag: '法條收藏',
    content: '侵權行為常見於車禍、網路言論、消費糾紛與財產損害，仍須看故意過失、損害與因果關係。',
    relatedLaw: '民法第 184 條',
    relatedTopic: '侵權行為與損害賠償',
  ),
];
