import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/app/app_state.dart';
import 'package:lawapp/components/shared/mvp_state_widgets.dart';
import 'package:lawapp/data/legal_sources/legal_source_registry.dart';
import 'package:lawapp/theme/adaptive_layout.dart';
import 'package:lawapp/theme/app_colors.dart';
import 'package:lawapp/pages/profile/widgets/profile_widgets.dart';
import 'package:lawapp/pages/profile/widgets/profile_editor.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = LawAppScope.of(context);
    final canPop = Navigator.of(context).canPop();
    final topPadding = context.hasLargeTopInset ? context.topSafeInset + 10.h : 22.h;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final backgroundColor = isDark ? const Color(0xFF0F1216) : AppColors.background;
    final cardColor = isDark ? const Color(0xFF171C22) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2B3441) : AppColors.border;
    final textColor = isDark ? const Color(0xFFF2F4F7) : AppColors.textPrimary;
    final textMutedColor = isDark ? const Color(0xFFA3ABB6) : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          16.w, 
          topPadding, 
          16.w, 
          context.pageContentBottomPadding + 32.h
        ),
        children: [
          if (canPop) _BackButton(onBack: () => Navigator.of(context).pop()),
          
          // Header: 自訂個人頭像與狀態（大頭像居中排列，偏上方視覺）
          Container(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 24.h),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: borderColor),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000), 
                  blurRadius: 18, 
                  offset: Offset(0, 8),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 居中大尺寸自訂頭像，點擊開啟編輯器
                GestureDetector(
                  onTap: () => _showProfileEditorSheet(context, appState),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AvatarWidget(
                        avatarUrl: appState.currentUser.avatarUrl,
                        isSubscriber: appState.isSubscriber,
                        isGuest: appState.isGuest,
                        size: 88, // 放大頭像尺寸
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: cardColor, width: 1.5.w),
                          ),
                          child: Icon(
                            Icons.edit_rounded,
                            color: Colors.white,
                            size: 13.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 14.h),
                
                // 居中使用者名稱
                Text(
                  appState.isGuest ? '訪客個人中心' : appState.currentUser.displayName,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4.h),
                
                // 信箱或提示字
                Text(
                  appState.isGuest ? '點擊頭像編輯資料' : appState.currentUser.email,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: textMutedColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12.h),

                // 方案與額度膠囊 Badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: appState.isSubscriber 
                        ? AppColors.accent.withOpacity(0.12)
                        : AppColors.primary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(100.r),
                    border: Border.all(
                      color: appState.isSubscriber 
                          ? AppColors.accent 
                          : AppColors.primary.withOpacity(0.15),
                      width: 1.w,
                    ),
                  ),
                  child: Text(
                    '${appState.accessTier.label}方案 ｜ 今日 AI 額度：${appState.remainingAiQuota}',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: appState.isSubscriber ? AppColors.accent : AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 14.h),

          // Pro Upgrade Banner (只有在非 Pro 會員時顯示)
          if (!appState.isSubscriber) ...[
            ProUpgradeBanner(onTap: appState.activateSubscriberDemo),
            SizedBox(height: 14.h),
          ],

          // Dashboard 卡片 Grid (對接統計數據)
          _SectionTitle('我的資料'),
          SizedBox(height: 10.h),
          DashboardGrid(appState: appState),
          
          SizedBox(height: 20.h),

          // 設定與個人化 (Grouped List Style)
          GroupedSettingsList(
            title: '個人化與設定',
            tiles: [
              SettingsTile(
                icon: Icons.dark_mode_rounded,
                iconColor: Colors.purple,
                title: '深色模式',
                subtitle: '夜間查資料或讀案例時降低亮度',
                trailing: Switch.adaptive(
                  value: appState.isDarkMode,
                  onChanged: appState.setDarkMode,
                  activeColor: AppColors.accent,
                ),
              ),
              SettingsTile(
                icon: Icons.delete_sweep_rounded,
                iconColor: Colors.redAccent,
                title: '清除快取暫存',
                subtitle: '釋放本機暫存並優化 App 效能',
                onTap: () => _showClearCacheDialog(context),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // 關於與條款 (Grouped List Style)
          GroupedSettingsList(
            title: '支援與服務條款',
            tiles: [
              SettingsTile(
                icon: Icons.feedback_rounded,
                iconColor: Colors.blueAccent,
                title: '問題回報與建議',
                subtitle: '向團隊回饋系統程式錯誤或優化意見',
                onTap: () => _showFeedbackSheet(context, appState),
              ),
              SettingsTile(
                icon: Icons.source_rounded,
                iconColor: Colors.teal,
                title: '資料來源介接狀態',
                subtitle: '查看司法院、法務部等來源之同步狀態',
                onTap: () => _showSourcesSheet(context),
              ),
              SettingsTile(
                icon: Icons.gavel_rounded,
                iconColor: Colors.amber,
                title: '法律免責聲明',
                subtitle: '檢視產品之法律資訊與責任限制說明',
                onTap: () => _showDisclaimerSheet(context),
              ),
              SettingsTile(
                icon: Icons.info_outline_rounded,
                iconColor: Colors.grey,
                title: '版本資訊',
                trailing: Text(
                  'v1.0.0 (Build 42)',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: textMutedColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          // 開發者測試控制台
          _SectionTitle('測試控制台'),
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '身分切換與模擬',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  '此區塊為 Prototype 開發測試控制台，可用來展示不同權限層級的 UI 表現，不代表正式線上登入。',
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    height: 1.45,
                    color: textMutedColor,
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    if (appState.isGuest) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: appState.signInDemo,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: borderColor),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                          ),
                          child: const Text('登入 Demo 會員'),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: FilledButton(
                          onPressed: appState.activateSubscriberDemo,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                          ),
                          child: const Text('啟用 Pro Demo'),
                        ),
                      ),
                    ] else ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: appState.signOut,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            side: const BorderSide(color: Colors.redAccent),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                          ),
                          child: const Text('登出並回到訪客'),
                        ),
                      ),
                      if (appState.accessTier != LawAppAccessTier.subscriber) ...[
                        SizedBox(width: 8.w),
                        Expanded(
                          child: FilledButton(
                            onPressed: appState.activateSubscriberDemo,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                            ),
                            child: const Text('啟用 Pro Demo'),
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showProfileEditorSheet(BuildContext context, LawAppState appState) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProfileEditorSheet(appState: appState),
    );
  }

  void _showFeedbackSheet(BuildContext context, LawAppState appState) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FeedbackSheet(appState: appState),
    );
  }

  void _showDisclaimerSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Padding(
          padding: EdgeInsets.all(16.w),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF171C22) : Colors.white,
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: isDark ? const Color(0xFF2B3441) : AppColors.border),
            ),
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.gavel_rounded, color: AppColors.accent, size: 36.sp),
                SizedBox(height: 12.h),
                Text(
                  '法律免責聲明',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                    color: isDark ? const Color(0xFFF2F4F7) : AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 12.h),
                const LegalDisclaimerBox(),
                SizedBox(height: 20.h),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: const Text('關閉'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSourcesSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final textColor = isDark ? const Color(0xFFF2F4F7) : AppColors.textPrimary;
        final borderStyle = BorderSide(color: isDark ? const Color(0xFF2B3441) : AppColors.border);

        return Padding(
          padding: EdgeInsets.all(16.w),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF171C22) : Colors.white,
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: isDark ? const Color(0xFF2B3441) : AppColors.border),
            ),
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '資料來源介接狀態',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 220.h),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: legalSourceEntries.length,
                    separatorBuilder: (_, __) => Divider(height: 10.h, color: Colors.transparent),
                    itemBuilder: (context, index) {
                      final source = legalSourceEntries[index];
                      Color getStatusColor(LegalSourceStatus status) {
                        switch (status) {
                          case LegalSourceStatus.connected:
                            return Colors.green;
                          case LegalSourceStatus.credentialRequired:
                            return Colors.orange;
                          case LegalSourceStatus.planned:
                            return Colors.blue;
                        }
                      }

                      final statusColor = getStatusColor(source.status);

                      return Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F1216) : const Color(0xFFFAF7F2),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: isDark ? const Color(0xFF2B3441) : AppColors.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              source.title,
                              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: textColor),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                source.statusLabel,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: const Text('關閉'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final surfaceColor = isDark ? const Color(0xFF171C22) : Colors.white;
        final textStyle = TextStyle(
          fontSize: 14.sp,
          color: isDark ? const Color(0xFFA3ABB6) : AppColors.textSecondary,
        );

        return AlertDialog(
          backgroundColor: surfaceColor,
          title: Text(
            '清除快取暫存',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w900,
              color: isDark ? const Color(0xFFF2F4F7) : AppColors.textPrimary,
            ),
          ),
          content: Text('這將會清除您本機的圖片與離線法規暫存，需要重新連網下載。是否確定清除？', style: textStyle),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('快取清除成功！'),
                    backgroundColor: Color(0xFF2E7D32),
                  ),
                );
              },
              child: const Text('確認清除', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        onPressed: onBack,
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFFF2F4F7)
            : AppColors.textPrimary,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w900,
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFFF2F4F7)
            : AppColors.textPrimary,
      ),
    );
  }
}
