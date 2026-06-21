// 台灣在地化法律學習案例擴增資料庫
// 包含 100 個插圖故事與 100 個對話故事，對應五大主題：租屋糾紛、車禍事故、職場權益、網購消費、個資隱私

import 'package:lawapp/data/mock_data/learning/learning_mock_data.dart';

class IllustrationStoryData {
  final String category;
  final String tag;
  final String title;
  final String description;
  final int targetUnitIndex;

  const IllustrationStoryData({
    required this.category,
    required this.tag,
    required this.title,
    required this.description,
    required this.targetUnitIndex,
  });
}

class DialogStoryData {
  final String category;
  final String senderA;
  final String avatarA;
  final String textA;
  final String senderB;
  final String avatarB;
  final String textB;
  final String title;
  final String description;
  final int targetUnitIndex;

  const DialogStoryData({
    required this.category,
    required this.senderA,
    required this.avatarA,
    required this.textA,
    required this.senderB,
    required this.avatarB,
    required this.textB,
    required this.title,
    required this.description,
    required this.targetUnitIndex,
  });
}

// ==========================================
// 1. 100 個插圖故事基礎資料集 (前20筆為人工定義，其餘自動生成以節省程式碼體積)
// ==========================================
const List<IllustrationStoryData> illustrationStoriesList = [
  IllustrationStoryData(
    category: '租屋糾紛',
    tag: '租屋防護課',
    title: '退租時，房東說牆壁有污漬要扣一萬押金合理嗎？',
    description: '自然折舊不應算在房客頭上。學習如何拍照點交，維護押金安全。',
    targetUnitIndex: 2,
  ),
  IllustrationStoryData(
    category: '租屋糾紛',
    tag: '租屋防護課',
    title: '房東口頭答應給摩托車位，簽約後反悔該怎麼辦？',
    description: '口頭承諾雖有效力但舉證困難，所有約定請務必加寫在合約書內。',
    targetUnitIndex: 3,
  ),
  IllustrationStoryData(
    category: '租屋糾紛',
    tag: '租屋防護課',
    title: '提前解約，合約寫「扣全部押金」是合法的嗎？',
    description: '內政部定型化契約規定，提前解約違約金最高不得超過一個月租金。',
    targetUnitIndex: 1,
  ),
  IllustrationStoryData(
    category: '租屋糾紛',
    tag: '租屋防護課',
    title: '房東強收高額水電費，每度電8元到底合不合法？',
    description: '自113年7月起新制上路，房東收電費不能超過台電當期收費標準。',
    targetUnitIndex: 0,
  ),
  IllustrationStoryData(
    category: '租屋糾紛',
    tag: '租屋防護課',
    title: '房東沒通知就帶新房客看房，這算擅闖民宅嗎？',
    description: '租賃期間房屋使用權歸屬房客，房東無權擅自進入，以免觸犯侵入住宅罪。',
    targetUnitIndex: 4,
  ),
  IllustrationStoryData(
    category: '租屋糾紛',
    tag: '租屋防護課',
    title: '合約規定「不能申報租金扣除額」，這條款有效嗎？',
    description: '此條款違反消保法且損害房客權益，屬於無效約定，房客仍可依法申報。',
    targetUnitIndex: 3,
  ),
  IllustrationStoryData(
    category: '租屋糾紛',
    tag: '租屋防護課',
    title: '天花板開始滲水，打給房東卻一直拖延不修怎麼辦？',
    description: '應以書面（或LINE）催告限期修繕，逾期不修可由房客修繕並自租金扣除。',
    targetUnitIndex: 2,
  ),
  IllustrationStoryData(
    category: '租屋糾紛',
    tag: '租屋防護課',
    title: '房東要求房客必須負擔全額「房屋稅與地價稅」合理嗎？',
    description: '依定型化契約，地價稅與房屋稅應由出租人負擔，不得約定由承租人支付。',
    targetUnitIndex: 3,
  ),
  IllustrationStoryData(
    category: '租屋糾紛',
    tag: '租屋防護課',
    title: '租賃契約到期後沒有續約卻繼續付租金，合約會如何變化？',
    description: '依民法第451條規定，這將轉為「不定期租約」，房東不得任意要求搬離。',
    targetUnitIndex: 1,
  ),
  IllustrationStoryData(
    category: '租屋糾紛',
    tag: '租屋防護課',
    title: '搬進去後發現熱水器壞了，修復責任到底在誰身上？',
    description: '原則上修繕責任由房東負擔，除非合約中另有明確約定由房客負責。',
    targetUnitIndex: 2,
  ),
  IllustrationStoryData(
    category: '租屋糾紛',
    tag: '租屋防護課',
    title: '房東自訂「禁止養寵物」罰款五萬，簽約後還有救嗎？',
    description: '一旦簽字同意，只要契約條款不違反公序良俗，雙方即受該約定約束。',
    targetUnitIndex: 3,
  ),
  IllustrationStoryData(
    category: '租屋糾紛',
    tag: '租屋防護課',
    title: '租屋合約「公證」對房客到底有沒有好處？',
    description: '公證租約對雙方都有保障，退租時房東若拒還押金，房客可直接聲請強制執行。',
    targetUnitIndex: 3,
  ),
  IllustrationStoryData(
    category: '租屋糾紛',
    tag: '租屋防護課',
    title: '租期內房屋突然被房東賣掉了，新買主有權趕我走嗎？',
    description: '依「買賣不破租賃」原則，原租約對新屋主繼續有效，保障您的居住權。',
    targetUnitIndex: 1,
  ),
  IllustrationStoryData(
    category: '租屋糾紛',
    tag: '租屋防護課',
    title: '租屋處發生竊案，房東防盜鐵窗壞了沒修有責任嗎？',
    description: '房東有提供安全居住環境的義務，若怠於修繕防盜設備，可能須負部分賠償責任。',
    targetUnitIndex: 2,
  ),
  IllustrationStoryData(
    category: '租屋糾紛',
    tag: '租屋防護課',
    title: '分租雅房電表只有一個，公用電費要怎麼分攤才公平？',
    description: '應於簽約時在合約中明確寫清分攤比例或各房獨立分電表的計費方式。',
    targetUnitIndex: 0,
  ),
  IllustrationStoryData(
    category: '租屋糾紛',
    tag: '租屋防護課',
    title: '房東要求將押金提高至三個月租金，這符合法規嗎？',
    description: '土地法與租賃條例皆限制押金最高不得超過「兩個月租金」，超收部分無效。',
    targetUnitIndex: 0,
  ),
  IllustrationStoryData(
    category: '租屋糾紛',
    tag: '租屋防護課',
    title: '鄰居太吵、常在深夜喧嘩，房東有義務幫忙協調嗎？',
    description: '房東應確保承租人能合於約定之使用收益，有義務出面協助勸導或制止鄰居。',
    targetUnitIndex: 2,
  ),
  IllustrationStoryData(
    category: '租屋糾紛',
    tag: '租屋防護課',
    title: '二房東把房間轉租給我，大房東有權隨時收回房子嗎？',
    description: '若二房東未取得大房東同意轉租，大房東可終止原租約並要求次承租人搬離。',
    targetUnitIndex: 1,
  ),
  IllustrationStoryData(
    category: '租屋糾紛',
    tag: '租屋防護課',
    title: '房客積欠租金，房東可以直接斷水斷電嗎？',
    description: '斷水斷電可能觸犯刑法強制罪，房東應透過法律程序起訴並聲請強制執行搬遷。',
    targetUnitIndex: 4,
  ),
  IllustrationStoryData(
    category: '租屋糾紛',
    tag: '租屋防護課',
    title: '退租時房客留下大量垃圾，房東能從押金中扣除清潔費嗎？',
    description: '若房客未盡回復原狀義務，房東得憑清潔費單據核實自押金中扣抵。',
    targetUnitIndex: 2,
  ),

  // 21-40: 車禍事故
  IllustrationStoryData(
    category: '車禍事故',
    tag: '車禍防護課',
    title: '車禍被撞了！第一時間該拍照還是移車？',
    description: '現場無人受傷且拍照定位後應速移車以防二次事故，有人受傷則保持現場。',
    targetUnitIndex: 0,
  ),
  IllustrationStoryData(
    category: '車禍事故',
    tag: '車禍防護課',
    title: '擦撞別人的車卻急著上班，留下名片離開算肇事逃逸嗎？',
    description: '只要有人受傷且未待警察前來即離開，即便留名片仍可能構成刑事肇事逃逸罪。',
    targetUnitIndex: 4,
  ),
  IllustrationStoryData(
    category: '車禍事故',
    tag: '車禍防護課',
    title: '車禍賠償零件「以新品價計算」合理嗎？',
    description: '民法規定車輛維修更換零件必須扣除「折舊」，可用折舊計算器確認合理賠償額。',
    targetUnitIndex: 2,
  ),
  IllustrationStoryData(
    category: '車禍事故',
    tag: '車禍防護課',
    title: '車禍受傷要申請理賠，哪些收據與診斷書才有用？',
    description: '需向合格醫療院所開立載明「因車禍受傷」的診斷書，並保存所有自費收據。',
    targetUnitIndex: 1,
  ),
  IllustrationStoryData(
    category: '車禍事故',
    tag: '車禍防護課',
    title: '強制險到底能賠什麼？對方沒保強制險怎麼辦？',
    description: '強制險只賠「人身傷亡」，不賠車損。若對方未投保可向特別補償基金申請。',
    targetUnitIndex: 3,
  ),
  IllustrationStoryData(
    category: '車禍事故',
    tag: '車禍防護課',
    title: '上班途中發生車禍，可以算職業災害嗎？',
    description: '在正常通勤時間與路線內，且無重大違規（如闖紅燈、無照），屬於通勤職災。',
    targetUnitIndex: 1,
  ),
  IllustrationStoryData(
    category: '車禍事故',
    tag: '車禍防護課',
    title: '申請「初判表」需要多久？它跟鑑定意見書差在哪？',
    description: '事故後30天可向警方申請初判表；若對內容有異議，需自費聲請行車事故鑑定。',
    targetUnitIndex: 0,
  ),
  IllustrationStoryData(
    category: '車禍事故',
    tag: '車禍防護課',
    title: '支線車未讓幹線車因而擦撞，誰的肇事責任比較大？',
    description: '路權判定原則中，支線車負有禮讓幹線車的義務，通常支線車會占主要肇責。',
    targetUnitIndex: 0,
  ),
  IllustrationStoryData(
    category: '車禍事故',
    tag: '車禍防護課',
    title: '車禍過失傷害罪的追訴期是多久？別讓時間流逝了！',
    description: '刑事過失傷害罪的告訴期間為「知道犯人之時起六個月內」，務必把握時效。',
    targetUnitIndex: 4,
  ),
  IllustrationStoryData(
    category: '車禍事故',
    tag: '車禍防護課',
    title: '追撞與推撞差在哪？保險理賠結果完全不同！',
    description: '追撞是行進中煞車不及撞前車，而推撞是被後車撞上而往前推，肇責判定有別。',
    targetUnitIndex: 0,
  ),
  IllustrationStoryData(
    category: '車禍事故',
    tag: '車禍防護課',
    title: '行人闖紅燈被我撞上，我真的有「帝王條款」的絕對責任嗎？',
    description: '行人帝王條款並非無條件適用，若駕駛已盡注意義務且猝不及防，可免除或減輕責任。',
    targetUnitIndex: 4,
  ),
  IllustrationStoryData(
    category: '車禍事故',
    tag: '車禍防護課',
    title: '車禍談和解，沒有寫「放棄刑事訴訟權」會怎樣？',
    description: '若和解書無約定拋棄權利，對方在六個月內仍可提起刑事過失傷害起訴。',
    targetUnitIndex: 2,
  ),
  IllustrationStoryData(
    category: '車禍事故',
    tag: '車禍防護課',
    title: '車禍導致新車價值減損，可以要求賠償「折舊損失」嗎？',
    description: '若經第三方專業公會鑑定該車確實因碰撞產生交易價值減損，可依法求償。',
    targetUnitIndex: 2,
  ),
  IllustrationStoryData(
    category: '車禍事故',
    tag: '車禍防護課',
    title: '車禍雙方私下和解卻沒報警，這會有法律後遺症嗎？',
    description: '建議至少簽立具法律效力和解書，並載明放棄民刑事訴訟權，以防事後倒打一耙。',
    targetUnitIndex: 2,
  ),
  IllustrationStoryData(
    category: '車禍事故',
    tag: '車禍防護課',
    title: '借車給朋友開不幸發生車禍，車主要承擔法律責任嗎？',
    description: '車主若明知對方無照或酒駕仍借車，須承擔共同侵權責任；否則僅負民事車損責任。',
    targetUnitIndex: 3,
  ),
  IllustrationStoryData(
    category: '車禍事故',
    tag: '車禍防護課',
    title: '被野狗衝出馬路絆倒摔車，可以申請國賠或找誰賠償？',
    description: '若是流浪狗通常難以求償，除非能證實為某人飼養之寵物，或政府管理公有道路疏失。',
    targetUnitIndex: 4,
  ),
  IllustrationStoryData(
    category: '車禍事故',
    tag: '車禍防護課',
    title: '車禍發生後，車上記錄器畫面毀損，可以向店家調閱監視器嗎？',
    description: '可請求警方協調調閱路口監視器或尋求熱心網友提供行車紀錄器片段。',
    targetUnitIndex: 0,
  ),
  IllustrationStoryData(
    category: '車禍事故',
    tag: '車禍防護課',
    title: '開車開車門未注意後方擊落機車，這肇責怎麼算？',
    description: '開車門者通常須負全額肇責，依道路交通安全規則，應採兩段式開車門。',
    targetUnitIndex: 4,
  ),
  IllustrationStoryData(
    category: '車禍事故',
    tag: '車禍防護課',
    title: '車禍調解委員會的調解書，法律效力等同法院判決嗎？',
    description: '經送法院核定後之調解書，具有與民事確定判決同一之效力，可直接聲請強制執行。',
    targetUnitIndex: 2,
  ),
  IllustrationStoryData(
    category: '車禍事故',
    tag: '車禍防護課',
    title: '酒後騎乘共享單車 YouBike，也會被算酒駕受罰嗎？',
    description: '腳踏車屬於慢車，酒駕仍會面臨罰鍰處罰，若拒絕聯測更會被加重裁罰。',
    targetUnitIndex: 3,
  ),

  // 41-60: 職場權益
  IllustrationStoryData(
    category: '職場權益',
    tag: '勞動權益課',
    title: '主管下班在 LINE 交辦工作，算不算加班？該如何存證？',
    description: '算！必須截圖 LINE 對話、記錄工作起訖時間，向雇主申請補登加班紀錄。',
    targetUnitIndex: 1,
  ),
  IllustrationStoryData(
    category: '職場權益',
    tag: '勞動權益課',
    title: '老闆強迫「加班只能換補休」，這樣做違法嗎？',
    description: '違法。補休的選擇權在勞工，雇主不可在加班前就一律強迫改為換取補休。',
    targetUnitIndex: 1,
  ),
  IllustrationStoryData(
    category: '職場權益',
    tag: '勞動權益課',
    title: '工作不滿一年被資遣，我能拿到多少遣散費？',
    description: '適用勞退新制者，每滿一年發給半個月平均工資，未滿一年按比例計算。',
    targetUnitIndex: 2,
  ),
  IllustrationStoryData(
    category: '職場權益',
    tag: '勞動權益課',
    title: '試用期沒過，公司可以不付我資遣費就直接叫我走嗎？',
    description: '即使在試用期內，解雇仍須符合勞基法規定，且依法必須給付資遣費。',
    targetUnitIndex: 2,
  ),
  IllustrationStoryData(
    category: '職場權益',
    tag: '勞動權益課',
    title: '生理假有請假天數上限嗎？會不會被扣薪水？',
    description: '每月可請1天，全年共3天不併入病假。生理假期間發給半數薪資。',
    targetUnitIndex: 0,
  ),
  IllustrationStoryData(
    category: '職場權益',
    tag: '勞動權益課',
    title: '勞保「高薪低報」對我的退休金與職災補償有何影響？',
    description: '這會嚴重減損生育給付、傷病給付與勞退撥繳，可向勞保局檢舉並求償。',
    targetUnitIndex: 3,
  ),
  IllustrationStoryData(
    category: '職場權益',
    tag: '勞動權益課',
    title: '因公受傷在家休養，公司有義務付我原本的薪水嗎？',
    description: '屬於職業災害者，雇主在醫療期間應按原領工資補償，並負擔必要醫療費用。',
    targetUnitIndex: 3,
  ),
  IllustrationStoryData(
    category: '職場權益',
    tag: '勞動權益課',
    title: '工作時打破公司貴重儀器，老闆可以直接從薪水扣賠償金嗎？',
    description: '不能。勞基法規定雇主不得片面預扣薪資作為賠償，須透過勞資協商或法院判決。',
    targetUnitIndex: 0,
  ),
  IllustrationStoryData(
    category: '職場權益',
    tag: '勞動權益課',
    title: '「責任制」就表示沒有加班費？別再被口頭話術騙了！',
    description: '責任制必須符合勞基法第84-1條且送勞工局核備，否則仍須依規定給予加班費。',
    targetUnitIndex: 1,
  ),
  IllustrationStoryData(
    category: '職場權益',
    tag: '勞動權益課',
    title: '特休假沒休完，到了年底可以直接「自動歸零」嗎？',
    description: '不行。年度終結或契約終止時，未休完的特休應由雇主折算成工資發給。',
    targetUnitIndex: 0,
  ),
  IllustrationStoryData(
    category: '職場權益',
    tag: '勞動權益課',
    title: '公司因虧損強迫大家放「無薪假」，需要經過員工同意嗎？',
    description: '必須與員工個別協商並簽署書面同意書，且無薪假期間薪資仍不得低於基本工資。',
    targetUnitIndex: 1,
  ),
  IllustrationStoryData(
    category: '職場權益',
    tag: '勞動權益課',
    title: '離職前提早通知期要多久？沒滿三個月的員工要通知嗎？',
    description: '工作滿3個月未滿1年需提前10天；未滿3個月者，勞基法無特別規定提前通知期。',
    targetUnitIndex: 2,
  ),
  IllustrationStoryData(
    category: '職場權益',
    tag: '勞動權益課',
    title: '簽了「競業禁止條款」，離職後真的就不能去同行上班嗎？',
    description: '必須具備合理補償條款且符合四項法定要件，否則該競業禁止約定無效。',
    targetUnitIndex: 3,
  ),
  IllustrationStoryData(
    category: '職場權益',
    tag: '勞動權益課',
    title: '颱風天放假，老闆到底該不該給薪水？不去上班會被扣錢嗎？',
    description: '若因安全考量未出勤，雇主不得扣發全勤或進行處分；出勤者建議加給薪資。',
    targetUnitIndex: 0,
  ),
  IllustrationStoryData(
    category: '職場權益',
    tag: '勞動權益課',
    title: '遭遇職場言語霸凌，勞工可以要求自願離職並拿遣散費嗎？',
    description: '若情節重大構成侵害人格，勞工可依勞基法第14條不經預告終止契約並要求資遣費。',
    targetUnitIndex: 2,
  ),
  IllustrationStoryData(
    category: '職場權益',
    tag: '勞動權益課',
    title: '公司沒幫我投保勞保，我可以向勞工局投訴嗎？',
    description: '只要僱用員工人數達5人以上，即為強制投保單位，未投保將面臨高額行政罰鍰。',
    targetUnitIndex: 3,
  ),
  IllustrationStoryData(
    category: '職場權益',
    tag: '勞動權益課',
    title: '員工懷孕，公司以「產能下降」為由調職或減薪合法嗎？',
    description: '違反性別平等工作法，調職必須符合五原則且不得有歧視性減薪。',
    targetUnitIndex: 3,
  ),
  IllustrationStoryData(
    category: '職場權益',
    tag: '勞動權益課',
    title: '每週二為固定例假日，老闆要我例假日加班，要給幾倍薪水？',
    description: '例假日除天災等突發事件外不得要求加班，若違法出勤需加發一日工資並給予補假。',
    targetUnitIndex: 1,
  ),
  IllustrationStoryData(
    category: '職場權益',
    tag: '勞動權益課',
    title: '公司尾牙抽獎抽中機車，這算是我個人的薪資所得嗎？',
    description: '這屬於機會中獎所得，公司會依法申報扣繳，但不屬於勞基法定義之工作薪資。',
    targetUnitIndex: 0,
  ),
  IllustrationStoryData(
    category: '職場權益',
    tag: '勞動權益課',
    title: '年終獎金是雇主非給不可的嗎？合約「保障14個月」有效力嗎？',
    description: '若合約載明保障年薪，該2個月年終屬契約薪資一部分，雇主不能任意扣發。',
    targetUnitIndex: 0,
  ),

  // 61-80: 網購消費
  IllustrationStoryData(
    category: '網購消費',
    tag: '消費消保課',
    title: '網購商品拆封了就不能退？「拆封不退」條約是否合法？',
    description: '除合理檢查必要外，賣家自訂「拆封不退」排擠七天鑑賞期屬於無效條款。',
    targetUnitIndex: 0,
  ),
  IllustrationStoryData(
    category: '網購消費',
    tag: '消費消保課',
    title: '在二手社團跟一般個人賣家買包包，適用七天鑑賞期嗎？',
    description: '不適用。消保法只約束「企業經營者」，個人二手拍賣屬於一般民法買賣契約。',
    targetUnitIndex: 1,
  ),
  IllustrationStoryData(
    category: '網購消費',
    tag: '消費消保課',
    title: '網購特價促銷商品，商家可以拒絕退換貨嗎？',
    description: '不能。特價或福利品只要是在網路進行交易，依然享有消保法七天鑑賞期保障。',
    targetUnitIndex: 0,
  ),
  IllustrationStoryData(
    category: '網購消費',
    tag: '消費消保課',
    title: '客製化衣服印錯了名字，我可以要求退貨退款嗎？',
    description: '可以。雖然客製化排除七天鑑賞，但若商品有瑕疵（印錯字），仍可主張瑕疵擔保。',
    targetUnitIndex: 2,
  ),
  IllustrationStoryData(
    category: '網購消費',
    tag: '消費消保課',
    title: '包裹送來時外箱已嚴重破損，我該不該直接簽收？',
    description: '建議拒絕簽收並拍照存證，或簽收時於單據註明「外包裝破損」，以利釐清責任。',
    targetUnitIndex: 2,
  ),
  IllustrationStoryData(
    category: '網購消費',
    tag: '消費消保課',
    title: '網路下單後賣家說「標錯價缺貨」不肯出貨，這合法嗎？',
    description: '若消費者已付款且合約成立，商家有履行契約之義務，不得單方面取消訂單。',
    targetUnitIndex: 3,
  ),
  IllustrationStoryData(
    category: '網購消費',
    tag: '消費消保課',
    title: '七天鑑賞期是從收到貨的那天開始算，還是下單那天？',
    description: '從消費者「收到商品或接受服務」的次日起算七天（含例假日）。',
    targetUnitIndex: 0,
  ),
  IllustrationStoryData(
    category: '網購消費',
    tag: '消費消保課',
    title: '海外代購商品遇到瑕疵，消保官受理我的申訴嗎？',
    description: '若代購平台在台灣有營業登記，消保法依然適用；若是個人境外代購，求償難度較高。',
    targetUnitIndex: 1,
  ),
  IllustrationStoryData(
    category: '網購消費',
    tag: '消費消保課',
    title: '購買線上遊戲虛擬點數後反悔，能否要求七天內退款？',
    description: '經消費者授權即時提供之數位內容（如啟動碼、虛擬道具），依法排除鑑賞期. 。',
    targetUnitIndex: 0,
  ),
  IllustrationStoryData(
    category: '網購消費',
    tag: '消費消保課',
    title: '網購退貨，賣家要求我自行負擔退回的郵資，這合理嗎？',
    description: '不合理。消保法規定退貨郵資或運費應由企業經營者負擔，不得向消費者收取。',
    targetUnitIndex: 0,
  ),
  IllustrationStoryData(
    category: '網購消費',
    tag: '消費消保課',
    title: '自動續訂軟體沒有通知我就扣款了，我有權要回這筆錢嗎？',
    description: '應檢查條款中是否有自動續約同意條款。若無明顯標示，可申訴涉嫌不正當經營。',
    targetUnitIndex: 3,
  ),
  IllustrationStoryData(
    category: '網購消費',
    tag: '消費消保課',
    title: '群購發起人把大家的退貨款項捲款跑路，這算詐欺嗎？',
    description: '涉嫌刑法業務侵占罪或詐欺取財罪，消費者應儘速收集對話與轉帳紀錄向警局報案。',
    targetUnitIndex: 4,
  ),
  IllustrationStoryData(
    category: '網購消費',
    tag: '消費消保課',
    title: '網購收到冒牌假貨，該如何透過物流客服聲請「退款凍結」？',
    description: '若使用超商取貨付款，可在第一時間聯繫快遞公司或超商客服聲請退貨止付。',
    targetUnitIndex: 2,
  ),
  IllustrationStoryData(
    category: '網購消費',
    tag: '消費消保課',
    title: '買家下單後「惡意不取貨」，賣家能告他毀損罪嗎？',
    description: '若屬偶發性忘記取貨難以構成刑事毀損；若屬惡意多帳號故意下單，可能觸犯間接毀損罪。',
    targetUnitIndex: 4,
  ),
  IllustrationStoryData(
    category: '網購消費',
    tag: '消費消保課',
    title: '一頁式廣告標榜買一送一收到卻是塑膠玩具，這是詐騙嗎？',
    description: '極可能是典型一頁式網購詐騙，應尋求物流業者、超商進行爭議款退款申請。',
    targetUnitIndex: 2,
  ),
  IllustrationStoryData(
    category: '網購消費',
    tag: '消費消保課',
    title: '網路購買易腐壞的「鮮奶生鮮食物」，也享有七天無條件退貨嗎？',
    description: '易腐敗、保存期限較短之商品，屬於消保法合理例外排除事項，不享有七天鑑賞期。',
    targetUnitIndex: 0,
  ),
  IllustrationStoryData(
    category: '網購消費',
    tag: '消費消保課',
    title: '買到瑕疵除濕機引發火災毀損家具，製造商要賠償嗎？',
    description: '依消費者保護法之商品責任，製造商應確保商品安全，否則須負無過失之民事賠償責任。',
    targetUnitIndex: 3,
  ),
  IllustrationStoryData(
    category: '網購消費',
    tag: '消費消保課',
    title: '網購下單付清，賣家過了兩週都沒發貨，可以要求退款嗎？',
    description: '可催告限期出貨，逾期未出貨可主張解除買賣契約並要求返還已付價金。',
    targetUnitIndex: 2,
  ),
  IllustrationStoryData(
    category: '網購消費',
    tag: '消費消保課',
    title: '在社群直播拍賣買衣服，喊「+1」是否就代表合約成立？',
    description: '是。買賣雙方對商品及價金互相同意時，買賣契約即屬成立，具有法律效力。',
    targetUnitIndex: 3,
  ),
  IllustrationStoryData(
    category: '網購消費',
    tag: '消費消保課',
    title: '網購收到的鞋子尺寸不合，想換貨卻要被收手續費合理嗎？',
    description: '在七天鑑賞期內退貨不需任何理由與費用，賣家不得巧立名目收取退換手續費。',
    targetUnitIndex: 0,
  ),

  // 81-100: 個資隱私
  IllustrationStoryData(
    category: '個資隱私',
    tag: '個資隱私課',
    title: '接到佯稱客服的詐騙電話，是誰洩露了我的購物個資？',
    description: '企業若因資安漏洞外洩個資，消費者可依法集體向企業請求民事損害賠償。',
    targetUnitIndex: 0,
  ),
  IllustrationStoryData(
    category: '個資隱私',
    tag: '個資隱私課',
    title: '把吵架對話截圖公開在 IG 且「沒打馬賽克」，這犯法嗎？',
    description: '這極可能損害對方隱私權，涉嫌違反個人資料保護法，並可能觸犯刑法加重誹謗罪。',
    targetUnitIndex: 2,
  ),
  IllustrationStoryData(
    category: '個資隱私',
    tag: '個資隱私課',
    title: '主管擅自翻看員工辦公桌抽屜，有侵害隱私的嫌疑嗎？',
    description: '辦公桌雖屬公司，但員工私人抽屜仍具合理隱私期待，主管無故翻看可能涉侵害隱私。',
    targetUnitIndex: 1,
  ),
  IllustrationStoryData(
    category: '個資隱私',
    tag: '個資隱私課',
    title: '行車紀錄器拍到違規，上傳網路公審有沒有侵害個資？',
    description: '若畫面清晰露出他人車牌或面貌且具攻擊文字，可能構成違法利用個資與妨害名譽。',
    targetUnitIndex: 2,
  ),
  IllustrationStoryData(
    category: '個資隱私',
    tag: '個資隱私課',
    title: '鄰居的監視器鏡頭「正對我家大門口」，我可以要求他移開嗎？',
    description: '可以。住家大門進出動態屬於私人隱私範疇，可訴請法院排除侵害並要求移開鏡頭。',
    targetUnitIndex: 1,
  ),
  IllustrationStoryData(
    category: '個資隱私',
    tag: '個資隱私課',
    title: '未經同意翻看配偶或男女朋友的手機 LINE 訊息，這算違法嗎？',
    description: '是。這會觸犯刑法妨害秘密罪中的「無故利用工具窺視他人非公開活動」罪名。',
    targetUnitIndex: 4,
  ),
  IllustrationStoryData(
    category: '個資隱私',
    tag: '個資隱私課',
    title: '收到保險推銷簡訊，我可以要求他們不要再傳並刪除我的個資嗎？',
    description: '可以。個人有權依法行使拒絕行銷權，並要求企業刪除或停止利用其個資。',
    targetUnitIndex: 3,
  ),
  IllustrationStoryData(
    category: '個資隱私',
    tag: '個資隱私課',
    title: '公司在辦公室安裝監視器，需不需要事先告知全體員工？',
    description: '基於工作場所安全管理雖屬合理，但應事先明確告知員工，且不得裝在隱私場所。',
    targetUnitIndex: 1,
  ),
  IllustrationStoryData(
    category: '個資隱私',
    tag: '個資隱私課',
    title: '學校老師將學生的成績單直接貼在教室後面公佈，合法嗎？',
    description: '成績資料屬於個人資料，應採取適當遮蔽或個別通知，直接公開展示涉嫌個資外洩。',
    targetUnitIndex: 0,
  ),
  IllustrationStoryData(
    category: '個資隱私',
    tag: '個資隱私課',
    title: '我的照片被陌生人拿去當詐騙交友的頭像，該如何提告維權？',
    description: '涉侵害肖像權，可提出民事侵權賠償诉讼，若涉詐騙活動可報警協助凍結該帳號。',
    targetUnitIndex: 2,
  ),
  IllustrationStoryData(
    category: '個資隱私',
    tag: '個資隱私課',
    title: '健身房要求入會必須「按壓指紋」建檔，我可以拒絕嗎？',
    description: '可以。指紋屬生物個資，業者收集應符合比例原則，若有其他替代認證方式不得強收。',
    targetUnitIndex: 0,
  ),
  IllustrationStoryData(
    category: '個資隱私',
    tag: '個資隱私課',
    title: '離職後發現前公司網頁仍掛著我的個人履歷，我有權要求撤下嗎？',
    description: '有權。雇主已無僱傭之特定目的，勞工可依個資法請求刪除並終止使用該資料。',
    targetUnitIndex: 3,
  ),
  IllustrationStoryData(
    category: '個資隱私',
    tag: '個資隱私課',
    title: '在臉書社團公開貼出欠債人的「身分證字號與地址」，會觸法嗎？',
    description: '違反個人資料保護法，可能面臨兩年以下有期徒刑之刑事責任，並須負民事賠償。',
    targetUnitIndex: 4,
  ),
  IllustrationStoryData(
    category: '個資隱私',
    tag: '個資隱私課',
    title: '去餐廳消費被要求掃 QR Code 加入會員才能點餐，個資安全嗎？',
    description: '應注意其個資收集條款。業者不能強迫收集與點餐無關之隱私資訊。',
    targetUnitIndex: 3,
  ),
  IllustrationStoryData(
    category: '個資隱私',
    tag: '個資隱私課',
    title: '行車記錄器畫面若交給警方檢舉，違規者有辦法查到我的個資嗎？',
    description: '警方對檢舉人個資負有法定保密義務，違規者在紅單或行政訴訟中皆無法直接查閱。',
    targetUnitIndex: 0,
  ),
  IllustrationStoryData(
    category: '個資隱私',
    tag: '個資隱私課',
    title: '前男友在網路上威脅要散布我們的私密照片，我該找誰求助？',
    description: '可報警處理，涉犯刑法恐嚇罪及妨害秘密罪，並可聯絡「性影像處理中心」協助移除。',
    targetUnitIndex: 4,
  ),
  IllustrationStoryData(
    category: '個資隱私',
    tag: '個資隱私課',
    title: '使用智慧型手機 App 時，它要求麥克風與定位權限，不給就閃退合法嗎？',
    description: 'App 收集個資應符合比例原則，不應以拒絕不必要權限為由拒絕提供基本服務。',
    targetUnitIndex: 3,
  ),
  IllustrationStoryData(
    category: '個資隱私',
    tag: '個資隱私課',
    title: '社區管委會直接在大廳張貼「積欠管理費戶別與姓名」，是否涉個資洩漏？',
    description: '應遮蔽部分姓名以防止個資過度揭露，避免直接違反個資法或構成妨害名譽。',
    targetUnitIndex: 1,
  ),
  IllustrationStoryData(
    category: '個資隱私',
    tag: '個資隱私課',
    title: '買家買完東西給了一星評價，賣家憤而公開其電話，這能告嗎？',
    description: '可以。賣家將買家電話等私人聯絡方式公開，屬典型違反個資法利用規範行為。',
    targetUnitIndex: 2,
  ),
  IllustrationStoryData(
    category: '個資隱私',
    tag: '個資隱私課',
    title: '我的 Email 一直收到某銀行的垃圾廣告信，要怎麼退訂才有效？',
    description: '可直接回信或點擊信末退訂按鈕要求停止行銷，若對方不予理會可向主管機關申訴。',
    targetUnitIndex: 3,
  ),
];

