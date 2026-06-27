import SwiftUI
import WidgetKit

// ==========================================
// SHARED UTILITIES & MODIFIERS
// ==========================================

extension View {
    func adoptContainerBackground() -> some View {
        if #available(iOS 17.0, *) {
            return self.containerBackground(for: .widget) {
                Color.clear
            }
        } else {
            return self
        }
    }
}

// ==========================================
// 1. WIDGET BUNDLE (ENTRY POINT)
// ==========================================

@main
struct PreambleWidgetBundle: WidgetBundle {
    var body: some Widget {
        PreambleTodayCaseWidget()
        PreambleTodoListWidget()
        PreambleShortcutsWidget()
    }
}

// ==========================================
// 2. WIDGET 1: TODAY'S CASE STORY (今日判決故事)
// ==========================================

private enum TodayCaseWidgetStore {
  static let appGroupIdentifier = "group.com.vernalcollective.preamble"
  static let payloadKey = "today_case_widget_payload"

  static let fallback = TodayCaseWidgetPayload(
    badge: "每日精選",
    title: "罵人「毒瘤」算侮辱嗎？",
    summary: "公開平台上的貶損用語，可能構成公然侮辱；先看白話整理再判斷下一步。",
    category: "今日判決故事",
    dateLabel: TodayCaseWidgetPayload.defaultDateLabel
  )

  static func loadPayload() -> TodayCaseWidgetPayload {
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
    .widgetURL(URL(string: "preamble://today-case"))
    .adoptContainerBackground()
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

struct PreambleTodayCaseWidget: Widget {
  let kind = "緒言 PreambleTodayCaseWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: TodayCaseProvider()) { entry in
      TodayCaseWidgetView(entry: entry)
    }
    .configurationDisplayName("緒言 Preamble 今日判決")
    .description("每天用白話整理一則值得理解的台灣法律故事。")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}

// ==========================================
// 3. WIDGET 2: TODO LIST CHECKLIST (今日待辦清單)
// ==========================================

private enum TodoListWidgetStore {
  static let appGroupIdentifier = "group.com.vernalcollective.preamble"
  static let payloadKey = "todo_list_widget_payload"

  static let fallback = TodoListWidgetPayload(
    title: "今日法律待辦",
    tasks: ["與律師確認起訴狀內容", "準備本案相關證物影本", "至司法院網站查詢期日"],
    dateLabel: TodoListWidgetPayload.defaultDateLabel
  )

  static func loadPayload() -> TodoListWidgetPayload {
    guard
      let defaults = UserDefaults(suiteName: appGroupIdentifier),
      let jsonString = defaults.string(forKey: payloadKey),
      let data = jsonString.data(using: .utf8),
      let payload = try? JSONDecoder().decode(TodoListWidgetPayload.self, from: data)
    else {
      return fallback
    }
    return payload
  }
}

private struct TodoListWidgetPayload: Decodable {
  let title: String
  let tasks: [String]
  let dateLabel: String

  static var defaultDateLabel: String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "zh_TW")
    formatter.dateFormat = "MM/dd"
    return formatter.string(from: Date())
  }
}

private struct TodoListEntry: TimelineEntry {
  let date: Date
  let payload: TodoListWidgetPayload
}

private struct TodoListProvider: TimelineProvider {
  func placeholder(in context: Context) -> TodoListEntry {
    TodoListEntry(date: Date(), payload: TodoListWidgetStore.fallback)
  }

  func getSnapshot(in context: Context, completion: @escaping (TodoListEntry) -> Void) {
    completion(TodoListEntry(date: Date(), payload: TodoListWidgetStore.loadPayload()))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<TodoListEntry>) -> Void) {
    let entry = TodoListEntry(date: Date(), payload: TodoListWidgetStore.loadPayload())
    let refreshDate = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
    completion(Timeline(entries: [entry], policy: .after(refreshDate)))
  }
}

private struct TodoListWidgetView: View {
  @Environment(\.widgetFamily) private var family
  let entry: TodoListEntry

