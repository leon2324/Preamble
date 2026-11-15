import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:preamble/app/app_state.dart';
import 'package:preamble/components/shared/custom_toast.dart';
import 'package:preamble/theme/preamble_tokens.dart';

class NotificationSettingsSheet extends StatefulWidget {
  const NotificationSettingsSheet({super.key, required this.appState});

  final PreambleState appState;

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
    final t = context.tokens;

    return Container(
      decoration: BoxDecoration(
        color: t.surfaceElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        border: Border.all(color: t.border),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 38.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: t.borderStrong,
                    borderRadius: BorderRadius.circular(99.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                '提醒偏好設定',
                style: t.serifTitle(size: 17.sp),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 18.h),

              Text(
                '動態摘要頻率',
                style: t.sansBody(
                  size: 12.sp,
                  weight: FontWeight.w700,
                  color: t.textSecondary,
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  _buildOptionCard(
                    context,
                    type: 'frequency',
                    value: 'instant',
                    label: '即時提示',
                    icon: PhosphorIconsRegular.lightning,
                  ),
                  SizedBox(width: 8.w),
                  _buildOptionCard(
                    context,
                    type: 'frequency',
                    value: 'daily',
                    label: '每日摘要',
                    icon: PhosphorIconsRegular.calendarBlank,
                  ),
                  SizedBox(width: 8.w),
                  _buildOptionCard(
                    context,
                    type: 'frequency',
                    value: 'weekly',
                    label: '每週彙報',
                    icon: PhosphorIconsRegular.calendarCheck,
                  ),
                ],
              ),
              SizedBox(height: 18.h),

              Text(
                '摘要呈現模式',
                style: t.sansBody(
                  size: 12.sp,
                  weight: FontWeight.w700,
                  color: t.textSecondary,
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  _buildOptionCard(
                    context,
                    type: 'channel',
                    value: 'push',
                    label: 'App 內提醒',
                    icon: PhosphorIconsRegular.bellRinging,
                  ),
                  SizedBox(width: 8.w),
                  _buildOptionCard(
                    context,
                    type: 'channel',
                    value: 'email',
                    label: '重點摘要',
                    icon: PhosphorIconsRegular.article,
                  ),
                  SizedBox(width: 8.w),
                  _buildOptionCard(
                    context,
                    type: 'channel',
                    value: 'both',
                    label: '完整摘要',
                    icon: PhosphorIconsRegular.stack,
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
                        side: BorderSide(color: t.borderStrong),
                        foregroundColor: t.textSecondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: const Text('取消'),
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
                        CustomToast.show(
                          context,
                          '提醒偏好設定已儲存',
                          icon: PhosphorIconsFill.checkCircle,
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: t.brandPrimaryStrong,
                        foregroundColor: const Color(0xFFFAF8F4),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: const Text('儲存'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required String type,
    required String value,
    required String label,
    required IconData icon,
  }) {
    final t = context.tokens;
    final isSelected =
        type == 'frequency' ? _frequency == value : _channel == value;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            if (type == 'frequency') {
              _frequency = value;
            } else {
              _channel = value;
            }
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 6.w),
          decoration: BoxDecoration(
            color: isSelected ? t.brandContainer : t.surfaceSubtle,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: isSelected ? t.brandPrimary : t.border,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? t.brandPrimary : t.textSecondary,
                size: 20.sp,
              ),
              SizedBox(height: 6.h),
              Text(
                label,
                style: t.sansBody(
                  size: 11.5.sp,
                  weight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? t.brandOnContainer : t.textPrimary,
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
