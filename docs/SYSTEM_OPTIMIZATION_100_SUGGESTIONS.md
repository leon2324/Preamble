# 緒言 Preamble 系統全方位優化與功能擴充 100 點可行性建議報告

本報告針對 **Preamble 緒言** 法律科技 App 的現有架構、UI/UX 體驗、AI 流式對話、PDF 生成引擎、iOS 生態系整合、離線快取、效能監控與商業化發行，進行深度盤點與升級規劃，列出 100 項精準且可落地的優化建議。

---

## 一、 AI 小法助對話與 Streaming 渲染優化 (1–10)

1. **SSE 重連斷點續傳 (Resumable Streaming)**：當網絡在中途波動中斷時，攜帶 `Last-Event-ID` 重新連線，接續未渲染完畢的 AI 回覆。
2. **多輪對話 Context 窗口自動壓縮**：在長對話中，自動摘要歷史上下文（Context Summarization），減少後端 Token 消耗與傳輸延遲。
3. **動態打字機速度調節**：根據 Prompt 複雜度與語段標點符號，動態調整 15ms~50ms 打字機吐字間隔，模擬自然思考停頓。
4. **法條 Citation 懸浮預覽卡片 (Popover Preview)**：點擊 `[民法第 184 條]` 時不必立即導頁，先跳出 Glassmorphism 懸浮卡片展示條文摘要。
5. **語音對話輸入與 TTS 朗讀**：整合 iOS Speech Framework 與 Text-to-Speech，支援法律諮詢語音輸入與語音朗讀解答。
6. **對話智慧推薦追問 (Suggested Follow-up Prompts)**：在 AI 吐字完成後，根據內容動態產生 3 個延伸法律追問按鈕。
7. **Markdown 表格與公式高亮支援**：優化 `MarkdownBody` 渲染，支援複雜民刑事賠償算式、金額對照表與 Markdown 流暢表格。
8. **對話樹分支 (Conversation Threading)**：支援針對某一次 AI 回覆點擊「重新生成」或「開闢分支提問」，建立多路對話探索。
9. **AI 回覆滿意度反饋機制**：提供 👍/👎 點讚評分與「檢舉/內容修正」按鈕，數據上報後端改善 Prompt 工程。
10. **離線 LLM 本機小模型 Fallback 預研**：研究引入 WebAssembly / On-device Small Language Model（如 MobileLLM），在完全無網時提供基礎法條查詢。

---

## 二、 法律文件工具箱與 PDF 產出優化 (11–20)

11. **PDF 莫蘭迪綠/典雅黑炭主題切換器**：在 PDF 預覽頁提供即時主題調色盤，讓使用者選擇商務黑炭或莫蘭迪綠配色。
12. **電子簽名板與數位印章手繪**：在填表 Step 2 加入 `CustomPainter` 手繪簽名板，將手寫簽名轉為 PNG 嵌入 PDF 簽章區。
13. **多頁面 PDF 自動頁碼與頁尾條碼**：長文件產出時，頁尾自動生成防偽 QR Code 與 `Page X of Y` 印記。
14. **PDF 模板擴充至 20+ 生活常見情境**：新增借據、離婚協議草案、智慧財產授權、智慧租約條款、勞資離職證明等模板。
15. **文字/欄位即時 AI 潤飾與語氣調整**：在填表過程提供「AI 幫我潤色」按鈕，將白話訴求自動轉為正式法律書狀用語。
16. **草稿版本歷史紀錄與對比 (Draft Version Control)**：保存同一份文件的多次修改版本，支援 Side-by-Side 差異比對。
17. **PDF OCR 檔案匯入與解析**：支援上傳既存 PDF / 圖片合約，自動萃取當事人、金額與日期填入表單。
18. **線上合約數位簽署整合 (E-Signature API)**：對接 DocuSign / Adobe Sign 等第三方服務，實現線上發送與加密簽署。
19. **高解析度 PNG / SVG 格式匯出**：除 PDF 外，支援將單頁存證信函或和解書匯出為高畫質圖檔以便 LINE 分享。
20. **法律文件填表完成度評分 (Form Completeness Score)**：動態計算填表完整度百分比，提醒漏填之關鍵證據或日期。

---

## 三、 Apple 生態系與跨平台極致體驗 (21–30)

