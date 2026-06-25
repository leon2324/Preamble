import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/app/app_state.dart';
import 'package:lawapp/theme/app_colors.dart';

class NotificationSettingsSheet extends StatefulWidget {
  const NotificationSettingsSheet({super.key, required this.appState});

  final LawAppState appState;

  @override
  State<NotificationSettingsSheet> createState() =>
      _NotificationSettingsSheetState();
}

class _NotificationSettingsSheetState extends State<NotificationSettingsSheet> {
  late String _frequency;
  late String _channel;

  @override
  void initState() {
    super.initState();
    _frequency = widget.appState.notifyFrequency;
    _channel = widget.appState.notifyChannel;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF171C22) : Colors.white;
    final borderSide =
        BorderSide(color: isDark ? const Color(0xFF2B3441) : AppColors.border);
    final textMuted =
        isDark ? const Color(0xFFA3ABB6) : AppColors.textSecondary;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2B3441) : AppColors.border,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            '提醒偏好',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w900,
              color: isDark ? const Color(0xFFF2F4F7) : AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20.h),

          // 台灣繁體中文教學註解：
          // 這裡只保存 App 內提醒偏好，不宣稱已完成系統推播、信件或背景通知。
          Text('摘要頻率',
              style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: textMuted)),
          SizedBox(height: 8.h),
          Row(
            children: [
              _buildOptionCard(
                type: 'frequency',
                value: 'instant',
                label: '即時提示',
                icon: Icons.flash_on_rounded,
              ),
              SizedBox(width: 8.w),
              _buildOptionCard(
                type: 'frequency',
                value: 'daily',
                label: '每日摘要',
                icon: Icons.today_rounded,
              ),
              SizedBox(width: 8.w),
              _buildOptionCard(
                type: 'frequency',
                value: 'weekly',
                label: '每週彙報',
                icon: Icons.date_range_rounded,
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // 呈現方式選擇
          Text('呈現方式',
              style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: textMuted)),
          SizedBox(height: 8.h),
          Row(
            children: [
              _buildOptionCard(
                type: 'channel',
                value: 'push',
                label: 'App 內提醒',
                icon: Icons.notifications_active_rounded,
              ),
              SizedBox(width: 8.w),
              _buildOptionCard(
                type: 'channel',
                value: 'email',
                label: '重點摘要',
                icon: Icons.email_rounded,
              ),
              SizedBox(width: 8.w),
              _buildOptionCard(
                type: 'channel',
                value: 'both',
                label: '完整摘要',
                icon: Icons.all_inclusive_rounded,
              ),
            ],
          ),
          SizedBox(height: 24.h),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    side: borderSide,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r)),
                  ),
                  child: Text('取消',
                      style: TextStyle(fontSize: 14.sp, color: textMuted)),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    widget.appState.updateSettings(
                      notifyFrequency: _frequency,
                      notifyChannel: _channel,
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('提醒偏好已儲存。'),
                        backgroundColor: Color(0xFF2E7D32),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r)),
                  ),
                  child: Text('儲存',
                      style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required String type,
    required String value,
    required String label,
    required IconData icon,
  }) {
    final isSelected =
        type == 'frequency' ? _frequency == value : _channel == value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (type == 'frequency') {
              _frequency = value;
            } else {
              _channel = value;
            }
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 4.w),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? const Color(0xFF243B63) : const Color(0xFFEAF0F8))
                : (isDark ? const Color(0xFF0F1216) : const Color(0xFFFAF7F2)),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected
                  ? AppColors.accent
                  : (isDark ? const Color(0xFF2B3441) : AppColors.border),
              width: isSelected ? 1.5.w : 1.w,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? AppColors.accent
                    : (isDark ? Colors.white70 : AppColors.textSecondary),
                size: 20.sp,
              ),
              SizedBox(height: 6.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? AppColors.accent
                      : (isDark ? Colors.white70 : AppColors.textPrimary),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
