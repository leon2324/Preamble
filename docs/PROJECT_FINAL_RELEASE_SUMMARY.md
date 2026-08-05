# 緒言 Preamble 專案最終健康審查與發行總結報告 (Project Health Audit & Final Release Summary)

本報告為 **Preamble 緒言** 法律科技應用程式由 Phase 2 至 Phase 5 全階段重構歷程、技術拓樸架構、測試品質門檻（Quality Gate）、安全性規範與 TestFlight 發行準備之最終總結文件。

---

## 1. 專案基本概況與技術架構

### 1.1 技術棧 (Tech Stack)
- **前端框架**：Flutter (SDK `^3.5.2`) / Dart (`^3.5.0`)
- **UI & 響應式佈局**：`flutter_screenutil` (`375x812` 設計稿基準), Vanilla Flutter Widgets, Canvas2D, SVG (`flutter_svg`)
- **設計系統**：Preamble 莫蘭迪主色調 (`#2C5E43` 莫蘭迪綠, `#17231F` 深炭灰, `#F5F8F6` 紙質感 Surface)
- **狀態管理與層級架構**：`ChangeNotifier` + `ListenableBuilder` 搭配嚴格**三層單向資料流 (UI ➔ Repository ➔ Data/API Service)**
- **PDF 渲染與列印**：`pdf` + `printing` 套件，內建思源宋體與黑體繁中字型檔 (`SourceHanSerifTW-VF.ttf`, `SourceHanSansTW-VF.ttf`)
- **本機快取與持久化**：`SharedPreferences` + 本機 SQLite (sqflite)

### 1.2 零第三方 API Key 安全防線 (Zero Client Key Security Guard)
- **原則**：Flutter 前端嚴禁儲存或使用任何 OpenAI、Gemini 或其他 LLM Provider API Key。
- **架構**：所有 AI 提問與 Prompt 組合一律由後端 REST API 代理，前端僅透過帶有 JWT Token 的 REST/SSE 介面通訊，徹底隔離安全風險。

---

## 2. Phase 2 ~ Phase 5 重構里程碑全景回顧

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     Preamble 緒言 Architecture                          │
├─────────────────┬─────────────────┬─────────────────┬──────────────────┤
│     Phase 2     │     Phase 3     │     Phase 4     │     Phase 5      │
│  Backend API    │  AI Streaming   │  Document PDF   │  Apple Ecosystem │
│  & Fallback     │  & Citation     │  & Local Sync   │  & Widget Hub    │
└────────┬────────┴────────┬────────┴────────┬────────┴─────────┬────────┘
         │                 │                 │                  │
         ▼                 ▼                 ▼                  ▼
 ┌───────────────┐ ┌───────────────┐ ┌───────────────┐ ┌────────────────┐
 │AuthHttpClient │ │SSE Streaming  │ │5 Templates    │ │IosIntentRouter │
 │401 Refresh    │ │30ms Typewriter│ │Local Drafts   │ │App Group Sync  │
 │Offline Cache  │ │Inline Citation│ │PdfStyleBuilder│ │Spotlight Index │
 └───────────────┘ └───────────────┘ └───────────────┘ └────────────────┘
