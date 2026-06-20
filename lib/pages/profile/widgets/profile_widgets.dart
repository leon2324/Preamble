import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/app/app_state.dart';
import 'package:lawapp/theme/app_colors.dart';
import 'profile_editor.dart';

/// 專屬頭像組件，支援訪客、會員與 Pro 訂閱者特效。
class AvatarWidget extends StatelessWidget {
  const AvatarWidget({
    super.key,
    required this.avatarUrl,
    required this.isSubscriber,
    required this.isGuest,
    this.size = 64,
  });

  final String? avatarUrl;
  final bool isSubscriber;
  final bool isGuest;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF171C22) : Colors.white;
    final avatar = isGuest ? null : getAvatarById(avatarUrl);

    Widget avatarCore = Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        color: isGuest
            ? (isDark ? const Color(0xFF2B3441) : AppColors.chipSurface)
            : avatar!.backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(color: isDark ? const Color(0xFF2B3441) : AppColors.border, width: 1.w),
      ),
      child: Center(
        child: Icon(
          isGuest
              ? Icons.person_rounded
              : avatar!.icon,
          color: isGuest
              ? (isDark ? const Color(0xFFA3ABB6) : AppColors.textSecondary)
              : avatar!.color,
          size: (size * 0.52).sp,
        ),
      ),
    );

    if (isSubscriber) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.accent, width: 2.w),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 1.5,
                )
              ],
            ),
            child: avatarCore,
          ),
          Positioned(
            bottom: -2.h,
            right: -2.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(color: surfaceColor, width: 1.5.w),
              ),
              child: Text(
                'PRO',
                style: TextStyle(
                  fontSize: 8.5.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return avatarCore;
  }
}

/// 儀表板 2x2 對稱卡片網格與下方 AI 提問紀錄 Banner。
class DashboardGrid extends StatelessWidget {
  const DashboardGrid({super.key, required this.appState});