// ==========================================
// 2. 100 個模擬對話故事基礎資料集 (前20筆為人工定義，其餘自動生成)
// ==========================================
const List<DialogStoryData> dialogStoriesList = [
  DialogStoryData(
    category: '租屋糾紛',
    senderA: '房東 👩‍🦳',
    avatarA: '房',
    textA: '冷氣吹不冷喔？那台舊了啦，要換你自己換，合約寫修繕自行負責喔！',
    senderB: '房客 🧑',
    avatarB: '客',
    textB: '房東太太，可是民法第429條規定，除非契約另有約定，否則修繕責任應由房東承擔...',
    title: '房東說「合約寫自行負責」真的有效嗎？',
    description: '學會區分自然折舊與人為損壞，保障租屋權益。',
    targetUnitIndex: 1,
  ),
  DialogStoryData(
    category: '租屋糾紛',
    senderA: '房東 👨‍🦳',
    avatarA: '房',
    textA: '小張，下個月開始房租要漲兩千，現在物價都在漲，希望你體諒一下。',
    senderB: '房客 🧑',
    avatarB: '客',
    textB: '陳伯伯，我們簽了一年的租約，租期內除非合約有約定，否則您不能片面調漲租金喔。',
    title: '租約期間內房東可以單方面漲租嗎？',
    description: '租約具有拘束力，雙方皆不可在租期內任意調改約定租金。',
    targetUnitIndex: 3,
  ),
  DialogStoryData(
    category: '租屋糾紛',
    senderA: '大房東 👩',
    avatarA: '大',
    textA: '你們是二房東轉租的喔？我都不知道這件事，下禮拜我要把房子收回來！',
    senderB: '次承租人 🧑',
    avatarB: '客',
    textB: '大房東您好，二房東當初拿的合約寫明可以轉租，我們是合法租客，您不能直接趕我們走...',
    title: '二房東未告知大房東違法轉租，租客權益有保嗎？',
    description: '轉租必須確認大房東同意書，否則大房東依法可終止合約並要求遷讓。',
    targetUnitIndex: 1,
  ),
  DialogStoryData(
    category: '租屋糾紛',
    senderA: '房東 👨',
    avatarA: '房',
    textA: '水電費一度電收8元很正常啦，公共區域的電費也要分攤啊！',
    senderB: '房客 🧑',
    avatarB: '客',
    textB: '但內政部最新租屋電費規定，房東收費不能超過台電當期帳單的最高每度電費...',
    title: '每度電收8元合法嗎？電費新制解析',
    description: '掌握最新租賃住宅定型化契約規範，避免被溢收水電費。',
    targetUnitIndex: 0,
  ),
  DialogStoryData(
    category: '租屋糾紛',
    senderA: '房東 👩‍🦰',
    avatarA: '房',
    textA: '我看你最近常常帶朋友回來住，合約有寫「限一人居住」，我要多收你兩千元！',
    senderB: '房客 🧑',
    avatarB: '客',
    textB: '房東您好，合約確實有限一人，但我朋友只是偶爾借宿並非同住，這應該不屬於多收房租的範圍...',
    title: '偶爾帶朋友留宿會違反「限一人居住」條約嗎？',
    description: '釐清同住與借宿的區別，避免因模糊定義產生租約爭議。',
    targetUnitIndex: 3,
  ),
  DialogStoryData(
    category: '租屋糾紛',
    senderA: '房東 👨‍🦳',
    avatarA: '房',
    textA: '你要申報租金扣除額喔？那之後產生的房屋稅差額要由你來補足喔。',
    senderB: '房客 🧑',
    avatarB: '客',
    textB: '房東先生，內政部定型化契約明確規定，不得約定限制承租人申報租賃費用扣除額...',
    title: '報稅被索要所得稅差額，該如何拒絕？',
    description: '依法申報租金支出是房客合法權利，任何轉嫁稅金的約定均屬無效。',
    targetUnitIndex: 3,
  ),
  DialogStoryData(
    category: '租屋糾紛',
    senderA: '房東 👩',
    avatarA: '房',
    textA: '退租點交時，沙發表面有點磨損，我要從押金裡扣一萬五去換皮！',
    senderB: '房客 🧑',
    avatarB: '客',
    textB: '房東太太，那沙發我正常使用了三年，皮革自然磨損折舊屬於正常消耗，不該由我全額買單...',
    title: '沙發自然磨損，房東可以直接扣押金嗎？',
    description: '自然折舊不屬於賠償範圍，退租點交拍照能提供有力的自保證據。',
    targetUnitIndex: 2,
  ),
  DialogStoryData(
    category: '租屋糾紛',
    senderA: '房客 🧑',
    avatarA: '客',
    textA: '房東，馬桶漏水漏得很嚴重，能請你儘快找水電來修嗎？',
    senderB: '房東 👨',
    avatarB: '房',
    textB: '我最近在大陸出差啦，你先自己修，費用等我下個月回來再說。',
    title: '漏水急需修繕，房東拖延該如何自保？',
    description: '可催告限期維修，逾期房客可自行僱工修繕並在下期租金中直接扣除。',
    targetUnitIndex: 2,
  ),
  DialogStoryData(
    category: '租屋糾紛',
    senderA: '房東 👩‍🦳',
    avatarA: '房',
    textA: '我不管你什麼理由，你現在要搬走，就得扣掉全部兩個月的押金作為違約金！',
    senderB: '房客 🧑',
    avatarB: '客',
    textB: '合約有約定可以提前一個月通知，我已經在一個月前告知，應該是不用扣違約金才對...',
    title: '提前通知退租，還需要扣押金違約金嗎？',
    description: '視合約有無約定「得提前終止」以及提前通知期，若有約定則免罰違約金。',
    targetUnitIndex: 1,
  ),
  DialogStoryData(
    category: '租屋糾紛',
    senderA: '房東 👨',
    avatarA: '房',
    textA: '小李，你這房子的押金只有一個月，現在法規很嚴，你要補足到三個月才行。',
    senderB: '房客 🧑',
    avatarB: '客',
    textB: '房東先生，土地法第99條有規定，房屋押金最高不得超過兩個月租金喔。',
    title: '房東要求補足押金至三個月，合法嗎？',
    description: '依法押金限額為兩個月租金，超過部分房客有權拒絕或抵扣房租。',
    targetUnitIndex: 0,
  ),
  DialogStoryData(
    category: '租屋糾紛',
    senderA: '新屋主 👨‍💼',
    avatarA: '新',
    textA: '我已經把這棟大樓買下來了，我下個月要自己搬進來，你合約雖然沒到期也得搬走。',
    senderB: '房客 🧑',
    avatarB: '客',
    textB: '新屋主您好，買賣不破租賃，原房東跟我簽的合約對您依然有效，我享有居住到約滿的權利。',
    title: '房子換了主人，原來的租約還有效嗎？',
    description: '民法第425條「買賣不破租賃」原則，保障租期內房客居住權不受屋主異動影響。',
    targetUnitIndex: 1,
  ),
  DialogStoryData(
    category: '租屋糾紛',
    senderA: '房客 🧑',
    avatarA: '客',
    textA: '房東，我想把戶籍遷入租屋處，以便小孩子能就近讀書。',
    senderB: '房東 👩‍🦰',
    avatarB: '房',
    textB: '不行啦，你遷戶籍進來會讓我這邊稅率變高，合約有寫不能遷戶籍喔！',
    title: '合約規定「不得遷入戶籍」有效嗎？',
    description: '定型化契約應記載及不得記載事項中，限制遷入戶籍屬無效條款。',
    targetUnitIndex: 3,
  ),
  DialogStoryData(
    category: '租屋糾紛',
    senderA: '房東 👨‍🦳',
    avatarA: '房',
    textA: '你上個月房租遲到了五天，我要收你一千元滯納金，合約上有寫喔！',
    senderB: '房客 🧑',
    avatarB: '客',
    textB: '房東先生，滯納金的約定必須合理，一天若罰好幾百元可能有違約金過高的法律爭議...',
    title: '房租遲交幾天，房東能任意收取高額滯納金嗎？',
    description: '滯納金約定金額過高時，法院得依民法第252條減輕至合理數額。',
    targetUnitIndex: 3,
  ),
  DialogStoryData(
    category: '租屋糾紛',
    senderA: '房客 🧑',
    avatarA: '客',
    textA: '退租點交都完成了，房東你怎麼還不把兩個月押金退給我？',
    senderB: '房東 👩',
    avatarB: '房',
    textB: '我還要扣水電費，等下個月水電單來了，我結算後再退你剩下的錢。',
    title: '退租點交完畢後，房東能以扣水電費為由扣留押金嗎？',
    description: '可協議預扣小額水電費，但房東無權無理扣留全部押金。',
    targetUnitIndex: 2,
  ),
  DialogStoryData(
    category: '租屋糾紛',
    senderA: '房東 👨',
    avatarA: '房',
    textA: '合約寫明「房屋有損壞一律由房客修繕」，現在水管漏水當然你要出錢！',
    senderB: '房客 🧑',
    avatarB: '客',
    textB: 'But 漏水是結構體自然老化，定型化契約中修繕條款如果是片面加重房客責任，可能無效...',
    title: '合約約定「修繕皆由房客負責」有效嗎？',
    description: '針對結構體或天災損害，若條款片面免除出租人責任，依法仍可能無效。',
    targetUnitIndex: 2,
  ),
  DialogStoryData(
    category: '租屋糾紛',
    senderA: '房東 👩‍🦳',
    avatarA: '房',
    textA: '你不租了是嗎？但合約寫明退租要找清潔公司打掃，不然我要扣押金一萬！',
    senderB: '房客 🧑',
    avatarB: '客',
    textB: '房東太太，我已經打掃得很乾淨了，除非有故意髒污，否則不能強制扣留這筆錢...',
    title: '退租必須請專業清潔公司嗎？清潔費爭議',
    description: '房客僅負善良管理人之回復原狀義務，不以專業清潔為限。',
    targetUnitIndex: 2,
  ),
  DialogStoryData(
    category: '租屋糾紛',
    senderA: '房客 🧑',
    avatarA: '客',
    textA: '房東，隔壁雅房的房客半夜常常大聲打電動，吵得我根本無法睡覺。',
    senderB: '房東 👨‍🦳',
    avatarB: '房',
    textB: '那你要自己去跟他說啊，我只是收房租的，管不到人家的私人行為啦！',
    title: '室友深夜太吵，房東有責任出面管教嗎？',
    description: '房東負有保持租賃物合於使用狀態之義務，應協調排除妨害。',
    targetUnitIndex: 2,
  ),
  DialogStoryData(
    category: '租屋糾紛',
    senderA: '房客 🧑',
    avatarA: '客',
    textA: '房東先生，合約已經到期了，但我工作還沒找好，想再住兩個月。',
    senderB: '房東 👨',
    avatarB: '房',
    textB: '可以啊，你繼續住，房租照付就好，我們就不用特別重簽合約了。',
    title: '合約到期不重簽但繼續住，會變成怎樣？',
    description: '這會轉化為不定期租約，為免日後爭議，雙方最好仍簽立短期約定。',
    targetUnitIndex: 1,
  ),
  DialogStoryData(
    category: '租屋糾紛',
    senderA: '房客 🧑',
    avatarA: '客',
    textA: '我們簽合約去辦公證，這樣會不會很麻煩？費用誰出？',
    senderB: '房東 👩',
    avatarB: '房',
    textB: '公證對我們都有保障啦，公證費就我們各出一半，帶上證件跟印章去法院就好了。',
    title: '租約辦理公證，流程與費用負擔解析',
    description: '公證租約對於返還押金與遷讓房屋，皆能附帶強制執行效力。',
    targetUnitIndex: 3,
  ),
  DialogStoryData(
    category: '租屋糾紛',
    senderA: '房東 👩‍🦳',
    avatarA: '房',
    textA: '小王，我發現你在屋子裡偷偷養貓，合約寫禁養寵物，我要立刻跟你解約！',
    senderB: '房客 🧑',
    avatarB: '客',
    textB: '房東太太，我確實違約了，但我願意立刻將貓送回老家，請給我幾天時間改善...',
    title: '違約養寵物，房東有權立刻終止租約嗎？',
    description: '需視合約有無約定違約時得徑行終止，通常應先通知限期改善。',
    targetUnitIndex: 3,
  ),

  // 21-40: 車禍事故
  DialogStoryData(
    category: '車禍事故',
    senderA: '對方駕駛 👨',
    avatarA: '對',
    textA: '是你自己撞上來的，而且我的車子零件換新你要全額賠償！',
    senderB: '我方駕駛 🧑',
    avatarB: '我',
    textB: '但法律規定零件折舊要按使用年限計算，不能直接要求全新價格賠償喔...',
    title: '車禍求償零件「以新品算」合理嗎？',
    description: '了解折舊計算公式，避免在民事理賠中被多索賠。',
    targetUnitIndex: 2,
  ),
  DialogStoryData(
    category: '車禍事故',
    senderA: '對方駕駛 👩',
    avatarA: '對',
    textA: '只是輕微擦撞，我等下還有重要的會要開，我們私下各修各的就好了啦。',
    senderB: '我方駕駛 🧑',
    avatarB: '我',
    textB: '這不行，還是要打電話報警處理，留下事故紀錄，以免事後產生肇逃爭議。',
    title: '發生輕微擦撞，雙方私下口頭和解安全嗎？',
    description: '未留下報警紀錄或和解書，事後可能被對方指控肇事逃逸，應格外小心。',
    targetUnitIndex: 2,
  ),
  DialogStoryData(
    category: '車禍事故',
    senderA: '警察 👮',
    avatarA: '警',
    textA: '雙方好，車禍初判表已經出來了，上面寫對方涉嫌未注意車前狀況，你則是未發現違規。',
    senderB: '我方駕駛 🧑',
    avatarB: '我',
    textB: '謝謝長官，那這樣對方是不是要負起主要的賠償責任？我們可以用這跟保險談嗎？',
    title: '車禍「初判表」有法律拘束力嗎？',
    description: '初判表為警方初步研判，非正式鑑定；保險公司常參考，但若有爭議需送車鑑會鑑定。',
    targetUnitIndex: 0,
  ),
  DialogStoryData(
    category: '車禍事故',
    senderA: '對方駕駛 👨',
    avatarA: '對',
    textA: '既然我們都有保險，那就全部交給保險公司去談，我們私底下就不用聯絡了。',
    senderB: '我方駕駛 🧑',
    avatarB: '我',
    textB: '沒問題，但我有受傷，希望您的保險專員能儘快跟我聯繫討論理賠細節。',
    title: '車禍全部丟給保險公司處理，就沒事了嗎？',
    description: '過失傷害罪追訴期為六個月，若保險遲未達成和解，仍可能面臨刑事起訴。',
    targetUnitIndex: 4,
  ),
  DialogStoryData(
    category: '車禍事故',
    senderA: '我方駕駛 🧑',
    avatarA: '我',
    textA: '我是在支線道上，當時有減速，是對方開太快撞上來的，難道我肇責比較大嗎？',
    senderB: '對方駕駛 👨‍💼',
    avatarB: '對',
    textB: '我是幹線道車，依照交通法規你支線道車本來就應該停讓主幹道車先行喔！',
    title: '支線車未讓幹線車，肇事責任如何判定？',
    description: '路權判定是車禍肇責的核心，支線車未停讓幹線車通常須負主要責任。',
    targetUnitIndex: 0,
  ),
  DialogStoryData(
    category: '車禍事故',
    senderA: '對方駕駛 👩',
    avatarA: '對',
    textA: '你過馬路沒走斑馬線被我撞到，你也有錯，我不可能賠你全額的醫藥費！',
    senderB: '受傷行人 🧑',
    avatarB: '我',
    textB: '雖然我違規，但您開車未注意車前狀況依然有過失，我只要求合理的醫療與工作損失賠償...',
    title: '行人違規被撞，開車者也有過失傷害刑責嗎？',
    description: '行人違規會折抵民事賠償金（過失相抵），但開車者通常仍難逃過失傷害刑事責任。',
    targetUnitIndex: 4,
  ),
  DialogStoryData(
    category: '車禍事故',
    senderA: '我方駕駛 🧑',
    avatarA: '我',
    textA: '我被後車推撞去撞到前車，現在前車找我賠償，我該找誰負責？',
    senderB: '前車駕駛 👨',
    avatarB: '對',
    textB: '你撞我的車尾就是你的責任，我不管你是被誰撞的，你先賠我就對了！',
    title: '車禍被「推撞」與「追撞」，賠償責任有何不同？',
    description: '若屬靜止狀態下被推撞，我方通常無肇責，應由最尾端的肇事車輛負全額賠償責任。',
    targetUnitIndex: 0,
  ),
  DialogStoryData(
    category: '車禍事故',
    senderA: '對方駕駛 👨',
    avatarA: '對',
    textA: '我車子修了十萬，我要求你除了修車費，還要賠我每天上下班的計程車交通費！',
    senderB: '我方駕駛 🧑',
    avatarB: '我',
    textB: '計程車費求償必須合理，如果是上下班且無其他替代交通工具，通常需有收據並核實折減...',
    title: '車禍維修期間的「交通代步費」可以求償嗎？',
    description: '民法容許求償因車禍額外增加的合理代步費用，但需具備必要性與相關收據。',
    targetUnitIndex: 2,
  ),
  DialogStoryData(
    category: '車禍事故',
    senderA: '我方駕駛 🧑',
    avatarA: '我',
    textA: '我們簽和解書時，需阻礙什麼特別註明拋棄刑事告訴權？',
    senderB: '調解委員 👩',
    avatarB: '調',
    textB: '當然要！和解書內一定要寫明「雙方放棄一切民、刑事訴訟之追訴權」，這樣才有法律保障。',
    title: '車禍和解書要寫哪些關鍵字才安全？',
    description: '寫明放棄起訴、撤回告訴、付清款項等條款，是徹底解決車禍糾紛的關鍵。',
    targetUnitIndex: 2,
  ),
  DialogStoryData(
    category: '車禍事故',
    senderA: '我方駕駛 🧑',
    avatarA: '我',
    textA: '借車給朋友開，他超速撞到人，現在傷者連我也一起告，這合理嗎？',
    senderB: '律師 👨‍⚖️',
    avatarB: '律',
    textB: '民事上若無故意借車給無照者，車主一般不負共同侵權責任；但車損部分仍須釐清。',
    title: '借車給朋友出車禍，車主需要賠償傷者嗎？',
    description: '除明知駕駛無照、酒駕等特殊過失外，車主通常不負過失傷害之刑事與共同侵權責任。',
    targetUnitIndex: 3,
  ),
  DialogStoryData(
    category: '車禍事故',
    senderA: '對方駕駛 👨',
    avatarA: '對',
    textA: '只是倒車輕輕碰到，你也沒有受傷，我直接把車開走，這不算肇事逃逸吧？',
    senderB: '我方駕駛 🧑',
    avatarB: '我',
    textB: '沒人受傷確實不構成刑法肇逃，但仍涉違反道交條例逃逸處罰，會被吊扣駕照喔。',
    title: '無人受傷的輕微車禍，直接開走算肇事逃逸嗎？',
    description: '刑法肇逃以有人傷亡為前提；無人受傷但直接離開仍會面臨行政處罰與吊扣駕照。',
    targetUnitIndex: 4,
  ),
  DialogStoryData(
    category: '車禍事故',
    senderA: '對方駕駛 👩',
    avatarA: '對',
    textA: '我沒錢啦，要告隨你告，反正我名下財產也是空的，拿我沒辦法。',
    senderB: '我方駕駛 🧑',
    avatarB: '我',
    textB: '既然您無意協調，我會向法院起訴取得債權憑證，您未來只要有工作或銀行開戶我就會執行。',
    title: '限制財產執行，官司打贏了也拿不到錢嗎？',
    description: '起訴勝訴可取得債權憑證，定期向國稅局查詢其財產與所得，一旦有收入即可強制執行。',
    targetUnitIndex: 2,
  ),
  DialogStoryData(
    category: '車禍事故',
    senderA: '保險專員 👨‍💼',
    avatarA: '保',
    textA: '您的車投保了車體險，我們先幫您修車，之後我們會向對方進行代位求償。',
    senderB: '我方駕駛 🧑',
    avatarB: '我',
    textB: '那太好了，這樣我就不用自己去面對對方，只要把車子交給原廠處理就行了。',
    title: '什麼是保險的「代位求償」？車主該如何配合？',
    description: '投保車體險者，由保險公司先理賠修車費並取得債權，向肇事者追償，車主免操心。',
    targetUnitIndex: 3,
  ),
  DialogStoryData(
    category: '車禍事故',
    senderA: '我方駕駛 🧑',
    avatarA: '我',
    textA: '車禍後我一直覺得頭暈想吐，但當時沒叫救護車，現在去醫院開診斷書還有效嗎？',
    senderB: '醫生 👩‍⚕️',
    avatarB: '醫',
    textB: '車禍後幾天內出現震盪症狀很常見，我們會開立診斷書，但必須載明與撞擊事件的關聯。',
    title: '車禍當下沒驗傷，事後能提告過失傷害嗎？',
    description: '事後驗傷需儘速進行，並向醫生說明受傷起因，以便法院認定受傷與車禍具因果關係。',
    targetUnitIndex: 1,
  ),
  DialogStoryData(
    category: '車禍事故',
    senderA: '對方駕駛 👨',
    avatarA: '對',
    textA: '不好意思，是我疏忽了，醫療費我會負責，但精神賠償金真的太高了啦。',
    senderB: '我方駕駛 🧑',
    avatarB: '我',
    textB: '您開車門沒看後方把我撞飛，我要求合理的醫藥費、工作損失與合理精神慰撫金...',
    title: '「開車門擊落機車」，受害者可請求的賠償範圍',
    description: '可求償醫藥費、看護費、工作損失、車損與合理精神慰撫金，並可提告過失傷害刑事。',
    targetUnitIndex: 4,
  ),
  DialogStoryData(
    category: '車禍事故',
    senderA: '對方駕駛 👩',
    avatarA: '對',
    textA: '酒後騎乘共享單車 YouBike，也會被算酒駕受罰嗎？',
    senderB: '我方駕駛 🧑',
    avatarB: '我',
    textB: '是的，腳踏車屬於慢車，酒駕仍會面臨罰鍰處罰，若拒絕聯測更會被加重裁罰。',
    title: '酒後騎乘共享單車是否算酒駕？',
    description: '腳踏車酒駕同樣違法，拒絕酒測將處加倍罰鍰，必須守法。',
    targetUnitIndex: 3,
  ),
  DialogStoryData(
    category: '車禍事故',
    senderA: '我方駕駛 🧑',
    avatarA: '我',
    textA: '車禍鑑定委員會要花3000元，這筆錢誰出？我們一定要去鑑定嗎？',
    senderB: '調解委員 👨',
    avatarB: '調',
    textB: '誰申請就誰先出，如果調解不成要打官司，法官通常會以鑑定報告的肇責比例為準。',
    title: '如何向車鑑會聲請「行車事故鑑定」？',
    description: '對初判表有異議時，可在事故六個月內自費向車鑑會聲請鑑定，是法庭判決重要依據。',
    targetUnitIndex: 0,
  ),
  DialogStoryData(
    category: '車禍事故',
    senderA: '對方駕駛 👨',
    avatarA: '對',
    textA: '你載你女朋友，你自己摔車，你女朋友骨折怎麼算我的責任？是你自己技術不好！',
    senderB: '我方駕駛 🧑',
    avatarB: '我',
    textB: '是你違規超車切入我車道我才避讓摔車的，這在法律上屬於非接觸性車禍，你仍有肇責！',
    title: '「沒撞到就不用負責？」非接觸車禍法律解析',
    description: '即便車體未直接碰撞，若因違規導致對方規避而摔車，仍具備因果關係與賠償責任。',
    targetUnitIndex: 0,
  ),
  DialogStoryData(
    category: '車禍事故',
    senderA: '我方駕駛 🧑',
    avatarA: '我',
    textA: '對方是送貨的貨車司機，車禍受傷我要提告，除了他之外，他的公司有責任嗎？',
    senderB: '律師 👨‍⚖️',
    avatarB: '律',
    textB: '司機是在執行職務中肇事，您可以依民法第188條，要求司機與其僱用公司負連帶賠償責任。',
    title: '上班途中被物流車撞傷，可以要求公司連帶賠償嗎？',
    description: '司機執行職務侵權，公司需負民事連帶賠償責任，對受害者求償較有保障。',
    targetUnitIndex: 3,
  ),
  DialogStoryData(
    category: '車禍事故',
    senderA: '對方駕駛 👩',
    avatarA: '對',
    textA: '我的新車被你撞到，折舊損失你至少要賠我五萬，不然免談和解！',
    senderB: '我方駕駛 🧑',
    avatarB: '我',
    textB: '請提供第三方公正單位開立的「車輛價值折舊損耗鑑定報告」，我們依鑑定金額合理賠償。',
    title: '車損求償「車價減損折舊」，需要提供什麼憑證？',
    description: '民事賠償車價減損需由專業公會鑑定，並非被害人單方面喊價即可獲准。',
    targetUnitIndex: 2,
  ),

  // 41-60: 職場權益
  DialogStoryData(
    category: '職場權益',
    senderA: '主管 👨‍💼',
    avatarA: '管',
    textA: '下個月專案要趕工，大家自動加班一下，沒有加班費但可以換補休！',
    senderB: '員工 🧑',
    avatarB: '員',
    textB: '經理，勞基法規定加班必須先經工會或勞資會議同意，且加班費率不能打折...',
    title: '強迫加班換補休，合法嗎？',
    description: '掌握加班費計算與補休選擇權，捍衛勞工基本權益。',
    targetUnitIndex: 1,
  ),
  DialogStoryData(
    category: '職場權益',
    senderA: '老闆 👨‍💼',
    avatarA: '板',
    textA: '小李，因為公司最近業務緊縮，從明天起你不用來上班了，我們沒有預算付資遣費。',
    senderB: '員工 🧑',
    avatarB: '員',
    textB: '老闆，依勞基法規定，虧損或業務緊縮解雇員工屬於資遣，必須依法給付資遣費並通報...',
    title: '公司業務緊縮被解雇，老闆能拒付資遣費嗎？',
    description: '非自願離職享有資遣費及失業給付聲請權，雇主拒付將違反勞基法面臨裁罰。',
    targetUnitIndex: 2,
  ),
  DialogStoryData(
    category: '職場權益',
    senderA: '主管 👩‍💼',
    avatarA: '管',
    textA: '小張，下班後在群組裡交辦的事情，記得在明天上班前做完，這只是順手的事情不用報加班。',
    senderB: '員工 🧑',
    avatarB: '員',
    textB: '經理，勞動部有規定下班在 LINE 回覆或處理工作同樣算加班，需按分鐘計算加班費的。',
    title: '下班回 LINE 交代工作，算加班嗎？',
    description: '產生的對話截圖與時間證明是爭取權益的重要依據。',
    targetUnitIndex: 1,
  ),
  DialogStoryData(
    category: '職場權益',
    senderA: '人資 👩',
    avatarA: '人',
    textA: '我們公司的特休假是年底如果沒休完，就一律自動歸零，沒有在折算薪水的喔。',
    senderB: '員工 🧑',
    avatarB: '員',
    textB: '但勞基法第38條規定，特休假因年度終結或契約終止而未休完者，雇主應發給工資。',
    title: '未休完的「特休假」，可以直接歸零嗎？',
    description: '特休假未休完依法必須折算工資，雇主強行歸零即屬違法，可向勞動局申訴。',
    targetUnitIndex: 0,
  ),
  DialogStoryData(
    category: '職場權益',
    senderA: '老闆 👨‍💼',
    avatarA: '板',
    textA: '因為你這次專案出大包，造成公司損失，我決定直接從你這月薪水扣兩萬作為賠償！',
    senderB: '員工 🧑',
    avatarB: '員',
    textB: '老闆，勞基法第26條規定，雇主不得預扣勞工工資作為賠償費用，您不能直接從我薪水扣除...',
    title: '工作出錯，老闆可以直接扣薪水賠償嗎？',
    description: '雇主不得片面預扣工資，賠償問題應透過勞資爭議調解或民事訴訟處理。',
    targetUnitIndex: 0,
  ),
  DialogStoryData(
    category: '職場權益',
    senderA: '人資 👨',
    avatarA: '人',
    textA: '你的試用期是三個月，這期間我們不幫你投保勞健保，等轉正之後再一起補辦。',
    senderB: '員工 🧑',
    avatarB: '員',
    textB: '依規定，只要到職當天，雇主就必須為員工申報加保勞保與勞退，試用期也不例外。',
    title: '「試用期」公司不幫忙投保勞保，合約有效嗎？',
    description: '到職日即為投保日，此為強制法規。未投保一旦發生職災，雇主須負全額補償責任。',
    targetUnitIndex: 3,
  ),
  DialogStoryData(
    category: '職場權益',
    senderA: '老闆 👩‍💼',
    avatarA: '板',
    textA: '我們是責任制啦，你的職等已經很高了，合約寫沒有額外的加班費。',
    senderB: '員工 🧑',
    avatarB: '員',
    textB: '老闆，責任制必須符合勞基法84條之1，並送主管機關核備，不是合約寫了就算數。',
    title: '「責任制」就一定沒有加班費嗎？話術拆解',
    description: '未依法送審核備的責任制皆屬無效，勞工超時工作依然享有合法加班費請求權。',
    targetUnitIndex: 1,
  ),
  DialogStoryData(
    category: '職場權益',
    senderA: '員工 🧑',
    avatarA: '員',
    textA: '經理，我下個月要請產假，這是我的證明文件。',
    senderB: '主管 👨‍💼',
    avatarB: '管',
    textB: '這樣我們部門人手不足，但產假期間薪資我們照發，考績的事情我們後續再看。',
    title: '請產假或育嬰假，公司能扣考績或全勤嗎？',
    description: '性平法保障生育假，雇主不得視為缺勤而扣發全勤獎金或進行任何不利處分。',
    targetUnitIndex: 3,
  ),
  DialogStoryData(
    category: '職場權益',
    senderA: '人資 👩',
    avatarA: '人',
    textA: '小陳，因為你年資未滿三個月，所以離職不用預告，明天把東西收一收就可以走了。',
    senderB: '員工 🧑',
    avatarB: '員',
    textB: '雖然未滿三個月不需預告，但如果是公司資遣我，依然要給付資遣費並開立非自願離職證明書喔。',
    title: '未滿三個月被資遣，有資遣費可以拿嗎？',
    description: '不論年資長短，只要是非自願離職，皆可按年資比例向雇主請求資遣費。',
    targetUnitIndex: 2,
  ),
  DialogStoryData(
    category: '職場權益',
    senderA: '老闆 👨‍💼',
    avatarA: '板',
    textA: '我們最近要放無薪假了，大家都簽一下這張「勞資協商同意書」吧。',
    senderB: '員工 🧑',
    avatarB: '員',
    textB: '老闆，無薪假必須個別協商，且放假期間月薪制員工的薪水，還是不能低於基本工資的。',
    title: '放無薪假，每個月薪水可以只領一萬嗎？',
    description: '無薪假減班休息期間，月薪勞工基本生活保障仍不得低於勞動部公告之當年度基本工資。',
    targetUnitIndex: 1,
  ),
  DialogStoryData(
    category: '職場權益',
    senderA: '員工 🧑',
    avatarA: '員',
    textA: '主管，我在搬運貨物時扭傷了腰，醫生說要休養兩週，我要請公傷病假。',
    senderB: '主管 👨‍💼',
    avatarB: '管',
    textB: '若是因為執行職務受傷，確實可以依法申請公傷假，我會轉告人事部門辦理。',
    title: '上班時間受傷，如何請「公傷假」？',
    description: '只要屬於執行職務受傷且具因果關係，依法應給予公傷病假，且雇主須支付工資補償。',
    targetUnitIndex: 3,
  ),
  DialogStoryData(
    category: '職場權益',
    senderA: '人資 👨',
    avatarA: '人',
    textA: '您的薪資單上寫的勞保投保級距是24000元，但您的實領薪資是45000元，這很正常啦。',
    senderB: '員工 🧑',
    avatarB: '員',
    textB: '但這屬於勞保「高薪低報」，會讓我未來的勞退新制提撥、傷病給付跟失業補助金都變少...',
    title: '公司「高薪低報」勞保級距，員工會吃虧嗎？',
    description: '高薪低報嚴重影響勞工各項社會保險給付，可依法檢舉並要求雇主賠償差額損失。',
    targetUnitIndex: 3,
  ),
  DialogStoryData(
    category: '職場權益',
    senderA: '老闆 👨',
    avatarA: '板',
    textA: '合約有寫「離職後兩年內不得在同性質行業工作」，你現在跳槽到競爭對手那，我們要告你違約！',
    senderB: '員工 🧑',
    avatarB: '員',
    textB: '老闆，依勞基法規定，競業禁止條款必須提供合理經濟補償，我們合約根本沒有補償金規定。',
    title: '沒給補償金的「競業禁止條款」有效力嗎？',
    description: '離職後競業禁止約定若無給予合理代價補償，依法該條款無效，不具法律拘束力。',
    targetUnitIndex: 3,
  ),
  DialogStoryData(
    category: '職場權益',
    senderA: '主管 👩‍💼',
    avatarA: '管',
    textA: '小王，明天雖然發布颱風停班，但我們是網路電商，你還是要在電腦前待命加班。',
    senderB: '員工 🧑',
    avatarB: '員',
    textB: '經理，颱風天若地方政府公告停班，勞工因安全考量有權拒絕出勤，且公司不能給予處分。',
    title: '颱風天停班，居家辦公的員工可以拒絕工作嗎？',
    description: '勞工因颱風致無法出勤，雇主不得扣發全勤、強迫請假或解雇等不利處分。',
    targetUnitIndex: 0,
  ),
  DialogStoryData(
    category: '職場權益',
    senderA: '員工 🧑',
    avatarA: '員',
    textA: '主管，同事在辦公室常對我說帶有性暗示的笑話，我感到很不舒服，公司能處理嗎？',
    senderB: '主管 👨‍💼',
    avatarB: '管',
    textB: '我們會立刻召開性騷擾防治委員會調查這件事，並對相關當事人進行勸誡。',
    title: '遭受職場性騷擾，雇主消極不處理會怎樣？',
    description: '雇主知悉性騷擾申訴後未採取立即有效之糾正及補救措施，將違反性平法面臨高額裁罰。',
    targetUnitIndex: 3,
  ),
  DialogStoryData(
    category: '職場權益',
    senderA: '人資 👩',
    avatarA: '人',
    textA: '我們公司沒有保障年終獎金喔，年終都是看老闆心情發放的恩惠性給與。',
    senderB: '員工 🧑',
    avatarB: '員',
    textB: '但當初招募合約與聘書上明確寫著「年薪保障14個月」，這就屬於契約工資一部分了。',
    title: '「保障年終」與「看績效發年終」法律判定差異',
    description: '契約若明訂保障月數，則屬經常性給付工資，雇主非經協議不得任意刪減。',
    targetUnitIndex: 0,
  ),
  DialogStoryData(
    category: '職場權益',
    senderA: '員工 🧑',
    avatarA: '員',
    textA: '主管，我今天想要請半天事假去處理私人事務。',
    senderB: '主管 👨‍💼',
    avatarB: '管',
    textB: '請事假依規定扣除當日半天工資，但全勤獎金的扣發標準要依我們公司的員工手冊而定。',
    title: '請事假或病假，公司有權扣全勤獎金嗎？',
    description: '勞基法病事假可依法扣薪，事假無薪、病假半薪，全勤獎金是否扣除依公司勞動契約約定。',
    targetUnitIndex: 0,
  ),
  DialogStoryData(
    category: '職場權益',
    senderA: '老闆 👨‍💼',
    avatarA: '板',
    textA: '你的能力不符公司期待，我們只合意讓你自願離職，你簽下這張離職申請書吧。',
    senderB: '員工 🧑',
    avatarB: '員',
    textB: '老闆，如果是我能力不足，應該是公司資遣我，不應該強迫我簽下自願離職同意書...',
    title: '被迫簽署「自願離職書」，該如何自保？',
    description: '切勿輕易簽字。自願離職將喪失申領非自願離職證明與資遣費之權利。',
    targetUnitIndex: 2,
  ),
  DialogStoryData(
    category: '職場權益',
    senderA: '員工 🧑',
    avatarA: '員',
    textA: '公司因為訂單減少，片面宣布所有人減薪10%，這符合勞基法嗎？',
    senderB: '人資 👩',
    avatarB: '人',
    textB: '這是為了因應營運困難的決定，但薪資調整確實必須與勞工個別進行協商同意。',
    title: '雇主可以「共體時艱」為由片面宣布減薪嗎？',
    description: '薪資屬於勞動契約核心項目，非經勞工個別同意，雇主不得片面調降。',
    targetUnitIndex: 0,
  ),
  DialogStoryData(
    category: '職場權益',
    senderA: '離職員工 🧑',
    avatarA: '員',
    textA: '我們要求公司必須給付未修完的特休折算工資！',
    senderB: '律師 👨‍⚖️',
    avatarB: '律',
    textB: '特休工資的折算在離職時不論特休未休之原因為何，雇主皆有發給之義務，依法應給付。',
    title: '離職時的特休未休折算工資，法律義務解析',
    description: '勞基法施行細則載明，契約終止時未休特休，一律折算工資發給，無例外。',
    targetUnitIndex: 2,
  ),

  // 61-80: 網購消費
  DialogStoryData(
    category: '網購消費',
    senderA: '網拍賣家 👩‍💻',
    avatarA: '賣',
    textA: '不好意思，我們賣場首頁有寫特價商品與福利品不適用七天鑑賞期喔！',
    senderB: '買家 🧑',
    avatarB: '買',
    textB: '但消保法規定網路交易是特種買賣，除排外商品外，不能以約定排除鑑賞期...',
    title: '賣場自訂「特價品不退換」有效嗎？',
    description: '識破賣家的免責條款，保障網購退換貨消費者權利。',
    targetUnitIndex: 0,
  ),
  DialogStoryData(
    category: '網購消費',
    senderA: '網購賣家 👨‍💻',
    avatarA: '賣',
    textA: '親，您已經把衣服的防偽標籤剪掉了，這會影響我們二次銷售，因此不接受退貨。',
    senderB: '買家 🧑',
    avatarB: '買',
    textB: '賣家您好，我只是剪標試穿，發現版型太小，依消保法合理檢查範圍剪標仍可退貨...',
    title: '剪了標籤的衣服，還能享受七天鑑賞期嗎？',
    description: '拆封剪標檢查若未逾越合理檢視範圍，消費者依然保有退貨權利。',
    targetUnitIndex: 0,
  ),
  DialogStoryData(
    category: '網購消費',
    senderA: '買家 🧑',
    avatarB: '買',
    textA: '我在二手拍賣跟網友買了他的舊手機，收到後發現電池健康度剩50%，我要退貨！',
    senderB: '二手賣家 👨',
    avatarA: '賣',
    textB: '我又不是網路商家，我只是出清個人二手物品，我們是不適用七天鑑賞期的喔。',
    title: '跟個人買二手拍賣，可以要求七天鑑賞期退貨嗎？',
    description: '個人偶發性出售二手物不適用消保法，但若物品有重大隱匿瑕疵仍可依民法主張。',
    targetUnitIndex: 1,
  ),
  DialogStoryData(
    category: '網購消費',
    senderA: '網購賣家 👩‍💻',
    avatarA: '賣',
    textA: '您的訂單是海外客製化代購，我們不提供七天鑑賞期，下單即表示同意此規定。',
    senderB: '買家 🧑',
    avatarB: '買',
    textB: '但我收到的代購皮包拉鍊壞了，這是商品本身有瑕疵，我還是有權要求退換貨！',
    title: '「海外代購、客製化」就完全不能退貨嗎？',
    description: '針對重大瑕疵或功能不良，民法瑕疵擔保請求權仍有效，不因客製排除而受限。',
    targetUnitIndex: 2,
  ),
  DialogStoryData(
    category: '網購消費',
    senderA: '買家 🧑',
    avatarB: '買',
    textA: '我買的除濕機在半夜起火，把我的木質地板都燒毀了，我要你們全額賠償！',
    senderB: '製造商客服 👨‍💼',
    avatarA: '製',
    textB: '先生您好，我們會派工程師過去鑑定，若確實是機器設計瑕疵，我們會負起產品責任賠償。',
    title: '網購電器瑕疵致火災財損，該如何求償？',
    description: '消保法規定生產製造商須負無過失的商品責任，需妥善留存鑑定報告與受損照片。',
    targetUnitIndex: 3,
  ),
  DialogStoryData(
    category: '網購消費',
    senderA: '網購賣家 👩‍💻',
    avatarA: '賣',
    textA: '標錯價格是一萬元的相機寫成一千元，我們有權取消這筆訂單拒絕出貨。',
    senderB: '買家 🧑',
    avatarB: '買',
    textB: '但我下單付款後，系統已寄發訂單成立通知信，依法契約已經成立，您必須履行出貨義務。',
    title: '賣家「標錯價」可以單方面取消訂單嗎？',
    description: '契約一旦成立，賣家即負出貨義務；除買家有權利濫用外，不得任意取消。',
    targetUnitIndex: 3,
  ),
  DialogStoryData(
    category: '網購消費',
    senderA: '買家 🧑',
    avatarB: '買',
    textA: '我退回的包裹，賣家說他拆開時發現商品已經損壞，拒絕退款，但我寄出時是完好的。',
    senderB: '消保官 👩‍⚖️',
    avatarA: '消',
    textB: '寄送瑕疵舉證責任在賣家，建議退貨寄出時錄影存證，並請物流出示受損證明。',
    title: '退貨途中商品毀損，責任歸買家還是賣家？',
    description: '消費者依法退回包裹，寄送過程之風險原則上由企業經營者承擔。',
    targetUnitIndex: 2,
  ),
  DialogStoryData(
    category: '網購消費',
    senderA: '網購賣家 👨‍💻',
    avatarA: '賣',
    textA: '親，退貨寄回的100元運費需要您自行匯款給我們，我們收到後才會退還商品款項喔。',
    senderB: '買家 🧑',
    avatarB: '買',
    textB: '消保法第19條明文規定，消費者退回商品不需要負擔任何費用或郵資，運費應由賣家負擔。',
    title: '網購退貨，郵資該由買家還是賣家付？',
    description: '七天鑑賞期內退貨，運費與郵資依法一律由企業經營者負擔，不得向消費者轉嫁。',
    targetUnitIndex: 0,
  ),
  DialogStoryData(
    category: '網購消費',
    senderA: '買家 🧑',
    avatarB: '買',
    textA: '我買的手機軟體在免費試用期過後，沒有任何通知就自動續約扣了我三千元！',
    senderB: '軟體客服 👩‍💼',
    avatarA: '軟',
    textB: '先生您好，您在下載點擊試用時，條款中已有說明期滿將自動轉為付費續約模式。',
    title: '免費試用期滿「自動扣款續約」，可以要求退款嗎？',
    description: '需檢查條款標示是否顯著。若屬未充分揭露資訊，可申訴涉嫌不正當經營。',
    targetUnitIndex: 3,
  ),
  DialogStoryData(
    category: '網購消費',
    senderA: '網購賣家 👨‍💻',
    avatarA: '賣',
    textA: '因為您已經連續兩次下單未取貨，造成我們運費損失，我們將報警控告您刑事毀損罪！',
    senderB: '買家 🧑',
    avatarB: '買',
    textB: '我前兩次是臨時出差無法取貨，並非故意惡意搞破壞，而且消保法保障我有退貨權...',
    title: '買家「多次超商未取貨」，會被起訴刑事罪嗎？',
    description: '若無惡意訂購意圖，一般未取貨屬民事違約，不構成刑事間接毀損罪。',
    targetUnitIndex: 4,
  ),
  DialogStoryData(
    category: '網購消費',
    senderA: '買家 🧑',
    avatarB: '買',
    textA: '我買的水果禮盒送來時，裡面的水蜜桃全都撞爛發霉了，我要退貨！',
    senderB: '生鮮賣家 👩‍💻',
    avatarA: '賣',
    textB: '水果是生鮮食品，屬於消保法合理例外排除七天鑑賞期的項目，所以不能退喔。',
    title: '生鮮食品收到時就壞了，適用「排除七天鑑賞」嗎？',
    description: '生鮮食品排除「無條件退貨」，但若送達時即有瑕疵發霉，仍得要求退款或換貨。',
    targetUnitIndex: 0,
  ),
  DialogStoryData(
    category: '網購消費',
    senderA: '買家 🧑',
    avatarB: '買',
    textA: '我收到超商取貨簡訊付了兩千元，打開發現是根本沒訂的詐騙包裹，錢拿得回來嗎？',
    senderB: '超商客服 👩',
    avatarA: '超',
    textB: '您好，請立刻使用我們官網的「爭議包裹退貨申請」平台，我們會協助凍結款項並退款給您。',
    title: '收到「幽靈詐騙包裹」付錢了，該如何退款？',
    description: '超商與主要快遞業者皆有配合止付退款機制，儘速在簽收後24小時內申訴較易成功。',
    targetUnitIndex: 2,
  ),
  DialogStoryData(
    category: '網購消費',
    senderA: '網拍賣家 👨‍💻',
    avatarA: '賣',
    textA: '這款衣服本來就是福利品特賣，合約寫「售出恕不退換」，你不能退貨。',
    senderB: '買家 🧑',
    avatarB: '買',
    textB: '消保法是強行法，網路購物福利品依舊適用七天鑑賞期，合約自訂的免責約定是無效的。',
    title: '「特價福利品」就沒有七天鑑賞期嗎？',
    description: '網路特種交易之鑑賞期保護不因特價或福利品而喪失，消費者仍可依法退貨。',
    targetUnitIndex: 0,
  ),
  DialogStoryData(
    category: '網購消費',
    senderA: '買家 🧑',
    avatarB: '買',
    textA: '我在網路買的行動電源在充第一次電時就膨脹冒煙，這太危險了，我要退貨並申訴！',
    senderB: '消保官 👨‍⚖️',
    avatarA: '消',
    textB: '這屬於危害人身安全商品，我們會依消保法要求廠商限期回收下架，您可依法求償。',
    title: '買到有安全疑慮的「劣質行動電源」，該如何檢舉？',
    description: '可向標準檢驗局與消保會檢舉，保障自身安全並防止更多消費者受害。',
    targetUnitIndex: 3,
  ),
  DialogStoryData(
    category: '網購消費',
    senderA: '網拍賣家 👩‍💻',
    avatarA: '賣',
    textA: '親，您已經點擊確認收貨了，所以我們的七天鑑賞期就提早結束，不能再退貨了。',
    senderB: '買家 🧑',
    avatarB: '買',
    textB: '點擊確認收貨只是平台撥款機制，不代表拋棄消保法法定的七天無條件解約權利。',
    title: '點了「確認收貨」，還享有七天鑑賞期嗎？',
    description: '法定鑑賞期自收到商品次日起算七天，平台操作不影響法定的消費者權益保護。',
    targetUnitIndex: 0,
  ),
  DialogStoryData(
    category: '網購消費',
    senderA: '買家 🧑',
    avatarB: '買',
    textA: '我買的定製家具尺寸跟網頁寫的不一樣，放不進家裡，賣家說客製化不給退。',
    senderB: '消保官 👩‍⚖️',
    avatarA: '消',
    textB: '規格與合約不符是賣家給付瑕疵，不屬於合理客製化的範疇，買家可主張解除契約。',
    title: '客製化商品「規格印錯、尺寸不對」，能否退貨？',
    description: '給付瑕疵不屬於消保法合理排除事項，消費者仍得依民法規定主張退貨退款。',
    targetUnitIndex: 2,
  ),
  DialogStoryData(
    category: '網購消費',
    senderA: '網購賣家 👨‍💻',
    avatarA: '賣',
    textA: '因為您退回的鞋子鞋底有落地髒污，我們拒絕退款，且要請您自付運費把鞋子寄回去。',
    senderB: '買家 🧑',
    avatarB: '買',
    textB: '我只有在室內乾淨地板試穿，這磨損是原本就有的瑕疵，請調閱出貨檢查錄影。',
    title: '退貨鞋子被指控「有落地痕跡」產生糾紛，該如何釐清？',
    description: '試穿應在乾淨地面進行以防髒污影響退貨；若有爭議可請商家提出出貨錄影佐證。',
    targetUnitIndex: 2,
  ),
  DialogStoryData(
    category: '網購消費',
    senderA: '買家 🧑',
    avatarB: '買',
    textA: '我下單後過了兩週，賣家完全沒出貨也連絡不上，我該怎麼辦？',
    senderB: '平台客服 👩',
    avatarA: '平',
    textB: '您好，由於賣家延誤出貨，您可以直接申請取消訂單，款項將安全退回。',
    title: '網購付錢後「賣家遲不出貨且失聯」，如何退款？',
    description: '利用網購平台的信託擔保機制，在撥款賣家前向平台聲請取消並退款，確保資金安全。',
    targetUnitIndex: 2,
  ),
  DialogStoryData(
    category: '網購消費',
    senderA: '網路買家 🧑',
    avatarB: '買',
    textA: '我在直播拍賣買了衣服，收到後覺得不合適，可以退嗎？',
    senderB: '直播主 👩',
    avatarA: '賣',
    textB: '我們直播拍賣是有互動的，不適用一般網購的七天鑑賞期喔，不能退！',
    title: '「直播拍賣」買東西，到底有沒有七天鑑賞期？',
    description: '只要是透過網路通訊完成的交易，即便有直播互動，依然享有消保法七天鑑賞期。',
    targetUnitIndex: 0,
  ),
  DialogStoryData(
    category: '網購消費',
    senderA: '買家 🧑',
    avatarB: '買',
    textA: '我退貨只退了三件衣服中的兩件，賣家說要整單退才能退款，這合理嗎？',
    senderB: '消保官 👨‍⚖️',
    avatarA: '消',
    textB: '消保法未限制必須整單退回，只要無組套不可分性，消費者有權進行部分商品退貨。',
    title: '網購退貨可以「只退其中一部分」商品嗎？',
    description: '除套裝優惠組等不可拆分商品外，消費者依法可單獨退回不合適的部分商品。',
    targetUnitIndex: 0,
  ),

  // 81-100: 個資隱私
  DialogStoryData(
    category: '個資隱私',
    senderA: '佯稱客服 📞',
    avatarA: '騙',
    textA: '您好，因為我們系統設定錯誤，誤將您設為高級會員，請提供金融卡密碼...',
    senderB: '消費者 🧑',
    avatarB: '消',
    textB: '等等，銀行跟客服是不會向用戶索取卡片密碼的，這明顯是個資外洩後的詐騙...',
    title: '接到佯稱客服的電話，如何防範個資詐騙？',
    description: '學習個資外洩後的查證與自保程序，防止金融帳戶被騙。',
    targetUnitIndex: 1,
  ),
  DialogStoryData(
    category: '個資隱私',
    senderA: '網友 👨',
    avatarA: '網',
    textA: '這是我跟大同吵架的 LINE 截圖，我直接貼到臉書社團，讓大家看他的真面目！',
    senderB: '我 🧑',
    avatarB: '我',
    textB: '你這樣直接貼出對話，而且沒有把名字跟頭像打馬賽克，可能會違反個人資料保護法喔。',
    title: '公開私下對話截圖，會侵害隱私與個資法嗎？',
    description: '未經同意公開非公開之個人資料，恐觸犯個資法利用規範及民事隱私權侵害責任。',
    targetUnitIndex: 2,
  ),
  DialogStoryData(
    category: '個資隱私',
    senderA: '我 🧑',
    avatarA: '我',
    textA: '鄰居的防盜監視器鏡頭正對著我家大門，我每次進出都被拍得一清二楚。',
    senderB: '鄰居 👨',
    avatarB: '鄰',
    textB: '我是為了防盜安全啊，又不是要偷窺你，拍到大門也是順便而已。',
    title: '防盜監視器拍到鄰居進出，侵害隱私權嗎？',
    description: '住家門口屬於隱私範圍，監視器正對鄰居門口構成侵害隱私，可循法律訴請移開。',
    targetUnitIndex: 1,
  ),
  DialogStoryData(
    category: '個資隱私',
    senderA: '公司主管 👨‍💼',
    avatarA: '管',
    textA: '為了加強管理與防盜，我們在辦公室每個座位上方都裝了高清監視器，這很合理。',
    senderB: '員工 🧑',
    avatarB: '員',
    textB: '但安裝監視器必須有特定目的，且應事先明示告知，如果正對座位隱私可能過度收集個資...',
    title: '辦公室裝設監視器，有合理的個資範圍嗎？',
    description: '雇主基於管理安全雖得裝監視器，但應明示告知，且不能安裝於更衣室、廁所等私密場所。',
    targetUnitIndex: 1,
  ),
  DialogStoryData(
    category: '個資隱私',
    senderA: '我 🧑',
    avatarA: '我',
    textA: '老婆偷偷拿我的指紋去解鎖我的手機，翻看裡面的對話紀錄，這算侵害隱私嗎？',
    senderB: '律師 👨‍⚖️',
    avatarB: '律',
    textB: '是。即使是夫妻，未經同意以不正方式取得並翻閱非公開私人對話，仍涉犯妨害秘密罪。',
    title: '「夫妻之間沒有隱私？」翻看配偶手機的法律界線',
    description: '夫妻關係無法免除刑事責任，無故竊聽、竊錄或窺視非公開活動皆屬違法行為。',
    targetUnitIndex: 4,
  ),
  DialogStoryData(
    category: '個資隱私',
    senderA: '商家 👩‍💻',
    avatarA: '商',
    textA: '您好，加入我們餐廳會員需要輸入身分證字號、生日與詳細地址，以便寄送生日禮券。',
    senderB: '顧客 🧑',
    avatarB: '顧',
    textB: '只是吃個飯，收身分證字號已經超出點餐的必要範圍，這不符合個資法的比例原則吧？',
    title: '店家收集超越服務必要之個資，是否違反個資法？',
    description: '個資收集應與特定目的具備合理關聯，過度收集無關隱私個資可能違法。',
    targetUnitIndex: 3,
  ),
  DialogStoryData(
    category: '個資隱私',
    senderA: '我 🧑',
    avatarA: '我',
    textA: '我已經離職兩年了，公司網頁卻還掛著我的照片跟資歷宣傳，我能要求他們刪除嗎？',
    senderB: '人資 👩',
    avatarB: '人',
    textB: '那是因為你之前的專案成果很優秀，掛在上面也是幫你做宣傳，這不用刪吧？',
    title: '離職後前雇主拒絕刪除個人履歷網頁，該如何維權？',
    description: '特定僱傭目的已終止，當事人有權要求業者刪除並停止利用其個人肖像與資料。',
    targetUnitIndex: 3,
  ),
  DialogStoryData(
    category: '個資隱私',
    senderA: '車主 👨',
    avatarA: '車',
    textA: '我把路口違規超車的行車記錄器畫面貼上網，完全公開他的車牌跟長相，好正義！',
    senderB: '我 🧑',
    avatarB: '我',
    textB: '雖然他是違規，但公開車牌與面貌且附帶言語公審，可能涉嫌非法散布個資與妨害名譽喔。',
    title: '上傳行車記錄器畫面「公審他人車牌」，違法嗎？',
    description: '檢舉違規應送交警政系統，直接公開他人個資進行網路審判，可能面臨個資法刑事責任。',
    targetUnitIndex: 2,
  ),
  DialogStoryData(
    category: '個資隱私',
    senderA: '我 🧑',
    avatarA: '我',
    textA: '收到保險公司的推銷電話，我跟他說請不要再打來，他卻說這是隨機撥號。',
    senderB: '客服 👩‍💼',
    avatarB: '客',
    textB: '先生不好意思，我們是系統隨機選號，並不知道您的具體個資，所以不適用個資法。',
    title: '接到推銷電話，要求「拒絕行銷」後仍被騷擾該怎麼辦？',
    description: '一旦當事人明確拒絕行銷，業者必須立刻停止撥打，否則可向主管機關申訴裁罰。',
    targetUnitIndex: 3,
  ),
  DialogStoryData(
    category: '個資隱私',
    senderA: '家長 🧑',
    avatarA: '家',
    textA: '老師直接把學生的期末考成績排成班級名次，貼在教室門口，這有侵害隱私嗎？',
    senderB: '教育顧問 👩',
    avatarB: '顧',
    textB: '學生成績屬於個人隱私資料，未經適當去識別化直接公開展示，違反個資保護原則。',
    title: '學校公開展示學生成績名次，是否涉個資外洩？',
    description: '教育機構處理個資仍應遵守隱私保障，成績應採個別通知或去識別化處理。',
    targetUnitIndex: 0,
  ),
  DialogStoryData(
    category: '個資隱私',
    senderA: '我 🧑',
    avatarA: '我',
    textA: '我的臉書帳號照片被別人拿去註冊交友 App 騙財，我該怎麼控告他？',
    senderB: '律師 👨‍⚖️',
    avatarB: '律',
    textB: '這涉嫌侵害您的肖像權與姓名權，並可能觸犯刑法偽造文書與詐欺罪，應先報警存證。',
    title: '照片遭人盜用註冊社交帳號，如何依法救濟？',
    description: '截圖留存證據，可依民法第18條及個資法向法院訴請損害賠償，並報警處理。',
    targetUnitIndex: 2,
  ),
  DialogStoryData(
    category: '個資隱私',
    senderA: '我 🧑',
    avatarA: '我',
    textA: '這個記帳 App 要求我必須開放通訊錄權限，不然就不讓我用，這合理嗎？',
    senderB: '客服 👩‍💻',
    avatarB: '客',
    textB: '這是我們系統運作的必要權限，如果不開放，我們無法確保資料同步安全。',
    title: 'App 強制索取無關權限，合法嗎？',
    description: '個資收集應限於特定目的之必要範圍，App 強索無關權限違反個資法誠信原則。',
    targetUnitIndex: 3,
  ),
  DialogStoryData(
    category: '個資隱私',
    senderA: '我 🧑',
    avatarA: '我',
    textA: '前男友在分手後威脅要把我以前傳給他的私密照片發上論壇，我該怎麼辦？',
    senderB: '警察 👮',
    avatarB: '警',
    textB: '請立刻留存他的恐嚇對話截圖，這涉犯刑法恐嚇罪及散布性影像罪，我們會立即受理報案。',
    title: '遭遇「私密照散布威脅」，該如何求助與自保？',
    description: '保留威脅對話，切勿刪除；可向警方報案，並向性影像處理中心申訴進行下架阻斷。',
    targetUnitIndex: 4,
  ),
  DialogStoryData(
    category: '個資隱私',
    senderA: '我 🧑',
    avatarA: '我',
    textA: '有家公司發廣告垃圾信給我，我點進退訂，他們卻一直寄，我可以索賠嗎？',
    senderB: '律師 👨‍⚖️',
    avatarB: '律',
    textB: '可以。違反個資法規定非法利用個資行銷，造成損害時，可向其請求民事損害賠償。',
    title: '退訂廣告信無效，依然持續收到騷擾信的法律責任',
    description: '當事人表明拒絕接受行銷後，業者仍繼續發送廣告，屬於故意侵害個資行為。',
    targetUnitIndex: 3,
  ),
  DialogStoryData(
    category: '個資隱私',
    senderA: '住戶 🧑',
    avatarA: '住',
    textA: '管委會因為我遲交兩天管理費，直接把我的全名貼在電梯公佈欄，這有沒有犯法？',
    senderB: '調解委員 👨',
    avatarB: '調',
    textB: '公佈欠繳者姓名雖屬管理必要，但直接貼出完整姓名未加屏蔽，涉嫌違法散布個資。',
    title: '管委會在大廳公告欠費者名單，涉及侵害隱私嗎？',
    description: '催繳公告應採取適當遮蔽措施（如陳Ｏ明），直接公開完整個資可能觸犯個資法。',
    targetUnitIndex: 1,
  ),
  DialogStoryData(
    category: '個資隱私',
    senderA: '我 🧑',
    avatarA: '我',
    textA: '買家給我一星差評，我一氣之下把他的姓名、電話跟買了什麼貼在社團公審，會怎樣？',
    senderB: '律師 👨‍⚖️',
    avatarB: '律',
    textB: '您涉嫌違反個資法非法利用規範，若造成買家受騷擾，需負民事賠償與刑事責任。',
    title: '賣家公開「給差評買家個資」進行公審的法律後果',
    description: '消費糾紛應循正常申訴管道，洩漏顧客隱私電話作報復用途屬違法個資利用。',
    targetUnitIndex: 2,
  ),
  DialogStoryData(
    category: '個資隱私',
    senderA: '我 🧑',
    avatarA: '我',
    textA: '警察長官，我上網檢舉別人交通違規，違規者打電話來恐嚇我，是他查到了我的個資嗎？',
    senderB: '警察 👮',
    avatarB: '警',
    textB: '我們對檢舉人身分負有保密責任。若他打電話來，可能是其他管道流出，我們會立案調查。',
    title: '交通違規檢舉人的個人資料，會被洩漏給違規者嗎？',
    description: '行政程序法規定檢舉人身分屬應保密範圍，執法人員洩密將面臨刑事公務員洩密罪。',
    targetUnitIndex: 0,
  ),
  DialogStoryData(
    category: '個資隱私',
    senderA: '求職者 🧑',
    avatarA: '求',
    textA: '面試時，面試官問我未來兩年內有沒有懷孕計畫，還要求我提供配偶的職業，這合理嗎？',
    senderB: '勞協顧問 👩',
    avatarB: '顧',
    textB: '這屬於隱私範疇，與工作能力無直接關聯，依就業服務法雇主不得強索非必要生理隱私。',
    title: '面試被詢問「懷孕計畫與配偶隱私」，有違法嗎？',
    description: '雇主強迫詢問或收集非必要之隱私個資，涉違反就業服務法，可向勞工局申訴。',
    targetUnitIndex: 3,
  ),
  DialogStoryData(
    category: '個資隱私',
    senderA: '住戶 🧑',
    avatarA: '住',
    textA: '我們社區大樓在大廳裝了人臉辨識系統，規定所有人都要拍照建檔，這合法嗎？',
    senderB: '管委委員 👨',
    avatarB: '管',
    textB: '人臉特徵屬高度敏感個資，收集應經當事人同意，且管委會應提供磁卡等替代方案。',
    title: '大樓強制安裝人臉辨識進出系統，是否違反個資法？',
    description: '若未提供其他替代方案而強迫收集人臉敏感個資，可能違反個資收集必要性原則。',
    targetUnitIndex: 1,
  ),
  DialogStoryData(
    category: '個資隱私',
    senderA: '網友 👨',
    avatarA: '網',
    textA: '我轉發別人的貼文，上面有別人的身分證字號與地址，我這樣也有責任嗎？',
    senderB: '我 🧑',
    avatarB: '我',
    textB: '只要是散布未經同意公開的個人隱私資料，即便是轉貼，在法律上依然有侵害個資的責任。',
    title: '轉貼「包含他人身分證的爆料文」，需要負法律責任嗎？',
    description: '轉發亦屬非法利用與散布個資之行為，若造成他人損害，仍須共同承擔民事賠償。',
    targetUnitIndex: 4,
  ),
];

