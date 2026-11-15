import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:preamble/theme/preamble_tokens.dart';

/// 對造公文白話文翻譯結果結構
class PlainDocumentTranslation {
  const PlainDocumentTranslation({
    required this.documentType,
    required this.whatTheyWant,
    required this.areTheyRight,
    required this.whatYouShouldDo,
    required this.extractedDeadline,
    required this.potentialRisks,
  });

  final String documentType;
  final String whatTheyWant; // 他想要什麼？
  final String areTheyRight; // 他有道理嗎？
  final String whatYouShouldDo; // 我現在該做什麼？
  final String extractedDeadline; // 期限
  final String potentialRisks; // 潛在時效與法律風險

  static PlainDocumentTranslation parseFromRawLegalText(String text) {
    final lower = text.toLowerCase();

    if (lower.contains('押金') || lower.contains('租') || lower.contains('房東')) {
      return const PlainDocumentTranslation(
        documentType: '房東扣抵押金 / 催告搬遷存證信函',
        whatTheyWant:
            '【他想要什麼？】房東主張屋況有污損或提前退租，要求扣抵全部 2 個月押金（約 4 萬元），並要你於 7 日內結清雜費搬離。',
        areTheyRight:
            '【他有道理嗎？】只有一半合理。若是自然折舊耗損（例如牆面正常變黃、家具正常使用老化），依法本來就應由房東承擔，房東無權全額扣抵押金！',
        whatYouShouldDo:
            '【你現在該做什麼？】別慌張！切勿直接同意或簽署任何拋棄押金的切結書。請先備妥退租點交當天的照片錄影，並寄發催告返還押金信函反制。',
        extractedDeadline: '信件送達後 7 日內',
        potentialRisks:
            '若置之不理超過 6 個月，出租人與承租人間關於租賃物損害賠償與點交爭議之法定黃金時效將屆滿，且沉默可能被誤解為默認扣款明細。',
      );
    } else if (lower.contains('車禍') ||
        lower.contains('過失') ||
        lower.contains('撞')) {
      return const PlainDocumentTranslation(
        documentType: '車禍求償與侵權損害賠償律師函',
        whatTheyWant:
            '【他想要什麼？】對方主張你未注意車前狀況追撞，要求賠償車輛維修費、工作損失及精神撫慰金共 35 萬元。',
        areTheyRight:
            '【他有道理嗎？】對方金額明顯灌水。車輛維修零件依法必須按年份「計算折舊」，且對方在初判表上同樣可能有未依規定減速之「與有過失」責任！',
        whatYouShouldDo:
            '【你現在該做什麼？】不要私下答應匯款。立即將此信函轉交給你的產險理賠專員，並向警方申請初步分析研判表，向鄉鎮市區調解委員會申請調解。',
        extractedDeadline: '文到後 5 日內出面協商',
        potentialRisks:
            '若涉及人員受傷且未在事故發生起 6 個月內達成和解，對方可能提出過失傷害刑事告訴（告訴乃論 6 個月時效）。',
      );
    } else if (lower.contains('資遣') ||
        lower.contains('離職') ||
        lower.contains('公司') ||
        lower.contains('加班')) {
      return const PlainDocumentTranslation(
        documentType: '公司勞動契約終止 / 懲戒通知書',
        whatTheyWant:
            '【他想要什麼？】公司主張你未能勝任工作，要求你自請離職且不發給資遣費與非自願離職證明。',
        areTheyRight:
            '【他有道理嗎？】明顯違法！雇主若以不能勝任為由解僱，依法必須給付資遣費並開立非自願離職證明書，且須符合最後手段性原則（PIP 輔導未果）才具合法性。',
        whatYouShouldDo:
            '【你現在該做什麼？】絕對不要在「自願離職單」上簽名！立即將打卡紀錄與薪資單備份截圖，向工作所在地勞工局申請勞資爭議調解。',
        extractedDeadline: '即日起生效（建議 30 日內爭議調解）',
        potentialRisks:
            '一旦簽署自願離職書，將直接喪失法定資遣費請求權及請領最長 6 個月就業保險失業給付之重大權益。',
      );
    } else {
      return const PlainDocumentTranslation(
        documentType: '民事權益催告 / 存證信函',
        whatTheyWant:
            '【他想要什麼？】對方主張你未履行特定給付義務，要求你在限期內給付指定金額或履行協議。',
        areTheyRight:
            '【他有道理嗎？】需視雙方當初白紙黑字約定與實際金流憑證而定；若對方無明確契約或單據憑證，單方催告函本身並不具備法院強制執行力。',
        whatYouShouldDo:
            '【你現在該做什麼？】先核對是否真有該筆債務或未履行義務。若與事實不符，建議於 7 日內以存證信函書面否認並保留證據，避免事後舉證被動。',
        extractedDeadline: '文到後 7 日內',
        potentialRisks:
            '若對方後續向法院聲請核發「支付命令」，收到法院公文後務必在法定 20 日不變期間內具狀向法院聲明異議，否則將確定產生執行力！',
      );
    }
  }
}

