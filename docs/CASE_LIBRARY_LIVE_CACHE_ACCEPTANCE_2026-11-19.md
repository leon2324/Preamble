# 案件庫正式來源與本機快取驗收（2026-11-19）

## 問題與資料契約

上一批已修正正式案件清單成功回傳空陣列後改顯示種子案件的情況，但案件庫初始化仍會把內建種子寫進 SQLite，完整詳情也會先回傳 SQLite 舊內容。這可能使正式來源已更新、刪除或暫時失敗時，使用者仍看到與雲端不一致的案件正文。

本批將案件正文與本機使用者標記分開處理：正式模式的案件內容以雲端成功回傳為準；SQLite 僅保留收藏及追蹤標記，並作為成功回傳後的本機快取。未設定來源的展示模式繼續使用內建案例。

## 修改範圍

| 路徑 | 正式來源已設定 | 來源未設定 |
| --- | --- | --- |
| 初始化 | 不同步內建種子到 SQLite，也不把 SQLite 舊列表載入正式推薦快取 | 保留原有種子與 SQLite 展示流程 |
| 分頁／推薦 | 第一頁正式無篩選清單建立推薦快照；之後成功空清單清除舊推薦；並發時只有最後發起的請求可更新快照 | 保留本機推薦 |
| 同步查找 | 只回傳當次工作階段已驗證的正式案件；未取得時使用既有「載入中」佔位模型 | 可查內建種子 |
| 完整詳情 | 每次向雲端確認正文；本機只合併收藏／追蹤標記；SQLite 寫入失敗不丟失已取得的正文 | 可先用完整 SQLite 快取，再用本機來源 |
| 指定 ID 不存在 | 雲端錯誤向上傳遞；詳情頁用既有共用錯誤狀態提供重試 | 本機查無 ID 明確失敗，不回傳第一筆無關案件 |

案件入口頁先取得正式清單再產生 Hero 推薦；指定案件不在推薦清單時，向正式來源讀取完整詳情。詳情頁在正式讀取失敗時不再顯示傳入頁面的舊案件正文。上述頁面修改限於資料取得及錯誤狀態分支，未變更版面、顏色、尺寸或元件樣式。

## 驗證

- `/Users/babychen/Documents/flutter/bin/cache/dart-sdk/bin/dart analyze`：`No issues found!`。
- `flutter test --no-pub --reporter expanded test/supabase_source_contract_test.dart test/data_fallback_policy_test.dart test/backend_api_services_test.dart`：27 項通過；其後單獨重跑 `test/supabase_source_contract_test.dart` 9 項通過，含新增的並發舊回應測例。合計 28 項相異測例已通過，未再合併重跑一次。涵蓋正式空清單、失敗、詳情雲端確認、推薦快照清除、並發順序、未設定來源與遺失 ID。
- `flutter test --no-pub --reporter expanded test/phase23_case_library_wikipedia_reading_experience_test.dart`：8 項通過、1 項失敗。失敗為 `Renders authentic landmark case with Wikipedia Infobox & TOC and no mock wording` 的「體驗法官裁判心證」文字斷言；同測例已列於先前全量測試失敗清單，尚未隔離基準 Commit 驗證。
- `git diff --check`：通過。
- 尚未連正式 Supabase、進行遠端資料寫入、migration、CI、push、部署或真機驗收。

## 留待後續的契約

- `caseLibraryCasesSeed` 也用於部分獨立的編輯型內容及 generated `caseLibraryCases` getter；本批不把這些內容誤當成正式分頁結果。若產品要求正式模式全面移除靜態編輯內容，需先定義內容來源與導頁空狀態，再調整 generated 資料及相關頁面。
- SQLite 舊資料表沒有來源欄位；本批不刪除使用者資料或執行 migration。正式內容不再直接由舊快取返回，但仍可從同 ID 的舊列保留收藏／追蹤標記。
- 正式模式的 Hero 及詳情錯誤分支尚未做可注入服務的 widget 層測試；目前由資料層契約測試與靜態分析保護。

## Antigravity 接手

1. 先查 `git log -1` 和 `git status --short`，再讀 `docs/AI_HANDOVER.md` 及 `docs/IMPLEMENTATION_STATUS.md` 最新快照。
2. 保留「正式正文由雲端確認；本機只合併使用者標記」的契約，不要恢復先讀 SQLite 正文或空結果補種子案件的路徑。
3. 若要處理 generated `caseLibraryCases` 與靜態編輯內容，先建立內容來源標示及資料等價驗證；不要把 `time_recorder` 狀態套入本專案。
