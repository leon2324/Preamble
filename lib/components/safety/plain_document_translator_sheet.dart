import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/components/shared/custom_toast.dart';

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
  final String potentialRisks; // 風險評估

  static PlainDocumentTranslation parseFromRawLegalText(String text) {
    final lower = text.toLowerCase();

    if (lower.contains('押金') || lower.contains('租') || lower.contains('房東')) {
      return const PlainDocumentTranslation(
        documentType: '房東扣抵押金/催告搬遷存證信函',
        whatTheyWant: '【他想要什麼？】房東主張屋況有污損或提前退租，要求扣抵全部 2 個月押金（約 4 萬元），並要你於 7 日內結清雜費搬離。',
        areTheyRight: '【他有道理嗎？】只有一半合理。若是自然折舊耗損（例如牆面正常變黃、家具正常使用老化），依法本來就應由房東承擔，房東無權全額扣抵押金！',
        whatYouShouldDo: '【你現在該做什麼？】別慌張！切勿直接同意或簽署任何拋棄押金的切結書。請先備妥退租點交當天的照片錄影，點擊下方「回覆協商公文」，系統會幫你生成合法催告函反制。',
        extractedDeadline: '信件送達後 7 日內',
        potentialRisks: '若置之不理超過 6 個月，你請求返還押金的民法法定時效將消滅。',
      );
    } else if (lower.contains('車禍') || lower.contains('過失') || lower.contains('撞')) {
      return const PlainDocumentTranslation(
        documentType: '車禍求償與侵權損害賠償律師函',
        whatTheyWant: '【他想要什麼？】對方主張你未注意車前狀況追撞，要求賠償車輛維修費、工作損失及精神撫慰金共 35 萬元。',
        areTheyRight: '【他有道理嗎？】對方金額明顯灌水。車輛維修零件依法必須按年份「計算折舊」，且對方在初判表上同樣有未依規定減速之「與有過失」責任！',
        whatYouShouldDo: '【你現在該做什麼？】不要私下答應匯款。立即將此信函轉交給你的產險理賠專員，並向警方申請初步分析研判表，向鄉鎮市調解委員會申請和解調解。',
        extractedDeadline: '文到後 5 日內出面協商',
        potentialRisks: '若涉及人傷且未在 6 個月內和解，對方可能提出過失傷害刑事告訴。',
      );
    } else if (lower.contains('資遣') || lower.contains('離職') || lower.contains('公司') || lower.contains('加班')) {
      return const PlainDocumentTranslation(
        documentType: '公司勞動契約終止/懲戒通知書',
        whatTheyWant: '【他想要什麼？】公司主張你未能勝任工作，要求你自請離職且不發給資遣費與非自願離職證明。',
        areTheyRight: '【他有道理嗎？】完全違法！雇主若以不能勝任為由解僱，依法必須給付資遣費並開立非自願離職證明書，且需經 PIP 改善輔導未果才具合法性。',
        whatYouShouldDo: '【你現在該做什麼？】絕對不要在「自願離職單」上簽名！立即將打卡紀錄與薪資單備份截圖，點擊下方一鍵向所在地勞工局申請勞資爭議調解。',
        extractedDeadline: '即日起生效',
        potentialRisks: '一旦簽了自願離職，將喪失資遣費與請領 6 個月失業給付之權益。',
      );
    } else {
      return const PlainDocumentTranslation(
        documentType: '民事權益催告/存證信函',
        whatTheyWant: '【他想要什麼？】對方主張你未履行特定給付義務，要求你在限期內給付指定金額或履行協議。',
        areTheyRight: '【他有道理嗎？】需視雙方當初白紙黑字約定與實際金流憑證而定，若對方無明確憑證，空口催告不具強制執行力。',
        whatYouShouldDo: '【你現在該做什麼？】確認自己是否真有該筆欠款或未履行事項。若無，請於 7 日內發送反駁信函以正視聽，切勿已讀不回讓對方在訴訟中取得優勢。',
        extractedDeadline: '文到後 7 日內',
        potentialRisks: '若對方後續向法院聲請核發支付命令，收到後務必在 20 天內向法院聲明異議！',
      );
    }
  }
}

