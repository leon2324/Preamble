import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:preamble/app/app_state.dart';
import 'package:preamble/components/home/home_content.dart';
import 'package:preamble/components/home/v2/home_v2_sections.dart';
import 'package:preamble/components/lawyer/lawyer_referral_sheet.dart';
import 'package:preamble/components/navigation/app_shell_content_insets.dart';
import 'package:preamble/components/safety/plain_document_translator_sheet.dart';
import 'package:preamble/data/lawyer/lawyer_models.dart';
import 'package:preamble/data/moj/moj_feed_item.dart';
import 'package:preamble/features/case_library/data/case_library_data.dart';
import 'package:preamble/features/case_library/data/case_library_repository.dart';
import 'package:preamble/features/case_library/pages/case_dossier_detail_page.dart';
import 'package:preamble/pages/following/following_page.dart';
import 'package:preamble/pages/home/home_subpages.dart';
import 'package:preamble/pages/journal/data/journal_page_items.dart';
import 'package:preamble/pages/journal/widgets/discussion_detail_page.dart';
import 'package:preamble/pages/journal/widgets/journal_palette.dart';
import 'package:preamble/pages/learning/know_law_page.dart';
import 'package:preamble/pages/learning/statute_database_page.dart';
import 'package:preamble/pages/profile/profile_page.dart';
import 'package:preamble/pages/tools/legal_toolkit_hub_page.dart';
import 'package:preamble/theme/adaptive_layout.dart';
import 'package:preamble/theme/preamble_tokens.dart';

