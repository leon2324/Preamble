# 緒言 Preamble Phase 2 後端 API 完整串接規格書

本規格書記錄「緒言 Preamble」前端與 `PREAMBLE_API_BASE_URL` 後端 RESTful API 串接架構、Auth 401 攔截器、Token Refresh 機制、平滑降級 (Fallback) 邏輯與測試涵蓋範疇。

---

## 1. 核心機制與設計原則

### 1.1 零第三方 API Key 政策
- 所有第三方 AI 模型（如 OpenAI、Gemini）請求完全由 `PREAMBLE_API_BASE_URL` 後端代理。
- Flutter 前端嚴禁寫入或保存任何第三方 API Provider 金鑰。

### 1.2 無縫降級 (Seamless Offline Fallback)
- 當未傳入 `PREAMBLE_API_BASE_URL` 或網路連線失敗時，Repository 自動平滑切換至本機靜態快取/Mock 資料。
- UI 層完全與資料來源隔離，無法感受後端連線狀態差異，維護流暢的使用者體驗。

---

## 2. Auth 401 攔截器與 Token 刷新機制

### 2.1 HTTP Auth Interceptor 運作流程
1. **發送 Request**：前端透過 `AuthHttpClient` 發送 API 請求，自動於 Header 附帶 `Authorization: Bearer <token>`。
2. **攔截 401 Unauthorized**：若後端回傳 HTTP 401 狀態碼，攔截器自動阻斷原失敗流程。
3. **發起 Token 刷新**：自動呼叫 `POST /auth/refresh` 並帶入當前 Token / Refresh Session。
4. **重新發送 Request**：
   - 刷新成功：更新本機儲存之 Token，使用新 Token 重新發送原 HTTP 請求並回傳結果。
   - 刷新失敗：清除本機 Token，轉為 Guest 訪客模式，並拋出可讀之 Auth 異常。

```
[ HTTP Request ] ───(Bearer Token)───► [ Backend API ]
                                             │
                                       (HTTP 401 Response)
                                             │
                                             ▼
                                   [ Auth Interceptor ]
                                             │
                                     (POST /auth/refresh)
                                             │
                                   ┌─────────┴─────────┐
                             (200 Success)       (Error/401)
                                   │                   │
                            [ Retry Request ]   [ Sign Out to Guest ]
```

---

## 3. API 服務與平滑降級 (Fallback) 矩陣

| API 服務名稱 | 核心 Endpoints | 成功時資料流 | Fallback 降級機制 |
| :--- | :--- | :--- | :--- |
| **`BackendAuthService`** | `POST /auth/demo/member`<br>`POST /auth/demo/subscriber`<br>`POST /auth/refresh`<br>`POST /auth/sign-out`<br>`GET /users/me` | 後端核發 Token 與 `PreambleUser` 實體 | `DemoAuthService` (本機 Mock 切換) |
| **`CaseApiService`** | `GET /cases/featured`<br>`GET /cases/archive`<br>`GET /cases/search`<br>`GET /cases/{id}` | 線上 35 案與歷史卷宗 JSON | `CaseRepository._mockCases` 靜態卷宗 |
| **`SearchApiService`** | `GET /search?q=&type=` | 全局後端混合索引結果 | 聯合 `SearchRepository` 本機多庫搜尋 |
| **`OfficialFeedApiService`** | `GET /official-feeds/news`<br>`GET /official-feeds/press-releases`<br>`GET /official-feeds/announcements` | 官方網址、標題與發布時間 | `MojFeedService` 直接連線法務部官網或靜態示範項 |
| **`QuotaApiService`** | `GET /quota`<br>`POST /quota/consume` | 線上 AI 剩餘額度即時扣減 | `PreambleUser` 本機計數器邏輯 |

---

## 4. 單元測試驗證範疇 (`test/backend_api_services_test.dart`)

- **Bearer Token 自動帶入**：驗證 `AuthTokenProvider` 正常輸出 Token 時，HTTP Header 正確帶入 `Authorization`。
- **401 Interceptor 自動重試**：使用 `MockClient` 模擬首發 401 狀態，驗證自動調用 `/auth/refresh` 後重試原請求並成功取得資料。
- **JSON 序列化與例外解析**：驗證正常 JSON 轉 Models 流程，以及非 2xx HTTP 錯誤碼時產生可讀性 Exception。
- **Fallback 切換**：驗證各 Repository 在無 Base URL 或連線異常時能正常傳回非空之本機 Mock 資料。
