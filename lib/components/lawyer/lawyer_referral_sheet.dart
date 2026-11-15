import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:preamble/components/shared/custom_toast.dart';
import 'package:preamble/data/lawyer/lawyer_models.dart';
import 'package:preamble/data/lawyer/lawyer_repository.dart';
import 'package:preamble/theme/preamble_tokens.dart';

/// 《緒言 Preamble》執業律師精準轉介與案件交辦面板 (Lawyer Referral & Handover Sheet)。
///
/// 讓使用者一鍵將 AI 彙整好的案情簡報（Case Brief）加密交辦給專長執業律師預約諮詢。
class LawyerReferralSheet extends StatefulWidget {
  const LawyerReferralSheet({
    super.key,
    required this.caseBrief,
  });

  final CaseBrief caseBrief;

  static Future<void> show(
    BuildContext context, {
    required CaseBrief caseBrief,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LawyerReferralSheet(caseBrief: caseBrief),
    );
  }

  @override
  State<LawyerReferralSheet> createState() => _LawyerReferralSheetState();
}

class _LawyerReferralSheetState extends State<LawyerReferralSheet> {
  final LawyerRepository _repository = LawyerRepository();
  late List<LawyerProfile> _lawyers;
  LawyerProfile? _selectedLawyer;
  String _selectedConsultationType = '線上視訊 30 分鐘';
  bool _includeCaseBrief = true;
  bool _isSubmitting = false;

  // 保持空白，絕不預填他人姓名與電話，以 hintText 提供範例指引
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  static const List<String> _consultationTypes = [
    '線上視訊 30 分鐘',
    '實體事務所面談',
    '書狀代撰審閱',
  ];

