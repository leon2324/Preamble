import 'package:preamble/features/case_library/models/case_library_models.dart';

/// 案件圖書館圖片解析器。
///
/// 維護原則：
/// 1. 優先使用官方機構發布、或 Wikimedia Commons 等授權條款清楚的圖片。
/// 2. 圖片必須能對應案件本身或案件分類，例如憲法裁判使用司法院/憲法法庭脈絡圖片。
/// 3. 找不到安全來源時，只回傳明確標示的示意圖，不把示意圖偽裝成真實案件照片。
/// 4. 不使用搜尋引擎縮圖、來源不明新聞圖、未確認授權的媒體照片。
List<CaseImage> resolveCaseLibraryImages(CaseBook book) {
  if (book.images.isNotEmpty && !_containsUnsafeImageHost(book.images)) {
    return book.images;
  }

  final curated = _curatedCaseImages[book.id];
  if (curated != null && curated.isNotEmpty) {
    return curated;
  }

  final categoryImages = _categoryFallbackImages(book);
  if (categoryImages.isNotEmpty) {
    return categoryImages;
  }

  return _generalLegalFallbackImages;
}

CaseImage? resolveCaseLibraryCoverImage(CaseBook book) {
  final images = resolveCaseLibraryImages(book);
  return images.isEmpty ? null : images.first;
}

bool _containsUnsafeImageHost(List<CaseImage> images) {
  return images.any((image) {
    final url = image.url.toLowerCase();
    return url.contains('tse') ||
        url.contains('bing.net') ||
        url.contains('pid=') ||
        url.contains('unsplash.com');
  });
}

