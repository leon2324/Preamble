import 'package:lawapp/components/home/home_content.dart';

/// 首頁各區塊使用的假資料。
///
/// 正式串後端資料前，可先在這裡快速調整文案與資料量，驗證畫面是否撐得住。
const homeNewsItems = [
  HomeNewsItem(
    badge: '快訊',
    title: '法務部攜手金管會，打擊新型態科技詐騙管道',
  ),
  HomeNewsItem(
    badge: '公告',
    title: '犯罪被害人權益保障新制，全面溫暖陪伴被害家屬',
  ),
  HomeNewsItem(
    badge: '服務',
    title: '檢察機關推動數位申辦服務，提升便民司法效率',
  ),
  HomeNewsItem(
    badge: '宣導',
    title: '法務部結合社區與校園，深耕無毒家園宣導活動',
  ),
  HomeNewsItem(
    badge: '更生',
    title: '更生保護業務啟動轉型，多元協助更生人重返社會',
  ),
  HomeNewsItem(
    badge: '立法',
    title: '積極推動科技偵查法案，完備執法機關偵查工具',
  ),
  HomeNewsItem(
    badge: '人權',
    title: '精進人權保障制度，法務部公布國家人權報告',
  ),
  HomeNewsItem(
    badge: '交流',
    title: '加強台美司法互助，法務部派員赴美深化交流',
  ),
  HomeNewsItem(
    badge: '執法',
    title: '反賄選宣導全面啟動，檢警調廉全力維護選舉公正',
  ),
  HomeNewsItem(
    badge: '公益',
    title: '行政執行署推動綠色執法，結合公益關懷弱勢義務人',
  ),
];

final homeNewsletterItems = [
  ..._featuredTrapNoteItems,
  ...List<HomeNewsletterItem>.generate(515, _buildGeneratedTrapNote),
];

const _featuredTrapNoteItems = [
  HomeNewsletterItem(
    title: '狗咬人，主人要賠？！',
    summary: '根據《民法》第195條，飼主有責任控管動物。若狗咬人，可能得賠醫藥費、精神損失費等。',
    tip: '小提醒：遛狗記得繫牽繩，也別忘記植晶片喔！',
    likes: '300+',
    shares: '100+',
    comments: '100+',
    downloads: '500+',
    category: '養狗',
  ),
  HomeNewsletterItem(
    title: '自拍時拍到別人臉，侵權了？！',
    summary: '公共場所攝影雖普遍，但若未經同意特寫他人，或將照片用於營利、醜化，恐侵犯肖像權。',
    tip: '小提醒：上傳前替路人臉部做適度遮蔽，尊重隱私也保護自己。',
    likes: '220+',
    shares: '80+',
    comments: '64+',
    downloads: '180+',
    category: '拍照隱私',
  ),
  HomeNewsletterItem(
    title: '租屋提前解約，押金一定拿不回來嗎？',
    summary: '押金並不是房東想扣就能扣，仍須看契約條款、損害情形與是否有明確依據。',
    tip: '小提醒：簽約前先拍照存證，退租時比較不容易吃虧。',
    likes: '174+',
    shares: '92+',
    comments: '58+',
    downloads: '210+',
    category: '租屋',
  ),
  HomeNewsletterItem(
    title: '網購退貨，拆封就一定不能退嗎？',
    summary: '七天鑑賞期不是試用期，但也不是商家一句「拆封不退」就能完全排除。',
    tip: '小提醒：退貨前保留商品狀態、訂單頁面與客服對話。',
    likes: '260+',
    shares: '86+',
    comments: '77+',
    downloads: '240+',
    category: '網購',
  ),
  HomeNewsletterItem(
    title: '車禍後先道歉，會不會變成承認全責？',
    summary: '事故責任仍要看證據、肇責判斷與調解內容；現場可以關心傷勢，但別急著簽不清楚的文件。',
    tip: '小提醒：先報警、拍照、交換資料，再談和解。',
    likes: '310+',
    shares: '120+',
    comments: '88+',
    downloads: '330+',
    category: '交通',
  ),
];

HomeNewsletterItem _buildGeneratedTrapNote(int index) {
  final category = _trapNoteCategories[index % _trapNoteCategories.length];
  final topic = _trapNoteTopics[index % _trapNoteTopics.length];
  final action = _trapNoteActions[index % _trapNoteActions.length];
  final scenario = _trapNoteScenarios[index % _trapNoteScenarios.length];
  final number = index + 1;

  return HomeNewsletterItem(
    title: '$category避坑筆記 $number：$scenario',
    summary: '$topic 時，常見風險不是只有誰對誰錯，也包含證據、期限、通知方式與是否留下紀錄。',
    tip: '小提醒：$action，先把事情說清楚，再決定要協商、申訴或查法規。',
    likes: '${120 + (index * 7) % 880}+',
    shares: '${32 + (index * 5) % 260}+',
    comments: '${18 + (index * 3) % 190}+',
    downloads: '${80 + (index * 11) % 920}+',
    category: category,
  );
}

const _trapNoteCategories = [
  '最近',
  '養狗',
  '租屋',
  '拍照隱私',
  '網購',
  '交通',
  '職場',
  '家庭',
  '校園',
  '醫療',
  '旅遊',
  '社群',
  '金融',
  '裝修',
  '鄰里',
  '外送',
  '寵物',
  '二手交易',
  '活動票券',
  '個資',
];

