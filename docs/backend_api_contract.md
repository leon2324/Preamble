# 緒言 Preamble 後端 API 契約

Flutter 端只呼叫 緒言 Preamble 後端，不保存任何 OpenAI、Gemini 或其他 AI provider API key。後端 base URL 由 `PREAMBLE_API_BASE_URL` 注入；未設定時 App 使用 mock mode。

## 通用規則

- Auth：`Authorization: Bearer <token>`
- Content-Type：`application/json; charset=utf-8`
- 時間格式：ISO 8601 UTC
- 錯誤格式：

```json
{
  "error": {
    "code": "quota_exceeded",
    "message": "今日額度已用完",
    "requestId": "req_123"
  }
}
```

## Auth

- `POST /auth/demo/member`
- `POST /auth/demo/subscriber`
- `POST /auth/sign-out`
- `POST /auth/refresh`

回傳：

```json
{
  "token": "jwt-or-session-token",
  "user": {
    "id": "u_123",
    "displayName": "王小明",
    "email": "ming@example.com",
    "accessTier": "member",
    "createdAt": "2026-05-05T00:00:00Z",
    "updatedAt": "2026-05-05T00:00:00Z",
    "usageQuota": 20,
    "usedQuotaToday": 3
  }
}
```

## User Profile

- `GET /users/me`
- `PATCH /users/me`
- `GET /users/me/quota`

## Law Assistant

- `GET /law-assistant/conversations`
- `POST /law-assistant/conversations`
- `GET /law-assistant/conversations/{id}`
- `POST /law-assistant/conversations/{id}/messages`

Conversation 欄位：

- `id`
- `title`
- `preview`
- `categoryLabel`
- `updatedAt`
- `messages`
- `sourceCitations`
- `disclaimer`

Message 欄位：

- `id`
- `role`: `user` / `assistant` / `system`
- `content`
- `createdAt`
- `answer`
- `citations`
- `warningText`

Answer 欄位：

- `problemDirection`
- `relatedContent`
- `nextStep`
- `evidenceNeeded`
- `possibleLegalIssues`
- `recommendedActions`
- `disclaimer`

Citation 欄位：

- `title`
- `sourceType`: `statute` / `judgment` / `official` / `news` / `other`
- `url`
- `publishedAt`
- `updatedAt`
- `lawName`
- `articleNumber`

## Statutes

- `GET /statutes`
- `GET /statutes/search?q=&lawName=&articleNumber=&category=`
- `GET /statutes/{id}`

必備欄位：`codeName`、`articleNumber`、`articleText`、`lawUrl`、`category`、`updatedDate`、`isRepealed`、`sourceName`、`sourceType`、`plainLanguageSummary`、`relatedKeywords`。

## Cases

- `GET /cases/featured`
- `GET /cases/archive?era=&category=`
- `GET /cases/search?q=`
- `GET /cases/{id}`

必備欄位：`id`、`title`、`subtitle`、`summary`、`oneSentenceTakeaway`、`country`、`location`、`happenedAt`、`updatedAt`、`status`、`category`、`tags`、`timeline`、`legalIssues`、`relatedStatutes`、`sourceLinks`、`privacyLevel`、`isMockData`、`era`。

## Search

- `GET /search?q=&type=`

Result 欄位：`id`、`title`、`subtitle`、`snippet`、`type`、`destination`、`score`、`source`、`updatedAt`、`tags`。

## Following

- `GET /following`
- `POST /following/cases/{id}`
- `DELETE /following/cases/{id}`
- `POST /following/topics/{id}`
- `DELETE /following/topics/{id}`
- `POST /following/statutes/{id}`
- `DELETE /following/statutes/{id}`
- `POST /following/saved/cases/{id}`
- `DELETE /following/saved/cases/{id}`
- `POST /following/saved/statutes/{id}`
- `DELETE /following/saved/statutes/{id}`
- `POST /following/saved/articles/{id}`
- `DELETE /following/saved/articles/{id}`
- `GET /following/updates`

`GET /following` 回傳 `FollowingSummary`，需同時包含
`followedCaseIds`、`followedStatuteIds`、`followedTopicIds`、`followedKeywords`、
`savedCaseIds`、`savedStatuteIds`、`savedArticleIds`、`notificationEnabled`、
`createdAt`、`updatedAt`。全站搜尋、法規頁與我的 緒言 Preamble 都使用這份 summary。

## Documents

- `GET /documents/templates`
- `POST /documents/drafts`
- `GET /documents/drafts/{id}`
- `POST /documents/drafts/{id}/export`

文件回傳必須包含 `disclaimer`，並標示是否由模板或 AI 產生。

## Official Feeds

- `GET /official-feeds/news`
- `GET /official-feeds/press-releases`
- `GET /official-feeds/announcements`

官方資料只回傳標題、摘要、來源、發布時間與官方連結，不回傳或保存新聞全文。

## Quota

- `GET /quota`
- `POST /quota/consume`

額度應由後端強制執行；Flutter 的 `remainingAiQuota` 只作 UI 提示。

## 固定免責聲明

所有 AI 回答、法條解釋、案件整理與文件草稿都必須包含：

> 本內容僅供法律知識參考，不構成正式法律意見；具體案件請諮詢律師或專業人士。
