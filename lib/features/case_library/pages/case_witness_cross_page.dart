import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/features/case_library/models/case_library_models.dart';
import 'package:preamble/features/case_library/theme/case_library_theme.dart';

class CaseWitnessCrossPage extends StatefulWidget {
  const CaseWitnessCrossPage({super.key, required this.book});

  final CaseBook book;

  @override
  State<CaseWitnessCrossPage> createState() => _CaseWitnessCrossPageState();
}

class _CaseWitnessCrossPageState extends State<CaseWitnessCrossPage> {
  late CasePersonRole _selectedRole;
  final List<Map<String, dynamic>> _chatMessages = [];
  final ScrollController _scrollController = ScrollController();

  // 針對不同角色預設 3 個最具交鋒張力的「快捷詰問金句」
  final Map<String, List<String>> _quickQuestions = {
    '被告': [
      '既然宣稱是和平集會，為何要強行衝撞大門損壞公物？',
      '在面臨警方驅離時，被告等人的主觀意圖到底是什麼？',
      '你認為「公民不服從」可以做為違法行為的免死金牌嗎？',
    ],
    '檢方': [
      '檢方在起訴被告時，主要依據哪些客觀證據？',
      '是否考量過起訴可能造成對集會自由人權的寒蟬效應？',
      '公訴機關如何論證被告等人的行為已逾越了言論自由界線？',
    ],
    '指揮官': [
      '在執行驅離行動中，警方是否有使用過度暴力的具體證據？',
      '現場指揮時，警方是如何遵守比例原則與警械使用條例的？',
      '對於群眾受傷一事，警方目前的態度與檢討為何？',
    ],
    '被害人': [
      '事發當時你所經歷的最真實情境與感受是什麼？',
      '你認為司法判決目前有還給被害人應有的公道嗎？',
      '對於加害者或相關單位的處置，你有哪些實質期待？',
    ],
    '預設': [
      '此案件最核心的法理爭議到底是什麼？',
      '法院在審理中，如何權衡法治秩序與人權自由？',
      '此案件對台灣社會制度產生了什麼實質影響？',
    ]
  };

  @override
  void initState() {
    super.initState();
    // 預設選擇第一個角色，若無角色則使用預設 Mock 角色
    if (widget.book.people.isNotEmpty) {
      _selectedRole = widget.book.people.first;
    } else {
      _selectedRole = const CasePersonRole(
        role: '被告/運動領袖',
        description: '本案的關鍵行為人與運動組織者。',
      );
    }
    _addSystemMessage();
  }

  void _addSystemMessage() {
    _chatMessages.clear();
    _chatMessages.add({
      'isMe': false,
      'text':
          '我是本案的【${_selectedRole.role}】代表。你現在是詰問人，請點選下方的快捷金句或對我提問，我將根據真實庭審筆錄與我方立場向你解答。',
      'sender': _selectedRole.role,
    });
  }

  void _selectRole(CasePersonRole role) {
    setState(() {
      _selectedRole = role;
      _addSystemMessage();
    });
  }

