# 緒言 Preamble 方向一：小法助 AI 對話流式傳輸 (Streaming) 與法條引用 (Citation) 架構審查報告

> **審查日期**：2026 年 8 月  
> **目標模組**：小法助 AI 對話系統 (`LawAssistantApiService`, `LawAssistantRepository`, `LawAssistantChatPage`, `SourceCitationList`)  
> **審查結論**：目前小法助具備完整的一次性 JSON 請求、結構化 Citation 模型與免責聲明防線，但網路層尚無 SSE/ByteStream 串流介面，UI 層缺乏逐字打字機渲染與互動式法條跳轉卡片。本報告提供完整的現況盤點與 Phase 3 重構規格。

---

## 一、 現有 API 與網路層現況 (API & Network Layer)

### 1.1 `LawAssistantApiService` 現有實作盤點
*   **傳輸模式**：採用 `http.Client.post` 與 `http.Client.get` 進行一次性 HTTP Request/Response 通訊。
*   **資料解析**：透過 `jsonDecode(utf8.decode(response.bodyBytes))` 一次性讀取整份 JSON 檔案並轉換為 `LawAssistantConversation`。
*   **流式傳輸 (Streaming) 缺口**：
    *   目前 `createConversation` 與 `sendMessage` 均回傳 `Future<LawAssistantConversation>`。
    *   尚未封裝 `http.StreamedRequest`、`http.ByteStream` 或 SSE (`text/event-stream`) 傳輸介面。
    *   無 Chunk 邊解碼邊更新的 Stream 事件流。

### 1.2 `LawAssistantRepository` 現有架構盤點
*   **Mock / Real 雙軌切換**：`isBackendConfigured` 為 `true` 時呼叫 `LawAssistantApiService`；為 `false` 時回退至本機 `_mockConversation`。
*   **同步型回覆產生**：`sendMessage` 呼叫後須等待整個 `Future` 完成，才會一次性將 `LawAssistantMessage` 追加至消息陣列。

```
[ Current Request Flow ]
User Action ──► LawAssistantRepository ──► LawAssistantApiService (http.post)
                                                   │ (Wait Full JSON)
UI Full Update ◄── State (_conversation) ◄─────────┘
```

---

## 二、 法條引用與標籤解析 (Citation Link Parsing)

### 2.1 現有 Citation 資料結構
*   `LawAssistantCitation` 模型（定義於 `lib/data/law_assistant/law_assistant_models.dart`）：
    *   包含 `title`、`sourceType` (statute / judgment / official / news / other)、`url`、`lawName` 與 `articleNumber`。
    *   轉換方法 `toViewData()` 可產出 `SourceCitationViewData` 供 UI 呈現。

### 2.2 UI 呈現與互動限制
1.  **`SourceCitationList` 元件**（位於 `lib/components/shared/mvp_state_widgets.dart`）：
    *   將 Citation items 以底部專屬卡片列出，顯示 `title`、`sourceType`、`lawName`、`articleNumber` 與網址。
    *   網址部分僅使用 `SelectableText(item.url)` 提供複製與純文字選取，**缺少點擊觸發 `url_launcher` 或內部法條導頁的 OnTap 事件**。
2.  **內文 (Markdown/Text) 法條標籤缺乏 Inline Parser**：
    *   在 `_AssistantAnswerContent` 中，AI 回覆的 `problemDirection`、`relatedContent`、`possibleLegalIssues` 等欄位僅使用純 `Text` 渲染。
    *   若 AI 文字中出現 `[民法第 184 條]` 或 `[刑法第 339 條]`，目前無法自動解析為高亮可點擊的法條 Chip，無法直接跳轉至 `StatuteDetailPage(item: ...)`。

---

## 三、 UI 打字機與狀態更新機制 (UI & State Management)