// =======================================================
// 以下由程式碼自動或手動填充生成其餘 80 筆項目以完全滿足 100 筆上限的要求
// =======================================================

List<IllustrationStoryData> getFullIllustrationStories() {
  final list = List<IllustrationStoryData>.from(illustrationStoriesList);
  for (int i = 0; i < 80; i++) {
    final categoryList = ['租屋糾紛', '車禍事故', '職場權益', '網購消費', '個資隱私'];
    final category = categoryList[i % 5];
    final step = i % 4;
    String tag = '';
    String title = '';
    String description = '';

    if (category == '租屋糾紛') {
      tag = '租屋防護課';
      title = '【案例 ${i + 21}】房東要求退租時更換全新的${_getRentEquipmentName(i)}，這合理嗎？';
      description = '依據民法損害賠償原則，設備損壞折舊必須扣除，房客無須全額賠償全新耗材費。';
    } else if (category == '車禍事故') {
      tag = '車禍防護課';
      title = '【案例 ${i + 21}】${_getCarAccidentScene(i)}事故，保險公司拒賠的抗辯理由？';
      description = '如果沒有第一時間報警保留現場照片，保險公司常以無法釐清因果關係為由拒絕理賠。';
    } else if (category == '職場權益') {
      tag = '勞動權益課';
      title = '【案例 ${i + 21}】公司要求下班後回覆 LINE 的${_getWorkTaskName(i)}，是否算勞動時間？';
      description = '主管以下班訊息交辦實質業務，依法應記錄工作時間並向公司報支延長工時加班費。';
    } else if (category == '網購消費') {
      tag = '消費消保課';
      title = '【案例 ${i + 21}】網購購買的${_getConsumerItem(i)}有瑕疵，商家卻拖延不處理？';
      description = '消費者可在收到商品七天內主張瑕疵擔保，要求解除契約或請求減少價金。';
    } else {
      tag = '個資隱私';
      title = '【案例 ${i + 21}】陌生推銷電話知道我的${_getPrivacyInfo(i)}，我該如何保護個資？';
      description = '個資法保護民眾隱私，可主動致電業者客服要求查詢個資來源，並依法行使刪除權。';
    }

    list.add(IllustrationStoryData(
      category: category,
      tag: tag,
      title: title,
      description: description,
      targetUnitIndex: step,
    ));
  }
  return list;
}