  // 模擬 AI 根據角色立場與案件事實產生擬真、有建設性的第一人稱回答
  void _sendQuestion(String text) {
    setState(() {
      _chatMessages.add({
        'isMe': true,
        'text': text,
        'sender': '詰問人',
      });
    });

    _scrollToBottom();

    // 模擬 AI 回答延遲
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;

      String reply = '';
      final roleTitle = _selectedRole.role;

      if (roleTitle.contains('被告') || roleTitle.contains('領袖')) {
        if (text.contains('衝撞')) {
          reply =
              '我們當時並非以破壞為目的。在《兩岸服貿協議》面臨黑箱程序審查、民主憲政受重大威脅且毫無其他救濟管道時，我們強行進入是為保全更重大的憲政民主秩序。此行為屬於「公民不服從」的合憲防禦範疇。';
        } else if (text.contains('意圖')) {
          reply =
              '我們的意圖十分單純，就是要求「退回服貿、捍衛民主」。我們的手段是非暴力的和平集會，旨在喚起全民對程序正義的重視，絕無煽惑他人犯罪之惡意。';
        } else {
          reply =
              '「公民不服從」絕非免死金牌，它有極嚴格的超法規阻卻違法要件：必須是非暴力、出於公益、面臨民主制度的重大侵害，且是最後手段。我們在法庭上也是基於這些憲法精神為自己辯護，並最終獲得法院肯認。';
        }
      } else if (roleTitle.contains('檢') || roleTitle.contains('訴')) {
        if (text.contains('起訴')) {
          reply =
              '公訴機關是依據被告等人強行闖入立法院、毀損公物、妨害執行公務的客觀事實起訴。法律面前人人平等，無論動機多麼高尚，違法犯罪行為仍應受司法檢驗，這也是維護法治秩序的必要手段。';
        } else if (text.contains('寒蟬')) {
          reply =
              '我們理解社會對人權保障的期待，但檢方的職責是落實法律實施。起訴是為了劃分和平表達與違法暴力破壞的界線，保護多數人安全與公共財產，並非打壓集會言論自由。';
        } else {
          reply =
              '言論自由與集會遊行是憲法基本權利，但並非毫無限制。當抗爭手段涉及實體暴力、侵入政府機關首要禁區，且癱瘓國家機關正常運作時，即已逾越了和平示威的界線，應受刑法追溯。';
        }
      } else if (roleTitle.contains('被害人')) {
        reply =
            '那一刻對我們而言是非常驚恐且受傷的。我們希望社會在探討宏大法理的同時，也能看見受害個體在身體與心靈上承受的實質傷害，這才是司法正義不可忽視的另一面。';
      } else {
        // 預設回答
        reply =
            '這起案件在台灣法治史上有著舉足輕重的地位，不僅劃定了公民抗爭的界線，也促使司法機關在法條適用上，注入了更多憲法思維與平等權人權保障。';
      }

      setState(() {
        _chatMessages.add({
          'isMe': false,
          'text': reply,
          'sender': _selectedRole.role,
        });
      });

      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((__) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 獲取目前角色對應的問題，若無對應則使用預設問題
    List<String> questions = [];
    final roleTitle = _selectedRole.role;
    if (roleTitle.contains('被告') || roleTitle.contains('領袖')) {
      questions = _quickQuestions['被告']!;
    } else if (roleTitle.contains('檢') || roleTitle.contains('訴')) {
      questions = _quickQuestions['檢方']!;
    } else if (roleTitle.contains('指揮')) {
      questions = _quickQuestions['指揮官']!;
    } else if (roleTitle.contains('被害')) {
      questions = _quickQuestions['被害人']!;
    } else {
      questions = _quickQuestions['預設']!;
    }

    return Scaffold(
      backgroundColor: CaseLibraryColors.bgCream,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: CaseLibraryColors.bgCream,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: CaseLibraryColors.primaryGreen,
            size: 20.sp,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '虛擬詰問室',
          style: TextStyle(
            fontFamily: 'Songti TC',
            fontFamilyFallback: const ['Songti SC', 'STSong', 'PingFang TC'],
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: CaseLibraryColors.primaryGreen,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. 關係人選擇橫欄 (橫向滑動頭像卡片)
            Container(
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: CaseLibraryColors.borderLight),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '點選以選擇詰問對象：',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: CaseLibraryColors.textMuted,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final role in widget.book.people.isEmpty
                            ? [
                                const CasePersonRole(
                                    role: '被告/運動領袖', description: '林飛帆等被告。'),
                                const CasePersonRole(
                                    role: '公訴檢察官', description: '代表國家起訴。')
                              ]
                            : widget.book.people)
                          GestureDetector(
                            onTap: () => _selectRole(role),
                            child: Container(
                              margin: EdgeInsets.only(right: 8.w),
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 8.h,
                              ),
                              decoration: BoxDecoration(
                                color: _selectedRole.role == role.role
                                    ? const Color(0xFFEAF6EF)
                                    : const Color(0xFFFAF7F0),
                                border: Border.all(
                                  color: _selectedRole.role == role.role
                                      ? CaseLibraryColors.primaryGreen
                                      : CaseLibraryColors.borderLight,
                                ),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 10.r,
                                    backgroundColor:
                                        _selectedRole.role == role.role
                                            ? CaseLibraryColors.primaryGreen
                                            : const Color(0xFFC8A261),
                                    child: Icon(
                                      Icons.person,
                                      size: 10.sp,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(
                                    role.role,
                                    style: TextStyle(
                                      fontSize: 11.5.sp,
                                      fontWeight: FontWeight.bold,
                                      color: _selectedRole.role == role.role
                                          ? CaseLibraryColors.primaryGreen
                                          : CaseLibraryColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // 2. 對話聊天區
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.all(16.w),
                itemCount: _chatMessages.length,
                itemBuilder: (context, index) {
                  final msg = _chatMessages[index];
                  final isMe = msg['isMe'] as bool;
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: Row(
                      mainAxisAlignment: isMe
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isMe) ...[
                          CircleAvatar(
                            backgroundColor: const Color(0xFFC8A261),
                            radius: 15.r,
                            child: Text(
                              msg['sender'].toString().substring(0, 1),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(width: 8.w),
                        ],
                        Flexible(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 10.h,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isMe ? const Color(0xFFD0E0D6) : Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(14.r),
                                topRight: Radius.circular(14.r),
                                bottomLeft:
                                    isMe ? Radius.circular(14.r) : Radius.zero,
                                bottomRight:
                                    isMe ? Radius.zero : Radius.circular(14.r),
                              ),
                              border: Border.all(
                                color: isMe
                                    ? const Color(0xFFB5CDC0)
                                    : CaseLibraryColors.borderLight,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (!isMe) ...[
                                  Text(
                                    msg['sender'].toString(),
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFFC8A261),
                                    ),
                                  ),
                                  SizedBox(height: 3.h),
                                ],
                                Text(
                                  msg['text'].toString(),
                                  style: TextStyle(
                                    fontSize: 12.5.sp,
                                    height: 1.5,
                                    color: CaseLibraryColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isMe) ...[
                          SizedBox(width: 8.w),
                          CircleAvatar(
                            backgroundColor: CaseLibraryColors.primaryGreen,
                            radius: 15.r,
                            child: Icon(
                              Icons.gavel_rounded,
                              size: 13.sp,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
            // 3. 快捷詰問按鈕 (引導金句)
            Container(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.r),
                  topRight: Radius.circular(20.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.record_voice_over_rounded,
                        color: CaseLibraryColors.primaryGreen,
                        size: 15.sp,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        '詰問問題建議 (點選直接發問)：',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: CaseLibraryColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  for (final q in questions)
                    Padding(
                      padding: EdgeInsets.only(bottom: 6.h),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _sendQuestion(q),
                          borderRadius: BorderRadius.circular(10.r),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAF8F5),
                              border: Border.all(
                                color: const Color(0xFFE6E2D8),
                              ),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    q,
                                    style: TextStyle(
                                      fontSize: 11.5.sp,
                                      color: CaseLibraryColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.send_rounded,
                                  size: 13.sp,
                                  color: const Color(0xFFC8A261),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
