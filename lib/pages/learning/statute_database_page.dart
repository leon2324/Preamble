import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/data/statutes/statute_api_service.dart';
import 'package:lawapp/data/statutes/statute_item.dart';
import 'package:lawapp/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class StatuteDatabasePage extends StatefulWidget {
  const StatuteDatabasePage({super.key, this.initialQuery = ''});

  final String initialQuery;

  @override
  State<StatuteDatabasePage> createState() => _StatuteDatabasePageState();
}

class _StatuteDatabasePageState extends State<StatuteDatabasePage> {
  static const List<String> _quickFilters = [
    '全部',
    '民法',
    '刑法',
    '勞動基準法',
    '道路交通管理處罰條例',
    '消費者保護法',
  ];
  static const List<_StatuteGuideEntry> _homeGuides = [
    _StatuteGuideEntry(
      title: '日常權利',
      subtitle: '契約、租屋、損害賠償',
      query: '民法',
      icon: Icons.home_work_rounded,
    ),
    _StatuteGuideEntry(
      title: '職場保障',
      subtitle: '工時、休假、薪資',
      query: '勞動基準法',
      icon: Icons.badge_rounded,
    ),
    _StatuteGuideEntry(
      title: '交通生活',
      subtitle: '道路規則與裁罰',
      query: '道路交通管理處罰條例',
      icon: Icons.directions_car_filled_rounded,
    ),
  ];

  final StatuteApiService _service = StatuteApiService();
  late final TextEditingController _searchController;
  late Future<List<StatuteItem>> _itemsFuture;
  String _query = '';
  String _selectedFilter = '全部';