  var body: some View {
    ZStack {
      background
      VStack(alignment: .leading, spacing: 8) {
        header
        
        VStack(alignment: .leading, spacing: 6) {
          ForEach(0..<min(entry.payload.tasks.count, 3), id: \.self) { index in
            HStack(alignment: .top, spacing: 6) {
              Image(systemName: "square")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(Color(red: 0.13, green: 0.37, blue: 0.28))
                .padding(.top, 2)
              Text(entry.payload.tasks[index])
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color(red: 0.08, green: 0.14, blue: 0.18))
                .lineLimit(1)
            }
          }
          if entry.payload.tasks.isEmpty {
            Text("今日無待辦事項，點擊安排！")
              .font(.system(size: 12, weight: .medium))
              .foregroundColor(Color(red: 0.36, green: 0.43, blue: 0.50))
              .padding(.top, 4)
          }
        }
        
        Spacer(minLength: 0)
        footer
      }
      .padding(14)
    }
    .widgetURL(URL(string: "preamble://todo-list"))
    .adoptContainerBackground()
  }

  private var background: some View {
    LinearGradient(
      colors: [
        Color(red: 0.98, green: 0.98, blue: 0.98),
        Color(red: 0.92, green: 0.95, blue: 0.96)
      ],
      startPoint: .topLeading,
      endPoint: .bottomTrailing
    )
  }

  private var header: some View {
    HStack {
      Text(entry.payload.title)
        .font(.system(size: 12, weight: .heavy))
        .foregroundColor(Color(red: 0.13, green: 0.37, blue: 0.28))
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(red: 0.88, green: 0.94, blue: 0.92))
        .clipShape(Capsule())

      Spacer()

      Text(entry.payload.dateLabel)
        .font(.system(size: 10, weight: .bold))
        .foregroundColor(Color(red: 0.36, green: 0.43, blue: 0.50))
    }
  }

  private var footer: some View {
    HStack {
      Label("案件待辦", systemImage: "checkmark.circle.fill")
        .font(.system(size: 10, weight: .heavy))
        .foregroundColor(Color(red: 0.13, green: 0.37, blue: 0.28))
      Spacer()
    }
  }
}

struct PreambleTodoListWidget: Widget {
  let kind = "緒言 PreambleTodoListWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: TodoListProvider()) { entry in
      TodoListWidgetView(entry: entry)
    }
    .configurationDisplayName("緒言 Preamble 待辦清單")
    .description("在桌面上追蹤您的訴訟或法律程序待辦事項。")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}

// ==========================================
// 4. WIDGET 3: SHORTCUTS GRID (首頁快捷入口)
// ==========================================

private struct ShortcutsEntry: TimelineEntry {
  let date: Date
}

private struct ShortcutsProvider: TimelineProvider {
  func placeholder(in context: Context) -> ShortcutsEntry {
    ShortcutsEntry(date: Date())
  }

  func getSnapshot(in context: Context, completion: @escaping (ShortcutsEntry) -> Void) {
    completion(ShortcutsEntry(date: Date()))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<ShortcutsEntry>) -> Void) {
    completion(Timeline(entries: [ShortcutsEntry(date: Date())], policy: .never))
  }
}

private struct ShortcutsWidgetView: View {
  var body: some View {
    ZStack {
      background
      VStack(alignment: .leading, spacing: 8) {
        HStack {
          Text("緒言 Preamble 快捷功能")
            .font(.system(size: 12, weight: .heavy))
            .foregroundColor(Color(red: 0.13, green: 0.37, blue: 0.28))
          Spacer()
          Image(systemName: "bolt.fill")
            .font(.system(size: 11))
            .foregroundColor(Color(red: 0.76, green: 0.52, blue: 0.12))
        }
        
        Spacer(minLength: 0)
        
        HStack(spacing: 8) {
          Link(destination: URL(string: "preamble://time-machine")!) {
            shortcutItem(title: "時光機", icon: "clock.arrow.2.circlepath")
          }
          Link(destination: URL(string: "preamble://chat")!) {
            shortcutItem(title: "AI諮詢", icon: "bubble.left.and.bubble.right.fill")
          }
          Link(destination: URL(string: "preamble://tips")!) {
            shortcutItem(title: "生活避坑", icon: "shield.fill")
          }
          Link(destination: URL(string: "preamble://vocabulary")!) {
            shortcutItem(title: "法律詞彙", icon: "character.book.closed.fill")
          }
        }
        
        Spacer(minLength: 0)
      }
      .padding(16)
    }
    .adoptContainerBackground()
  }

  private var background: some View {
    LinearGradient(
      colors: [
        Color(red: 0.99, green: 0.98, blue: 0.96),
        Color(red: 0.96, green: 0.93, blue: 0.88)
      ],
      startPoint: .topLeading,
      endPoint: .bottomTrailing
    )
  }

  private func shortcutItem(title: String, icon: String) -> some View {
    VStack(spacing: 6) {
      Image(systemName: icon)
        .font(.system(size: 18))
        .foregroundColor(Color(red: 0.13, green: 0.37, blue: 0.28))
      Text(title)
        .font(.system(size: 11, weight: .heavy))
        .foregroundColor(Color(red: 0.08, green: 0.14, blue: 0.18))
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 10)
    .background(Color.white.opacity(0.85))
    .cornerRadius(10)
    .overlay(
      RoundedRectangle(cornerRadius: 10)
        .stroke(Color(red: 0.13, green: 0.37, blue: 0.28).opacity(0.12), lineWidth: 0.8)
    )
  }
}

struct PreambleShortcutsWidget: Widget {
  let kind = "緒言 PreambleShortcutsWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: ShortcutsProvider()) { entry in
      ShortcutsWidgetView()
    }
    .configurationDisplayName("緒言 Preamble 快捷功能")
    .description("一鍵快速啟動法律時光機、AI 諮詢等熱門功能。")
    .supportedFamilies([.systemMedium])
  }
}
