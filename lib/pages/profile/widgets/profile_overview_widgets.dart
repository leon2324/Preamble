import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/app/app_state.dart';
import 'package:lawapp/pages/following/following_page.dart';
import 'package:lawapp/theme/app_colors.dart';

import 'profile_editor.dart';

// 這個檔案集中收納個人頁上半部的展示型 widgets。
// 會使用 AppState 讀取統計資料與保留既有 FollowingPage 導航，但不在此新增資料寫入流程。

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
        border: Border.all(
            color: isDark ? const Color(0xFF2B3441) : AppColors.border,
            width: 1.w),
      ),
      child: Center(
        child: Icon(
          isGuest ? Icons.person_rounded : avatar!.icon,
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
                  color: AppColors.accent.withValues(alpha: 0.3),
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

  final PreambleState appState;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF171C22) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2B3441) : AppColors.border;
    final textMuted =
        isDark ? const Color(0xFFA3ABB6) : AppColors.textSecondary;

    // 計算使用者追蹤的總項目數量（加總案件、法條與主題的追蹤數）
    final following = appState.followingSummary;
    final followedCount = following.followedCaseIds.length +
        following.followedStatuteIds.length +
        following.followedTopicIds.length;
    final savedCaseCount = {
      ...appState.savedCaseIds,
      ...following.savedCaseIds,
    }.length;
    final savedCount = savedCaseCount +
        following.savedStatuteIds.length +
        following.savedArticleIds.length;

    // 建立 4 個儀表板主要資料項目，分別對接 AppState 裡的真實筆數
    final items = [
      _DashboardItemData(
        title: '我的收藏',
        value: '$savedCount 筆',
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
                          color: isDark
                              ? const Color(0xFFF2F4F7)
                              : AppColors.textPrimary,
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
                  child: Icon(Icons.smart_toy_rounded,
                      color: AppColors.accent, size: 22.sp),
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
                          color: isDark
                              ? const Color(0xFFF2F4F7)
                              : AppColors.textPrimary,
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
                  color:
                      isDark ? const Color(0xFF556070) : AppColors.placeholder,
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
              border: Border.all(
                  color: isDark ? const Color(0xFF2B3441) : AppColors.border),
            ),
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.folder_open_rounded,
                    color: AppColors.accent, size: 40.sp),
                SizedBox(height: 12.h),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                    color: isDark
                        ? const Color(0xFFF2F4F7)
                        : AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: isDark
                        ? const Color(0xFFA3ABB6)
                        : AppColors.textSecondary,
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
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r)),
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
                          Icon(Icons.workspace_premium_rounded,
                              color: AppColors.accent, size: 20.sp),
                          SizedBox(width: 6.w),
                          Text(
                            '解鎖 緒言 Preamble Pro',
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
                    padding:
                        EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r)),
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

class LearningProgressBanner extends StatelessWidget {
  const LearningProgressBanner({super.key, required this.appState});

  final PreambleState appState;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF171C22) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2B3441) : AppColors.border;
    final textMuted =
        isDark ? const Color(0xFFA3ABB6) : AppColors.textSecondary;

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
                color: const Color(0xFFD6A85F).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.workspace_premium_rounded,
                  color: const Color(0xFFD6A85F), size: 22.sp),
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
                      color: isDark
                          ? const Color(0xFFF2F4F7)
                          : AppColors.textPrimary,
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

  final PreambleState appState;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF171C22) : Colors.white;
    final textMuted =
        isDark ? const Color(0xFFA3ABB6) : AppColors.textSecondary;

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

  Widget _buildAchievementTile(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required bool isUnlocked,
    required Color badgeColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textMuted =
        isDark ? const Color(0xFFA3ABB6) : AppColors.textSecondary;
    final cardColor =
        isDark ? const Color(0xFF0F1216) : const Color(0xFFFAF7F2);
    final borderSide =
        BorderSide(color: isDark ? const Color(0xFF2B3441) : AppColors.border);

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color:
              isUnlocked ? badgeColor.withValues(alpha: 0.4) : borderSide.color,
          width: isUnlocked ? 1.5.w : 1.w,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: isUnlocked
                  ? badgeColor.withValues(alpha: 0.12)
                  : Colors.grey.withValues(alpha: 0.1),
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
                            ? (isDark
                                ? const Color(0xFFF2F4F7)
                                : AppColors.textPrimary)
                            : Colors.grey,
                      ),
                    ),
                    if (isUnlocked) ...[
                      SizedBox(width: 6.w),
                      Icon(Icons.check_circle_rounded,
                          color: badgeColor, size: 14.sp),
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
