part of '../global_search_page.dart';

// 狀態卡、分類 Tab 與「真實生效」的檢索篩選／排序控制器。
// 所有篩選晶片、排序切換與篩選面板皆綁定 GlobalSearchPage 狀態，徹底消除空殼按鈕。

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.icon,
    this.action,
    this.onAction,
  });

  final String title;
  final IconData? icon;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 16.sp, color: t.accentBrass),
          SizedBox(width: 6.w),
        ],
        Expanded(child: Text(title, style: _SearchText.section(context))),
        if (action != null)
          InkWell(
            onTap: onAction,
            borderRadius: BorderRadius.circular(6.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
              child: Text(action!, style: _SearchText.action(context)),
            ),
          ),
      ],
    );
  }
}

class _SearchStateCard extends StatelessWidget {
  const _SearchStateCard({
    required this.message,
    this.icon,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return _ProtoCard(
      background: t.surfaceSubtle,
      elevated: false,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 26.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48.r,
            height: 48.r,
            decoration: BoxDecoration(
              color: t.brandContainer,
              shape: BoxShape.circle,
              border: Border.all(
                color: t.brandPrimary.withValues(alpha: 0.2),
              ),
            ),
            child: Icon(
              icon ?? PhosphorIconsRegular.magnifyingGlass,
              color: t.brandPrimary,
              size: 22.sp,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            message,
            style: _SearchText.bodyStrong(context),
            textAlign: TextAlign.center,
          ),
          if (actionLabel != null && onAction != null) ...[
            SizedBox(height: 14.h),
            OutlinedButton.icon(
              onPressed: onAction,
              style: OutlinedButton.styleFrom(
                foregroundColor: t.brandPrimary,
                side: BorderSide(color: t.borderStrong),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999.r),
                ),
              ),
              icon: Icon(PhosphorIconsRegular.arrowCounterClockwise, size: 14.sp),
              label: Text(
                actionLabel!,
                style: _SearchText.captionStrong(context).copyWith(
                  color: t.brandPrimary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SearchTabs extends StatelessWidget {
  const _SearchTabs({
    required this.tab,
    required this.onTab,
  });

  final _SearchTab tab;
  final ValueChanged<_SearchTab> onTab;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    const labels = <_SearchTab, String>{
      _SearchTab.all: '全部',
      _SearchTab.assistant: '小法助',
      _SearchTab.statutes: '法規',
      _SearchTab.cases: '案件',
      _SearchTab.lifeNotes: '避坑實務',
      _SearchTab.official: '法務動態',
    };
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: t.border, width: 1)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: labels.entries.map((entry) {
            final active = entry.key == tab;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTab(entry.key),
              child: Padding(
                padding: EdgeInsets.only(right: 20.w, top: 4.h),
                child: Container(
                  padding: EdgeInsets.only(bottom: 9.h),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: active ? t.brandPrimary : Colors.transparent,
                        width: 2.2,
                      ),
                    ),
                  ),
                  child: Text(
                    entry.value,
                    style: _SearchText.tab(context).copyWith(
                      color: active ? t.brandPrimary : t.textMuted,
                    ),
                  ),
                ),
              ),
            );
          }).toList(growable: false),
        ),
      ),
    );
  }
}

class _InteractiveFilterBar extends StatelessWidget {
  const _InteractiveFilterBar({
    required this.sortMode,
    required this.domainFilter,
    required this.activeFilterCount,
    required this.onSortChanged,
    required this.onDomainChanged,
    required this.onOpenFilterPanel,
  });

