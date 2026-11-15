import 'package:preamble/features/on_this_day/models/on_this_day_models.dart';

const List<OnThisDayCase> onThisDayCases = [
  OnThisDayCase(
    id: 'nylon-cheng-1989',
    year: 1989,
    month: 4,
    day: 7,
    location: '台北市大安區',
    title: '鄭南榕事件',
    category: '言論自由',
    tags: ['言論自由', '民主運動', '政黨政治'],
    summary: '1989年，鄭南榕因《自由時代》雜誌政治主張遭起訴，事件成為台灣言論自由與民主運動的重要記憶座標。',
    quote: '有些日子不能過去，而是在社會仍在還原檢討自己曾經如何抉擇自由。',
    background:
        '1989年，鄭南榕因《自由時代》週刊刊登「台灣共和國憲法草案」而被控涉嫌叛亂。他宣示「國民黨只能捉到我的屍體，不能捉到我的人」，並在民權東路雜誌社內展開拒捕抗爭，最終於4月7日自焚身亡。',
    backgroundDetails:
        '在1980年代末期，台灣雖已解嚴，但《懲治叛亂條例》與刑法第一百條（陰謀叛亂罪）依然存在。政府對於政治言論的查禁與限制仍相當嚴格，鄭南榕主張完全的言論自由，挑戰當局的禁忌。',
    socialImpact:
        '此事件引發台灣社會對言論自由的強烈關注，並直接推動了刑法第一百條的修正與懲治叛亂條例的廢除。政府於2016年將每年的4月7日定為「言論自由日」。',
    status: '歷史案件整理',
    timeline: [
      OnThisDayTimelineNode(
        dateLabel: '1984.03',
        title: '自由時代週刊創刊',
        description: '鄭南榕創辦《自由時代》系列週刊，標榜「爭取百分之百的言論自由」。',
      ),
      OnThisDayTimelineNode(
        dateLabel: '1988.12',
        title: '刊登新憲法草案',
        description: '週刊第254期刊登許世楷起草的「台灣共和國新憲法草案」，隨即被指控涉嫌叛亂。',
      ),
      OnThisDayTimelineNode(
        dateLabel: '1989.01',
        title: '鄭南榕誓言拒捕',
        description: '收到高檢處的傳票後，鄭南榕在雜誌社自囚，誓言絕不上法庭。',
      ),
      OnThisDayTimelineNode(
        dateLabel: '1989.04.07',
        title: '拒捕自焚',
        description: '警方準備強行進入雜誌社逮捕時，鄭南榕在總編輯室自焚身亡。',
      ),
      OnThisDayTimelineNode(
        dateLabel: '1989.05.20',
        title: '出殯與萬人遊行',
        description: '出殯當天，數萬名群眾參與遊行，同日發生詹益樺在總統府前自焚事件。',
      ),
    ],
    photos: [
      OnThisDayPhoto(
        photoUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/4/47/04.07_%E3%80%8C%E9%84%AD%E5%8D%97%E6%A6%9528%E9%80%B1%E5%B9%B4%E7%B4%80%E5%BF%B5%E8%BF%BD%E6%80%9D%E6%9C%83%E3%80%8D_%2833889642495%29.jpg/960px-04.07_%E3%80%8C%E9%84%AD%E5%8D%97%E6%A6%9528%E9%80%B1%E5%B9%B4%E7%B4%80%E5%BF%B5%E8%BF%BD%E6%80%9D%E6%9C%83%E3%80%8D_%2833889642495%29.jpg',
        caption: '鄭南榕殉道紀念追思會現場攝影紀錄（Wikimedia Commons CC 授權）',
      ),
      OnThisDayPhoto(
        photoUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d8/Ceci_n%E2%80%99est_pas_place_de_Nylon_%28%E5%8D%97%E6%A6%95%E5%BB%A3%E5%A0%B4%29.jpg/960px-Ceci_n%E2%80%99est_pas_place_de_Nylon_%28%E5%8D%97%E6%A6%95%E5%BB%A3%E5%A0%B4%29.jpg',
        caption: '「南榕廣場」言論自由紀念地景攝影（Wikimedia Commons CC 授權）',
      ),
    ],
    relatedCaseTitles: ['美麗島事件', '雷震案', '野百合學運'],
    relatedReadings: [
      OnThisDayReading(
        title: '《自由時代》數位典藏資料庫',
        url: 'https://www.nylon.org.tw/archive',
      ),
      OnThisDayReading(
        title: '鄭南榕紀念基金會 | 生平與精神',
        url: 'https://www.nylon.org.tw/',
      ),
      OnThisDayReading(
        title: '國家人權博物館 | 言論自由歷史軌跡',
        url: 'https://www.nhrm.gov.tw/',
      ),
    ],
    sources: [
      OnThisDaySource(
        title: '公開歷史檔案與報導',
        url: 'https://www.archives.gov.tw/',
        updatedAt: '2026-06-02',
      ),
      OnThisDaySource(
        title: '鄭南榕基金會官方紀錄',
        url: 'https://www.nylon.org.tw/',
        updatedAt: '2026-06-02',
      ),
    ],
  ),
  OnThisDayCase(
    id: '228-event-1947',
    year: 1947,
    month: 2,
    day: 28,
    location: '台北市延平北路',
    title: '二二八事件',
    category: '民主運動',
    tags: ['民主運動', '公共安全', '人權侵害'],
    summary: '1947年2月28日，由緝菸血案引發的全台性大規模衝突與後續軍事鎮壓，是台灣近代史上深遠的政治創傷。',
    quote: '歷史的傷口需要正視的勇氣，法治的基石奠定於對人權尊嚴的絕對捍衛。',
    background:
        '1947年2月27日，專賣局緝菸員在台北市大稻埕天馬茶房前暴力緝菸並開槍打死市民。次日（2月28日），市民罷市、罷課並遊行抗議，在長官公署前遭衛兵開槍掃射，衝突隨即蔓延全台。',
    backgroundDetails:
        '二戰後初期，國民政府接收台灣，由於物資缺乏、通貨膨脹、失業嚴重，加上官員貪腐與文化隔閡，省籍矛盾日益加深。緝菸血案成為引爆積怨的導火線。',
    socialImpact:
        '此事件導致台灣大量社會精英消失，並開啟了長達數十年的戒嚴與白色恐怖時期。政府於1990年代起推動平反與賠償，並訂定2月28日為國定紀念日。',
    status: '歷史案件整理',
    timeline: [
      OnThisDayTimelineNode(
        dateLabel: '1947.02.27',
        title: '天馬茶房緝菸血案',
        description: '專賣局人員暴力查緝私菸，開槍誤殺市民陳文溪，民眾圍攻警察局。',
      ),
      OnThisDayTimelineNode(
        dateLabel: '1947.02.28',
        title: '行政長官公署衝突',
        description: '群眾遊行抗議，公署衛兵開槍射擊，事件隨之擴大為武裝衝突。',
      ),
      OnThisDayTimelineNode(
        dateLabel: '1947.03.02',
        title: '成立處理委員會',
        description: '全台各地士紳成立處理委員會，向行政長官陳儀提出政治改革要求。',
      ),
      OnThisDayTimelineNode(
        dateLabel: '1947.03.08',
        title: '國軍登陸與清鄉',
        description: '國民政府自大陸調派軍隊登陸基隆，展開全台軍事鎮壓與清鄉。',
      ),
    ],
    photos: [
      OnThisDayPhoto(
        photoUrl:
            'https://upload.wikimedia.org/wikipedia/commons/9/9b/Kaohsiung_Senior_High_Students_in_the_228_incident.jpg',
        caption: '二二八事件高雄中學學生自衛隊歷史照片（Wikimedia Commons 公有領域）',
      ),
      OnThisDayPhoto(
        photoUrl:
            'https://upload.wikimedia.org/wikipedia/commons/7/7b/228_Memorial_Park_Taipei.jpg',
        caption: '台北二二八和平紀念公園與紀念碑實景（Wikimedia Commons CC 授權）',
      ),
    ],
    relatedCaseTitles: ['林宅血案', '美麗島事件', '雷震案'],
    relatedReadings: [
      OnThisDayReading(
        title: '二二八事件紀念基金會官網',
        url: 'https://www.228.org.tw/',
      ),
      OnThisDayReading(
        title: '國家發展委員會檔案管理局 | 228國家檔案',
        url: 'https://www.archives.gov.tw/english/Publish.aspx?cnid=1708',
      ),
    ],
    sources: [
      OnThisDaySource(
        title: '行政院二二八事件研究報告',
        url: 'https://www.228.org.tw/',
        updatedAt: '2026-06-02',
      ),
    ],
  ),
  OnThisDayCase(
    id: 'formosa-incident-1979',
    year: 1979,
    month: 12,
    day: 10,
    location: '高雄市新興區',
    title: '美麗島事件',
    category: '民主運動',
    tags: ['民主運動', '司法爭議', '政黨政治'],
    summary: '1979年世界人權日，美麗島雜誌社發起之集會遊行爆發警民衝突，隨後的大逮捕與大審判成為台灣民主化關鍵。',
    quote: '審判席上的直言無懼，將軍法法庭化為民主憲政啟蒙的講堂。',
    background:
        '1979年12月10日，以《美麗島》雜誌社成員為核心的黨外人士，在高雄舉辦世界人權日演講遊行。警方發射催淚彈並包圍遊行隊伍，爆發激烈衝突。事後當局對黨外人士展開大逮捕。',
    backgroundDetails:
        '事件發生於中華民國與美國斷交、國內外局勢動盪的戒嚴末期。當局試圖以此重大社會衝突徹底整肅黨外運動，隨後在軍法法庭上對黃信介、施明德、林義雄等人進行公開大審。',
    socialImpact:
        '公開審判使全台社會首次公開接觸黨外的政治主張與對法治民主的渴望。辯護律師團成員（如陳水扁、謝長廷、蘇貞昌等）後續成為推動台灣政黨輪替的核心人物。',
    status: '歷史案件整理',
    timeline: [
      OnThisDayTimelineNode(
        dateLabel: '1979.08',
        title: '美麗島雜誌創刊',
        description: '黃信介發行《美麗島》雜誌，作為團結黨外民主運動的組織平台。',
      ),
      OnThisDayTimelineNode(
        dateLabel: '1979.12.10',
        title: '世界人權日衝突',
        description: '遊行集會爆發衝突，軍警與群眾嚴重對峙，事後稱為高雄事件。',
      ),
      OnThisDayTimelineNode(
        dateLabel: '1979.12.13',
        title: '全台大逮捕',
        description: '憲警聯合出動，逮捕黃信介、施明德、呂秀蓮、陳菊等核心成員。',
      ),
      OnThisDayTimelineNode(
        dateLabel: '1980.03',
        title: '美麗島軍法大審',
        description: '公開審判過程引起國際矚目，被告於庭上慷慨陳詞，震撼台灣社會。',
      ),
    ],
    photos: [
      OnThisDayPhoto(
        photoUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c8/%E7%BE%8E%E9%BA%97%E5%B3%B6%E9%9B%9C%E8%AA%8C_Formosa_-_The_Magazine_of_TAIWAN%27s_Democratic_Movement.jpg/960px-%E7%BE%8E%E9%BA%97%E5%B3%B6%E9%9B%9C%E8%AA%8C_Formosa_-_The_Magazine_of_TAIWAN%27s_Democratic_Movement.jpg',
        caption: '1979年《美麗島》雜誌歷史刊物實照（Wikimedia Commons CC 授權）',
      ),
      OnThisDayPhoto(
        photoUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/7/75/%E7%BE%8E%E9%BA%97%E5%B3%B6%E9%9B%9C%E8%AA%8C%E7%A4%BE%E9%AB%98%E9%9B%84%E6%9C%8D%E5%8B%99%E8%99%95%E5%8E%9F%E5%9D%80.JPG/960px-%E7%BE%8E%E9%BA%97%E5%B3%B6%E9%9B%9C%E8%AA%8C%E7%A4%BE%E9%AB%98%E9%9B%84%E6%9C%8D%E5%8B%99%E8%99%95%E5%8E%9F%E5%9D%80.JPG',
        caption: '美麗島雜誌社高雄服務處歷史原址實景（Wikimedia Commons CC 授權）',
      ),
    ],
    relatedCaseTitles: ['林宅血案', '雷震案', '江南案'],
    relatedReadings: [
      OnThisDayReading(
        title: '美麗島事件軍法審判數位典藏',
        url: 'https://www.nhrm.gov.tw/',
      ),
      OnThisDayReading(
        title: '美麗島事件與律師團回顧特展',
        url: 'https://www.tba.org.tw/',
      ),
    ],
    sources: [
      OnThisDaySource(
        title: '國防部軍法大審官方判決書',
        url: 'https://www.mnd.gov.tw/',
        updatedAt: '2026-06-02',
      ),
    ],
  ),
  OnThisDayCase(
    id: 'lei-chen-1960',
    year: 1960,
    month: 9,
    day: 4,
    location: '台北市信義路',
    title: '雷震案',
    category: '言論自由',
    tags: ['言論自由', '司法爭議', '政黨政治'],
    summary: '1960年，自由中國發行人雷震因籌組反對黨並發表民主評論遭逮捕，是威權體制下打壓言論與結社自由的指標性案件。',
    quote: '如果沒有反對黨，民主憲政就只是一句沒有靈魂的空話。',
    background:
        '1960年9月4日，憲兵與警備總部逮捕《自由中國》半月刊發行人雷震、編輯傅正等人。軍事法庭以「包庇匪諜」、「煽動叛亂」罪名判處雷震有期徒刑十年。',
    backgroundDetails:
        '雷震在1950年代積極推動反對黨「中國民主黨」的籌組，並在雜誌中撰文批評蔣中正連任總統及威權壟斷，觸怒當局，因而遭受莫須有的軍法指控。',
    socialImpact:
        '自由中國遭停刊，組黨運動中斷，使台灣反對運動推遲了近二十年。然而，雷震在獄中的寫作與對自由的堅持，為後續的黨外運動奠定了論述基石。',
    status: '歷史案件整理',
    timeline: [
      OnThisDayTimelineNode(
        dateLabel: '1949.11',
        title: '自由中國創刊',
        description: '雷震、胡適等人在台北創辦《自由中國》半月刊，宣揚自由民主。',
      ),
      OnThisDayTimelineNode(
        dateLabel: '1960.05',
        title: '宣布籌組新黨',
        description: '雷震與台灣本土士紳共同發表聲明，籌組反對黨「中國民主黨」。',
      ),
      OnThisDayTimelineNode(
        dateLabel: '1960.09.04',
        title: '逮捕雷震與傅正',
        description: '在宣布組黨前夕，警總大舉逮捕雷震，並查禁相關出版物。',
      ),
      OnThisDayTimelineNode(
        dateLabel: '1960.10',
        title: '軍法判刑十年',
        description: '軍事法庭以極快速度判處雷震有期徒刑十年，胡適上書求情未果。',
      ),
    ],
    photos: [
      OnThisDayPhoto(
        photoUrl:
            'https://upload.wikimedia.org/wikipedia/commons/3/39/Lei_Chen_%281959%29.jpg',
        caption: '《自由中國》創辦人雷震先生歷史肖像（1959年攝，Wikimedia Commons 公有領域）',
      ),
    ],
    relatedCaseTitles: ['美麗島事件', '鄭南榕事件'],
    relatedReadings: [
      OnThisDayReading(
        title: '雷震紀念館暨數位典藏網',
        url: 'https://leichen.nccu.edu.tw/',
      ),
    ],
    sources: [
      OnThisDaySource(
        title: '警備總部雷震案審判卷宗',
        url: 'https://www.archives.gov.tw/',
        updatedAt: '2026-06-02',
      ),
    ],
  ),
  OnThisDayCase(
    id: 'sunflower-ly-2014',
    year: 2014,
    month: 3,
    day: 18,
    location: '台北市中正區',
    title: '太陽花學運佔領立法院',
    category: '民主運動',
    tags: ['民主運動', '司法爭議', '公民不服從'],
    summary: '2014年3月18日，為抗議兩岸服貿協議「三十秒黑箱審查」，學生與公民團體突破防線佔領立法院議場，開啟為期24天的社會運動。',
    quote: '當獨裁成為事實，革命就是義務。程序正義是法治社會不可逾越的底線。',
    background:
        '2014年3月17日，國民黨立委張慶忠在聯席會中以三十秒宣告服貿協議「已視為審查，送院會存查」。不滿黑箱作業的學生與民眾，於3月18日晚間突破立法院警衛防線，成功進佔議場。',
    backgroundDetails:
        '此案引發關於「集會自由」、「阻卻違法事由（公民不服從）」與「緊急避難」等重大憲法與法律辯論。起訴多人的刑事訴訟最終由法院以公民不服從之憲法法理判定無罪確定。',
    socialImpact:
        '該運動阻止了服貿協議通過，重塑了台灣的政黨版圖與公民運動模式，並使「公民不服從」與「程序正義」在法學界與司法實務中獲得深入探討。',
    status: '歷史案件整理',
    timeline: [
      OnThisDayTimelineNode(
        dateLabel: '2014.03.17',
        title: '三十秒服貿黑箱宣示',
        description: '立委張慶忠以极速宣稱服貿已完成審查，引發社會譁然。',
      ),
      OnThisDayTimelineNode(
        dateLabel: '2014.03.18',
        title: '突襲佔領立法院議場',
        description: '抗議民眾與學生於晚間九時衝入立法院並封鎖議場通道，展開長期靜坐。',
      ),
      OnThisDayTimelineNode(
        dateLabel: '2014.04.06',
        title: '院長王金平到場承諾',
        description: '立法院長王金平承諾「先立法、再審查」，學生接受後宣布退場。',
      ),
      OnThisDayTimelineNode(
        dateLabel: '2014.04.10',
        title: '正式退場',
        description: '學生離開議場，結束長達24天的抗爭行動。',
      ),
    ],
    photos: [
      OnThisDayPhoto(
        photoUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/1/17/Sunflower_Movement_collage.jpg/960px-Sunflower_Movement_collage.jpg',
        caption: '2014年太陽花學運佔領立法院與集會遊行實景紀錄（Wikimedia Commons CC 授權）',
      ),
    ],
    relatedCaseTitles: ['太陽花學運佔領行政院', '野百合學運'],
    relatedReadings: [
      OnThisDayReading(
        title: '台北地方法院 104 年度矚訴字第 1 號判決書（立法院案無罪判決）',
        url: 'https://law.moj.gov.tw/',
      ),
    ],
    sources: [
      OnThisDaySource(
        title: '司法最新裁判書查詢系統',
        url: 'https://jud.judicial.gov.tw/',
        updatedAt: '2026-06-02',
      ),
    ],
  ),
  OnThisDayCase(
    id: 'sunflower-ey-2014',
    year: 2014,
    month: 3,
    day: 23,
    location: '台北市中正區',
    title: '太陽花學運佔領行政院',
    category: '司法爭議',
    tags: ['司法爭議', '公共安全', '公民不服從'],
    summary: '2014年3月23日，抗議服貿部分群眾轉往佔領行政院，遭到警方強力驅離，引發後續「國家暴力」與「煽惑他人犯罪」之訴訟爭議。',
    quote: '法治國家之執法應維持比例原則，任何公權力的動用皆須受到正當程序的檢驗。',
    background:
        '學運期間，不滿馬英九總統對學生訴求的回應，一部分抗議者於3月23日晚間衝入行政院院區並試圖佔領辦公大樓。行政院隨即宣布戒備，警方於24日清晨發動數波暴力驅離。',
    backgroundDetails:
        '本案相較於立法院案，涉及較嚴重的肢體衝突與公權力越界爭議。後續起訴中，最高法院針對「煽惑他人犯罪」與「抵抗權」做出了關鍵性的法律闡釋與翻轉。',
    socialImpact:
        '警方的強力驅離造成多人受傷，引發關於「國家暴力」的嚴厲指責。此案推動了公民對警察執法界線、比例原則及公務員違法執行職務賠償的討論。',
    status: '歷史案件整理',
    timeline: [
      OnThisDayTimelineNode(
        dateLabel: '2014.03.23',
        title: '衝擊行政院',
        description: '晚間大批民眾越過行政院拒馬圍牆，進入中庭並試圖爬入大樓。',
      ),
      OnThisDayTimelineNode(
        dateLabel: '2014.03.24',
        title: '流血驅離行動',
        description: '鎮暴警察以水龍頭與警棍進行強制驅離，警民爆發激烈流血衝突。',
      ),
      OnThisDayTimelineNode(
        dateLabel: '2020.04',
        title: '高院改判魏揚等人有罪',
        description: '高等法院二審以「煽惑他人犯罪」改判魏揚等有罪，引發輿論議論。',
      ),
      OnThisDayTimelineNode(
        dateLabel: '2021.10',
        title: '最高法院撤銷發回',
        description: '最高法院認定人民擁有「抵抗權」與「公民不服從」，撤銷有罪判決。',
      ),
    ],
    photos: [
      OnThisDayPhoto(
        photoUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2b/Taipei_Sunflower_Movement_Lonely_Morning_Sunflower_%2813662063795%29.jpg/960px-Taipei_Sunflower_Movement_Lonely_Morning_Sunflower_%2813662063795%29.jpg',
        caption: '2014年3月太陽花學運抗爭現場實景攝影（Wikimedia Commons CC 授權）',
      ),
    ],
    relatedCaseTitles: ['太陽花學運佔領立法院', '美麗島事件'],
    relatedReadings: [
      OnThisDayReading(
        title: '最高法院 110 年度台上字第 4 號刑事判決',
        url: 'https://law.moj.gov.tw/',
      ),
    ],
    sources: [
      OnThisDaySource(
        title: '司法院最新裁判書',
        url: 'https://jud.judicial.gov.tw/',
        updatedAt: '2026-06-02',
      ),
    ],
  ),
  OnThisDayCase(
    id: '319-shooting-2004',
    year: 2004,
    month: 3,
    day: 19,
    location: '台南市金華路',
    title: '319槍擊事件',
    category: '公共安全',
    tags: ['公共安全', '司法爭議', '政黨政治'],
    summary: '2004年總統大選投票前夕，總統陳水扁與副總統呂秀蓮於台南掃街時遭槍擊受傷，對選情及政治局勢產生重大震撼。',
    quote: '真相的追尋是法治誠信的基礎，面對政治高度敏感案件，更需以科學與程序釐清疑雲。',
    background:
        '2004年3月19日下午，陳水扁與呂秀蓮在台南市進行車隊掃街拜票。現場鞭炮聲中，兩人遭土製槍彈擊中受傷。送醫治療後無生命危險。翌日大選照常舉行，陳呂以極微小差距勝選連任。',
    backgroundDetails:
        '本案引發關於選罷法「暫停選舉」規定、國安機制啟動及刑事調查真實性的巨大爭議。台南地檢署與刑事局成立專案小組，於2005年鎖定已自殺身亡的嫌犯陳義雄並予以簽結。',
    socialImpact:
        '事件造成長期的社會對立與政治爭議，朝野隨後成立「319真相調查特別委員會」，針對案件真偽及調查程序進行長年交鋒。本案亦促進了國安特勤機制的法律化修補。',
    status: '歷史案件整理',
    timeline: [
      OnThisDayTimelineNode(
        dateLabel: '2004.03.19',
        title: '金華路遭槍擊',
        description: '下午約1時45分，吉普車上的陳水扁與呂秀蓮突遭槍擊，送奇美醫院急救。',
      ),
      OnThisDayTimelineNode(
        dateLabel: '2004.03.20',
        title: '正副總統大選投票',
        description: '選舉如期舉行，陳呂以不足三萬票（0.228%）的差距擊敗連宋組合。',
      ),
      OnThisDayTimelineNode(
        dateLabel: '2004.08',
        title: '真調會條例通過',
        description: '立法院在野黨主導通過「三一九槍擊事件真相調查特別委員會條例」，引發違憲爭議。',
      ),
      OnThisDayTimelineNode(
        dateLabel: '2005.08',
        title: '專案小組結案公佈',
        description: '刑事局宣佈偵結，認定嫌犯為已溺斃的陳義雄，檢方予以不起訴處分。',
      ),
    ],
    photos: [
      OnThisDayPhoto(
        photoUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1f/Judicial_Yuan_Building_20140307.jpg/960px-Judicial_Yuan_Building_20140307.jpg',
        caption: '司法院大廈實景：大法官作成釋字第585號解釋審查真調會條例合憲性（Wikimedia Commons CC 授權）',
      ),
    ],
    relatedCaseTitles: ['江南案', '鄭南榕事件'],
    relatedReadings: [
      OnThisDayReading(
        title: '司法院釋字第 585 號解釋（真調會條例部分違憲）',
        url: 'https://cons.judicial.gov.tw/',
      ),
    ],
    sources: [
      OnThisDaySource(
        title: '最高檢察署特別偵查組報告資料',
        url: 'https://www.tps.moj.gov.tw/',
        updatedAt: '2026-06-02',
      ),
    ],
  ),
  OnThisDayCase(
    id: 'tca-founding-1921',
    year: 1921,
    month: 10,
    day: 17,
    location: '台北市大稻埕',
    title: '臺灣文化協會創立',
    category: '民主運動',
    tags: ['民主運動', '言論自由', '歷史事件'],
    summary: '1921年10月17日，林獻堂、蔣渭水等人成立臺灣文化協會，以文化啟蒙為名，實質推動台灣人對抗日本殖民統治的法治與自治運動。',
    quote: '台灣是台灣人的台灣。以文化啟迪民智，以法理力爭民權。',
    background:
        '1921年10月17日，在台北市大稻埕靜修女子中學召開臺灣文化協會創立大會。協會以「謀台灣文化之向上」為宗旨，透過讀報社、講習會、巡迴演講、電影放映等，推廣現代思想與民權法治意識。',
    backgroundDetails:
        '在日治中期，台灣知識精英體認到武裝抗日已不可行，轉而採取非暴力法治抗爭。文協成立後，與「臺灣議會設置請願運動」互相呼應，多次挑戰總督府的《治安警察法》限制。',
    socialImpact:
        '文協是台灣近代史上最大規模的文化與政治啟蒙組織，深刻激發了台灣人的主體意識與階級覺醒，並孕育了後續的臺灣民眾黨及多個農工抗爭團體。',
    status: '歷史案件整理',
    timeline: [
      OnThisDayTimelineNode(
        dateLabel: '1921.10.17',
        title: '召開創立大會',
        description: '推舉林獻堂為總理，蔣渭水為專務理事，通過會則並確立啟蒙宗旨。',
      ),
      OnThisDayTimelineNode(
        dateLabel: '1923.12',
        title: '治安警察法違反事件',
        description: '因文協成員請願組黨，總督府發動全台大逮捕，史稱「治警事件」。',
      ),
      OnThisDayTimelineNode(
        dateLabel: '1927.01',
        title: '文協分裂',
        description: '因左右翼路線鬥爭，協會於新竹大會分裂，右翼另組臺灣民眾黨。',
      ),
    ],
    photos: [
      OnThisDayPhoto(
        photoUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/1/12/Anthem_of_the_Taiwanese_Cultural_Association_20210313.jpg/960px-Anthem_of_the_Taiwanese_Cultural_Association_20210313.jpg',
        caption: '臺灣文化協會《會歌》歷史文物展覽攝影（Wikimedia Commons CC 授權）',
      ),
    ],
    relatedCaseTitles: ['雷震案', '美麗島事件'],
    relatedReadings: [
      OnThisDayReading(
        title: '國立台灣歷史博物館 | 臺灣文化協會百年回顧',
        url: 'https://www.nmth.gov.tw/',
      ),
    ],
    sources: [
      OnThisDaySource(
        title: '總督府警察沿革誌歷史紀錄',
        url: 'https://th.gov.tw/',
        updatedAt: '2026-06-02',
      ),
    ],
  ),
  OnThisDayCase(
    id: 'lin-family-massacre-1980',
    year: 1980,
    month: 2,
    day: 28,
    location: '台北市信義路',
    title: '林宅血案',
    category: '公共安全',
    tags: ['公共安全', '人權侵害', '司法爭議'],
    summary: '1980年2月28日，美麗島事件被告林義雄遭扣押期間，其母與雙胞胎女兒於住宅內遭刺殺身亡，是白色恐怖時期的重大懸案。',
    quote: '在威權與黑暗的深處，無辜者的血淚敲擊著台灣民主憲法前行的晨鐘。',
    background:
        '1980年2月28日中午，因美麗島事件被扣押在景美軍法處的林義雄，其位於台北市信義路的住宅內，母親林游阿妹及七歲雙胞胎女兒林亮均、林婷均遭刺客持刀殺害身亡，大女兒林奐均重傷經搶救生還。',
    backgroundDetails:
        '案發當天適逢二二八事件三十三週年紀念日，且林宅處於治安機關的嚴密監控之下。兇手行兇手法極其專業，案發後警方專案小組經年調查卻始終無法破案，被懷疑與當局特務系統有關。',
    socialImpact:
        '此案引起國際社會強烈譴責，並對國民黨威權體制造成極大的道德正當性打擊，激發了台灣人民對政治改革及保障基本人權的更強烈追求。',
    status: '歷史案件整理',
    timeline: [
      OnThisDayTimelineNode(
        dateLabel: '1979.12.13',
        title: '林義雄因美麗島案遭逮捕',
        description: '林義雄在家中遭宪兵逮捕，扣押於軍事檢察署。',
      ),
      OnThisDayTimelineNode(
        dateLabel: '1980.02.28',
        title: '林宅命案發生',
        description: '林宅爆發駭人聽聞的祖孫刺殺案，專案小組成立「撥雲專案」進行調查。',
      ),
      OnThisDayTimelineNode(
        dateLabel: '2020.02',
        title: '促轉會公佈調查報告',
        description: '促進轉型正義委員會公佈調查，指出案發時治安機關監聽錄音遭銷毀，強烈暗示當局涉入。',
      ),
    ],
    photos: [
      OnThisDayPhoto(
        photoUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/50/%E6%9E%97%E7%BE%A9%E9%9B%84%E5%AE%B6%E6%9B%B8.jpg/960px-%E6%9E%97%E7%BE%A9%E9%9B%84%E5%AE%B6%E6%9B%B8.jpg',
        caption: '林義雄獄中家書歷史手稿紀錄照片（Wikimedia Commons CC 授權）',
      ),
    ],
    relatedCaseTitles: ['二二八事件', '美麗島事件', '江南案'],
    relatedReadings: [
      OnThisDayReading(
        title: '促進轉型正義委員會 | 林宅血案調查報告書',
        url: 'https://www.tjc.gov.tw/',
      ),
    ],
    sources: [
      OnThisDaySource(
        title: '促轉會國家檔案庫',
        url: 'https://www.archives.gov.tw/',
        updatedAt: '2026-06-02',
      ),
    ],
  ),
  OnThisDayCase(
    id: 'chiang-nan-1984',
    year: 1984,
    month: 10,
    day: 15,
    location: '美國加州戴利城',
    title: '江南案',
    category: '司法爭議',
    tags: ['司法爭議', '公共安全', '外交事件'],
    summary: '1984年10月15日，作家劉宜良（筆名江南）於美國遭台灣黑幫成員刺殺身亡，隨後證實有台灣情報機關高層介入，震驚台美政壇。',
    quote: '司法獨立與國家安全不應成為謀殺與打壓異己言論的遮羞布。',
    background:
        '1984年10月15日上午，撰寫《蔣經國傳》的華裔作家劉宜良，在加州自宅地下室遭台灣竹聯幫成員陳啟禮、吳敦、董桂森槍擊身亡。美國聯邦調查局迅速介入調查。',
    backgroundDetails:
        '調查證實，中華民國國防部情報局局長汪希苓、副局長胡儀敏等人指派竹聯幫赴美執行該「制裁」行動。案發後蔣經國總統下令逮捕汪希苓等人，並向美方表達歉意與配合司法調查。',
    socialImpact:
        '本案導致台美關係陷入嚴重危機，迫使蔣經國總統加速推進台灣的民主化進程，並宣示蔣家後代將不會接任總統，實質上終結了威權世襲体制。',
    status: '歷史案件整理',
    timeline: [
      OnThisDayTimelineNode(
        dateLabel: '1984.10.15',
        title: '加州自宅遭槍殺',
        description: '劉宜良於美國住處車庫遭槍手擊中頭部身亡，引發外交風波。',
      ),
      OnThisDayTimelineNode(
        dateLabel: '1984.11',
        title: '一清專案啟動',
        description: '台灣官方發動大規模掃黑「一清專案」，逮捕陳啟禮等人，陳隨後透露情報局指派內幕。',
      ),
      OnThisDayTimelineNode(
        dateLabel: '1985.04',
        title: '台北地院大審',
        description: '陳啟禮、吳敦因共同謀殺罪判處無期徒刑。情報局長汪希苓亦被改送軍法判處無期徒刑。',
      ),
    ],
    photos: [
      OnThisDayPhoto(
        photoUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/2/21/Criminal_Division_Building%2C_Taiwan_High_Court_20221113.jpg/960px-Criminal_Division_Building%2C_Taiwan_High_Court_20221113.jpg',
        caption: '臺灣高等法院刑事庭大廈實景：承審江南案相關司法審判程序（Wikimedia Commons CC 授權）',
      ),
    ],
    relatedCaseTitles: ['美麗島事件', '林宅血案', '319槍擊事件'],
    relatedReadings: [
      OnThisDayReading(
        title: '江南案與台美政治風暴歷史專題',
        url: 'https://www.archives.gov.tw/',
      ),
    ],
    sources: [
      OnThisDaySource(
        title: '台北地方法院 74 年度矚訴字第 1 號判決書及情報局卷宗',
        url: 'https://www.tpde.moj.gov.tw/',
        updatedAt: '2026-06-02',
      ),
    ],
  ),
];

