import AppIntents
import Foundation

private enum PreambleQuickAskIntentStore {
  static let appGroupIdentifier = "group.com.leonchen.lawapp.dev1"
  static let pendingPromptKey = "quick_ask_intent_pending_prompt"
}

// 台灣繁體中文教學註解：
// App Intents 是 iOS 16 之後讓 Siri、Shortcuts、Spotlight 等系統入口呼叫 App 功能的原生架構。
// 這個檔案只描述「快問小法助」這個系統級入口；真正的聊天與搜尋仍交給 Flutter App 內既有流程。
@available(iOS 16.0, *)
struct PreambleQuickAskIntent: AppIntent {
  static var title: LocalizedStringResource = "快問小法助"
  static var description = IntentDescription("用 Siri 或捷徑把生活法律問題直接交給 緒言 Preamble 小法助整理。")
  static var openAppWhenRun = true

  @Parameter(
    title: "法律問題",
    description: "例如：租屋押金被扣怎麼辦？"
  )
  var question: String

  static var parameterSummary: some ParameterSummary {
    Summary("用小法助回答 \(\.$question)")
  }

  @MainActor
  func perform() async throws -> some IntentResult {
    let normalizedQuestion = question.trimmingCharacters(in: .whitespacesAndNewlines)
    let prompt = normalizedQuestion.isEmpty ? "租屋押金被扣怎麼辦？" : normalizedQuestion

    // 台灣繁體中文教學註解：
    // iOS 16 的 App Intents 可以用 openAppWhenRun 開啟主 App，但不適合直接依賴 iOS 18 的 OpenURLIntent。
    // 因此先把問題寫入 App Group，AppDelegate 啟動或回前景時再交給 Flutter 小法助流程。
    UserDefaults(suiteName: PreambleQuickAskIntentStore.appGroupIdentifier)?
      .set(prompt, forKey: PreambleQuickAskIntentStore.pendingPromptKey)
    return .result()
  }
}

@available(iOS 16.0, *)
struct PreambleQuickAskShortcuts: AppShortcutsProvider {
  static var appShortcuts: [AppShortcut] {
    AppShortcut(
      intent: PreambleQuickAskIntent(),
      phrases: [
        "用\(.applicationName)問法律",
        "用\(.applicationName)問小法助",
        "請\(.applicationName)回答法律問題"
      ],
      shortTitle: "快問法律",
      systemImageName: "text.bubble"
    )
  }
}
