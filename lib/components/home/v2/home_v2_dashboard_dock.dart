import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:preamble/app/app_state.dart';
import 'package:preamble/pages/home/subpages/life_situation_guide_page.dart';
import 'package:preamble/theme/preamble_tokens.dart';

/// 《緒言 Preamble》溫柔日系粉彩 × 極簡任務導向首屏頂部中樞 (HomeDashboardDock)
///
/// 設計核心：
/// 1. 親切打招呼刊頭 + 小提醒膠囊，拿掉公文印章與冷峻距離感。
/// 2. 圓潤雲朵感「小法助問問框」＋ 粉彩杏橘「公文解讀」按鈕。
/// 3. 四大生活情境大按鈕（租屋／職場／網購／車禍），用一般人聽得懂的話一鍵求助。
/// 4. 四枚粉彩圓圈常用小工具（存證信函、看合約、查法條、工具箱）。
class HomeDashboardDock extends StatefulWidget {
  const HomeDashboardDock({
    super.key,
    required this.onProfileTap,
    required this.onNotificationTap,
    required this.onSearchOrAiTap,
    required this.onMetricTap,
    required this.onToolTap,
    this.onSubmitPrompt,
    this.onScanDocumentTap,
    this.onOpenStatuteDatabase,
  });

  final VoidCallback onProfileTap;
  final VoidCallback onNotificationTap;
  final VoidCallback onSearchOrAiTap;
  final ValueChanged<String> onMetricTap;
  final ValueChanged<String> onToolTap;
  final ValueChanged<String>? onSubmitPrompt;
  final VoidCallback? onScanDocumentTap;
  final ValueChanged<String?>? onOpenStatuteDatabase;

  @override
  State<HomeDashboardDock> createState() => _HomeDashboardDockState();
}

class _HomeDashboardDockState extends State<HomeDashboardDock> {
  final TextEditingController _promptController = TextEditingController();
  final FocusNode _promptFocusNode = FocusNode();
  bool _isCommandExpanded = false;

  static const List<(String label, String prompt)> _quickScenarios = [
    ('退租押金不退', '房東退租時以牆面自然折舊為由扣留兩個月押金，我該怎麼拿回來？'),
    ('加班費與資遣', '公司叫我自願離職又沒給加班費，我該怎麼保護自己？'),
    ('網購不給退貨', '網購商品賣家說拆封就不能退，真的沒有七天鑑賞期嗎？'),
    ('車禍求償怎麼算', '收到對方車禍維修求償單金額很高，零件折舊跟責任比例怎麼算？'),
  ];

  @override
  void initState() {
    super.initState();
    _promptFocusNode.addListener(_handleFocusChange);
    _promptController.addListener(_handleTextChange);
  }

  void _handleFocusChange() {
    if (_promptFocusNode.hasFocus && !_isCommandExpanded && mounted) {
      setState(() {
        _isCommandExpanded = true;
      });
    }
  }

