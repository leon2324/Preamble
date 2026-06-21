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

part 'widgets/following_views.dart';
part 'widgets/following_cards.dart';
part 'widgets/following_primitives.dart';

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
  const FollowingPage({super.key, this.initialTab});

  /// 台灣繁體中文教學註解：
  /// 可傳入初始分頁名稱（如 'collections', 'notes', 'drafts', 'questions', 'tabs'），
  /// 便於從新的個人頁面直接導航至子畫面。
  final String? initialTab;

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
  late _FollowPage _page;
  _FollowTab _tab = _FollowTab.cases;
  _FollowItem _selectedItem = _caseItems.first;
  _NoteItem _selectedNote = _notes.first;
  int _updatesTabIndex = 0;
  int _trackingSegmentIndex = 0;

  @override
  void initState() {
    super.initState();
    _page = _parseInitialTab(widget.initialTab);
  }

  _FollowPage _parseInitialTab(String? tab) {
    if (tab == null) return _FollowPage.home;
    switch (tab) {
      case 'collections':
        return _FollowPage.collections;
      case 'notes':
        return _FollowPage.notes;
      case 'drafts':
        return _FollowPage.drafts;
      case 'questions':
        return _FollowPage.questions;
      case 'updates':
        return _FollowPage.updates;
      case 'tabs':
        return _FollowPage.tabs;
      default:
        return _FollowPage.home;
    }
  }

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
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
          onCreateDraft: _showDraftComingSoon,
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

  void _showDraftComingSoon() {
    // 台灣繁體中文教學註解：
    // 舊版法律工具頁已隔離到 legacy，正式 App 先保留入口回饋，
    // 等新版文件產生流程定版後，再從這裡接回正式頁面或服務。
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('文件產生工具即將推出。')),
    );
  }

  void _handleBack() {
    // 台灣繁體中文教學註解：
    // 若此頁面是從新版 ProfilePage 點擊卡片 push 進來的（canPop 為 true），
    // 且目前正處於該子功能的主列表頁面，點選返回時應直接 Pop 路由回到 ProfilePage，
    // 避免使用者退回已棄用的舊版 _HomeView 畫面中。
    if (widget.initialTab != null) {
      final initialPage = _parseInitialTab(widget.initialTab);
      if (_page == initialPage) {
        Navigator.of(context).pop();
        return;
      }
    }

    setState(() {
      switch (_page) {
        case _FollowPage.detail:
          _page = _FollowPage.tabs;
          break;
        case _FollowPage.noteDetail:
          _page = _FollowPage.notes;
          break;
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
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            _page = _FollowPage.home;
          }
          break;
        case _FollowPage.home:
        case _FollowPage.guest:
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          break;
      }
    });
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
