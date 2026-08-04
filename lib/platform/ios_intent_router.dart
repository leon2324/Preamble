import 'package:flutter/material.dart';
import 'package:preamble/data/statutes/statute_item.dart';
import 'package:preamble/pages/learning/know_law_page.dart';
import 'package:preamble/pages/learning/statute_database_page.dart';
import 'package:preamble/platform/ios_deep_link_bridge.dart';
import 'package:preamble/platform/ios_quick_ask_intent_bridge.dart';
import 'package:preamble/platform/ios_statute_spotlight_bridge.dart';

/// iOS 生態系意圖與深層連結統一路由中樞。
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
