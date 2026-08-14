/// 律師專長領域
enum LawyerSpecialty {
  rentalAndRealEstate,
  carAccidentAndTort,
  laborAndEmployment,
  corporateAndPartnership,
  intellectualProperty,
  generalCivil,
}

extension LawyerSpecialtyExt on LawyerSpecialty {
  String get label => switch (this) {
        LawyerSpecialty.rentalAndRealEstate => '不動產與租賃爭議',
        LawyerSpecialty.carAccidentAndTort => '交通事故與侵權求償',
        LawyerSpecialty.laborAndEmployment => '勞資糾紛與資遣協商',
        LawyerSpecialty.corporateAndPartnership => '合夥拆夥與公司商務',
        LawyerSpecialty.intellectualProperty => '著作權與智慧財產',
        LawyerSpecialty.generalCivil => '一般民事與債務清償',
      };
}

/// 認證執業律師個人檔案
class LawyerProfile {
  const LawyerProfile({
    required this.id,
    required this.name,
    required this.title,
    required this.firmName,
    required this.avatarUrl,
    required this.specialties,
    required this.yearsOfExperience,
    required this.successfulCasesCount,
    required this.rating,
    required this.reviewsCount,
    required this.location,
    required this.consultationFeeLabel,
    required this.bio,
    this.isTopRecommended = false,
  });

  final String id;
  final String name;
  final String title;
  final String firmName;
  final String avatarUrl;
  final List<LawyerSpecialty> specialties;
  final int yearsOfExperience;
  final int successfulCasesCount;
  final double rating;
  final int reviewsCount;
  final String location;
  final String consultationFeeLabel;
  final String bio;
  final bool isTopRecommended;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'title': title,
        'firmName': firmName,
        'avatarUrl': avatarUrl,
        'specialties': specialties.map((s) => s.name).toList(),
        'yearsOfExperience': yearsOfExperience,
        'successfulCasesCount': successfulCasesCount,
        'rating': rating,
        'reviewsCount': reviewsCount,
        'location': location,
        'consultationFeeLabel': consultationFeeLabel,
        'bio': bio,
        'isTopRecommended': isTopRecommended,
      };

  factory LawyerProfile.fromJson(Map<String, dynamic> json) {
    return LawyerProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      title: json['title'] as String? ?? '執業律師',
      firmName: json['firmName'] as String? ?? '聯合法律事務所',
      avatarUrl: json['avatarUrl'] as String? ?? '',
      specialties: (json['specialties'] as List<dynamic>?)
              ?.map((e) => LawyerSpecialty.values.firstWhere(
                    (s) => s.name == e.toString(),
                    orElse: () => LawyerSpecialty.generalCivil,
                  ))
              .toList() ??
          const [],
      yearsOfExperience: json['yearsOfExperience'] as int? ?? 5,
      successfulCasesCount: json['successfulCasesCount'] as int? ?? 50,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.9,
      reviewsCount: json['reviewsCount'] as int? ?? 30,
      location: json['location'] as String? ?? '台北市',
      consultationFeeLabel:
          json['consultationFeeLabel'] as String? ?? 'NT\$ 2,000 / 30分',
      bio: json['bio'] as String? ?? '',
      isTopRecommended: json['isTopRecommended'] == true,
    );
  }
}

/// 案件委任簡報（由 AI 自動打包萃取）
class CaseBrief {
  const CaseBrief({
    required this.disputeCategory,
    required this.factSummary,
    required this.demands,
    required this.evidences,
    required this.possibleLegalBasis,
    this.estimatedDisputeAmount = '',
    this.opponentProfile = '',
  });

  final String disputeCategory;
  final String factSummary;
  final List<String> demands;
  final List<String> evidences;
  final List<String> possibleLegalBasis;
  final String estimatedDisputeAmount;
  final String opponentProfile;

  String toFormattedBriefText() {
    final buffer = StringBuffer();
    buffer.writeln('【緒言 AI 案件委任簡報】');
    buffer.writeln('• 案由類別：$disputeCategory');
    if (estimatedDisputeAmount.isNotEmpty) {
      buffer.writeln('• 涉及爭議金額：$estimatedDisputeAmount');
    }
    buffer.writeln('• 案件事實摘要：\n$factSummary');
    buffer.writeln();
    buffer.writeln('• 主要訴求與主張：');
    for (var i = 0; i < demands.length; i++) {
      buffer.writeln('  ${i + 1}. ${demands[i]}');
    }
    buffer.writeln();
    buffer.writeln('• 已掌握關鍵證據清單：');
    for (var j = 0; j < evidences.length; j++) {
      buffer.writeln('  - ${evidences[j]}');
    }
    return buffer.toString().trim();
  }

  Map<String, dynamic> toJson() => {
        'disputeCategory': disputeCategory,
        'factSummary': factSummary,
        'demands': demands,
        'evidences': evidences,
        'possibleLegalBasis': possibleLegalBasis,
        'estimatedDisputeAmount': estimatedDisputeAmount,
        'opponentProfile': opponentProfile,
      };

  factory CaseBrief.fromJson(Map<String, dynamic> json) => CaseBrief(
        disputeCategory: json['disputeCategory'] as String? ?? '一般民事爭議',
        factSummary: json['factSummary'] as String? ?? '',
        demands: (json['demands'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        evidences: (json['evidences'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        possibleLegalBasis: (json['possibleLegalBasis'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        estimatedDisputeAmount:
            json['estimatedDisputeAmount'] as String? ?? '',
        opponentProfile: json['opponentProfile'] as String? ?? '',
      );
}

/// 預約諮詢請求單
class LawyerConsultationBooking {
  const LawyerConsultationBooking({
    required this.id,
    required this.lawyerId,
    required this.lawyerName,
    required this.clientName,
    required this.clientPhone,
    required this.consultationType,
    required this.preferredDate,
    required this.caseBrief,
    required this.createdAt,
    this.isConfirmed = false,
  });

  final String id;
  final String lawyerId;
  final String lawyerName;
  final String clientName;
  final String clientPhone;
  final String consultationType; // '線上視訊 30 分鐘', '實體事務所面談', '書狀代撰審閱'
  final String preferredDate;
  final CaseBrief caseBrief;
  final DateTime createdAt;
  final bool isConfirmed;

  Map<String, dynamic> toJson() => {
        'id': id,
        'lawyerId': lawyerId,
        'lawyerName': lawyerName,
        'clientName': clientName,
        'clientPhone': clientPhone,
        'consultationType': consultationType,
        'preferredDate': preferredDate,
        'caseBrief': caseBrief.toJson(),
        'createdAt': createdAt.toIso8601String(),
        'isConfirmed': isConfirmed,
      };
}