const _curatedCaseImages = <String, List<CaseImage>>{
  '318': [
    CaseImage(
      url:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/17/Sunflower_Movement_collage.jpg/960px-Sunflower_Movement_collage.jpg',
      source: '【太陽花學運立法院議場與群眾實景】2014年3月反服貿學生與公民佔領立法院抗爭現場（Wikimedia Commons CC 授權）',
    ),
    CaseImage(
      url:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2b/Taipei_Sunflower_Movement_Lonely_Morning_Sunflower_%2813662063795%29.jpg/960px-Taipei_Sunflower_Movement_Lonely_Morning_Sunflower_%2813662063795%29.jpg',
      source: '【立法院周邊集會守夜實景】青島東路與濟南路靜坐群眾與太陽花象徵（Wikimedia Commons CC 授權）',
    ),
  ],
  '748': [
    CaseImage(
      url:
          'https://upload.wikimedia.org/wikipedia/commons/3/36/Same-sex-marriage-taiwan.jpg',
      source: '【同性婚姻釋憲公民集會實景】釋字第748號宣告民法未保障同婚違憲現場（Wikimedia Commons CC 授權）',
    ),
    CaseImage(
      url:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1f/Judicial_Yuan_Building_20140307.jpg/960px-Judicial_Yuan_Building_20140307.jpg',
      source: '【司法院憲法法庭所在地實景】司法院大廈外觀（Wikimedia Commons CC 授權）',
    ),
  ],
  '101': [
    CaseImage(
      url:
          'https://upload.wikimedia.org/wikipedia/commons/3/36/Same-sex-marriage-taiwan.jpg',
      source: '【同性婚姻釋憲公民集會實景】釋字第748號宣告民法未保障同婚違憲現場（Wikimedia Commons CC 授權）',
    ),
    CaseImage(
      url:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1f/Judicial_Yuan_Building_20140307.jpg/960px-Judicial_Yuan_Building_20140307.jpg',
      source: '【司法院憲法法庭所在地實景】司法院大廈外觀（Wikimedia Commons CC 授權）',
    ),
  ],
  '799': [
    CaseImage(
      url:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1f/Judicial_Yuan_Building_20140307.jpg/960px-Judicial_Yuan_Building_20140307.jpg',
      source: '【司法院大廈實景】大法官召開憲法法庭言詞辯論審理刑後強制治療制度（Wikimedia Commons CC 授權）',
    ),
    CaseImage(
      url:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4e/Judicial_Yuan_Building_20230503.jpg/960px-Judicial_Yuan_Building_20230503.jpg',
      source: '【司法院與憲法法庭建築】釋字第799號宣告強制治療應踐行正當法律程序（Wikimedia Commons CC 授權）',
    ),
  ],
  '499': [
    CaseImage(
      url:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4e/Judicial_Yuan_Building_20230503.jpg/960px-Judicial_Yuan_Building_20230503.jpg',
      source: '【司法院大廈實景】釋字第499號確立修憲有界限論與自由民主憲政秩序（Wikimedia Commons CC 授權）',
    ),
  ],
  '520': [
    CaseImage(
      url:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d2/Legislative_Yuan_Building_20240626.jpg/960px-Legislative_Yuan_Building_20240626.jpg',
      source: '【立法院院區實景】釋字第520號釐清行政院重大政策變更向立法院報告之憲法義務（Wikimedia Commons CC 授權）',
    ),
    CaseImage(
      url:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1f/Judicial_Yuan_Building_20140307.jpg/960px-Judicial_Yuan_Building_20140307.jpg',
      source: '【司法院大廈實景】大法官作成釋字第520號解釋（Wikimedia Commons CC 授權）',
    ),
  ],
  '102': [
    CaseImage(
      url:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1f/Judicial_Yuan_Building_20140307.jpg/960px-Judicial_Yuan_Building_20140307.jpg',
      source: '【司法院大廈實景】釋字第689號衡量新聞採訪自由與公共場域合理隱私期待（Wikimedia Commons CC 授權）',
    ),
  ],
  'cheng-2021': [
    CaseImage(
      url:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/2/22/2021%E5%B9%B4%E5%A4%AA%E9%AD%AF%E9%96%A3%E5%88%97%E8%BB%8A%E5%87%BA%E8%BB%8C%E4%BA%8B%E6%95%85_01.jpg/960px-2021%E5%B9%B4%E5%A4%AA%E9%AD%AF%E9%96%A3%E5%88%97%E8%BB%8A%E5%87%BA%E8%BB%8C%E4%BA%8B%E6%95%85_01.jpg',
      source: '【花蓮清水隧道太魯閣號事故現場真實照片】2021年4月2日工程車滑落軌道出軌搶救與採證現場（Wikimedia Commons CC 授權）',
    ),
    CaseImage(
      url:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/0/00/The_train_derailment_in_Hualien_2021-04-02.jpg/960px-The_train_derailment_in_Hualien_2021-04-02.jpg',
      source: '【清水隧道北口事故車廂實景】國家運輸安全調查委員會與救難人員現場勘查（Wikimedia Commons CC 授權）',
    ),
  ],
  '124': [
    CaseImage(
      url:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/2/22/2021%E5%B9%B4%E5%A4%AA%E9%AD%AF%E9%96%A3%E5%88%97%E8%BB%8A%E5%87%BA%E8%BB%8C%E4%BA%8B%E6%95%85_01.jpg/960px-2021%E5%B9%B4%E5%A4%AA%E9%AD%AF%E9%96%A3%E5%88%97%E8%BB%8A%E5%87%BA%E8%BB%8C%E4%BA%8B%E6%95%85_01.jpg',
      source: '【花蓮清水隧道太魯閣號事故現場真實照片】2021年4月2日工程車滑落軌道出軌搶救與採證現場（Wikimedia Commons CC 授權）',
    ),
    CaseImage(
      url:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/0/00/The_train_derailment_in_Hualien_2021-04-02.jpg/960px-The_train_derailment_in_Hualien_2021-04-02.jpg',
      source: '【清水隧道北口事故車廂實景】國家運輸安全調查委員會與救難人員現場勘查（Wikimedia Commons CC 授權）',
    ),
  ],
  'hung-2013': [
    CaseImage(
      url:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/Citizen_1985_from_VOA.jpg/960px-Citizen_1985_from_VOA.jpg',
      source: '【凱達格蘭大道白衫軍萬人集會真實照片】2013年8月公民1985行動聯盟聲援洪仲丘案促成軍審法修法（VOA 公有領域照片）',
    ),
    CaseImage(
      url:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f2/Citizen_1985_from_VOA_%281%29.jpg/960px-Citizen_1985_from_VOA_%281%29.jpg',
      source: '【白衫軍運動現場實景】二十五萬公民凱道集會要求軍中人權與真相調查（VOA 公有領域照片）',
    ),
  ],
  'case-formosa-incident': [
    CaseImage(
      url:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c8/%E7%BE%8E%E9%BA%97%E5%B3%B6%E9%9B%9C%E8%AA%8C_Formosa_-_The_Magazine_of_TAIWAN%27s_Democratic_Movement.jpg/960px-%E7%BE%8E%E9%BA%97%E5%B3%B6%E9%9B%9C%E8%AA%8C_Formosa_-_The_Magazine_of_TAIWAN%27s_Democratic_Movement.jpg',
      source: '【美麗島雜誌創刊號歷史實物】1979年黨外民主運動重要刊物與美麗島事件導火線（Wikimedia Commons CC 授權）',
    ),
    CaseImage(
      url:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/7/75/%E7%BE%8E%E9%BA%97%E5%B3%B6%E9%9B%9C%E8%AA%8C%E7%A4%BE%E9%AB%98%E9%9B%84%E6%9C%8D%E5%8B%99%E8%99%95%E5%8E%9F%E5%9D%80.JPG/960px-%E7%BE%8E%E9%BA%97%E5%B3%B6%E9%9B%9C%E8%AA%8C%E7%A4%BE%E9%AB%98%E9%9B%84%E6%9C%8D%E5%8B%99%E8%99%95%E5%8E%9F%E5%9D%80.JPG',
      source: '【美麗島雜誌社高雄服務處歷史原址】1979年12月10日世界人權日遊行集結地（Wikimedia Commons CC 授權）',
    ),
  ],
  'case-dapu-expropriation': [
    CaseImage(
      url:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/11/Miaoli_Dabu_Incident_717_Night_Watch_2.jpg/960px-Miaoli_Dabu_Incident_717_Night_Watch_2.jpg',
      source: '【苗栗大埔事件守夜抗爭真實照片】大埔居民與聲援公民反對違法區段徵收現場（Wikimedia Commons CC 授權）',
    ),
    CaseImage(
      url:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/6/63/Miaoli_Dabu_Incident_717_Night_Watch_3.jpg/960px-Miaoli_Dabu_Incident_717_Night_Watch_3.jpg',
      source: '【大埔事件農地與家園保衛集會】促成行政法院確立公益性與必要性實質審查基準（Wikimedia Commons CC 授權）',
    ),
  ],
  'case-delivery-labor-2152': [
    CaseImage(
      url:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/0/08/Food_cart_and_Foodpanda_scooter_at_Eslite_Spectrum_Nanxi_20190814.jpg/960px-Food_cart_and_Foodpanda_scooter_at_Eslite_Spectrum_Nanxi_20190814.jpg',
      source: '【台灣外送平台機車與保溫箱實景】最高法院113年度台上字第2152號審酌平台演算法與品牌裝備之從屬性（Wikimedia Commons CC 授權）',
    ),
    CaseImage(
      url:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b2/COMEBUY_Keelung_Qidu_Store_and_Foodpanda_scooter_20200913.jpg/960px-COMEBUY_Keelung_Qidu_Store_and_Foodpanda_scooter_20200913.jpg',
      source: '【外送員取單執勤街頭實景】平台經濟下人格、經濟與組織從屬性之實務爭點（Wikimedia Commons CC 授權）',
    ),
  ],
  'case-chang-will-1764': [
    CaseImage(
      url:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9c/Evergreen_Marine_Building_20190615.jpg/960px-Evergreen_Marine_Building_20190615.jpg',
      source: '【台北長榮海運大樓實景】長榮集團創辦人張榮發密封遺囑訴訟核心集團總部（Wikimedia Commons CC 授權）',
    ),
    CaseImage(
      url:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/5/52/Supreme_Court_of_the_ROC_front_view_20140307.jpg/960px-Supreme_Court_of_the_ROC_front_view_20140307.jpg',
      source: '【最高法院院舍實景】最高法院113年度台上字第1764號判決認定密封遺囑有效確定（Wikimedia Commons CC 授權）',
    ),
  ],
  'case-tsmc-secret-1589': [
    CaseImage(
      url:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7f/TSMC_Global_R%EF%BC%86D_Center.jpg/960px-TSMC_Global_R%EF%BC%86D_Center.jpg',
      source: '【台積電全球研發中心實景】半導體先進製程營業秘密保護與競業禁止訴訟核心場域（Wikimedia Commons CC 授權）',
    ),
    CaseImage(
      url:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8a/TSMC_Fab5.JPG/960px-TSMC_Fab5.JPG',
      source: '【新竹科學園區台積電廠區實景】最高法院確立高階主管重大核心營業秘密保護防線（Wikimedia Commons CC 授權）',
    ),
  ],
  'case-chiang-kuo-ching': [
    CaseImage(
      url:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5a/Control_Yuan_Building_20050702.jpg/960px-Control_Yuan_Building_20050702.jpg',
      source: '【監察院院舍實景】監察院調查報告糾正空軍反情報隊非法取供並促成江國慶案再審無罪平反（Wikimedia Commons CC 授權）',
    ),
    CaseImage(
      url:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1f/Judicial_Yuan_Building_20140307.jpg/960px-Judicial_Yuan_Building_20140307.jpg',
      source: '【司法院大廈實景】江國慶冤案促成刑事補償法修法與軍事審判制度改革（Wikimedia Commons CC 授權）',
    ),
  ],
  'case-su-chien-ho': [
    CaseImage(
      url:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/2/21/Criminal_Division_Building%2C_Taiwan_High_Court_20221113.jpg/960px-Criminal_Division_Building%2C_Taiwan_High_Court_20221113.jpg',
      source: '【臺灣高等法院刑事庭大廈實景】蘇建和等三人歷經21年審理於高院再更三審獲判無罪定讞之地（Wikimedia Commons CC 授權）',
    ),
    CaseImage(
      url:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/5/52/Supreme_Court_of_the_ROC_front_view_20140307.jpg/960px-Supreme_Court_of_the_ROC_front_view_20140307.jpg',
      source: '【最高法院院舍實景】確立嚴格證明法則、無罪推定與《刑事妥速審判法》防線（Wikimedia Commons CC 授權）',
    ),
  ],
  'case-hsu-tzu-chiang-582': [
    CaseImage(
      url:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1f/Judicial_Yuan_Building_20140307.jpg/960px-Judicial_Yuan_Building_20140307.jpg',
      source: '【司法院大廈實景】徐自強案聲請釋字第582號解釋確立共同被告自白須經對質詰問與補強證據（Wikimedia Commons CC 授權）',
    ),
    CaseImage(
      url:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/5/52/Supreme_Court_of_the_ROC_front_view_20140307.jpg/960px-Supreme_Court_of_the_ROC_front_view_20140307.jpg',
      source: '【最高法院院舍實景】最高法院105年度台上字第2571號判決徐自強無罪確定（Wikimedia Commons CC 授權）',
    ),
  ],
  'case-chiu-ho-shun': [
    CaseImage(
      url:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5a/Control_Yuan_Building_20050702.jpg/960px-Control_Yuan_Building_20050702.jpg',
      source: '【監察院院舍實景】監察院調查邱和順案員警刑求逼供與證物遺失爭議（Wikimedia Commons CC 授權）',
    ),
    CaseImage(
      url:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/5/52/Supreme_Court_of_the_ROC_front_view_20140307.jpg/960px-Supreme_Court_of_the_ROC_front_view_20140307.jpg',
      source: '【最高法院院舍實景】台灣司法史上羈押最久之刑事程序正義指標案件（Wikimedia Commons CC 授權）',
    ),
  ],
  'case-indigenous-hunt-803': [
    CaseImage(
      url:
          'https://upload.wikimedia.org/wikipedia/commons/7/7c/%E7%8D%B5%E4%BA%BA%E8%88%87%E6%9D%BE%E9%9B%B2%E9%9B%B2.jpg',
      source: '【台灣原住民族山林狩獵文化實景】釋字第803號肯認原住民族傳統狩獵文化權受憲法保障（Wikimedia Commons CC 授權）',
    ),
    CaseImage(
      url:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1f/Judicial_Yuan_Building_20140307.jpg/960px-Judicial_Yuan_Building_20140307.jpg',
      source: '【司法院大廈實景】大法官召開憲法法庭作成釋字第803號解釋（Wikimedia Commons CC 授權）',
    ),
  ],
  'case-adultery-791': [
    CaseImage(
      url:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4e/Judicial_Yuan_Building_20230503.jpg/960px-Judicial_Yuan_Building_20230503.jpg',
      source: '【司法院大廈實景】釋字第791號宣告刑法第239條通姦罪違反性自主權與比例原則立即失效（Wikimedia Commons CC 授權）',
    ),
  ],
  'case-support-exemption-1118': [
    CaseImage(
      url:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/5/52/Supreme_Court_of_the_ROC_front_view_20140307.jpg/960px-Supreme_Court_of_the_ROC_front_view_20140307.jpg',
      source: '【最高法院院舍實景】審酌父母無正當理由未盡扶養義務情節重大者得完全免除子女扶養義務（Wikimedia Commons CC 授權）',
    ),
  ],
  'case-rca-pollution': [
    CaseImage(
      url:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/5/52/Supreme_Court_of_the_ROC_front_view_20140307.jpg/960px-Supreme_Court_of_the_ROC_front_view_20140307.jpg',
      source: '【最高法院院舍實景】台灣史上最大規模職災公害團體訴訟，最高法院確立疫學因果關係與揭穿公司面紗原則（Wikimedia Commons CC 授權）',
    ),
  ],
  '106': [
    CaseImage(
      url:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/5/52/Supreme_Court_of_the_ROC_front_view_20140307.jpg/960px-Supreme_Court_of_the_ROC_front_view_20140307.jpg',
      source: '【最高法院院舍實景】台灣史上最大規模職災公害團體訴訟，最高法院確立疫學因果關係與揭穿公司面紗原則（Wikimedia Commons CC 授權）',
    ),
  ],
  'case-ting-hsin-oil': [
    CaseImage(
      url:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/4/41/Taiwan_High_Court_Taichung_Branch_Court_and_Taichung_High_Administrative_Court_20100810.jpg/960px-Taiwan_High_Court_Taichung_Branch_Court_and_Taichung_High_Administrative_Court_20100810.jpg',
      source: '【臺灣高等法院臺中分院實景】二審逆轉改判頂新製油案重刑並促成食安法攙偽假冒抽象危險犯修法（Wikimedia Commons CC 授權）',
    ),
  ],
  'ding-2015': [
    CaseImage(
      url:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/4/41/Taiwan_High_Court_Taichung_Branch_Court_and_Taichung_High_Administrative_Court_20100810.jpg/960px-Taiwan_High_Court_Taichung_Branch_Court_and_Taichung_High_Administrative_Court_20100810.jpg',
      source: '【臺灣高等法院臺中分院實景】二審逆轉改判頂新製油案重刑並促成食安法攙偽假冒抽象危險犯修法（Wikimedia Commons CC 授權）',
    ),
  ],
  'case-tang-ying-shen': [
    CaseImage(
      url:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/5/52/Supreme_Court_of_the_ROC_front_view_20140307.jpg/960px-Supreme_Court_of_the_ROC_front_view_20140307.jpg',
      source: '【最高法院院舍實景】1987年湯英伸案震撼台灣社會，促成《就業服務法》立法嚴禁扣留勞工身分證件（Wikimedia Commons CC 授權）',
    ),
  ],
  'case-cross-marriage-1445': [
    CaseImage(
      url:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/5/52/Supreme_Court_of_the_ROC_front_view_20140307.jpg/960px-Supreme_Court_of_the_ROC_front_view_20140307.jpg',
      source: '【最高法院院舍實景】涉外同性伴侶跨國結婚登記效力司法爭訟（Wikimedia Commons CC 授權）',
    ),
  ],
  'case-cross-border-111': [
    CaseImage(
      url:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1f/Judicial_Yuan_Building_20140307.jpg/960px-Judicial_Yuan_Building_20140307.jpg',
      source: '【司法院憲法法庭實景】111年憲判字第8號宣告跨國交付子女裁定應保障未成年子女法庭陳述權（Wikimedia Commons CC 授權）',
    ),
  ],
  'case-prison-selection-13': [
    CaseImage(
      url:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1f/Judicial_Yuan_Building_20140307.jpg/960px-Judicial_Yuan_Building_20140307.jpg',
      source: '【司法院憲法法庭實景】112年憲判字第13號審查外役監遴選除外條款平等原則爭議（Wikimedia Commons CC 授權）',
    ),
  ],
  'case-taikai-insider-1342': [
    CaseImage(
      url:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/5/52/Supreme_Court_of_the_ROC_front_view_20140307.jpg/960px-Supreme_Court_of_the_ROC_front_view_20140307.jpg',
      source: '【最高法院院舍實景】台開內線交易案與金融犯罪不法利得沒收計算基準（Wikimedia Commons CC 授權）',
    ),
  ],
};

