import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:preamble/features/case_time_machine/models/case_time_machine_models.dart';
import 'package:preamble/features/case_time_machine/theme/case_time_machine_theme.dart';
import 'package:preamble/features/case_time_machine/widgets/case_time_machine_svg_icon.dart';

// 「案件時間軸」互動詳情頁 (CaseTimelineDetailPage)
// 本頁面為特定的案件提供高度細緻的垂直時間軌跡探索。
// 具備橫向滑動的里程碑分類篩選器（起因、衝突、審理判決、社會影響），
// 且點擊各個事件卡片時，能「向下滑動展開」顯示該日期對應的富媒體網友發言或涉案法規，
// 將原本生硬的年表，轉化為沉浸式脈絡百科。
class CaseTimelineDetailPage extends StatefulWidget {
  const CaseTimelineDetailPage({
    super.key,
    required this.book,
  });

  final CaseBook book;

  @override
  State<CaseTimelineDetailPage> createState() => _CaseTimelineDetailPageState();
}

class _CaseTimelineDetailPageState extends State<CaseTimelineDetailPage> {
  String _selectedCategory = '全部';
  final Set<int> _expandedIndices = {};

  // 透過解析時間軸項目的標題或敘述，動態將其分類為：起因、衝突、司法判決、社會迴響。
  // 這可保證現有的 CaseBook 資料模型無須大改，便能呈現進階的分類篩選功能。
  String _getCategoryForItem(CaseTimelineItem item) {
    final text = (item.title + item.description).toLowerCase();
    if (text.contains('起訴') ||
        text.contains('判決') ||
        text.contains('宣判') ||
        text.contains('解釋') ||
        text.contains('審理') ||
        text.contains('定讞')) {
      return '司法判決';
    }
    if (text.contains('衝突') ||
        text.contains('驅離') ||
        text.contains('佔領') ||
        text.contains('滑落') ||
        text.contains('事故') ||
        text.contains('襲擊')) {
      return '關鍵衝突';
    }
    if (text.contains('修法') ||
        text.contains('國賠') ||
        text.contains('重建') ||
        text.contains('影響') ||
        text.contains('倡議')) {
      return '社會迴響';
    }
    return '事件起因';
  }

  // 當卡片點擊展開時，根據不同的事件內容，動態產生對應的模擬「當日網友反應/歷史輿情」，
  // 讓使用者看懂當時法律事件引發的公眾情緒。
  Map<String, dynamic> _getEventRichContext(CaseTimelineItem item) {
    final title = item.title;
    if (title.contains('佔領') || title.contains('發起')) {
      return {
        'reactions': [
          {'user': '公民觀察者', 'text': '這程序太扯了，支持站出來！', 'tag': '合理'},
          {'user': '不平則鳴', 'text': '再怎麼不滿也不能佔領公署吧，這有違法治。', 'tag': '不合理'}
        ],
        'lawTip': '中華民國憲法第14條保障集會遊行自由，但需與刑法妨害公務罪、侵入住宅罪進行利益衡量。'
      };
    }
    if (title.contains('驅離') || title.contains('衝突')) {
      return {
        'reactions': [
          {'user': '心痛的一天', 'text': '警察打人太過分了！國家暴力！', 'tag': '不合理'},
          {'user': '維護秩序者', 'text': '警察是在依法執行公務，請還給社會平靜。', 'tag': '合理'}
        ],
        'lawTip': '警械使用條例與警察職權行使法皆規定，執行強制作為必須符合最小侵害原則。'
      };
    }
    if (title.contains('判決') || title.contains('解釋') || title.contains('宣判')) {
      return {
        'reactions': [
          {'user': '法學愛好者', 'text': '最高法院能引入公民不服從的概念，是台灣法治的進步！', 'tag': '合理'},
          {
            'user': '守法老百姓',
            'text': '這樣以後抗議有罪都能說自己是不服從，基層警消以後怎麼執法？',
            'tag': '不合理'
          }
        ],
        'lawTip': '最高法院的這份判決，實質建立了公民不服從的七大要件，作為阻卻違法事由。'
      };
    }
    return {
      'reactions': [
        {'user': '社會大眾', 'text': '希望這起悲劇能換來真正的制度改進。', 'tag': '中立'}
      ],
      'lawTip': '案件引申出對安全防護、行政監督疏失的民刑事責任劃分討論。'
    };
  }

