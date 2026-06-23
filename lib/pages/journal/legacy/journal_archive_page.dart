import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/pages/journal/data/journal_page_items.dart';
import 'package:lawapp/theme/app_colors.dart';

/// 可導覽的案件資料館頁。
///
/// 台灣繁體中文教學註解：
/// 這頁目前還沒有正式後端，所以先把 mock 卷宗做成「可篩選、可點進詳情」的真流程；
/// 未來接 API 時保留這裡的互動結構，只要把 archiveDossierItems 換成後端資料即可。
class JournalArchivePage extends StatefulWidget {
  const JournalArchivePage({
    super.key,
    this.entryLabel,
    this.focusTitle,
  });

  final String? entryLabel;
  final String? focusTitle;

  @override
  State<JournalArchivePage> createState() => _JournalArchivePageState();
}

class _JournalArchivePageState extends State<JournalArchivePage> {
  late String? _selectedEra;

  ArchiveDossierItem? get _focusItem {
    final title = widget.focusTitle;
    if (title == null) return null;

    for (final item in archiveDossierItems) {
      if (item.title == title) return item;
    }
    return null;
  }

  List<ArchiveDossierItem> get _filteredItems {
    final selectedEra = _selectedEra;
    if (selectedEra == null) return archiveDossierItems;

    return archiveDossierItems
        .where((item) => item.era == selectedEra)
        .toList(growable: false);
  }

  @override
  void initState() {
    super.initState();
    _selectedEra = _focusItem?.era;
  }

  void _openDossier(ArchiveDossierItem item) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (__) => ArchiveDossierDetailPage(item: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final focusItem = _focusItem;
    final filteredItems = _filteredItems;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F1E8),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: const Color(0xFFF6F1E8),
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            expandedHeight: 240.h,
            leading: IconButton(
              icon: const Icon(CupertinoIcons.back),
              color: const Color(0xFF173C37),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: _ArchiveHero(
                entryLabel: widget.entryLabel,
                focusTitle: focusItem?.title ?? widget.focusTitle,
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 120.h),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _ArchiveStatusBanner(
                  selectedEra: _selectedEra,
                  visibleCount: filteredItems.length,
                  totalCount: archiveDossierItems.length,
                ),
                if (focusItem != null) ...[
                  SizedBox(height: 18.h),
                  _SectionTitle(
                    title: '入口焦點',
                    subtitle:
                        '從「${widget.entryLabel ?? '記事頁'}」帶入的卷宗已先幫你篩到對應年代。',
                  ),
                  SizedBox(height: 12.h),
                  _DossierCard(
                    item: focusItem,
                    isHighlighted: true,
                    onTap: () => _openDossier(focusItem),
                  ),
                ],
                SizedBox(height: 22.h),
                _SectionTitle(
                  title: '年代館',
                  subtitle: '點選年代後，下方卷宗列表會即時切換；現在先使用 mock data 誠實呈現可瀏覽內容。',
                ),
                SizedBox(height: 12.h),
                _EraFilterChips(
                  selectedEra: _selectedEra,
                  onSelected: (era) => setState(() => _selectedEra = era),
                ),
                SizedBox(height: 22.h),
                _SectionTitle(
                  title: '精選卷宗',
                  subtitle: _selectedEra == null
                      ? '目前收錄 ${archiveDossierItems.length} 份示範卷宗，每一份都可以進入詳情頁閱讀。'
                      : '$_selectedEra 目前有 ${filteredItems.length} 份示範卷宗。',
                ),
                SizedBox(height: 12.h),
                if (filteredItems.isEmpty)
                  const _ArchiveEmptyState()
                else
                  for (final item in filteredItems) ...[
                    _DossierCard(
                      item: item,
                      isHighlighted: focusItem?.id == item.id,
                      onTap: () => _openDossier(item),
                    ),
                    SizedBox(height: 12.h),
                  ],
                SizedBox(height: 8.h),
                const _ArchiveSourceNote(),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArchiveHero extends StatelessWidget {
  const _ArchiveHero({
    required this.entryLabel,
    required this.focusTitle,
  });

  final String? entryLabel;
  final String? focusTitle;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/journal/journal_case_surf.png',
          fit: BoxFit.cover,
          alignment: Alignment.centerRight,
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF173C37).withValues(alpha: 0.94),
                const Color(0xFF173C37).withValues(alpha: 0.48),
                Colors.transparent,
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(22.w, 86.h, 22.w, 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (entryLabel != null)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(999.r),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.22),
                    ),
                  ),
                  child: Text(
                    entryLabel!,
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFF8F2E7),
                    ),
                  ),
                ),
              SizedBox(height: 12.h),
              Text(
                '案件資料館',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8.h),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 248.w),
                child: Text(
                  focusTitle == null
                      ? '從正在被討論的社會事件，走進可篩選、可閱讀的示範卷宗。'
                      : '從 $focusTitle 出發，回看那一天之前與之後，社會是怎麼記住這起案件的。',
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.88),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ArchiveStatusBanner extends StatelessWidget {
  const _ArchiveStatusBanner({
    required this.selectedEra,
    required this.visibleCount,
    required this.totalCount,
  });

  final String? selectedEra;
  final int visibleCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF3),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: const Color(0xFFD9C9A8).withValues(alpha: 0.92),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              color: const Color(0xFF173C37),
              borderRadius: BorderRadius.circular(15.r),
            ),
            child: Icon(
              CupertinoIcons.archivebox_fill,
              size: 20.sp,
              color: const Color(0xFFF3D08B),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              selectedEra == null
                  ? '目前顯示全部 $totalCount 份 mock 卷宗。'
                  : '目前瀏覽 $selectedEra：$visibleCount / $totalCount 份卷宗。',
              style: TextStyle(
                fontSize: 12.4.sp,
                height: 1.45,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF5F5B53),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EraFilterChips extends StatelessWidget {
  const _EraFilterChips({
    required this.selectedEra,
    required this.onSelected,
  });

  final String? selectedEra;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        _EraChip(
          label: '全部',
          isSelected: selectedEra == null,
          onTap: () => onSelected(null),
        ),
        for (final label in archiveEraLabels)
          _EraChip(
            label: label,
            isSelected: selectedEra == label,
            onTap: () => onSelected(label),
          ),
      ],
    );
  }
}

