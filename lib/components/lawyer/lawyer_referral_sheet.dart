import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/components/shared/custom_toast.dart';
import 'package:preamble/data/lawyer/lawyer_models.dart';
import 'package:preamble/data/lawyer/lawyer_repository.dart';

/// 緒言莫蘭迪律師配對與案件一鍵交辦面板 (Lawyer Referral & Handover Sheet)。
///
/// 讓使用者一鍵把 AI 整理好的案情簡報（Case Brief）直接交辦給專長執業律師預約諮詢。
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

  final TextEditingController _nameController =
      TextEditingController(text: '林先生');
  final TextEditingController _phoneController =
      TextEditingController(text: '0912-345-678');

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgDark = isDark ? const Color(0xFF16241D) : const Color(0xFFF7FAF8);
    final cardBg = isDark ? const Color(0xFF1F332A) : Colors.white;
    final primaryGreen =
        isDark ? const Color(0xFF68B28B) : const Color(0xFF2C5E43);
    final goldAccent =
        isDark ? const Color(0xFFE5C07B) : const Color(0xFF9E6800);

    return Container(
      height: 0.88.sh,
      decoration: BoxDecoration(
        color: bgDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 20,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          // 頂部拖曳把手與標題
          Padding(
            padding: EdgeInsets.only(top: 12.h, left: 16.w, right: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 40.w),
                Container(
                  width: 36.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black26,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close_rounded,
                    color: isDark ? Colors.white70 : Colors.black54,
                    size: 22.sp,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 標題與簡介
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: primaryGreen.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.gavel_rounded,
                          size: 20.sp,
                          color: primaryGreen,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '執業律師精準轉介與交辦',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF17231F),
                              ),
                            ),
                            Text(
                              '已依您的案由自動配對最擅長之認證律師',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),

                  // 案件簡報摘要預覽卡
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF263D32)
                          : const Color(0xFFEAF3EE),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: primaryGreen.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.assignment_outlined,
                              size: 15.sp,
                              color: primaryGreen,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              '本次交辦案件簡報：${widget.caseBrief.disputeCategory}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: primaryGreen,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          widget.caseBrief.factSummary,
                          style: TextStyle(
                            fontSize: 11.sp,
                            height: 1.4,
                            color: isDark ? Colors.white70 : const Color(0xFF33423B),
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Checkbox(
                              value: _includeCaseBrief,
                              activeColor: primaryGreen,
                              onChanged: (val) {
                                setState(() => _includeCaseBrief = val ?? true);
                              },
                            ),
                            Expanded(
                              child: Text(
                                '授權將 AI 整理之完整攻防證據簡報發送給律師先期審閱（省去 80% 溝通時間）',
                                style: TextStyle(
                                  fontSize: 10.5.sp,
                                  color: isDark ? Colors.white60 : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // 推薦執業律師名冊
                  Text(
                    '選擇諮詢律師',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF17231F),
                    ),
                  ),
                  SizedBox(height: 8.h),

                  for (final lawyer in _lawyers)
                    _buildLawyerCard(lawyer, cardBg, primaryGreen, goldAccent, isDark),

                  SizedBox(height: 16.h),

                  // 諮詢服務形式
                  Text(
                    '諮詢與委任方式',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF17231F),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      _buildTypeChip('線上視訊 30 分鐘', primaryGreen, isDark),
                      SizedBox(width: 8.w),
                      _buildTypeChip('實體事務所面談', primaryGreen, isDark),
                      SizedBox(width: 8.w),
                      _buildTypeChip('書狀代撰審閱', primaryGreen, isDark),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // 聯絡人資訊輸入
                  Text(
                    '您的聯絡方式（律師事務所將以此聯繫確認時段）',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF17231F),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: '姓名 / 稱呼',
                            filled: true,
                            fillColor: cardBg,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: TextField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            labelText: '聯絡電話',
                            filled: true,
                            fillColor: cardBg,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30.h),
                ],
              ),
            ),
          ),

          // 底部送出按鈕
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: cardBg,
              border: Border(
                top: BorderSide(
                  color: isDark ? Colors.white12 : Colors.black12,
                ),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _handleSubmitBooking,
                icon: const Icon(Icons.send_rounded, color: Colors.white),
                label: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        '一鍵打包交辦並預約 ${_selectedLawyer?.name ?? '律師'} 諮詢',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLawyerCard(
    LawyerProfile lawyer,
    Color cardBg,
    Color primaryGreen,
    Color goldAccent,
    bool isDark,
  ) {
    final isSelected = _selectedLawyer?.id == lawyer.id;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedLawyer = lawyer);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryGreen.withValues(alpha: 0.12)
              : cardBg,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? primaryGreen
                : (isDark ? Colors.white12 : Colors.black12),
            width: isSelected ? 1.8.w : 1.w,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 頭像
            CircleAvatar(
              radius: 22.r,
              backgroundColor: primaryGreen.withValues(alpha: 0.2),
              child: Text(
                lawyer.name.substring(0, 1),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: primaryGreen,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${lawyer.name} ${lawyer.title}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF17231F),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        '• ${lawyer.firmName}',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Icon(Icons.star_rounded, size: 14.sp, color: goldAccent),
                      SizedBox(width: 2.w),
                      Text(
                        '${lawyer.rating} (${lawyer.reviewsCount}則評價) ｜ 執業 ${lawyer.yearsOfExperience} 年 ｜ 勝訴 ${lawyer.successfulCasesCount}+ 件',
                        style: TextStyle(
                          fontSize: 9.5.sp,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    lawyer.bio,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    lawyer.consultationFeeLabel,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      color: primaryGreen,
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

  Widget _buildTypeChip(String label, Color primaryGreen, bool isDark) {
    final isSelected = _selectedConsultationType == label;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selectedConsultationType = label);
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            color: isSelected
                ? primaryGreen
                : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.white70 : Colors.black87),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmitBooking() async {
    if (_selectedLawyer == null) return;
    setState(() => _isSubmitting = true);
    HapticFeedback.mediumImpact();

    try {
      final booking = await _repository.submitBooking(
        lawyer: _selectedLawyer!,
        clientName: _nameController.text.trim(),
        clientPhone: _phoneController.text.trim(),
        consultationType: _selectedConsultationType,
        preferredDate: '直近可預約時段 (文到後由秘書聯絡)',
        brief: widget.caseBrief,
      );

      if (!mounted) return;
      HapticFeedback.heavyImpact();
      Navigator.of(context).pop();

      _showSuccessDialog(booking);
    } catch (_) {
      if (!mounted) return;
      CustomToast.show(context, '預約提交失敗，請稍後再試。');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSuccessDialog(LawyerConsultationBooking booking) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            Icon(Icons.check_circle_outline_rounded,
                color: const Color(0xFF2C5E43), size: 24.sp),
            SizedBox(width: 8.w),
            Text('案件已成功交辦！', style: TextStyle(fontSize: 16.sp)),
          ],
        ),
        content: Text(
          '您的案件簡報與聯絡資訊已安全加密傳送至【${booking.lawyerName} 律師事務所】。\n\n律師助理將於 24 小時內以電話 (${booking.clientPhone}) 與您確認諮詢時間與會議連結。',
          style: TextStyle(fontSize: 12.sp, height: 1.5),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2C5E43),
            ),
            child: const Text('確定'),
          ),
        ],
      ),
    );
  }
}
