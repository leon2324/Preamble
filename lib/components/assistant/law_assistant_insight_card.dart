import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:preamble/components/safety/negotiation_kit_card.dart';
import 'package:preamble/components/safety/statute_countdown_badge.dart';
import 'package:preamble/components/shared/custom_toast.dart';
import 'package:preamble/data/documents/document_models.dart';
import 'package:preamble/data/law_assistant/law_assistant_models.dart';
import 'package:preamble/theme/preamble_tokens.dart';

/// 小法助對話底部的「靜奢雙重編碼」攻防洞察與行動交付卡片。
///
/// 以清晰的垂直雙層架構收斂為三大模組：
/// 1. `爭點核心`（定心丸與對方常見抗辯）
/// 2. `法條依據`（宋體法源引證與法定時效倒數）
/// 3. `下一步行動`（現場應對金句、關鍵舉證清單與一鍵書狀／律師轉介）
class LawAssistantInsightCard extends StatefulWidget {
  const LawAssistantInsightCard({
    super.key,
    required this.insight,
    required this.onConvertToDocument,
    this.onConsultLawyer,
    this.onSaveToJournal,
    this.initiallyExpanded = true,
  });

  final LawAssistantDefenseInsight insight;
  final void Function(DocumentTemplateType templateType, String suggestedFacts)
      onConvertToDocument;
  final VoidCallback? onConsultLawyer;
  final VoidCallback? onSaveToJournal;
  // 台灣繁體中文教學註解：對話頁可預設收合洞察卡片，避免一次堆疊過多框線；獨立元件測試預設展開。
  final bool initiallyExpanded;

  @override
  State<LawAssistantInsightCard> createState() =>
      _LawAssistantInsightCardState();
}

