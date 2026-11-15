part of '../global_search_page.dart';

// 《緒言 Preamble》Tab 3「問診」雙軌中樞首頁（AI 法律問診 ⇄ 法規・裁判檢索）。
// 融合靜奢律政編輯風刊頭、雙模式切換器、六大生活爭議結構化問診入口、
// 公文白話解讀與實戰工具捷徑，以及四大法源精準檢索索引。

class _HubEditorialHeader extends StatelessWidget {
  const _HubEditorialHeader({
    required this.onOpenTranslator,
    required this.onOpenToolkit,
  });

  final VoidCallback onOpenTranslator;
  final VoidCallback onOpenToolkit;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    PhosphorIconsFill.scales,
                    size: 13.sp,
                    color: t.accentBrass,
                  ),
                  SizedBox(width: 5.w),
                  Flexible(
                    child: Text(
                      '小法助在線・查法條也很簡單',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _SearchText.captionStrong(context).copyWith(
                        color: t.accentOnBrassContainer,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 3.h),
              Text(
                '問問小法助',
                style: _SearchText.serifHero(context),
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: '公文白話解讀',
              onPressed: onOpenTranslator,
              style: IconButton.styleFrom(
                backgroundColor: t.accentBrassContainer,
                foregroundColor: t.accentOnBrassContainer,
                minimumSize: const Size(40, 40),
                padding: EdgeInsets.all(8.r),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  side: BorderSide(
                    color: t.accentBrass.withValues(alpha: 0.32),
                  ),
                ),
              ),
              icon: Icon(PhosphorIconsRegular.scan, size: 19.sp),
            ),
            SizedBox(width: 8.w),
            IconButton(
              tooltip: '法務實戰工具',
              onPressed: onOpenToolkit,
              style: IconButton.styleFrom(
                backgroundColor: t.surface,
                foregroundColor: t.brandPrimary,
                minimumSize: const Size(40, 40),
                padding: EdgeInsets.all(8.r),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  side: BorderSide(color: t.borderStrong),
                ),
              ),
              icon: Icon(PhosphorIconsRegular.toolbox, size: 19.sp),
            ),
          ],
        ),
      ],
    );
  }
}

class _DualModeSegmentedSwitch extends StatelessWidget {
  const _DualModeSegmentedSwitch({
    required this.mode,
    required this.onModeChanged,
  });

