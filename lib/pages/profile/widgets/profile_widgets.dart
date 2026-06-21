import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/app/app_state.dart';
import 'package:lawapp/theme/app_colors.dart';
import 'package:lawapp/pages/following/following_page.dart';
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
              builder: (__) => const FollowingPage(initialTab: 'collections'),
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
              builder: (__) => const FollowingPage(initialTab: 'tabs'),
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
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (__) => const FollowingPage(initialTab: 'notes'),
            ),
          );
        },
      ),
      _DashboardItemData(
        title: '文件草稿',
        value: '${appState.documentRepository.drafts.length} 份',
        icon: Icons.description_rounded,
        color: const Color(0xFFC96B3B),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (__) => const FollowingPage(initialTab: 'drafts'),
            ),
          );
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
                          color: item.color.withValues(alpha: 0.08),
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
                    color: AppColors.accent.withValues(alpha: 0.08),
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
                color: AppColors.accent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.12),
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
                      color: borderColor.withValues(alpha: 0.7),
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
                color: iconColor.withValues(alpha: 0.08),
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

// 台灣繁體中文教學註解：
// 以下為新增的個人中心功能擴充元件。
// 包含學習成就歷程橫幅、成就室底頁、通知微調設定、以及帳號與安全模擬對話框。

class LearningProgressBanner extends StatelessWidget {
  const LearningProgressBanner({super.key, required this.appState});

  final LawAppState appState;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF171C22) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2B3441) : AppColors.border;
    final textMuted = isDark ? const Color(0xFFA3ABB6) : AppColors.textSecondary;

    final savedStatuteCount = appState.followingSummary.savedStatuteIds.length;
    
    // 根據追蹤法條數計算等級
    String levelName = '法學小白 🐣';
    if (savedStatuteCount >= 1 && savedStatuteCount <= 2) {
      levelName = '法學初學者 🔍';
    } else if (savedStatuteCount >= 3) {
      levelName = '法學進修者 🏛️';
    }

    return InkWell(
      onTap: () {
        showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => AchievementRoomSheet(appState: appState),
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
                color: const Color(0xFFD6A85F).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.workspace_premium_rounded, color: const Color(0xFFD6A85F), size: 22.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '我的學習歷程',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w900,
                      color: isDark ? const Color(0xFFF2F4F7) : AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '等級：$levelName (已收藏 $savedStatuteCount 條法規)',
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
    );
  }
}

class AchievementRoomSheet extends StatelessWidget {
  const AchievementRoomSheet({super.key, required this.appState});

  final LawAppState appState;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF171C22) : Colors.white;
    final textMuted = isDark ? const Color(0xFFA3ABB6) : AppColors.textSecondary;

    final savedStatuteCount = appState.followingSummary.savedStatuteIds.length;
    final savedCaseCount = appState.savedCaseIds.length;
    final noteCount = appState.caseNoteDrafts.length;

    // 根據條件計算成就啟動狀態
    final hasNovice = savedStatuteCount >= 1;
    final hasScholar = savedStatuteCount >= 3;
    final hasCaseMaster = savedCaseCount >= 1;
    final hasNoteTaker = noteCount >= 1;

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
              '法律成就陳列室',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w900,
                color: isDark ? const Color(0xFFF2F4F7) : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),

            // 成就列表
            _buildAchievementTile(
              context,
              title: '法學初學者',
              description: '收藏至少 1 條法規 (已收藏 $savedStatuteCount 條)',
              icon: Icons.search_rounded,
              isUnlocked: hasNovice,
              badgeColor: const Color(0xFF2E7D32),
            ),
            SizedBox(height: 10.h),
            _buildAchievementTile(
              context,
              title: '法學進修者',
              description: '收藏至少 3 條法規 (已收藏 $savedStatuteCount 條)',
              icon: Icons.account_balance_rounded,
              isUnlocked: hasScholar,
              badgeColor: const Color(0xFFD6A85F),
            ),
            SizedBox(height: 10.h),
            _buildAchievementTile(
              context,
              title: '修法達人',
              description: '收藏至少 1 筆判決案件 (已收藏 $savedCaseCount 筆)',
              icon: Icons.gavel_rounded,
              isUnlocked: hasCaseMaster,
              badgeColor: const Color(0xFFC96B3B),
            ),
            SizedBox(height: 10.h),
            _buildAchievementTile(
              context,
              title: '卷宗推手',
              description: '撰寫至少 1 筆案件筆記 (已撰寫 $noteCount 筆)',
              icon: Icons.drive_file_rename_outline_rounded,
              isUnlocked: hasNoteTaker,
              badgeColor: const Color(0xFF3F51B5),
            ),
            SizedBox(height: 24.h),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
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

  Widget _buildAchievementTile(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required bool isUnlocked,
    required Color badgeColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textMuted = isDark ? const Color(0xFFA3ABB6) : AppColors.textSecondary;
    final cardColor = isDark ? const Color(0xFF0F1216) : const Color(0xFFFAF7F2);
    final borderSide = BorderSide(color: isDark ? const Color(0xFF2B3441) : AppColors.border);

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isUnlocked ? badgeColor.withOpacity(0.4) : borderSide.color,
          width: isUnlocked ? 1.5.w : 1.w,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: isUnlocked ? badgeColor.withOpacity(0.12) : Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isUnlocked ? badgeColor : Colors.grey,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: isUnlocked
                            ? (isDark ? const Color(0xFFF2F4F7) : AppColors.textPrimary)
                            : Colors.grey,
                      ),
                    ),
                    if (isUnlocked) ...[
                      SizedBox(width: 6.w),
                      Icon(Icons.check_circle_rounded, color: badgeColor, size: 14.sp),
                    ],
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    color: isUnlocked ? textMuted : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            isUnlocked ? '已解鎖' : '未解鎖',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
              color: isUnlocked ? badgeColor : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationSettingsSheet extends StatefulWidget {
  const NotificationSettingsSheet({super.key, required this.appState});

  final LawAppState appState;

  @override
  State<NotificationSettingsSheet> createState() => _NotificationSettingsSheetState();
}

