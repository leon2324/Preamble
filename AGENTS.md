# lawapp 開發與交接規範

本檔只適用於 `lawapp`。此專案與同層的 `time_recorder` 完全分開；兩者不得互相修改、複製業務資料或沿用部署狀態。

## 接手順序

1. 先讀 `docs/AI_HANDOVER.md` 的目前快照，再讀 `docs/IMPLEMENTATION_STATUS.md` 與最新日期化驗收紀錄。
2. 查實際分支、HEAD、工作區差異和測試結果；文件中的歷史狀態不能代替現況。
3. 重要新增或調整的程式碼須補上台灣繁體中文、教學介紹型維護註解。
4. 完成一批工程後同步更新交接文件與實作狀態，明確區分本機修改、已 commit、已 push、CI、部署與真機驗收。

## 使用者指定的修改與 Commit 規則

- 使用者要求只動後端與架構時，不改 UI 與前端展示。
- 若使用者要求把頁面與子頁面改成 Prototype 樣式，應先忠實 1:1 還原 Prototype 的比例、尺寸、間距、色彩、圖像與 icon；不自行增加 Material Design、陰影或重新設計。無法實作時先說明原因。
- 使用者說「Commit」時，範圍是上次 Commit 至提出要求時的所有更動；使用英文 Commit 標題，並提供英文與台灣繁體中文的詳細紀錄。提交前確認實際差異，不把機密寫進 Git 或紀錄。
- Flutter SDK 路徑為 `/Users/babychen/Documents/flutter`。