  final _SearchSortMode sortMode;
  final _SearchDomainFilter domainFilter;
  final int activeFilterCount;
  final ValueChanged<_SearchSortMode> onSortChanged;
  final ValueChanged<_SearchDomainFilter> onDomainChanged;
  final VoidCallback onOpenFilterPanel;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              // 排序切換晶片：相關度優先 ⇄ 最新年度
              for (final mode in _SearchSortMode.values)
                Padding(
                  padding: EdgeInsets.only(right: 6.w),
                  child: _FilterChipItem(
                    label: mode.label,
                    icon: mode == _SearchSortMode.relevance
                        ? PhosphorIconsRegular.sparkle
                        : PhosphorIconsRegular.calendarBlank,
                    selected: sortMode == mode,
                    onTap: () => onSortChanged(mode),
                  ),
                ),
              Container(
                width: 1,
                height: 18.h,
                margin: EdgeInsets.symmetric(horizontal: 6.w),
                color: t.borderStrong,
              ),
              // 爭議領域篩選晶片：全部領域／民事／刑事／勞動／租屋
              for (final domain in _SearchDomainFilter.values)
                Padding(
                  padding: EdgeInsets.only(right: 6.w),
                  child: _FilterChipItem(
                    label: domain.label,
                    selected: domainFilter == domain,
                    accentWhenSelected: domain != _SearchDomainFilter.all,
                    onTap: () => onDomainChanged(domain),
                  ),
                ),
              // 進階篩選面板入口
              _FilterChipItem(
                label: activeFilterCount > 0
                    ? '篩選 ($activeFilterCount)'
                    : '進階篩選',
                icon: PhosphorIconsRegular.slidersHorizontal,
                selected: activeFilterCount > 0,
                accentWhenSelected: true,
                onTap: onOpenFilterPanel,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FilterChipItem extends StatelessWidget {
  const _FilterChipItem({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.accentWhenSelected = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final bool accentWhenSelected;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final bg = selected
        ? (accentWhenSelected ? t.accentBrassContainer : t.brandContainer)
        : t.surface;
    final fg = selected
        ? (accentWhenSelected ? t.accentOnBrassContainer : t.brandOnContainer)
        : t.textSecondary;
    final borderCol = selected
        ? (accentWhenSelected
            ? t.accentBrass.withValues(alpha: 0.45)
            : t.brandPrimary.withValues(alpha: 0.4))
        : t.border;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(999.r),
            border: Border.all(color: borderCol, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 13.sp, color: fg),
                SizedBox(width: 4.w),
              ],
              Text(
                label,
                style: _SearchText.captionStrong(context).copyWith(
                  color: fg,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubListFilterStrip extends StatelessWidget {
  const _SubListFilterStrip({
    required this.selected,
    required this.onChanged,
  });

  final _SubListFilter selected;
  final ValueChanged<_SubListFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _SubListFilter.values.map((filter) {
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: _Pill(
              label: filter.label,
              selected: selected == filter,
              onTap: () => onChanged(filter),
            ),
          );
        }).toList(growable: false),
      ),
    );
  }
}

class _DetailSectionSwitch extends StatelessWidget {
  const _DetailSectionSwitch({
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: t.subtleBoxDecoration(radius: 12.r),
      child: Row(
        children: List.generate(labels.length, (index) {
          final active = index == selectedIndex;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onSelected(index),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 6.w),
                decoration: BoxDecoration(
                  color: active ? t.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(9.r),
                  border: active ? Border.all(color: t.borderStrong) : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  labels[index],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _SearchText.captionStrong(context).copyWith(
                    color: active ? t.brandPrimary : t.textMuted,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _FilterPanel extends StatelessWidget {
  const _FilterPanel({
    required this.enabledTypes,
    required this.domainFilter,
    required this.recentYearsFilter,
    required this.sortMode,
    required this.onToggleType,
    required this.onDomainChanged,
    required this.onRecentYearsChanged,
    required this.onSortChanged,
    required this.onReset,
    required this.onApply,
  });

  final Set<_ResultType> enabledTypes;
  final _SearchDomainFilter domainFilter;
  final int? recentYearsFilter;
  final _SearchSortMode sortMode;
  final ValueChanged<_ResultType> onToggleType;
  final ValueChanged<_SearchDomainFilter> onDomainChanged;
  final ValueChanged<int?> onRecentYearsChanged;
  final ValueChanged<_SearchSortMode> onSortChanged;
  final VoidCallback onReset;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    const sourceOptions = <(_ResultType, String)>[
      (_ResultType.statute, '法規條文（民刑法・勞基・消保）'),
      (_ResultType.caseItem, '裁判案卷（各級法院實務見解）'),
      (_ResultType.lifeNote, '避坑實務（蒐證與自保指南）'),
      (_ResultType.official, '法務動態（司法院・法務部・165）'),
    ];
    const yearOptions = <(int?, String)>[
      (null, '不限時間（完整資料庫）'),
      (1, '近一年內更新／裁判'),
      (3, '近三年內更新／裁判'),
    ];

    return _ProtoCard(
      padding: EdgeInsets.all(18.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIconsRegular.slidersHorizontal,
                size: 18.sp,
                color: t.brandPrimary,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text('精準檢索篩選條件', style: _SearchText.section(context)),
              ),
              TextButton.icon(
                onPressed: onReset,
                icon: Icon(
                  PhosphorIconsRegular.arrowCounterClockwise,
                  size: 14.sp,
                  color: t.brandPrimary,
                ),
                label: Text('重設條件', style: _SearchText.action(context)),
              ),
            ],
          ),
          Divider(color: t.border, height: 22.h),
          Text('爭議法學領域', style: _SearchText.captionStrong(context)),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: _SearchDomainFilter.values.map((domain) {
              return _Pill(
                label: domain.label,
                selected: domainFilter == domain,
                onTap: () => onDomainChanged(domain),
              );
            }).toList(growable: false),
          ),
          SizedBox(height: 18.h),
          Text('檢索資料來源', style: _SearchText.captionStrong(context)),
          SizedBox(height: 6.h),
          for (final (type, label) in sourceOptions)
            _CheckLine(
              text: label,
              checked: enabledTypes.contains(type),
              onTap: () => onToggleType(type),
            ),
          SizedBox(height: 16.h),
          Text('年度與時效範圍', style: _SearchText.captionStrong(context)),
          SizedBox(height: 6.h),
          for (final (years, label) in yearOptions)
            _RadioLine(
              text: label,
              selected: recentYearsFilter == years,
              onTap: () => onRecentYearsChanged(years),
            ),
          SizedBox(height: 16.h),
          Text('結果排序依據', style: _SearchText.captionStrong(context)),
          SizedBox(height: 6.h),
          for (final mode in _SearchSortMode.values)
            _RadioLine(
              text: mode.label,
              selected: sortMode == mode,
              onTap: () => onSortChanged(mode),
            ),
          SizedBox(height: 20.h),
          _PrimaryButton(
            label: '套用篩選並檢視結果',
            icon: PhosphorIconsRegular.check,
            onPressed: onApply,
          ),
        ],
      ),
    );
  }
}
