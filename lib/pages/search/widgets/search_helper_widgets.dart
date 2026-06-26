part of '../global_search_page.dart';

// 本檔集中放搜尋 Prototype 的小型展示 helper 與共用 primitive，例如卡片、按鈕、標籤與頂部列。
// 這些元件只接收文字或 callback，不直接處理搜尋 state、repository 或導頁決策。

class _AssistantHint extends StatelessWidget {
  const _AssistantHint({required this.query, required this.onTap});

  final String query;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _ProtoCard(
      background: _SearchColors.softMint,
      onTap: onTap,
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 4.w, 4.h),
      child: SizedBox(
        height: 100.h,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              right: 104.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('小法助總結', style: _SearchText.section()),
                  SizedBox(height: 8.h),
                  Text(
                    '針對「$query」整理相關法規、案件與生活避坑重點。',
                    style: _SearchText.body(),
                  ),
                  SizedBox(height: 8.h),
                  Text('查看說明・2 分鐘前', style: _SearchText.caption()),
                ],
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: SvgPicture.asset(_SearchAsset.plant, width: 112.w),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdvancedRoutes extends StatelessWidget {
  const _AdvancedRoutes({required this.onOpen});

  final ValueChanged<_SearchPage> onOpen;

  @override
  Widget build(BuildContext context) {
    return _ProtoCard(
      background: _SearchColors.softPaper,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('進階查詢路徑', style: _SearchText.section()),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _Pill(label: '小法助搜尋', onTap: () => onOpen(_SearchPage.assistant)),
              _Pill(label: '法規搜尋子頁', onTap: () => onOpen(_SearchPage.statutes)),
              _Pill(label: '案件搜尋子頁', onTap: () => onOpen(_SearchPage.cases)),
              _Pill(label: '官方資料', onTap: () => onOpen(_SearchPage.official)),
            ],
          ),
        ],
      ),
    );
  }
}

class _NextStep extends StatelessWidget {
  const _NextStep({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: _ProtoCard(
        onTap: onTap,
        child: Row(
          children: [
            Icon(Icons.open_in_new_rounded,
                color: _SearchColors.primary, size: 18.sp),
            SizedBox(width: 8.w),
            Expanded(child: Text(label, style: _SearchText.captionStrong())),
          ],
        ),
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({required this.item});

  final _QuickAction item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: SizedBox(
        height: 98.h,
        child: _ProtoCard(
          onTap: item.onTap,
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, color: _SearchColors.primary, size: 27.sp),
              SizedBox(height: 8.h),
              Text(
                item.label,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: _SearchText.captionStrong(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar(
      {required this.title,
      required this.showBack,
      required this.onBack,
      this.trailing});

  final String title;
  final bool showBack;
  final VoidCallback onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        if (showBack) ...[
          _RoundIcon(icon: Icons.arrow_back_ios_new_rounded, onTap: onBack),
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
  const _RoundIcon({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999.r),
      child: Container(
        width: 38.w,
        height: 38.w,
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF2C3545).withValues(alpha: 0.8)
              : Colors.white,
          shape: BoxShape.circle,
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4.r,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Icon(icon,
            color: isDark ? Colors.white : _SearchColors.text, size: 20.sp),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Adapt backgrounds for dark mode
    Color cardBg = background;
    if (cardBg == Colors.white) {
      cardBg = isDark ? const Color(0xFF1E2430) : Colors.white;
    } else if (cardBg == _SearchColors.softPaper) {
      cardBg = isDark ? const Color(0xFF282F3E) : _SearchColors.softPaper;
    } else if (cardBg == _SearchColors.mint) {
      cardBg = isDark ? const Color(0xFF1A3831) : _SearchColors.mint;
    }

    const radius = 14.0;
    final card = Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius.r),
        boxShadow: [
          BoxShadow(
            color: _getAdaptiveShadowColor(cardBg),
            blurRadius: 14.r,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius.r),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: double.infinity,
            padding: padding ?? EdgeInsets.all(13.w),
            decoration: BoxDecoration(
              color: cardBg.withValues(alpha: isDark ? 0.92 : 0.88),
              borderRadius: BorderRadius.circular(radius.r),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF2C3545).withValues(alpha: 0.5)
                    : _SearchColors.border.withValues(alpha: 0.35),
                width: 0.8.w,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
    if (onTap == null) return card;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius.r),
      child: card,
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: Colors.white,
      side: const BorderSide(color: _SearchColors.border),
      visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 8.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999.r)),
      labelStyle: _SearchText.captionStrong(),
    );
  }
}

class _SmallTag extends StatelessWidget {
  const _SmallTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A3831) : _SearchColors.mint,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        label,
        style: _SearchText.captionStrong(context).copyWith(
          color: isDark ? const Color(0xFF33A88D) : _SearchColors.text,
        ),
      ),
    );
  }
}

class _CheckLine extends StatelessWidget {
  const _CheckLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.only(bottom: 7.h),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded,
              color: isDark ? const Color(0xFF33A88D) : _SearchColors.primary,
              size: 16.sp),
          SizedBox(width: 8.w),
          Expanded(child: Text(text, style: _SearchText.bodyStrong(context))),
        ],
      ),
    );
  }
}

class _RadioLine extends StatelessWidget {
  const _RadioLine({required this.text, this.selected = false});

  final String text;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: _SearchColors.primary,
              size: 17.sp),
          SizedBox(width: 8.w),
          Text(text, style: _SearchText.bodyStrong()),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 7.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: _SearchText.bodyStrong(context)),
          Expanded(child: Text(text, style: _SearchText.bodyStrong(context))),
        ],
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({
    this.icon,
    required this.color,
    this.svgAsset,
  });

  final IconData? icon;
  final Color color;
  final String? svgAsset;

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (svgAsset != null) {
      child = Padding(
        padding: EdgeInsets.all(10.w),
        child: SvgPicture.asset(
          svgAsset!,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          fit: BoxFit.contain,
        ),
      );
    } else {
      child = Icon(icon ?? Icons.help_outline, color: color, size: 22.sp);
    }

    return Container(
      width: 42.w,
      height: 42.w,
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(12.r)),
      alignment: Alignment.center,
      child: child,
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryBg = isDark ? const Color(0xFF33A88D) : _SearchColors.primary;
    return SizedBox(
      width: double.infinity,
      height: 46.h,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: primaryBg,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999.r)),
        ),
        child: Text(label),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? const Color(0xFF33A88D) : _SearchColors.primary;
    final borderColor = isDark ? const Color(0xFF2C3545) : _SearchColors.border;
    return SizedBox(
      width: double.infinity,
      height: 42.h,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: borderColor),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
        ),
        child: Text(label),
      ),
    );
  }
}
