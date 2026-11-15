part of '../global_search_page.dart';

// 詳情頁共用雙重編碼輔助模組：
// 1. _DualCodedSummaryCard：取代原本無聲假計時的 _VoiceReader，提供「法定原文 ⇄ 白話核心結論」雙重編碼對照與一鍵複製引用。
// 2. _ScenarioFollowUps：結構化情境延伸追問。
// 3. _CaseTimelineVisualizer：裁判事實與程序時序軸（等寬日期對齊）。
// 4. _RelatedStatuteChips：關聯互補條文跳轉。

class _DualCodedSummaryCard extends StatelessWidget {
  const _DualCodedSummaryCard({
    required this.plainConclusion,
    required this.copyPayload,
    this.authoritativeExcerpt,
    this.sectionLabel = '白話核心結論',
    this.copyLabel = '一鍵複製引用條文',
  });

  final String plainConclusion;
  final String copyPayload;
  final String? authoritativeExcerpt;
  final String sectionLabel;
  final String copyLabel;

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
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: t.accentBrassContainer,
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(
                    color: t.accentBrass.withValues(alpha: 0.28),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      PhosphorIconsFill.scales,
                      size: 13.sp,
                      color: t.accentOnBrassContainer,
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      '雙重編碼重點摘要對照',
                      style: _SearchText.captionStrong(context).copyWith(
                        color: t.accentOnBrassContainer,
                      ),
                    ),
                  ],
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: copyPayload));
                    if (!context.mounted) return;
                    CustomToast.show(context, '已複製引用條文與白話核心結論');
                  },
                  borderRadius: BorderRadius.circular(999.r),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 11.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: t.brandContainer,
                      borderRadius: BorderRadius.circular(999.r),
                      border: Border.all(
                        color: t.brandPrimary.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          PhosphorIconsRegular.copy,
                          size: 13.sp,
                          color: t.brandOnContainer,
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          copyLabel,
                          style: _SearchText.captionStrong(context).copyWith(
                            color: t.brandOnContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (authoritativeExcerpt != null &&
              authoritativeExcerpt!.trim().isNotEmpty) ...[
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 10.h),
              decoration: BoxDecoration(
                color: t.surfaceSubtle,
                borderRadius: BorderRadius.circular(10.r),
                border: Border(
                  left: BorderSide(color: t.brandPrimary, width: 3.w),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '法定規範／裁判原文',
                    style: _SearchText.captionStrong(context).copyWith(
                      color: t.brandPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    authoritativeExcerpt!,
                    style: _SearchText.serifBody(context),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: t.subtleBoxDecoration(
              radius: 12.r,
              fill: t.brandContainer.withValues(alpha: t.isDark ? 0.55 : 0.65),
              borderColor: t.brandPrimary.withValues(alpha: 0.22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      PhosphorIconsFill.lightbulbFilament,
                      size: 14.sp,
                      color: t.accentBrass,
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        sectionLabel,
                        style: _SearchText.captionStrong(context).copyWith(
                          color: t.brandOnContainer,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Text(
                  plainConclusion,
                  style: _SearchText.bodyStrong(context).copyWith(
                    color: t.textPrimary,
                    height: 1.55,
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

class _ScenarioFollowUps extends StatelessWidget {
  const _ScenarioFollowUps({
    required this.title,
    required this.onAsk,
  });

  final String title;
  final ValueChanged<String> onAsk;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final List<String> questions = [];
    if (title.contains('消保') || title.contains('19') || title.contains('鑑賞期')) {
      questions.addAll([
        '個人二手賣家也適用七天鑑賞期嗎？',
        '如果是客製化商品還能主張退貨嗎？',
        '商品拆封檢查後還能主張無條件退貨嗎？',
      ]);
    } else if (title.contains('詐') || title.contains('339')) {
      questions.addAll([
        '匯款後如何啟動 165 緊急圈存止付？',
        '銀行帳戶遭列為警示帳戶該如何申請解除？',
        '單純借錢不還與刑法詐欺罪如何區分？',
      ]);
    } else if (title.contains('租') ||
        title.contains('房') ||
        title.contains('421') ||
        title.contains('429')) {
      questions.addAll([
        '退租時房東以自然折舊扣押金該如何反制？',
        '房屋漏水房東遲不修繕可以自行修繕扣抵租金嗎？',
        '租約未到期提前解約最高違約金上限是多少？',
      ]);
    } else if (title.contains('勞') || title.contains('24') || title.contains('資遣')) {
      questions.addAll([
        '雇主無預警資遣時如何計算預告工資與資遣費？',
        '公司拒絕開立非自願離職證明書該向哪裡申訴？',
        '平日與休息日延長工時的加班費倍率如何計算？',
      ]);
    } else {
      questions.addAll([
        '主張這個條文在訴訟上需要準備哪些關鍵證據？',
        '遇到這類糾紛該如何聲請鄉鎮市區調解？',
        '收到對造存證信函後幾天內應該正式回覆？',
      ]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              PhosphorIconsRegular.chatsCircle,
              color: t.brandPrimary,
              size: 16.sp,
            ),
            SizedBox(width: 6.w),
            Expanded(
              child: Text(
                '情境延伸問診追問',
                style: _SearchText.captionStrong(context),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: questions.map((q) {
              return Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onAsk(q),
                    borderRadius: BorderRadius.circular(999.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: t.brandContainer,
                        borderRadius: BorderRadius.circular(999.r),
                        border: Border.all(
                          color: t.brandPrimary.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            q,
                            style: _SearchText.captionStrong(context).copyWith(
                              color: t.brandOnContainer,
                            ),
                          ),
                          SizedBox(width: 5.w),
                          Icon(
                            PhosphorIconsRegular.arrowRight,
                            color: t.brandPrimary,
                            size: 12.sp,
                          ),
                        ],
                      ),
                    ),
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

class _CaseTimelineVisualizer extends StatelessWidget {
  const _CaseTimelineVisualizer({
    required this.caseId,
    required this.title,
  });

  final String caseId;
  final String title;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final List<_TimelineEvent> events = [];
    if (caseId.contains('2') || title.contains('租') || title.contains('押金')) {
      events.addAll(const [
        _TimelineEvent('2025.03.15', '簽訂租約', '雙方起租並交付二個月押租金。'),
        _TimelineEvent('2026.03.14', '期滿點交', '租期屆滿返還房屋，出租人主張自然折舊扣抵押金。'),
        _TimelineEvent('2026.04.10', '調解不成立', '向區公所聲請調解，出租人執意扣除油漆清潔費。'),
        _TimelineEvent('2026.06.15', '小額判決確定', '法院認定自然耗損屬出租人成本，判命全額返還押金。'),
      ]);
    } else if (caseId.contains('1') || title.contains('詐')) {
      events.addAll(const [
        _TimelineEvent('2025.02.10', '三方詐騙發生', '買家受騙匯款至善意賣家帳戶，詐欺行為人取走商品。'),
        _TimelineEvent('2025.02.12', '警示帳戶通報', '帳戶遭通報凍結，賣家名下金融帳戶暫停自動化交易。'),
        _TimelineEvent('2025.08.12', '檢察官不起訴', '偵查釐清交易對話與出貨憑證，認無幫助詐欺故意。'),
        _TimelineEvent('2026.02.18', '解除警示定讞', '持不起訴處分書向警局申請解除警示帳戶獲准。'),
      ]);
    } else {
      events.addAll(const [
        _TimelineEvent('2025.10.15', '通訊交易收貨', '網路下單收到商品並開箱檢視外觀與功能。'),
        _TimelineEvent('2025.10.18', '通知解除契約', '於法定 7 日猶豫期內書面通知退貨，賣家以拆封拒退。'),
        _TimelineEvent('2025.11.05', '消保線上申訴', '向行政院消保處提出申訴，由消保官函請業者說明。'),
        _TimelineEvent('2026.01.12', '消費調解成立', '確認僅為必要檢視且無毀損，業者同意全額退還價金。'),
      ]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              PhosphorIconsRegular.gitCommit,
              color: t.brandPrimary,
              size: 16.sp,
            ),
            SizedBox(width: 6.w),
            Expanded(
              child: Text(
                '案件事實與審理時序軸',
                style: _SearchText.captionStrong(context),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        for (var index = 0; index < events.length; index++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  children: [
                    Container(
                      width: 9.r,
                      height: 9.r,
                      margin: EdgeInsets.only(top: 4.h),
                      decoration: BoxDecoration(
                        color: index == events.length - 1
                            ? t.accentBrass
                            : t.brandPrimary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    if (index != events.length - 1)
                      Expanded(
                        child: Container(
                          width: 1.5,
                          color: t.borderStrong,
                        ),
                      ),
                  ],
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 2.h,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              events[index].date,
                              style: _SearchText.metric(
                                context,
                                size: 11.5.sp,
                                color: t.brandPrimary,
                              ),
                            ),
                            Text(
                              events[index].title,
                              style: _SearchText.bodyStrong(context),
                            ),
                          ],
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          events[index].desc,
                          style: _SearchText.body(context),
                        ),
                      ],
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

class _TimelineEvent {
  const _TimelineEvent(this.date, this.title, this.desc);
  final String date;
  final String title;
  final String desc;
}

class _RelatedStatuteChips extends StatelessWidget {
  const _RelatedStatuteChips({
    required this.statuteTitle,
    required this.onNavigate,
  });

  final String statuteTitle;
  final ValueChanged<_SearchResult> onNavigate;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final List<_RelatedStatuteInfo> list = [];
    if (statuteTitle.contains('消費者保護法') &&
        statuteTitle.contains('19') &&
        !statuteTitle.contains('19之2')) {
      list.addAll(const [
        _RelatedStatuteInfo(
          '民法第 259 條',
          '契約解除時雙方回復原狀義務之細節規範。',
          'statute-民法-259',
        ),
        _RelatedStatuteInfo(
          '消保法第 19 條之 2',
          '通訊交易退回商品與返還價金之期限規定。',
          'statute-消費者保護法-19之2',
        ),
      ]);
    } else if (statuteTitle.contains('刑法') && statuteTitle.contains('339')) {
      list.addAll(const [
        _RelatedStatuteInfo(
          '民法第 184 條',
          '因故意或過失不法侵害他人權利之侵權損害賠償請求權。',
          'statute-民法-184',
        ),
        _RelatedStatuteInfo(
          '民法第 179 條',
          '無法律上原因受有利益致他人受損之不當得利返還請求權。',
          'statute-民法-179',
        ),
      ]);
    } else if (statuteTitle.contains('民法') &&
        (statuteTitle.contains('421') ||
            statuteTitle.contains('429') ||
            statuteTitle.contains('444'))) {
      list.addAll(const [
        _RelatedStatuteInfo(
          '民法第 429 條',
          '租賃物修繕義務之歸屬與費用負擔原則。',
          'statute-民法-429',
        ),
        _RelatedStatuteInfo(
          '民法第 430 條',
          '出租人催告不修繕時，承租人自行修繕或終止契約之權利。',
          'statute-民法-430',
        ),
      ]);
    } else {
      list.addAll(const [
        _RelatedStatuteInfo(
          '民法第 184 條',
          '一般侵權行為之損害賠償請求權基礎。',
          'statute-民法-184',
        ),
        _RelatedStatuteInfo(
          '民法第 179 條',
          '不當得利之返還請求權基礎。',
          'statute-民法-179',
        ),
      ]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              PhosphorIconsRegular.gitBranch,
              color: t.brandPrimary,
              size: 16.sp,
            ),
            SizedBox(width: 6.w),
            Expanded(
              child: Text(
                '關聯互補法條參照',
                style: _SearchText.captionStrong(context),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: list.map((info) {
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  onNavigate(
                    _SearchResult(
                      type: _ResultType.statute,
                      title: info.title,
                      summary: info.summary,
                      source: '法規參照・施行中',
                      query: info.title.replaceAll(' ', ''),
                      id: info.id,
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(10.r),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 11.w, vertical: 7.h),
                  decoration: BoxDecoration(
                    color: t.surface,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: t.borderStrong),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        PhosphorIconsRegular.bookOpenText,
                        color: t.brandPrimary,
                        size: 13.sp,
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        info.title,
                        style: _SearchText.serifBody(context).copyWith(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _RelatedStatuteInfo {
  const _RelatedStatuteInfo(this.title, this.summary, this.id);
  final String title;
  final String summary;
  final String id;
}