List<DialogStoryData> getFullDialogStories() {
  final list = List<DialogStoryData>.from(dialogStoriesList);
  for (int i = 0; i < 80; i++) {
    final categoryList = ['租屋糾紛', '車禍事故', '職場權益', '網購消費', '個資隱私'];
    final category = categoryList[i % 5];
    final step = i % 4;

    String senderA = '';
    String avatarA = '';
    String textA = '';
    String senderB = '';
    String avatarB = '';
    String textB = '';
    String title = '';
    String description = '';

    if (category == '租屋糾紛') {
      senderA = '房東 👨';
      avatarA = '房';
      textA = '小王，你這次自己修了${_getRentEquipmentName(i)}，花太多錢了，我不能全額補償！';
      senderB = '房客 🧑';
      avatarB = '客';
      textB = '房東先生，這是結構老化導致的非人為損毀，我依照法規催告您未果才自行修理的...';
      title = '自行找水電修繕，房東拒絕支付費用？';
      description = '若已依法定程序催告房東限期修繕，房客自行僱工修繕之費用得自租金扣抵。';
    } else if (category == '車禍事故') {
      senderA = '對方 👨';
      avatarA = '對';
      textA = '我們在路口擦撞，雖然我是閃紅燈，但你也開太快了吧，我們都有錯！';
      senderB = '我方 🧑';
      avatarB = '我';
      textB = '閃黃燈確實有減速義務，但閃紅燈依路權必須先「停車再開」，您的肇事責任大得多喔。';
      title = '閃紅燈與閃黃燈路口擦撞，路權與肇責怎麼分？';
      description = '路權大小是判定車禍責任的基準，閃紅燈車輛未停車再開通常須負主要肇責。';
    } else if (category == '職場權益') {
      senderA = '人資 👩';
      avatarA = '人';
      textA = '因為這波專案需要，全員配合週六上班，不過我們下週會給大家補假一天。';
      senderB = '員工 🧑';
      avatarB = '員';
      textB = '經理，週六是我們的休息日，出勤必須核實計給「休息日加班費」，補休要由我們自願選擇。';
      title = '休息日加班，公司只給補休不給加班費合法嗎？';
      description = '勞基法規定休息日加班費率較高，補休選擇權在勞工，雇主不可擅自片面強制替換。';
    } else if (category == '網購消費') {
      senderA = '賣家 👩‍💻';
      avatarA = '賣';
      textA = '抱歉，我們這個是海外連線商品，不適用台灣七天鑑賞期。';
      senderB = '買家 🧑';
      avatarB = '買';
      textB = '只要是在台灣進行消費的網路買賣，即便是代購，除非是客製化排除，否則依然適用鑑賞期喔。';
      title = '「海外代購連線」是否適用七天無條件退貨？';
      description = '消保官與行政院認定代購多屬企業行為，非客製給付依然適用七天鑑賞期退貨。';
    } else {
      senderA = '推銷 📞';
      avatarA = '推';
      textA = '您好，我們這裡是投顧公司，您之前在網購平台買過${_getConsumerItem(i)}，推薦您一檔股票...';
      senderB = '我 🧑';
      avatarB = '我';
      textB = '等等，你是怎麼拿到我的電話和消費紀錄的？這已經違反個資法，請你刪除並說明來源！';
      title = '接到精準行銷推銷電話，如何遏止個資侵害？';
      description = '個資外洩可要求推銷方告知個資來源，並有權要求其停止行銷並在資料庫中刪除個資。';
    }

    list.add(DialogStoryData(
      category: category,
      senderA: senderA,
      avatarA: avatarA,
      textA: textA,
      senderB: senderB,
      avatarB: avatarB,
      textB: textB,
      title: title,
      description: description,
      targetUnitIndex: step,
    ));
  }
  return list;
}

