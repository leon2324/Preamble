import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/features/case_library/data/case_interactive_profiles.dart';
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

  // 根據角色立場與案件事實產生擬真、有建設性的第一人稱回答
  void _sendQuestion(String text) {
    setState(() {
      _chatMessages.add({
        'isMe': true,
        'text': text,
        'sender': '詰問人',
      });
    });

    _scrollToBottom();

    // 擬真 AI 回答延遲
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;

      final reply = CaseInteractiveProfiles.getWitnessReply(
        widget.book,
        _selectedRole.role,
        text,
      );

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
    // 依據案件與選定角色，獲取量身打造的詰問快捷金句
    final questions = CaseInteractiveProfiles.getWitnessQuickQuestions(
      widget.book,
      _selectedRole.role,
    );

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
            fontWeight: FontWeight.w600,
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
