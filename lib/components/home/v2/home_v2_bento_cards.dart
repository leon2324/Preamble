import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/pages/learning/know_law_page.dart';
import 'package:preamble/theme/app_colors.dart';
import 'package:preamble/data/mock_data/followed_updates/followed_updates_mock_data.dart';
import 'package:preamble/pages/learning/home_mission_quiz_page.dart';
import 'package:preamble/pages/following/following_page.dart';
import 'package:preamble/app/app_state.dart';
import 'package:preamble/features/case_library/pages/case_dossier_detail_page.dart';
import 'package:preamble/features/case_library/data/case_library_data.dart';
import 'package:preamble/components/shared/liquid_glass_widgets.dart';
import 'package:preamble/components/safety/plain_document_translator_sheet.dart';

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
    final boxBg = isDark ? const Color(0xFF1E242F) : const Color(0xFFF3FAF6);
    final borderColor =
        isDark ? const Color(0xFF2C3545) : const Color(0xFFC7DED1);
    final text = isDark ? const Color(0xFFF2F4F7) : const Color(0xFF1B3F38);
    final hintColor =
        isDark ? const Color(0xFF6B7785) : const Color(0xFF6A8680);
    final chipBg = isDark ? const Color(0xFF161B22) : const Color(0xFFFFFFFF);
    final chipBorder =
        isDark ? const Color(0xFF26303D) : const Color(0xFFE2EBE7);

    // 這些短 prompt 之後可直接映射到 App Intents 的常用捷徑參數；
    // 目前仍先維持 Flutter 端可點擊送出的完整互動。
    final recommendations = [
      {'text': '租屋押金房東不退', 'color': const Color(0xFF4A7C8C)},
      {'text': '車禍理賠和解程序', 'color': const Color(0xFF9E7B2D)},
      {'text': '加班費沒給怎麼辦', 'color': const Color(0xFFCD5C5C)},
      {'text': '網路留言被控公然侮辱', 'color': const Color(0xFF6D649A)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF2E394A) : const Color(0xFFE6F2EC),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                color: const Color(0xFF2EA26F),
                size: 14.sp,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              '法律即時快問',
              style: TextStyle(
                fontSize: 13.5.sp,
                fontWeight: FontWeight.w900,
                color: text,
              ),
            ),
            const Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: const Color(0xFF2EA26F).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(100.r),
              ),
              child: Text(
                '快捷問法',
                style: TextStyle(
                  color: const Color(0xFF2EA26F),
                  fontSize: 9.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Container(
          decoration: BoxDecoration(
            color: boxBg,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: borderColor, width: 1.2.w),
            boxShadow: [
              BoxShadow(
                color: const Color(0x06000000),
                blurRadius: 10.r,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _controller,
            style: TextStyle(
                fontSize: 13.sp, color: text, fontWeight: FontWeight.w600),
            onSubmitted: _submitPrompt,
            onTapOutside: (event) {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            decoration: InputDecoration(
              hintText: '描述你遇到的問題，例如：租賃合約提前解約...',
              hintStyle: TextStyle(
                color: hintColor,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              border: InputBorder.none,
              prefixIcon: Icon(
                Icons.psychology_alt_outlined,
                color: const Color(0xFF2EA26F),
                size: 22.sp,
              ),
              suffixIcon: Padding(
                padding: EdgeInsets.all(6.w),
                child: CircleAvatar(
                  backgroundColor: const Color(0xFF2EA26F),
                  radius: 16.r,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.arrow_upward_rounded,
                      color: Colors.white,
                      size: 16.sp,
                    ),
                    onPressed: () => _submitPrompt(_controller.text),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 10.h),
        SizedBox(
          height: 32.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              // 📷 拍存證信函/公文白話解讀（純粹初衷輕量入口）
              Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: InkWell(
                  onTap: () => PlainDocumentTranslatorSheet.show(context),
                  borderRadius: BorderRadius.circular(99.r),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2EA26F).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(99.r),
                      border: Border.all(
                        color: const Color(0xFF2EA26F).withValues(alpha: 0.4),
                        width: 1.w,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.translate_rounded,
                          size: 13.sp,
                          color: const Color(0xFF2EA26F),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '拍公文信件秒解讀',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2EA26F),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              for (final rec in recommendations)
                Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: InkWell(
                    onTap: () => _submitPrompt(rec['text'] as String),
                    borderRadius: BorderRadius.circular(99.r),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: chipBg,
                        borderRadius: BorderRadius.circular(99.r),
                        border: Border.all(color: chipBorder, width: 1.w),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x03000000),
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.assistant_navigation,
                            size: 11.sp,
                            color: rec['color'] as Color,
                          ),
                          SizedBox(width: 5.w),
                          Text(
                            rec['text'] as String,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: text.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 2. 我的關注更新看板 (Watchlist Card)
class HomeV2WatchlistCard extends StatelessWidget {
  const HomeV2WatchlistCard({super.key});

  void _openFollowingUpdates(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (__) => const FollowingPage(initialTab: 'updates'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appState = PreambleScope.of(context);

    // 檢查是否有更新
    final hasUpdates = appState.followingSummary.followedCaseIds.isNotEmpty ||
        appState.followingSummary.followedStatuteIds.isNotEmpty ||
        appState.followingSummary.followedTopicIds.isNotEmpty;

    return LiquidGlassCard(
      padding: EdgeInsets.all(16.w),
      radius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                          SizedBox(height: 2.h),
                          Text(
                            hasUpdates ? '今天的追蹤摘要已整理好' : '先給你一則今日精選案卷',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
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
              SizedBox(width: 10.w),
              InkWell(
                onTap: () => _openFollowingUpdates(context),
                child: Text(
                  '管理關注',
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
          if (hasUpdates) ...[
            // 讀取關注的主題更新列表
            ...trackedTopicItems.take(2).map((item) {
              final isLaw = item.tag.contains('法');
              final badgeBg = isLaw
                  ? (isDark ? const Color(0x1F2E7D32) : const Color(0xFFE9F5EE))
                  : (isDark
                      ? const Color(0x1F1565C0)
                      : const Color(0xFFE8F3FF));
              final badgeColor =
                  isLaw ? const Color(0xFF2E7D32) : const Color(0xFF1565C0);

              return Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: InkWell(
                  onTap: () => _openFollowingUpdates(context),
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
          ] else ...[
            // 無追蹤動態時，首頁仍提供一則今日精選案卷；
            // 未來 Widget 點回 App 時，也可以共用這個「今日精選」語意。
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF1B241E) : const Color(0xFFF2F8F4),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF275435)
                      : const Color(0xFFD4E8DA),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 台灣繁體中文教學註解：此列的案卷 badge 與字號都是獨立資訊。
                  // 以內容寬度換行可在大字時保留兩者，不必以 ellipsis 隱藏其中一項。
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 4.h,
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF275435)
                              : const Color(0xFFD4E8DA),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          '今日精選案卷',
                          style: TextStyle(
                            color: isDark
                                ? const Color(0xFF76BA8B)
                                : const Color(0xFF275435),
                            fontSize: 9.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '釋字第 799 號',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '強制治療案：人身自由與社會防衛的拉鋸戰',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '本案審查性侵害犯刑後強制治療之合憲性，探討人身自由與比例原則。',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10.5.sp,
                      height: 1.35,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          // 點擊「立即思辨」進入該案卷
                          final caseBook = caseLibraryCases.first;
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (__) =>
                                    CaseDossierDetailPage(book: caseBook)),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: isDark
                              ? const Color(0xFF76BA8B)
                              : const Color(0xFF275435),
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 6.h),
                          visualDensity: VisualDensity.compact,
                        ),
                        child: const Text('立即思辨 →'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
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

    return LiquidGlassCard(
      padding: EdgeInsets.all(14.w),
      radius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 4.w,
            runSpacing: 4.h,
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
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: const Color(0x15FF9800),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  '5天連續',
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 8.5.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.orange,
                  ),
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
          SizedBox(height: 12.h),
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
///
/// 這張卡是 MAIC Demo 的 Widget 落地入口候選；
/// Widget 顯示短摘要，點回 App 後就能從這裡進入完整白話解說。
class HomeV2DailyCaseStoryCard extends StatelessWidget {
  const HomeV2DailyCaseStoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF171C22) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2B3441) : AppColors.border;

    return LiquidGlassCard(
      padding: EdgeInsets.all(14.w),
      radius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 4.w,
            runSpacing: 4.h,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(
                Icons.gavel_rounded,
                color: const Color(0xFFC62828),
                size: 14.sp,
              ),
              SizedBox(width: 4.w),
              Text(
                '今天判決故事',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w900,
                  color:
                      isDark ? const Color(0xFFF2F4F7) : AppColors.textPrimary,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFC62828).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(99.r),
                ),
                child: Text(
                  '每日精選',
                  style: TextStyle(
                    color: const Color(0xFFC62828),
                    fontSize: 8.5.sp,
                    fontWeight: FontWeight.w900,
                  ),
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
          Text(
            '法官認定「毒瘤」一詞具有貶損他人名譽之意，且在公開網路平台發表，已達公然侮辱標準，判處罰金五千元。',
            style: TextStyle(
              fontSize: 9.5.sp,
              height: 1.35,
              color: isDark ? const Color(0xFFA3ABB6) : AppColors.textSecondary,
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

    final titleStyle = TextStyle(
      fontSize: 10.5.sp,
      fontWeight: FontWeight.bold,
      color: isDark ? const Color(0xFFE5E9E6) : AppColors.textPrimary,
    );
    final subtitleStyle = TextStyle(
      fontSize: 8.5.sp,
      color: isDark ? const Color(0xFFA3ABB6) : AppColors.textSecondary,
    );
    final itemWidth = 145.w;
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
        SingleChildScrollView(
          // 台灣繁體中文教學註解：工具捷徑原本固定 72.h；橫向或大字時，
          // 圖示與兩行文字的真實高度可能超過它。高度改由最需要空間的工具
          // 決定，橫向捲動行為則維持原本的工具列互動與卡片節奏。
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: toolItems.map((item) {
              return Padding(
                padding: EdgeInsets.only(right: 12.w),
                child: InkWell(
                  onTap: () {
                    // 直接導向「學習」頁的「生活工具箱」，並指定特定的工具分頁
                    onNavigateToTab(1, subTabIndex: 1, toolTab: item.toolTab);
                  },
                  borderRadius: BorderRadius.circular(16.r),
                  child: Container(
                    width: itemWidth,
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
                    child: _ToolDrawerItemContent(
                      item: item,
                      itemWidth: itemWidth,
                      isDark: isDark,
                      titleStyle: titleStyle,
                      subtitleStyle: subtitleStyle,
                    ),
                  ),
                ),
              );
            }).toList(growable: false),
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

Size _measureText(
  String text, {
  required TextStyle style,
  required TextScaler textScaler,
  double? maxWidth,
}) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textScaler: textScaler,
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: maxWidth ?? double.infinity);
  return painter.size;
}

class _ToolDrawerItemContent extends StatelessWidget {
  const _ToolDrawerItemContent({
    required this.item,
    required this.itemWidth,
    required this.isDark,
    required this.titleStyle,
    required this.subtitleStyle,
  });

  final _ToolItemData item;
  final double itemWidth;
  final bool isDark;
  final TextStyle titleStyle;
  final TextStyle subtitleStyle;

  @override
  Widget build(BuildContext context) {
    final iconBox = 18.sp + 16.w;
    final contentWidth = itemWidth - 20.w;
    final textScaler = MediaQuery.textScalerOf(context);
    final title = _measureText(
      item.title,
      style: titleStyle,
      textScaler: textScaler,
      maxWidth: contentWidth,
    );
    final subtitle = _measureText(
      item.subtitle,
      style: subtitleStyle,
      textScaler: textScaler,
      maxWidth: contentWidth,
    );
    final inlineTitleWidth = _measureText(
      item.title,
      style: titleStyle,
      textScaler: textScaler,
    ).width;
    final inlineSubtitleWidth = _measureText(
      item.subtitle,
      style: subtitleStyle,
      textScaler: textScaler,
    ).width;
    final stacked =
        iconBox + 8.w + math.max(inlineTitleWidth, inlineSubtitleWidth) >
            contentWidth;
    final icon = Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: isDark ? item.iconColor.withValues(alpha: 0.15) : item.color,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Icon(item.icon, color: item.iconColor, size: 18.sp),
    );
    final labels = SizedBox(
      width: stacked ? contentWidth : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(item.title, style: titleStyle),
          SizedBox(height: 2.h),
          Text(item.subtitle, style: subtitleStyle),
        ],
      ),
    );

    // 台灣繁體中文教學註解：是否改成上下排列只依每張卡片真正需要的
    // 寬度判斷；不能用「文字倍率 >= 某值」猜測，因為中英文與字型都會改變需求。
    return stacked
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [icon, SizedBox(height: 8.h), labels],
          )
        : Row(
            children: [
              icon,
              SizedBox(width: 8.w),
              Expanded(child: labels),
            ],
          );
  }
}
