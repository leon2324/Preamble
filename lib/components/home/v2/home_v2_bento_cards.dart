import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/app/app_state.dart';
import 'package:lawapp/pages/learning/know_law_page.dart';
import 'package:lawapp/theme/app_colors.dart';
import 'package:lawapp/components/home/v2/home_v2_palette.dart';
import 'package:lawapp/components/home/v2/home_v2_primitives.dart';
import 'package:lawapp/data/mock_data/followed_updates/followed_updates_mock_data.dart';
import 'package:lawapp/pages/learning/home_mission_quiz_page.dart';
import 'package:lawapp/pages/followed_updates/followed_updates_page.dart';

/// 1. AI 法律即時快問與 Prompt 推薦標籤
class HomeV2QuickAskSection extends StatefulWidget {
  const HomeV2QuickAskSection({super.key});

  @override
  State<HomeV2QuickAskSection> createState() => _HomeV2QuickAskSectionState();
}

class _HomeV2QuickAskSectionState extends State<HomeV2QuickAskSection> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitPrompt(String text) {
    final prompt = text.trim();
    if (prompt.isEmpty) return;
    _controller.clear();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (__) => LawAssistantChatPage(initialPrompt: prompt),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final boxBg = isDark ? const Color(0xFF1E242F) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2C3545) : AppColors.border;

    // 台灣繁體中文教學註解：推薦常用法律問題的 Prompt 標籤
    final recommendations = [
      '租屋押金房東不退',
      '車禍理賠和解程序',
      '加班費沒給怎麼辦',
      '網路留言挨告公然侮辱',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.auto_awesome_rounded,
              color: const Color(0xFFD6A85F),
              size: 16.sp,
            ),
            SizedBox(width: 6.w),
            Text(
              'AI 法律即時快問',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w900,
                color: isDark ? const Color(0xFFF2F4F7) : AppColors.textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: boxBg,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: borderColor),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _controller,
            style: TextStyle(fontSize: 13.sp),
            onSubmitted: _submitPrompt,
            decoration: InputDecoration(
              hintText: '描述你遇到的問題，例如：租約到期房東扣押金...',
              hintStyle: TextStyle(
                color: isDark ? const Color(0xFF6B7785) : AppColors.textMuted,
                fontSize: 12.sp,
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              border: InputBorder.none,
              prefixIcon: Icon(
                Icons.psychology_alt_outlined,
                color: const Color(0xFFD6A85F),
                size: 20.sp,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.send_rounded,
                  color: AppColors.primary,
                  size: 18.sp,
                ),
                onPressed: () => _submitPrompt(_controller.text),
              ),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        SizedBox(
          height: 30.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: recommendations.length,
            itemBuilder: (context, index) {
              final prompt = recommendations[index];
              return Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: InkWell(
                  onTap: () => _submitPrompt(prompt),
                  borderRadius: BorderRadius.circular(99.r),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF161B22)
                          : const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(99.r),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF26303D)
                            : const Color(0xFFE4E8EC),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 10.sp,
                          color: isDark
                              ? const Color(0xFFB5C1D0)
                              : AppColors.textSecondary,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          prompt,
                          style: TextStyle(
                            fontSize: 10.5.sp,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? const Color(0xFFE5E9E6)
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// 2. 我的關注更新看板 (Watchlist Card)
class HomeV2WatchlistCard extends StatelessWidget {
  const HomeV2WatchlistCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF171C22) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2B3441) : AppColors.border;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: const Color(0x151565C0),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.notifications_active_rounded,
                      color: const Color(0xFF1565C0),
                      size: 18.sp,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '我的關注更新',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w900,
                      color: isDark
                          ? const Color(0xFFF2F4F7)
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (__) => const FollowedUpdatesPage()),
                  );
                },
                child: Text(
                  '查看全部',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // 台灣繁體中文教學註解：讀取關注的主題更新列表
          ...trackedTopicItems.take(2).map((item) {
            final isLaw = item.tag.contains('法');
            final badgeBg = isLaw
                ? (isDark ? const Color(0x1F2E7D32) : const Color(0xFFE9F5EE))
                : (isDark ? const Color(0x1F1565C0) : const Color(0xFFE8F3FF));
            final badgeColor =
                isLaw ? const Color(0xFF2E7D32) : const Color(0xFF1565C0);

            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (__) => const FollowedUpdatesPage()),
                  );
                },
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0F1216)
                        : const Color(0xFFFAF7F2),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF222B35)
                          : const Color(0xFFEBEFF3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          item.tag,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: badgeColor,
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.5.sp,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? const Color(0xFFE5E9E6)
                                    : AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              item.summary,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: isDark
                                    ? const Color(0xFFA3ABB6)
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: isDark ? const Color(0xFF6B7785) : Colors.grey,
                        size: 16.sp,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// 3. 每日任務與學習成就 (Gamified Achievement Card)
class HomeV2AchievementCard extends StatelessWidget {
  const HomeV2AchievementCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF171C22) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2B3441) : AppColors.border;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '每日任務',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w900,
                  color:
                      isDark ? const Color(0xFFF2F4F7) : AppColors.textPrimary,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: const Color(0x15FF9800),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Row(
                  children: [
                    Text(
                      '🔥 5天連續',
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            'Lv. 4 律師學徒',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFFE5E9E6) : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: LinearProgressIndicator(
              value: 0.8,
              minHeight: 6.h,
              backgroundColor:
                  isDark ? const Color(0xFF222B35) : const Color(0xFFEAEFF5),
              color: AppColors.accent,
            ),
          ),
          SizedBox(height: 4.h),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '80 / 100 XP',
              style: TextStyle(
                fontSize: 9.sp,
                color:
                    isDark ? const Color(0xFFA3ABB6) : AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 32.h,
            child: FilledButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (__) => const HomeMissionQuizPage()),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: Text(
                '挑戰今日測驗',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 4. 今日 AI 判決故事卡片
class HomeV2DailyCaseStoryCard extends StatelessWidget {
  const HomeV2DailyCaseStoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF171C22) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2B3441) : AppColors.border;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.gavel_rounded,
                color: const Color(0xFFC62828),
                size: 14.sp,
              ),
              SizedBox(width: 4.w),
              Text(
                '今日判決故事',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w900,
                  color:
                      isDark ? const Color(0xFFF2F4F7) : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            '罵人「毒瘤」算侮辱嗎？',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w900,
              color: isDark ? const Color(0xFFE5E9E6) : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 3.h),
          Expanded(
            child: Text(
              '法官認定「毒瘤」一詞具有貶損他人名譽之意，且在公開網路平台發表，已達公然侮辱標準，判處罰金五千元。',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9.5.sp,
                height: 1.35,
                color:
                    isDark ? const Color(0xFFA3ABB6) : AppColors.textSecondary,
              ),
            ),
          ),
          SizedBox(height: 4.h),
          SizedBox(
            width: double.infinity,
            height: 32.h,
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (__) => const LawAssistantChatPage(
                      initialPrompt: '我想知道法院對於在網路上罵人「毒瘤」被判公然侮辱的相關案例分析與白話解說。',
                    ),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.primary, width: 1.w),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: Text(
                '看 AI 白話解說',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 5. 常用工具快捷抽屜 (Legal Tools Drawer)
class HomeV2ToolsDrawer extends StatelessWidget {
  const HomeV2ToolsDrawer({
    super.key,
    required this.onNavigateToTab,
  });

  final void Function(int targetOriginalIndex,
      {int? subTabIndex, String? toolTab}) onNavigateToTab;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF171C22) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2B3441) : AppColors.border;

    final toolItems = [
      _ToolItemData(
        title: '押金返還通知',
        subtitle: '租屋退租催告',
        icon: Icons.home_work_outlined,
        color: const Color(0xFFE9F5EE),
        iconColor: const Color(0xFF2E7D32),
        toolTab: '租屋催告',
      ),
      _ToolItemData(
        title: '車禍紀錄備忘',
        subtitle: '折舊公式試算',
        icon: Icons.directions_car_filled_outlined,
        color: const Color(0xFFEAF3FF),
        iconColor: const Color(0xFF1565C0),
        toolTab: '車禍計算',
      ),
      _ToolItemData(
        title: '加班費協商書',
        subtitle: '工資補休試算',
        icon: Icons.groups_2_outlined,
        color: const Color(0xFFF0ECFF),
        iconColor: const Color(0xFF673AB7),
        toolTab: '加班計算',
      ),
      _ToolItemData(
        title: '消費爭議申訴',
        subtitle: '網購瑕疵退貨',
        icon: Icons.storefront_outlined,
        color: const Color(0xFFFFF1D1),
        iconColor: const Color(0xFFB78103),
        toolTab: '網購退貨',
      ),
      _ToolItemData(
        title: '勞資權益自救',
        subtitle: '職場自保清單',
        icon: Icons.chat_bubble_outline_rounded,
        color: const Color(0xFFFFEBEE),
        iconColor: const Color(0xFFC62828),
        toolTab: '自救清單',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.construction_rounded,
              color: isDark ? const Color(0xFFA3ABB6) : AppColors.textSecondary,
              size: 15.sp,
            ),
            SizedBox(width: 6.w),
            Text(
              '實用法律工具快捷鍵',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w900,
                color: isDark ? const Color(0xFFF2F4F7) : AppColors.textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        SizedBox(
          height: 72.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: toolItems.length,
            itemBuilder: (context, index) {
              final item = toolItems[index];
              return Padding(
                padding: EdgeInsets.only(right: 12.w),
                child: InkWell(
                  onTap: () {
                    // 台灣繁體中文教學註解：直接導向「學習」頁的「生活工具箱」，並指定特定的工具分頁
                    onNavigateToTab(1, subTabIndex: 1, toolTab: item.toolTab);
                  },
                  borderRadius: BorderRadius.circular(16.r),
                  child: Container(
                    width: 145.w,
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: borderColor),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x04000000),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: isDark
                                ? item.iconColor.withOpacity(0.15)
                                : item.color,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            item.icon,
                            color: item.iconColor,
                            size: 18.sp,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                item.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10.5.sp,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? const Color(0xFFE5E9E6)
                                      : AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                item.subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 8.5.sp,
                                  color: isDark
                                      ? const Color(0xFFA3ABB6)
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ToolItemData {
  const _ToolItemData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.iconColor,
    required this.toolTab,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color iconColor;
  final String toolTab;
}