List<CaseImage> _categoryFallbackImages(CaseBook book) {
  if (book.category == '司法解釋' || book.tags.any((tag) => tag.contains('憲'))) {
    return _judicialFallbackImages;
  }
  if (book.tags.any((tag) => tag.contains('交通') || tag.contains('鐵路'))) {
    return const [
      CaseImage(
        url: 'assets/images/case_library_v2/recent_housing.png',
        source: '情境示意圖（非本案當事人真實照片）：重大交通與公共安全案件示意圖。',
      ),
    ];
  }
  if (book.category == '兒少保護' || book.tags.any((tag) => tag.contains('兒少'))) {
    return const [
      CaseImage(
        url: 'assets/images/case_library_v2/daily_hunting.png',
        source: '情境示意圖（非本案當事人真實照片）：兒少保護案件依法隱蔽當事人可辨識影像。',
      ),
    ];
  }
  return const [];
}

const _judicialFallbackImages = [
  CaseImage(
    url:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1f/Judicial_Yuan_Building_20140307.jpg/960px-Judicial_Yuan_Building_20140307.jpg',
    source: '【司法院大廈實景】憲法裁判與司法解釋脈絡實景照片（Wikimedia Commons CC 授權）。',
  ),
];

const _generalLegalFallbackImages = [
  CaseImage(
    url: 'assets/images/case_library_v2/case_library_v2_case_book_cover.png',
    source: '情境示意圖（非本案真實現場照片）：案件圖書館內建編目示意封面。',
  ),
];