  final _HubMode mode;
  final ValueChanged<_HubMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: t.subtleBoxDecoration(
        radius: 14.r,
        fill: t.surfaceSubtle,
        borderColor: t.borderStrong,
      ),
      child: Row(
        children: [
          Expanded(
            child: _SegmentButton(
              label: 'AI 法律問診',
              icon: mode == _HubMode.consultation
                  ? PhosphorIconsFill.chatsCircle
                  : PhosphorIconsRegular.chatsCircle,
              active: mode == _HubMode.consultation,
              onTap: () => onModeChanged(_HubMode.consultation),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: _SegmentButton(
              label: '法規・裁判檢索',
              icon: mode == _HubMode.legalSearch
                  ? PhosphorIconsFill.bookOpenText
                  : PhosphorIconsRegular.bookOpenText,
              active: mode == _HubMode.legalSearch,
              onTap: () => onModeChanged(_HubMode.legalSearch),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: active ? t.brandPrimaryStrong : Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
          border: active
              ? Border.all(color: t.accentBrass.withValues(alpha: 0.38))
              : null,
          boxShadow: active
              ? [
                  BoxShadow(
                    color: t.shadowAmbient,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15.sp,
              color: active ? t.accentBrass : t.textMuted,
            ),
            SizedBox(width: 6.w),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _SearchText.captionStrong(context).copyWith(
                  fontSize: 12.5.sp,
                  color: active ? const Color(0xFFFAF8F4) : t.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConsultationPromptCard extends StatelessWidget {
  const _ConsultationPromptCard({
    required this.controller,
    required this.quotaText,
    required this.onQuickAnalyze,
    required this.onLaunchChat,
    required this.onClear,
  });

  final TextEditingController controller;
  final String quotaText;
  final ValueChanged<String> onQuickAnalyze;
  final ValueChanged<String?> onLaunchChat;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return _ProtoCard(
      background: t.surface,
      borderColor: t.borderStrong,
      padding: EdgeInsets.all(15.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32.r,
                height: 32.r,
                decoration: BoxDecoration(
                  color: t.brandContainer,
                  borderRadius: BorderRadius.circular(9.r),
                ),
                child: Icon(
                  PhosphorIconsFill.sparkle,
                  size: 16.sp,
                  color: t.brandPrimary,
                ),
              ),
              SizedBox(width: 9.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '嗨！我是小法助，遇到什麼麻煩嗎？',
                      style: _SearchText.bodyStrong(context).copyWith(
                        color: t.brandPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '用白話幫你拆解重點、找出法條跟下一步怎麼做',
                      style: _SearchText.caption(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 11.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: t.subtleBoxDecoration(
              radius: 13.r,
              fill: t.surfaceSubtle,
              borderColor: t.borderStrong,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  PhosphorIconsRegular.chatsCircle,
                  size: 18.sp,
                  color: t.brandPrimary,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: TextField(
                    controller: controller,
                    onTapOutside: (_) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    textInputAction: TextInputAction.search,
                    onSubmitted: onQuickAnalyze,
                    minLines: 1,
                    maxLines: 3,
                    style: _SearchText.bodyStrong(context),
                    decoration: InputDecoration(
                      hintText: '描述遇到的糾紛（例：退租房東扣押金、無預警被資遣）...',
                      hintStyle: _SearchText.body(context).copyWith(
                        color: t.textMuted,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                    ),
                  ),
                ),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller,
                  builder: (context, value, _) {
                    if (value.text.isEmpty) return const SizedBox.shrink();
                    return IconButton(
                      tooltip: '清除輸入',
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        PhosphorIconsRegular.x,
                        size: 16.sp,
                        color: t.textMuted,
                      ),
                      onPressed: onClear,
                    );
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 11.h),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              GestureDetector(
                onTap: () {
                  CustomToast.show(
                    context,
                    '目前提問額度依本機狀態計算，每日自動重置。',
                  );
                },
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: t.brandContainer,
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6.r,
                        height: 6.r,
                        decoration: BoxDecoration(
                          color: t.brandPrimary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Flexible(
                        child: Text(
                          quotaText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _SearchText.metric(
                            context,
                            size: 11.sp,
                            color: t.brandOnContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Wrap(
                spacing: 8.w,
                runSpacing: 6.h,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      final text = controller.text.trim();
                      onQuickAnalyze(text.isEmpty ? '租屋押金扣款' : text);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: t.brandPrimary,
                      backgroundColor: t.surface,
                      side: BorderSide(color: t.borderStrong),
                      minimumSize: const Size(0, 38),
                      padding: EdgeInsets.symmetric(
                        horizontal: 11.w,
                        vertical: 8.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    icon: Icon(PhosphorIconsRegular.scales, size: 14.sp),
                    label: Text(
                      '白話快析',
                      style: _SearchText.captionStrong(context).copyWith(
                        color: t.brandPrimary,
                      ),
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () {
                      final text = controller.text.trim();
                      onLaunchChat(text.isEmpty ? null : text);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: t.brandPrimaryStrong,
                      foregroundColor: t.brandOnPrimary,
                      minimumSize: const Size(0, 38),
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(99.r),
                      ),
                    ),
                    icon: Icon(
                      PhosphorIconsFill.paperPlaneRight,
                      size: 13.sp,
                      color: t.brandOnPrimary,
                    ),
                    label: Text(
                      '跟小法助聊聊',
                      style: _SearchText.captionStrong(context).copyWith(
                        color: t.brandOnPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PracticalUtilityPair extends StatelessWidget {
  const _PracticalUtilityPair({
    required this.onOpenTranslator,
    required this.onOpenToolkit,
  });

  final VoidCallback onOpenTranslator;
  final VoidCallback onOpenToolkit;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final singleCol = constraints.maxWidth < 340 || textScale > 1.25;
        final itemWidth = singleCol
            ? constraints.maxWidth
            : (constraints.maxWidth - 10.w) / 2;

        return Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: [
            SizedBox(
              width: itemWidth,
              child: _InteractiveCard(
                onTap: onOpenTranslator,
                background: t.brandPrimaryStrong,
                borderColor: t.accentBrass.withValues(alpha: 0.38),
                padding: EdgeInsets.all(13.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32.r,
                          height: 32.r,
                          decoration: BoxDecoration(
                            color: t.accentBrass.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(9.r),
                          ),
                          child: Icon(
                            PhosphorIconsRegular.scan,
                            color: t.accentBrass,
                            size: 17.sp,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          PhosphorIconsRegular.arrowUpRight,
                          color: t.accentBrass,
                          size: 15.sp,
                        ),
                      ],
                    ),
                    SizedBox(height: 9.h),
                    Text(
                      '公文拍照／貼文白話翻譯',
                      style: _SearchText.serifTileTitle(context).copyWith(
                        color: const Color(0xFFFAF8F4),
                        fontSize: 13.5.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '3 秒拆解存證信函、律師函與傳票期限對策',
                      style: _SearchText.caption(context).copyWith(
                        color: const Color(0xFFD6E2DC),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _InteractiveCard(
                onTap: onOpenToolkit,
                background: t.surface,
                borderColor: t.borderStrong,
                padding: EdgeInsets.all(13.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32.r,
                          height: 32.r,
                          decoration: BoxDecoration(
                            color: t.brandContainer,
                            borderRadius: BorderRadius.circular(9.r),
                          ),
                          child: Icon(
                            PhosphorIconsRegular.toolbox,
                            color: t.brandPrimary,
                            size: 17.sp,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          PhosphorIconsRegular.arrowUpRight,
                          color: t.textMuted,
                          size: 15.sp,
                        ),
                      ],
                    ),
                    SizedBox(height: 9.h),
                    Text(
                      '實戰存證／試算工具',
                      style: _SearchText.serifTileTitle(context).copyWith(
                        fontSize: 13.5.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '存證信函草擬、契約審查、車禍折舊與加班試算',
                      style: _SearchText.caption(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DisputeDomainSpec {
  const _DisputeDomainSpec({
    required this.title,
    required this.statuteRef,
    required this.issues,
    required this.prompt,
    required this.icon,
  });

  final String title;
  final String statuteRef;
  final String issues;
  final String prompt;
  final IconData icon;
}

class _DisputeDomainIntakeGrid extends StatelessWidget {
  const _DisputeDomainIntakeGrid({
    required this.onSelectPrompt,
    required this.onLaunchChat,
  });

  final ValueChanged<String> onSelectPrompt;
  final ValueChanged<String> onLaunchChat;

  static const _domains = <_DisputeDomainSpec>[
    _DisputeDomainSpec(
      title: '租屋居住',
      statuteRef: '民法 §429・租賃條例',
      issues: '押金扣抵・修繕責任・提前解約',
      prompt: '退租時房東以自然折舊為由扣押金不退，我該如何爭取返還？',
      icon: PhosphorIconsRegular.houseLine,
    ),
    _DisputeDomainSpec(
      title: '勞動職場',
      statuteRef: '勞基法 §11・§24',
      issues: '無預警資遣・加班費・非自願離職',
      prompt: '公司無預警資遣我且拒絕開立非自願離職證明書，如何自保？',
      icon: PhosphorIconsRegular.briefcase,
    ),
    _DisputeDomainSpec(
      title: '車禍賠償',
      statuteRef: '民法 §184・§217',
      issues: '初判肇責・零件折舊・過失傷害',
      prompt: '車禍對方要求全額賠償全新零件維修費，如何主張折舊與調解？',
      icon: PhosphorIconsRegular.carProfile,
    ),
    _DisputeDomainSpec(
      title: '消費網購',
      statuteRef: '消保法 §19',
      issues: '七日鑑賞期・瑕疵退貨・定型化契約',
      prompt: '網購收到瑕疵商品，賣家以已拆封為由拒絕七天鑑賞期退貨怎麼辦？',
      icon: PhosphorIconsRegular.shoppingBagOpen,
    ),
    _DisputeDomainSpec(
      title: '家事繼承',
      statuteRef: '民法 §1030-1・§1174',
      issues: '剩餘財產分配・拋棄繼承・扶養費',
      prompt: '親人過世留有債務，辦理拋棄繼承或限定繼承的法定時效與步驟？',
      icon: PhosphorIconsRegular.usersThree,
    ),
    _DisputeDomainSpec(
      title: '反詐防身',
      statuteRef: '刑法 §339・洗錢防制',
      issues: '165 緊急圈存・警示帳戶・三方詐騙',
      prompt: '遭遇網購或投資詐騙剛匯款，如何啟動 165 緊急圈存與解除警示帳戶？',
      icon: PhosphorIconsRegular.shieldWarning,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final singleCol = constraints.maxWidth < 310 || textScale > 1.3;
        final itemWidth = singleCol
            ? constraints.maxWidth
            : (constraints.maxWidth - 10.w) / 2;

        return Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: _domains.map((domain) {
            return SizedBox(
              width: itemWidth,
              child: _InteractiveCard(
                onTap: () => onSelectPrompt(domain.prompt),
                padding: EdgeInsets.all(13.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _IconBox(
                          icon: domain.icon,
                          color: t.brandPrimary,
                          backgroundColor: t.brandContainer,
                        ),
                        const Spacer(),
                        Tooltip(
                          message: '直接進入多輪問診',
                          child: InkWell(
                            onTap: () => onLaunchChat(domain.prompt),
                            borderRadius: BorderRadius.circular(8.r),
                            child: Container(
                              padding: EdgeInsets.all(6.r),
                              decoration: BoxDecoration(
                                color: t.surfaceSubtle,
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(color: t.border),
                              ),
                              child: Icon(
                                PhosphorIconsRegular.chatsCircle,
                                size: 14.sp,
                                color: t.accentBrass,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 9.h),
                    Text(
                      domain.title,
                      style: _SearchText.tileTitle(context),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      domain.statuteRef,
                      style: _SearchText.serifBody(context).copyWith(
                        fontSize: 11.5.sp,
                        color: t.brandPrimary,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      domain.issues,
                      style: _SearchText.caption(context),
                    ),
                  ],
                ),
              ),
            );
          }).toList(growable: false),
        );
      },
    );
  }
}

class _HorizontalRecentFootprints extends StatelessWidget {
  const _HorizontalRecentFootprints({
    required this.recent,
    required this.onQuery,
  });

  final List<String> recent;
  final ValueChanged<String> onQuery;

  @override
  Widget build(BuildContext context) {
    if (recent.isEmpty) return const SizedBox.shrink();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      clipBehavior: Clip.none,
      child: Row(
        children: recent.map((query) {
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: _Pill(
              label: query,
              icon: PhosphorIconsRegular.clockCounterClockwise,
              onTap: () => onQuery(query),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _InspirationScenario {
  const _InspirationScenario(
    this.query,
    this.subtitle,
    this.statuteTag,
    this.icon,
  );

  final String query;
  final String subtitle;
  final String statuteTag;
  final IconData icon;
}

class _InspirationCarousel extends StatelessWidget {
  const _InspirationCarousel({required this.onQuery});

  final ValueChanged<String> onQuery;

  static const _items = <_InspirationScenario>[
    _InspirationScenario(
      '租屋押金扣款',
      '退租時房東主張自然折舊扣抵押金如何爭取返還？',
      '民法第 429・430 條',
      PhosphorIconsRegular.houseLine,
    ),
    _InspirationScenario(
      '公司無預警資遣',
      '遭雇主終止契約，如何請求預告工資與資遣費？',
      '勞動基準法第 11・16 條',
      PhosphorIconsRegular.briefcase,
    ),
    _InspirationScenario(
      '車禍折舊估算',
      '車損維修零件折舊與工資求償之實務計算標準。',
      '民法第 184・213 條',
      PhosphorIconsRegular.carProfile,
    ),
    _InspirationScenario(
      '網購7天鑑賞期',
      '通訊交易七日猶豫期適用範圍與例外排除事由。',
      '消費者保護法第 19 條',
      PhosphorIconsRegular.shoppingBagOpen,
    ),
    _InspirationScenario(
      '借錢不還本票追討',
      '親友欠款逾期，如何透過支付命令或本票裁定追償？',
      '民事訴訟法第 508 條',
      PhosphorIconsRegular.scroll,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final cardWidth = (screenWidth * 0.68).clamp(205.0, 245.0);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      clipBehavior: Clip.none,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _items.map((item) {
          return Container(
            width: cardWidth,
            margin: EdgeInsets.only(right: 10.w),
            child: _InteractiveCard(
              onTap: () => onQuery(item.query),
              background: t.surface,
              borderColor: t.border,
              padding: EdgeInsets.all(13.w),
              width: null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(item.icon, color: t.brandPrimary, size: 16.sp),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          item.query,
                          style: _SearchText.tileTitle(context).copyWith(
                            fontSize: 13.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    item.statuteTag,
                    style: _SearchText.serifBody(context).copyWith(
                      fontSize: 11.5.sp,
                      color: t.accentBrass,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    item.subtitle,
                    style: _SearchText.caption(context),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _LegalSearchIndexGrid extends StatelessWidget {
  const _LegalSearchIndexGrid({
    required this.onStatutes,
    required this.onCases,
    required this.onLifeNotes,
    required this.onOfficial,
  });

  final VoidCallback onStatutes;
  final VoidCallback onCases;
  final VoidCallback onLifeNotes;
  final VoidCallback onOfficial;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final entries = <({
      String title,
      String subtitle,
      IconData icon,
      Color accent,
      Color container,
      VoidCallback onTap,
    })>[
      (
        title: '法規',
        subtitle: '民刑法・勞基・消保條文與白話對照',
        icon: PhosphorIconsRegular.bookBookmark,
        accent: t.brandPrimary,
        container: t.brandContainer,
        onTap: onStatutes,
      ),
      (
        title: '裁判案卷',
        subtitle: '各級法院實務裁判要旨與時序解析',
        icon: PhosphorIconsRegular.gavel,
        accent: t.semanticInfo,
        container: t.semanticInfoContainer,
        onTap: onCases,
      ),
      (
        title: '避坑實務',
        subtitle: '常見糾紛蒐證清單與自保談判指南',
        icon: PhosphorIconsRegular.lightbulbFilament,
        accent: t.accentOnBrassContainer,
        container: t.accentBrassContainer,
        onTap: onLifeNotes,
      ),
      (
        title: '法務動態',
        subtitle: '司法院・法務部・165 官方權威資料',
        icon: PhosphorIconsRegular.bank,
        accent: t.semanticSuccess,
        container: t.semanticSuccessContainer,
        onTap: onOfficial,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final singleCol = constraints.maxWidth < 310 || textScale > 1.3;
        final itemWidth = singleCol
            ? constraints.maxWidth
            : (constraints.maxWidth - 10.w) / 2;

        return Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: entries.map((e) {
            return SizedBox(
              width: itemWidth,
              child: _InteractiveCard(
                onTap: e.onTap,
                padding: EdgeInsets.all(14.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _IconBox(
                          icon: e.icon,
                          color: e.accent,
                          backgroundColor: e.container,
                        ),
                        const Spacer(),
                        Icon(
                          PhosphorIconsRegular.caretRight,
                          size: 15.sp,
                          color: t.textMuted,
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      e.title,
                      style: _SearchText.serifTileTitle(context),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      e.subtitle,
                      style: _SearchText.caption(context),
                    ),
                  ],
                ),
              ),
            );
          }).toList(growable: false),
        );
      },
    );
  }
}

class _HotSearchSection extends StatelessWidget {
  const _HotSearchSection({required this.onQuery});

  final ValueChanged<String> onQuery;

  static const _hotKeywords = <String>[
    '民法第 184 條',
    '刑法第 339 條',
    '勞動基準法第 24 條',
    '消保法第 19 條',
    '民法第 429 條',
    '租屋押金扣款',
    '公司無預警資遣',
    '車禍折舊估算',
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: _hotKeywords.map((kw) {
        return _Pill(
          label: kw,
          icon: kw.contains('第')
              ? PhosphorIconsRegular.bookOpenText
              : PhosphorIconsRegular.trendUp,
          onTap: () => onQuery(kw),
        );
      }).toList(growable: false),
    );
  }
}

class _SearchHome extends StatelessWidget {
  const _SearchHome({
    required this.mode,
    required this.onModeChanged,
    required this.recent,
    required this.onQuery,
    required this.onLaunchChat,
    required this.onOpenTranslator,
    required this.onOpenToolkit,
    required this.onStatutes,
    required this.onCases,
    required this.onLifeNotes,
    required this.onOfficial,
    required this.onOpenFilters,
    required this.onClearRecent,
    required this.controller,
  });

  final _HubMode mode;
  final ValueChanged<_HubMode> onModeChanged;
  final List<String> recent;
  final ValueChanged<String> onQuery;
  final ValueChanged<String?> onLaunchChat;
  final VoidCallback onOpenTranslator;
  final VoidCallback onOpenToolkit;
  final VoidCallback onStatutes;
  final VoidCallback onCases;
  final VoidCallback onLifeNotes;
  final VoidCallback onOfficial;
  final VoidCallback onOpenFilters;
  final VoidCallback onClearRecent;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final appState = PreambleScope.of(context);
    final quotaText =
        '今日問診額度 ${appState.remainingAiQuota}/${appState.accessTier.defaultDailyAiQuota}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. 靜奢律政刊頭（含公文白話解讀 & 法務實戰工具捷徑）
        _HubEditorialHeader(
          onOpenTranslator: onOpenTranslator,
          onOpenToolkit: onOpenToolkit,
        ),
        SizedBox(height: 14.h),

        // 2. 雙軌分段切換器：AI 法律問診 ⇄ 法規・裁判檢索
        _DualModeSegmentedSwitch(
          mode: mode,
          onModeChanged: onModeChanged,
        ),
        SizedBox(height: 14.h),

        if (mode == _HubMode.consultation) ...[
          // Mode A：AI 法律問診中樞
          _ConsultationPromptCard(
            controller: controller,
            quotaText: quotaText,
            onQuickAnalyze: onQuery,
            onLaunchChat: onLaunchChat,
            onClear: controller.clear,
          ),
          SizedBox(height: 14.h),

          // 一鍵公文翻譯 & 實戰存證／試算工具
          _PracticalUtilityPair(
            onOpenTranslator: onOpenTranslator,
            onOpenToolkit: onOpenToolkit,
          ),
          SizedBox(height: 20.h),

          if (recent.isNotEmpty) ...[
            _SectionHeader(
              title: '最近搜尋',
              icon: PhosphorIconsRegular.clockCounterClockwise,
              action: '清除歷史',
              onAction: onClearRecent,
            ),
            SizedBox(height: 8.h),
            _HorizontalRecentFootprints(recent: recent, onQuery: onQuery),
            SizedBox(height: 20.h),
          ],

          // 六大生活爭議結構化問診卡
          const _SectionHeader(
            title: '六大生活爭議結構化問診',
            icon: PhosphorIconsRegular.squaresFour,
          ),
          SizedBox(height: 10.h),
          _DisputeDomainIntakeGrid(
            onSelectPrompt: onQuery,
            onLaunchChat: (prompt) => onLaunchChat(prompt),
          ),
          SizedBox(height: 20.h),

          // 常見爭議靈感橫向導覽
          const _SectionHeader(
            title: '法律探索靈感',
            icon: PhosphorIconsRegular.sparkle,
          ),
          SizedBox(height: 10.h),
          _InspirationCarousel(onQuery: onQuery),
        ] else ...[
          // Mode B：法規・裁判精準檢索中樞
          _SearchField(
            controller: controller,
            hintText: '輸入條號或案由關鍵字（例：民法 184、詐欺、加班費）',
            onSubmitted: onQuery,
            onClear: controller.clear,
            showFilter: true,
            onFilter: onOpenFilters,
          ),
          SizedBox(height: 18.h),

          const _SectionHeader(
            title: '四大法源分類檢索',
            icon: PhosphorIconsRegular.books,
          ),
          SizedBox(height: 10.h),
          _LegalSearchIndexGrid(
            onStatutes: onStatutes,
            onCases: onCases,
            onLifeNotes: onLifeNotes,
            onOfficial: onOfficial,
          ),
          SizedBox(height: 20.h),

          const _SectionHeader(
            title: '熱門條文與實務關鍵字',
            icon: PhosphorIconsRegular.trendUp,
          ),
          SizedBox(height: 10.h),
          _HotSearchSection(onQuery: onQuery),
          SizedBox(height: 20.h),

          _SectionHeader(
            title: '最近搜尋',
            icon: PhosphorIconsRegular.clockCounterClockwise,
            action: recent.isNotEmpty ? '清除歷史' : null,
            onAction: recent.isNotEmpty ? onClearRecent : null,
          ),
          SizedBox(height: 8.h),
          if (recent.isNotEmpty)
            _HorizontalRecentFootprints(recent: recent, onQuery: onQuery)
          else
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: t.subtleBoxDecoration(radius: 12.r),
              child: Text(
                '尚無近期檢索紀錄；可直接輸入條號或點選上方熱門條文快速查閱。',
                style: _SearchText.body(context),
              ),
            ),
        ],
      ],
    );
  }
}