```

### Phase 2：後端 API 完整串接與平滑降級
- **Auth 401 Interceptor**：實作 `AuthHttpClient`，遭遇 401 Unauthorized 時自動發起 `POST /auth/refresh` 靜默刷新 JWT Token 並自動重試原請求。
- **4 大 API 服務與 Fallback Repository**：`CaseApiService`、`SearchApiService`、`OfficialFeedApiService`、`QuotaApiService`。當未設定 `PREAMBLE_API_BASE_URL` 或網路異常時，自動降級至離線本機快取，UI 瀏覽不卡死。

### Phase 3：小法助 AI 流式傳輸與法條引用重構
- **SSE Stream 逐字渲染**：`LawAssistantApiService.sendMessageStream` 解析 `data:` 串流，結合 `LawAssistantStreamChunk` 模型實作打字機漸進效果；離線模式下提供 30ms 逐字對話模擬。
- **`InlineCitationParser`**：利用 RegExp 正則表達式自動辨識 `[民法第 184 條]` 等法條標籤，渲染為可點擊之 `StatuteTagChip`，點擊即時發起查詢並跳轉至 `StatuteDetailPage`。

### Phase 4：法律文件工具箱與高質感 PDF 產出
- **5 大生活模板**：存證信函、租屋押金、車禍和解、消費申訴、勞資爭議。
- **`SharedPreferences` 持久化與離線同步**：離線新建草稿自動寫入本機，當連線恢復時發起背景自動同步至 `/documents/drafts`。
- **`PdfStyleBuilder` 繪製引擎**：套用莫蘭迪墨綠與深炭灰雙主題，內建思源繁中字型、雙欄點陣卡片、簽名/蓋印落款區域 (`pw.Container`) 與頁尾免責聲明。

### Phase 5：Apple 生態系整合與 iOS 17+ Widget 同步
- **`IosIntentRouter` 統一路由中樞**：集中處理 Siri Intents 語音快問 (`openQuickAsk`)、Widget 點擊 Deep Link (`openDeepLink`) 與 CoreSpotlight 下拉搜尋 (`openStatuteDatabase`)，支援 Cold Start 與 Warm Start 頁面秒級跳轉。
- **App Group & Spotlight 動態寫入**：於 `group.com.vernalcollective.preamble` 寫入每日判決故事，並發起 `WidgetCenter.shared.reloadAllTimelines()`；提供 `indexCustomStatute` 將使用者瀏覽條文寫入 CoreSpotlight 索引。
- **行事曆與 Taptic Engine**：`CalendarSyncService` 生成 RFC 5545 iCalendar `.ics` DATA URI 喚起 iOS 日曆，搭配 `HapticFeedback.vibrate()` 震動反饋。

---

## 3. 靜態分析與測試品質門檻 (Quality Gate)

### 3.1 靜態分析 (Static Analysis)
- 執行指令：`/Users/babychen/Documents/flutter/bin/flutter analyze lib test`
- 分析結果：**0 Errors, 0 Warnings** 潔淨狀態。

### 3.2 單元與 UI 測試涵蓋 (Test Suite Coverage)
所有新增與重構模組均包含獨立測試檔案，單元測試執行結果（**All Tests Passed**）：

| 測試檔案 | 涵蓋模組與測試項目 | 測試結果 |
| :--- | :--- | :---: |
| `test/backend_api_services_test.dart` | Auth 401 Interceptor、Token 刷新、Case/Search/Quota API 降級 | PASS |
| `test/law_assistant_streaming_test.dart` | SSE Line Splitter 解碼、30ms 離線打字機、Inline Citation Parser Chip 渲染 | PASS |
| `test/document_tools_pdf_test.dart` | SharedPreferences 草稿持久化、Form Stepper 視覺與 QuickFill、PdfStyleBuilder %PDF- | PASS |
| `test/apple_ecosystem_test.dart` | IosIntentRouter 傳參解碼、MissingPluginException 降級防護、RFC 5545 iCalendar URI | PASS |

---

## 4. 安全防線與合規聲明

1. **零金鑰原則 (No Client Keys)**：前端程式碼與資源檔中完全無任何 AI 金鑰、資料庫密碼或私鑰。
2. **法律免責聲明覆蓋率 (Mandatory Legal Disclaimer Coverage)**：
   - AI 對話回答、PDF 匯出文件、原生分享卡片與 Siri 帶入文字，均完整包含 `lawAppLegalDisclaimer` 提醒：
     > 「法律提醒：本文件與內容僅供學習與資訊整理參考，不構成法律意見。如涉及實際個案，請諮詢合格律師或相關專業人士。」

---

## 5. 發行準備檢核表 (Production Release Checklist)

- [x] **iOS `Info.plist` 權限描述備齊**：包含 Calendar / Reminders scheme 與 App Group Entitlements (`group.com.vernalcollective.preamble`)。
- [x] **環境變數切換**：正式環境可透過 `--dart-define=PREAMBLE_API_BASE_URL=https://api.preamble.app` 啟動線上後端，未設定時自動切換至優質本機快取模式。
- [x] **發行打包編譯命令**：
  ```bash
  /Users/babychen/Documents/flutter/bin/flutter build ipa --release \
    --dart-define=PREAMBLE_API_BASE_URL=https://api.preamble.app
  ```
