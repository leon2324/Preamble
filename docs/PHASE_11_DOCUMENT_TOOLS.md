# 緒言 Preamble Phase 11 法律文件工具箱與數位簽名規格書

本規格書紀錄 Phase 11 所落實的「電子簽名板」、「高解析度圖片匯出」與「文件完成度評分」功能，對應優化清單中的第 12、19、20 項。

---

## 1. 電子簽名板 (`SignaturePad`)
- **檔案**：`lib/components/documents/signature_pad.dart`
- **目的**：允許使用者在手機畫面上直接手繪簽名，不需列印紙本也能為草稿附加簽名。
- **實作設計**：
  - 使用純 Dart 內建之 `CustomPainter` 與 `GestureDetector`，追蹤 `Offset` 軌跡並渲染。
  - 避免引入過多相依套件，確保核心渲染輕量快速。
  - 支援「重簽」清除陣列，以及「確認簽名」將畫布透過 `ui.PictureRecorder` 轉為 `Uint8List` PNG 格式儲存。

---

## 2. 法律文件填表完成度評分 (`FormCompletenessIndicator`)
- **檔案**：`lib/components/documents/form_completeness_indicator.dart`
- **目的**：輔助使用者確認表單填寫的完整性，降低法律文件內容過於空泛的風險。
- **實作設計**：
  - 讀取 `DocumentTemplateInput` 模型狀態。
  - 針對發件人、收件人、事實、時間地點、證據共 5 大項目進行計分。
  - 動態回傳 0% ~ 100% 分數，並根據不同落點透過 UI 的進度條顏色（紅/橘/綠）與文案提供補件建議。

---

## 3. 高解析度圖片匯出 (`exportDraftAsImage`)
- **檔案**：`lib/data/documents/document_repository.dart`
- **目的**：打破純文字分享限制，將含有簽名的草稿轉換為高畫質圖檔，便於直接於 LINE 或其他社群平台分享。
- **實作設計**：
  - 新增 `exportDraftAsImage`，同樣透過 `ui.PictureRecorder` 建構離線虛擬畫布。
  - 運用 `ui.ParagraphBuilder` 繪製草稿的標題與內文排版。
  - 解析草稿模型中的 `signatureBytes`，若存在則將簽名 PNG 繪製於草稿底部。
  - 使用 `path_provider` 將最終結果儲存為本機暫存檔案，為未來介接 `share_plus` 開出基礎。