21. **iOS 17+ Interactive Widget 支持**：點擊桌面 Widget 直接在小工具上勾選「法律待辦事項」，無需開啟 App。
22. **macOS / iPadOS 雙欄響應式佈局 (Master-Detail Layout)**：在 iPad 與 Mac 上自動切換為左側導覽、中間列表、右側內文的三欄寬螢幕介面。
23. **Apple Watch 獨立 Extension**：在 Apple Watch 上閱讀今日判決故事短評與開庭提醒。
24. **Standby Mode 待機模式 Widget**：支援 iOS 17 Standby 橫螢幕待機模式下顯示每日精選法律格言與裁判故事。
25. **VisionOS 空間運算適配**：為 Apple VisionOS 提供空間視窗懸浮體驗與 3D 天平視覺互動。
26. **Lock Screen 鎖定畫面小工具**：在 iPhone 鎖定畫面展示今日倒數開庭天數與緊急法律專線。
27. **Handoff 跨裝置接續處理**：在 iPhone 填寫一半的存證信函，開起 Mac 版 Preamble 即刻無縫接續編輯。
28. **Siri 捷徑自訂 Voice Intents**：支援「Hey Siri，用緒言幫我查民法 184 條」與自訂 Shortcuts 自動化流程。
29. **CoreSpotlight 深度結構化索引**：將判決書摘要、個人草稿與收藏條文自動寫入系統索引，支援 iOS 廣域搜尋。
30. **AirDrop 快速分享草稿與法條**：透過 AirDrop 近場分享 Preamble 原生文件包給附近好友。

---

## 四、 效能、快取與記憶體管理 (31–40)

31. **Isolate 背景多執行緒運算**：將 JSON 龐大解析與 PDF 繪製移至 `Isolate.run()`，防止 UI 主執行緒掉幀 (Jank)。
32. **圖片與 Asset 快取策略**：使用 `cached_network_image` 與 `RepaintBoundary` 減少重繪，維持 60/120 FPS 順暢度。
33. **SQLite 資料庫 Index 索引最佳化**：為 `statutes` 與 `cases` 表的 `code_name`、`article_number` 與 `tags` 欄位建立複合索引。
34. **SharedPreferences 異步批量寫入優化**：改用高效能 KV 儲存庫（如 Hive / Isar / MMKV），提升本地讀寫速度 10 倍以上。
35. **記憶體洩漏 (Memory Leak) 稽核**：為所有 `TextEditingController`、`StreamSubscription` 與 `AnimationController` 建立嚴格 `dispose()` 驗證。
36. **HTTP 響應 ETag 與 304 Cache-Control**：後端傳遞 ETag，前端僅於資料更新時下載新版，節省 80% 網路流量。
37. **Widget 列表 Virtualization (ListView.builder)**：長列表全面採用懶載入機制，控制 DOM 節點數量於 50 個以內。
38. **字體檔根目錄預載與子集化 (Font Subsetting)**：精簡思源宋體/黑體檔案大小，從 10MB+ 壓縮至 2MB 專用字型集。
39. **App 套件大小 (APK / IPA Size) 瘦身**：使用 `--analyze-size` 移除未使用的原生資源與重複 Assets。
40. **啟動時間 (App Launch Time) 最佳化**：將非必要初始化延遲至第一屏渲染完成後 (Deferred Initialization)。

---

## 五、 UI/UX 莫蘭迪視覺與微互動體驗 (41–50)

41. **全站 Dynamic Dark Mode 完美適配**：針對莫蘭迪綠配色調製深色模式，提升夜間閱讀快適度。
42. **Skeletal Loading 微光骨架屏**：所有資料載入階段使用 Shimmer 骨架屏取代傳統 Spinner 轉圈圈。
43. **Custom Micro-Interactions 觸感反饋**：點擊卡片、切換 Tab 或按讚時搭配輕柔 Apple Taptic Haptics。
44. **Hero 頁面元素流暢轉場動畫**：點擊搜尋結果卡片時，標題與封面流暢放大過渡至詳情頁。
45. **Slivers 彈性滾動視差頂欄 (Parallax Header)**：在學習與法規庫大頁面採用 `NestedScrollView` + `SliverAppBar` 視差收合。
46. **無障礙 (Accessibility / WCAG 2.1) 支援**：全面加入 `Semantics` 標籤，支援 VoiceOver 語音導覽與大字體動態縮放。
47. **Pull-to-Refresh 莫蘭迪天平下拉刷新**：客製化下拉刷新動畫，展示莫蘭迪天平動態擺盪。
48. **自訂 UI 主題色彩輪廓 (Custom Accent Themes)**：允許使用者在莫蘭迪綠、海軍藍、玫瑰金與深炭灰間自由切換。
49. **空狀態 (Empty State) 插畫與引導**：無搜尋結果或無草稿時，展示手繪風格插畫與一鍵引導按鈕。
50. **手勢滑動操作 (Swipe Actions)**：草稿列表支援向左滑動刪除、向右滑動快速備份或分享。

