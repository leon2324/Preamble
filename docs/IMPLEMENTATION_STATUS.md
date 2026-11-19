# lawapp 實作狀態

更新日期：2026-11-19。狀態只代表本機 `lawapp`，不代表遠端部署。

## 本批：正式來源空結果與錯誤（基準 `06e1ef6`）

| 項目 | 狀態 | 依據／限制 |
| --- | --- | --- |
| 正式來源空清單 | 本機已修 | 案件、法規、官方消息、全站搜尋、學習文章、生活筆記、每日專題、案件庫分頁照實回空；生活筆記、學堂及案件館不再將固定內容加回遠端清單。 |
| 正式來源失敗 | 本機已修 | 錯誤向上傳遞；生活筆記頁不再於錯誤時顯示示範卡。 |
| 未設定來源／明確 demo | 保留既有流程 | 未設定來源可展示本機內容；四個共用 repository 只有明確指定 `demo` 才允許正式空／錯誤回退。 |
| 每日專題 ID | 本機已修 | 從雲端存在的 ID 分頁取得後按日期抽選，不再猜 1–1000。 |
| 全專案靜態分析 | 通過 | `dart analyze`：`No issues found!`。 |
| 聚焦 Flutter 測試 | 34 項通過 | 來源空結果、HTTP 失敗、後端 API、搜尋與首頁 feed；詳見 [日期化驗收](LIVE_SOURCE_EMPTY_RESULTS_ACCEPTANCE_2026-11-19.md)。 |
| 相關 widget 測試 | 6 項通過、1 項既有失敗 | 學堂與案件館 portal 測例通過；案件入口頁 `pumpAndSettle timed out`，見日期化驗收。 |
| 全量 UI／正式來源／部署 | 未執行 | 上批全量仍為 304 通過、8 失敗；本批沒有正式 Supabase、CI、push 或部署。 |

以下為上一批歷史狀態；本批預設已非 demo。

## 本批：資料來源回退契約（基準 `501fe97`）

| 項目 | 狀態 | 依據／限制 |
| --- | --- | --- |
| 預設展示模式 | 本機已實作 | 案件、法規、官方消息與搜尋保留原有回退；未改 App 入口或 UI。 |
| 明確 strict 模式 | 本機已實作，尚未於正式 App 啟用 | 未設定報錯、遠端空清單照實回空、遠端失敗傳出原始錯誤。 |
| 全專案靜態分析 | 通過 | `dart analyze`：`No issues found!`。 |
| 聚焦 Flutter 測試 | 30 項通過 | 涵蓋四個 repository 的三種來源結果、後端 API、基礎流程與搜尋；詳見日期化驗收。 |
| 全量 UI 測試 | 本批未重跑 | 上一批 304 項通過、8 項失敗，不能宣稱全量通過。 |
| Git／遠端／部署 | 本批已 Commit；遠端未執行 | 基準 `501fe97`；最新 SHA 以 `git log -1` 查核。未 push、未建立 PR、未部署。 |

以下為上一批狀態；本批結果請以上方及日期化驗收為準。

## 本批：共用 API 傳輸層（基準 `09ce31a`）

| 項目 | 狀態 | 依據／限制 |
| --- | --- | --- |
| Token 介面與七個 API 服務 | 本機已重構 | `AuthTokenProvider` 位於 `lib/data/common`；共用 URI、headers 與錯誤訊息解析；保留各服務的端點及例外型別。 |
| UI 與前端展示 | 本批未修改 | 只改 `lib/data`、`lib/app/app_state.dart` 的 import、測試與文件。 |
| 全專案靜態分析 | 通過 | `dart analyze`，`No issues found!`。 |
| 聚焦 Flutter 測試 | 33 項通過 | API 契約、資源所有權、共用傳輸層、小法助、基礎流程與文件 repository；結果見 `docs/BACKEND_API_TRANSPORT_ACCEPTANCE_2026-11-19.md`。 |
| Git／遠端／部署 | 本批已 Commit；遠端未執行 | 基準 `09ce31a`，最新 SHA 以 `git log -1` 查核；未 push、未建立 PR、未部署。 |

以下為上一批狀態；本批測試請看上方及日期化驗收。

| 項目 | 狀態 | 依據／限制 |
| --- | --- | --- |
| UI 與前端展示 | 本批未修改 | 修改限於 `lib/data`、後端測試與文件。 |
| 並發 401 Token 刷新 | 本機已修 | 共用單次刷新 Future；獨立 Dart smoke check 已通過。 |
| 不可重送請求 | 本機已修 | 串流請求保留 401，不嘗試重播；獨立 Dart smoke check 已通過。 |
| HTTP client 所有權 | 本機已修、聚焦測試通過 | 自建資源由建立者釋放，外部注入由呼叫端管理。 |
| 全專案靜態分析 | 通過 | `/Users/babychen/Documents/flutter/bin/cache/dart-sdk/bin/dart analyze`，`No issues found!`。 |
| Flutter 後端回歸測試 | 13 項通過 | `flutter test --no-pub --reporter expanded test/backend_api_services_test.dart test/backend_resource_ownership_test.dart`。首輪既有 401 測例曾失敗，已修正並重跑通過。 |
| Flutter 全量測試 | 304 項通過、8 項失敗 | `flutter test --no-pub --reporter expanded test` 完整執行。失敗集中在既有首頁／記事／案件時光機／Wikipedia 頁面的 widget 斷言與 `pumpAndSettle`；本批未修改上述 UI 檔。不能宣稱全量測試通過。 |
| Git Commit | 本批已提交 | 使用英文標題與中英雙語詳細內文；最新 SHA 以 `git log -1` 查核。尚未 push 或建立 PR。 |
| 真實後端／JWT、手機、CI、部署 | 未執行 | 本批沒有遠端環境操作。 |

下一優先事項：資料來源回退契約、共用 HTTP 傳輸層、大型靜態資料的等價拆分。詳細規劃見 `docs/AI_HANDOVER.md` 與 `docs/BACKEND_ARCHITECTURE_AUDIT_2026-11-19.md`。
