part of '../following_page.dart';

class _TopHeaderBar extends StatelessWidget {
  const _TopHeaderBar({
    required this.title,
    required this.subtitle,
    required this.showBack,
    required this.onBack,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final bool showBack;
  final VoidCallback onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (showBack) ...[
          InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(99.r),
            child: Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                color: t.surface,
                shape: BoxShape.circle,
                border: Border.all(color: t.border),
              ),
              child: Icon(
                PhosphorIconsRegular.arrowLeft,
                size: 18.sp,
                color: t.textPrimary,
              ),
            ),
          ),
          SizedBox(width: 12.w),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: t.serifTitle(size: 19.sp),
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: t.sansBody(size: 12.sp, color: t.textSecondary),
              ),
            ],
          ),
        ),
        if (trailing != null) ...[
          SizedBox(width: 8.w),
          trailing!,
        ],
      ],
    );
  }
}

class _FollowSectionTabBar extends StatelessWidget {
  const _FollowSectionTabBar({
    required this.activeSection,
    required this.counts,
    required this.onChanged,
  });

  final _FollowingSection activeSection;
  final Map<_FollowingSection, int> counts;
  final ValueChanged<_FollowingSection> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          for (final section in _FollowingSection.values) ...[
            _buildTabPill(context, t, section),
            if (section != _FollowingSection.values.last) SizedBox(width: 8.w),
          ],
        ],
      ),
    );
  }

  Widget _buildTabPill(
    BuildContext context,
    PreambleTokens t,
    _FollowingSection section,
  ) {
    final active = section == activeSection;
    final count = counts[section] ?? 0;

    return InkWell(
      onTap: () => onChanged(section),
      borderRadius: BorderRadius.circular(99.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: active ? t.brandPrimaryStrong : t.surface,
          borderRadius: BorderRadius.circular(99.r),
          border: Border.all(
            color: active ? t.brandPrimaryStrong : t.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              section.icon,
              size: 15.sp,
              color: active ? const Color(0xFFFAF8F4) : t.textSecondary,
            ),
            SizedBox(width: 6.w),
            Text(
              section.label,
              style: t.sansBody(
                size: 12.5.sp,
                weight: FontWeight.w700,
                color: active ? const Color(0xFFFAF8F4) : t.textPrimary,
              ),
            ),
            if (count > 0) ...[
              SizedBox(width: 6.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
                decoration: BoxDecoration(
                  color: active
                      ? Colors.white.withValues(alpha: 0.18)
                      : t.surfaceSubtle,
                  borderRadius: BorderRadius.circular(99.r),
                ),
                child: Text(
                  '$count',
                  style: t.tabularMetric(
                    size: 10.5.sp,
                    color: active ? const Color(0xFFFAF8F4) : t.textSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FollowFilterChips extends StatelessWidget {
  const _FollowFilterChips({
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(labels.length, (i) {
          final active = i == selectedIndex;
          return Padding(
            padding: EdgeInsets.only(right: i == labels.length - 1 ? 0 : 8.w),
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                onChanged(i);
              },
              borderRadius: BorderRadius.circular(10.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.5.h),
                decoration: BoxDecoration(
                  color: active ? t.brandContainer : t.surface,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: active ? t.brandPrimary : t.border,
                  ),
                ),
                child: Text(
                  labels[i],
                  style: t.sansBody(
                    size: 12.sp,
                    weight: active ? FontWeight.w700 : FontWeight.w500,
                    color: active ? t.brandOnContainer : t.textSecondary,
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

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({
    required this.label,
    required this.color,
    required this.bgColor,
    this.icon,
  });

  final String label;
  final Color color;
  final Color bgColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.5.w, vertical: 3.5.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(7.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12.sp, color: color),
            SizedBox(width: 4.w),
          ],
          Text(
            label,
            style: t.sansBody(
              size: 11.sp,
              weight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _FollowActionChip extends StatelessWidget {
  const _FollowActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(99.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: t.brandPrimaryStrong,
          borderRadius: BorderRadius.circular(99.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14.sp, color: const Color(0xFFFAF8F4)),
            SizedBox(width: 4.w),
            Text(
              label,
              style: t.sansBody(
                size: 12.sp,
                weight: FontWeight.w700,
                color: const Color(0xFFFAF8F4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuietEmptyCard extends StatelessWidget {
  const _QuietEmptyCard({
    required this.icon,
    required this.title,
    required this.description,
    this.primaryLabel,
    this.onPrimaryTap,
    this.secondaryLabel,
    this.onSecondaryTap,
    this.helperLabel,
    this.onHelperTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final String? primaryLabel;
  final VoidCallback? onPrimaryTap;
  final String? secondaryLabel;
  final VoidCallback? onSecondaryTap;
  final String? helperLabel;
  final VoidCallback? onHelperTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      decoration: t.cardDecoration(radius: 20.r),
      child: Column(
        children: [
          Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              color: t.brandContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 24.sp, color: t.brandPrimary),
          ),
          SizedBox(height: 14.h),
          Text(
            title,
            style: t.serifTitle(size: 16.5.sp),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6.h),
          Text(
            description,
            style: t.sansBody(size: 12.5.sp, color: t.textSecondary),
            textAlign: TextAlign.center,
          ),
          if (primaryLabel != null && onPrimaryTap != null) ...[
            SizedBox(height: 16.h),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10.w,
              runSpacing: 8.h,
              children: [
                FilledButton.icon(
                  onPressed: onPrimaryTap,
                  style: FilledButton.styleFrom(
                    backgroundColor: t.brandPrimaryStrong,
                    foregroundColor: const Color(0xFFFAF8F4),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 10.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  icon: Icon(PhosphorIconsRegular.compass, size: 16.sp),
                  label: Text(primaryLabel!),
                ),
                if (secondaryLabel != null && onSecondaryTap != null)
                  OutlinedButton.icon(
                    onPressed: onSecondaryTap,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: t.brandPrimary,
                      side: BorderSide(color: t.borderStrong),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 10.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    icon: Icon(PhosphorIconsRegular.bookOpenText, size: 16.sp),
                    label: Text(secondaryLabel!),
                  ),
              ],
            ),
          ],
          if (helperLabel != null && onHelperTap != null) ...[
            SizedBox(height: 10.h),
            TextButton.icon(
              onPressed: onHelperTap,
              icon: Icon(
                PhosphorIconsRegular.sparkle,
                size: 14.sp,
                color: t.accentBrass,
              ),
              label: Text(
                helperLabel!,
                style: t.sansBody(
                  size: 12.sp,
                  weight: FontWeight.w600,
                  color: t.accentBrass,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