  @override
  void initState() {
    super.initState();
    _query = widget.initialQuery;
    _searchController = TextEditingController(text: widget.initialQuery);
    _itemsFuture = _service.fetchChineseLawItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _service.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() {
      _itemsFuture = _service.fetchChineseLawItems();
    });
  }

  void _applyGuideQuery(String query) {
    // 教學註解：首頁型入口會同時更新搜尋欄文字、篩選膠囊與查詢字串，
    // 讓使用者點入口後，看到的列表、搜尋欄狀態與選中的分類保持一致。
    setState(() {
      _searchController.text = query;
      _query = query;
      _selectedFilter = _quickFilters.contains(query) ? query : '全部';
    });
    FocusManager.instance.primaryFocus?.unfocus();
  }

  List<StatuteItem> _filterItems(List<StatuteItem> items) {
    // 搜尋採本地過濾，讓第一版不用每輸入一個字就打 API；
    // 未來若資料量或 API 能力改變，可以在這裡抽換成遠端搜尋。
    final filtered = items.where((item) {
      final matchesQuery = item.matches(_query);
      final matchesFilter = _selectedFilter == '全部' ||
          item.codeName.contains(_selectedFilter) ||
          item.category.contains(_selectedFilter);
      return matchesQuery && matchesFilter && !item.isRepealed;
    }).take(50);

    return filtered.toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F0),
      body: Padding(
        padding: EdgeInsets.fromLTRB(16.w, topPadding + 14.h, 16.w, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _RoundToolButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => Navigator.of(context).pop(),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _StatuteSearchField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _query = value;
                      });
                    },
                    onClear: () {
                      // 教學註解：清除按鈕要同時清 TextField 與本頁用來篩選資料的 `_query`，
                      // 否則畫面看起來清空了，列表仍會被舊關鍵字過濾。
                      setState(() {
                        _searchController.clear();
                        _query = '';
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 18.h),
            Text(
              '法條資料庫',
              style: TextStyle(
                fontSize: 24.sp,
                height: 1.05,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              '資料來源：全國法規資料庫法律與命令資料。以下內容僅作法規資料呈現，不構成法律意見。',
              style: TextStyle(
                fontSize: 12.sp,
                height: 1.45,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 14.h),
            Expanded(
              child: FutureBuilder<List<StatuteItem>>(
                future: _itemsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const _StatuteLoadingState();
                  }

                  if (snapshot.hasError) {
                    return _StatuteErrorState(
                      message: snapshot.error.toString(),
                      onRetry: _reload,
                    );
                  }

                  final items = _filterItems(snapshot.data ?? const []);
                  if (items.isEmpty) {
                    return const _StatuteEmptyState();
                  }

                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.only(bottom: 28.h),
                    itemCount: items.length + 1,
                    separatorBuilder: (_, __) => SizedBox(height: 10.h),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _StatuteHomeGuide(
                          filters: _quickFilters,
                          selectedFilter: _selectedFilter,
                          guides: _homeGuides,
                          onFilterTap: (label) {
                            setState(() {
                              _selectedFilter = label;
                              _searchController.clear();
                              _query = '';
                            });
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                          onGuideTap: _applyGuideQuery,
                        );
                      }

                      final item = items[index - 1];
                      return _StatuteResultCard(
                        item: item,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => StatuteDetailPage(item: item),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatuteGuideEntry {
  const _StatuteGuideEntry({
    required this.title,
    required this.subtitle,
    required this.query,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String query;
  final IconData icon;
}

class StatuteDetailPage extends StatelessWidget {
  const StatuteDetailPage({super.key, required this.item});

  final StatuteItem item;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F0),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, topPadding + 14.h, 16.w, 32.h),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: _RoundToolButton(
              icon: Icons.arrow_back_rounded,
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            item.codeName,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF64715A),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            item.articleNumber.isEmpty ? '條文內容' : item.articleNumber,
            style: TextStyle(
              fontSize: 26.sp,
              height: 1.15,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          _DetailSectionCard(
            title: '條文原文',
            child: SelectableText(
              item.articleText,
              style: TextStyle(
                fontSize: 16.sp,
                height: 1.65,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          _DetailSectionCard(
            title: '資料資訊',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DetailMetaRow(label: '法規類別', value: item.category),
                _DetailMetaRow(label: '最新異動', value: item.updatedDate),
                const _DetailMetaRow(
                  label: '資料來源',
                  value: '全國法規資料庫',
                ),
                if (item.lawUrl.isNotEmpty) ...[
                  SizedBox(height: 10.h),
                  OutlinedButton.icon(
                    onPressed: () {
                      launchUrl(
                        Uri.parse(item.lawUrl),
                        mode: LaunchMode.externalApplication,
                      );
                    },
                    icon: Icon(Icons.open_in_new_rounded, size: 16.sp),
                    label: const Text('前往全國法規資料庫'),
                  ),
                  SizedBox(height: 4.h),
                  SelectableText(
                    item.lawUrl,
                    style: TextStyle(
                      fontSize: 12.sp,
                      height: 1.45,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            '提醒：本頁只呈現法規資料，實際個案仍需要依事實、證據與最新正式公布資料判斷。',
            style: TextStyle(
              fontSize: 12.sp,
              height: 1.45,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatuteSearchField extends StatelessWidget {
  const _StatuteSearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44.h,
      decoration: BoxDecoration(
        color: const Color(0xFFE6ECE6),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: '搜尋法規名稱、條號、關鍵字...',
          hintStyle: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xFF7E877B),
          ),
          border: InputBorder.none,
          isCollapsed: true,
          contentPadding: EdgeInsets.only(left: 16.w, right: 8.w),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_rounded,
                size: 22.sp,
                color: const Color(0xFF4B5647),
              ),
              if (controller.text.isNotEmpty)
                IconButton(
                  onPressed: onClear,
                  visualDensity: VisualDensity.compact,
                  tooltip: '清除搜尋關鍵字',
                  icon: Icon(
                    Icons.close_rounded,
                    size: 18.sp,
                    color: const Color(0xFF4B5647),
                  ),
                ),
              SizedBox(width: 4.w),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundToolButton extends StatelessWidget {
  const _RoundToolButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // 返回鍵只保留大箭頭，不再加底色圓框；
    // 點擊範圍仍保留 42.w，避免視覺變輕後手指不好點。
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: SizedBox(
          width: 42.w,
          height: 42.w,
          child: Icon(
            icon,
            size: 30.sp,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
          decoration: BoxDecoration(
            color:
                isSelected ? const Color(0xFFCFDDBF) : const Color(0xFFFFFAEC),
            borderRadius: BorderRadius.circular(999.r),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFB9CAA8)
                  : const Color(0xFFE2D7B8),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w800,
              color: isSelected
                  ? const Color(0xFF405238)
                  : const Color(0xFF5C5C45),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatuteHomeGuide extends StatelessWidget {
  const _StatuteHomeGuide({
    required this.filters,
    required this.selectedFilter,
    required this.guides,
    required this.onFilterTap,
    required this.onGuideTap,
  });

  final List<String> filters;
  final String selectedFilter;
  final List<_StatuteGuideEntry> guides;
  final ValueChanged<String> onFilterTap;
  final ValueChanged<String> onGuideTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4E9),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFDDE8D5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.travel_explore_rounded,
                size: 20.sp,
                color: const Color(0xFF405238),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  '先選一個方向',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            '不知道要查哪一條時，可以先從常用法規或生活情境開始。',
            style: TextStyle(
              fontSize: 11.5.sp,
              height: 1.45,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: filters.map((label) {
              return _FilterChipButton(
                label: label,
                isSelected: label == selectedFilter,
                onTap: () => onFilterTap(label),
              );
            }).toList(growable: false),
          ),
          SizedBox(height: 14.h),
          Text(
            '生活入口',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF5D5A38),
            ),
          ),
          SizedBox(height: 6.h),
          for (var index = 0; index < guides.length; index++) ...[
            if (index > 0)
              Divider(
                height: 1.h,
                color: const Color(0xFFDDE8D5),
              ),
            _StatuteGuideRow(
              guide: guides[index],
              onTap: () => onGuideTap(guides[index].query),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatuteGuideRow extends StatelessWidget {
  const _StatuteGuideRow({
    required this.guide,
    required this.onTap,
  });

  final _StatuteGuideEntry guide;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          child: Row(
            children: [
              Icon(
                guide.icon,
                size: 21.sp,
                color: AppColors.primary,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      guide.title,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      guide.subtitle,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                guide.query,
                style: TextStyle(
                  fontSize: 10.5.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF6B765F),
                ),
              ),
              SizedBox(width: 6.w),
              Icon(
                Icons.chevron_right_rounded,
                size: 20.sp,
                color: const Color(0xFF6B7280),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatuteResultCard extends StatelessWidget {
  const _StatuteResultCard({
    required this.item,
    required this.onTap,
  });

  final StatuteItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Container(
          padding: EdgeInsets.all(15.w),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFAEC),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: const Color(0xFFE7DFC7)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.displayTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 20.sp,
                    color: const Color(0xFF4B5563),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                item.plainSummary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.sp,
                  height: 1.45,
                  color: AppColors.textSecondary,
                ),
              ),
              if (item.updatedDate.isNotEmpty) ...[
                SizedBox(height: 8.h),
                Text(
                  '最新異動：${item.updatedDate}',
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    color: const Color(0xFF8A8372),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailSectionCard extends StatelessWidget {
  const _DetailSectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAEC),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFE7DFC7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF5D5A38),
            ),
          ),
          SizedBox(height: 10.h),
          child,
        ],
      ),
    );
  }
}

class _DetailMetaRow extends StatelessWidget {
  const _DetailMetaRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.sp,
                height: 1.45,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatuteLoadingState extends StatefulWidget {
  const _StatuteLoadingState();

  @override
  State<_StatuteLoadingState> createState() => _StatuteLoadingStateState();
}

class _StatuteLoadingStateState extends State<_StatuteLoadingState>
    with SingleTickerProviderStateMixin {
  static const List<String> _legalQuotes = [
    '法律之前，人人平等。',
    '權利會睡著，提醒自己醒著。',
    '懂法，是保護自己的第一步。',
    '讓法條慢一點，也讓判斷準一點。',
    '自由不是沒有界線，而是知道界線在哪。',
    '證據會說話，判斷要聽完。',
    '程序走得穩，權利才站得住。',
    '法律保護願意主張權利的人。',
    '每一條法規，都是生活的一個路標。',
    '公平不是口號，是一步一步被實現。',
    '先理解事實，再靠近答案。',
    '權利與義務，總是一起出場。',
    '好的判斷，從不急著下結論。',
    '規則清楚，生活才有安全感。',
    '法律不是距離感，是日常的保護傘。',
    '把問題說清楚，就是解決的一半。',
    '法條很安靜，但權利需要被看見。',
    '每一次查法，都是替自己多留一盞燈。',
    '正義需要熱情，也需要耐心。',
    '懂得問，才會更接近真正的答案。',
  ];

  late final AnimationController _typewriterController;
  var _quoteIndex = 0;

  @override
  void initState() {
    super.initState();
    // 教學註解：這裡用 AnimationController 模擬打字機節奏。
    // 每輪動畫結束後切換下一句金句，再重新播放，讓等待資料時畫面不會僵住。
    _typewriterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _quoteIndex = (_quoteIndex + 1) % _legalQuotes.length;
          });
          _typewriterController.forward(from: 0);
        }
      });
    _typewriterController.forward();
  }

  @override
  void dispose() {
    _typewriterController.dispose();
    super.dispose();
  }

  String _visibleQuote(String quote, double progress) {
    final runes = quote.runes.toList(growable: false);
    final visibleCount =
        (runes.length * progress.clamp(0.0, 1.0)).ceil().clamp(0, runes.length);
    return String.fromCharCodes(runes.take(visibleCount));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _typewriterController,
        builder: (context, _) {
          final quote = _legalQuotes[_quoteIndex];
          final typingProgress =
              (_typewriterController.value / 0.78).clamp(0.0, 1.0);
          final cursorIsVisible =
              (_typewriterController.value * 12).floor().isEven;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.balance_rounded,
                size: 42.sp,
                color: AppColors.primary,
              ),
              SizedBox(height: 16.h),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: '「${_visibleQuote(quote, typingProgress)}'),
                    TextSpan(
                      text: cursorIsVisible ? '｜' : ' ',
                      style: const TextStyle(color: AppColors.accent),
                    ),
                    TextSpan(
                      text: typingProgress >= 1 ? '」' : '',
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15.sp,
                  height: 1.45,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                '正在整理全國法規資料...',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatuteErrorState extends StatelessWidget {
  const _StatuteErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFAEC),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: const Color(0xFFE7DFC7)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 32.sp,
              color: const Color(0xFF8A6E2F),
            ),
            SizedBox(height: 10.h),
            Text(
              '暫時讀不到法規資料',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                height: 1.45,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 14.h),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('重新讀取'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatuteEmptyState extends StatelessWidget {
  const _StatuteEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '找不到符合條件的條文，試試換一個關鍵字。',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13.sp,
          height: 1.45,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
