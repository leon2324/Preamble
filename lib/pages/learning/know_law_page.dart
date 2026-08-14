import 'package:flutter/material.dart';
import 'package:preamble/components/shared/custom_toast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
// google_fonts is imported in notebook_aesthetics
import 'package:preamble/app/app_state.dart';
import 'package:preamble/components/home/v2/home_v2_palette.dart';
import 'package:preamble/components/navigation/app_shell_content_insets.dart';
import 'package:preamble/components/shared/inline_citation_parser.dart';
import 'package:preamble/components/shared/mvp_state_widgets.dart';
import 'package:preamble/data/law_assistant/guest_law_assistant_usage.dart';
import 'package:preamble/data/law_assistant/law_assistant_models.dart';
import 'package:preamble/data/law_assistant/law_assistant_repository.dart';
import 'package:preamble/data/mock_data/learning/daily_quiz_questions.dart';
import 'package:preamble/data/mock_data/learning/learning_mock_data.dart';
import 'package:preamble/data/mock_data/learning/extended_stories_data.dart';
import 'package:preamble/pages/learning/learning_mock_detail_page.dart';
import 'package:preamble/pages/learning/statute_database_page.dart';
import 'package:preamble/theme/app_colors.dart';

// 導入遊戲化、手寫本美學與自訂 SVG 圖示
import 'package:preamble/data/learning/learning_game_state.dart';
import 'package:preamble/pages/learning/widgets/notebook_aesthetics.dart';
import 'package:preamble/pages/learning/widgets/learning_shared_widgets.dart';
import 'package:preamble/pages/learning/widgets/learning_result_action_bar.dart';
import 'package:preamble/pages/learning/widgets/achievement_room.dart';
import 'package:preamble/pages/learning/widgets/mock_court_challenge.dart';
import 'package:preamble/pages/learning/widgets/legal_document_export_page.dart';
import 'package:preamble/pages/learning/widgets/notebook_cover_editor_page.dart';
import 'package:preamble/pages/learning/widgets/topic_catalog_bottom_sheet.dart';
import 'package:preamble/pages/learning/widgets/custom_classroom_dialog.dart';
import 'package:preamble/pages/learning/models/learning_topic_option.dart';
import 'package:preamble/features/case_library/widgets/case_library_svg_icon.dart';
import 'package:preamble/data/learning/supabase_learning_service.dart';
import 'package:preamble/components/assistant/law_assistant_insight_card.dart';
import 'package:preamble/data/documents/document_models.dart';
import 'package:preamble/data/documents/document_repository.dart';
import 'package:preamble/data/documents/dynamic_legal_drafter_brain.dart';
import 'package:preamble/components/subscription/morandi_paywall_sheet.dart';

import 'dart:async';
import 'dart:io';
import 'dart:ui' show ImageFilter;

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

part 'law_assistant/law_assistant_palette.dart';
part 'law_assistant/law_assistant_chat_page.dart';

part 'tabs/learning_classroom_tab.dart';
part 'tabs/learning_tools_tab.dart';
part 'tabs/learning_notebook_tab.dart';

/// 學習頁重構：單一 ListView 滾動大框架，結合方格紙手寫筆記本美學，全面採用 SVG 圖示
class KnowLawPage extends StatefulWidget {
  const KnowLawPage({
    super.key,
    this.initialTabIndex,
    this.initialToolTab,
  });

  final int? initialTabIndex;
  final String? initialToolTab;

  @override
  KnowLawPageState createState() => KnowLawPageState();
}

class KnowLawPageState extends State<KnowLawPage> {
  String _activeTopic = '租屋糾紛';
  int _illuStoryIndex = 0;
  int _dialogStoryIndex = 0;
  List<LearningTopicData> _dailyTopics = [];
  final List<LearningTopicData> _customTopics = [];
  bool _isLoadingTopics = true;
  int? _selectedDailyAnswer;

  // 隨手記與法條標籤對照狀態
  final TextEditingController _quickNoteController = TextEditingController();
  final List<String> _quickNotes = [
    '車禍過失傷害是告訴乃論，起訴期限只有六個月要特別注意！',
    '定金返還規定在民法第 249 條，若可歸責於付定金當事人則無法收回。',
  ];
  String _selectedStatuteTag = '租賃契約';

  @override
  void initState() {
    super.initState();
    if (widget.initialTabIndex != null) {
      _selectedTabIndex = widget.initialTabIndex!;
    }
    if (widget.initialToolTab != null) {
      _activeToolTab = widget.initialToolTab!;
    }
    _initDailyTopics();
  }

  @override
  void dispose() {
    _quickNoteController.dispose();
    super.dispose();
  }

  void openNotebookTab() {
    setState(() => _selectedTabIndex = 2);
  }

  void saveQuickNote(String text) {
    setState(() {
      _quickNotes.insert(0, text);
      _quickNoteController.clear();
    });
  }

  void removeQuickNoteAt(int index) {
    setState(() {
      _quickNotes.removeAt(index);
    });
  }

  void selectStatuteTag(String tag) {
    setState(() {
      _selectedStatuteTag = tag;
    });
  }