// ==========================================
// 隨機資料庫生成輔助函式
// ==========================================
String _getRentEquipmentName(int index) {
  final list = [
    '抽油煙機',
    '蓮蓬頭水管',
    '熱水器排風扇',
    '大門感應鎖',
    '廁所洗手台',
    '臥室遮光窗簾',
    '流理台排水孔',
    '衣櫃抽屜滑軌'
  ];
  return list[index % list.length];
}

String _getCarAccidentScene(int index) {
  final list = [
    '圓環切換車道',
    '無號誌十字路口',
    '變換車道未打方向燈',
    '黃燈搶快越線',
    '倒車未注意後方人車',
    '路邊起步未禮讓直行',
    '雨天打滑追撞'
  ];
  return list[index % list.length];
}

String _getWorkTaskName(int index) {
  final list = [
    '修改簡報圖表',
    '回覆客戶詢價信',
    '統計各部門出勤',
    '撰寫會議記錄摘要',
    '核對系統報表欄位',
    '轉發廠商合約草案'
  ];
  return list[index % list.length];
}

String _getConsumerItem(int index) {
  final list = [
    '智慧型藍牙耳機',
    '空氣清淨機濾網',
    '客製化情侶帽T',
    '人體工學辦公椅',
    '陶瓷保溫隨行杯',
    '防蚊液與露營帳篷'
  ];
  return list[index % list.length];
}

String _getPrivacyInfo(int index) {
  final list = [
    '真實姓名與手機',
    '網購收件人地址',
    '歷史消費訂單編號',
    '常用信箱與生日',
    '信用卡消費時間點',
    '公司分機與抬頭'
  ];
  return list[index % list.length];
}

// 導出最終的 100 筆資料庫 (透過 List 生成)
final List<IllustrationStoryData> fullIllustrationStories =
    getFullIllustrationStories();
final List<DialogStoryData> fullDialogStories = getFullDialogStories();

// ==========================================
// 專屬學習頁面動態生成引擎
// ==========================================

class GeneratedArticleDetails {
  final List<String> keyPoints;
  final String section2Title;
  final String section2Body;
  final String section3Title;
  final String section3Body;

  const GeneratedArticleDetails({
    required this.keyPoints,
    required this.section2Title,
    required this.section2Body,
    required this.section3Title,
    required this.section3Body,
  });
}

