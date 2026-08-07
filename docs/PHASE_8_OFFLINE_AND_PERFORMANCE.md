# 緒言 Preamble Phase 8 離線韌性與效能底層優化規格書

本規格書記錄 Phase 8 所落實的「離線佇列機制」與「防重發效能優化」，為 Preamble 提供更強固的底層網路韌性，解決使用者在弱網環境下的操作體驗痛點。

---

## 1. 離線韌性基礎建設 (Offline Resiliency)

### 1.1 離線請求佇列 (`OfflineRequestQueue`)
- **檔案**：`lib/utils/offline_request_queue.dart`
- **目的**：解決當使用者在無網路或網路極度不穩定（如：捷運中、電梯內）狀態下，執行「建立草稿」或「發送問題」等關鍵操作時的錯誤體驗。
- **實作邏輯**：
  - **In-Memory MVP**：現行實作為單例 (Singleton) 記憶體佇列，紀錄 endpoint、payload 與 retryCount。
  - **Enqueue**：在 `document_repository.dart` 的 `createDraft` 中，若捕捉到網路連線異常 `Exception`，即將 payload 與 `templateType` 封裝並推入 `OfflineRequestQueue`，同時提示使用者「已存入離線佇列」。
  - **Sync (背景重發)**：透過呼叫 `sync()` 並傳遞處理常式 (handler)，佇列中的請求會依序被打出。若遇到錯誤（例如仍無網路），會增加 `retryCount` 並放回佇列，最多重試 3 次。

---

## 2. API 防護與防重發機制 (Idempotency)

### 2.1 防重發管理員 (`IdempotencyManager`)
- **檔案**：`lib/utils/idempotency_manager.dart`
- **目的**：防止使用者在網路延遲時，不耐煩地「狂點」送出按鈕，導致後端建立出多筆一模一樣的草稿或多次扣除 AI Quota。
- **實作技術**：
  - **UUID v4**：引入 `uuid` 套件，於發送請求前利用 `IdempotencyManager.instance.generateKey()` 產生唯一的 `X-Idempotency-Key`。
  - **攔截驗證**：透過 `markAsUsed(key)` 驗證該筆請求是否已經發送。若發現為重複發送（Key 已存在 Set 中），將直接阻擋並拋出 `Exception('重複的請求已被阻擋')`。
  - **LRU 清理機制**：內部使用 Set 暫存，設定長度上限 100，避免長時間執行導致記憶體溢出。

---

## 3. 架構盤點與後續優化建議
- **統一 Dispose (Memory Leak 稽核)**：後續開發中，所有掛載於 StatefulWidget 的 `TextEditingController` 與 `StreamSubscription` 都應強制在 `dispose()` 區塊內釋放，以符合 Phase 8 之記憶體安全標準。
- **SharedPreferences 擴展**：目前的 `OfflineRequestQueue` 與 `IdempotencyManager` 皆為 In-Memory 實作。建議在未來版本整合 `SharedPreferences` 進行永久化快取，以達成「App 關閉重啟後，離線佇列依然能接續重發」的完全體。