const _trapNoteTopics = [
  '簽約前沒有看清楚條款',
  '對方只用口頭承諾',
  '付款後沒有留下收據',
  '發生爭議時急著刪訊息',
  '把私人照片傳到公開群組',
  '借名登記或代收款項',
  '社群留言太快下結論',
  '共同生活費沒有記帳',
  '臨時取消預約或訂單',
  '被要求先匯保證金',
  '收到存證信函卻放著不理',
  '車禍現場沒有拍照',
  '租屋點交沒有錄影',
  '公司要求加班但沒有紀錄',
  '寵物造成他人受傷或損害',
  '網購商品瑕疵但包裝已丟',
  '旅遊住宿描述與實際不符',
  '醫療說明聽不懂卻直接簽名',
  '裝修追加費沒有白紙黑字',
  '孩子在校衝突沒有保存通知',
];

const _trapNoteScenarios = [
  '先確認誰有證據',
  '不要只相信截圖',
  '付款紀錄很重要',
  '合約附件也要保存',
  '期限比情緒更急',
  '先問清楚再簽名',
  '公開發文前停一下',
  '退貨規則要先看',
  '維修報價要留底',
  '和解內容要寫完整',
  '證人資訊要記下來',
  '通話後補一封文字確認',
  '別急著承認全部責任',
  '先把損害拍清楚',
  '請對方提出明細',
  '保固範圍要看文件',
  '個資不要隨手傳',
  '報案資料要留存',
  '對方身分要核對',
  '先查官方來源',
];

const _trapNoteActions = [
  '截圖、拍照、保存原始檔',
  '把日期、地點、對話對象記下來',
  '請對方用文字確認說法',
  '先看契約，再談感受',
  '保留付款、匯款與發票資料',
  '不要在情緒高點公開指名道姓',
  '重要文件簽名前先拍照留存',
  '先確認申訴或請求期限',
  '要求明細、收據或報價單',
  '把口頭約定補成文字紀錄',
  '先找官方資料，不只看轉傳訊息',
  '把證據存在雲端或寄給自己備份',
];

const homeTrackedTopics = [
  HomeTrackedTopic(
    hashtag: '#財劃法',
    title: '財劃法大出包，16縣市藍委明在北市召開記者會',
    summary: '最近 2 小時內有 6 則新動態',
  ),
  HomeTrackedTopic(
    hashtag: '#柯文哲',
    title: '柯文哲7000萬交保，黃國昌更新FB：接主席回家',
    summary: '你追蹤的議題今天討論度上升',
  ),
];

