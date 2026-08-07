# 緒言 Preamble Phase 7 視覺體驗升級與資料安全防護規格書

本規格書記錄 Phase 7 所落實的 UI/UX 微互動體驗與 AI 隱私防護核心元件，包含：莫蘭迪深色模式主題系統 (`PreambleTheme`)、微光骨架屏 (`PreambleShimmerSkeleton`)、空狀態引導 (`PreambleEmptyState`) 與 AI 敏感詞遮蔽引擎 (`PiiDataMasker`)。

---

## 1. 資料安全與隱私防護 (Data Security)

### 1.1 個資去識別化引擎 (`PiiDataMasker`)
- **檔案**：`lib/utils/pii_data_masker.dart`
- **目的**：在文字發送至大語言模型（如 OpenAI / Gemini）前，強制於端側 (Client-side) 攔截並遮蔽敏感個人資訊 (PII)，確保零隱私外洩。
- **支援遮蔽類型**：
  - **台灣身分證字號**：正則表達式 `[A-Z][1289]\d{8}`。
  - **台灣手機號碼**：正則表達式 `09\d{2}[-\s]?\d{3}[-\s]?\d{3}`。
- **遮蔽行為**：符合規則之字串將被置換為 `[保護資訊]`。
- **整合位置**：已全面整合至 `LawAssistantRepository` 的 `createConversation`、`sendMessage` 與 `sendMessageStream`。

---

## 2. 視覺體驗與微互動 (UI/UX Micro-Interactions)

### 2.1 莫蘭迪深色模式主題系統 (`PreambleTheme`)
- **檔案**：`lib/app/preamble_theme.dart`
- **支援配色 (Accents)**：
  - `morandiGreen`: Preamble 預設莫蘭迪綠 (`#2C5E43` / `#488764`)。
  - `charcoalDark`: 典雅黑炭 (`#17231F` / `#333333`)。
  - `navyBlue`: 海軍藍 (`#2A4D69` / `#5A8BBA`)。
- **模式支援**：提供 `getLightTheme()` 與 `getDarkTheme()`，支援 Material 3 規範，可與 `MaterialApp.themeMode` 直接綁定。

### 2.2 微光骨架屏 (`PreambleShimmerSkeleton`)
- **檔案**：`lib/components/shared/preamble_shimmer_skeleton.dart`
- **目的**：取代傳統的 `CircularProgressIndicator` (轉圈圈)，在法規資料或案件載入時提供具備流動光影效果的骨架屏。
- **實作技術**：使用 `AnimatedBuilder` 搭配 `ShaderMask` 與 `LinearGradient`，實作 1.5 秒週期的平滑漸層滑動特效。支援深色模式自動切換基底色 (`#2A2A2A` / `#E2E8E4`)。

### 2.3 空狀態視覺卡片 (`PreambleEmptyState`)
- **檔案**：`lib/components/shared/preamble_empty_state.dart`
- **目的**：處理「無搜尋結果」、「尚無草稿」等情境，避免畫面留白造成的困惑。
- **設計**：包含大型圓底 Icon、主標題、副標題說明與可選的引導按鈕 (Call to Action)，配色全面適配 `PreambleTheme`。
