import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:preamble/components/shared/shimmer_skeleton.dart';
import 'package:preamble/config/supabase_config.dart';
import 'package:preamble/features/case_library/data/case_library_repository.dart';
import 'package:preamble/features/case_library/pages/case_dossier_detail_page.dart';
import 'package:preamble/pages/learning/know_law_page.dart';
import 'package:preamble/pages/learning/statute_database_page.dart';
import 'package:preamble/pages/tools/legal_toolkit_hub_page.dart';
import 'package:preamble/theme/preamble_tokens.dart';

/// 四大生活情境深度閱讀與權利脈絡頁（85% 知識脈絡閱讀＋右下角懸浮工具入口）。
///
/// 台灣繁體中文教學註解：依產品定位設計為「先看懂權利關係與社會結構處境，
/// 需要時再透過右下角懸浮按鈕呼叫小法助或實戰工具」，避免一進頁面就變成純工具箱。
class LifeSituationGuidePage extends StatefulWidget {
  const LifeSituationGuidePage({
    super.key,
    required this.domainId,
  });

  final String domainId;

  @override
  State<LifeSituationGuidePage> createState() => _LifeSituationGuidePageState();
}

class _LifeSituationGuidePageState extends State<LifeSituationGuidePage> {
  late _SituationDomainSpec _domain;
  int _selectedSubIndex = 0;
  bool _isLoadingRemote = false;

  @override
  void initState() {
    super.initState();
    _domain = _situationDomains.firstWhere(
      (d) => d.id == widget.domainId,
      orElse: () => _situationDomains.first,
    );
    _loadFromSupabase();
  }

