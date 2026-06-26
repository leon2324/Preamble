# 緒言 Preamble

緒言 Preamble 是一個以台灣使用者為核心的法律知識、法規查詢與社會案件資料 App。產品方向是把「不知道該查什麼」的生活法律問題，整理成可學習、可追蹤、可收藏、可產生文件草稿的 MVP。

## 功能總覽

- 首頁：法律知識入口、今日資訊、學習任務與工具導流。
- 學習：主題文章、測驗、法規資料庫與小法助入口。
- 搜尋：跨小法助、法條、案件、文件工具與官方資料的混合搜尋架構。
- 記事：大家都在討論、案件角度、案件時光機、那年今日與案件資料館。
- 追蹤：追蹤案件、法條、主題與關鍵字的 MVP 骨架。
- 文件工具：存證信函、租屋押金、車禍、消費爭議、勞資爭議草稿。
- 會員狀態：guest / member / subscriber、demo 登入、深色模式、案件收藏與筆記草稿。

## 技術架構

- Flutter app：Material 3、`flutter_screenutil` 響應式尺寸、SharedPreferences 本機狀態。
- Repository 層：AI、法規、案件、搜尋、追蹤、文件與官方資料都保留 mock/backend 切換。
- Service 層：`LawAssistantApiService`、`StatuteApiService`、`MojFeedService` 負責實際資料來源。
- 後端設定：Flutter 端只讀 `LAWAPP_API_BASE_URL`，不得放 OpenAI、Gemini 或其他 provider API key。

## Flutter SDK

本機開發使用：

```bash
/Users/babychen/Documents/flutter/bin/flutter --version
```

專案 `pubspec.yaml` 目前設定：

```yaml
environment:
  sdk: ^3.5.2
```

## 安裝與執行

```bash
/Users/babychen/Documents/flutter/bin/flutter pub get
/Users/babychen/Documents/flutter/bin/flutter run
```

設定正式後端：

```bash
/Users/babychen/Documents/flutter/bin/flutter run \
  --dart-define=LAWAPP_API_BASE_URL=https://api.example.com
```

未設定 `LAWAPP_API_BASE_URL` 時，App 會顯示 backend not configured 提示並使用 mock data。

## 測試

```bash
/Users/babychen/Documents/flutter/bin/dart analyze lib test
/Users/babychen/Documents/flutter/bin/flutter test
```

## 資料夾說明

- `lib/app/`：全域 AppState、會員權限與本機狀態。
- `lib/components/`：首頁、搜尋與共用 UI 元件。
- `lib/data/`：models、services、repositories、mock data。
- `lib/pages/`：五大分頁與子流程。
- `docs/`：API 契約、資料來源、roadmap、盤點文件。
- `test/`：model、service、repository 與 widget tests。

## 法律免責聲明

本 App 所有 AI 回答、法規解釋、案件整理與文件草稿，均僅供法律知識參考，不構成正式法律意見；具體案件請諮詢律師或專業人士。

## Roadmap

- Phase 1：可用 MVP，完成 mock/backend 切換、共用狀態、核心 repository 與測試。
- Phase 2：接正式後端、RAG、法規與裁判書同步。
- Phase 3：會員、訂閱、額度、追蹤同步與文件進階產生。
- Phase 4：上架前 QA、無障礙、效能與資料授權檢查。
- Phase 5：正式營運、內容維護、客服與法務流程。

