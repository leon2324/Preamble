import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/data/mock_data/learning/learning_mock_data.dart';
import 'package:lawapp/theme/app_colors.dart';
import 'package:lawapp/data/learning/learning_game_state.dart';
import 'package:lawapp/components/home/v2/home_v2_palette.dart';
import 'package:lawapp/pages/learning/widgets/notebook_aesthetics.dart';
import 'package:lawapp/features/case_time_machine/widgets/case_time_machine_svg_icon.dart';
import 'package:lawapp/pages/learning/know_law_page.dart'; // To access LawAssistantSearchPage
import 'package:lawapp/pages/learning/widgets/achievement_room.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class LearningMockDetailPage extends StatefulWidget {
  const LearningMockDetailPage({
    super.key,
    required this.article,
    this.unitStepLabel,
    this.category,
  });

  final LearningMockArticle article;
  final String? unitStepLabel;
  final String? category;

  @override
  State<LearningMockDetailPage> createState() => _LearningMockDetailPageState();
}

class _LearningMockDetailPageState extends State<LearningMockDetailPage> {
  static const String _svgStarOutlineIcon = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon>
</svg>
''';

  static const String _svgStarFilledIcon = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor">
  <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon>
</svg>
''';

  int? _selectedQuizIndex;
  bool _isQuizAnswered = false;

  // 1 題思辨測試題目資料
  late final Map<String, dynamic>? _quizData;

  String _guessCategory(String title) {
    if (title.contains('租屋') || title.contains('押金') || title.contains('房東') || title.contains('房客') || title.contains('約定') || title.contains('點交') || title.contains('提前解約')) return '租屋糾紛';
    if (title.contains('職場') || title.contains('加班') || title.contains('工時') || title.contains('離職') || title.contains('勞資') || title.contains('病假') || title.contains('勞基') || title.contains('資遣') || title.contains('解雇') || title.contains('勞動')) return '職場權益';
    if (title.contains('網購') || title.contains('退貨') || title.contains('消保') || title.contains('消費') || title.contains('鑑賞期') || title.contains('標錯價') || title.contains('電商')) return '網購消費';
    if (title.contains('肖像') || title.contains('發文') || title.contains('個資') || title.contains('隱私') || title.contains('監視器') || title.contains('垃圾簡訊') || title.contains('去識別化')) return '個資隱私';
    if (title.contains('車禍') || title.contains('事故') || title.contains('碰撞') || title.contains('交通') || title.contains('路權') || title.contains('肇責') || title.contains('折舊') || title.contains('慰撫金')) return '車禍事故';
    return '法律常識';
  }

  @override
  void initState() {
    super.initState();
    final cat = widget.category ?? widget.article.category ?? _guessCategory(widget.article.title);
    _quizData = widget.article.quizData ?? _getQuizForStep(cat, widget.unitStepLabel);
    LearningGameState.instance.markCategoryViewed(cat);
  }

