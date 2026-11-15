import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:preamble/app/app_state.dart';
import 'package:preamble/components/shared/custom_toast.dart';
import 'package:preamble/theme/preamble_tokens.dart';

class AccountSecuritySheet extends StatefulWidget {
  const AccountSecuritySheet({super.key, required this.appState});

  final PreambleState appState;

  @override
  State<AccountSecuritySheet> createState() => _AccountSecuritySheetState();
}

class _AccountSecuritySheetState extends State<AccountSecuritySheet> {
  bool _isGoogleLinked = true;
  bool _isAppleLinked = false;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return Container(
      decoration: BoxDecoration(
        color: t.surfaceElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        border: Border.all(color: t.border),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 38.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: t.borderStrong,
                    borderRadius: BorderRadius.circular(99.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                '帳號與資料安全管理',
                style: t.serifTitle(size: 17.sp),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.h),

              Text(
                '第三方登入綁定狀態',
                style: t.sansBody(
                  size: 12.sp,
                  weight: FontWeight.w700,
                  color: t.textSecondary,
                ),
              ),
              SizedBox(height: 8.h),
              _buildLinkTile(
                context,
                label: 'Google 帳號',
                icon: PhosphorIconsRegular.globe,
                isLinked: _isGoogleLinked,
                onChanged: (val) {
                  setState(() => _isGoogleLinked = val);
                  CustomToast.show(
                    context,
                    'Google 帳號${val ? "連結成功" : "已解除連結"}',
                    icon: PhosphorIconsRegular.link,
                  );
                },
              ),
              SizedBox(height: 8.h),
              _buildLinkTile(
                context,
                label: 'Apple 帳號',
                icon: PhosphorIconsRegular.deviceMobile,
                isLinked: _isAppleLinked,
                onChanged: (val) {
                  setState(() => _isAppleLinked = val);
                  CustomToast.show(
                    context,
                    'Apple 帳號${val ? "連結成功" : "已解除連結"}',
                    icon: PhosphorIconsRegular.link,
                  );
                },
              ),
              SizedBox(height: 20.h),

              Text(
                '密碼安全',
                style: t.sansBody(
                  size: 12.sp,
                  weight: FontWeight.w700,
                  color: t.textSecondary,
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                decoration: t.subtleBoxDecoration(radius: 14.r),
                child: ListTile(
                  leading: Icon(
                    PhosphorIconsRegular.key,
                    color: t.brandPrimary,
                    size: 20.sp,
                  ),
                  title: Text('重設登入密碼', style: t.sansTitle(size: 14.sp)),
                  subtitle: Text(
                    '更新您用於登入 緒言 Preamble 的獨立密碼',
                    style: t.sansBody(size: 11.5.sp, color: t.textSecondary),
                  ),
                  trailing: Icon(
                    PhosphorIconsRegular.caretRight,
                    size: 15.sp,
                    color: t.textMuted,
                  ),
                  onTap: _showResetPasswordDialog,
                ),
              ),
              SizedBox(height: 22.h),

              Text(
                '進階帳號處置',
                style: t.sansBody(
                  size: 12.sp,
                  weight: FontWeight.w700,
                  color: t.semanticUrgent,
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                decoration: BoxDecoration(
                  color: t.semanticUrgentContainer,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: t.semanticUrgent.withValues(alpha: 0.4),
                  ),
                ),
                child: ListTile(
                  leading: Icon(
                    PhosphorIconsRegular.trash,
                    color: t.semanticUrgent,
                    size: 20.sp,
                  ),
                  title: Text(
                    '清除帳號與回復訪客狀態',
                    style: t.sansTitle(size: 14.sp, color: t.semanticUrgent),
                  ),
                  subtitle: Text(
                    '登出目前身分並清除帳號授權狀態',
                    style: t.sansBody(size: 11.5.sp, color: t.textSecondary),
                  ),
                  trailing: Icon(
                    PhosphorIconsRegular.caretRight,
                    color: t.semanticUrgent,
                    size: 15.sp,
                  ),
                  onTap: _showDeleteAccountDialog,
                ),
              ),
              SizedBox(height: 22.h),

              FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  backgroundColor: t.brandPrimaryStrong,
                  foregroundColor: const Color(0xFFFAF8F4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                child: const Text('關閉'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLinkTile(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool isLinked,
    required ValueChanged<bool> onChanged,
  }) {
    final t = context.tokens;

    return Container(
      decoration: t.subtleBoxDecoration(radius: 14.r),
      child: ListTile(
        leading: Icon(
          icon,
          color: isLinked ? t.brandPrimary : t.textMuted,
          size: 22.sp,
        ),
        title: Text(label, style: t.sansTitle(size: 14.sp)),
        subtitle: Text(
          isLinked ? '已連結' : '未連結',
          style: t.sansBody(size: 11.5.sp, color: t.textSecondary),
        ),
        trailing: Switch.adaptive(
          value: isLinked,
          activeThumbColor: t.brandPrimary,
          onChanged: onChanged,
        ),
      ),
    );
  }

  void _showResetPasswordDialog() {
    final controller = TextEditingController();
    final t = context.tokens;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: t.surfaceElevated,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
            side: BorderSide(color: t.border),
          ),
          title: Text('重設密碼', style: t.serifTitle(size: 16.5.sp)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '請輸入新的登入密碼（至少 6 字元）：',
                style: t.sansBody(size: 13.sp, color: t.textSecondary),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: controller,
                obscureText: true,
                style: t.sansBody(size: 14.sp, color: t.textPrimary),
                decoration: InputDecoration(
                  labelText: '新密碼',
                  filled: true,
                  fillColor: t.surfaceSubtle,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () {
                final pw = controller.text.trim();
                if (pw.length < 6) {
                  CustomToast.show(
                    context,
                    '密碼長度需至少 6 字元',
                    icon: PhosphorIconsRegular.warningCircle,
                  );
                  return;
                }
                Navigator.pop(dialogContext);
                CustomToast.show(
                  context,
                  '密碼已更新',
                  icon: PhosphorIconsFill.checkCircle,
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: t.brandPrimaryStrong,
                foregroundColor: const Color(0xFFFAF8F4),
              ),
              child: const Text('確定變更'),
            ),
          ],
        );
      },
    ).whenComplete(controller.dispose);
  }

  void _showDeleteAccountDialog() {
    final t = context.tokens;
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: t.surfaceElevated,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
            side: BorderSide(color: t.border),
          ),
          title: Row(
            children: [
              Icon(
                PhosphorIconsRegular.warning,
                color: t.semanticUrgent,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  '確認清除帳號授權',
                  style: t.serifTitle(size: 16.sp, color: t.semanticUrgent),
                ),
              ),
            ],
          ),
          content: Text(
            '確定要清除目前帳號狀態並回復為訪客身分嗎？操作後需重新登入方可恢復會員狀態。',
            style: t.sansBody(size: 13.sp, color: t.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pop(context);
                widget.appState.signOut();
                CustomToast.show(
                  context,
                  '已清除帳號狀態並回復訪客身分',
                  icon: PhosphorIconsRegular.info,
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: t.semanticUrgent,
                foregroundColor: Colors.white,
              ),
              child: const Text('確定清除'),
            ),
          ],
        );
      },
    );
  }
}