class _LawAssistantInsightCardState extends State<LawAssistantInsightCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  static final RegExp _leadingEmojiRegex = RegExp(
    r'^[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}\u{FE0F}\s]+',
    unicode: true,
  );

  String _cleanText(String raw) {
    return raw.replaceFirst(_leadingEmojiRegex, '').trim();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final insight = widget.insight;

    return Container(
      margin: EdgeInsets.only(top: 12.h, bottom: 6.h),
      decoration: t.cardDecoration(
        radius: 18.r,
        fill: t.surface,
        borderColor: t.borderStrong,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 頂部標題列（可收合）
          InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _isExpanded = !_isExpanded);
            },
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(18.r),
              bottom: _isExpanded ? Radius.zero : Radius.circular(18.r),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              child: Row(
                children: [
                  Container(
                    width: 34.w,
                    height: 34.w,
                    decoration: BoxDecoration(
                      color: t.brandContainer,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: t.brandPrimary.withValues(alpha: 0.22),
                      ),
                    ),
                    child: Icon(
                      PhosphorIconsRegular.scales,
                      size: 18.sp,
                      color: t.brandPrimary,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '攻防洞察與雙重編碼指引',
                          style: t.sansTitle(size: 13.5.sp),
                        ),
                        SizedBox(height: 2.h),
                        Wrap(
                          spacing: 6.w,
                          runSpacing: 4.h,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              insight.disputeCategory,
                              style: t.sansBody(
                                size: 11.5.sp,
                                weight: FontWeight.w600,
                                color: t.brandPrimary,
                              ),
                            ),
                            if (insight.detectedAmount.isNotEmpty)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6.w,
                                  vertical: 1.5.h,
                                ),
                                decoration: BoxDecoration(
                                  color: t.accentBrassContainer,
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Text(
                                  '標的 ${insight.detectedAmount}',
                                  style: t.tabularMetric(
                                    size: 11.sp,
                                    color: t.accentOnBrassContainer,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Icon(
                    _isExpanded
                        ? PhosphorIconsRegular.caretUp
                        : PhosphorIconsRegular.caretDown,
                    size: 18.sp,
                    color: t.textSecondary,
                  ),
                ],
              ),
            ),
          ),

          if (_isExpanded) ...[
            Divider(height: 1, color: t.border),
            Padding(
              padding: EdgeInsets.all(14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 頂層三維概覽標籤列（Wrap 自適應，320pt 與大字級絕不溢位）
                  _buildDualCodingOverviewStrip(t, insight),
                  SizedBox(height: 12.h),

                  // 模組一：爭點核心
                  _buildDisputeCoreSection(t, insight),
                  SizedBox(height: 10.h),

                  // 模組二：法條依據與時效生死線
                  _buildLegalBasisSection(t, insight),
                  SizedBox(height: 10.h),

                  // 模組三：下一步行動（應對金句 + 舉證清單 + 轉書狀交付）
                  _buildNextActionsSection(context, t, insight),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDualCodingOverviewStrip(
    PreambleTokens t,
    LawAssistantDefenseInsight insight,
  ) {
    final defenseCount = insight.defensePoints.length;
    final deadlineLabel = insight.statuteDeadline != null
        ? '${insight.statuteDeadline!.durationDays} 日時效'
        : '一般法定時效';
    final evidenceCount = insight.keyEvidences.length;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: t.subtleBoxDecoration(radius: 12.r),
      child: Wrap(
        spacing: 12.w,
        runSpacing: 8.h,
        alignment: WrapAlignment.spaceBetween,
        children: [
          _buildOverviewMetric(
            t: t,
            icon: PhosphorIconsRegular.crosshair,
            accent: t.accentBrass,
            label: '爭點核心',
            value: '$defenseCount 項抗辯預判',
          ),
          _buildOverviewMetric(
            t: t,
            icon: PhosphorIconsRegular.bookBookmark,
            accent: t.brandPrimary,
            label: '法條依據',
            value: deadlineLabel,
          ),
          _buildOverviewMetric(
            t: t,
            icon: PhosphorIconsRegular.footprints,
            accent: t.semanticSuccess,
            label: '下一步行動',
            value: '$evidenceCount 項關鍵舉證',
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewMetric({
    required PreambleTokens t,
    required IconData icon,
    required Color accent,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14.sp, color: accent),
        SizedBox(width: 5.w),
        Text(
          '$label：',
          style: t.sansBody(
            size: 11.sp,
            weight: FontWeight.w600,
            color: t.textSecondary,
          ),
        ),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: t.tabularMetric(size: 11.5.sp, color: t.textPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader({
    required PreambleTokens t,
    required String stepCode,
    required String title,
    required IconData icon,
    required Color badgeBg,
    required Color badgeFg,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: badgeBg,
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 12.sp, color: badgeFg),
              SizedBox(width: 4.w),
              Text(
                stepCode,
                style: t.tabularMetric(size: 11.sp, color: badgeFg),
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            title,
            style: t.sansTitle(size: 13.sp),
          ),
        ),
      ],
    );
  }

  Widget _buildDisputeCoreSection(
    PreambleTokens t,
    LawAssistantDefenseInsight insight,
  ) {
    final reassurance = _cleanText(insight.immediateReassurance);

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: t.surfaceSubtle.withValues(alpha: t.isDark ? 0.65 : 0.75),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: t.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            t: t,
            stepCode: '01',
            title: '爭點核心 · 相對人常見抗辯預判',
            icon: PhosphorIconsRegular.crosshair,
            badgeBg: t.accentBrassContainer,
            badgeFg: t.accentOnBrassContainer,
          ),
          if (reassurance.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: t.brandContainer,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 2.h),
                    child: Icon(
                      PhosphorIconsFill.shieldCheck,
                      size: 15.sp,
                      color: t.brandPrimary,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      reassurance,
                      style: t.sansBody(
                        size: 12.sp,
                        color: t.brandOnContainer,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (insight.defensePoints.isNotEmpty) ...[
            SizedBox(height: 10.h),
            for (final point in insight.defensePoints)
              Padding(
                padding: EdgeInsets.only(bottom: 6.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 3.h),
                      child: Icon(
                        PhosphorIconsRegular.warningCircle,
                        size: 14.sp,
                        color: t.accentBrass,
                      ),
                    ),
                    SizedBox(width: 7.w),
                    Expanded(
                      child: Text(
                        _cleanText(point),
                        style: t.sansBody(
                          size: 12.sp,
                          color: t.textPrimary,
                          height: 1.45,
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

  Widget _buildLegalBasisSection(
    PreambleTokens t,
    LawAssistantDefenseInsight insight,
  ) {
    final deadline = insight.statuteDeadline;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: t.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            t: t,
            stepCode: '02',
            title: '法條依據 · 請求權基礎與法定時效',
            icon: PhosphorIconsRegular.bookBookmark,
            badgeBg: t.brandContainer,
            badgeFg: t.brandOnContainer,
          ),
          SizedBox(height: 8.h),
          if (deadline != null) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: t.surfaceSubtle,
                borderRadius: BorderRadius.circular(10.r),
                border: Border(
                  left: BorderSide(color: t.accentBrass, width: 3.w),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 4.h,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        deadline.legalBasis,
                        style: t.serifBody(
                          size: 13.5.sp,
                          weight: FontWeight.w700,
                          color: t.textPrimary,
                          height: 1.5,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 7.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: t.semanticUrgentContainer,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          '黃金時效 ${deadline.durationDays} 日',
                          style: t.tabularMetric(
                            size: 11.sp,
                            color: t.semanticUrgent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    deadline.urgencyDescription,
                    style: t.sansBody(
                      size: 11.5.sp,
                      color: t.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            StatuteCountdownBadge(deadline: deadline),
          ] else
            Text(
              '請依雙方法律關係檢附契約與金流憑證，並留意民法一般請求權消滅時效與刑事告訴乃論 6 個月期間。',
              style: t.serifBody(
                size: 13.sp,
                color: t.textPrimary,
                height: 1.6,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNextActionsSection(
    BuildContext context,
    PreambleTokens t,
    LawAssistantDefenseInsight insight,
  ) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: t.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            t: t,
            stepCode: '03',
            title: '下一步行動 · 應對金句與舉證交付',
            icon: PhosphorIconsRegular.footprints,
            badgeBg: t.semanticSuccessContainer,
            badgeFg: t.semanticSuccess,
          ),
          SizedBox(height: 10.h),

          // 現場 / LINE 應對金句
          if (insight.tacticalGoldenPhrase.isNotEmpty) ...[
            _buildTacticalGoldenPhraseBox(
              context: context,
              t: t,
              goldenPhrase: insight.tacticalGoldenPhrase,
            ),
            SizedBox(height: 10.h),
          ],

          // 現場談判防坑錦囊
          if (insight.negotiationKit != null) ...[
            NegotiationKitCard(
              threeNeverSign: insight.negotiationKit!.threeNeverSign,
              threeMustAsk: insight.negotiationKit!.threeMustAsk,
              recordingLegalityTip:
                  insight.negotiationKit!.recordingLegalityTip,
            ),
            SizedBox(height: 10.h),
          ],

          // 建議優先蒐集舉證清單
          if (insight.keyEvidences.isNotEmpty) ...[
            Row(
              children: [
                Icon(
                  PhosphorIconsRegular.listChecks,
                  size: 15.sp,
                  color: t.brandPrimary,
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    '建議優先保全之關鍵證據清單',
                    style: t.sansBody(
                      size: 12.sp,
                      weight: FontWeight.w700,
                      color: t.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            for (final evidence in insight.keyEvidences)
              Padding(
                padding: EdgeInsets.only(bottom: 5.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 2.h),
                      child: Icon(
                        PhosphorIconsRegular.checkCircle,
                        size: 14.sp,
                        color: t.semanticSuccess,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        _cleanText(evidence),
                        style: t.sansBody(
                          size: 12.sp,
                          color: t.textSecondary,
                          height: 1.42,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(height: 12.h),
          ],

          // 主要交付行動：一鍵轉入實體書狀
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                widget.onConvertToDocument(
                  insight.suggestedTemplateType,
                  insight.extractedFacts,
                );
              },
              icon: Icon(
                PhosphorIconsRegular.fileText,
                size: 16.sp,
                color: t.brandOnPrimary,
              ),
              label: Text(
                _cleanText(insight.suggestedActionLabel),
                style: t.sansBody(
                  size: 12.5.sp,
                  weight: FontWeight.w700,
                  color: t.brandOnPrimary,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: t.brandPrimary,
                foregroundColor: t.brandOnPrimary,
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
          ),

          // 次要交付行動：存入「紀事」追蹤
          if (widget.onSaveToJournal != null) ...[
            SizedBox(height: 8.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  widget.onSaveToJournal!();
                },
                icon: Icon(
                  PhosphorIconsRegular.bookmarkSimple,
                  size: 15.sp,
                  color: t.brandPrimary,
                ),
                label: Text(
                  '存入「紀事」自救進度追蹤',
                  style: t.sansBody(
                    size: 12.sp,
                    weight: FontWeight.w700,
                    color: t.brandPrimary,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: t.borderStrong),
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
            ),
          ],

          // 次要交付行動：預約執業律師
          if (widget.onConsultLawyer != null) ...[
            SizedBox(height: 8.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  widget.onConsultLawyer!();
                },
                icon: Icon(
                  PhosphorIconsRegular.gavel,
                  size: 15.sp,
                  color: t.accentOnBrassContainer,
                ),
                label: Text(
                  '一鍵打包案情簡報並預約認證律師',
                  style: t.sansBody(
                    size: 12.sp,
                    weight: FontWeight.w700,
                    color: t.accentOnBrassContainer,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: t.accentBrassContainer.withValues(alpha: 0.45),
                  side: BorderSide(
                    color: t.accentBrass.withValues(alpha: 0.45),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTacticalGoldenPhraseBox({
    required BuildContext context,
    required PreambleTokens t,
    required String goldenPhrase,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: t.surfaceSubtle,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: t.borderStrong),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8.w,
            runSpacing: 6.h,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    PhosphorIconsRegular.chatTeardropText,
                    size: 15.sp,
                    color: t.brandPrimary,
                  ),
                  SizedBox(width: 6.w),
                  Flexible(
                    child: Text(
                      '現場 / LINE 應對金句（可直接複製發送）',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: t.sansBody(
                        size: 11.5.sp,
                        weight: FontWeight.w700,
                        color: t.brandPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: goldenPhrase));
                  HapticFeedback.mediumImpact();
                  CustomToast.show(context, '應對金句已複製到剪貼簿，可直接貼上發送');
                },
                borderRadius: BorderRadius.circular(8.r),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: t.brandPrimary,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        PhosphorIconsRegular.copy,
                        size: 13.sp,
                        color: t.brandOnPrimary,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '一鍵複製',
                        style: t.sansBody(
                          size: 11.sp,
                          weight: FontWeight.w700,
                          color: t.brandOnPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 9.h),
            decoration: BoxDecoration(
              color: t.surface,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: t.border),
            ),
            child: Text(
              goldenPhrase,
              style: t.serifBody(
                size: 13.sp,
                weight: FontWeight.w600,
                color: t.textPrimary,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
