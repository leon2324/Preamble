part of '../following_page.dart';

// 這個 part 檔集中放 Following Page 可重用的基礎 UI 元件。
// 這些元件只負責視覺呈現與簡單 callback，不承擔資料來源或頁面切換流程。

class _FollowTabBar extends StatelessWidget {
  const _FollowTabBar({required this.tab, required this.onTab});

  final _FollowTab tab;
  final ValueChanged<_FollowTab> onTab;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42.h,
      decoration: const BoxDecoration(),
      child: Row(
        children: [
          _TabButton(
              label: '案件',
              active: tab == _FollowTab.cases,
              onTap: () => onTab(_FollowTab.cases)),
          _TabButton(
              label: '法條',
              active: tab == _FollowTab.statutes,
              onTap: () => onTab(_FollowTab.statutes)),
          _TabButton(
              label: '主題',
              active: tab == _FollowTab.topics,
              onTap: () => onTab(_FollowTab.topics)),
          _TabButton(
              label: '關鍵字',
              active: tab == _FollowTab.keywords,
              onTap: () => onTab(_FollowTab.keywords)),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton(
      {required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: active ? _FollowColors.primary : Colors.transparent,
                width: 1.5,
              ),
            ),
          ),
          child: Text(
            label,
            style: _FollowText.captionStrong().copyWith(
              color: active ? _FollowColors.primary : _FollowColors.text,
            ),
          ),
        ),
      ),
    );
  }
}

class _TabStrip extends StatelessWidget {
  const _TabStrip({
    required this.labels,
    this.selectedIndex = 0,
    this.onChanged,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    // Prototype 的分類列不是裝飾底線而已；這裡把選取狀態交給父層，
    // 讓「我的」底下的動態、收藏、筆記與草稿都能用同一個可互動元件切換資料。
    return Container(
      height: 42.h,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _FollowColors.divider)),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: labels.length,
        separatorBuilder: (_, __) => SizedBox(width: 10.w),
        itemBuilder: (context, i) {
          final active = i == selectedIndex;
          return InkWell(
            onTap: onChanged == null ? null : () => onChanged!(i),
            borderRadius: BorderRadius.circular(8.r),
            child: Container(
              constraints: BoxConstraints(minWidth: 58.w),
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: active ? _FollowColors.primary : Colors.transparent,
                    width: 1.5,
                  ),
                ),
              ),
              child: Text(
                labels[i],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _FollowText.captionStrong().copyWith(
                  color: active ? _FollowColors.primary : _FollowColors.text,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.title,
    required this.showBack,
    required this.onBack,
    this.centerTitle = false,
    this.trailing,
  });

  final String title;
  final bool showBack;
  final VoidCallback onBack;
  final bool centerTitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    if (centerTitle) {
      // 有返回鍵與搜尋鍵時，單純用 Row + Expanded 會讓標題被左側返回鍵推偏；
      // 置中頁首改用 Stack，左右按鈕貼邊，標題永遠以整個螢幕寬度置中。
      return SizedBox(
        height: 40.h,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (showBack)
              Align(
                alignment: Alignment.centerLeft,
                child: _RoundIcon(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: onBack,
                ),
              ),
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 64.w),
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: _FollowText.navTitle(),
                ),
              ),
            ),
            if (trailing != null)
              Align(alignment: Alignment.centerRight, child: trailing!),
          ],
        ),
      );
    }

    return Row(
      children: [
        if (showBack) ...[
          _RoundIcon(icon: Icons.arrow_back_ios_new_rounded, onTap: onBack),
          SizedBox(width: 10.w),
        ],
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _FollowText.navTitle(),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.action, this.onTap});

  final String title;
  final String? action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: _FollowText.section())),
        if (action != null && onTap != null)
          TextButton(onPressed: onTap, child: Text(action!)),
      ],
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow(
      {required this.title,
      this.value,
      this.trailing,
      this.locked = false,
      this.onTap});

  final String title;
  final String? value;
  final IconData? trailing;
  final bool locked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final row = _SettingShell(
      child: Row(
        children: [
          Expanded(child: Text(title, style: _FollowText.bodyStrong())),
          if (value != null) Text(value!, style: _FollowText.caption()),
          SizedBox(width: 8.w),
          Icon(locked ? Icons.lock_outline_rounded : trailing,
              color: _FollowColors.mutedText, size: 18.sp),
        ],
      ),
    );
    if (onTap == null) return row;
    return InkWell(
      onTap: onTap,
      child: row,
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow(
      {required this.title, required this.value, required this.onChanged});

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return _SettingShell(
      child: Row(
        children: [
          Expanded(child: Text(title, style: _FollowText.bodyStrong())),
          Switch(
            value: value,
            activeThumbColor: _FollowColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _LockedRow extends StatelessWidget {
  const _LockedRow({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return _SettingShell(
      child: Row(
        children: [
          Expanded(child: Text(title, style: _FollowText.bodyStrong())),
          Icon(Icons.lock_outline_rounded,
              color: _FollowColors.mutedText, size: 18.sp),
        ],
      ),
    );
  }
}

class _SettingShell extends StatelessWidget {
  const _SettingShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 50.h),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _FollowColors.divider)),
      ),
      child: child,
    );
  }
}