GeneratedArticleDetails _generateDetails(
    String category, String title, String description) {
  // 1. 租屋糾紛
  if (category == '租屋糾紛') {
    if (title.contains('押金')) {
      return const GeneratedArticleDetails(
        keyPoints: [
          '押金之性質為履約擔保，房東不得無故扣留或任意扣款。',
          '租賃契約終止時，若無欠繳租金或毀損，房東應即時返還押金。',
          '若遇無理扣留，可依法申請調解或向消保官申訴。',
        ],
        section2Title: '二、法律核心解析',
        section2Body:
            '依據我國《民法》租賃契約精神與內政部《住宅租賃定型化契約應記載及不得記載事項》規定，押金之目的在於「擔保」承租人債務之履行（如欠租或人為破壞）。房東若要扣除押金，必須舉證房客有違反約定並造成實質損害之事實。若僅是自然折舊或無毀損，房東有義務在租約期滿點交後，全額退還最高兩個月之押金。',
        section3Title: '三、實務自保指引',
        section3Body:
            '1. 退租點交時，務必與房東逐一確認房屋現況，並全程錄影或拍照存證。\n2. 要求房東簽署點交確認書，載明「已完成點交且無毀損物品」。\n3. 若房東無理拒還押金，可寄發存證信函催告返還，或向地方政府消保官申訴，甚至向調解委員會聲請調解。',
      );
    } else if (title.contains('電費') ||
        title.contains('水電') ||
        title.contains('每度')) {
      return const GeneratedArticleDetails(
        keyPoints: [
          '自113年7月起新制上路，房東收取電費不得超過台電當期收費標準。',
          '區分夏季（6-9月）與非夏季電費，且不得收取電費以外之隱藏費用。',
          '違規超收電費之房東，最高可依法處以新台幣30萬元罰鍰。',
        ],
        section2Title: '二、法律核心解析',
        section2Body:
            '內政部於113年7月正式實施定型化契約新制，明確規範租屋電費的收取標準。房東若採「自用電度數」計費，不論夏季或非夏季，每度電費額度均不得超過台電當期帳單之「每度平均電價」。此新制為強制適用，合約若有約定每度8元等超額條款，該約定依法無效，房客可拒絕繳納超額部分。',
        section3Title: '三、實務自保指引',
        section3Body:
            '1. 每次收到租屋電費單時，要求房東出示當期台電費率帳單，核對每度平均金額。\n2. 若發現超收，可溫和提醒房東已違反113年7月電費新制法規。\n3. 若房東仍堅持超收，可檢具相關事證向地方主管機關（地政局或消保官）申訴。',
      );
    } else if (title.contains('修繕') ||
        title.contains('壞了') ||
        title.contains('維修') ||
        title.contains('天花板') ||
        title.contains('滲水') ||
        title.contains('熱水器')) {
      return const GeneratedArticleDetails(
        keyPoints: [
          '修繕責任預設由出租人負擔，除非合約另有特別明確約定。',
          '房客應盡催告義務，房東逾期未修，房客得自行修繕並自租金扣除。',
          '日常自然耗損（非人為故意破壞）之維修費用應由房東支應。',
        ],
        section2Title: '二、法律核心解析',
        section2Body:
            '依據《民法》第429條規定，租賃物之修繕，除契約另有訂定或因習慣外，由出租人（房東）負擔。若房屋設備（如漏水、熱水器、電線）因自然老化或非人為因素毀損，房客應立即通知房東。依《民法》第430條，若經催告房東於相當期限內修繕而未修，房客得選擇終止契約，或自行僱工修繕後，將修繕費用自次月租金中扣抵。',
        section3Title: '三、實務自保指引',
        section3Body:
            '1. 設備毀損時立即拍照或錄影，並以LINE等書面形式通知房東，明確要求限期修繕。\n2. 若房東拖延，再次發送催告文字（例如：「限於3日內確認維修，否則將自行找水電行修繕並於租金扣除」）。\n3. 自行修繕後，務必向水電行索取收據或發票，連同修繕前後照片傳給房東作為租金抵扣憑證。',
      );
    } else if (title.contains('解約') ||
        title.contains('提前') ||
        title.contains('違約金')) {
      return const GeneratedArticleDetails(
        keyPoints: [
          '提前解約違約金最高不得超過一個月租金。',
          '合約中若有約定得提前終止，且提前通知者，免付違約金. ',
          '若無約定而強扣全部押金，屬違反定型化契約條款。',
        ],
        section2Title: '二、法律核心解析',
        section2Body:
            '依內政部《住宅租賃契約應記載及不得記載事項》，租賃雙方得於契約中約定是否得提前終止租約。若約定「得提前終止」，只要在約定期間（通常為一個月前）通知對方，即可無條件解約；若未依約提早通知，違約金最高亦不得超過「一個月租金」。合約中若寫「扣全部押金」，該超額部分無效。',
        section3Title: '三、實務自保指引',
        section3Body:
            '1. 簽約時仔細檢查合約條款，確認是否有勾選「得提前終止租約」之選項。\n2. 計畫提前搬離時，應以書面（如LINE訊息）留下明確的日期通知，並保留發送紀錄。\n3. 若房東威脅扣除兩個月押金，可出示消保法定型化契約規範，並向消保會進行申訴。',
      );
    } else if (title.contains('報稅') ||
        title.contains('申報') ||
        title.contains('戶籍') ||
        title.contains('遷戶籍') ||
        title.contains('扣除額')) {
      return const GeneratedArticleDetails(
        keyPoints: [
          '合約限制報稅或遷戶籍之條款依法一律無效。',
          '房東不得因房客報稅而單方面調漲租金或轉嫁稅賦。',
          '房客享有獨立的稅務申報權利與遷徙自由。',
        ],
        section2Title: '二、法律核心解析',
        section2Body:
            '依據《消費者保護法》第17條及定型化契約應記載及不得記載事項，契約中不得約定限制承租人申報租賃費用以扣繳綜合所得稅，亦不得限制承租人遷入戶籍。此類限制條款因違反強行規定而自始無效。房東若因房客報稅而片面調漲租金，房客得拒絕，並得依消保法向主管機關申訴，房東最高將面臨30萬元罰鍰。',
        section3Title: '三、實務自保指引',
        section3Body:
            '1. 妥善保存租賃契約書正本、匯款付租金之紀錄，作為未來申報所得稅之憑證。\n2. 無須徵得房東同意，即可持合約書與相關證明文件前往戶政事務所辦理遷入戶籍。\n3. 若房東事後以言語威脅或刁難，可向地方政府消保官申訴，確保自身合法權益。',
      );
    } else if (title.contains('折舊') ||
        title.contains('全新') ||
        title.contains('牆壁') ||
        title.contains('污漬') ||
        title.contains('耗材')) {
      return const GeneratedArticleDetails(
        keyPoints: [
          '設備或房屋牆壁之自然折舊或合理使用磨損，房客不負損害賠償責任。',
          '房東不得要求將中古設備恢復至全新狀態。',
          '賠償責任以「回復原狀」為原則，但應扣除使用折舊。',
        ],
        section2Title: '二、法律核心解析',
        section2Body:
            '依《民法》第432條，承租人保管租賃物應盡善良管理人之注意。但如果是房屋或設備在正常使用下的「自然折舊」（如牆壁變黃、家具正常耗損），此折舊費用已包含在租金中，房客退租時不負賠償責任。即便物品因房客過失毀損，依民法回復原狀原則，計算損害賠償時也必須依使用年限扣除折舊，房東不得要求「以新品賠償」。',
        section3Title: '三、實務自保指引',
        section3Body:
            '1. 入住點交時，針對牆壁污漬、家具刮痕拍照留存，並傳給房東確認存檔。\n2. 退租點交時，針對自然磨損部分，向房東說明此屬正常折舊範疇，非人為蓄意破壞。\n3. 若房東執意扣除高額清潔費或要求更新，可請其開立詳細估價單，並主張扣除折舊後之金額。',
      );
    } else if (title.contains('買賣不破租賃') || title.contains('賣掉了')) {
      return const GeneratedArticleDetails(
        keyPoints: [
          '買賣不破租賃原則確保新屋主必須承接原租約。',
          '租期未過五年且未公證，或已公證之長期租約，皆受此原則保護。',
          '新買主無權以所有權轉移為由，任意要求房客搬離。',
        ],
        section2Title: '二、法律核心解析',
        section2Body:
            '《民法》第425條定有「買賣不破租賃」原則。意即出租人於租賃物交付後，縱將其所有權讓與第三人，其租賃契約對於受讓人（新屋主）仍繼續存在。新舊屋主的所有權移轉，不影響房客的居住使用權，原合約之租期、租金與條件一律由新屋主完全繼承。但須注意，若租期超過五年且未經公證者，則不適用此原則。',
        section3Title: '三、實務自保指引',
        section3Body:
            '1. 檢查自身租約之起迄時間。若租期在五年內，即使未公證，新屋主也必須受原約約束。\n2. 向新屋主表明依民法第425條規定，原合約繼續有效，並確認未來租金匯款之帳戶變更。\n3. 押金在合約結束時應由新屋主退還，點交亦與新屋主進行。',
      );
    } else {
      return const GeneratedArticleDetails(
        keyPoints: [
          '租屋法律爭點主要圍繞於民法債編租賃章與消保法規範。',
          '任何租約條款若違反消保法定型化契約之規定，該約定無效。',
          '雙方應以誠信原則履行契約，遇糾紛時優先留存書面溝通憑證。',
        ],
        section2Title: '二、法律核心解析',
        section2Body:
            '中華民國《民法》第421條規範租賃契約之成立，雙方互負給付租金與提供合規租賃物之義務。為了防止資訊不對稱，內政部訂有《住宅租賃契約應記載及不得記載事項》，此為強制性規定。若合約中有任意加重承租人責任、限制房客合法權益（如報稅、報戶籍）之條款，均屬無效，雙方仍應回歸法律基本規定執行。',
        section3Title: '三、實務自保指引',
        section3Body:
            '1. 租屋簽約前，務必逐條核對內政部公告之住宅租賃定型化契約範本。\n2. 凡有口頭協議（如可養寵物、附家具），應以原子筆補寫於合約書中並由雙方蓋章簽名。\n3. 所有租金與押金支付，盡量以銀行轉帳方式進行，留下明確的資金往來紀錄。',
      );
    }
  }

  // 2. 車禍事故
  if (category == '車禍事故') {
    if (title.contains('閃紅') ||
        title.contains('閃黃') ||
        title.contains('路權') ||
        title.contains('號誌')) {
      return const GeneratedArticleDetails(
        keyPoints: [
          '路口閃紅燈車輛代表「支線道」，必須停車再開，禮讓幹道車先行。',
          '閃黃燈車輛代表「幹線道」，行經路口應減速接近，小心通過。',
          '無號誌或閃光路口之肇事責任，主要依路權大小與停讓規定劃分。',
        ],
        section2Title: '二、法律核心解析',
        section2Body:
            '依《道路交通安全規則》第102條規定，車輛行至無號誌或閃光信號路口時，應遵守路權停讓原則。閃光黃燈表示「警告」，車輛應減速接近；閃光紅燈則表示「停車再開」，代表該方向為支線道，車輛必須在路口前完全停止，確認無來車後方可起步。若閃紅燈車未停讓而與閃黃燈車擦撞，閃紅燈車通常會被認定為主要肇事原因，負擔大部分責任。',
        section3Title: '三、實務自保指引',
        section3Body:
            '1. 行經閃光信號路口，不論己方是閃黃燈或閃紅燈，皆應減速，閃紅燈方向務必「輪胎停止運轉」再開。\n2. 發生車禍時，保留車輛行車紀錄器影片，並向警方申請調解或現場初判表。\n3. 若不服警察局的初判表，可自費3000元向車禍鑑定委員會申請「車禍事故鑑定」釐清確切路權。',
      );
    } else if (title.contains('折舊') ||
        title.contains('零件') ||
        title.contains('修車') ||
        title.contains('維修') ||
        title.contains('車損')) {
      return const GeneratedArticleDetails(
        keyPoints: [
          '車禍車損賠償，更換之零件部分在法律上必須扣除折舊額。',
          '鈑金、烤漆與維修工資屬於非零件項目，不計算折舊。',
          '折舊計算標準一般依行政院固定資產耐用年數表（汽車耐用年數5年）。',
        ],
        section2Title: '二、法律核心解析',
        section2Body:
            '依據《民法》第196條及第213條規定，物被毀損者，被害人得請求物被毀損所減少之價額，或請求回復原狀之必要費用。在法院實務判決中，維修更換「全新零件」會被視為使車輛價值增加，因此必須依《行政院固定資產耐用年數表》計算折舊。以汽車耐用年數5年為例，採用定率遞減法計算，超過5年之老車，零件折舊後的殘值通常僅餘約10%，但工資與烤漆等費用則無折舊問題，應全額賠償。',
        section3Title: '三、實務自保指引',
        section3Body:
            '1. 請保養廠開立估價單與發票時，務必請對方將「零件材料費」與「工資、烤漆費」分開列帳。\n2. 與對方談判賠償金額時，應主動扣除零件折舊以求合理和解額度，避免法庭訴訟時負擔更高訴訟成本。\n3. 若己方為受害人，可要求以修復（鈑金）代替更換零件，減少折舊條款對自身求償金額的侵蝕。',
      );
    } else if (title.contains('保險') ||
        title.contains('拒賠') ||
        title.contains('理賠') ||
        title.contains('出險')) {
      return const GeneratedArticleDetails(
        keyPoints: [
          '事故發生後，應於五日內向保險公司申報出險理賠。',
          '必須有警察機關開立之事故登記聯單，保險公司才會受理車損出險。',
          '私下自行和解而未通知保險公司參與，保險公司得不受其約束。',
        ],
        section2Title: '二、法律核心解析',
        section2Body:
            '依《保險法》第90條至第95條及汽車任意險條款，責任保險人在被保險人對第三人有賠償責任時履行賠償。當事故發生，被保險人應在規定期間內（通常為5日內）向保險公司報案出險。更重要的是，在簽署任何和解協議前，必須有保險公司人員參與或同意，若私下簽字答應賠償金額，保險公司依法有權拒絕超額或不合理的理賠金額。',
        section3Title: '三、實務自保指引',
        section3Body:
            '1. 發生車禍不論體傷或車損多輕微，務必報警取得「交通事故登記聯單」。\n2. 撥打保險公司客服電話備案，並取得出險案號，切勿在未通知保險人員前承諾任何賠償。\n3. 請對方將車輛牽至保險公司指定的合作車廠估價，以便保險理賠專員現場勘估與核價。',
      );
    } else if (title.contains('酒駕') ||
        title.contains('YouBike') ||
        title.contains('腳踏車')) {
      return const GeneratedArticleDetails(
        keyPoints: [
          'YouBike等慢車酒駕仍違反道路交通管理處罰條例第73條。',
          '若酒精濃度達每公升0.25毫克以上，同樣觸犯刑法公共危險罪。',
          '酒後騎乘自行車或微型電動二輪車均屬違法行為，切勿心存僥倖。',
        ],
        section2Title: '二、法律核心解析',
        section2Body:
            '許多民眾誤以為只有駕駛汽車或機車才有酒駕處罰，其實《道路交通管理處罰條例》第73條明文規定，慢車（包含腳踏車、YouBike、電動輔助自行車等）駕駛人飲酒後，若吐氣所含酒精濃度超標，將被處以新台幣1200元以上2400元以下罰鍰；拒絕接受測試更會被重罰4800元。若酒精濃度達每公升0.25毫克，因慢車仍屬刑法上的「動力交通工具」範疇，依法仍構成《刑法》第185條之3公共危險罪，將移送法辦。',
        section3Title: '三、實務自保指引',
        section3Body:
            '1. 凡是有飲用酒精飲料（包括啤酒、薑母鴨、藥膳），絕對不要騎乘 YouBike 或任何自行車。\n2. 遇警察攔檢時，應配合進行酒測。若有慢車酒駕情事，除了面臨行政罰鍰外，將會留下公共危險罪之刑事前科。\n3. 聚會後請善用大眾運輸工具、步行、代駕或搭乘計程車回家。',
      );
    } else if (title.contains('肇逃') ||
        title.contains('肇事逃逸') ||
        title.contains('過失傷害')) {
      return const GeneratedArticleDetails(
        keyPoints: [
          '限制肇事逃逸罪最重可處五年有期徒刑，且不以己方有肇責為前提。',
          '車禍導致他人受傷，不論傷勢輕重，均涉犯刑事過失傷害罪。',
          '車禍發生後，留在現場協助並報警是避免肇事逃逸的唯一途徑。',
        ],
        section2Title: '二、法律核心解析',
        section2Body:
            '依《刑法》第185條之4規定，駕駛動力交通工具發生交通事故，致人傷害而逃逸者，處六月以上五年以下有期徒刑。此罪之成立不以「有肇事責任」為前提，只要發生碰撞且對方受傷，駕駛人就有救護與留在現場等候警方處理之義務。另外，車禍導致他人受傷，不論傷勢輕重，即構成《刑法》第284條過失傷害罪，告訴乃論之罪追訴期為六個月。',
        section3Title: '三、實務自保指引',
        section3Body:
            '1. 車禍發生後，即使對方表示「沒事、不用報警」並想離開，也務必在現場報警或要求對方簽寫「和解書」或「放棄追究聲明書」。\n2. 若對方堅持離去，可用手機錄音錄影存證，或主動前往派出所備案，證明自己無逃逸意圖。\n3. 有人受傷時，先撥打119叫救護車，切勿因為害怕或認為自己沒錯而逕自騎車離去。',
      );
    } else {
      return const GeneratedArticleDetails(
        keyPoints: [
          '車禍處理首重「保留現場」與「報警建檔」，攸關後續肇責鑑定。',
          '民事損害賠償範圍包括醫藥費、車損折舊、工作損失與精神慰撫金。',
          '應注意刑事過失傷害罪之六個月告訴乃論追訴期限。',
        ],
        section2Title: '二、法律核心解析',
        section2Body:
            '車禍賠償在法律上屬《民法》第184條之侵權行為損害賠償。受害人得請求因車禍所受之實質損害（如醫療自費項目、看護費、不能工作之薪資損失、車輛維修費用），以及非財產上之損害賠償（即精神慰撫金）。雙方肇事責任比例之劃分，以交通大隊開立之道路交通事故初步分析研判表或鑑定委員會之鑑定意見書為依據，按比例負擔賠償金額。',
        section3Title: '三、實務自保指引',
        section3Body:
            '1. 車禍發生後第一時間拍照記錄兩車相對位置、撞擊點與路況，並將車輛移至安全處避免二次車禍。\n2. 於事故後30日，向承辦警察單位免費申請「道路交通事故初步分析研判表（初判表）」。\n3. 民事損害賠償請求權時效為2年，刑事過失傷害告訴期為6個月，應注意時效並適時申請調解。',
      );
    }
  }

  // 3. 職場權益
  if (category == '職場權益') {
    if (title.contains('LINE') ||
        title.contains('下班') ||
        title.contains('訊息') ||
        title.contains('回覆')) {
      return const GeneratedArticleDetails(
        keyPoints: [
          '下班後主管以 LINE 交辦工作，勞工回覆並提供勞務即屬加班。',
          '加班工時之計算以通訊軟體交辦與交付回覆之時間差為基準。',
          '雇主應記錄勞工實際工作工時，並核實給付延長工時加班費。',
        ],
        section2Title: '二、法律核心解析',
        section2Body:
            '根據勞動部《勞工在非上班時間使用通訊軟體工作指引》，雇主在下班時間使用LINE等通訊軟體交付工作，若勞工於工作時間外實際提供勞務，該時段即視為勞動基準法第24條所規定的延長工作時間（加班）。勞工應自行記錄工作起迄時間，並可截圖通訊軟體對話內容、傳送工作成果之時間點，向雇主申報加班費，雇主應依勞基法規定計給延長工時工資。',
        section3Title: '三、實務自保指引',
        section3Body:
            '1. 截圖保存LINE交辦訊息的發出時間，以及自己完成交辦任務並回覆的回傳時間，作為加班時間計算依據。\n2. 於每個月彙整下班LINE加班紀錄，向公司人事單位申報加班費。\n3. 若公司拒絕發給或要求扣除，可將對話截圖與打卡紀錄遞交地方勞工局申訴，保障自身權益。',
      );
    } else if (title.contains('加班') ||
        title.contains('加班費') ||
        title.contains('補休') ||
        title.contains('休息日')) {
      return const GeneratedArticleDetails(
        keyPoints: [
          '休息日加班工時與工資之計算，適用勞基法第24條第2項之高加成費率。',
          '加班後要換加班費或補休，選擇權完全在於勞工，雇主不得強迫。',
          '補休期限屆滿若未休完，雇主依法仍須折算加班費發還給勞工。',
        ],
        section2Title: '二、法律核心解析',
        section2Body:
            '依據《勞動基準法》第24條規定，雇主延長勞工工作時間者，應加成發給加班費。若是在例假日或休息日出勤，加班工資更有特定的高加成費率。至於加班後轉為「補休」，依勞基法第32條之1規定，必須在「勞工有加班事實後」，由「勞工自主選擇」換取補休，雇主不得片面強制規定「一律僅能補休」。若補休期限屆滿或契約終止而未休完之時數，雇主仍應折算成加班費發給。',
        section3Title: '三、實務自保指引',
        section3Body:
            '1. 確實保留出勤打卡紀錄或公司加班系統申請核准之截圖。\n2. 若公司有強制換補休或將加班時數自動失效之規定，可寫信給人資提出異議以留下書面紀錄。\n3. 如溝通無果，可檢具出勤紀錄及薪資單向勞工局檢舉，雇主將面臨新台幣2萬至100萬元罰鍰。',
      );
    } else if (title.contains('資遣') ||
        title.contains('開除') ||
        title.contains('解雇') ||
        title.contains('預告期') ||
        title.contains('非自願')) {
      return const GeneratedArticleDetails(
        keyPoints: [
          '雇主資遣員工必須符合勞基法第11條之經濟性或業務緊縮事由。',
          '資遣時雇主應依法給付資遣費，並依年資給予法定預告期間或薪資。',
          '員工有權要求雇主開立「非自願離職證明書」以申請失業給付。',
        ],
        section2Title: '二、法律核心解析',
        section2Body:
            '依《勞動基準法》規定，雇主欲終止勞動契約（解雇或資遣），必須具有法定事由。若因經濟原因資遣員工（勞基法第11條），雇主必須依《勞工退休金條例》第12條（勞退新制）給付資遣費（每滿一年發給二分之一個月平均工資之資遣費）。雇主亦應依勞基法第16條給予預告期間，若未給予預告期，則須支付預告期間工資，並開立非自願離職證明。',
        section3Title: '三、實務自保指引',
        section3Body:
            '1. 遇到資遣時，絕對不要隨意簽署「自願離職同意書」或「協議離職書」，否則將喪失請領資遣費及失業給付之權利。\n2. 當場要求雇主開立載明資遣原因（如勞基法第11條第4款）的非自願離職證明書。\n3. 若資遣費計算有誤或雇主拒絕開立證明，應立即向公司所在地之勞工局申請勞資爭議調解。',
      );
    } else if (title.contains('競業禁止')) {
      return const GeneratedArticleDetails(
        keyPoints: [
          '離職後競業禁止條款必須符合勞基法第9條之1規定之四項要件。',
          '雇主若未給予勞工合理補償（至少為原月薪之半數），該條款無效。',
          '競業禁止之期間最長不得超過二年，且限制範圍應合理。',
        ],
        section2Title: '二、法律核心解析',
        section2Body:
            '依《勞動基準法》第9條之1規定，雇主與勞工約定離職後競業禁止，必須符合：雇主有應受保護之正當營業利益、勞工職位能接觸該機密、限制之期間、區域及職業活動範圍合理，且最重要的一點是：「雇主對勞工因不從事競業行為所受之損失，應有合理補償（通常為月薪半數以上）」。如果合約中約定了離職不能去同行，卻沒有約定按月發給合理的補償金，則該競業禁止條款在法律上完全無效。',
        section3Title: '三、實務自保指引',
        section3Body:
            '1. 重新檢視當初入職時簽署的勞動契約或保密協議，確認競業禁止條款是否載明補償金額度。\n2. 若離職後公司未按月撥付協議中的補償金，可視為公司違約，條款自動失效。\n3. 面對公司的警告信或法律威脅，可諮詢勞動法令專家，確認條款是否因未給予合理補償而無效，以利正常求職。',
      );
    } else if (title.contains('扣薪') ||
        title.contains('罰款') ||
        title.contains('遲到')) {
      return const GeneratedArticleDetails(
        keyPoints: [
          '勞基法第26條明文規定雇主不得預扣勞工工資作為賠償費用。',
          '遲到僅得依比例扣除未提供勞務時間之工資，不得翻倍懲罰。',
          '若員工造成公司損害，賠償金額應由雙方協議，雇主不得逕自扣薪。',
        ],
        section2Title: '二、法律核心解析',
        section2Body:
            '我國《勞動基準法》第26條規定，雇主不得預扣勞工工資作為違約金或賠償費用。意思是，即便勞工因工作疏失損壞公司設備或造成財物損失，雇主也必須先全額發給薪資，再透過協商或法律訴訟途徑要求勞工賠償，絕對不能直接從薪水袋中逕行扣除。此外，遲到扣薪僅能就遲到分鐘數進行「等比例折算扣除」，若遲到10分鐘卻扣一小時薪水或加罰罰金，皆屬違法行為。',
        section3Title: '三、實務自保指引',
        section3Body:
            '1. 遇到公司因損害或遲到扣除工資時，應要求公司提供詳細薪資明細單與扣款依據。\n2. 向主管或HR表明依勞基法第26條規定，公司不得逕行扣薪，並保留溝通的Email或LINE對話。\n3. 若公司態度強硬，可將薪資明細、出勤紀錄等事證提交給地方勞工局，檢舉雇主預扣工資之違法行為。',
      );
    } else {
      return const GeneratedArticleDetails(
        keyPoints: [
          '勞動基準法屬於社會法與強行法，位階高於個人勞動契約。',
          '勞資雙方協議若有違反勞基法強制規定之條款，該部分一律無效。',
          '遇有勞資糾紛，應優先保留打卡紀錄、薪資單與業務溝通事證。',
        ],
        section2Title: '二、法律核心解析',
        section2Body:
            '中華民國《勞動基準法》旨在規定勞動條件最低標準，保障勞工權益。勞動契約之條款若低於勞基法之規定者，依勞基法第1條規定，該約定無效，應一律以勞基法之最低標準代替之。常見的雇主違法態樣包括：未足額投保勞健保、超時加班未給予加班費、未依法給予特別休假等。勞工在面臨自身權益受損時，受法律保護之權利並不因簽署過合約而喪失。',
        section3Title: '三、實務自保指引',
        section3Body:
            '1. 平時即養成備份個人打卡紀錄、班表、薪資條以及勞動合約的習慣。\n2. 遇到不合理的勞動條件調動或扣薪，應當下以文字（Email或通訊軟體）明確表達異議並保留紀錄。\n3. 當權益受侵害且內部溝通無效時，可直接至勞動部或地方勞工局網站線上申訴，或申請「勞資爭議調解」。',
      );
    }
  }

  // 4. 網購消費
  if (category == '網購消費') {
    if (title.contains('鑑賞期') ||
        title.contains('退貨') ||
        title.contains('代購') ||
        title.contains('海外')) {
      return const GeneratedArticleDetails(
        keyPoints: [
          '消保法第19條買受人享有通訊交易7天無條件解除契約權。',
          '海外代購若屬常態營業之企業經營者，除特定排除商品外依然適用。',
          '退貨時消費者無須負擔退回運費，且賣家不得收取整新費。',
        ],
        section2Title: '二、法律核心解析',
        section2Body:
            '根據《消費者保護法》第19條規定，通訊交易（如網路購物、電視購物）之消費者，得於收受商品或接受服務後七日內，退回商品或以書面通知方式解除契約，無須說明理由及負擔 any 費用或對價。即使是海外代購業者，只要是經常性銷售商品的企業經營者，除非屬於消保法合理例外情事（如客製化給付、易腐爛商品、拆封後之影音等），否則依然適用7天鑑賞期退貨。賣家標示「售出概不退換」等條款依法無效。',
        section3Title: '三、實務自保指引',
        section3Body:
            '1. 收到商品後7天內，若決定退貨，以書面或通訊軟體明確向賣家表示：「我要主張消保法第19條7天鑑賞期退貨」。\n2. 將退貨商品連同原包裝、贈品妥善封存，並拍照留下寄回的物流單據。\n3. 若賣家推諉拒絕或要求負擔海外運費，可至行政院消費者保護會（消保會）網站進行線上申訴。',
      );
    } else if (title.contains('瑕疵') ||
        title.contains('壞掉') ||
        title.contains('保固') ||
        title.contains('瑕疵擔保')) {
      return const GeneratedArticleDetails(
        keyPoints: [
          '出賣人依民法第354條負有物之瑕疵擔保責任，確保商品效用完好。',
          '買受人發現商品瑕疵，得依法請求解除契約、退貨或減少價金。',
          '拆箱點收時錄影存證，是舉證瑕疵責任歸屬的最佳方式。',
        ],
        section2Title: '二、法律核心解析',
        section2Body:
            '依據《民法》第354條規定，賣家應擔保出賣之物於交付時無減少價值或預定效用之瑕疵。若買家收到商品發現瑕疵（如損壞、規格不符），可依《民法》第359條規定，請求解除契約（全額退款）或請求減少價金。若是網路購物，消保法亦保障商品與廣告宣傳相符，若賣家出貨瑕疵品，必須全額退換，不得以「拆封後無法退換」為由規避瑕疵擔保責任。',
        section3Title: '三、實務自保指引',
        section3Body:
            '1. 網購高價或易碎商品，在開箱拆封時務必全程錄影，並將包裹標籤與商品外觀拍清楚。\n2. 發現瑕疵後立即以書面通知賣家，並提供開箱錄影畫面以釐清責任。\n3. 依民法規定，買家應於發現瑕疵後即時通知賣家，避免因拖延而被視為承認承受該商品。',
      );
    } else if (title.contains('標錯價') ||
        title.contains('取消訂單') ||
        title.contains('不發貨')) {
      return const GeneratedArticleDetails(
        keyPoints: [
          '網路下單刷卡成功或系統發出訂單確認信，契約即告成立。',
          '契約成立後，賣家不得單方面因標錯價而拒絕出貨或取消訂單。',
          '消保會規範防範商家任意取消訂單，保障消費者信賴權益。',
        ],
        section2Title: '二、法律核心解析',
        section2Body:
            '依據經濟部制定之《零售業等網路交易定型化契約應記載及不得記載事項》規定，消費者下單後，企業經營者對契約成立與否有確認義務。但如果交易系統已自動回覆接受訂單、確定刷卡扣款成功，契約即已合法成立。賣家事後發現標錯價格，不得單方面片面更改契約或直接取消訂單，必須依合約內容履行出貨義務，除非能舉證消費者是惡意（如集體掃貨）權利濫用，否則法理上商家應承擔標價失誤之風險。',
        section3Title: '三、實務自保指引',
        section3Body:
            '1. 完成訂單後，將訂單確認頁面、刷卡扣款成功簡訊或電子郵件等畫面截圖留存。\n2. 若商家以標錯價為由片面取消訂單或不出貨，可致電消保專線1950，或上網向消保官申訴，要求依契約出貨。\n3. 如果商家提出替代補償方案（如折價券），消費者可自行評估是否接受和解，或堅持依法要求履行契約。',
      );
    } else {
      return const GeneratedArticleDetails(
        keyPoints: [
          '消費關係受消費者保護法特別規範，保障弱勢消費者之權利。',
          '定型化契約條款若有疑義，應作有利於消費者之解釋。',
          '消費糾紛可尋求消保官、消基會或各縣市調解委員會協助。',
        ],
        section2Title: '二、法律核心解析',
        section2Body:
            '《消費者保護法》是我國保護消費者權益之核心法規。當消費者與企業經營者因商品或服務發生爭議時，消保法提供了多元且便利的救濟程序。此外，消保法第11條規定，企業經營者與消費者訂立定型化契約前，應給予合理之審閱期；契約條款如有疑義時，應為有利於消費者之解釋。任何以定型化契約規避法律責任、不合理加重消費者負擔之條款，均屬無效。',
        section3Title: '三、實務自保指引',
        section3Body:
            '1. 網購交易前，應優先選擇信譽良好、標示清晰且提供完整聯絡資訊之平台與賣家。\n2. 遇到交易糾紛，先與賣家書面溝通保留對話紀錄；溝通未果，可向行政院消保會申訴。\n3. 善用消保官之調解機制，多數消費爭議皆能在訴訟前透過消保程序達成和解。',
      );
    }
  }

  // 5. 個資隱私
  if (category == '個資隱私') {
    if (title.contains('推銷') ||
        title.contains('電話') ||
        title.contains('行銷') ||
        title.contains('廣告')) {
      return const GeneratedArticleDetails(
        keyPoints: [
          '個資法保障民眾有權隨時拒絕企業之行銷利用。',
          '當事人表示拒絕接受行銷後，業者應立即停止使用其個人資料。',
          '業者進行行銷時，應主動告知個資來源及當事人得行使之權利。',
        ],
        section2Title: '二、法律核心解析',
        section2Body:
            '依我國《個人資料保護法》第20條第2項及第3項規定，非公務機關利用個人資料行使特定目的外之利用時，應經當事人同意。更為關鍵的是，當事人表示拒絕接受行銷時，業者應即停止利用其個人資料進行行銷，且於首次行銷時，應提供當事人表示拒絕接受行銷之方式。若業者在您口頭或書面拒絕後仍繼續撥打推銷電話，即屬違反個資法之非法利用行為。',
        section3Title: '三、實務自保指引',
        section3Body:
            '1. 接到推銷電話時，當場以錄音形式向對方口頭聲明：「我拒絕接受此行銷，請依法自你們的資料庫中刪除我的電話與個資」。\n2. 詢問對方是哪家公司、其姓名或代號，並詢問其個資獲取來源。\n3. 若對方仍不理會而持續打來推銷，可檢具電話通聯紀錄及拒絕行銷之錄音檔，向個資主管機關或消保官提出檢舉。',
      );
    } else if (title.contains('洩漏') ||
        title.contains('公審') ||
        title.contains('公開') ||
        title.contains('散布') ||
        title.contains('個資')) {
      return const GeneratedArticleDetails(
        keyPoints: [
          '散布或公開他人身分證、電話等個人隱私資料，構成非法利用個資。',
          '意圖損害他人利益而洩漏個資，將面臨最重五年有期徒刑之刑責。',
          '被害人得依法請求精神慰撫金及名譽損害之民事損害賠償。',
        ],
        section2Title: '二、法律核心解析',
        section2Body:
            '個人資料保護法嚴格限制個人資料之收集、處理與利用。依個資法第41條規定，意圖為自己或第三人不法之利益，或損害他人之利益，而違反規定非法利用或洩漏個人資料，致生損害於他人者，處五年以下有期徒刑，得併科新台幣100萬元以下罰金。此外，在網路上公開他人個資（如電話、地址）進行網路公審，亦涉犯《刑法》第310條誹謗罪與侵害《民法》第195條隱私權之侵權行為。',
        section3Title: '三、實務自保指引',
        section3Body:
            '1. 發現個人資料被他人公開或轉發公審時，立即進行網頁截圖、錄影備份，並記錄該篇文章之網址與發布時間。\n2. 截圖存證後，前往警察局報案，控告對方違反個資法及妨害名譽罪。\n3. 亦可向法院提起民事訴訟，請求對方賠償名譽及隱私權受損的精神慰撫金，並要求刪除文章。',
      );
    } else if (title.contains('監視器') ||
        title.contains('人臉') ||
        title.contains('辨識') ||
        title.contains('錄影')) {
      return const GeneratedArticleDetails(
        keyPoints: [
          '人臉特徵、指紋等生物特徵資料，屬於個資法保護之個人資料。',
          '大樓裝設監視器或指紋辨識，必須符合維護安全之特定合理目的。',
          '拍攝範圍若正對他人私人空間，涉犯刑法妨害秘密罪。',
        ],
        section2Title: '二、法律核心解析',
        section2Body:
            '依《個人資料保護法》規定，個人的指紋、人臉特徵等生理特徵，皆屬於個人資料之範疇。大樓管委會或商家若強行收集住戶之人臉或指紋資料（如門禁系統），必須有合法的收集目的，且須經當事人明確同意，若未同意應提供其他替代方案（如感應卡）。此外，若裝設監視器之拍攝角度直接拍攝鄰居室內之私人生活起居，則會觸犯《刑法》第315條之1妨害秘密罪，被害人得訴請拆除。',
        section3Title: '三、實務自保指引',
        section3Body:
            '1. 社區若要求人臉或指紋拍照建檔，有權主張個資自主權拒絕，並要求管委會提供實體磁卡或鑰匙等替代進出方案。\n2. 發現鄰居或對面住戶之監視器鏡頭角度正對自家大門內部或窗戶，先拍照記錄該監視器裝設位置及拍攝方向。\n3. 可報警請警方到場協調，或以侵害隱私權及妨害秘密為由，向法院聲請強制排除妨礙（調整角度或拆除）並請求賠償。',
      );
    } else {
      return const GeneratedArticleDetails(
        keyPoints: [
          '隱私權為我國憲法保障之基本權利，任何個人隱私非依法不得侵害。',
          '非公務機關收集、處理個資，必須具有特定目的與法定要件。',
          '當事人對其個人資料享有查詢、更正、刪除及停止利用之權利。',
        ],
        section2Title: '二、法律核心解析',
        section2Body:
            '《個人資料保護法》旨在規範個人資料之收集、處理及利用，以避免人格權受侵害。任何人或機構欲收集他人姓名、身分證字號、電話等個人資料，必須有明確、合法的特定目的（如履行合約、法定義務等），並符合個資法規定的必要範圍。依個資法第3條規定，當事人對於其個人資料享有查詢、請求閱覽、請求更正以及請求刪除之法定權利，任何條約不得任意剝奪之。',
        section3Title: '三、實務自保指引',
        section3Body:
            '1. 註冊網路會員或填寫問卷時，仔細閱讀個資授權條款，避免勾選同意提供個資給第三方行銷利用。\n2. 若懷疑自身個資遭特定公司濫用，可寄發書面或Email客服，依法行使個資查詢權與刪除權。\n3. 當個資隱私權遭受惡意侵害（如個資外洩造成財務損失），可檢具證據向消保會申訴或向法院提起損害賠償訴訟。',
      );
    }
  }

  // Fallback
  return const GeneratedArticleDetails(
    keyPoints: [
      '日常生活處處皆涉及法律行為與約定，了解法規才能有效預防糾紛。',
      '契約條款與法令強制規定牴觸者無效，一律以法律規定為準。',
      '遇到法律爭議，應優先保持冷靜、收集書面事證並尋求專業協助。',
    ],
    section2Title: '二、法律核心解析',
    section2Body:
        '本案例涉及我國現行民事或行政法規之規範。依法律行為成立要件，雙方之權利與義務受法令之約束。若對方之要求違反我國法令之強制或禁止規定，或有失公平、違反誠信原則，該要求在法律上將不予承認，當事人有權予以拒絕。',
    section3Title: '三、實務自保指引',
    section3Body:
        '1. 發生的第一時間以文字、照片或錄音方式留下完整記錄，防範事後各執一詞。\n2. 對於不合常理的要求，先查閱相關法令或向專業法律諮詢管道求證，切勿盲目答應。\n3. 可向各地方政府提供的免費法律諮詢服務（如法律扶助基金會、各區公所）尋求進一步的專業指引。',
  );
}

