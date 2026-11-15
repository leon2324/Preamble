import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:preamble/app/app_state.dart';
import 'package:preamble/components/lawyer/lawyer_referral_sheet.dart';
import 'package:preamble/components/safety/plain_document_translator_sheet.dart';
import 'package:preamble/components/shared/custom_toast.dart';
import 'package:preamble/data/lawyer/lawyer_models.dart';
import 'package:preamble/data/learning/learning_game_state.dart';
import 'package:preamble/pages/learning/statute_database_page.dart';
import 'package:preamble/pages/learning/widgets/learning_result_action_bar.dart';
import 'package:preamble/pages/learning/widgets/legal_document_export_page.dart';
import 'package:preamble/pages/tools/widgets/document_signature_canvas.dart';
import 'package:preamble/theme/preamble_tokens.dart';

/// 獨立「法務實戰工具館 (Legal Toolkit Hub)」。
///
/// 由原本內嵌於「學習」分頁的 9 項工具升級抽離，並新增「契約條款風險審查器」，
/// 共計 10 項生活實戰工具，統一採用靜奢律政編輯風與雙重編碼數據視覺化。
class LegalToolkitHubPage extends StatefulWidget {
  const LegalToolkitHubPage({
    super.key,
    this.initialToolKey,
  });

  /// 支援英文語意 key（如 `'notice'`, `'contract'`, `'car'`）或中文舊稱（如 `'租屋催告'`）。
  final String? initialToolKey;

  @override
  State<LegalToolkitHubPage> createState() => _LegalToolkitHubPageState();
}

enum _ToolkitItem {
  notice('notice', '租屋存證信函', '書狀與契約', PhosphorIconsRegular.envelopeSimpleOpen),
  contract('contract', '契約地雷審查', '書狀與契約', PhosphorIconsRegular.fileMagnifyingGlass),
  consumer('consumer', '網購退貨催告', '書狀與契約', PhosphorIconsRegular.shoppingBagOpen),
  translator('translator', '判決術語白話', '書狀與契約', PhosphorIconsRegular.translate),
  car('car', '車禍折舊試算', '賠償與權益試算', PhosphorIconsRegular.carProfile),
  overtime('overtime', '勞基加班費試算', '賠償與權益試算', PhosphorIconsRegular.clockCountdown),
  marriage('marriage', '夫妻剩餘財產', '賠償與權益試算', PhosphorIconsRegular.scales),
  neighbor('neighbor', '鄰損漏水蒐證', '現場蒐證與自保', PhosphorIconsRegular.houseLine),
  privacy('privacy', '個資外洩自保', '現場蒐證與自保', PhosphorIconsRegular.shieldCheck),
  antifraud('antifraud', '防詐緊急圈存', '現場蒐證與自保', PhosphorIconsRegular.warningOctagon);

  const _ToolkitItem(this.key, this.label, this.group, this.icon);
  final String key;
  final String label;
  final String group;
  final IconData icon;

  static _ToolkitItem resolve(String? raw) {
    if (raw == null || raw.trim().isEmpty) return _ToolkitItem.notice;
    final key = raw.trim();
    for (final item in _ToolkitItem.values) {
      if (item.key == key || item.label == key) return item;
    }
    switch (key) {
      case '租屋催告':
      case '存證信函':
        return _ToolkitItem.notice;
      case '契約審閱':
      case '契約審查':
        return _ToolkitItem.contract;
      case '車禍計算':
        return _ToolkitItem.car;
      case '加班計算':
        return _ToolkitItem.overtime;
      case '網購退貨':
        return _ToolkitItem.consumer;
      case '翻譯機':
        return _ToolkitItem.translator;
      case '財產分配':
        return _ToolkitItem.marriage;
      case '鄰里蒐證':
        return _ToolkitItem.neighbor;
      case '自救清單':
        return _ToolkitItem.privacy;
      case '防詐騙':
        return _ToolkitItem.antifraud;
      default:
        return _ToolkitItem.notice;
    }
  }
}

class _LegalToolkitHubPageState extends State<LegalToolkitHubPage> {
  late _ToolkitItem _activeTool;

  // 1. 租屋存證信函
  int _rentNoticeType = 0; // 0: 修繕催告, 1: 期滿退押金
  final _landlordNameController = TextEditingController();
  final _rentAddressController = TextEditingController();
  final _brokenItemController = TextEditingController();
  final _noticeDaysController = TextEditingController(text: '7');
  final _leaseExpiryDateController = TextEditingController();
  final _depositAmountController = TextEditingController();
  String _rentNoticeResult = '';
  Uint8List? _signatureBytes;

  // 2. 契約地雷審查
  final _contractClauseController = TextEditingController();
  List<({String riskTitle, String lawBasis, String suggestion, bool isHighRisk})>
      _contractFindings = const [];

  // 3. 網購退貨催告
  final _sellerNameController = TextEditingController();
  final _productNameController = TextEditingController();
  final _receiveDateController = TextEditingController();
  String _consumerNoticeResult = '';

  // 4. 法律術語翻譯機
  final _translatorController = TextEditingController();
  String _translationOutput = '';
  static const Map<String, String> _termsMap = {
    '應予駁回': '白話結論：法院拒絕了原告／上訴人的這項請求，認定主張在法律上站不住腳。',
    '酌減': '白話結論：法院認為原本約定的違約金或賠償金額過高，依職權決定調降金額（常見於民法第 252 條）。',
    '按之': '白話結論：「依照這條法規或法理來看」，通常作為判決書引用法條的開頭語。',
    '矧以': '白話結論：「更何況是……」，法官用來補強前一段論點、加重說服力的連接詞。',
    '與有過失': '白話結論：被害人自己對事故發生或損害擴大也有一部分疏失，法院會依比例扣減賠償金額（民法第 217 條）。',
    '假執行': '白話結論：雖然案件還可以上訴還沒最終確定，但勝訴方可以先拿這份判決去查封對方財產（通常需先提擔保金）。',
  };

  // 5. 車禍折舊試算（含雙重編碼比例模型）
  bool _carIsMotorcycle = false;
  bool _carIsDecliningBalance = true;
  final _partsCostController = TextEditingController();
  final _laborCostController = TextEditingController();
  final _carAgeYearsController = TextEditingController();
  final _carAgeMonthsController = TextEditingController();
  String _depreciationResult = '';
  double _calcOriginalParts = 0;
  double _calcDepreciatedParts = 0;
  double _calcLabor = 0;

  // 6. 加班費試算
  final _salaryController = TextEditingController();
  final _weekdayOvertimeController = TextEditingController();
  final _holidayOvertimeController = TextEditingController();
  String _overtimeResult = '';
  double _calcWeekdayPay = 0;
  double _calcHolidayPay = 0;

  // 7. 夫妻剩餘財產差額分配
  final _husbandPropertyController = TextEditingController();
  final _husbandDebtController = TextEditingController();
  final _wifePropertyController = TextEditingController();
  final _wifeDebtController = TextEditingController();
  String _marriagePropertyResult = '';

