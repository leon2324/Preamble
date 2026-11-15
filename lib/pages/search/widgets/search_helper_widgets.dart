part of '../global_search_page.dart';

// 靜奢律政編輯風 × 雙重編碼共用基礎元件。
// 所有表面與文字色彩皆強制自 BuildContext 讀取 PreambleTokens，
// 並徹底移除卡片層級 BackdropFilter，確保 120fps 滑動效能與深淺色高對比。

class _AdvancedRoutes extends StatelessWidget {
  const _AdvancedRoutes({required this.onOpen});

  final ValueChanged<_SearchPage> onOpen;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return _ProtoCard(
      background: t.surfaceSubtle,
      elevated: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIconsRegular.compass,
                size: 16.sp,
                color: t.brandPrimary,
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text('進階查詢路徑', style: _SearchText.section(context)),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _Pill(
                label: 'AI 問診解析',
                icon: PhosphorIconsRegular.chatsCircle,
                onTap: () => onOpen(_SearchPage.assistant),
              ),
              _Pill(
                label: '法規檢索專區',
                icon: PhosphorIconsRegular.bookBookmark,
                onTap: () => onOpen(_SearchPage.statutes),
              ),
              _Pill(
                label: '裁判案卷專區',
                icon: PhosphorIconsRegular.gavel,
                onTap: () => onOpen(_SearchPage.cases),
              ),
              _Pill(
                label: '避坑實務專區',
                icon: PhosphorIconsRegular.lightbulbFilament,
                onTap: () => onOpen(_SearchPage.lifeNotes),
              ),
              _Pill(
                label: '法務動態連結',
                icon: PhosphorIconsRegular.bank,
                onTap: () => onOpen(_SearchPage.official),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NextStep extends StatelessWidget {
  const _NextStep({
    required this.label,
    required this.onTap,
    this.icon,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: _ProtoCard(
        onTap: onTap,
        elevated: false,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        child: Row(
          children: [
            Icon(
              icon ?? PhosphorIconsRegular.arrowSquareOut,
              color: t.brandPrimary,
              size: 17.sp,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(label, style: _SearchText.bodyStrong(context)),
            ),
            Icon(
              PhosphorIconsRegular.caretRight,
              color: t.textMuted,
              size: 15.sp,
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.title,
    required this.showBack,
    required this.onBack,
    this.trailing,
  });

  final String title;
  final bool showBack;
  final VoidCallback onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showBack) ...[
          _RoundIcon(
            icon: Icons.arrow_back_ios_new_rounded,
            tooltip: '返回上一層',
            onTap: onBack,
          ),
          SizedBox(width: 10.w),
        ],
        Expanded(
          child: Text(
            title,
            style: _SearchText.navTitle(context),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.active = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999.r),
        child: Container(
          constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: active ? t.brandContainer : t.surface,
            shape: BoxShape.circle,
            border: Border.all(
              color: active ? t.brandPrimary : t.border,
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: active ? t.brandPrimary : t.textPrimary,
            size: 18.sp,
          ),
        ),
      ),
    );

    if (tooltip == null || tooltip!.isEmpty) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}

class _ProtoCard extends StatelessWidget {
  const _ProtoCard({
    required this.child,
    this.onTap,
    this.background,
    this.borderColor,
    this.padding,
    this.elevated = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color? background;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final r = 16.r;
    final decoration = t.cardDecoration(
      radius: r,
      fill: background ?? t.surface,
      borderColor: borderColor ?? t.border,
      elevated: elevated,
    );

    if (onTap == null) {
      return Container(
        width: double.infinity,
        padding: padding ?? EdgeInsets.all(14.w),
        decoration: decoration,
        child: child,
      );
    }

    return Container(
      width: double.infinity,
      decoration: decoration,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(r),
          child: Padding(
            padding: padding ?? EdgeInsets.all(14.w),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.onTap,
    this.icon,
    this.selected = false,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
          decoration: BoxDecoration(
            color: selected ? t.brandPrimaryStrong : t.surface,
            borderRadius: BorderRadius.circular(999.r),
            border: Border.all(
              color: selected ? t.brandPrimaryStrong : t.border,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 13.sp,
                  color: selected ? const Color(0xFFFAF8F4) : t.brandPrimary,
                ),
                SizedBox(width: 5.w),
              ],
              Flexible(
                child: Text(
                  label,
                  style: _SearchText.captionStrong(context).copyWith(
                    color: selected ? const Color(0xFFFAF8F4) : t.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallTag extends StatelessWidget {
  const _SmallTag({
    required this.label,
    this.accent = false,
  });

  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: accent ? t.accentBrassContainer : t.brandContainer,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: (accent ? t.accentBrass : t.brandPrimary)
              .withValues(alpha: 0.22),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: _SearchText.captionStrong(context).copyWith(
          color: accent ? t.accentOnBrassContainer : t.brandOnContainer,
        ),
      ),
    );
  }
}

class _CheckLine extends StatelessWidget {
  const _CheckLine({
    required this.text,
    this.checked = true,
    this.onTap,
  });

  final String text;
  final bool checked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final row = Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 2.h),
            child: Icon(
              checked
                  ? PhosphorIconsFill.checkCircle
                  : PhosphorIconsRegular.circle,
              color: checked ? t.brandPrimary : t.textMuted,
              size: 16.sp,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: checked
                  ? _SearchText.bodyStrong(context)
                  : _SearchText.body(context),
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return row;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: row,
    );
  }
}

class _RadioLine extends StatelessWidget {
  const _RadioLine({
    required this.text,
    this.selected = false,
    this.onTap,
  });

  final String text;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final row = Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Row(
        children: [
          Icon(
            selected
                ? PhosphorIconsFill.radioButton
                : PhosphorIconsRegular.circle,
            color: selected ? t.brandPrimary : t.textMuted,
            size: 17.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: selected
                  ? _SearchText.bodyStrong(context)
                  : _SearchText.body(context),
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return row;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: row,
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({
    required this.icon,
    required this.color,
    this.backgroundColor,
  });

  final IconData icon;
  final Color color;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.r,
      height: 40.r,
      decoration: BoxDecoration(
        color: backgroundColor ?? color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(11.r),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: color, size: 19.sp),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final style = FilledButton.styleFrom(
      backgroundColor: t.brandPrimaryStrong,
      foregroundColor: const Color(0xFFFAF8F4),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 11.h),
      minimumSize: const Size(double.infinity, 44),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.r),
        side: BorderSide(color: t.accentBrass.withValues(alpha: 0.3)),
      ),
      textStyle: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w700,
      ),
    );

    if (icon != null) {
      return FilledButton.icon(
        onPressed: onPressed,
        style: style,
        icon: Icon(icon, size: 16.sp, color: t.accentBrass),
        label: Text(label),
      );
    }

    return FilledButton(
      onPressed: onPressed,
      style: style,
      child: Text(label),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final style = OutlinedButton.styleFrom(
      foregroundColor: t.brandPrimary,
      backgroundColor: t.surface,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      minimumSize: const Size(double.infinity, 42),
      side: BorderSide(color: t.borderStrong),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.r),
      ),
      textStyle: TextStyle(
        fontSize: 12.5.sp,
        fontWeight: FontWeight.w700,
      ),
    );

    if (icon != null) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        style: style,
        icon: Icon(icon, size: 15.sp),
        label: Text(label),
      );
    }

    return OutlinedButton(
      onPressed: onPressed,
      style: style,
      child: Text(label),
    );
  }
}
