# Walkthrough

## Tenth Period: Case Dossier Detail Page Refinements

本階段針對案件卷宗詳情頁 `case_dossier_detail_page.dart` 進行了三項核心功能提煉，皆符合莫蘭迪淡雅色調與 Cream 白色主題設計：

### 1. 裁判結果徽章 (Verdict Outcome Badge) 與 AI 小法助橫幅 (AI Q&A Banner)
- **裁判結果徽章 (Verdict Outcome Badge)**：在案件標題與標籤列下方，新增了精美的莫蘭迪色系徽章。針對不同的裁判結果（無罪、違憲/合憲、徒刑有罪處分、其他），動態套用柔和的背景、邊框與文字顏色（例如：無罪為綠色 `Color(0xFFEAF5F0)`，合憲/違憲為金色 `Color(0xFFFFF7E6)`，有罪為紅色 `Color(0xFFFFF1F0)`），清晰凸顯最終裁決。
- **AI 小法助橫幅 (AI Q&A Banner)**：在主內容下方，將原有的問法助橫幅重新設計為莫蘭迪粉綠漸層 (`Color(0xFFFAF8F5)` 到 `Color(0xFFE6EFEA)`)，邊框採用淡綠色 (`Color(0xFFC7DED1)`)，並將心理學圖示替換為專屬的「閃爍 (Sparkles)」向量圖示。點擊該橫幅會先觸發 Snackbar 提示，接著流暢載入 AI 小法助搜尋頁面並預填本案 prompt。

### 2. 互動式相關法條底頁 (Interactive Law Sheet)
- 在「相關法條」標籤頁中，原本的法條卡片被包覆於 `GestureDetector` 中，使其可點擊。
- 原本的外部連結圖示替換為向右箭頭 (`CtmSvgIcons.chevronRight`)。
- 點擊卡片將會開啟一個高度自適應、背景採用莫蘭迪米色 Cream 的 `showModalBottomSheet`，呈現該法條的詳細條文概要（Summary）以及此法條與本案的關聯（Relevance to Case），提供層次分明的沉浸式學習體驗。

### 3. 判決書分頁錨點滾動 (Judgment Book Section Anchors & Smooth Scrolling)
- 在「完整判決書」標籤頁頂端，新增了一個水平滾動的錨點按鈕列（主文、程序概述、理由與心證、適用法條），並使用 `CtmSvgIcons.article` 圖示修飾。
- 判決書全文從單一長文字區塊重構為區塊化（SelectionArea 包裹的 Column）結構，各區塊（主文、程序概述、實體理由與心證闡述、適用法條）分別綁定對應的 `GlobalKey`，並渲染在典雅的仿羊皮紙色（Parchment）背景容器中。
- 當使用者點擊頂部的錨點時，系統會調用 `Scrollable.ensureVisible` 於 400 毫秒內平滑滾動（`Curves.easeInOut`）至目標區塊。

---

*備註：在開發過程中，亦同步修正了 `lib/pages/learning/know_law_page.dart` 中因為私有類別 `_TranslatorCard` 未傳入選用參數 `variant` 導致的 Dart `unused_element_parameter` 靜態分析警告。目前 `flutter analyze` 掃描結果為 0 issues，完美通過。*
