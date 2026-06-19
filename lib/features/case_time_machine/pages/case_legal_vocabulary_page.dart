import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lawapp/features/case_time_machine/theme/case_time_machine_theme.dart';
import 'package:lawapp/features/case_time_machine/widgets/case_time_machine_svg_icon.dart';
import 'package:lawapp/features/case_time_machine/pages/case_dossier_detail_page.dart';
import 'package:lawapp/features/case_time_machine/data/case_time_machine_mock_data.dart';

// 台灣繁體中文教學註解：
// 「法律詞卡」探索與 3D 翻牌頁面 (CaseLegalVocabularyPage)
// 旨在將判決中艱深難懂的法理名詞「說白話」。
// 頁面提供搜尋欄位與分類選單，卡片點擊時會啟動 3D 旋轉翻牌動畫（Y 軸 180 度旋轉與透視 projection），
// 卡片正面提供白話文解說，背面提供日常生活故事實例、以及點選直接跳轉至時光機相關案件的傳送點。
class CaseLegalVocabularyPage extends StatefulWidget {
  const CaseLegalVocabularyPage({super.key});

  @override
  State<CaseLegalVocabularyPage> createState() => _CaseLegalVocabularyPageState();
}

class _CaseLegalVocabularyPageState extends State<CaseLegalVocabularyPage> {
  String _searchQuery = '';
  String _selectedCategory = '全部';

