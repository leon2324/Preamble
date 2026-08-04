# 緒言 Preamble 方向二：法律文件工具箱與 PDF 產出 (Document Tools & PDF Flow) 架構審查報告

> **審查日期**：2026 年 8 月  
> **目標模組**：法律文件工具箱與 PDF 產出流程 (`DocumentRepository`, `DocumentDraft`, `LegalToolsPage`, `LegalDocumentExportPage`)  
> **審查結論**：專案已具備 5 大生活情境模板、雙軌草稿 API 串接 (`/documents/drafts`)、思源黑體/宋體繁中字型 PDF 渲染 (`pdf` / `printing`) 與原生 AirPrint/分享能力。本報告針對表單即時驗證、本機持久化快取、莫蘭迪/Charcoal 經典風格 PDF 繪製與 Phase 4 重構提出全盤規範。

---

## 一、 現有 5 大生活模板與 UI 填表流程 (5 Life Templates & Form Flow)

### 1.1 5 大生活模板與資料模型盤點
*   **模型類別** (`lib/data/documents/document_models.dart`)：
    *   `DocumentTemplateType` 包含：
        1. `depositDemand` (存證信函 / 押金返還通知)
        2. `rentalDepositNegotiation` (租屋押金協商訊息)
        3. `carAccidentChecklist` (車禍和解前資料清單)
        4. `consumerComplaint` (消費爭議申訴草稿)
        5. `laborDisputeMessage` (勞資爭議溝通草稿)
    *   `DocumentTemplateInput` 抽象化欄位：`senderName`（發信/本人）、`receiverName`（相對人）、`facts`（事實）、`extraRequest`（處理事項）、`eventDate`（日期）、`eventPlace`（地點）、`evidence`（證據）、`toneLabel`（語氣）。

### 1.2 UI 步驟引導與表單填寫
*   **UI 容器** (`lib/pages/tools/legacy/legal_tools_page.dart`)：
    *   採用 `_ToolPage` 狀態轉換與 `_WizardShell` 進行 3-step 導引：
        *   **Step 1 情境選取 (`_ScenarioPanel`)**：選擇 5 大模板之一，帶入預設範例與引導提示。
        *   **Step 2 補充資料 (`_DetailsPanel`)**：輸入雙方名稱、時間地點、爭議事實與希望處理方式，並支援進入 `_EvidencePanel` 選擇證據清單。
        *   **Step 3 預覽草稿 (`_PreviewPanel`)**：切換「協商語氣」與「正式語氣」，即時重新生成文字，並提供複製、分享與進入 PDF 匯出頁面。

### 1.3 現狀體驗缺口
1.  **缺乏表單動態校驗 (Form Validation)**：輸入欄位未加入 `FormKey` 與即時非空/日期格式校驗，當使用者直接留空時僅使用 `_fallback` 字串填充。
2.  **模板專屬動態欄位不足**：5 大模板目前共用相同的基本輸入欄位，尚未針對「租屋扣款金額」、「車禍初判表字號」等特定情境提供專屬可選動態欄位。

---

## 二、 本機與線上草稿同步 (Draft Persistence & Sync)

### 2.1 `DocumentRepository` 現有架構 (`lib/data/documents/document_repository.dart`)
*   **雙軌存取機制**：
    *   **線上模式 (`isBackendConfigured == true`)**：
        *   `fetchDrafts()`：發送 `GET /documents/drafts` 取得線上草稿清單。
        *   `createDraft()`：發送 `POST /documents/drafts`，後端回傳後生成 `isSyncedToBackend = true` 之草稿。
    *   **離線/本機模式 (`isBackendConfigured == false`)**：
        *   `createDraft()` 呼叫 `_localDraft(...)` 於本機生成草稿，標記 `isSyncedToBackend = false` 與 `sourceLabel: '本機暫存'`。
*   **免責聲明附加**：每份草稿皆固定強制帶入 `lawAppLegalDisclaimer` 警語。

```
                    ┌── (Backend Configured) ──► GET/POST /documents/drafts (API) ──┐
[ LegalToolsPage ] ◄── List<DocumentDraft> ─────────────────────────────────────────┴─ [ DocumentRepository ]
                    └── (Mock Mode) ───────────► _localDraft & Memory _drafts ──────┘
```

### 2.2 持久化與離線恢復缺口
*   目前本機草稿僅儲存於 `DocumentRepository` 之記憶體清單 `_drafts` 中。
*   若使用者未設定 API Base URL 且重新啟動 App，本機新建的草稿將無法復原。
*   需要於 Phase 4 加入 `SharedPreferences` / 本機快取層，並實作離線建立草稿於連線復原後自動背景同步機制。

