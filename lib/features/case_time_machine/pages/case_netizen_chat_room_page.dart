import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lawapp/features/case_time_machine/models/case_time_machine_models.dart';
import 'package:lawapp/features/case_time_machine/pages/widgets/case_netizen_opinion_card.dart';
import 'package:lawapp/features/case_time_machine/pages/widgets/case_netizen_perspective_spectrum_card.dart';
import 'package:lawapp/features/case_time_machine/theme/case_time_machine_theme.dart';
import 'package:lawapp/features/case_time_machine/widgets/case_time_machine_scaffold.dart';
import 'package:lawapp/features/case_time_machine/widgets/case_time_machine_svg_icon.dart';
import 'package:lawapp/features/case_time_machine/pages/case_opinion_spectrum_page.dart';
import 'package:flutter/cupertino.dart';

// 本頁面定位為「案件思辨室」，不是一般聊天室。
// 版面以投票、AI 摘要、立場觀點卡與簡潔發言欄構成，讓使用者在保持閱讀秩序的前提下參與討論。

const String _svgBackIcon = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="#1B3F38" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
  <polyline points="15 18 9 12 15 6"></polyline>
</svg>
''';

const String _svgSendIcon = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="#FFFFFF" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
  <line x1="22" y1="2" x2="11" y2="13"></line>
  <polygon points="22 2 15 22 11 13 2 9 22 2"></polygon>
</svg>
''';

const String _svgPollStats = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="#1B3F38" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
  <line x1="18" y1="20" x2="18" y2="10"></line>
  <line x1="12" y1="20" x2="12" y2="4"></line>
  <line x1="6" y1="20" x2="6" y2="14"></line>
