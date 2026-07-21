import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:preamble/components/navigation/island_bottom_nav.dart';
import 'package:preamble/data/mock_data/learning/learning_mock_data.dart';
import 'package:preamble/main.dart';
import 'package:preamble/pages/home/home_page.dart';
import 'package:preamble/pages/journal/journal_page.dart';
import 'package:preamble/pages/learning/know_law_page.dart';
import 'package:preamble/pages/learning/learning_mock_detail_page.dart';
import 'package:preamble/pages/learning/statute_database_page.dart';
import 'package:preamble/pages/learning/widgets/legal_document_export_page.dart';
import 'package:preamble/pages/learning/widgets/learning_result_action_bar.dart';
import 'package:preamble/pages/profile/profile_page.dart';
import 'package:preamble/pages/search/global_search_page.dart';

import 'responsive_test_harness.dart';

/// 無法在不更動產品依賴注入架構下可靠啟動的頁面，仍要進 registry 留下稽核責任。
class ResponsiveManualAuditEntry {
  const ResponsiveManualAuditEntry({
    required this.id,
    required this.label,
    required this.reason,
    required this.declaredStates,
    required this.nextBatch,
  });

  final String id;
  final String label;
  final String reason;

  /// 僅記錄產品宣告的狀態；尚未代表每個狀態已有獨立自動化 fixture。
  final List<String> declaredStates;
  final String nextBatch;
}

final responsiveComponentEntries = <ResponsiveAuditEntry>[
  ResponsiveAuditEntry(
    id: 'component.island_bottom_nav',
    label: 'IslandBottomNav',
    declaredStates: const ['normal', 'safe-area'],
    primaryLabels: const ['首頁', '學習', '小法助', '紀事', '我的'],
    tappablePrimaryLabels: const ['首頁', '學習', '小法助', '紀事', '我的'],
    usesBoundedSettle: true,
    builder: () => Scaffold(
      body: Stack(
        children: [
          Positioned(
            left: 12,
            right: 12,
            bottom: 17,
            child: SafeArea(
              top: false,
              child: IslandBottomNav(
                selectedIndex: 0,
                showLabels: true,
                items: const [
                  BottomNavItemData(
                    label: '首頁',
                    icon: Icons.home_outlined,
                    selectedIcon: Icons.home_rounded,
                  ),
                  BottomNavItemData(
                    label: '學習',
                    icon: Icons.menu_book_outlined,
                    selectedIcon: Icons.menu_book_rounded,
                  ),
                  BottomNavItemData(
                    label: '小法助',
                    icon: Icons.support_agent_outlined,
                    selectedIcon: Icons.support_agent_rounded,
                  ),
                  BottomNavItemData(
                    label: '紀事',
                    icon: Icons.inventory_2_outlined,
                    selectedIcon: Icons.inventory_2_rounded,
                  ),
                  BottomNavItemData(
                    label: '我的',
                    icon: Icons.person_outline_rounded,
                    selectedIcon: Icons.person_rounded,
                  ),
                ],
                onTap: (_) {},
              ),
            ),
          ),
        ],
      ),
    ),
  ),
  ResponsiveAuditEntry(
    id: 'component.learning_result_action_bar',
    label: 'LearningResultActionBar',
    declaredStates: const ['normal', 'longest-realistic-content'],
    primaryLabels: const ['複製文字', '摘錄筆記', '預覽與導出 PDF'],
    tappablePrimaryLabels: const ['複製文字', '摘錄筆記', '預覽與導出 PDF'],
    usesBoundedSettle: true,
    builder: () => Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: LearningResultActionBar(
          copyAction: LearningResultActionButton(
            icon: Icons.copy_rounded,
            label: '複製文字',
            color: const Color(0xFFB8767A),
            onPressed: () {},
          ),
          noteAction: LearningResultActionButton(
            icon: Icons.edit_note_rounded,
            label: '摘錄筆記',
            color: const Color(0xFF8B7D74),
            onPressed: () {},
          ),
          exportAction: LearningResultActionButton(
            icon: Icons.picture_as_pdf_outlined,
            label: '預覽與導出 PDF',
            color: const Color(0xFF55796C),
            onPressed: () {},
          ),
        ),
      ),
    ),
  ),
];

