import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:preamble/app/app_state.dart';
import 'package:preamble/components/home/home_content.dart';
import 'package:preamble/components/shared/custom_toast.dart';
import 'package:preamble/data/mock_data/home/home_mock_data.dart';
import 'package:preamble/theme/preamble_tokens.dart';

/// 資訊流分類枚舉（親切白話分類）
enum HomeFeedFilter {
  all('全部', null),
  caseStory('生活案例', 'caseStory'),
  debate('大家怎麼看', 'debate'),
  statute('新規定', 'statute'),
  tips('避坑指南', 'tips');

  const HomeFeedFilter(this.label, this.key);
  final String label;
  final String? key;

  IconData? get icon {
    switch (this) {
      case HomeFeedFilter.all:
        return null;
      case HomeFeedFilter.caseStory:
        return PhosphorIconsRegular.scales;
      case HomeFeedFilter.debate:
        return PhosphorIconsRegular.arrowsLeftRight;
      case HomeFeedFilter.statute:
        return PhosphorIconsRegular.gitDiff;
      case HomeFeedFilter.tips:
        return PhosphorIconsRegular.shieldCheck;
    }
  }
}

class _CaseStorySpec {
  const _CaseStorySpec({
    required this.caseId,
    required this.courtBadge,
    required this.title,
    required this.disputeContext,
    required this.courtVerdict,
    required this.readMinutes,
  });

  final String caseId;
  final String courtBadge;
  final String title;
  final String disputeContext;
  final String courtVerdict;
  final int readMinutes;
}

class _DebateSpec {
  const _DebateSpec({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.sideALabel,
    required this.sideARationale,
    required this.sideAVotes,
    required this.sideBLabel,
    required this.sideBRationale,
    required this.sideBVotes,
    required this.discussionTopicIndex,
    required this.relatedCaseId,
  });

  final String id;
  final String title;
  final String subtitle;
  final String sideALabel;
  final String sideARationale;
  final int sideAVotes;
  final String sideBLabel;
  final String sideBRationale;
  final int sideBVotes;
  final int discussionTopicIndex;
  final String relatedCaseId;
}

class _StatuteDiffSpec {
  const _StatuteDiffSpec({
    required this.statuteId,
    required this.statuteQuery,
    required this.articleRef,
    required this.title,
    required this.oldRule,
    required this.newRule,
    required this.penaltyHighlight,
  });

  final String statuteId;
  final String statuteQuery;
  final String articleRef;
  final String title;
  final String oldRule;
  final String newRule;
  final String penaltyHighlight;
}

class _LifeTipSpec {
  const _LifeTipSpec({
    required this.articleId,
    required this.newsletterIndex,
    required this.statuteRef,
    required this.title,
    required this.steps,
  });

  final String articleId;
  final int newsletterIndex;
  final String statuteRef;
  final String title;
  final List<String> steps;
}

/// 《緒言 Preamble》1+2 融合首頁動態流 (HomeFeedStreamView)
///
/// 包含：
/// 1. 首屏「今日頭條・雙重編碼導讀大卡」
/// 2. 純淨幾何分類篩選列
/// 3. 12 則真實資料驅動的四類雙重編碼卡片（爭點定調對照膠囊、直接點擊雙向天秤投票、新舊條文差異區塊、01·02·03 戰術步驟軸）
class HomeFeedStreamView extends StatefulWidget {
  const HomeFeedStreamView({
    super.key,
    required this.onNavigateToCase,
    required this.onNavigateToOfficialNews,
    required this.onNavigateToTipDetail,
    required this.onNavigateToStatuteDatabase,
    required this.onNavigateToDiscussion,
    this.onNavigateToDiscussionTopic,
    this.onNavigateToStatuteQuery,
  });

  final ValueChanged<String> onNavigateToCase;
  final VoidCallback onNavigateToOfficialNews;
  final ValueChanged<HomeNewsletterItem> onNavigateToTipDetail;
  final VoidCallback onNavigateToStatuteDatabase;
  final VoidCallback onNavigateToDiscussion;
  final ValueChanged<int>? onNavigateToDiscussionTopic;
  final ValueChanged<String>? onNavigateToStatuteQuery;

  @override
  State<HomeFeedStreamView> createState() => _HomeFeedStreamViewState();
}

class _HomeFeedStreamViewState extends State<HomeFeedStreamView> {
  HomeFeedFilter _activeFilter = HomeFeedFilter.all;

  /// 各題思辨對決本地投票紀錄（key: debate.id -> 0 代表立場 A、1 代表立場 B）
  final Map<String, int> _debateVotes = <String, int>{};

