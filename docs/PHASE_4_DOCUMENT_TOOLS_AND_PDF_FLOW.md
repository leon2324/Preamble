# 緒言 Preamble Phase 4 法律文件工具箱與 PDF 產出重構規格書

本規格書記錄「法律文件工具箱」SharedPreferences 本機持久化快取、離線草稿自動同步至 `/documents/drafts` API、步驟化表單即時驗證、以及莫蘭迪/Charcoal 設計系統 PDF 主題繪製引擎之架構設計與實作規範。

---

## 1. 本機持久化與離線自動背景同步

### 1.1 SharedPreferences 快取結構
- 儲存 Key：`preamble_local_document_drafts_v1`
- 資料格式：JSON Array String。每份 `DocumentDraft` 序列化包含 `id`, `title`, `content`, `templateType`, `createdAt`, `isMock`, `disclaimer`, `isSyncedToBackend`, `sourceLabel`。

### 1.2 背景同步觸發流程 (Single Source of Truth)
1. 用戶於離線模式發起草稿建立 ➔ 寫入 `_drafts` 並調用 `_saveLocalDraftsToDisk()` 寫入 SharedPreferences，標記 `isSyncedToBackend = false`。
2. 當 `isBackendConfigured == true` 且發起 `fetchDrafts()` 時：
   - 走訪本機未同步清單（`isSyncedToBackend == false`）。
   - 對每一筆草稿發起 `POST /documents/drafts`。
   - 後端保存成功後將 `isSyncedToBackend` 標記為 `true` 並更新本機快取。

---

## 2. 步驟化表單驗證與快速範例帶入 (`document_form_stepper.dart`)

- **視覺化進度條 (`DocumentFormStepper`)**：
  - 顯示 Step 1（情境）、Step 2（補充資料）、Step 3（草稿預覽）之圓形與指示線。
- **即時欄位校驗**：
  - 檢查發信人與相對人姓名、事實摘要非空驗證。
  - 提供「一鍵帶入預設範例」按鈕，快速帶入各模板專屬情境。
- **模板情境擴充欄位**：
  - 租屋押金：可選扣款金額、點交日期。
  - 車禍和解：可選報案三聯單字號、修車初估金額。
  - 消費申訴：可選平台訂單編號。

---

## 3. 莫蘭迪 / Charcoal PDF 樣式繪製引擎 (`pdf_style_builder.dart`)

### 3.1 Design System Tokens
- **Morandi Green Theme**：
  - 主色 (Primary Header)：`#2C5E43`
  - 次色 / 邊框 (Accent Border)：`#B8DAC8`
  - 內文 (Body Text)：`#17231F`
  - 背景 Surface：`#F5F8F6`
- **Charcoal Classic Theme**：
  - 主色：`#17231F`
  - 邊框：`#D0D5DD`

### 3.2 PDF 頁面結構
1. **Header**：莫蘭迪配色頂欄與書狀名稱大字。
2. **Details Card**：雙欄點陣（時間、地點、發布者、相對人）。
3. **Body Content**：思源宋體 (`SourceHanSerifTW-VF.ttf`) 內文排版，搭配行高控制。
4. **Signature / Seal Card (簽名落款區)**：包含「立書人/發起人簽章」框與日期落款卡片。
5. **Footer**：頁碼 `${context.pageNumber} / ${context.pagesCount}` 與 `lawAppLegalDisclaimer` 法律免責條款。
