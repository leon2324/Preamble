# LawApp Gemini Context

這是給 Gemini 理解 LawApp 並撰寫參賽計劃書用的精簡專案脈絡，不是完整可 build 專案。

保留內容：
- `lib/`：主要 Flutter UI、頁面、資料模型、mock data 與前端狀態。
- `assets/`：保留非字型、非 abandoned 的圖片與 SVG 資產，方便理解畫面風格。
- `docs/`、`README.md`：專案背景、資料來源、API 與 roadmap。
- `pubspec.yaml` / `analysis_options.yaml`：提供套件與專案設定脈絡。

刻意排除內容：
- `build/`、`.dart_tool/`、`.git/`：建置快取與 Git 歷史。
- `assets/fonts/`：大型字型檔，會讓匯入大小暴增。
- `prototype/` 與 abandoned 圖片：舊草稿與棄用素材，容易干擾目前 production UI 判讀。

請 Gemini 先閱讀 `PROJECT_BRIEF_FOR_GEMINI.md`，再根據 `lib/`、`docs/`、`README.md` 產出參賽計劃書。