---

## 六、 後端 API 串接、安全性與 Token 防禦 (51–60)

51. **JWT Dual Token (Access + Refresh) 自動無感刷新**：強化 `AuthHttpClient`，當無網路時自動排隊請求並在恢復連線後發送。
52. **Certificate Pinning TLS 安全憑證綁定**：在 Flutter 端綁定後端 SSL 憑證公鑰，防止 MITM 中間人攻擊。
53. **數據加密儲存 (Flutter Secure Storage)**：敏感 Token、會員身份與本機草稿加密寫入 iOS Keychain / Android KeyStore。
54. **API Rate Limiting 頻率控制與指數退避**：遭遇 429 Too Many Requests 時，自動執行 Exponential Backoff 重試機制。
55. **GraphQL API 查詢支援預研**：評估引進 GraphQL 替代部分 REST 介面，按需拉取所需欄位，降低 payload 體積。
56. **請求防重發 (Idempotency Key)**：建立草稿或扣減 Quota 的 API 攜帶 `X-Idempotency-Key`，防止重複點擊與扣款。
57. **全站敏感詞與 PII 自動遮蔽 (Data Masking)**：傳送 AI 諮詢前，自動將身分證字號、電話、地址遮蔽為 `[保護資訊]`。
58. **離線請求佇列 (Offline Request Queue)**：在無網狀態下點擊收藏或編輯，自動納入 Queue 並在連線後背景同步。
59. **WebSocket 實時推播與在線狀態**：使用 WebSocket 接收即時法律新聞、開庭提醒與線上客服推播。
60. **自動化 API Contract 契約測試 (Pact Testing)**：建立前端與後端 OpenAPI / Swagger 規格自動比對，防止 API Breaking Changes。

---

## 七、 法規資料庫與全文檢索引擎 (71–70)

61. **法規條文條號快速跳轉 Slider / Wheel**：提供浮動條號滑條，快速滑動至「第 500 條」等特定條文。
62. **立法院修法歷史與新舊條文對照 (Amendment History)**：展示法條條文修正對照表與新舊條文劃線比對。
63. **司法院判決書全文關聯檢索 (Judicial Precedents)**：點擊條文自動關聯此條文最常用之最高法院裁判字號與實務見解。
64. **繁簡體與台語法律用語轉換**：支援台灣繁體中文、通用拼音與法律專業用語自動校正。
65. **全文搜尋語意向量檢索 (Vector Search / RAG)**：後端結合 Vector Database（如 Qdrant / Pinecone），支援白話文「租屋被扣錢」語意搜尋。
66. **常用法規本機離線全文下載包**：允許使用者一鍵下載「六法全書離線包」，無網路時依然可檢索全文。
67. **法條書籤與客製化標籤分類**：支援建立「車禍相關」、「租屋糾紛」等自訂資料夾分類收藏條文。
68. **法條個人畫線筆記與劃線註記**：在法條內文中可劃線（黃、綠、粉）並附加個人學習心得筆記。
69. **判決書重點 AI 自動摘要與簡報生成**：長達 20 頁的裁判書一鍵生成 200 字重點爭點摘要。
70. **法律名詞詞條百科 (Legal Glossary)**：劃線法律專有名詞（如「善意第三人」、「給付遲延」）自動跳出白話解釋。

---

## 八、 使用者會員、點數與 Quota 機制 (71–80)

