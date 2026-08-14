import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 臨場談判防坑三不原則錦囊元件
class NegotiationKitCard extends StatefulWidget {
  const NegotiationKitCard({
    super.key,
    required this.threeNeverSign,
    required this.threeMustAsk,
    required this.recordingLegalityTip,
  });

  final List<String> threeNeverSign;
  final List<String> threeMustAsk;
  final String recordingLegalityTip;

  @override
  State<NegotiationKitCard> createState() => _NegotiationKitCardState();
}

class _NegotiationKitCardState extends State<NegotiationKitCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgCard = isDark ? const Color(0xFF222B27) : const Color(0xFFF1F6F3);
    final borderCard =
        isDark ? const Color(0xFF35443D) : const Color(0xFFD6E3DC);
    final textGreen =
        isDark ? const Color(0xFF7FC29F) : const Color(0xFF2C5E43);

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: borderCard, width: 1.w),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _isExpanded = !_isExpanded);
            },
            borderRadius: BorderRadius.circular(10.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
              child: Row(
                children: [
                  Icon(
                    Icons.shield_outlined,
                    size: 15.sp,
                    color: textGreen,
                  ),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      '🛡️ 現場談判防坑三不原則錦囊 (點擊展開)',
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.bold,
                        color: textGreen,
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 18.sp,
                    color: isDark ? Colors.white60 : Colors.black45,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            Divider(height: 1, color: borderCard),
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. 三不簽
                  Text(
                    '⚠️ 現場交涉【三不簽】絕不輕易妥協：',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFC0392B),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  for (final item in widget.threeNeverSign)
                    Padding(
                      padding: EdgeInsets.only(bottom: 3.h),
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          height: 1.35,
                          color: isDark ? Colors.white70 : const Color(0xFF333333),
                        ),
                      ),
                    ),
                  SizedBox(height: 8.h),

                  // 2. 三必問
                  Text(
                    '💡 現場交涉【三必問】冷靜掌握主導權：',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      color: textGreen,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  for (final item in widget.threeMustAsk)
                    Padding(
                      padding: EdgeInsets.only(bottom: 3.h),
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          height: 1.35,
                          color: isDark ? Colors.white70 : const Color(0xFF333333),
                        ),
                      ),
                    ),
                  SizedBox(height: 8.h),

                  // 3. 合法錄音自保提示
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E2622) : Colors.white,
                      borderRadius: BorderRadius.circular(6.r),
                      border: Border.all(color: borderCard, width: 0.6.w),
                    ),
                    child: Text(
                      widget.recordingLegalityTip,
                      style: TextStyle(
                        fontSize: 10.sp,
                        height: 1.4,
                        color: isDark ? Colors.white60 : const Color(0xFF555555),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