OnThisDayCase? onThisDayCaseById(String id) {
  try {
    return onThisDayCases.firstWhere((c) => c.id == id);
  } catch (__) {
    return null;
  }
}

List<OnThisDayCase> onThisDayCasesForDate(int month, int day) {
  return onThisDayCases.where((c) => c.month == month && c.day == day).toList();
}

List<OnThisDayCase> onThisDayCasesForMonth(int month) {
  final list = onThisDayCases.where((c) => c.month == month).toList()
    ..sort((a, b) => a.day.compareTo(b.day));
  return list;
}

/// 取得指定月／日最鄰近的歷史案件：
/// 1. 若當日即有事件，回傳當日第一筆；
/// 2. 否則優先在「當月」尋找即將到來或最近剛過的歷史日期；
/// 3. 若當月無館藏，則依全年日序尋找最接近的下一筆歷史事件。
OnThisDayCase? onThisDayNearestCaseForDate(int month, int day) {
  if (onThisDayCases.isEmpty) return null;

  final exact = onThisDayCasesForDate(month, day);
  if (exact.isNotEmpty) return exact.first;

  final sameMonth = onThisDayCasesForMonth(month);
  if (sameMonth.isNotEmpty) {
    final upcoming = sameMonth.where((c) => c.day > day).toList();
    if (upcoming.isNotEmpty) return upcoming.first;
    return sameMonth.last;
  }

  int dayIndex(int m, int d) => m * 32 + d;
  final target = dayIndex(month, day);
  final sorted = [...onThisDayCases]
    ..sort((a, b) => dayIndex(a.month, a.day).compareTo(dayIndex(b.month, b.day)));
  for (final c in sorted) {
    if (dayIndex(c.month, c.day) >= target) return c;
  }
  return sorted.first;
}

