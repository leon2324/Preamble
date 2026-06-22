import 'package:lawapp/data/mock_data/home/home_mock_data.dart';

class LearningMockArticle {
  const LearningMockArticle({
    required this.badge,
    required this.title,
    required this.summary,
    required this.readTime,
    required this.heroNote,
    required this.keyPoints,
    required this.sections,
    this.category,
    this.quizData,
    this.topicId,
    this.stepNumber,
    this.heroImageUrl,
  });

  final String badge;
  final String title;
  final String summary;
  final String readTime;
  final String heroNote;
  final List<String> keyPoints;
  final List<LearningMockSection> sections;
  final String? category;
  final Map<String, dynamic>? quizData;
  final int? topicId;
  final int? stepNumber;
  final String? heroImageUrl;
}

class LearningMockSection {
  const LearningMockSection({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;
}

class LearningTopicUnit {
  const LearningTopicUnit({
    required this.stepLabel,
    required this.title,
    required this.goal,
    required this.readTime,
    required this.article,
  });

  final String stepLabel;
  final String title;
  final String goal;
  final String readTime;
  final LearningMockArticle article;
}

class LearningRelatedTopic {
  const LearningRelatedTopic({
    required this.title,
    required this.summary,
    required this.focusLabel,
    required this.article,
  });

  final String title;
  final String summary;
  final String focusLabel;
  final LearningMockArticle article;
}

class LearningSupportItem {
  const LearningSupportItem({
    required this.label,
    required this.title,
    required this.summary,
    required this.article,
  });

  final String label;
  final String title;
  final String summary;
  final LearningMockArticle article;
}

class LearningQuizEntryData {
  const LearningQuizEntryData({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
}

class LearningTopicData {
  const LearningTopicData({
    this.topicSlug,
    required this.title,
    required this.summary,
    required this.reasonToLearn,
    required this.unitSummary,
    required this.heroArticle,
    required this.units,
    required this.relatedTopics,
    required this.supportItems,
    required this.quizEntry,
  });

  // 穩定專題識別碼：導頁與歷史紀錄請優先使用它，避免顯示標題改名後找不到專題。
  final String? topicSlug;
  final String title;
  final String summary;
  final String reasonToLearn;
  final String unitSummary;
  final LearningMockArticle heroArticle;
  final List<LearningTopicUnit> units;
  final List<LearningRelatedTopic> relatedTopics;
  final List<LearningSupportItem> supportItems;
  final LearningQuizEntryData quizEntry;
}

const _topicIntroArticle = LearningMockArticle(
  badge: '主專題',
  title: '租屋糾紛怎麼看懂：從押金、解約到修繕責任',
  summary: '這個專題不是只回答押金能不能退，而是帶你把租屋最常見的三個爭點串成完整判斷順序。',
  readTime: '5 個學習單元',
  heroNote: '先搞懂合約、再分清楚損害、最後才談扣款，這樣遇到糾紛時比較不會被一句話帶走。',
  keyPoints: [
    '押金的功能是擔保，不是房東自由沒收的金額。',
    '提前解約、修繕責任、點交紀錄是最常一起出現的爭點。',
    '只要能把順序理清楚，多數租屋問題就不會只停在情緒上。',
  ],
  sections: [
    LearningMockSection(
      title: '這個專題在學什麼',
      body: '它會先帶你建立租屋糾紛的基本判斷架構，再拆進押金、違約金、修繕責任與證據保存四個核心環節。',
    ),
    LearningMockSection(
      title: '為什麼值得先學',
      body: '租屋是最常發生、也最容易因資訊不對稱吃虧的法律情境之一。先把這一題學懂，很多生活爭議都會更有方向。',
    ),
  ],
);

const _unitBasicsArticle = LearningMockArticle(
  badge: '學習單元',
  title: '單元 1：押金的法律角色是什麼？',
  summary: '先把押金看成履約擔保，而不是房東先收走的違約費，後面很多問題才會判斷得準。',
  readTime: '3 分鐘',
  heroNote: '你一旦把押金當成擔保金，而不是懲罰金，後面的爭議就會好拆很多。',
  keyPoints: [
    '押金和租金不是同一件事。',
    '扣押金仍然要有具體依據。',
    '押金能不能扣，和房東有沒有實際損害直接相關。',
  ],
  sections: [
    LearningMockSection(
      title: '先理解押金不是預設罰款',
      body: '押金的作用是擔保租客履行租約義務，例如積欠租金或造成損害時可依法扣抵，不是房東想扣就扣。',
    ),
    LearningMockSection(
      title: '為什麼這一步要先學',
      body: '因為很多人一開始就接受「提前解約就等於押金沒了」，後面討論自然會失焦。',
    ),
  ],
);

const _unitScenariosArticle = LearningMockArticle(
  badge: '學習單元',
  title: '單元 2：提前解約時，哪些情況真的可能被扣錢？',
  summary: '把違約金、空租損失和修繕費拆開來看，才不會把不同性質的主張混成一句「不能退押金」。',
  readTime: '4 分鐘',
  heroNote: '提前解約可能有成本，但不同成本的成立條件不一樣，不是全部都能打包處理。',
  keyPoints: [
    '違約金要先看合約約定。',
    '空租損失通常需要有事實基礎。',
    '修繕費要區分自然耗損和人為損害。',
  ],
  sections: [
    LearningMockSection(
      title: '常見情境怎麼拆',
      body: '提前解約時最常見的三種說法是違約金、空租期間損失與修繕費，但這三件事不一定都會成立，也不一定都能直接由押金扣抵。',
    ),
    LearningMockSection(
      title: '為什麼要分開看',
      body: '因為只要混在一起談，租客很容易被模糊說法壓過去，無法釐清對方到底主張的是哪一種法律效果。',
    ),
  ],
);

const _unitMisunderstandingArticle = LearningMockArticle(
  badge: '學習單元',
  title: '單元 3：租屋裡最容易誤解的地方',
  summary: '很多糾紛不是因為法律太難，而是因為雙方把自然耗損、人為損害、清潔整理和修繕義務混在一起。',
  readTime: '3 分鐘',
  heroNote: '把容易混淆的詞拆開，比背法條更能幫你避開糾紛。',
  keyPoints: [
    '自然耗損不等於租客一定要賠。',
    '清潔與修繕不是同一個概念。',
    '照片與點交紀錄比口頭記憶更重要。',
  ],
  sections: [
    LearningMockSection(
      title: '最常誤解的三件事',
      body: '包含押金是不是一定拿不回來、房東能不能把老化都算成損壞，以及退租清潔到底是不是所有責任都由房客承擔。',
    ),
    LearningMockSection(
      title: '學這一單元的目的',
      body: '讓你知道哪些話聽起來像常識，其實是最常造成資訊偏差的地方。',
    ),
  ],
);

const _unitRightsArticle = LearningMockArticle(
  badge: '學習單元',
  title: '單元 4：回到權利義務，合約到底要看哪幾句？',
  summary: '這一單元不會叫你逐條背，而是教你抓最該先看的租約重點。',
  readTime: '4 分鐘',
  heroNote: '不是整份租約都要一樣用力看，先抓關鍵條款才有用。',
  keyPoints: [
    '先看解約、押金、修繕與點交四類條款。',
    '條款寫了，不代表一定毫無限制地有效。',
    '沒有文字紀錄的地方，後面最容易各說各話。',
  ],
  sections: [
    LearningMockSection(
      title: '優先看的條款',
      body: '先看提前解約怎麼處理、押金返還條件、修繕責任分配以及退租點交方式，這幾句通常最直接影響結果。',
    ),
    LearningMockSection(
      title: '學完這單元要會什麼',
      body: '你不需要變成法律人，但至少要知道遇到爭議時該先翻哪裡，而不是只看對方怎麼講。',
    ),
  ],
);

const _unitQuizPrepArticle = LearningMockArticle(
  badge: '學習單元',
  title: '單元 5：用一題測驗確認你真的懂了',
  summary: '把前面學過的概念收回到一個實際判斷題，確認你能不能分辨押金、損害和條款效力。',
  readTime: '1 題測驗',
  heroNote: '能答對不是因為記住一句話，而是因為你知道判斷順序。',
  keyPoints: [
    '先辨識問題是押金、違約金，還是損害賠償。',
    '再回到合約與事實。',
    '最後才判斷扣款是否合理。',
  ],
  sections: [
    LearningMockSection(
      title: '這單元的用途',
      body: '不是額外補充新資訊，而是確認你能不能把前面學到的內容真正用在判斷上。',
    ),
  ],
);

const _workplaceArticle = LearningMockArticle(
  badge: '平行專題',
  title: '職場權益：從工時、加班到離職程序',
  summary: '如果你想學的是勞動法的日常爭議，這個專題會從工作現場最常遇到的權益問題帶你進去。',
  readTime: '4 個學習單元',
  heroNote: '職場權益最怕的不是沒規定，而是不知道哪個規定跟自己現在的情況有關。',
  keyPoints: [
    '先抓工時和加班。',
    '再看試用期和資遣。',
    '最後回到證據保存。',
  ],
  sections: [
    LearningMockSection(
      title: '這個專題在學什麼',
      body: '工時、加班費、補休、離職與資遣，是多數勞資爭議的核心入口。',
    ),
  ],
);

const _privacyArticle = LearningMockArticle(
  badge: '平行專題',
  title: '肖像權與社群發文：什麼可以拍、什麼不能用',
  summary: '適合想從社群、攝影與個人權利邊界開始學的人。',
  readTime: '3 個學習單元',
  heroNote: '公共場合能不能拍，和拍到之後能不能怎麼用，是兩層不同問題。',
  keyPoints: [
    '可辨識性很重要。',
    '公開使用與商業使用風險更高。',
    '不是所有入鏡都等於侵權。',
  ],
  sections: [
    LearningMockSection(
      title: '這個專題在學什麼',
      body: '會從生活拍攝、社群發文與商業使用三個層次，把肖像權與隱私邊界拆清楚。',
    ),
  ],
);

const _consumerArticle = LearningMockArticle(
  badge: '平行專題',
  title: '網購退貨與消保：從七天鑑賞期到商品瑕疵',
  summary: '如果你想學的是最常出現在購物平台與客服對話裡的法律問題，這個專題會比較適合。',
  readTime: '4 個學習單元',
  heroNote: '七天鑑賞期不是所有情況的萬用答案，商品瑕疵和退貨權也不是同一件事。',
  keyPoints: [
    '先分清楚鑑賞期與瑕疵。',
    '保存訂單與對話紀錄。',
    '再判斷可主張的權利。',
  ],
  sections: [
    LearningMockSection(
      title: '這個專題在學什麼',
      body: '從通訊交易、退貨權到瑕疵擔保，整理消費者最常碰到的幾個關鍵問題。',
    ),
  ],
);

const _faqArticle = LearningMockArticle(
  badge: '延伸理解',
  title: '租屋 FAQ：房東最常說的三句話，哪句真的站得住？',
  summary: '把租屋糾紛中最常聽到的說法拆開，幫你快速辨認哪些是合理主張、哪些只是口頭壓力。',
  readTime: '3 分鐘',
  heroNote: 'FAQ 的價值在於幫你先辨識哪些問題值得追問，而不是直接相信最順口的答案。',
  keyPoints: [
    '不是合約有寫就一定毫無限制。',
    '不是押金在房東手上就能自由決定。',
    '不是點交沒做就代表房客一定吃虧。',
  ],
  sections: [
    LearningMockSection(
      title: '常見問題',
      body: '例如「提前退租押金就全部沒了」、「房東說老化也算損害」或「租約是制式的所以不能改」。',
    ),
  ],
);

const _lawContextArticle = LearningMockArticle(
  badge: '延伸理解',
  title: '相關法條怎麼看：不用背條文，也能知道重點在哪',
  summary: '這一篇不是背法條，而是教你在租屋問題裡，條文通常扮演什麼角色。',
  readTime: '3 分鐘',
  heroNote: '法條不是拿來壓人，而是拿來幫你辨識爭點和排序問題。',
  keyPoints: [
    '條文是判斷工具，不是裝飾。',
    '先抓概念，再回條文。',
    '知道要找哪類規定，比記號碼更重要。',
  ],
  sections: [
    LearningMockSection(
      title: '延伸理解的角色',
      body: '它幫你把專題內容和正式法律語言接起來，讓你知道自己的生活問題在法律上通常怎麼被描述。',
    ),
  ],
);

const _caseArticle = LearningMockArticle(
  badge: '延伸理解',
  title: '案例對照：同樣是退租，為什麼有些人拿得回押金、有些人拿不回來？',
  summary: '透過兩種不同租屋案例，帶你看懂判斷差別通常發生在哪一段。',
  readTime: '4 分鐘',
  heroNote: '案例的作用不是背答案，而是讓你看到同一題在不同事實下，結果怎麼變。',
  keyPoints: [
    '事實差一點，結果就可能差很多。',
    '證據和點交紀錄常是轉折點。',
    '案例有助於把抽象規則落地。',
  ],
  sections: [
    LearningMockSection(
      title: '案例的用途',
      body: '讓使用者把前面學到的概念帶回真實情境，理解判斷差異不是隨機發生，而是有邏輯可循。',
    ),
  ],
);

const learningTopic = LearningTopicData(
  topicSlug: 'rental_dispute',
  title: '租屋糾紛怎麼看懂',
  summary: '從押金、提前解約到修繕責任，這個主專題會帶你用一條完整順序理解租屋裡最常見的爭議。',
  reasonToLearn: '租屋問題常發生在日常生活，而且很容易因為資訊不對稱吃虧。先把這個主題學懂，遇到糾紛時比較知道該先問什麼、看什麼。',
  unitSummary: '5 個學習單元',
  heroArticle: _topicIntroArticle,
  units: [
    LearningTopicUnit(
      stepLabel: 'STEP 1',
      title: '押金的法律角色是什麼？',
      goal: '先建立正確概念，知道押金不是預設罰款。',
      readTime: '3 分鐘',
      article: _unitBasicsArticle,
    ),
    LearningTopicUnit(
      stepLabel: 'STEP 2',
      title: '提前解約時，哪些情況真的可能被扣錢？',
      goal: '拆開違約金、空租損失與修繕費的差別。',
      readTime: '4 分鐘',
      article: _unitScenariosArticle,
    ),
    LearningTopicUnit(
      stepLabel: 'STEP 3',
      title: '租屋裡最容易誤解的地方',
      goal: '先看哪些常識其實最容易讓人誤判。',
      readTime: '3 分鐘',
      article: _unitMisunderstandingArticle,
    ),
    LearningTopicUnit(
      stepLabel: 'STEP 4',
      title: '回到權利義務，合約到底要看哪幾句？',
      goal: '抓出最值得先看的條款與判斷順序。',
      readTime: '4 分鐘',
      article: _unitRightsArticle,
    ),
    LearningTopicUnit(
      stepLabel: 'STEP 5',
      title: '用一題測驗確認你真的懂了',
      goal: '把前面學過的概念收束成可判斷的實際問題。',
      readTime: '1 題測驗',
      article: _unitQuizPrepArticle,
    ),
  ],
  relatedTopics: [
    LearningRelatedTopic(
      title: '職場權益',
      summary: '從工時、加班到離職程序，把最常遇到的勞資問題學成一條路徑。',
      focusLabel: '平行專題',
      article: _workplaceArticle,
    ),
    LearningRelatedTopic(
      title: '肖像權與社群發文',
      summary: '從拍到別人、發布照片到商業使用，把常見邊界整理清楚。',
      focusLabel: '平行專題',
      article: _privacyArticle,
    ),
    LearningRelatedTopic(
      title: '網購退貨與消保',
      summary: '從七天鑑賞期、商品瑕疵到平台申訴，建立消費爭議的基礎判斷。',
      focusLabel: '平行專題',
      article: _consumerArticle,
    ),
  ],
  supportItems: [
    LearningSupportItem(
      label: 'FAQ',
      title: '房東最常說的三句話，哪句真的站得住？',
      summary: '先拆掉最常見的口頭說法，避免還沒開始判斷就先被帶走。',
      article: _faqArticle,
    ),
    LearningSupportItem(
      label: '法條脈絡',
      title: '相關法條怎麼看：不用背條文，也能知道重點在哪',
      summary: '把生活問題和法律語言接起來，知道自己到底在問什麼問題。',
      article: _lawContextArticle,
    ),
    LearningSupportItem(
      label: '案例對照',
      title: '同樣是退租，為什麼有人拿得回押金、有人拿不回來？',
      summary: '透過案例對照，把抽象規則落到真實情境。',
      article: _caseArticle,
    ),
  ],
  quizEntry: LearningQuizEntryData(
    title: '專題測驗',
    subtitle: '用 1 題小測驗確認你能不能分辨押金、損害與條款效力。',
    actionLabel: '開始測驗',
  ),
);

const learningNewsletterDetailByTitle = {
  '狗咬人，主人要賠？！': _caseArticle,
  '自拍時拍到別人臉，侵權了？！': _privacyArticle,
  '租屋提前解約，押金一定拿不回來嗎？': _topicIntroArticle,
};

// ==========================================
// 擴充專題 1：車禍事故
// ==========================================
const _carIntroArticle = LearningMockArticle(
  badge: '主專題',
  title: '車禍事故怎麼看懂：路權判定與車損折舊',
  summary: '從事故發生的第一時間處理，到責任釐清與民事折舊計算，掌握求償黃金順序。',
  readTime: '5 個學習單元',
  heroNote: '車禍當下最重要是存證與釐清責任，求償時零件折舊是一大重點，懂法律才能保障權益。',
  keyPoints: [
    '第一時間必須先報警並做現場記錄，否則影響後續鑑定。',
    '路權判定（如支線讓幹線、轉彎讓直行）決定了肇事責任主次因。',
    '車輛維修費用中，更換新零件要扣折舊，但工資與烤漆不扣折舊。',
  ],
  sections: [
    LearningMockSection(
      title: '這個專題在學什麼',
      body: '本專題帶你建立車禍後的標準求償與責任判定流程，從現場處理、初判表研讀，到零件折舊公式。',
    ),
    LearningMockSection(
      title: '為什麼值得先學',
      body: '車禍是非常普遍的生活纠纷。了解折舊與路權，能防止在調解委員會或訴訟中被任意砍價或浮報。',
    ),
  ],
);

const _carUnit1Article = LearningMockArticle(
  badge: '學習單元',
  title: '單元 1：事故第一時間的黃金處理三步驟',
  summary: '車禍當下別慌亂，做好這三件事，為後續鑑定打下鐵證。',
  readTime: '3 分鐘',
  heroNote: '車禍當下應先報警、拍照存證並將車輛移至安全處（若無體傷），並保留行車記錄器。',
  keyPoints: [
    '即使是輕微擦撞，也建議報警以取得登記聯單。',
    '拍照時要拍攝標線、標誌與雙方碰撞點的全景與特寫。',
    '行車記錄器畫面應盡快存檔，防範被循環覆蓋。',
  ],
  sections: [
    LearningMockSection(
      title: '第一步：保護現場與報警',
      body: '開啟雙黃警示燈，並在車後放置三角牌。隨即撥打 110 與保險公司，確認是否需要救護車。',
    ),
    LearningMockSection(
      title: '第二步：拍照與定位',
      body: '拍攝全景（包含標線、路口、碰撞位置關係）與特寫（碰撞損害處）。若無體傷且妨礙交通，定位後應移置路旁。',
    ),
  ],
);

const _carUnit2Article = LearningMockArticle(
  badge: '學習單元',
  title: '單元 2：什麼是路權？如何看懂肇事責任？',
  summary: '誰讓誰不是看誰開的車大，而是看路權優先順序。',
  readTime: '4 分鐘',
  heroNote: '路權是判定過失比例的基礎。少讓多、支線讓幹線、轉彎讓直行是核心原則。',
  keyPoints: [
    '無號誌路口：支線道車輛必須讓幹線道車輛先行。',
    '轉彎車與直行車：轉彎車應讓直行車先行。',
    '初判表僅供參考，真正法律效力以鑑定委員會之鑑定意見書為準。',
  ],
  sections: [
    LearningMockSection(
      title: '路權基本規則',
      body: '道路交通安全規則第 102 條規範了路口優先權。例如：轉彎車未讓直行車是常見的肇事主因。',
    ),
    LearningMockSection(
      title: '初判表與車禍鑑定',
      body: '事故 30 日後可向警方申請「道路交通事故初步分析研判表」。若對責任有異議，可自費 3,000 元申請車禍鑑定。',
    ),
  ],
);

const _carUnit3Article = LearningMockArticle(
  badge: '學習單元',
  title: '單元 3：車損求償中的「折舊計算」公式',
  summary: '為什麼換新零件會被打折？法律上的不當得利與折舊限制。',
  readTime: '3 分鐘',
  heroNote: '以新零件代替舊零件時，新舊差額視為折舊扣減；但修車工資與烤漆費用無折舊問題，應全額賠償。',
  keyPoints: [
    '零件折舊通常採用定率遞減法或平均法，依據耐用年數計算。',
    '自用小客車的耐用年數為 5 年，超過 5 年零件殘值通常僅賸 1/10。',
    '工資與烤漆是純勞務，法律上不予折舊扣除。',
  ],
  sections: [
    LearningMockSection(
      title: '折舊判定實務',
      body: '最高法院見解認為，零件因折舊需打折，否則原告等於拿到全新品，會構成不當得利。但工資並無實體損耗，故不在折舊範圍。',
    ),
  ],
);

const _carUnit4Article = LearningMockArticle(
  badge: '學習單元',
  title: '單元 4：體傷與精神慰撫金的合理範圍',
  summary: '車禍受傷可以求償哪些項目？精神慰撫金如何認定？',
  readTime: '4 分鐘',
  heroNote: '體傷求償包括醫藥費、看護費、工作損失以及精神慰撫金。必須備齊收據與診斷證明。',
  keyPoints: [
    '工作損失需醫生診斷書載明「需休養且無法工作」之天數與薪資證明。',
    '精神慰撫金無固定公式，由法院審酌雙方身分、地位、經濟能力與傷勢嚴重度裁量。',
    '強制險是特別補償，體傷部分可先申請強制險理賠。',
  ],
  sections: [
    LearningMockSection(
      title: '求償項目清單',
      body:
          '1. 醫療費用（收據）\n2. 交通費（計程車收據）\n3. 看護費（家人照顧亦可請求）\n4. 工作損失（薪資扣繳憑單）\n5. 慰撫金。',
    ),
  ],
);

const _carUnit5Article = LearningMockArticle(
  badge: '學習單元',
  title: '單元 5：車禍模擬思辨測驗',
  summary: '用一題實務案例測驗你是否已掌握車損折舊的計算規則。',
  readTime: '1 題測驗',
  heroNote: '實務上調解時，對方常拿折舊當藉口砍工資賠償，必須當場指出其違法性。',
  keyPoints: [
    '零件更換要折舊，工資烤漆不要折舊。',
    '調解成立即等同法院確定判決效力。',
  ],
  sections: [
    LearningMockSection(
      title: '案例情境',
      body:
          '小明駕駛車齡 6 年車輛被撞，修車廠估價零件 10 萬元，工資 5 萬元，烤漆 2 萬元。對方稱車子老了零件跟工資都要打 1 折，只賠 1.7 萬。這樣合理嗎？',
    ),
  ],
  category: '車禍事故',
  quizData: {
    'question': '車子修復費用中，對方宣稱車子老舊所以「零件」與「工資、烤漆」全部都要折舊打 1 折，是否合理？',
    'options': [
      'A. 合理，整台車都折舊了，所以全部維修費都要打折。',
      'B. 不合理，只有「換新零件」需要折舊扣減；「工資與烤漆」沒有折舊問題，應全額理賠。',
      'C. 不合理，車禍是被撞，所以不論零件或工資都可以要求全新全額理賠，不扣折舊。'
    ],
    'correctIndex': 1,
    'explanation': '實務上零件需折舊，但工資、烤漆等勞務費用不予折舊，對方要求工資打折是於法無據的。'
  },
);

const learningTopicCarAccident = LearningTopicData(
  topicSlug: 'traffic_accident',
  title: '車禍事故怎麼看懂',
  summary: '從事故發生的第一時間處理，到責任釐清與民事折舊計算，掌握求償黃金順序。',
  reasonToLearn: '車禍發生時常慌亂無措，懂路權與民事折舊計算，才能保障權益，不上當吃虧。',
  unitSummary: '5 個學習單元',
  heroArticle: _carIntroArticle,
  units: [
    LearningTopicUnit(
      stepLabel: 'STEP 1',
      title: '事故第一時間的黃金處理三步驟',
      goal: '冷氣、記錄與報警的標準流程。',
      readTime: '3 分鐘',
      article: _carUnit1Article,
    ),
    LearningTopicUnit(
      stepLabel: 'STEP 2',
      title: '什麼是路權？如何看懂肇事責任？',
      goal: '學會看現場圖與研判表中的責任判定。',
      readTime: '4 分鐘',
      article: _carUnit2Article,
    ),
    LearningTopicUnit(
      stepLabel: 'STEP 3',
      title: '車損求償中的「折舊計算」公式',
      goal: '搞懂零件折舊與工資全額賠償的公式。',
      readTime: '3 分鐘',
      article: _carUnit3Article,
    ),
    LearningTopicUnit(
      stepLabel: 'STEP 4',
      title: '體傷與精神慰撫金的合理範圍',
      goal: '學會列出醫藥費與工作損失明細。',
      readTime: '4 分鐘',
      article: _carUnit4Article,
    ),
    LearningTopicUnit(
      stepLabel: 'STEP 5',
      title: '車禍模擬思辨測驗',
      goal: '用一題實務案例測驗你是否已掌握車損折舊的計算規則。',
      readTime: '1 題測驗',
      article: _carUnit5Article,
    ),
  ],
  relatedTopics: [
    LearningRelatedTopic(
      title: '租屋糾紛',
      summary: '從押金、提前解約到修繕責任，這個主專題會帶你用一條完整順序理解租屋裡最常見的爭議。',
      focusLabel: '平行專題',
      article: _topicIntroArticle,
    ),
  ],
  supportItems: [
    LearningSupportItem(
      label: 'FAQ',
      title: '車禍當下沒報警私下和解，事後對方反悔告肇逃怎麼辦？',
      summary: '私下和解必須簽署正式和解書並放棄民刑事追訴權。',
      article: _carUnit1Article,
    ),
  ],
  quizEntry: LearningQuizEntryData(
    title: '專題測驗',
    subtitle: '用 1 題小測驗確認你能不能分辨零件折舊與工資理賠界線。',
    actionLabel: '開始測驗',
  ),
);

// ==========================================
// 擴充專題 2：職場權益
// ==========================================
const _workUnit1Article = LearningMockArticle(
  badge: '學習單元',
  title: '單元 1：加班費計算公式與倍數',
  summary: '平日、休息日與例假日的加班費，勞基法規定各不相同。',
  readTime: '3 分鐘',
  heroNote: '加班費依勞基法第 24 條規定計算，平日加班前兩小時加給 1/3，後兩小時加給 2/3。',
  keyPoints: [
    '平日加班：前 2 小時乘 1.34，後 2 小時乘 1.67。',
    '休息日加班：前 2 小時乘 1.34，第 3 到 8 小時乘 1.67。',
    '加班必須有雇主指示或合理的加班事實紀錄（如打卡）。',
  ],
  sections: [
    LearningMockSection(
      title: '平日加班費計算',
      body: '平日工作 8 小時後，第 9-10 小時加班費為時薪的 1.34 倍，第 11-12 小時為 1.67 倍。',
    ),
  ],
);

const _workUnit2Article = LearningMockArticle(
  badge: '學習單元',
  title: '單元 2：特別休假的排定權與限制',
  summary: '特休假日是員工決定還是老闆決定？',
  readTime: '4 分鐘',
  heroNote: '勞基法第 38 條明文，特別休假期日由勞工排定之。雇主不得片面指定特休日期。',
  keyPoints: [
    '排定權在勞工。雇主只有在有急迫經營需求時能與勞工協商。',
    '雇主不能強制規定「請特休必須提前一個月申請且公司核准才算數」。',
    '未休完之特休，年度終結或離職時雇主必須折算工資。',
  ],
  sections: [
    LearningMockSection(
      title: '特休排定實務',
      body: '勞動部解釋，雇主僅能進行「協商」，無權「否決」勞工排定的特別休假，且不需證明請假原因。',
    ),
  ],
);

const _workUnit3Article = LearningMockArticle(
  badge: '學習單元',
  title: '單元 3：自願離職與預告期規定',
  summary: '勞工提出離職，需要提前多久通知公司？',
  readTime: '3 分鐘',
  heroNote: '離職預告期依工作年限決定。未滿三個月免預告期；滿三個月至一年需 10 天前。',
  keyPoints: [
    '工作 3 個月到 1 年：10 天前預告。',
    '工作 1 年到 3 年：20 天前預告。',
    '工作 3 年以上：30 天前預告。',
  ],
  sections: [
    LearningMockSection(
      title: '預告期之法律效力',
      body: '離職預告是單方意思表示，送達雇主即生效力（如寄送 Email 或 LINE 訊息），不需老闆批准。',
    ),
  ],
);

const _workUnit4Article = LearningMockArticle(
  badge: '學習單元',
  title: '單元 4：資遣、非自願離職與資遣費',
  summary: '被公司裁員或解雇時，你的法定權益有哪些？',
  readTime: '4 分鐘',
  heroNote: '資遣必須符合勞基法第 11 條法定事由，並依法給付資遣費及發給非自願離職證明。',
  keyPoints: [
    '新制資遣費：工作每滿一年發給 0.5 個月平均工資，最高以 6 個月為限。',
    '非自願離職證明是向就業服務站申請失業給付（投保薪資 60%）的必要文件。',
    '若公司違法解雇，可向勞工局申請勞資爭議調解。',
  ],
  sections: [
    LearningMockSection(
      title: '資遣費計算',
      body: '新制資遣費計算方式為：年資 * 0.5 * 平均工資。未滿一年者按比例計算。',
    ),
  ],
);

const _workUnit5Article = LearningMockArticle(
  badge: '學習單元',
  title: '單元 5：勞基法模擬思辨測驗',
  summary: '用一題案例測驗你是否懂特休假折算工資的標準。',
  readTime: '1 題測驗',
  heroNote: '離職時任何未休的特休，一律應折算成一日工資給付，不受離職原因影響。',
  keyPoints: [
    '離職特休折算工資是雇主的法定義務。',
  ],
  sections: [
    LearningMockSection(
      title: '情境案例',
      body:
          '小明向公司提出離職，尚有 10 天特休假。主管說「因為是你自己要走，且最近很忙，所以特休一律失效，也不會折算工資。」主管說法合理嗎？',
    ),
  ],
  category: '職場權益',
  quizData: {
    'question': '勞工自願提出離職時，尚有未休完的特別休假，雇主宣稱「因為是你自願離職，所以剩餘特休自動失效且不折算薪資」，這符合勞基法嗎？',
    'options': [
      'A. 符合，自願離職代表勞工放棄請假權利。',
      'B. 不符合，不論離職原因為何，勞工離職時未休畢之特休，雇主均應折算發給一日工資。',
      'C. 符合，只要合約中有寫明「離職未休特休歸零」即可。'
    ],
    'correctIndex': 1,
    'explanation':
        '勞基法第 38 條第 4 項規定為強制條款，契約終止時未休完之特休，雇主一律應折算工資給付，任何「自願放棄特休合約條款」均屬無效。'
  },
);

const learningTopicWorkplace = LearningTopicData(
  topicSlug: 'workplace_rights',
  title: '職場權益怎麼看懂',
  summary: '從加班費計算、特別休假到預告期與非自願離職，保護你的勞動基本權益。',
  reasonToLearn: '勞資爭議常因條款模糊，搞懂法律界線與證據存證，才能安全離職並拿到應得補償。',
  unitSummary: '5 個學習單元',
  heroArticle: _workplaceArticle,
  units: [
    LearningTopicUnit(
      stepLabel: 'STEP 1',
      title: '加班費計算公式與倍數',
      goal: '分清平日、休息日與國定假日的加成倍數。',
      readTime: '3 分鐘',
      article: _workUnit1Article,
    ),
    LearningTopicUnit(
      stepLabel: 'STEP 2',
      title: '特別休假的排定權與限制',
      goal: '搞懂特休假能不能被雇主強制取消或歸零。',
      readTime: '4 分鐘',
      article: _workUnit2Article,
    ),
    LearningTopicUnit(
      stepLabel: 'STEP 3',
      title: '自願離職與預告期規定',
      goal: '勞動基準法對不同年資離職預告期的規範。',
      readTime: '3 分鐘',
      article: _workUnit3Article,
    ),
    LearningTopicUnit(
      stepLabel: 'STEP 4',
      title: '資遣、非自願離職與資遣費',
      goal: '被公司資遣裁員時應享有的資遣費與失業津貼權益。',
      readTime: '4 分鐘',
      article: _workUnit4Article,
    ),
    LearningTopicUnit(
      stepLabel: 'STEP 5',
      title: '勞基法模擬思辨測驗',
      goal: '確認你已學會離職特別休假的折算工資規則。',
      readTime: '1 題測驗',
      article: _workUnit5Article,
    ),
  ],
  relatedTopics: [
    LearningRelatedTopic(
      title: '租屋糾紛',
      summary: '從押金、提前解約到修繕責任，這個主專題會帶你用一條完整順序理解租屋裡最常見的爭議。',
      focusLabel: '平行專題',
      article: _topicIntroArticle,
    ),
  ],
  supportItems: [
    LearningSupportItem(
      label: 'FAQ',
      title: '公司要求簽署「自願離職單」才肯發放年終，會有什麼風險？',
      summary: '簽署自願離職單將失去資遣費與失業給付申領資格，應極力避免。',
      article: _workUnit4Article,
    ),
  ],
  quizEntry: LearningQuizEntryData(
    title: '專題測驗',
    subtitle: '用 1 題小測驗確認你能不能分辨自願離職與非自願離職特休結算界線。',
    actionLabel: '開始測驗',
  ),
);

// ==========================================
// 擴充專題 3：網購消費
// ==========================================
const _consumerUnit1Article = LearningMockArticle(
  badge: '學習單元',
  title: '單元 1：網購七天鑑賞期的本質與適用',
  summary: '七天鑑賞期是猶豫期，而非試用期。',
  readTime: '3 分鐘',
  heroNote: '消保法第 19 條規定，通訊交易消費者可在收到商品後七日內，無條件退回商品或解除契約。',
  keyPoints: [
    '鑑賞期指的是「猶豫期」，旨在讓消費者檢查商品外觀與品質。',
    '拆封檢查通常不影響退貨權利，但若試用造成毀損，可能需賠償價值減損。',
    '實體店面消費原則上不適用七天無條件退貨。',
  ],
  sections: [
    LearningMockSection(
      title: '猶豫期之法律規範',
      body: '消保法保障網路購物，因為消費者在購買前無法觸摸實體商品。因此給予 7 天猶豫時間，無須說明理由即可退貨。',
    ),
  ],
);

const _consumerUnit2Article = LearningMockArticle(
  badge: '學習單元',
  title: '單元 2：排除鑑賞期的七大類例外商品',
  summary: '哪些網購商品一旦拆封或售出，就不能主張七天退貨？',
  readTime: '4 分鐘',
  heroNote: '消保法施行細則規定，易腐敗生鮮、個人衛生用品、客製化商品等 7 大類排除鑑賞期。',
  keyPoints: [
    '生鮮食品、易腐敗之商品（如蛋糕、蔬菜）。',
    '依消費者要求所為之客製化給付（如刻字、客製衣服）。',
    '已拆封之個人衛生用品（如內衣褲、刮鬍刀）。',
  ],
  sections: [
    LearningMockSection(
      title: '例外排除清單',
      body: '除上述外，還包括報紙期刊、已拆封之影音軟體/電腦軟體、數位內容（如電子書、下載遊戲）等。',
    ),
  ],
);

const _consumerUnit3Article = LearningMockArticle(
  badge: '學習單元',
  title: '單元 3：退貨運費與賣家免責條款',
  summary: '退貨運費誰來付？「售出不退」網頁聲明有效嗎？',
  readTime: '3 分鐘',
  heroNote: '網購退貨運費依法由賣家負擔，任何「退貨運費由買家自理」的免責聲明均屬違法無效。',
  keyPoints: [
    '消費者行使消保法第 19 條解約權，無須負擔任何費用或運費。',
    '商家在首頁寫「特價商品概不退換」，違反消保法強制規定而無效。',
    '若退貨需買家支付包裝手續費，亦屬違法。',
  ],
  sections: [
    LearningMockSection(
      title: '運費負擔義務',
      body: '消保法明確規定，退回商品之運費由企業經營者負擔。若賣家強制要求買家自付，可向消保官申訴。',
    ),
  ],
);

const _consumerUnit4Article = LearningMockArticle(
  badge: '學習單元',
  title: '單元 4：瑕疵擔保責任與消保申訴管道',
  summary: '網購收到瑕疵品，如何主張換貨或退款？',
  readTime: '4 分鐘',
  heroNote: '除 7 天鑑賞期外，買受人亦享有民法瑕疵擔保權利，可請求減少價金或解除契約。',
  keyPoints: [
    '收到商品後應立即檢查，發現瑕疵應速通知賣家。',
    '申訴途徑：可至行政院消保會網站線上申訴，或撥打 1950 全國消保專線。',
    '若付款使用信用卡，可向發卡銀行申請「爭議款凍結」以扣回款項。',
  ],
  sections: [
    LearningMockSection(
      title: '民法瑕疵擔保',
      body: '民法第 354 條規定，出賣人應擔保商品無滅失或減少其價值之瑕疵。如網購收到破裂商品，可依法求償。',
    ),
  ],
);

const _consumerUnit5Article = LearningMockArticle(
  badge: '學習單元',
  title: '單元 5：消費者保護法模擬思辨測驗',
  summary: '用一題案例測驗你是否已掌握網購退貨運費的法規界線。',
  readTime: '1 題測驗',
  heroNote: '消保法第 19 條規定之解除權，非經法律明文排除，不得以特約予以限制或剥奪。',
  keyPoints: [
    '網購鑑賞期退貨運費由賣家負擔。',
  ],
  sections: [
    LearningMockSection(
      title: '情境案例',
      body:
          '小明在網路購買一件衣服，收到後不滿意欲申請退貨。賣家稱「此款為出清特價品，不適用 7 天鑑賞期，且網頁已寫明退貨運費需自理。」賣家說法合理嗎？',
    ),
  ],
  category: '網購消費',
  quizData: {
    'question': '在網路購買衣服收到 7 天內欲退貨，賣家宣稱「特價品售出不退，且退貨運費需由買家自理」，這符合消保法嗎？',
    'options': [
      'A. 符合，衣服不是生鮮，且買賣前賣家已有特約聲明，應以特約為準。',
      'B. 不符合，消保法規定網購商品（除 7 大類例外商品外）享有 7 天無條件退換貨，且退貨運費與任何費用均由賣家負擔，賣家聲明無效。',
      'C. 符合，只有原價商品才享有賣家負擔運費退貨的權利。'
    ],
    'correctIndex': 1,
    'explanation':
        '衣服不屬於生鮮、客製化等 7 大類例外排除商品，因此適用 7 天鑑賞期。且退貨運費依法應由賣家負擔，商家的免責宣告因違反消保法強制規定而無效。'
  },
);

const learningTopicConsumer = LearningTopicData(
  topicSlug: 'consumer_dispute',
  title: '網購消費怎麼看懂',
  summary: '掌握七天鑑賞期、瑕疵品退換貨以及網購詐騙的自保申訴途徑。',
  reasonToLearn: '消保法保障通訊交易，但特價品、個人衛生用品等例外狀況必須先分辨清楚。',
  unitSummary: '5 個學習單元',
  heroArticle: _consumerArticle,
  units: [
    LearningTopicUnit(
      stepLabel: 'STEP 1',
      title: '網購七天鑑賞期的本質與適用',
      goal: '釐清無條件退換貨的法定要件。',
      readTime: '3 分鐘',
      article: _consumerUnit1Article,
    ),
    LearningTopicUnit(
      stepLabel: 'STEP 2',
      title: '排除鑑賞期的七大類例外商品',
      goal: '生鮮、客製化、已拆封衛生用品如何適用。',
      readTime: '4 分鐘',
      article: _consumerUnit2Article,
    ),
    LearningTopicUnit(
      stepLabel: 'STEP 3',
      title: '退貨運費與賣家免責條款',
      goal: '消保法強制規定運費由賣家負擔。',
      readTime: '3 分鐘',
      article: _consumerUnit3Article,
    ),
    LearningTopicUnit(
      stepLabel: 'STEP 4',
      title: '瑕疵擔保責任與消保申訴管道',
      goal: '善用消保官與第三方支付平臺的爭議款退款。',
      readTime: '4 分鐘',
      article: _consumerUnit4Article,
    ),
    LearningTopicUnit(
      stepLabel: 'STEP 5',
      title: '消費者保護法模擬思辨測驗',
      goal: '確認你已學會網購退貨運費的法規界線。',
      readTime: '1 題測驗',
      article: _consumerUnit5Article,
    ),
  ],
  relatedTopics: [
    LearningRelatedTopic(
      title: '租屋糾紛',
      summary: '從押金、提前解約到修繕責任，這個主專題會帶你用一條完整順序理解租屋裡最常見的爭議。',
      focusLabel: '平行專題',
      article: _topicIntroArticle,
    ),
  ],
  supportItems: [
    LearningSupportItem(
      label: 'FAQ',
      title: '拆封網購包裹時沒有錄影，收到瑕疵品賣家拒絕理賠怎麼辦？',
      summary: '法律無強制規定拆封需錄影，但強烈建議錄影存證以方便舉證。',
      article: _consumerUnit4Article,
    ),
  ],
  quizEntry: LearningQuizEntryData(
    title: '專題測驗',
    subtitle: '用 1 題小測驗確認你能不能分辨一般網購商品退貨費用責任。',
    actionLabel: '開始測驗',
  ),
);

// ==========================================
// 擴充專題 4：個資隱私
// ==========================================
const _privacyUnit1Article = LearningMockArticle(
  badge: '學習單元',
  title: '單元 1：轉傳對話紀錄截圖與個資法',
  summary: '將含有他人個資的 LINE 截圖公開轉傳，是否違法？',
  readTime: '3 分鐘',
  heroNote: '個人資料保護法保護姓名、電話等直接或間接識別個人的資訊。未經同意公開利用即涉違法。',
  keyPoints: [
    '對話截圖若含有他人未遮蔽的姓名、大頭貼、電話，屬於個資法範疇。',
    '公開轉傳意圖招人議論，已構成「非蒐集特定目的外之利用」。',
    '受害者可依個資法請求侵害民事損害賠償。',
  ],
  sections: [
    LearningMockSection(
      title: '個資合理使用限制',
      body: '個資法第 19、20 條規定非公務機關對個資的利用。澄清自己名譽雖是合理動機，但直接公開他人未去識別化之個資仍易觸法。',
    ),
  ],
);

const _privacyUnit2Article = LearningMockArticle(
  badge: '學習單元',
  title: '單元 2：公開場所拍照攝影與肖像權',
  summary: '在街上錄影拍到路人，路人可以要求刪除嗎？',
  readTime: '4 分鐘',
  heroNote: '肖像權屬於民法第 195 條人格權。在公開場所拍照，未經同意不得特寫或做營利/醜化用途。',
  keyPoints: [
    '背景拍到路人一般不構成侵權，但對路人特寫或做焦點人物則涉侵害肖像權。',
    '若將含有路人臉部之影像用於廣告、商業推廣，必須取得授權。',
    '發文至公開論壇前，將路人臉部打碼遮蔽是最佳自保方式。',
  ],
  sections: [
    LearningMockSection(
      title: '肖像權侵害界線',
      body: '實務判決多審酌該拍照是否造成受害者社會評價降低、是否具商業營利性質、以及是否侵害其私生活合理隱私期待。',
    ),
  ],
);

const _privacyUnit3Article = LearningMockArticle(
  badge: '學習單元',
  title: '單元 3：網路發言隱私期待與妨害秘密',
  summary: '公開他人私訊或群組對話，是否觸犯刑法妨害秘密罪？',
  readTime: '3 分鐘',
  heroNote: '妨害秘密罪以「無故利用工具監聽、錄音、照相或錄影他人非公開活動或言論」為要件。',
  keyPoints: [
    '自己是對話人之一，將自己與他人的私訊公開，不構成刑法妨害秘密罪。',
    '但若截圖他人與第三人的非公開私訊公開轉傳，則會觸犯刑法。',
    '即使不構成刑法，公開私密對話仍可能涉民法隱私權侵權責任。',
  ],
  sections: [
    LearningMockSection(
      title: '非公開言論之合理期待',
      body: '私密的一對一對話，雙方通常有不對外公開之隱私期待。將之公開可能侵害人格權，需負民事賠償責任。',
    ),
  ],
);

const _privacyUnit4Article = LearningMockArticle(
  badge: '學習單元',
  title: '單元 4：個資洩漏防範與求償門檻',
  summary: '企業洩漏我的會員個資，我能要求多少賠償？',
  readTime: '4 分鐘',
  heroNote: '個資法第 28 條規定，非公務機關違法侵害個人資料，被害人雖不易證明實際損害額，仍可請求法定賠償。',
  keyPoints: [
    '若不易證明實際損害額，法院可依侵害情節核定每人每件 500 元以上 20,000 元以下之賠償。',
    '若屬企業故意或重大過失洩漏，賠償額度可能拉高。',
    '消費者應注意防範後續引發的解除分期付款等詐騙電話。',
  ],
  sections: [
    LearningMockSection(
      title: '個資法定賠償',
      body: '個資法特設「法定賠償額」降低被害人的舉證門檻，但仍需舉證個資確因該企業過失而外洩。',
    ),
  ],
);

const _privacyUnit5Article = LearningMockArticle(
  badge: '學習單元',
  title: '單元 5：個資隱私模擬思辨測驗',
  summary: '用一題案例測驗你是否懂轉傳對話紀錄與個資保護的關聯。',
  readTime: '1 題測驗',
  heroNote: '個人資料的利用應遵守誠實信用原則，不得逾越特定目的之必要範圍。',
  keyPoints: [
    '轉傳截圖必須遮蔽可供識別個人的隱私資訊。',
  ],
  sections: [
    LearningMockSection(
      title: '情境案例',
      body:
          '阿榮與前妻發生爭執，阿榮將前妻罵他的 LINE 對話（內含前妻姓名與電話），未遮蔽個資便直接發到公開的 Facebook 社團，意圖招人議論。阿榮做法合理嗎？',
    ),
  ],
  category: '個資隱私',
  quizData: {
    'question': '為了向大家澄清爭執，將含對方姓名、聯絡電話的私密對話截圖直接公開張貼在公開社群，這符合個資法嗎？',
    'options': [
      'A. 符合，只要截圖內容屬實，且是為了澄清爭議，即屬於言論自由保障。',
      'B. 不符合，姓名、聯絡電話屬於個人資料，未經遮蔽去識別化即公開轉傳，已構成個資法違法利用，並涉侵害隱私權。',
      'C. 符合，對話記錄雙方共有，任一方皆有決定公開的權利。'
    ],
    'correctIndex': 1,
    'explanation':
        '澄清名譽雖屬正當動機，但公開轉傳未去識別化的個資（如包含姓名、電話）已逾越個資合理使用範圍，構成個資侵權，受害者可起訴求償。'
  },
);

const learningTopicPrivacy = LearningTopicData(
  topicSlug: 'privacy_rights',
  title: '個資隱私怎麼看懂',
  summary: '了解截圖轉傳、社群公開他人個資以及未經同意攝影的隱私侵權邊界。',
  reasonToLearn: '網路社群發言容易踩雷，搞懂個資法與隱私侵權，防範民刑事責任。',
  unitSummary: '5 個學習單元',
  heroArticle: _privacyArticle,
  units: [
    LearningTopicUnit(
      stepLabel: 'STEP 1',
      title: '轉傳對話紀錄截圖與個資法',
      goal: '姓名、頭像等可直接識別資料的保護界線。',
      readTime: '3 分鐘',
      article: _privacyUnit1Article,
    ),
    LearningTopicUnit(
      stepLabel: 'STEP 2',
      title: '公開場所拍照攝影與肖像權',
      goal: '肖像權侵害的認定標準與商業使用例外。',
      readTime: '4 分鐘',
      article: _privacyUnit2Article,
    ),
    LearningTopicUnit(
      stepLabel: 'STEP 3',
      title: '網路發言隱私期待與妨害秘密',
      goal: '私密對話與公開對話的合理期待區別。',
      readTime: '3 分鐘',
      article: _privacyUnit3Article,
    ),
    LearningTopicUnit(
      stepLabel: 'STEP 4',
      title: '個資洩漏防範與求償門檻',
      goal: '學習存證與個資法求償門檻。',
      readTime: '4 分鐘',
      article: _privacyUnit4Article,
    ),
    LearningTopicUnit(
      stepLabel: 'STEP 5',
      title: '個資隱私模擬思辨測驗',
      goal: '確認你已學會轉傳對話紀錄與個資保護的法規界線。',
      readTime: '1 題測驗',
      article: _privacyUnit5Article,
    ),
  ],
  relatedTopics: [
    LearningRelatedTopic(
      title: '租屋糾紛',
      summary: '從押金、提前解約到修繕責任，這個主專題會帶你用一條完整順序理解租屋裡最常見的爭議。',
      focusLabel: '平行專題',
      article: _topicIntroArticle,
    ),
  ],
  supportItems: [
    LearningSupportItem(
      label: 'FAQ',
      title: '被他人未經同意公開截圖求償，若對方要求的金額過高該如何抗辯？',
      summary: '可舉證自己並無惡意、對方未受有財產損害，請求法院酌減精神撫慰金。',
      article: _privacyUnit1Article,
    ),
  ],
  quizEntry: LearningQuizEntryData(
    title: '專題測驗',
    subtitle: '用 1 題小測驗確認你能不能分辨個資侵害民事法定求償範圍。',
    actionLabel: '開始測驗',
  ),
);

// 合併所有精選專題的 Map
const featuredLearningTopics = {
  '租屋糾紛': learningTopic,
  '車禍事故': learningTopicCarAccident,
  '職場權益': learningTopicWorkplace,
  '網購消費': learningTopicConsumer,
  '個資隱私': learningTopicPrivacy,
};

// 以穩定 id 查找精選專題，供歷史紀錄與跨頁導頁使用。
const featuredLearningTopicsBySlug = {
  'rental_dispute': learningTopic,
  'traffic_accident': learningTopicCarAccident,
  'workplace_rights': learningTopicWorkplace,
  'consumer_dispute': learningTopicConsumer,
  'privacy_rights': learningTopicPrivacy,
};
const learningQuizQuestions = homeQuizQuestions;
