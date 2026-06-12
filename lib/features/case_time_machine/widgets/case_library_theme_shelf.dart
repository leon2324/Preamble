import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/features/case_time_machine/models/case_time_machine_models.dart';
import 'package:lawapp/features/case_time_machine/theme/case_time_machine_theme.dart';
import 'package:lawapp/features/case_time_machine/widgets/case_library_section_header.dart';

// 台灣繁體中文教學註解：
// 核心議題→固定配色對照表。這裡不要再用 index 輪播顏色，
// 否則同一個案件出現在不同 Shelf 時會變色，使用者會失去案件類型的色彩記憶。
const _coreIssueAccents = <String, ({Color color, Color bgTint})>{
  '集會遊行': (color: Color(0xFF4A7C8C), bgTint: Color(0xFFEAF4F7)),
  '婚姻平權': (color: Color(0xFF357A53), bgTint: Color(0xFFEAF6EF)),
  '強制治療': (color: Color(0xFF6D649A), bgTint: Color(0xFFF0EEF9)),
  '死刑制度': (color: Color(0xFF8C4A5A), bgTint: Color(0xFFF8EEF0)),
  '新聞自由': (color: Color(0xFF9E7B2D), bgTint: Color(0xFFFFF2CF)),
  '修憲程序': (color: Color(0xFF4A7C8C), bgTint: Color(0xFFEAF4F7)),
  '軍事司法': (color: Color(0xFF5A6B4F), bgTint: Color(0xFFEFF4EA)),
  '詐欺犯罪': (color: Color(0xFF8C642B), bgTint: Color(0xFFFFF2CF)),
};

// 台灣繁體中文教學註解：
// 重要案件 id 先做明確指定，避免資料的 category 或 tag 之後被文案調整時，
// 太陽花、釋字 748、釋字 799、死刑憲判這類核心案件的色彩跟著漂移。
const _caseIssueOverrides = <String, String>{
  '318': '集會遊行',
  '101': '婚姻平權',
  '748': '婚姻平權',
  '799': '強制治療',
  '103': '死刑制度',
  '499': '修憲程序',
  '520': '修憲程序',
  '102': '新聞自由',
  'hung-2013': '軍事司法',
  'ding-2015': '詐欺犯罪',
};

// 台灣繁體中文教學註解：
// 若未來資料來源不是固定 id，而是來自搜尋或後端同步，仍可透過標題與 tags 的關鍵字
// 解析核心議題。這是保底規則，不會取代上方 id 指定。
const _coreIssueKeywords = <String, List<String>>{
  '集會遊行': ['太陽花', '集會遊行', '公民不服從', '社會運動'],
  '婚姻平權': ['釋字 748', '釋字第 748', '婚姻平權', '同性婚姻', '性別平權'],
  '強制治療': ['釋字 799', '釋字第 799', '強制治療', '性侵害', '醫療防線'],
  '死刑制度': ['死刑', '生存權', '113年憲判', '憲判字第 8', '比例原則'],
  '新聞自由': ['新聞自由', '跟拍', '隱私'],
  '修憲程序': ['修憲程序', '國民大會', '核四', '法定預算'],
  '軍事司法': ['軍事司法', '軍審', '洪仲丘'],
  '詐欺犯罪': ['詐欺', '食品安全', '劣油', '頂新'],
};

String _resolveCoreIssue(CaseBook book) {
  // 台灣繁體中文教學註解：
  // 解析順序：案件 id 明確指定 → tags → category → 標題/說明關鍵字 → 預設案件色。
  // 這樣能同時支援目前 mock data、未來後端資料，以及同案在不同 Shelf 的一致配色。
  final issueById = _caseIssueOverrides[book.id];
  if (issueById != null) return issueById;

  for (final tag in book.tags) {
    if (_coreIssueAccents.containsKey(tag)) return tag;
  }
  if (_coreIssueAccents.containsKey(book.category)) return book.category;

  final searchableText = [
    book.titleZh,
    book.shortTitleZh,
    book.displayCode,
    book.category,
    ...book.tags,
    book.memoryLine,
    book.shortDescription,
  ].join(' ');

  for (final entry in _coreIssueKeywords.entries) {
    if (entry.value.any(searchableText.contains)) return entry.key;
  }

  return '一般案件';
}

({String label, Color color, Color bgTint}) _getThemeAccent(CaseBook book) {
  final issue = _resolveCoreIssue(book);
  final accent = _coreIssueAccents[issue];
  if (accent != null) {
    return (label: issue, color: accent.color, bgTint: accent.bgTint);
  }

  // 台灣繁體中文教學註解：預設為案件圖書館深綠大地色，只用在尚未分類的一般案件。
  return (
    label: book.tags.isNotEmpty ? book.tags.first : book.category,
    color: const Color(0xFF173C37),
    bgTint: const Color(0xFFF0F3F2),
  );
}

// 台灣繁體中文教學註解：
// 主題 Shelf 元件 V4 — 水平卡片列，每張小卡進行以下修正：
// 1. 配色改為「依案件核心議題 (Tags) 定義固定專屬顏色」，橫向對齊色彩認知。
// 2. 卡片高度維持 115.h，視覺緊湊精緻。
// 3. 標題字重維持 normal（宋體），移除右下角 SVG 圖檔。
// 4. 右下角為該案件專屬色的實心「閱讀」按鈕 Block。
class CaseLibraryThemeShelf extends StatelessWidget {
  const CaseLibraryThemeShelf({
    super.key,
    required this.title,
    required this.cases,
    required this.onCaseTap,
    required this.onViewAllTap,
  });

  final String title;
  final List<CaseBook> cases;
  final ValueChanged<CaseBook> onCaseTap;
  final VoidCallback onViewAllTap;

