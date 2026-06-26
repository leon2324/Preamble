part of '../global_search_page.dart';

// 這裡放搜尋頁的狀態卡、Tab 與篩選外觀元件；
// filter state 仍由父層管理，本檔只保留既有展示與按鈕 callback。

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.action, this.onAction});

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: _SearchText.section())),
        if (action != null)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onAction,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 4.h),
              child: Text(action!, style: _SearchText.action()),
            ),
          ),
      ],
    );
  }
}

class _PrototypeChipGrid extends StatelessWidget {
  const _PrototypeChipGrid({required this.labels, required this.onTap});

  final List<String> labels;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6.w,
      runSpacing: 7.h,
      children: labels
          .map((label) => _Pill(label: label, onTap: () => onTap(label)))
          .toList(growable: false),
    );
  }
}

class _SearchStateCard extends StatelessWidget {
  const _SearchStateCard({required this.message, this.showMascot = true});

  final String message;
  final bool showMascot;

  @override
  Widget build(BuildContext context) {
    return _ProtoCard(
      background: _SearchColors.softPaper,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showMascot) ...[
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: _SearchColors.border.withValues(alpha: 0.5),
                    width: 1.8.w),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 7,
                    offset: const Offset(0, 3.5),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/assistant/law_assistant_empty.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 16.h),
          ],
          Text(
            message,
            style: _SearchText.bodyStrong().copyWith(
              color: _SearchColors.text,
              fontSize: 13.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _FilterPanel extends StatelessWidget {
  const _FilterPanel({required this.onApply});

  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return _ProtoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('篩選條件', style: _SearchText.section())),
              Text('重設', style: _SearchText.action()),
            ],
          ),
          SizedBox(height: 16.h),
          Text('資料來源', style: _SearchText.captionStrong()),
          SizedBox(height: 8.h),
          const _CheckLine(text: '小法助'),
          const _CheckLine(text: '法規'),
          const _CheckLine(text: '案件'),
          const _CheckLine(text: '生活避坑'),
          const _CheckLine(text: '官方資料'),
          SizedBox(height: 14.h),
          Text('時間範圍', style: _SearchText.captionStrong()),
          SizedBox(height: 8.h),
          const _RadioLine(text: '不限時間', selected: true),
          const _RadioLine(text: '近一年'),
          const _RadioLine(text: '近三年'),
          const _RadioLine(text: '自訂區間'),
          SizedBox(height: 14.h),
          Text('排序方式', style: _SearchText.captionStrong()),
          SizedBox(height: 8.h),
          const _RadioLine(text: '相關性', selected: true),
          const _RadioLine(text: '最新'),
          SizedBox(height: 16.h),
          _PrimaryButton(label: '套用篩選', onPressed: onApply),
        ],
      ),
    );
  }
}

class _SearchTabs extends StatelessWidget {
  const _SearchTabs({required this.tab, required this.onTab});

  final _SearchTab tab;
  final ValueChanged<_SearchTab> onTab;

  @override
  Widget build(BuildContext context) {
    final labels = {
      _SearchTab.all: '全部',
      _SearchTab.assistant: '小法助',
      _SearchTab.statutes: '法規',
      _SearchTab.cases: '案件',
      _SearchTab.lifeNotes: '生活避坑',
      _SearchTab.official: '官方資料',
    };
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: labels.entries.map((entry) {
          final active = entry.key == tab;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onTab(entry.key),
            child: Padding(
              padding: EdgeInsets.only(right: 19.w, top: 8.h),
              child: Container(
                padding: EdgeInsets.only(bottom: 9.h),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color:
                          active ? _SearchColors.primary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  entry.value,
                  style: _SearchText.tab().copyWith(
                    color: active
                        ? _SearchColors.primary
                        : _SearchColors.mutedText,
                  ),
                ),
              ),
            ),
          );
        }).toList(growable: false),
      ),
    );
  }
}

class _TabStrip extends StatelessWidget {
  const _TabStrip({required this.labels});

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor =
        isDark ? const Color(0xFF33A88D) : _SearchColors.primary;
    final inactiveColor =
        isDark ? const Color(0xFFA4B2AB) : _SearchColors.mutedText;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Container(
              margin: EdgeInsets.only(right: 18.w),
              padding: EdgeInsets.only(bottom: 8.h),
              decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: i == 0 ? activeColor : Colors.transparent,
                        width: 1.5)),
              ),
              child: Text(labels[i],
                  style: _SearchText.captionStrong(context)
                      .copyWith(color: i == 0 ? activeColor : inactiveColor)),
            ),
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _MiniFilter(label: '排序：相關性'),
        SizedBox(width: 8.w),
        _MiniFilter(label: '時間：全部'),
        const Spacer(),
        _MiniFilter(label: '篩選'),
      ],
    );
  }
}

class _MiniFilter extends StatelessWidget {
  const _MiniFilter({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg =
        isDark ? const Color(0xFF1E2530) : Colors.white.withValues(alpha: 0.85);
    final border = isDark ? const Color(0xFF2C3545) : const Color(0xFFE2E8F0);
    final textColor = isDark ? const Color(0xFFE2E8F0) : _SearchColors.text;

    return GestureDetector(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: border, width: 0.8.w),
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (label == '篩選') ...[
              Icon(Icons.tune_rounded, size: 12.sp, color: textColor),
              SizedBox(width: 4.w),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            if (label != '篩選') ...[
              SizedBox(width: 4.w),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 13.sp,
                color: textColor.withValues(alpha: 0.7),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