  /// 台灣繁體中文教學註解：優先從 Supabase `life_situation_guides` 資料表讀取內容，
  /// 載入期間顯示骨架波紋；若離線或測試環境無法連線，則保留本機內建脈絡不中斷閱讀。
  Future<void> _loadFromSupabase() async {
    if (supabaseUrl.trim().isEmpty || supabaseAnonKey.trim().isEmpty) return;
    setState(() => _isLoadingRemote = true);
    final client = http.Client();
    try {
      final uri = Uri.parse(
        '$supabaseUrl/rest/v1/life_situation_guides?id=eq.${Uri.encodeComponent(widget.domainId)}&select=*',
      );
      final response = await client.get(
        uri,
        headers: {
          'apikey': supabaseAnonKey,
          'Authorization': 'Bearer $supabaseAnonKey',
        },
      ).timeout(const Duration(seconds: 6));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        if (decoded is List && decoded.isNotEmpty) {
          final row = decoded.first;
          if (row is Map<String, dynamic>) {
            final parsed = _SituationDomainSpec.fromJson(row);
            if (parsed != null && mounted) {
              setState(() {
                _domain = parsed;
                _selectedSubIndex = 0;
              });
            }
          }
        }
      }
    } catch (_) {
      // 離線或逾時靜默保留本機內建指引
    } finally {
      client.close();
      if (mounted) setState(() => _isLoadingRemote = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final sub = _domain.subSituations[_selectedSubIndex];

    return Scaffold(
      backgroundColor: t.canvas,
      appBar: AppBar(
        backgroundColor: t.canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(CupertinoIcons.back, color: t.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _domain.title,
          style: t.serifTitle(size: 17.sp),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openToolActionSheet(context, t, sub),
        backgroundColor: t.brandPrimary,
        foregroundColor: t.brandOnPrimary,
        elevation: 3,
        icon: Icon(PhosphorIconsRegular.toolbox, size: 18.sp),
        label: Text(
          '情境工具',
          style: t.sansTitle(size: 13.sp, color: t.brandOnPrimary),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 100.h),
        children: [

          // 情境導言橫幅
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: _accentContainer(t),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: t.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(_domain.emoji, style: TextStyle(fontSize: 22.sp)),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        _domain.headline,
                        style: t.serifTitle(size: 17.sp, height: 1.3),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  _domain.intro,
                  style: t.sansBody(
                    size: 13.sp,
                    color: t.textSecondary,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),

          // 頂部子情境切換膠囊
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                for (var i = 0; i < _domain.subSituations.length; i++) ...[
                  if (i > 0) SizedBox(width: 8.w),
                  ChoiceChip(
                    label: Text(_domain.subSituations[i].label),
                    selected: _selectedSubIndex == i,
                    onSelected: (_) => setState(() => _selectedSubIndex = i),
                    selectedColor: t.brandPrimary,
                    backgroundColor: t.surface,
                    labelStyle: t.sansBody(
                      size: 12.5.sp,
                      weight: FontWeight.w700,
                      color: _selectedSubIndex == i
                          ? t.brandOnPrimary
                          : t.textPrimary,
                    ),
                    side: BorderSide(
                      color:
                          _selectedSubIndex == i ? t.brandPrimary : t.border,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(99.r),
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 18.h),

          // 1. 處境與權利關係解析（載入遠端時顯示骨架波紋）
          _SectionHeading(
            icon: PhosphorIconsRegular.bookOpenText,
            title: '處境與權利關係解析',
          ),
          SizedBox(height: 8.h),
          if (_isLoadingRemote) ...[
            ShimmerSkeleton(
              width: double.infinity,
              height: 150.h,
              borderRadius: 18.r,
            ),
            SizedBox(height: 14.h),
            ShimmerSkeleton(
              width: double.infinity,
              height: 95.h,
              borderRadius: 16.r,
            ),
            SizedBox(height: 18.h),
          ] else ...[
            Container(
            padding: EdgeInsets.all(16.w),
            decoration: t.cardDecoration(radius: 18.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sub.contextTitle,
                  style: t.serifTitle(size: 16.sp, height: 1.35),
                ),
                SizedBox(height: 10.h),
                Text(
                  sub.contextBody,
                  style: t.sansBody(
                    size: 13.5.sp,
                    color: t.textPrimary,
                    height: 1.68,
                  ),
                ),
                SizedBox(height: 12.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: t.surfaceSubtle,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        PhosphorIconsFill.lightbulb,
                        size: 16.sp,
                        color: t.accentBrass,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          sub.sociologyNote,
                          style: t.sansBody(
                            size: 12.sp,
                            color: t.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 18.h),
          ],

          // 2. 常見話術 vs 法理拆解
          _SectionHeading(
            icon: PhosphorIconsRegular.chatTeardropDots,
            title: '常見話術與迷思拆解',
          ),
          SizedBox(height: 8.h),
          for (final myth in sub.myths) ...[
            Container(
              margin: EdgeInsets.only(bottom: 10.h),
              padding: EdgeInsets.all(14.w),
              decoration: t.cardDecoration(radius: 16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '「${myth.claim}」',
                    style: t.sansTitle(
                      size: 13.5.sp,
                      color: t.semanticUrgent,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    myth.reality,
                    style: t.sansBody(
                      size: 13.sp,
                      color: t.textSecondary,
                      height: 1.55,
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: 8.h),

          // 3. 核心法條依據（點擊可進全國法規資料庫查詢）
          _SectionHeading(
            icon: PhosphorIconsRegular.scales,
            title: '核心法條依據',
          ),
          SizedBox(height: 8.h),
          for (final statute in sub.statutes) ...[
            Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14.r),
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute<void>(
                        builder: (_) => StatuteDatabasePage(
                          initialQuery: statute.query,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: t.cardDecoration(radius: 14.r),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                statute.name,
                                style: t.sansTitle(
                                  size: 13.5.sp,
                                  color: t.brandPrimary,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                statute.summary,
                                style: t.sansBody(
                                  size: 12.5.sp,
                                  color: t.textSecondary,
                                  height: 1.48,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Icon(
                          CupertinoIcons.chevron_right,
                          size: 15.sp,
                          color: t.textMuted,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
          SizedBox(height: 10.h),

          // 4. 關聯真實判例（點擊進入案件圖書館詳情）
          _SectionHeading(
            icon: PhosphorIconsRegular.books,
            title: '相關真實判例參考',
          ),
          SizedBox(height: 8.h),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16.r),
              onTap: () {
                final book =
                    CaseLibraryRepository.instance.getCaseById(sub.caseId);
                Navigator.of(context).push(
                  CupertinoPageRoute<void>(
                    builder: (_) => CaseDossierDetailPage(book: book),
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.all(14.w),
                decoration: t.cardDecoration(
                  radius: 16.r,
                  fill: t.surface,
                  borderColor: t.borderStrong,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38.w,
                      height: 38.w,
                      decoration: BoxDecoration(
                        color: t.brandContainer,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        PhosphorIconsRegular.gavel,
                        size: 19.sp,
                        color: t.brandPrimary,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sub.caseTitle,
                            style: t.sansTitle(size: 13.5.sp),
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            sub.caseSummary,
                            style: t.sansBody(
                              size: 12.sp,
                              color: t.textSecondary,
                              height: 1.42,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Icon(
                      CupertinoIcons.chevron_right,
                      size: 15.sp,
                      color: t.textMuted,
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

  Color _accentContainer(PreambleTokens t) {
    return switch (_domain.id) {
      'rental' => t.brandContainer,
      'labor' => t.accentBrassContainer,
      'shopping' => t.semanticInfoContainer,
      _ => t.semanticUrgentContainer,
    };
  }

  void _openToolActionSheet(
    BuildContext context,
    PreambleTokens t,
    _SubSituationSpec sub,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return Container(
          decoration: BoxDecoration(
            color: t.surfaceElevated,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
            border: Border.all(color: t.border),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 18.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 38.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: t.borderStrong,
                        borderRadius: BorderRadius.circular(99.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Text(
                    '延伸協助：${sub.label}',
                    style: t.serifTitle(size: 16.sp),
                  ),
                  SizedBox(height: 12.h),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: t.brandContainer,
                      child: Icon(
                        PhosphorIconsRegular.chatCircleText,
                        color: t.brandPrimary,
                        size: 19.sp,
                      ),
                    ),
                    title: Text('向 AI 小法助詢問此情境', style: t.sansTitle(size: 14.sp)),
                    subtitle: Text(
                      '帶入目前子情境，針對你的具體細節做分析',
                      style: t.sansBody(size: 12.sp, color: t.textSecondary),
                    ),
                    onTap: () {
                      Navigator.of(sheetCtx).pop();
                      Navigator.of(context).push(
                        CupertinoPageRoute<void>(
                          builder: (_) =>
                              LawAssistantChatPage(initialPrompt: sub.prompt),
                        ),
                      );
                    },
                  ),
                  Divider(color: t.border),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: t.accentBrassContainer,
                      child: Icon(
                        PhosphorIconsRegular.fileText,
                        color: t.accentOnBrassContainer,
                        size: 19.sp,
                      ),
                    ),
                    title: Text(
                      '開啟「${sub.toolTitle}」',
                      style: t.sansTitle(size: 14.sp),
                    ),
                    subtitle: Text(
                      '前往實戰工具館整理存證信函或試算金額',
                      style: t.sansBody(size: 12.sp, color: t.textSecondary),
                    ),
                    onTap: () {
                      Navigator.of(sheetCtx).pop();
                      Navigator.of(context).push(
                        CupertinoPageRoute<void>(
                          builder: (_) => LegalToolkitHubPage(
                            initialToolKey: sub.toolKey,
                          ),
                        ),
                      );
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
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Row(
      children: [
        Icon(icon, size: 17.sp, color: t.brandPrimary),
        SizedBox(width: 6.w),
        Text(title, style: t.sansTitle(size: 14.5.sp)),
      ],
    );
  }
}

class _SituationDomainSpec {
  const _SituationDomainSpec({
    required this.id,
    required this.emoji,
    required this.title,
    required this.headline,
    required this.intro,
    required this.subSituations,
  });

  final String id;
  final String emoji;
  final String title;
  final String headline;
  final String intro;
  final List<_SubSituationSpec> subSituations;

  static _SituationDomainSpec? fromJson(Map<String, dynamic> json) {
    final rawSubs = json['sub_situations'];
    if (rawSubs is! List || rawSubs.isEmpty) return null;
    final subs = <_SubSituationSpec>[];
    for (final item in rawSubs.whereType<Map<String, dynamic>>()) {
      final myths = <({String claim, String reality})>[];
      if (item['myths'] is List) {
        for (final m in (item['myths'] as List).whereType<Map<String, dynamic>>()) {
          myths.add((
            claim: (m['claim'] as String? ?? '').trim(),
            reality: (m['reality'] as String? ?? '').trim(),
          ));
        }
      }
      final statutes = <({String name, String query, String summary})>[];
      if (item['statutes'] is List) {
        for (final s in (item['statutes'] as List).whereType<Map<String, dynamic>>()) {
          statutes.add((
            name: (s['name'] as String? ?? '').trim(),
            query: (s['query'] as String? ?? '').trim(),
            summary: (s['summary'] as String? ?? '').trim(),
          ));
        }
      }
      subs.add(_SubSituationSpec(
        label: (item['label'] as String? ?? '').trim(),
        contextTitle: (item['contextTitle'] as String? ?? '').trim(),
        contextBody: (item['contextBody'] as String? ?? '').trim(),
        sociologyNote: (item['sociologyNote'] as String? ?? '').trim(),
        myths: myths,
        statutes: statutes,
        caseId: (item['caseId'] as String? ?? 'case-045').trim(),
        caseTitle: (item['caseTitle'] as String? ?? '').trim(),
        caseSummary: (item['caseSummary'] as String? ?? '').trim(),
        prompt: (item['prompt'] as String? ?? '').trim(),
        toolKey: (item['toolKey'] as String? ?? '').trim(),
        toolTitle: (item['toolTitle'] as String? ?? '').trim(),
      ));
    }
    if (subs.isEmpty) return null;
    return _SituationDomainSpec(
      id: (json['id'] as String? ?? '').trim(),
      emoji: (json['emoji'] as String? ?? '⚖️').trim(),
      title: (json['title'] as String? ?? '').trim(),
      headline: (json['headline'] as String? ?? '').trim(),
      intro: (json['intro'] as String? ?? '').trim(),
      subSituations: subs,
    );
  }
}

class _SubSituationSpec {
  const _SubSituationSpec({
    required this.label,
    required this.contextTitle,
    required this.contextBody,
    required this.sociologyNote,
    required this.myths,
    required this.statutes,
    required this.caseId,
    required this.caseTitle,
    required this.caseSummary,
    required this.prompt,
    required this.toolKey,
    required this.toolTitle,
  });

  final String label;
  final String contextTitle;
  final String contextBody;
  final String sociologyNote;
  final List<({String claim, String reality})> myths;
  final List<({String name, String query, String summary})> statutes;
  final String caseId;
  final String caseTitle;
  final String caseSummary;
  final String prompt;
  final String toolKey;
  final String toolTitle;
}

const List<_SituationDomainSpec> _situationDomains = [
  _SituationDomainSpec(
    id: 'rental',
    emoji: '🏠',
    title: '租屋大小事',
    headline: '看懂租賃契約裡的權力與義務',
    intro:
        '台灣租屋市場長期存在資訊不對等，許多房客簽約時並不清楚「定型化契約應記載及不得記載事項」已經具有強制效力。先了解自己的法定底線，再決定下一步溝通方式。',
    subSituations: [
      _SubSituationSpec(
        label: '押金不退',
        contextTitle: '押金的法律性質是「擔保」，不是房東的額外收入',
        contextBody:
            '押金最高不得超過兩個月租金總額。租期屆滿且點交完成後，扣除雙方確認的欠租、水電或非自然損耗修繕費，房東原則上應即時無息返還剩餘押金。',
        sociologyNote:
            '法律社會學視角：許多租屋糾紛源自「退租點交無書面紀錄」，導致雙方在權力不對等下各說各話，拍照與文字紀錄能大幅降低舉證門檻。',
        myths: [
          (
            claim: '牆壁正常使用泛黃或家具自然折舊，我要從押金扣清潔與粉刷費',
            reality: '正常使用下的自然耗損屬於租金已涵蓋的折舊成本，房東不能額外從押金扣除。',
          ),
          (
            claim: '合約上寫提前退租押金全部沒收',
            reality: '住宅租賃定型化契約規定，提前終止違約金最高以一個月租金為上限，不能無條件全額沒收兩個月押金。',
          ),
        ],
        statutes: [
          (
            name: '租賃住宅市場發展及管理條例第 7 條',
            query: '租賃住宅市場發展及管理條例',
            summary: '規範押金上限（二個月租金）及租期屆滿返還義務。',
          ),
          (
            name: '民法第 423 條・第 430 條',
            query: '民法 430',
            summary: '出租人應保持租賃物合於約定使用收益之狀態。',
          ),
        ],
        caseId: 'case-045',
        caseTitle: '網路與契約權益參考案件',
        caseSummary: '進入案件圖書館檢視民事契約與侵權舉證架構',
        prompt: '退租完成點交後，房東以各種名義扣住押金不退，我該如何依法請求返還？',
        toolKey: '租屋催告',
        toolTitle: '租屋押金催告存證信函',
      ),
      _SubSituationSpec(
        label: '修繕責任',
        contextTitle: '房屋結構與設備自然故障，原則上由房東負責修繕',
        contextBody:
            '除非租約明確約定且屬於消耗品（如燈泡），否則冷氣、熱水器、管線漏水等影響居住安全與基本使用機能的損壞，房東依法負有修繕義務。',
        sociologyNote:
            '實務提醒：先以 LINE 或簡訊通知房東並給予合理修繕期限；若逾期不修，房客可自行僱工修繕並保留收據，依法請求償還或自租金中扣除。',
        myths: [
          (
            claim: '合約寫「現況交屋，後續修繕房客自理」就全部歸房客',
            reality: '重大結構漏水或安全問題若未於簽約時明確揭露，房東仍難完全免除瑕疵擔保與修繕義務。',
          ),
        ],
        statutes: [
          (
            name: '民法第 429 條・第 430 條',
            query: '民法 429',
            summary: '租賃物之修繕，除契約另有訂定或另有習慣外，由出租人負擔。',
          ),
        ],
        caseId: 'case-045',
        caseTitle: '民事損害賠償與舉證案例',
        caseSummary: '了解損害發生時如何保存照片與通知紀錄',
        prompt: '租屋處漏水或熱水器故障，房東一直拖延不修，我可以自己找人修再扣房租嗎？',
        toolKey: '租屋催告',
        toolTitle: '租屋修繕／催告存證信函',
      ),
      _SubSituationSpec(
        label: '提前解約',
        contextTitle: '定型化契約下，提前終止租約的賠償有法定上限',
        contextBody:
            '若因工作調動或個人因素需提前退租，應先確認租約是否有「得提前終止」條款及提前通知期間（通常為一個月）。即使沒有約定，實務上也常依一個月內租金計算合理補償。',
        sociologyNote:
            '溝通關鍵：提前告知並協助新房客看屋，往往能與房東協調降低違約金，避免進入冗長調解程序。',
        myths: [
          (
            claim: '沒住滿一年，剩下幾個月的房租要全部賠完',
            reality: '除極少數特殊商用或非住宅情況，一般住宅租賃不得請求顯失公平的剩餘全額租金。',
          ),
        ],
        statutes: [
          (
            name: '民法第 450 條・住宅租賃定型化契約',
            query: '民法 450',
            summary: '規範定期與不定期租賃之終止與預告期間。',
          ),
        ],
        caseId: 'case-045',
        caseTitle: '契約終止與違約金爭議參考',
        caseSummary: '檢視法院如何衡量違約金與實際損害',
        prompt: '因為工作或學業因素需要提前退租，房東要求賠償好幾個月租金合理嗎？',
        toolKey: '租屋催告',
        toolTitle: '存證信函與金額試算',
      ),
    ],
  ),
  _SituationDomainSpec(
    id: 'labor',
    emoji: '💼',
    title: '職場與薪資',
    headline: '辨識僱傭從屬性與勞動基準法底線',
    intro:
        '在非典型勞動、責任制與數位平台興起的時代，許多勞工常被「承攬合約」或「底薪加獎金」模糊了應有權益。台灣法院判斷勞動關係的核心是「實質從屬性」，而非契約上的名稱。',
    subSituations: [
      _SubSituationSpec(
        label: '加班費爭議',
        contextTitle: '只要受雇主指揮監督延長工時，原則上就應計給加班費',
        contextBody:
            '平日延長工時前兩小時按平日每小時工資額加給 1/3 以上，再延長兩小時加給 2/3 以上。若雇主以「責任制」或「補休」拒絕給付，需檢視是否屬於勞動部核定之第 84-1 條工作者，且補休須由勞工同意。',
        sociologyNote:
            '制度背景：加班紀錄往往掌握在公司打卡系統裡，平時下班傳訊息回報、截圖工作對話紀錄，都是極為關鍵的輔助佐證。',
        myths: [
          (
            claim: '我們公司是責任制，本來就沒有加班費',
            reality: '並非雇主口頭宣布就算責任制，必須符合勞基法第 84 條之 1 指定行業並經主管機關核備才有效。',
          ),
          (
            claim: '沒事先申請加班就不算加班',
            reality: '若雇主明知或可得而知勞工仍在提供勞務（例如持續指派急件）而未反對，仍可能認定為加班。',
          ),
        ],
        statutes: [
          (
            name: '勞動基準法第 24 條・第 32 條',
            query: '勞動基準法 24',
            summary: '規定平日與休息日延長工時工資之法定加成標準。',
          ),
        ],
        caseId: 'case-delivery-labor-2152',
        caseTitle: '外送平台外送員僱傭關係認定案',
        caseSummary: '最高法院 113 台上 2152：實質從屬性檢驗與平台勞動權益',
        prompt: '公司常態性加班卻用責任制或強迫補休不給加班費，我該怎麼計算與保存證據？',
        toolKey: '加班費試算',
        toolTitle: '加班費與資遣費試算',
      ),
      _SubSituationSpec(
        label: '資遣與預告',
        contextTitle: '非自願離職必須符合法定事由，並給預告期與資遣費',
        contextBody:
            '雇主不能僅因主觀不滿就片面解僱員工，必須符合勞基法第 11 條（如業務緊縮、確不能勝任工作）並遵守最後手段性原則，同時依年資給予預告期間（或預告工資）、資遣費及非自願離職證明。',
        sociologyNote:
            '重要提醒：若公司遞出「自願離職單」要求簽名，一旦簽署就可能喪失資遣費與失業給付資格，切勿當場簽署不符事實的文件。',
        myths: [
          (
            claim: '你先簽自願離職比較好看，我們再另外談補償',
            reality: '簽了自願離職單後不但可能拿不到資遣費，也無法向就業服務站申請失業補助。',
          ),
        ],
        statutes: [
          (
            name: '勞動基準法第 11 條・第 16 條',
            query: '勞動基準法 11',
            summary: '規範資遣法定事由、預告期間與預告工資。',
          ),
        ],
        caseId: 'case-delivery-labor-2152',
        caseTitle: '外送平台外送員僱傭關係認定案',
        caseSummary: '檢視終止契約防禦事由與實質勞動關係',
        prompt: '公司突然通知我做到月底並要我簽自願離職書，我該如何爭取資遣費與預告工資？',
        toolKey: '加班費試算',
        toolTitle: '資遣費與預告工資試算',
      ),
      _SubSituationSpec(
        label: '離職與交接',
        contextTitle: '勞工有離職自由，雇主不得無故扣發已工作的薪資',
        contextBody:
            '即使勞工未提前預告而離職，雇主仍應全額給付「已出勤日數」的工資，不得直接以未交接為由扣薪。若有損害賠償爭議，應循民事途徑另行舉證請求。',
        sociologyNote:
            '預留紀錄：以 Email 或書面明確提出離職日期並完成工作交接清單，能有效避免日後爭議。',
        myths: [
          (
            claim: '沒做滿一個月或沒找到人交接就不發薪水',
            reality: '勞基法第 26 條明定雇主不得預扣勞工工資作為違約金或賠償費用。',
          ),
        ],
        statutes: [
          (
            name: '勞動基準法第 22 條・第 26 條',
            query: '勞動基準法 26',
            summary: '工資應全額直接給付勞工，禁止雇主預扣工資。',
          ),
        ],
        caseId: 'case-tsmc-secret-1589',
        caseTitle: '台積電控梁孟松營業秘密競業禁止案',
        caseSummary: '了解離職後保密義務與競業禁止之法律邊界',
        prompt: '離職時公司以交接未完成為由扣留最後一個月薪水，這樣合法嗎？',
        toolKey: '加班費試算',
        toolTitle: '薪資計算與工具館',
      ),
    ],
  ),
  _SituationDomainSpec(
    id: 'shopping',
    emoji: '🛍️',
    title: '網購與消費',
    headline: '認識消保法七天猶豫期與平台交易責任',
    intro:
        '網路購物因消費者無法事先檢視實體商品，法律特別設計了「通訊交易解除權」來平衡資訊落差。理解一般企業經營者與個人偶發賣家的差異，是處理網購糾紛的第一步。',
    subSituations: [
      _SubSituationSpec(
        label: '七天退貨',
        contextTitle: '收受商品後 7 日內，原則上可無條件解除契約',
        contextBody:
            '依消費者保護法第 19 條，通訊交易（網購）消費者得於收受商品後 7 日內，以退回商品或書面通知方式解除契約，無須說明理由及負擔任何費用或對價。',
        sociologyNote:
            '常見邊界：若賣家屬於「非以提供商品為業」的個人偶發轉賣二手物品，可能不適用消保法，而回歸民法瑕疵擔保規定。',
        myths: [
          (
            claim: '賣場公告「拆封即不退換」或「貼身衣物不退」',
            reality: '只有符合行政院公告之「合理例外情事」（如易腐敗、客製化、已拆封個人衛生用品）才能排除七天鑑賞期；一般商品拆封檢查不影響退貨權。',
          ),
        ],
        statutes: [
          (
            name: '消費者保護法第 19 條',
            query: '消費者保護法 19',
            summary: '通訊交易及訪問交易消費者得於七日內解除契約。',
          ),
        ],
        caseId: 'case-045',
        caseTitle: '網路交易與侵權參考案件',
        caseSummary: '檢視網路平台爭議之法律認定方式',
        prompt: '網購衣服或家電拆封檢查後不滿意，在七天內申請退貨卻被賣家拒絕怎麼辦？',
        toolKey: '消費退貨',
        toolTitle: '消費退貨／申訴存證信函',
      ),
      _SubSituationSpec(
        label: '瑕疵爭議',
        contextTitle: '商品有瑕疵時，即使過了七天仍可主張物之瑕疵擔保',
        contextBody:
            '七天鑑賞期是「無條件反悔權」；如果商品本身有功能故障、規格不符或破損等瑕疵，依民法第 354 條至第 365 條，消費者在發見瑕疵後通知賣家，仍可請求修補、更換、減少價金或解約。',
        sociologyNote:
            '開箱全程錄影是最好的習慣，能直接證明瑕疵在拆封前即已存在。',
        myths: [
          (
            claim: '超過七天了我們就完全不處理喔',
            reality: '民法瑕疵擔保責任期間原則上可達交付後數月至五年（視情況並須盡速通知），不因過了七天就歸零。',
          ),
        ],
        statutes: [
          (
            name: '民法第 354 條・第 359 條',
            query: '民法 359',
            summary: '買賣標的物有瑕疵時，買受人得請求解除契約或減少價金。',
          ),
        ],
        caseId: 'case-045',
        caseTitle: '瑕疵損害與舉證責任參考',
        caseSummary: '了解證據保存與通知義務',
        prompt: '網購收到商品兩週後發現故障瑕疵，賣家說過了七天鑑賞期不給退換合理嗎？',
        toolKey: '消費退貨',
        toolTitle: '消費爭議函件工具',
      ),
      _SubSituationSpec(
        label: '網購詐騙',
        contextTitle: '遇到一頁式詐騙或幽靈賣場，搶在撥款前止付最關鍵',
        contextBody:
            '若透過貨到付款超商取貨遇到詐騙包裹，立即保留託運單與外箱並聯繫物流／超商客服申請止付退貨；若是轉帳匯款，應立刻撥打 165 反詐騙專線並至派出所報案取得三聯單。',
        sociologyNote:
            '平台結構：合法電商平台多設有第三方支付履約保障，切勿跳出平台私下用通訊軟體轉帳。',
        myths: [
          (
            claim: '超商貨到付款拆開才發現是假貨就沒救了',
            reality: '四大超商與主要物流業者皆設有「詐騙包裹退貨退款申訴管道」，盡速申請有機會攔截代收款項。',
          ),
        ],
        statutes: [
          (
            name: '刑法第 339 條・詐欺犯罪危害防制條例',
            query: '刑法 339',
            summary: '規範詐欺取財罪責與金融止付防制機制。',
          ),
        ],
        caseId: '102',
        caseTitle: '憲法與隱私權益參考案例',
        caseSummary: '進入案件圖書館探索數位時代個人權益界線',
        prompt: '在網路上買東西遇到一頁式詐騙或匯款後賣家消失，我現在第一步該做什麼？',
        toolKey: '消費退貨',
        toolTitle: '實戰工具館',
      ),
    ],
  ),
  _SituationDomainSpec(
    id: 'traffic',
    emoji: '🚗',
    title: '車禍與賠償',
    headline: '釐清肇事責任比例與零件折舊計算',
    intro:
        '車禍發生後，當事人常在保險公司、車行報價單與對方和解壓力之間感到無所適從。其實法院計算財產損害有非常明確的公式，了解規則就能避免被漫天喊價。',
    subSituations: [
      _SubSituationSpec(
        label: '維修折舊',
        contextTitle: '修車賠「零件」要算折舊，只有「工資與烤漆」不折舊',
        contextBody:
            '民法損害賠償原則是「回復原狀」，而非讓對方免費換新零件獲利。因此法院在計算車輛維修費時，會將報價單區分為「零件費」與「工資／烤漆費」：零件依車輛出廠年數按行政院固定資產耐用年數表計算折舊，工資則全額計算。',
        sociologyNote:
            '談判實力：對方拿出一張 10 萬元原廠估價單時，其中可能 7 萬元都是零件；老車折舊後，實際應負擔的零件費往往不到原本的一半。',
        myths: [
          (
            claim: '被撞就要照原廠報價單全額賠到好',
            reality: '依最高法院長期穩定見解，新品換舊品必須扣除零件折舊，並再乘以雙方肇事責任比例。',
          ),
        ],
        statutes: [
          (
            name: '民法第 184 條・第 191 條之 2・第 213 條',
            query: '民法 213',
            summary: '確立侵權行為損害賠償與回復原狀之折舊計算原則。',
          ),
        ],
        caseId: 'case-045',
        caseTitle: '民事侵權損害賠償參考案例',
        caseSummary: '了解民法第 184 條侵權損害賠償要件',
        prompt: '車禍對方拿原廠 8 萬元估價單向我求償，零件折舊跟肇責比例應該怎麼算？',
        toolKey: '車禍折舊',
        toolTitle: '車禍零件折舊試算器',
      ),
      _SubSituationSpec(
        label: '初判與鑑定',
        contextTitle: '事故後 30 日可申請初步分析研判表，有疑義再申請鑑定',
        contextBody:
            '報警處理後，事故當事人可於事故 7 日後申請現場圖與照片、30 日後免費申請「道路交通事故初步分析研判表（初判表）」。若對肇責比例仍有爭執，可於 6 個月內向車輛行車事故鑑定委員會申請正式鑑定。',
        sociologyNote:
            '時效提醒：若涉及人員受傷（過失傷害罪），刑事告訴期間為知悉犯人之日起「6 個月內」，千萬不要在和解拉鋸中錯過期限。',
        myths: [
          (
            claim: '只要是後車撞前車就一定是後車全責',
            reality: '仍須視前車是否無故驟停、違規變換車道未打方向燈等具體路權因素判定，並非絕對全責。',
          ),
        ],
        statutes: [
          (
            name: '刑法第 284 條・刑事訴訟法第 237 條',
            query: '刑法 284',
            summary: '過失傷害罪責與告訴乃論六個月告訴期間。',
          ),
        ],
        caseId: 'case-045',
        caseTitle: '過失責任與舉證參考案例',
        caseSummary: '檢視法院如何認定注意義務與因果關係',
        prompt: '車禍初判表還沒出來對方就急著要談和解，我應該先準備哪些資料保護自己？',
        toolKey: '車禍折舊',
        toolTitle: '車禍求償與折舊工具',
      ),
      _SubSituationSpec(
        label: '調解和解',
        contextTitle: '和解書應明確寫清楚「是否包含強制險」與「拋棄其他請求」',
        contextBody:
            '建議至鄉鎮市區公所調解委員會進行調解（經法院核定後具與確定判決同一效力）。簽署和解書時務必確認賠償金額是否已含強制汽車責任保險理賠，以及是否連同刑事告訴一併撤回。',
        sociologyNote:
            '調解技巧：通知自己的任意第三人責任險理賠專員一同出席調解會，能有效協助評估合理賠付範圍。',
        myths: [
          (
            claim: '私下寫一張和解書就代表全部結束了',
            reality: '若只寫「民事和解」未處理刑事撤告，對方仍可能保留追訴空間；條文措辭應明確載明範圍。',
          ),
        ],
        statutes: [
          (
            name: '鄉鎮市調解條例第 27 條・民法第 736 條',
            query: '民法 736',
            summary: '規範和解契約之效力與調解核定後之執行力。',
          ),
        ],
        caseId: 'case-support-exemption-1118',
        caseTitle: '家事與民事公平原則參考',
        caseSummary: '探索法院在衡平雙方權益時的判斷視角',
        prompt: '要去區公所車禍調解會了，和解書條款有哪些一定要注意的陷阱？',
        toolKey: '車禍折舊',
        toolTitle: '車禍折舊與和解試算',
      ),
    ],
  ),
];
