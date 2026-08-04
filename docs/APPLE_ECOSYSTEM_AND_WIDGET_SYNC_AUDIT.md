# 緒言 Preamble 方向三：Apple 生態系整合與 iOS 17+ Widget 數據同步現況盤點與架構審查報告

本報告為 Preamble（緒言）法律科技 App 於 iOS 生態系整合、iOS 17+ WidgetKit 數據同步、Siri App Intents 語音快問、Core Spotlight 全系統法規搜尋、Core Graphics 原生天平圖卡渲染與 iOS 行事曆/提醒事項同步之現況盤點與深度架構審查報告。

---

## 1. 執行摘要 (Executive Summary)

Preamble 前端採用 Flutter 跨平台架構，在 Apple 生態系整合上遵循「**極致原生體感 (Native Feeling)**」與「**平滑退退備援 (Graceful Fallback)**」原則。由於 WidgetKit Extension 與 CoreSpotlight 無法直接存取 Dart Runtime 或 Flutter 記憶體，專案於 `lib/platform/` 目錄建立了一套健全的原生 Channel 橋接層，將數據資料寫入 Apple 原生 IPC (Inter-Process Communication) 與 App Group 共享記憶體中。

### 核心盤點結論：
1. **iOS 17+ WidgetKit & App Group**：已建立 `IosTodayCaseWidgetBridge`，經由 MethodChannel (`preamble/today_case_widget`) 寫入 App Group 共享 storage (`group.com.vernalcollective.preamble`)，支援「每日判決故事」與「今日法律待辦」小工具。
2. **Siri Shortcuts & App Intents 語音入口**：已建立 `IosQuickAskIntentBridge`，經由 `preamble/quick_ask_intent` Channel 接收 Siri/捷徑輸入之 Prompt，並無縫切換至小法助對話頁面。
3. **Core Spotlight 系統級法規搜尋**：已建立 `IosStatuteSpotlightBridge`，將民法第 184 條、421 條、勞基法 24 條、消保法 19 條、刑法 339 條等核心種子法條寫入 Core Spotlight 索引，點擊可直接喚醒 App 法規資料庫。
4. **原生圖卡與 Calendar/Reminders 同步**：已實作 `NativeShareBridge`（呼叫原生分享面板）與 `CalendarSyncService`（利用 RFC 5545 iCalendar `.ics` DATA URI 直接拉起 iOS 原生行事曆，並觸發 Apple Taptic Engine 雙重震動）。

---

## 2. 核心模組盤點與實作現況分析