/// 《緒言 Preamble》1+2 黃金融合首頁。
///
/// 採用「靜奢律政編輯風 × 雙重編碼」架構：
/// 頂部收斂為單一漸進式問診艙與 4 枚工具入口磚，並讓「今日頭條雙重編碼導讀大卡」
/// 於首屏完整呈現，下方承接 12 則真實資料驅動的四類雙重編碼動態流。
class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.onNavigateToTab,
  });

  final void Function(
    int targetOriginalIndex, {
    int? subTabIndex,
    String? toolTab,
  }) onNavigateToTab;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _openStatuteDatabase({String? initialQuery}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StatuteDatabasePage(initialQuery: initialQuery ?? ''),
      ),
    );
  }

  void _openFollowingUpdates() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const FollowingPage(initialTab: 'updates'),
      ),
    );
  }

  void _openOfficialFeed(MojFeedCategory category) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => OfficialFeedPage(category: category),
      ),
    );
  }

  void _openLifeLegalTip(HomeNewsletterItem item) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LifeLegalTipDetailPage(item: item),
      ),
    );
  }

  void _openProfilePage() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const ProfilePage(showBackButton: true),
      ),
    );
  }

  void _openLegalToolkit({String? initialToolKey}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LegalToolkitHubPage(initialToolKey: initialToolKey),
      ),
    );
  }

  void _openQuickSettingsPanel() {
    final appState = PreambleScope.of(context);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) {
        return AnimatedBuilder(
          animation: appState,
          builder: (context, _) {
            final t = context.tokens;
            final displayName = appState.currentUser.displayName;
            final initial = appState.currentUser.isGuest
                ? '訪'
                : (displayName.isNotEmpty ? displayName.substring(0, 1) : '訪');

            return SafeArea(
              top: false,
              child: Container(
                decoration: BoxDecoration(
                  color: t.surfaceElevated,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(24.r)),
                  border: Border.all(color: t.border),
                ),
                padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 24.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 42.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: t.borderStrong,
                          borderRadius: BorderRadius.circular(99.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 18.h),
                    Row(
                      children: [
                        Container(
                          width: 48.w,
                          height: 48.w,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: t.brandPrimaryStrong,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: t.accentBrass.withValues(alpha: 0.55),
                              width: 1.4,
                            ),
                          ),
                          child: Text(
                            initial,
                            style: t.serifTitle(
                              size: 18.sp,
                              color: const Color(0xFFFAF8F4),
                            ),
                          ),
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appState.currentUser.isGuest
                                    ? '訪客會員中心'
                                    : displayName,
                                style: t.serifTitle(size: 17.sp),
                              ),
                              SizedBox(height: 3.h),
                              Text(
                                '${appState.accessTier.label}方案 ｜ 今日 AI 問診額度：${appState.remainingAiQuota} / 10',
                                style: t.sansBody(size: 12.sp),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 18.h),
                    Divider(color: t.border, height: 1),
                    SizedBox(height: 14.h),
                    Text(
                      '閱讀環境設定',
                      style: t.sansTitle(size: 13.sp, color: t.textSecondary),
                    ),
                    SizedBox(height: 10.h),
                    Container(
                      decoration:
                          t.cardDecoration(radius: 16.r, elevated: false),
                      padding:
                          EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                      child: Row(
                        children: [
                          Container(
                            width: 34.w,
                            height: 34.w,
                            decoration: BoxDecoration(
                              color: t.brandContainer,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Icon(
                              PhosphorIconsRegular.moonStars,
                              color: t.brandPrimary,
                              size: 18.sp,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '靜奢深色閱讀模式',
                                  style: t.sansTitle(size: 13.5.sp),
                                ),
                                Text(
                                  '切換深曜墨綠暗色畫布，減緩夜間長文閱讀疲勞',
                                  style: t.sansBody(size: 11.5.sp),
                                ),
                              ],
                            ),
                          ),
                          Switch.adaptive(
                            value: appState.isDarkMode,
                            onChanged: appState.setDarkMode,
                            activeThumbColor: t.brandPrimary,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 18.h),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.of(sheetContext).pop();
                          _openProfilePage();
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: t.brandPrimaryStrong,
                          foregroundColor: const Color(0xFFFAF8F4),
                          padding: EdgeInsets.symmetric(vertical: 13.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                        ),
                        icon: Icon(
                          PhosphorIconsRegular.userCircle,
                          size: 18.sp,
                        ),
                        label: Text(
                          '前往個人中心與收藏紀錄',
                          style: t.sansTitle(
                            size: 13.5.sp,
                            color: const Color(0xFFFAF8F4),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showNotificationBubble() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) {
        final t = sheetContext.tokens;
        return SafeArea(
          top: false,
          child: Container(
            decoration: BoxDecoration(
              color: t.surfaceElevated,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              border: Border.all(color: t.border),
            ),
            padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 24.h),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: t.borderStrong,
                        borderRadius: BorderRadius.circular(99.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Icon(
                        PhosphorIconsFill.bellRinging,
                        color: t.accentBrass,
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          '法務動態通知',
                          style: t.serifTitle(size: 17.sp),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        visualDensity: VisualDensity.compact,
                        icon: Icon(
                          PhosphorIconsRegular.x,
                          color: t.textSecondary,
                          size: 18.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  _buildNotificationTile(
                    t: t,
                    category: '修法警示',
                    title: '住宅租賃定型化契約電費新制已生效，超收條款依法無效。',
                    time: '15 分鐘前',
                    icon: PhosphorIconsRegular.gitDiff,
                    accent: t.semanticInfo,
                    accentBg: t.semanticInfoContainer,
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _openStatuteDatabase(initialQuery: '租賃');
                    },
                  ),
                  SizedBox(height: 10.h),
                  _buildNotificationTile(
                    t: t,
                    category: '案卷更新',
                    title: '您關注的「外送平台外送員僱傭關係認定案」新增白話爭點對照。',
                    time: '2 小時前',
                    icon: PhosphorIconsRegular.scales,
                    accent: t.brandPrimary,
                    accentBg: t.brandContainer,
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _openCaseDossier('case-delivery-labor-2152');
                    },
                  ),
                  SizedBox(height: 10.h),
                  _buildNotificationTile(
                    t: t,
                    category: '自救提醒',
                    title: '實戰工具館已備妥存證信函簽名匯出與車禍折舊試算模組。',
                    time: '今天',
                    icon: PhosphorIconsRegular.toolbox,
                    accent: t.accentOnBrassContainer,
                    accentBg: t.accentBrassContainer,
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _openLegalToolkit(initialToolKey: '租屋催告');
                    },
                  ),
                  SizedBox(height: 18.h),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(sheetContext).pop();
                        _openFollowingUpdates();
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: t.borderStrong),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: Text(
                        '檢視全部追蹤與法規異動',
                        style: t.sansTitle(size: 13.sp),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationTile({
    required PreambleTokens t,
    required String category,
    required String title,
    required String time,
    required IconData icon,
    required Color accent,
    required Color accentBg,
    VoidCallback? onTap,
  }) {
    final content = Padding(
      padding: EdgeInsets.all(12.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34.w,
            height: 34.w,
            decoration: BoxDecoration(
              color: accentBg,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: accent, size: 17.sp),
          ),
          SizedBox(width: 11.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      category,
                      style: t.sansTitle(size: 11.5.sp, color: accent),
                    ),
                    Text(
                      time,
                      style: t.tabularMetric(
                        size: 11.sp,
                        weight: FontWeight.w500,
                        color: t.textMuted,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  title,
                  style: t.sansBody(
                    size: 12.5.sp,
                    color: t.textPrimary,
                    height: 1.42,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null) ...[
            SizedBox(width: 6.w),
            Padding(
              padding: EdgeInsets.only(top: 10.h),
              child: Icon(
                PhosphorIconsBold.caretRight,
                size: 14.sp,
                color: t.textMuted,
              ),
            ),
          ],
        ],
      ),
    );

    return Container(
      decoration: t.cardDecoration(radius: 16.r, elevated: false),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Material(
          type: MaterialType.transparency,
          child: onTap == null
              ? content
              : InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(16.r),
                  child: content,
                ),
        ),
      ),
    );
  }

  void _openAiAssistantOrSearch({String? initialPrompt}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LawAssistantChatPage(
          initialPrompt:
              initialPrompt ?? '你好小法助，我想了解常見生活法律問題與蒐證建議。',
        ),
      ),
    );
  }

  void _handleMetricTap(String metric) {
    switch (metric) {
      case 'statute':
      case 'timeline':
        _openFollowingUpdates();
        break;
      case 'quota':
        _openQuickSettingsPanel();
        break;
      case 'cases':
        widget.onNavigateToTab(3, subTabIndex: 1);
        break;
    }
  }

  void _handleToolTap(String toolKey) {
    switch (toolKey) {
      case 'notice':
        _openLegalToolkit(initialToolKey: '租屋催告');
        break;
      case 'contract':
        _openLegalToolkit(initialToolKey: '契約審閱');
        break;
      case 'database':
        _openStatuteDatabase();
        break;
      case 'all_tools':
        _openLegalToolkit();
        break;
      case 'lawyer':
        LawyerReferralSheet.show(
          context,
          caseBrief: const CaseBrief(
            disputeCategory: '生活法律諮詢',
            factSummary: '預約專業認證律師進行法律諮詢與權益評估。',
            demands: ['評估法律可行性與權益保障'],
            evidences: ['合約或相關對話證明'],
            possibleLegalBasis: ['民法相關規定'],
          ),
        );
        break;
    }
  }

  void _openDiscussionTopic(int topicIndex) {
    final matched = discussionTrendItems.firstWhere(
      (item) => item.fullTopicIndex == topicIndex,
      orElse: () => discussionTrendItems.first,
    );
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (ctx) => DiscussionDetailPage(
          item: matched,
          palette: JournalPalette.of(ctx),
        ),
      ),
    );
  }

  void _openCaseDossier(String caseId) {
    final targetCase = caseLibraryCases.firstWhere(
      (c) => c.id == caseId,
      orElse: () => CaseLibraryRepository.instance.getCaseById(caseId),
    );
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CaseDossierDetailPage(book: targetCase),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final layout = context.homeSearchLayout;
    final additionalBottom = AppShellContentInsets.additionalBottomOf(context);
    final topContentPadding =
        context.hasLargeTopInset ? context.topSafeInset + 10.h : 14.h;

    return ColoredBox(
      color: t.canvas,
      child: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      EdgeInsets.fromLTRB(16.w, topContentPadding, 16.w, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HomeDashboardDock(
                        onProfileTap: _openQuickSettingsPanel,
                        onNotificationTap: _showNotificationBubble,
                        onSearchOrAiTap: _openAiAssistantOrSearch,
                        onSubmitPrompt: (prompt) =>
                            _openAiAssistantOrSearch(initialPrompt: prompt),
                        onScanDocumentTap: () =>
                            PlainDocumentTranslatorSheet.show(context),
                        onOpenStatuteDatabase: (query) =>
                            _openStatuteDatabase(initialQuery: query),
                        onMetricTap: _handleMetricTap,
                        onToolTap: _handleToolTap,
                      ),
                      SizedBox(height: 14.h),
                      HomeFeedStreamView(
                        onNavigateToCase: _openCaseDossier,
                        onNavigateToOfficialNews: () =>
                            _openOfficialFeed(MojFeedCategory.news),
                        onNavigateToTipDetail: _openLifeLegalTip,
                        onNavigateToStatuteDatabase: _openStatuteDatabase,
                        onNavigateToStatuteQuery: (query) =>
                            _openStatuteDatabase(initialQuery: query),
                        onNavigateToDiscussion: () => widget.onNavigateToTab(3),
                        onNavigateToDiscussionTopic: _openDiscussionTopic,
                      ),
                      SizedBox(height: 112.h + additionalBottom),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (layout.hasLargeTopInset)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Container(
                  height: layout.topMaskHeight.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0, 0.12, 0.28, 0.52, 1],
                      colors: [
                        t.canvas,
                        t.canvas.withValues(alpha: 0.92),
                        t.canvas.withValues(alpha: 0.56),
                        t.canvas.withValues(alpha: 0.18),
                        t.canvas.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