  @override
  void initState() {
    super.initState();
    _lawyers = _repository.getRecommendedLawyersForCategory(
      widget.caseBrief.disputeCategory,
    );
    if (_lawyers.isNotEmpty) {
      _selectedLawyer = _lawyers.first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final viewInsetsBottom = MediaQuery.viewInsetsOf(context).bottom;
    final safeBottom = MediaQuery.viewPaddingOf(context).bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(bottom: viewInsetsBottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: 0.90.sh,
        ),
        decoration: BoxDecoration(
          color: t.canvas,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          border: Border(
            top: BorderSide(color: t.borderStrong),
          ),
          boxShadow: [
            BoxShadow(
              color: t.shadowAmbient,
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 頂部拖曳把手與關閉鈕
            Padding(
              padding: EdgeInsets.only(top: 10.h, left: 16.w, right: 12.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(width: 40.w),
                  Container(
                    width: 38.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: t.borderStrong,
                      borderRadius: BorderRadius.circular(99.r),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: '關閉',
                    icon: Icon(
                      PhosphorIconsRegular.x,
                      color: t.textSecondary,
                      size: 20.sp,
                    ),
                  ),
                ],
              ),
            ),

            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 刊頭標題
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: BoxDecoration(
                            color: t.brandContainer,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: t.brandPrimary.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Icon(
                            PhosphorIconsRegular.gavel,
                            size: 20.sp,
                            color: t.brandPrimary,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '執業律師精準轉介與交辦',
                                style: t.serifTitle(size: 17.sp),
                              ),
                              SizedBox(height: 3.h),
                              Text(
                                '已依您的案由自動媒合專精領域之認證執業律師',
                                style: t.sansBody(size: 12.sp),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // 案件簡報摘要預覽卡
                    Container(
                      padding: EdgeInsets.all(14.w),
                      decoration: t.subtleBoxDecoration(
                        radius: 14.r,
                        fill: t.brandContainer.withValues(
                          alpha: t.isDark ? 0.55 : 0.65,
                        ),
                        borderColor: t.brandPrimary.withValues(alpha: 0.28),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                PhosphorIconsRegular.files,
                                size: 16.sp,
                                color: t.brandPrimary,
                              ),
                              SizedBox(width: 6.w),
                              Expanded(
                                child: Text(
                                  '交辦案件簡報：${widget.caseBrief.disputeCategory}',
                                  style: t.sansTitle(
                                    size: 13.sp,
                                    color: t.brandOnContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            widget.caseBrief.factSummary,
                            style: t.serifBody(
                              size: 12.5.sp,
                              color: t.textPrimary,
                              height: 1.55,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 10.h),
                          InkWell(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(
                                () => _includeCaseBrief = !_includeCaseBrief,
                              );
                            },
                            borderRadius: BorderRadius.circular(8.r),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 4.h),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    _includeCaseBrief
                                        ? PhosphorIconsFill.checkSquare
                                        : PhosphorIconsRegular.square,
                                    size: 18.sp,
                                    color: _includeCaseBrief
                                        ? t.brandPrimary
                                        : t.textMuted,
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      '授權將系統整理之攻防證據簡報加密提供予律師先期審閱（節省約 80% 初步溝通時間）',
                                      style: t.sansBody(
                                        size: 11.5.sp,
                                        color: t.textSecondary,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 18.h),

                    // 推薦執業律師名冊
                    Text(
                      '選擇諮詢律師',
                      style: t.sansTitle(size: 14.sp),
                    ),
                    SizedBox(height: 10.h),
                    for (final lawyer in _lawyers) _buildLawyerCard(lawyer, t),

                    SizedBox(height: 14.h),

                    // 諮詢服務形式（Wrap 自適應，不擠壓）
                    Text(
                      '諮詢與委任方式',
                      style: t.sansTitle(size: 14.sp),
                    ),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: [
                        for (final type in _consultationTypes)
                          _buildTypeChip(type, t),
                      ],
                    ),
                    SizedBox(height: 18.h),

                    // 聯絡人資訊輸入
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 4.h,
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          '您的聯絡方式（供事務所聯繫確認時段）',
                          style: t.sansTitle(size: 13.5.sp),
                        ),
                        InkWell(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() {
                              _nameController.text = '林先生';
                              _phoneController.text = '0912-345-678';
                            });
                          },
                          borderRadius: BorderRadius.circular(6.r),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            child: Text(
                              '帶入測試範例',
                              style: t.sansBody(
                                size: 11.sp,
                                weight: FontWeight.w600,
                                color: t.brandPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isNarrow = constraints.maxWidth < 310;
                        final nameField = _buildInputField(
                          t: t,
                          controller: _nameController,
                          label: '姓名 / 稱呼',
                          hint: '例如：林先生',
                          icon: PhosphorIconsRegular.user,
                          keyboardType: TextInputType.name,
                        );
                        final phoneField = _buildInputField(
                          t: t,
                          controller: _phoneController,
                          label: '聯絡電話',
                          hint: '例如：0912-345-678',
                          icon: PhosphorIconsRegular.phone,
                          keyboardType: TextInputType.phone,
                        );
                        if (isNarrow) {
                          return Column(
                            children: [
                              nameField,
                              SizedBox(height: 10.h),
                              phoneField,
                            ],
                          );
                        }
                        return Row(
                          children: [
                            Expanded(child: nameField),
                            SizedBox(width: 10.w),
                            Expanded(child: phoneField),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // 底部送出行動列（支援安全區與鍵盤避讓）
            Container(
              padding: EdgeInsets.fromLTRB(
                20.w,
                12.h,
                20.w,
                (viewInsetsBottom > 0 ? 12.h : safeBottom + 14.h),
              ),
              decoration: BoxDecoration(
                color: t.surface,
                border: Border(
                  top: BorderSide(color: t.border),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isSubmitting ? null : _handleSubmitBooking,
                  icon: _isSubmitting
                      ? SizedBox(
                          width: 16.w,
                          height: 16.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: t.brandOnPrimary,
                          ),
                        )
                      : Icon(
                          PhosphorIconsRegular.paperPlaneTilt,
                          size: 17.sp,
                          color: t.brandOnPrimary,
                        ),
                  label: Text(
                    _isSubmitting
                        ? '正在加密傳送案件簡報...'
                        : '打包交辦並預約 ${_selectedLawyer?.name ?? '律師'} 諮詢',
                    style: t.sansBody(
                      size: 13.sp,
                      weight: FontWeight.w700,
                      color: t.brandOnPrimary,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: t.brandPrimary,
                    foregroundColor: t.brandOnPrimary,
                    padding: EdgeInsets.symmetric(vertical: 13.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required PreambleTokens t,
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required TextInputType keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: t.sansBody(size: 13.sp, color: t.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: t.sansBody(size: 12.sp, color: t.textSecondary),
        hintText: hint,
        hintStyle: t.sansBody(size: 12.sp, color: t.textMuted),
        prefixIcon: Icon(icon, size: 16.sp, color: t.textSecondary),
        filled: true,
        fillColor: t.surface,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: t.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: t.brandPrimary, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildLawyerCard(LawyerProfile lawyer, PreambleTokens t) {
    final isSelected = _selectedLawyer?.id == lawyer.id;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedLawyer = lawyer);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: isSelected
              ? t.brandContainer.withValues(alpha: t.isDark ? 0.65 : 0.7)
              : t.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected ? t.brandPrimary : t.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 22.r,
              backgroundColor: t.accentBrassContainer,
              child: Text(
                lawyer.name.substring(0, 1),
                style: t.serifTitle(
                  size: 16.sp,
                  color: t.accentOnBrassContainer,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 6.w,
                    runSpacing: 2.h,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        '${lawyer.name} ${lawyer.title}',
                        style: t.serifTitle(size: 14.5.sp),
                      ),
                      Text(
                        '· ${lawyer.firmName}',
                        style: t.sansBody(size: 11.5.sp, color: t.textSecondary),
                      ),
                    ],
                  ),
                  SizedBox(height: 5.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 4.h,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            PhosphorIconsFill.star,
                            size: 13.sp,
                            color: t.accentBrass,
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            '${lawyer.rating} (${lawyer.reviewsCount} 則)',
                            style: t.tabularMetric(size: 11.5.sp),
                          ),
                        ],
                      ),
                      Text(
                        '執業 ${lawyer.yearsOfExperience} 年 · 勝訴 ${lawyer.successfulCasesCount}+ 件',
                        style: t.tabularMetric(
                          size: 11.sp,
                          weight: FontWeight.w600,
                          color: t.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    lawyer.bio,
                    style: t.sansBody(size: 11.5.sp, height: 1.42),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: t.accentBrassContainer,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      lawyer.consultationFeeLabel,
                      style: t.sansBody(
                        size: 11.5.sp,
                        weight: FontWeight.w700,
                        color: t.accentOnBrassContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 6.w),
            Icon(
              isSelected
                  ? PhosphorIconsFill.checkCircle
                  : PhosphorIconsRegular.circle,
              size: 19.sp,
              color: isSelected ? t.brandPrimary : t.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip(String label, PreambleTokens t) {
    final isSelected = _selectedConsultationType == label;

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedConsultationType = label);
      },
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: isSelected ? t.brandPrimary : t.surface,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isSelected ? t.brandPrimary : t.border,
          ),
        ),
        child: Text(
          label,
          style: t.sansBody(
            size: 12.sp,
            weight: FontWeight.w700,
            color: isSelected ? t.brandOnPrimary : t.textPrimary,
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmitBooking() async {
    if (_selectedLawyer == null) return;
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    if (name.isEmpty || phone.isEmpty) {
      HapticFeedback.lightImpact();
      CustomToast.show(context, '請填寫聯絡人姓名與電話，以便事務所與您聯繫確認時段');
      return;
    }

    setState(() => _isSubmitting = true);
    HapticFeedback.mediumImpact();

    try {
      final booking = await _repository.submitBooking(
        lawyer: _selectedLawyer!,
        clientName: name,
        clientPhone: phone,
        consultationType: _selectedConsultationType,
        preferredDate: '直近可預約時段 (文到後由秘書聯絡)',
        brief: widget.caseBrief,
      );

      if (!mounted) return;
      HapticFeedback.heavyImpact();
      final rootContext = Navigator.of(context).context;
      Navigator.of(context).pop();

      if (rootContext.mounted) {
        _showSuccessDialog(rootContext, booking);
      }
    } catch (_) {
      if (!mounted) return;
      CustomToast.show(context, '預約提交失敗，請稍後再試。');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSuccessDialog(
    BuildContext rootContext,
    LawyerConsultationBooking booking,
  ) {
    showDialog<void>(
      context: rootContext,
      builder: (ctx) {
        final dt = ctx.tokens;
        return AlertDialog(
          backgroundColor: dt.surfaceElevated,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.r),
            side: BorderSide(color: dt.border),
          ),
          title: Row(
            children: [
              Icon(
                PhosphorIconsFill.checkCircle,
                color: dt.semanticSuccess,
                size: 22.sp,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  '案件已成功交辦',
                  style: dt.serifTitle(size: 16.5.sp),
                ),
              ),
            ],
          ),
          content: Text(
            '您的案件簡報與聯絡資訊已安全加密傳送至【${booking.lawyerName} 律師事務所】。\n\n律師助理將於 24 小時內以電話（${booking.clientPhone}）與您確認諮詢時間與會議連結。',
            style: dt.sansBody(
              size: 12.5.sp,
              color: dt.textPrimary,
              height: 1.55,
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: FilledButton.styleFrom(
                backgroundColor: dt.brandPrimary,
                foregroundColor: dt.brandOnPrimary,
              ),
              child: Text(
                '確定',
                style: dt.sansBody(
                  size: 12.5.sp,
                  weight: FontWeight.w700,
                  color: dt.brandOnPrimary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