/// 《緒言 Preamble》對造公文／存證信函「雙重編碼四維拆解」白話翻譯面板。
///
/// 完整呈現四大法務維度：
/// `[對方意圖 | 合理性評估 | 潛在時效風險 | 建議反制行動]`
class PlainDocumentTranslatorSheet extends StatefulWidget {
  const PlainDocumentTranslatorSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PlainDocumentTranslatorSheet(),
    );
  }

  @override
  State<PlainDocumentTranslatorSheet> createState() =>
      _PlainDocumentTranslatorSheetState();
}

class _PlainDocumentTranslatorSheetState
    extends State<PlainDocumentTranslatorSheet> {
  final TextEditingController _inputController = TextEditingController(
    text:
        '按民法第423條及雙方租賃契約，承租人應負善良管理人注意義務。台端退租時屋況污損不堪，出租人依約抵扣押租金新台幣四萬元整，特此函告，請於文到七日內出面清結。',
  );
  PlainDocumentTranslation? _result;
  bool _isTranslating = false;

  static final RegExp _bracketPrefixRegex = RegExp(r'^【[^】]+】\s*');

  String _stripBracketPrefix(String text) {
    return text.replaceFirst(_bracketPrefixRegex, '').trim();
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final viewInsetsBottom = MediaQuery.viewInsetsOf(context).bottom;
    final safeBottom = MediaQuery.viewPaddingOf(context).bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(bottom: viewInsetsBottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: 0.90.sh),
        decoration: BoxDecoration(
          color: t.canvas,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          border: Border(top: BorderSide(color: t.borderStrong)),
          boxShadow: [
            BoxShadow(
              color: t.shadowAmbient,
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 頂部拖曳把手與關閉按鈕
            Padding(
              padding: EdgeInsets.only(top: 10.h, left: 16.w, right: 12.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(width: 40.w),
                  Container(
                    width: 38.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: t.borderStrong,
                      borderRadius: BorderRadius.circular(99.r),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: '關閉',
                    icon: Icon(
                      PhosphorIconsRegular.x,
                      color: t.textSecondary,
                      size: 20.sp,
                    ),
                  ),
                ],
              ),
            ),

            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  20.w,
                  4.h,
                  20.w,
                  (viewInsetsBottom > 0 ? 20.h : safeBottom + 24.h),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 刊頭標題
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: BoxDecoration(
                            color: t.brandContainer,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: t.brandPrimary.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Icon(
                            PhosphorIconsRegular.translate,
                            size: 20.sp,
                            color: t.brandPrimary,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '對造公文 / 存證信函白話解讀儀',
                                style: t.serifTitle(size: 17.sp),
                              ),
                              SizedBox(height: 3.h),
                              Text(
                                '將艱澀法言法語拆解為「意圖、合理性、時效風險、反制行動」四維白話指引',
                                style: t.sansBody(size: 12.sp),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // 原文輸入艙（宋體呈現對造正式公文語氣）
                    Text(
                      '貼上或輸入收到的存證信函 / 律師函原文：',
                      style: t.sansTitle(size: 13.sp),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      decoration: BoxDecoration(
                        color: t.surface,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: t.borderStrong),
                      ),
                      padding: EdgeInsets.all(14.w),
                      child: TextField(
                        controller: _inputController,
                        maxLines: 4,
                        style: t.serifBody(
                          size: 13.5.sp,
                          color: t.textPrimary,
                          height: 1.6,
                        ),
                        decoration: InputDecoration.collapsed(
                          hintText: '請貼上對方寄來的存證信函、律師函或催告通知文字...',
                          hintStyle: t.sansBody(
                            size: 12.5.sp,
                            color: t.textMuted,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),

                    // 快速範例標籤（Wrap 避免窄螢幕溢位）
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          '快速帶入範例：',
                          style: t.sansBody(size: 11.5.sp, color: t.textMuted),
                        ),
                        _buildSamplePill(
                          t,
                          '房東扣押金',
                          '按民法第423條，台端退租污損屋況，抵扣押金4萬元七日內清結。',
                        ),
                        _buildSamplePill(
                          t,
                          '車禍求償 35 萬',
                          '台端未注意車前狀況肇事追撞，限期五日內賠償維修與工作損失35萬元。',
                        ),
                        _buildSamplePill(
                          t,
                          '公司要求自請離職',
                          '台端未能勝任工作，請於今日辦理自願離職手續，本公司不另發給資遣費。',
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),

                    // 翻譯按鈕
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _isTranslating ? null : _handleTranslate,
                        icon: _isTranslating
                            ? SizedBox(
                                width: 16.w,
                                height: 16.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: t.brandOnPrimary,
                                ),
                              )
                            : Icon(
                                PhosphorIconsRegular.sparkle,
                                size: 17.sp,
                                color: t.brandOnPrimary,
                              ),
                        label: Text(
                          _isTranslating
                              ? '正在進行四維雙重編碼拆解...'
                              : '一鍵拆解公文真相與時效風險',
                          style: t.sansBody(
                            size: 13.sp,
                            weight: FontWeight.w700,
                            color: t.brandOnPrimary,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: t.brandPrimary,
                          foregroundColor: t.brandOnPrimary,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                    ),

                    // 四維翻譯結果展示
                    if (_result != null) ...[
                      SizedBox(height: 18.h),
                      Container(
                        padding: EdgeInsets.all(14.w),
                        decoration: t.cardDecoration(
                          radius: 16.r,
                          fill: t.surface,
                          borderColor: t.borderStrong,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 頂部文書定性與期限膠囊
                            Wrap(
                              spacing: 8.w,
                              runSpacing: 6.h,
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 9.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: t.brandContainer,
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Text(
                                    _result!.documentType,
                                    style: t.sansBody(
                                      size: 11.5.sp,
                                      weight: FontWeight.w700,
                                      color: t.brandOnContainer,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 9.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: t.semanticUrgentContainer,
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        PhosphorIconsRegular.clockCountdown,
                                        size: 13.sp,
                                        color: t.semanticUrgent,
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        '期限：${_result!.extractedDeadline}',
                                        style: t.tabularMetric(
                                          size: 11.sp,
                                          color: t.semanticUrgent,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 14.h),

                            // 卡片 1：對方意圖
                            _buildBreakdownCard(
                              t: t,
                              indexLabel: '01',
                              title: '對方意圖',
                              subtitle: '白話翻譯對方真正要求的條件',
                              body: _stripBracketPrefix(_result!.whatTheyWant),
                              icon: PhosphorIconsRegular.target,
                              accentColor: t.semanticInfo,
                              containerColor: t.semanticInfoContainer,
                            ),
                            SizedBox(height: 10.h),

                            // 卡片 2：合理性評估
                            _buildBreakdownCard(
                              t: t,
                              indexLabel: '02',
                              title: '合理性評估',
                              subtitle: '對照現行法規檢視對方主張是否站得住腳',
                              body: _stripBracketPrefix(_result!.areTheyRight),
                              icon: PhosphorIconsRegular.scales,
                              accentColor: t.accentOnBrassContainer,
                              containerColor: t.accentBrassContainer,
                            ),
                            SizedBox(height: 10.h),

                            // 卡片 3：潛在時效風險（先前遺漏之關鍵欄位完整補齊！）
                            _buildBreakdownCard(
                              t: t,
                              indexLabel: '03',
                              title: '潛在時效風險',
                              subtitle: '逾期未回應或誤簽文件之法定失權風險',
                              body:
                                  _stripBracketPrefix(_result!.potentialRisks),
                              icon: PhosphorIconsRegular.warningOctagon,
                              accentColor: t.semanticUrgent,
                              containerColor: t.semanticUrgentContainer,
                              highlightBorder: true,
                            ),
                            SizedBox(height: 10.h),

                            // 卡片 4：建議反制行動
                            _buildBreakdownCard(
                              t: t,
                              indexLabel: '04',
                              title: '建議反制行動',
                              subtitle: '當下立即可執行的蒐證與回覆步驟',
                              body: _stripBracketPrefix(
                                _result!.whatYouShouldDo,
                              ),
                              icon: PhosphorIconsRegular.shieldCheck,
                              accentColor: t.semanticSuccess,
                              containerColor: t.semanticSuccessContainer,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSamplePill(
    PreambleTokens t,
    String title,
    String sampleText,
  ) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _inputController.text = sampleText;
          _result = null;
        });
      },
      borderRadius: BorderRadius.circular(99.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: t.surfaceSubtle,
          borderRadius: BorderRadius.circular(99.r),
          border: Border.all(color: t.border),
        ),
        child: Text(
          title,
          style: t.sansBody(
            size: 11.5.sp,
            weight: FontWeight.w600,
            color: t.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildBreakdownCard({
    required PreambleTokens t,
    required String indexLabel,
    required String title,
    required String subtitle,
    required String body,
    required IconData icon,
    required Color accentColor,
    required Color containerColor,
    bool highlightBorder = false,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: highlightBorder
            ? containerColor.withValues(alpha: t.isDark ? 0.55 : 0.65)
            : t.surfaceSubtle,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: highlightBorder
              ? accentColor.withValues(alpha: 0.55)
              : t.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: containerColor,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 13.sp, color: accentColor),
                    SizedBox(width: 4.w),
                    Text(
                      indexLabel,
                      style: t.tabularMetric(size: 11.sp, color: accentColor),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: t.sansTitle(size: 13.sp, color: t.textPrimary),
                    ),
                    Text(
                      subtitle,
                      style: t.sansBody(size: 11.sp, color: t.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            body,
            style: t.sansBody(
              size: 12.5.sp,
              color: t.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleTranslate() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isTranslating = true);
    HapticFeedback.mediumImpact();

    await Future.delayed(const Duration(milliseconds: 380));
    if (!mounted) return;

    setState(() {
      _result = PlainDocumentTranslation.parseFromRawLegalText(text);
      _isTranslating = false;
    });

    HapticFeedback.heavyImpact();
  }
}
