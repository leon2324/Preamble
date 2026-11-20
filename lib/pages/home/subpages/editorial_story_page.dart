import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:preamble/components/shared/shimmer_skeleton.dart';
import 'package:preamble/features/case_library/data/case_library_repository.dart';
import 'package:preamble/features/case_library/models/case_library_models.dart';
import 'package:preamble/theme/preamble_tokens.dart';

/// 首頁「今日生活話題 / 生活案例 / 大家怎麼看」專屬專題報導閱讀頁。
///
/// 台灣繁體中文教學註解：將首頁的生活化議題定位為雜誌式專題報導，
/// 先以白話故事脈絡、雙方論點對照與生活影響引導閱讀，頁面最下方再提供
/// 「延伸閱讀：前往對應法院判決卷宗」作為選用入口，不直接把讀者丟進硬派裁判書頁面。
class EditorialStoryPage extends StatefulWidget {
  const EditorialStoryPage({
    super.key,
    required this.categoryLabel,
    required this.subtitleBadge,
    required this.title,
    required this.leftLabel,
    required this.leftSummary,
    required this.rightLabel,
    required this.rightSummary,
    required this.caseId,
    required this.onOpenCaseDossier,
  });

  final String categoryLabel;
  final String subtitleBadge;
  final String title;
  final String leftLabel;
  final String leftSummary;
  final String rightLabel;
  final String rightSummary;
  final String caseId;
  final ValueChanged<String> onOpenCaseDossier;

  @override
  State<EditorialStoryPage> createState() => _EditorialStoryPageState();
}

class _EditorialStoryPageState extends State<EditorialStoryPage> {
  CaseBook? _caseBook;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCaseStory();
  }

  Future<void> _loadCaseStory() async {
    try {
      final book =
          await CaseLibraryRepository.instance.getCaseDetail(widget.caseId);
      if (mounted) {
        setState(() {
          _caseBook = book;
          _loading = false;
        });
      }
    } catch (_) {
      final fallback =
          CaseLibraryRepository.instance.getCaseById(widget.caseId);
      if (mounted) {
        setState(() {
          _caseBook = fallback;
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final book = _caseBook;
    final hasStory = book != null &&
        book.background.trim().isNotEmpty &&
        book.titleZh != '案件載入中...';

    return Scaffold(
      backgroundColor: t.canvas,
      appBar: AppBar(
        backgroundColor: t.canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(CupertinoIcons.back, color: t.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '生活專題報導',
          style: t.serifTitle(size: 17.sp),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(18.w, 8.h, 18.w, 40.h),
        children: [
          // 雜誌分類標籤列
          Wrap(
            spacing: 8.w,
            runSpacing: 6.h,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: t.brandContainer,
                  borderRadius: BorderRadius.circular(99.r),
                ),
                child: Text(
                  widget.categoryLabel,
                  style: t.sansTitle(
                    size: 11.5.sp,
                    color: t.brandOnContainer,
                  ),
                ),
              ),
              Text(
                widget.subtitleBadge,
                style: t.sansBody(size: 12.sp, color: t.textSecondary),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // 專題大標題
          Text(
            widget.title,
            style: t.serifTitle(size: 21.sp, height: 1.35),
          ),
          SizedBox(height: 16.h),

          // 雙欄觀點對照摘要卡
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: t.cardDecoration(radius: 18.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.leftLabel,
                  style: t.sansTitle(size: 12.5.sp, color: t.textSecondary),
                ),
                SizedBox(height: 4.h),
                Text(
                  widget.leftSummary,
                  style: t.sansBody(size: 13.sp, height: 1.55),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  child: Divider(color: t.border, height: 1),
                ),
                Text(
                  widget.rightLabel,
                  style: t.sansTitle(size: 12.5.sp, color: t.brandPrimary),
                ),
                SizedBox(height: 4.h),
                Text(
                  widget.rightSummary,
                  style: t.sansBody(
                    size: 13.sp,
                    weight: FontWeight.w600,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          // 專題報導本文（載入中顯示骨架波紋）
          if (_loading) ...[
            ShimmerSkeleton(
              width: double.infinity,
              height: 140.h,
              borderRadius: 18.r,
            ),
            SizedBox(height: 14.h),
            ShimmerSkeleton(
              width: double.infinity,
              height: 110.h,
              borderRadius: 18.r,
            ),
          ] else if (hasStory) ...[
            _EditorialSection(
              title: '事件來龍去脈',
              body: book.background,
            ),
            if (book.fullStory.trim().isNotEmpty) ...[
              SizedBox(height: 16.h),
              _EditorialSection(
                title: '關鍵轉折與社會意義',
                body: book.fullStory,
              ),
            ],
            if (book.memoryLine.trim().isNotEmpty) ...[
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: t.accentBrassContainer,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      PhosphorIconsFill.lightbulb,
                      size: 18.sp,
                      color: t.accentOnBrassContainer,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '白話一句話帶走',
                            style: t.sansTitle(
                              size: 12.5.sp,
                              color: t.accentOnBrassContainer,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            book.memoryLine,
                            style: t.sansBody(
                              size: 13.sp,
                              color: t.accentOnBrassContainer,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
          SizedBox(height: 24.h),

          // 頁面最下方選用入口：延伸閱讀判決卷宗
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: t.subtleBoxDecoration(radius: 16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '想看更深入的法院審理紀錄與思辨工具？',
                  style: t.sansTitle(size: 13.sp, color: t.textSecondary),
                ),
                SizedBox(height: 10.h),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onOpenCaseDossier(widget.caseId);
                    },
                    icon: Icon(
                      PhosphorIconsRegular.scales,
                      size: 16.sp,
                      color: t.brandPrimary,
                    ),
                    label: Text(
                      '延伸閱讀：前往對應法院判決卷宗',
                      style: t.sansTitle(
                        size: 13.sp,
                        color: t.brandPrimary,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: t.brandPrimary),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
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
}

class _EditorialSection extends StatelessWidget {
  const _EditorialSection({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: t.cardDecoration(radius: 18.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: t.serifTitle(size: 16.sp)),
          SizedBox(height: 8.h),
          Text(
            body,
            style: t.sansBody(
              size: 13.5.sp,
              color: t.textPrimary,
              height: 1.68,
            ),
          ),
        ],
      ),
    );
  }
}