  static const List<_CaseStorySpec> _caseStories = [
    _CaseStorySpec(
      caseId: 'case-chang-will-1764',
      courtBadge: '最高法院民事判決',
      title: '密封遺囑公證瑕疵爭議：長榮張榮發遺囑效力定讞解析',
      disputeContext: '遺囑人僅點頭或簡短示意，是否符合民法第 1192 條「陳述為自己遺囑」法定要件？',
      courtVerdict: '最高法院認定公證紀錄足以確認真意，形式要件無重大瑕疵，判決密封遺囑有效確定。',
      readMinutes: 4,
    ),
    _CaseStorySpec(
      caseId: 'case-support-exemption-1118',
      courtBadge: '家事法庭裁定實務',
      title: '失職父母年邁請求扶養費：民法第 1118 條之 1 免除標準',
      disputeContext: '父母於子女未成年時無正當理由未盡扶養義務，年老後能否強制要求子女按月給付生活費？',
      courtVerdict: '法院審酌情節重大者得「完全免除」而非僅減輕扶養義務，避免情感與經濟雙重剝削。',
      readMinutes: 3,
    ),
    _CaseStorySpec(
      caseId: 'case-tsmc-secret-1589',
      courtBadge: '智慧財產及商業法院',
      title: '高階研發主管跳槽競爭對手：競業禁止與營業秘密洩漏邊界',
      disputeContext: '離職後競業禁止期滿，前雇主能否仍依營業秘密法請求禁止任職於特定競業對手？',
      courtVerdict: '首創「不可避免揭露原則」實務判準，認定重大核心製程秘密具實質洩漏風險得予定暫時狀態處分。',
      readMinutes: 5,
    ),
  ];

  static const List<_DebateSpec> _debates = [
    _DebateSpec(
      id: 'debate-gig-labor',
      title: '數位平台外送員應定性為「勞動僱傭」或「獨立承攬」？',
      subtitle: '牽動職災保險雇主責任、演算法停權救濟與自由排班彈性的制度取捨。',
      sideALabel: '認定僱傭關係',
      sideARationale: '平台演算法實質控制單價與獎懲，具高度經濟與組織從屬性',
      sideAVotes: 1762,
      sideBLabel: '維持獨立承攬',
      sideBRationale: '保留跨平台自由上線與拒單彈性，不宜套用傳統固定工時框架',
      sideBVotes: 1080,
      discussionTopicIndex: 5,
      relatedCaseId: 'case-delivery-labor-2152',
    ),
    _DebateSpec(
      id: 'debate-street-photo',
      title: '公共場所街拍與新聞跟拍：創作採訪自由 vs 個人肖像隱私',
      subtitle: '身處公開街道是否代表默示放棄不被特寫拍攝與公開上傳社群的權利？',
      sideALabel: '公共領域合理拍攝',
      sideARationale: '非營利紀實與公共利益監督受表現自由保障，過度限縮將致寒蟬效應',
      sideAVotes: 940,
      sideBLabel: '肖像自主權優先',
      sideBRationale: '身處公開場所仍享合理隱私期待，未經同意特寫傳播應負侵權責任',
      sideBVotes: 1485,
      discussionTopicIndex: 6,
      relatedCaseId: '102',
    ),
    _DebateSpec(
      id: 'debate-ai-copyright',
      title: '生成式 AI 擷取公開圖文訓練模型，是否構成著作權合理使用？',
      subtitle: '技術創新公共利益與人類創作者授權報酬機制之間的全球法制攻防。',
      sideALabel: '屬轉化性合理使用',
      sideARationale: '機器學習係萃取統計規律而非重製原表達，過度管制將阻礙本土模型發展',
      sideAVotes: 812,
      sideBLabel: '須經事前授權付費',
      sideBRationale: '生成結果直接替代人類創作市場，未付費擷取違反著作權法第 65 條衡量基準',
      sideBVotes: 1624,
      discussionTopicIndex: 7,
      relatedCaseId: 'case-045',
    ),
  ];

  static const List<_StatuteDiffSpec> _statutes = [
    _StatuteDiffSpec(
      statuteId: 'labor-32-1',
      statuteQuery: '勞動基準法',
      articleRef: '勞動基準法・第 32 條之 1',
      title: '休息日出勤工時折算與加班補休結算期限強制規範',
      oldRule: '勞資實務常見雇主單方規定「加班一律換補休」，且逾期未休直接歸零作廢。',
      newRule: '補休須由勞工於加班「事實發生後」自主選擇；契約年度屆期未休畢者，強制依原加班費率折發工資。',
      penaltyHighlight: '違者最高處新臺幣 100 萬元罰鍰並公布事業單位名稱',
    ),
    _StatuteDiffSpec(
      statuteId: 'rental-elec-2024',
      statuteQuery: '租賃',
      articleRef: '住宅租賃定型化契約應記載事項',
      title: '租屋電費計收新制：全面禁止超收台電當期每度平均單價',
      oldRule: '房東得自行約定夏季每度 6 至 8 元固定費率，且無義務提供台電帳單明細供房客查核。',
      newRule: '計收上限不得超過台電當期每度平均電價；未經台電申裝公共電費分攤者不得額外加收，且房東須揭露電費資訊。',
      penaltyHighlight: '超收條款無效；限期不改正最高處新臺幣 30 萬元罰鍰',
    ),
    _StatuteDiffSpec(
      statuteId: 'anti-fraud-2024',
      statuteQuery: '詐欺',
      articleRef: '詐欺犯罪危害防制條例・第 43 條',
      title: '高額假投資與深偽詐欺加重刑責暨被害人訴訟參與新制',
      oldRule: '一般三人以上加重詐欺最重本刑 7 年，鉅額吸金集團量刑與犯罪所得不成比例。',
      newRule: '詐欺犯罪所得達 500 萬元處 3 至 10 年徒刑；達 1 億元者最重處 12 年徒刑並得併科 3 億元罰金。',
      penaltyHighlight: '假釋門檻提高至三分之二，三犯詐欺一律不得假釋',
    ),
  ];

