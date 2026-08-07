# 緒言 Preamble Phase 9 API 安全防護與配額系統基礎規格書

本規格書記錄 Phase 9 所落實的「JWT 雙憑證無感刷新」、「AI 諮詢點數配額管理」與「法規書籤系統」，為 Preamble 的安全性防護與未來的商業化訂閱模式打下堅實基礎。

---

## 1. 網路安全與認證 (Authentication Security)

### 1.1 JWT 雙憑證無感刷新 (`AuthInterceptor`)
- **檔案**：`lib/utils/auth_interceptor.dart`
- **目的**：提供穩定的 API 溝通管道。當 Access Token 因過期而被後端拒絕 (401 Unauthorized) 時，前端可自動進行換發，不影響使用者的當下操作。
- **運作機制**：
  - 攔截 `requestAction` 拋出的 401 錯誤。
  - 使用鎖 (`_isRefreshing`) 防止多個併發請求同時觸發刷新。
  - 背景向伺服器以 Refresh Token 換取新的 Access Token 後，原封不動地「重發 (Retry)」原本失敗的 API 請求。
  - 若 Refresh Token 也過期，則拋出 `AuthException` 強制登出。

---

## 2. 點數配額與商業化邏輯 (Quota System)

### 2.1 AI 免費點數配額管理 (`QuotaManager`)
- **檔案**：`lib/utils/quota_manager.dart`
- **目的**：限制使用者每天使用 AI 法律諮詢的次數，避免 API 成本無限膨脹，並為後續推出 VIP 訂閱 (無限制次數) 建立付費牆 (Paywall) 前提。
- **實作設計**：
  - 預設每日提供 **5 次** 免費諮詢額度 (`_dailyLimit = 5`)。
  - 每次送出 prompt 時，由 `LawAssistantRepository` 呼叫 `consumeQuota()` 扣減額度。
  - **跨日自動重置**：讀取上一次使用的日期，若與今日不同，則重置消耗量為 0。
  - 額度用罄時拋出 `QuotaExceededException`。

---

## 3. 個人化體驗 (Personalization)

### 3.1 法規書籤收藏 (`BookmarkManager`)
- **檔案**：`lib/utils/bookmark_manager.dart`
- **目的**：實作 Preamble 100 項優化中提及的「法條書籤與客製化標籤分類」雛形。
- **功能特性**：
  - 提供 `toggleBookmark(id, title)` 加入/移除法規。
  - 以 JSON 序列化方式，支援 `SharedPreferences` 的本機持久化儲存。
  - 統一透過 `ChangeNotifier`，使 UI 能即時監聽收藏狀態並更新愛心/書籤圖示。
