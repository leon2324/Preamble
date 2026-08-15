import 'package:preamble/data/documents/document_models.dart';
import 'package:preamble/data/law_assistant/law_assistant_models.dart';
import 'package:preamble/data/lawyer/lawyer_models.dart';

/// 智慧案件打包器：自動將 AI 對話或動態書狀結構收斂為標準委任簡報。
class CaseBriefPackager {
  const CaseBriefPackager._();

  /// 從 AI 小法助訊息打包
  static CaseBrief fromAssistantMessage(LawAssistantMessage message) {
    final insight = message.insight;
    final category = insight?.disputeCategory ?? '一般法律爭議';
    final fact = message.answer?.problemDirection.isNotEmpty == true
        ? '${message.answer!.problemDirection}\n${message.answer!.relatedContent}'
        : message.content;

    return CaseBrief(
      disputeCategory: category,
      factSummary: fact.isNotEmpty ? fact : '使用者於小法助諮詢之案件事實。',
      demands: message.answer?.recommendedActions.isNotEmpty == true
          ? [message.answer!.recommendedActions]
          : ['尋求專業律師審核並評估訴訟/協商可行性'],
      evidences: insight?.keyEvidences ??
          (message.answer?.evidenceNeeded.isNotEmpty == true
              ? [message.answer!.evidenceNeeded]
              : const ['相關通訊對話紀錄與單據']),
      possibleLegalBasis: message.citations?.map((c) => c.title).toList() ?? [],
      opponentProfile: '相對人',
    );
  }

  /// 從動態法律公文結構打包
  static CaseBrief fromDynamicDocument(DynamicLegalDocument doc) {
    return CaseBrief(
      disputeCategory: doc.title,
      factSummary: doc.sections.map((s) => '${s.heading}：${s.body}').join('\n\n'),
      demands: doc.demands,
      evidences: doc.evidences,
      possibleLegalBasis: doc.legalBasis,
      opponentProfile: doc.receiverName,
    );
  }
}

/// 認證執業律師檢索庫與預約管理倉庫
class LawyerRepository {
  LawyerRepository();

  static const List<LawyerProfile> _certifiedLawyers = [
    LawyerProfile(
      id: 'lawyer-01',
      name: '林承翰',
      title: '資深合夥律師',
      firmName: '誠品聯合法律事務所',
      avatarUrl: '',
      specialties: [
        LawyerSpecialty.rentalAndRealEstate,
        LawyerSpecialty.generalCivil,
      ],
      yearsOfExperience: 12,
      successfulCasesCount: 180,
      rating: 4.98,
      reviewsCount: 142,
      location: '台北市大安區',
      consultationFeeLabel: 'NT\$ 2,500 / 30分',
      bio: '專精不動產租賃、拆屋還地、押金損害賠償與強制執行。曾任地方法院調解委員。',
      isTopRecommended: true,
    ),
    LawyerProfile(
      id: 'lawyer-02',
      name: '張雅筑',
      title: '主理律師',
      firmName: '德承法律事務所',
      avatarUrl: '',
      specialties: [
        LawyerSpecialty.laborAndEmployment,
        LawyerSpecialty.corporateAndPartnership,
      ],
      yearsOfExperience: 9,
      successfulCasesCount: 120,
      rating: 4.95,
      reviewsCount: 88,
      location: '台北市中山區',
      consultationFeeLabel: 'NT\$ 2,200 / 30分',
      bio: '專注勞基法爭議、非法解僱、加班費及資遣費討回、合夥股權拆夥結算。',
      isTopRecommended: true,
    ),
    LawyerProfile(
      id: 'lawyer-03',
      name: '陳柏宇',
      title: '執業律師',
      firmName: '正言法律事務所',
      avatarUrl: '',
      specialties: [
        LawyerSpecialty.carAccidentAndTort,
        LawyerSpecialty.generalCivil,
      ],
      yearsOfExperience: 7,
      successfulCasesCount: 95,
      rating: 4.92,
      reviewsCount: 65,
      location: '新北市板橋區',
      consultationFeeLabel: 'NT\$ 1,800 / 30分',
      bio: '專辦交通事故過失傷害、車輛折舊與人傷求償理賠、相鄰噪音氣響侵權。',
      isTopRecommended: false,
    ),
    LawyerProfile(
      id: 'lawyer-04',
      name: '黃怡君',
      title: '專利智財律師',
      firmName: '創智國際法律事務所',
      avatarUrl: '',
      specialties: [
        LawyerSpecialty.intellectualProperty,
        LawyerSpecialty.corporateAndPartnership,
      ],
      yearsOfExperience: 10,
      successfulCasesCount: 110,
      rating: 4.97,
      reviewsCount: 79,
      location: '新竹市東區',
      consultationFeeLabel: 'NT\$ 3,000 / 30分',
      bio: '專精著作權盜用侵權、商標侵權保全、商業保密協議 (NDA) 與軟體著作權合約。',
      isTopRecommended: false,
    ),
  ];

  /// 取得所有認證律師
  List<LawyerProfile> getAllLawyers() => List.unmodifiable(_certifiedLawyers);

  /// 依糾紛案由智慧推薦最適律師
  List<LawyerProfile> getRecommendedLawyersForCategory(String categoryText) {
    final text = categoryText.toLowerCase();

    LawyerSpecialty target = LawyerSpecialty.generalCivil;
    if (text.contains('租') || text.contains('房') || text.contains('漏水')) {
      target = LawyerSpecialty.rentalAndRealEstate;
    } else if (text.contains('車禍') || text.contains('撞') || text.contains('噪音')) {
      target = LawyerSpecialty.carAccidentAndTort;
    } else if (text.contains('勞') || text.contains('薪') || text.contains('資遣') || text.contains('加班')) {
      target = LawyerSpecialty.laborAndEmployment;
    } else if (text.contains('合夥') || text.contains('拆夥') || text.contains('工程') || text.contains('公司')) {
      target = LawyerSpecialty.corporateAndPartnership;
    } else if (text.contains('著作') || text.contains('侵權') || text.contains('商標') || text.contains('盜用')) {
      target = LawyerSpecialty.intellectualProperty;
    }

    final matched = _certifiedLawyers.where((l) => l.specialties.contains(target)).toList();
    if (matched.isNotEmpty) return matched;
    return _certifiedLawyers;
  }

  /// 提交預約諮詢
  Future<LawyerConsultationBooking> submitBooking({
    required LawyerProfile lawyer,
    required String clientName,
    required String clientPhone,
    required String consultationType,
    required String preferredDate,
    required CaseBrief brief,
  }) async {
    // 模擬網絡通訊與律師端案件推播
    await Future.delayed(const Duration(milliseconds: 600));

    return LawyerConsultationBooking(
      id: 'booking-${DateTime.now().millisecondsSinceEpoch}',
      lawyerId: lawyer.id,
      lawyerName: lawyer.name,
      clientName: clientName,
      clientPhone: clientPhone,
      consultationType: consultationType,
      preferredDate: preferredDate,
      caseBrief: brief,
      createdAt: DateTime.now(),
      isConfirmed: true,
    );
  }
}