  final LawAppState appState;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF171C22) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2B3441) : AppColors.border;
    final textMuted = isDark ? const Color(0xFFA3ABB6) : AppColors.textSecondary;

    // 台灣繁體中文教學註解：計算使用者追蹤的總項目數量（加總案件、法條與主題的追蹤數）
    final following = appState.followingSummary;
    final followedCount = following.followedCaseIds.length +
        following.followedStatuteIds.length +
        following.followedTopicIds.length;

    // 台灣繁體中文教學註解：建立 4 個儀表板主要資料項目，分別對接 AppState 裡的真實筆數
    final items = [
      _DashboardItemData(
        title: '我的收藏',
        value: '${appState.savedCaseIds.length} 筆',
        icon: Icons.bookmark_rounded,
        color: AppColors.primary,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (__) => const Scaffold(
                body: Center(child: Text('我的收藏 (此路徑原對接 FollowingPage)')),
              ),
            ),
          );
        },
      ),
      _DashboardItemData(
        title: '我的追蹤',
        value: '$followedCount 筆',
        icon: Icons.notifications_active_rounded,
        color: const Color(0xFF3F51B5),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (__) => const Scaffold(
                body: Center(child: Text('我的追蹤 (此路徑原對接 FollowingPage)')),
              ),
            ),
          );
        },
      ),
      _DashboardItemData(
        title: '我的筆記',
        value: '${appState.caseNoteDrafts.length} 筆',
        icon: Icons.note_alt_rounded,
        color: const Color(0xFF2E7D32),
        onTap: () {
          _showMockSheet(context, '我的筆記', '本機有 ${appState.caseNoteDrafts.length} 筆案件筆記。雲端同步功能正在對接中。');
        },
      ),
      _DashboardItemData(
        title: '文件草稿',
        value: '${appState.documentRepository.drafts.length} 份',
        icon: Icons.description_rounded,
        color: const Color(0xFFC96B3B),
        onTap: () {
          _showMockSheet(context, '文件草稿', '本機有 ${appState.documentRepository.drafts.length} 份文件草稿。雲端儲存庫將在下個版本推出。');
        },
      ),
    ];

    final cardWidth = (MediaQuery.sizeOf(context).width - 42.w) / 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 2x2 雙欄卡片網格佈局 (2x2 Grid)
        Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: items.map((item) {
            return SizedBox(
              width: cardWidth,
              child: InkWell(
                onTap: item.onTap,
                borderRadius: BorderRadius.circular(20.r),
                child: Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: item.color.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(item.icon, color: item.color, size: 20.sp),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w900,
                          color: isDark ? const Color(0xFFF2F4F7) : AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        item.value,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 10.h),
        // 小法助提問紀錄橫幅，供使用者一鍵進入對答歷史 (AI Chat History Horizontal Banner)
        InkWell(
          onTap: () {
            _showMockSheet(
              context,
              '小法助對答歷史',
              appState.isGuest
                  ? '訪客帳戶對話未同步。請登入以雲端保存對答紀錄。'
                  : '目前本地模擬對話紀錄已存檔，實時後端雲端對話同步即將推出。',
            );
          },
          borderRadius: BorderRadius.circular(20.r),
          child: Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.smart_toy_rounded, color: AppColors.accent, size: 22.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '小法助提問紀錄',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w900,
                          color: isDark ? const Color(0xFFF2F4F7) : AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        appState.isGuest ? '訪客對答未同步' : '點擊檢視與 AI 助手的歷史諮詢',
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          color: textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: isDark ? const Color(0xFF556070) : AppColors.placeholder,
                  size: 14.sp,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showMockSheet(BuildContext context, String title, String message) {
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
                Icon(Icons.folder_open_rounded, color: AppColors.accent, size: 40.sp),
                SizedBox(height: 12.h),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                    color: isDark ? const Color(0xFFF2F4F7) : AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: isDark ? const Color(0xFFA3ABB6) : AppColors.textSecondary,
                    height: 1.45,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20.h),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: const Text('我知道了'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DashboardItemData {
  _DashboardItemData({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
}

/// 精美金屬漸層 Pro 升級 Banner。
class ProUpgradeBanner extends StatelessWidget {
  const ProUpgradeBanner({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E2F50), Color(0xFF131D33)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          )
        ],
      ),
      child: Stack(
        children: [
          // 裝飾用背景圓形發光特效 (Background decorative glow)
          Positioned(
            right: -20.w,
            top: -20.h,
            child: Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.12),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.12),
                    blurRadius: 40,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(18.w),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.workspace_premium_rounded, color: AppColors.accent, size: 20.sp),
                          SizedBox(width: 6.w),
                          Text(
                            '解鎖 LawApp Pro',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFFFAF7F2),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        '享案件卷宗、高級小法助額度、文件匯出與追蹤提醒。',
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          color: const Color(0xFFCED5E0),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10.w),
                ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: const Color(0xFF1E2F50),
                    elevation: 0,
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  child: Text(
                    '暸解更多',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 群組化設定列表組件。
class GroupedSettingsList extends StatelessWidget {
  const GroupedSettingsList({
    super.key,
    required this.title,
    required this.tiles,
  });

  final String title;
  final List<SettingsTile> tiles;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final containerColor = isDark ? const Color(0xFF171C22) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2B3441) : AppColors.border;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFFA3ABB6) : AppColors.textSecondary,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: List.generate(tiles.length, (index) {
              final tile = tiles[index];
              final isLast = index == tiles.length - 1;
              return Column(
                children: [
                  tile,
                  if (!isLast)
                    Divider(
                      height: 1.h,
                      thickness: 0.8.h,
                      color: borderColor.withOpacity(0.7),
                      indent: 48.w, // 與標題對齊的縮排 (Align with title)
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

/// 個別設定項目。
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textMuted = isDark ? const Color(0xFFA3ABB6) : AppColors.textSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(7.w),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 18.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: isDark ? const Color(0xFFF2F4F7) : AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else if (onTap != null)
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: isDark ? const Color(0xFF556070) : AppColors.placeholder,
                size: 13.sp,
              ),
          ],
        ),
      ),
    );
  }
}

/// 反饋/問題回報 Bottom Sheet。
class FeedbackSheet extends StatefulWidget {
  const FeedbackSheet({super.key, required this.appState});

  final LawAppState appState;

  @override
  State<FeedbackSheet> createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends State<FeedbackSheet> {
  final _feedbackController = TextEditingController();
  final _emailController = TextEditingController();
  String _category = '功能建議';
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.appState.currentUser.email;
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF171C22) : Colors.white;
    final borderSide = BorderSide(color: isDark ? const Color(0xFF2B3441) : AppColors.border);

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, MediaQuery.viewInsetsOf(context).bottom + 24.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 頂部拖曳指示條 (Drag handle)
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
            '問題回報與意見反饋',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w900,
              color: isDark ? const Color(0xFFF2F4F7) : AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20.h),

          // 反饋類型選擇按鈕組 (Category Selector)
          Text('反饋類型', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFFA3ABB6) : AppColors.textSecondary)),
          SizedBox(height: 6.h),
          Row(
            children: ['功能建議', '內容錯誤', '程式錯誤', '其他'].map((cat) {
              final isSelected = _category == cat;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  child: InkWell(
                    onTap: () => setState(() => _category = cat),
                    borderRadius: BorderRadius.circular(8.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : (isDark ? const Color(0xFF0F1216) : const Color(0xFFFAF7F2)),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : (isDark ? const Color(0xFF2B3441) : AppColors.border),
                        ),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? const Color(0xFFF2F4F7) : AppColors.textPrimary),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 16.h),

          // 聯絡信箱輸入欄位 (Email Field)
          Text('您的聯絡信箱 (選填)', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFFA3ABB6) : AppColors.textSecondary)),
          SizedBox(height: 6.h),
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              hintText: '請輸入信箱以利回覆',
              contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              filled: true,
              fillColor: isDark ? const Color(0xFF0F1216) : const Color(0xFFFAF7F2),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: borderSide,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppColors.accent, width: 1.5),
              ),
            ),
            style: TextStyle(fontSize: 13.5.sp, color: isDark ? const Color(0xFFF2F4F7) : AppColors.textPrimary),
          ),
          SizedBox(height: 16.h),

          // 反饋內容描述輸入欄位 (Content Field)
          Text('描述與建議', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFFA3ABB6) : AppColors.textSecondary)),
          SizedBox(height: 6.h),
          TextField(
            controller: _feedbackController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: '請詳細描述您遇到的問題或給予的指教...',
              contentPadding: EdgeInsets.all(14.w),
              filled: true,
              fillColor: isDark ? const Color(0xFF0F1216) : const Color(0xFFFAF7F2),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: borderSide,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppColors.accent, width: 1.5),
              ),
            ),
            style: TextStyle(fontSize: 13.5.sp, color: isDark ? const Color(0xFFF2F4F7) : AppColors.textPrimary),
          ),
          SizedBox(height: 20.h),

          // 底部操作按鈕（取消與提交） (Actions)
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSending ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    side: borderSide,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                  ),
                  child: Text('取消', style: TextStyle(fontSize: 14.sp, color: isDark ? const Color(0xFFA3ABB6) : AppColors.textSecondary)),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: FilledButton(
                  onPressed: _isSending ? null : _submitFeedback,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                  ),
                  child: _isSending
                      ? SizedBox(
                          width: 18.w,
                          height: 18.w,
                          child: const CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : Text('提交', style: TextStyle(fontSize: 14.sp, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _submitFeedback() async {
    final content = _feedbackController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請填寫回饋內容！'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() => _isSending = true);

    // 模擬網路傳輸延遲約 1 秒，提供真實載入感 (模擬網路延遲 1 秒)
    await Future<void>.delayed(const Duration(milliseconds: 900));

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('感謝回報！我們會盡快處理「$_category」問題。'),
          backgroundColor: const Color(0xFF2E7D32),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