  static const List<_LifeTipSpec> _tips = [
    _LifeTipSpec(
      articleId: 'tip-landlord-entry',
      newsletterIndex: 0,
      statuteRef: '刑法第 306 條・民法第 423 條',
      title: '租屋簽約與居住防身：房東擅自帶看與扣押金三步自保',
      steps: [
        '入住點交當日逐一拍攝牆面與家電現況，附於租約附件釐清自然折舊責任',
        '租期內房屋占有權歸房客，房東未經同意持備用鑰匙入內涉犯無故侵入住宅罪',
        '退租遭無理扣留押金時，先寄發定期催告存證信函保留返還請求權證據',
      ],
    ),
    _LifeTipSpec(
      articleId: 'tip-lock-change',
      newsletterIndex: 3,
      statuteRef: '民法租賃編・占有保護原則',
      title: '房客為安全自行換鎖違法嗎？退租點交零糾紛實務清單',
      steps: [
        '先檢視租約有無「禁止換鎖」特約；若無禁止，基於居住安全換鎖屬合法占有行使',
        '妥善保存拆下之原始鎖芯與螺絲零件，避免退租時衍生毀損賠償爭議',
        '退租點交前裝回原鎖，或經房東書面同意無償留置新鎖並交付全數鑰匙',
      ],
    ),
    _LifeTipSpec(
      articleId: 'tip-intrusion-evidence',
      newsletterIndex: 2,
      statuteRef: '刑事訴訟法證據保全實務',
      title: '遭遇突襲開門或鄰里騷擾：具備法庭證據力的蒐證三原則',
      steps: [
        '屋內自設監視器拍攝自有租賃空間不構成妨害秘密，務必開啟精確日期時間戳記',
        '當下保持冷靜避免肢體拉扯，明確口頭告知「請立即離開」並同步錄音存證',
        '第一時間將原始影音雙重備份至雲端，切勿剪輯變造以免遭質疑證據同一性',
      ],
    ),
  ];

  void _handleVote(_DebateSpec spec, int side) {
    if (_debateVotes[spec.id] == side) return;
    setState(() {
      _debateVotes[spec.id] = side;
    });
    final chosenLabel = side == 0 ? spec.sideALabel : spec.sideBLabel;
    CustomToast.show(context, '已記錄您的法理立場：「$chosenLabel」');
  }

  Future<void> _toggleCaseSaved(PreambleState appState, String caseId) async {
    final nextSaved = !appState.isCaseSaved(caseId);
    await appState.setCaseSaved(caseId, nextSaved);
    if (!mounted) return;
    CustomToast.show(context, nextSaved ? '已收入個人案卷收藏夾' : '已自收藏夾移除');
  }

  Future<void> _toggleStatuteFollowed(
    PreambleState appState,
    String statuteId,
  ) async {
    final nextFollowed = !appState.isStatuteFollowed(statuteId);
    await appState.setStatuteFollowed(statuteId, nextFollowed);
    if (!mounted) return;
    CustomToast.show(context, nextFollowed ? '已開啟此法規修法異動追蹤' : '已取消追蹤此法規');
  }

