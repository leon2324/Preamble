import 'package:flutter/material.dart';
import 'package:preamble/data/statutes/statute_item.dart';
import 'package:preamble/pages/learning/know_law_page.dart';
import 'package:preamble/pages/learning/statute_database_page.dart';
import 'package:preamble/platform/ios_deep_link_bridge.dart';
import 'package:preamble/platform/ios_quick_ask_intent_bridge.dart';
import 'package:preamble/platform/ios_statute_spotlight_bridge.dart';

// =============================================================================
// [審查標記] 此檔案的功能已被 NativeStartupCoordinator + main.dart 取代。
// =============================================================================
// IosIntentRouter 與 NativeStartupCoordinator 存在嚴重的競態條件：
// 兩者都會呼叫 consumeInitialPrompt / consumeInitialQuery / consumeInitialLink，
// 而 Platform Channel 的 consume 行為是「讀取即銷毀」。
// 若兩者同時註冊監聽，會導致：
//   1. 其中一方讀到 null（intent 已被另一方消費）
//   2. 兩方各自處理不同事件，觸發矛盾導航
//      （IosIntentRouter 用 Navigator.push，main.dart 改 selectedIndex）
//
// 此外，_handleDeepLink 中對 today_case 做 Navigator.push(KnowLawPage())，
// 但 KnowLawPage 是 IndexedStack 中的主分頁。
// Push 後使用者會看到一個沒有底部導覽的重複頁面。
//
// 教學重點：當有多個元件競爭消費同一個 one-shot 事件時，
// 必須指定唯一的「消費者」，而非讓多個模組各自嘗試消費。
// =============================================================================

/// [已棄用] iOS 生態系意圖與深層連結統一路由中樞。
/// 此類別的功能已由 [NativeStartupCoordinator] + main.dart 的事件處理取代。
/// 請勿在新程式碼中使用此類別。
@Deprecated('Use NativeStartupCoordinator instead. '
    'IosIntentRouter has a race condition with NativeStartupCoordinator '
    'when consuming platform channel intents. See code_audit_report_2026-08-14.md for details.')
class IosIntentRouter {
  const IosIntentRouter._();

  /// 註冊廣播監聽與熱啟動 (Warm Start) 路由 Handler。
  static void register(BuildContext context) {
    // 1. Siri 快問語音意圖
    IosQuickAskIntentBridge.registerPromptHandler((prompt) {
      _navigateToLawAssistant(context, prompt: prompt);
    });

    // 2. Widget 與 Deep Link 點擊
    IosDeepLinkBridge.registerLinkHandler((url) {
      _handleDeepLink(context, url);
    });

    // 3. Core Spotlight 搜尋條文
    IosStatuteSpotlightBridge.registerQueryHandler((query) {
      _navigateToStatuteSearch(context, query: query);
    });
  }

  /// 檢查冷啟動 (Cold Start) 傳入之意圖。
  static Future<void> checkInitialIntents(BuildContext context) async {
    // 檢查 Siri 語音 Prompt
    final initialPrompt =
        await IosQuickAskIntentBridge.consumeInitialPrompt();
    if (initialPrompt != null && initialPrompt.isNotEmpty) {
      if (context.mounted) {
        _navigateToLawAssistant(context, prompt: initialPrompt);
      }
      return;
    }

    // 檢查 Deep Link URL
    final initialLink = await IosDeepLinkBridge.consumeInitialLink();
    if (initialLink != null && initialLink.isNotEmpty) {
      if (context.mounted) {
        _handleDeepLink(context, initialLink);
      }
      return;
    }

    // 檢查 Spotlight 搜尋語
    final initialQuery =
        await IosStatuteSpotlightBridge.consumeInitialQuery();
    if (initialQuery != null && initialQuery.isNotEmpty) {
      if (context.mounted) {
        _navigateToStatuteSearch(context, query: initialQuery);
      }
      return;
    }
  }

  /// 取消註冊所有橋接監聽。
  static void unregister() {
    IosQuickAskIntentBridge.unregisterPromptHandler();
    IosDeepLinkBridge.unregisterLinkHandler();
    IosStatuteSpotlightBridge.unregisterQueryHandler();
  }

  static void _navigateToLawAssistant(
    BuildContext context, {
    required String prompt,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LawAssistantChatPage(
          initialPrompt: prompt,
        ),
      ),
    );
  }

  static void _navigateToStatuteSearch(
    BuildContext context, {
    required String query,
  }) {
    final articleNumStr =
        RegExp(r'\d+').firstMatch(query)?.group(0) ?? '184';
    final codeName = query.contains('民')
        ? '民法'
        : (query.contains('勞') ? '勞動基準法' : '民法');

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StatuteDetailPage(
          item: StatuteItem(
            codeName: codeName,
            articleNumber: articleNumStr,
            articleText: '條文查詢：$query\n（點擊此處閱讀完整法規條文與相關解釋）',
            lawUrl: 'https://law.moj.gov.tw',
            category: '民事法',
            updatedDate: '2026/01/01',
            isRepealed: false,
            tags: [codeName, '第 $articleNumStr 條'],
          ),
        ),
      ),
    );
  }

  static void _handleDeepLink(BuildContext context, String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return;

    if (uri.host == 'quick_ask' || url.contains('quick_ask')) {
      final prompt = uri.queryParameters['prompt'] ?? '請問法律相關問題';
      _navigateToLawAssistant(context, prompt: prompt);
    } else if (uri.host == 'today_case' || url.contains('today_case')) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const KnowLawPage(),
        ),
      );
    }
  }
}
