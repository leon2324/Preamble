# 緒言 Preamble Phase 5 Apple 生態系整合與 Widget 數據同步規格書

本規格書記錄 Siri 捷徑/Widget/Spotlight 統一路由中樞 (`IosIntentRouter`)、App Group UserDefaults 跨進程數據同步、CoreSpotlight 客製法條動態索引、以及 RFC 5545 iCalendar 行事曆同步之架構與測試規範。

---

## 1. 統一路由中樞 (`IosIntentRouter`)

### 1.1 設計架構
- **檔案**：`lib/platform/ios_intent_router.dart`
- **職責**：
  - 統籌 Siri 語音快問 (`IosQuickAskIntentBridge`)、Widget 點擊 Deep Link (`IosDeepLinkBridge`) 以及 CoreSpotlight 搜尋 (`IosStatuteSpotlightBridge`)。
  - 支援 **Cold Start (冷啟動)**：經由 `consumeInitialPrompt()`、`consumeInitialLink()` 與 `consumeInitialQuery()` 取得啟動意圖，在主 Shell 載入完成後一秒內完成導頁。
  - 支援 **Warm Start (熱啟動 / 背景喚醒)**：註冊 MethodChannel Handlers 即時接收事件並在現有 Navigator 樹上進行頁面推送。

### 1.2 導頁目的地映射表
| 觸發來源 | 傳入資料格式 | 導向頁面 | 攜帶參數 / 行為 |
| :--- | :--- | :--- | :--- |
| **Siri / App Intents** | `prompt` (String) | `LawAssistantChatPage` | 將 prompt 自動代入小法助對話框發起對話 |
| **Spotlight Search** | `query` (String) | `StatuteDetailPage` / 法規搜尋 | 自動查詢法條並開啟對應條文詳情 |
| **Widget Deep Link** | `preamble://today_case` | `KnowLawPage` / 判決故事卡 | 自動開啟判決故事閱讀 Modal |

---

## 2. WidgetKit & App Group 跨進程同步 (`group.com.vernalcollective.preamble`)

1. **App Group 共享 Storage**：`group.com.vernalcollective.preamble`
2. **自動寫入時機**：
   - 首頁加載每日判決故事時，自動呼叫 `IosTodayCaseWidgetBridge.syncDefaultStory()`。
   - 更新法律待辦事項時，呼叫 `IosTodayCaseWidgetBridge.syncTodoList(...)`。
3. **Widget 刷新觸發**：
   - 經由 iOS MethodChannel 呼叫原生 `WidgetCenter.shared.reloadAllTimelines()` 秒級更新桌面 Widget。

---

## 3. CoreSpotlight 動態索引機制 (`indexCustomStatute`)

1. **動態索引接口**：`IosStatuteSpotlightBridge.indexCustomStatute(StatuteItem statute)`
2. **索引資料結構**：
   - `id`: `preamble.statute.${statute.codeName}.${statute.articleNumber}`
   - `title`: `${statute.codeName} 第 ${statute.articleNumber} 條`
   - `summary`: `statute.articleText` 內文前 100 字摘要
   - `keywords`: 條文關鍵字與編號標籤
3. **跨平台極致降級**：
   - 捕捉 `MissingPluginException` 與 `PlatformException`，非 iOS 環境或無簽章證書時 100% 保持靜默且不拋出拋潰。

---

## 4. RFC 5545 iCalendar 行事曆與 Taptic Engine 回饋

1. **RFC 5545 iCalendar (.ics)**：
   - 標準 VCALENDAR / VEVENT 結構，編碼為 `data:text/calendar;charset=utf8,...` DATA URI。
   - 喚起原生 iOS 日曆對話框。
2. **Apple Taptic Engine 反饋**：
   - 使用 `HapticFeedback.vibrate()` (連續雙擊) 與 `HapticFeedback.selectionClick()` 賦予極致原生質感。
3. **法律免責聲明**：
   - 所有分享之圖卡文字與 Siri 帶入之回答均自動附帶 `lawAppLegalDisclaimer`。
