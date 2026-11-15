part of '../global_search_page.dart';

// 靜奢律政編輯風 Bottom Sheet 動作選單元件。
// 完全採用 PreambleTokens 動態語意色票，確保淺深色對比清晰一致。

class _SearchActionSheet extends StatelessWidget {
  const _SearchActionSheet({
    required this.title,
    required this.message,
    required this.actions,
  });

  final String title;
  final String message;
  final List<_SheetAction> actions;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        child: Container(
          padding: EdgeInsets.all(18.w),
          decoration: t.cardDecoration(
            radius: 22.r,
            fill: t.surfaceElevated,
            borderColor: t.borderStrong,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: t.borderStrong,
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                  ),
                ),
                SizedBox(height: 14.h),
                Text(title, style: _SearchText.serifSection(context)),
                SizedBox(height: 6.h),
                Text(message, style: _SearchText.body(context)),
                SizedBox(height: 14.h),
                for (final action in actions) ...[
                  _SheetActionTile(action: action),
                  SizedBox(height: 8.h),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetActionTile extends StatelessWidget {
  const _SheetActionTile({required this.action});

  final _SheetAction action;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return _ProtoCard(
      onTap: action.onTap,
      background: t.surfaceSubtle,
      elevated: false,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      child: Row(
        children: [
          _IconBox(
            icon: action.icon,
            color: t.brandPrimary,
            backgroundColor: t.brandContainer,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(action.title, style: _SearchText.tileTitle(context)),
                SizedBox(height: 3.h),
                Text(action.subtitle, style: _SearchText.caption(context)),
              ],
            ),
          ),
          Icon(
            PhosphorIconsRegular.caretRight,
            color: t.textMuted,
            size: 16.sp,
          ),
        ],
      ),
    );
  }
}

class _SheetAction {
  const _SheetAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
}