class _NotificationSettingsSheetState extends State<NotificationSettingsSheet> {
  late String _frequency;
  late String _channel;

  @override
  void initState() {
    super.initState();
    _frequency = widget.appState.notifyFrequency;
    _channel = widget.appState.notifyChannel;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF171C22) : Colors.white;
    final borderSide = BorderSide(color: isDark ? const Color(0xFF2B3441) : AppColors.border);
    final textMuted = isDark ? const Color(0xFFA3ABB6) : AppColors.textSecondary;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
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
            '通知精細設定',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w900,
              color: isDark ? const Color(0xFFF2F4F7) : AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20.h),

          // 頻率選擇
          Text('通知頻率', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: textMuted)),
          SizedBox(height: 8.h),
          Row(
            children: [
              _buildOptionCard(
                type: 'frequency',
                value: 'instant',
                label: '即時推送',
                icon: Icons.flash_on_rounded,
              ),
              SizedBox(width: 8.w),
              _buildOptionCard(
                type: 'frequency',
                value: 'daily',
                label: '每日摘要',
                icon: Icons.today_rounded,
              ),
              SizedBox(width: 8.w),
              _buildOptionCard(
                type: 'frequency',
                value: 'weekly',
                label: '每週彙報',
                icon: Icons.date_range_rounded,
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // 管道選擇
          Text('通知管道', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: textMuted)),
          SizedBox(height: 8.h),
          Row(
            children: [
              _buildOptionCard(
                type: 'channel',
                value: 'push',
                label: '系統推送',
                icon: Icons.notifications_active_rounded,
              ),
              SizedBox(width: 8.w),
              _buildOptionCard(
                type: 'channel',
                value: 'email',
                label: '信箱副本',
                icon: Icons.email_rounded,
              ),
              SizedBox(width: 8.w),
              _buildOptionCard(
                type: 'channel',
                value: 'both',
                label: '雙管齊下',
                icon: Icons.all_inclusive_rounded,
              ),
            ],
          ),
          SizedBox(height: 24.h),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    side: borderSide,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                  ),
                  child: Text('取消', style: TextStyle(fontSize: 14.sp, color: textMuted)),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    widget.appState.updateSettings(
                      notifyFrequency: _frequency,
                      notifyChannel: _channel,
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('通知設定已成功儲存！'),
                        backgroundColor: Color(0xFF2E7D32),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                  ),
                  child: Text('儲存', style: TextStyle(fontSize: 14.sp, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required String type,
    required String value,
    required String label,
    required IconData icon,
  }) {
    final isSelected = type == 'frequency' ? _frequency == value : _channel == value;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (type == 'frequency') {
              _frequency = value;
            } else {
              _channel = value;
            }
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 4.w),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? const Color(0xFF243B63) : const Color(0xFFEAF0F8))
                : (isDark ? const Color(0xFF0F1216) : const Color(0xFFFAF7F2)),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected
                  ? AppColors.accent
                  : (isDark ? const Color(0xFF2B3441) : AppColors.border),
              width: isSelected ? 1.5.w : 1.w,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.accent : (isDark ? Colors.white70 : AppColors.textSecondary),
                size: 20.sp,
              ),
              SizedBox(height: 6.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppColors.accent : (isDark ? Colors.white70 : AppColors.textPrimary),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AccountSecuritySheet extends StatefulWidget {
  const AccountSecuritySheet({super.key, required this.appState});

  final LawAppState appState;

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
    final borderSide = BorderSide(color: isDark ? const Color(0xFF2B3441) : AppColors.border);
    final textMuted = isDark ? const Color(0xFFA3ABB6) : AppColors.textSecondary;

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
            Text('第三方帳號綁定', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: textMuted)),
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
            Text('密碼安全', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: textMuted)),
            SizedBox(height: 8.h),
            ListTile(
              leading: Icon(Icons.lock_reset_rounded, color: AppColors.primary, size: 22.sp),
              title: const Text('重設登入密碼', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('更換您用於登入 LawApp 的獨立密碼'),
              trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14.sp),
              tileColor: isDark ? const Color(0xFF0F1216) : const Color(0xFFFAF7F2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
                side: borderSide,
              ),
              onTap: _showResetPasswordDialog,
            ),
            SizedBox(height: 24.h),

            // 刪除帳號（危險區域）
            Text('危險區域', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.redAccent)),
            SizedBox(height: 8.h),
            ListTile(
              leading: Icon(Icons.delete_forever_rounded, color: Colors.redAccent, size: 22.sp),
              title: const Text('永久刪除帳號', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
              subtitle: const Text('刪除後所有收藏、追蹤與筆記紀錄皆無法復原'),
              trailing: Icon(Icons.arrow_forward_ios_rounded, color: Colors.redAccent, size: 14.sp),
              tileColor: isDark ? const Color(0x11FF5252) : const Color(0xFFFFF1F1),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
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
    final borderSide = BorderSide(color: isDark ? const Color(0xFF2B3441) : AppColors.border);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F1216) : const Color(0xFFFAF7F2),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: borderSide.color),
      ),
      child: ListTile(
        leading: Icon(icon, color: isLinked ? AppColors.accent : Colors.grey, size: 26.sp),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(isLinked ? '已連結' : '未連結'),
        trailing: Switch(
          value: isLinked,
          activeColor: AppColors.accent,
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
          title: const Text('重設密碼', style: TextStyle(fontWeight: FontWeight.bold)),
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
         // 台灣繁體中文教學註解：
// 介面自訂設定底頁，支援 iOS 風格橫向島嶼導覽列拖曳排序、非同步微幅晃動動效，
// 以及導覽文字標籤開關與 Accent 主題色彩點選。

class _JiggleWidget extends StatefulWidget {
  const _JiggleWidget({required this.child, required this.index, this.enabled = true});

  final Widget child;
  final int index;
  final bool enabled;

  @override
  State<_JiggleWidget> createState() => _JiggleWidgetState();
}

class _JiggleWidgetState extends State<_JiggleWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _rotationAnim;
  late final Animation<double> _translationAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );

    // 台灣繁體中文教學註解：微幅的弧度旋轉動效（約 -1.1度 到 1.1度）
    _rotationAnim = Tween<double>(begin: -0.02, end: 0.02).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // 台灣繁體中文教學註解：微幅的上下平移，加強懸浮晃動感
    _translationAnim = Tween<double>(begin: -0.6, end: 0.6).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.enabled) {
      // 台灣繁體中文教學註解：使用項目 index 來決定相位偏移量，
      // 如此能確保每個分頁的抖動起動點不同，呈現擬真且不呆板的 iOS 非同步抖動效果。
      _controller.value = (widget.index * 0.23) % 1.0;
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _JiggleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled != oldWidget.enabled) {
      if (widget.enabled) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _translationAnim.value),
          child: Transform.rotate(
            angle: _rotationAnim.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

class InterfaceSettingsSheet extends StatefulWidget {
  const InterfaceSettingsSheet({super.key, required this.appState});

  final LawAppState appState;

  @override
  State<InterfaceSettingsSheet> createState() => _InterfaceSettingsSheetState();
}

class _InterfaceSettingsSheetState extends State<InterfaceSettingsSheet> {
  late List<int> _tempOrder;
  late bool _tempShowLabels;
  late int _tempAccentIndex;

  // 台灣繁體中文教學註解：簡短文字標籤，適用於島嶼空間
  static const Map<int, String> _tabLabelsShort = {
    0: '首頁',
    1: '學習',
    2: '小法助',
    3: '記事',
    4: '我的',
  };

  @override
  void initState() {
    super.initState();
    _tempOrder = List<int>.from(widget.appState.navbarOrder);
    _tempShowLabels = widget.appState.showNavbarLabels;
    _tempAccentIndex = widget.appState.accentColorIndex;
  }

  Widget _buildTabIcon(int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // 使用當前的 Accent 主題色，增加自訂時的色彩回饋感
    final iconColor = AppColors.accent;
    
    if (index == 2) {
      return Container(
        width: 24.w,
        height: 24.w,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: Image.asset(
            'assets/images/assistant/law_assistant_home.png',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
      );
    }

    final IconData iconData;
    switch (index) {
      case 0:
        iconData = Icons.home_rounded;
        break;
      case 1:
        iconData = Icons.menu_book_rounded;
        break;
      case 3:
        iconData = Icons.inventory_2_rounded;
        break;
      case 4:
      default:
        iconData = Icons.person_rounded;
        break;
    }

    return Icon(iconData, color: iconColor, size: 24.sp);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF171C22) : Colors.white;
    final borderSide = BorderSide(color: isDark ? const Color(0xFF2B3441) : AppColors.border);
    final textMuted = isDark ? const Color(0xFFA3ABB6) : AppColors.textSecondary;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
      child: SafeArea(
        top: false,
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
                '自訂導覽與介面',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w900,
                  color: isDark ? const Color(0xFFF2F4F7) : AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.h),

              // 1. 拖曳排序
              Text('自訂分頁順序（長按並左右拖曳進行排序）', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: textMuted)),
              SizedBox(height: 12.h),
              
              // 台灣繁體中文教學註解：
              // 水平「懸浮島嶼」拖曳排序列，高度固定為 84.h，大圓角與精緻陰影
              Container(
                height: 84.h,
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A2028) : const Color(0xFFF2F4F7),
                  borderRadius: BorderRadius.circular(28.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ReorderableListView(
                  scrollDirection: Axis.horizontal,
                  buildDefaultDragHandles: false, // 長按拖曳
                  children: [
                    for (int i = 0; i < _tempOrder.length; i++)
                      ReorderableDelayedDragStartListener(
                        index: i,
                        key: ValueKey(_tempOrder[i]),
                        child: _JiggleWidget(
                          index: i,
                          enabled: true,
                          child: Container(
                            width: (MediaQuery.sizeOf(context).width - 64.w) / 5.2,
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildTabIcon(_tempOrder[i]),
                                SizedBox(height: 5.h),
                                Text(
                                  _tabLabelsShort[_tempOrder[i]]!,
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? const Color(0xFFF2F4F7) : AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }
                      final int item = _tempOrder.removeAt(oldIndex);
                      _tempOrder.insert(newIndex, item);
                    });
                  },
                ),
              ),
              SizedBox(height: 24.h),

              // 2. 顯示文字標籤
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F1216) : const Color(0xFFFAF7F2),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: borderSide.color),
                ),
                child: SwitchListTile(
                  title: const Text('顯示分頁文字標籤', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('關閉後將只顯示導覽圖示，高度更加緊湊'),
                  value: _tempShowLabels,
                  activeColor: AppColors.accent,
                  onChanged: (val) {
                    setState(() {
                      _tempShowLabels = val;
                    });
                  },
                ),
              ),
              SizedBox(height: 24.h),

              // 3. 主題 Accent Color 點選
              Text('App 品牌配色', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: textMuted)),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildColorCircle(0, const Color(0xFFD6A85F), '金沙黃'),
                  _buildColorCircle(1, const Color(0xFFC62828), '酒櫻紅'),
                  _buildColorCircle(2, const Color(0xFF1565C0), '律政藍'),
                  _buildColorCircle(3, const Color(0xFF2E7D32), '法規綠'),
                ],
              ),
              SizedBox(height: 28.h),

              // 操作按鈕
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        side: borderSide,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                      ),
                      child: Text('取消', style: TextStyle(fontSize: 14.sp, color: textMuted)),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        widget.appState.updateInterfaceSettings(
                          navbarOrder: _tempOrder,
                          showNavbarLabels: _tempShowLabels,
                          accentColorIndex: _tempAccentIndex,
                        );
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('介面自訂偏好已儲存！'),
                            backgroundColor: Color(0xFF2E7D32),
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                      ),
                      child: Text('儲存變更', style: TextStyle(fontSize: 14.sp, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorCircle(int index, Color color, String name) {
    final isSelected = _tempAccentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _tempAccentIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: Colors.white, width: 3.w)
                  : Border.all(color: Colors.transparent),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(isSelected ? 0.5 : 0.2),
                  blurRadius: isSelected ? 8 : 4,
                  spreadRadius: isSelected ? 2 : 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: isSelected
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                : null,
          ),
          SizedBox(height: 6.h),
          Text(
            name,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppColors.accent : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
