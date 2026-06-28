import Flutter
import CoreSpotlight
import UIKit
import WidgetKit
import ActivityKit

private enum TodayCaseWidgetBridge {
  // 台灣繁體中文教學註解：
  // 這組常數是 Flutter 主 App 與 Widget extension 的「原生整合契約」。
  // MethodChannel 名稱負責讓 Dart 呼叫 iOS，App Group 與 payload key 則負責讓 WidgetKit 讀取同一份資料。
  static let channelName = "preamble/today_case_widget"
  static let appGroupIdentifier = "group.com.vernalcollective.preamble"
  static let payloadKey = "today_case_widget_payload"
}

private enum TodoListWidgetBridge {
  static let payloadKey = "todo_list_widget_payload"
}

private enum QuickAskAppIntentBridge {
  // 台灣繁體中文教學註解：
  // App Intents 與 Widget 點擊都會透過 preamble:// URL scheme 回到主 App；
  // 這裡再轉成 MethodChannel，讓 Flutter 主殼層負責切換到「小法助」分頁。
  static let channelName = "preamble/quick_ask_intent"
  static let quickAskHost = "quick-ask"
  static let todayCaseHost = "today-case"
  static let promptQueryName = "prompt"
  static let appGroupIdentifier = "group.com.vernalcollective.preamble"
  static let pendingPromptKey = "quick_ask_intent_pending_prompt"
  static let todayCasePrompt = "我想看今天判決故事的白話整理，並請小法助補充相關法律重點。"
}

private enum StatuteSpotlightBridge {
  // 台灣繁體中文教學註解：
  // 法條內容與索引策略留在 Dart；Swift 只保存 Core Spotlight 需要的系統常數。
  // 這樣日後要改成正式資料庫、使用者追蹤法條或個人化推薦時，不必重寫原生層。
  static let channelName = "preamble/statute_spotlight"
  static let domainIdentifier = "com.vernalcollective.preamble.statutes"
  static let itemPrefix = "preamble.statute."
}