class _SoftDivider extends StatelessWidget {
  const _SoftDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      color: _FollowColors.divider,
    );
  }
}

class _CheckLine extends StatelessWidget {
  const _CheckLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Icon(Icons.check_rounded, color: _FollowColors.primary, size: 16.sp),
          SizedBox(width: 8.w),
          Expanded(child: Text(text, style: _FollowText.bodyStrong())),
        ],
      ),
    );
  }
}

class _BottomAction extends StatelessWidget {
  const _BottomAction({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: _FollowColors.text, size: 21.sp),
          SizedBox(height: 5.h),
          Text(label, style: _FollowText.captionStrong()),
        ],
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999.r),
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: _FollowColors.text, size: 19.sp),
      ),
    );
  }
}

class _TrackedPill extends StatelessWidget {
  const _TrackedPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: _FollowColors.softPaper,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text('已追蹤', style: _FollowText.captionStrong()),
    );
  }
}

class _NewBadge extends StatelessWidget {
  const _NewBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
      decoration: const BoxDecoration(
        color: _FollowColors.orange,
        shape: BoxShape.circle,
      ),
      child:
          Text('新', style: _FollowText.buttonSmall().copyWith(fontSize: 9.sp)),
    );
  }
}

class _SmallPill extends StatelessWidget {
  const _SmallPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: _FollowColors.softPaper,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(label, style: _FollowText.captionStrong()),
    );
  }
}

class _HintText extends StatelessWidget {
  const _HintText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: _FollowText.caption().copyWith(height: 1.5),
    );
  }
}

class _TinyBadge extends StatelessWidget {
  const _TinyBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: _FollowColors.primary,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(label,
          style: _FollowText.buttonSmall().copyWith(fontSize: 9.sp)),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42.w,
      height: 42.w,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Icon(icon, color: color, size: 22.sp),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return _ProtoCard(
      background: _FollowColors.softMist,
      child: Row(
        children: [
          Icon(Icons.inbox_outlined,
              color: _FollowColors.mutedText, size: 20.sp),
          SizedBox(width: 10.w),
          Expanded(child: Text(message, style: _FollowText.captionStrong())),
        ],
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        color: _FollowColors.softPaper,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Icon(icon, color: _FollowColors.text, size: 24.sp),
    );
  }
}

class _ClipboardIllustration extends StatelessWidget {
  const _ClipboardIllustration({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 86.w,
      height: 88.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 58.w,
            height: 72.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: _FollowColors.borderDark),
            ),
          ),
          Icon(icon, color: _FollowColors.primary, size: 32.sp),
          Positioned(
            right: 4.w,
            bottom: 8.h,
            child: Icon(Icons.bookmark_border_rounded,
                color: _FollowColors.gold, size: 28.sp),
          ),
        ],
      ),
    );
  }
}

class _FooterIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: SvgPicture.asset(
        _ProfileAsset.footer,
        width: double.infinity,
        height: 76.h,
        fit: BoxFit.cover,
      ),
    );
  }
}

class _ProtoCard extends StatelessWidget {
  const _ProtoCard({
    required this.child,
    this.onTap,
    this.background = Colors.white,
    this.padding,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color background;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(13.w),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: background == Colors.white
              ? Colors.transparent
              : _FollowColors.cardStroke,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );

    if (onTap == null) return card;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: card,
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 46.h,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: _FollowColors.primary,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        ),
        child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 42.h,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: _FollowColors.primary,
          side: const BorderSide(color: _FollowColors.borderDark),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        ),
        child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}