  @override
  void didUpdateWidget(covariant KnowLawPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTabIndex != null) {
      setState(() {
        _selectedTabIndex = widget.initialTabIndex!;
      });
    }
    if (widget.initialToolTab != null) {
      setState(() {
        _activeToolTab = widget.initialToolTab!;
      });
    }
  }

  Future<void> _initDailyTopics() async {
    try {
      final topics = await SupabaseLearningService.instance
          .fetchDailyFeaturedTopics(DateTime.now());
      if (mounted) {
        setState(() {
          _dailyTopics = topics;
          _isLoadingTopics = false;
          if (_dailyTopics.isNotEmpty) {
            _activeTopic = _dailyTopics.first.title;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingTopics = false;
        });
      }
    }
  }

  String _extractCategory(String title) {
    if (title.contains('租屋糾紛') || title.contains('租屋')) {
      return '租屋糾紛';
    }
    if (title.contains('車禍事故') ||
        title.contains('車禍') ||
        title.contains('交通事故')) {
      return '車禍事故';
    }
    if (title.contains('職場權益') ||
        title.contains('加班') ||
        title.contains('勞基法') ||
        title.contains('離職')) {
      return '職場權益';
    }
    if (title.contains('網購消費') ||
        title.contains('網購') ||
        title.contains('消保法') ||
        title.contains('退貨')) {
      return '網購消費';
    }
    if (title.contains('個資隱私') ||
        title.contains('個資') ||
        title.contains('隱私') ||
        title.contains('洩露')) {
      return '個資隱私';
    }
    if (title.contains('鄰里生活') ||
        title.contains('漏水') ||
        title.contains('天花板') ||
        title.contains('鄰居')) {
      return '鄰里生活';
    }
    if (title.contains('婚姻家庭') ||
        title.contains('離婚') ||
        title.contains('財產制') ||
        title.contains('夫妻')) {
      return '婚姻家庭';
    }
    if (title.contains('防詐騙') ||
        title.contains('詐騙') ||
        title.contains('警示') ||
        title.contains('人頭帳戶')) {
      return '防詐騙常識';
    }
    return '法律常識';
  }

  void _rotateIllustrationTopic() {
    setState(() {
      _illuStoryIndex = (_illuStoryIndex + 1) % fullIllustrationStories.length;
    });
  }

  void _rotateDialogTopic() {
    setState(() {
      _dialogStoryIndex = (_dialogStoryIndex + 1) % fullDialogStories.length;
    });
  }

  Color _getTopicColor(String category) {
    final cat = _extractCategory(category);
    switch (cat) {
      case '車禍事故':
        return const Color(0xFF3F7FBF);
      case '職場權益':
        return const Color(0xFFE65100);
      case '網購消費':
        return const Color(0xFFC2185B);
      case '個資隱私':
        return const Color(0xFF512DA8);
      case '租屋糾紛':
      default:
        return const Color(0xFF2E7D32);
    }
  }

  Color _getTopicCardBg(String category, bool isDark) {
    if (isDark) return const Color(0xFF242C36);
    final cat = _extractCategory(category);
    switch (cat) {
      case '車禍事故':
        return const Color(0xFFEAF0F8);
      case '職場權益':
        return const Color(0xFFFFF3E0);
      case '網購消費':
        return const Color(0xFFFCE4EC);
      case '個資隱私':
        return const Color(0xFFEDE7F6);
      case '租屋糾紛':
      default:
        return const Color(0xFFE8F5E9);
    }
  }

  String _getHeroAsset(String topicTitle) {
    final cat = _extractCategory(topicTitle);
    switch (cat) {
      case '車禍事故':
        return 'assets/images/learning/car_course_room.png';
      case '職場權益':
        return 'assets/images/learning/work_course_room.png';
      case '網購消費':
        return 'assets/images/learning/consumer_course_room.png';
      case '個資隱私':
        return 'assets/images/learning/privacy_course_room.png';
      case '租屋糾紛':
      default:
        return 'assets/images/learning/rent_course_room.png';
    }
  }

  String _getTopicBadgeText(String topicTitle) {
    final cat = _extractCategory(topicTitle);
    switch (cat) {
      case '車禍事故':
        return '道路安全必備';
      case '職場權益':
        return '勞資權益保障';
      case '網購消費':
        return '網購消保常識';
      case '個資隱私':
        return '資訊安全防護';
      case '租屋糾紛':
      default:
        return '租屋生活必修';
    }
  }

  String _getTopicTip(String topicTitle) {
    final cat = _extractCategory(topicTitle);
    switch (cat) {
      case '車禍事故':
        return '遇到事故鑑定與折舊問題時，可以到「生活工具箱」使用工具來協助計算或準備。';
      case '職場權益':
        return '了解加班與勞退爭議後，可以到「生活工具箱」查閱常用法規與調解文件。';
      case '網購消費':
        return '發生七天鑑賞期與退貨爭議時，可以使用「生活工具箱」準備存證信函範本。';
      case '個資隱私':
        return '面臨個資洩露或網路詐騙時，可以使用「生活工具箱」查詢權益自保步驟。';
      case '租屋糾紛':
      default:
        return '學到點交與修繕時，可以到「生活工具箱」整理租屋證據清單。';
    }
  }

  static const List<LearningTopicOption> _featuredTopics = [
    LearningTopicOption('租屋糾紛', '主修中', true),
    LearningTopicOption('車禍事故', '看全部', false),
    LearningTopicOption('職場權益', '看全部', false),
    LearningTopicOption('網購消費', '看全部', false),
    LearningTopicOption('個資隱私', '看全部', false),
  ];

  List<LearningTopicOption> get _currentFeaturedTopicOptions {
    final List<LearningTopicOption> options = [];

    // 1. 優先放入客製化訂製專題
    for (final topic in _customTopics) {
      final isMain = topic.title == _activeTopic;
      options.add(LearningTopicOption(
        topic.title,
        isMain ? '主修中' : '自訂專題',
        true,
      ));
    }

    // 2. 放入每日精選專題
    if (_dailyTopics.isNotEmpty) {
      options.addAll(_dailyTopics.map((topic) {
        final isMain = topic.title == _activeTopic;
        return LearningTopicOption(
          topic.title,
          isMain ? '主修中' : '看全部',
          true,
        );
      }));
    } else {
      options.addAll(_featuredTopics);
    }
    return options;
  }

  LearningTopicData get _currentTopicData {
    // 1. 優先在自訂專題中尋找
    for (final topic in _customTopics) {
      if (topic.title == _activeTopic) {
        return topic;
      }
    }
    // 2. 再從每日隨機專題中尋找
    for (final topic in _dailyTopics) {
      if (topic.title == _activeTopic) {
        return topic;
      }
    }
    return featuredLearningTopics[_activeTopic] ?? learningTopic;
  }

  /// 🧠 客製化專題資料產生器
  LearningTopicData _generateCustomTopicData(String prompt) {
    final category = _extractCategory(prompt);
    final keyText = prompt.trim().isNotEmpty ? prompt.trim() : '自訂法律疑難';

    // 限制顯示長度，避免選單晶片文字過長
    final shortKey =
        keyText.length > 8 ? '${keyText.substring(0, 8)}...' : keyText;
    final topicTitle = '「$shortKey」專屬法律課堂';

    final step1Article = LearningMockArticle(
      badge: '學習單元',
      title: '單元 1：關於「$shortKey」的法律觀念起點',
      summary: '建立正確的法律邏輯，理清核心爭點與法律關係。',
      readTime: '3 分鐘',
      heroNote: '遇到糾紛時，千萬不要憑直覺處理，理清基本權益是自保的關鍵。',
      keyPoints: [
        '釐清法律關係是民事契約還是侵權求償。',
        '確認自己具有法律上的請求權基礎。',
        '切勿隨意進行私力救濟，以免得不償失。',
      ],
      sections: [
        LearningMockSection(
          title: '觀念起點',
          body:
              '在日常生活中，遇到「$keyText」的糾紛非常多。許多人一開始容易陷入情緒，但法律上最先看的是『雙方的法律關係』與『誰有請求權基礎』。',
        ),
        LearningMockSection(
          title: '初步解析',
          body:
              '針對您關注的「$keyText」情境，我們需要先釐清這屬於民法契約糾紛（例如買賣、租賃契約）、還是侵權行為求償，或是特定的特別法保障範疇。',
        ),
      ],
      category: category,
      quizData: {
        'question': '面對「$keyText」的法律糾紛時，第一步最正確的作法是什麼？',
        'options': [
          'A. 收集對話與契約等關鍵證據，釐清請求權基礎。',
          'B. 聯絡親友一起去現場向對方爭論。',
          'C. 直接在網路上公開發文爆料。',
        ],
        'correctIndex': 0,
        'explanation': '解決法律爭議應以證據為先，理性分析法律關係與請求權基礎才是自保正道。',
      },
      topicId: 9999,
      stepNumber: 1,
    );

    final step2Article = LearningMockArticle(
      badge: '學習單元',
      title: '單元 2：實務案例解析：當我們碰上「$shortKey」',
      summary: '透過具體情境，看懂實務中責任與損失如何劃分。',
      readTime: '4 分鐘',
      heroNote: '看懂他人發生的糾紛過程，能幫助我們在自己遇到時做出正確判斷。',
      keyPoints: [
        '分析案例中各方的行為是否構成違約或侵權。',
        '找出該糾紛最關鍵的法條（例如民法或特別法）。',
        '確認雙方是否有協商或減輕損害之義務。',
      ],
      sections: [
        LearningMockSection(
          title: '案例情境',
          body:
              '阿榮碰上了「$keyText」的情況。對方態度強硬，宣稱阿榮必須全額負責賠償。阿榮對此感到困惑，不知道法律上的權責界線到底在哪裡。',
        ),
        LearningMockSection(
          title: '權責剖析',
          body:
              '在類似「$keyText」的情境中，民法通常講求『損害賠償範圍』與『過失相抵原則』。更換零件通常必須計算折舊率，自然損耗與老化由所有人負擔，非故意損壞也應妥善舉證。',
        ),
      ],
      category: category,
      quizData: {
        'question': '在類似「$keyText」的損害賠償案件中，折舊率是以什麼為計算基礎？',
        'options': [
          'A. 物品購買時的全新品價格，全額理賠。',
          'B. 依行政院固定資產耐用年數表與已使用年限進行折舊計算。',
          'C. 雙方自由喊價，誰大聲誰就贏。',
        ],
        'correctIndex': 1,
        'explanation': '民事賠償更換零件需扣除折舊，以符合禁止不當得利原則。',
      },
      topicId: 9999,
      stepNumber: 2,
    );

    final step3Article = LearningMockArticle(
      badge: '學習單元',
      title: '單元 3：處理「$shortKey」最常見的直覺誤區',
      summary: '避開自以為合理、其實違法的隱藏陷阱。',
      readTime: '3 分鐘',
      heroNote: '常見的法律誤解會讓我們在談判或調解時落入下風。',
      keyPoints: [
        '不要口頭承諾任何賠償或退讓，口頭合意同樣可能成立契約。',
        '切勿一時氣憤在公開平台上傳播對方個資，以免反遭控告。',
        '並非只要自己有理就可以強行採取私力救濟，須循合法程序。',
      ],
      sections: [
        LearningMockSection(
          title: '直覺陷阱',
          body:
              '許多人獲悉「$keyText」時，直覺會認為『既然是他不對，那我就可以把他的東西扣下來當質押，或者把我們的 LINE 聊天紀錄公開發上網』。然而這往往觸犯了个資法或刑法。',
        ),
        LearningMockSection(
          title: '法律紅線',
          body:
              '未經同意公開轉傳內含對方可識別資訊（姓名、電話等）的截圖，可能會違反個人資料保護法。強行扣留對方私人物品亦涉妨害自由或強制罪。合法討公道應循民事調解或訴訟。',
        ),
      ],
      category: category,
      quizData: {
        'question': '為了澄清事實，把內含對方姓名與聯絡電話的「$keyText」對話截圖無遮蔽直接發到公開爆料群組，是否安全？',
        'options': [
          'A. 安全，說實話是憲法言論自由保障。',
          'B. 不安全，已構成個資法違法利用與侵害隱私，可能會反遭起訴。',
          'C. 只要我們是受害者就絕對沒事。',
        ],
        'correctIndex': 1,
        'explanation': '即使對話屬實，直接公開他人可識別個資仍構成個資侵權。',
      },
      topicId: 9999,
      stepNumber: 3,
    );

    final step4Article = LearningMockArticle(
      badge: '學習單元',
      title: '單元 4：實務維權指南：證據清單與存證信函寫法',
      summary: '學會保留鐵證，並寫出具法律效果的通知信。',
      readTime: '4 分鐘',
      heroNote: '在法律的世界裡，「沒有證據就等於沒有事實」。做好證據保存是贏得訴訟的關鍵。',
      keyPoints: [
        '妥善保留所有對話紀錄、合約、發票、收據與現場照片。',
        '利用存證信函明確傳達意思表示，並留下郵局的正式郵戳證明。',
        '存證信函不是判決書，但能起到正式催告與警告的效果。',
      ],
      sections: [
        LearningMockSection(
          title: '證據搜集',
          body:
              '要贏得「$keyText」的爭議，證據是唯一的武器。請務必保留：1. 雙方通訊紀錄。 2. 發票、收據、維修估價單。 3. 現場拍照或錄影存證。',
        ),
        LearningMockSection(
          title: '存證信函寫法',
          body:
              '若對方避不處理，應寄發存證信函。內容載明本件「$keyText」的經過、我方明確訴求（如限期履行合約）、以及限期於 7 日內解決、逾期將循法律途徑之聲明，以此作為正式催告鐵證。',
        ),
      ],
      category: category,
      quizData: {
        'question': '面對「$keyText」糾紛，寄發存證信函最核心的作用是什麼？',
        'options': [
          'A. 警告對方郵局會去抄他的家。',
          'B. 留存我方確已進行限期催告與意思表示的正式書面法理證明。',
          'C. 存證信函是一張欠條。',
        ],
        'correctIndex': 1,
        'explanation': '存證信函是郵局存證的書面催告信，主要用以作為日後訴訟中已進行告知的證據。',
      },
      topicId: 9999,
      stepNumber: 4,
    );

    final step5Article = LearningMockArticle(
      badge: '學習單元',
      title: '單元 5：綜合實戰測驗與通關驗證',
      summary: '綜合前面單元學習，用一題測驗確認您已掌握維權核心。',
      readTime: '1 題測驗',
      heroNote: '恭喜您來到最後一關，讓我們用這題測驗完成通關認證吧！',
      keyPoints: [
        '堅持證據優先，以存證信函與調解為首要解決手段。',
        '遵守法律程序，切勿訴諸私力救濟或情緒化爆料。',
        '調解成立具備法院確定判決同等效力。',
      ],
      sections: [
        LearningMockSection(
          title: '綜合實戰',
          body: '因為「$keyText」的事情，透過存證信函催告對方無效。此時最理想的解決方法是？',
        ),
        LearningMockSection(
          title: '自保解答',
          body:
              '應向當地的鄉鎮市區公所免費聲請民事調解。調解一旦成立，經法院核定後與民事三審確定判決有同等效力，對方不配合即可直接強制執行，既省時又省力。',
        ),
      ],
      category: category,
      quizData: {
        'question': '當「$keyText」糾紛寄信催告無效，雙方依舊僵持不下時，下列哪一個是成本最低且極具法律效力的做法？',
        'options': [
          'A. 認賠退出。',
          'B. 向鄉鎮市區公所聲請免費民事調解，取得與法院確定判決同等效力的調解書。',
          'C. 提起漫長且昂貴的三審訴訟。',
        ],
        'correctIndex': 1,
        'explanation': '免費的民事調解是成本最低、速度最快且最具備法律執行效力的維權途徑。',
      },
      topicId: 9999,
      stepNumber: 5,
    );

    return LearningTopicData(
      title: topicTitle,
      summary: '特別為您遇到的「$shortKey」量身打造的實務法學分析專題。',
      reasonToLearn: '客製化訂製專題能精準指引您當前糾紛的法理脈絡，提供最立即的自保指引。',
      unitSummary: '5 個學習單元',
      heroArticle: LearningMockArticle(
        badge: '主專題',
        title: '針對「$shortKey」自訂專題：情境拆解與應對技巧',
        summary: '本專案由 5 個單元組成，帶你循序漸進建立關於 $category 的精準判斷架構。',
        readTime: '5 個學習單元',
        heroNote: '不要憑直覺解決爭議。先搞懂權利，再掌握證據，最後才談具體求償。',
        keyPoints: [
          '理解 $category 的法律概念與自身法律關係。',
          '學習如何避開常見的個資隱私直覺誤區。',
          '掌握證據保存與鄉鎮市區公所民事調解的申辦步驟。',
        ],
        sections: const [
          LearningMockSection(
            title: '這個自訂專題在學什麼',
            body: '它會針對您輸入的情境，從基礎概念、案例解析、盲點避讓，一路講到存證信函寫法與調解指引。',
          ),
          LearningMockSection(
            title: '訂製的好處',
            body: '這能將枯燥的法律文字具體對接到您現在正面臨的痛點，以最快的速度幫您建立底氣。',
          ),
        ],
      ),
      units: [
        LearningTopicUnit(
            stepLabel: 'STEP 1',
            title: step1Article.title,
            goal: step1Article.summary,
            readTime: step1Article.readTime,
            article: step1Article),
        LearningTopicUnit(
            stepLabel: 'STEP 2',
            title: step2Article.title,
            goal: step2Article.summary,
            readTime: step2Article.readTime,
            article: step2Article),
        LearningTopicUnit(
            stepLabel: 'STEP 3',
            title: step3Article.title,
            goal: step3Article.summary,
            readTime: step3Article.readTime,
            article: step3Article),
        LearningTopicUnit(
            stepLabel: 'STEP 4',
            title: step4Article.title,
            goal: step4Article.summary,
            readTime: step4Article.readTime,
            article: step4Article),
        LearningTopicUnit(
            stepLabel: 'STEP 5',
            title: step5Article.title,
            goal: step5Article.summary,
            readTime: step5Article.readTime,
            article: step5Article),
      ],
      relatedTopics: const [],
      supportItems: const [],
      quizEntry: const LearningQuizEntryData(
        title: '專題測驗',
        subtitle: '用 1 題小測驗確認你能不能分辨此情境的法律責任。',
        actionLabel: '開始測驗',
      ),
    );
  }

  Widget _buildCustomClassroomCard(bool isDark) {
    return LearningCustomClassroomCard(
      isDark: isDark,
      onTap: _showCustomClassroomDialog,
    );
  }

  void _showCustomClassroomDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return CustomClassroomDialog(
          isDark: isDark,
          onGenerate: (userInput) {
            Navigator.pop(dialogContext);
            final newTopic = _generateCustomTopicData(userInput);
            setState(() {
              _customTopics.add(newTopic);
              _activeTopic = newTopic.title;
            });
            HapticFeedback.heavyImpact();
            CustomToast.show(context, '🎉 成功訂製您的專屬課程「${newTopic.title}」！');
          },
        );
      },
    );
  }

  int _selectedTabIndex = 0; // 0: 法學課堂, 1: 生活工具箱

  void _openArticle(LearningMockArticle article) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (__) => LearningMockDetailPage(article: article),
      ),
    );
  }

  void _openUnitStep(LearningTopicUnit unit) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (__) => LearningMockDetailPage(
          article: unit.article,
          unitStepLabel: unit.stepLabel,
          category: _activeTopic,
          onSwitchTopic: _switchToNextTopic,
        ),
      ),
    );
  }

  void _openStatuteDatabase({String initialQuery = ''}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (__) => StatuteDatabasePage(initialQuery: initialQuery),
      ),
    );
  }

  void _openAchievementRoom() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (__) => const AchievementRoomPage(),
      ),
    );
  }

  void _switchToNextTopic() {
    final List<String> topicNames = _dailyTopics.isNotEmpty
        ? _dailyTopics.map((t) => t.title).toList()
        : featuredLearningTopics.keys.toList();
    final currentIndex = topicNames.indexOf(_activeTopic);
    final gameState = LearningGameState.instance;
    String? nextTopicName;

    // 優先尋找下一個未完成全部單元的專題
    for (int i = 1; i <= topicNames.length; i++) {
      final idx = (currentIndex + i) % topicNames.length;
      final name = topicNames[idx];
      final topicData = _dailyTopics.isNotEmpty
          ? _dailyTopics[idx]
          : featuredLearningTopics[name]!;

      bool hasUncompleted = false;
      for (final unit in topicData.units) {
        if (!gameState.completedSteps.contains("${name}_${unit.stepLabel}")) {
          hasUncompleted = true;
          break;
        }
      }

      if (hasUncompleted) {
        nextTopicName = name;
        break;
      }
    }

    // 若全部專題皆已通關，則循環切換至下一個
    if (nextTopicName == null) {
      final idx = (currentIndex + 1) % topicNames.length;
      nextTopicName = topicNames[idx];
    }

    setState(() {
      _activeTopic = nextTopicName!;
    });

    CustomToast.show(context, '已為您切換至選修專題：$nextTopicName 📚');
  }

  void _showTopicComingSoon(String topic) {
    CustomToast.show(context, '$topic 專題正在整理中，之後會加入主修課。');
  }

  void _openLearningTopicCatalog({String? initialCategory}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
        return LearningTopicCatalogBottomSheet(
          initialCategory: initialCategory,
          isDark: isDark,
          onArticleTap: _openArticle,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gameState = LearningGameState.instance;
    final additionalBottom = AppShellContentInsets.additionalBottomOf(context);
    final mediaPadding = MediaQuery.paddingOf(context);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: ListenableBuilder(
          listenable: gameState,
          builder: (context, _) {
            return NotebookBackground(
              // 台灣繁體中文教學註解：筆記本背景要畫到狀態列下方；內容則從
              // 當前 MediaQuery 的安全邊界開始。若主殼層已用 SafeArea 消耗
              // top inset，這裡的 top 會自然是 0，只留下原本的 12.h 設計間距。
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  16.w + mediaPadding.left,
                  12.h + mediaPadding.top,
                  16.w + mediaPadding.right,
                  // 台灣繁體中文教學註解：A2 的共用 inset 只代表大字級 Nav
                  // 額外長出的高度；Home Indicator safe inset 仍由 MediaQuery
                  // 負責，兩者不可重複計算。
                  80.h + mediaPadding.bottom + additionalBottom,
                ),
                physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics()),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                children: [
                  // 1. 頂部自訂 Header列
                  _buildHeaderRow(isDark, gameState),
                  SizedBox(height: 12.h),

                  // 2. 智慧小法助輪播提問氣泡
                  _AssistantPromptBubble(
                    onMascotTap: _openAchievementRoom,
                  ),
                  SizedBox(height: 16.h),

                  // 3. 左右切換分頁 Tab 按鈕（單一 Scroll 結構下的切換按鈕）
                  _buildTabSwitcher(isDark),
                  SizedBox(height: 16.h),

                  // 4. 根據切換選取的 Tab 渲染不同內容
                  if (_selectedTabIndex == 0)
                    buildLearningClassroomTab(isDark, gameState)
                  else if (_selectedTabIndex == 1)
                    buildLearningToolsTab(isDark, gameState)
                  else
                    buildLearningNotebookTab(isDark, gameState),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // 1) 頂部自訂 Header 列
  Widget _buildHeaderRow(bool isDark, LearningGameState gameState) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '學堂與工具箱',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                '手寫法律筆記本 • 用情境學常識',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        // 迷你虛筆記本封面，點擊開啟封面編輯器
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => const NotebookCoverEditorPage()),
            );
          },
          child: Tooltip(
            message: '編輯我的筆記本封面',
            child: Container(
              width: 32.w,
              height: 42.h,
              margin: EdgeInsets.only(right: 12.w),
              decoration: BoxDecoration(
                color: Color(int.parse(
                    gameState.coverColorHex.replaceFirst('#', '0xFF'))),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(5.r),
                  bottomRight: Radius.circular(5.r),
                  topLeft: Radius.circular(1.5.r),
                  bottomLeft: Radius.circular(1.5.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
                    blurRadius: 3,
                    offset: const Offset(1, 2),
                  )
                ],
                border: Border.all(
                  color: isDark ? Colors.white24 : Colors.black12,
                  width: 0.8.w,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 書脊深色線
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: 3.w,
                    child: Container(color: Colors.black12),
                  ),
                  // 第一張貼紙縮影
                  if (gameState.placedStickers.isNotEmpty)
                    Text(
                      _getStickerEmoji(gameState.placedStickers.first['id']),
                      style: TextStyle(fontSize: 12.sp),
                    )
                  else
                    Text('🌱', style: TextStyle(fontSize: 12.sp)),
                ],
              ),
            ),
          ),
        ),
        // 吉祥物頭像按鈕，點擊開啟成就室
        GestureDetector(
          onTap: _openAchievementRoom,
          child: Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF26303D) : const Color(0xFFF3EDE0),
              shape: BoxShape.circle,
              border: Border.all(
                color:
                    isDark ? const Color(0xFF354454) : const Color(0xFFE4D9C4),
                width: 1.5.w,
              ),
            ),
            child: Center(
              child: Text(
                gameState.mascotExpression,
                style: TextStyle(fontSize: 22.sp),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getStickerEmoji(String id) {
    switch (id) {
      case 'sprout':
        return '🌱';
      case 'gavel':
        return '🔨';
      case 'shield':
        return '🛡️';
      case 'trophy':
        return '🏆';
      case 'star':
        return '⭐';
      case 'heart':
        return '❤️';
      case 'scale':
        return '⚖️';
      case 'car':
        return '🚗';
      default:
        return '🌿';
    }
  }

  // 2) 左右切換分頁按鈕
  Widget _buildTabSwitcher(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161C23) : const Color(0xFFEFECE6),
        borderRadius: BorderRadius.circular(12.r),
      ),
      padding: EdgeInsets.all(4.w),
      child: Row(
        children: [
          // 1. 法學課堂
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = 0),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 0
                      ? (isDark ? const Color(0xFF232B35) : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10.r),
                  border: _selectedTabIndex == 0
                      ? Border.all(
                          color: isDark
                              ? const Color(0xFF2D3845)
                              : const Color(0xFFECE6DB),
                          width: 1.2.w,
                        )
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CaseLibrarySvgIcon(
                      CaseLibrarySvgIcons.bookOpen,
                      size: 14.sp,
                      color: _selectedTabIndex == 0
                          ? HomeV2Palette.trustGreen
                          : AppColors.textSecondary,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '法學課堂',
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.bold,
                        color: _selectedTabIndex == 0
                            ? HomeV2Palette.trustGreen
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 2. 生活工具箱
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = 1),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 1
                      ? (isDark ? const Color(0xFF232B35) : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10.r),
                  border: _selectedTabIndex == 1
                      ? Border.all(
                          color: isDark
                              ? const Color(0xFF2D3845)
                              : const Color(0xFFECE6DB),
                          width: 1.2.w,
                        )
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CaseLibrarySvgIcon(
                      CaseLibrarySvgIcons.gavel,
                      size: 14.sp,
                      color: _selectedTabIndex == 1
                          ? HomeV2Palette.trustGreen
                          : AppColors.textSecondary,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '生活工具箱',
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.bold,
                        color: _selectedTabIndex == 1
                            ? HomeV2Palette.trustGreen
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 3. 手帳筆記
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = 2),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 2 ? null : Colors.transparent,
                  gradient: _selectedTabIndex == 2
                      ? LinearGradient(
                          colors: isDark
                              ? [
                                  const Color(0xFF1E3525),
                                  const Color(0xFF14241B)
                                ]
                              : [
                                  const Color(0xFFE8F2EA),
                                  const Color(0xFFD4E8DA)
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  borderRadius: BorderRadius.circular(10.r),
                  border: _selectedTabIndex == 2
                      ? Border.all(
                          color: isDark
                              ? const Color(0xFF275435)
                              : const Color(0xFFB1D5BC),
                          width: 1.2.w,
                        )
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.edit_note_rounded,
                      size: 16.sp,
                      color: _selectedTabIndex == 2
                          ? (isDark
                              ? const Color(0xFF76BA8B)
                              : const Color(0xFF275435))
                          : AppColors.textSecondary,
                    ),
                    SizedBox(width: 2.w),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Text(
                          '手帳筆記',
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.bold,
                            color: _selectedTabIndex == 2
                                ? (isDark
                                    ? const Color(0xFF76BA8B)
                                    : const Color(0xFF275435))
                                : AppColors.textSecondary,
                          ),
                        ),
                        if (_selectedTabIndex != 2)
                          Positioned(
                            top: -2.h,
                            right: -8.w,
                            child: const BreathingDot(),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedTopicSwitcher(bool isDark) {
    final gameState = LearningGameState.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 膠囊顯示曾經看過案件的議題
        if (gameState.viewedCategories.isNotEmpty) ...[
          Text(
            '最近關注的議題',
            style: TextStyle(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 6.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: gameState.viewedCategories.map((cat) {
                return Padding(
                  padding: EdgeInsets.only(right: 6.w),
                  child: ActionChip(
                    label: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.bold,
                        color: HomeV2Palette.trustGreen,
                      ),
                    ),
                    backgroundColor: HomeV2Palette.mint,
                    side: BorderSide(
                      color: HomeV2Palette.trustGreen.withValues(alpha: 0.25),
                      width: 1.w,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                    onPressed: () =>
                        _openLearningTopicCatalog(initialCategory: cat),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 14.h),
        ],

        Row(
          children: [
            Text(
              '精選專題',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => _openLearningTopicCatalog(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '全部專題',
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w900,
                      color: HomeV2Palette.trustGreen,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  CaseLibrarySvgIcon(
                    CaseLibrarySvgIcons.chevronRight,
                    size: 13.sp,
                    color: HomeV2Palette.trustGreen,
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        // 學習首頁只展示少量精選專題，避免活躍 App 內容增加後把首頁塞成百科列表；
        // 更多專題集中到「全部專題」面板，未來接 API 時阻擋並直接以 drawer 代替。
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: _currentFeaturedTopicOptions.map((topic) {
              return Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: _buildTopicChip(topic, isDark),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  String _getTopicChipLabel(String title) {
    if (title.startsWith('「') && title.endsWith('」專屬法律課堂')) {
      final regExp = RegExp(r'^「(.*?)」專屬法律課堂$');
      final match = regExp.firstMatch(title);
      if (match != null) {
        return match.group(1)!;
      }
    }
    return _extractCategory(title);
  }

  Widget _buildTopicChip(LearningTopicOption topic, bool isDark) {
    final isSelected = topic.title == _activeTopic;
    final badgeText = topic.title == _activeTopic
        ? '主修中'
        : (topic.badge == '自訂專題' ? '自訂' : '選修');
    return GestureDetector(
      onTap: () {
        if (_activeTopic != topic.title) {
          setState(() {
            _activeTopic = topic.title;
          });
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? HomeV2Palette.trustGreen
              : (isDark ? const Color(0xFF161C23) : Colors.white),
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(
            color: isSelected
                ? HomeV2Palette.trustGreen
                : (isDark ? const Color(0xFF2D3845) : const Color(0xFFECE6DB)),
            width: 1.1.w,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getTopicChipLabel(topic.title),
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w900,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
            SizedBox(width: 6.w),
            Text(
              badgeText,
              style: TextStyle(
                fontSize: 9.5.sp,
                fontWeight: FontWeight.w800,
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.78)
                    : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainCourseCard({
    required bool isDark,
    required LearningGameState gameState,
    required List<LearningTopicUnit> rentUnits,
    required int completedRentCount,
    required double rentProgress,
    required LearningTopicData topicData,
  }) {
    final cardColor = isDark ? const Color(0xFF161C23) : Colors.white;
    final nextUnit = rentUnits.firstWhere(
      (unit) => !gameState.completedSteps
          .contains("${_activeTopic}_${unit.stepLabel}"),
      orElse: () => rentUnits.last,
    );
    final isComplete = completedRentCount == rentUnits.length;
    final ctaLabel = isComplete
        ? '複習主修課'
        : completedRentCount == 0
            ? '開始學習'
            : '繼續學習';

    final heroAsset = _getHeroAsset(_activeTopic);
    final heroImageUrl = topicData.heroArticle.heroImageUrl;

    return NotebookCard(
      hasBinderRings: true,
      padding: EdgeInsets.zero,
      backgroundColor: cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 292.h,
            child: Stack(
              fit: StackFit.expand,
              children: [
                buildLearningHeroImage(
                  imageUrl: heroImageUrl,
                  localAsset: heroAsset,
                  fit: BoxFit.cover,
                ),
                // 這裡用兩層同圖柔焦做「景深式」過渡：中段先開始微糊，底部再加重糊。
                // 這樣照片仍會延伸到底部，不會變成一塊紙色霧面造成斷層。
                Positioned.fill(
                  child: IgnorePointer(
                    child: ShaderMask(
                      blendMode: BlendMode.dstIn,
                      shaderCallback: (bounds) => const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black26,
                          Colors.black,
                        ],
                        stops: [0.0, 0.18, 0.38, 1.0],
                      ).createShader(bounds),
                      child: ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                        child: Transform.scale(
                          scale: 1.03,
                          child: buildLearningHeroImage(
                            imageUrl: heroImageUrl,
                            localAsset: heroAsset,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: ShaderMask(
                      blendMode: BlendMode.dstIn,
                      shaderCallback: (bounds) => const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black38,
                          Colors.black,
                        ],
                        stops: [0.0, 0.46, 0.64, 1.0],
                      ).createShader(bounds),
                      child: ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 42, sigmaY: 42),
                        child: Transform.scale(
                          scale: 1.08,
                          child: buildLearningHeroImage(
                            imageUrl: heroImageUrl,
                            localAsset: heroAsset,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: isDark ? 0.12 : 0.02),
                        (isDark ? Colors.black : Colors.white)
                            .withValues(alpha: isDark ? 0.10 : 0.18),
                        (isDark ? Colors.black : const Color(0xFFD7B27C))
                            .withValues(alpha: isDark ? 0.24 : 0.18),
                        (isDark ? Colors.black : const Color(0xFF8C5D24))
                            .withValues(alpha: isDark ? 0.48 : 0.34),
                      ],
                      stops: const [0.0, 0.42, 0.74, 1.0],
                    ),
                  ),
                ),
                Positioned(
                  top: 12.h,
                  left: 12.w,
                  right: 12.w,
                  child: Row(
                    children: [
                      buildLearningCourseBadge('主修課', isDark),
                      SizedBox(width: 8.w),
                      buildLearningCourseBadge(
                          '${rentUnits.length} 個單元', isDark),
                      const Spacer(),
                      buildLearningCourseBadge(
                          _getTopicBadgeText(_activeTopic), isDark),
                    ],
                  ),
                ),
                Positioned(
                  left: 14.w,
                  right: 14.w,
                  bottom: 14.h,
                  // 文字直接壓在已經糊化的照片上，不再另做局部霧面卡；
                  // 可讀性靠底圖重糊、全寬漸層與文字陰影共同處理。
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topicData.title,
                        style: TextStyle(
                          fontSize: 21.sp,
                          height: 1.18,
                          fontWeight: FontWeight.w900,
                          color:
                              isDark ? Colors.white : const Color(0xFF17243A),
                          shadows: [
                            Shadow(
                              color: (isDark ? Colors.black : Colors.white)
                                  .withValues(alpha: isDark ? 0.40 : 0.70),
                              blurRadius: 12,
                            ),
                            Shadow(
                              color: (isDark ? Colors.black : Colors.white)
                                  .withValues(alpha: isDark ? 0.22 : 0.50),
                              blurRadius: 24,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        topicData.reasonToLearn,
                        style: TextStyle(
                          fontSize: 12.sp,
                          height: 1.45,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.78)
                              : const Color(0xFF53657B),
                          shadows: [
                            Shadow(
                              color: (isDark ? Colors.black : Colors.white)
                                  .withValues(alpha: isDark ? 0.34 : 0.58),
                              blurRadius: 14,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12.h),
                      if (isComplete) ...[
                        Row(
                          children: [
                            // 按鈕 A: 前往成就室
                            Expanded(
                              flex: 5,
                              child: GestureDetector(
                                onTap: _openAchievementRoom,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.w, vertical: 10.h),
                                  decoration: BoxDecoration(
                                    color: HomeV2Palette.trustGreen,
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '🎉 前往成就室',
                                              style: TextStyle(
                                                fontSize: 12.5.sp,
                                                fontWeight: FontWeight.w900,
                                                color: Colors.white,
                                              ),
                                            ),
                                            SizedBox(height: 2.h),
                                            Text(
                                              '去給智慧樹澆水',
                                              style: TextStyle(
                                                fontSize: 9.5.sp,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white
                                                    .withValues(alpha: 0.82),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.park,
                                        size: 16.sp,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            // 按鈕 B: 切換選修新專題
                            Expanded(
                              flex: 5,
                              child: GestureDetector(
                                onTap: _switchToNextTopic,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.w, vertical: 10.h),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF1E293B)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(10.r),
                                    border: Border.all(
                                      color: HomeV2Palette.trustGreen,
                                      width: 1.2.w,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '切換新專題',
                                              style: TextStyle(
                                                fontSize: 12.5.sp,
                                                fontWeight: FontWeight.w900,
                                                color: HomeV2Palette.trustGreen,
                                              ),
                                            ),
                                            SizedBox(height: 2.h),
                                            Text(
                                              '修讀下一個法律領域',
                                              style: TextStyle(
                                                fontSize: 9.5.sp,
                                                fontWeight: FontWeight.w600,
                                                color: HomeV2Palette.trustGreen
                                                    .withValues(alpha: 0.82),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward,
                                        size: 16.sp,
                                        color: HomeV2Palette.trustGreen,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        GestureDetector(
                          onTap: () => _openUnitStep(nextUnit),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 10.h),
                            decoration: BoxDecoration(
                              color: HomeV2Palette.trustGreen,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ctaLabel,
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        '下一步：${nextUnit.stepLabel} ${nextUnit.title}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 10.5.sp,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white
                                              .withValues(alpha: 0.82),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                CaseLibrarySvgIcon(
                                  CaseLibrarySvgIcons.arrowRight,
                                  size: 18.sp,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 4.h, 14.w, 14.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '學習路徑',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '已完成 $completedRentCount / ${rentUnits.length}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w800,
                        color: HomeV2Palette.trustGreen,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99.r),
                  child: LinearProgressIndicator(
                    value: rentProgress,
                    minHeight: 6.h,
                    backgroundColor: isDark
                        ? const Color(0xFF2D3845)
                        : const Color(0xFFEFECE6),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      HomeV2Palette.trustGreen,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                ...rentUnits.asMap().entries.map((entry) {
                  final unit = entry.value;
                  final isDone = gameState.completedSteps
                      .contains("${_activeTopic}_${unit.stepLabel}");
                  final isNext =
                      unit.stepLabel == nextUnit.stepLabel && !isComplete;
                  return _buildCoursePathStepRow(
                    unit,
                    isDone: isDone,
                    isNext: isNext,
                    isLast: entry.key == rentUnits.length - 1,
                    isDark: isDark,
                  );
                }),
                SizedBox(height: 10.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E2622)
                        : const Color(0xFFF2FAF6),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF2E3C36)
                          : const Color(0xFFD2E6DE),
                    ),
                  ),
                  child: Text(
                    _getTopicTip(_activeTopic),
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      height: 1.35,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? const Color(0xFF99C3B3)
                          : const Color(0xFF1B4D3E),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoursePathStepRow(
    LearningTopicUnit unit, {
    required bool isDone,
    required bool isNext,
    required bool isLast,
    required bool isDark,
  }) {
    final activeColor = isDone
        ? HomeV2Palette.trustGreen
        : isNext
            ? const Color(0xFFE8B95F)
            : AppColors.textMuted;
    final paperColor =
        isDark ? const Color(0xFF1D252E) : const Color(0xFFFAF7F0);

    return GestureDetector(
      onTap: () => _openUnitStep(unit),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 26.w,
            child: Column(
              children: [
                Container(
                  width: 24.w,
                  height: 24.w,
                  decoration: BoxDecoration(
                    color: activeColor.withValues(
                        alpha: isDone || isNext ? 0.18 : 0.10),
                    shape: BoxShape.circle,
                    border: Border.all(color: activeColor, width: 1.4.w),
                  ),
                  child: Center(
                    child: CaseLibrarySvgIcon(
                      isDone
                          ? CaseLibrarySvgIcons.star
                          : CaseLibrarySvgIcons.timeline,
                      size: 13.sp,
                      color: activeColor,
                    ),
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 1.2.w,
                    height: 42.h,
                    color: activeColor.withValues(alpha: 0.24),
                  ),
              ],
            ),
          ),
          SizedBox(width: 9.w),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: isLast ? 0 : 8.h),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 9.h),
              decoration: BoxDecoration(
                color: paperColor,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: isNext
                      ? const Color(0xFFE8B95F)
                      : (isDark
                          ? const Color(0xFF2D3845)
                          : const Color(0xFFECE6DB)),
                  width: isNext ? 1.4.w : 1.w,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${unit.stepLabel}：${unit.title}',
                          style: TextStyle(
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w900,
                            decoration:
                                isDone ? TextDecoration.lineThrough : null,
                            color: isDone
                                ? AppColors.textMuted
                                : AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          '${unit.goal} • ${unit.readTime}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.5.sp,
                            height: 1.35,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  CaseLibrarySvgIcon(
                    CaseLibrarySvgIcons.chevronRight,
                    size: 15.sp,
                    color: activeColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble({
    required String sender,
    required String text,
    required bool isMe,
    String? avatarInitial,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final initial =
        avatarInitial ?? (sender.isNotEmpty ? sender.substring(0, 1) : '');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isMe) ...[
          CircleAvatar(
            radius: 14.r,
            backgroundColor: Colors.grey.shade300,
            child: Text(initial, style: TextStyle(fontSize: 11.sp)),
          ),
          SizedBox(width: 8.w),
        ],
        Flexible(
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(sender,
                  style: TextStyle(fontSize: 9.sp, color: Colors.grey)),
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isMe
                      ? HomeV2Palette.mint
                      : (isDark
                          ? const Color(0xFF26303D)
                          : const Color(0xFFE8E8E8)),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isMe ? 12.r : 2.r),
                    topRight: Radius.circular(isMe ? 2.r : 12.r),
                    bottomLeft: Radius.circular(12.r),
                    bottomRight: Radius.circular(12.r),
                  ),
                ),
                child: Text(
                  text,
                  style: TextStyle(fontSize: 12.sp, height: 1.3),
                ),
              ),
            ],
          ),
        ),
        if (isMe) ...[
          SizedBox(width: 8.w),
          CircleAvatar(
            radius: 14.r,
            backgroundColor: HomeV2Palette.trustGreen.withValues(alpha: 0.2),
            child: Text(initial,
                style: TextStyle(
                    fontSize: 11.sp, color: HomeV2Palette.trustGreen)),
          ),
        ],
      ],
    );
  }

  // 1) 法律術語白話翻譯機 Widget
  final TextEditingController _translatorController = TextEditingController();
  String _translationOutput = '';
  final Map<String, String> _termsMap = {
    '應予駁回': '法院拒絕了這項請求。例如：原告主張無理由，法院「應予駁回」。',
    '酌減': '法院決定減少金額/處罰。例如：違約金過高，法院予以「酌減」。',
    '按之': '依照這個規定/道理來看。通常用在引用法條。',
    '矧以': '更何況是...。用來加強論點。',
    '無理由': '主張在法律上站不住腳，不可信。',
  };

  // 側邊標籤切換分頁狀態
  String _activeToolTab = '翻譯機';

  // 車禍計算器狀態
  final TextEditingController _partsCostController = TextEditingController();
  final TextEditingController _laborCostController = TextEditingController();
  final TextEditingController _carAgeYearsController = TextEditingController();
  final TextEditingController _carAgeMonthsController = TextEditingController();
  String _depreciationResult = '';
  bool _carDepreciationIsMotorcycle = false;
  bool _carDepreciationIsDecliningBalance = true;

  // 租屋催告起草狀態
  final TextEditingController _landlordNameController = TextEditingController();
  final TextEditingController _rentAddressController = TextEditingController();
  final TextEditingController _brokenItemController = TextEditingController();
  final TextEditingController _noticeDaysController = TextEditingController();
  final TextEditingController _leaseExpiryDateController =
      TextEditingController();
  final TextEditingController _depositAmountController =
      TextEditingController();
  String _rentNoticeResult = '';
  int _rentNoticeType = 0; // 0: 設備修繕, 1: 押金返還

  // 加班費計算器狀態
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _weekdayOvertimeController =
      TextEditingController();
  final TextEditingController _holidayOvertimeController =
      TextEditingController();
  String _overtimeResult = '';

  // 網購退貨起草狀態
  final TextEditingController _sellerNameController = TextEditingController();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _receiveDateController = TextEditingController();
  String _consumerNoticeResult = '';

  // 夫妻財產分配計算器狀態
  final TextEditingController _husbandPropertyController =
      TextEditingController();
  final TextEditingController _husbandDebtController = TextEditingController();
  final TextEditingController _wifePropertyController = TextEditingController();
  final TextEditingController _wifeDebtController = TextEditingController();
  String _marriagePropertyResult = '';

  // 自救與蒐證 Checklists 狀態
  final Set<String> _checkedPrivacyEvidences = {};
  final Set<String> _checkedNeighborEvidences = {};
  final Set<String> _checkedAntiFraudEvidences = {};

  final List<String> _privacySops = [
    '立即通知相關發卡銀行或電信業者進行圈存與掛失。',
    '更改所有使用相同密碼之社群與金融帳戶密碼，並啟用兩步驟驗證。',
    '蒐集個資外洩的簡訊、Email 或通知截圖作為證據。',
    '向警政署刑事警察局或撥打 165 進行諮詢備案。',
    '填寫個資侵害申訴書送交主管機關（如國家通訊傳播委員會）。'
  ];

  final List<String> _neighborSops = [
    '聯絡水電技師前來檢修，並開立「漏水原因鑑定報告書」。',
    '拍攝漏水天花板、牆面剝落及受損家具之彩色高畫質照片與錄影。',
    '進行漏水修繕工程之估價，並保存修繕估價單與工程合約。',
    '噪音爭議：準備分貝計或合格錄音器材，在不同時段進行分貝量測與錄影。',
    '記錄每次與鄰居/管委會溝通協調的時間、參與人員與對話音檔或簡訊。'
  ];

  final List<String> _antiFraudSops = [
    '撥打 165 反詐騙專線，提供「詐騙帳戶」、「匯款時間」與「金額」進行黃金30分鐘緊急圈存扣押。',
    '親自攜帶身分證、印章、匯款單據或網銀轉帳成功截圖，前往派出所製作筆錄，取得警示帳戶公文。',
    '妥善保存與詐騙集團之所有對話截圖，特別是涉及保證獲利、信用修補等引導字眼，作為訴訟證據。'
  ];

  // ==================== 自訂手繪手帳風 UI 元件 ====================

  Widget _buildStationeryToggle<T>({
    required T value,
    required T selectedValue,
    required String label,
    required ValueChanged<T> onChanged,
    required bool isDark,
    required Color activeColor,
  }) {
    final isSelected = value == selectedValue;
    return GestureDetector(
      onTap: () {
        onChanged(value);
        HapticFeedback.lightImpact();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: isDark ? 0.3 : 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected
                ? activeColor
                : (isDark ? const Color(0xFF2D3845) : const Color(0xFFE5CEB1)),
            width: isSelected ? 1.5.w : 1.w,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
            color: isSelected
                ? (isDark ? Colors.white : activeColor)
                : (isDark ? Colors.grey : const Color(0xFF7A6B53)),
          ),
        ),
      ),
    );
  }

  // ==================== 8 大生活法律工具與計算機實作 ====================

  void _calculateCarDepreciation() {
    final partsText = _partsCostController.text.trim();
    final laborText = _laborCostController.text.trim();
    final yearsText = _carAgeYearsController.text.trim();
    final monthsText = _carAgeMonthsController.text.trim();

    if (partsText.isEmpty) return;

    final double P = double.tryParse(partsText) ?? 0;
    final double L = double.tryParse(laborText) ?? 0;
    final int Y = int.tryParse(yearsText) ?? 0;
    final int M = int.tryParse(monthsText) ?? 0;

    final int N = _carDepreciationIsMotorcycle ? 3 : 5;
    final double r = _carDepreciationIsMotorcycle ? 0.533 : 0.369;
    final double minResidual = P / (N + 1.0);

    double residual = P;
    double D = 0;

    if (_carDepreciationIsDecliningBalance) {
      // 定律遞減法 (定律折舊)
      // 先計算完整年份的折舊
      for (int i = 0; i < Y; i++) {
        double d = residual * r;
        residual -= d;
        D += d;
      }
      // 再計算剩餘不足一年的月份折舊 (按月比例)
      if (M > 0) {
        double d = residual * r * (M / 12.0);
        residual -= d;
        D += d;
      }
    } else {
      // 平均法 (定額折舊)
      // 每年折舊額 = P / (N + 1)
      final double monthlyDep = P / ((N + 1.0) * 12.0);
      D = monthlyDep * (Y * 12 + M);
      residual = P - D;
    }

    // 限制度：殘值不得小於法定基本殘值
    if (residual < minResidual) {
      residual = minResidual;
      D = P - minResidual;
    }

    final double totalClaim = residual + L;

    final vehicleTypeStr =
        _carDepreciationIsMotorcycle ? '🛵 機車 (耐用 3 年)' : '🚗 汽車 (耐用 5 年)';
    final methodStr =
        _carDepreciationIsDecliningBalance ? '定律遞減法 (定律折舊)' : '平均法 (定額折舊)';

    setState(() {
      _depreciationResult = '【試算結果】\n'
          '• 車輛種類：$vehicleTypeStr\n'
          '• 計算方法：$methodStr\n'
          '• 零件原始費：\$${P.toStringAsFixed(0)} 元\n'
          '• 零件累計折舊：-\$${D.toStringAsFixed(0)} 元\n'
          '• 零件折舊後殘值：\$${residual.toStringAsFixed(0)} 元 (依法保留基本殘值)\n'
          '• 工資、烤漆與鈑金費：\$${L.toStringAsFixed(0)} 元 (工資不折舊)\n'
          '---------------------------\n'
          '💰 法院認定合理請求總額：\$${totalClaim.toStringAsFixed(0)} 元';
      LearningGameState.instance.incrementTranslatorUsage();
    });
  }

  void _calculateOvertime() {
    final salaryText = _salaryController.text.trim();
    final weekdayText = _weekdayOvertimeController.text.trim();
    final holidayText = _holidayOvertimeController.text.trim();

    if (salaryText.isEmpty) return;

    final double salary = double.tryParse(salaryText) ?? 0;
    final double weekdayHours = double.tryParse(weekdayText) ?? 0;
    final double holidayHours = double.tryParse(holidayText) ?? 0;

    // 時薪估算基數為 240 小時
    final double hourlyRate = salary / 240.0;

    // 平日加班費計算
    double weekdayPay = 0;
    if (weekdayHours <= 2) {
      weekdayPay = weekdayHours * hourlyRate * (4.0 / 3.0);
    } else {
      weekdayPay = (2 * hourlyRate * (4.0 / 3.0)) +
          ((weekdayHours - 2) * hourlyRate * (5.0 / 3.0));
    }

    // 休息日加班費計算
    double holidayPay = 0;
    if (holidayHours > 0) {
      if (holidayHours <= 2) {
        holidayPay = holidayHours * hourlyRate * 1.34;
      } else if (holidayHours <= 8) {
        holidayPay =
            (2 * hourlyRate * 1.34) + ((holidayHours - 2) * hourlyRate * 1.67);
      } else {
        holidayPay = (2 * hourlyRate * 1.34) +
            (6 * hourlyRate * 1.67) +
            ((holidayHours - 8) * hourlyRate * 2.67);
      }
    }

    final double totalPay = weekdayPay + holidayPay;

    setState(() {
      _overtimeResult = '【計算結果】\n'
          '• 您的平日平均時薪：\$${hourlyRate.toStringAsFixed(1)} 元 / 小時\n'
          '• 平日累計加班費：\$${weekdayPay.toStringAsFixed(0)} 元\n'
          '• 休息日累計加班費：\$${holidayPay.toStringAsFixed(0)} 元\n'
          '---------------------------\n'
          '💰 勞基法標準加班費應領：\$${totalPay.toStringAsFixed(0)} 元';
      LearningGameState.instance.incrementTranslatorUsage();
    });
  }

  void _calculateMarriageProperty() {
    final hpText = _husbandPropertyController.text.trim();
    final hdText = _husbandDebtController.text.trim();
    final wpText = _wifePropertyController.text.trim();
    final wdText = _wifeDebtController.text.trim();

    if (hpText.isEmpty && wpText.isEmpty) return;

    final double hp = double.tryParse(hpText) ?? 0;
    final double hd = double.tryParse(hdText) ?? 0;
    final double wp = double.tryParse(wpText) ?? 0;
    final double wd = double.tryParse(wdText) ?? 0;

    double hNet = hp - hd;
    if (hNet < 0) hNet = 0;

    double wNet = wp - wd;
    if (wNet < 0) wNet = 0;

    final double diff = (hNet - wNet).abs();
    final double claim = diff / 2.0;

    String whoClaims = '';
    if (hNet > wNet) {
      whoClaims = '妻可向夫請求分配差額';
    } else if (wNet > hNet) {
      whoClaims = '夫可向妻請求分配差額';
    } else {
      whoClaims = '雙方賸餘財產均等，無須分配';
    }

    setState(() {
      _marriagePropertyResult = '【分配試算結果】\n'
          '• 夫之婚後淨財產：\$${hNet.toStringAsFixed(0)} 元\n'
          '• 妻之婚後淨財產：\$${wNet.toStringAsFixed(0)} 元\n'
          '• 雙方婚後財產差額：\$${diff.toStringAsFixed(0)} 元\n'
          '---------------------------\n'
          '💍 分配判定：$whoClaims\n'
          '💰 依法可請求差額分配額：\$${claim.toStringAsFixed(0)} 元';
      LearningGameState.instance.incrementTranslatorUsage();
    });
  }

  LearningResultActionButton _buildLearningResultActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return LearningResultActionButton(
      icon: icon,
      label: label,
      color: color,
      onPressed: onPressed,
    );
  }

  Widget _buildLearningResultActionBar({
    required LearningResultActionButton copyAction,
    required LearningResultActionButton noteAction,
    required LearningResultActionButton exportAction,
  }) {
    return LearningResultActionBar(
      copyAction: copyAction,
      noteAction: noteAction,
      exportAction: exportAction,
    );
  }

  Widget _buildTranslatorTool(bool isDark) {
    return NotebookCard(
      hasPaperClip: true,
      backgroundColor:
          isDark ? const Color(0xFF28241B) : const Color(0xFFFFFDF8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CaseLibrarySvgIcon(CaseLibrarySvgIcons.gavel,
                  color: const Color(0xFF94610D), size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                '法律術語白話翻譯機',
                style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          buildLearningPostItInput(
            controller: _translatorController,
            hintText: '輸入判決書難懂字眼（例如：應予駁回、酌減、矧以...）',
            isDark: isDark,
            maxLines: 2,
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 6.w,
            runSpacing: 6.h,
            children: _termsMap.keys.map((term) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _translatorController.text = term;
                    _translationOutput = _termsMap[term]!;
                    LearningGameState.instance.incrementTranslatorUsage();
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF2C353F)
                        : const Color(0xFFEAE5DB),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF3B4856)
                          : const Color(0xFFD7CDBC),
                      width: 1.w,
                    ),
                  ),
                  child: Text(
                    term,
                    style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? Colors.grey.shade300
                            : const Color(0xFF5A4E3A)),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              buildLearningSealButton(
                label: '翻譯',
                onPressed: () {
                  final text = _translatorController.text.trim();
                  if (text.isEmpty) return;
                  setState(() {
                    _translationOutput = _termsMap[text] ??
                        '白話翻譯：該詞彙正在整理中。通常指「依照法律規定執行對應的法律效果或程序處置，以保障權利人權益」。';
                    LearningGameState.instance.incrementTranslatorUsage();
                  });
                },
                color: const Color(0xFF94610D),
              ),
              if (_translationOutput.isNotEmpty) ...[
                SizedBox(width: 12.w),
                buildLearningWashiTapeButton(
                  label: '清除便籤',
                  onPressed: () {
                    setState(() {
                      _translatorController.clear();
                      _translationOutput = '';
                    });
                  },
                  color: isDark ? Colors.red.shade300 : const Color(0xFFC04E4E),
                ),
              ],
            ],
          ),
          if (_translationOutput.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF332B1E) : const Color(0xFFFFFAEC),
                borderRadius: BorderRadius.circular(10.r),
                border:
                    Border.all(color: const Color(0xFFE4C179), width: 1.2.w),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _translationOutput,
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      height: 1.45,
                      color: isDark
                          ? Colors.orange.shade100
                          : const Color(0xFF5D4017),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        icon:
                            Icon(Icons.copy, size: 12.sp, color: Colors.white),
                        label:
                            Text('複製文字', style: TextStyle(fontSize: 10.5.sp)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF94610D),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 4.h),
                        ),
                        onPressed: () {
                          Clipboard.setData(
                              ClipboardData(text: _translationOutput));
                          CustomToast.show(context, '已複製譯文至剪貼簿！');
                        },
                      ),
                      SizedBox(width: 8.w),
                      ElevatedButton.icon(
                        icon: Icon(Icons.bookmark_add_outlined,
                            size: 12.sp, color: Colors.white),
                        label: Text('📌 摘錄筆記',
                            style: TextStyle(fontSize: 10.5.sp)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8D7F70),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 4.h),
                        ),
                        onPressed: () {
                          final text = _translatorController.text.trim();
                          LearningGameState.instance.addHighlight(
                            '術語：$text\n$_translationOutput',
                            '法律術語白話翻譯',
                          );
                          CustomToast.show(context, '已成功將譯文摘錄至手帳筆記！📌');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCarDepreciationTool(bool isDark) {
    return NotebookCard(
      hasBinderRings: true,
      backgroundColor:
          isDark ? const Color(0xFF1B232E) : const Color(0xFFF0F5FA),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CaseLibrarySvgIcon(CaseLibrarySvgIcons.scale,
                  color: const Color(0xFF3F7FBF), size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                '車禍零件折舊與工資計算機',
                style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            '說明：車禍更換全新零件需扣除折舊，但「工資與鈑金」免計折舊。本工具依法規提供雙重車種與折舊公式試算，並自動保留法定最低殘值。',
            style: TextStyle(
                fontSize: 11.sp, height: 1.4, color: AppColors.textSecondary),
          ),
          SizedBox(height: 12.h),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6.w,
            runSpacing: 4.h,
            children: [
              Text(
                '車輛種類：',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.grey : const Color(0xFF7A6B53),
                ),
              ),
              _buildStationeryToggle<bool>(
                value: false,
                selectedValue: _carDepreciationIsMotorcycle,
                label: '🚗 汽車 (耐用5年)',
                onChanged: (val) =>
                    setState(() => _carDepreciationIsMotorcycle = val),
                isDark: isDark,
                activeColor: const Color(0xFF3F7FBF),
              ),
              _buildStationeryToggle<bool>(
                value: true,
                selectedValue: _carDepreciationIsMotorcycle,
                label: '🛵 機車 (耐用3年)',
                onChanged: (val) =>
                    setState(() => _carDepreciationIsMotorcycle = val),
                isDark: isDark,
                activeColor: const Color(0xFF3F7FBF),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6.w,
            runSpacing: 4.h,
            children: [
              Text(
                '計算方法：',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.grey : const Color(0xFF7A6B53),
                ),
              ),
              _buildStationeryToggle<bool>(
                value: true,
                selectedValue: _carDepreciationIsDecliningBalance,
                label: '定律遞減法 (定律)',
                onChanged: (val) =>
                    setState(() => _carDepreciationIsDecliningBalance = val),
                isDark: isDark,
                activeColor: const Color(0xFF3F7FBF),
              ),
              _buildStationeryToggle<bool>(
                value: false,
                selectedValue: _carDepreciationIsDecliningBalance,
                label: '平均法 (定額)',
                onChanged: (val) =>
                    setState(() => _carDepreciationIsDecliningBalance = val),
                isDark: isDark,
                activeColor: const Color(0xFF3F7FBF),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          buildLearningNotebookInput(
            controller: _partsCostController,
            labelText: '更換零件費 (元)',
            hintText: '例如：12000',
            isDark: isDark,
            keyboardType: TextInputType.number,
          ),
          buildLearningNotebookInput(
            controller: _laborCostController,
            labelText: '鈑金與工資費 (元，免折舊)',
            hintText: '例如：8000',
            isDark: isDark,
            keyboardType: TextInputType.number,
          ),
          Row(
            children: [
              Expanded(
                child: buildLearningNotebookInput(
                  controller: _carAgeYearsController,
                  labelText: '車輛已使用年數 (年)',
                  hintText: '例如：3',
                  isDark: isDark,
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: buildLearningNotebookInput(
                  controller: _carAgeMonthsController,
                  labelText: '使用剩餘月數 (月)',
                  hintText: '例如：4',
                  isDark: isDark,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              buildLearningSealButton(
                label: '試算理賠額',
                onPressed: _calculateCarDepreciation,
                color: const Color(0xFF3F7FBF),
              ),
              if (_depreciationResult.isNotEmpty) ...[
                SizedBox(width: 12.w),
                buildLearningWashiTapeButton(
                  label: '清除',
                  onPressed: () {
                    setState(() {
                      _partsCostController.clear();
                      _laborCostController.clear();
                      _carAgeYearsController.clear();
                      _carAgeMonthsController.clear();
                      _depreciationResult = '';
                    });
                  },
                  color: isDark ? Colors.red.shade300 : const Color(0xFFC04E4E),
                ),
              ],
            ],
          ),
          if (_depreciationResult.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF232B36) : const Color(0xFFEAF1F9),
                borderRadius: BorderRadius.circular(10.r),
                border:
                    Border.all(color: const Color(0xFF8CAECC), width: 1.2.w),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _depreciationResult,
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      height: 1.45,
                      color: isDark
                          ? Colors.blue.shade100
                          : const Color(0xFF1F4C75),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  _buildLearningResultActionBar(
                    copyAction: _buildLearningResultActionButton(
                      icon: Icons.copy,
                      label: '複製文字',
                      color: const Color(0xFF3F7FBF),
                      onPressed: () {
                        Clipboard.setData(
                            ClipboardData(text: _depreciationResult));
                        CustomToast.show(context, '已複製折舊計算結果至剪貼簿！');
                      },
                    ),
                    noteAction: _buildLearningResultActionButton(
                      icon: Icons.bookmark_add_outlined,
                      label: '摘錄筆記',
                      color: const Color(0xFF8D7F70),
                      onPressed: () {
                        LearningGameState.instance.addHighlight(
                          _depreciationResult,
                          '車禍折舊理賠計算',
                        );
                        CustomToast.show(context, '已成功將折舊結果摘錄至手帳筆記！📌');
                      },
                    ),
                    exportAction: _buildLearningResultActionButton(
                      icon: Icons.picture_as_pdf_rounded,
                      label: '預覽與匯出 PDF',
                      color: HomeV2Palette.trustGreen,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LegalDocumentExportPage(
                              title: '車禍折舊理賠計算明細表',
                              content: _depreciationResult,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF26211C) : const Color(0xFFFFF9E6),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color:
                    isDark ? const Color(0xFF4C3D26) : const Color(0xFFFBE4A0),
                width: 1.w,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 14.sp,
                  color: isDark
                      ? const Color(0xFFD49C40)
                      : const Color(0xFFB37410),
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    '💡 法律小常識：民事損害賠償更換零件需扣除折舊，但『工資與烤漆費』不予折舊。折舊上限最高保留 1/6 (汽車) 或 1/4 (機車) 之基本殘值，避免被折舊歸零！',
                    style: TextStyle(
                      fontSize: 10.sp,
                      height: 1.4,
                      color: isDark
                          ? const Color(0xFFD49C40)
                          : const Color(0xFF8E5A0B),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRentNoticeTool(bool isDark) {
    return NotebookCard(
      hasPaperClip: true,
      backgroundColor:
          isDark ? const Color(0xFF1E281F) : const Color(0xFFF1FAF2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CaseLibrarySvgIcon(CaseLibrarySvgIcons.bookOpen,
                  color: const Color(0xFF2E7D32), size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                '租屋存證信函起草器',
                style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            '說明：當遇到租屋糾紛時，寄發存證信函能留下正式的法律意思表示與催告事實證明。本工具支持設備修繕催告與到期退押金催告兩種模式。',
            style: TextStyle(
                fontSize: 11.sp, height: 1.4, color: AppColors.textSecondary),
          ),
          SizedBox(height: 12.h),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6.w,
            runSpacing: 4.h,
            children: [
              Text(
                '通知類型：',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.grey : const Color(0xFF7A6B53),
                ),
              ),
              _buildStationeryToggle<int>(
                value: 0,
                selectedValue: _rentNoticeType,
                label: '🔧 設備損壞修繕',
                onChanged: (val) => setState(() {
                  _rentNoticeType = val;
                  _rentNoticeResult = '';
                }),
                isDark: isDark,
                activeColor: const Color(0xFF2E7D32),
              ),
              _buildStationeryToggle<int>(
                value: 1,
                selectedValue: _rentNoticeType,
                label: '💰 租約期滿退押金',
                onChanged: (val) => setState(() {
                  _rentNoticeType = val;
                  _rentNoticeResult = '';
                }),
                isDark: isDark,
                activeColor: const Color(0xFF2E7D32),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          buildLearningNotebookInput(
            controller: _landlordNameController,
            labelText: '房東姓名',
            hintText: '例如：王太太',
            isDark: isDark,
          ),
          buildLearningNotebookInput(
            controller: _rentAddressController,
            labelText: '承租房屋地址',
            hintText: '例如：台北市大安區忠孝東路三段XX號',
            isDark: isDark,
          ),
          if (_rentNoticeType == 0) ...[
            Row(
              children: [
                Expanded(
                  child: buildLearningNotebookInput(
                    controller: _brokenItemController,
                    labelText: '損壞故障設備',
                    hintText: '例如：客廳冷氣漏水',
                    isDark: isDark,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: buildLearningNotebookInput(
                    controller: _noticeDaysController,
                    labelText: '限期完成天數 (天)',
                    hintText: '例如：7',
                    isDark: isDark,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: buildLearningNotebookInput(
                    controller: _leaseExpiryDateController,
                    labelText: '租約到期日 (年月日)',
                    hintText: '例如：2026年6月1日',
                    isDark: isDark,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: buildLearningNotebookInput(
                    controller: _depositAmountController,
                    labelText: '押金總金額 (元)',
                    hintText: '例如：30000',
                    isDark: isDark,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            buildLearningNotebookInput(
              controller: _noticeDaysController,
              labelText: '限期退還天數 (天)',
              hintText: '例如：7',
              isDark: isDark,
              keyboardType: TextInputType.number,
            ),
          ],
          SizedBox(height: 14.h),
          Row(
            children: [
              buildLearningSealButton(
                label: '起草催告書',
                onPressed: () {
                  final landlord = _landlordNameController.text.trim();
                  final addr = _rentAddressController.text.trim();
                  final days = _noticeDaysController.text.trim().isEmpty
                      ? '7'
                      : _noticeDaysController.text.trim();

                  if (landlord.isEmpty || addr.isEmpty) return;

                  if (_rentNoticeType == 0) {
                    final item = _brokenItemController.text.trim();
                    if (item.isEmpty) return;

                    setState(() {
                      _rentNoticeResult = '郵局存證信函草稿 (設備修繕催告)\n'
                          '---------------------------\n'
                          '寄件人（承租人）：（請填寫您的姓名）\n'
                          '收件人（出租人）：$landlord\n'
                          '房屋地址：$addr\n\n'
                          '【主旨】\n'
                          '為請求儘速修繕房屋內「$item」設備事。\n\n'
                          '【說明】\n'
                          '一、本人向台端承租位於上述地址之房屋，合約存續期間，因室內配置之「$item」設備發生損壞故障，非人為故意或過失所致，已嚴重影響本人日常基本生活使用。\n'
                          '二、依中華民國民法第 429 條之規定，租賃物之修繕義務除特約外由出租人負擔。本人特以此函限期台端於收到本函起 $days 日內前來修繕完畢。\n'
                          '三、倘屆期台端仍未履行修繕義務，本人將依民法第 430 條之規定，自行雇工修繕。該次修繕所支出之所有必要估價及維修費，本人將逕自下月份應付租金中全額扣除，特此催告通知。';
                      LearningGameState.instance.incrementTranslatorUsage();
                    });
                  } else {
                    final expiryDate = _leaseExpiryDateController.text.trim();
                    final deposit = _depositAmountController.text.trim();
                    if (expiryDate.isEmpty || deposit.isEmpty) return;

                    setState(() {
                      _rentNoticeResult = '郵局存證信函草稿 (期滿退還押金催告)\n'
                          '---------------------------\n'
                          '寄件人（承租人）：（請填寫您的姓名）\n'
                          '收件人（出租人）：$landlord\n'
                          '房屋地址：$addr\n\n'
                          '【主旨】\n'
                          '為請求依法儘速返還租賃房屋押租金新台幣 $deposit 元整事。\n\n'
                          '【說明】\n'
                          '一、本人前向台端承租位於上述地址之房屋，租賃期限於 $expiryDate 屆滿。本件租賃契約業已期滿消滅，且本人已與台端完成房屋現場點交、返還房屋手續，並無欠繳租金、管理費或任何違約損害之情事。\n'
                          '二、依民法不當得利與租賃契約返還義務，台端應將本人原交付之押租金新台幣 $deposit 元整全額無息返還。特以此函限期台端於收到本函起 $days 日內返還該筆押金。\n'
                          '三、倘屆期台端仍未返還押金，本人將依法請求加計法定年利率 5% 之遲延利息，並逕循民事調解或訴訟途徑追討，特不另行通知，希勿自誤。';
                      LearningGameState.instance.incrementTranslatorUsage();
                    });
                  }
                },
                color: const Color(0xFF2E7D32),
              ),
              if (_rentNoticeResult.isNotEmpty) ...[
                SizedBox(width: 12.w),
                buildLearningWashiTapeButton(
                  label: '清除',
                  onPressed: () {
                    setState(() {
                      _landlordNameController.clear();
                      _rentAddressController.clear();
                      _brokenItemController.clear();
                      _noticeDaysController.clear();
                      _leaseExpiryDateController.clear();
                      _depositAmountController.clear();
                      _rentNoticeResult = '';
                    });
                  },
                  color: isDark ? Colors.red.shade300 : const Color(0xFFC04E4E),
                ),
              ],
            ],
          ),
          if (_rentNoticeResult.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF1B2E1D) : const Color(0xFFFAFDFB),
                borderRadius: BorderRadius.circular(10.r),
                border:
                    Border.all(color: const Color(0xFF8CBE91), width: 1.2.w),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _rentNoticeResult,
                    style: TextStyle(
                      fontSize: 11.sp,
                      height: 1.5,
                      color: isDark
                          ? Colors.green.shade100
                          : const Color(0xFF1E4E21),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  _buildLearningResultActionBar(
                    copyAction: _buildLearningResultActionButton(
                      icon: Icons.copy,
                      label: '複製文字',
                      color: const Color(0xFF2E7D32),
                      onPressed: () {
                        Clipboard.setData(
                            ClipboardData(text: _rentNoticeResult));
                        CustomToast.show(context, '已複製催告信函草稿至剪貼簿！');
                      },
                    ),
                    noteAction: _buildLearningResultActionButton(
                      icon: Icons.bookmark_add_outlined,
                      label: '摘錄筆記',
                      color: const Color(0xFF8D7F70),
                      onPressed: () {
                        LearningGameState.instance.addHighlight(
                          _rentNoticeResult,
                          _rentNoticeType == 0 ? '設備修繕催告存證信函' : '期滿退押金催告存證信函',
                        );
                        CustomToast.show(context, '已成功將草稿摘錄至手帳筆記！📌');
                      },
                    ),
                    exportAction: _buildLearningResultActionButton(
                      icon: Icons.picture_as_pdf_rounded,
                      label: '預覽與匯出 PDF',
                      color: HomeV2Palette.trustGreen,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LegalDocumentExportPage(
                              title: _rentNoticeType == 0
                                  ? '設備修繕催告存證信函'
                                  : '期滿退押金催告存證信函',
                              content: _rentNoticeResult,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2620) : const Color(0xFFF1FAF2),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color:
                    isDark ? const Color(0xFF2B472E) : const Color(0xFF8CBE91),
                width: 1.w,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 14.sp,
                  color:
                      isDark ? Colors.green.shade400 : const Color(0xFF2E7D32),
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    '💡 法律小常識：民法規定，除非有特別約定，否則房東有義務維持設備正常使用。如故意不修繕，房客自行雇工維修後，可依法從租金直接抵扣。退租時房東亦不得以折舊自然耗損為由任意扣發押金。',
                    style: TextStyle(
                      fontSize: 10.sp,
                      height: 1.4,
                      color: isDark
                          ? Colors.green.shade200
                          : const Color(0xFF1E4E21),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOvertimeTool(bool isDark) {
    return NotebookCard(
      hasBinderRings: true,
      backgroundColor:
          isDark ? const Color(0xFF2B211A) : const Color(0xFFFAF5F0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CaseLibrarySvgIcon(CaseLibrarySvgIcons.clock,
                  color: const Color(0xFFD87D32), size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                '加班費與特休折算計算機',
                style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            '說明：依勞基法平日加班 2 小時內乘 1.34 倍，後 2 小時乘 1.67 倍；休息日加班前 2 小時 1.34，後 6 小時 1.67，超過 8 小時 2.67。',
            style: TextStyle(
                fontSize: 11.sp, height: 1.4, color: AppColors.textSecondary),
          ),
          SizedBox(height: 10.h),
          buildLearningNotebookInput(
            controller: _salaryController,
            labelText: '月薪薪資 (元，以底薪計算)',
            hintText: '例如：36000',
            isDark: isDark,
            keyboardType: TextInputType.number,
          ),
          buildLearningNotebookInput(
            controller: _weekdayOvertimeController,
            labelText: '本月平日加班時數 (時)',
            hintText: '例如：10',
            isDark: isDark,
            keyboardType: TextInputType.number,
          ),
          buildLearningNotebookInput(
            controller: _holidayOvertimeController,
            labelText: '本月休息日加班時數 (時)',
            hintText: '例如：8',
            isDark: isDark,
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              buildLearningSealButton(
                label: '計算加班費',
                onPressed: _calculateOvertime,
                color: const Color(0xFFD87D32),
              ),
              if (_overtimeResult.isNotEmpty) ...[
                SizedBox(width: 12.w),
                buildLearningWashiTapeButton(
                  label: '清除',
                  onPressed: () {
                    setState(() {
                      _salaryController.clear();
                      _weekdayOvertimeController.clear();
                      _holidayOvertimeController.clear();
                      _overtimeResult = '';
                    });
                  },
                  color: isDark ? Colors.red.shade300 : const Color(0xFFC04E4E),
                ),
              ],
            ],
          ),
          if (_overtimeResult.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF352B24) : const Color(0xFFFAF4EE),
                borderRadius: BorderRadius.circular(10.r),
                border:
                    Border.all(color: const Color(0xFFECC2A8), width: 1.2.w),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _overtimeResult,
                    style: TextStyle(
                      fontSize: 12.sp,
                      height: 1.45,
                      color: isDark
                          ? Colors.orange.shade100
                          : const Color(0xFF7A4A28),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        icon:
                            Icon(Icons.copy, size: 12.sp, color: Colors.white),
                        label:
                            Text('複製文字', style: TextStyle(fontSize: 10.5.sp)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD87D32),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 4.h),
                        ),
                        onPressed: () {
                          Clipboard.setData(
                              ClipboardData(text: _overtimeResult));
                          CustomToast.show(context, '已複製加班費試算結果至剪貼簿！');
                        },
                      ),
                      SizedBox(width: 8.w),
                      ElevatedButton.icon(
                        icon: Icon(Icons.bookmark_add_outlined,
                            size: 12.sp, color: Colors.white),
                        label: Text('📌 摘錄筆記',
                            style: TextStyle(fontSize: 10.5.sp)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8D7F70),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 4.h),
                        ),
                        onPressed: () {
                          LearningGameState.instance.addHighlight(
                            _overtimeResult,
                            '加班費試算結果',
                          );
                          CustomToast.show(context, '已成功將加班費結果摘錄至手帳筆記！📌');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2B211A) : const Color(0xFFFFF7F0),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color:
                    isDark ? const Color(0xFF5A4433) : const Color(0xFFECC2A8),
                width: 1.w,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 14.sp,
                  color: isDark
                      ? const Color(0xFFD87D32)
                      : const Color(0xFFB35A10),
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    '💡 勞基法小常識：時薪計算基礎為『月薪除以 240 小時』。休息日加班前 2 小時按時薪 1.34 倍計算，第 3 到 8 小時按 1.67 倍計算。例假日原則上禁止加班，若違法加班除工資應加倍發給外，還必須給予補假一日喔！',
                    style: TextStyle(
                      fontSize: 10.sp,
                      height: 1.4,
                      color: isDark
                          ? const Color(0xFFE3A06E)
                          : const Color(0xFF8E4A10),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsumerNoticeTool(bool isDark) {
    return NotebookCard(
      hasPaperClip: true,
      backgroundColor:
          isDark ? const Color(0xFF2C1C24) : const Color(0xFFFAF1F4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CaseLibrarySvgIcon(CaseLibrarySvgIcons.filePen,
                  color: const Color(0xFFC2185B), size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                '網購退貨存證信函起草器',
                style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            '說明：通訊交易消費者，得於收受商品後七日內無條件退回商品或解除契約，無須說明理由及負擔任何費用。本工具起草退換貨存證催告信以主張權益。',
            style: TextStyle(
                fontSize: 11.sp, height: 1.4, color: AppColors.textSecondary),
          ),
          SizedBox(height: 10.h),
          buildLearningNotebookInput(
            controller: _sellerNameController,
            labelText: '賣家/平台名稱',
            hintText: '例如：蝦皮某某小鋪 / 某電商公司',
            isDark: isDark,
          ),
          buildLearningNotebookInput(
            controller: _productNameController,
            labelText: '退貨商品名稱',
            hintText: '例如：藍牙無線耳機一件',
            isDark: isDark,
          ),
          buildLearningNotebookInput(
            controller: _receiveDateController,
            labelText: '收到商品日期 (年月日)',
            hintText: '例如：2026年6月10日',
            isDark: isDark,
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              buildLearningSealButton(
                label: '起草退貨信',
                onPressed: () {
                  final seller = _sellerNameController.text.trim();
                  final product = _productNameController.text.trim();
                  final date = _receiveDateController.text.trim();

                  if (seller.isEmpty || product.isEmpty || date.isEmpty) return;

                  setState(() {
                    _consumerNoticeResult = '郵局存證信函草稿\n'
                        '---------------------------\n'
                        '寄件人（買受人）：（請填寫您的姓名）\n'
                        '收件人（出賣人）：$seller\n\n'
                        '【主旨】\n'
                        '為請求解除「$product」買賣契約並全額退還價金事。\n\n'
                        '【說明】\n'
                        '一、本人於 $date 收受向台端購買之商品「$product」，金額共計...元整並已付清。\n'
                        '二、依消費者保護法第 19 條第 1 項規定，通訊交易或訪問交易之消費者，得於收受商品或服務後七日內，以退回商品或書面通知方式解除契約，無須說明理由及負擔任何費用或對價。\n'
                        '三、本人特以此函通知台端，依法解除本件買賣契約。請台端於收到本函後儘速聯絡本人收回商品，並將本人支付之全部價金返還，特此催告通知。';
                    LearningGameState.instance.incrementTranslatorUsage();
                  });
                },
                color: const Color(0xFFC2185B),
              ),
              if (_consumerNoticeResult.isNotEmpty) ...[
                SizedBox(width: 12.w),
                buildLearningWashiTapeButton(
                  label: '清除',
                  onPressed: () {
                    setState(() {
                      _sellerNameController.clear();
                      _productNameController.clear();
                      _receiveDateController.clear();
                      _consumerNoticeResult = '';
                    });
                  },
                  color: isDark ? Colors.red.shade300 : const Color(0xFFC04E4E),
                ),
              ],
            ],
          ),
          if (_consumerNoticeResult.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF2E1C23) : const Color(0xFFFAF2F4),
                borderRadius: BorderRadius.circular(10.r),
                border:
                    Border.all(color: const Color(0xFFCE8CAE), width: 1.2.w),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _consumerNoticeResult,
                    style: TextStyle(
                      fontSize: 11.sp,
                      height: 1.5,
                      color: isDark
                          ? Colors.pink.shade100
                          : const Color(0xFF6E2849),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  _buildLearningResultActionBar(
                    copyAction: _buildLearningResultActionButton(
                      icon: Icons.copy,
                      label: '複製文字',
                      color: const Color(0xFFC2185B),
                      onPressed: () {
                        Clipboard.setData(
                            ClipboardData(text: _consumerNoticeResult));
                        CustomToast.show(context, '已複製退貨催告信函草稿至剪貼簿！');
                      },
                    ),
                    noteAction: _buildLearningResultActionButton(
                      icon: Icons.bookmark_add_outlined,
                      label: '摘錄筆記',
                      color: const Color(0xFF8D7F70),
                      onPressed: () {
                        LearningGameState.instance.addHighlight(
                          _consumerNoticeResult,
                          '網購退貨存證信函',
                        );
                        CustomToast.show(context, '已成功將草稿摘錄至手帳筆記！📌');
                      },
                    ),
                    exportAction: _buildLearningResultActionButton(
                      icon: Icons.picture_as_pdf_rounded,
                      label: '預覽與匯出 PDF',
                      color: HomeV2Palette.trustGreen,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LegalDocumentExportPage(
                              title: '網購退貨催告書狀',
                              content: _consumerNoticeResult,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2E1C24) : const Color(0xFFFAF1F4),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color:
                    isDark ? const Color(0xFF5E2E3E) : const Color(0xFFCE8CAE),
                width: 1.w,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 14.sp,
                  color: isDark
                      ? const Color(0xFFC2185B)
                      : const Color(0xFF9E0D43),
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    '💡 溫馨提醒：消保法七天鑑賞期僅適用於『企業經營者』與消費者之通訊交易。若向個人二手賣家購買、或屬於海外代購（客製化給付）、拆封後之影音或衛生用品等，依法排除適用七天無條件退貨。',
                    style: TextStyle(
                      fontSize: 10.sp,
                      height: 1.4,
                      color: isDark
                          ? const Color(0xFFEAA0C2)
                          : const Color(0xFF8E1045),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySopTool(bool isDark, LearningGameState gameState) {
    return NotebookCard(
      hasBinderRings: true,
      backgroundColor:
          isDark ? const Color(0xFF211D2B) : const Color(0xFFFAF7FD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CaseLibrarySvgIcon(CaseLibrarySvgIcons.sparkles,
                  color: const Color(0xFF512DA8), size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                '個資外洩防範自救清單',
                style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            '說明：當發生帳密外洩或可疑扣款時，請照下方步驟迅速自保。勾選項目可同步記錄，完成後可將證據清單儲存備忘。',
            style: TextStyle(
                fontSize: 11.sp, height: 1.4, color: AppColors.textSecondary),
          ),
          SizedBox(height: 10.h),
          ..._privacySops.map((sop) {
            final isChecked = _checkedPrivacyEvidences.contains(sop);
            return buildLearningHanddrawnCheckbox(
              label: sop,
              value: isChecked,
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    _checkedPrivacyEvidences.add(sop);
                  } else {
                    _checkedPrivacyEvidences.remove(sop);
                  }
                });
              },
              isDark: isDark,
            );
          }),
          SizedBox(height: 12.h),
          Row(
            children: [
              buildLearningSealButton(
                label: '儲存備忘',
                onPressed: () {
                  gameState.saveEvidenceList(
                    '個資外洩應變清單',
                    _checkedPrivacyEvidences.toList(),
                    _privacySops,
                  );
                  CustomToast.show(context, '已成功儲存自救步驟至小法助的「備忘錄」中！');
                },
                color: const Color(0xFF512DA8),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNeighborLeakTool(bool isDark, LearningGameState gameState) {
    return NotebookCard(
      hasPaperClip: true,
      backgroundColor:
          isDark ? const Color(0xFF1D282B) : const Color(0xFFF0FAF9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CaseLibrarySvgIcon(CaseLibrarySvgIcons.timeline,
                  color: const Color(0xFF00796B), size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                '鄰里漏水與噪音證據包',
                style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            '說明：天花板漏水與噪音是常見鄰里爭端。請落實以下要點以便未來在調解或民事起訴中能拿出「法官採信的關鍵證據」。',
            style: TextStyle(
                fontSize: 11.sp, height: 1.4, color: AppColors.textSecondary),
          ),
          SizedBox(height: 10.h),
          ..._neighborSops.map((sop) {
            final isChecked = _checkedNeighborEvidences.contains(sop);
            return buildLearningHanddrawnCheckbox(
              label: sop,
              value: isChecked,
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    _checkedNeighborEvidences.add(sop);
                  } else {
                    _checkedNeighborEvidences.remove(sop);
                  }
                });
              },
              isDark: isDark,
            );
          }),
          SizedBox(height: 12.h),
          Row(
            children: [
              buildLearningSealButton(
                label: '儲存備忘',
                onPressed: () {
                  gameState.saveEvidenceList(
                    '鄰里糾紛蒐證清單',
                    _checkedNeighborEvidences.toList(),
                    _neighborSops,
                  );
                  CustomToast.show(context, '已將證據蒐證清單儲存至小法助的「備忘錄」中！');
                },
                color: const Color(0xFF00796B),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMarriagePropertyTool(bool isDark) {
    return NotebookCard(
      hasBinderRings: true,
      backgroundColor:
          isDark ? const Color(0xFF281E2C) : const Color(0xFFFAF0FB),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CaseLibrarySvgIcon(CaseLibrarySvgIcons.bookOpen,
                  color: const Color(0xFF8E24AA), size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                '夫妻財產分配試算器',
                style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            '說明：法定財產制下，當婚姻關係消滅時，夫或妻現存之婚後財產扣除婚姻關係存續中所負債務後，如有剩餘，雙方應平均分配其差額（即「賸餘財產分配請求權」）。',
            style: TextStyle(
                fontSize: 11.sp, height: 1.4, color: AppColors.textSecondary),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: buildLearningNotebookInput(
                  controller: _husbandPropertyController,
                  labelText: '夫的婚後財產 (元)',
                  hintText: '例如：500000',
                  isDark: isDark,
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: buildLearningNotebookInput(
                  controller: _husbandDebtController,
                  labelText: '夫的婚後債務 (元)',
                  hintText: '例如：100000',
                  isDark: isDark,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: buildLearningNotebookInput(
                  controller: _wifePropertyController,
                  labelText: '妻的婚後財產 (元)',
                  hintText: '例如：800000',
                  isDark: isDark,
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: buildLearningNotebookInput(
                  controller: _wifeDebtController,
                  labelText: '妻的婚後債務 (元)',
                  hintText: '例如：50000',
                  isDark: isDark,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              buildLearningSealButton(
                label: '試算分配差額',
                onPressed: _calculateMarriageProperty,
                color: const Color(0xFF8E24AA),
              ),
              if (_marriagePropertyResult.isNotEmpty) ...[
                SizedBox(width: 12.w),
                buildLearningWashiTapeButton(
                  label: '清除',
                  onPressed: () {
                    setState(() {
                      _husbandPropertyController.clear();
                      _husbandDebtController.clear();
                      _wifePropertyController.clear();
                      _wifeDebtController.clear();
                      _marriagePropertyResult = '';
                    });
                  },
                  color: isDark ? Colors.red.shade300 : const Color(0xFFC04E4E),
                ),
              ],
            ],
          ),
          if (_marriagePropertyResult.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF332039) : const Color(0xFFF9EEFB),
                borderRadius: BorderRadius.circular(10.r),
                border:
                    Border.all(color: const Color(0xFFD3A2DF), width: 1.2.w),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _marriagePropertyResult,
                    style: TextStyle(
                      fontSize: 12.sp,
                      height: 1.45,
                      color: isDark
                          ? Colors.purple.shade100
                          : const Color(0xFF6A1B9A),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        icon:
                            Icon(Icons.copy, size: 12.sp, color: Colors.white),
                        label:
                            Text('複製文字', style: TextStyle(fontSize: 10.5.sp)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8E24AA),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 4.h),
                        ),
                        onPressed: () {
                          Clipboard.setData(
                              ClipboardData(text: _marriagePropertyResult));
                          CustomToast.show(context, '已複製夫妻財產分配計算結果至剪貼簿！');
                        },
                      ),
                      SizedBox(width: 8.w),
                      ElevatedButton.icon(
                        icon: Icon(Icons.bookmark_add_outlined,
                            size: 12.sp, color: Colors.white),
                        label: Text('📌 摘錄筆記',
                            style: TextStyle(fontSize: 10.5.sp)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8D7F70),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 4.h),
                        ),
                        onPressed: () {
                          LearningGameState.instance.addHighlight(
                            _marriagePropertyResult,
                            '夫妻財產分配計算結果',
                          );
                          CustomToast.show(context, '已成功將分配結果摘錄至手帳筆記！📌');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAntiFraudTool(bool isDark, LearningGameState gameState) {
    return NotebookCard(
      hasPaperClip: true,
      backgroundColor:
          isDark ? const Color(0xFF2D1E1E) : const Color(0xFFFDF0F0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CaseLibrarySvgIcon(CaseLibrarySvgIcons.bookmark,
                  color: const Color(0xFFD32F2F), size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                '詐騙通報與帳戶警示自救清單',
                style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            '說明：如果遭受詐騙並已匯款，黃金 30 分鐘內可對詐騙帳戶執行緊急「圈存扣押」，延緩資金流出。請按以下 SOP 行動。',
            style: TextStyle(
                fontSize: 11.sp, height: 1.4, color: AppColors.textSecondary),
          ),
          SizedBox(height: 10.h),
          ..._antiFraudSops.map((sop) {
            final isChecked = _checkedAntiFraudEvidences.contains(sop);
            return buildLearningHanddrawnCheckbox(
              label: sop,
              value: isChecked,
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    _checkedAntiFraudEvidences.add(sop);
                  } else {
                    _checkedAntiFraudEvidences.remove(sop);
                  }
                });
              },
              isDark: isDark,
            );
          }),
          SizedBox(height: 12.h),
          Row(
            children: [
              buildLearningSealButton(
                label: '儲存備忘',
                onPressed: () {
                  gameState.saveEvidenceList(
                    '防詐騙自救清單',
                    _checkedAntiFraudEvidences.toList(),
                    _antiFraudSops,
                  );
                  CustomToast.show(context, '已將防詐自救步驟儲存至小法助「備忘錄」中！');
                },
                color: const Color(0xFFD32F2F),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToolkitTabs(bool isDark) {
    final List<Map<String, dynamic>> tabs = [
      {'name': '翻譯機', 'color': const Color(0xFFD8B273)},
      {'name': '車禍計算', 'color': const Color(0xFF7FAECC)},
      {'name': '租屋催告', 'color': const Color(0xFF8CBE91)},
      {'name': '加班計算', 'color': const Color(0xFFECC2A8)},
      {'name': '網購退貨', 'color': const Color(0xFFCE8CAE)},
      {'name': '自救清單', 'color': const Color(0xFF9E8CCA)},
      {'name': '鄰里蒐證', 'color': const Color(0xFF8CBEC2)},
      {'name': '財產分配', 'color': const Color(0xFFD3A2DF)},
      {'name': '防詐騙', 'color': const Color(0xFFE89191)},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: tabs.map((tab) {
          final String name = tab['name'];
          final Color tabColor = tab['color'];
          final isSelected = _activeToolTab == name;
          final fontCol = isDark ? Colors.white : const Color(0xFF3B3324);

          return GestureDetector(
            onTap: () {
              setState(() {
                _activeToolTab = name;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: EdgeInsets.only(
                  right: 6.w,
                  top: isSelected ? 0.h : 4.h,
                  bottom: isSelected ? 4.h : 0.h),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? tabColor
                    : (isDark
                        ? const Color(0xFF252C34)
                        : const Color(0xFFECE6DB)),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8.r),
                  topRight: Radius.circular(8.r),
                  bottomLeft: Radius.circular(isSelected ? 0 : 8.r),
                  bottomRight: Radius.circular(isSelected ? 0 : 8.r),
                ),
                border: Border.all(
                  color: isSelected
                      ? tabColor
                      : (isDark
                          ? const Color(0xFF343F4C)
                          : const Color(0xFFD7CDBC)),
                  width: 1.w,
                ),
              ),
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w900,
                  color: isSelected
                      ? Colors.white
                      : fontCol.withValues(alpha: 0.8),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActiveTool(bool isDark, LearningGameState gameState) {
    switch (_activeToolTab) {
      case '車禍計算':
        return _buildCarDepreciationTool(isDark);
      case '租屋催告':
        return _buildRentNoticeTool(isDark);
      case '加班計算':
        return _buildOvertimeTool(isDark);
      case '網購退貨':
        return _buildConsumerNoticeTool(isDark);
      case '自救清單':
        return _buildPrivacySopTool(isDark, gameState);
      case '鄰里蒐證':
        return _buildNeighborLeakTool(isDark, gameState);
      case '財產分配':
        return _buildMarriagePropertyTool(isDark);
      case '防詐騙':
        return _buildAntiFraudTool(isDark, gameState);
      case '翻譯機':
      default:
        return _buildTranslatorTool(isDark);
    }
  }

  // 3) 常用法規快查 Widget
  Widget _buildStatuteSearchWidget() {
    return NotebookCard(
      hasBookmark: true,
      bookmarkColor: const Color(0xFF6FA8DC),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CaseLibrarySvgIcon(CaseLibrarySvgIcons.search,
                  color: const Color(0xFF3F7FBF), size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                '常用法規快速查詢',
                style: TextStyle(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 6.h,
            children: [
              _buildStatuteChip('民法'),
              _buildStatuteChip('刑法'),
              _buildStatuteChip('勞基法', actual: '勞動基準法'),
              _buildStatuteChip('消保法', actual: '消費者保護法'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatuteChip(String label, {String? actual}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => _openStatuteDatabase(initialQuery: actual ?? label),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2B38) : const Color(0xFFE8F0FE),
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(
            color: isDark ? const Color(0xFF2C3E52) : const Color(0xFFB5CFF7),
            width: 1.w,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.blue.shade100 : const Color(0xFF1F4E87),
          ),
        ),
      ),
    );
  }

  Widget _buildDailyQuizCard(bool isDark, LearningGameState gameState) {
    final now = DateTime.now();
    final todayStr = now.toIso8601String().substring(0, 10);
    final hasCompletedToday = gameState.lastDailyQuizDate == todayStr;
    final q = dailyQuizQuestionForDate(now);

    if (hasCompletedToday) {
      return NotebookCard(
        hasPaperClip: true,
        backgroundColor:
            isDark ? const Color(0xFF1B2E21) : const Color(0xFFF1FAF2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '🔥 今日簽到已完成',
                  style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.green),
                ),
                const Spacer(),
                Text(
                  '學習連擊：🔥 ${gameState.studyStreak} 天',
                  style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade800),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              '小法助提醒您：每天答對一題，法律觀念更清晰！\n明天別忘了再來簽到挑戰新題目喔！🌱',
              style: TextStyle(
                  fontSize: 11.sp, height: 1.45, color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    return NotebookCard(
      hasPaperClip: true,
      backgroundColor:
          isDark ? const Color(0xFF2C241E) : const Color(0xFFFAF6F0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CaseLibrarySvgIcon(CaseLibrarySvgIcons.star,
                  color: const Color(0xFFE8B95F), size: 18.sp),
              SizedBox(width: 8.w),
              Text(
                '📅 每日隨堂簽到挑戰',
                style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary),
              ),
              const Spacer(),
              Text(
                '目前連擊：🔥 ${gameState.studyStreak} 天',
                style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            q.question,
            style: TextStyle(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary),
          ),
          SizedBox(height: 10.h),
          // 選項
          ...List.generate(q.options.length, (index) {
            final optionText = q.options[index];
            final isSelected = _selectedDailyAnswer == index;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDailyAnswer = index;
                });
              },
              child: Container(
                margin: EdgeInsets.only(bottom: 6.h),
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark
                          ? const Color(0xFF3B3324)
                          : const Color(0xFFFFF9EC))
                      : (isDark ? const Color(0xFF1E242B) : Colors.white),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFE8B95F)
                        : (isDark ? Colors.white10 : const Color(0xFFECE5D9)),
                    width: 1.w,
                  ),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_off_rounded,
                      size: 14.sp,
                      color: isSelected ? const Color(0xFFE8B95F) : Colors.grey,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        optionText,
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: _selectedDailyAnswer == null
                    ? null
                    : () {
                        final isCorrect =
                            _selectedDailyAnswer == q.correctIndex;
                        gameState.completeDailyQuiz(isCorrect);
                        if (!isCorrect) {
                          // 加入錯題本
                          gameState.addIncorrectQuestion(
                            q.question,
                            q.options[_selectedDailyAnswer!],
                            q.options[q.correctIndex],
                            q.explanation,
                            q.options,
                          );
                        }
                        _showDailyQuizResultDialog(
                            isCorrect, q.explanation, gameState);
                        setState(() {
                          _selectedDailyAnswer = null; // 重置
                        });
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8B95F),
                  foregroundColor: const Color(0xFF6B4B14),
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r)),
                ),
                child: Text('提交答案並簽到',
                    style: TextStyle(
                        fontSize: 11.sp, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDailyQuizResultDialog(
      bool isCorrect, String explanation, LearningGameState gameState) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          title: Text(
            isCorrect ? '🎉 答對了！完成簽到' : '👏 答錯了，但簽到成功！',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isCorrect
                    ? '恭喜您答對了今日挑戰！獲得簽到經驗值 +30 XP！\n目前學習連擊：🔥 ${gameState.studyStreak} 天！'
                    : '真可惜選錯了，本題已自動幫您加入「📕 錯題本」。仍獲得基本簽到經驗值 +20 XP！\n目前學習連擊：🔥 ${gameState.studyStreak} 天！',
                style: TextStyle(fontSize: 12.5.sp, height: 1.45),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F2EA),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '⚖️ 小法助白話解析：',
                      style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF94610D)),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      explanation,
                      style: TextStyle(
                          fontSize: 11.5.sp,
                          height: 1.4,
                          color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  icon: Icon(Icons.bookmark_add_outlined, size: 14.sp),
                  label: const Text('📌 摘錄解析'),
                  onPressed: () {
                    gameState.addHighlight(
                      '解析：$explanation',
                      '每日隨堂簽到挑戰',
                    );
                    CustomToast.show(context, '已將解析成功摘錄至手帳筆記！📌');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: HomeV2Palette.trustGreen,
                    side: const BorderSide(color: HomeV2Palette.trustGreen),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r)),
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                  ),
                ),
                SizedBox(width: 12.w),
                FilledButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  style: FilledButton.styleFrom(
                    backgroundColor: HomeV2Palette.trustGreen,
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r)),
                  ),
                  child: const Text('繼續學習'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // 1) 筆記本美學設定卡片
  Widget _buildAestheticsConfigCard(bool isDark, LearningGameState gameState) {
    final titleStyle = getNotebookTextStyle(
        context,
        TextStyle(
            fontSize: 14.5.sp,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary));
    final bodyStyle = getNotebookTextStyle(
        context, TextStyle(fontSize: 12.sp, color: AppColors.textSecondary));
    final labelStyle = getNotebookTextStyle(
        context,
        TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary));

    return NotebookCard(
      hasBookmark: true,
      bookmarkColor: const Color(0xFFCE8CAE),
      backgroundColor: isDark ? const Color(0xFF1B232E) : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.palette_outlined,
                  size: 20.sp, color: const Color(0xFFCE8CAE)),
              SizedBox(width: 8.w),
              Text('筆記本美學設定', style: titleStyle),
            ],
          ),
          SizedBox(height: 10.h),
          // 手寫字體開關
          Row(
            children: [
              Icon(Icons.font_download_outlined,
                  size: 16.sp, color: AppColors.textSecondary),
              SizedBox(width: 8.w),
              Text('啟用手寫風格字體 (馬山正楷)', style: bodyStyle),
              const Spacer(),
              Switch.adaptive(
                value: gameState.useHandwrittenFont,
                activeThumbColor: HomeV2Palette.trustGreen,
                onChanged: (val) {
                  gameState.setUseHandwrittenFont(val);
                },
              ),
            ],
          ),
          const Divider(height: 14, thickness: 0.6),
          // 內頁紙張風格選擇
          Text('紙張底紋樣式：', style: labelStyle),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _buildPaperStyleChip('經典方格', 'grid',
                  gameState.notebookPaperStyle == 'grid', isDark, gameState),
              _buildPaperStyleChip('復古橫線', 'lined',
                  gameState.notebookPaperStyle == 'lined', isDark, gameState),
              _buildPaperStyleChip('極簡點陣', 'dotted',
                  gameState.notebookPaperStyle == 'dotted', isDark, gameState),
              _buildPaperStyleChip('康乃爾紙', 'cornell',
                  gameState.notebookPaperStyle == 'cornell', isDark, gameState),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaperStyleChip(String label, String value, bool isSelected,
      bool isDark, LearningGameState gameState) {
    final chipLabelStyle = getNotebookTextStyle(
        context,
        TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.bold,
          color: isSelected ? Colors.white : AppColors.textSecondary,
        ));

    return GestureDetector(
      onTap: () => gameState.setNotebookPaperStyle(value),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected
              ? HomeV2Palette.trustGreen
              : (isDark ? const Color(0xFF26323E) : const Color(0xFFF0ECE4)),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (isDark ? const Color(0xFF344A5F) : const Color(0xFFD6CFC4)),
            width: 1.w,
          ),
        ),
        child: Text(label, style: chipLabelStyle),
      ),
    );
  }

  // 2) 我的手帳貼紙簿卡片
  Widget _buildStickersAlbumCard(bool isDark, LearningGameState gameState) {
    final titleStyle = getNotebookTextStyle(
        context,
        TextStyle(
            fontSize: 14.5.sp,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary));
    final countStyle = getNotebookTextStyle(
        context,
        TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary));

    final Map<String, Map<String, dynamic>> stickersDb = {
      'sprout': {'emoji': '🌱', 'name': '法學新芽', 'desc': 'Level 1 解鎖'},
      'gavel': {'emoji': '🔨', 'name': '思辨法槌', 'desc': '翻譯機用 3 次解鎖'},
      'shield': {'emoji': '🛡️', 'name': '自救盾牌', 'desc': '儲存證據清單解鎖'},
      'trophy': {'emoji': '🏆', 'name': '擂台金盃', 'desc': '隨堂考完美解鎖'},
      'star': {'emoji': '⭐', 'name': '連擊之星', 'desc': '連擊 7 天解鎖'},
      'heart': {'emoji': '❤️', 'name': '平分秋色', 'desc': '進行折舊/加班計算'},
      'scale': {'emoji': '⚖️', 'name': '公平天平', 'desc': '製作三段論筆記'},
      'car': {'emoji': '🚗', 'name': '交通安全', 'desc': '車禍計算器解鎖'},
    };

    return NotebookCard(
      hasPaperClip: true,
      backgroundColor:
          isDark ? const Color(0xFF28251E) : const Color(0xFFFAF6F0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.style_outlined,
                  size: 20.sp, color: const Color(0xFFE8B95F)),
              SizedBox(width: 8.w),
              Text('我的手帳貼紙簿', style: titleStyle),
              const Spacer(),
              Text('已解鎖 ${gameState.unlockedStickers.length} / 8',
                  style: countStyle),
            ],
          ),
          SizedBox(height: 12.h),
          // 貼紙 Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: stickersDb.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 10.h,
              crossAxisSpacing: 8.w,
              childAspectRatio: 0.9,
            ),
            itemBuilder: (context, idx) {
              final id = stickersDb.keys.elementAt(idx);
              final item = stickersDb[id]!;
              final isUnlocked = gameState.unlockedStickers.contains(id);
              final stickerNameStyle = getNotebookTextStyle(
                  context,
                  TextStyle(
                    fontSize: 9.sp,
                    color: isUnlocked
                        ? AppColors.textPrimary
                        : AppColors.textMuted,
                    fontWeight: FontWeight.bold,
                  ));

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 38.w,
                    height: 38.w,
                    decoration: BoxDecoration(
                      color: isUnlocked
                          ? (isDark ? const Color(0xFF38332A) : Colors.white)
                          : (isDark
                              ? const Color(0xFF1E2125)
                              : const Color(0xFFEFECE6)),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isUnlocked
                            ? const Color(0xFFE8B95F)
                            : (isDark
                                ? const Color(0xFF2A2E33)
                                : const Color(0xFFDCD6CD)),
                        width: 1.2.w,
                      ),
                      boxShadow: isUnlocked
                          ? [
                              BoxShadow(
                                color: const Color(0xFFE8B95F)
                                    .withValues(alpha: 0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        isUnlocked ? item['emoji'] as String : '🔒',
                        style: TextStyle(fontSize: 18.sp),
                      ),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(item['name'] as String,
                      style: stickerNameStyle, textAlign: TextAlign.center),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // 3) 我的法律摘錄本卡片列表
  Widget _buildHighlightsSection(bool isDark, LearningGameState gameState) {
    final titleStyle = getNotebookTextStyle(
        context,
        TextStyle(
            fontSize: 14.5.sp,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary));
    final emptyTitleStyle = getNotebookTextStyle(
        context,
        TextStyle(
            fontSize: 12.5.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary));
    final emptyBodyStyle = getNotebookTextStyle(
        context,
        TextStyle(
            fontSize: 11.5.sp, height: 1.45, color: AppColors.textSecondary));
    final itemTextStyle = getNotebookTextStyle(
        context,
        TextStyle(
            fontSize: 12.5.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary));
    final sourceStyle = getNotebookTextStyle(
        context, TextStyle(fontSize: 10.sp, color: AppColors.textSecondary));
    final noteStyle = getNotebookTextStyle(
        context,
        TextStyle(
            fontSize: 11.sp,
            color: const Color(0xFF8A6C53),
            fontWeight: FontWeight.bold));

    if (gameState.savedHighlights.isEmpty) {
      return NotebookCard(
        hasPaperClip: true,
        backgroundColor:
            isDark ? const Color(0xFF1E2125) : const Color(0xFFFAF9F6),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Column(
            children: [
              Icon(Icons.bookmark_outline_rounded,
                  size: 24.sp, color: AppColors.textMuted),
              SizedBox(height: 8.h),
              Text('您的摘錄本目前是空的 📕', style: emptyTitleStyle),
              SizedBox(height: 6.h),
              Text(
                '在學習文章或課堂中，長按並選取任何一段您覺得重要的文字，在跳出的選單中點擊「劃記重點 ✍️」，即可將內容摘錄至此，並可以寫下心得隨記、塗寫螢光筆喔！',
                style: emptyBodyStyle,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
          child: Row(
            children: [
              Icon(Icons.bookmark_added_outlined,
                  size: 18.sp, color: HomeV2Palette.trustGreen),
              SizedBox(width: 8.w),
              Text('我的法律摘錄本 (${gameState.savedHighlights.length})',
                  style: titleStyle),
            ],
          ),
        ),
        SizedBox(height: 6.h),
        ...List.generate(gameState.savedHighlights.length, (index) {
          final item = gameState.savedHighlights[index];
          final text = item['highlight'] as String;
          final articleTitle = item['articleTitle'] as String;
          final note = item['note'] as String? ?? '';
          final highlightColor = item['highlightColor'] as String? ?? 'yellow';
          final stampStickerId = item['stickerId'] as String?;

          // 取得螢光筆的背景色
          Color bgHighlightColor = Colors.white;
          if (highlightColor == 'yellow') {
            bgHighlightColor =
                isDark ? const Color(0xFF38341A) : const Color(0xFFFFFAD6);
          }
          if (highlightColor == 'green') {
            bgHighlightColor =
                isDark ? const Color(0xFF1F2F20) : const Color(0xFFEDF8E9);
          }
          if (highlightColor == 'pink') {
            bgHighlightColor =
                isDark ? const Color(0xFF341F28) : const Color(0xFFFDEEF4);
          }
          if (highlightColor == 'none') {
            bgHighlightColor = isDark ? const Color(0xFF1C222A) : Colors.white;
          }

          final Map<String, String> emojiDb = {
            'sprout': '🌱',
            'gavel': '🔨',
            'shield': '🛡️',
            'trophy': '🏆',
            'star': '⭐',
            'heart': '❤️',
            'scale': '⚖️',
            'car': '🚗'
          };
          final String stampEmoji =
              stampStickerId != null ? (emojiDb[stampStickerId] ?? '') : '';

          return GestureDetector(
            onTap: () => _showHighlightDetailDialog(context, index, gameState),
            child: NotebookCard(
              backgroundColor: bgHighlightColor,
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        text,
                        style: itemTextStyle,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8.h),
                      Text('來源：$articleTitle', style: sourceStyle),
                      if (note.isNotEmpty) ...[
                        SizedBox(height: 6.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF261D15)
                                : const Color(0xFFF5EFE6),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.notes,
                                  size: 12.sp, color: const Color(0xFF8A6C53)),
                              SizedBox(width: 6.w),
                              Expanded(
                                child: Text(
                                  note,
                                  style: noteStyle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (stampEmoji.isNotEmpty)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Opacity(
                        opacity: 0.65,
                        child: Transform.rotate(
                          angle: -0.15,
                          child: Text(
                            stampEmoji,
                            style: TextStyle(fontSize: 32.sp),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // 4) 三段論邏輯思維筆記區
  Widget _buildCornellSection(bool isDark, LearningGameState gameState) {
    final titleStyle = getNotebookTextStyle(
        context,
        TextStyle(
            fontSize: 14.5.sp,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary));
    final emptyTitleStyle = getNotebookTextStyle(
        context,
        TextStyle(
            fontSize: 12.5.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary));
    final emptyBodyStyle = getNotebookTextStyle(
        context,
        TextStyle(
            fontSize: 11.5.sp, height: 1.45, color: AppColors.textSecondary));
    final buttonTextStyle = getNotebookTextStyle(
        context,
        TextStyle(
            fontSize: 11.5.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
          child: Row(
            children: [
              Icon(Icons.menu_book_outlined,
                  size: 18.sp, color: const Color(0xFFCE8CAE)),
              SizedBox(width: 8.w),
              Text('三段論邏輯思維筆記', style: titleStyle),
              const Spacer(),
              ElevatedButton.icon(
                icon: Icon(Icons.add_rounded, size: 14.sp, color: Colors.white),
                label: Text('新增筆記', style: buttonTextStyle),
                onPressed: () =>
                    _showAddCornellNoteBottomSheet(context, gameState),
                style: ElevatedButton.styleFrom(
                  backgroundColor: HomeV2Palette.trustGreen,
                  foregroundColor: Colors.white,
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  minimumSize: Size(60.w, 28.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r)),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 6.h),
        if (gameState.cornellNotes.isEmpty)
          NotebookCard(
            hasBookmark: true,
            bookmarkColor: const Color(0xFF6FA8DC),
            backgroundColor:
                isDark ? const Color(0xFF1E2125) : const Color(0xFFF4F6F8),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Column(
                children: [
                  Icon(Icons.psychology_outlined,
                      size: 24.sp, color: AppColors.textMuted),
                  SizedBox(height: 8.h),
                  Text('尚無三段論邏輯筆記 ⚖️', style: emptyTitleStyle),
                  SizedBox(height: 6.h),
                  Text(
                    '法律推理最核心的模式就是三段論。點擊上方「新增筆記」，依照「大前提（適用法律）、小前提（發生事實）、結論（您的主張）」引導，幫您把生活糾紛整理得有條有理，還能解鎖獨特的天平貼紙裝飾喔！',
                    style: emptyBodyStyle,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          ...gameState.cornellNotes
              .map((note) => _buildCornellCard(isDark, note, gameState)),
      ],
    );
  }

  // 康乃爾版面風格的三段論筆記卡片
  Widget _buildCornellCard(
      bool isDark, Map<String, dynamic> note, LearningGameState gameState) {
    final titleStyle = getNotebookTextStyle(
        context,
        TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary));
    final headerStyle = getNotebookTextStyle(
        context,
        TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF7A6B53)));
    final contentStyle = getNotebookTextStyle(
        context,
        TextStyle(
            fontSize: 11.5.sp, color: AppColors.textPrimary, height: 1.35));
    final summaryTitleStyle = getNotebookTextStyle(
        context,
        TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF2E7D32)));
    final summaryContentStyle = getNotebookTextStyle(
        context,
        TextStyle(
            fontSize: 11.5.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2E7D32),
            height: 1.35));

    final stampStickerId = note['stickerId'] as String?;
    final Map<String, String> emojiDb = {
      'sprout': '🌱',
      'gavel': '🔨',
      'shield': '🛡️',
      'trophy': '🏆',
      'star': '⭐',
      'heart': '❤️',
      'scale': '⚖️',
      'car': '🚗'
    };
    final String stampEmoji =
        stampStickerId != null ? (emojiDb[stampStickerId] ?? '') : '';

    return NotebookCard(
      padding: EdgeInsets.zero, // 自己內置邊界與康乃爾分隔線
      backgroundColor:
          isDark ? const Color(0xFF1C222A) : const Color(0xFFFFFCF5),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. 卡片頂部標題與刪除鈕
              Padding(
                padding: EdgeInsets.fromLTRB(12.w, 10.h, 8.w, 8.h),
                child: Row(
                  children: [
                    Icon(Icons.edit_note_outlined,
                        size: 15.sp, color: const Color(0xFF7A6B53)),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        note['title'] as String,
                        style: titleStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      note['date'] as String,
                      style: TextStyle(
                          fontSize: 9.sp, color: AppColors.textSecondary),
                    ),
                    SizedBox(width: 4.w),
                    IconButton(
                      icon: Icon(Icons.delete_outline_rounded,
                          size: 14.sp, color: Colors.red.shade400),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        _showDeleteConfirmDialog(
                            context, note['id'] as String, gameState);
                      },
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 0.5),

              // 2. 康乃爾左右分割區（左 Cue / 右 Notes）
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 左側分欄 Cue Column (26% 寬度)
                    Container(
                      width: 90.w,
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF222933)
                            : const Color(0xFFF9F6F0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('大前提 (法規)', style: headerStyle),
                          SizedBox(height: 28.h),
                          Text('小前提 (事實)', style: headerStyle),
                        ],
                      ),
                    ),
                    // 垂直紅線分割
                    Container(
                        width: 1.2.w,
                        color: isDark
                            ? const Color(0xFF4A282D)
                            : const Color(0xFFF0ACB4)),
                    // 右側筆記欄 Notes Column
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(note['premise'] as String,
                                style: contentStyle,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis),
                            SizedBox(height: 10.h),
                            Text(note['fact'] as String,
                                style: contentStyle,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 水平分割紅線
              Container(
                  height: 1.2.h,
                  color: isDark
                      ? const Color(0xFF4A282D)
                      : const Color(0xFFF0ACB4)),

              // 3. 底部總結區 Summary Column
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E2820)
                      : const Color(0xFFF1FAF2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('結論主張與自救救濟', style: summaryTitleStyle),
                    SizedBox(height: 3.h),
                    Text(note['conclusion'] as String,
                        style: summaryContentStyle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
          // 印章/貼紙裝飾
          if (stampEmoji.isNotEmpty)
            Positioned(
              right: 28.w,
              top: 22.h,
              child: Opacity(
                opacity: 0.65,
                child: Transform.rotate(
                  angle: -0.1,
                  child: Text(
                    stampEmoji,
                    style: TextStyle(fontSize: 34.sp),
                  ),
                ),
              ),
            ),
          // 蓋章按鈕入口
          Positioned(
            right: 32.w,
            top: 6.h,
            child: IconButton(
              icon: Icon(Icons.stars_outlined,
                  size: 14.sp, color: const Color(0xFF7A6B53)),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => _showCornellStickerPicker(
                  context, note['id'] as String, gameState),
              tooltip: '印章蓋戳裝飾',
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(
      BuildContext context, String noteId, LearningGameState gameState) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('刪除邏輯筆記？'),
          content: const Text('您確定要永久刪除此篇三段論邏輯筆記嗎？刪除後將無法還原。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                gameState.removeCornellNote(noteId);
                Navigator.pop(dialogContext);
              },
              child: const Text('刪除', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showHighlightDetailDialog(
      BuildContext context, int index, LearningGameState gameState) {
    final item = gameState.savedHighlights[index];
    final text = item['highlight'] as String;
    final noteController =
        TextEditingController(text: item['note'] as String? ?? '');
    String selectedColor = item['highlightColor'] as String? ?? 'yellow';
    String? selectedStickerId = item['stickerId'] as String?;

    showDialog(
      context: context,
      builder: (dialogContext) {
        final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
        final dialogBg =
            isDark ? const Color(0xFF1E242B) : const Color(0xFFFFFDFA);

        final titleStyle = getNotebookTextStyle(
            dialogContext,
            TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary));
        final bodyStyle = getNotebookTextStyle(
            dialogContext,
            TextStyle(
                fontSize: 12.sp, height: 1.45, color: AppColors.textSecondary));
        final labelStyle = getNotebookTextStyle(
            dialogContext,
            TextStyle(
                fontSize: 11.5.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary));
        final buttonTextStyle = getNotebookTextStyle(dialogContext,
            TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold));

        return StatefulBuilder(
          builder: (statefulContext, setDialogState) {
            final Map<String, String> emojiDb = {
              'sprout': '🌱',
              'gavel': '🔨',
              'shield': '🛡️',
              'trophy': '🏆',
              'star': '⭐',
              'heart': '❤️',
              'scale': '⚖️',
              'car': '🚗'
            };
            final String stampEmoji = selectedStickerId != null
                ? (emojiDb[selectedStickerId] ?? '')
                : '';

            // 取得螢光筆的背景色樣式
            Color previewBgColor = Colors.white;
            if (selectedColor == 'yellow') {
              previewBgColor =
                  isDark ? const Color(0xFF38341A) : const Color(0xFFFFFAD6);
            }
            if (selectedColor == 'green') {
              previewBgColor =
                  isDark ? const Color(0xFF1F2F20) : const Color(0xFFEDF8E9);
            }
            if (selectedColor == 'pink') {
              previewBgColor =
                  isDark ? const Color(0xFF341F28) : const Color(0xFFFDEEF4);
            }
            if (selectedColor == 'none') {
              previewBgColor =
                  isDark ? const Color(0xFF282D35) : const Color(0xFFF9F6F0);
            }

            return AlertDialog(
              backgroundColor: dialogBg,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r)),
              title: Row(
                children: [
                  Icon(Icons.edit_note_rounded,
                      size: 18.sp, color: HomeV2Palette.trustGreen),
                  SizedBox(width: 8.w),
                  Text('編輯摘錄筆記', style: titleStyle),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 摘錄文字預覽 (螢光筆效果)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: previewBgColor,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF2C3238)
                              : const Color(0xFFECE6DB),
                          width: 1.w,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                right: stampEmoji.isNotEmpty ? 24.w : 0),
                            child: Text(text, style: bodyStyle),
                          ),
                          if (stampEmoji.isNotEmpty)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Opacity(
                                opacity: 0.7,
                                child: Text(stampEmoji,
                                    style: TextStyle(fontSize: 26.sp)),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: 14.h),

                    // 1. 選擇螢光筆高亮色彩
                    Text('選擇螢光筆劃記色彩：', style: labelStyle),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        buildLearningHighlightColorDot(
                            'yellow', const Color(0xFFFFF2B2), selectedColor,
                            () {
                          setDialogState(() => selectedColor = 'yellow');
                        }),
                        buildLearningHighlightColorDot(
                            'green', const Color(0xFFC8E6C9), selectedColor,
                            () {
                          setDialogState(() => selectedColor = 'green');
                        }),
                        buildLearningHighlightColorDot(
                            'pink', const Color(0xFFF8BBD0), selectedColor, () {
                          setDialogState(() => selectedColor = 'pink');
                        }),
                        buildLearningHighlightColorDot(
                            'none',
                            isDark
                                ? const Color(0xFF37474F)
                                : const Color(0xFFCFD8DC),
                            selectedColor, () {
                          setDialogState(() => selectedColor = 'none');
                        }, isNone: true),
                      ],
                    ),
                    SizedBox(height: 14.h),

                    // 2. 手帳貼紙蓋戳裝飾
                    Text('手帳蓋戳印記：', style: labelStyle),
                    SizedBox(height: 6.h),
                    if (gameState.unlockedStickers.isEmpty)
                      Text('（尚無解鎖貼紙，通關專題以解鎖貼紙印章！）',
                          style: TextStyle(
                              fontSize: 10.sp, color: AppColors.textMuted))
                    else
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 4.h,
                        children: [
                          // 無印戳選項
                          GestureDetector(
                            onTap: () =>
                                setDialogState(() => selectedStickerId = null),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: selectedStickerId == null
                                    ? HomeV2Palette.trustGreen
                                    : Colors.transparent,
                                border: Border.all(
                                    color: Colors.grey.shade400, width: 0.8.w),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text('無',
                                  style: TextStyle(
                                      fontSize: 10.sp,
                                      color: selectedStickerId == null
                                          ? Colors.white
                                          : AppColors.textSecondary)),
                            ),
                          ),
                          ...gameState.unlockedStickers.map((stickerId) {
                            final emoji = emojiDb[stickerId] ?? '🌿';
                            final isSelected = selectedStickerId == stickerId;
                            return GestureDetector(
                              onTap: () => setDialogState(
                                  () => selectedStickerId = stickerId),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 6.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? HomeV2Palette.trustGreen
                                          .withValues(alpha: 0.2)
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected
                                        ? HomeV2Palette.trustGreen
                                        : Colors.grey.shade400,
                                    width: 1.w,
                                  ),
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Text(emoji,
                                    style: TextStyle(fontSize: 14.sp)),
                              ),
                            );
                          }),
                        ],
                      ),
                    SizedBox(height: 14.h),

                    // 3. 備忘隨記輸入框
                    Text('編寫我的備忘隨記：', style: labelStyle),
                    SizedBox(height: 6.h),
                    TextField(
                      controller: noteController,
                      onTapOutside: (event) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      minLines: 2,
                      maxLines: 4,
                      style: getNotebookTextStyle(
                          dialogContext,
                          TextStyle(
                              fontSize: 12.5.sp, color: AppColors.textPrimary)),
                      decoration: InputDecoration(
                        hintText: '輸入與該條文或概念相關的筆記備忘...',
                        hintStyle: TextStyle(
                            fontSize: 11.5.sp, color: AppColors.textMuted),
                        filled: true,
                        fillColor: isDark
                            ? const Color(0xFF282F37)
                            : const Color(0xFFF9F6F1),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: isDark
                                  ? const Color(0xFF34404C)
                                  : const Color(0xFFECE6DB)),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        contentPadding: EdgeInsets.all(10.w),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        gameState.removeHighlight(index);
                        Navigator.pop(dialogContext);
                      },
                      child: Text('刪除摘錄',
                          style: buttonTextStyle.copyWith(color: Colors.red)),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: Text('取消',
                              style: buttonTextStyle.copyWith(
                                  color: AppColors.textSecondary)),
                        ),
                        SizedBox(width: 4.w),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: HomeV2Palette.trustGreen,
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r)),
                          ),
                          onPressed: () {
                            gameState.updateHighlightColor(
                                index, selectedColor);
                            gameState.updateHighlightNote(
                                index, noteController.text);
                            gameState.updateHighlightSticker(
                                index, selectedStickerId);
                            Navigator.pop(dialogContext);
                          },
                          child: Text('保存',
                              style: buttonTextStyle.copyWith(
                                  color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddCornellNoteBottomSheet(
      BuildContext context, LearningGameState gameState) {
    final titleController = TextEditingController();
    final premiseController = TextEditingController();
    final factController = TextEditingController();
    final conclusionController = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
        final bg = isDark ? const Color(0xFF161C23) : const Color(0xFFFFFCF5);

        final sheetTitleStyle = getNotebookTextStyle(
            sheetContext,
            TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary));
        final labelStyle = getNotebookTextStyle(
            sheetContext,
            TextStyle(
                fontSize: 11.5.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF7A6B53)));
        final inputStyle = getNotebookTextStyle(sheetContext,
            TextStyle(fontSize: 12.5.sp, color: AppColors.textPrimary));

        return Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            border: Border.all(
                color:
                    isDark ? const Color(0xFF26323E) : const Color(0xFFECE6DB),
                width: 1.5.w),
          ),
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w,
              16.h + MediaQuery.of(sheetContext).viewInsets.bottom),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white12 : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Icon(Icons.border_color_outlined,
                        size: 18.sp, color: HomeV2Palette.trustGreen),
                    SizedBox(width: 8.w),
                    Text('撰寫三段論邏輯筆記', style: sheetTitleStyle),
                  ],
                ),
                SizedBox(height: 14.h),

                // 1. 筆記主題
                _buildSheetInput(
                  label: '主題名稱',
                  hint: '例如：租屋漏水修繕爭議、網購標錯價不發貨',
                  controller: titleController,
                  isDark: isDark,
                  labelStyle: labelStyle,
                  inputStyle: inputStyle,
                ),

                // 2. 大前提
                _buildSheetInput(
                  label: '大前提 (適用法律法規)',
                  hint:
                      '例如：民法第 430 條規定，租賃物有修繕之必要，房客催告房東修理而房東不修理時，房客可終止契約或自行修繕扣抵租金。',
                  controller: premiseController,
                  isDark: isDark,
                  minLines: 2,
                  labelStyle: labelStyle,
                  inputStyle: inputStyle,
                ),

                // 3. 小前提
                _buildSheetInput(
                  label: '小前提 (具體事實事實)',
                  hint:
                      '例如：承租套房冷氣於 2026/06/01 漏水無法運轉，於 6/2 與 6/5 用 LINE 催告房東要求修復，房東敷衍且至今均未派工處理。',
                  controller: factController,
                  isDark: isDark,
                  minLines: 2,
                  labelStyle: labelStyle,
                  inputStyle: inputStyle,
                ),

                // 4. 結論
                _buildSheetInput(
                  label: '結論 (自救主張與救濟管道)',
                  hint:
                      '例如：房客可發存證信函催告，逾期未修則自行找工維修（預估 5000 元），並在下個月租金直接扣除該維修費，或向消保會申訴調解。',
                  controller: conclusionController,
                  isDark: isDark,
                  minLines: 2,
                  labelStyle: labelStyle,
                  inputStyle: inputStyle,
                ),
                SizedBox(height: 16.h),

                // 按鈕
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        child: const Text('取消'),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: HomeV2Palette.trustGreen,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r)),
                        ),
                        onPressed: () {
                          final t = titleController.text.trim();
                          final p = premiseController.text.trim();
                          final f = factController.text.trim();
                          final c = conclusionController.text.trim();
                          if (t.isEmpty ||
                              p.isEmpty ||
                              f.isEmpty ||
                              c.isEmpty) {
                            CustomToast.show(
                                context, '⚠️ 每個欄位都是必填的喔，才能構成完整的三段論邏輯！');

                            return;
                          }
                          gameState.addCornellNote(t, p, f, c);
                          Navigator.pop(sheetContext);
                          CustomToast.show(context, '🎉 三段論筆記建立成功！解鎖公平天平貼紙！');
                        },
                        child: const Text('儲存筆記',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSheetInput({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool isDark,
    int minLines = 1,
    required TextStyle labelStyle,
    required TextStyle inputStyle,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: labelStyle),
          SizedBox(height: 6.h),
          TextField(
            controller: controller,
            onTapOutside: (event) {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            minLines: minLines,
            maxLines: minLines + 2,
            style: inputStyle,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(fontSize: 11.sp, color: AppColors.textMuted),
              filled: true,
              fillColor:
                  isDark ? const Color(0xFF282F37) : const Color(0xFFF9F6F1),
              border: OutlineInputBorder(
                borderSide: BorderSide(
                    color: isDark
                        ? const Color(0xFF34404C)
                        : const Color(0xFFECE6DB)),
                borderRadius: BorderRadius.circular(8.r),
              ),
              contentPadding: EdgeInsets.all(10.w),
            ),
          ),
        ],
      ),
    );
  }

  void _showCornellStickerPicker(
      BuildContext context, String noteId, LearningGameState gameState) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
        final dialogBg =
            isDark ? const Color(0xFF1E242B) : const Color(0xFFFFFDFA);

        final titleStyle = getNotebookTextStyle(
            dialogContext,
            TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary));
        final list = gameState.unlockedStickers.toList();

        final Map<String, String> emojiDb = {
          'sprout': '🌱',
          'gavel': '🔨',
          'shield': '🛡️',
          'trophy': '🏆',
          'star': '⭐',
          'heart': '❤️',
          'scale': '⚖️',
          'car': '🚗'
        };

        return AlertDialog(
          backgroundColor: dialogBg,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: Text('印章蓋戳裝飾', style: titleStyle),
          content: list.isEmpty
              ? Text('（尚無解鎖貼紙，通關專題以解鎖貼紙印章！）',
                  style: TextStyle(fontSize: 11.sp, color: AppColors.textMuted))
              : Wrap(
                  spacing: 12.w,
                  runSpacing: 10.h,
                  children: [
                    // 清除印章
                    GestureDetector(
                      onTap: () {
                        gameState.updateCornellSticker(noteId, null);
                        Navigator.pop(dialogContext);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.grey.shade400, width: 0.8.w),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text('無印章',
                            style: TextStyle(
                                fontSize: 11.sp,
                                color: AppColors.textSecondary)),
                      ),
                    ),
                    ...list.map((stickerId) {
                      final emoji = emojiDb[stickerId] ?? '🌿';
                      return GestureDetector(
                        onTap: () {
                          gameState.updateCornellSticker(noteId, stickerId);
                          Navigator.pop(dialogContext);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: HomeV2Palette.trustGreen, width: 1.w),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(emoji, style: TextStyle(fontSize: 18.sp)),
                        ),
                      );
                    }),
                  ],
                ),
        );
      },
    );
  }
}

// 🤖 智慧小法助輪播提問氣泡元件 (整合等級表情與自訂印花)
class _AssistantPromptBubble extends StatefulWidget {
  const _AssistantPromptBubble({required this.onMascotTap});
  final VoidCallback onMascotTap;

  @override
  State<_AssistantPromptBubble> createState() => _AssistantPromptBubbleState();
}

class _AssistantPromptBubbleState extends State<_AssistantPromptBubble> {
  late final Timer _timer;
  int _currentIndex = 0;

  static const List<String> _prompts = [
    '租屋提前解約，押金一定拿不回來嗎？',
    '車禍發生時，第一時間到底該不該移車？',
    '網購服飾拆封試穿後，到底能不能退？',
    '在臉書貼人對話截圖，會不會觸犯個資法？',
    '什麼是法律上的「應予駁回」？',
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _prompts.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentPrompt = _prompts[_currentIndex];
    final gameState = LearningGameState.instance;

    final bubbleBgColor =
        isDark ? const Color(0xFF1E2622) : const Color(0xFFF2FAF6);
    final bubbleBorderColor =
        isDark ? const Color(0xFF2E3C36) : const Color(0xFFD2E6DE);
    final textColor =
        isDark ? const Color(0xFF99C3B3) : const Color(0xFF1B4D3E);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 吉祥物頭貼
        GestureDetector(
          onTap: widget.onMascotTap,
          child: Tooltip(
            message: '開啟小法助成長檔案',
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border:
                    Border.all(color: HomeV2Palette.trustGreen, width: 1.5.w),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/assistant/law_assistant_home.png',
                  width: 40.w,
                  height: 40.w,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        // 對話氣泡 (優化動畫與排版對齊避免重疊)
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      LawAssistantChatPage(initialPrompt: currentPrompt),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: bubbleBgColor,
                border: Border.all(color: bubbleBorderColor, width: 1.2.w),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4.r),
                  topRight: Radius.circular(16.r),
                  bottomLeft: Radius.circular(16.r),
                  bottomRight: Radius.circular(16.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${gameState.levelTitle} ${gameState.mascotExpression} 提問：',
                          style: TextStyle(
                            fontSize: 9.5.sp,
                            fontWeight: FontWeight.bold,
                            color: textColor.withValues(alpha: 0.7),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        // 鎖定 ClipRect 與 AnimatedSwitcher 進行向上跑馬燈，防止新舊文字動畫期間重疊
                        ClipRect(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            layoutBuilder: (Widget? currentChild,
                                List<Widget> previousChildren) {
                              return Stack(
                                alignment: Alignment.centerLeft,
                                children: <Widget>[
                                  ...previousChildren,
                                  if (currentChild != null) currentChild,
                                ],
                              );
                            },
                            transitionBuilder: (child, animation) {
                              final isNew =
                                  child.key == ValueKey<int>(_currentIndex);
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: isNew
                                        ? const Offset(0.0, 0.2)
                                        : const Offset(0.0, -0.2),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              );
                            },
                            child: Text(
                              currentPrompt,
                              key: ValueKey<int>(_currentIndex),
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 4.w),
                  CaseLibrarySvgIcon(
                    CaseLibrarySvgIcons.chevronRight,
                    size: 12.sp,
                    color: textColor.withValues(alpha: 0.7),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// 保留此私有類別供 part 檔案外部呼叫 (編譯相容性)
class _LawBuddyAvatar extends StatelessWidget {
  const _LawBuddyAvatar();

  @override
  Widget build(BuildContext context) {
    final assistantPalette = _LawAssistantPalette.of(context);
    return SizedBox(
      width: 42.w,
      height: 42.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CaseLibrarySvgIcon(
            CaseLibrarySvgIcons.bot,
            size: 35.sp,
            color: assistantPalette.accent,
          ),
          Positioned(
            right: 3.w,
            bottom: 2.w,
            child: Container(
              width: 15.w,
              height: 15.w,
              decoration: BoxDecoration(
                color: assistantPalette.highlight,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CaseLibrarySvgIcon(
                  CaseLibrarySvgIcons.scale,
                  size: 10.sp,
                  color: assistantPalette.primaryText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