  // 8~10. 蒐證與自保 SOP
  final Set<String> _checkedNeighbor = {};
  final Set<String> _checkedPrivacy = {};
  final Set<String> _checkedAntiFraud = {};

  static const List<String> _neighborSops = [
    '聯絡合格水電或抓漏技師勘驗，取得載明漏水成因之書面鑑定單。',
    '拍攝漏水天花板、壁癌剝落與受損財物之高畫質照片及連續錄影（含日期時間）。',
    '保留修繕估價單、發票與收據正本，區分必要修繕與裝潢升級費用。',
    '若為噪音爭議：於不同時段以分貝計連續錄影取證，並通報管委會或環保局留存紀錄。',
    '保存每次與樓上住戶、管委會協調之 LINE 對話截圖或存證催告紀錄。',
  ];

  static const List<String> _privacySops = [
    '立即聯絡發卡銀行或行動支付機構辦理緊急止付、爭議款申訴與換卡。',
    '更換所有共用相同帳密之信箱、網銀與社群帳號密碼，並強制開啟雙重驗證 (2FA)。',
    '完整截圖可疑登入通知、釣魚簡訊網址與扣款紀錄（切勿刪除原始簡訊）。',
    '撥打 165 反詐騙專線或向警政署刑事局報案，取得受（處）理案件證明單。',
    '若為企業平台外洩個資，依個資法第 28/29 條保留求償紀錄並向目的事業主管機關檢舉。',
  ];

  static const List<String> _antiFraudSops = [
    '匯款後黃金 30 分鐘內立即撥打 165 專線，提供對方帳號、銀行代碼、匯款時間與金額啟動緊急圈存。',
    '攜帶身分證、印章、轉帳明細正本或網銀截圖至就近派出所製作筆錄，聲請通報警示帳戶。',
    '完整備份詐騙群組對話、投資平台網址、對方收款帳號畫面（避免對方收回訊息）。',
    '若自身帳戶遭冒用列為警示帳戶，備妥求職／借貸對話證據向原通報分局聲請解除警示。',
  ];

  @override
  void initState() {
    super.initState();
    _activeTool = _ToolkitItem.resolve(widget.initialToolKey);
  }