  // 台灣繁體中文教學註解：討論數 mock
  static const _discussionCounts = <String, int>{
    '318': 142,
    '799': 245,
    '499': 158,
    '520': 340,
    '103': 89,
    '101': 203,
    'hung-2013': 167,
    'cheng-2021': 78,
    '102': 112,
    '104': 56,
  };

  // 台灣繁體中文教學註解：依據案件內容，動態產生合適的副資訊一行
  String _getSubInfo(CaseBook book) {
    if (book.category == '刑事案件' || book.category == '刑事') {
      if (book.tags.contains('集會遊行')) return '重大社會運動案件';
      if (book.tags.contains('死刑制度')) return '死刑制度與比例原則';
      return '重大刑事爭點解析';
    }
    if (book.category == '司法解釋' ||
        book.category == '司法制度' ||
        book.category == '憲法解釋') {
      if (book.tags.contains('強制治療')) return '關於強制治療的憲法爭點';
      if (book.tags.contains('婚姻平權')) return '婚姻平權的重要里程碑';
      if (book.tags.contains('修憲程序')) return '民主憲政與修憲界線';
      return '憲法法庭重要解釋';
    }
    if (book.tags.contains('勞資')) return '勞資權益與社會運動';
    if (book.tags.contains('詐欺犯罪') || book.tags.contains('詐欺')) {
      return '新型態詐欺與法律規範';
    }
    if (book.tags.contains('校園')) return '校園權利關係之變革';

    // 預設以最前面的 tag 加上主軸描述
    final tag = book.tags.isNotEmpty ? book.tags.first : book.category;
    return '關於 $tag 的重要實務案件';
  }

  @override
  Widget build(BuildContext context) {
    if (cases.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CaseLibrarySectionHeader(
          title: title,
          actionText: '查看全部',
          onActionTap: onViewAllTap,
        ),
        SizedBox(height: 9.h),
        SizedBox(
          height: 115.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: cases.length,
            itemBuilder: (context, idx) {
              final book = cases[idx];

              // 台灣繁體中文教學註解：依據案件本身的議題屬性獲取專屬色系與背景淡色，取代以 index 輪流分色
              final accent = _getThemeAccent(book);
              final accentColor = accent.color;
              final bgTint = accent.bgTint;

              final primaryTag = accent.label;
              final discussions = _discussionCounts[book.id] ??
                  (book.id.hashCode % 90 + 20).abs();
              final followers = (discussions * 0.85).round();
              final subInfo = _getSubInfo(book);

              return GestureDetector(
                onTap: () => onCaseTap(book),
                child: Container(
                  width: 146.w,
                  margin: EdgeInsets.only(right: 10.w),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        bgTint.withValues(alpha: 0.35),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.16),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // 台灣繁體中文教學註解：左側彩色邊條
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 4.w,
                          decoration: BoxDecoration(
                            color: accentColor,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12.r),
                              bottomLeft: Radius.circular(12.r),
                            ),
                          ),
                        ),
                      ),
                      // 台灣繁體中文教學註解：主要內容佈局
                      Padding(
                        padding: EdgeInsets.fromLTRB(12.w, 8.h, 10.w, 8.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 頂部標籤列
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 5.w, vertical: 1.h),
                                  decoration: BoxDecoration(
                                    color: accentColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  child: Text(
                                    primaryTag,
                                    style: TextStyle(
                                      fontSize: 7.5.sp,
                                      fontWeight: FontWeight.bold,
                                      color: accentColor,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${book.year} 年',
                                  style: TextStyle(
                                    fontSize: 8.sp,
                                    fontWeight: FontWeight.w700,
                                    color: CaseTimeMachineColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4.h),
                            // 案件短標題：字體不用粗體 (normal)，但維持 Songti TC 韻味
                            Text(
                              book.shortTitleZh.isNotEmpty
                                  ? book.shortTitleZh
                                  : book.titleZh,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Songti TC',
                                fontFamilyFallback: const [
                                  'Songti SC',
                                  'STSong',
                                  'BiauKai',
                                  'PingFang TC'
                                ],
                                fontSize: 12.sp,
                                fontWeight: FontWeight.normal,
                                color: const Color(0xFF173C37),
                                height: 1.25,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            // 新增一行「很淡的小字副資訊」
                            Text(
                              subInfo,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 8.5.sp,
                                fontWeight: FontWeight.normal,
                                color: CaseTimeMachineColors.textMuted
                                    .withValues(alpha: 0.75),
                              ),
                            ),
                            const Spacer(),
                            // 書卡 footer
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.chat_bubble_outline_rounded,
                                      size: 8.sp,
                                      color: accentColor.withValues(alpha: 0.8),
                                    ),
                                    SizedBox(width: 1.5.w),
                                    Text(
                                      '$discussions',
                                      style: TextStyle(
                                        fontSize: 7.5.sp,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            accentColor.withValues(alpha: 0.8),
                                      ),
                                    ),
                                    SizedBox(width: 4.w),
                                    Icon(
                                      Icons.favorite_border_rounded,
                                      size: 8.sp,
                                      color: accentColor.withValues(alpha: 0.8),
                                    ),
                                    SizedBox(width: 1.5.w),
                                    Text(
                                      '$followers',
                                      style: TextStyle(
                                        fontSize: 7.5.sp,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            accentColor.withValues(alpha: 0.8),
                                      ),
                                    ),
                                  ],
                                ),
                                // 台灣繁體中文教學註解：
                                // 改用有顏色的小 Block 包裹「閱讀」字樣，與該案件議題專屬色一致。
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 6.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color: accentColor,
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  child: Text(
                                    '閱讀',
                                    style: TextStyle(
                                      fontSize: 7.5.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
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
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
