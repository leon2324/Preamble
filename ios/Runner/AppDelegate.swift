import Flutter
import UIKit
import WidgetKit

private enum TodayCaseWidgetBridge {
  // 台灣繁體中文教學註解：
  // 這組常數是 Flutter 主 App 與 Widget extension 的「原生整合契約」。
  // MethodChannel 名稱負責讓 Dart 呼叫 iOS，App Group 與 payload key 則負責讓 WidgetKit 讀取同一份資料。
  static let channelName = "lawapp/today_case_widget"
  static let appGroupIdentifier = "group.com.leonchen.lawapp.dev1"
  static let payloadKey = "today_case_widget_payload"
}

private enum QuickAskAppIntentBridge {
  // 台灣繁體中文教學註解：
  // App Intents 與 Widget 點擊都會透過 lawapp:// URL scheme 回到主 App；
  // 這裡再轉成 MethodChannel，讓 Flutter 主殼層負責切換到「小法助」分頁。
  static let channelName = "lawapp/quick_ask_intent"
  static let quickAskHost = "quick-ask"
  static let todayCaseHost = "today-case"
  static let promptQueryName = "prompt"
  static let appGroupIdentifier = "group.com.leonchen.lawapp.dev1"
  static let pendingPromptKey = "quick_ask_intent_pending_prompt"
  static let todayCasePrompt = "我想看今天判決故事的白話整理，並請小法助補充相關法律重點。"
}

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var quickAskChannel: FlutterMethodChannel?
  private var quickAskBridgeReady = false
  private var pendingQuickAskPrompt: String?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    registerTodayCaseWidgetBridge()
    registerQuickAskAppIntentBridge()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func applicationDidBecomeActive(_ application: UIApplication) {
    super.applicationDidBecomeActive(application)
    deliverPersistedQuickAskPromptIfPossible()
  }

  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    if handleLawAppURL(url) {
      return true
    }
    return super.application(app, open: url, options: options)
  }

  override func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
  ) -> Bool {
    if let url = userActivity.webpageURL, handleLawAppURL(url) {
      return true
    }
    return super.application(
      application,
      continue: userActivity,
      restorationHandler: restorationHandler
    )
  }

  private func registerTodayCaseWidgetBridge() {
    // 台灣繁體中文教學註解：
    // MAIC 方向不是把 Flutter 全部重寫成 Swift，而是把 Apple 原生能力接成清楚的邊界層；
    // 這個 bridge 讓 Flutter 首頁資料能同步到 WidgetKit，同時避免 Widget extension 依賴 Dart runtime。
    guard let controller = window?.rootViewController as? FlutterViewController else {
      return
    }

    let channel = FlutterMethodChannel(
      name: TodayCaseWidgetBridge.channelName,
      binaryMessenger: controller.binaryMessenger
    )

    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "updateTodayCaseWidget":
        self.updateTodayCaseWidget(arguments: call.arguments, result: result)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func registerQuickAskAppIntentBridge() {
    guard let controller = window?.rootViewController as? FlutterViewController else {
      return
    }

    let channel = FlutterMethodChannel(
      name: QuickAskAppIntentBridge.channelName,
      binaryMessenger: controller.binaryMessenger
    )
    quickAskChannel = channel

    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else {
        result(nil)
        return
      }

      switch call.method {
      case "consumeInitialQuickAsk":
        // 台灣繁體中文教學註解：
        // App 冷啟動時，URL 事件可能比 Flutter 畫面註冊 listener 更早抵達；
        // 因此先暫存在 pendingQuickAskPrompt，等 Flutter 主殼層初始化後再一次取走。
        self.quickAskBridgeReady = true
        let prompt = self.pendingQuickAskPrompt ?? self.consumePersistedQuickAskPrompt()
        self.pendingQuickAskPrompt = nil
        result(prompt.map { ["prompt": $0] })
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func handleLawAppURL(_ url: URL) -> Bool {
    guard url.scheme == "lawapp",
          let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
      return false
    }

    switch components.host {
    case QuickAskAppIntentBridge.quickAskHost:
      let prompt = components.queryItems?
        .first(where: { $0.name == QuickAskAppIntentBridge.promptQueryName })?
        .value
      deliverQuickAskPrompt(prompt ?? "")
      return true
    case QuickAskAppIntentBridge.todayCaseHost:
      deliverQuickAskPrompt(QuickAskAppIntentBridge.todayCasePrompt)
      return true
    default:
      return false
    }
  }

  private func deliverQuickAskPrompt(_ prompt: String) {
    let normalizedPrompt = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !normalizedPrompt.isEmpty else {
      return
    }

    if quickAskBridgeReady, let quickAskChannel {
      quickAskChannel.invokeMethod(
        "openQuickAsk",
        arguments: ["prompt": normalizedPrompt]
      )
    } else {
      pendingQuickAskPrompt = normalizedPrompt
    }
  }

  private func deliverPersistedQuickAskPromptIfPossible() {
    guard let prompt = consumePersistedQuickAskPrompt() else {
      return
    }
    deliverQuickAskPrompt(prompt)
  }

  private func consumePersistedQuickAskPrompt() -> String? {
    guard let defaults = UserDefaults(
      suiteName: QuickAskAppIntentBridge.appGroupIdentifier
    ) else {
      return nil
    }

    let prompt = defaults
      .string(forKey: QuickAskAppIntentBridge.pendingPromptKey)?
      .trimmingCharacters(in: .whitespacesAndNewlines)
    defaults.removeObject(forKey: QuickAskAppIntentBridge.pendingPromptKey)
    return prompt?.isEmpty == false ? prompt : nil
  }

  private func updateTodayCaseWidget(arguments: Any?, result: FlutterResult) {
    // 台灣繁體中文教學註解：
    // 原生端只接受扁平 dictionary，避免把 Flutter model 直接綁進 iOS extension。
    // 這樣之後要換成真實 API、Spotlight 索引或 App Intent 回應，都能共用同一種 payload 觀念。
    guard let payload = arguments as? [String: Any] else {
      result(FlutterError(
        code: "invalid_payload",
        message: "Today case widget payload must be a dictionary.",
        details: nil
      ))
      return
    }

    var normalizedPayload = payload
    normalizedPayload["updatedAt"] = ISO8601DateFormatter().string(from: Date())

    do {
      let data = try JSONSerialization.data(
        withJSONObject: normalizedPayload,
        options: []
      )
      guard let jsonString = String(data: data, encoding: .utf8),
            let defaults = UserDefaults(
              suiteName: TodayCaseWidgetBridge.appGroupIdentifier
            ) else {
        result(FlutterError(
          code: "app_group_unavailable",
          message: "Unable to open LawApp App Group defaults.",
          details: TodayCaseWidgetBridge.appGroupIdentifier
        ))
        return
      }

      // 台灣繁體中文教學註解：
      // Widget extension 與主 App 只能透過 App Group 分享少量資料；
      // 這裡存 JSON 字串而不是 Flutter 物件，讓 SwiftUI Widget 能用 Foundation 直接解析。
      defaults.set(jsonString, forKey: TodayCaseWidgetBridge.payloadKey)

      if #available(iOS 14.0, *) {
        WidgetCenter.shared.reloadTimelines(ofKind: "LawAppTodayCaseWidget")
      }
      result(nil)
    } catch {
      result(FlutterError(
        code: "encode_failed",
        message: "Unable to encode today case widget payload.",
        details: error.localizedDescription
      ))
    }
  }
}
