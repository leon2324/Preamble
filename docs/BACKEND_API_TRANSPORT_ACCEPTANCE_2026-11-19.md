# 後端 API 傳輸層重構驗收（2026-11-19）

## 範圍與基準

- 專案僅 `lawapp`；分支 `redesign/home-responsive-carousel`，基準 Commit `09ce31a`。
- 本批只調整 `lib/data` 的共用傳輸邏輯、`lib/app/app_state.dart` 的 Token 介面 import、契約測試與交接文件，沒有修改 UI、前端展示、圖片、資料庫或遠端服務。
- 上一批全量 Flutter 測試為 304 項通過、8 項畫面／案件頁 widget 測例失敗；該結果不是本批測試結果，也未證明 8 項在基準 Commit 已失敗。

## 設計與修改

1. `AuthTokenProvider` 與 `GuestAuthTokenProvider` 移至 `lib/data/common/auth_token_provider.dart`。`PreambleState` 改為直接依賴共用介面；小法助原路徑繼續 `export` 兩個型別，保護現有呼叫端的 import 相容性。
2. `PreambleApiTransport` 集中 base URL 與路徑組合、query 參數編碼、每次請求取最新 Token 的 headers，以及後端錯誤訊息解析。它不持有 HTTP client，也不決定領域例外型別。
3. 案件、搜尋、追蹤、官方消息、小法助、配額與文件七個服務保留各自端點、JSON 模型、fallback 判斷與原本的例外型別，改由共用傳輸層處理重複外殼。
4. `test/preamble_api_transport_test.dart` 覆蓋含路徑 base URL、query 編碼、Token 變更、訪客 headers、JSON 錯誤與純文字／HTML 錯誤降級。

## 驗證

- 全專案 `dart analyze`：`No issues found!`。
- 聚焦 Flutter 測試：`backend_api_services_test.dart`、`backend_resource_ownership_test.dart`、`preamble_api_transport_test.dart`、`law_assistant_streaming_test.dart` 與 `mvp_foundation_test.dart` 共 31 項通過；另跑 `phase11_document_tools_test.dart` 2 項通過，合計 33 項。
- 上一批全量測試的 8 項 UI／案件頁失敗本批未重跑；本批不改 UI，不能宣稱全量綠燈。
- 新增的共用 Dart 檔與契約測試已執行 `dart format`；`git diff --check` 無問題。其餘既有大檔未為格式化而擴大差異。

## 限制與後續

- 本批保留原本的 mock 回退政策與使用者可見結果。下一批需先定義「未設定後端、遠端空結果、遠端錯誤」各自的資料來源契約，避免修改展示語意時無法區分設計決策與錯誤。
- 尚未做正式後端 JWT、CI、真機、部署或遠端資料驗收；實際 Git 與遠端狀態以接手時查核為準。
