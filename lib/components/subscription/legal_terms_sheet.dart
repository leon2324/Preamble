import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:preamble/theme/preamble_tokens.dart';

/// 法律條款文件類型（服務條款 EULA ／ 隱私權政策）
enum LegalTermsKind {
  eula,
  privacy,
}

class _LegalClause {
  const _LegalClause({
    required this.number,
    required this.title,
    required this.body,
  });

  final String number;
  final String title;
  final String body;
}

/// 《緒言 Preamble》正式條款閱讀底頁（符合 App Store / Google Play 審查規範）。
///
/// 涵蓋：
/// - AI 非正式法律意見免責聲明
/// - 訂閱自動續訂、試用轉換與取消說明
/// - 本機優先與個人資料保護政策
class LegalTermsSheet extends StatelessWidget {
  const LegalTermsSheet({
    super.key,
    required this.kind,
  });

  final LegalTermsKind kind;

  static Future<void> show(
    BuildContext context, {
    required LegalTermsKind kind,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LegalTermsSheet(kind: kind),
    );
  }

  static const List<_LegalClause> _eulaClauses = [
    _LegalClause(
      number: '01',
      title: 'AI 非正式法律意見免責聲明',
      body: '《緒言 Preamble》所提供之案件整理、法規白話解析、AI 法律問診推演及書狀草稿生成功能，均僅供法學教育、資訊檢索與個人事前爭點整理參考，不構成正式律師法律意見或訴訟代理。使用本服務並不會在您與本團隊之間建立律師與委任人關係。涉及具體個案權利義務、法定期間計算或正式訴訟文書遞交前，請務必向合格執業律師或相關主管機關查核確認。',
    ),
    _LegalClause(
      number: '02',
      title: '訂閱方案、免費試用與自動續訂說明',
      body: '升級「緒言 PRO 專業會員」或「企業商務版」後，款項將於確認購買時由您的 Apple App Store 或 Google Play 帳戶扣款。若您選購含有免費試用期（例如年繳方案享 7 天免費試用）之方案，試用期屆滿前 24 小時內若未主動取消，系統將自動轉為正式付費訂閱並依所選週期（每月或每年）續訂扣款；購買正式訂閱後，任何未使用完畢之免費試用天數將自動失效。',
    ),
    _LegalClause(
      number: '03',
      title: '管理訂閱與取消自動續訂方式',
      body: '本服務採自動續訂制，除非您在當期計費週期結束前至少 24 小時關閉自動續訂，否則系統將於到期前 24 小時內自動扣繳下一期費用。您可隨時前往裝置之「系統設定 > Apple 帳號 > 訂閱項目」或「Google Play 商店 > 付款與訂閱」管理或取消自動續訂；取消後您仍可繼續使用 PRO 權益至當期計費週期屆滿為止。',
    ),
    _LegalClause(
      number: '04',
      title: '本機資料保存與合理使用規範',
      body: '您於本應用程式建立之收藏、追蹤、隨手筆記與書狀草稿預設儲存於您的個人裝置本機。您同意不得利用本服務從事詐欺、恐嚇、騷擾、偽造文書或其他違反中華民國法令之行為。法規與裁判資料以全國法規資料庫及司法院公開檢索系統之最新公布文本為準。',
    ),
  ];

