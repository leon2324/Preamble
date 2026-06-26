part of '../global_search_page.dart';

// 台灣繁體中文教學註解：
// 本檔集中放全站搜尋首頁的展示型 UI，包括迎賓吉祥物、最近搜尋、靈感卡與快捷入口；
// 搜尋 state、submit 流程與 route 切換仍留在 GlobalSearchPage，避免 UI 拆分影響搜尋行為。

class _MascotFloatingWrapper extends StatefulWidget {
  const _MascotFloatingWrapper({required this.child});
  final Widget child;

  @override
  State<_MascotFloatingWrapper> createState() => _MascotFloatingWrapperState();
}

class _MascotFloatingWrapperState extends State<_MascotFloatingWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
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
        final offset = math.sin(_controller.value * 2 * math.pi) * 4.h;
        return Transform.translate(
          offset: Offset(0, offset),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SpeechBubblePainter extends CustomPainter {
  const _SpeechBubblePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final double radius = 12.r;
    final double arrowWidth = 8.w;
    final double arrowHeight = 10.h;

    // Body of the bubble, starting after the arrow on the left
    path.moveTo(arrowWidth + radius, 0);
    path.lineTo(size.width - radius, 0);
    path.arcToPoint(Offset(size.width, radius),
        radius: Radius.circular(radius));
    path.lineTo(size.width, size.height - radius);
    path.arcToPoint(Offset(size.width - radius, size.height),
        radius: Radius.circular(radius));
    path.lineTo(arrowWidth + radius, size.height);
    path.arcToPoint(Offset(arrowWidth, size.height - radius),
        radius: Radius.circular(radius));

    // Draw the left-pointing arrow centered vertically
    final double arrowCenterY = size.height / 2;
    path.lineTo(arrowWidth, arrowCenterY + arrowHeight / 2);
    path.lineTo(0, arrowCenterY);
    path.lineTo(arrowWidth, arrowCenterY - arrowHeight / 2);

    path.lineTo(arrowWidth, radius);
    path.arcToPoint(Offset(arrowWidth + radius, 0),
        radius: Radius.circular(radius));
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SpeechBubblePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _AssistantSpeechBubble extends StatelessWidget {
  const _AssistantSpeechBubble({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SpeechBubblePainter(color: const Color(0xFFE8F1EC)),
      child: Container(
        padding: EdgeInsets.fromLTRB(16.w + 8.w, 12.h, 16.w, 12.h),
        child: Text(
          text,
          style: _SearchText.body().copyWith(
            color: const Color(0xFF2E5E4E),
            fontSize: 12.5.sp,
            height: 1.45,
          ),
        ),
      ),
    );
  }
}

class _AssistantQuotaCapsule extends StatelessWidget {
  const _AssistantQuotaCapsule({required this.quotaText, this.onTap});
  final String quotaText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: _SearchColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(999.r),
          border:
              Border.all(color: _SearchColors.primary.withValues(alpha: 0.18)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 5.w,
              height: 5.w,
              decoration: const BoxDecoration(
                color: _SearchColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 6.w),
            Text(
              quotaText,
              style: _SearchText.caption().copyWith(
                color: _SearchColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 10.sp,
              ),
            ),
            SizedBox(width: 4.w),
            Icon(
              Icons.chevron_right_rounded,
              size: 11.sp,
              color: _SearchColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _HorizontalRecentFootprints extends StatelessWidget {
  const _HorizontalRecentFootprints(
      {required this.recent, required this.onQuery});
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
          return Container(
            margin: EdgeInsets.only(right: 8.w),
            child: ActionChip(
              avatar: Icon(Icons.history_rounded,
                  size: 12.sp, color: _SearchColors.mutedText),
              label: Text(query),
              onPressed: () => onQuery(query),
              backgroundColor: Colors.white,
              side: const BorderSide(color: _SearchColors.border),
              visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999.r)),
              labelStyle:
                  _SearchText.caption().copyWith(color: _SearchColors.text),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _InspirationItem {
  const _InspirationItem(
      this.query, this.subtitle, this.gradient, this.textColor, this.icon);
  final String query;
  final String subtitle;
  final List<Color> gradient;
  final Color textColor;
  final IconData icon;

  String get title => query;
}

class _InspirationCarousel extends StatelessWidget {
  const _InspirationCarousel({required this.onQuery});
  final ValueChanged<String> onQuery;

  @override
  Widget build(BuildContext context) {
    final inspirations = [
      _InspirationItem(
        '租屋押金扣款',
        '退租時房東扣減押金該如何爭取？',
        const [Color(0xFFE8F1EC), Color(0xFFD6E6DE)],
        const Color(0xFF2E5E4E),
        Icons.home_work_outlined,
      ),
      _InspirationItem(
        '車禍折舊估算',
        '車損維修零件折舊的法律計算公式？',
        const [Color(0xFFF7EFE5), Color(0xFFECDDC5)],
        const Color(0xFF7A583A),
        Icons.directions_car_filled_outlined,
      ),
      _InspirationItem(
        '網購7天鑑賞期',
        '消保法鑑賞期適用範圍與退貨規定。',
        const [Color(0xFFECF0F7), Color(0xFFD3DFEF)],
        const Color(0xFF38527A),
        Icons.shopping_bag_outlined,
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      clipBehavior: Clip.none,
      child: Row(
        children: inspirations.map((item) {
          return Container(
            width: 220.w,
            margin: EdgeInsets.only(right: 12.w),
            child: _InteractiveCard(
              onTap: () => onQuery(item.query),
              background: Colors.transparent,
              borderColor: item.textColor.withValues(alpha: 0.15),
              padding: EdgeInsets.zero,
              width: null,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: item.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(item.icon, color: item.textColor, size: 16.sp),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            item.title,
                            style: _SearchText.captionStrong().copyWith(
                              color: item.textColor,
                              fontSize: 12.sp,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      item.subtitle,
                      style: _SearchText.caption().copyWith(
                        color: item.textColor.withValues(alpha: 0.8),
                        fontSize: 10.5.sp,
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SearchHome extends StatelessWidget {
  const _SearchHome({
    required this.recent,
    required this.onQuery,
    required this.onAssistant,
    required this.onStatutes,
    required this.onCases,
    required this.onOfficial,
    required this.onClearRecent,
    required this.controller,
  });

  final List<String> recent;
  final ValueChanged<String> onQuery;
  final VoidCallback onAssistant;
  final VoidCallback onStatutes;
  final VoidCallback onCases;
  final VoidCallback onOfficial;
  final VoidCallback onClearRecent;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final appState = LawAppScope.of(context);
    final quick = [
      _QuickAction('AI小法助', Icons.support_agent_rounded, onAssistant),
      _QuickAction('法規速查', Icons.menu_book_outlined, onStatutes),
      _QuickAction('判例檢索', Icons.description_outlined, onCases),
      _QuickAction('官方資料', Icons.verified_outlined, onOfficial),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. 吉祥物互動迎賓區 (呼吸浮動動畫與對話氣泡)
        SizedBox(height: 12.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _MascotFloatingWrapper(
              child: Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: _SearchColors.primary.withValues(alpha: 0.15),
                      width: 1.8.w),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 7,
                      offset: const Offset(0, 3.5),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/assistant/law_assistant_home.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            const Expanded(
              child: _AssistantSpeechBubble(
                text: '嗨！我是小法助。今天想聊點什麼？我已為您接通了法規庫、裁判書與生活避坑指南，隨時為您分析！',
              ),
            ),
          ],
        ),
        SizedBox(height: 22.h),

        // 2. 聚光燈搜尋欄
        _SearchField(
          controller: controller,
          onSubmitted: onQuery,
          onClear: () => controller.clear(),
        ),
        SizedBox(height: 12.h),

        // 3. 提問額度小膠囊
        Center(
          child: _AssistantQuotaCapsule(
            quotaText:
                '今日 AI 提問剩餘：${appState.remainingAiQuota} / ${appState.accessTier.defaultDailyAiQuota} 次',
            onTap: () {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    content: Text('目前提問額度以本機使用狀態計算；正式方案開放前不提供付費升級。'),
                  ),
                );
            },
          ),
        ),
        SizedBox(height: 26.h),

        // 4. 歷史足跡標籤 (最近搜尋晶片列)
        if (recent.isNotEmpty) ...[
          _SectionHeader(
            title: '最近搜尋',
            action: '清除歷史',
            onAction: onClearRecent,
          ),
          SizedBox(height: 8.h),
          _HorizontalRecentFootprints(recent: recent, onQuery: onQuery),
          SizedBox(height: 22.h),
        ],

        // 5. 法律探索靈感 (橫向漸層卡片)
        const _SectionHeader(title: '🔥 法律探索靈感'),
        SizedBox(height: 10.h),
        _InspirationCarousel(onQuery: onQuery),
        SizedBox(height: 22.h),

        // 6. 快捷導航按鈕列 (扁平微晶片)
        const _SectionHeader(title: '🧭 快捷助理導航'),
        SizedBox(height: 10.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          clipBehavior: Clip.none,
          child: Row(
            children: quick.map((action) {
              return Container(
                margin: EdgeInsets.only(right: 8.w),
                child: _InteractiveCard(
                  onTap: action.onTap,
                  background: Colors.white,
                  borderColor: _SearchColors.border.withValues(alpha: 0.6),
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                  width: null,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(action.icon,
                          color: _SearchColors.primary, size: 14.sp),
                      SizedBox(width: 6.w),
                      Text(
                        action.label,
                        style: _SearchText.captionStrong().copyWith(
                          fontSize: 11.sp,
                          color: _SearchColors.text,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