  // 台灣繁體中文教學註解：
  // 定義詞卡 mock 資料，包含正面（白話翻譯、圖案圖示）與背面（生活實例、對應案件 ID 與名稱）
  final List<Map<String, dynamic>> _vocabData = [
    {
      'term': '公民不服從',
      'category': '憲法/權益',
      'icon': CtmSvgIcons.scale,
      'color': const Color(0xFF1B5E4F),
      'plainExplanation': '當政府或程序出現重大不正義時，人民在「窮盡其他救濟管道」後，以和平、非暴力且「願意接受處分」的方式，公開表達抵抗的最後防線權利。',
      'lifeExample': '班長選舉程序有嚴重黑箱作票，同學們抗議無效，集體在走廊靜坐要求重選，事後也願意被班導以「集體遲到」名義記點懲處。',
      'caseId': '318',
      'caseName': '太陽花學運佔領立法院事件',
    },
    {
      'term': '比例原則',
      'category': '憲法/行政',
      'icon': CtmSvgIcons.sparkles,
      'color': const Color(0xFFB08C4A),
      'plainExplanation': '國家限制人民權利時，採取的「手段」與要達成的「目的」必須合理且相稱，也就是不可以「用大砲打小鳥」，手段要符合適當、必要與衡平性。',
      'lifeExample': '小明上課沒帶鉛筆（小過失），老師卻罰他整學期不准進入教室（過度限制手段），這就嚴重違反了比例原則。',
      'caseId': '318', // 太陽花警力驅離爭點
      'caseName': '太陽花學運佔領立法院事件',
    },
    {
      'term': '無罪推定原則',
      'category': '刑法/程序',
      'icon': CtmSvgIcons.gavel,
      'color': const Color(0xFFC62828),
      'plainExplanation': '在法官正式宣判有罪確定之前，法律上必須先假設被告是清白無罪的。控方（檢察官）必須提出毫無合理懷疑的證據，否則就應判決無罪。',
      'lifeExample': '客廳桌上的蛋糕被吃掉了，在還沒找到發票、指紋或嘴角的奶油前，即使小弟嫌疑最大，爸媽也不能在沒證據的情形下直接認定是他偷吃的。',
      'caseId': '161',
      'caseName': '蘇建和案（經典冤獄追訴）',
    },
    {
      'term': '正當法律程序',
      'category': '憲法/程序',
      'icon': CtmSvgIcons.award,
      'color': const Color(0xFF6A1B9A),
      'plainExplanation': '政府對人民做成不利處分（如罰款、限制自由）之前，必須遵循法定公開公平的程序，例如通知當事人、給予辯護權利、召開聽證會等，否則程序違憲。',
      'lifeExample': '學校要記大過前，不可以默默在系統建檔，必須先開會通知你和家長，並讓你到場為自己申辯，這就是正當程序。',
      'caseId': '799',
      'caseName': '釋字 799 號強制治療案',
    },
    {
      'term': '信賴保護原則',
      'category': '憲法/行政',
      'icon': CtmSvgIcons.clock,
      'color': const Color(0xFF455A64),
      'plainExplanation': '國家如果公布了某項法規或承諾（信賴基礎），且人民因為相信這個承諾而做了相應規劃（信賴表現），日後國家改口或修改法律時，必須保護人民不受損害。',
      'lifeExample': '政府宣布購買節能家電可補助一萬元，小明信賴此政策而買了冰箱。之後政府說經費不夠取消補助，小明此時可主張信賴保護，要求政府給付補助。',
      'caseId': '520',
      'caseName': '釋字 520 號核四停建解釋案',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // 依關鍵字與分類進行過濾
    final filteredVocab = _vocabData.where((item) {
      final matchesSearch =
          (item['term'] as String).contains(_searchQuery) ||
          (item['plainExplanation'] as String).contains(_searchQuery);
      final matchesCategory = _selectedCategory == '全部' ||
          (item['category'] as String).contains(_selectedCategory);
      return matchesSearch && matchesCategory;
    }).toList();

    final categories = ['全部', '憲法', '程序', '刑法'];

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
                          '法律詞卡',
                          style: CaseTimeMachineTextStyles.pageTitle(context)
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

            // 搜尋欄
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Container(
                height: 40.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: CaseTimeMachineColors.borderLight),
                ),
                child: TextField(
                  onTapOutside: (event) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  style: TextStyle(fontSize: 12.sp),
                  decoration: InputDecoration(
                    hintText: '搜尋法律詞彙或釋義...',
                    hintStyle: TextStyle(
                      fontSize: 12.sp,
                      color: CaseTimeMachineColors.textMuted,
                    ),
                    prefixIcon: const Icon(Icons.search, size: 16),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h),

            // 分類快篩 ChoiceChip
            SizedBox(
              height: 32.h,
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
                          fontSize: 10.sp,
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
                          });
                        }
                      },
                      selectedColor: CaseTimeMachineColors.primaryGreen,
                      backgroundColor: Colors.white,
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

            // 詞卡 Grid 列表
            Expanded(
              child: filteredVocab.isEmpty
                  ? Center(
                      child: Text(
                        '找不到相符的法律詞卡',
                        style: CaseTimeMachineTextStyles.caption(context),
                      ),
                    )
                  : GridView.builder(
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 32.h),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1, // 單欄大卡片，以容納豐富的白話解釋
                        childAspectRatio: 1.55,
                        mainAxisSpacing: 16.h,
                      ),
                      itemCount: filteredVocab.length,
                      itemBuilder: (context, idx) {
                        final item = filteredVocab[idx];
                        return _VocabularyFlipCard(item: item);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  static const String _svgBackIcon = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round">
  <path d="m15 18-6-6 6-6"></path>
</svg>
''';
}

// 台灣繁體中文教學註解：
// 單張 3D 翻轉詞卡組件 (_VocabularyFlipCard)
// 透過 AnimatedBuilder 結合 Matrix4，當點擊時於 Y 軸旋轉 180 度，
// 並在 90 度（正中央垂直）時動態切換正面與反面，做出精美自然的翻牌物理動畫。
class _VocabularyFlipCard extends StatefulWidget {
  const _VocabularyFlipCard({required this.item});

  final Map<String, dynamic> item;

  @override
  State<_VocabularyFlipCard> createState() => _VocabularyFlipCardState();
}

class _VocabularyFlipCardState extends State<_VocabularyFlipCard>
    with SingleTickerProviderStateMixin {
  bool _showFront = true;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleCard() {
    if (_showFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() {
      _showFront = !_showFront;
    });
  }

  // 台灣繁體中文教學註解：
  // 當在詞卡背面點擊「前往案件」時，需要跳轉至真實的 CaseBook 詳情頁，
  // 由於詞卡資料記錄了對應的 caseId，可順暢地完成學習導流。
  void _navigateToCase(BuildContext context, String caseId) {
    final book = caseTimeMachineCaseById(caseId);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (__) => CaseDossierDetailPage(book: book),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleCard,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final double rotationValue = _controller.value * pi;
          final bool isFrontSide = rotationValue < pi / 2;

          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // 3D 透視投影係數
              ..rotateY(rotationValue),
            alignment: Alignment.center,
            child: isFrontSide
                ? _buildFront()
                : Transform(
                    // 背面需要額外旋轉 180 度 (pi)，文字才不會變成左右顛倒的鏡像
                    transform: Matrix4.identity()..rotateY(pi),
                    alignment: Alignment.center,
                    child: _buildBack(),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildFront() {
    final item = widget.item;
    final color = item['color'] as Color;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: CaseTimeMachineColors.borderLight),
        boxShadow: [CaseTimeMachineShadows.softShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CtmSvgIcon(
                    item['icon'] as String,
                    size: 18,
                    color: color,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    item['term'] as String,
                    style: CaseTimeMachineTextStyles.cardTitle(context).copyWith(
                      fontSize: 14.5.sp,
                      color: CaseTimeMachineColors.primaryGreen,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  item['category'] as String,
                  style: TextStyle(
                    fontSize: 8.5.sp,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Expanded(
            child: Text(
              item['plainExplanation'] as String,
              style: CaseTimeMachineTextStyles.body(context).copyWith(
                fontSize: 12.sp,
                height: 1.45,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '🔄 點擊卡片翻看實例',
                  style: TextStyle(
                    fontSize: 9.sp,
                    color: CaseTimeMachineColors.textMuted,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 2.w),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBack() {
    final item = widget.item;
    final color = item['color'] as Color;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF8F2),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: CaseTimeMachineColors.accentGold.withValues(alpha: 0.5)),
        boxShadow: [CaseTimeMachineShadows.softShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🌟 生活實例（白話說人話）：',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 6.h),
          Expanded(
            child: Text(
              item['lifeExample'] as String,
              style: TextStyle(
                fontSize: 11.5.sp,
                color: CaseTimeMachineColors.textSecondary,
                height: 1.45,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const Divider(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.link, size: 12, color: Color(0xFF8C7355)),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        '關聯案件：${item['caseName']}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9.5.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF8C7355),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: CaseTimeMachineColors.primaryGreen,
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                ),
                onPressed: () => _navigateToCase(context, item['caseId'] as String),
                child: Text(
                  '讀案 ➔',
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