const homeDiscussionFeed = HomeDiscussionFeed(
  collectionSlogan: '資料收集顯示：以下熱度由司法新聞、Google 與社群討論訊號彙整而成（mock data）。',
  topics: [
    HomeDiscussionTopic(
      headline: '即將釋憲，究竟廢死還是維持死刑？',
      title: '即將釋憲，究竟廢死還是維持死刑？',
      heatScore: 92,
      rank: 1,
      dayChangePercent: 12,
      weekRankDelta: 2,
      overview:
          '近日因定讞執行死刑槍決的 77 名囚犯提出死刑違憲，因此最高院提出釋憲，而結果將於 2023.09.20 在司法院官方 YouTube 全程直播公布。',
      heatLabel: '下列資料是由此系統查詢次數、Google、社群話題趨勢資料提供，原因為AI判斷',
      trendPoints: [
        HomeDiscussionTrendPoint(dateLabel: '9/6', volumeLabel: '10 次'),
        HomeDiscussionTrendPoint(
          dateLabel: '9/7',
          volumeLabel: '50 次',
          annotation: '司法院直播消息',
        ),
        HomeDiscussionTrendPoint(
          dateLabel: '9/8',
          volumeLabel: '200 次',
        ),
        HomeDiscussionTrendPoint(
          dateLabel: '9/9',
          volumeLabel: '50 次',
          annotation: '他案新聞分流',
        ),
        HomeDiscussionTrendPoint(
          dateLabel: '9/10',
          volumeLabel: '300 次',
          annotation: '媒體重提釋憲',
        ),
        HomeDiscussionTrendPoint(
          dateLabel: '9/11',
          volumeLabel: '420 次',
          annotation: '網紅大量發言',
        ),
        HomeDiscussionTrendPoint(
          dateLabel: '9/12',
          volumeLabel: '500 次',
          annotation: '社群聲量維持',
        ),
        HomeDiscussionTrendPoint(
          dateLabel: '9/13',
          volumeLabel: '800 次',
          annotation: '今日',
        ),
      ],
      timelineEvents: [
        HomeDiscussionTimelineEvent(
          pointIndex: 1,
          timeLabel: '9/7 09:40',
          description: '司法院釋出直播預告，話題快速升溫。',
          impactLabel: '+18%',
        ),
        HomeDiscussionTimelineEvent(
          pointIndex: 3,
          timeLabel: '9/9 13:20',
          description: '他案新聞分流，討論聲量短暫回落。',
          impactLabel: '-9%',
        ),
        HomeDiscussionTimelineEvent(
          pointIndex: 4,
          timeLabel: '9/10 20:30',
          description: '媒體重新聚焦釋憲內容，留言量回升。',
          impactLabel: '+14%',
        ),
        HomeDiscussionTimelineEvent(
          pointIndex: 5,
          timeLabel: '9/11 22:10',
          description: '網紅密集評論，社群互動持續攀高。',
          impactLabel: '+11%',
        ),
      ],
      poll: HomeDiscussionPoll(
        prompt: '這一區只在要投票時出現',
        options: [
          HomeDiscussionPollOption(label: '支持廢死', votes: 1342),
          HomeDiscussionPollOption(label: '反對廢死', votes: 1820),
          HomeDiscussionPollOption(label: '還不確定', votes: 954),
        ],
      ),
      latestComment: HomeDiscussionComment(
        content: '我覺得死刑應該保留，因為一命償一命。',
        submittedAt: '2025.09.13 21:10:07',
        userHandle: '@user5525',
      ),
      tags: ['#刑法', '#死刑', '#人權', '#憲法釋憲'],
    ),
    HomeDiscussionTopic(
      headline: '詐騙集團橫行，政府擬強化金融監管',
      title: '詐騙集團橫行，政府擬強化金融監管',
      heatScore: 88,
      rank: 2,
      dayChangePercent: 9,
      weekRankDelta: 1,
      overview: '近期詐騙金流案件攀升，政府預告提升高風險帳戶審查與跨行通報機制，引發「防詐效率」與「金融隱私」的兩派討論。',
      heatLabel: '下列資料是由此系統查詢次數、Google、社群話題趨勢資料提供，原因為AI判斷',
      trendPoints: [
        HomeDiscussionTrendPoint(
          dateLabel: '9/6',
          volumeLabel: '120 次',
          annotation: '詐騙案新聞連發',
        ),
        HomeDiscussionTrendPoint(
          dateLabel: '9/8',
          volumeLabel: '260 次',
          annotation: '受害案例短影音擴散',
        ),
        HomeDiscussionTrendPoint(
          dateLabel: '9/10',
          volumeLabel: '430 次',
          annotation: '金管會預告新機制',
        ),
        HomeDiscussionTrendPoint(
          dateLabel: '9/12',
          volumeLabel: '620 次',
          annotation: '直播節目集中討論',
        ),
        HomeDiscussionTrendPoint(
          dateLabel: '9/13',
          volumeLabel: '760 次',
          annotation: '熱門關鍵字衝上前段',
        ),
      ],
      timelineEvents: [
        HomeDiscussionTimelineEvent(
          pointIndex: 1,
          timeLabel: '9/8 11:05',
          description: '受害者案例短影音擴散，搜尋量上升。',
          impactLabel: '+13%',
        ),
        HomeDiscussionTimelineEvent(
          pointIndex: 2,
          timeLabel: '9/10 15:40',
          description: '金管會預告新機制，論壇討論翻倍。',
          impactLabel: '+16%',
        ),
        HomeDiscussionTimelineEvent(
          pointIndex: 3,
          timeLabel: '9/12 21:00',
          description: '直播節目連線受害者，留言量衝高。',
          impactLabel: '+10%',
        ),
      ],
      poll: null,
      latestComment: HomeDiscussionComment(
        content: '希望強化凍結效率，但要有更快的申訴流程。',
        submittedAt: '2025.09.13 20:47:51',
        userHandle: '@lin245',
      ),
      tags: ['#詐騙', '#金融監管', '#個資', '#金流'],
    ),
    HomeDiscussionTopic(
      headline: '《勞基法》第 32 條修正通過，週工時改上限',
      title: '《勞基法》第 32 條修正通過，週工時改上限',
      heatScore: 79,
      rank: 3,
      dayChangePercent: 5,
      weekRankDelta: -1,
      overview: '法條修正後，企業排班彈性提高，但勞方擔心工時延長與補休落空。勞資雙方在「效率」與「過勞風險」之間意見分歧。',
      heatLabel: '下列資料是由此系統查詢次數、Google、社群話題趨勢資料提供，原因為AI判斷',
      trendPoints: [
        HomeDiscussionTrendPoint(
          dateLabel: '9/6',
          volumeLabel: '80 次',
          annotation: '修法草案外流',
        ),
        HomeDiscussionTrendPoint(
          dateLabel: '9/8',
          volumeLabel: '180 次',
          annotation: '企業端表態支持',
        ),
        HomeDiscussionTrendPoint(
          dateLabel: '9/10',
          volumeLabel: '390 次',
          annotation: '勞團發聲反彈',
        ),
        HomeDiscussionTrendPoint(
          dateLabel: '9/12',
          volumeLabel: '540 次',
          annotation: '電視政論節目加溫',
        ),
        HomeDiscussionTrendPoint(
          dateLabel: '9/13',
          volumeLabel: '670 次',
          annotation: '修法條文懶人包瘋傳',
        ),
      ],
      timelineEvents: [
        HomeDiscussionTimelineEvent(
          pointIndex: 1,
          timeLabel: '9/8 10:15',
          description: '企業端表態支持彈性排班，熱度墊高。',
          impactLabel: '+8%',
        ),
        HomeDiscussionTimelineEvent(
          pointIndex: 2,
          timeLabel: '9/10 18:20',
          description: '勞團反彈聲量發酵，議題再升溫。',
          impactLabel: '+12%',
        ),
        HomeDiscussionTimelineEvent(
          pointIndex: 3,
          timeLabel: '9/12 20:45',
          description: '政論節目集中討論，討論量維持高檔。',
          impactLabel: '+6%',
        ),
      ],
      poll: null,
      latestComment: HomeDiscussionComment(
        content: '如果要彈性，至少要把加班費與補休機制寫更清楚。',
        submittedAt: '2025.09.13 19:33:20',
        userHandle: '@may_work',
      ),
      tags: ['#勞基法', '#工時', '#加班', '#勞權'],
    ),
    HomeDiscussionTopic(
      headline: '多起職場性騷擾案曝光，性平教育成焦點',
      title: '多起職場性騷擾案曝光，性平教育成焦點',
      heatScore: 74,
      rank: 4,
      dayChangePercent: 3,
      weekRankDelta: 0,
      overview: '多起案件在短時間內曝光，企業內部通報流程與主管責任被放大檢視，社群上出現大量「如何保護申訴人」的實務討論。',
      heatLabel: '下列資料是由此系統查詢次數、Google、社群話題趨勢資料提供，原因為AI判斷',
      trendPoints: [
        HomeDiscussionTrendPoint(
          dateLabel: '9/6',
          volumeLabel: '40 次',
          annotation: '首波爆料文出現',
        ),
        HomeDiscussionTrendPoint(
          dateLabel: '9/8',
          volumeLabel: '160 次',
          annotation: '企業內訓議題發酵',
        ),
        HomeDiscussionTrendPoint(
          dateLabel: '9/10',
          volumeLabel: '280 次',
          annotation: '受害者經驗串擴散',
        ),
        HomeDiscussionTrendPoint(
          dateLabel: '9/12',
          volumeLabel: '510 次',
          annotation: '名人聲援帶動話題',
        ),
        HomeDiscussionTrendPoint(
          dateLabel: '9/13',
          volumeLabel: '690 次',
          annotation: '制度改革訴求升溫',
        ),
      ],
      timelineEvents: [
        HomeDiscussionTimelineEvent(
          pointIndex: 1,
          timeLabel: '9/8 14:10',
          description: '企業內訓與申訴流程議題持續發酵。',
          impactLabel: '+7%',
        ),
        HomeDiscussionTimelineEvent(
          pointIndex: 2,
          timeLabel: '9/10 23:00',
          description: '受害者經驗串擴散，社群討論集中。',
          impactLabel: '+9%',
        ),
        HomeDiscussionTimelineEvent(
          pointIndex: 3,
          timeLabel: '9/12 19:25',
          description: '名人聲援後，改革訴求再次升高。',
          impactLabel: '+8%',
        ),
      ],
      poll: null,
      latestComment: HomeDiscussionComment(
        content: '匿名通報後若沒有保護措施，很多人還是不敢說。',
        submittedAt: '2025.09.13 22:05:44',
        userHandle: '@eva_legal',
      ),
      tags: ['#職場性平', '#性騷擾', '#申訴機制', '#勞動法'],
    ),
  ],
  actionLabels: ['查看更多留言', '追蹤', '進入議題'],
);