class _EraChip extends StatelessWidget {
  const _EraChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: '篩選 $label',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999.r),
          onTap: onTap,
          child: Ink(
            padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF173C37) : Colors.white,
              borderRadius: BorderRadius.circular(999.r),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF173C37)
                    : AppColors.border.withValues(alpha: 0.8),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.8.sp,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : const Color(0xFF173C37),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF173C37),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 11.8.sp,
            height: 1.45,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF6D706B),
          ),
        ),
      ],
    );
  }
}

class _DossierCard extends StatelessWidget {
  const _DossierCard({
    required this.item,
    required this.isHighlighted,
    required this.onTap,
  });

  final ArchiveDossierItem item;
  final bool isHighlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '閱讀卷宗 ${item.title}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22.r),
          onTap: onTap,
          child: Ink(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: isHighlighted ? item.tint : Colors.white,
              borderRadius: BorderRadius.circular(22.r),
              border: Border.all(
                color: isHighlighted
                    ? const Color(0xFF173C37).withValues(alpha: 0.34)
                    : AppColors.border.withValues(alpha: 0.75),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.035),
                  blurRadius: 14,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 9.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9F1ED),
                        borderRadius: BorderRadius.circular(999.r),
                      ),
                      child: Text(
                        item.era,
                        style: TextStyle(
                          fontSize: 10.8.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF173C37),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        item.tag,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF897456),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 17.sp,
                    height: 1.2,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF173C37),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  item.summary,
                  style: TextStyle(
                    fontSize: 12.2.sp,
                    height: 1.55,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF5F5B53),
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${item.fullDate}｜${item.location}',
                        style: TextStyle(
                          fontSize: 11.2.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF7A705E),
                        ),
                      ),
                    ),
                    Text(
                      '閱讀卷宗',
                      style: TextStyle(
                        fontSize: 11.6.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF173C37),
                      ),
                    ),
                    SizedBox(width: 5.w),
                    Icon(
                      CupertinoIcons.arrow_right,
                      size: 13.sp,
                      color: const Color(0xFF173C37),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ArchiveEmptyState extends StatelessWidget {
  const _ArchiveEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.78)),
      ),
      child: Text(
        '這個年代還沒有卷宗。等後端資料補齊後，可以保留這個空狀態作為載入或無資料提示。',
        style: TextStyle(
          fontSize: 12.2.sp,
          height: 1.5,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF5F5B53),
        ),
      ),
    );
  }
}

