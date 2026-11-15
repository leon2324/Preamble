import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:preamble/components/lawyer/lawyer_referral_sheet.dart';
import 'package:preamble/data/documents/dynamic_legal_drafter_brain.dart';
import 'package:preamble/data/law_assistant/law_assistant_models.dart';
import 'package:preamble/data/lawyer/lawyer_models.dart';
import 'package:preamble/data/lawyer/lawyer_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 17: Lawyer Referral & Handover Hub Tests', () {
    late LawyerRepository repository;

    setUp(() {
      repository = LawyerRepository();
    });

    test('LawyerRepository returns certified lawyers for categories', () {
      final rentalLawyers =
          repository.getRecommendedLawyersForCategory('租屋押金不還扣抵糾紛');
      expect(rentalLawyers, isNotEmpty);
      expect(
        rentalLawyers.any(
          (l) => l.specialties.contains(LawyerSpecialty.rentalAndRealEstate),
        ),
        isTrue,
      );

      final laborLawyers =
          repository.getRecommendedLawyersForCategory('公司老闆欠加班費資遣');
      expect(laborLawyers, isNotEmpty);
      expect(
        laborLawyers.any(
          (l) => l.specialties.contains(LawyerSpecialty.laborAndEmployment),
        ),
        isTrue,
      );
    });

    test('CaseBriefPackager packages assistant message into structured brief', () {
      final msg = LawAssistantMessage(
        id: 'msg-test',
        role: LawAssistantMessageRole.assistant,
        content: '建議您先發函給房東催告。',
        createdAt: DateTime.now(),
        insight: LawAssistantDefenseInsight.fromContext(
          text: '房東扣押金4萬元不還',
        ),
      );

      final brief = CaseBriefPackager.fromAssistantMessage(msg);
      expect(brief.disputeCategory, contains('租賃'));
      expect(brief.evidences, isNotEmpty);

      final briefText = brief.toFormattedBriefText();
      expect(briefText, contains('案由類別'));
      expect(briefText, contains('關鍵證據清單'));
    });

    test('CaseBriefPackager packages DynamicLegalDocument into brief', () {
      final doc = DynamicLegalDrafterBrain.generateFromFactDescription(
        rawFacts: '我和朋友合開美甲店鬧拆夥，請求依法查帳結算50萬出資額。',
      );

      final brief = CaseBriefPackager.fromDynamicDocument(doc);
      expect(brief.disputeCategory, contains('合夥'));
      expect(brief.demands, isNotEmpty);
      expect(brief.possibleLegalBasis.any((b) => b.contains('民法')), isTrue);
    });

    test('Submitting consultation booking creates confirmed booking model',
        () async {
      final lawyer = repository.getAllLawyers().first;
      final brief = CaseBrief(
        disputeCategory: '租賃押金爭議',
        factSummary: '房東扣抵押金不退',
        demands: const ['退還押金4萬元'],
        evidences: const ['點交錄影'],
        possibleLegalBasis: const ['民法第423條'],
      );

      final booking = await repository.submitBooking(
        lawyer: lawyer,
        clientName: '王先生',
        clientPhone: '0988-123-456',
        consultationType: '線上視訊 30 分鐘',
        preferredDate: '直近時段',
        brief: brief,
      );

      expect(booking.id, startsWith('booking-'));
      expect(booking.lawyerName, lawyer.name);
      expect(booking.isConfirmed, isTrue);
    });

    testWidgets('LawyerReferralSheet renders recommended lawyers and brief',
        (WidgetTester tester) async {
      final testBrief = CaseBrief(
        disputeCategory: '房屋租賃爭議',
        factSummary: '房東於租約到期點交後拒絕返還兩個月押金4萬元。',
        demands: const ['限期全額返還押金'],
        evidences: const ['租約原本', '點交現況照片'],
        possibleLegalBasis: const ['民法第423條'],
      );

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: LawyerReferralSheet(caseBrief: testBrief),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('執業律師精準轉介與交辦'), findsOneWidget);
      expect(find.textContaining('交辦案件簡報'), findsOneWidget);
      expect(find.text('線上視訊 30 分鐘'), findsOneWidget);
      expect(find.text('實體事務所面談'), findsOneWidget);
      expect(find.text('書狀代撰審閱'), findsOneWidget);
    });
  });
}