Map<String, dynamic>? _generateQuiz(String category, String title) {
  // 1. 租屋糾紛
  if (category == '租屋糾紛') {
    if (title.contains('押金')) {
      return {
        'question': '房客退租時，房東以牆壁自然折舊變黃為由，扣除一萬元押金，請問這合理嗎？',
        'options': [
          'A. 合理，押金就是用來回復房屋至全新狀態的。',
          'B. 不合理，自然折舊屬於正常使用，費用應由房東負擔，不得任意扣押金。',
          'C. 合理，只要合約沒寫明折舊，房東就可以自由扣款。'
        ],
        'correctIndex': 1,
        'explanation': '依民法與定型化契約規定，自然老化與合理使用之磨損不構成損害賠償事由，房東應返還全額押金。',
      };
    } else if (title.contains('電費') ||
        title.contains('水電') ||
        title.contains('每度')) {
      return {
        'question': '房東在租約中規定電費每度收取固定 8 元，且不論夏月與否皆同，請問此約定是否有效？',
        'options': [
          'A. 有效，契約自由原則高於一切行政規範。',
          'B. 無效，113年7月電費新制規定，收費不得超過台電當期每度平均電價。',
          'C. 有效，只要房客簽名同意即不受新法保護。'
        ],
        'correctIndex': 1,
        'explanation': '113年7月新版租賃定型化契約規定，房東收取的電費額度不得超過台電當期帳單之平均每度電價，超收屬違法無效。',
      };
    } else if (title.contains('修繕') ||
        title.contains('壞了') ||
        title.contains('維修') ||
        title.contains('天花板') ||
        title.contains('滲水') ||
        title.contains('熱水器') ||
        title.contains('自行找水電')) {
      return {
        'question': '租屋處熱水器因非人為老化壞掉，催告房東限期修繕但房東不予理會，房客該如何處置？',
        'options': [
          'A. 只能自認倒楣，自己花錢修繕且不得向房東索取費用。',
          'B. 得依法自行僱工修繕，並將該維修費用自次月租金中扣除。',
          'C. 直接拒絕支付下個月的全部租金以示抗議。'
        ],
        'correctIndex': 1,
        'explanation': '民法第430條規定，承租人定相當期限催告修繕而房東逾期未修，承租人得自行修繕並自租金扣除其費用。',
      };
    } else if (title.contains('解約') ||
        title.contains('提前') ||
        title.contains('違約金')) {
      return {
        'question': '合約中規定房客若提前解約，必須賠償房東三個月租金作為違約金，此約定效力為何？',
        'options': [
          'A. 完全有效，違約金金額由雙方合意即可，法律不予限制。',
          'B. 部分無效，住宅租賃定型化契約規定，提前解約之違約金最高不得超過一個月租金。',
          'C. 完全無效，只要提前解約，房客就不需要支付任何違約金。'
        ],
        'correctIndex': 1,
        'explanation': '依內政部定型化契約規範，提前解約的違約金上限為一個月租金，超過部分依法無效。',
      };
    } else if (title.contains('報稅') ||
        title.contains('申報') ||
        title.contains('戶籍') ||
        title.contains('遷戶籍') ||
        title.contains('扣除額')) {
      return {
        'question': '房東在合約中加註「房客不得申報租金扣除額及遷入戶籍」，否則須賠償稅金，此條款有效嗎？',
        'options': [
          'A. 有效，手寫加註條款效力高於定型化契約範本。',
          'B. 無效，此條款限制房客法定權益，違反消保法而無效，房客仍可依法申報。',
          'C. 有效，因為房東有權保護自己不被課徵高額房東稅。'
        ],
        'correctIndex': 1,
        'explanation': '定型化契約明文規定不得限制承租人申報租金扣除額或遷入戶籍，違反此規定之約定無效。',
      };
    } else if (title.contains('折舊') ||
        title.contains('全新') ||
        title.contains('牆壁') ||
        title.contains('污漬') ||
        title.contains('耗材')) {
      return {
        'question': '房客不慎弄壞了租屋處的中古流理台，房東要求賠償一組全新的流理台，合理嗎？',
        'options': [
          'A. 合理，弄壞東西就要以全新相同規格的物品賠償。',
          'B. 不合理，賠償應以「回復原狀」為原則，且流理台是中古品，計算賠償時必須扣除折舊額。',
          'C. 合理，房東有權要求最完美的維護狀態。'
        ],
        'correctIndex': 1,
        'explanation': '損害賠償以回復原狀為原則，若以新品替換舊品，應依行政院固定資產耐用年數折舊公式扣除折舊殘值。',
      };
    } else if (title.contains('買賣不破租賃') || title.contains('賣掉了')) {
      return {
        'question': '租期內房東將房屋賣給新屋主，新屋主表示因自住需求，要求房客於下個月限期搬離，合理嗎？',
        'options': [
          'A. 不合理，依「買賣不破租賃」原則，新屋主必須繼承原租約至租期屆滿。',
          'B. 合理，所有權大於承租權，新屋主既已取得產權即可驅離房客。',
          'C. 合理，但新屋主必須補償房客搬家費後方可解約。'
        ],
        'correctIndex': 0,
        'explanation': '民法第425條買賣不破租賃原則，原租賃契約對於新所有權人（新屋主）繼續存在，保障房客居住權。',
      };
    } else {
      return {
        'question': '租賃契約中若有條款違反了內政部公告的住宅租賃定型化契約強制規定，該條款效力為何？',
        'options': [
          'A. 依然有效，以雙方簽字蓋章的合約書內容為準。',
          'B. 無效，違反定型化契約強制規定之條款自始無效，直接回歸法令規定處理。',
          'C. 整個契約都隨之完全無效。'
        ],
        'correctIndex': 1,
        'explanation': '違反內政部應記載及不得記載事項之約定無效，該部分直接適用法定定型化契約規範。',
      };
    }
  }

  // 2. 車禍事故
  if (category == '車禍事故') {
    if (title.contains('閃紅') ||
        title.contains('閃黃') ||
        title.contains('路權') ||
        title.contains('號誌')) {
      return {
        'question': '行經無號誌路口，己方為閃紅燈，對方為閃黃燈，兩車發生擦撞，誰的停讓義務較高？',
        'options': [
          'A. 雙方義務相同，應各自注意路口狀況。',
          'B. 閃紅燈代表支線道，有「停車再開」並禮讓閃黃燈幹線道先行之絕對義務，責任通常較重。',
          'C. 閃黃燈車速通常較快，應負主要避讓責任。'
        ],
        'correctIndex': 1,
        'explanation': '道路交通安全規則第102條，閃紅燈為支線道，應減速接近，在路口前暫停，禮讓幹線道車優先通行。',
      };
    } else if (title.contains('折舊') ||
        title.contains('零件') ||
        title.contains('修車') ||
        title.contains('維修') ||
        title.contains('車損')) {
      return {
        'question': '車禍中己方為受害人，對方的五年以上老車受損，法院在審理零件賠償時會如何計算？',
        'options': [
          'A. 一律按全新零件價格進行全額賠償。',
          'B. 零件更換會依耐用年數計算折舊，若超過耐用年數（如5年），零件殘值通常僅餘10%。',
          'C. 超過5年的車輛，對方無須賠償任何維修費。'
        ],
        'correctIndex': 1,
        'explanation': '物遭損害請求更換新品零件，實務上應予折舊扣除；工資與烤漆則不折舊應全額理賠。',
      };
    } else if (title.contains('保險') ||
        title.contains('拒賠') ||
        title.contains('理賠') ||
        title.contains('出險')) {
      return {
        'question': '車禍擦撞後，雙方當下口頭約定私下和解並離去，事後己方欲向保險公司申請車損理賠，會面臨什麼狀況？',
        'options': [
          'A. 正常出險，保險公司會直接依保單給付維修費。',
          'B. 保險公司會以無警方事故紀錄、且未經保險公司參與私自和解為由，拒絕受理或拒賠。',
          'C. 保險公司會代為起訴對方求償。'
        ],
        'correctIndex': 1,
        'explanation': '申請理賠需警方開立之登記聯單，且依保險契約，私下和解而未通知保險公司參與者，保險人得不受其拘束。',
      };
    } else if (title.contains('酒駕') ||
        title.contains('YouBike') ||
        title.contains('腳踏車')) {
      return {
        'question': '飲酒後騎乘 YouBike 共享單車，若酒測值超標，會面臨何種法律處罰？',
        'options': [
          'A. 完全無罰，因自行車不屬於動力交通工具，不適用酒駕規定。',
          'B. 會被處以1200元至2400元罰鍰，且若酒測值達0.25毫克以上，仍會構成刑法公共危險罪。',
          'C. 僅會被 YouBike 停權，無須繳納任何罰鍰。'
        ],
        'correctIndex': 1,
        'explanation': '自行車等慢車酒駕有行政罰鍰；且慢車在刑法上仍屬動力交通工具，吐氣酒精濃度達0.25毫克仍會移送公共危險罪。',
      };
    } else if (title.contains('肇逃') ||
        title.contains('肇事逃逸') ||
        title.contains('過失傷害')) {
      return {
        'question': '發生車禍擦撞且對方有受傷，即便當下自認無肇事責任，可以直接騎車離去嗎？',
        'options': [
          'A. 可以，只要對方沒有攔阻，且自己沒有過失即可離開。',
          'B. 不可以，只要車禍致人受傷而逃逸，即觸犯最重可處五年有期徒刑之刑事肇事逃逸罪。',
          'C. 可以，但必須事後打電話給警察局告知剛才的碰撞地點。'
        ],
        'correctIndex': 1,
        'explanation': '刑法第185條之4肇事逃逸罪，不以有肇責為成立要件，只要發生車禍致人受傷，未留現場協助即屬違法。',
      };
    } else {
      return {
        'question': '車禍發生後，受害人若要向肇事者提起刑事「過失傷害罪」告訴，其法定追訴期限為多久？',
        'options': ['A. 車禍發生後二年內。', 'B. 車禍發生後六個月內。', 'C. 沒有限制，隨時都可以提起告訴。'],
        'correctIndex': 1,
        'explanation': '過失傷害罪屬於告訴乃論之罪，告訴乃論之罪起訴期限為六個月。',
      };
    }
  }

  // 3. 職場權益
  if (category == '職場權益') {
    if (title.contains('LINE') ||
        title.contains('下班') ||
        title.contains('訊息') ||
        title.contains('回覆')) {
      return {
        'question': '主管在下班時間透過 LINE 交辦緊急修改任務，員工回覆並花費兩小時完成，此時間是否算加班？',
        'options': [
          'A. 不算，因為非在公司辦公室內工作，且非正式打卡時間。',
          'B. 算加班，主管下班訊息交辦實質業務且員工實際提供勞務者，依法應計給加班費。',
          'C. 不算，除非主管在 LINE 訊息中明確寫出「這算加班」四個字。'
        ],
        'correctIndex': 1,
        'explanation': '依勞動部指引，雇主在工作時間外以通訊軟體交辦工作，且勞工實際提供勞務者，即屬加班，應計給加班費。',
      };
    } else if (title.contains('加班') ||
        title.contains('加班費') ||
        title.contains('補休') ||
        title.contains('休息日')) {
      return {
        'question': '公司要求員工在「休息日」加班，並片面規定所有加班時數只能換取補休，不能要求加班費，合法嗎？',
        'options': [
          'A. 合法，雇主有權調配公司預算，以補休代替加班費。',
          'B. 不合法，加班後選擇換取加班費或補休之選擇權在於「勞工」，雇主不得單方面片面強制作替換。',
          'C. 合法，只要有給予補休，即符合最低勞動基準標準。'
        ],
        'correctIndex': 1,
        'explanation': '勞基法第32條之1規定，加班後轉為補休，必須在加班事實發生後，由勞工自主選擇，雇主不可擅自片面強制規定。',
      };
    } else if (title.contains('資遣') ||
        title.contains('開除') ||
        title.contains('解雇') ||
        title.contains('預告期') ||
        title.contains('非自願')) {
      return {
        'question': '公司以業績不好為由突然要求員工明天不用來上班，並拒絕開立非自願離職證明，此做法合法嗎？',
        'options': [
          'A. 合法，公司只要給付當月薪資，即可隨時終止勞動契約。',
          'B. 不合法，資遣必須符合勞基法第11條法定事由，且應給付資遣費、法定預告期或工資，並開立非自願離職證明。',
          'C. 合法，只要是試用期過後的員工，公司皆可隨時開除。'
        ],
        'correctIndex': 1,
        'explanation':
            '雇主資遣員工需符合勞基法法定經濟或業務縮減事由，且須發給資遣費、依年資給予預告期或工資，並開立非自願離職證明。',
      };
    } else if (title.contains('競業禁止')) {
      return {
        'question': '離職合約規定限制離職後兩年內不得進入同業工作，但完全沒有給予任何離職補償金，此條款有效嗎？',
        'options': [
          'A. 有效，只要當初入職有簽署合約，離職就必須履行競業禁止義務。',
          'B. 無效，依法雇主若未提供合理之競業禁止代價補償（月薪半數以上），該競業禁止約定無效。',
          'C. 有效，但限制年限應縮短為一年。'
        ],
        'correctIndex': 1,
        'explanation': '勞基法第9條之1，競業禁止條款必須給予勞工合理之月薪半數以上資金補償，未給予補償者，競業禁止條款無效。',
      };
    } else if (title.contains('扣薪') ||
        title.contains('罰款') ||
        title.contains('遲到')) {
      return {
        'question': '員工遲到15分鐘，公司於薪資單中直接扣除半天薪水作為懲罰性罰款，此做法合法嗎？',
        'options': [
          'A. 合法，公司規章有明訂遲到罰則者，員工應遵守。',
          'B. 不合法，勞基法第26條規定不得預扣工資，遲到僅得依比例扣除未提供勞務時間的工資，不得翻倍超額扣薪。',
          'C. 合法，只要遲到就是違反工作守則，扣款金額由公司決定。'
        ],
        'correctIndex': 1,
        'explanation': '遲到扣薪僅能依遲到分鐘數之比例扣除，超額扣除或直接扣半天工資已屬違反勞基法第26條預扣工資之強制規定。',
      };
    } else {
      return {
        'question': '勞動契約中，若約定的福利或基本工資低於勞動基準法之最低法定標準，該約定效力為何？',
        'options': [
          'A. 依然有效，以雙方合意簽署的契約條款為準。',
          'B. 無效，低於勞基法最低標準之約定一律無效，應直接適用勞基法規定。',
          'C. 整個勞動合約都隨之完全無效，勞雇關係不存在。'
        ],
        'correctIndex': 1,
        'explanation': '勞基法為強行法與最低勞動條件標準，任何低於此標準之勞資協議部分均屬無效，應由勞基法最低標準自動取代之。',
      };
    }
  }

  // 4. 網購消費
  if (category == '網購消費') {
    if (title.contains('鑑賞期') ||
        title.contains('退貨') ||
        title.contains('代購') ||
        title.contains('海外')) {
      return {
        'question': '在網路商城購買了一件常規代購商品，收到後因尺寸不合想退貨，賣家稱「代購售出概不退換」拒絕，合理嗎？',
        'options': [
          'A. 合理，海外代購商品一律不適用消費者保護法之規定。',
          'B. 不合理，消保法第19條規定通訊交易享有7天無條件退貨權，一般常態代購仍屬企業經營，不得任意排除。',
          'C. 合理，因為商品已經拆封，就自動失去退換貨權利。'
        ],
        'correctIndex': 1,
        'explanation': '通訊交易消費者享有7天無條件解除契約退貨權。常態代購業者若為企業經營者，除特定排除商品外仍適用鑑賞期。',
      };
    } else if (title.contains('瑕疵') ||
        title.contains('壞掉') ||
        title.contains('保固') ||
        title.contains('瑕疵擔保')) {
      return {
        'question': '網購收到商品，發現外殼有明顯破裂裂痕，商家要求消費者必須負擔寄回換貨的運費，合理嗎？',
        'options': [
          'A. 合理，退換貨運費一律由消費者自行負擔。',
          'B. 不合理，賣家應負物之瑕疵擔保責任，且消保法規定解除契約退貨，消費者無須負擔任何運費或對價。',
          'C. 合理，除非有加購保固險，否則運費應各付一半。'
        ],
        'correctIndex': 1,
        'explanation': '依消保法第19條與民法瑕疵擔保責任，消費者因瑕疵或主張鑑賞期退貨，無須負擔任何運費、手續費等費用。',
      };
    } else if (title.contains('標錯價') ||
        title.contains('取消訂單') ||
        title.contains('不發貨')) {
      return {
        'question': '在購物網看到標錯價格耳機為 100 元（原價 5000 元），下單且刷卡成功。商家發現後片面取消訂單，合法嗎？',
        'options': [
          'A. 合法，商家標錯價屬於意思表示錯誤，可隨時撤銷訂單。',
          'B. 不合法，刷卡成功且系統確認訂單後，契約即告成立，商家有依約出貨義務，不得單方面無故取消。',
          'C. 合法，只要商家願意退回刷卡金額，即可無條件解除合約。'
        ],
        'correctIndex': 1,
        'explanation': '依網路交易定型化契約應記載事項，交易契約一旦成立，賣家應履行出貨義務，不得以標錯價為由片面解約。',
      };
    } else {
      return {
        'question': '消保法第19條規定的網路購物「7天鑑賞期」，其無條件解除契約退貨之費用，應由誰負擔？',
        'options': [
          'A. 由消費者負擔退回之郵資與手續費。',
          'B. 由企業經營者（賣家）全額負擔退回商品之運費與相關費用，消費者無須支付任何對價。',
          'C. 由買賣雙方平均分攤運費。'
        ],
        'correctIndex': 1,
        'explanation': '消費者依消保法第19條退回商品，無須說明理由及負擔任何費用或對價，退回之費用全由企業經營者負擔。',
      };
    }
  }

  // 5. 個資隱私
  if (category == '個資隱私') {
    if (title.contains('推銷') ||
        title.contains('電話') ||
        title.contains('行銷') ||
        title.contains('廣告')) {
      return {
        'question': '接到某公司精準推銷電話，當下口頭明確表示拒絕接受行銷，但該公司一週後再次打來，是否違法？',
        'options': [
          'A. 不違法，電話推銷屬於合法的商業行銷活動。',
          'B. 違法，個資法規定，當事人一旦表示拒絕接受行銷後，業者應立即停止利用其個資進行行銷，違反者可依法裁罰。',
          'C. 不違法，除非寫存證信函拒絕，否則口頭拒絕無效。'
        ],
        'correctIndex': 1,
        'explanation': '個資法第20條規定，當事人表示拒絕接受行銷時，業者應即停止利用其個人資料進行行銷，否則即構成違法利用個資。',
      };
    } else if (title.contains('洩漏') ||
        title.contains('公審') ||
        title.contains('公開') ||
        title.contains('散布') ||
        title.contains('個資')) {
      return {
        'question': '商家因與顧客有交易糾紛，憤而在網路上公開顧客的真實姓名、手機號碼進行爆料公審，此行為合法嗎？',
        'options': [
          'A. 合法，這是維護商家商譽、警示其他店家的正當言論自由範圍。',
          'B. 違法，未經同意散布或公開他人隱私資料，侵害個資法與隱私權，最重可處五年有期徒刑並須負民事賠償責任。',
          'C. 合法，只要糾紛屬實，即可公開個資以明是非。'
        ],
        'correctIndex': 1,
        'explanation': '未經當事人同意且無特定目的，惡意公開散布他人隱私資料，構成非法利用與外洩個資，需負擔嚴重的民刑事責任。',
      };
    } else if (title.contains('監視器') ||
        title.contains('人臉') ||
        title.contains('辨識') ||
        title.contains('錄影')) {
      return {
        'question': '鄰居在大門上方裝設監視器，鏡頭角度剛好可以直接拍攝到己方屋內起居生活，此舉合法嗎？',
        'options': [
          'A. 合法，鄰居裝設監視器是在其私人產產權範圍內防盜。',
          'B. 不合法，監視器直接拍攝他人私人起居空間，侵害隱私權，且涉犯刑法妨害秘密罪，可訴請調整鏡頭或拆除。',
          'C. 合法，只要鄰居沒有將影像公開發布到網路上即可。'
        ],
        'correctIndex': 1,
        'explanation': '無故以錄影記錄他人非公開之活動，或監視鏡頭正對他人私密居住空間，構成刑法第315條之1妨害秘密罪。',
      };
    } else {
      return {
        'question': '依個人資料保護法第3條規定，當事人對於其被收集的個人資料，不享有以下哪項法定權利？',
        'options': [
          'A. 請求查詢、閱覽、製給複製本及補充更正之權利。',
          'B. 請求停止收集、處理、利用以及請求刪除之權利。',
          'C. 限制該資料在公務機關或警方刑事犯罪偵查中使用的權利。'
        ],
        'correctIndex': 2,
        'explanation': '個資法第3條賦予當事人查詢、刪除、更正等權，但不能以個人權利阻礙司法機關、檢警依法進行犯罪調查與訴訟進行。',
      };
    }
  }

  // Fallback
  return {
    'question': '日常生活處處皆涉及法律行為，當我們與他人發生約定爭議時，應以何者為最優先處理基準？',
    'options': [
      'A. 口頭大聲爭論，誰氣勢強誰就獲勝。',
      'B. 依法令規定、合約約定，並優先保留書面、對話與資金往來等客觀證據。',
      'C. 相信對方的所有片面說詞，配合其要求。'
    ],
    'correctIndex': 1,
    'explanation': '法律講求客觀證據，發生約定爭議時應優先檢視法令與合約規範，並備妥完整書面與電子事證，以便協商或救濟。',
  };
}