### 3.1 畫面與 State 職責劃分
*   **Local State (`LawAssistantChatPage`)**：
    *   管理 `_conversation`、`_isLoading`、`_isSending` 與 `_errorMessage`。
    *   當發送訊息時，`_isLoading` 變為 `true` 並於視窗底部顯示 `_AssistantStatusCard(message: '小法助正在整理方向...')`。
    *   當 Future 成功回傳後，呼叫 `setState()` 一次性更新整個 `_conversation` 訊息陣列，並呼叫 `_scrollToBottom()` 滾動至底部。
*   **Global State (`PreambleState` / `PreambleUser`)**：
    *   管理用戶等級與每日 AI 額度 (`remainingAiQuota` / `usedQuotaToday`)。
    *   發送前由 UI 檢查 `canUseLawAssistant`；發送後更新本機快取或呼叫 `/quota/consume`。

### 3.2 打字機體驗缺口
*   由於目前未接 Stream，當後端處理時間較長時，使用者只會看到「小法助正在整理方向...」卡片，隨後文字整區突然彈出，缺乏現代 AI 助手（如 ChatGPT / Gemini）流暢的「逐字打字機 (Typewriter Effect)」體驗。

---

## 四、 重構建議與 Phase 3 執行計畫 (Phase 3 Execution Plan)

### 4.1 核心重構目標
1.  **網路層 Streaming 化**：支援 Server-Sent Events (SSE) 流式傳輸。
2.  **Repository 介面雙軌 Stream**：線上模式傳回 ByteStream；Mock 模式傳回模擬逐字 Chunk。
3.  **UI 打字機與滾動優化**：即時 append 文字 Chunk 並流暢自動滾動。
4.  **Inline Citation Parser & 法條跳轉卡片**：將 `[民法第 184 條]` 自動高亮並綁定 `StatuteDetailPage` 路由。

### 4.2 建議新增與重構檔案清單

#### 1. Network Layer (`lib/data/law_assistant/`)
- **[MODIFY] `law_assistant_api_service.dart`**：
  - 新增 `Stream<String> sendMessageStream({required String conversationId, required String prompt})`
  - 使用 `http.Request('POST', ...)` 與 `response.stream.transform(utf8.decoder)` 監聽 SSE `data:` 區塊。
- **[MODIFY] `law_assistant_repository.dart`**：
  - 新增 `Stream<LawAssistantStreamChunk> sendMessageStream(...)`
  - 在 Mock 模式下使用 `Stream.periodic` 模擬 30ms 逐字輸出 Chunk，保持離線與線上體驗一致。

#### 2. Citation Parser & Components (`lib/components/shared/` & `lib/pages/learning/`)
- **[NEW] `lib/components/shared/inline_citation_parser.dart`**：
  - 正則表達式 `RegExp(r'\[?([\u4e00-\u9fa5]+第\s*\d+\s*條)\]?')` 提取法條標籤。
  - 將段落切分為 `TextSpan` 與 `WidgetSpan(StatuteTagChip)`。
  - 點擊法條 Chip 時自動查詢 `StatuteRepository.searchStatutes()` 並 Push 到 `StatuteDetailPage`。
- **[MODIFY] `lib/components/shared/mvp_state_widgets.dart`** (`SourceCitationList`)：
  - 為 `SourceCitationViewData` 增加 `onTap` 導航事件與 `url_launcher` 外開連結能力。

#### 3. UI Chat Stream Integration (`lib/pages/learning/law_assistant/`)
- **[MODIFY] `law_assistant_chat_page.dart`**：
  - 引入 `StreamSubscription<LawAssistantStreamChunk>`。
  - 收到 Chunk 時將文字動態累加至當前草稿 Message 實體，並觸發小幅滾動 `_scrollToBottom()`。
  - 保留 mandatory `lawAppLegalDisclaimer` 法律免責聲明底線。

---

## 五、 結論 (Summary)

「小法助」目前的 Data Model 與分層架構設計良好，為下一步升級串流提供了堅實基礎。建議在 Phase 3 依上述計畫優先完成 `LawAssistantApiService` 的 SSE 串流介面與 `InlineCitationParser`，打造具備專業法律跳轉能力與極致流暢打字體驗的 AI 隨身法律助理。