const List<OnThisDayLegalQuote> onThisDayLegalQuotes = [
  OnThisDayLegalQuote(
    quote: '法律的生命不在於邏輯，而在於經驗。',
    author: '奧利弗·溫德爾·霍姆斯',
    reflectiveQuestion: '你認為在判決中，法官應該更看重邏輯推理還是社會現實？',
  ),
  OnThisDayLegalQuote(
    quote: '正義不僅要實現，而且要以看得見的方式實現。',
    author: '戈登·休厄特',
    reflectiveQuestion: '當法庭審判過程不透明時，即使結果正確，公眾還會相信正義嗎？',
  ),
  OnThisDayLegalQuote(
    quote: '法律如果推不開特權的門，也擋不住暴力的風。',
    author: '梁啟超',
    reflectiveQuestion: '在威權體制或特權面前，法律如何能保持其尊嚴與公正？',
  ),
  OnThisDayLegalQuote(
    quote: '在民主國家，法律就是國王；在專制國家，國王就是法律。',
    author: '湯瑪斯·潘恩',
    reflectiveQuestion: '我們如何防範擁有權力的人將自己的意志凌駕於法律之上？',
  ),
  OnThisDayLegalQuote(
    quote: '一個不公正的法律根本就不是法律。',
    author: '聖奧古斯丁',
    reflectiveQuestion: '當法律與社會的道德正義發生嚴重衝突時，公民該如何面對？',
  ),
  OnThisDayLegalQuote(
    quote: '法律應當與正義同行，否則它只是有組織的暴力。',
    author: '古斯塔夫·拉德布魯赫',
    reflectiveQuestion: '當惡法被制定並執行時，司法人員應當選擇恪守條文還是拒絕執行？',
  ),
];