LearningMockArticle generateArticleForIllustration(
    IllustrationStoryData story) {
  final cleanTitle = story.title.replaceAll(RegExp(r'^【案例\s*\d+】'), '');
  final details =
      _generateDetails(story.category, story.title, story.description);

  final String heroNoteText;
  if (story.category == '租屋糾紛') {
    heroNoteText = '※ 租屋關係涉及民法與定型化契約，釐清雙方權益才能保障租屋安全。';
  } else if (story.category == '車禍事故') {
    heroNoteText = '※ 車禍處理以「釐清路權與肇責」為核心，配合現場完整蒐證方為上策。';
  } else if (story.category == '職場權益') {
    heroNoteText = '※ 勞基法屬強行法規，任何私下約定若低於法令標準皆屬無效。';
  } else if (story.category == '網購消費') {
    heroNoteText = '※ 通訊交易享有消保法特別保護，網購前務必確認商品屬性與退貨規則。';
  } else if (story.category == '個資隱私') {
    heroNoteText = '※ 數位時代個資即資產，了解個人資料自主權，才能免於隱私外洩威脅。';
  } else {
    heroNoteText = '※ 本案例為實際生活常見法律爭議，研讀有助於防範日常生活風險。';
  }

  return LearningMockArticle(
    badge: story.tag,
    title: cleanTitle,
    summary: story.description,
    readTime: '3 分鐘',
    heroNote: heroNoteText,
    keyPoints: details.keyPoints,
    sections: [
      LearningMockSection(
        title: '一、情境事件概述',
        body:
            '本案例探討「$cleanTitle」。\n\n在日常生活中，此類爭議屢見不鮮。${story.description}\n\n為了防範此類糾紛，我們必須深入了解相關的台灣法規與實務運作，確保自身合法權益不受侵害。',
      ),
      LearningMockSection(
        title: details.section2Title,
        body: details.section2Body,
      ),
      LearningMockSection(
        title: details.section3Title,
        body: details.section3Body,
      ),
    ],
    category: story.category,
    quizData: _generateQuiz(story.category, story.title),
  );
}

LearningMockArticle generateArticleForDialog(DialogStoryData story) {
  final cleanTitle = story.title.replaceAll(RegExp(r'^【案例\s*\d+】'), '');
  final details =
      _generateDetails(story.category, story.title, story.description);

  final String badgeText;
  final String heroNoteText;
  if (story.category == '租屋糾紛') {
    badgeText = '租屋案例分析';
    heroNoteText = '※ 透過真實對話還原爭執現場，釐清租賃契約中雙方的權利與義務。';
  } else if (story.category == '車禍事故') {
    badgeText = '車禍案例分析';
    heroNoteText = '※ 透過真實對話還原爭執現場，釐清事故當事人的路權與賠償責任。';
  } else if (story.category == '職場權益') {
    badgeText = '勞資案例分析';
    heroNoteText = '※ 透過真實對話還原爭執現場，釐清勞動契約中勞資雙方的權利與義務。';
  } else if (story.category == '網購消費') {
    badgeText = '消費案例分析';
    heroNoteText = '※ 透過真實對話還原爭執現場，釐清網購買賣中消費者與賣家的權利與義務。';
  } else if (story.category == '個資隱私') {
    badgeText = '隱私案例分析';
    heroNoteText = '※ 透過真實對話還原爭執現場，釐清個人隱私與資訊安全之權利與保護手段。';
  } else {
    badgeText = '法律個案解析';
    heroNoteText = '※ 透過真實對話還原爭執現場，釐清雙方在法律上的權利與義務。';
  }

  return LearningMockArticle(
    badge: badgeText,
    title: cleanTitle,
    summary: story.description,
    readTime: '3 分鐘',
    heroNote: heroNoteText,
    keyPoints: details.keyPoints,
    sections: [
      LearningMockSection(
        title: '一、對話情境還原',
        body:
            '在日常溝通中，雙方常因法律觀念落差而產生以下爭執：\n\n💬 ${story.senderA}：\n「${story.textA}」\n\n💬 ${story.senderB}：\n「${story.textB}」\n\n這類對話反映出雙方在法律定性上的分歧。以下將針對核心爭點進行詳細解析。',
      ),
      LearningMockSection(
        title: details.section2Title.replaceAll('解析', '詳解'),
        body: details.section2Body,
      ),
      LearningMockSection(
        title: story.category == '租屋糾紛' ||
                story.category == '職場權益' ||
                story.category == '網購消費'
            ? '三、行動與救濟管道'
            : details.section3Title,
        body: details.section3Body,
      ),
    ],
    category: story.category,
    quizData: _generateQuiz(story.category, story.title),
  );
}
