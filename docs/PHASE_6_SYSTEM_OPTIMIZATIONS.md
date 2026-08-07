# 緒言 Preamble Phase 6 系統核心功能升級與優化規格書

本規格書記錄「法條懸浮預覽對話框 (`CitationPopoverDialog`)」、「AI 智慧追問按鈕 (`LawAssistantSuggestedPrompts`)」、「手繪簽名板 (`DocumentSignatureCanvas`)」、莫蘭迪 PDF 簽名印記與防偽條碼嵌入、以及「填表完整度計量器 (`DocumentFormCompletenessBar`)」之架構設計與實作規範。

---

## 1. AI 對話與法條引用懸浮預覽卡片

### 1.1 法條懸浮預覽對話框 (`CitationPopoverDialog`)
- **檔案**：`lib/components/shared/citation_popover_dialog.dart`
- **設計規範**：
  - 採用 Preamble 莫蘭迪綠 (`#2C5E43`) 頂欄標章卡片。
  - 展示法規名稱、條號、條文摘要內文與實務求償提示。
  - 提供「開啟完整法規條文」按鈕，點擊導向 `StatuteDetailPage`。
- **整合**：`InlineCitationText` 的 `StatuteTagChip` 點擊或長按自動跳出 `CitationPopoverDialog`。

### 1.2 AI 智慧追問按鈕 (`LawAssistantSuggestedPrompts`)
- **檔案**：`lib/pages/learning/widgets/law_assistant_suggested_prompts.dart`
- **對話選項**：
  - 「該如何蒐集與保存證據？」
  - 「請求賠償的法定消滅時效多久？」
  - 「如果對方拒絕回應，下一步該怎麼做？」
- **行為**：點擊建議按鈕自動填入小法助輸入框並發起對話。

---

## 2. 法律文件手繪簽名板與 PDF 防偽印記

### 2.1 手繪簽名板 (`DocumentSignatureCanvas`)
- **檔案**：`lib/pages/tools/widgets/document_signature_canvas.dart`
- **技術實作**：
  - 使用 `CustomPainter` 手繪筆跡觸控監聽 (`onPanUpdate`)。
  - 提供「清除手繪」與「確認儲存簽名」工具按鈕。
  - 將繪製之 Path 轉譯為 250x100 點陣圖 (`ui.Image` ➔ PNG `Uint8List`)。

### 2.2 PDF 簽名與防偽頁尾嵌入 (`pdf_style_builder.dart`)
- **參數擴充**：`buildDocumentPdf({..., Uint8List? signaturePngBytes})`
- **視覺渲染**：
  - 若包含 `signaturePngBytes`，在落款卡片中將預設底線替換為真實 `pw.Image` 手繪簽名。
  - 頁尾繪製莫蘭迪防偽條碼印記與 `lawAppLegalDisclaimer` 法律免責提醒。

---

## 3. 填表完整度計量器 (`DocumentFormCompletenessBar`)

- **檔案**：`lib/pages/tools/widgets/document_form_stepper.dart`
- **演算法**：
  - 計算當前情境必填欄位（發信人、相對人、事實摘要、爭議點）非空數量比例 (0% ~ 100%)。
  - 以莫蘭迪綠動態進度條呈現，提醒使用者未填漏項目。
