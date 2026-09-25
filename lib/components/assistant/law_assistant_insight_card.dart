import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/data/documents/document_models.dart';
import 'package:preamble/data/law_assistant/law_assistant_models.dart';
import 'package:preamble/components/safety/statute_countdown_badge.dart';
import 'package:preamble/components/safety/negotiation_kit_card.dart';

/// 小法助對話底部的攻防洞察與書狀一鍵生成卡片。
///
/// 採用莫蘭迪紙質感設計，將 AI 對話的抽象分析收斂為實體行動方案（交付物）。
class LawAssistantInsightCard extends StatefulWidget {
  const LawAssistantInsightCard({
    super.key,
    required this.insight,
    required this.onConvertToDocument,
    this.onConsultLawyer,
    this.onSaveToJournal,
  });

  final LawAssistantDefenseInsight insight;
  final void Function(DocumentTemplateType templateType, String suggestedFacts)
      onConvertToDocument;
  final VoidCallback? onConsultLawyer;
  final VoidCallback? onSaveToJournal;

  @override
  State<LawAssistantInsightCard> createState() =>
      _LawAssistantInsightCardState();
}

class _LawAssistantInsightCardState extends State<LawAssistantInsightCard> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final insight = widget.insight;

    final cardBg = isDark ? const Color(0xFF1E2824) : const Color(0xFFF3F7F5);
    final borderColor =
        isDark ? const Color(0xFF2C3E36) : const Color(0xFFDCE7E2);
    final headerColor =
        isDark ? const Color(0xFFE8F1EC) : const Color(0xFF17231F);
    final accentGreen =
        isDark ? const Color(0xFF68B28B) : const Color(0xFF2C5E43);
    final lightAmber =
        isDark ? const Color(0xFF33291A) : const Color(0xFFFDF7E7);
    final amberBorder =
        isDark ? const Color(0xFF5C4724) : const Color(0xFFF0DEB4);
    final amberText =
        isDark ? const Color(0xFFE5C07B) : const Color(0xFF9E6800);

    return Container(
      margin: EdgeInsets.only(top: 10.h, bottom: 4.h),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: borderColor, width: 1.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 頂部標題列
          InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _isExpanded = !_isExpanded);
            },
            borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(5.w),
                    decoration: BoxDecoration(
                      color: accentGreen.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.balance_rounded,
                      size: 15.sp,
                      color: accentGreen,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '攻防洞察與舉證指引',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: headerColor,
                          ),
                        ),
                        Text(
                          insight.disputeCategory,
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: accentGreen,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 20.sp,
                    color: isDark ? Colors.white60 : Colors.black45,
                  ),
                ],
              ),
            ),
          ),

          if (_isExpanded) ...[
            Divider(height: 1, color: borderColor),
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 0. 現場 / LINE 應對金句與即時定心丸 (Tactical Golden Phrase)
                  if (insight.tacticalGoldenPhrase.isNotEmpty) ...[
                    _buildTacticalGoldenPhraseBox(
                      context: context,
                      reassurance: insight.immediateReassurance,
                      goldenPhrase: insight.tacticalGoldenPhrase,
                      isDark: isDark,
                      accentGreen: accentGreen,
                      headerColor: headerColor,
                    ),
                    SizedBox(height: 10.h),
                  ],

                  // 0.2 法律時效生死線倒數膠囊 (Statute Countdown)
                  if (insight.statuteDeadline != null)
                    StatuteCountdownBadge(deadline: insight.statuteDeadline!),

                  // 0.5 現場談判防坑三不原則錦囊 (Negotiation Defense Kit)
                  if (insight.negotiationKit != null)
                    NegotiationKitCard(
                      threeNeverSign: insight.negotiationKit!.threeNeverSign,
                      threeMustAsk: insight.negotiationKit!.threeMustAsk,
                      recordingLegalityTip:
                          insight.negotiationKit!.recordingLegalityTip,
                    ),

                  // 1. 對方可能主張
                  if (insight.defensePoints.isNotEmpty) ...[
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: lightAmber,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: amberBorder, width: 0.8.w),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.lightbulb_outline_rounded,
                                size: 14.sp,
                                color: amberText,
                              ),
                              SizedBox(width: 5.w),
                              Text(
                                '對方常見抗辯與可能主張',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold,
                                  color: amberText,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6.h),
                          for (final point in insight.defensePoints)
                            Padding(
                              padding: EdgeInsets.only(bottom: 4.h),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '• ',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: amberText,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      point,
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        height: 1.35,
                                        color: isDark
                                            ? const Color(0xFFE2D6C0)
                                            : const Color(0xFF523D1B),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10.h),
                  ],

                  // 2. 關鍵舉證清單
                  if (insight.keyEvidences.isNotEmpty) ...[
                    Text(
                      '📋 建議優先蒐集之舉證清單：',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: headerColor,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    for (final evidence in insight.keyEvidences)
                      Padding(
                        padding: EdgeInsets.only(bottom: 4.h),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.check_circle_outline_rounded,
                              size: 13.sp,
                              color: accentGreen,
                            ),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Text(
                                evidence,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  height: 1.35,
                                  color: isDark
                                      ? Colors.white70
                                      : const Color(0xFF4A5550),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(height: 10.h),
                  ],

                  // 3. 一鍵轉入實體書狀按鈕
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        widget.onConvertToDocument(
                          insight.suggestedTemplateType,
                          insight.extractedFacts,
                        );
                      },
                      icon: Icon(
                        Icons.description_outlined,
                        size: 15.sp,
                        color: Colors.white,
                      ),
                      label: Text(
                        insight.suggestedActionLabel,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    ),
                  ),

                  // 4. 存入自救記事按鈕
                  if (widget.onSaveToJournal != null) ...[
                    SizedBox(height: 6.h),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          widget.onSaveToJournal!();
                        },
                        icon: Icon(
                          Icons.bookmark_add_outlined,
                          size: 14.sp,
                          color: accentGreen,
                        ),
                        label: Text(
                          '📥 存入「紀事」自救進度追蹤',
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.bold,
                            color: accentGreen,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: accentGreen.withValues(alpha: 0.5),
                            width: 1.w,
                          ),
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      ),
                    ),
                  ],

                  // 5. 尋求專長執業律師按鈕
                  if (widget.onConsultLawyer != null) ...[
                    SizedBox(height: 6.h),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          widget.onConsultLawyer!();
                        },
                        icon: Icon(
                          Icons.gavel_rounded,
                          size: 14.sp,
                          color: accentGreen,
                        ),
                        label: Text(
                          '一鍵打包案情簡報並預約認證律師',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: accentGreen,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: accentGreen.withValues(alpha: 0.5),
                            width: 1.w,
                          ),
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTacticalGoldenPhraseBox({
    required BuildContext context,
    required String reassurance,
    required String goldenPhrase,
    required bool isDark,
    required Color accentGreen,
    required Color headerColor,
  }) {
    final boxBg = isDark ? const Color(0xFF1B2B23) : const Color(0xFFEBF5F0);
    final boxBorder = isDark ? const Color(0xFF325443) : const Color(0xFFC3DEC8);

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: boxBg,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: boxBorder, width: 1.w),
        boxShadow: [
          BoxShadow(
            color: accentGreen.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: accentGreen.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 14.sp,
                  color: accentGreen,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  '現場 / LINE 應對金句（可直接複製發送）',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: accentGreen,
                  ),
                ),
              ),
            ],
          ),
          if (reassurance.isNotEmpty) ...[
            SizedBox(height: 6.h),
            Text(
              reassurance,
              style: TextStyle(
                fontSize: 10.5.sp,
                height: 1.4,
                color: isDark ? const Color(0xFFD0E2D8) : const Color(0xFF2C4C3B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          SizedBox(height: 8.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF14201A) : Colors.white,
              borderRadius: BorderRadius.circular(6.r),
              border: Border.all(
                color: isDark ? const Color(0xFF2E483A) : const Color(0xFFD6E8DC),
                width: 0.8.w,
              ),
            ),
            child: Text(
              goldenPhrase,
              style: TextStyle(
                fontSize: 11.5.sp,
                height: 1.45,
                color: headerColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () {
                Clipboard.setData(ClipboardData(text: goldenPhrase));
                HapticFeedback.mediumImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      '📋 應對金句已複製到剪貼簿！可直接貼至 LINE 或在現場照著唸。',
                      style: TextStyle(fontSize: 12),
                    ),
                    backgroundColor: Color(0xFF2C5E43),
                    duration: Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              borderRadius: BorderRadius.circular(6.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: accentGreen,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.copy_rounded,
                      size: 12.sp,
                      color: Colors.white,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '一鍵複製金句',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
