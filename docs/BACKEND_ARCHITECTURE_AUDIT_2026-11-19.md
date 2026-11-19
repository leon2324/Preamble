# 後端與架構盤點（2026-11-19）

## 本次範圍

僅檢查 `lawapp`；不修改 UI、頁面版型、圖片或前端展示。盤點涵蓋 `lib/data`、`lib/utils`、HTTP 認證流程、既有後端測試與全專案 Dart 靜態分析。此紀錄只代表原始碼與本機工具檢查，沒有部署或連線驗收正式後端。

## 專案現況

- `lib` 約 290 個 Dart 檔、17 萬行；已有 `data`、`pages`、`components`、`features` 等分層。
- API service 與 repository 已能注入測試用 HTTP client，且有 `test/backend_api_services_test.dart` 涵蓋主要後端契約。
- 多數 repository 在遠端失敗或回傳空清單時會退回本機 mock。這是現有展示行為；若要改成正式資料來源政策，需另行定義「空結果」與「連線失敗」的產品語意。

## 本次修正

`AuthHttpClient` 原本每筆 401 都會各自刷新 Token，而且對不可重送的 `BaseRequest` 會直接重用同一個已送出的物件。現在同一時間的刷新共用 Future；已由其他請求取得新 Token 時直接重試；只有可複製的 `http.Request` 才自動重試，並在重試前讀完舊 401 回應。呼叫端自行提供 Authorization 時不改寫其授權資訊。對應並發與串流邊界已加回歸測試。

主要 API service 與文件 repository 現在記錄 HTTP client 是否由自己建立，`dispose()` 僅關閉自建 client。案件、法規、追蹤、官方資料、小法助與搜尋 repository 也用相同所有權原則管理注入的依賴。搜尋 repository 現在會釋放自己建立的案件 repository；外部傳入的依賴則保留給呼叫端管理。對應測試見 `test/backend_resource_ownership_test.dart`。

## 後續架構優先順序

1. **資料來源政策**：逐一釐清各 repository 對「未設定後端」「連線失敗」「遠端空結果」的處理，避免正式環境把 mock 當成真實資料；此項會影響展示內容，需在保持 UI 視覺的前提下另行規劃。
2. **共用 API 基礎設施**：多個 service 各自實作 base URL、headers、HTTP 錯誤解析；可抽出共用傳輸層，逐個 service 遷移並保留契約測試。
3. **大型資料檔**：案件資料與輔助資料各超過一萬行，應分資料來源拆檔並建立資料驗證工具，減輕審查與維護成本；不宜在沒有資料等價驗證時機械搬動。

## 驗證紀錄

- `dart format`：修改的 Dart 檔已格式化。
- `dart analyze lib/data/auth/auth_service.dart test/backend_api_services_test.dart`：無問題。
- 獨立 Dart smoke check：並發 401 僅刷新一次、兩筆請求皆以新 Token 成功、串流請求不自動重送，均通過。
- 首輪 `flutter test --no-pub test/backend_api_services_test.dart`：工具持續停在載入測試約七分鐘，沒有執行任何測例；已中止，不計通過。
- 本批 `flutter test --no-pub --reporter expanded test/backend_api_services_test.dart test/backend_resource_ownership_test.dart`：13 項通過。首次跑出原有 401 整合測例失敗，辨識到 `BackendAuthService` 預先放入的受管理 Token；修正辨識後重跑全綠。
- 全專案 `dart analyze`：無問題。
- 全量 `flutter test --no-pub --reporter expanded test`：304 項通過、8 項失敗。失敗分布於 `home_v2_bento_cards_responsive_test.dart` 1 項、`widget_test.dart` 5 項、`phase22_case_library_wikipedia_portals_test.dart` 1 項、`phase23_case_library_wikipedia_reading_experience_test.dart` 1 項；主要是現有畫面文字／元素斷言與一項 `pumpAndSettle` 逾時。這些畫面程式均未在本批修改，不能以本批綠燈宣稱全量已通過；是否在基準 commit 即失敗尚未隔離驗證。