  @override
  void dispose() {
    _landlordNameController.dispose();
    _rentAddressController.dispose();
    _brokenItemController.dispose();
    _noticeDaysController.dispose();
    _leaseExpiryDateController.dispose();
    _depositAmountController.dispose();
    _contractClauseController.dispose();
    _sellerNameController.dispose();
    _productNameController.dispose();
    _receiveDateController.dispose();
    _translatorController.dispose();
    _partsCostController.dispose();
    _laborCostController.dispose();
    _carAgeYearsController.dispose();
    _carAgeMonthsController.dispose();
    _salaryController.dispose();
    _weekdayOvertimeController.dispose();
    _holidayOvertimeController.dispose();
    _husbandPropertyController.dispose();
    _husbandDebtController.dispose();
    _wifePropertyController.dispose();
    _wifeDebtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final bottomSafe = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: t.canvas,
      appBar: AppBar(
        backgroundColor: t.canvas,
        elevation: 0,
        leading: IconButton(
          icon: Icon(PhosphorIconsRegular.caretLeft, color: t.textPrimary, size: 20.sp),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          '法務實戰工具館',
          style: t.serifTitle(size: 18.sp, weight: FontWeight.w700),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: TextButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const StatuteDatabasePage(),
                  ),
                );
              },
              icon: Icon(PhosphorIconsRegular.bookBookmark, size: 15.sp, color: t.brandPrimary),
              label: Text(
                '六法文庫',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: t.brandPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 36.h + bottomSafe),
        children: [
          _buildHeroUtilityBanner(t),
          SizedBox(height: 16.h),
          _buildToolSelectorRail(t),
          SizedBox(height: 16.h),
          _buildActiveToolWorkspace(t),
          SizedBox(height: 18.h),
          _buildLawyerEscalationFooter(t),
        ],
      ),
    );
  }

  Widget _buildHeroUtilityBanner(PreambleTokens t) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: t.brandPrimaryStrong,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: t.accentBrass.withValues(alpha: 0.35)),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12.w,
        runSpacing: 10.h,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 225.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(PhosphorIconsFill.sealCheck, color: t.accentBrass, size: 15.sp),
                    SizedBox(width: 6.w),
                    Flexible(
                      child: Text(
                        '法定公式試算 · 標準書狀草擬',
                        style: TextStyle(
                          color: t.accentBrass,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Text(
                  '收到公文或存證信函看不懂？',
                  style: t.serifTitle(
                    size: 16.sp,
                    color: const Color(0xFFFAF8F4),
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  '一鍵貼上或掃描信件，3 秒拆解潛在法律期限與應對策略。',
                  style: t.sansBody(
                    size: 11.5.sp,
                    color: const Color(0xFFD6E2DC),
                  ),
                ),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: () => PlainDocumentTranslatorSheet.show(context),
            style: FilledButton.styleFrom(
              backgroundColor: t.accentBrass,
              foregroundColor: const Color(0xFF151C19),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999.r),
              ),
            ),
            icon: Icon(PhosphorIconsBold.scan, size: 15.sp),
            label: Text(
              '公文秒解讀',
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolSelectorRail(PreambleTokens t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '選擇實戰工具',
              style: t.sansTitle(size: 13.5.sp, color: t.textSecondary),
            ),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: t.brandContainer,
                borderRadius: BorderRadius.circular(999.r),
              ),
              child: Text(
                _activeTool.group,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: t.brandOnContainer,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: _ToolkitItem.values.map((item) {
              final selected = item == _activeTool;
              return Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _activeTool = item);
                    },
                    borderRadius: BorderRadius.circular(14.r),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 9.h),
                      decoration: BoxDecoration(
                        color: selected ? t.brandPrimary : t.surface,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: selected ? t.brandPrimary : t.border,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.icon,
                            size: 16.sp,
                            color: selected ? t.brandOnPrimary : t.brandPrimary,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 12.5.sp,
                              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                              color: selected ? t.brandOnPrimary : t.textPrimary,
                            ),
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

  Widget _buildActiveToolWorkspace(PreambleTokens t) {
    switch (_activeTool) {
      case _ToolkitItem.notice:
        return _buildRentNoticeCard(t);
      case _ToolkitItem.contract:
        return _buildContractScannerCard(t);
      case _ToolkitItem.consumer:
        return _buildConsumerNoticeCard(t);
      case _ToolkitItem.translator:
        return _buildTranslatorCard(t);
      case _ToolkitItem.car:
        return _buildCarDepreciationCard(t);
      case _ToolkitItem.overtime:
        return _buildOvertimeCard(t);
      case _ToolkitItem.marriage:
        return _buildMarriagePropertyCard(t);
      case _ToolkitItem.neighbor:
        return _buildSopChecklistCard(
          t: t,
          title: '鄰里漏水與噪音蒐證檢核包',
          lawCitation: '民法第 184、191、767、793 條 · 公寓大廈管理條例第 6 條',
          subtitle: '進入調解或民事訴訟前，法官認定責任歸屬與修繕金額的 5 項核心證據：',
          items: _neighborSops,
          checkedSet: _checkedNeighbor,
          saveListTitle: '鄰里糾紛蒐證清單',
        );
      case _ToolkitItem.privacy:
        return _buildSopChecklistCard(
          t: t,
          title: '個資外洩與盜刷應變自保清單',
          lawCitation: '個人資料保護法第 28、29 條 · 刑法第 358~360 條',
          subtitle: '發生帳號遭盜用、個資外流或不明扣款時，依序完成以保全免責與求償證據：',
          items: _privacySops,
          checkedSet: _checkedPrivacy,
          saveListTitle: '個資外洩應變清單',
        );
      case _ToolkitItem.antifraud:
        return _buildSopChecklistCard(
          t: t,
          title: '詐騙匯款緊急圈存與警示自救 SOP',
          lawCitation: '刑法第 339-4 條 · 洗錢防制法 · 存款帳戶及其疑似不法或顯屬異常交易管理辦法',
          subtitle: '把握匯款後黃金 30 分鐘攔截金流，或解除無辜受牽連之警示帳戶：',
          items: _antiFraudSops,
          checkedSet: _checkedAntiFraud,
          saveListTitle: '防詐騙自救清單',
        );
    }
  }

  // ---------------------------------------------------------------------------
  // 1. 租屋存證信函起草器
  // ---------------------------------------------------------------------------
  Widget _buildRentNoticeCard(PreambleTokens t) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: t.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWorkspaceHeader(
            t: t,
            icon: PhosphorIconsRegular.envelopeSimpleOpen,
            title: '租屋催告存證信函起草器',
            lawTag: '民法第 429、430 條 · 租賃條例第 34 條',
            description: '產生符合郵局正式意思表示結構之催告函草稿，支援「設備修繕催告」與「期滿返還押金」雙模式。',
          ),
          SizedBox(height: 14.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _buildModeChip(
                t: t,
                selected: _rentNoticeType == 0,
                label: '設備損壞限期修繕',
                icon: PhosphorIconsRegular.wrench,
                onTap: () => setState(() {
                  _rentNoticeType = 0;
                  _rentNoticeResult = '';
                }),
              ),
              _buildModeChip(
                t: t,
                selected: _rentNoticeType == 1,
                label: '租約期滿退還押金',
                icon: PhosphorIconsRegular.coins,
                onTap: () => setState(() {
                  _rentNoticeType = 1;
                  _rentNoticeResult = '';
                }),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          _buildLabeledField(
            t: t,
            controller: _landlordNameController,
            label: '收件人（出租人／房東姓名）',
            hint: '例如：王大明',
          ),
          _buildLabeledField(
            t: t,
            controller: _rentAddressController,
            label: '承租房屋完整地址',
            hint: '例如：台北市大安區仁愛路四段 XX 號 X 樓',
          ),
          if (_rentNoticeType == 0)
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildLabeledField(
                    t: t,
                    controller: _brokenItemController,
                    label: '故障損壞項目',
                    hint: '例如：熱水器無法點火',
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildLabeledField(
                    t: t,
                    controller: _noticeDaysController,
                    label: '限期天數',
                    hint: '7',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: _buildLabeledField(
                    t: t,
                    controller: _leaseExpiryDateController,
                    label: '租約屆滿日',
                    hint: '例如：2026年10月31日',
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildLabeledField(
                    t: t,
                    controller: _depositAmountController,
                    label: '應退押金 (元)',
                    hint: '例如：32000',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            _buildLabeledField(
              t: t,
              controller: _noticeDaysController,
              label: '限期返還天數 (天)',
              hint: '7',
              keyboardType: TextInputType.number,
            ),
          ],
          SizedBox(height: 6.h),
          DocumentSignatureCanvas(
            onSignatureSaved: (bytes) => _signatureBytes = bytes,
            onCleared: () => _signatureBytes = null,
          ),
          SizedBox(height: 14.h),
          _buildPrimaryActionRow(
            t: t,
            primaryLabel: '生成正式催告草稿',
            onPrimary: _generateRentNotice,
            showClear: _rentNoticeResult.isNotEmpty,
            onClear: () => setState(() {
              _landlordNameController.clear();
              _rentAddressController.clear();
              _brokenItemController.clear();
              _leaseExpiryDateController.clear();
              _depositAmountController.clear();
              _rentNoticeResult = '';
            }),
          ),
          if (_rentNoticeResult.isNotEmpty) ...[
            SizedBox(height: 16.h),
            _buildFormalDraftPreview(
              t: t,
              docTitle: _rentNoticeType == 0 ? '設備修繕催告存證信函' : '期滿退還押金催告存證信函',
              content: _rentNoticeResult,
            ),
          ],
        ],
      ),
    );
  }

  void _generateRentNotice() {
    final landlord = _landlordNameController.text.trim().isEmpty
        ? '（出租人姓名）'
        : _landlordNameController.text.trim();
    final addr = _rentAddressController.text.trim().isEmpty
        ? '（承租房屋地址）'
        : _rentAddressController.text.trim();
    final days = _noticeDaysController.text.trim().isEmpty
        ? '7'
        : _noticeDaysController.text.trim();

    setState(() {
      if (_rentNoticeType == 0) {
        final item = _brokenItemController.text.trim().isEmpty
            ? '室內附屬設備'
            : _brokenItemController.text.trim();
        _rentNoticeResult = '郵局存證信函草稿（設備修繕定期催告）\n'
            '────────────────────────────────\n'
            '寄件人（承租人）：（請填寫您的姓名）\n'
            '收件人（出租人）：$landlord\n'
            '標的物地址：$addr\n'
            '簽署狀態：${_signatureBytes != null ? "已附親筆電子簽名檔" : "待親筆簽章"}\n\n'
            '【主旨】\n'
            '請台端於文到 $days 日內履行租賃物「$item」之法定修繕義務，詳如說明。\n\n'
            '【說明】\n'
            '一、本人前向台端承租門牌號碼「$addr」之房屋，租賃期間內因「$item」發生損壞故障（非可歸責於承租人之正常使用耗損），已妨礙租賃物合於約定使用收益之狀態。\n'
            '二、按民法第 429 條第 1 項規定，租賃物之修繕，除契約另有訂定或另有習慣外，由出租人負擔。爰特以此函正式催告台端於收受本函起 $days 日內修復完畢。\n'
            '三、倘屆期仍未修繕，本人將依民法第 430 條規定自行雇工修復，並逕自次期租金中扣除全部必要修繕費用，或依法終止租約，特此存證通知。';
      } else {
        final expiry = _leaseExpiryDateController.text.trim().isEmpty
            ? '租期屆滿日'
            : _leaseExpiryDateController.text.trim();
        final deposit = _depositAmountController.text.trim().isEmpty
            ? '______'
            : _depositAmountController.text.trim();
        _rentNoticeResult = '郵局存證信函草稿（期滿返還押租金催告）\n'
            '────────────────────────────────\n'
            '寄件人（承租人）：（請填寫您的姓名）\n'
            '收件人（出租人）：$landlord\n'
            '標的物地址：$addr\n'
            '簽署狀態：${_signatureBytes != null ? "已附親筆電子簽名檔" : "待親筆簽章"}\n\n'
            '【主旨】\n'
            '請台端於文到 $days 日內全額返還押租金新臺幣 $deposit 元整，詳如說明。\n\n'
            '【說明】\n'
            '一、本人承租台端所有「$addr」房屋，租期業於 $expiry 屆滿消滅，並已完成點交返還房屋、結清相關水電管理費用，並無任何積欠債務或毀損情事。\n'
            '二、依租賃住宅市場發展及管理條例與民法押租金契約法理，台端負有全額返還押租金新臺幣 $deposit 元整之義務。特以此函催告於文到 $days 日內匯還。\n'
            '三、逾期未還者，本人將依法請求自遲延日起按法定年利率 5% 計算之遲延利息，並逕向調解委員會聲請調解或向法院聲請核發支付命令，希勿自誤。';
      }
      LearningGameState.instance.incrementTranslatorUsage();
    });
  }

  // ---------------------------------------------------------------------------
  // 2. 契約條款風險審查器
  // ---------------------------------------------------------------------------
  Widget _buildContractScannerCard(PreambleTokens t) {
    final presets = [
      (
        '租屋霸王條款範例',
        '乙方若提前終止租約，應賠償甲方相當於三個月租金之違約金，且不得申報租金所得稅扣抵，否則稅金概由乙方負擔。',
      ),
      (
        '職場競業與罰則範例',
        '員工離職後三年內不得任職於任何同業或相關產業，違反者應無條件賠償公司新臺幣兩百萬元懲罰性違約金，公司無須提供離職後補償。',
      ),
    ];

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: t.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWorkspaceHeader(
            t: t,
            icon: PhosphorIconsRegular.fileMagnifyingGlass,
            title: '契約條款地雷審查器',
            lawTag: '民法第 247-1 條 · 定型化契約應記載及不得記載事項',
            description: '貼上租約、勞動契約或外包合約條文，自動比對台灣法定強行規定與無效霸王條款紅線。',
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 6.h,
            children: presets.map((p) {
              return ActionChip(
                backgroundColor: t.surfaceSubtle,
                side: BorderSide(color: t.border),
                label: Text(
                  '帶入：${p.$1}',
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w600,
                    color: t.textPrimary,
                  ),
                ),
                onPressed: () {
                  setState(() => _contractClauseController.text = p.$2);
                  _analyzeContractClause();
                },
              );
            }).toList(),
          ),
          SizedBox(height: 12.h),
          _buildLabeledField(
            t: t,
            controller: _contractClauseController,
            label: '欲審查之合約條款原文',
            hint: '請貼上合約中的違約金、修繕、報稅限制或競業禁止條款...',
            maxLines: 4,
          ),
          _buildPrimaryActionRow(
            t: t,
            primaryLabel: '掃描條款法律效力',
            onPrimary: _analyzeContractClause,
            showClear: _contractFindings.isNotEmpty,
            onClear: () => setState(() {
              _contractClauseController.clear();
              _contractFindings = const [];
            }),
          ),
          if (_contractFindings.isNotEmpty) ...[
            SizedBox(height: 16.h),
            ..._contractFindings.map((f) {
              final badgeColor = f.isHighRisk ? t.semanticUrgent : t.accentBrass;
              final badgeBg =
                  f.isHighRisk ? t.semanticUrgentContainer : t.accentBrassContainer;
              return Container(
                margin: EdgeInsets.only(bottom: 10.h),
                padding: EdgeInsets.all(14.w),
                decoration: t.subtleBoxDecoration(borderColor: badgeColor.withValues(alpha: 0.45)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            borderRadius: BorderRadius.circular(999.r),
                          ),
                          child: Text(
                            f.isHighRisk ? '高風險 · 依法可能無效' : '審閱重點提醒',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: badgeColor,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            f.riskTitle,
                            style: t.sansTitle(size: 13.5.sp),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text('法規依據：${f.lawBasis}', style: t.sansBody(size: 12.sp, color: t.brandPrimary)),
                    SizedBox(height: 4.h),
                    Text('議約對策：${f.suggestion}', style: t.sansBody(size: 12.5.sp, color: t.textPrimary)),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  void _analyzeContractClause() {
    final raw = _contractClauseController.text.trim();
    if (raw.isEmpty) return;

    final findings =
        <({String riskTitle, String lawBasis, String suggestion, bool isHighRisk})>[];

    if (raw.contains('稅') || raw.contains('扣抵') || raw.contains('設籍')) {
      findings.add((
        riskTitle: '禁止報稅或轉嫁稅賦條款「依法無效」',
        lawBasis: '住宅租賃定型化契約不得記載事項第 3、4、5 點 · 消保法第 17 條',
        suggestion: '房東不得限制房客申報租金支出扣抵或遷入戶籍，亦不得約定將增加之稅賦轉嫁由房客負擔，該特約條款自始無效。',
        isHighRisk: true,
      ));
    }
    if (raw.contains('三個月') || raw.contains('兩個月') || raw.contains('違約金')) {
      findings.add((
        riskTitle: '提前終止違約金上限檢核',
        lawBasis: '住宅租賃定型化契約應記載事項第 14 點 · 民法第 252 條',
        suggestion: '住宅租賃若約定得提前終止，最高違約金不得超過「1 個月租金」；一般商務違約金過高亦可請法院依民法 252 條酌減。',
        isHighRisk: raw.contains('三個月') || raw.contains('兩百萬'),
      ));
    }
    if (raw.contains('競業') || raw.contains('同業') || raw.contains('離職後')) {
      findings.add((
        riskTitle: '離職後競業禁止無合理補償者「無效」',
        lawBasis: '勞動基準法第 9 條之 1 第 1 項及第 3 項、第 4 項',
        suggestion: '競業期間最長不得逾 2 年，且雇主必須按月給予不低於離職時月平均工資 50% 之合理補償；欠缺補償或逾越 2 年部分均屬無效。',
        isHighRisk: true,
      ));
    }
    if (findings.isEmpty) {
      findings.add((
        riskTitle: '定型化契約顯失公平審查基準',
        lawBasis: '民法第 247 條之 1 · 消費者保護法第 12 條',
        suggestion: '請確認條款是否有「免除對造故意重大過失責任」、「限制我方行使權利」或「加重我方舉證義務」；建議保留修改磋商對話紀錄。',
        isHighRisk: false,
      ));
    }

    setState(() => _contractFindings = findings);
  }

  // ---------------------------------------------------------------------------
  // 3. 網購退貨催告
  // ---------------------------------------------------------------------------
  Widget _buildConsumerNoticeCard(PreambleTokens t) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: t.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWorkspaceHeader(
            t: t,
            icon: PhosphorIconsRegular.shoppingBagOpen,
            title: '網購七日猶豫期退貨解約通知',
            lawTag: '消費者保護法第 19 條第 1 項',
            description: '針對向企業經營者網購商品遭拒退貨時，產生具法律解除契約效力之正式書面通知。',
          ),
          SizedBox(height: 14.h),
          _buildLabeledField(
            t: t,
            controller: _sellerNameController,
            label: '賣家／電商企業名稱',
            hint: '例如：〇〇股份有限公司／〇〇網購旗艦店',
          ),
          _buildLabeledField(
            t: t,
            controller: _productNameController,
            label: '購買商品名稱與訂單編號',
            hint: '例如：降噪藍牙耳機乙組（訂單 #TW8821）',
          ),
          _buildLabeledField(
            t: t,
            controller: _receiveDateController,
            label: '實際收受商品日期',
            hint: '例如：2026年11月3日',
          ),
          _buildPrimaryActionRow(
            t: t,
            primaryLabel: '生成解約退貨通知',
            onPrimary: () {
              final seller = _sellerNameController.text.trim().isEmpty
                  ? '（出賣人名稱）'
                  : _sellerNameController.text.trim();
              final product = _productNameController.text.trim().isEmpty
                  ? '（訂購商品）'
                  : _productNameController.text.trim();
              final date = _receiveDateController.text.trim().isEmpty
                  ? '收受商品日'
                  : _receiveDateController.text.trim();
              setState(() {
                _consumerNoticeResult = '通訊交易解除買賣契約正式通知函\n'
                    '────────────────────────────────\n'
                    '買受人（消費者）：（請填寫姓名）\n'
                    '出賣人（企業經營者）：$seller\n\n'
                    '【主旨】\n'
                    '依法行使消費者保護法第 19 條七日猶豫期權利，解除「$product」買賣契約並請求返還全部價金。\n\n'
                    '【說明】\n'
                    '一、本人於 $date 收受向貴司透過通訊交易購買之「$product」，商品均保持完整未逾越必要檢查限度。\n'
                    '二、按消費者保護法第 19 條第 1 項及第 2 項規定，通訊交易消費者得於收受商品後七日內，以書面通知解除契約，無須說明理由及負擔任何費用（包含退貨運費），任何相反特約均屬無效。\n'
                    '三、特以此函於法定七日期間內正式通知解除契約，請於文到後儘速派員取回商品並全額退還款項；逾期未處理將向各縣市消保官提出申訴。';
              });
            },
            showClear: _consumerNoticeResult.isNotEmpty,
            onClear: () => setState(() {
              _sellerNameController.clear();
              _productNameController.clear();
              _receiveDateController.clear();
              _consumerNoticeResult = '';
            }),
          ),
          if (_consumerNoticeResult.isNotEmpty) ...[
            SizedBox(height: 16.h),
            _buildFormalDraftPreview(
              t: t,
              docTitle: '網購七日猶豫期解約通知書',
              content: _consumerNoticeResult,
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 4. 判決術語白話翻譯機
  // ---------------------------------------------------------------------------
  Widget _buildTranslatorCard(PreambleTokens t) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: t.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWorkspaceHeader(
            t: t,
            icon: PhosphorIconsRegular.translate,
            title: '判決書文言術語白話翻譯機',
            lawTag: '司法文書常規用語對照',
            description: '點選常見艱澀詞彙或直接輸入裁判書字詞，立即轉譯為具體權利義務影響。',
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: _termsMap.keys.map((term) {
              final active = _translatorController.text.trim() == term;
              return InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _translatorController.text = term;
                    _translationOutput = _termsMap[term]!;
                  });
                },
                borderRadius: BorderRadius.circular(999.r),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: active ? t.brandContainer : t.surfaceSubtle,
                    borderRadius: BorderRadius.circular(999.r),
                    border: Border.all(
                      color: active ? t.brandPrimary : t.border,
                    ),
                  ),
                  child: Text(
                    term,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: active ? t.brandOnContainer : t.textPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 14.h),
          _buildLabeledField(
            t: t,
            controller: _translatorController,
            label: '輸入欲查詢之法律術語',
            hint: '例如：應予駁回、與有過失、假執行...',
          ),
          _buildPrimaryActionRow(
            t: t,
            primaryLabel: '轉譯白話釋義',
            onPrimary: () {
              final q = _translatorController.text.trim();
              if (q.isEmpty) return;
              setState(() {
                _translationOutput = _termsMap[q] ??
                    '白話解析：「$q」為正式裁判與程序文書用語，核心在於界定請求權成立要件、舉證責任分配或程序效力；若為整段公文，可點上方「公文秒解讀」進行全文分析。';
              });
            },
            showClear: _translationOutput.isNotEmpty,
            onClear: () => setState(() {
              _translatorController.clear();
              _translationOutput = '';
            }),
          ),
          if (_translationOutput.isNotEmpty) ...[
            SizedBox(height: 14.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(14.w),
              decoration: t.subtleBoxDecoration(
                fill: t.brandContainer,
                borderColor: t.brandPrimary.withValues(alpha: 0.35),
              ),
              child: Text(
                _translationOutput,
                style: t.sansBody(size: 13.5.sp, color: t.brandOnContainer),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 5. 車禍零件折舊與工資試算機（含雙重編碼比例長條圖）
  // ---------------------------------------------------------------------------
  Widget _buildCarDepreciationCard(PreambleTokens t) {
    final totalBeforeDep = _calcOriginalParts + _calcLabor;
    final depDeducted = (_calcOriginalParts - _calcDepreciatedParts).clamp(0.0, double.infinity);

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: t.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWorkspaceHeader(
            t: t,
            icon: PhosphorIconsRegular.carProfile,
            title: '車禍零件折舊與工資求償試算',
            lawTag: '民法第 196、213 條 · 固定資產耐用年數表',
            description: '實務上「換新零件」須扣除折舊，但「工資、鈑金與烤漆」100% 免折舊，且依法保留最低基本殘值。',
          ),
          SizedBox(height: 14.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _buildModeChip(
                t: t,
                selected: !_carIsMotorcycle,
                label: '自用汽車（耐用 5 年）',
                icon: PhosphorIconsRegular.car,
                onTap: () => setState(() => _carIsMotorcycle = false),
              ),
              _buildModeChip(
                t: t,
                selected: _carIsMotorcycle,
                label: '機車（耐用 3 年）',
                icon: PhosphorIconsRegular.motorcycle,
                onTap: () => setState(() => _carIsMotorcycle = true),
              ),
              _buildModeChip(
                t: t,
                selected: _carIsDecliningBalance,
                label: '定率遞減法（法院主流）',
                icon: PhosphorIconsRegular.chartLineDown,
                onTap: () => setState(() => _carIsDecliningBalance = true),
              ),
              _buildModeChip(
                t: t,
                selected: !_carIsDecliningBalance,
                label: '平均法（直線折舊）',
                icon: PhosphorIconsRegular.minus,
                onTap: () => setState(() => _carIsDecliningBalance = false),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: _buildLabeledField(
                  t: t,
                  controller: _partsCostController,
                  label: '全新零件估價 (元)',
                  hint: '15000',
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildLabeledField(
                  t: t,
                  controller: _laborCostController,
                  label: '工資／烤漆費 (免折舊)',
                  hint: '8000',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _buildLabeledField(
                  t: t,
                  controller: _carAgeYearsController,
                  label: '出廠已使用年數',
                  hint: '3',
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildLabeledField(
                  t: t,
                  controller: _carAgeMonthsController,
                  label: '零頭月數 (0~11)',
                  hint: '6',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          _buildPrimaryActionRow(
            t: t,
            primaryLabel: '試算法院合理判賠額',
            onPrimary: _calculateCarDepreciation,
            showClear: _depreciationResult.isNotEmpty,
            onClear: () => setState(() {
              _partsCostController.clear();
              _laborCostController.clear();
              _carAgeYearsController.clear();
              _carAgeMonthsController.clear();
              _depreciationResult = '';
            }),
          ),
          if (_depreciationResult.isNotEmpty && totalBeforeDep > 0) ...[
            SizedBox(height: 16.h),
            // 雙重編碼：折舊 vs 殘值 vs 工資空間比例條
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: t.subtleBoxDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('求償結構視覺對照（雙重編碼比例）', style: t.sansTitle(size: 12.5.sp)),
                  SizedBox(height: 8.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: SizedBox(
                      height: 14.h,
                      child: Row(
                        children: [
                          if (_calcDepreciatedParts > 0)
                            Expanded(
                              flex: (_calcDepreciatedParts * 100 ~/ totalBeforeDep).clamp(1, 100),
                              child: Container(color: t.brandPrimary),
                            ),
                          if (_calcLabor > 0)
                            Expanded(
                              flex: (_calcLabor * 100 ~/ totalBeforeDep).clamp(1, 100),
                              child: Container(color: t.accentBrass),
                            ),
                          if (depDeducted > 0)
                            Expanded(
                              flex: (depDeducted * 100 ~/ totalBeforeDep).clamp(1, 100),
                              child: Container(color: t.borderStrong),
                            ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 12.w,
                    runSpacing: 4.h,
                    children: [
                      _buildLegendDot(t, t.brandPrimary, '零件殘值 NT\$${_calcDepreciatedParts.toStringAsFixed(0)}'),
                      _buildLegendDot(t, t.accentBrass, '免折舊工資 NT\$${_calcLabor.toStringAsFixed(0)}'),
                      _buildLegendDot(t, t.borderStrong, '依法扣除折舊 NT\$${depDeducted.toStringAsFixed(0)}'),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            _buildFormalDraftPreview(
              t: t,
              docTitle: '車禍維修折舊與合理求償計算明細表',
              content: _depreciationResult,
            ),
          ],
        ],
      ),
    );
  }

  void _calculateCarDepreciation() {
    final p = double.tryParse(_partsCostController.text.trim()) ?? 0;
    final l = double.tryParse(_laborCostController.text.trim()) ?? 0;
    final y = int.tryParse(_carAgeYearsController.text.trim()) ?? 0;
    final m = int.tryParse(_carAgeMonthsController.text.trim()) ?? 0;
    if (p <= 0 && l <= 0) return;

    final n = _carIsMotorcycle ? 3 : 5;
    final r = _carIsMotorcycle ? 0.536 : 0.369;
    final minResidual = p / (n + 1.0);

    var residual = p;
    var dep = 0.0;

    if (_carIsDecliningBalance) {
      for (var i = 0; i < y; i++) {
        final d = residual * r;
        residual -= d;
        dep += d;
      }
      if (m > 0) {
        final d = residual * r * (m / 12.0);
        residual -= d;
        dep += d;
      }
    } else {
      final monthlyDep = p / ((n + 1.0) * 12.0);
      dep = monthlyDep * (y * 12 + m);
      residual = p - dep;
    }

    if (p > 0 && residual < minResidual) {
      residual = minResidual;
      dep = p - minResidual;
    }

    final totalClaim = residual + l;
    setState(() {
      _calcOriginalParts = p;
      _calcDepreciatedParts = residual;
      _calcLabor = l;
      _depreciationResult = '【車禍損害賠償法定折舊計算表】\n'
          '• 車種耐用年限：${_carIsMotorcycle ? "機車（耐用 3 年）" : "自用小客車（耐用 5 年）"}\n'
          '• 折舊計算基準：${_carIsDecliningBalance ? "定率遞減法" : "平均法"}\n'
          '• 原估零件總額：NT\$ ${p.toStringAsFixed(0)} 元\n'
          '• 依法扣除折舊：-NT\$ ${dep.toStringAsFixed(0)} 元\n'
          '• 零件折舊後殘值：NT\$ ${residual.toStringAsFixed(0)} 元\n'
          '• 鈑金烤漆與工資：NT\$ ${l.toStringAsFixed(0)} 元（依法不計折舊）\n'
          '────────────────────────────────\n'
          '法院實務認定合理請求總額：NT\$ ${totalClaim.toStringAsFixed(0)} 元';
    });
  }

  // ---------------------------------------------------------------------------
  // 6. 加班費試算
  // ---------------------------------------------------------------------------
  Widget _buildOvertimeCard(PreambleTokens t) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: t.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWorkspaceHeader(
            t: t,
            icon: PhosphorIconsRegular.clockCountdown,
            title: '勞基法加班費加成試算機',
            lawTag: '勞動基準法第 24 條',
            description: '以平日每小時工資額（月薪 ÷ 240）為基準，精算平日延長工時（4/3、5/3 倍）與休息日出勤（1.34、1.67、2.67 倍）應領總額。',
          ),
          SizedBox(height: 14.h),
          _buildLabeledField(
            t: t,
            controller: _salaryController,
            label: '經常性月薪總額 (元)',
            hint: '例如：42000',
            keyboardType: TextInputType.number,
          ),
          Row(
            children: [
              Expanded(
                child: _buildLabeledField(
                  t: t,
                  controller: _weekdayOvertimeController,
                  label: '平日加班總時數',
                  hint: '例如：8',
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildLabeledField(
                  t: t,
                  controller: _holidayOvertimeController,
                  label: '休息日出勤時數',
                  hint: '例如：8',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          _buildPrimaryActionRow(
            t: t,
            primaryLabel: '試算應領加班費',
            onPrimary: () {
              final salary = double.tryParse(_salaryController.text.trim()) ?? 0;
              if (salary <= 0) return;
              final wh = double.tryParse(_weekdayOvertimeController.text.trim()) ?? 0;
              final hh = double.tryParse(_holidayOvertimeController.text.trim()) ?? 0;
              final rate = salary / 240.0;

              final weekdayPay = wh <= 2
                  ? wh * rate * (4.0 / 3.0)
                  : (2 * rate * (4.0 / 3.0)) + ((wh - 2) * rate * (5.0 / 3.0));

              var holidayPay = 0.0;
              if (hh > 0) {
                if (hh <= 2) {
                  holidayPay = hh * rate * 1.34;
                } else if (hh <= 8) {
                  holidayPay = (2 * rate * 1.34) + ((hh - 2) * rate * 1.67);
                } else {
                  holidayPay = (2 * rate * 1.34) + (6 * rate * 1.67) + ((hh - 8) * rate * 2.67);
                }
              }

              setState(() {
                _calcWeekdayPay = weekdayPay;
                _calcHolidayPay = holidayPay;
                _overtimeResult = '【勞基法第 24 條加班費試算明細】\n'
                    '• 平日每小時工資基準：NT\$ ${rate.toStringAsFixed(1)} 元／時\n'
                    '• 平日延長工時應領：NT\$ ${weekdayPay.toStringAsFixed(0)} 元\n'
                    '• 休息日出勤應領：NT\$ ${holidayPay.toStringAsFixed(0)} 元\n'
                    '────────────────────────────────\n'
                    '法定最低應給付加班費合計：NT\$ ${(weekdayPay + holidayPay).toStringAsFixed(0)} 元';
              });
            },
            showClear: _overtimeResult.isNotEmpty,
            onClear: () => setState(() {
              _salaryController.clear();
              _weekdayOvertimeController.clear();
              _holidayOvertimeController.clear();
              _overtimeResult = '';
            }),
          ),
          if (_overtimeResult.isNotEmpty) ...[
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: _buildKpiBox(t, '平日延長工時', 'NT\$ ${_calcWeekdayPay.toStringAsFixed(0)}'),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _buildKpiBox(t, '休息日出勤', 'NT\$ ${_calcHolidayPay.toStringAsFixed(0)}'),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            _buildFormalDraftPreview(
              t: t,
              docTitle: '勞基法加班費計算明細表',
              content: _overtimeResult,
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 7. 夫妻剩餘財產差額分配
  // ---------------------------------------------------------------------------
  Widget _buildMarriagePropertyCard(PreambleTokens t) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: t.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWorkspaceHeader(
            t: t,
            icon: PhosphorIconsRegular.scales,
            title: '夫妻剩餘財產差額分配試算',
            lawTag: '民法第 1030 條之 1',
            description: '法定財產制關係消滅時，雙方現存之婚後財產（不含繼承或無償取得）扣除婚後負債後，就雙方剩餘差額平均分配。',
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: _buildLabeledField(
                  t: t,
                  controller: _husbandPropertyController,
                  label: '甲方婚後財產 (元)',
                  hint: '5000000',
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildLabeledField(
                  t: t,
                  controller: _husbandDebtController,
                  label: '甲方婚後負債 (元)',
                  hint: '1000000',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _buildLabeledField(
                  t: t,
                  controller: _wifePropertyController,
                  label: '乙方婚後財產 (元)',
                  hint: '2000000',
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildLabeledField(
                  t: t,
                  controller: _wifeDebtController,
                  label: '乙方婚後負債 (元)',
                  hint: '200000',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          _buildPrimaryActionRow(
            t: t,
            primaryLabel: '試算剩餘財產請求額',
            onPrimary: () {
              final aNet = ((double.tryParse(_husbandPropertyController.text.trim()) ?? 0) -
                      (double.tryParse(_husbandDebtController.text.trim()) ?? 0))
                  .clamp(0.0, double.infinity);
              final bNet = ((double.tryParse(_wifePropertyController.text.trim()) ?? 0) -
                      (double.tryParse(_wifeDebtController.text.trim()) ?? 0))
                  .clamp(0.0, double.infinity);
              final diff = (aNet - bNet).abs();
              final claim = diff / 2.0;
              final who = aNet > bNet
                  ? '乙方得向甲方請求差額之半數'
                  : (bNet > aNet ? '甲方得向乙方請求差額之半數' : '雙方婚後淨資產相等，無差額請求');

              setState(() {
                _marriagePropertyResult = '【民法第 1030-1 條剩餘財產差額試算】\n'
                    '• 甲方婚後淨財產：NT\$ ${aNet.toStringAsFixed(0)} 元\n'
                    '• 乙方婚後淨財產：NT\$ ${bNet.toStringAsFixed(0)} 元\n'
                    '• 雙方剩餘財產差額：NT\$ ${diff.toStringAsFixed(0)} 元\n'
                    '────────────────────────────────\n'
                    '請求權方向：$who\n'
                    '法定分配請求金額：NT\$ ${claim.toStringAsFixed(0)} 元';
              });
            },
            showClear: _marriagePropertyResult.isNotEmpty,
            onClear: () => setState(() {
              _husbandPropertyController.clear();
              _husbandDebtController.clear();
              _wifePropertyController.clear();
              _wifeDebtController.clear();
              _marriagePropertyResult = '';
            }),
          ),
          if (_marriagePropertyResult.isNotEmpty) ...[
            SizedBox(height: 16.h),
            _buildFormalDraftPreview(
              t: t,
              docTitle: '夫妻剩餘財產差額分配試算表',
              content: _marriagePropertyResult,
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 8~10. 雙重編碼進度條蒐證清單卡
  // ---------------------------------------------------------------------------
  Widget _buildSopChecklistCard({
    required PreambleTokens t,
    required String title,
    required String lawCitation,
    required String subtitle,
    required List<String> items,
    required Set<String> checkedSet,
    required String saveListTitle,
  }) {
    final progress = items.isEmpty ? 0.0 : checkedSet.length / items.length;

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: t.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWorkspaceHeader(
            t: t,
            icon: PhosphorIconsRegular.listChecks,
            title: title,
            lawTag: lawCitation,
            description: subtitle,
          ),
          SizedBox(height: 14.h),
          // 雙重編碼：進度條 + 等寬百分比
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: t.subtleBoxDecoration(),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('關鍵蒐證完成度', style: t.sansTitle(size: 12.sp)),
                    Text(
                      '${checkedSet.length} / ${items.length} 項 (${(progress * 100).round()}%)',
                      style: t.tabularMetric(size: 12.sp, color: t.brandPrimary),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999.r),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 7.h,
                    backgroundColor: t.border,
                    valueColor: AlwaysStoppedAnimation<Color>(t.brandPrimary),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          ...List.generate(items.length, (idx) {
            final sop = items[idx];
            final checked = checkedSet.contains(sop);
            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    if (checked) {
                      checkedSet.remove(sop);
                    } else {
                      checkedSet.add(sop);
                    }
                  });
                },
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
                  decoration: BoxDecoration(
                    color: checked ? t.brandContainer : t.surface,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: checked ? t.brandPrimary.withValues(alpha: 0.45) : t.border,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        checked
                            ? PhosphorIconsFill.checkCircle
                            : PhosphorIconsRegular.circle,
                        size: 19.sp,
                        color: checked ? t.brandPrimary : t.textMuted,
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          '0${idx + 1}. $sop',
                          style: t.sansBody(
                            size: 12.5.sp,
                            color: checked ? t.brandOnContainer : t.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          SizedBox(height: 8.h),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                LearningGameState.instance.saveEvidenceList(
                  saveListTitle,
                  checkedSet.toList(),
                  items,
                );
                PreambleScope.of(context).saveCaseNoteDraft(
                  'toolkit_${_activeTool.key}',
                  '【$saveListTitle】已完成 ${checkedSet.length}/${items.length} 項：\n${checkedSet.join('\n')}',
                );
                CustomToast.show(context, '已儲存蒐證進度至個人筆記與備忘錄');
              },
              style: FilledButton.styleFrom(
                backgroundColor: t.brandPrimaryStrong,
                foregroundColor: const Color(0xFFFAF8F4),
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              icon: Icon(PhosphorIconsRegular.floppyDisk, size: 17.sp),
              label: Text(
                '儲存蒐證清單至個人筆記',
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 共用高質感組件
  // ---------------------------------------------------------------------------
  Widget _buildWorkspaceHeader({
    required PreambleTokens t,
    required IconData icon,
    required String title,
    required String lawTag,
    required String description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                color: t.brandContainer,
                borderRadius: BorderRadius.circular(11.r),
              ),
              child: Icon(icon, color: t.brandPrimary, size: 20.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: t.serifTitle(size: 16.5.sp)),
                  SizedBox(height: 3.h),
                  Text(
                    lawTag,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: t.accentBrass,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Text(description, style: t.sansBody(size: 12.5.sp)),
      ],
    );
  }

  Widget _buildModeChip({
    required PreambleTokens t,
    required bool selected,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: selected ? t.brandContainer : t.surfaceSubtle,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: selected ? t.brandPrimary : t.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14.sp,
              color: selected ? t.brandPrimary : t.textSecondary,
            ),
            SizedBox(width: 5.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? t.brandOnContainer : t.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabeledField({
    required PreambleTokens t,
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: t.textPrimary,
            ),
          ),
          SizedBox(height: 5.h),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: t.sansBody(size: 13.5.sp, color: t.textPrimary),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: t.sansBody(size: 12.5.sp, color: t.textMuted),
              filled: true,
              fillColor: t.surfaceSubtle,
              contentPadding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 11.h),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: t.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: t.brandPrimary, width: 1.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryActionRow({
    required PreambleTokens t,
    required String primaryLabel,
    required VoidCallback onPrimary,
    required bool showClear,
    required VoidCallback onClear,
  }) {
    return Wrap(
      spacing: 10.w,
      runSpacing: 8.h,
      children: [
        FilledButton.icon(
          onPressed: () {
            HapticFeedback.lightImpact();
            onPrimary();
          },
          style: FilledButton.styleFrom(
            backgroundColor: t.brandPrimaryStrong,
            foregroundColor: const Color(0xFFFAF8F4),
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 11.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          icon: Icon(PhosphorIconsRegular.sparkle, size: 16.sp),
          label: Text(
            primaryLabel,
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700),
          ),
        ),
        if (showClear)
          OutlinedButton.icon(
            onPressed: onClear,
            style: OutlinedButton.styleFrom(
              foregroundColor: t.textSecondary,
              side: BorderSide(color: t.borderStrong),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            icon: Icon(PhosphorIconsRegular.eraser, size: 15.sp),
            label: Text('重設', style: TextStyle(fontSize: 12.5.sp)),
          ),
      ],
    );
  }

  Widget _buildFormalDraftPreview({
    required PreambleTokens t,
    required String docTitle,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15.w),
      decoration: t.subtleBoxDecoration(borderColor: t.borderStrong),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(content, style: t.serifBody(size: 13.sp, height: 1.65)),
          SizedBox(height: 14.h),
          LearningResultActionBar(
            copyAction: LearningResultActionButton(
              icon: PhosphorIconsRegular.copy,
              label: '複製全文',
              color: t.brandPrimaryStrong,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: content));
                CustomToast.show(context, '已複製內容至剪貼簿');
              },
            ),
            noteAction: LearningResultActionButton(
              icon: PhosphorIconsRegular.bookmarkSimple,
              label: '存入筆記',
              color: t.accentBrass,
              onPressed: () {
                LearningGameState.instance.addHighlight(content, docTitle);
                PreambleScope.of(context).saveCaseNoteDraft(
                  'doc_${DateTime.now().millisecondsSinceEpoch}',
                  '【$docTitle】\n$content',
                );
                CustomToast.show(context, '已歸檔至個人法務筆記');
              },
            ),
            exportAction: LearningResultActionButton(
              icon: PhosphorIconsRegular.filePdf,
              label: '預覽匯出 PDF',
              color: t.semanticInfo,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => LegalDocumentExportPage(
                      title: docTitle,
                      content: content,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(PreambleTokens t, Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 5.w),
        Text(text, style: t.tabularMetric(size: 11.5.sp, color: t.textSecondary)),
      ],
    );
  }

  Widget _buildKpiBox(PreambleTokens t, String label, String value) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: t.subtleBoxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: t.sansBody(size: 11.5.sp)),
          SizedBox(height: 4.h),
          Text(value, style: t.tabularMetric(size: 15.sp, color: t.brandPrimary)),
        ],
      ),
    );
  }

  Widget _buildLawyerEscalationFooter(PreambleTokens t) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: t.cardDecoration(elevated: false),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12.w,
        runSpacing: 10.h,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 220.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('爭議金額較大或需律師代撰簽證？', style: t.sansTitle(size: 13.5.sp)),
                SizedBox(height: 3.h),
                Text(
                  '可將試算結果與書狀草稿一鍵交接予合作認證律師審閱。',
                  style: t.sansBody(size: 11.5.sp),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: () {
              LawyerReferralSheet.show(
                context,
                caseBrief: CaseBrief(
                  disputeCategory: _activeTool.label,
                  factSummary: '已透過《緒言》法務實戰工具館完成初步試算／草擬，申請專業律師進階審閱。',
                  demands: const ['審閱書狀效力與訴訟勝算評估'],
                  evidences: const ['初步試算單、對話紀錄與相關合約'],
                  possibleLegalBasis: const ['中華民國民事／勞動相關法規'],
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: t.brandPrimary,
              side: BorderSide(color: t.brandPrimary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999.r),
              ),
            ),
            icon: Icon(PhosphorIconsRegular.briefcase, size: 15.sp),
            label: Text(
              '預約律師審閱',
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