---

## 三、 PDF 渲染與列印/分享流 (PDF Generation & Export)

### 3.1 `LegalDocumentExportPage` 實作現況 (`lib/pages/learning/widgets/legal_document_export_page.dart`)
*   **套件整合**：使用 `package:pdf/pdf.dart`、`package:pdf/widgets.dart` 與 `package:printing/printing.dart`。
*   **繁體中文字型載入**：
    *   明確載入專案開放原始碼字型 `SourceHanSerifTW-VF.ttf`（思源宋體）作為內文及 `SourceHanSansTW-VF.ttf`（思源黑體）作為標題與頁首頁尾。
    *   解決了預設 PDF 套件缺乏中文字型導致列印/預覽時出現亂碼或方塊字的問題。
*   **排版與美學**：
    *   格式：標準 A4 (`PdfPageFormat.a4`)，邊距 42/44/42/48 pt。
    *   視覺邊框：紅褐色線條外框 (`PdfColor.fromHex('#9E4A4A')`) 與紅色律師蓋印動畫。
    *   頁首頁尾：自動顯示「緒言 Preamble 書狀草稿」與頁碼 `${context.pageNumber} / ${context.pagesCount}`。
*   **列印與分享**：
    *   `Printing.layoutPdf` 支援原生 AirPrint 列印與預覽。
    *   `Printing.sharePdf` 支援將 PDF 檔直接分享至 LINE、Mail、檔案系統。

### 3.2 美學與功能優化缺口
1.  **莫蘭迪/Charcoal 設計系統套用**：目前 PDF 外框偏向傳統單一紅褐色，尚未完整套用 Preamble 現代莫蘭迪墨綠 (`#2C5E43`) 或深炭灰 (`#17231F`) 視覺語言。
2.  **缺乏自訂落款印章與簽名欄位**：尚未提供「申請人蓋印/簽名卡片」與自訂日期落款功能。

---

## 四、 重構建議與 Phase 4 執行計畫 (Phase 4 Execution Plan)

### 4.1 核心重構目標
1.  **本機草稿持久化與離線自動同步**：整合 `SharedPreferences` 保存本機草稿，連線後自動上傳。
2.  **動態步驟表單與欄位驗證**：新增即時驗證、進度條與特定模板專屬選填欄位。
3.  **高質感莫蘭迪 PDF 樣式引擎**：升級 `LegalDocumentExportPage`，提供墨綠/深灰經典樣式、自動頁碼、落款簽名區與雙重分享 (PDF + 純文字)。

### 4.2 建議待修改與新增檔案清單

#### 1. Data Layer (`lib/data/documents/`)
- **[MODIFY] `document_repository.dart`**：
  - 新增 `SharedPreferences` 本機快取讀寫邏輯 (`_saveLocalDraftsToDisk`, `_loadLocalDraftsFromDisk`)。
  - 當連線成功時，自動尋找 `isSyncedToBackend == false` 的本機草稿背景同步至後端。

#### 2. Form & UI Stepper (`lib/pages/tools/`)
- **[NEW] `lib/pages/tools/widgets/document_form_stepper.dart`**：
  - 解耦 `_WizardShell`，提供更流暢的進度條指示器、欄位即時驗證 (Validation feedback) 與範例填入快捷按鈕。
- **[MODIFY] `lib/pages/tools/legacy/legal_tools_page.dart`**：
  - 接入解耦元件，擴充各情境專屬選項（如租金扣除額、車禍和解條件）。

#### 3. PDF Generator & Export (`lib/pages/learning/widgets/`)
- **[NEW] `lib/pages/learning/widgets/pdf_style_builder.dart`**：
  - 抽離 PDF 繪製邏輯，提供經典莫蘭迪綠與典雅黑炭兩種專屬主題。
  - 新增簽名與蓋印區域 (`pw.Container` 落款卡片) 及法律免責標籤。
- **[MODIFY] `legal_document_export_page.dart`**：
  - 呼叫 `pdf_style_builder.dart` 生成多主題 PDF，並升級匯出與複製體驗。

---

## 五、 結論 (Summary)

「法律文件工具箱」目前的 5 大模板與 `pdf`/`printing` 基礎整合非常優良。在 Phase 4 中，我們將重點著墨於「本機快取持久化」與「高質感莫蘭迪 PDF 主題繪製引擎」，提供使用者最專業、可靠且美觀的生活法律文件製作體驗。
