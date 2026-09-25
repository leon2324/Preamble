import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/features/case_library/theme/case_library_theme.dart';

/// 維基百科條目目錄項目定義
class WikipediaTocItem {
  const WikipediaTocItem({
    required this.indexLabel,
    required this.title,
    required this.targetTab,
    this.subItems = const [],
  });

  final String indexLabel;
  final String title;
  final String targetTab;
  final List<String> subItems;
}

/// 維基百科式「條目目錄導覽列」（Wikipedia Table of Contents / TOC）。
///
/// 讓使用者在查閱篇幅長、論理深奧的重大判決時，如同閱讀維基百科一般，
/// 能一目瞭然全案章節架構，並可點擊一鍵平滑跳轉至該主題段落。
class WikipediaTableOfContents extends StatefulWidget {
  const WikipediaTableOfContents({
    super.key,
    required this.activeTab,
    required this.onSelectTab,
    this.initialExpanded = true,
  });

  final String activeTab;
  final ValueChanged<String> onSelectTab;
  final bool initialExpanded;

  @override
  State<WikipediaTableOfContents> createState() =>
      _WikipediaTableOfContentsState();
}

class _WikipediaTableOfContentsState extends State<WikipediaTableOfContents> {
  late bool _isExpanded;

  static const List<WikipediaTocItem> _tocItems = [
    WikipediaTocItem(
      indexLabel: '1',
      title: '事件背景與始末',
      targetTab: '事件背景',
      subItems: ['案發由來', '當事人主張', '司法資料來源'],
    ),
    WikipediaTocItem(
      indexLabel: '2',
      title: '事件與訴訟大事紀脈絡',
      targetTab: '事件與訴訟脈絡',
      subItems: ['審級歷程', '起訴與偵查', '重大審理時間線'],
    ),
    WikipediaTocItem(
      indexLabel: '3',
      title: '核心法律爭點與法理辯論',
      targetTab: '法律爭點',
      subItems: ['爭點剖析', '白話法律釋義', '與本案法律關聯'],
    ),
    WikipediaTocItem(
      indexLabel: '4',
      title: '法院心證與裁判論述',
      targetTab: '裁判心證',
      subItems: ['合議庭認定', '大法官不同意見書', '關鍵法律原則'],
    ),
    WikipediaTocItem(
      indexLabel: '5',
      title: '司法院裁判書官方全文與要旨',
      targetTab: '完整判決書',
      subItems: ['裁判主文', '理由要領', '適用法規條號'],
    ),
    WikipediaTocItem(
      indexLabel: '6',
      title: '相關法規條文對照',
      targetTab: '相關法條',
      subItems: ['憲法保障條文', '實體法與程序法'],
    ),
    WikipediaTocItem(
      indexLabel: '7',
      title: '社會影響與後續修法效應',
      targetTab: '社會影響',
      subItems: ['輿論反應', '法制修訂歷程', '人權指標意義'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initialExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FBF9),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: const Color(0xFFD6E3DB),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with TOC title and toggle
          Row(
            children: [
              Text(
                '目錄',
                style: TextStyle(
                  fontFamily: 'Songti TC',
                  fontFamilyFallback: const [
                    'BiauKai',
                    'Songti SC',
                    'STSong'
                  ],
                  fontSize: 14.5.sp,
                  fontWeight: FontWeight.w900,
                  color: CaseLibraryColors.primaryGreen,
                ),
              ),
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                behavior: HitTestBehavior.opaque,
                child: Text(
                  _isExpanded ? '[隱藏]' : '[顯示]',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1B65A4),
                  ),
                ),
              ),
            ],
          ),

          if (_isExpanded) ...[
            SizedBox(height: 8.h),
            const Divider(height: 1, color: Color(0xFFE0EAE4)),
            SizedBox(height: 8.h),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _tocItems.map((item) {
                final isCurrent = widget.activeTab == item.targetTab;
                return Padding(
                  padding: EdgeInsets.only(bottom: 6.h),
                  child: InkWell(
                    onTap: () => widget.onSelectTab(item.targetTab),
                    borderRadius: BorderRadius.circular(4.r),
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${item.indexLabel} ',
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w900,
                              color: isCurrent
                                  ? CaseLibraryColors.primaryGreen
                                  : const Color(0xFF1B65A4),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              item.title,
                              style: TextStyle(
                                fontSize: 11.5.sp,
                                fontWeight: isCurrent
                                    ? FontWeight.w900
                                    : FontWeight.w600,
                                color: isCurrent
                                    ? CaseLibraryColors.primaryGreen
                                    : const Color(0xFF1B65A4),
                                decoration: isCurrent
                                    ? TextDecoration.none
                                    : TextDecoration.underline,
                                decorationColor: const Color(0xFF1B65A4),
                              ),
                            ),
                          ),
                          if (isCurrent)
                            Container(
                              margin: EdgeInsets.only(left: 6.w),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6.w, vertical: 1.h),
                              decoration: BoxDecoration(
                                color: CaseLibraryColors.primaryGreen
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                '當前閱讀',
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.bold,
                                  color: CaseLibraryColors.primaryGreen,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
