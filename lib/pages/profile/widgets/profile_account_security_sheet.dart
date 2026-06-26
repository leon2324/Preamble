import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/app/app_state.dart';
import 'package:preamble/theme/app_colors.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF171C22) : Colors.white;
    final borderSide =
        BorderSide(color: isDark ? const Color(0xFF2B3441) : AppColors.border);
    final textMuted =
        isDark ? const Color(0xFFA3ABB6) : AppColors.textSecondary;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2B3441) : AppColors.border,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              '帳號與安全管理',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w900,
                color: isDark ? const Color(0xFFF2F4F7) : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),

            // 帳號綁定模擬
            Text('第三方帳號綁定',
                style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: textMuted)),
            SizedBox(height: 8.h),
            _buildLinkTile(
              label: 'Google 帳號',
              icon: Icons.g_mobiledata_rounded,
              isLinked: _isGoogleLinked,
              onChanged: (val) {
                setState(() => _isGoogleLinked = val);
                _showSnackBar('Google 帳號${val ? "連結成功" : "已解除連結"}');
              },
            ),
            SizedBox(height: 8.h),
            _buildLinkTile(
              label: 'Apple 帳號',
              icon: Icons.apple_rounded,
              isLinked: _isAppleLinked,
              onChanged: (val) {
                setState(() => _isAppleLinked = val);
                _showSnackBar('Apple 帳號${val ? "連結成功" : "已解除連結"}');
              },
            ),
            SizedBox(height: 20.h),

            // 重設密碼
            Text('密碼安全',
                style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: textMuted)),
            SizedBox(height: 8.h),
            ListTile(
              leading: Icon(Icons.lock_reset_rounded,
                  color: AppColors.primary, size: 22.sp),
              title: const Text('重設登入密碼',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('更換您用於登入 緒言 Preamble 的獨立密碼'),
              trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14.sp),
              tileColor:
                  isDark ? const Color(0xFF0F1216) : const Color(0xFFFAF7F2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
                side: borderSide,
              ),
              onTap: _showResetPasswordDialog,
            ),
            SizedBox(height: 24.h),

            // 刪除帳號（危險區域）
            Text('危險區域',
                style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent)),
            SizedBox(height: 8.h),
            ListTile(
              leading: Icon(Icons.delete_forever_rounded,
                  color: Colors.redAccent, size: 22.sp),
              title: const Text('永久刪除帳號',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.redAccent)),
              subtitle: const Text('刪除後所有收藏、追蹤與筆記紀錄皆無法復原'),
              trailing: Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.redAccent, size: 14.sp),
              tileColor:
                  isDark ? const Color(0x11FF5252) : const Color(0xFFFFF1F1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
                side: const BorderSide(color: Colors.redAccent, width: 0.8),
              ),
              onTap: _showDeleteAccountDialog,
            ),
            SizedBox(height: 24.h),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                child: const Text('關閉'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkTile({
    required String label,
    required IconData icon,
    required bool isLinked,
    required ValueChanged<bool> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderSide =
        BorderSide(color: isDark ? const Color(0xFF2B3441) : AppColors.border);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F1216) : const Color(0xFFFAF7F2),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: borderSide.color),
      ),
      child: ListTile(
        leading: Icon(icon,
            color: isLinked ? AppColors.accent : Colors.grey, size: 26.sp),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(isLinked ? '已連結' : '未連結'),
        trailing: Switch(
          value: isLinked,
          activeThumbColor: AppColors.accent,
          onChanged: onChanged,
        ),
      ),
    );
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFF2E7D32),
      ),
    );
  }

  void _showResetPasswordDialog() {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
              const Text('重設密碼', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('請輸入新的登入密碼：'),
              SizedBox(height: 12.h),
              TextField(
                controller: controller,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '新密碼',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                final pw = controller.text.trim();
                if (pw.length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('密碼長度需至少 6 字元！'),
                        backgroundColor: Colors.redAccent),
                  );
                  return;
                }
                Navigator.pop(context);
                _showSnackBar('密碼變更成功！');
              },
              child: const Text('確定變更',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('⚠️ 高危警示：刪除帳號',
              style: TextStyle(
                  color: Colors.redAccent, fontWeight: FontWeight.bold)),
          content: const Text(
              '您確定要永久刪除此帳號嗎？刪除後，您將被登出，並且所有的儲存、追蹤及筆記資料將被徹底清除，此操作無法復原。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 關閉對話框
                Navigator.pop(context); // 關閉 Bottom Sheet
                widget.appState.signOut(); // 執行登出（回復訪客狀態）
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('帳號已刪除，已為您回復訪客身分！'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              },
              child: const Text('確定刪除',
                  style: TextStyle(
                      color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