  Map<String, dynamic>? _getQuizForStep(String category, String? step) {
    if (step == null) return null;

    if (category == '租屋糾紛') {
      switch (step) {
        case 'STEP 1':
          return {
            'question': '阿榮退租時，房東說沙發有自然老化的皮裂，要扣押金 3000 元買新沙發。請問這合理嗎？',
            'options': [
              'A. 合理，房東收押金就是為了能扣除任何老舊家具的維護費。',
              'B. 不合理，自然老化耗損屬於正常使用，折舊與修繕責任應由房東承擔，不得扣抵押金。',
              'C. 合理，家具折舊費用本來就是由租客全額補貼新家具。'
            ],
            'correctIndex': 1,
            'explanation': '自然耗損非屬人為故意或過失之損害，房東應自行承擔家具耗損，不得據此扣抵租客的押金。',
          };
        case 'STEP 2':
          return {
            'question': '大雄租約寫明「提前解約賠一個月租金」。大雄租了半年後退租，並提早一個月告知，房東太太要求沒收全額兩個月押金。請問合理嗎？',
            'options': [
              'A. 不合理，既然合約已約定賠一個月，且法律規定違約金最高上限也是一個月，房東要求兩個月是違法的。',
              'B. 合理，因為提早告知仍會對房東造成出租空窗期的損失，所以可以多扣一個月。',
              'C. 合理，契約只要簽字，房東要扣多少就以房東口頭要求為準。'
            ],
            'correctIndex': 0,
            'explanation': '提前解約的違約金應按合約約定為之，且依政府租賃住宅定型化契約規範，最高不得超過一個月租金。',
          };
        case 'STEP 3':
          return {
            'question': '房客搬走後，房東發現牆壁上有前房客貼海報留下的隱約膠帶痕跡，要求房客必須負擔「整間屋子全新油漆」的費用。請問合理嗎？',
            'options': [
              'A. 合理，租客必須保證退租時房屋跟全新的一模一樣。',
              'B. 不合理，賠償應以「恢復原狀」為原則，正常使用痕跡已折舊，且不應無限上綱要求整間油漆的費用。',
              'C. 合理，房東找工人的所有開銷都可以直接從押金扣除。'
            ],
            'correctIndex': 1,
            'explanation': '房屋租賃折舊是常態，且貼海報之輕微痕跡通常屬於合理使用範圍，房東要求整間粉刷費用並不符合法理上賠償折舊與恢復原狀之比例原則。',
          };
        case 'STEP 4':
          return {
            'question': '合約上若手寫了一句「租客自願拋棄任何提前解約的法律通知期權利，且一旦解約，違約金由房東自由決定」。這句話有效嗎？',
            'options': [
              'A. 完全有效，法律尊重當事人契約自由，有簽名就必須遵守。',
              'B. 部分或全部無效，因違反消費者保護法與內政部定型化契約之強制禁止規定，顯失公平之條款無效。',
              'C. 完全有效，手寫字體法律效力高於一切法規。'
            ],
            'correctIndex': 1,
            'explanation': '若條款內容違反消保法或內政部定型化契約應記載及不得記載事項，即便租客簽字，該條款亦會被認定為無效。',
          };
        case 'STEP 5':
          return {
            'question': '租期屆滿後，房東藉口水電費帳單尚未結清、牆壁有灰塵為由，拒絕點交並扣留全部兩個月押金三個月，請問房客該如何保障權益？',
            'options': [
              'A. 只能被動等待帳單寄來，無權催告房東點交。',
              'B. 可發存證信函催告房東限期點交返還押金，並可扣除預估水電費後要求返還餘額。',
              'C. 直接撬開房門搬走所有家具以折抵押金。'
            ],
            'correctIndex': 1,
            'explanation': '押金於租期屆滿且返還房屋時，房東扣除積欠租金、費用後即應返還，不得以未結清微小水電費為由無理扣留全部押金。',
          };
      }
    }

    if (category == '車禍事故') {
      switch (step) {
        case 'STEP 1':
          return {
            'question': '發生車禍擦撞但無人受傷，車輛堵塞交通，當事人應如何處理？',
            'options': [
              'A. 絕對不能移動車輛，否則視同肇事逃逸，必須等警察來才行。',
              'B. 應先標繪車輛位置並拍照錄影攝影採證後，將車輛移置路邊，避免妨礙交通與二次事故。',
              'C. 直接開走，不用等警察，事後再用電話聯絡即可。'
            ],
            'correctIndex': 1,
            'explanation': '依道路交通管理處罰條例第62條，無人受傷之事故，若不移置妨礙交通之車輛，可處以罰鍰。前提是必須先拍照或標記定位。',
          };
        case 'STEP 2':
          return {
            'question': '支線道車輛行經無號誌路口時，未禮讓幹線道車輛而發生碰撞，責任通常如何判定？',
            'options': [
              'A. 雙方車速一樣就各負一半責任。',
              'B. 支線道車輛未禮讓幹線道車輛，違反路權規定，通常要負主要肇事責任（如 7 成以上）。',
              'C. 撞人的一方要負全部責任，被撞的完全無責。'
            ],
            'correctIndex': 1,
            'explanation': '道路交通安全規則第102條規定，支線道車應讓幹線道車先行。未禮讓路權優先者，為車禍之主要肇因。',
          };
        case 'STEP 3':
          return {
            'question': '車禍導致車輛受損維修，更換全新零件費用 10 萬元，工資 3 萬元。若該車已使用 5 年，民事折舊會如何計算？',
            'options': [
              'A. 零件與工資全部都要折舊扣減。',
              'B. 工資與烤漆不折舊（賠 3 萬）；零件 10 萬元折舊後，通常僅需賠償殘值（如 1 萬元），合計賠償約 4 萬元。',
              'C. 必須以 13 萬元全額賠償，不能折舊。'
            ],
            'correctIndex': 1,
            'explanation': '依實務見解，工資與烤漆為無形勞務，無折舊問題；而更換之零件為新品，應依耐用年數計算折舊，超過耐用年數則以殘值（通常為1/10）計算。',
          };
        case 'STEP 4':
          return {
            'question': '車禍受傷請求精神慰撫金，法院判決金額的主要審酌依據是什麼？',
            'options': [
              'A. 受害人單方面開出的發票或收據金額。',
              'B. 雙方的身分、地位、資力、受傷嚴重程度、對生活影響及肇事責任比例等綜合因素。',
              'C. 固定按診斷證明書上寫的休養天數，一天一萬元計算。'
            ],
            'correctIndex': 1,
            'explanation': '精神慰撫金（非財產上損害賠償）無固定計算公式，法院會綜合考量雙方社經地位、資力、受傷程度與責任歸屬來定出合理金額。',
          };
        case 'STEP 5':
          return {
            'question': '己方車輛在紅燈停等時，遭後方車輛追撞，己方全無過失。對方保險公司卻表示「零件已折舊所以只賠兩成」，該如何應對？',
            'options': [
              'A. 只能自認倒楣接受兩成理賠。',
              'B. 堅持工資與烤漆不能折舊，且可要求提供同等品質之中古零件（不折舊）或主張以修復原狀為主要訴求。',
              'C. 直接起訴對方保險公司刑事詐欺罪。'
            ],
            'correctIndex': 1,
            'explanation': '雖然零件有折舊，但民法規定損害賠償以回復原狀為原則，且工資、工時及烤漆絕對不能折舊，可據此與保險公司爭取合理理賠。',
          };
      }
    }

    if (category == '職場權益') {
      switch (step) {
        case 'STEP 1':
          return {
            'question': '入職時公司要求簽署「自願放棄勞保與勞退，改發補貼」的切結書，此約定效力為何？',
            'options': [
              'A. 有效，只要勞資雙方同意，即屬契約自由。',
              'B. 無效，投保勞保與提繳勞退屬於雇主的強行法定義務，員工簽署之放棄聲明自始無效。',
              'C. 有效，但公司必須每個月補貼 5000 元以上才算合法。'
            ],
            'correctIndex': 1,
            'explanation': '勞工保險條例與勞工退休金條例為強制規定，非當事人得自由拋棄之權利，該切結書因違反強行法規而無效。',
          };
        case 'STEP 2':
          return {
            'question': '主管要求員工下班後用通訊軟體交辦工作，且必須在一小時內回覆並交出檔案，請問是否構成加班？',
            'options': [
              'A. 不構成，因為員工是在家裡，沒有在辦公室刷卡。',
              'B. 構成，只要雇主下班後指派任務且勞工實際提供勞務，即應核實計算加班時數並發給加班費。',
              'C. 不構成，除非主管發訊息時有打出「我要發加班費」這幾個字。'
            ],
            'correctIndex': 1,
            'explanation': '勞基法以實質提供勞務作為工時認定基準，雇主於工作時間外以通訊軟體指派工作，勞工可記錄起迄時間並要求加班費。',
          };
        case 'STEP 3':
          return {
            'question': '員工請病假，公司在薪資單中扣除全額當日工資，並扣發當月全額全勤獎金，是否合法？',
            'options': [
              'A. 合法，請假沒上班本來就不能領薪水。',
              'B. 不合法，勞工請假規則規定普通病假一年內未超過 30 日者工資折半發給，且不得因病假扣發全勤獎金。',
              'C. 合法，全勤獎金是獎勵，公司有權決定發放標準。'
            ],
            'correctIndex': 1,
            'explanation': '依法普通病假應給予半薪。此外，性別工作平等法及相關函釋亦規定，不得因病假或生理假扣發全勤獎金。',
          };
        case 'STEP 4':
          return {
            'question': '公司因業務緊縮需要裁員，以下哪項是雇主必須履行的法定程序？',
            'options': [
              'A. 提前告知即可，不需要支付資遣費. ',
              'B. 必須發給資遣費、依年資提前預告（或給付預告工資），並開立非自願離職證明書。',
              'C. 只要在年終獎金發放後，雇主即可隨時開除且不需任何程序。'
            ],
            'correctIndex': 1,
            'explanation': '雇主依勞基法第11條資遣員工時，必須依法發給資遣費、符合法定預告期間，並依就業服務法進行通報及發給非自願離職證明。',
          };
        case 'STEP 5':
          return {
            'question': '遭遇公司違法解雇或積欠加班費，勞工最快、最有效的政府行政救濟管道為何？',
            'options': [
              'A. 直接向法院提起刑事起訴。',
              'B. 向當地勞動局或勞工局申請「勞資爭議調解」，不需負擔訴訟費用且具有調解效力。',
              'C. 到公司門口抗議以引起輿論關注。'
            ],
            'correctIndex': 1,
            'explanation': '各地方政府勞工主管機關設有免費的「勞資爭議調解」機制，能快速協商並做成具有法律效力的調解成立書，是極為實用的救濟途徑。',
          };
      }
    }

    if (category == '網購消費') {
      switch (step) {
        case 'STEP 1':
          return {
            'question': '在網路購物買了一件衣服，收到後發現不喜歡，在第 5 天申請退貨。賣家以「商品無瑕疵、出貨前已告知不能退」為由拒絕，合理嗎？',
            'options': [
              'A. 合理，買賣講求誠信，買家不能反悔。',
              'B. 不合理，消保法第19條規定，通訊交易消費者享有 7 天無條件解除契約退貨權，無須說明理由，賣家不得拒絕。',
              'C. 合理，必須有重大破損才能申請退款。'
            ],
            'correctIndex': 1,
            'explanation': '消保法第19條定義網路購物（通訊交易）消費者 7 天鑑賞期，可無條件退貨，商家在網頁上自訂的「不退換」條款無效。',
          };
        case 'STEP 2':
          return {
            'question': '網路買家主張 7 天鑑賞期退貨，賣家同意退款，但要求買家必須負擔商品寄回的 60 元運費，這樣合法嗎？',
            'options': [
              'A. 合理，退貨運費本來就該由買家自行承擔。',
              'B. 不合法，消保法明文規定，解除契約後退回商品之費用（包含運費）應由企業經營者負擔。',
              'C. 合法，只要賣家在出貨前有特別聲明即可。'
            ],
            'correctIndex': 1,
            'explanation': '依消保法第19條，消費者退回商品無須負擔任何費用或對價，退回運費依法應由賣家（企業經營者）負擔。',
          };
        case 'STEP 3':
          return {
            'question': '某知名電商將原價 3 萬元的筆電標錯價為 3000 元，買家立刻下單並刷卡付款成功，系統也自動發送訂單確認信。事後電商表示不予出貨，合理嗎？',
            'options': [
              'A. 合理，標錯價屬於重大錯誤，買賣契約不成立。',
              'B. 不合理，網路交易定型化契約規定，一旦付款成功且契約成立，賣家即負有依約出貨之義務。',
              'C. 合理，只要電商願意補償 500 元折價券就可以取消訂單。'
            ],
            'correctIndex': 1,
            'explanation': '經濟部網路零售定型化契約規範，消費者下單且契約成立（刷卡成功、系統發送確認等）後，企業應履行契約，標錯價不能作為片面解約的藉口。',
          };
        case 'STEP 4':
          return {
            'question': '以下哪一種網購商品，依法可以「排除」 7 天無條件退貨鑑賞期的適用？',
            'options': [
              'A. 衣服、包包與鞋子。',
              'B. 易於腐敗、保存期限較短之生鮮食品（如蛋糕、水果）或已拆封之個人衛生用品（如內衣褲）。',
              'C. 所有在國外代購的電子產品。'
            ],
            'correctIndex': 1,
            'explanation': '消保法授權訂定之「通訊交易解除權合理例外情事適用準則」，排除了生鮮食品、客製化給付、報紙雜誌、已拆封個人衛生用品等的鑑賞期適用。',
          };
        case 'STEP 5':
          return {
            'question': '網購發生爭議與賣家協商無果，消費者可向哪一個政府管道提起申訴與調解？',
            'options': [
              'A. 撥打 1950 全國消費者服務專線，或至行政院消保會網站提起「消費爭議申訴」。',
              'B. 直接到警察局檢舉賣家詐欺罪。',
              'C. 向公平交易委員會仲裁。'
            ],
            'correctIndex': 0,
            'explanation': '消費者可透過「1950」專線或各縣市政府消保官提起一至二次消費爭議申訴，若仍未解決，可申請消費爭議調解委員會調解。',
          };
      }
    }

    if (category == '個資隱私') {
      switch (step) {
        case 'STEP 1':
          return {
            'question': '依個資法規定，以下哪一項資訊單獨或結合其他資料，不屬於受個資法保護的「個人資料」？',
            'options': [
              'A. 身分證字號、姓名、病歷、聯絡電話、指紋。',
              'B. 純粹匿名化、且無法以任何方式還原或連結到特定個人的去識別化統計數據。',
              'C. 公司的統一編號、登記地址與負責人姓名。'
            ],
            'correctIndex': 1,
            'explanation': '個資法保護的是「自然人」的個人資料，且必須是能直接或間接識別該個人的資料。完全去識別化或法人的工商資料不適用個資法。',
          };
        case 'STEP 2':
          return {
            'question': '某健身房取得顧客電話進行推銷，顧客在電話中表示「請不要再打來行銷了」，健身房隔週又換人打來，是否違法？',
            'options': [
              'A. 不違法，因為更換了不同的推銷專員，每次都是獨立事件。',
              'B. 違法，個資法規定當事人表示拒絕接受行銷後，業者應立即停止利用其個人資料進行行銷。',
              'C. 不違法，除非顧客親自到店填寫紙本拒絕聲明書。'
            ],
            'correctIndex': 1,
            'explanation': '個資法第20條第2項規定，當事人表示拒絕接受行銷時，委託或利用個資之業者應即停止行銷，違反者屬於違法利用個資。',
          };
        case 'STEP 3':
          return {
            'question': '房東因為跟房客吵架，將房客的身分證照片與合約內容拍照上傳到臉書社團「公審爆料」，這會面臨何種法律後果？',
            'options': [
              'A. 沒有後果，爆料事實屬於言論自由保障範疇。',
              'B. 涉犯個資法非法利用個資罪（刑事責任），且房客可請求精神慰撫金與名譽受損之民事賠償。',
              'C. 僅會被臉書下架貼文，無實質法律責任。'
            ],
            'correctIndex': 1,
            'explanation': '未經同意且非出於公益等法定事由，將他人身分隱私資料公開散布，侵害隱私權，觸犯個資法刑事罪，並須負民事侵權賠償責任。',
          };
        case 'STEP 4':
          return {
            'question': '鄰居在公用樓梯間安裝監視器，鏡頭角度可清楚拍到己方進出大門與家中的內部陳設，此舉在法律上如何定性？',
            'options': [
              'A. 不合法，侵害他人非公開之生活與居住隱私，涉犯刑法妨害秘密罪，並構成民事侵權。',
              'B. 合法，樓梯間是公共空間，任何人都可以自由裝設監視器。',
              'C. 合法，只要鄰居承諾監視畫面不會洩漏給第三人看即可。'
            ],
            'correctIndex': 0,
            'explanation': '即使是公共樓梯間，亦不得裝設鏡頭正對他人住家大門或內部隱私空間，否則即構成妨害他人非公開活動，侵害隱私權並觸犯刑法。',
          };
        case 'STEP 5':
          return {
            'question': '當我們不再使用某個網路服務時，依法是否有權要求該平台刪除他們所收集的所有個人帳號與隱私資料？',
            'options': [
              'A. 沒有，平台有權永久保留其資料庫中收集到的任何數據。',
              'B. 有權，個資法第3條規定當事人享有請求停止收集、處理、利用或「請求刪除」之法定權利。',
              'C. 只有付費用戶才有權要求刪除個資。'
            ],
            'correctIndex': 1,
            'explanation': '個資法第3條規定，當事人對於其個人資料享有請求停止收集、處理、利用以及請求刪除之權利，此為法定權利，平台不得以服務契約排除。',
          };
      }
    }

    return null;
  }