/// 對造公文白話文翻譯解讀面板
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

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgDark = isDark ? const Color(0xFF16241D) : const Color(0xFFF7FAF8);
    final cardBg = isDark ? const Color(0xFF1F332A) : Colors.white;
    final primaryGreen =
        isDark ? const Color(0xFF68B28B) : const Color(0xFF2C5E43);
    final amberText =
        isDark ? const Color(0xFFE5C07B) : const Color(0xFF9E6800);

    return Container(
      height: 0.88.sh,
      decoration: BoxDecoration(
        color: bgDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 20,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          // 頂部拖曳把手與標題
          Padding(
            padding: EdgeInsets.only(top: 12.h, left: 16.w, right: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 40.w),
                Container(
                  width: 36.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black26,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close_rounded,
                    color: isDark ? Colors.white70 : Colors.black54,
                    size: 22.sp,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: primaryGreen.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.translate_rounded,
                          size: 20.sp,
                          color: primaryGreen,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '對造公文/存證信函白話翻譯機',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF17231F),
                              ),
                            ),
                            Text(
                              '看不懂對方律師寫的文言文？一秒翻譯成 3 句白話人話',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),

                  // 輸入或貼上公文內文
                  Text(
                    '貼上或輸入收到的存證信函 / 律師函文字：',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF17231F),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isDark ? Colors.white12 : Colors.black12,
                      ),
                    ),
                    padding: EdgeInsets.all(12.w),
                    child: TextField(
                      controller: _inputController,
                      maxLines: 4,
                      style: TextStyle(fontSize: 12.sp, height: 1.4),
                      decoration: const InputDecoration.collapsed(
                        hintText: '請貼上對方寄來的信函文字，或點擊相機拍下信件...',
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),

                  // 快速範例 Pill
                  Row(
                    children: [
                      Text(
                        '快速試用：',
                        style: TextStyle(fontSize: 10.5.sp, color: Colors.grey),
                      ),
                      _buildSamplePill('房東扣押金', '按民法第423條，台端退租污損屋況，抵扣押金4萬元七日內清結。'),
                      SizedBox(width: 6.w),
                      _buildSamplePill('車禍求償35萬', '台端未注意車前狀況肇事追撞，限期五日內賠償維修與工作損失35萬元。'),
                    ],
                  ),
                  SizedBox(height: 14.h),

                  // 翻譯按鈕
                  SizedBox(
                    width: double.infinity,
                    height: 44.h,
                    child: ElevatedButton.icon(
                      onPressed: _isTranslating ? null : _handleTranslate,
                      icon: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
                      label: _isTranslating
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              '一鍵翻譯為 3 句白話文真相',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // 翻譯結果展示卡
                  if (_result != null) ...[
                    Container(
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: primaryGreen.withValues(alpha: 0.4),
                          width: 1.2.w,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 3.h),
                                decoration: BoxDecoration(
                                  color: primaryGreen,
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Text(
                                  _result!.documentType,
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '期限：${_result!.extractedDeadline}',
                                style: TextStyle(
                                  fontSize: 10.5.sp,
                                  fontWeight: FontWeight.bold,
                                  color: amberText,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),

                          // 1. 他想要什麼
                          _buildTranslationBlock(
                            Icons.help_outline_rounded,
                            _result!.whatTheyWant,
                            const Color(0xFFC0392B),
                            isDark,
                          ),
                          SizedBox(height: 10.h),

                          // 2. 他有道理嗎
                          _buildTranslationBlock(
                            Icons.balance_rounded,
                            _result!.areTheyRight,
                            amberText,
                            isDark,
                          ),
                          SizedBox(height: 10.h),

                          // 3. 你該做什麼
                          _buildTranslationBlock(
                            Icons.check_circle_outline_rounded,
                            _result!.whatYouShouldDo,
                            primaryGreen,
                            isDark,
                          ),
                        ],
                      ),
                    ),
                  ],
                  SizedBox(height: 30.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSamplePill(String title, String sampleText) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _inputController.text = sampleText;
          _result = null;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(100.r),
        ),
        child: Text(
          title,
          style: TextStyle(fontSize: 10.sp, color: Colors.black87),
        ),
      ),
    );
  }

  Widget _buildTranslationBlock(
    IconData icon,
    String text,
    Color accentColor,
    bool isDark,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16.sp, color: accentColor),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11.5.sp,
              height: 1.45,
              color: isDark ? Colors.white70 : const Color(0xFF2C3E35),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleTranslate() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isTranslating = true);
    HapticFeedback.mediumImpact();

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    setState(() {
      _result = PlainDocumentTranslation.parseFromRawLegalText(text);
      _isTranslating = false;
    });

    HapticFeedback.heavyImpact();
  }
}
