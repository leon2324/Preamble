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

const learningQuizQuestions = homeQuizQuestions;
