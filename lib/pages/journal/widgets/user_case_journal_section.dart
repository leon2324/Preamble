import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:preamble/components/lawyer/lawyer_referral_sheet.dart';
import 'package:preamble/components/shared/custom_toast.dart';
import 'package:preamble/data/journal/user_case_journal_models.dart';
import 'package:preamble/data/journal/user_case_journal_repository.dart';
import 'package:preamble/data/lawyer/lawyer_models.dart';
import 'package:preamble/data/legal_brain/taiwan_statute_canon.dart';
import 'package:preamble/pages/journal/widgets/journal_palette.dart';
import 'package:preamble/pages/learning/know_law_page.dart';
import 'package:preamble/pages/tools/legal_toolkit_hub_page.dart';
import 'package:preamble/theme/preamble_tokens.dart';

/// 個人自救案件夾 (`UserCaseJournalSection`) — 靜奢律政 × 雙重編碼卷宗卡。
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
    final t = context.tokens;
    final entries = widget.repository.entries;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '個人自救案件夾',
                    style: t.serifTitle(
                      size: 18.sp,
                      weight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    '法定時效關鍵期限、蒐證完成度進度條與一鍵實戰工具連動',
                    style: t.sansBody(
                      size: 12.sp,
                      color: t.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            ElevatedButton.icon(
              onPressed: () => _openNewCaseDialog(context),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: t.brandPrimaryStrong,
                foregroundColor: const Color(0xFFFAF8F4),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              icon: Icon(
                PhosphorIconsRegular.plus,
                size: 14.sp,
                color: const Color(0xFFFAF8F4),
              ),
              label: Text(
                '問診建檔',
                style: t.sansBody(
                  size: 11.5.sp,
                  weight: FontWeight.w700,
                  color: const Color(0xFFFAF8F4),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),
        if (entries.isEmpty)
          _buildEmptyState(context, t)
        else
          ...entries.map(
            (entry) => Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: _UserCaseDossierCard(
                entry: entry,
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
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, PreambleTokens t) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(22.w),
      decoration: t.cardDecoration(radius: 20.r, elevated: false),
      child: Column(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: t.brandContainer,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              PhosphorIconsRegular.briefcase,
              size: 24.sp,
              color: t.brandOnContainer,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            '尚未建立個人自救案件卷宗',
            style: t.serifTitle(size: 16.sp, weight: FontWeight.w800),
          ),
          SizedBox(height: 6.h),
          Text(
            '透過小法助問診或開啟實戰工具館，可將爭議事實、法定時效與蒐證待辦清單收錄至此處統一追蹤。',
            textAlign: TextAlign.center,
            style: t.sansBody(
              size: 12.sp,
              color: t.textSecondary,
              height: 1.5,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute<void>(
                        builder: (_) => const LegalToolkitHubPage(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    side: BorderSide(color: t.borderStrong),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  icon: Icon(
                    PhosphorIconsRegular.toolbox,
                    size: 15.sp,
                    color: t.textPrimary,
                  ),
                  label: Text(
                    '開啟實戰工具館',
                    style: t.sansBody(
                      size: 12.sp,
                      weight: FontWeight.w700,
                      color: t.textPrimary,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const LawAssistantChatPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: t.brandPrimaryStrong,
                    foregroundColor: const Color(0xFFFAF8F4),
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  icon: Icon(
                    PhosphorIconsRegular.chatTeardropText,
                    size: 15.sp,
                    color: const Color(0xFFFAF8F4),
                  ),
                  label: Text(
                    '小法助問診建檔',
                    style: t.sansBody(
                      size: 12.sp,
                      weight: FontWeight.w700,
                      color: const Color(0xFFFAF8F4),
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

  void _openNewCaseDialog(BuildContext context) {
    final t = context.tokens;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return Container(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
          decoration: BoxDecoration(
            color: t.surfaceElevated,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            border: Border.all(color: t.borderStrong),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36.w,
                    height: 4.h,
                    margin: EdgeInsets.only(bottom: 14.h),
                    decoration: BoxDecoration(
                      color: t.borderStrong,
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                  ),
                ),
                Text(
                  '新增個人自救案件卷宗',
                  style: t.serifTitle(size: 18.sp, weight: FontWeight.w800),
                ),
                SizedBox(height: 8.h),
                Text(
                  '透過「小法助 AI 問診」描述您的糾紛事實，系統將自動盤點法條時效、必備證據清冊與應對話術，並一鍵歸入案件夾。',
                  style: t.sansBody(
                    size: 12.5.sp,
                    color: t.textSecondary,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 18.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(sheetCtx).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const LawAssistantChatPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: t.brandPrimaryStrong,
                      foregroundColor: const Color(0xFFFAF8F4),
                      padding: EdgeInsets.symmetric(vertical: 13.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    icon: Icon(
                      PhosphorIconsFill.sparkle,
                      size: 16.sp,
                      color: const Color(0xFFEED3A5),
                    ),
                    label: Text(
                      '前往小法助進行深度問診',
                      style: t.sansTitle(
                        size: 13.5.sp,
                        weight: FontWeight.w700,
                        color: const Color(0xFFFAF8F4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _UserCaseDossierCard extends StatefulWidget {
  const _UserCaseDossierCard({
    required this.entry,
    required this.onToggleEvidence,
    required this.onAddLog,
  });

  final UserCaseJournalEntry entry;
  final ValueChanged<int> onToggleEvidence;
  final void Function(String title, String note, String tag) onAddLog;

  @override
  State<_UserCaseDossierCard> createState() => _UserCaseDossierCardState();
}

class _UserCaseDossierCardState extends State<_UserCaseDossierCard> {
  bool _isExpanded = true;
  bool _showAllLogs = false;

  String _toolkitKeyForDomain(TaiwanDisputeDomain domain) {
    return switch (domain) {
      TaiwanDisputeDomain.rentalAndHousing => 'notice',
      TaiwanDisputeDomain.trafficAndTort => 'car',
      TaiwanDisputeDomain.laborAndEmployment => 'overtime',
      TaiwanDisputeDomain.consumerProtection => 'consumer',
      TaiwanDisputeDomain.familyAndDivorce ||
      TaiwanDisputeDomain.inheritanceAndWills =>
        'marriage',
      TaiwanDisputeDomain.propertyAndNeighbor => 'neighbor',
      TaiwanDisputeDomain.defamationAndPrivacy => 'privacy',
      TaiwanDisputeDomain.fraudAndCybercrime => 'antifraud',
      TaiwanDisputeDomain.constructionAndContract ||
      TaiwanDisputeDomain.corporateAndPartnership ||
      TaiwanDisputeDomain.loanAndDebt ||
      TaiwanDisputeDomain.generalCivilAndContract =>
        'contract',
      _ => 'translator',
    };
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final entry = widget.entry;

    final totalEvidences = entry.evidences.length;
    final collectedEvidences =
        entry.evidences.where((e) => e.isCollected).length;
    final progress = entry.evidenceProgress.clamp(0.0, 1.0);
    final progressPct = (progress * 100).round();

    final isUrgent = entry.remainingDays <= 30;
    final deadlineAccent = isUrgent ? t.semanticUrgent : t.accentBrass;
    final deadlineContainer =
        isUrgent ? t.semanticUrgentContainer : t.accentBrassContainer;
    final deadlineText =
        isUrgent ? t.semanticUrgent : t.accentOnBrassContainer;

    return Container(
      decoration: t.cardDecoration(radius: 20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: t.brandContainer,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          entry.status.label,
                          style: t.sansBody(
                            size: 10.5.sp,
                            weight: FontWeight.w700,
                            color: t.brandOnContainer,
                            height: 1.2,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          '相對人：${entry.counterparty}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: t.sansBody(
                            size: 11.5.sp,
                            weight: FontWeight.w600,
                            color: t.textSecondary,
                          ),
                        ),
                      ),
                      if (entry.disputedAmount.isNotEmpty) ...[
                        SizedBox(width: 6.w),
                        Text(
                          entry.disputedAmount,
                          style: t.tabularMetric(
                            size: 12.sp,
                            weight: FontWeight.w700,
                            color: t.accentBrass,
                          ),
                        ),
                      ],
                      SizedBox(width: 6.w),
                      Icon(
                        _isExpanded
                            ? PhosphorIconsRegular.caretUp
                            : PhosphorIconsRegular.caretDown,
                        size: 16.sp,
                        color: t.textMuted,
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    entry.title,
                    style: t.serifTitle(
                      size: 17.sp,
                      weight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Dual-Coding Indicator 1: Statutory Limitation / Deadline Badge
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: deadlineContainer,
                borderRadius: BorderRadius.circular(13.r),
                border: Border.all(
                  color: deadlineAccent.withValues(alpha: 0.45),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isUrgent
                        ? PhosphorIconsFill.warningCircle
                        : PhosphorIconsRegular.clockCountdown,
                    size: 18.sp,
                    color: deadlineAccent,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '法定時效／關鍵期限 · ${entry.statuteDeadlineTitle}',
                          style: t.sansBody(
                            size: 11.5.sp,
                            weight: FontWeight.w700,
                            color: t.textPrimary,
                            height: 1.25,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          entry.statuteDeadlineBasis,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: t.sansBody(
                            size: 10.5.sp,
                            color: t.textSecondary,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 9.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: t.surface,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: deadlineAccent.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Text(
                      '剩餘 ${entry.remainingDays} 天',
                      style: t.tabularMetric(
                        size: 11.5.sp,
                        weight: FontWeight.w700,
                        color: deadlineText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 12.h),

          // Dual-Coding Indicator 2: Linear Evidence Completion Progress Bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: t.subtleBoxDecoration(radius: 13.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        PhosphorIconsRegular.checkSquareOffset,
                        size: 15.sp,
                        color: progress >= 1.0
                            ? t.semanticSuccess
                            : t.brandPrimary,
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          '蒐證與待辦完成度',
                          style: t.sansBody(
                            size: 12.sp,
                            weight: FontWeight.w700,
                            color: t.textPrimary,
                            height: 1.2,
                          ),
                        ),
                      ),
                      Text(
                        totalEvidences == 0
                            ? '100%'
                            : '$collectedEvidences / $totalEvidences ($progressPct%)',
                        style: t.tabularMetric(
                          size: 12.sp,
                          weight: FontWeight.w700,
                          color: progress >= 1.0
                              ? t.semanticSuccess
                              : t.brandPrimary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999.r),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 7.h,
                      backgroundColor: t.surfaceMuted,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress >= 1.0 ? t.semanticSuccess : t.brandPrimary,
                      ),
                    ),
                  ),
                  if (_isExpanded && entry.evidences.isNotEmpty) ...[
                    SizedBox(height: 10.h),
                    ...entry.evidences.asMap().entries.map((item) {
                      final idx = item.key;
                      final ev = item.value;
                      return InkWell(
                        onTap: () => widget.onToggleEvidence(idx),
                        borderRadius: BorderRadius.circular(8.r),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 4.h),
                          child: Row(
                            children: [
                              Icon(
                                ev.isCollected
                                    ? PhosphorIconsFill.checkCircle
                                    : PhosphorIconsRegular.circle,
                                size: 16.sp,
                                color: ev.isCollected
                                    ? t.semanticSuccess
                                    : t.textMuted,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  ev.title,
                                  style: t.sansBody(
                                    size: 12.sp,
                                    color: ev.isCollected
                                        ? t.textMuted
                                        : t.textPrimary,
                                    weight: ev.isCollected
                                        ? FontWeight.w500
                                        : FontWeight.w600,
                                  ).copyWith(
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
                ],
              ),
            ),
          ),

          if (_isExpanded) ...[
            if (entry.tacticalGoldenPhrase.isNotEmpty) ...[
              SizedBox(height: 12.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: t.surface,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border(
                      left: BorderSide(color: t.accentBrass, width: 3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            PhosphorIconsRegular.quotes,
                            size: 14.sp,
                            color: t.accentBrass,
                          ),
                          SizedBox(width: 5.w),
                          Expanded(
                            child: Text(
                              '建議交涉應對金句',
                              style: t.sansBody(
                                size: 11.sp,
                                weight: FontWeight.w700,
                                color: t.accentBrass,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Clipboard.setData(
                                ClipboardData(text: entry.tacticalGoldenPhrase),
                              );
                              CustomToast.show(context, '應對金句已複製到剪貼簿');
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  PhosphorIconsRegular.copy,
                                  size: 13.sp,
                                  color: t.brandPrimary,
                                ),
                                SizedBox(width: 3.w),
                                Text(
                                  '複製',
                                  style: t.sansBody(
                                    size: 11.sp,
                                    weight: FontWeight.w700,
                                    color: t.brandPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        entry.tacticalGoldenPhrase,
                        style: t.serifBody(
                          size: 12.5.sp,
                          color: t.textPrimary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            SizedBox(height: 12.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '交涉與行動日誌 (${entry.logs.length})',
                        style: t.sansBody(
                          size: 12.sp,
                          weight: FontWeight.w700,
                          color: t.textPrimary,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _openAddLogDialog(context),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: Icon(
                          PhosphorIconsRegular.plusCircle,
                          size: 14.sp,
                          color: t.brandPrimary,
                        ),
                        label: Text(
                          '新增紀錄',
                          style: t.sansBody(
                            size: 11.5.sp,
                            weight: FontWeight.w700,
                            color: t.brandPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  ...(_showAllLogs ? entry.logs : entry.logs.take(2)).map(
                    (log) => Padding(
                      padding: EdgeInsets.only(bottom: 7.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: t.surfaceSubtle,
                              borderRadius: BorderRadius.circular(5.r),
                              border: Border.all(color: t.border),
                            ),
                            child: Text(
                              log.tag,
                              style: t.sansBody(
                                size: 10.sp,
                                weight: FontWeight.w700,
                                color: t.textSecondary,
                                height: 1.2,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${log.title} · ${log.timestamp.month}/${log.timestamp.day}',
                                  style: t.sansBody(
                                    size: 11.5.sp,
                                    weight: FontWeight.w700,
                                    color: t.textPrimary,
                                    height: 1.3,
                                  ),
                                ),
                                Text(
                                  log.note,
                                  style: t.sansBody(
                                    size: 11.sp,
                                    color: t.textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (entry.logs.length > 2)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () =>
                            setState(() => _showAllLogs = !_showAllLogs),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          _showAllLogs
                              ? '收合日誌'
                              : '展開全部 ${entry.logs.length} 則日誌',
                          style: t.sansBody(
                            size: 11.sp,
                            weight: FontWeight.w700,
                            color: t.textMuted,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],

          SizedBox(height: 12.h),
          Divider(color: t.border, height: 1),

          // Action Strip: 1-Tap 開啟實戰工具館 + 小法助複盤 + 委任律師
          Padding(
            padding: EdgeInsets.all(14.w),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        CupertinoPageRoute<void>(
                          builder: (_) => LegalToolkitHubPage(
                            initialToolKey: _toolkitKeyForDomain(entry.domain),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: t.brandPrimaryStrong,
                      foregroundColor: const Color(0xFFFAF8F4),
                      padding: EdgeInsets.symmetric(vertical: 11.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    icon: Icon(
                      PhosphorIconsRegular.toolbox,
                      size: 16.sp,
                      color: const Color(0xFFEED3A5),
                    ),
                    label: Text(
                      '開啟實戰工具館（存證信函／金額試算）',
                      style: t.sansBody(
                        size: 12.5.sp,
                        weight: FontWeight.w700,
                        color: const Color(0xFFFAF8F4),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          final latestNote = entry.logs.isNotEmpty
                              ? entry.logs.first.note
                              : entry.initialFacts;
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => LawAssistantChatPage(
                                initialPrompt:
                                    '針對先前的「${entry.title}」，目前進度為：$latestNote，請為我複盤下一步自保行動與具體法律策略。',
                              ),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 9.h),
                          side: BorderSide(color: t.borderStrong),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11.r),
                          ),
                        ),
                        icon: Icon(
                          PhosphorIconsRegular.chatTeardropText,
                          size: 14.sp,
                          color: t.brandPrimary,
                        ),
                        label: Text(
                          '小法助複盤',
                          style: t.sansBody(
                            size: 11.5.sp,
                            weight: FontWeight.w700,
                            color: t.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: OutlinedButton.icon(
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
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 9.h),
                          side: BorderSide(
                            color: t.accentBrass.withValues(alpha: 0.55),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11.r),
                          ),
                        ),
                        icon: Icon(
                          PhosphorIconsRegular.scales,
                          size: 14.sp,
                          color: t.accentBrass,
                        ),
                        label: Text(
                          '委任律師審核',
                          style: t.sansBody(
                            size: 11.5.sp,
                            weight: FontWeight.w700,
                            color: t.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openAddLogDialog(BuildContext context) {
    final t = context.tokens;
    final titleCtrl = TextEditingController(text: '與相對人協商紀錄');
    final noteCtrl = TextEditingController();
    String selectedTag = '通話/對話';

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDlgState) {
            return AlertDialog(
              backgroundColor: t.surfaceElevated,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.r),
                side: BorderSide(color: t.border),
              ),
              title: Text(
                '新增交涉筆記',
                style: t.serifTitle(size: 16.sp, weight: FontWeight.w800),
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
                    SizedBox(height: 10.h),
                    Wrap(
                      spacing: 6.w,
                      runSpacing: 6.h,
                      children: ['通話/對話', 'LINE文字', '現場點交', '存證信函', '調解會']
                          .map(
                            (tag) => ChoiceChip(
                              label: Text(tag),
                              selected: selectedTag == tag,
                              onSelected: (_) {
                                setDlgState(() => selectedTag = tag);
                              },
                            ),
                          )
                          .toList(),
                    ),
                    SizedBox(height: 10.h),
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
                  child: Text(
                    '取消',
                    style: t.sansBody(
                      weight: FontWeight.w600,
                      color: t.textSecondary,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: t.brandPrimaryStrong,
                    foregroundColor: const Color(0xFFFAF8F4),
                  ),
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
                      CustomToast.show(context, '已成功新增交涉日誌');
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