final responsiveScreenEntries = <ResponsiveAuditEntry>[
  ResponsiveAuditEntry(
    id: 'screen.app_shell_home',
    label: '主導航首頁',
    declaredStates: const ['loading', 'normal'],
    primaryLabels: const ['法律即時快問', '首頁', '學習', '小法助', '紀事', '我的'],
    ownsAppShell: true,
    builder: () => const MylawApp(),
  ),
  ResponsiveAuditEntry(
    id: 'screen.home_page',
    label: '首頁內容',
    declaredStates: const ['loading', 'normal', 'longest-realistic-content'],
    primaryLabels: const ['法律即時快問'],
    // 台灣繁體中文教學註解：首頁主內容是長頁面；primary label 初始不在
    // viewport 不代表不可達，稽核前應先使用既有 ensureVisible 流程捲動。
    requiresScroll: true,
    builder: () => Scaffold(
      body: HomePage(
        onNavigateToTab: (_, {int? subTabIndex, String? toolTab}) {},
      ),
    ),
  ),
  ResponsiveAuditEntry(
    id: 'screen.learning_tools',
    label: '學習首頁與工具箱',
    declaredStates: const ['loading', 'normal', 'longest-realistic-content'],
    primaryLabels: const ['學堂與工具箱'],
    builder: () => const KnowLawPage(initialTabIndex: 1),
  ),
  ResponsiveAuditEntry(
    id: 'screen.learning_article',
    label: '學習工具結果文章',
    declaredStates: const ['normal', 'longest-realistic-content'],
    primaryLabels: [featuredLearningTopics.values.first.heroArticle.title],
    builder: () => LearningMockDetailPage(
      article: featuredLearningTopics.values.first.heroArticle,
      category: featuredLearningTopics.keys.first,
    ),
  ),
  ResponsiveAuditEntry(
    id: 'screen.journal',
    label: '紀事',
    declaredStates: const ['normal', 'search-result'],
    primaryLabels: const [],
    builder: () => const JournalPage(),
  ),
  ResponsiveAuditEntry(
    id: 'screen.profile',
    label: '我的 Preamble',
    declaredStates: const ['loading', 'normal', 'build-info-fallback'],
    primaryLabels: const ['訪客個人中心'],
    builder: () => const ProfilePage(),
  ),
  ResponsiveAuditEntry(
    id: 'screen.global_search',
    label: '小法助搜尋',
    declaredStates: const ['normal', 'user-entered-long-text', 'keyboard'],
    primaryLabels: const ['嗨！我是小法助'],
    interaction: _enterLongSearchText,
    builder: () => const GlobalSearchPage(),
  ),
  ResponsiveAuditEntry(
    id: 'screen.statute_database',
    label: '法規資料庫',
    declaredStates: const [
      'normal',
      'empty',
      'user-entered-long-text',
      'keyboard'
    ],
    primaryLabels: const ['法規資料庫'],
    interaction: _enterLongSearchText,
    builder: () => const StatuteDatabasePage(),
  ),
  ResponsiveAuditEntry(
    id: 'screen.document_export',
    label: 'PDF 預覽與導出',
    declaredStates: const ['normal', 'longest-realistic-content'],
    primaryLabels: const ['書狀預覽與導出'],
    requiresScroll: true,
    builder: () => const LegalDocumentExportPage(
      title: '網購退貨通知書',
      content: '本人於網路購物後，依消費者保護法行使解除契約權利。'
          '請協助確認退款、退貨物流與後續權益安排。',
    ),
  ),
];

const responsiveManualOnlyEntries = <ResponsiveManualAuditEntry>[
  ResponsiveManualAuditEntry(
    id: 'manual.case_library',
    label: '案件圖書館與卷宗',
    reason: '頁面初始化直接依賴 SQLite 與 Supabase singleton，目前沒有可注入 repository。',
    declaredStates: ['loading', 'normal', 'longest-realistic-content', 'error'],
    nextBatch: 'Batch A',
  ),
  ResponsiveManualAuditEntry(
    id: 'manual.law_assistant_chat',
    label: '小法助對話頁',
    reason: '啟動即建立正式 LawAssistantRepository，尚未提供測試 fake。',
    declaredStates: [
      'loading',
      'normal',
      'error',
      'keyboard',
      'user-entered-long-text'
    ],
    nextBatch: 'Batch B',
  ),
  ResponsiveManualAuditEntry(
    id: 'manual.saved_notes',
    label: '摘錄筆記與收藏',
    reason: '頁面互動會呼叫 SupabaseLearningService，沒有 stable fake service。',
    declaredStates: ['normal', 'empty', 'longest-realistic-content'],
    nextBatch: 'Batch C',
  ),
  ResponsiveManualAuditEntry(
    id: 'manual.profile_sheets',
    label: '個人頁設定 Bottom Sheets',
    reason: '需由多個實際點擊路徑開啟，尚未建立共用 sheet presenter。',
    declaredStates: ['normal', 'keyboard', 'longest-realistic-content'],
    nextBatch: 'Batch B',
  ),
];

Future<void> _enterLongSearchText(WidgetTester tester) async {
  final editableText = find.byType(EditableText);
  if (editableText.evaluate().isEmpty) return;
  await tester.tap(editableText.first, warnIfMissed: false);
  await tester.enterText(
    editableText.first,
    '這是一段用於響應式稽核的較長法律問題，請說明民法侵權行為、'
    '消費者保護與網路購物退貨的權利義務以及可以採取的下一步。',
  );
}