  void _submitQuizAnswer() {
    final quiz = _quizData;
    if (_selectedQuizIndex == null || _isQuizAnswered || quiz == null) return;

    final isCorrect = _selectedQuizIndex == quiz['correctIndex'];
    if (isCorrect) {
      // 答對了！記錄進度並給 XP
      if (widget.unitStepLabel != null) {
        final gameState = LearningGameState.instance;
        final cat = widget.category ?? widget.article.category ?? _guessCategory(widget.article.title);
        final uniqueStepId = "${cat}_${widget.unitStepLabel}";
        final isFirstTimeComplete = !gameState.completedSteps.contains(uniqueStepId);

        gameState.completeStep(uniqueStepId);

        // 如果是最後一個單元 (STEP 5) 且是首次通關
        if (widget.unitStepLabel == 'STEP 5' && isFirstTimeComplete) {
          Future.delayed(const Duration(milliseconds: 600), () {
            _showCompletionDialog();
          });
        }
      } else {
        LearningGameState.instance.addExperience(20); // 動態專題答對直接給 20 XP
      }
    } else {
      // 答錯，加進錯題本
      LearningGameState.instance.addIncorrectQuestion(
        quiz['question'],
        quiz['options'][_selectedQuizIndex!],
        quiz['options'][quiz['correctIndex']],
        quiz['explanation'],
      );
    }

    // 紀錄答題歷史
    final cat = widget.category ?? widget.article.category ?? _guessCategory(widget.article.title);
    LearningGameState.instance.recordQuizHistory(
      question: quiz['question'],
      options: List<String>.from(quiz['options']),
      selectedAnswer: quiz['options'][_selectedQuizIndex!],
      correctAnswer: quiz['options'][quiz['correctIndex']],
      isCorrect: isCorrect,
      category: cat,
      stepLabel: widget.unitStepLabel ?? '專題測驗',
      explanation: quiz['explanation'],
    );

    setState(() {
      _isQuizAnswered = true;
    });
  }