  static const List<_LegalClause> _privacyClauses = [
    _LegalClause(
      number: '01',
      title: '本機優先（Local-First）個人資料保護架構',
      body: '《緒言 Preamble》採取最小化蒐集與本機優先儲存原則。您於應用程式內建立之案卷收藏、法規追蹤清單、法務筆記、閱讀字級偏好與書狀草稿，均優先保存在您個人裝置之本機儲存空間中，不會在未經您主動操作下公開或出售予任何第三方廣告商。',
    ),
    _LegalClause(
      number: '02',
      title: 'AI 法律問診與書狀生成資料處理原則',
      body: '當您主動使用「AI 法律問診」或「動態書狀草稿生成」功能時，您送出之問題描述僅用於當次語意解析與生成回應。為保障您的隱私安全，建議於提問或撰寫草稿時以代稱取代真實姓名、身分證統一編號、完整門牌地址、金融帳號或第三人敏感個人資料。',
    ),
    _LegalClause(
      number: '03',
      title: '訂閱交易驗證與第三方平台規範',
      body: '付費訂閱交易均透過 Apple App Store 或 Google Play 官方金流系統處理，本應用程式不會直接擷取或儲存您的信用卡卡號與帳單密碼，僅接收匿名化之訂閱有效狀態憑證以解鎖對應會員權益。當您點擊外部官方連結（如全國法規資料庫或司法院網站）時，資料處理將適用該外部網站之隱私權規範。',
    ),
    _LegalClause(
      number: '04',
      title: '資料自主管理、備份與清除權利',
      body: '您擁有隨時檢視、編輯或刪除本機收藏、追蹤動態、法務筆記與文件草稿之完整權利。於更換裝置、重置系統或移除應用程式前，請自行匯出或備份重要草稿內容；一旦移除應用程式或清除本機資料，儲存於本機之紀錄將無法由遠端復原。',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final isEula = kind == LegalTermsKind.eula;
    final clauses = isEula ? _eulaClauses : _privacyClauses;
    final title = isEula ? '服務條款與使用者授權合約 (EULA)' : '隱私權與個人資料保護政策';
    final subtitle = isEula
        ? '涵蓋 AI 非正式法律意見免責聲明、訂閱自動續訂與取消規範'
        : '涵蓋本機優先儲存原則、AI 問診隱私保護與個資自主管理';

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 0.88.sh),
      child: Container(
        decoration: BoxDecoration(
          color: t.surfaceElevated,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          border: Border.all(color: t.border),
          boxShadow: [
            BoxShadow(
              color: t.shadowAmbient,
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 12.w, 8.h),
                child: Column(
                  children: [
                    Container(
                      width: 38.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: t.borderStrong,
                        borderRadius: BorderRadius.circular(99.r),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(9.w),
                          decoration: BoxDecoration(
                            color: t.brandContainer,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            isEula
                                ? PhosphorIconsRegular.scales
                                : PhosphorIconsRegular.shieldCheck,
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
                                title,
                                style: t.serifTitle(size: 16.5.sp),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                subtitle,
                                style: t.sansBody(
                                  size: 12.sp,
                                  color: t.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          tooltip: '關閉',
                          icon: Icon(
                            PhosphorIconsRegular.x,
                            size: 20.sp,
                            color: t.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: t.border),
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        decoration: t.subtleBoxDecoration(radius: 12.r),
                        child: Row(
                          children: [
                            Icon(
                              PhosphorIconsRegular.clockCounterClockwise,
                              size: 15.sp,
                              color: t.accentBrass,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                '最後修訂日期：2026 年 5 月 ｜ 適用中華民國（臺灣）法令規範',
                                style: t.sansBody(
                                  size: 11.5.sp,
                                  color: t.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 14.h),
                      for (final clause in clauses) ...[
                        Container(
                          margin: EdgeInsets.only(bottom: 12.h),
                          padding: EdgeInsets.all(16.w),
                          decoration: t.cardDecoration(
                            radius: 20.r,
                            elevated: false,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 3.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: t.accentBrassContainer,
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    child: Text(
                                      clause.number,
                                      style: t.tabularMetric(
                                        size: 11.sp,
                                        color: t.accentOnBrassContainer,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      clause.title,
                                      style: t.serifTitle(size: 14.5.sp),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.h),
                              Text(
                                clause.body,
                                style: t.sansBody(
                                  size: 13.sp,
                                  color: t.textPrimary,
                                  height: 1.62,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 14.h),
                decoration: BoxDecoration(
                  color: t.surfaceElevated,
                  border: Border(top: BorderSide(color: t.border)),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: FilledButton.styleFrom(
                      backgroundColor: t.brandPrimaryStrong,
                      foregroundColor: const Color(0xFFFAF8F4),
                      padding: EdgeInsets.symmetric(vertical: 13.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    child: Text(
                      '我已詳閱並了解',
                      style: t.sansTitle(
                        size: 14.sp,
                        color: const Color(0xFFFAF8F4),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
