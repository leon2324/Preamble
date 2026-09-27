import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/features/case_library/models/case_library_models.dart';
import 'package:preamble/features/case_library/theme/case_library_theme.dart';

/// 維基百科式「案件條目資訊框」（Wikipedia Case Infobox）。
///
/// 依據真實司法院與憲法法庭裁判書規格，提供全方位的結構化訴訟速覽：
/// 包含審理法院、正式裁判字號、宣判日期、案由、審判長/主筆大法官、聲請人/當事人、核心法規、判決主文與後續修法影響。
class WikipediaInfoboxCard extends StatefulWidget {
  const WikipediaInfoboxCard({
    super.key,
    required this.book,
    this.initialExpanded = true,
  });

  final CaseBook book;
  final bool initialExpanded;

  @override
  State<WikipediaInfoboxCard> createState() => _WikipediaInfoboxCardState();
}

class _WikipediaInfoboxCardState extends State<WikipediaInfoboxCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initialExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    final basic = book.basicInfo;

    // Determine court badge and styling
    final isConstitutional = book.category.contains('憲法') ||
        book.category.contains('司法解釋') ||
        book.titleZh.contains('憲判') ||
        book.titleZh.contains('釋字');

    final badgeLabel = isConstitutional ? '🏛️ 憲法法庭 / 大法官裁判' : '⚖️ 司法院確定終局裁判';

    final officialCitation = basic.caseNumber?.isNotEmpty == true
        ? basic.caseNumber!
        : (book.displayCode.isNotEmpty ? book.displayCode : book.titleZh);

    final judgmentDateText = basic.judgmentDate?.isNotEmpty == true
        ? basic.judgmentDate!
        : '${book.year} 年（${basic.updatedAt}）';

    final benchText = basic.bench?.isNotEmpty == true
        ? basic.bench!
        : (book.people.any((p) => p.role.contains('審判') || p.role.contains('法官'))
            ? book.people
                .firstWhere(
                    (p) => p.role.contains('審判') || p.role.contains('法官'))
                .description
            : '司法院合議庭');

    final partiesText = basic.partiesOrPetitioner?.isNotEmpty == true
        ? basic.partiesOrPetitioner!
        : (book.people.isNotEmpty
            ? book.people.map((p) => '${p.role}：${p.description}').join('\n')
            : '全案當事人詳見判決');

    final causeText = basic.cause?.isNotEmpty == true
        ? basic.cause!
        : (book.oneSentenceSummary.isNotEmpty
            ? book.oneSentenceSummary
            : book.category);

    final subsequentText = basic.subsequentAction?.isNotEmpty == true
        ? basic.subsequentAction!
        : (book.socialImpact.isNotEmpty ? book.socialImpact : null);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
        color: CaseLibraryColors.bgWhite,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFFC4D5CB),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header banner (Wikipedia article infobox header)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: isConstitutional
                  ? const Color(0xFFEBF3F0)
                  : const Color(0xFFF0F4F8),
              borderRadius: BorderRadius.vertical(top: Radius.circular(10.5.r)),
              border: Border(
                bottom: BorderSide(
                  color: isConstitutional
                      ? const Color(0xFFC4D5CB)
                      : const Color(0xFFD0DDEB),
                  width: 1.0,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: CaseLibraryColors.primaryGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    badgeLabel,
                    style: TextStyle(
                      fontSize: 10.5.sp,
                      fontWeight: FontWeight.w900,
                      color: CaseLibraryColors.primaryGreen,
                    ),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _isExpanded ? '收合案件速覽' : '展開案件速覽',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: CaseLibraryColors.primaryGreen,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        size: 16.sp,
                        color: CaseLibraryColors.primaryGreen,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Title & Citation in Infobox
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 6.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.titleZh,
                  style: TextStyle(
                    fontFamily: 'Songti TC',
                    fontFamilyFallback: const [
                      'BiauKai',
                      'Songti SC',
                      'STSong'
                    ],
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w900,
                    color: CaseLibraryColors.primaryGreen,
                    height: 1.35,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '正式案號：$officialCitation',
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w800,
                    color: CaseLibraryColors.accentGold,
                  ),
                ),
              ],
            ),
          ),

          if (_isExpanded) ...[
            const Divider(height: 1, color: CaseLibraryColors.borderLight),
            _buildInfoRow('審理法院／機關', basic.courtLevel, isFirst: true),
            _buildInfoRow('正式裁判字號', officialCitation),
            _buildInfoRow('宣判／作成日期', judgmentDateText),
            _buildInfoRow('案件爭點案由', causeText),
            _buildInfoRow('審判長／主筆大法官', benchText),
            _buildInfoRow('聲請人／關係當事人', partiesText),
            if (book.relatedLaws.isNotEmpty)
              _buildInfoRow(
                '主要適用法規',
                book.relatedLaws
                    .take(3)
                    .map((l) => '${l.lawName} ${l.articleNumber}')
                    .join('、'),
              ),
            _buildInfoRow(
              '裁判主文與宣告',
              book.judgmentResult.isNotEmpty
                  ? book.judgmentResult
                  : '裁判確定，駁回上訴。',
              isHighlight: true,
            ),
            if (subsequentText != null)
              _buildInfoRow('後續修法與司法效應', subsequentText, isLast: true),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool isFirst = false,
    bool isLast = false,
    bool isHighlight = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.5.h),
      decoration: BoxDecoration(
        color: isHighlight
            ? const Color(0xFFF6FAF8)
            : (isFirst ? Colors.transparent : const Color(0xFFFAFAF7)),
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : const BorderSide(
                  color: CaseLibraryColors.borderLight,
                  width: 0.8,
                ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 108.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w800,
                color: CaseLibraryColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 11.5.sp,
                fontWeight: isHighlight ? FontWeight.w900 : FontWeight.w600,
                color: isHighlight
                    ? const Color(0xFF1B5E20)
                    : CaseLibraryColors.textPrimary,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