const homeQuizQuestions = [
  HomeQuizQuestion(
    question: '請問下列何者為公共危險罪之定義？',
    options: [
      HomeQuizOption(
        title: 'A. 指人民在公共場所大聲喧嘩，影響他人安寧之行為。',
        isCorrect: false,
      ),
      HomeQuizOption(
        title: 'B. 指對不特定或多數人的生命、身體、財產安全造成危險之行為。',
        isCorrect: true,
      ),
      HomeQuizOption(
        title: 'C. 指對特定個人施以毆打，造成其身體受傷的行為。',
        isCorrect: false,
      ),
      HomeQuizOption(
        title: 'D. 指公務員利用職務上機會，非法圖利自己或他人之行為。',
        isCorrect: false,
      ),
    ],
    hint: '提示：公共危險罪的關鍵在於是否危及不特定或多數人的公共安全。',
    explanation:
        '刑法上的公共危險罪，重點在於危及「不特定或多數人」的公共安全，例如放火、決水、汽車酒駕肇事等；而 A 是違反社會秩序維護法、C 屬於傷害罪、D 屬於貪污治罪條例相關罪名。',
    termExplainMap: {
      '公共危險罪': '公共危險罪是指對不特定或多數人的生命、身體、財產安全造成危險之犯罪類型。',
      '不特定或多數人': '不是只針對某一個人，而是可能影響到社會上不特定群眾或多數人的情境。',
      '決水': '決水是指故意或疏忽使水大量流出、氾濫，足以造成公共危險的行為。',
      '汽車酒駕肇事': '飲酒後駕車並造成危險或事故，屬於公共安全風險極高的典型行為。',
    },
  ),
  HomeQuizQuestion(
    question: '下列何者最符合「正當防衛」的成立要件？',
    options: [
      HomeQuizOption(title: 'A. 對過去的侮辱心生不滿，隔天報復對方。', isCorrect: false),
      HomeQuizOption(title: 'B. 面對正在進行的不法侵害，為保護自己而做必要反擊。', isCorrect: true),
      HomeQuizOption(title: 'C. 為了嚇阻未來可能發生的衝突，先動手攻擊。', isCorrect: false),
      HomeQuizOption(title: 'D. 因雙方口角升高情緒，主動以暴力壓制對方。', isCorrect: false),
    ],
    hint: '提示：重點在於「現在正在發生」的不法侵害，以及防衛手段是否必要。',
    explanation:
        '正當防衛必須針對現在正在發生的不法侵害，且防衛行為須具有必要性，不能藉機報復或預先攻擊。A 與 C 都不是面對當下侵害，D 則屬主動攻擊。',
    termExplainMap: {
      '正當防衛': '對於現在不法侵害，為保護自己或他人權利所為的必要防衛行為。',
      '不法侵害': '違反法律、正在侵害法益的行為，例如正在毆打、搶奪。',
      '必要性': '防衛手段必須限於足以排除侵害的範圍，不能過度。',
    },
  ),
  HomeQuizQuestion(
    question: '下列何者最可能成立誹謗罪？',
    options: [
      HomeQuizOption(title: 'A. 在網路上散布足以毀損他人名譽的不實指控。', isCorrect: true),
      HomeQuizOption(title: 'B. 私下告知律師自己的訴訟擔憂。', isCorrect: false),
      HomeQuizOption(title: 'C. 在日記裡記錄自己對同事的不滿。', isCorrect: false),
      HomeQuizOption(title: 'D. 向警方如實陳述自己親眼所見的案件經過。', isCorrect: false),
    ],
    hint: '提示：看是否「向第三人散布」會損害他人名譽的內容。',
    explanation:
        '誹謗罪重點在於向第三人散布足以毀損他人名譽的事。A 符合公開散布與名譽損害的要素；B、C 沒有對外散布，D 則屬向有權機關陳述事實。',
    termExplainMap: {
      '誹謗罪': '以言語、文字或其他方式散布足以毀損他人名譽之事的犯罪。',
      '名譽': '一個人在社會上受到他人評價與信賴的利益。',
      '第三人': '不是當事人自己，也不是被害人本人，而是其他會接收到訊息的人。',
    },
  ),
  HomeQuizQuestion(
    question: '若網購商品有瑕疵，消費者最合理的主張是什麼？',
    options: [
      HomeQuizOption(title: 'A. 只能摸摸鼻子認賠，賣家一定不用負責。', isCorrect: false),
      HomeQuizOption(title: 'B. 可依契約與消保規範主張退換貨、減價或修補。', isCorrect: true),
      HomeQuizOption(title: 'C. 只要不喜歡都能無條件要求賣家賠三倍。', isCorrect: false),
      HomeQuizOption(title: 'D. 只能在社群抱怨，不能向平台或主管機關申訴。', isCorrect: false),
    ],
    hint: '提示：商品瑕疵通常和契約責任、消保規範以及退換貨權益有關。',
    explanation:
        '商品有瑕疵時，消費者通常可以依契約與消費者保護相關規範，主張修補、減價、解除契約或退換貨。A、D 過度限縮權利，C 則誇大法效果。',
    termExplainMap: {
      '商品瑕疵': '商品在品質、功能或安全上不符合契約約定或通常可期待狀態。',
      '減價': '買受人保留商品，但要求降低價金。',
      '解除契約': '使契約關係消滅，雙方回復原狀，例如退貨退款。',
    },
  ),
  HomeQuizQuestion(
    question: '下列何者最符合「侵占」的概念？',
    options: [
      HomeQuizOption(title: 'A. 將自己保管中的他人財物據為己有。', isCorrect: true),
      HomeQuizOption(title: 'B. 在公開場合大聲辱罵他人。', isCorrect: false),
      HomeQuizOption(title: 'C. 在街上撿到無主物品後帶回家。', isCorrect: false),
      HomeQuizOption(title: 'D. 因一時衝動毀損自己購買的手機。', isCorrect: false),
    ],
    hint: '提示：侵占通常發生在原本就合法持有、保管他人財物的情況。',
    explanation:
        '侵占的關鍵，是行為人原本就持有或保管他人財物，之後卻違反義務將之據為己有。A 最符合；B 是侮辱範疇，C 不一定構成侵占，D 處分自己財物不涉及侵占。',
    termExplainMap: {
      '侵占': '將自己持有的他人財物，違法變成自己所有的行為。',
      '據為己有': '把本來不是自己的東西，當作自己的來處分或占有。',
      '保管': '依約或基於某種關係暫時持有、照看他人財物。',
    },
  ),
  HomeQuizQuestion(
    question: '租屋押金的法律性質，下列何者較正確？',
    options: [
      HomeQuizOption(title: 'A. 房東可以自由決定全部沒收，不需任何理由。', isCorrect: false),
      HomeQuizOption(title: 'B. 押金是擔保租客履約，是否扣抵仍須有依據。', isCorrect: true),
      HomeQuizOption(title: 'C. 押金一旦交付，法律上即轉為房東贈與所得。', isCorrect: false),
      HomeQuizOption(title: 'D. 押金與租金完全相同，提前解約就當作全部租金。', isCorrect: false),
    ],
    hint: '提示：押金的核心功能是「擔保」，不是房東想扣就扣。',
    explanation:
        '押金主要是擔保租客履行租約義務，例如未付租金或造成損害時可依法扣抵。B 最正確；A、C、D 都把押金性質說得太絕對或錯誤。',
    termExplainMap: {
      '押金': '承租人交付給出租人，作為履約與損害擔保的金錢。',
      '履約': '依契約約定完成自己應盡的義務，例如按時繳租、善良使用房屋。',
      '扣抵': '以原本保留的金錢抵償特定債務或損害。',
    },
  ),
  HomeQuizQuestion(
    question: '下列何者最可能侵犯他人肖像權？',
    options: [
      HomeQuizOption(title: 'A. 在公共場所拍到路人背影，未特意辨識身份。', isCorrect: false),
      HomeQuizOption(title: 'B. 未經同意特寫他人臉部並作為廣告素材使用。', isCorrect: true),
      HomeQuizOption(title: 'C. 對著自己拍攝自拍照。', isCorrect: false),
      HomeQuizOption(title: 'D. 將自己畫的虛構人物插畫發布在社群。', isCorrect: false),
    ],
    hint: '提示：關鍵在於是否可辨識特定個人，以及是否未經同意而利用。',
    explanation: '肖像權保護的是可辨識個人外貌被拍攝、公開或利用的利益。B 屬未經同意而作商業使用，侵害風險最高；A、C、D 都與此不同。',
    termExplainMap: {
      '肖像權': '個人對自己外貌影像是否被拍攝、公開、利用所享有的權利。',
      '特寫': '把攝影鏡頭集中在特定人物身上，使其能被明確辨識。',
      '商業使用': '將照片或影像用於廣告、宣傳、販售等營利目的。',
    },
  ),
  HomeQuizQuestion(
    question: '民事損害賠償通常是為了達成什麼目的？',
    options: [
      HomeQuizOption(title: 'A. 處罰所有犯錯的人，使其一定入獄。', isCorrect: false),
      HomeQuizOption(title: 'B. 補償被害人所受損害，回復其原本利益狀態。', isCorrect: true),
      HomeQuizOption(title: 'C. 宣告社會道德譴責，不涉及金錢。', isCorrect: false),
      HomeQuizOption(title: 'D. 由警察直接決定賠償金額並強制執行。', isCorrect: false),
    ],
    hint: '提示：民事責任與刑事處罰不同，重點在補償損害。',
    explanation:
        '民事損害賠償主要在填補被害人的損失，使其盡量回復到未受侵害前的狀態，而不是以入獄等刑罰方式處理。A、C、D 都把民事責任混同於其他制度。',
    termExplainMap: {
      '損害賠償': '以金錢或其他方式填補被害人因侵權或違約所受損失。',
      '民事責任': '私人間因侵權、違約等所生的法律責任，通常以賠償為主。',
      '回復原狀': '盡可能恢復受害前的財產或利益狀態。',
    },
  ),
  HomeQuizQuestion(
    question: '下列何者較可能屬於個人資料？',
    options: [
      HomeQuizOption(title: 'A. 完全無法連結到特定人的隨機數字。', isCorrect: false),
      HomeQuizOption(title: 'B. 能識別特定個人的姓名、電話與地址。', isCorrect: true),
      HomeQuizOption(title: 'C. 已公開超過十年的歷史年表。', isCorrect: false),
      HomeQuizOption(title: 'D. 純粹統計平均值且無法回推個人。', isCorrect: false),
    ],
    hint: '提示：看資料是否能直接或間接辨識出特定個人。',
    explanation:
        '個人資料的核心在於是否能識別特定自然人。姓名、電話、地址等都可能直接識別個人，因此 B 最符合；其餘選項不是無法辨識，就是不具個人指向性。',
    termExplainMap: {
      '個人資料': '能直接或間接識別特定個人的各種資訊。',
      '識別': '透過資訊判斷出某個資料是屬於哪一位特定個人。',
      '自然人': '在法律上指真實存在的人，不包括法人或公司。',
    },
  ),
  HomeQuizQuestion(
    question: '如果收到法院寄來的支付命令，較合理的第一步是什麼？',
    options: [
      HomeQuizOption(title: 'A. 完全不理會，時間久了自然失效。', isCorrect: false),
      HomeQuizOption(title: 'B. 先確認內容與期限，必要時在法定期間內提出異議。', isCorrect: true),
      HomeQuizOption(title: 'C. 立即在社群網站公開對方個資反擊。', isCorrect: false),
      HomeQuizOption(title: 'D. 只需打電話給寄件人，不需要任何正式回應。', isCorrect: false),
    ],
    hint: '提示：這類文書通常有「法定期間」，不能只靠口頭處理。',
    explanation:
        '收到支付命令後，應先確認內容是否屬實、期限何時屆至，若有爭執需在法定期間內提出異議，否則可能確定並進入強制執行。A、C、D 都忽略正式程序的重要性。',
    termExplainMap: {
      '支付命令': '債權人向法院聲請，要求債務人給付金錢或其他代替物的程序文書。',
      '異議': '對法院命令或主張表達不同意見，要求進一步審理。',
      '法定期間': '法律明定必須在多久內完成某項行為的期限。',
    },
  ),
  HomeQuizQuestion(
    question: '下列何者最符合「過失」的概念？',
    options: [
      HomeQuizOption(title: 'A. 明知違法仍故意去做。', isCorrect: false),
      HomeQuizOption(title: 'B. 應注意而未注意，導致損害或危害發生。', isCorrect: true),
      HomeQuizOption(title: 'C. 完全不可避免的天然災害。', isCorrect: false),
      HomeQuizOption(title: 'D. 依法執行公務的合法行為。', isCorrect: false),
    ],
    hint: '提示：過失不是故意，但仍有「本來應該注意」的義務。',
    explanation:
        '過失是指行為人本來有注意義務，也有能力注意，卻因疏忽未注意，造成損害結果。A 屬故意，C 不一定有人為可歸責，D 則是合法行為。',
    termExplainMap: {
      '過失': '因疏忽、未盡注意義務而造成結果的心理狀態。',
      '注意義務': '法律或生活經驗上，行為人應採取適當注意的要求。',
      '故意': '明知或預見結果發生而希望或放任其發生。',
    },
  ),
  HomeQuizQuestion(
    question: '下列何者較可能構成恐嚇？',
    options: [
      HomeQuizOption(title: 'A. 因情緒激動而提高音量說話。', isCorrect: false),
      HomeQuizOption(title: 'B. 揚言要對他人生命、身體或財產造成危害，使其害怕。', isCorrect: true),
      HomeQuizOption(title: 'C. 禮貌地要求對方還錢。', isCorrect: false),
      HomeQuizOption(title: 'D. 向朋友抱怨某人讓自己不開心。', isCorrect: false),
    ],
    hint: '提示：重點在於是否以惡害通知使對方心生畏懼。',
    explanation: '恐嚇的核心在於以將來惡害相告，讓對方產生害怕心理。B 最符合；A、C、D 即使讓人不舒服，也未必達到恐嚇要件。',
    termExplainMap: {
      '恐嚇': '以惡害通知他人，使對方心生畏懼的行為。',
      '惡害': '對生命、身體、自由、名譽或財產等不利益的威脅內容。',
      '畏懼': '因擔心威脅成真而產生恐懼不安的心理狀態。',
    },
  ),
  HomeQuizQuestion(
    question: '下列何者最符合「偽造文書」的基本概念？',
    options: [
      HomeQuizOption(title: 'A. 自己寫私人筆記備忘。', isCorrect: false),
      HomeQuizOption(title: 'B. 冒用他人名義製作文書，足以生損害於公眾或他人。', isCorrect: true),
      HomeQuizOption(title: 'C. 將自己寫的文章刪改重寫。', isCorrect: false),
      HomeQuizOption(title: 'D. 在草稿紙上胡亂塗鴉。', isCorrect: false),
    ],
    hint: '提示：要看是否有冒用他人名義，以及文書是否足以發生法律或社會信賴效果。',
    explanation: '偽造文書通常涉及冒用他人名義、製作具有一定證明或表示作用的文書，並足以生損害。B 最符合；A、C、D 都缺乏關鍵要素。',
    termExplainMap: {
      '偽造文書': '冒用他人名義製作文書，足以生損害於公眾或他人的犯罪。',
      '文書': '能以文字、符號等方式表示意思或證明事項的資料。',
      '足生損害': '行為具有造成他人或社會信賴受損的可能性。',
    },
  ),
  HomeQuizQuestion(
    question: '在路上撿到皮夾後，較合適的處理方式是什麼？',
    options: [
      HomeQuizOption(title: 'A. 直接把現金拿走，其餘丟棄。', isCorrect: false),
      HomeQuizOption(title: 'B. 交給警察或其他適當機關處理。', isCorrect: true),
      HomeQuizOption(title: 'C. 先放著當作自己的備用金。', isCorrect: false),
      HomeQuizOption(title: 'D. 拍照上傳失主證件內容到社群找人。', isCorrect: false),
    ],
    hint: '提示：重點在於遺失物不是自己的財物，應走合法招領程序。',
    explanation: '拾得遺失物後，應依法律交由警察或適當機關處理，讓失主有機會領回。A、C 可能涉及侵占遺失物，D 則還可能侵犯個資與隱私。',
    termExplainMap: {
      '遺失物': '原所有人不慎喪失占有的物品。',
      '拾得': '撿到他人遺失物並實際取得占有。',
      '招領': '透過合法程序公告或保管，讓失主領回遺失物。',
    },
  ),
  HomeQuizQuestion(
    question: '下列何者最符合「契約成立」的基本概念？',
    options: [
      HomeQuizOption(title: 'A. 雙方意思表示一致，對主要內容達成合意。', isCorrect: true),
      HomeQuizOption(title: 'B. 只要其中一方心裡想好就當然成立。', isCorrect: false),
      HomeQuizOption(title: 'C. 必須一律到法院辦理才算有效。', isCorrect: false),
      HomeQuizOption(title: 'D. 只有用手寫紙本才算契約。', isCorrect: false),
    ],
    hint: '提示：關鍵是當事人之間是否對重要內容達成一致。',
    explanation:
        '契約成立的核心在於雙方當事人對契約主要內容達成合意，不一定都要紙本、法院或特定形式。A 正確；B、C、D 都把契約成立講得過度狹隘。',
    termExplainMap: {
      '契約': '當事人間基於合意而發生法律效果的約定。',
      '意思表示': '將內心意願以言語、文字或行為向外表達。',
      '合意': '雙方對重要內容達成一致認知。',
    },
  ),
  HomeQuizQuestion(
    question: '公司若蒐集員工個資，較合理的做法是什麼？',
    options: [
      HomeQuizOption(title: 'A. 無限制蒐集與工作完全無關的所有資訊。', isCorrect: false),
      HomeQuizOption(title: 'B. 於特定目的範圍內蒐集，並告知用途與使用方式。', isCorrect: true),
      HomeQuizOption(title: 'C. 將員工個資任意上傳公開網頁方便查詢。', isCorrect: false),
      HomeQuizOption(title: 'D. 完全不需要任何管理措施。', isCorrect: false),
    ],
    hint: '提示：個資蒐集要有特定目的，也要注意告知與保護義務。',
    explanation:
        '蒐集員工個資應有特定目的，並盡到告知義務、合理使用與安全維護義務。B 最符合個資保護的基本原則；A、C、D 都過度擴張或忽略保護義務。',
    termExplainMap: {
      '特定目的': '蒐集個資時必須具體、明確且合法的使用目的。',
      '告知義務': '蒐集個資時向當事人說明蒐集目的、類別、利用方式等資訊的責任。',
      '安全維護': '採取適當措施避免個資外洩、竄改或被不當使用。',
    },
  ),
  HomeQuizQuestion(
    question: '下列何者最可能屬於業務上的保密義務？',
    options: [
      HomeQuizOption(title: 'A. 將客戶未公開資料轉傳給朋友聊天。', isCorrect: false),
      HomeQuizOption(title: 'B. 對執行職務中知悉的客戶資訊負保密責任。', isCorrect: true),
      HomeQuizOption(title: 'C. 看到公開新聞後向同事討論。', isCorrect: false),
      HomeQuizOption(title: 'D. 轉述自己對市場的個人觀察。', isCorrect: false),
    ],
    hint: '提示：重點在於資訊是否因職務而取得，且未經授權不得外流。',
    explanation:
        '業務上的保密義務通常來自職務、契約或法令，要求從業人員對工作中知悉的未公開資訊保密。B 正確；A 明顯違反保密義務，C、D 則不一定涉及受保護資訊。',
    termExplainMap: {
      '保密義務': '對特定資訊負有不任意揭露、傳播或利用的法律或契約責任。',
      '未公開資訊': '尚未對外公開、具有一定敏感性或價值的資訊。',
      '授權': '經權利人或有權決定者同意而為某種行為。',
    },
  ),
  HomeQuizQuestion(
    question: '交通事故發生後，較適當的初步處理是什麼？',
    options: [
      HomeQuizOption(title: 'A. 立刻離開現場，避免麻煩。', isCorrect: false),
      HomeQuizOption(title: 'B. 先確保安全、報警並保留現場與證據。', isCorrect: true),
      HomeQuizOption(title: 'C. 先刪除行車紀錄器影片以免被看到。', isCorrect: false),
      HomeQuizOption(title: 'D. 在未確認狀況前先公開指責對方人格。', isCorrect: false),
    ],
    hint: '提示：事故後首重安全、通報與證據保存。',
    explanation:
        '交通事故發生後，應先確保人員安全、必要時報警或叫救護車，並保留現場與相關證據。B 最適當；A、C、D 可能讓責任更不利或造成其他問題。',
    termExplainMap: {
      '保留現場': '在不影響安全前提下維持事故狀態，利於釐清責任。',
      '證據': '可以證明事故經過、責任或損害程度的資料，例如照片、影片、證人說法。',
      '通報': '向警方或有關機關報告事故情形。',
    },
  ),
  HomeQuizQuestion(
    question: '下列何者最能說明「著作權」保護的對象？',
    options: [
      HomeQuizOption(title: 'A. 單純的事實本身，例如今天下雨。', isCorrect: false),
      HomeQuizOption(title: 'B. 具有原創性的表達，例如文章、插畫、攝影作品。', isCorrect: true),
      HomeQuizOption(title: 'C. 所有人都知道的數學公式。', isCorrect: false),
      HomeQuizOption(title: 'D. 法律規定的條文本身。', isCorrect: false),
    ],
    hint: '提示：著作權保護的是「表達」，不是抽象概念或單純事實。',
    explanation: '著作權保護的是具原創性的表達成果，例如文字、圖像、音樂、攝影等，而不是單純事實、公式或法規本身。B 最正確。',
    termExplainMap: {
      '著作權': '創作者對其原創表達成果所享有的權利。',
      '原創性': '作品具有創作者自己的精神創作，不是單純抄襲他人。',
      '表達': '把想法、概念用具體形式呈現出來的內容。',
    },
  ),
  HomeQuizQuestion(
    question: '如果被別人借名辦手機門號，較需要注意的是什麼？',
    options: [
      HomeQuizOption(title: 'A. 只要是朋友借用，就完全沒有法律風險。', isCorrect: false),
      HomeQuizOption(title: 'B. 門號名義人可能仍需承擔費用、通知或其他法律風險。', isCorrect: true),
      HomeQuizOption(title: 'C. 門號借出後，任何責任都會自動轉給實際使用人。', isCorrect: false),
      HomeQuizOption(title: 'D. 門號與個人完全無關，愛借誰都可以。', isCorrect: false),
    ],
    hint: '提示：借名行為常讓名義人仍被外界認定為負責對象。',
    explanation:
        '即使是他人實際使用，門號若登記在自己名下，仍可能面臨帳單、通知、調查或其他責任風險，因此 B 最合理。A、C、D 都過度輕忽借名風險。',
    termExplainMap: {
      '借名': '由他人出借自己的名義、帳戶或身份資料供另一人使用。',
      '名義人': '在文件、契約或登記上被記載為權利義務主體的人。',
      '法律風險': '因行為或狀態可能引發責任、糾紛或不利益的可能性。',
    },
  ),
  HomeQuizQuestion(
    question: '下列何者較符合「勞動契約」中的工資概念？',
    options: [
      HomeQuizOption(title: 'A. 雇主高興才給的任意獎賞，完全無任何規則。', isCorrect: false),
      HomeQuizOption(title: 'B. 勞工因提供勞務而獲得的報酬。', isCorrect: true),
      HomeQuizOption(title: 'C. 員工自己墊付差旅費後的報銷。', isCorrect: false),
      HomeQuizOption(title: 'D. 朋友私下送的禮物。', isCorrect: false),
    ],
    hint: '提示：工資與「提供勞務」之間有直接對價關係。',
    explanation: '工資是勞工因提供勞務而由雇主給付的報酬，具有勞務對價性。B 最符合；C 屬費用報銷，A、D 則不具典型工資性質。',
    termExplainMap: {
      '勞動契約': '勞工提供勞務，雇主給付工資的契約。',
      '工資': '勞工因提供勞務所獲得的報酬。',
      '對價': '一方提供某項給付，另一方因此支付相對應報酬。',
    },
  ),
  HomeQuizQuestion(
    question: '收到陌生連結要求輸入帳號密碼時，較合理的做法是什麼？',
    options: [
      HomeQuizOption(title: 'A. 直接輸入，反正看起來很像官方網站。', isCorrect: false),
      HomeQuizOption(title: 'B. 先確認來源真偽，不任意點擊或輸入敏感資訊。', isCorrect: true),
      HomeQuizOption(title: 'C. 把連結轉傳給所有朋友一起試。', isCorrect: false),
      HomeQuizOption(title: 'D. 截圖後公開自己的密碼提醒別人小心。', isCorrect: false),
    ],
    hint: '提示：防詐的基本原則是先查證來源，不要急著輸入敏感資料。',
    explanation: '面對陌生連結時，應先確認來源與網址真偽，不應直接輸入帳號密碼或其他敏感資訊。B 最安全合理；其餘做法都可能使風險擴大。',
    termExplainMap: {
      '敏感資訊': '一旦外洩可能造成重大損害的資料，如密碼、驗證碼、身分證號。',
      '釣魚連結': '冒充可信來源，引誘使用者輸入帳號密碼或下載惡意內容的連結。',
      '查證': '透過官方管道、客服或可信資訊確認真偽。',
    },
  ),
  HomeQuizQuestion(
    question: '下列何者最符合「和解」的意義？',
    options: [
      HomeQuizOption(title: 'A. 雙方透過互相讓步解決爭議。', isCorrect: true),
      HomeQuizOption(title: 'B. 一方單方面宣布自己贏了。', isCorrect: false),
      HomeQuizOption(title: 'C. 只要吵架後不再聯絡就叫和解。', isCorrect: false),
      HomeQuizOption(title: 'D. 必須每次都由法院判決才能叫和解。', isCorrect: false),
    ],
    hint: '提示：和解通常建立在雙方都有某種程度退讓與同意。',
    explanation: '和解的核心在於雙方對爭議事項互相讓步，藉此終止糾紛。A 正確；B、C、D 都忽略了雙方合意與讓步這個本質。',
    termExplainMap: {
      '和解': '當事人間藉由互相讓步，解決既有爭議的合意。',
      '爭議': '雙方對事實、權利義務或責任範圍有不同看法的情況。',
      '讓步': '為了達成解決而在主張上作部分退讓。',
    },
  ),
];