### 2.1 iOS 17+ WidgetBundle & App Group 同步機制
- **相關檔案**：
  - Flutter 橋接層：[`lib/platform/ios_today_case_widget_bridge.dart`](file:///Users/babychen/Dropbox/Baby%20Mac/python/lawapp/lib/platform/ios_today_case_widget_bridge.dart)
  - iOS 原生 Widget：`ios/Runner/PreambleTodayCaseWidget.swift` (App Group: `group.com.vernalcollective.preamble`)
- **實作架構**：
  - `syncDefaultStory()`：打包 `badge`（每日精選）、`title`（罵人「毒瘤」算侮辱嗎？）、`summary`、`category`、`prompt` 與 `dateLabel`（MM/dd）。
  - `syncTodoList(List<String> tasks)`：打包法律待辦事項。
  - **跨進程同步流程**：
    ```
    Flutter App (HomePage) ➔ MethodChannel('preamble/today_case_widget')
       ➔ iOS AppDelegate / Plugin ➔ UserDefaults(suiteName: "group.com.vernalcollective.preamble")
       ➔ WidgetCenter.shared.reloadAllTimelines() ➔ Today Case Widget 視覺更新
    ```
- **極致平滑降級 (Fallback)**：
  - 補捉 `MissingPluginException` (Web / Android / 測試環境) 與 `PlatformException` (App Group 未在 Xcode 簽章設定完成時)，確保不會中斷 App 正常啟動。

### 2.2 Siri Shortcuts & App Intents 語音重定向
- **相關檔案**：
  - [`lib/platform/ios_quick_ask_intent_bridge.dart`](file:///Users/babychen/Dropbox/Baby%20Mac/python/lawapp/lib/platform/ios_quick_ask_intent_bridge.dart)
  - [`lib/platform/ios_deep_link_bridge.dart`](file:///Users/babychen/Dropbox/Baby%20Mac/python/lawapp/lib/platform/ios_deep_link_bridge.dart)
- **實作架構**：
  - 提供 `registerPromptHandler((prompt) { ... })` 監聽 MethodChannel (`preamble/quick_ask_intent`) 之 `openQuickAsk` 事件。
  - 提供 `consumeInitialPrompt()` 處理 App 處於 Cold Start（冷啟動）時 Siri 傳入之文字 Prompt。
  - 支援 Deep Link 格式：`preamble://quick_ask?prompt=...` 或 Siri Intent 物件傳參解析。

### 2.3 iOS Core Spotlight 系統級搜尋索引
- **相關檔案**：
  - [`lib/platform/ios_statute_spotlight_bridge.dart`](file:///Users/babychen/Dropbox/Baby%20Mac/python/lawapp/lib/platform/ios_statute_spotlight_bridge.dart)
- **實作架構**：
  - `syncDefaultIndex()`：透過 `preamble/statute_spotlight` Channel 將熱門常用法條（民法 184 侵權行為、421 租賃、勞基法 24 加班費、消保法 19 七日鑑賞期、刑法 339 詐欺罪）寫入 `CSSearchableItem`。
  - `registerQueryHandler` & `consumeInitialQuery`：當使用者從 iPhone 桌面下拉 Spotlight 搜尋「民法 184」並點擊搜尋結果時，系統傳送 `openStatuteDatabase` 事件帶入 `query`，App 自動跳轉至法規資料庫搜尋頁。

### 2.4 原生天平圖卡渲染與 iOS 行事曆/提醒事項同步
- **相關檔案**：
  - [`lib/platform/native_share_bridge.dart`](file:///Users/babychen/Dropbox/Baby%20Mac/python/lawapp/lib/platform/native_share_bridge.dart)
  - [`lib/platform/calendar_sync_service.dart`](file:///Users/babychen/Dropbox/Baby%20Mac/python/lawapp/lib/platform/calendar_sync_service.dart)
- **實作架構**：
  - **`NativeShareBridge`**：提供 `shareText` 與 `shareTipCard`，喚起 iOS 原生 `UIActivityViewController` 面板，支援天平標章卡片與法律短評分享。
  - **`CalendarSyncService` (RFC 5545 iCalendar & Taptic Feedback)**：
    - `syncToCalendar`：使用純 Dart 建立符合 RFC 5545 規範之 `BEGIN:VCALENDAR ... END:VCALENDAR` 檔案內容，編碼為 `data:text/calendar;charset=utf8,...` URI，經由 `url_launcher` 直接拉起 iOS 原生行事曆編輯視窗。
    - 觸發 **Apple Taptic Engine** 兩次連續震動 (`HapticFeedback.vibrate()`)，給予使用者最真實的原生操作回饋。若平台不支援 Data URI，亦自動降級至網頁版 Google Calendar 視窗。
    - `syncToReminders`：發起 `x-apple-reminder://` Scheme 並配合 `HapticFeedback.selectionClick()`。

---

## 3. 架構缺口與 Phase 5 重構建議

| 模組區塊 | 目前狀況 | 發現之架構缺口 | Phase 5 重構計畫與建議 |
| :--- | :--- | :--- | :--- |
| **WidgetKit 同步** | 已實作靜態範例同步 | 缺乏當使用者切換首頁「每日判決故事」或新增個人法規收藏時的即時廣播通知。 | 於 `StatuteRepository` 與 `AppProvider` 加入 `IosTodayCaseWidgetBridge.syncDefaultStory()` 自動觸發點。 |
| **Siri Intents 路由** | 已實作 Channel 監聽 | 尚需在 `main.dart` 頂層 Widget 生命週期中綁定 `registerPromptHandler` 並自動導頁至 `LawAssistantChatPage`。 | 建立 `IosIntentRouter` 統一處理 `openQuickAsk` 與 `openDeepLink` 導頁邏輯。 |
| **Spotlight 廣播** | 僅預設 6 筆種子法條 | 未能將使用者最新搜尋之客製化法條動態寫入 Spotlight 索引。 | 新增 `indexCustomStatute(StatuteItem item)` 動態寫入 Spotlight。 |
| **圖卡渲染引擎** | 僅文字分享 | 尚未在 iOS 原生端使用 Core Graphics 繪製高品質天平水印與莫蘭迪視覺分享卡片。 | 擴充 iOS 原生 Plugin 實作 `shareTipCard` 之 Core Graphics `UIGraphicsImageRenderer` 圖卡生成。 |

---

## 4. Phase 5 執行 roadmap 預覽

1. **`lib/platform/ios_intent_router.dart` [NEW]**：統一管理 Siri Intents、Widget Deep Link 與 Spotlight 搜尋跳轉。
2. **`lib/app/app_state.dart` [MODIFY]**：於初始化與狀態變更時調用 `IosTodayCaseWidgetBridge.syncDefaultStory()` 與 Spotlight 動態索引。
3. **`test/apple_ecosystem_test.dart` [NEW]**：建立針對 Apple 生態系 Channel 橋接器與 iCalendar RFC 5545 格式解構之單元與 Widget 測試 suite。
