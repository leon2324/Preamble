import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/features/case_library/data/case_library_data.dart';
import 'package:preamble/features/case_library/pages/case_dossier_detail_page.dart';
import 'package:preamble/features/case_library/theme/case_library_theme.dart';

enum WikilinkType { caseItem, lawArticle, legalConcept }

class WikilinkEntry {
  const WikilinkEntry({
    required this.term,
    required this.type,
    required this.title,
    required this.citation,
    required this.summary,
    this.targetCaseId,
    this.targetLawArticle,
  });

  final String term;
  final WikilinkType type;
  final String title;
  final String citation;
  final String summary;
  final String? targetCaseId;
  final String? targetLawArticle;
}

/// 維基百科式「文字內連圖譜資料庫」（Wikipedia Wikilink Registry）。
///
/// 登錄所有真實重大判決、憲法解釋、法律條文及關鍵法學術語，
/// 在卷宗文本中出現時自動生成超連結，形成彼此參照的法律知識網絡。
class WikipediaWikilinkService {
  static final List<WikilinkEntry> entries = [
    // --- 經典裁判與憲法解釋 ---
    const WikilinkEntry(
      term: '釋字第748號',
      type: WikilinkType.caseItem,
      title: '司法院釋字第 748 號解釋（同性婚姻平權案）',
      citation: '司法院釋字第748號解釋（2017/05/24公布）',
      summary:
          '宣告民法婚姻章未保障同性別二人成立婚姻關係違憲，侵害憲法第22條婚姻自由與第7條平等權，限期兩年立法保障。',
      targetCaseId: '101',
    ),
    const WikilinkEntry(
      term: '釋字748',
      type: WikilinkType.caseItem,
      title: '司法院釋字第 748 號解釋（同性婚姻平權案）',
      citation: '司法院釋字第748號解釋（2017/05/24公布）',
      summary:
          '宣告民法未保障同婚違憲，催生亞洲首部同婚專法《司法院釋字第七四八號解釋施行法》。',
      targetCaseId: '101',
    ),
    const WikilinkEntry(
      term: '113年憲判字第8號',
      type: WikilinkType.caseItem,
      title: '憲法法庭 113 年憲判字第 8 號判決（死刑合憲性與最嚴格程序限制案）',
      citation: '113年憲判字第8號（2024/09/20宣判，審判長許宗力，主筆黃昭元）',
      summary:
          '死刑作為法定刑合憲，但僅得適用於個案犯罪情節達「最嚴重」程度，且審判程序須受各級法院一致決、強制辯護與心智缺陷豁免等最嚴密程序保障。',
      targetCaseId: '103',
    ),
    const WikilinkEntry(
      term: '釋字第791號',
      type: WikilinkType.caseItem,
      title: '司法院釋字第 791 號解釋（通姦罪違憲除罪化案）',
      citation: '司法院釋字第791號解釋（2020/05/29公布，審判長許宗力）',
      summary:
          '刑法第239條通姦罪侵害憲法第22條性自主權，不符比例原則，宣告自公布日起立即失效；刑事訴訟法第239條但書亦違反平等權失效。',
      targetCaseId: 'case-adultery-791',
    ),
    const WikilinkEntry(
      term: '釋字第803號',
      type: WikilinkType.caseItem,
      title: '司法院釋字第 803 號解釋（王光祿原住民狩獵文化權案）',
      citation: '司法院釋字第803號解釋（2021/05/07公布，審判長許宗力）',
      summary:
          '肯認原住民傳統狩獵為憲法保障之文化權；槍砲彈藥許可辦法限制獵槍規格違憲限期修正，王光祿後續改判無罪確定。',
      targetCaseId: 'case-indigenous-hunt-803',
    ),
    const WikilinkEntry(
      term: 'RCA案',
      type: WikilinkType.caseItem,
      title: '台灣美國無線電公司 RCA 毒物公害集體訴訟',
      citation: '最高法院 107 年度台上字第 1358 號民事判決（2018/08/16宣判）',
      summary:
          '確立揭穿公司面紗原則，裁定控制公司負連帶賠償責任；認定被告時效抗辯構成權利濫用，創立流行病學因果關係倒置舉證標準。',
      targetCaseId: '106',
    ),
    const WikilinkEntry(
      term: '江國慶案',
      type: WikilinkType.caseItem,
      title: '空軍作戰司令部江國慶冤獄錯殺平反案',
      citation: '國防部北部地方軍事法院 100 年度再字第 001 號再審無罪判決（2011/09/13）',
      summary:
          '空軍非法刑求逼供導致役男江國慶遭錯殺，再審改判無罪定讞，獲發刑事補償金1億318萬元，並促成軍事審判法全面改革。',
      targetCaseId: '104',
    ),
    const WikilinkEntry(
      term: '太陽花學運',
      type: WikilinkType.caseItem,
      title: '318太陽花學運佔領立法院妨害公務案',
      citation: '臺灣高等法院 106 年度矚上訴字第 1 號刑事判決（2018/03/13定讞）',
      summary:
          '法院肯定「公民不服從」七大要件，以阻卻違法事由判處黃國昌等22人全部無罪確定；最高法院後續並肯認憲法抵抗權概念。',
      targetCaseId: '318',
    ),
    const WikilinkEntry(
      term: '徐自強案',
      type: WikilinkType.caseItem,
      title: '徐自強綁架勒贖更審平反無罪定讞案',
      citation: '最高法院 105 年度台上字第 2570 號刑事判決（2016/10/13定讞）',
      summary:
          '歷經九次更審，大法官作成釋字第582號解釋，確立共犯未經對質詰問之自白不得作為唯一證據，洗刷徐自強死刑冤屈獲判無罪。',
      targetCaseId: 'case-hsu-tzu-chiang-582',
    ),
    const WikilinkEntry(
      term: '111年憲判字第8號',
      type: WikilinkType.caseItem,
      title: '憲法法庭 111 年憲判字第 8 號判決（跨國父母搶女與子女最佳利益案）',
      citation: '111年憲判字第8號（2022/05/27宣判，審判長許宗力）',
      summary:
          '廢棄最高法院強制交付子女裁定，確立法院處理跨國親權應親自聽取未成年子女陳述，貫徹未成年子女最佳利益之憲法原則。',
      targetCaseId: 'case-cross-border-111',
    ),
    const WikilinkEntry(
      term: '台開案',
      type: WikilinkType.caseItem,
      title: '台開股票重大內線交易案',
      citation: '最高法院 110 年度台上字第 1342 號刑事判決（2021/10/14定讞）',
      summary:
          '纏訟16年定讞，釐清證券交易法第157條之1重大消息明確時點，以及第171條加重內線交易罪犯罪所得之計算基準。',
      targetCaseId: 'case-taikai-insider-1342',
    ),
    const WikilinkEntry(
      term: '張榮發遺囑案',
      type: WikilinkType.caseItem,
      title: '長榮集團創辦人張榮發密封遺囑效力確認案',
      citation: '最高法院 112 年度台上字第 1764 號民事判決（2024/08定讞）',
      summary:
          '駁回上訴確認張榮發密封遺囑具法律效力，符合民法第1192條法定形式要件；其餘繼承人仍得依法主張民法第1225條特留分扣減權。',
      targetCaseId: 'case-chang-will-1764',
    ),
    const WikilinkEntry(
      term: '梁孟松',
      type: WikilinkType.caseItem,
      title: '台積電控告梁孟松競業禁止與營業秘密案',
      citation: '最高法院 104 年度台上字第 1589 號民事判決（2015/08/24定讞）',
      summary:
          '創下競業禁止期限屆滿後仍受禁止任職之先例，引進不可避免揭露原則（Inevitable Disclosure），保護半導體核心營業秘密。',
      targetCaseId: 'case-tsmc-secret-1589',
    ),
    const WikilinkEntry(
      term: '蘇建和案',
      type: WikilinkType.caseItem,
      title: '蘇建和三人強盜殺人再審無罪判決定讞案',
      citation: '最高法院 101 年度台上字第 4500 號刑事判決（2012/08/31定讞）',
      summary:
          '歷經21年纏訟、非常上訴與再審，排除不正訊問自白，嚴格貫徹無罪推定原則與李昌鈺博士鑑識意見，依速審法判決無罪確定。',
      targetCaseId: 'case-su-chien-ho',
    ),
    const WikilinkEntry(
      term: '最高法院101年度台上字第4500號',
      type: WikilinkType.caseItem,
      title: '最高法院 101 年度台上字第 4500 號刑事判決（蘇建和案無罪確定）',
      citation: '最高法院 101 年度台上字第 4500 號刑事判決（審判長石木欽）',
      summary:
          '駁回檢察官上訴，確立偵查機關取得自白必須具有任意性與真實補強，宣告蘇建和、劉秉 dried、莊林勳無罪定讞。',
      targetCaseId: 'case-su-chien-ho',
    ),
    const WikilinkEntry(
      term: 'RCA公害案',
      type: WikilinkType.caseItem,
      title: '台灣美國無線電公司 RCA 毒物公害集體訴訟',
      citation: '最高法院 107 年度台上字第 267 號民事判決（2018/08/16宣判）',
      summary:
          '確立揭穿公司面紗原則，認定被告時效抗辯為權利濫用，創立流行病學因果關係倒置舉證標準，判賠上億元確定。',
      targetCaseId: 'case-rca-pollution',
    ),
    const WikilinkEntry(
      term: '最高法院107年度台上字第267號',
      type: WikilinkType.caseItem,
      title: '最高法院 107 年度台上字第 267 號民事判決（RCA集體求償定讞判決）',
      citation: '最高法院 107 年度台上字第 267 號民事判決（審判長林大洋）',
      summary:
          '肯認公害集體訴訟因果關係得採疫學因果關係，凡接觸達一定劑量罹病即推定因果關係，並命跨國母公司負連帶賠償責任。',
      targetCaseId: 'case-rca-pollution',
    ),
    const WikilinkEntry(
      term: '湯英伸案',
      type: WikilinkType.caseItem,
      title: '曹族青年湯英伸洗衣店命案與死刑法理思辨',
      citation: '最高法院 75 年度台上字第 5006 號刑事判決（1986/10/24定讞）',
      summary:
          '鄒族青年求職遭扣押身分證與高壓勞動，失控殺害雇主一家。判處死刑定讞執行，促成原住民族權益覺醒與洗刷吳鳳神話運動。',
      targetCaseId: 'case-tang-ying-shen',
    ),
    const WikilinkEntry(
      term: '最高法院75年度台上字第5006號',
      type: WikilinkType.caseItem,
      title: '最高法院 75 年度台上字第 5006 號刑事判決（湯英伸案死刑定讞判決）',
      citation: '最高法院 75 年度台上字第 5006 號刑事判決（審判長王德雲）',
      summary:
          '認定湯英伸殺害雇主一家三人手段殘酷，駁回上訴維持死刑判決。引發法界對於刑法第57條審酌生活狀況與弱勢困境之長遠思辨。',
      targetCaseId: 'case-tang-ying-shen',
    ),
    const WikilinkEntry(
      term: '跨國同婚首例勝訴',
      type: WikilinkType.caseItem,
      title: '祁家威跨國同性婚姻登記撤銷行政訴訟案',
      citation: '臺北高等行政法院 109 年度訴字第 1445 號判決（2021/03/04宣判）',
      summary:
          '引用涉外民事法律適用法反致原則與消極公序良俗，認定外國不承認同婚牴觸我國憲法保障婚姻自由，命戶政事務所准予結婚登記。',
      targetCaseId: 'case-cross-marriage-1445',
    ),
    const WikilinkEntry(
      term: '臺北高等行政法院109年度訴字第1445號',
      type: WikilinkType.caseItem,
      title: '臺北高等行政法院 109 年度訴字第 1445 號判決（跨國同婚首例准予登記）',
      citation: '臺北高等行政法院 109 年度訴字第 1445 號判決（審判長陳金圍）',
      summary:
          '開創跨國同性伴侶得依我國公序良俗排除不承認同婚母國法之先河，內政部後續亦全面鬆綁跨國同性婚姻登記規範。',
      targetCaseId: 'case-cross-marriage-1445',
    ),
    const WikilinkEntry(
      term: '112年憲判字第13號',
      type: WikilinkType.caseItem,
      title: '憲法法庭 112 年憲判字第 13 號判決（外役監條例受刑人平等權案）',
      citation: '112年憲判字第13號（2023/07/28宣判，審判長許宗力，主筆謝銘洋）',
      summary:
          '宣告外役監條例第4條第1項但書第1款一律排除受過有期徒刑執行之累犯遴選外役監，違反憲法第7條平等原則，二年內失效。',
      targetCaseId: 'case-prison-selection-13',
    ),

    // --- 核心法規條文 ---
    const WikilinkEntry(
      term: '憲法第7條',
      type: WikilinkType.lawArticle,
      title: '中華民國憲法 第 7 條（平等權原則）',
      citation: '憲法 第 7 條',
      summary:
          '中華民國人民，無分男女、宗教、種族、階級、黨派，在法律上一律平等。禁止無正當理由之差別待遇。',
      targetLawArticle: '憲法第7條',
    ),
    const WikilinkEntry(
      term: '憲法第8條',
      type: WikilinkType.lawArticle,
      title: '中華民國憲法 第 8 條（人身自由保障與正當法律程序）',
      citation: '憲法 第 8 條',
      summary:
          '人民身體之自由應予保障，除現行犯之逮捕由法律另定外，非經司法或警察機關依法定程序，不得逮捕拘禁。',
      targetLawArticle: '憲法第8條',
    ),
    const WikilinkEntry(
      term: '憲法第15條',
      type: WikilinkType.lawArticle,
      title: '中華民國憲法 第 15 條（生存權、工作權與財產權）',
      citation: '憲法 第 15 條',
      summary:
          '人民之生存權、工作權及財產權，應予保障。死刑爭議中生存權為最核心之憲法利益。',
      targetLawArticle: '憲法第15條',
    ),
    const WikilinkEntry(
      term: '憲法第22條',
      type: WikilinkType.lawArticle,
      title: '中華民國憲法 第 22 條（非列舉權與基本人權保障）',
      citation: '憲法 第 22 條',
      summary:
          '凡人民之其他自由及權利，不妨害社會秩序公共利益者，均受憲法之保障。包括婚姻自由、性自主權、隱私權與契約自由。',
      targetLawArticle: '憲法第22條',
    ),
    const WikilinkEntry(
      term: '憲法第23條',
      type: WikilinkType.lawArticle,
      title: '中華民國憲法 第 23 條（法律保留與比例原則）',
      citation: '憲法 第 23 條',
      summary:
          '除為防止妨礙他人自由、避免緊急危難、維持社會秩序，或增進公共利益所必要者外，不得以法律限制之。',
      targetLawArticle: '憲法第23條',
    ),
    const WikilinkEntry(
      term: '刑法第239條',
      type: WikilinkType.lawArticle,
      title: '中華民國刑法 第 239 條（通姦罪，已失效除罪化）',
      citation: '刑法 第 239 條（釋字791宣告立即失效）',
      summary:
          '原有配偶而與人通姦者處1年以下有期徒刑之規定，因過度干預婚姻私領域性自主權，已由釋字791宣告違憲除罪。',
      targetLawArticle: '刑法第239條',
    ),
    const WikilinkEntry(
      term: '刑法第271條',
      type: WikilinkType.lawArticle,
      title: '中華民國刑法 第 271 條（普通殺人罪）',
      citation: '刑法 第 271 條第 1 項',
      summary:
          '殺人者，處死刑、無期徒刑或十年以上有期徒刑。113憲判8限定死刑僅得適用於情節最嚴重之故意殺人罪行。',
      targetLawArticle: '刑法第271條',
    ),
    const WikilinkEntry(
      term: '勞動基準法第2條',
      type: WikilinkType.lawArticle,
      title: '勞動基準法 第 2 條（勞動契約與勞雇定義）',
      citation: '勞動基準法 第 2 條',
      summary:
          '定義勞工、雇主與勞動契約。實務採取人格、經濟與組織三從屬性檢驗平台外送員之僱傭關係。',
      targetLawArticle: '勞動基準法第2條',
    ),
    const WikilinkEntry(
      term: '民法第972條',
      type: WikilinkType.lawArticle,
      title: '中華民國民法 第 972 條（婚約之成立）',
      citation: '民法 第 972 條',
      summary:
          '婚約應由男女當事人自行訂定。釋字748認定未涵蓋同性伴侶違憲，促成同婚專法制定。',
      targetLawArticle: '民法第972條',
    ),
    const WikilinkEntry(
      term: '民法第1118條之1',
      type: WikilinkType.lawArticle,
      title: '中華民國民法 第 1118 條之 1（扶養義務之減輕或免除）',
      citation: '民法 第 1118 條之 1',
      summary:
          '受扶養權利者（如父母）若自幼對負扶養義務者無正當理由未盡扶養義務且情節重大，法院得裁定免除扶養義務。',
      targetLawArticle: '民法第1118條之1',
    ),
    const WikilinkEntry(
      term: '民法第1192條',
      type: WikilinkType.lawArticle,
      title: '中華民國民法 第 1192 條（密封遺囑之法定要件）',
      citation: '民法 第 1192 條',
      summary:
          '立遺囑人於遺囑上簽名後密封，向公證人提出並指定二人以上見證人，陳述其為自己之遺囑。長榮張榮發案認定符合此要件。',
      targetLawArticle: '民法第1192條',
    ),
    const WikilinkEntry(
      term: '民法第1225條',
      type: WikilinkType.lawArticle,
      title: '中華民國民法 第 1225 條（特留分之扣減權）',
      citation: '民法 第 1225 條',
      summary:
          '應得特留分之人，如因被繼承人所為之遺贈致其應得之數不足者，得按其不足之數由遺贈財產扣減之。',
      targetLawArticle: '民法第1225條',
    ),
    const WikilinkEntry(
      term: '營業秘密法第13條之1',
      type: WikilinkType.lawArticle,
      title: '營業秘密法 第 13 條之 1（侵害營業秘密之刑事責任）',
      citation: '營業秘密法 第 13 條之 1',
      summary:
          '以竊取、毀損、隱匿或未經授權重製等方式侵害他人營業秘密者，處五年以下有期徒刑；意圖在境外使用者加重處罰。',
      targetLawArticle: '營業秘密法第13條之1',
    ),
    const WikilinkEntry(
      term: '證券交易法第157條之1',
      type: WikilinkType.lawArticle,
      title: '證券交易法 第 157 條之 1（禁止內線交易規定）',
      citation: '證券交易法 第 157 條之 1',
      summary:
          '規範獲悉發行股票公司有重大影響其股票價格之消息時，在該消息未公開前或公開後一定時限內，不得買入或賣出該公司股票。',
      targetLawArticle: '證券交易法第157條之1',
    ),

    // --- 權威法學術語 ---
    const WikilinkEntry(
      term: '公民不服從',
      type: WikilinkType.legalConcept,
      title: '公民不服從（Civil Disobedience）',
      citation: '刑法超法規阻卻違法理論',
      summary:
          '基於憲政秩序維護或重大公共利益，以和平、非暴力且公開之最後手段，抗議政府重大違法或不義決策之抗爭行為。',
    ),
    const WikilinkEntry(
      term: '比例原則',
      type: WikilinkType.legalConcept,
      title: '比例原則（Principle of Proportionality）',
      citation: '憲法 第 23 條核心法理',
      summary:
          '國家公權力限制人民權利時，必須符合適當性原則、必要性原則（侵害最小手段）及狹義比例原則（衡量性）。',
    ),
    const WikilinkEntry(
      term: '正當法律程序',
      type: WikilinkType.legalConcept,
      title: '正當法律程序（Due Process of Law）',
      citation: '憲法 第 8 條與第 16 條',
      summary:
          '國家剝奪人民生命、身體或重大權益時，必須遵循公正、中立、公開之程序，保障受告知權、聽證權及受律師有效協助之權利。',
    ),
    const WikilinkEntry(
      term: '揭穿公司面紗',
      type: WikilinkType.legalConcept,
      title: '揭穿公司面紗原則（Piercing the Corporate Veil）',
      citation: '法人格否認法理',
      summary:
          '當控制股東或母公司濫用公司獨立法人格逃避債務或責任時，法院得穿透其法律外觀，命幕後實際控制者負連帶責任。',
    ),
    const WikilinkEntry(
      term: '嚴格證據法則',
      type: WikilinkType.legalConcept,
      title: '嚴格證據法則（Strict Rules of Evidence）',
      citation: '刑事訴訟法 第 154 條與第 155 條',
      summary:
          '認定犯罪事實所憑之證據，必須具備證據能力，且經合法之調查程序，始得作為判斷被告有罪之基礎。',
    ),
    const WikilinkEntry(
      term: '特留分',
      type: WikilinkType.legalConcept,
      title: '特留分（Legal Reserve / Forced Share）',
      citation: '民法 第 1223 條至第 1225 條',
      summary:
          '法律為保護法定繼承人最低限度之繼承權益，限制被繼承人以遺囑自由處分全部遺產之法定保留比例。',
    ),
    const WikilinkEntry(
      term: '實質從屬性',
      type: WikilinkType.legalConcept,
      title: '勞動契約之實質從屬性（Subordination Test）',
      citation: '勞動基準法 實務裁判認定標準',
      summary:
          '不拘泥於合約文字形式，綜合審查勞工在人格上是否受指揮監督、在經濟上是否自負盈虧、在組織上是否納入企業體系。',
    ),
    const WikilinkEntry(
      term: '不可避免揭露原則',
      type: WikilinkType.legalConcept,
      title: '不可避免揭露原則（Inevitable Disclosure Doctrine）',
      citation: '營業秘密法 司法裁判法理',
      summary:
          '高階研發人員轉任競爭對手從事高度相同職務時，若客觀上無法避免運用前雇主營業秘密，法院得核發預防性禁令禁止其就任。',
    ),
    const WikilinkEntry(
      term: '外役監條例第4條',
      type: WikilinkType.lawArticle,
      title: '外役監條例 第 4 條（受刑人遴選外役監之積極與消極資格）',
      citation: '外役監條例 第 4 條（112年憲判字第13號判決違憲宣告）',
      summary:
          '規範受刑人參加外役監遴選之條件。原規定累犯一律不得遴選，憲法法庭判決違反平等權定期失效，立法院後續修法改採個案實質審查。',
      targetLawArticle: '外役監條例第4條',
    ),
    const WikilinkEntry(
      term: '疫學因果關係',
      type: WikilinkType.legalConcept,
      title: '疫學因果關係理論（Epidemiological Causation）',
      citation: '民事公害侵權行為法理',
      summary:
          '在公害集體訴訟中，被害人難以就微觀毒理機制完全證明時，得依流行病學調查證明暴露與罹病存在高度統計關聯，進而倒置因果關係舉證責任。',
    ),
    const WikilinkEntry(
      term: '消極公序良俗',
      type: WikilinkType.legalConcept,
      title: '消極公序良俗（Negative Public Policy Clause）',
      citation: '涉外民事法律適用法 第 8 條',
      summary:
          '適用外國法若違反我國公共秩序或善良風俗時，不予適用。跨國同婚案以此排除外國不承認同婚之法律，保障婚姻自由憲法價值。',
    ),
    const WikilinkEntry(
      term: '反致原則',
      type: WikilinkType.legalConcept,
      title: '反致原則（Doctrine of Renvoi）',
      citation: '涉外民事法律適用法 第 6 條',
      summary:
          '依我國法應適用外國法時，若依該外國法之國際私法規定應適用我國法者，應適用中華民國法，以達成涉外案件法律適用之衡平。',
    ),
    const WikilinkEntry(
      term: '自白補強法則',
      type: WikilinkType.legalConcept,
      title: '自白補強法則（Corroboration Rule for Confession）',
      citation: '刑事訴訟法 第 156 條第 2 項',
      summary:
          '被告雖經自白，仍應調查其他必要之證據，以察其是否與事實相符。蘇建和案與徐自強案均重申不得以唯一自白作為有罪判決之基礎。',
    ),
  ];

