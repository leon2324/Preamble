import SwiftUI
import WidgetKit

private enum TodayCaseWidgetStore {
  static let appGroupIdentifier = "group.com.leonchen.lawapp.dev1"
  static let payloadKey = "today_case_widget_payload"

  // 台灣繁體中文教學註解：
  // Widget 可能在主 App 尚未啟動前就被系統要求產生畫面，因此一定要準備 fallback。
  // Demo 或 TestFlight 初次安裝時，即使 App Group 還沒有資料，也能呈現穩定的「今日判決故事」入口。
  static let fallback = TodayCaseWidgetPayload(
    badge: "每日精選",
    title: "罵人「毒瘤」算侮辱嗎？",
    summary: "公開平台上的貶損用語，可能構成公然侮辱；先看白話整理再判斷下一步。",
    category: "今日判決故事",
    dateLabel: TodayCaseWidgetPayload.defaultDateLabel
  )

  static func loadPayload() -> TodayCaseWidgetPayload {
    // 台灣繁體中文教學註解：
    // WidgetKit extension 不能直接讀 Flutter 狀態；這裡只從 App Group UserDefaults 讀 JSON。
    // 這個限制反而讓架構更清楚：Flutter 提供資料，iOS 原生層負責系統入口與渲染。
    guard
      let defaults = UserDefaults(suiteName: appGroupIdentifier),
      let jsonString = defaults.string(forKey: payloadKey),
      let data = jsonString.data(using: .utf8),
      let payload = try? JSONDecoder().decode(TodayCaseWidgetPayload.self, from: data)
    else {
      return fallback
    }
    return payload
  }
}

private struct TodayCaseWidgetPayload: Decodable {
  // 台灣繁體中文教學註解：
  // payload 欄位刻意保持短小，因為 Widget 是一眼掃描的入口，不適合承載完整文章。
  // 真正的長內容仍回到 Flutter App 內呈現，Widget 只負責帶出 MAIC Demo 的 Apple 原生入口。
  let badge: String
  let title: String
  let summary: String
  let category: String
  let dateLabel: String

  static var defaultDateLabel: String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "zh_TW")
    formatter.dateFormat = "MM/dd"
    return formatter.string(from: Date())
  }
}

private struct TodayCaseEntry: TimelineEntry {
  let date: Date
  let payload: TodayCaseWidgetPayload
}

private struct TodayCaseProvider: TimelineProvider {
  // 台灣繁體中文教學註解：
  // TimelineProvider 是 WidgetKit 的資料排程器；系統會依照時間線決定何時重畫 Widget。
  // 目前每 2 小時刷新一次，足夠支援每日判決故事，未來接 API 後可改成依內容更新時間刷新。
  func placeholder(in context: Context) -> TodayCaseEntry {
    TodayCaseEntry(date: Date(), payload: TodayCaseWidgetStore.fallback)
  }

  func getSnapshot(in context: Context, completion: @escaping (TodayCaseEntry) -> Void) {
    completion(TodayCaseEntry(date: Date(), payload: TodayCaseWidgetStore.loadPayload()))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<TodayCaseEntry>) -> Void) {
    let entry = TodayCaseEntry(date: Date(), payload: TodayCaseWidgetStore.loadPayload())
    let refreshDate = Calendar.current.date(byAdding: .hour, value: 2, to: Date()) ?? Date()
    completion(Timeline(entries: [entry], policy: .after(refreshDate)))
  }
}

private struct TodayCaseWidgetView: View {
  // 台灣繁體中文教學註解：
  // Widget 畫面用 SwiftUI 原生實作，不是 Flutter 截圖或 WebView；
  // 評審看到的是 iOS 系統級入口，這比單純把 App UI 做得像 Apple 更有架構說服力。
  @Environment(\.widgetFamily) private var family
  let entry: TodayCaseEntry

  var body: some View {
    ZStack {
      background
      VStack(alignment: .leading, spacing: family == .systemSmall ? 7 : 10) {
        header
        Text(entry.payload.title)
          .font(.system(size: family == .systemSmall ? 15 : 18, weight: .heavy))
          .foregroundColor(Color(red: 0.08, green: 0.14, blue: 0.18))
          .lineLimit(family == .systemSmall ? 2 : 1)
          .minimumScaleFactor(0.85)

        Text(entry.payload.summary)
          .font(.system(size: family == .systemSmall ? 11 : 13, weight: .semibold))
          .foregroundColor(Color(red: 0.36, green: 0.43, blue: 0.50))
          .lineLimit(family == .systemSmall ? 3 : 2)
          .minimumScaleFactor(0.82)

        Spacer(minLength: 0)
        footer
      }
      .padding(family == .systemSmall ? 14 : 18)
    }
    .widgetURL(URL(string: "lawapp://today-case"))
  }

  private var background: some View {
    LinearGradient(
      colors: [
        Color(red: 0.99, green: 0.97, blue: 0.93),
        Color(red: 0.91, green: 0.97, blue: 0.93)
      ],
      startPoint: .topLeading,
      endPoint: .bottomTrailing
    )
  }

  private var header: some View {
    HStack(spacing: 6) {
      Text(entry.payload.badge)
        .font(.system(size: 10, weight: .heavy))
        .foregroundColor(Color(red: 0.76, green: 0.22, blue: 0.20))
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(red: 0.98, green: 0.86, blue: 0.84))
        .clipShape(Capsule())

      Spacer(minLength: 4)

      Text(entry.payload.dateLabel)
        .font(.system(size: 10, weight: .bold))
        .foregroundColor(Color(red: 0.34, green: 0.49, blue: 0.42))
    }
  }

  private var footer: some View {
    HStack(spacing: 6) {
      Image(systemName: "scale.3d")
        .font(.system(size: 12, weight: .bold))
        .foregroundColor(Color(red: 0.13, green: 0.37, blue: 0.28))

      Text(entry.payload.category)
        .font(.system(size: 11, weight: .heavy))
        .foregroundColor(Color(red: 0.13, green: 0.37, blue: 0.28))

      Spacer(minLength: 0)

      Image(systemName: "chevron.right")
        .font(.system(size: 11, weight: .heavy))
        .foregroundColor(Color(red: 0.13, green: 0.37, blue: 0.28))
    }
  }
}

@main
struct LawAppTodayCaseWidget: Widget {
  // 台灣繁體中文教學註解：
  // kind 必須和 AppDelegate reloadTimelines(ofKind:) 完全一致；
  // 這是主 App 通知 WidgetKit 重新讀取 App Group payload 的識別名稱。
  let kind = "LawAppTodayCaseWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: TodayCaseProvider()) { entry in
      TodayCaseWidgetView(entry: entry)
    }
    .configurationDisplayName("LawApp 今日判決")
    .description("每天用白話整理一則值得理解的台灣法律故事。")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}