</svg>
''';

abstract final class _ChatPastels {
  static const page = Color(0xFFF7F3EA);
  static const surface = Color(0xFFFFFEFA);
  static const mint = Color(0xFFEAF6EF);
  static const mintText = Color(0xFF357A53);
  static const rose = Color(0xFFFBECEC);
  static const roseText = Color(0xFFC84E55);
  static const sky = Color(0xFFEAF4F7);
  static const skyText = Color(0xFF4A7C8C);
  static const lemon = Color(0xFFFFF2CF);
  static const lemonText = Color(0xFF9E7B2D);
  static const lavender = Color(0xFFF0EEF9);
  static const lavenderText = Color(0xFF6D649A);
  static const neutral = Color(0xFFEDEEEA);
  static const neutralText = Color(0xFF73766F);
  static const ink = Color(0xFF1A332F);
  static const muted = Color(0xFF7A8179);
  static const border = Color(0xFFE8DFD0);
}

class CaseNetizenChatRoomPage extends StatefulWidget {
  CaseNetizenChatRoomPage({
    super.key,
    required this.book,
    Map<String, List<int>>? caseVotes,
    Map<String, List<Map<String, dynamic>>>? netizenComments,
  })  : caseVotes = caseVotes ?? _defaultCaseVotes,
        netizenComments = netizenComments ?? _defaultNetizenComments;

  final CaseBook book;
  final Map<String, List<int>> caseVotes;
  final Map<String, List<Map<String, dynamic>>> netizenComments;

  static final Map<String, List<int>> _defaultCaseVotes = {
    '318': [142, 103],
    '799': [245, 312],
    '499': [158, 290],
    '520': [340, 120],
    '161': [12, 228],
    '124': [88, 42],
  };
  static final Map<String, List<Map<String, dynamic>>> _defaultNetizenComments =
      {};

  @override
  State<CaseNetizenChatRoomPage> createState() =>
      _CaseNetizenChatRoomPageState();
}

class _CaseNetizenChatRoomPageState extends State<CaseNetizenChatRoomPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();

  // 這裡保留本機投票狀態即可，MVP 階段先不接後端；未來接 API 時可用同一個 key 對應案件 id。
  final Map<String, String> _myVotes = {};
  String _selectedStance = '中立派';
  String _selectedSort = '熱門';
  bool _isSummaryExpanded = false;
  bool _isComposerExpanded = false;
  bool _showAllOpinions = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  void _ensureDiscussionSeed() {
    if (widget.netizenComments.containsKey(widget.book.id)) return;

    widget.netizenComments[widget.book.id] = [
      {
        'avatar': '理',
        'name': '理性旁觀者',
        'time': '1 小時前',
        'stance': '合理派',
        'content': '司法裁判的核心是程序正義與證據裁判。即使結果在情感上不容易接受，仍要回到既有法規與證據標準。',
        'likes': 15,
        'liked': false,
        'hasCitation': true,
        'source': '證據裁判原則',
      },
      {
        'avatar': '正',
        'name': '社會公平維護',
        'time': '2 小時前',
        'stance': '不合理派',
        'content': '法官量刑也應該回應一般社會通念。當判決與民眾法感落差太大，司法公信力就會被消耗。',
        'likes': 22,
        'liked': false,
        'hasCitation': false,
      },
      {
        'avatar': '衡',
        'name': '中線觀察',
        'time': '3 小時前',
        'stance': '中立派',
        'content': '我會想先看判決理由怎麼處理比例原則。如果法院有交代理由，討論就不該只停在結果重不重。',
        'likes': 9,
        'liked': false,
        'hasCitation': true,
        'source': '比例原則',
      },
    ];
  }

  List<int> _normalizedVotes(List<Map<String, dynamic>> comments) {
    final storedVotes = widget.caseVotes[widget.book.id] ?? [50, 50];
    if (storedVotes.length >= 3) return storedVotes;

    final neutralSeed = comments
        .where((comment) => (comment['stance'] as String?) == '中立派')
        .length
        .clamp(1, 8);
    final normalized = [
      storedVotes.isNotEmpty ? storedVotes[0] : 50,
      storedVotes.length > 1 ? storedVotes[1] : 50,
      neutralSeed,
    ];
    widget.caseVotes[widget.book.id] = normalized;
    return normalized;
  }

  @override
  Widget build(BuildContext context) {
    _ensureDiscussionSeed();

    final comments = widget.netizenComments[widget.book.id]!;
    final votes = _normalizedVotes(comments);
    final visibleComments = _sortedComments(comments);
    final highlightedComments =
        _showAllOpinions ? visibleComments : visibleComments.take(3).toList();

    return CaseTimeMachineScaffold(
      scene: CaseTimeMachineScene.dossier,
      showBackButton: false,
      useSafeArea: false,
      child: Container(
        color: _ChatPastels.page,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: ListView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  controller: _scrollController,
                  padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 18.h),
                  children: [
                    _buildPollCard(context, votes),
                    SizedBox(height: 8.h),
                    _buildAssistantSummaryCard(context, comments),
                    SizedBox(height: 12.h),
                    CaseNetizenPerspectiveSpectrumCard(comments: comments),
                    SizedBox(height: 12.h),
                    _buildSortBar(context, comments.length),
                    SizedBox(height: 10.h),
                    for (final entry in highlightedComments.indexed) ...[
                      CaseNetizenOpinionCard(
                        comment: entry.$2,
                        index: entry.$1,
                        onLike: () => _toggleLike(entry.$2),
                      ),
                      SizedBox(height: 9.h),
                    ],
                    if (!_showAllOpinions && visibleComments.length > 3)
                      _buildShowMoreOpinionsButton(visibleComments.length),
                  ],
                ),
              ),
              _buildComposer(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(10.w, 4.h, 10.w, 2.h),
          child: SizedBox(
            width: double.infinity,
            height: 48.h,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 0,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: SvgPicture.string(
                      _svgBackIcon,
                      width: 20.w,
                      height: 20.w,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 72.w),
                  child: Text(
                    '${widget.book.shortTitleZh.isNotEmpty ? widget.book.shortTitleZh : widget.book.titleZh} 思辨室',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style:
                        CaseTimeMachineTextStyles.cardTitle(context).copyWith(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w900,
                      color: _ChatPastels.ink,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 點擊可跳轉至本案的「觀點光譜」互動頁面，方便使用者對照大眾思辨立場。
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: SvgPicture.string(
                          CtmSvgIcons.sparkles
                              .replaceAll('currentColor', '#1B3F38'),
                          width: 20.w,
                          height: 20.w,
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            CupertinoPageRoute<void>(
                              builder: (__) =>
                                  CaseOpinionSpectrumPage(book: widget.book),
                            ),
                          );
                        },
                      ),
                      SizedBox(width: 14.w),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: SvgPicture.string(
                          _svgPollStats,
                          width: 20.w,
                          height: 20.w,
                        ),
                        onPressed: () {
                          final comments =
                              widget.netizenComments[widget.book.id] ?? [];
                          final votes = _normalizedVotes(comments);
                          _showStatsBottomSheet(context, comments, votes);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1, color: _ChatPastels.border),
      ],
    );
  }

  void _showStatsBottomSheet(
    BuildContext context,
    List<Map<String, dynamic>> comments,
    List<int> votes,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      barrierColor: Colors.black.withValues(alpha: 0.32),
      backgroundColor: Colors.transparent,
      builder: (context) {
        final screenHeight = MediaQuery.sizeOf(context).height;

        // 統計視圖是輔助資訊，不應該像完整頁面一樣佔滿螢幕。
        // 外層 GestureDetector 讓使用者點擊卡片外空白處即可關閉；內層 GestureDetector 則吸收卡片本身點擊，避免誤關。
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context).pop(),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: screenHeight * 0.78,
              child: Padding(
                padding: EdgeInsets.fromLTRB(22.w, 0, 22.w, 24.h),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: GestureDetector(
                    onTap: () {},
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: screenHeight * 0.66,
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 14.h),
                        decoration: BoxDecoration(
                          color: _ChatPastels.surface,
                          borderRadius: BorderRadius.circular(22.r),
                          border: Border.all(color: _ChatPastels.border),
                        ),
                        child: SingleChildScrollView(
                          child: _buildStatsView(context, comments, votes),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsView(
    BuildContext context,
    List<Map<String, dynamic>> comments,
    List<int> votes,
  ) {
    final totalVotes = votes.fold<int>(0, (sum, count) => sum + count);
    final agreePercent = _percentOf(votes[0], totalVotes);
    final disagreePercent = _percentOf(votes[1], totalVotes);
    final neutralPercent = (100 - agreePercent - disagreePercent).clamp(0, 100);
    final citationCount = _citationCount(comments);
    final citationPercent = _percentOf(citationCount, comments.length);
    final popularComments = List<Map<String, dynamic>>.from(comments)
      ..sort(
        (a, b) => (b['likes'] as int? ?? 0).compareTo(a['likes'] as int? ?? 0),
      );

    // 統計內容改由 bottom sheet 承載，避免主畫面在「閱讀討論」與「看統計」之間整頁切換，
    // 使用者可以把它當成輕量參考層，看完後自然回到思辨串。
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '觀點分布',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w900,
                color: _ChatPastels.ink,
              ),
            ),
            const Spacer(),
            _labelPill('輕量摘要', _ChatPastels.mint, _ChatPastels.mintText),
          ],
        ),
        SizedBox(height: 10.h),
        Container(
          padding: EdgeInsets.all(14.w),
          decoration: _softCardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _labelPill('立場分布', _ChatPastels.sky, _ChatPastels.skyText),
                  SizedBox(width: 8.w),
                  Text(
                    '$totalVotes 票',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w800,
                      color: _ChatPastels.muted,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              _statBar(
                label: '合理派',
                percent: agreePercent,
                count: votes[0],
                color: _ChatPastels.mintText,
                background: _ChatPastels.mint,
              ),
              SizedBox(height: 10.h),
              _statBar(
                label: '不合理派',
                percent: disagreePercent,
                count: votes[1],
                color: _ChatPastels.roseText,
                background: _ChatPastels.rose,
              ),
              SizedBox(height: 10.h),
              _statBar(
                label: '中立派',
                percent: neutralPercent,
                count: votes[2],
                color: _ChatPastels.neutralText,
                background: _ChatPastels.neutral,
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            _statsMetricCard(
              '引用率',
              '$citationPercent%',
              '$citationCount 則觀點有引用',
              _ChatPastels.lavender,
              _ChatPastels.lavenderText,
            ),
            SizedBox(width: 8.w),
            _statsMetricCard(
              '互動數',
              '${_totalLikes(comments)}',
              '愛心與同意回饋',
              _ChatPastels.rose,
              _ChatPastels.roseText,
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: _ChatPastels.sky,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFD9EAF0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _labelPill('小法助判讀', Colors.white, _ChatPastels.skyText),
                  SizedBox(width: 8.w),
                  Text(
                    '一眼看討論重心',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w800,
                      color: _ChatPastels.skyText,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                _statsReadingHint(
                    agreePercent, disagreePercent, citationPercent),
                style: TextStyle(
                  fontSize: 11.5.sp,
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                  color: _ChatPastels.ink,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        Container(
          padding: EdgeInsets.all(14.w),
          decoration: _softCardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _labelPill('目前最受關注', _ChatPastels.lemon, _ChatPastels.lemonText),
              SizedBox(height: 10.h),
              for (final entry in popularComments.take(3).indexed) ...[
                _popularOpinionRow(entry.$2, entry.$1),
                if (entry.$1 != popularComments.take(3).length - 1)
                  Divider(height: 18.h, color: _ChatPastels.border),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPollCard(BuildContext context, List<int> votes) {
    final totalVotes = votes.fold<int>(0, (sum, count) => sum + count);
    final agreePercent = _percentOf(votes[0], totalVotes);
    final disagreePercent = _percentOf(votes[1], totalVotes);
    final neutralPercent = (100 - agreePercent - disagreePercent).clamp(0, 100);
    final hasVoted = _myVotes.containsKey(widget.book.id);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
      decoration: _softCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _labelPill('本案思辨題', _ChatPastels.lemon, _ChatPastels.lemonText),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  _pollQuestion,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    height: 1.35,
                    fontWeight: FontWeight.w900,
                    color: _ChatPastels.ink,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 9.h),
          if (!hasVoted)
            Row(
              children: [
                Expanded(
                  child: _voteButton(
                    label: '合理',
                    color: _ChatPastels.mintText,
                    background: _ChatPastels.mint,
                    onTap: () => _vote('agree'),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _voteButton(
                    label: '不合理',
                    color: _ChatPastels.roseText,
                    background: _ChatPastels.rose,
                    onTap: () => _vote('disagree'),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _voteButton(
                    label: '觀望',
                    color: _ChatPastels.neutralText,
                    background: _ChatPastels.neutral,
                    onTap: () => _vote('neutral'),
                  ),
                ),
              ],
            )
          else ...[
            Row(
              children: [
                Text(
                  '合理 $agreePercent%',
                  style: _compactPollText(_ChatPastels.mintText),
                ),
                SizedBox(width: 8.w),
                Text(
                  '不合理 $disagreePercent%',
                  style: _compactPollText(_ChatPastels.roseText),
                ),
                SizedBox(width: 8.w),
                Text(
                  '中立 $neutralPercent%',
                  style: _compactPollText(_ChatPastels.neutralText),
                ),
                const Spacer(),
                Text(
                  '$totalVotes 票',
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w800,
                    color: _ChatPastels.muted,
                  ),
                ),
              ],
            ),
            SizedBox(height: 7.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: SizedBox(
                height: 7.h,
                child: Row(
                  children: [
                    Expanded(
                      flex: _safeFlex(agreePercent),
                      child: Container(color: _ChatPastels.mintText),
                    ),
                    Expanded(
                      flex: _safeFlex(disagreePercent),
                      child: Container(color: _ChatPastels.roseText),
                    ),
                    Expanded(
                      flex: _safeFlex(neutralPercent),
                      child: Container(color: _ChatPastels.neutralText),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAssistantSummaryCard(
    BuildContext context,
    List<Map<String, dynamic>> comments,
  ) {
    final compactSummary = '討論集中在「程序正義」與「社會法感」的拉扯。';

    return GestureDetector(
      onTap: () {
        setState(() {
          _isSummaryExpanded = !_isSummaryExpanded;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: _ChatPastels.sky,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFD9EAF0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _labelPill('小法助整理', Colors.white, _ChatPastels.skyText),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    _isSummaryExpanded
                        ? '目前 ${comments.length} 則觀點'
                        : compactSummary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w800,
                      color: _ChatPastels.skyText,
                    ),
                  ),
                ),
                CtmSvgIcon(
                  _isSummaryExpanded
                      ? CtmSvgIcons.chevronUp
                      : CtmSvgIcons.chevronDown,
                  size: 17.sp,
                  color: _ChatPastels.skyText,
                ),
              ],
            ),
            if (_isSummaryExpanded) ...[
              SizedBox(height: 8.h),
              Text(
                '支持方多聚焦「程序正義與證據標準」，反對方則提醒「社會法感與量刑落差」。建議閱讀時先分辨：你是在評價結果，還是在評價法院理由。',
                style: TextStyle(
                  fontSize: 11.5.sp,
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                  color: _ChatPastels.ink,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSortBar(BuildContext context, int totalComments) {
    return Row(
      children: [
        Text(
          _showAllOpinions ? '全部觀點' : '精選觀點',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w900,
            color: _ChatPastels.ink,
          ),
        ),
        SizedBox(width: 6.w),
        Text(
          '$totalComments 則',
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w800,
            color: _ChatPastels.muted,
          ),
        ),
        const Spacer(),
        _sortChip('熱門'),
        _sortChip('最新'),
      ],
    );
  }

  Widget _buildShowMoreOpinionsButton(int totalComments) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showAllOpinions = true;
        });
      },
      child: Container(
        margin: EdgeInsets.only(top: 1.h, bottom: 3.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: _ChatPastels.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: _ChatPastels.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '看全部 $totalComments 則觀點',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w900,
                color: _ChatPastels.ink,
              ),
            ),
            SizedBox(width: 4.w),
            CtmSvgIcon(
              CtmSvgIcons.chevronDown,
              size: 17.sp,
              color: _ChatPastels.ink,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComposer(BuildContext context) {
    if (!_isComposerExpanded) {
      return Container(
        padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 22.h),
        decoration: BoxDecoration(
          color: _ChatPastels.surface,
          border: const Border(top: BorderSide(color: _ChatPastels.border)),
        ),
        child: GestureDetector(
          onTap: _expandComposer,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 11.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFCFAF5),
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: _ChatPastels.border),
            ),
            child: Row(
              children: [
                _labelPill(
                  _selectedStance,
                  _stanceColors(_selectedStance).background,
                  _stanceColors(_selectedStance).foreground,
                ),
                SizedBox(width: 9.w),
                Expanded(
                  child: Text(
                    '發表我的看法',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w800,
                      color: _ChatPastels.muted,
                    ),
                  ),
                ),
                Container(
                  width: 30.w,
                  height: 30.w,
                  decoration: const BoxDecoration(
                    color: CaseTimeMachineColors.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                  child: CtmSvgIcon(
                    CtmSvgIcons.edit,
                    size: 15.sp,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 22.h),
      decoration: BoxDecoration(
        color: _ChatPastels.surface,
        border: const Border(top: BorderSide(color: _ChatPastels.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '發表立場',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w900,
                  color: _ChatPastels.muted,
                ),
              ),
              SizedBox(width: 8.w),
              _stanceChip('合理派'),
              _stanceChip('不合理派'),
              _stanceChip('中立派'),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isComposerExpanded = false;
                  });
                  _messageFocusNode.unfocus();
                },
                child: CtmSvgIcon(
                  CtmSvgIcons.chevronDown,
                  size: 20.sp,
                  color: _ChatPastels.muted,
                ),
              ),
            ],
          ),
          SizedBox(height: 7.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCFAF5),
                    borderRadius: BorderRadius.circular(18.r),
                    border: Border.all(color: _ChatPastels.border),
                  ),
                  child: TextField(
                    controller: _messageController,
                    focusNode: _messageFocusNode,
                    onTapOutside: (event) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    minLines: 1,
                    maxLines: 3,
                    style: TextStyle(
                      fontSize: 12.sp,
                      height: 1.35,
                      color: _ChatPastels.ink,
                    ),
                    decoration: InputDecoration(
                      hintText: _composerHint,
                      hintStyle: TextStyle(
                        fontSize: 12.sp,
                        color: _ChatPastels.muted,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 15.w,
                        vertical: 10.h,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: _sendMessage,
                child: Container(
                  width: 42.w,
                  height: 42.w,
                  decoration: const BoxDecoration(
                    color: CaseTimeMachineColors.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SvgPicture.string(
                      _svgSendIcon,
                      width: 18.w,
                      height: 18.w,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statBar({
    required String label,
    required int percent,
    required int count,
    required Color color,
    required Color background,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5.sp,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const Spacer(),
            Text(
              '$percent% · $count 票',
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w800,
                color: _ChatPastels.muted,
              ),
            ),
          ],
        ),
        SizedBox(height: 5.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Stack(
            children: [
              Container(height: 8.h, color: background),
              FractionallySizedBox(
                widthFactor: (percent / 100).clamp(0.04, 1),
                child: Container(height: 8.h, color: color),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statsMetricCard(
    String label,
    String value,
    String caption,
    Color background,
    Color foreground,
  ) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: foreground.withValues(alpha: 0.12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w900,
                color: foreground,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w900,
                color: foreground,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              caption,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9.sp,
                height: 1.3,
                fontWeight: FontWeight.w700,
                color: _ChatPastels.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _popularOpinionRow(Map<String, dynamic> comment, int index) {
    final stance = comment['stance'] as String? ?? '中立派';
    final colors = _stanceColors(stance);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22.w,
          height: 22.w,
          decoration: BoxDecoration(
            color: colors.background,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w900,
                color: colors.foreground,
              ),
            ),
          ),
        ),
        SizedBox(width: 9.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      comment['name'] as String? ?? '思辨參與者',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w900,
                        color: _ChatPastels.ink,
                      ),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  _labelPill(stance, colors.background, colors.foreground),
                  const Spacer(),
                  Text(
                    '♥ ${comment['likes'] ?? 0}',
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w900,
                      color: _ChatPastels.roseText,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                comment['content'] as String? ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5.sp,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                  color: _ChatPastels.ink,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _voteButton({
    required String label,
    required Color color,
    required Color background,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 9.h),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _labelPill(String label, Color background, Color foreground) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 9.sp,
          fontWeight: FontWeight.w900,
          color: foreground,
        ),
      ),
    );
  }

  TextStyle _compactPollText(Color color) {
    return TextStyle(
      fontSize: 9.5.sp,
      fontWeight: FontWeight.w900,
      color: color,
    );
  }

  Widget _sortChip(String label) {
    final selected = _selectedSort == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSort = label;
        });
      },
      child: Container(
        margin: EdgeInsets.only(left: 5.w),
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: selected ? _ChatPastels.ink : _ChatPastels.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? _ChatPastels.ink : _ChatPastels.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 9.sp,
            fontWeight: FontWeight.w900,
            color: selected ? Colors.white : _ChatPastels.muted,
          ),
        ),
      ),
    );
  }

  Widget _stanceChip(String stance) {
    final selected = _selectedStance == stance;
    final colors = _stanceColors(stance);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStance = stance;
        });
      },
      child: Container(
        margin: EdgeInsets.only(right: 6.w),
        padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: selected ? colors.foreground : colors.background,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          stance,
          style: TextStyle(
            fontSize: 9.sp,
            fontWeight: FontWeight.w900,
            color: selected ? Colors.white : colors.foreground,
          ),
        ),
      ),
    );
  }

  BoxDecoration _softCardDecoration() {
    return BoxDecoration(
      color: _ChatPastels.surface,
      borderRadius: BorderRadius.circular(18.r),
      border: Border.all(color: _ChatPastels.border),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.025),
          blurRadius: 14,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _sortedComments(
    List<Map<String, dynamic>> comments,
  ) {
    final copy = List<Map<String, dynamic>>.from(comments);
    if (_selectedSort == '熱門') {
      copy.sort((a, b) => (b['likes'] as int? ?? 0).compareTo(
            a['likes'] as int? ?? 0,
          ));
      return copy;
    }
    return copy;
  }

  _StanceColors _stanceColors(String stance) {
    return switch (stance) {
      '合理派' => const _StanceColors(
          background: _ChatPastels.mint,
          foreground: _ChatPastels.mintText,
        ),
      '不合理派' => const _StanceColors(
          background: _ChatPastels.rose,
          foreground: _ChatPastels.roseText,
        ),
      _ => const _StanceColors(
          background: _ChatPastels.neutral,
          foreground: _ChatPastels.neutralText,
        ),
    };
  }

  bool _hasCitation(Map<String, dynamic> comment) {
    final content = comment['content'] as String? ?? '';
    return comment['hasCitation'] == true ||
        content.contains('法條') ||
        content.contains('判決') ||
        content.contains('刑法') ||
        content.contains('憲法') ||
        content.contains('比例原則') ||
        content.contains('程序正義');
  }

  int _citationCount(List<Map<String, dynamic>> comments) {
    return comments.where(_hasCitation).length;
  }

  int _totalLikes(List<Map<String, dynamic>> comments) {
    return comments.fold<int>(
      0,
      (sum, comment) => sum + (comment['likes'] as int? ?? 0),
    );
  }

  int _percentOf(int count, int total) {
    if (total <= 0) return 0;
    return (count / total * 100).round();
  }

  int _safeFlex(int percent) {
    return percent.clamp(1, 100).toInt();
  }

  String get _pollQuestion {
    if (widget.book.id == '318') return '公民抗爭是否應作為阻卻違法事由？';
    if (widget.book.id == '161') return '本案二審量刑是否符合比例原則？';
    return '本案最終判決是否合乎社會正義？';
  }

  String get _composerHint {
    return switch (_selectedStance) {
      '合理派' => '用 1 句理由說明你支持合理派的原因...',
      '不合理派' => '用 1 句理由說明你覺得不合理的原因...',
      _ => '用中立角度補充你看到的關鍵疑問...',
    };
  }

  String _statsReadingHint(
    int agreePercent,
    int disagreePercent,
    int citationPercent,
  ) {
    final leading = agreePercent >= disagreePercent ? '合理派' : '不合理派';
    final gap = (agreePercent - disagreePercent).abs();
    final balanceHint = gap <= 12
        ? '目前兩方意見接近，適合先比較雙方法律理由。'
        : '目前$leading聲量較高，但仍建議回到判決理由與法條來源確認。';
    final citationHint = citationPercent >= 50
        ? '引用比例不低，這串討論的可讀性比一般留言區更好。'
        : '引用比例還偏低，可以鼓勵使用者補上法條或判決段落。';
    return '$balanceHint$citationHint';
  }

  void _vote(String choice) {
    final comments = widget.netizenComments[widget.book.id]!;
    final votes = _normalizedVotes(comments);
    setState(() {
      _myVotes[widget.book.id] = choice;
      if (choice == 'agree') votes[0] += 1;
      if (choice == 'disagree') votes[1] += 1;
      if (choice == 'neutral') votes[2] += 1;
    });
  }

  void _toggleLike(Map<String, dynamic> comment) {
    setState(() {
      final liked = comment['liked'] as bool? ?? false;
      final likes = comment['likes'] as int? ?? 0;
      comment['liked'] = !liked;
      comment['likes'] = liked ? likes - 1 : likes + 1;
    });
  }

  void _expandComposer() {
    setState(() {
      _isComposerExpanded = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((__) {
      if (!mounted) return;
      _messageFocusNode.requestFocus();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((__) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _selectedSort = '最新';
      _showAllOpinions = true;
      _isComposerExpanded = false;
      final comments = widget.netizenComments[widget.book.id]!;
      comments.add({
        'avatar': '我',
        'name': '我',
        'time': '剛剛',
        'stance': _selectedStance,
        'content': text,
        'likes': 0,
        'liked': false,
        'hasCitation': text.contains('法條') || text.contains('判決'),
        'isMe': true,
      });
      _messageController.clear();
    });

    _messageFocusNode.unfocus();
    _scrollToBottom();
  }
}

class _StanceColors {
  const _StanceColors({
    required this.background,
    required this.foreground,
  });

  final Color background;
  final Color foreground;
}
