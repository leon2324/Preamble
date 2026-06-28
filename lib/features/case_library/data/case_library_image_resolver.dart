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
          'https://upload.wikimedia.org/wikipedia/commons/e/ec/Sunflower_Movement_protests_inside_Legislative_Yuan_20140319.jpg',
      source: 'Wikimedia Commons 授權照片：太陽花學運立法院議場內部，對應集會遊行與國會程序爭議。',
    ),
    CaseImage(
      url:
          'https://upload.wikimedia.org/wikipedia/commons/f/fb/Sunflower_Movement_2014-03-24.jpg',
      source: 'Wikimedia Commons 授權照片：太陽花學運抗議現場，對應社會運動與公共秩序議題。',
    ),
  ],
  '748': [
    CaseImage(
      url:
          'https://upload.wikimedia.org/wikipedia/commons/b/b3/Judicial_Yuan_Republic_of_China.jpg',
      source: 'Wikimedia Commons 授權照片：司法院建築，對應同性婚姻釋憲與憲法裁判脈絡。',
    ),
  ],
  '799': [
    CaseImage(
      url:
          'https://upload.wikimedia.org/wikipedia/commons/b/b3/Judicial_Yuan_Republic_of_China.jpg',
      source: 'Wikimedia Commons 授權照片：司法院建築，對應強制治療釋憲與人身自由審查。',
    ),
  ],
  '499': [
    CaseImage(
      url:
          'https://upload.wikimedia.org/wikipedia/commons/b/b3/Judicial_Yuan_Republic_of_China.jpg',
      source: 'Wikimedia Commons 授權照片：司法院建築，對應修憲程序釋憲與民主憲政秩序。',
    ),
  ],
  'cheng-2021': [
    CaseImage(
      url:
          'https://upload.wikimedia.org/wikipedia/commons/b/b3/Judicial_Yuan_Republic_of_China.jpg',
      source: '授權清楚之司法機關示意照片：對應再審、無罪推定與刑事救濟分類。',
    ),
  ],
  'hung-2013': [
    CaseImage(
      url:
          'https://upload.wikimedia.org/wikipedia/commons/b/b3/Judicial_Yuan_Republic_of_China.jpg',
      source: '授權清楚之司法機關示意照片：對應軍事司法、人身自由與審判權限分類。',
    ),
  ],
  '124': [
    CaseImage(
      url:
          'https://upload.wikimedia.org/wikipedia/commons/b/b3/Judicial_Yuan_Republic_of_China.jpg',
      source: '授權清楚之司法機關示意照片：對應重大交通事故後續刑事審判分類。',
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
        source: '案件圖書館內建示意圖：重大交通與公共安全案件尚未取得可商用真實照片。',
      ),
    ];
  }
  if (book.category == '兒少保護' || book.tags.any((tag) => tag.contains('兒少'))) {
    return const [
      CaseImage(
        url: 'assets/images/case_library_v2/daily_hunting.png',
        source: '案件圖書館內建示意圖：兒少保護案件避免使用可辨識當事人照片。',
      ),
    ];
  }
  return const [];
}

const _judicialFallbackImages = [
  CaseImage(
    url:
        'https://upload.wikimedia.org/wikipedia/commons/b/b3/Judicial_Yuan_Republic_of_China.jpg',
    source: 'Wikimedia Commons 授權照片：司法院建築，作為憲法裁判與司法解釋分類照片。',
  ),
];

const _generalLegalFallbackImages = [
  CaseImage(
    url: 'assets/images/case_library_v2/case_library_v2_case_book_cover.png',
    source: '案件圖書館內建示意圖：尚未取得授權清楚且可對應案件內容的真實照片。',
  ),
];