private enum NativeShareBridge {
  // 台灣繁體中文教學註解：
  // Flutter 端只負責傳入圖卡文字內容；真正的 Apple 分享面板與「儲存圖片」選項
  // 由 iOS 原生 UIActivityViewController 提供，避免 App 直接假裝已分享或已存入相簿。
  static let channelName = "preamble/native_share"
}

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var quickAskChannel: FlutterMethodChannel?
  private var quickAskBridgeReady = false
  private var pendingQuickAskPrompt: String?
  private var statuteSpotlightChannel: FlutterMethodChannel?
  private var statuteSpotlightBridgeReady = false
  private var pendingStatuteSpotlightQuery: String?
  private var deepLinkChannel: FlutterMethodChannel?
  private var deepLinkBridgeReady = false
  private var pendingDeepLink: String?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    registerTodayCaseWidgetBridge()
    registerQuickAskAppIntentBridge()
    registerStatuteSpotlightBridge()
    registerDeepLinkBridge()
    registerNativeShareBridge()
    registerLiveActivityBridge()
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
    if handlePreambleURL(url) {
      return true
    }
    return super.application(app, open: url, options: options)
  }

  override func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
  ) -> Bool {
    if handleSpotlightUserActivity(userActivity) {
      return true
    }

    if let url = userActivity.webpageURL, handlePreambleURL(url) {
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
      case "updateTodoListWidget":
        self.updateTodoListWidget(arguments: call.arguments, result: result)
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

  private func registerDeepLinkBridge() {
    guard let controller = window?.rootViewController as? FlutterViewController else {
      return
    }

    let channel = FlutterMethodChannel(
      name: "preamble/deep_link",
      binaryMessenger: controller.binaryMessenger
    )
    deepLinkChannel = channel

    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else {
        result(nil)
        return
      }

      switch call.method {
      case "consumeInitialDeepLink":
        self.deepLinkBridgeReady = true
        let link = self.pendingDeepLink
        self.pendingDeepLink = nil
        result(link.map { ["url": $0] })
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func registerStatuteSpotlightBridge() {
    guard let controller = window?.rootViewController as? FlutterViewController else {
      return
    }

    let channel = FlutterMethodChannel(
      name: StatuteSpotlightBridge.channelName,
      binaryMessenger: controller.binaryMessenger
    )
    statuteSpotlightChannel = channel

    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else {
        result(nil)
        return
      }

      switch call.method {
      case "indexStatuteSpotlightItems":
        self.indexStatuteSpotlightItems(arguments: call.arguments, result: result)
      case "consumeInitialStatuteQuery":
        // 台灣繁體中文教學註解：
        // 使用者從 Spotlight 冷啟動 App 時，NSUserActivity 可能早於 Flutter listener；
        // 因此先把 query 暫存在原生層，待 Dart 主殼層初始化後再取回。
        self.statuteSpotlightBridgeReady = true
        let query = self.pendingStatuteSpotlightQuery
        self.pendingStatuteSpotlightQuery = nil
        result(query.map { ["query": $0] })
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func registerNativeShareBridge() {
    guard let controller = window?.rootViewController as? FlutterViewController else {
      return
    }

    let channel = FlutterMethodChannel(
      name: NativeShareBridge.channelName,
      binaryMessenger: controller.binaryMessenger
    )

    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else {
        result(nil)
        return
      }

      switch call.method {
      case "shareText":
        self.shareText(arguments: call.arguments, result: result)
      case "shareTipCard":
        self.shareTipCard(arguments: call.arguments, result: result)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func registerLiveActivityBridge() {
    guard let controller = window?.rootViewController as? FlutterViewController else {
      return
    }

    let channel = FlutterMethodChannel(
      name: "preamble/live_activity",
      binaryMessenger: controller.binaryMessenger
    )

    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "startLiveActivity":
        if #available(iOS 16.2, *) {
          guard let args = call.arguments as? [String: Any],
                let caseTitle = args["caseTitle"] as? String,
                let status = args["status"] as? String,
                let countdownDays = args["countdownDays"] as? Int,
                let nextEvent = args["nextEvent"] as? String else {
            result(FlutterError(code: "invalid_args", message: "Arguments mismatch", details: nil))
            return
          }

          // 啟動前先結束現有的即時動態，避免重複累積
          for activity in Activity<PreambleAttributes>.activities {
            Task {
              await activity.end(dismissalPolicy: .immediate)
            }
          }

          let attributes = PreambleAttributes(caseTitle: caseTitle)
          let initialContentState = PreambleAttributes.ContentState(status: status, countdownDays: countdownDays, nextEvent: nextEvent)

          do {
            let activity = try Activity<PreambleAttributes>.request(
              attributes: attributes,
              content: .init(state: initialContentState, staleDate: nil, relevanceScore: 1.0),
              pushType: nil
            )
            result(activity.id)
          } catch {
            result(FlutterError(code: "start_failed", message: error.localizedDescription, details: nil))
          }
        } else {
          result(FlutterError(code: "unsupported", message: "iOS 16.2+ required", details: nil))
        }
      case "stopLiveActivity":
        if #available(iOS 16.2, *) {
          Task {
            for activity in Activity<PreambleAttributes>.activities {
              await activity.end(dismissalPolicy: .immediate)
            }
            result(nil)
          }
        } else {
          result(nil)
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func handlePreambleURL(_ url: URL) -> Bool {
    guard url.scheme == "preamble",
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
    case "todo-list", "time-machine", "chat", "tips", "vocabulary":
      deliverDeepLink(url.absoluteString)
      return true
    default:
      return false
    }
  }

  private func deliverDeepLink(_ urlString: String) {
    let normalizedUrl = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !normalizedUrl.isEmpty else {
      return
    }

    if deepLinkBridgeReady, let deepLinkChannel {
      deepLinkChannel.invokeMethod(
        "openDeepLink",
        arguments: ["url": normalizedUrl]
      )
    } else {
      pendingDeepLink = normalizedUrl
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

  private func handleSpotlightUserActivity(_ userActivity: NSUserActivity) -> Bool {
    guard userActivity.activityType == CSSearchableItemActionType,
          let identifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String,
          identifier.hasPrefix(StatuteSpotlightBridge.itemPrefix) else {
      return false
    }

    let encodedQuery = String(identifier.dropFirst(StatuteSpotlightBridge.itemPrefix.count))
    let query = encodedQuery.removingPercentEncoding ?? encodedQuery
    deliverStatuteSpotlightQuery(query)
    return true
  }

  private func deliverStatuteSpotlightQuery(_ query: String) {
    let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !normalizedQuery.isEmpty else {
      return
    }

    if statuteSpotlightBridgeReady, let statuteSpotlightChannel {
      statuteSpotlightChannel.invokeMethod(
        "openStatuteDatabase",
        arguments: ["query": normalizedQuery]
      )
    } else {
      pendingStatuteSpotlightQuery = normalizedQuery
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
          message: "Unable to open 緒言 Preamble App Group defaults.",
          details: TodayCaseWidgetBridge.appGroupIdentifier
        ))
        return
      }

      // 台灣繁體中文教學註解：
      // Widget extension 與主 App 只能透過 App Group 分享少量資料；
      // 這裡存 JSON 字串而不是 Flutter 物件，讓 SwiftUI Widget 能用 Foundation 直接解析。
      defaults.set(jsonString, forKey: TodayCaseWidgetBridge.payloadKey)

      if #available(iOS 14.0, *) {
        WidgetCenter.shared.reloadTimelines(ofKind: "緒言 PreambleTodayCaseWidget")
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

  private func updateTodoListWidget(arguments: Any?, result: FlutterResult) {
    guard let payload = arguments as? [String: Any] else {
      result(FlutterError(
        code: "invalid_payload",
        message: "Todo list widget payload must be a dictionary.",
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
          message: "Unable to open 緒言 Preamble App Group defaults.",
          details: TodayCaseWidgetBridge.appGroupIdentifier
        ))
        return
      }

      defaults.set(jsonString, forKey: TodoListWidgetBridge.payloadKey)

      if #available(iOS 14.0, *) {
        WidgetCenter.shared.reloadTimelines(ofKind: "緒言 PreambleTodoListWidget")
      }
      result(nil)
    } catch {
      result(FlutterError(
        code: "encode_failed",
        message: "Unable to encode todo list widget payload.",
        details: error.localizedDescription
      ))
    }
  }

  private func indexStatuteSpotlightItems(arguments: Any?, result: @escaping FlutterResult) {
    guard let payload = arguments as? [String: Any],
          let rawItems = payload["items"] as? [[String: Any]] else {
      result(FlutterError(
        code: "invalid_spotlight_payload",
        message: "Statute Spotlight payload must contain an items array.",
        details: nil
      ))
      return
    }

    let searchableItems = rawItems.compactMap(makeStatuteSearchableItem)
    guard !searchableItems.isEmpty else {
      result(nil)
      return
    }

    // 台灣繁體中文教學註解：
    // Core Spotlight 是 iOS 系統索引服務，Flutter 不直接呼叫；
    // Swift 只把 Dart 傳進來的法條摘要轉成 CSSearchableItem，不決定法條內容本身。
    CSSearchableIndex.default().indexSearchableItems(searchableItems) { error in
      DispatchQueue.main.async {
        if let error {
          result(FlutterError(
            code: "spotlight_index_failed",
            message: "Unable to index statute Spotlight items.",
            details: error.localizedDescription
          ))
          return
        }

        result(nil)
      }
    }
  }

  private func shareTipCard(arguments: Any?, result: @escaping FlutterResult) {
    guard let payload = arguments as? [String: Any],
          let title = stringValue(payload["title"]),
          let summary = stringValue(payload["summary"]) else {
      result(FlutterError(
        code: "invalid_share_payload",
        message: "Native share payload must contain title and summary.",
        details: nil
      ))
      return
    }

    let source = stringValue(payload["source"]) ?? "緒言 Preamble 生活避坑筆記"
    let image = makeTipCardImage(title: title, summary: summary, source: source)
    let activityController = UIActivityViewController(
      activityItems: [image, "\(title)\n\(summary)"],
      applicationActivities: nil
    )

    if let popover = activityController.popoverPresentationController,
       let rootView = window?.rootViewController?.view {
      popover.sourceView = rootView
      popover.sourceRect = CGRect(
        x: rootView.bounds.midX,
        y: rootView.bounds.midY,
        width: 1,
        height: 1
      )
      popover.permittedArrowDirections = []
    }

    DispatchQueue.main.async { [weak self] in
      guard let rootController = self?.topMostViewController() else {
        result(FlutterError(
          code: "no_presenter",
          message: "Unable to find a view controller for native share sheet.",
          details: nil
        ))
        return
      }

      rootController.present(activityController, animated: true) {
        result(nil)
      }
    }
  }

  private func shareText(arguments: Any?, result: @escaping FlutterResult) {
    guard let payload = arguments as? [String: Any],
          let text = stringValue(payload["text"]) else {
      result(FlutterError(
        code: "invalid_share_text_payload",
        message: "Native share payload must contain text.",
        details: nil
      ))
      return
    }

    let activityController = UIActivityViewController(
      activityItems: [text],
      applicationActivities: nil
    )

    if let popover = activityController.popoverPresentationController,
       let rootView = window?.rootViewController?.view {
      popover.sourceView = rootView
      popover.sourceRect = CGRect(
        x: rootView.bounds.midX,
        y: rootView.bounds.midY,
        width: 1,
        height: 1
      )
      popover.permittedArrowDirections = []
    }

    DispatchQueue.main.async { [weak self] in
      guard let rootController = self?.topMostViewController() else {
        result(FlutterError(
          code: "no_presenter",
          message: "Unable to find a view controller for native share sheet.",
          details: nil
        ))
        return
      }

      rootController.present(activityController, animated: true) {
        result(nil)
      }
    }
  }

  private func makeTipCardImage(title: String, summary: String, source: String) -> UIImage {
    let size = CGSize(width: 1080, height: 1350)
    let renderer = UIGraphicsImageRenderer(size: size)

    return renderer.image { context in
      let rect = CGRect(origin: .zero, size: size)
      // Background Morandi Warm Gray/Beige
      UIColor(red: 0.976, green: 0.957, blue: 0.925, alpha: 1).setFill()
      context.cgContext.fill(rect)

      // Card body white background
      let cardRect = CGRect(x: 86, y: 120, width: 908, height: 1110)
      let cardPath = UIBezierPath(roundedRect: cardRect, cornerRadius: 42)
      UIColor.white.setFill()
      cardPath.fill()

      UIColor(red: 0.925, green: 0.878, blue: 0.788, alpha: 1).setStroke()
      cardPath.lineWidth = 3
      cardPath.stroke()

      let ctx = context.cgContext

      // 1. Draw Preamble Stylized Balance Scale Logo Mark (Vector CGPath)
      let logoColor = UIColor(red: 0.106, green: 0.247, blue: 0.220, alpha: 1)
      ctx.setStrokeColor(logoColor.cgColor)
      ctx.setLineWidth(4.0)
      ctx.setLineCap(.round)

      // Stand column
      ctx.move(to: CGPoint(x: 160, y: 180))
      ctx.addLine(to: CGPoint(x: 160, y: 215))
      // Base
      ctx.move(to: CGPoint(x: 148, y: 215))
      ctx.addLine(to: CGPoint(x: 172, y: 215))
      // Main horizontal beam
      ctx.move(to: CGPoint(x: 135, y: 190))
      ctx.addLine(to: CGPoint(x: 185, y: 190))
      // Left pan hanger strings
      ctx.move(to: CGPoint(x: 135, y: 190))
      ctx.addLine(to: CGPoint(x: 135, y: 205))
      // Left pan
      ctx.move(to: CGPoint(x: 125, y: 205))
      ctx.addLine(to: CGPoint(x: 145, y: 205))
      // Right pan hanger strings
      ctx.move(to: CGPoint(x: 185, y: 190))
      ctx.addLine(to: CGPoint(x: 185, y: 205))
      // Right pan
      ctx.move(to: CGPoint(x: 175, y: 205))
      ctx.addLine(to: CGPoint(x: 195, y: 205))
      ctx.strokePath()

      // Header Preamble text branding
      drawText(
        "緒言 Preamble | 生活避坑指引",
        in: CGRect(x: 215, y: 178, width: 700, height: 60),
        font: UIFont.systemFont(ofSize: 32, weight: .heavy),
        color: logoColor
      )

      // Thin Top Divider line
      ctx.move(to: CGPoint(x: 140, y: 245))
      ctx.addLine(to: CGPoint(x: 940, y: 245))
      ctx.setStrokeColor(UIColor(red: 0.925, green: 0.878, blue: 0.788, alpha: 1).cgColor)
      ctx.setLineWidth(2.0)
      ctx.strokePath()

      // 2. Draw Tip Title (large bold)
      drawText(
        title,
        in: CGRect(x: 140, y: 285, width: 800, height: 220),
        font: UIFont.systemFont(ofSize: 56, weight: .black),
        color: UIColor(red: 0.067, green: 0.137, blue: 0.122, alpha: 1),
        lineSpacing: 10
      )

      // 3. Draw Tip Summary (middle paragraph)
      drawText(
        summary,
        in: CGRect(x: 140, y: 535, width: 800, height: 420),
        font: UIFont.systemFont(ofSize: 36, weight: .semibold),
        color: UIColor(red: 0.294, green: 0.333, blue: 0.392, alpha: 1),
        lineSpacing: 14
      )

      // Thin Bottom Divider line
      ctx.move(to: CGPoint(x: 140, y: 1010))
      ctx.addLine(to: CGPoint(x: 940, y: 1010))
      ctx.setStrokeColor(UIColor(red: 0.925, green: 0.878, blue: 0.788, alpha: 1).cgColor)
      ctx.setLineWidth(2.0)
      ctx.strokePath()

      // 4. Draw Footer Branding & Source
      drawText(
        "蒔光未來 • 普惠法律智慧認知介面",
        in: CGRect(x: 140, y: 1045, width: 500, height: 50),
        font: UIFont.systemFont(ofSize: 26, weight: .bold),
        color: UIColor(red: 0.36, green: 0.43, blue: 0.50, alpha: 1)
      )

      drawText(
        source,
        in: CGRect(x: 640, y: 1045, width: 300, height: 50),
        font: UIFont.systemFont(ofSize: 24, weight: .bold),
        color: logoColor,
        alignment: .right
      )
    }
  }

  private func drawText(
    _ text: String,
    in rect: CGRect,
    font: UIFont,
    color: UIColor,
    lineSpacing: CGFloat = 6,
    alignment: NSTextAlignment = .left
  ) {
    let paragraph = NSMutableParagraphStyle()
    paragraph.lineSpacing = lineSpacing
    paragraph.lineBreakMode = .byTruncatingTail
    paragraph.alignment = alignment

    let attributes: [NSAttributedString.Key: Any] = [
      .font: font,
      .foregroundColor: color,
      .paragraphStyle: paragraph
    ]

    text.draw(with: rect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: attributes, context: nil)
  }

  private func topMostViewController(
    from controller: UIViewController? = UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .first(where: { $0.isKeyWindow })?
      .rootViewController
  ) -> UIViewController? {
    if let navigationController = controller as? UINavigationController {
      return topMostViewController(from: navigationController.visibleViewController)
    }
    if let tabController = controller as? UITabBarController {
      return topMostViewController(from: tabController.selectedViewController)
    }
    if let presented = controller?.presentedViewController {
      return topMostViewController(from: presented)
    }
    return controller
  }

  private func makeStatuteSearchableItem(from rawItem: [String: Any]) -> CSSearchableItem? {
    guard let title = stringValue(rawItem["title"]),
          let query = stringValue(rawItem["query"]) else {
      return nil
    }

    let rawIdentifier = stringValue(rawItem["id"])
    let identifier = rawIdentifier?.hasPrefix(StatuteSpotlightBridge.itemPrefix) == true
      ? rawIdentifier!
      : StatuteSpotlightBridge.itemPrefix + encodedSpotlightQuery(query)

    let attributeSet = CSSearchableItemAttributeSet(itemContentType: "public.text")
    attributeSet.title = title
    attributeSet.displayName = title
    attributeSet.contentDescription = stringValue(rawItem["summary"])
    attributeSet.keywords = normalizedKeywords(from: rawItem, title: title, query: query)

    let item = CSSearchableItem(
      uniqueIdentifier: identifier,
      domainIdentifier: StatuteSpotlightBridge.domainIdentifier,
      attributeSet: attributeSet
    )
    item.expirationDate = Date.distantFuture
    return item
  }

  private func normalizedKeywords(
    from rawItem: [String: Any],
    title: String,
    query: String
  ) -> [String] {
    let rawKeywords = rawItem["keywords"] as? [Any] ?? []
    let keywords = rawKeywords.compactMap { stringValue($0) }
    let queryTokens = query
      .split(whereSeparator: { $0.isWhitespace })
      .map(String.init)
    return Array(Set(([title, query] + keywords + queryTokens).filter { !$0.isEmpty }))
      .sorted()
  }

  private func encodedSpotlightQuery(_ query: String) -> String {
    query.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? query
  }

  private func stringValue(_ value: Any?) -> String? {
    guard let value else {
      return nil
    }

    let text = "\(value)".trimmingCharacters(in: .whitespacesAndNewlines)
    return text.isEmpty ? nil : text
  }
}

// ==========================================
// 6. LIVE ACTIVITY ATTRIBUTES
// ==========================================

struct PreambleAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var status: String
        var countdownDays: Int
        var nextEvent: String
    }
    var caseTitle: String
}
