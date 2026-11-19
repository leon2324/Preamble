# lawapp Codex／Antigravity 交接入口

此文件僅記錄 `lawapp`。每次接手先核對 Git 現況與最新驗收，不得把同層 `time_recorder` 的分支、測試、資料或部署狀態套用到此專案。

## 目前快照（2026-11-19，後端 API 傳輸層重構）

- 分支 `redesign/home-responsive-carousel`，基準 Commit `09ce31a`。本批將共用 Token 介面移至 `lib/data/common`，讓 `PreambleState` 直接依賴該介面，並讓七個領域服務共用 URI、headers 與錯誤訊息解析；保留原端點、模型、領域例外型別、mock 回退政策與前端展示。
- 共用傳輸物件不擁有 HTTP client；上一批的 client 所有權規則繼續由服務負責。小法助原型別 import 路徑保留 re-export。
- 全專案靜態分析無問題；聚焦測試與文件 repository 測試合計 33 項通過。完整結果與未測事項以[本批日期化驗收](BACKEND_API_TRANSPORT_ACCEPTANCE_2026-11-19.md)為準。本批 Commit SHA 以 `git log -1` 查核；尚未 push、建立 PR、執行遠端 CI、部署或真機驗收。
- 下一步先查本批實際 Commit 與測試，再定義各 repository 的資料來源回退契約；大型靜態資料拆分仍須資料等價驗證。

以下為上一批快照；測試與部署狀態不可代替本批驗證。

## 目前快照（2026-11-19，後端資源生命週期整理）

- 工作分支：`redesign/home-responsive-carousel`；開工基準 HEAD：`0e76821`。本批原始工作區已有上一輪未提交的認證修補、回歸測試與後端盤點文件，這些變更一併納入本批 Commit。
- 修改範圍：`AuthHttpClient` 的並發 401 刷新與不可重送請求保護；主要 API service、文件 repository 與組合型 repository 的資源所有權。只釋放自身建立的依賴，並補上搜尋 repository 自建案件 repository 的釋放。
- UI、前端展示、圖片與 Prototype 均未修改。沒有後端 migration、正式資料寫入或部署。
- 驗證：全專案 `dart analyze` 無問題；後端聚焦測試 13 項通過；全量 Flutter 304 項通過、8 項既有畫面／案件頁 widget 測例失敗。完整證據見 `docs/IMPLEMENTATION_STATUS.md` 與 `docs/BACKEND_ARCHITECTURE_AUDIT_2026-11-19.md`，不得把全量測試記為通過。
- 本批已以單一英文標題、中英雙語內文的 Commit 提交；實際 SHA 以 `git log -1` 查核。沒有 push 或建立 PR；遠端 CI、正式後端 JWT、手機與 production 均未驗收。

## 下次接手

1. 先確認本批 Commit、工作區、最新 CI；後端聚焦 13 項已通過，全量測試 8 項失敗需按 `docs/IMPLEMENTATION_STATUS.md` 核對。修 UI 測例前先確認使用者最新的 UI 修改範圍。
2. 釐清各 repository 在「未設定後端」「遠端空結果」「請求失敗」時的 mock 回退規則。這可能影響展示內容，需保留既有 UI 視覺並建立明確資料來源契約。
3. 整理各 API service 重複的 base URL、headers、錯誤解析，在契約測試保護下逐一遷移。
4. 拆分大型靜態案件資料檔前先建立內容等價驗證，避免無意改動案件資訊。

詳細問題清單與判斷依據見 [後端架構盤點](BACKEND_ARCHITECTURE_AUDIT_2026-11-19.md)。
