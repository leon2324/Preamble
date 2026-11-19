# lawapp 實作狀態

更新日期：2026-11-19。狀態只代表本機 `lawapp`，不代表遠端部署。

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