  Future<void> _toggleTipSaved(PreambleState appState, String articleId) async {
    final nextSaved = !appState.isArticleSaved(articleId);
    await appState.setArticleSaved(articleId, nextSaved);
    if (!mounted) return;
    CustomToast.show(context, nextSaved ? '已收藏避坑檢核指引' : '已取消收藏避坑指引');
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final appState = PreambleScope.of(context);

    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 首屏今日頭條・雙重編碼導讀大卡（完整露出於底部導覽島上方）
            _buildHeroBriefingCard(context, t, appState),
            SizedBox(height: 18.h),

            // 2. 分類標題與水平幾何篩選列
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8.w,
              runSpacing: 4.h,
              children: [
                Text(
                  '往下逛逛・生活知識',
                  style: t.serifTitle(size: 16.5.sp),
                ),
                Text(
                  '白話輕鬆讀 ✨',
                  style: t.sansBody(size: 11.5.sp, color: t.textMuted),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            _buildFilterBar(t),
            SizedBox(height: 14.h),

            // 3. 交錯排列之 12 則真實結構化資訊流
            ..._buildInterleavedFeed(context, t, appState),
          ],
        );
      },
    );
  }

  Widget _buildHeroBriefingCard(
    BuildContext context,
    PreambleTokens t,
    PreambleState appState,
  ) {
    const heroCaseId = 'case-delivery-labor-2152';
    final isSaved = appState.isCaseSaved(heroCaseId);
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => widget.onNavigateToCase(heroCaseId),
        borderRadius: BorderRadius.circular(24.r),
        child: Ink(
          decoration: BoxDecoration(
            color: t.brandContainer,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: t.shadowAmbient,
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 8.w,
                      runSpacing: 4.h,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 9.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: t.surface,
                            borderRadius: BorderRadius.circular(99.r),
                          ),
                          child: Text(
                            '今日生活話題 💡',
                            style: t.sansTitle(
                              size: 11.sp,
                              color: t.brandOnContainer,
                            ),
                          ),
                        ),
                        Text(
                          '外送與打工權益',
                          style: t.sansBody(
                            size: 11.sp,
                            color: t.brandOnContainer.withValues(alpha: 0.78),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: isSaved ? '取消收藏' : '收藏起來',
                    onPressed: () => _toggleCaseSaved(appState, heroCaseId),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(
                      minWidth: 32.w,
                      minHeight: 32.w,
                    ),
                    icon: Icon(
                      isSaved
                          ? PhosphorIconsFill.bookmarkSimple
                          : PhosphorIconsRegular.bookmarkSimple,
                      size: 19.sp,
                      color: isSaved ? t.accentBrass : t.brandOnContainer,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                '跑外送算員工還是自己接案？法院這樣看平台跟外送員的關係',
                style: t.serifTitle(
                  size: 16.5.sp,
                  color: t.textPrimary,
                  height: 1.38,
                ),
              ),
              SizedBox(height: 10.h),
              // 柔白雙欄比較框
              LayoutBuilder(
                builder: (context, constraints) {
                  final stackVertically =
                      constraints.maxWidth < 290 || textScale > 1.35;
                  return Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: t.surface,
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                    child: stackVertically
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _HeroContrastCell(
                                label: '平台怎麼說',
                                content: '自由上下線、沒底薪，簽的是接案合約',
                                accentColor: t.textSecondary,
                                textColor: t.textPrimary,
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 6.h),
                                child: Icon(
                                  PhosphorIconsBold.arrowDown,
                                  size: 13.sp,
                                  color: t.brandPrimary,
                                ),
                              ),
                              _HeroContrastCell(
                                label: '法院怎麼看',
                                content: '派單與報酬都受演算法規定，其實就像員工一樣',
                                accentColor: t.brandPrimary,
                                textColor: t.textPrimary,
                              ),
                            ],
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _HeroContrastCell(
                                  label: '平台怎麼說',
                                  content: '自由上下線、沒底薪，簽的是接案合約',
                                  accentColor: t.textSecondary,
                                  textColor: t.textPrimary,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 10.h,
                                ),
                                child: Icon(
                                  PhosphorIconsBold.arrowRight,
                                  size: 14.sp,
                                  color: t.brandPrimary,
                                ),
                              ),
                              Expanded(
                                child: _HeroContrastCell(
                                  label: '法院怎麼看',
                                  content: '派單與報酬都受演算法規定，其實就像員工一樣',
                                  accentColor: t.brandPrimary,
                                  textColor: t.textPrimary,
                                ),
                              ),
                            ],
                          ),
                  );
                },
              ),
              SizedBox(height: 11.h),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8.w,
                runSpacing: 6.h,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        PhosphorIconsRegular.clock,
                        size: 13.sp,
                        color: t.brandOnContainer.withValues(alpha: 0.78),
                      ),
                      SizedBox(width: 4.w),
                      Flexible(
                        child: Text(
                          '4 分鐘輕鬆看懂',
                          style: t.tabularMetric(
                            size: 11.sp,
                            weight: FontWeight.w600,
                            color: t.brandOnContainer.withValues(alpha: 0.78),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          '看看完整故事',
                          style: t.sansTitle(
                            size: 12.sp,
                            color: t.brandPrimaryStrong,
                          ),
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        PhosphorIconsBold.arrowRight,
                        size: 13.sp,
                        color: t.brandPrimaryStrong,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar(PreambleTokens t) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: HomeFeedFilter.values.map((filter) {
          final isSelected = _activeFilter == filter;
          final bg = isSelected ? t.brandPrimaryStrong : t.surface;
          final fg = isSelected ? const Color(0xFFFAF8F4) : t.textSecondary;
          final border = isSelected ? t.brandPrimaryStrong : t.border;

          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _activeFilter = filter;
                  });
                },
                borderRadius: BorderRadius.circular(99.r),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: EdgeInsets.symmetric(
                    horizontal: 13.w,
                    vertical: 7.h,
                  ),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(99.r),
                    border: Border.all(color: border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (filter.icon != null) ...[
                        Icon(filter.icon, size: 13.5.sp, color: fg),
                        SizedBox(width: 5.w),
                      ],
                      Text(
                        filter.label,
                        style: t.sansTitle(
                          size: 12.sp,
                          weight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: fg,
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
    );
  }

  List<Widget> _buildInterleavedFeed(
    BuildContext context,
    PreambleTokens t,
    PreambleState appState,
  ) {
    final widgets = <Widget>[];
    final maxLen = 3; // 每類別 3 則，共 12 則交錯呈現

    for (var i = 0; i < maxLen; i++) {
      if (_activeFilter == HomeFeedFilter.all ||
          _activeFilter == HomeFeedFilter.caseStory) {
        widgets.add(_buildCaseStoryCard(context, t, appState, _caseStories[i]));
        widgets.add(SizedBox(height: 14.h));
      }
      if (_activeFilter == HomeFeedFilter.all ||
          _activeFilter == HomeFeedFilter.debate) {
        widgets.add(_buildDebateCard(context, t, _debates[i]));
        widgets.add(SizedBox(height: 14.h));
      }
      if (_activeFilter == HomeFeedFilter.all ||
          _activeFilter == HomeFeedFilter.statute) {
        widgets.add(_buildStatuteDiffCard(context, t, appState, _statutes[i]));
        widgets.add(SizedBox(height: 14.h));
      }
      if (_activeFilter == HomeFeedFilter.all ||
          _activeFilter == HomeFeedFilter.tips) {
        widgets.add(_buildLifeTipCard(context, t, appState, _tips[i]));
        widgets.add(SizedBox(height: 14.h));
      }
    }
    return widgets;
  }

  void _openDiscussionTopic(int topicIndex) {
    if (widget.onNavigateToDiscussionTopic != null) {
      widget.onNavigateToDiscussionTopic!(topicIndex);
    } else {
      widget.onNavigateToDiscussion();
    }
  }

  Widget _buildCardShell({
    required PreambleTokens t,
    required IconData categoryIcon,
    required String categoryLabel,
    required Color categoryColor,
    required Color categoryBg,
    required String metaBadge,
    required bool isBookmarked,
    required VoidCallback? onBookmarkTap,
    VoidCallback? onCardTap,
    required Widget child,
  }) {
    final content = Padding(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 15.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8.w,
                  runSpacing: 4.h,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 9.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: categoryBg,
                        borderRadius: BorderRadius.circular(99.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(categoryIcon, size: 12.5.sp, color: categoryColor),
                          SizedBox(width: 4.w),
                          Text(
                            categoryLabel,
                            style: t.sansTitle(
                              size: 11.sp,
                              weight: FontWeight.w700,
                              color: categoryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      metaBadge,
                      style: t.sansBody(size: 11.sp, color: t.textMuted),
                    ),
                  ],
                ),
              ),
              if (onBookmarkTap != null)
                IconButton(
                  onPressed: onBookmarkTap,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(
                    minWidth: 30.w,
                    minHeight: 30.w,
                  ),
                  tooltip: isBookmarked ? '移除收藏' : '加入收藏',
                  icon: Icon(
                    isBookmarked
                        ? PhosphorIconsFill.bookmarkSimple
                        : PhosphorIconsRegular.bookmarkSimple,
                    size: 18.sp,
                    color: isBookmarked ? t.accentBrass : t.textMuted,
                  ),
                ),
            ],
          ),
          SizedBox(height: 10.h),
          child,
        ],
      ),
    );

    return Container(
      decoration: t.cardDecoration(radius: 20.r),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Material(
          type: MaterialType.transparency,
          child: onCardTap == null
              ? content
              : InkWell(
                  onTap: onCardTap,
                  borderRadius: BorderRadius.circular(20.r),
                  child: content,
                ),
        ),
      ),
    );
  }

  /// A. 焦點判決卡片 — 雙重編碼微視覺：〔爭點情境 ➔ 法院定調〕雙欄膠囊
  Widget _buildCaseStoryCard(
    BuildContext context,
    PreambleTokens t,
    PreambleState appState,
    _CaseStorySpec spec,
  ) {
    final saved = appState.isCaseSaved(spec.caseId);
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);

    return _buildCardShell(
      t: t,
      categoryIcon: PhosphorIconsRegular.scales,
      categoryLabel: '生活案例',
      categoryColor: t.brandPrimary,
      categoryBg: t.brandContainer,
      metaBadge: spec.courtBadge,
      isBookmarked: saved,
      onBookmarkTap: () => _toggleCaseSaved(appState, spec.caseId),
      onCardTap: () => widget.onNavigateToCase(spec.caseId),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => widget.onNavigateToCase(spec.caseId),
            borderRadius: BorderRadius.circular(8.r),
            child: Text(
              spec.title,
              style: t.serifTitle(size: 16.sp, height: 1.38),
            ),
          ),
          SizedBox(height: 10.h),
          LayoutBuilder(
            builder: (context, constraints) {
              final vertical =
                  constraints.maxWidth < 290 || textScale > 1.35;
              return Container(
                padding: EdgeInsets.all(12.w),
                decoration: t.subtleBoxDecoration(radius: 16.r),
                child: vertical
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _DualContrastColumn(
                            badge: '發生什麼事',
                            badgeColor: t.textSecondary,
                            text: spec.disputeContext,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 6.h),
                            child: Icon(
                              PhosphorIconsBold.arrowDown,
                              size: 13.sp,
                              color: t.brandPrimary,
                            ),
                          ),
                          _DualContrastColumn(
                            badge: '最後怎麼判',
                            badgeColor: t.brandPrimary,
                            text: spec.courtVerdict,
                            emphasize: true,
                          ),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _DualContrastColumn(
                              badge: '發生什麼事',
                              badgeColor: t.textSecondary,
                              text: spec.disputeContext,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 12.h,
                            ),
                            child: Icon(
                              PhosphorIconsBold.arrowRight,
                              size: 14.sp,
                              color: t.brandPrimary,
                            ),
                          ),
                          Expanded(
                            child: _DualContrastColumn(
                              badge: '最後怎麼判',
                              badgeColor: t.brandPrimary,
                              text: spec.courtVerdict,
                              emphasize: true,
                            ),
                          ),
                        ],
                      ),
              );
            },
          ),
          SizedBox(height: 12.h),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8.w,
            runSpacing: 6.h,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    PhosphorIconsRegular.clock,
                    size: 13.sp,
                    color: t.textMuted,
                  ),
                  SizedBox(width: 4.w),
                  Flexible(
                    child: Text(
                      '${spec.readMinutes} 分鐘白話導讀',
                      style: t.tabularMetric(
                        size: 11.5.sp,
                        weight: FontWeight.w600,
                        color: t.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => widget.onNavigateToCase(spec.caseId),
                borderRadius: BorderRadius.circular(8.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          '閱讀判決解析',
                          style: t.sansTitle(
                            size: 12.sp,
                            color: t.brandPrimary,
                          ),
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        PhosphorIconsBold.arrowRight,
                        size: 13.sp,
                        color: t.brandPrimary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// B. 思辨對決卡片 — 雙重編碼微視覺：一體式直接點擊雙向天秤卡（淘汰重複雙按鈕列）
  Widget _buildDebateCard(
    BuildContext context,
    PreambleTokens t,
    _DebateSpec spec,
  ) {
    final votedSide = _debateVotes[spec.id];
    final countA = spec.sideAVotes + (votedSide == 0 ? 1 : 0);
    final countB = spec.sideBVotes + (votedSide == 1 ? 1 : 0);
    final total = countA + countB;
    final pctA = total > 0 ? ((countA / total) * 100).round() : 50;
    final pctB = 100 - pctA;
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);

    return _buildCardShell(
      t: t,
      categoryIcon: PhosphorIconsRegular.arrowsLeftRight,
      categoryLabel: '大家怎麼看',
      categoryColor: t.accentOnBrassContainer,
      categoryBg: t.accentBrassContainer,
      metaBadge: '${total.toString()} 人參與投票',
      isBookmarked: false,
      onBookmarkTap: null,
      onCardTap: () => _openDiscussionTopic(spec.discussionTopicIndex),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            spec.title,
            style: t.serifTitle(size: 16.sp, height: 1.35),
          ),
          SizedBox(height: 5.h),
          Text(
            spec.subtitle,
            style: t.sansBody(size: 12.5.sp),
          ),
          SizedBox(height: 12.h),
          // 頂部即時比例雙色天秤光譜條
          ClipRRect(
            borderRadius: BorderRadius.circular(99.r),
            child: SizedBox(
              height: 6.h,
              child: Row(
                children: [
                  Expanded(
                    flex: pctA.clamp(8, 92),
                    child: Container(color: t.brandPrimary),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    flex: pctB.clamp(8, 92),
                    child: Container(color: t.accentBrass),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10.h),
          // 直接點擊立場卡（合併論點閱讀與投票操作於同一互動表面）
          LayoutBuilder(
            builder: (context, constraints) {
              final stackVertically =
                  constraints.maxWidth < 290 || textScale > 1.35;
              final cardA = _DirectStanceCard(
                stanceTag: '正方觀點',
                title: spec.sideALabel,
                rationale: spec.sideARationale,
                percentage: pctA,
                isSelected: votedSide == 0,
                hasVotedAny: votedSide != null,
                accentColor: t.brandPrimary,
                accentContainer: t.brandContainer,
                onTap: () => _handleVote(spec, 0),
              );
              final cardB = _DirectStanceCard(
                stanceTag: '反方觀點',
                title: spec.sideBLabel,
                rationale: spec.sideBRationale,
                percentage: pctB,
                isSelected: votedSide == 1,
                hasVotedAny: votedSide != null,
                accentColor: t.accentBrass,
                accentContainer: t.accentBrassContainer,
                onTap: () => _handleVote(spec, 1),
              );

              if (stackVertically) {
                return Column(
                  children: [
                    cardA,
                    SizedBox(height: 8.h),
                    cardB,
                  ],
                );
              }
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: cardA),
                    SizedBox(width: 8.w),
                    Expanded(child: cardB),
                  ],
                ),
              );
            },
          ),
          SizedBox(height: 11.h),
          Text(
            votedSide == null ? '點擊任一立場立即表態並檢視比例' : '已計入您的法理表態',
            style: t.sansBody(size: 11.sp, color: t.textMuted),
          ),
          SizedBox(height: 6.h),
          SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10.w,
              runSpacing: 6.h,
              children: [
                InkWell(
                  onTap: () => _openDiscussionTopic(spec.discussionTopicIndex),
                  borderRadius: BorderRadius.circular(8.r),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 3.h,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          PhosphorIconsRegular.chatsCircle,
                          size: 13.5.sp,
                          color: t.brandPrimary,
                        ),
                        SizedBox(width: 4.w),
                        Flexible(
                          child: Text(
                            '參與議題討論',
                            style: t.sansTitle(
                              size: 12.sp,
                              color: t.brandPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => widget.onNavigateToCase(spec.relatedCaseId),
                  borderRadius: BorderRadius.circular(8.r),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 3.h,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            '看關聯判決卷宗',
                            style: t.sansTitle(
                              size: 12.sp,
                              color: t.accentOnBrassContainer,
                            ),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          PhosphorIconsBold.arrowRight,
                          size: 13.sp,
                          color: t.accentOnBrassContainer,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// C. 修法監控卡片 — 雙重編碼微視覺：〔舊制實務 ➔ 新制強制規範〕Git Diff 對照艙
  Widget _buildStatuteDiffCard(
    BuildContext context,
    PreambleTokens t,
    PreambleState appState,
    _StatuteDiffSpec spec,
  ) {
    final followed = appState.isStatuteFollowed(spec.statuteId);

    return _buildCardShell(
      t: t,
      categoryIcon: PhosphorIconsRegular.gitDiff,
      categoryLabel: '新規定提醒',
      categoryColor: t.semanticInfo,
      categoryBg: t.semanticInfoContainer,
      metaBadge: spec.articleRef,
      isBookmarked: followed,
      onBookmarkTap: () => _toggleStatuteFollowed(appState, spec.statuteId),
      onCardTap: () {
        if (widget.onNavigateToStatuteQuery != null) {
          widget.onNavigateToStatuteQuery!(spec.statuteQuery);
        } else {
          widget.onNavigateToStatuteDatabase();
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            spec.title,
            style: t.serifTitle(size: 16.sp, height: 1.35),
          ),
          SizedBox(height: 10.h),
          Container(
            decoration: t.subtleBoxDecoration(radius: 16.r),
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      PhosphorIconsRegular.minusCircle,
                      size: 15.sp,
                      color: t.textMuted,
                    ),
                    SizedBox(width: 7.w),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: t.sansBody(size: 12.sp, color: t.textMuted),
                          children: [
                            TextSpan(
                              text: '以前常見｜',
                              style: t.sansTitle(
                                size: 11.5.sp,
                                color: t.textSecondary,
                              ),
                            ),
                            TextSpan(text: spec.oldRule),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Divider(height: 1, color: t.border),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      PhosphorIconsFill.plusCircle,
                      size: 15.sp,
                      color: t.semanticSuccess,
                    ),
                    SizedBox(width: 7.w),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: t.sansBody(
                            size: 12.2.sp,
                            weight: FontWeight.w600,
                            color: t.textPrimary,
                          ),
                          children: [
                            TextSpan(
                              text: '現在規定｜',
                              style: t.sansTitle(
                                size: 11.5.sp,
                                color: t.semanticSuccess,
                              ),
                            ),
                            TextSpan(text: spec.newRule),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 9.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: t.semanticUrgentContainer,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              children: [
                Icon(
                  PhosphorIconsRegular.warningCircle,
                  size: 14.sp,
                  color: t.semanticUrgent,
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    spec.penaltyHighlight,
                    style: t.tabularMetric(
                      size: 11.5.sp,
                      weight: FontWeight.w700,
                      color: t.semanticUrgent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 11.h),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () {
                if (widget.onNavigateToStatuteQuery != null) {
                  widget.onNavigateToStatuteQuery!(spec.statuteQuery);
                } else {
                  widget.onNavigateToStatuteDatabase();
                }
              },
              borderRadius: BorderRadius.circular(8.r),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        '查閱完整法規條文',
                        style: t.sansTitle(size: 12.sp, color: t.semanticInfo),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      PhosphorIconsBold.arrowRight,
                      size: 13.sp,
                      color: t.semanticInfo,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// D. 生活避坑卡片 — 雙重編碼微視覺：〔01 · 02 · 03〕垂直戰術步驟軸
  Widget _buildLifeTipCard(
    BuildContext context,
    PreambleTokens t,
    PreambleState appState,
    _LifeTipSpec spec,
  ) {
    final saved = appState.isArticleSaved(spec.articleId);
    final safeIdx = spec.newsletterIndex.clamp(0, homeNewsletterItems.length - 1);
    final linkedTip = homeNewsletterItems[safeIdx];

    return _buildCardShell(
      t: t,
      categoryIcon: PhosphorIconsRegular.shieldCheck,
      categoryLabel: '避坑指南',
      categoryColor: t.semanticSuccess,
      categoryBg: t.semanticSuccessContainer,
      metaBadge: spec.statuteRef,
      isBookmarked: saved,
      onBookmarkTap: () => _toggleTipSaved(appState, spec.articleId),
      onCardTap: () => widget.onNavigateToTipDetail(linkedTip),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            spec.title,
            style: t.sansTitle(size: 15.5.sp, height: 1.35),
          ),
          SizedBox(height: 11.h),
          Column(
            children: [
              for (var idx = 0; idx < spec.steps.length; idx++)
                _TacticalStepRow(
                  stepNumber: '0${idx + 1}',
                  text: spec.steps[idx],
                  isLast: idx == spec.steps.length - 1,
                ),
            ],
          ),
          SizedBox(height: 10.h),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8.w,
            runSpacing: 4.h,
            children: [
              Text(
                '實戰三步驟自保清單',
                style: t.sansBody(size: 11.sp, color: t.textMuted),
              ),
              InkWell(
                onTap: () => widget.onNavigateToTipDetail(linkedTip),
                borderRadius: BorderRadius.circular(8.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          '開啟避坑實務詳解',
                          style: t.sansTitle(
                            size: 12.sp,
                            color: t.semanticSuccess,
                          ),
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        PhosphorIconsBold.arrowRight,
                        size: 13.sp,
                        color: t.semanticSuccess,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroContrastCell extends StatelessWidget {
  const _HeroContrastCell({
    required this.label,
    required this.content,
    required this.accentColor,
    required this.textColor,
  });

  final String label;
  final String content;
  final Color accentColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: t.sansTitle(
            size: 11.sp,
            color: accentColor,
          ),
        ),
        SizedBox(height: 3.h),
        Text(
          content,
          style: t.sansBody(
            size: 12.sp,
            color: textColor,
            height: 1.42,
          ),
        ),
      ],
    );
  }
}

class _DualContrastColumn extends StatelessWidget {
  const _DualContrastColumn({
    required this.badge,
    required this.badgeColor,
    required this.text,
    this.emphasize = false,
  });

  final String badge;
  final Color badgeColor;
  final String text;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          badge,
          style: t.sansTitle(
            size: 11.sp,
            weight: FontWeight.w700,
            color: badgeColor,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          text,
          style: t.sansBody(
            size: 12.sp,
            weight: emphasize ? FontWeight.w600 : FontWeight.w500,
            color: emphasize ? t.textPrimary : t.textSecondary,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _DirectStanceCard extends StatelessWidget {
  const _DirectStanceCard({
    required this.stanceTag,
    required this.title,
    required this.rationale,
    required this.percentage,
    required this.isSelected,
    required this.hasVotedAny,
    required this.accentColor,
    required this.accentContainer,
    required this.onTap,
  });

  final String stanceTag;
  final String title;
  final String rationale;
  final int percentage;
  final bool isSelected;
  final bool hasVotedAny;
  final Color accentColor;
  final Color accentContainer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.all(11.w),
          decoration: BoxDecoration(
            color: isSelected ? accentContainer : t.surfaceSubtle,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: isSelected ? accentColor : t.border,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      stanceTag,
                      style: t.sansTitle(
                        size: 11.sp,
                        color: accentColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected) ...[
                        Icon(
                          PhosphorIconsFill.checkCircle,
                          size: 13.sp,
                          color: accentColor,
                        ),
                        SizedBox(width: 3.w),
                      ],
                      Text(
                        '$percentage%',
                        style: t.tabularMetric(
                          size: 12.sp,
                          color: hasVotedAny ? accentColor : t.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 5.h),
              Text(
                title,
                style: t.sansTitle(size: 13.sp),
              ),
              SizedBox(height: 4.h),
              Text(
                rationale,
                style: t.sansBody(size: 11.5.sp, height: 1.42),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TacticalStepRow extends StatelessWidget {
  const _TacticalStepRow({
    required this.stepNumber,
    required this.text,
    required this.isLast,
  });

  final String stepNumber;
  final String text;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.5.h),
                decoration: BoxDecoration(
                  color: t.accentBrassContainer,
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(
                    color: t.accentBrass.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  stepNumber,
                  style: t.tabularMetric(
                    size: 11.sp,
                    color: t.accentOnBrassContainer,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1.5,
                    margin: EdgeInsets.symmetric(vertical: 3.h),
                    color: t.borderStrong,
                  ),
                ),
            ],
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 9.h),
              child: Text(
                text,
                style: t.sansBody(
                  size: 12.5.sp,
                  color: t.textPrimary,
                  height: 1.44,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
