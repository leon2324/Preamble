import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lawapp/config/supabase_config.dart';

void main() async {
  print('========================================');
  print('🚀 開始產生並批量上傳 1,000 組法律情境專題 (共 5,000 筆單元) 至 Supabase...');
  print('雲端 URL: $supabaseUrl');
  print('========================================');

  if (supabaseUrl.isEmpty) {
    print('❌ 錯誤: 請設定 Supabase URL。');
    return;
  }

  // 使用 service_role secret key 繞過 RLS
  final supabaseSecretKey = 'sb_secret_c2K2Ycrj1eaPibn_0N2ypw_LVYP3jnd';
  final headers = {
    'apikey': supabaseSecretKey,
    'Authorization': 'Bearer $supabaseSecretKey',
    'Content-Type': 'application/json',
    'Prefer': 'resolution=merge-duplicates',
  };

  final List<String> categories = [
    '租屋糾紛',
    '車禍事故',
    '職場權益',
    '網購消費',
    '個資隱私',
    '鄰里生活',
    '婚姻家庭',
    '防詐騙常識'
  ];

  final Map<String, List<String>> categoryImages = {
    '租屋糾紛': [
      'https://vtpdncwijhfjtegnnwkz.supabase.co/storage/v1/object/public/learning-covers/rent_1.png',
      'https://vtpdncwijhfjtegnnwkz.supabase.co/storage/v1/object/public/learning-covers/rent_2.png',
      'https://vtpdncwijhfjtegnnwkz.supabase.co/storage/v1/object/public/learning-covers/rent_3.png',
      'https://vtpdncwijhfjtegnnwkz.supabase.co/storage/v1/object/public/learning-covers/rent_4.png'
    ],
    '車禍事故': [
      'https://vtpdncwijhfjtegnnwkz.supabase.co/storage/v1/object/public/learning-covers/car_1.png',
      'https://vtpdncwijhfjtegnnwkz.supabase.co/storage/v1/object/public/learning-covers/car_2.png',
      'https://vtpdncwijhfjtegnnwkz.supabase.co/storage/v1/object/public/learning-covers/car_3.png',
      'https://vtpdncwijhfjtegnnwkz.supabase.co/storage/v1/object/public/learning-covers/car_4.png'
    ],
    '職場權益': [
      'https://vtpdncwijhfjtegnnwkz.supabase.co/storage/v1/object/public/learning-covers/work_1.png',
      'https://vtpdncwijhfjtegnnwkz.supabase.co/storage/v1/object/public/learning-covers/work_2.png',
      'https://vtpdncwijhfjtegnnwkz.supabase.co/storage/v1/object/public/learning-covers/work_3.png',
      'https://vtpdncwijhfjtegnnwkz.supabase.co/storage/v1/object/public/learning-covers/work_4.png'
    ],
    '網購消費': [
      'https://vtpdncwijhfjtegnnwkz.supabase.co/storage/v1/object/public/learning-covers/consumer_1.png',
      'https://vtpdncwijhfjtegnnwkz.supabase.co/storage/v1/object/public/learning-covers/consumer_2.png',
      'https://vtpdncwijhfjtegnnwkz.supabase.co/storage/v1/object/public/learning-covers/consumer_3.png',
      'https://vtpdncwijhfjtegnnwkz.supabase.co/storage/v1/object/public/learning-covers/consumer_4.png'
    ],
    '個資隱私': [
      'https://vtpdncwijhfjtegnnwkz.supabase.co/storage/v1/object/public/learning-covers/privacy_1.png',
      'https://vtpdncwijhfjtegnnwkz.supabase.co/storage/v1/object/public/learning-covers/privacy_2.png',
      'https://vtpdncwijhfjtegnnwkz.supabase.co/storage/v1/object/public/learning-covers/privacy_3.png'
    ],
    '鄰里生活': [
      'https://vtpdncwijhfjtegnnwkz.supabase.co/storage/v1/object/public/learning-covers/rent_1.png',
      'https://vtpdncwijhfjtegnnwkz.supabase.co/storage/v1/object/public/learning-covers/rent_2.png',
      'https://vtpdncwijhfjtegnnwkz.supabase.co/storage/v1/object/public/learning-covers/rent_3.png',
      'https://vtpdncwijhfjtegnnwkz.supabase.co/storage/v1/object/public/learning-covers/rent_4.png'
    ],
    '婚姻家庭': [
      'https://vtpdncwijhfjtegnnwkz.supabase.co/storage/v1/object/public/learning-covers/rent_2.png',
      'https://vtpdncwijhfjtegnnwkz.supabase.co/storage/v1/object/public/learning-covers/work_1.png',
      'https://vtpdncwijhfjtegnnwkz.supabase.co/storage/v1/object/public/learning-covers/consumer_1.png'
    ],
    '防詐騙常識': [
      'https://vtpdncwijhfjtegnnwkz.supabase.co/storage/v1/object/public/learning-covers/privacy_1.png',
      'https://vtpdncwijhfjtegnnwkz.supabase.co/storage/v1/object/public/learning-covers/privacy_2.png',
      'https://vtpdncwijhfjtegnnwkz.supabase.co/storage/v1/object/public/learning-covers/privacy_3.png'
    ]
  };

  final List<String> names = ['阿榮', '小明', '大雄', '阿美', '志明', '春嬌', '老李', '小華', '雅婷', '怡君', '家豪', '建宏', '俊傑', '欣怡', '冠宇', '詩婷', '承翰', '美玲', '淑芬', '阿豪'];
  final List<String> counterNames = ['房東太太', '車主陳先生', '王經理', '賣家老張', '主管李姐', '鄰居老趙', '表哥阿強', '同事小張', '前夫阿德', '前妻美華', '房客小林', '對造林先生'];
  final List<String> items = ['沙發', '冷氣', '馬桶', '熱水器', '冰箱', '手機', '洗衣機', '電視', '微波爐', '吸塵器', '烘衣機', '瓦斯爐'];
  final List<String> locations = ['台北市', '新北市', '台中市', '高雄市', '台南市', '桃園市', '新竹市', '彰化縣', '屏東縣', '宜蘭縣'];

  int successCount = 0;
  int failCount = 0;
  final batchSize = 100;
  List<Map<String, dynamic>> batch = [];

  for (int topicId = 1; topicId <= 1000; topicId++) {
    final catIndex = (topicId - 1) % categories.length;
    final category = categories[catIndex];

    final name = names[topicId % names.length];
    final counter = counterNames[topicId % counterNames.length];
    final item = items[topicId % items.length];
    final location = locations[topicId % locations.length];
    final amount = 1000 + (topicId * 37) % 50000;
    final days = 7 + (topicId * 3) % 90;

    for (int step = 1; step <= 5; step++) {
      String title = '';
      String summary = '';
      String heroNote = '';
      List<String> keyPoints = [];
      List<Map<String, String>> sections = [];
      Map<String, dynamic> quiz = {};

      if (category == '租屋糾紛') {
        if (step == 1) {
          title = '單元 1：關於租屋中 $item 賠償與折舊的法律基礎';
          summary = '房東要求賠償損壞的 $item，我們該如何從法律角度釐清自然耗損與折舊率？';
          heroNote = '退租點交時，自然耗損屬於房東負擔，折舊率是以使用年限為計算基礎，不應按全新品價格賠償。';
          keyPoints = [
            '自然耗損由房東負擔，不應扣除租客押金。',
            '折舊計算應以行政院公布的固定資產耐用年數表為基準。',
            '點交時應拍照存證，以佐證退租時的物品狀態。'
          ];
          sections = [
            {'title': '觀念起點', 'body': '在 $location，$name 租屋期滿準備搬走。點交時，$counter 發現房內的 $item 有使用痕跡，宣稱折損嚴重，要求從押金中扣除 $amount 元作為賠償以購置全新品。$name 認為該 $item 已使用多年，直接扣款不合理。'},
            {'title': '法律規定', 'body': '民法第 429 條規定，租賃物之修繕與耗損原則上由出租人負擔。若物品因租客故意或過失損壞，賠償也應按物品已使用的年限進行「折舊計算」。例如 $item 的耐用年限若為 5 年，已使用 4 年，則殘值僅賸 1/5，房東要求賠償全新價是於法無據的。'}
          ];
          quiz = {
            'question': '退租點交時，房東宣稱已使用多年的 $item 損壞，要求扣押金 $amount 元買新的，這樣合理嗎？',
            'options': [
              'A. 合理，租客有責任保證交屋時所有東西跟全新的一樣。',
              'B. 不合理，自然老化耗損屬於正常使用，且賠償應按耐用年數計算折舊，不能直接扣全新價格。',
              'C. 合理，押金在房東手上，只要房東列出金額就可以扣除。'
            ],
            'correctIndex': 1,
            'explanation': '自然耗損由房東負擔。若因過失毀損，賠償應扣除折舊，房東不得要求以新換舊的賠償金額。'
          };
        } else if (step == 2) {
          title = '單元 2：$name 在 $location 的 $item 修繕責任歸屬爭議';
          summary = '當 $item 出現故障時，到底該由房客 $name 還是房東 $counter 負責修繕？責任如何劃分？';
          heroNote = '民法規定修繕義務原則上由房東負擔，除非租約中有明文特別約定由房客負責。';
          keyPoints = [
            '租賃物修繕義務原則上屬於出租人（房東）。',
            '若因房客使用不當導致損壞，房客應負賠償或修繕責任。',
            '故障發生時應即時通知房東，否則造成損害擴大房客需負責。'
          ];
          sections = [
            {'title': '情境起因', 'body': '在 $location 承租處，$name 發現房內配置的 $item 突然無法運作，打電話給 $counter 報修。$counter 回應「租給你的時候是好的，現在壞了當然是你自己要修」，拒絕支付維修費 $amount 元。'},
            {'title': '修繕劃分', 'body': '依民法第 429 條，除契約另有習慣外，出租人應負修繕義務。若 $item 是因自然老化或通常使用而壞掉，房東有義務修好。若房東經催告仍不修，房客可自行找人修繕，並從下個月租金中直接扣除修繕費用。'}
          ];
          quiz = {
            'question': '房客承租期間，房內附帶的 $item 因老化自然損壞，且合約無特別約定，修繕責任由誰承擔？',
            'options': [
              'A. 房東，民法規定出租人應保持租賃物合於使用狀態，並負修繕義務。',
              'B. 房客，因為是房客在使用，不管壞掉原因為何都該自己修。',
              'C. 雙方平分維修費用。'
            ],
            'correctIndex': 0,
            'explanation': '合約無特別約定下，設備自然老化損壞由房東負責修繕。'
          };
        } else if (step == 3) {
          title = '單元 3：租屋契約常見扣除押金的法條盲點';
          summary = '解析租約中關於「提前解約沒收押金」與「恢復原狀」的常見法律誤解。';
          heroNote = '押金的功能是擔保債務，並非違約金；即使提前解約，房東也無權直接全部沒收。';
          keyPoints = [
            '押金主要用於扣抵欠租、損害賠償等，不是違約的懲罰。',
            '「恢復原狀」指依通常折舊後的合理狀態返還，不等於要重新粉刷至全新。',
            '提前解約的違約金依法最高不得超過一個月租金。'
          ];
          sections = [
            {'title': '合約陷阱', 'body': '由於生涯規劃，$name 打算提前退租。$counter 指出合約寫明「提前解約押金不予退還」，因此宣稱要沒收全部 $amount 元的兩個月押金。$name 對此感到困惑。'},
            {'title': '法條真相', 'body': '最高法院見解認為，押金為信託的擔保，在租賃期滿且無欠款時，房東應返還。即使合約約定提前解約可沒收押金，性質上也屬於違約金的預定，若金額過高（超過一個月租金），法院或消保官可依民法第 252 條予以酌減。'}
          ];
          quiz = {
            'question': '合約上寫著「若提前解約，房東得沒收全部兩個月押金」，這在法律上是無條件合理的嗎？',
            'options': [
              'A. 合理，契約自由原則下，只要簽字就必須無條件遵守。',
              'B. 不一定合理，若沒收金額過高（高於一個月租金），租客可以主張酌減違約金，且押金與違約金本質不同。',
              'C. 不合理，提前解約房東連一個月都不能扣。'
            ],
            'correctIndex': 1,
            'explanation': '違約金上限通常為一個月租金，過高時可透過調解或訴訟請求法院酌減。'
          };
        } else if (step == 4) {
          title = '單元 4：退租點交的證據清單與存證信函寫法';
          summary = '當與房東發生點交糾紛，如何利用拍照、錄影建立證據鏈，以及存證信函的催告步驟。';
          heroNote = '點交時的文字紀錄與影像存證是打官司時最重要的證據，口頭承諾不具法律效力。';
          keyPoints = [
            '點交時一定要現場逐項檢查，並請房東在「點交清單」上簽名確認。',
            '若房東故意不退押金，應撰寫存證信函進行限期催告返還。',
            '善用各縣市調解委員會聲請調解，既省時又具備民事判決效力。'
          ];
          sections = [
            {'title': '證據建立', 'body': '為了避免 $counter 之後藉故扣押金，$name 在退租當天將所有房間角落與 $item 進行拍照，並在通訊軟體上發送給 $counter 確認「已完成清潔點交」。'},
            {'title': '法律催告', 'body': '若點交完畢後，房東仍無故拖延不退押金。房客應寄發存證信函催告（內容載明租約到期、已點交完畢、限期於 $days 天內返還押金）。若逾期未還，可逕行起訴或聲請支付命令。'}
          ];
          quiz = {
            'question': '點交完成後，房東仍無故拖延不返還押金，以下哪一項是正確的維權步驟？',
            'options': [
              'A. 默默等待，或在網路上發文謾罵房東。',
              'B. 拍照留存點交紀錄，寄發存證信函限期催告返還，若逾期則聲請調解或向法院聲請支付命令。',
              'C. 直接把鎖頭換掉，不讓房東進去。'
            ],
            'correctIndex': 1,
            'explanation': '存證信函具有法律催告與證據保留作用，之後可透過支付命令或調解索回押金。'
          };
        } else {
          title = '單元 5：租屋糾紛模擬測驗與通關驗證';
          summary = '本專題的綜合檢測，用一個綜合租屋爭點驗證您是否已具備自保能力。';
          heroNote = '恭喜您來到最後一關，讓我們用這個綜合模擬題確認您對押金與折舊的判斷架構。';
          keyPoints = [
            '先釐清故障或損壞是自然耗損還是人為因素。',
            '確認合約是否有特約限制修繕義務。',
            '賠償時必扣折舊，不可任由要求賠新品價格。'
          ];
          sections = [
            {'title': '綜合情境', 'body': '$name 的租約即將到期，但在承租期間因為 $item 老化壞掉自行請人修理花費 $amount 元。點交時 $counter 反過來指責 $name 將牆壁弄髒，要求扣除所有押金。$name 應該怎麼主張？'},
            {'title': '核心判斷', 'body': '1. $name 可就自行維修的 $amount 元費用主張與應付租金抵銷。2. 牆壁髒污若是正常居住使用痕跡，屬於自然耗損，房東不得扣押金要求恢復到全新牆面。'}
          ];
          quiz = {
            'question': '如果租客在退租時，牆壁有正常使用的合理發黃，且曾自費維修老化的 $item，房東要扣押金，租客如何主張？',
            'options': [
              'A. 認賠，因為押金在房東手上。',
              'B. 主張牆壁發黃屬自然消耗不予賠償，且可就自費修繕老舊設備的費用向房東請求抵銷。',
              'C. 報警控告房東侵占罪。'
            ],
            'correctIndex': 1,
            'explanation': '自然耗損不用賠，且房東應負擔之修繕費若由房客墊付，房客依法有權請求返還或抵銷。'
          };
        }
      } else if (category == '車禍事故') {
        if (step == 1) {
          title = '單元 1：車禍發生時的路權優先權與初步分析研判表';
          summary = '探討車禍發生時路權優先順序，以及如何申請並解讀警方的「初步分析研判表」。';
          heroNote = '車禍民事求償與過失比例，主要建立在路權（支線讓幹線、轉彎讓直行）的歸屬上。';
          keyPoints = [
            '無號誌路口應遵循「支線道讓幹線道」、「左方車讓右方車」。',
            '事故發生 30 天後，可向警方免費申請「道路交通事故初步分析研判表」。',
            '初步分析研判表非最終鑑定，但為保險理賠與和解的重要參考。'
          ];
          sections = [
            {'title': '事故經過', 'body': '在 $location 的無號誌路口，$name 駕駛車輛與 $counter 發生碰撞，導致雙方車頭毀損。估價單顯示 $name 的車輛更換 $item 及鈑金烤漆共需 $amount 元。雙方就過失責任比例爭執不休。'},
            {'title': '路權解析', 'body': '依道路交通安全規則第 102 條，行至無號誌路口時，轉彎車應讓直行車先行；如同為直行車，支線道車應讓幹線道車先行。警方製作的初判表會寫明雙方的「可能肇事原因」，是釐清責任的第一步。'}
          ];
          quiz = {
            'question': '車禍發生後，如果想了解警方初步認定的違規事實與主次要肇事因素，應該申請什麼文件？',
            'options': [
              'A. 診斷證明書。',
              'B. 道路交通事故初步分析研判表（初判表）。',
              'C. 車輛損毀估價單。'
            ],
            'correctIndex': 1,
            'explanation': '事故 30 日後可向警察機關申請初判表，用以了解初步的肇事原因。'
          };
        } else if (step == 2) {
          title = '單元 2：車損折舊計算與「以新換舊」法律原則';
          summary = '車輛損壞維修時，零件與工資的折舊計算。如何看懂法院的定率遞減法？';
          heroNote = '車禍民事求償中，車輛損壞維修零件應計算折舊，但工資與烤漆費用則不在折舊之列。';
          keyPoints = [
            '民事求償維修費用中，換新零件必須扣除折舊，工資與烤漆費用不予折舊。',
            '折舊率按行政院固定資產耐用年數表（普通客車耐用年限 5 年，定率遞減法）。',
            '若車輛已達耐用年限，零件殘值通常計算為原價之 1/10。'
          ];
          sections = [
            {'title': '折舊爭端', 'body': '車禍後 $name 將車送修，$counter 指出 $name 的車已開了 4 年，維修單上的全新 $item 價值 $amount 元，不能全額要求賠償，必須扣除折舊。'},
            {'title': '法院標準', 'body': '民法第 196 條規定，物被毀損之賠償以修復費用為估算標準者，新零件折換舊零件應扣除折舊。以折舊年限 5 年的客車為例，每年以定率遞減法折舊（折舊率為 0.369）。但鈑金、烤漆等「工資」屬於勞務，不適用折舊，須全額賠償。'}
          ];
          quiz = {
            'question': '車禍後維修車輛，對方估價單列出零件與烤漆工資，在法律求償時折舊如何計算？',
            'options': [
              'A. 整張維修估價單不論零件或工資，都必須按車齡折舊。',
              'B. 只有更換的「新零件」需要計算折舊扣減，而「工資與烤漆」等項目不需要折舊，應全額理賠。',
              'C. 只要是車禍維修，一律可以要求對方全額賠償全新零件，不扣折舊。'
            ],
            'correctIndex': 1,
            'explanation': '新零件代替舊零件有不當得利之嫌，故零件需折舊；工資與烤漆是純勞務，沒有折舊問題。'
          };
        } else if (step == 3) {
          title = '單元 3：車禍受傷的「過失傷害」刑事起訴期限';
          summary = '車禍中如果有人受傷，該如何利用刑事「過失傷害」逼使對方民事和解？起訴期限有多長？';
          heroNote = '只要車禍有受傷（不論傷勢輕重），皆可提告刑法過失傷害罪，告訴期間為 6 個月。';
          keyPoints = [
            '過失傷害罪為告訴乃論，必須在車禍發生之日起 6 個月內提起告訴。',
            '「以刑逼民」是實務上促成民事賠償和解的常見策略。',
            '即使自己也有過失，只要對方有過失且造成我方受傷，我方即可提告。'
          ];
          sections = [
            {'title': '受傷求償', 'body': '車禍中 $name 的手部挫傷，$counter 態度消極，拒絕賠償醫療費與 $item 損失共 $amount 元。$name 的醫生診斷書顯示需休養 $days 天。'},
            {'title': '刑事訴訟', 'body': '刑法第 284 條過失傷害罪只要有過失且致人於傷即可成立。因告訴期限僅 6 個月，若民事和解談不攏，應於期限前向警方或地檢署提告，迫使對方出面解決。民事賠償請求權期限則為 2 年。'}
          ];
          quiz = {
            'question': '車禍有人受傷，如果想提起「過失傷害」刑事告訴，最遲應在車禍後幾個月內提出？',
            'options': [
              'A. 2 個月。',
              'B. 6 個月。',
              'C. 2 年。'
            ],
            'correctIndex': 1,
            'explanation': '刑事過失傷害罪為告訴乃論，告訴期間為自事故發生之日起算 6 個月內。'
          };
        } else if (step == 4) {
          title = '單元 4：車禍和解、調解程序與和解書關鍵條款';
          summary = '如何撰寫一份具備法律效力的車禍和解書？「放棄民刑事訴訟權利」條款的重要性。';
          heroNote = '和解書中必須載明「雙方拋棄對本件車禍之其餘民刑事請求權」，否則對方可能事後再告。';
          keyPoints = [
            '私下和解需簽署書面和解書；至調解委員會調解，調解書經法院核定後等同三審判決。',
            '和解書必須包含「放棄其餘民事請求權及刑事告訴權」條款。',
            '賠償款項最好當場給付或約定匯款，並保留匯款紀錄。'
          ];
          sections = [
            {'title': '達成和解', 'body': '雙方同意以 $amount 元達成和解。$counter 承諾分期付款，要求 $name 當場簽署和解書。$name 需確保和解條款安全無虞。'},
            {'title': '條款解析', 'body': '有效的車禍和解書應詳細記載：當事人資訊、事故經過、和解金額、給付方式，以及「本和解書成立後，雙方拋棄對本件事故之其餘民刑事請求權與告訴權」的拋棄條款，以杜絕後患。'}
          ];
          quiz = {
            'question': '簽署車禍和解書時，為了避免對方事後反悔再度提告，和解書中一定要寫明哪一條？',
            'options': [
              'A. 保證以後不再開車。',
              'B. 雙方同意拋棄本件車禍之其餘民、刑事請求權及告訴權。',
              'C. 雙方必須成為朋友。'
            ],
            'correctIndex': 1,
            'explanation': '明確的民刑事請求權與告訴權拋棄條款，能防止任何一方在簽字後重新起訴或提告。'
          };
        } else {
          title = '單元 5：車禍糾紛綜合實戰測驗與通關';
          summary = '本專題的綜合檢測，用一個綜合車禍爭點驗證您是否已具備事故處理能力。';
          heroNote = '恭喜您來到車禍事故專題最後一關！讓我們用這題綜合題考考您的臨場判斷。';
          keyPoints = [
            '先確認雙方是否有受傷以評估是否有刑事風險。',
            '車損零件折舊，工資不折舊。',
            '和解時一定要確保包含拋棄訴訟權利條款。'
          ];
          sections = [
            {'title': '綜合情境', 'body': '$name 駕駛車輛與 $counter 發生車禍，$name 受輕傷，更換 $item 花費 $amount 元（折舊後殘值僅賸 1/3，但工資要 $amount 元）。$counter 拒不賠償。$name 應如何維權？'},
            {'title': '核心判斷', 'body': '1. $name 可在 6 個月內提起刑事過失傷害告訴以刑逼民。2. 民事賠償範圍包括折舊後零件費 + 全額工資 + 醫療費。3. 談和解時務必簽署含有拋棄權利條款的書面協議。'}
          ];
          quiz = {
            'question': '車禍中我方受傷且車輛零件受損，對方不願意賠償，我方該如何在法理上取得優勢？',
            'options': [
              'A. 自認倒楣，全額出資維修。',
              'B. 在 6 個月內向警方提出過失傷害刑事告訴，並在民事訴訟中請求折舊後零件費加全額工資與醫藥費。',
              'C. 到對方公司吵鬧，逼其出面。'
            ],
            'correctIndex': 1,
            'explanation': '提起刑事告訴（過失傷害）是促使對方積極和解的合法手段，且民事求償應合理計算零件折舊與工資。'
          };
        }
      } else {
        // 其他分類的通用模板，避免代碼過於冗長，並確保 1,000 組專題都有精細的 5 個單元
        if (step == 1) {
          title = '單元 1：關於 $category 的基本權利與法律觀念';
          summary = '在遇到 $category 情境時，首先應建立的基礎法律常識與權益認知。';
          heroNote = '做好基本權利功課，在爭議發生的當下才不會因驚慌而做出錯誤決定。';
          keyPoints = [
            '釐清該法律關係是屬於民法契約、侵權行為還是行政法規。',
            '確定自己具有法律上的請求權基礎。',
            '準備好記錄糾紛人、事、時、地、物之基本資料。'
          ];
          sections = [
            {'title': '概念導入', 'body': '在 $location，涉及 $category 的糾紛時常發生。$name 最近因為 $item 與 $counter 發生了糾紛，爭執金額達 $amount 元。$name 面臨了需要主張法律權利的情況。'},
            {'title': '法理說明', 'body': '處理 $category 的第一步是確定雙方的法律關係。例如在 $category 中，多數屬於民事糾紛，雙方權利義務主要由契約或法律明文（如民法、勞基法、消保法）來界定。'}
          ];
          quiz = {
            'question': '面對 $category 的爭議時，第一步最應該釐清的是什麼？',
            'options': [
              'A. 雙方的法律關係以及自己的權利請求權基礎。',
              'B. 對方的財務狀況。',
              'C. 如何在網路上公開爆料。'
            ],
            'correctIndex': 0,
            'explanation': '釐清法律關係與請求權基礎，是尋求法律救濟、撰寫存證信函或進行調解的首要前提。'
          };
        } else if (step == 2) {
          title = '單元 2：$name 的具體案例情境解析與法理解剖';
          summary = '深入剖析 $name 與 $counter 之間關於 $item 的具體爭議細節與適用條款。';
          heroNote = '透過實際案例的條文拆解，看懂法律是如何應用在真實生活糾紛中。';
          keyPoints = [
            '分析案例中各方的行為是否構成違約或侵權。',
            '找出該糾紛最關鍵的法條（例如民法或特別法）。',
            '確認雙方是否有協商或減輕損害之義務。'
          ];
          sections = [
            {'title': '案例經過', 'body': '$name 因 $item 與 $counter 產生意見分歧，$counter 態度強硬，主張 $name 必須負責並賠償 $amount 元，否則將提起訴訟。$name 認為對方的要求不合情理。'},
            {'title': '條文解析', 'body': '本案核心在於雙方是否有明確契約約定。若無約定，則回歸相關法規。在 $category 情境中，法律通常會保護資訊較弱勢的一方，或者要求主張權利的一方必須負擔舉證責任。'}
          ];
          quiz = {
            'question': '若 $counter 要求賠償 $amount 元，但沒有提出具體的契約依據或法規證明，我方應如何回應？',
            'options': [
              'A. 害怕被告，直接給錢了事。',
              'B. 禮貌要求對方提出具體索賠的合約條款或法律條文依據，並合理評估其合理性。',
              'C. 不予理會，直接拉黑對方。'
            ],
            'correctIndex': 1,
            'explanation': '索賠必須有契約或法律依據，要求對方提出明細與法律基礎是合理自保的手段。'
          };
        } else if (step == 3) {
          title = '單元 3：常見的 $category 法律盲點與直覺誤區';
          summary = '指出一般人在此類糾紛中最容易犯的直覺錯誤，避免越處理越糟糕。';
          heroNote = '法律是講求證據與法理的，直覺上的合理往往不等於法律上的合理。';
          keyPoints = [
            '不要口頭承諾任何賠償或退讓，口頭合意同樣可能成立契約。',
            '切勿一時氣憤在公開平台上傳播對方個資，以免反遭控告。',
            '並非只要自己有理就可以強行採取私力救濟，須循合法程序。'
          ];
          sections = [
            {'title': '常見誤區', 'body': '許多人在處理 $category 時，常認為「既然對方理虧，我就可以直接扣留其 $item 或是爆料對方的姓名電話」。然而這往往觸犯了个資法或刑法。'},
            {'title': '正確法治觀念', 'body': '實務上，即使對方確實違約，我方也應透過催告、調解或民事訴訟索賠，不得強行扣留對方私人物品。同時，個資法保護所有人，公開對方個資來討公道往往會得不償失。'}
          ];
          quiz = {
            'question': '在 $category 爭議中，為了討回公道，我們可以直接將對方的真實姓名與對話截圖公開發到爆料社群嗎？',
            'options': [
              'A. 可以，只要對話是真實的就沒有任何違法問題。',
              'B. 不可以，這極可能違反個資法利用限制，並侵害隱私權，可能反遭對方起訴求償。',
              'C. 可以，這是憲法保障的言論自由。'
            ],
            'correctIndex': 1,
            'explanation': '未遮蔽姓名電話等個資的公開爆料，會構成個資違法利用，得不償失。'
          };
        } else if (step == 4) {
          title = '單元 4：實務維權步驟：證據清單與存證信函範本';
          summary = '為您整理在 $category 中不可或缺的證據清單，以及寄發存證信函的寫法。';
          heroNote = '在法律的世界裡，「沒有證據就等於沒有事實」。做好證據保存是贏得訴訟的關鍵。';
          keyPoints = [
            '妥善保留所有對話紀錄、合約、發票、收據與現場照片。',
            '利用存證信函明確傳達意思表示，並留下郵局的正式郵戳證明。',
            '存證信函不是判決書，但能起到正式催告與警告的效果。'
          ];
          sections = [
            {'title': '證據準備', 'body': '當 $name 決定爭取權益時，必須先整理好包含通訊對話、關於 $item 的單據以及在 $location 簽署的契約等证据，限期要求 $counter 於 $days 日內履行。'},
            {'title': '存證信函作用', 'body': '存證信函主要用於保留法律上的催告證據，證明我方確已在某日向對方表達某種主張。若對方拒不履行，此信函可在調解或訴訟中作為我方已進行催告的重要證據。'}
          ];
          quiz = {
            'question': '在法律糾紛中，寄發「存證信函」最主要的目的是什麼？',
            'options': [
              'A. 讓郵局直接派人去逮捕對方。',
              'B. 留存正式催告意思表示的證明，並作為日後訴訟的書面證據。',
              'C. 這是一種恐嚇信，不需要理會。'
            ],
            'correctIndex': 1,
            'explanation': '存證信函是郵局存證的書面催告信，主要用以作為日後訴訟中已進行催告與告知的鐵證。'
          };
        } else {
          title = '單元 5：$category 綜合實戰測驗與通關';
          summary = '本專題的綜合檢測，用一個綜合 $category 爭點驗證您是否已具備自保能力。';
          heroNote = '恭喜您來到最後一關！讓我們用這題綜合題完成您的學習通關吧。';
          keyPoints = [
            '確認合約條款是否優於法規，若違法法規則無效。',
            '堅持證據優先，以存證信函與調解為首要解決手段。',
            '遵守法律程序，切勿訴諸私力救濟或情緒化爆料。'
          ];
          sections = [
            {'title': '綜合情境', 'body': '$name 在 $location 遇到 $category 爭議，與 $counter 協商無果。$counter 要求 $name 賠償 $amount 元，但 $name 握有證明 $counter 違約的關鍵對話紀錄。$name 應該怎麼做？'},
            {'title': '解決路徑', 'body': '1. 拒絕不合理索賠。 2. 寄發存證信函，列出關鍵證據，要求對方履行合約。 3. 若仍無共識，聲請調解委員會調解，避免耗時的訴訟。'}
          ];
          quiz = {
            'question': '遭遇 $category 糾紛且對方態度惡劣時，下列哪一個是合法且最有效的維權途徑？',
            'options': [
              'A. 自認倒楣，全額出資。',
              'B. 整理對話與合約證據，寄發存證信函催告，或向鄉鎮市區公所聲請免費的民事調解。',
              'C. 找朋友去包圍對方。'
            ],
            'correctIndex': 1,
            'explanation': '整理證據、寄發存證信函、聲請免費民事調解，是既合法、低成本又極具法律效力的解決方式。'
          };
        }
      }

      final images = categoryImages[category] ?? categoryImages['租屋糾紛']!;
      final imageUrl = images[topicId % images.length];

      batch.add({
        'topic_id': topicId,
        'step_number': step,
        'title': title,
        'category': category,
        'badge': '學習單元',
        'summary': summary,
        'read_time': '${3 + (topicId + step) % 3} 分鐘',
        'hero_note': heroNote,
        'key_points': keyPoints,
        'sections': sections,
        'quiz_data': quiz,
        'hero_image_url': imageUrl,
      });
    }

    if (batch.length >= batchSize || topicId == 1000) {
      final url = Uri.parse('$supabaseUrl/rest/v1/learning_articles');
      try {
        final response = await http.post(
          url,
          headers: headers,
          body: jsonEncode(batch),
        );
        if (response.statusCode == 200 || response.statusCode == 201) {
          successCount += batch.length;
          print('✅ 成功上傳批次 (目前累計: $successCount / 5000 筆)');
        } else {
          failCount += batch.length;
          print('❌ 失敗上傳批次: ${response.statusCode} ${response.body}');
        }
      } catch (e) {
        failCount += batch.length;
        print('❌ 上傳例外錯誤: $e');
      }
      batch.clear();
    }
  }

  print('========================================');
  print('🎉 專題情境產生與上傳完成！成功: $successCount 筆，失敗: $failCount 筆。');
  print('========================================');
}
