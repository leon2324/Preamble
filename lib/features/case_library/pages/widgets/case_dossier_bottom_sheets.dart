part of '../case_dossier_detail_page.dart';

// 這個 part 檔集中收納案件詳情頁的 Bottom Sheet UI。
// 呼叫時機、route/navigation 與資料 helper 仍保留在主頁狀態類別中。

extension _CaseDossierBottomSheets on _CaseDossierDetailPageState {
  void _showLawBottomSheet(BuildContext context, RelatedLaw law) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: CaseLibraryColors.bgCream,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 36.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: CaseLibraryColors.borderLight,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    child: Text(
                      '${law.lawName} ${law.articleNumber}',
                      style: TextStyle(
                        fontFamily: 'Songti TC',
                        fontFamilyFallback: const [
                          'BiauKai',
                          'Songti SC',
                          'STSong'
                        ],
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: CaseLibraryColors.primaryGreen,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color:
                          CaseLibraryColors.accentGold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      '關聯法條',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: CaseLibraryColors.accentGold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              const Divider(color: CaseLibraryColors.borderLight),
              SizedBox(height: 16.h),
              Text(
                '【條文概要與釋義】',
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w900,
                  color: CaseLibraryColors.accentGold,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                law.plainSummary,
                style: TextStyle(
                  fontSize: 13.sp,
                  height: 1.6,
                  color: CaseLibraryColors.textPrimary,
                ),
              ),
              if (law.relationToCase.isNotEmpty) ...[
                SizedBox(height: 20.h),
                Text(
                  '【本案關聯與適用】',
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w900,
                    color: CaseLibraryColors.accentGold,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  law.relationToCase,
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    height: 1.6,
                    color: CaseLibraryColors.textSecondary,
                  ),
                ),
              ],
              SizedBox(height: 28.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CaseLibraryColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('我知道了',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showHoldingBottomSheet(BuildContext context, _TrialStep step) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: CaseLibraryColors.bgCream,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 36.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: CaseLibraryColors.borderLight,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color:
                          CaseLibraryColors.accentGold.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      step.stage,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: CaseLibraryColors.accentGold,
                      ),
                    ),
                  ),
                  Text(
                    step.date,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: CaseLibraryColors.textMuted,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                step.courtName,
                style: TextStyle(
                  fontFamily: 'Songti TC',
                  fontFamilyFallback: const ['BiauKai', 'Songti SC', 'STSong'],
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: CaseLibraryColors.primaryGreen,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                step.caseNumber,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: CaseLibraryColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 16.h),
              const Divider(color: CaseLibraryColors.borderLight),
              SizedBox(height: 16.h),
              Text(
                '判決主文與核心理由',
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w900,
                  color: CaseLibraryColors.primaryGreen,
                ),
              ),
              SizedBox(height: 10.h),
              Flexible(
                child: SingleChildScrollView(
                  child: Text(
                    step.holdingDetail,
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      height: 1.6,
                      color: CaseLibraryColors.textPrimary,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: CaseLibraryColors.primaryGreen,
                        side: const BorderSide(
                            color: CaseLibraryColors.primaryGreen),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      icon: CaseLibrarySvgIcon(
                        CaseLibrarySvgIcons.copy,
                        size: 16.sp,
                        color: CaseLibraryColors.primaryGreen,
                      ),
                      label: const Text('複製案號資訊',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () {
                        Navigator.of(context).pop();
                        CustomToast.show(context,
                            '已複製：${step.courtName} ${step.caseNumber}');
                      },
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CaseLibraryColors.primaryGreen,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      icon: CaseLibrarySvgIcon(
                        CaseLibrarySvgIcons.externalLink,
                        size: 16.sp,
                        color: Colors.white,
                      ),
                      label: const Text('官方裁判書連結',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () {
                        Navigator.of(context).pop();
                        CustomToast.show(context, '正在開起司法行政機關裁判書系統...');
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showGlossaryBottomSheet(BuildContext context, _GlossaryItem item) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: CaseLibraryColors.bgCream,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 36.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: CaseLibraryColors.borderLight,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    item.term,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: CaseLibraryColors.primaryGreen,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      '(${item.pinyin})',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontStyle: FontStyle.italic,
                        color: CaseLibraryColors.textMuted,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              const Divider(color: CaseLibraryColors.borderLight),
              SizedBox(height: 16.h),
              Text(
                '【名詞釋義】',
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w900,
                  color: CaseLibraryColors.accentGold,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                item.definition,
                style: TextStyle(
                  fontSize: 13.sp,
                  height: 1.5,
                  color: CaseLibraryColors.textPrimary,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                '【本案關聯】',
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w900,
                  color: CaseLibraryColors.accentGold,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                item.importance,
                style: TextStyle(
                  fontSize: 12.5.sp,
                  height: 1.5,
                  color: CaseLibraryColors.textSecondary,
                ),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CaseLibraryColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: const Text('我知道了',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void showNoteBottomSheet(BuildContext context) {
    final appState = PreambleScope.of(context);
    final caseId = widget.book.id;
    final initialNote = appState.caseNoteDraft(caseId) ?? '';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _CaseStudyNoteSheet(
          book: widget.book,
          initialNote: initialNote,
          onSaveDraft: (text) => appState.saveCaseNoteDraft(caseId, text),
        );
      },
    );
  }
}

class _CaseStudyNoteSheet extends StatefulWidget {
  const _CaseStudyNoteSheet({
    required this.book,
    required this.initialNote,
    required this.onSaveDraft,
  });

  final CaseBook book;
  final String initialNote;
  final ValueChanged<String> onSaveDraft;

  @override
  State<_CaseStudyNoteSheet> createState() => _CaseStudyNoteSheetState();
}

class _CaseStudyNoteSheetState extends State<_CaseStudyNoteSheet> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;
  String _selectedTag = '爭點筆記';
  bool _hasUnsavedDraft = false;

  static const _noteTags = ['爭點筆記', '法條重點', '實務疑問', '生活應用'];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNote);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    widget.onSaveDraft(_controller.text);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged(String text) {
    if (!_hasUnsavedDraft) {
      setState(() => _hasUnsavedDraft = true);
    } else {
      setState(() {});
    }
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      widget.onSaveDraft(_controller.text);
      if (mounted) {
        setState(() => _hasUnsavedDraft = false);
      }
    });
  }

  void _insertTemplate(String snippet) {
    HapticFeedback.selectionClick();
    final current = _controller.text;
    final prefix = current.trim().isEmpty ? '' : '\n';
    final nextText = '$current$prefix$snippet';
    _controller.value = TextEditingValue(
      text: nextText,
      selection: TextSelection.collapsed(offset: nextText.length),
    );
    _onTextChanged(nextText);
    if (!_focusNode.hasFocus) {
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final caseTitle = widget.book.shortTitleZh.isNotEmpty
        ? widget.book.shortTitleZh
        : widget.book.titleZh;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: CaseLibraryColors.bgCream,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 18.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: CaseLibraryColors.borderLight,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 14.h),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '案件學習筆記',
                            style: TextStyle(
                              fontFamily: 'Songti TC',
                              fontFamilyFallback: const [
                                'Songti SC',
                                'STSong',
                                'PingFang TC'
                              ],
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w700,
                              color: CaseLibraryColors.primaryGreen,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            caseTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: CaseLibraryColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        border:
                            Border.all(color: CaseLibraryColors.borderLight),
                      ),
                      child: Text(
                        _hasUnsavedDraft
                            ? '${_controller.text.length} 字 · 暫存中'
                            : '${_controller.text.length} 字 · 已同步',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: CaseLibraryColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // 筆記標籤快選（點擊可直接帶入模板）
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _noteTags.map((tag) {
                      final isSelected = tag == _selectedTag;
                      return Padding(
                        padding: EdgeInsets.only(right: 6.w),
                        child: InkWell(
                          onTap: () {
                            setState(() => _selectedTag = tag);
                            _insertTemplate('[$tag] ');
                          },
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 5.h,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? CaseLibraryColors.primaryGreen
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: isSelected
                                    ? CaseLibraryColors.primaryGreen
                                    : CaseLibraryColors.borderLight,
                              ),
                            ),
                            child: Text(
                              '+ $tag',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? Colors.white
                                    : CaseLibraryColors.primaryGreen,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                if (widget.book.legalIssues.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: widget.book.legalIssues.take(3).map((issue) {
                        return Padding(
                          padding: EdgeInsets.only(right: 6.w),
                          child: InkWell(
                            onTap: () =>
                                _insertTemplate('【引用爭點】${issue.title}\n想法：'),
                            borderRadius: BorderRadius.circular(8.r),
                            child: Container(
                              constraints: BoxConstraints(maxWidth: 210.w),
                              padding: EdgeInsets.symmetric(
                                horizontal: 9.w,
                                vertical: 5.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF4F1),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                '引用：${issue.title}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10.5.sp,
                                  fontWeight: FontWeight.w700,
                                  color: CaseLibraryColors.primaryGreen,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
                SizedBox(height: 12.h),

                TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  maxLines: 5,
                  minLines: 4,
                  onChanged: _onTextChanged,
                  style: TextStyle(
                    fontSize: 13.sp,
                    height: 1.5,
                    color: CaseLibraryColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: '點上方標籤快速整理爭點，或寫下你對本案的思考...',
                    hintStyle: TextStyle(
                      fontSize: 12.5.sp,
                      color: CaseLibraryColors.textMuted,
                    ),
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: EdgeInsets.all(12.w),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(
                        color: CaseLibraryColors.borderLight,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(
                        color: CaseLibraryColors.borderLight,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(
                        color: CaseLibraryColors.primaryGreen,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 14.h),
                Row(
                  children: [
                    if (_focusNode.hasFocus)
                      TextButton(
                        onPressed: () => _focusNode.unfocus(),
                        child: Text(
                          '收起鍵盤',
                          style: TextStyle(
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w600,
                            color: CaseLibraryColors.textSecondary,
                          ),
                        ),
                      ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        '關閉',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: CaseLibraryColors.primaryGreen,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CaseLibraryColors.primaryGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      onPressed: () {
                        _debounce?.cancel();
                        widget.onSaveDraft(_controller.text);
                        Navigator.of(context).pop();
                        CustomToast.show(context, '筆記儲存成功！');
                      },
                      child: Text(
                        '儲存筆記',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
