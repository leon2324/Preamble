# 緒言 Preamble Phase 10 AI 串流體驗與隱密模式規格書

本規格書記錄 Phase 10 所落實的「動態打字機速度調節」、「離線機密模式」與「草稿版本歷史紀錄」，提升了對話真實感與機敏資料防護層級。

---

## 1. AI 串流體驗優化 (Streaming Experience)

### 1.1 動態打字機速度調節 (`TypingSimulator`)
- **檔案**：`lib/utils/typing_simulator.dart`
- **目的**：打破以往等速輸出文字的機械感，讓 AI 吐字更具「擬真思考」的自然韻律。
- **實作設計**：
  - 遇到句號 `。`、逗號 `，` 等標點符號時，程式會故意加入 300~500ms 的停頓 (Delay)。
  - 一般中文字元，則以 20~50ms 的隨機速度吐字。
  - 此設計不僅能增加 UX 溫度，也能掩蓋後端某些分段生成的網路延遲 (Network Jitter)。

---

## 2. 隱私與機敏資料防護 (Privacy & Confidentiality)

### 2.1 離線機密模式 (Incognito Mode)
- **檔案**：`lib/data/documents/document_repository.dart`
- **目的**：對於商業機密合約或高度敏感之法律案件，提供「閱後即焚」的本機操作體驗。
- **實作設計**：
  - 在 `DocumentRepository` 建構子注入 `isIncognito` 旗標。
  - 當此旗標開啟時：
    1. **不寫入硬碟**：`saveLocalDraftsToDisk` 提早 return，不會把資料寫進 `SharedPreferences`。
    2. **不拋送後端**：`createDraft` 繞過遠端 API 呼叫，強制只建立 Local Draft。
  - 一旦重啟或銷毀 Repository，資料將永久消失於 RAM 中。

---

## 3. 文件版本控管 (Draft Version Control)

### 3.1 草稿版本歷史紀錄 (`DocumentVersion`)
- **檔案**：`lib/data/documents/document_models.dart` & `document_repository.dart`
- **目的**：允許使用者追溯同一份草稿的修改歷史。
- **實作設計**：
  - 在 `DocumentDraft` 新增 `versions: List<DocumentVersion>` 陣列。
  - 新增 `DocumentRepository.updateDraft()` 方法，在每次覆蓋 `content` 前，自動將前一個版本的內容與時間戳記推入 `versions`，讓未來的 UI 有能力繪製「時光機 (Time Machine)」對比畫面。