  static WikilinkEntry? findEntry(String text) {
    for (final entry in entries) {
      if (entry.term == text) return entry;
    }
    return null;
  }
}

/// 維基百科式「富文本內連渲染器」（Wikipedia Wikilink Rich Text）。
///
/// 自動搜尋文本中出現的所有已登錄案件、法條及術語，為其套用維基藍色內連樣式與點擊浮動卡片。
class WikipediaWikilinkText extends StatelessWidget {
  const WikipediaWikilinkText({
    super.key,
    required this.text,
    required this.baseStyle,
  });

  final String text;
  final TextStyle baseStyle;

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) {
      return Text('', style: baseStyle);
    }

    final entries = WikipediaWikilinkService.entries;
    // Sort terms by length descending to match longest phrases first
    final sortedEntries = List<WikilinkEntry>.from(entries)
      ..sort((a, b) => b.term.length.compareTo(a.term.length));

    final pattern = sortedEntries.map((e) => RegExp.escape(e.term)).join('|');
    final regex = RegExp('($pattern)');
    final matches = regex.allMatches(text);

    if (matches.isEmpty) {
      return Text(text, style: baseStyle);
    }

    final spans = <InlineSpan>[];
    int lastEnd = 0;

    for (final match in matches) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: baseStyle,
        ));
      }

      final matchedTerm = match.group(0)!;
      final entry = sortedEntries.firstWhere((e) => e.term == matchedTerm);

      spans.add(TextSpan(
        text: matchedTerm,
        style: baseStyle.copyWith(
          color: const Color(0xFF1B65A4), // Classic Wikipedia Blue
          fontWeight: FontWeight.w700,
          decoration: TextDecoration.underline,
          decorationStyle: TextDecorationStyle.dotted,
          decorationColor: const Color(0xFF1B65A4).withValues(alpha: 0.6),
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            _showWikilinkHovercard(context, entry);
          },
      ));

      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: baseStyle,
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }

  static void _showWikilinkHovercard(
      BuildContext context, WikilinkEntry entry) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return Container(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
          decoration: BoxDecoration(
            color: CaseLibraryColors.bgWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top handle bar
                Center(
                  child: Container(
                    width: 36.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: CaseLibraryColors.borderLight,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 14.h),

                // Badge & Type
                Row(
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: _getBadgeColor(entry.type).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        _getBadgeLabel(entry.type),
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w900,
                          color: _getBadgeColor(entry.type),
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      color: CaseLibraryColors.textMuted,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => Navigator.of(bottomSheetContext).pop(),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),

                // Title
                Text(
                  entry.title,
                  style: TextStyle(
                    fontFamily: 'Songti TC',
                    fontFamilyFallback: const [
                      'BiauKai',
                      'Songti SC',
                      'STSong'
                    ],
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                    color: CaseLibraryColors.primaryGreen,
                    height: 1.35,
                  ),
                ),
                SizedBox(height: 4.h),

                // Citation
                Text(
                  entry.citation,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: CaseLibraryColors.accentGold,
                  ),
                ),
                SizedBox(height: 12.h),

                // Summary
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7FAF8),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: const Color(0xFFE2EBE5),
                      width: 1.0,
                    ),
                  ),
                  child: Text(
                    entry.summary,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: CaseLibraryColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ),
                SizedBox(height: 18.h),

                // Action Button (if navigatable)
                if (entry.targetCaseId != null)
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      color: CaseLibraryColors.primaryGreen,
                      borderRadius: BorderRadius.circular(10.r),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.menu_book_rounded,
                              size: 16, color: Colors.white),
                          SizedBox(width: 8.w),
                          Text(
                            '深入閱讀該案維基條目',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      onPressed: () {
                        Navigator.of(bottomSheetContext).pop();
                        final caseBook =
                            caseLibraryCaseById(entry.targetCaseId!);
                        Navigator.of(context).push(
                          CupertinoPageRoute<void>(
                            builder: (_) =>
                                CaseDossierDetailPage(book: caseBook),
                          ),
                        );
                      },
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      color: const Color(0xFFF0F4F8),
                      borderRadius: BorderRadius.circular(10.r),
                      child: Text(
                        '關閉速覽卡片',
                        style: TextStyle(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.bold,
                          color: CaseLibraryColors.primaryGreen,
                        ),
                      ),
                      onPressed: () => Navigator.of(bottomSheetContext).pop(),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  static String _getBadgeLabel(WikilinkType type) {
    switch (type) {
      case WikilinkType.caseItem:
        return '🏛️ 司法院／憲法法庭裁判條目';
      case WikilinkType.lawArticle:
        return '📜 實體法與程序法重要法規';
      case WikilinkType.legalConcept:
        return '📚 權威法學原則與爭議釋義';
    }
  }

  static Color _getBadgeColor(WikilinkType type) {
    switch (type) {
      case WikilinkType.caseItem:
        return CaseLibraryColors.primaryGreen;
      case WikilinkType.lawArticle:
        return const Color(0xFF1B65A4);
      case WikilinkType.legalConcept:
        return CaseLibraryColors.accentGold;
    }
  }
}