  void _showNotebookBottomSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gameState = LearningGameState.instance;
    final noteController = TextEditingController(text: gameState.getArticleNote(widget.article.title));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ListenableBuilder(
          listenable: gameState,
          builder: (context, _) {
            // 取得該文章的劃記重點
            final articleHighlights = gameState.savedHighlights
                .where((item) => item['articleTitle'] == widget.article.title)
                .toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161C23) : const Color(0xFFFBF8F5),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.r),
                  topRight: Radius.circular(24.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10.r,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // 頂部把手
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 5.h,
                      margin: EdgeInsets.symmetric(vertical: 12.h),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                  // 標題
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CtmSvgIcon(
                              CtmSvgIcons.filePen,
                              size: 22.sp,
                              color: HomeV2Palette.trustGreen,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              '專題學習筆記本',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(Icons.close, size: 20.sp, color: Colors.grey),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1.h, color: Colors.grey.shade300),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                      children: [
                        // 1. 自訂筆記區
                        Text(
                          '📝 我的學習心得與筆記',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                            color: HomeV2Palette.trustGreen,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF232A33) : const Color(0xFFFFFDF9),
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: isDark ? Colors.transparent : const Color(0xFFE9DFD2),
                              width: 1.2.w,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 4.r,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: noteController,
                            maxLines: 4,
                            onChanged: (val) {
                              gameState.setArticleNote(widget.article.title, val);
                            },
                            style: TextStyle(
                              fontSize: 13.5.sp,
                              height: 1.45,
                              color: AppColors.textPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: '在此寫下您的理解或心得筆記，系統會自動儲存...',
                              hintStyle: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.grey.shade400,
                              ),
                              contentPadding: EdgeInsets.all(14.w),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        SizedBox(height: 24.h),

                        // 2. 劃記重點區
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '✍️ 本單元劃記重點 (${articleHighlights.length})',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w800,
                                color: HomeV2Palette.trustGreen,
                              ),
                            ),
                            if (articleHighlights.isNotEmpty)
                              Text(
                                '提示：選取正文文字也可劃記',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.grey,
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        if (articleHighlights.isEmpty)
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: Colors.grey.shade300, width: 0.8.w),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.edit_note, size: 32.sp, color: Colors.grey.shade400),
                                SizedBox(height: 8.h),
                                Text(
                                  '目前尚無劃記重點\n您可以選取正文中的文字，並點擊「劃記重點 ✍️」將其存入這裡。',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    height: 1.45,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          ...List.generate(articleHighlights.length, (index) {
                            final highlightText = articleHighlights[index]['highlight'] as String;
                            // 找出當前重點在 gameState.savedHighlights 中的真實全域 index
                            final globalIndex = gameState.savedHighlights.indexOf(articleHighlights[index]);
                            return Container(
                              margin: EdgeInsets.only(bottom: 8.h),
                              padding: EdgeInsets.fromLTRB(12.w, 10.h, 6.w, 10.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFCEE),
                                border: Border.all(color: const Color(0xFFFBE4A2), width: 1.w),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      highlightText,
                                      style: TextStyle(
                                        fontSize: 12.5.sp,
                                        height: 1.4,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete_outline, size: 18.sp, color: Colors.red.shade400),
                                    onPressed: () {
                                      if (globalIndex != -1) {
                                        gameState.removeHighlight(globalIndex);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          }),
                        SizedBox(height: 24.h),

                        // 3. 快速點選核心重點 (不必選取文字即可劃記)
                        Text(
                          '💡 快速將核心思考點加入筆記',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                            color: HomeV2Palette.trustGreen,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        ...widget.article.keyPoints.map((point) {
                          final isPointHighlighted = articleHighlights.any((item) => item['highlight'] == point);
                          return Container(
                            margin: EdgeInsets.only(bottom: 8.h),
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF232A33) : Colors.white,
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                color: isPointHighlighted ? const Color(0xFFFBE4A2) : Colors.grey.shade300,
                                width: 1.w,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    point,
                                    style: TextStyle(
                                      fontSize: 12.5.sp,
                                      height: 1.45,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () {
                                    if (isPointHighlighted) {
                                      // 移除劃記
                                      final matchIndex = gameState.savedHighlights.indexWhere(
                                        (item) => item['highlight'] == point && item['articleTitle'] == widget.article.title
                                      );
                                      if (matchIndex != -1) {
                                        gameState.removeHighlight(matchIndex);
                                      }
                                    } else {
                                      // 新增劃記
                                      gameState.addHighlight(point, widget.article.title);
                                    }
                                  },
                                  icon: Icon(
                                    isPointHighlighted ? Icons.check_circle : Icons.add_circle_outline,
                                    size: 16.sp,
                                    color: isPointHighlighted ? const Color(0xFFE8B85F) : HomeV2Palette.trustGreen,
                                  ),
                                  label: Text(
                                    isPointHighlighted ? '已收錄' : '劃記',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                      color: isPointHighlighted ? const Color(0xFFE8B85F) : HomeV2Palette.trustGreen,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gameState = LearningGameState.instance;
    final cat = widget.category ?? widget.article.category ?? _guessCategory(widget.article.title);
    final isStepCompleted = widget.unitStepLabel != null && gameState.completedSteps.contains("${cat}_${widget.unitStepLabel}");
    final quiz = _quizData;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.article.category ?? _guessCategory(widget.article.title),
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          ListenableBuilder(
            listenable: gameState,
            builder: (context, _) {
              final isBookmarked = gameState.isArticleSaved(widget.article.title);
              return IconButton(
                icon: CtmSvgIcon(
                  isBookmarked ? _svgStarFilledIcon : _svgStarOutlineIcon,
                  size: 22.sp,
                  color: isBookmarked ? const Color(0xFFD6A85F) : Colors.grey,
                ),
                tooltip: isBookmarked ? '取消收藏' : '加入收藏',
                onPressed: () {
                  gameState.toggleArticleSave(widget.article.title);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        gameState.isArticleSaved(widget.article.title)
                            ? '已加入我的收藏！'
                            : '已取消收藏！',
                      ),
                      backgroundColor: HomeV2Palette.trustGreen,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              );
            },
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: ListenableBuilder(
        listenable: gameState,
        builder: (context, _) {
          // 取得當前單元已劃記的重點列表
          final currentHighlights = gameState.savedHighlights
              .where((item) => item['articleTitle'] == widget.article.title)
              .map((item) => item['highlight'] as String)
              .toList();

          return NotebookBackground(
            child: ListView(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 80.h), // 底部留白以防阻擋懸浮按鈕
              children: [
                // 1. 主卡片
                NotebookCard(
                  backgroundColor: isDark ? const Color(0xFF161C23) : Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: HomeV2Palette.mint,
                          borderRadius: BorderRadius.circular(999.r),
                        ),
                        child: Text(
                          widget.article.readTime,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: HomeV2Palette.trustGreen,
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        widget.article.title,
                        style: TextStyle(
                          fontSize: 20.sp,
                          height: 1.25,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      HighlightedSelectableText(
                        text: widget.article.summary,
                        highlights: currentHighlights,
                        style: TextStyle(
                          fontSize: 14.sp,
                          height: 1.55,
                          color: AppColors.textSecondary,
                        ),
                        articleTitle: widget.article.title,
                      ),
                      SizedBox(height: 18.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF232A33) : const Color(0xFFF7F2EA),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(color: isDark ? Colors.transparent : const Color(0xFFE9DFD2)),
                        ),
                        child: HighlightedSelectableText(
                          text: widget.article.heroNote,
                          highlights: currentHighlights,
                          style: TextStyle(
                            fontSize: 13.5.sp,
                            height: 1.55,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.orange.shade100 : const Color(0xFF6B5439),
                          ),
                          articleTitle: widget.article.title,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 14.h),

                // 2. 重點思考框
                Text(
                  '💡 三個核心法律思考點',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 12.h),
                ...widget.article.keyPoints.map((point) {
                  final isPointSaved = gameState.isQuoteSaved(point);
                  return NotebookCard(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                    margin: EdgeInsets.only(bottom: 10.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 2.h),
                          child: CtmSvgIcon(
                            CtmSvgIcons.star,
                            size: 16.sp,
                            color: HomeV2Palette.trustGreen,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            point,
                            style: TextStyle(
                              fontSize: 13.5.sp,
                              height: 1.45,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: CtmSvgIcon(
                            CtmSvgIcons.star,
                            size: 18.sp,
                            color: isPointSaved ? const Color(0xFFE8B85F) : Colors.grey.shade300,
                          ),
                          onPressed: () {
                            gameState.toggleQuoteSave(point, widget.article.title);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  gameState.isQuoteSaved(point)
                                      ? '已成功將金句收藏至備忘錄！'
                                      : '已取消收藏金句！',
                                ),
                                backgroundColor: HomeV2Palette.trustGreen,
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }),

                SizedBox(height: 18.h),

                // 3. 詳細章節
                ...widget.article.sections.map(
                  (section) => NotebookCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          section.title,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: HomeV2Palette.trustGreen,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        HighlightedSelectableText(
                          text: section.body,
                          highlights: currentHighlights,
                          style: TextStyle(
                            fontSize: 13.5.sp,
                            height: 1.6,
                            color: AppColors.textSecondary,
                          ),
                          articleTitle: widget.article.title,
                        ),
                      ],
                    ),
                  ),
                ),

                // 4. 嵌入的思辨小測驗
                if (quiz != null) ...[
                  SizedBox(height: 20.h),
                  Text(
                    '📝 課堂思辨小測試',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  NotebookCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isStepCompleted) ...[
                          Row(
                            children: [
                              CtmSvgIcon(CtmSvgIcons.star, color: HomeV2Palette.trustGreen, size: 24.sp),
                              SizedBox(width: 8.w),
                              const Text('本單元測驗已通關！', style: TextStyle(fontWeight: FontWeight.bold, color: HomeV2Palette.trustGreen)),
                            ],
                          ),
                          SizedBox(height: 8.h),
                        ],
                        Text(
                          quiz['question'],
                          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        SizedBox(height: 14.h),
                        ...List.generate(quiz['options'].length, (index) {
                          final isSelected = _selectedQuizIndex == index;
                          final isCorrect = _isQuizAnswered && index == quiz['correctIndex'];
                          final isWrong = _isQuizAnswered && isSelected && index != quiz['correctIndex'];

                          Color optionBg = Colors.white;
                          Color optionBorder = const Color(0xFFECE6DB);
                          if (isCorrect || (isStepCompleted && index == quiz['correctIndex'])) {
                            optionBg = const Color(0xFFEAF6E2);
                            optionBorder = const Color(0xFF9EC979);
                          } else if (isWrong) {
                            optionBg = const Color(0xFFFBE8E7);
                            optionBorder = const Color(0xFFE4A29D);
                          } else if (isSelected) {
                            optionBg = const Color(0xFFFFFAEC);
                            optionBorder = const Color(0xFFE8B95F);
                          }

                          Widget optionIcon;
                          if (isCorrect || (isStepCompleted && index == quiz['correctIndex'])) {
                            optionIcon = CtmSvgIcon(CtmSvgIcons.star, color: Colors.green, size: 18.sp);
                          } else if (isWrong) {
                            optionIcon = CtmSvgIcon(CtmSvgIcons.xCircle, color: Colors.red, size: 18.sp);
                          } else if (isSelected) {
                            optionIcon = CtmSvgIcon(CtmSvgIcons.star, color: const Color(0xFFE8B95F), size: 18.sp);
                          } else {
                            optionIcon = Container(
                              width: 18.w,
                              height: 18.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey, width: 1.5.w),
                              ),
                            );
                          }

                          return Padding(
                            padding: EdgeInsets.only(bottom: 8.h),
                            child: InkWell(
                              onTap: (_isQuizAnswered || isStepCompleted) ? null : () {
                                setState(() {
                                  _selectedQuizIndex = index;
                                });
                              },
                              borderRadius: BorderRadius.circular(10.r),
                              child: Container(
                                padding: EdgeInsets.all(12.w),
                                decoration: BoxDecoration(
                                  color: optionBg,
                                  border: Border.all(color: optionBorder, width: 1.2.w),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Row(
                                  children: [
                                    optionIcon,
                                    SizedBox(width: 8.w),
                                    Expanded(
                                      child: Text(
                                        quiz['options'][index],
                                        style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                        SizedBox(height: 12.h),
                        if (!_isQuizAnswered && !isStepCompleted)
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: _selectedQuizIndex == null ? null : _submitQuizAnswer,
                              style: FilledButton.styleFrom(backgroundColor: HomeV2Palette.trustGreen),
                              child: const Text('送出答案'),
                            ),
                          )
                        else ...[
                          // 答題後的動態吉祥物與泡泡反饋區
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 44.w,
                                height: 44.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: HomeV2Palette.trustGreen, width: 1.5.w),
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    gameState.mascotAsset,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.all(12.w),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1E2622) : const Color(0xFFF2FAF6),
                                    border: Border.all(
                                      color: isDark ? const Color(0xFF2E3C36) : const Color(0xFFD2E6DE),
                                      width: 1.2.w,
                                    ),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(2.r),
                                      topRight: Radius.circular(12.r),
                                      bottomLeft: Radius.circular(12.r),
                                      bottomRight: Radius.circular(12.r),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        (_isQuizAnswered && _selectedQuizIndex == quiz['correctIndex']) || isStepCompleted
                                            ? '🎉 答對了！恭喜！'
                                            : '❌ 答錯了，再接再厲！',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13.sp,
                                          color: isDark ? const Color(0xFF99C3B3) : const Color(0xFF1B4D3E),
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        (_isQuizAnswered && _selectedQuizIndex == quiz['correctIndex']) || isStepCompleted
                                            ? '您表現得非常好，真不愧是「${gameState.levelTitle} ${gameState.mascotExpression}」！獲得 20 XP！'
                                            : '沒關係，小法助已經把這道錯題記錄在您的「錯題本」了。先看看白話判決解析，再重新溫習吧！',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          height: 1.4,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          // 白話解析框
                          Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF232A33) : const Color(0xFFF7F2EA),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: isDark ? Colors.transparent : const Color(0xFFE9DFD2),
                                width: 1.w,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CtmSvgIcon(
                                      CtmSvgIcons.gavel,
                                      size: 16.sp,
                                      color: const Color(0xFF94610D),
                                    ),
                                    SizedBox(width: 6.w),
                                    Text(
                                      '白話判決解析',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13.sp,
                                        color: const Color(0xFF94610D),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 6.h),
                                Text(
                                  quiz['explanation'],
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    height: 1.45,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'learning_notebook_fab',
            onPressed: () => _showNotebookBottomSheet(context),
            backgroundColor: isDark ? const Color(0xFF1E2622) : const Color(0xFFF7F2EA),
            shape: CircleBorder(
              side: BorderSide(
                color: HomeV2Palette.trustGreen,
                width: 1.5.w,
              ),
            ),
            elevation: 8,
            child: ClipOval(
              child: Image.asset(
                'assets/images/learning/legal_notebook_icon.png',
                fit: BoxFit.cover,
                width: 56.w,
                height: 56.w,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          ListenableBuilder(
            listenable: gameState,
            builder: (context, _) {
              return FloatingActionButton(
                heroTag: 'mascot_ai_assistant_fab',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => LawAssistantSearchPage(
                        initialPrompt: '我正在學《${widget.article.title}》，想問問小法助關於這個主題的細節：',
                      ),
                    ),
                  );
                },
                backgroundColor: HomeV2Palette.mint,
                shape: CircleBorder(
                  side: BorderSide(
                    color: HomeV2Palette.trustGreen,
                    width: 1.5.w,
                  ),
                ),
                elevation: 8, // 更懸浮一點
                child: ClipOval(
                  child: Image.asset(
                    gameState.mascotAsset,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog() {
    HapticFeedback.mediumImpact();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cat = widget.category ?? widget.article.category ?? _guessCategory(widget.article.title);

    String badgeName = '租屋達人';
    switch (cat) {
      case '租屋糾紛':
        badgeName = '租屋達人';
        break;
      case '車禍事故':
        badgeName = '車禍防護';
        break;
      case '職場權益':
        badgeName = '職場精英';
        break;
      case '網購消費':
        badgeName = '消費專家';
        break;
      case '個資隱私':
        badgeName = '網路先鋒';
        break;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(20.w, 50.h, 20.w, 24.h),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E2732) : Colors.white,
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '🎉 恭喜通關！',
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w900,
                        color: HomeV2Palette.trustGreen,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '您已完成「$cat」主修專題的所有單元',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.grey[300] : Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: HomeV2Palette.trustGreen.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: HomeV2Palette.trustGreen.withValues(alpha: 0.15)),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.stars, color: const Color(0xFFE8B95F), size: 48.sp),
                          SizedBox(height: 6.h),
                          Text(
                            '解鎖榮譽徽章',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            '「$badgeName」',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 18.h),
                    Text(
                      '🌳 您的法學智慧樹已獲得巨大成長能量！\n快去成就室澆灌它吧！',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.sp,
                        height: 1.5,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('留在本專題'),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: HomeV2Palette.trustGreen,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const AchievementRoomPage(),
                                ),
                              );
                            },
                            child: const Text('前往成就室'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24.r),
                    child: const _ConfettiWidget(),
                  ),
                ),
              ),
              Positioned(
                top: -30.h,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8B95F),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.celebration, color: Colors.white, size: 28.sp),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class HighlightedSelectableText extends StatelessWidget {
  const HighlightedSelectableText({
    super.key,
    required this.text,
    required this.highlights,
    required this.style,
    required this.articleTitle,
  });

  final String text;
  final List<String> highlights;
  final TextStyle style;
  final String articleTitle;

  @override
  Widget build(BuildContext context) {
    if (highlights.isEmpty || text.isEmpty) {
      return SelectableText(
        text,
        style: style,
        contextMenuBuilder: _buildContextMenu,
      );
    }

    final List<_TextRange> ranges = [];
    for (final highlight in highlights) {
      if (highlight.trim().isEmpty) continue;
      int start = 0;
      while (true) {
        final index = text.indexOf(highlight, start);
        if (index == -1) break;
        ranges.add(_TextRange(index, index + highlight.length));
        start = index + highlight.length;
      }
    }

    if (ranges.isEmpty) {
      return SelectableText(
        text,
        style: style,
        contextMenuBuilder: _buildContextMenu,
      );
    }

    ranges.sort((a, b) => a.start.compareTo(b.start));
    final List<_TextRange> mergedRanges = [];
    _TextRange? currentRange = ranges.first;
    for (int i = 1; i < ranges.length; i++) {
      final nextRange = ranges[i];
      if (nextRange.start <= currentRange!.end) {
        if (nextRange.end > currentRange.end) {
          currentRange = _TextRange(currentRange.start, nextRange.end);
        }
      } else {
        mergedRanges.add(currentRange);
        currentRange = nextRange;
      }
    }
    if (currentRange != null) {
      mergedRanges.add(currentRange);
    }

    final List<TextSpan> spans = [];
    int currentIndex = 0;
    for (final range in mergedRanges) {
      if (range.start > currentIndex) {
        spans.add(TextSpan(text: text.substring(currentIndex, range.start)));
      }
      final highlightStr = text.substring(range.start, range.end);
      spans.add(TextSpan(
        text: highlightStr,
        style: TextStyle(
          backgroundColor: Colors.yellow.withOpacity(0.45),
        ),
        recognizer: LongPressGestureRecognizer()..onLongPress = () {
          _showShareCardDialog(context, highlightStr, articleTitle);
        },
      ));
      currentIndex = range.end;
    }
    if (currentIndex < text.length) {
      spans.add(TextSpan(text: text.substring(currentIndex)));
    }

    return SelectableText.rich(
      TextSpan(
        style: style,
        children: spans,
      ),
      contextMenuBuilder: _buildContextMenu,
    );
  }

  Widget _buildContextMenu(BuildContext context, EditableTextState editableTextState) {
    final List<ContextMenuButtonItem> buttonItems = editableTextState.contextMenuButtonItems;
    final selection = editableTextState.textEditingValue.selection;
    if (!selection.isCollapsed && selection.start >= 0 && selection.end <= text.length) {
      final selectedText = text.substring(selection.start, selection.end);
      if (selectedText.trim().isNotEmpty) {
        buttonItems.add(
          ContextMenuButtonItem(
            label: '劃記重點 ✍️',
            onPressed: () {
              LearningGameState.instance.addHighlight(selectedText, articleTitle);
              editableTextState.hideToolbar();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('已成功劃記此重點並儲存至成就室備忘錄！'),
                  backgroundColor: HomeV2Palette.trustGreen,
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        );
      }
    }
    return AdaptiveTextSelectionToolbar.buttonItems(
      anchors: editableTextState.contextMenuAnchors,
      buttonItems: buttonItems,
    );
  }
}

class _TextRange {
  final int start;
  final int end;
  _TextRange(this.start, this.end);
}

void _showShareCardDialog(BuildContext context, String highlightText, String articleTitle) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 卡片主體
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E2622) : const Color(0xFFFFFBF3),
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                  color: isDark ? const Color(0xFF2E3C36) : const Color(0xFFE9DFD2),
                  width: 1.5.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15.r,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.format_quote_rounded,
                        size: 32.sp,
                        color: HomeV2Palette.trustGreen.withOpacity(0.4),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Text(
                      highlightText,
                      style: TextStyle(
                        fontSize: 16.sp,
                        height: 1.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.yellow.withOpacity(0.6),
                        decorationThickness: 4,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Transform.rotate(
                        angle: 3.14159,
                        child: Icon(
                          Icons.format_quote_rounded,
                          size: 32.sp,
                          color: HomeV2Palette.trustGreen.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '—— 摘自《$articleTitle》',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: HomeV2Palette.trustGreen,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '小法助 • 隨身法律避坑筆記',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: '$highlightText\n\n—— 摘自《$articleTitle》• 小法助'));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('已複製重點及來源文字！'),
                        backgroundColor: HomeV2Palette.trustGreen,
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: HomeV2Palette.trustGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(99.r),
                      side: BorderSide(color: HomeV2Palette.trustGreen, width: 1.2.w),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  ),
                  icon: Icon(Icons.copy_rounded, size: 16.sp),
                  label: const Text('複製文字'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('🎨 成功產生精美圖卡！已儲存至相簿，您可以直接分享！'),
                        backgroundColor: HomeV2Palette.trustGreen,
                        action: SnackBarAction(
                          label: '分享',
                          textColor: Colors.white,
                          onPressed: () {},
                        ),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HomeV2Palette.trustGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(99.r),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  ),
                  icon: Icon(Icons.share_rounded, size: 16.sp),
                  label: const Text('分享圖卡'),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

class _ConfettiParticle {
  _ConfettiParticle({
    required this.color,
    required this.startX,
    required this.speedY,
    required this.speedX,
    required this.size,
    required this.rotationSpeed,
    required this.isRibbon,
  });

  final Color color;
  final double startX;
  final double speedY;
  final double speedX;
  final double size;
  final double rotationSpeed;
  final bool isRibbon;

  double x = 0;
  double y = 0;
  double angle = 0;

  void update(double value, double width, double height) {
    y = value * height * speedY - 30;
    x = startX + math.sin(value * 8) * speedX * width;
    angle = value * 10 * rotationSpeed;
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({
    required this.particles,
    required this.animationValue,
  });

  final List<_ConfettiParticle> particles;
  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in particles) {
      p.update(animationValue, size.width, size.height);

      if (p.y < -30 || p.y > size.height + 30) continue;

      canvas.save();
      canvas.translate(p.x, p.y);
      canvas.rotate(p.angle);
      paint.color = p.color;

      if (p.isRibbon) {
        final path = Path();
        path.moveTo(-p.size / 2, -p.size);
        path.quadraticBezierTo(p.size / 2, -p.size / 2, -p.size / 2, 0);
        path.quadraticBezierTo(p.size / 2, p.size / 2, -p.size / 2, p.size);
        path.lineTo(p.size / 2, p.size);
        path.quadraticBezierTo(-p.size / 2, p.size / 2, p.size / 2, 0);
        path.quadraticBezierTo(-p.size / 2, -p.size / 2, p.size / 2, -p.size);
        path.close();
        canvas.drawPath(path, paint);
      } else {
        canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}

class _ConfettiWidget extends StatefulWidget {
  const _ConfettiWidget();

  @override
  State<_ConfettiWidget> createState() => _ConfettiWidgetState();
}

class _ConfettiWidgetState extends State<_ConfettiWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_ConfettiParticle> _particles = [];
  final math.Random _random = math.Random();

  final List<Color> _colors = const [
    Color(0xFFFFADAD),
    Color(0xFFFFD6A5),
    Color(0xFFFDFFB6),
    Color(0xFFCAFFBF),
    Color(0xFF9BF6FF),
    Color(0xFFA0C4FF),
    Color(0xFFBDB2FF),
    Color(0xFFFFC6FF),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..forward();

    for (int i = 0; i < 45; i++) {
      _particles.add(
        _ConfettiParticle(
          color: _colors[_random.nextInt(_colors.length)],
          startX: _random.nextDouble() * 320.w,
          speedY: 0.8 + _random.nextDouble() * 0.5,
          speedX: 0.05 + _random.nextDouble() * 0.1,
          size: 6.r + _random.nextDouble() * 8.r,
          rotationSpeed: 0.5 + _random.nextDouble() * 1.5,
          isRibbon: _random.nextBool(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          size: Size(double.infinity, 350.h),
          painter: _ConfettiPainter(
            particles: _particles,
            animationValue: _controller.value,
          ),
        );
      },
    );
  }
}