  @override
  Widget build(BuildContext context) {
    // 依據選取的分類過濾時間軸節點
    final filteredItems = widget.book.timeline.where((item) {
      if (_selectedCategory == '全部') return true;
      return _getCategoryForItem(item) == _selectedCategory;
    }).toList();

    final categories = ['全部', '事件起因', '關鍵衝突', '司法判決', '社會迴響'];

    return Scaffold(
      backgroundColor: CaseTimeMachineColors.bgCream,
      body: SafeArea(
        child: Column(
          children: [
            // AppBar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              child: SizedBox(
                height: 56.h,
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
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 60.w),
                        child: Text(
                          '案件時間軸',
                          style: LightTextStyles.pageTitle(context)
                              .copyWith(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 案件橫幅
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: CaseTimeMachineColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.book.titleZh,
                    style:
                        LightTextStyles.cardTitle(context).copyWith(
                      fontSize: 13.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '點擊各時間點卡片，可展開當時的法規脈絡與社群聲量對話。',
                    style: LightTextStyles.caption(context).copyWith(
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),

            // 橫向篩選 Label 列
            SizedBox(
              height: 34.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                itemCount: categories.length,
                itemBuilder: (context, idx) {
                  final cat = categories[idx];
                  final isSelected = cat == _selectedCategory;
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: ChoiceChip(
                      label: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : CaseTimeMachineColors.primaryGreen,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedCategory = cat;
                            _expandedIndices.clear();
                          });
                        }
                      },
                      selectedColor: CaseTimeMachineColors.primaryGreen,
                      backgroundColor: Colors.white,
                      checkmarkColor: Colors.white,
                      side: BorderSide(
                        color: isSelected
                            ? Colors.transparent
                            : CaseTimeMachineColors.borderLight,
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16.h),

            // 垂直時間軸內容
            Expanded(
              child: filteredItems.isEmpty
                  ? Center(
                      child: Text(
                        '此分類下暫無事件節點',
                        style: LightTextStyles.caption(context),
                      ),
                    )
                  : Stack(
                      children: [
                        // 時間軸中央偏左豎線
                        Positioned(
                          left: 29.w,
                          top: 10.h,
                          bottom: 10.h,
                          child: Container(
                            width: 2.w,
                            color: CaseTimeMachineColors.borderLight,
                          ),
                        ),

                        // 時間軸滾動列表
                        ListView.builder(
                          padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 40.h),
                          itemCount: filteredItems.length,
                          itemBuilder: (context, idx) {
                            final item = filteredItems[idx];
                            final category = _getCategoryForItem(item);
                            final isExpanded = _expandedIndices.contains(idx);

                            return Padding(
                              padding: EdgeInsets.only(bottom: 20.h),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 左側時間點指示圓徽章
                                  Container(
                                    width: 28.w,
                                    height: 28.w,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: CaseTimeMachineColors.accentGold,
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.05),
                                          blurRadius: 4,
                                        )
                                      ],
                                    ),
                                    child: const Center(
                                      child: CtmSvgIcon(
                                        CtmSvgIcons.clock,
                                        size: 14,
                                        color:
                                            CaseTimeMachineColors.primaryGreen,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 14.w),

                                  // 右側事件大卡片
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (isExpanded) {
                                            _expandedIndices.remove(idx);
                                          } else {
                                            _expandedIndices.add(idx);
                                          }
                                        });
                                      },
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 350),
                                        curve: Curves.easeInOut,
                                        padding: EdgeInsets.all(14.w),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(14.r),
                                          border: Border.all(
                                            color: isExpanded
                                                ? CaseTimeMachineColors
                                                    .accentGold
                                                : CaseTimeMachineColors
                                                    .borderLight,
                                          ),
                                          boxShadow: [
                                            CaseTimeMachineShadows.softShadow
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // 日期與事件分類標籤
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  item.dateLabel,
                                                  style: TextStyle(
                                                    fontSize: 11.sp,
                                                    fontWeight: FontWeight.bold,
                                                    color: CaseTimeMachineColors
                                                        .accentGold,
                                                  ),
                                                ),
                                                _buildCategoryTag(category),
                                              ],
                                            ),
                                            SizedBox(height: 6.h),

                                            // 標題
                                            Text(
                                              item.title,
                                              style: LightTextStyles
                                                      .cardTitle(context)
                                                  .copyWith(
                                                fontSize: 13.sp,
                                                color: CaseTimeMachineColors
                                                    .primaryGreen,
                                              ),
                                            ),
                                            SizedBox(height: 6.h),

                                            // 內容
                                            Text(
                                              item.description,
                                              style: LightTextStyles
                                                      .bodySmall(context)
                                                  .copyWith(
                                                fontSize: 11.5.sp,
                                                height: 1.4,
                                              ),
                                            ),

                                            // 展開圖示
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: Padding(
                                                padding:
                                                    EdgeInsets.only(top: 4.h),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      isExpanded
                                                          ? '收合'
                                                          : '點擊展開脈絡',
                                                      style: TextStyle(
                                                        fontSize: 9.sp,
                                                        color:
                                                            CaseTimeMachineColors
                                                                .textMuted,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    SizedBox(width: 2.w),
                                                    Icon(
                                                      isExpanded
                                                          ? Icons
                                                              .keyboard_arrow_up
                                                          : Icons
                                                              .keyboard_arrow_down,
                                                      size: 12.sp,
                                                      color:
                                                          CaseTimeMachineColors
                                                              .textMuted,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),

                                            // 展開隱藏的富文本內容
                                            if (isExpanded) ...[
                                              const Divider(height: 16),
                                              _buildEventDetails(item),
                                            ]
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTag(String category) {
    Color color = Colors.grey;
    if (category == '事件起因') color = const Color(0xFF1B5E4F);
    if (category == '關鍵衝突') color = const Color(0xFFC62828);
    if (category == '司法判決') color = const Color(0xFFB08C4A);
    if (category == '社會迴響') color = const Color(0xFF6A1B9A);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        category,
        style: TextStyle(
          fontSize: 8.5.sp,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  // 建立展開後的延伸卡片內容，包括當天法理觀點說明以及模擬的歷史輿論氛圍。
  Widget _buildEventDetails(CaseTimelineItem item) {
    final detail = _getEventRichContext(item);
    final reactions = detail['reactions'] as List<Map<String, String>>;
    final lawTip = detail['lawTip'] as String;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 歷史法律解析
        Text(
          '💡 關鍵法益脈絡：',
          style: TextStyle(
            fontSize: 10.5.sp,
            fontWeight: FontWeight.bold,
            color: CaseTimeMachineColors.primaryGreen,
          ),
        ),
        SizedBox(height: 3.h),
        Text(
          lawTip,
          style: TextStyle(
            fontSize: 10.sp,
            color: CaseTimeMachineColors.textSecondary,
            height: 1.4,
          ),
        ),
        SizedBox(height: 10.h),

        // 當時社群輿論反應
        Text(
          '💬 當日社會輿情反響：',
          style: TextStyle(
            fontSize: 10.5.sp,
            fontWeight: FontWeight.bold,
            color: CaseTimeMachineColors.primaryGreen,
          ),
        ),
        SizedBox(height: 5.h),
        for (final react in reactions)
          Padding(
            padding: EdgeInsets.only(bottom: 6.h),
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F7F2),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: CaseTimeMachineColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '@${react['user']}',
                        style: TextStyle(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.bold,
                          color: CaseTimeMachineColors.textPrimary,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 5.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: react['tag'] == '合理'
                              ? const Color(0xFFE8F5E9)
                              : react['tag'] == '不合理'
                                  ? const Color(0xFFFFEBEE)
                                  : const Color(0xFFECEFF1),
                          borderRadius: BorderRadius.circular(3.r),
                        ),
                        child: Text(
                          react['tag']!,
                          style: TextStyle(
                            fontSize: 7.5.sp,
                            fontWeight: FontWeight.bold,
                            color: react['tag'] == '合理'
                                ? const Color(0xFF2E7D32)
                                : react['tag'] == '不合理'
                                    ? const Color(0xFFC62828)
                                    : const Color(0xFF455A64),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    react['text']!,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: CaseTimeMachineColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  static const String _svgBackIcon = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round">
  <path d="m15 18-6-6 6-6"></path>
</svg>
''';
}
