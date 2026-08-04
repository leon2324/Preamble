# 緒言 Preamble Phase 3 小法助 AI 對話流式傳輸與法條引用重構規格書

本規格書記錄「小法助」AI 對話系統雙軌 SSE 流式打字機傳輸、本機 `Stream.periodic` 離線模擬、`InlineCitationParser` 正則解析與點擊跳轉 `StatuteDetailPage` 之架構設計與實作規範。

---

## 1. 核心機制與設計原則

### 1.1 雙軌串流一致性 (Dual-Track Streaming Consistency)
- **線上模式 (`isBackendConfigured == true`)**：透過 `LawAssistantApiService.sendMessageStream` 連線至後端 SSE 端點 (`/law-assistant/conversations/{id}/messages/stream`)，解析 `data:` 區塊輸出 Chunk。
- **離線/Mock 模式 (`isBackendConfigured == false`)**：使用 `Stream.periodic` 搭配 `_mockAssistantMessage` 模擬每 30ms 輸出 2~4 個中文字之逐字 Chunk。
- **UI 層透明接收**：UI 僅透過 `StreamSubscription<LawAssistantStreamChunk>` 監聽，無需感知線上與離線傳輸之差異。

```
                    ┌── (Backend Configured) ──► SSE (http.ByteStream) ──┐
[ LawAssistantChatPage ] ◄── Stream<LawAssistantStreamChunk> ────────────┴─ [ LawAssistantRepository ]
                    └── (Mock Mode) ───────────► Stream.periodic (30ms) ─┘
```

### 1.2 零第三方金鑰與單向資料流
- 前端嚴禁寫入或保存任何 OpenAI / Gemini API Provider 金鑰。
- UI 層僅監聽 Stream 並觸發 `setState()` 與 `_scrollToBottom()`，不處理 raw HTTP stream 的分封解碼。

---

## 2. Chunk 模型與 Data Layer 實作

### 2.1 `LawAssistantStreamChunk` 資料模型
- 位於 `lib/data/law_assistant/law_assistant_models.dart`：
  - `textChunk` (`String`)：當前接收之文字片段。
  - `isFinished` (`bool`)：標記 Stream 是否完全傳輸完畢。
  - `citations` (`List<LawAssistantCitation>`)：最新附帶之引用來源清單。
  - `error` (`String?`)：異常訊息。

### 2.2 API Service SSE 解析流程
- 位於 `lib/data/law_assistant/law_assistant_api_service.dart`：
  1. 使用 `http.Request('POST', _uri('/law-assistant/conversations/$conversationId/messages/stream'))` 發送請求。
  2. 透過 `response.stream.transform(utf8.decoder).transform(const LineSplitter())` 分拆行。
  3. 監聽 `data:` 開頭之行，解析 JSON `LawAssistantStreamChunk` 並以 `yield` 輸出。

---

## 3. 法條標籤解析與互動 Chip (`InlineCitationParser`)

### 3.1 正則表達式與標籤識別
- 位於 `lib/components/shared/inline_citation_parser.dart`：
  - 關鍵正則：`RegExp(r'\[?((民法|刑法|勞動基準法|勞基法|消費者保護法|消保法|道路交通管理處罰條例|公司法|證券交易法)第\s*\d+\s*條)\]?')`
  - 將輸入文字分拆為一般 `TextSpan` 與包覆 `StatuteTagChip` 之 `WidgetSpan`。

### 3.2 點擊跳轉與檢索流程
1. 用戶點擊內文中的 `[民法第 184 條]` 標籤。
2. 觸發 `StatuteRepository().searchStatutes(query: '民法 第 184 條')`。
3. 取得 `StatuteItem` 實體後，經由 Navigator 導頁跳轉至 `StatuteDetailPage(item: statute)`。

---

## 4. UI 打字機與免責聲明防線

- **`LawAssistantChatPage` 訂閱模式**：
  - 點擊發送後建立草稿 AI `LawAssistantMessage`。
  - `StreamSubscription` 每收到 `textChunk` 即動態 append 至訊息內文並呼叫 `_scrollToBottom()`。
- **免責聲明防線**：
  - 流式打字過程中與傳輸結束後，訊息下方恆定渲染 `lawAppLegalDisclaimer`。