71. **Apple / Google One-Tap 快速無縫登入**：整合原生 Sign in with Apple 與 Google 登入，一秒完成認證。
72. **In-App Purchase (IAP) 訂閱管理**：整合 `in_app_purchase` 套件，支援訂閱月費/年費 VIP 升級與試用期。
73. **每日免費點數 (Daily Free Quota) 自動發放**：每日登入自動贈送 5 次 AI 免費諮詢，提升用戶留存率 (Retention)。
74. **點數消費明細與發票載具紀錄**：提供完整的點數使用歷史紀錄與電子發票載具設定。
75. **VIP 專屬權益 (如無限次 PDF 匯出與優先 AI 佇列)**：區隔 Free / Pro / Enterprise 會員功能權限矩陣。
76. **好友推薦 (Referral System) 贈點活動**：分享專屬邀請碼給朋友，雙方均可獲得額外 AI 諮詢次數。
77. **跨裝置會員訂閱狀態自動復原 (Restore Purchases)**：一鍵恢復先前在 Apple ID 購買的訂閱資格。
78. **使用者個人頭像與名片卡片客製**：支援上傳大頭貼、個人簡介與專業身分（如律師/法務）。
79. **推播通知時間與頻道偏好設定**：允許使用者自訂每週判決故事推播時間與關閉行銷通知。
80. **帳戶安全與資料一鍵刪除 (GDPR Account Deletion)**：遵照 Apple 指引提供一鍵註銷帳戶與完全清除雲端資料功能。

---

## 九、 自動化測試、CI/CD 與品質監控 (81–90)

81. **Sentry / Crashlytics 全域例外監控**：整合 Sentry / Crashlytics，捕捉 Dart 未處理例外與 Native JS/Swift 崩潰。
82. **Integration Test 全自動化 UI 測試腳本**：使用 `integration_test` 撰寫模擬使用者從登入、對話到 PDF 生成的全流程測試。
83. **GitHub Actions 兩階段 CI/CD Pipeline**：提交 Commit 自動執行 `flutter analyze` 與 `flutter test`，通過後打包 TestFlight。
84. **App Performance Metrics 效能指標監控**：監控 FCP (First Contentful Paint)、冷啟動時間與頁面切換 Latency。
85. **Visual Regression 視覺比對測試 (Golden Tests)**：建立 Golden UI 截圖基準，防止樣式改動導致畫面跑版。
86. **Mock Web Server 自動單元測試**：使用 `http/testing` 模擬所有後端情境（500 錯誤、401 過期、網路逾時）。
87. **Code Coverage 測試覆蓋率自動上報**：整合 Codecov，目標保持核心業務邏輯 Unit Test 覆蓋率 > 85%。
88. **Fastlane 一鍵自動化 App Store 部署**：寫入 `Fastfile` 與 `Matchfile`，自動處理 iOS 憑證與 TestFlight 上架。
89. **Staging / Production 環境切換 (Flavors)**：建立 `dev` / `staging` / `prod` 三種 Flutter Flavors 與各自獨立包名。
90. **使用者行為數據分析 (Privacy-Friendly Analytics)**：整合自建或去識別化 Analytics，分析最熱門法律情境。

---

## 十、 法律合規、數據隱私與商業化擴展 (91–100)

91. **全站法律免責聲明動態鎖定 (Dynamic Disclaimer Standard)**：確保每一頁卡片與匯出檔均有不可關閉之聲明警語。
92. **律師匹配與線上諮詢轉介 (Lawyer Directory)**：在 AI 諮詢完畢後，提供一鍵配對在地合格律師事務所服務。
93. **企業端 (B2B Enterprise) 團隊共用草稿庫**：提供公司法務團隊共用合約草稿與內部法律知識庫。
94. **法律校園與教學模式 (Preamble for Education)**：提供法律系學生專用介面，支援爭點分析與擬答練習。
95. **隱私權政策與服務條款 (Privacy Policy / TOS)**：內建完整的條款閱讀頁與版本變更通知。
96. **符合 ISO 27001 / GDPR 規範之數據安全措施**：資料庫加密傳輸與定期安全漏洞掃描報告。
97. **離線機密模式 (Incognito Mode)**：開啟隱密模式後，所有對話與草稿僅存在 RAM 中，離開頁面立即銷毀。
98. **法律知識社群與裁判故事討論區**：允許使用者針對熱門判決故事發表白話看法與心得交流。
99. **多國語言支援 (Bilingual Localization - EN/ZH)**：為外籍人士提供英文版台灣法律諮詢與草稿範本。
100. **Open API 夥伴生態系平台 (Preamble Developer Portal)**：開放 Preamble 法律引擎 API 給第三方平台整合使用。
