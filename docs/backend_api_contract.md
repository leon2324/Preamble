# MylawApp 後端 API 契約草案

> 台灣繁體中文教學註解：這份文件是 Flutter App 與後端/RAG 服務之間的「對齊表」。
> 目前 App 已預留 `LAWAPP_API_BASE_URL`，正式後端上線後請優先符合這裡的路徑與欄位，
> 這樣前端不需要大改就能接上真正的 AI、資料庫與法條索引。

## 1. 使用者權限

- `guest`：免登入，可看公開內容、試問 AI 一次。
- `member`：已登入，可保存 AI 對話、收藏追蹤、保存測驗與學習進度。
- `subscriber`：訂閱者，可使用進階文件產生、完整案例卷宗、較高 AI/RAG 額度。

建議後端以 Bearer token 回傳使用者層級，Flutter 端已透過 `AuthTokenProvider` 預留。

## 2. AI 法律助理

### `GET /law-assistant/conversations`

回傳最近對話。

```json
{
  "conversations": [
    {
      "id": "c_123",
      "title": "押金問題",
      "preview": "房東說押金不能退",
      "updatedAt": "2026-04-25T08:00:00Z",
      "categoryLabel": "租屋",
      "messages": []
    }
  ]
}
```

### `POST /law-assistant/conversations`

建立新對話。

```json
{
  "prompt": "房東不退押金，我可以怎麼處理？"
}
```

回傳 `LawAssistantConversation`。助理訊息建議固定提供：

```json
{
  "answer": {
    "problemDirection": "這可能是租賃押金返還爭議。",
    "relatedContent": "可先查看租約、點交紀錄、扣款明細與民法租賃相關規定。",
    "nextStep": "請補充租約押金條款、退租日期、房東扣款理由。"
  }
}
```

## 3. 法規資料與 RAG

- 台灣法規來源：法務部全國法規資料庫
  - `https://law.moj.gov.tw/api/ch/law/json`
  - `https://law.moj.gov.tw/api/ch/order/json`
- App 端已可直接讀取上述資料；正式 RAG 建議由後端排程同步、斷詞、建立向量索引。
- 回答時請回傳引用法規名稱、條號、來源網址與更新日期。

## 4. 裁判書與案例庫

- 司法院裁判書開放 API 需平台帳密換 token，且官方規格有服務時段限制。
- 建議由後端排程同步 `Auth`、`JList` 與 `JDoc/{jid}`，不要由 Flutter 端直接打司法院帳密 API。
- 不建議以網路爬蟲直接抓取司法院裁判書網頁作為正式資料來源；裁判書可能異動或移除，後端應依官方 API 的 `jid` 覆蓋與移除規則維護資料庫。
- 案例庫資料建議欄位：
  - `title`
  - `summary`
  - `country`
  - `category`
  - `timeline`
  - `legalIssues`
  - `sourceLinks`
  - `privacyLevel`

## 5. 文件產生

第一版 Flutter 已有本地模板。正式後端可新增：

- `POST /documents/drafts`
- `GET /documents/drafts/{id}`
- `POST /documents/drafts/{id}/export`

文件產生必須固定附上：內容僅為草稿，不構成律師正式法律意見。