class _ArchiveSourceNote extends StatelessWidget {
  const _ArchiveSourceNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF9F1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: const Color(0xFFD9C9A8).withValues(alpha: 0.92),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '資料狀態',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF6B4E2F),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '目前資料館使用 app 內建 mock data，目標是先讓使用者真的能瀏覽、篩選與閱讀詳情；接後端後可把卷宗列表、年代與時間軸改由 API 回傳。',
            style: TextStyle(
              fontSize: 12.2.sp,
              height: 1.5,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF5F5B53),
            ),
          ),
        ],
      ),
    );
  }
}

/// 卷宗詳情頁。
///
/// 台灣繁體中文教學註解：
/// 詳情頁先避免做成「死資料卡」，改用摘要、時間軸、觀察重點與來源四段；
/// 這些段落都對應到日後後端最容易提供的資料欄位，維護時比較不會牽一髮動全身。
class ArchiveDossierDetailPage extends StatelessWidget {
  const ArchiveDossierDetailPage({super.key, required this.item});

  final ArchiveDossierItem item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F1E8),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 210.h,
            backgroundColor: const Color(0xFFF6F1E8),
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(CupertinoIcons.back),
              color: const Color(0xFF173C37),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: _DossierDetailHero(item: item),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 120.h),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _DetailSectionCard(
                  title: '卷宗導讀',
                  child: Text(
                    item.lead,
                    style: _detailBodyStyle(),
                  ),
                ),
                SizedBox(height: 14.h),
                _TimelineSection(item: item),
                SizedBox(height: 14.h),
                _DetailSectionCard(
                  title: '法律與社會觀察',
                  child: _BulletList(items: item.keyPoints),
                ),
                SizedBox(height: 14.h),
                _DetailSectionCard(
                  title: '資料來源',
                  child: _BulletList(items: item.sources),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _DossierDetailHero extends StatelessWidget {
  const _DossierDetailHero({required this.item});

  final ArchiveDossierItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(22.w, 78.h, 22.w, 22.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF173C37),
            const Color(0xFF245E54),
            item.tint,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _HeroPill(label: item.era),
              SizedBox(width: 8.w),
              _HeroPill(label: item.tag),
            ],
          ),
          const Spacer(),
          Text(
            item.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 25.sp,
              height: 1.12,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '${item.fullDate}｜${item.location}｜${item.statusLabel}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.2.sp,
              height: 1.45,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.84),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _TimelineSection extends StatelessWidget {
  const _TimelineSection({required this.item});

  final ArchiveDossierItem item;

  @override
  Widget build(BuildContext context) {
    return _DetailSectionCard(
      title: '案件時間軸',
      child: Column(
        children: [
          for (var index = 0; index < item.timeline.length; index++)
            _TimelineRow(
              item: item.timeline[index],
              isLast: index == item.timeline.length - 1,
            ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.item,
    required this.isLast,
  });

  final ArchiveTimelineItem item;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24.w,
          child: Column(
            children: [
              Container(
                width: 10.w,
                height: 10.w,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF173C37),
                ),
              ),
              if (!isLast)
                Container(
                  width: 1.2.w,
                  height: 52.h,
                  color: const Color(0xFFD8C7A6),
                ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 14.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 13.2.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF173C37),
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  item.description,
                  style: _detailBodyStyle(),
                ),
              ],
            ),
          ),
        ),
      ],
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.76)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF173C37),
            ),
          ),
          SizedBox(height: 10.h),
          child,
        ],
      ),
    );
  }
}

class _BulletList extends StatelessWidget {
  const _BulletList({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 7.h),
                child: Container(
                  width: 5.w,
                  height: 5.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFB58A48),
                  ),
                ),
              ),
              SizedBox(width: 9.w),
              Expanded(
                child: Text(
                  item,
                  style: _detailBodyStyle(),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
        ],
      ],
    );
  }
}

TextStyle _detailBodyStyle() {
  return TextStyle(
    fontSize: 12.4.sp,
    height: 1.58,
    fontWeight: FontWeight.w600,
    color: const Color(0xFF5F5B53),
  );
}