  void _handleTextChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _promptFocusNode
      ..removeListener(_handleFocusChange)
      ..dispose();
    _promptController
      ..removeListener(_handleTextChange)
      ..dispose();
    super.dispose();
  }

  void _submitPrompt([String? preset]) {
    final text = (preset ?? _promptController.text).trim();
    _promptFocusNode.unfocus();
    if (text.isEmpty) {
      widget.onSearchOrAiTap();
      return;
    }
    if (preset == null) {
      _promptController.clear();
    }
    setState(() {
      _isCommandExpanded = false;
    });
    if (widget.onSubmitPrompt != null) {
      widget.onSubmitPrompt!(text);
    } else {
      widget.onSearchOrAiTap();
    }
  }

  void _showLegalRadarSheet(BuildContext context, PreambleState appState) {
    final followedStatutes = appState.followingSummary.followedStatuteIds.length;
    final statuteCount = followedStatutes > 0 ? followedStatutes : 3;
    final draftCount = appState.caseNoteDrafts.length;
    final activeCases = draftCount > 0 ? draftCount : 2;
    final quota = appState.remainingAiQuota;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final t = sheetContext.tokens;
        return SafeArea(
          top: false,
          child: Container(
            decoration: BoxDecoration(
              color: t.surfaceElevated,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
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
                  SizedBox(height: 18.h),
                  Row(
                    children: [
                      Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          color: t.brandContainer,
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Icon(
                          PhosphorIconsFill.sparkle,
                          color: t.brandPrimary,
                          size: 20.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '我的權益小提醒 🌱',
                              style: t.serifTitle(size: 17.5.sp),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              '幫你盯緊重要期限、新規定跟正在處理的事',
                              style: t.sansBody(size: 12.sp),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  _RadarDetailTile(
                    icon: PhosphorIconsRegular.clockCountdown,
                    accentColor: t.semanticUrgent,
                    containerColor: t.semanticUrgentContainer,
                    title: '快到期的處理期限',
                    metric: '剩餘 14 天',
                    subtitle: '租屋押金催告回覆期限快到了，記得把點交照片整理好喔',
                    progress: 0.76,
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      widget.onMetricTap('timeline');
                    },
                  ),
                  SizedBox(height: 10.h),
                  _RadarDetailTile(
                    icon: PhosphorIconsRegular.bellSimpleRinging,
                    accentColor: t.semanticInfo,
                    containerColor: t.semanticInfoContainer,
                    title: '你追蹤的新規定動態',
                    metric: '$statuteCount 則更新',
                    subtitle: '加班補休期限與租屋電費新制已經幫你整理好前後對照',
                    progress: (statuteCount / 5).clamp(0.2, 1.0),
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      widget.onMetricTap('statute');
                    },
                  ),
                  SizedBox(height: 10.h),
                  _RadarDetailTile(
                    icon: PhosphorIconsRegular.folderOpen,
                    accentColor: t.brandPrimary,
                    containerColor: t.brandContainer,
                    title: '進行中的生活案件',
                    metric: '$activeCases 件整理中',
                    subtitle: '點進去看看證據清單完成多少、下一步該做什麼',
                    progress: 0.6,
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      widget.onMetricTap('cases');
                    },
                  ),
                  SizedBox(height: 10.h),
                  _RadarDetailTile(
                    icon: PhosphorIconsRegular.chatsCircle,
                    accentColor: t.accentOnBrassContainer,
                    containerColor: t.accentBrassContainer,
                    title: '今日小法助問問次數',
                    metric: '$quota / 10 次',
                    subtitle: '${appState.accessTier.label}方案・隨時問生活困擾或拍公文翻譯',
                    progress: (quota / 10).clamp(0.0, 1.0),
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      widget.onMetricTap('quota');
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final appState = PreambleScope.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFriendlyMasthead(context, t, appState),
        SizedBox(height: 14.h),
        _buildBuddyCommandBar(context, t),
        SizedBox(height: 18.h),
        _buildLifeSituationGrid(context, t),
        SizedBox(height: 18.h),
        _buildPastelToolCircles(context, t),
      ],
    );
  }

  /// 1. 溫馨問候刊頭：拿掉冷冰冰的英文大標與印章框，用「嗨！今天想問什麼？」親切開場
  Widget _buildFriendlyMasthead(
    BuildContext context,
    PreambleTokens t,
    PreambleState appState,
  ) {
    final displayName = appState.currentUser.displayName;
    final isGuest = appState.currentUser.isGuest;
    final avatarLetter =
        isGuest ? '訪' : (displayName.isNotEmpty ? displayName.substring(0, 1) : '訪');
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final isLargeText = textScale > 1.6;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 3.w,
                      height: 15.h,
                      decoration: BoxDecoration(
                        color: t.brandPrimary,
                        borderRadius: BorderRadius.circular(99.r),
                      ),
                    ),
                    SizedBox(width: 7.w),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '緒言',
                                style: t.serifTitle(
                                  size: 16.5.sp,
                                  color: t.brandPrimary,
                                ),
                              ),
                              TextSpan(
                                text: ' Preamble',
                                style: t.sansBody(
                                  size: 12.sp,
                                  weight: FontWeight.w500,
                                  color: t.textMuted,
                                ),
                              ),
                            ],
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 8.w),
            // 柔和提醒膠囊
            Flexible(
              flex: 0,
              child: Semantics(
                button: true,
                label: '開啟我的權益小提醒',
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showLegalRadarSheet(context, appState),
                    borderRadius: BorderRadius.circular(99.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: t.semanticUrgentContainer,
                        borderRadius: BorderRadius.circular(99.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 13.w,
                            height: 13.w,
                            child: CustomPaint(
                              painter: _MiniRadarArcPainter(
                                trackColor:
                                    t.semanticUrgent.withValues(alpha: 0.22),
                                progressColor: t.semanticUrgent,
                                progress: 0.76,
                              ),
                            ),
                          ),
                          SizedBox(width: 5.w),
                          Flexible(
                            child: Text(
                              '提醒 1',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: t.tabularMetric(
                                size: 11.sp,
                                weight: FontWeight.w700,
                                color: t.semanticUrgent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 6.w),
            // 通知鈴鐺
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onNotificationTap,
                borderRadius: BorderRadius.circular(99.r),
                child: Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: t.surface,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: t.shadowAmbient,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        PhosphorIconsRegular.bell,
                        size: 18.sp,
                        color: t.textPrimary,
                      ),
                      Positioned(
                        right: 8.w,
                        top: 8.w,
                        child: Container(
                          width: 6.5.w,
                          height: 6.5.w,
                          decoration: BoxDecoration(
                            color: t.accentBrass,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 6.w),
            // 個人頭像
            Semantics(
              button: true,
              label: '個人中心與快速設定',
              child: GestureDetector(
                onTap: widget.onProfileTap,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 36.w,
                  height: 36.w,
                  padding: EdgeInsets.all(3.w),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: t.brandPrimary,
                    shape: BoxShape.circle,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      avatarLetter,
                      style: t.sansTitle(
                        size: 13.sp,
                        weight: FontWeight.w700,
                        color: t.brandOnPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: isLargeText ? 6.h : 8.h),
        Text(
          isGuest ? '嗨！遇到什麼困擾嗎？' : '嗨，$displayName！今天好嗎？',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: t.serifTitle(
            size: isLargeText ? 17.sp : 20.sp,
            weight: FontWeight.w800,
            height: 1.25,
          ),
        ),
      ],
    );
  }

  /// 2. 雲朵感「小法助問問框」：圓潤無硬邊框，搭配奶茶杏粉彩「公文解讀」按鈕
  Widget _buildBuddyCommandBar(BuildContext context, PreambleTokens t) {
    final hasText = _promptController.text.trim().isNotEmpty;
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final stackActionBelow = textScale > 1.75;

    final Widget trailingActionButton = hasText
        ? Material(
            color: t.brandPrimary,
            borderRadius: BorderRadius.circular(99.r),
            child: InkWell(
              onTap: _submitPrompt,
              borderRadius: BorderRadius.circular(99.r),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 13.w,
                  vertical: 8.h,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        '送出',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.sansTitle(
                          size: 12.sp,
                          color: t.brandOnPrimary,
                        ),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      PhosphorIconsBold.paperPlaneRight,
                      size: 13.sp,
                      color: t.brandOnPrimary,
                    ),
                  ],
                ),
              ),
            ),
          )
        : Material(
            color: t.accentBrassContainer,
            borderRadius: BorderRadius.circular(99.r),
            child: InkWell(
              onTap: widget.onScanDocumentTap ?? widget.onSearchOrAiTap,
              borderRadius: BorderRadius.circular(99.r),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 11.w,
                  vertical: 8.h,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      PhosphorIconsRegular.camera,
                      size: 14.sp,
                      color: t.accentOnBrassContainer,
                    ),
                    SizedBox(width: 5.w),
                    Flexible(
                      child: Text(
                        '公文解讀',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.sansTitle(
                          size: 11.5.sp,
                          color: t.accentOnBrassContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: t.cardDecoration(
        radius: 24.r,
        fill: t.surface,
        borderColor: (_isCommandExpanded || _promptFocusNode.hasFocus)
            ? t.brandPrimary.withValues(alpha: 0.45)
            : null,
      ),
      padding: EdgeInsets.fromLTRB(12.w, 10.h, 10.w, 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: t.brandContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  PhosphorIconsFill.chatCircleDots,
                  size: 18.sp,
                  color: t.brandPrimary,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: TextField(
                  controller: _promptController,
                  focusNode: _promptFocusNode,
                  textInputAction: TextInputAction.send,
                  onTap: () {
                    if (!_isCommandExpanded) {
                      setState(() {
                        _isCommandExpanded = true;
                      });
                    }
                  },
                  onSubmitted: (_) => _submitPrompt(),
                  style: t.sansBody(
                    size: 13.5.sp,
                    weight: FontWeight.w600,
                    color: t.textPrimary,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 6.h),
                    hintText: '問問小法助，或貼上看不懂的訊息...',
                    hintStyle: t.sansBody(
                      size: 13.sp,
                      color: t.textMuted,
                    ),
                  ),
                ),
              ),
              if (!stackActionBelow) ...[
                SizedBox(width: 6.w),
                trailingActionButton,
              ],
            ],
          ),
          if (stackActionBelow) ...[
            SizedBox(height: 8.h),
            Align(
              alignment: Alignment.centerRight,
              child: trailingActionButton,
            ),
          ],
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: _isCommandExpanded
                ? Padding(
                    padding: EdgeInsets.only(top: 10.h, right: 4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '大家常問的生活狀況：',
                          style: t.sansBody(
                            size: 11.5.sp,
                            color: t.textMuted,
                          ),
                        ),
                        SizedBox(height: 7.h),
                        Wrap(
                          spacing: 6.w,
                          runSpacing: 6.h,
                          children: _quickScenarios.map((scenario) {
                            return InkWell(
                              onTap: () => _submitPrompt(scenario.$2),
                              borderRadius: BorderRadius.circular(99.r),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 11.w,
                                  vertical: 6.h,
                                ),
                                decoration: BoxDecoration(
                                  color: t.surfaceSubtle,
                                  borderRadius: BorderRadius.circular(99.r),
                                ),
                                child: Text(
                                  scenario.$1,
                                  style: t.sansBody(
                                    size: 11.5.sp,
                                    weight: FontWeight.w600,
                                    color: t.textPrimary,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 8.h),
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8.w,
                          runSpacing: 4.h,
                          children: [
                            InkWell(
                              onTap: () {
                                _promptFocusNode.unfocus();
                                final q = _promptController.text.trim();
                                if (widget.onOpenStatuteDatabase != null) {
                                  widget.onOpenStatuteDatabase!(
                                    q.isEmpty ? null : q,
                                  );
                                } else {
                                  widget.onToolTap('database');
                                }
                              },
                              borderRadius: BorderRadius.circular(8.r),
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 2.h),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      PhosphorIconsRegular.bookBookmark,
                                      size: 13.sp,
                                      color: t.brandPrimary,
                                    ),
                                    SizedBox(width: 4.w),
                                    Flexible(
                                      child: Text(
                                        '去六法全書查條文',
                                        style: t.sansBody(
                                          size: 11.5.sp,
                                          weight: FontWeight.w700,
                                          color: t.brandPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                _promptFocusNode.unfocus();
                                setState(() {
                                  _isCommandExpanded = false;
                                });
                              },
                              borderRadius: BorderRadius.circular(8.r),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 4.w,
                                  vertical: 2.h,
                                ),
                                child: Text(
                                  '收起來',
                                  style: t.sansBody(
                                    size: 11.5.sp,
                                    color: t.textMuted,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  /// 3. 極簡任務導向核心：四大常見生活情境粉彩大按鈕（租屋／職場／網購／車禍）
  Widget _buildLifeSituationGrid(BuildContext context, PreambleTokens t) {
    final situations = <({
      String domainId,
      String emoji,
      String title,
      String subtitle,
      String prompt,
      Color cardColor,
      Color badgeColor,
      Color accentColor,
    })>[
      (
        domainId: 'rental',
        emoji: '🏠',
        title: '租屋大小事',
        subtitle: '押金不退・修繕・解約',
        prompt: '退租時房東扣住押金不退，或住處漏水不修，我該怎麼辦？',
        cardColor: t.brandContainer,
        badgeColor: t.surface,
        accentColor: t.brandOnContainer,
      ),
      (
        domainId: 'labor',
        emoji: '💼',
        title: '職場與薪資',
        subtitle: '加班費・資遣・離職',
        prompt: '公司沒給加班費或突然要我離職，怎麼算補償與自保？',
        cardColor: t.accentBrassContainer,
        badgeColor: t.surface,
        accentColor: t.accentOnBrassContainer,
      ),
      (
        domainId: 'shopping',
        emoji: '🛍️',
        title: '網購與消費',
        subtitle: '七天退貨・瑕疵・詐騙',
        prompt: '網購收到瑕疵品賣家不給退，或遇到網路詐騙怎麼處理？',
        cardColor: t.semanticInfoContainer,
        badgeColor: t.surface,
        accentColor: t.semanticInfo,
      ),
      (
        domainId: 'traffic',
        emoji: '🚗',
        title: '車禍與賠償',
        subtitle: '維修折舊・和解・求償',
        prompt: '發生車禍對方開天價維修費，零件折舊跟談判和解怎麼處理？',
        cardColor: t.semanticUrgentContainer,
        badgeColor: t.surface,
        accentColor: t.semanticUrgent,
      ),
    ];

    final textScale = MediaQuery.textScalerOf(context).scale(1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '遇到哪種狀況？點一下立即幫你分析',
          style: t.sansTitle(
            size: 13.5.sp,
            color: t.textSecondary,
          ),
        ),
        SizedBox(height: 10.h),
        LayoutBuilder(
          builder: (context, constraints) {
            final singleCol = constraints.maxWidth < 290 || textScale > 1.7;
            if (singleCol) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (int i = 0; i < situations.length; i++) ...[
                    if (i > 0) SizedBox(height: 10.h),
                    _buildLifeSituationCard(
                      t,
                      situations[i],
                      maxSubtitleLines: null,
                    ),
                  ],
                ],
              );
            }

            final rows = <List<int>>[];
            for (int i = 0; i < situations.length; i += 2) {
              rows.add([
                i,
                if (i + 1 < situations.length) i + 1,
              ]);
            }

            return Column(
              children: [
                for (int r = 0; r < rows.length; r++) ...[
                  if (r > 0) SizedBox(height: 10.h),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: _buildLifeSituationCard(
                            t,
                            situations[rows[r][0]],
                            maxSubtitleLines: 3,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: rows[r].length > 1
                              ? _buildLifeSituationCard(
                                  t,
                                  situations[rows[r][1]],
                                  maxSubtitleLines: 3,
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildLifeSituationCard(
    PreambleTokens t,
    ({
      String domainId,
      String emoji,
      String title,
      String subtitle,
      String prompt,
      Color cardColor,
      Color badgeColor,
      Color accentColor,
    }) item, {
    required int? maxSubtitleLines,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        // 台灣繁體中文教學註解：點擊四大生活情境卡改為進入 85% 知識脈絡閱讀頁，
        // 讓使用者先看懂權利關係，再透過右下角懸浮按鈕呼叫小法助或實戰工具。
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => LifeSituationGuidePage(domainId: item.domainId),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20.r),
        child: Ink(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: item.cardColor,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: item.badgeColor,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  item.emoji,
                  style: TextStyle(fontSize: 18.sp),
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                item.title,
                style: t.serifTitle(
                  size: 15.sp,
                  color: t.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 3.h),
              Text(
                item.subtitle,
                style: t.sansBody(
                  size: 11.5.sp,
                  color: item.accentColor,
                  weight: FontWeight.w600,
                ),
                maxLines: maxSubtitleLines,
                overflow: maxSubtitleLines == null
                    ? TextOverflow.visible
                    : TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 4. 溫柔粉彩圓圈常用小工具（存證信函、看合約、查法條、工具箱）
  Widget _buildPastelToolCircles(BuildContext context, PreambleTokens t) {
    final actions = <({
      String label,
      IconData icon,
      String key,
      Color bg,
      Color fg,
    })>[
      (
        label: '存證信函',
        icon: PhosphorIconsRegular.envelopeSimpleOpen,
        key: 'notice',
        bg: t.brandContainer,
        fg: t.brandOnContainer,
      ),
      (
        label: '契約審查',
        icon: PhosphorIconsRegular.fileMagnifyingGlass,
        key: 'contract',
        bg: t.accentBrassContainer,
        fg: t.accentOnBrassContainer,
      ),
      (
        label: '六法文庫',
        icon: PhosphorIconsRegular.bookOpenText,
        key: 'database',
        bg: t.semanticInfoContainer,
        fg: t.semanticInfo,
      ),
      (
        label: '實戰工具',
        icon: PhosphorIconsRegular.toolbox,
        key: 'all_tools',
        bg: t.semanticUrgentContainer,
        fg: t.semanticUrgent,
      ),
    ];

    final textScale = MediaQuery.textScalerOf(context).scale(1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final useTwoByTwo = constraints.maxWidth < 330 || textScale > 1.35;
        if (useTwoByTwo) {
          final tileWidth = (constraints.maxWidth - 10.w) / 2;
          return Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: actions.map((item) {
              return SizedBox(
                width: tileWidth,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => widget.onToolTap(item.key),
                    borderRadius: BorderRadius.circular(18.r),
                    child: Ink(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 10.h,
                      ),
                      decoration: t.cardDecoration(radius: 18.r, elevated: false),
                      child: Row(
                        children: [
                          Container(
                            width: 34.w,
                            height: 34.w,
                            decoration: BoxDecoration(
                              color: item.bg,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(item.icon, size: 17.sp, color: item.fg),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              item.label,
                              style: t.sansTitle(size: 12.sp),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
          decoration: t.cardDecoration(radius: 22.r),
          child: Row(
            children: [
              for (var i = 0; i < actions.length; i++)
                Expanded(
                  child: InkWell(
                    onTap: () => widget.onToolTap(actions[i].key),
                    borderRadius: BorderRadius.circular(14.r),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.h),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 44.w,
                            height: 44.w,
                            decoration: BoxDecoration(
                              color: actions[i].bg,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              actions[i].icon,
                              size: 20.sp,
                              color: actions[i].fg,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            actions[i].label,
                            style: t.sansTitle(size: 11.5.sp),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _RadarDetailTile extends StatelessWidget {
  const _RadarDetailTile({
    required this.icon,
    required this.accentColor,
    required this.containerColor,
    required this.title,
    required this.metric,
    required this.subtitle,
    required this.progress,
    required this.onTap,
  });

  final IconData icon;
  final Color accentColor;
  final Color containerColor;
  final String title;
  final String metric;
  final String subtitle;
  final double progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Ink(
          padding: EdgeInsets.all(14.w),
          decoration: t.subtleBoxDecoration(radius: 18.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 34.w,
                    height: 34.w,
                    decoration: BoxDecoration(
                      color: containerColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 17.sp, color: accentColor),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      title,
                      style: t.sansTitle(size: 13.5.sp),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    metric,
                    style: t.tabularMetric(
                      size: 12.5.sp,
                      color: accentColor,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    PhosphorIconsRegular.caretRight,
                    size: 14.sp,
                    color: t.textMuted,
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                subtitle,
                style: t.sansBody(size: 12.sp),
              ),
              SizedBox(height: 10.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(99.r),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6.h,
                  backgroundColor: t.surface,
                  valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniRadarArcPainter extends CustomPainter {
  const _MiniRadarArcPainter({
    required this.trackColor,
    required this.progressColor,
    required this.progress,
  });

  final Color trackColor;
  final Color progressColor;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 2.2;
    final rect = const Offset(stroke / 2, stroke / 2) &
        Size(size.width - stroke, size.height - stroke);

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke;

    canvas.drawArc(rect, 0, math.pi * 2, false, trackPaint);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * progress.clamp(0.0, 1.0),
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _MiniRadarArcPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor;
  }
}
