import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/components/lawyer/lawyer_referral_sheet.dart';
import 'package:preamble/components/shared/custom_toast.dart';
import 'package:preamble/data/journal/user_case_journal_models.dart';
import 'package:preamble/data/journal/user_case_journal_repository.dart';
import 'package:preamble/data/lawyer/lawyer_models.dart';
import 'package:preamble/pages/journal/widgets/journal_palette.dart';
import 'package:preamble/pages/learning/know_law_page.dart';

/// 使用者個人自救案件記事區塊 (My Case Journal Section)
class UserCaseJournalSection extends StatefulWidget {
  const UserCaseJournalSection({
    super.key,
    required this.palette,
    required this.repository,
  });

  final JournalPalette palette;
  final UserCaseJournalRepository repository;

  @override
  State<UserCaseJournalSection> createState() => _UserCaseJournalSectionState();
}

class _UserCaseJournalSectionState extends State<UserCaseJournalSection> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final entries = widget.repository.entries;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 頂部小導引與新增按鈕
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '進行中自救案件',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                    color: widget.palette.primaryText,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '法律時效倒數、證據清冊與交涉歷程追蹤',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: widget.palette.secondaryText,
                  ),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () => _openNewCaseDialog(context),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: isDark
                    ? const Color(0xFF2E463B)
                    : const Color(0xFF2C5E43),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              icon: Icon(Icons.add_rounded, size: 14.sp),
              label: Text(
                '問診新增',
                style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),

        if (entries.isEmpty)
          _buildEmptyState(context, isDark)
        else
          ...entries.map((entry) => Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: _UserCaseCard(
                  entry: entry,
                  palette: widget.palette,
                  onToggleEvidence: (idx) {
                    widget.repository.toggleEvidence(entry.id, idx);
                    setState(() {});
                  },
                  onAddLog: (title, note, tag) {
                    widget.repository.addLog(
                      entry.id,
                      CaseJournalLogEntry(
                        id: 'log-${DateTime.now().microsecondsSinceEpoch}',
                        timestamp: DateTime.now(),
                        title: title,
                        note: note,
                        tag: tag,
                      ),
                    );
                    setState(() {});
                  },
                ),
              )),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: widget.palette.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: widget.palette.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.folder_shared_outlined,
            size: 40.sp,
            color: widget.palette.secondaryText.withValues(alpha: 0.6),
          ),
          SizedBox(height: 8.h),
          Text(
            '尚未建立自救案件記事',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: widget.palette.primaryText,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '您在小法助進行法律問診時，可將案情、法定時效與應對金句一鍵收錄至此處，隨時追蹤進度！',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5.sp,
              color: widget.palette.secondaryText,
              height: 1.4,
            ),
          ),
          SizedBox(height: 12.h),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const LawAssistantChatPage(),
                ),
              );
            },
            icon: Icon(Icons.support_agent_rounded, size: 14.sp),
            label: Text('立即開始問診建立案件', style: TextStyle(fontSize: 12.sp)),
          ),
        ],
      ),
    );
  }

  void _openNewCaseDialog(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: widget.palette.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '新增個人自救案件',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: widget.palette.primaryText,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                '推薦直接透過「小法助 AI 問診」說明案件事實，AI 大腦會為您自動抽取爭點、法條時效與證據清單，並一鍵收錄至本記事！',
                style: TextStyle(
                  fontSize: 12.5.sp,
                  color: widget.palette.secondaryText,
                  height: 1.45,
                ),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const LawAssistantChatPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C5E43),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('打開小法助進行深度問診'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _UserCaseCard extends StatefulWidget {
  const _UserCaseCard({
    required this.entry,
    required this.palette,
    required this.onToggleEvidence,
    required this.onAddLog,
  });

  final UserCaseJournalEntry entry;
  final JournalPalette palette;
  final ValueChanged<int> onToggleEvidence;
  final void Function(String title, String note, String tag) onAddLog;

  @override
  State<_UserCaseCard> createState() => _UserCaseCardState();
}

class _UserCaseCardState extends State<_UserCaseCard> {
  bool _isExpanded = true;
  bool _showAllLogs = false;

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryGreen =
        isDark ? const Color(0xFF68B28B) : const Color(0xFF2C5E43);
    final amberWarn =
        isDark ? const Color(0xFFE5C07B) : const Color(0xFFB57400);

    return Container(
      decoration: BoxDecoration(
        color: widget.palette.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: widget.palette.border,
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 頂部狀態標題與收合按鈕
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            child: Padding(
              padding: EdgeInsets.all(14.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 7.w, vertical: 2.5.h),
                              decoration: BoxDecoration(
                                color: primaryGreen.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                entry.status.label,
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                  color: primaryGreen,
                                ),
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              '對造：${entry.counterparty}',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                                color: widget.palette.secondaryText,
                              ),
                            ),
                            if (entry.disputedAmount.isNotEmpty) ...[
                              SizedBox(width: 6.w),
                              Text(
                                '• 涉案 ${entry.disputedAmount}',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold,
                                  color: amberWarn,
                                ),
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          entry.title,
                          style: TextStyle(
                            fontSize: 14.5.sp,
                            fontWeight: FontWeight.w900,
                            color: widget.palette.primaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: widget.palette.secondaryText,
                  ),
                ],
              ),
            ),
          ),

          // 核心進度條：法定時效倒數警報
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF2A2318)
                    : const Color(0xFFFDF8EE),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF5A4426)
                      : const Color(0xFFF1DEB2),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.timer_outlined, size: 16.sp, color: amberWarn),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.statuteDeadlineTitle,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w800,
                            color: widget.palette.primaryText,
                          ),
                        ),
                        Text(
                          entry.statuteDeadlineBasis,
                          style: TextStyle(
                            fontSize: 9.5.sp,
                            color: widget.palette.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: amberWarn.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      '剩餘 ${entry.remainingDays} 天',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w900,
                        color: amberWarn,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_isExpanded) ...[
            SizedBox(height: 12.h),

            // 應對金句區塊
            if (entry.tacticalGoldenPhrase.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                child: Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: primaryGreen.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                        color: primaryGreen.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.chat_bubble_outline_rounded,
                                  size: 13.sp, color: primaryGreen),
                              SizedBox(width: 4.w),
                              Text(
                                '最新應對金句（可直接複製照唸/發送）',
                                style: TextStyle(
                                  fontSize: 10.5.sp,
                                  fontWeight: FontWeight.bold,
                                  color: primaryGreen,
                                ),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () {
                              Clipboard.setData(ClipboardData(
                                  text: entry.tacticalGoldenPhrase));
                              CustomToast.show(context, '金句已複製到剪貼簿！');
                            },
                            child: Padding(
                              padding: EdgeInsets.all(2.w),
                              child: Row(
                                children: [
                                  Icon(Icons.copy_rounded,
                                      size: 11.sp, color: primaryGreen),
                                  SizedBox(width: 2.w),
                                  Text(
                                    '複製',
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.bold,
                                      color: primaryGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        entry.tacticalGoldenPhrase,
                        style: TextStyle(
                          fontSize: 11.sp,
                          height: 1.35,
                          color: widget.palette.primaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            SizedBox(height: 12.h),

            // 證據清冊檢核進度
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '必備證據準備進度 (${(entry.evidenceProgress * 100).toInt()}%)',
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w800,
                          color: widget.palette.primaryText,
                        ),
                      ),
                      Text(
                        '點擊可勾選標記',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: widget.palette.secondaryText,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  ...entry.evidences.asMap().entries.map((item) {
                    final idx = item.key;
                    final ev = item.value;
                    return InkWell(
                      onTap: () => widget.onToggleEvidence(idx),
                      borderRadius: BorderRadius.circular(6.r),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 3.h),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              ev.isCollected
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked_rounded,
                              size: 15.sp,
                              color: ev.isCollected
                                  ? primaryGreen
                                  : widget.palette.secondaryText
                                      .withValues(alpha: 0.5),
                            ),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Text(
                                ev.title,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: ev.isCollected
                                      ? widget.palette.primaryText
                                      : widget.palette.secondaryText,
                                  decoration: ev.isCollected
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            SizedBox(height: 12.h),

            // 交涉歷程日誌 (Timeline logs)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '交涉與行動日誌 (${entry.logs.length})',
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w800,
                          color: widget.palette.primaryText,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _openAddLogDialog(context),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: Icon(Icons.add_circle_outline_rounded,
                            size: 13.sp, color: primaryGreen),
                        label: Text(
                          '新增筆記',
                          style: TextStyle(
                            fontSize: 10.5.sp,
                            fontWeight: FontWeight.bold,
                            color: primaryGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  ...(_showAllLogs ? entry.logs : entry.logs.take(2))
                      .map((log) => Padding(
                            padding: EdgeInsets.only(bottom: 6.h),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 5.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color: widget.palette.border
                                        .withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  child: Text(
                                    log.tag,
                                    style: TextStyle(
                                      fontSize: 9.sp,
                                      fontWeight: FontWeight.bold,
                                      color: widget.palette.secondaryText,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 6.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${log.title} (${log.timestamp.month}/${log.timestamp.day})',
                                        style: TextStyle(
                                          fontSize: 10.5.sp,
                                          fontWeight: FontWeight.bold,
                                          color: widget.palette.primaryText,
                                        ),
                                      ),
                                      Text(
                                        log.note,
                                        style: TextStyle(
                                          fontSize: 10.sp,
                                          color: widget.palette.secondaryText,
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )),
                  if (entry.logs.length > 2)
                    Center(
                      child: TextButton(
                        onPressed: () =>
                            setState(() => _showAllLogs = !_showAllLogs),
                        child: Text(
                          _showAllLogs
                              ? '收合日誌'
                              : '查看全部 ${entry.logs.length} 則日誌',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: widget.palette.secondaryText,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            Divider(color: widget.palette.border, height: 20.h),

            // 底部行動按鈕
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => LawAssistantChatPage(
                              initialPrompt:
                                  '針對先前的「${entry.title}」，目前進度為：${entry.logs.first.note}，請為我複盤下一步自保行動與具體法律策略。',
                            ),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        side: BorderSide(color: primaryGreen),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      icon: Icon(Icons.support_agent_rounded,
                          size: 13.sp, color: primaryGreen),
                      label: Text(
                        '小法助複盤',
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.bold,
                          color: primaryGreen,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final brief = CaseBrief(
                          disputeCategory: entry.title,
                          factSummary: entry.initialFacts.isNotEmpty
                              ? entry.initialFacts
                              : entry.title,
                          demands: [entry.tacticalGoldenPhrase],
                          evidences: entry.evidences
                              .where((e) => e.isCollected)
                              .map((e) => e.title)
                              .toList(),
                          possibleLegalBasis: [entry.statuteDeadlineBasis],
                          opponentProfile: entry.counterparty,
                        );
                        LawyerReferralSheet.show(context, caseBrief: brief);
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: isDark
                            ? const Color(0xFF2A3D33)
                            : const Color(0xFF2C5E43),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      icon: Icon(Icons.gavel_rounded, size: 13.sp),
                      label: Text(
                        '委任律師審核',
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _openAddLogDialog(BuildContext context) {
    final titleCtrl = TextEditingController(text: '與相對人電話協商');
    final noteCtrl = TextEditingController();
    String selectedTag = '通話/對話';

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDlgState) {
            return AlertDialog(
              backgroundColor: widget.palette.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              title: Text(
                '新增交涉筆記',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: widget.palette.primaryText,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(
                        labelText: '記事標題',
                        hintText: '如：向房東要求退還押金',
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 6.w,
                      children: ['通話/對話', 'LINE文字', '現場點交', '存證信函', '調解會']
                          .map((tag) => ChoiceChip(
                                label: Text(tag),
                                selected: selectedTag == tag,
                                onSelected: (_) {
                                  setDlgState(() => selectedTag = tag);
                                },
                              ))
                          .toList(),
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: noteCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: '交涉具體經過備忘',
                        hintText: '記錄雙方對話要點、承諾金額或爭執點...',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('取消'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final note = noteCtrl.text.trim();
                    if (note.isNotEmpty) {
                      widget.onAddLog(
                        titleCtrl.text.trim().isNotEmpty
                            ? titleCtrl.text.trim()
                            : '交涉記事',
                        note,
                        selectedTag,
                      );
                      Navigator.of(ctx).pop();
                      CustomToast.show(context, '已成功新增交涉日誌！');
                    }
                  },
                  child: const Text('儲存'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
