import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:preamble/app/app_state.dart';
import 'package:preamble/theme/app_colors.dart';

import 'package:preamble/components/shared/liquid_glass_widgets.dart';

const lawAppLegalDisclaimer = '本內容僅供法律知識參考，不構成正式法律意見；具體案件請諮詢律師或專業人士。';

/// 共用載入狀態。
///
/// MVP 階段每個 repository 都可能切 mock/backend，因此 loading/error/empty 先統一成元件，
/// 之後各頁要換文案即可，不需要重複寫一堆不一致的狀態卡。
class AppLoadingView extends StatelessWidget {
  const AppLoadingView({
    super.key,
    this.message = '正在整理資料...',
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 8.w,
                height: 8.w,
                decoration: const BoxDecoration(
                  color: Color(0xFF1B5E4F),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1B5E4F),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          LiquidGlassShimmer(
            width: double.infinity,
            height: 90.h,
            radius: 12.r,
          ),
          SizedBox(height: 12.h),
          LiquidGlassShimmer(
            width: double.infinity,
            height: 70.h,
            radius: 12.r,
          ),
          SizedBox(height: 12.h),
          LiquidGlassShimmer(
            width: double.infinity,
            height: 80.h,
            radius: 12.r,
          ),
        ],
      ),
    );
  }
}

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return _StateCard(
      icon: icon,
      title: title,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }
}

class AppErrorState extends StatelessWidget {
  const AppErrorState({
    super.key,
    required this.message,
    this.title = '資料暫時讀取失敗',
    this.onRetry,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return _StateCard(
      icon: Icons.error_outline_rounded,
      title: title,
      message: message,
      actionLabel: onRetry == null ? null : '再試一次',
      onAction: onRetry,
    );
  }
}

class LegalDisclaimerBox extends StatelessWidget {
  const LegalDisclaimerBox({
    super.key,
    this.message = lawAppLegalDisclaimer,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: _surfaceColor(context),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _borderColor(context)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded,
              size: 18.sp, color: AppColors.accent),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message,
              style: _bodyStyle(context).copyWith(fontSize: 11.5.sp),
            ),
          ),
        ],
      ),
    );
  }
}

class SourceCitationViewData {
  const SourceCitationViewData({
    required this.title,
    required this.sourceType,
    this.url = '',
    this.updatedAt,
    this.publisher = '',
    this.lawName = '',
    this.articleNumber = '',
  });

  final String title;
  final String sourceType;
  final String url;
  final DateTime? updatedAt;
  final String publisher;
  final String lawName;
  final String articleNumber;
}

class SourceCitationList extends StatelessWidget {
  const SourceCitationList({
    super.key,
    required this.items,
    this.title = '資料來源',
  });

  final String title;
  final List<SourceCitationViewData> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const AppEmptyState(
        title: '尚無來源',
        message: '這筆內容目前還沒有可顯示的引用來源，請以示範資料看待。',
        icon: Icons.link_off_rounded,
      );
    }

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: _surfaceColor(context),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: _borderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w900,
              color: _primaryTextColor(context),
            ),
          ),
          SizedBox(height: 10.h),
          for (final item in items) ...[
            Text(
              item.title,
              style: TextStyle(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w800,
                color: _primaryTextColor(context),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              [
                item.sourceType,
                if (item.publisher.isNotEmpty) item.publisher,
                if (item.lawName.isNotEmpty) item.lawName,
                if (item.articleNumber.isNotEmpty) item.articleNumber,
                if (item.updatedAt != null)
                  '更新 ${item.updatedAt!.toIso8601String().split('T').first}',
              ].join('｜'),
              style: _bodyStyle(context).copyWith(fontSize: 11.sp),
            ),
            if (item.url.isNotEmpty) ...[
              SizedBox(height: 3.h),
              SelectableText(
                item.url,
                style: _bodyStyle(context).copyWith(
                  fontSize: 10.8.sp,
                  color: AppColors.primary,
                ),
              ),
            ],
            SizedBox(height: 10.h),
          ],
        ],
      ),
    );
  }
}

class PermissionGateCard extends StatelessWidget {
  const PermissionGateCard({
    super.key,
    required this.title,
    required this.message,
    this.requireSubscriber = false,
  });

  final String title;
  final String message;
  final bool requireSubscriber;

  @override
  Widget build(BuildContext context) {
    final appState = PreambleScope.of(context);
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: _surfaceColor(context),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: _borderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w900,
              color: _primaryTextColor(context),
            ),
          ),
          SizedBox(height: 6.h),
          Text(message, style: _bodyStyle(context)),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              FilledButton(
                onPressed: appState.signInDemo,
                child: const Text('Demo 會員登入'),
              ),
              if (requireSubscriber)
                OutlinedButton(
                  onPressed: appState.activateSubscriberDemo,
                  child: const Text('Demo 訂閱者'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class BackendNotConfiguredBanner extends StatelessWidget {
  const BackendNotConfiguredBanner({
    super.key,
    this.featureName = '後端服務',
  });

  final String featureName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E5),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE8C77D)),
      ),
      child: Text(
        '$featureName 尚未設定 PREAMBLE_API_BASE_URL，目前使用本機 mock data，不會連到正式後端。',
        style: TextStyle(
          fontSize: 11.5.sp,
          height: 1.45,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF6B4E2F),
        ),
      ),
    );
  }
}

class LockedFeatureCard extends StatelessWidget {
  const LockedFeatureCard({
    super.key,
    required this.title,
    required this.message,
    this.actionLabel = '查看 Pro Demo',
    this.onAction,
  });

  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: _surfaceColor(context),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: _borderColor(context)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38.w,
            height: 38.w,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7E5),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              Icons.lock_outline_rounded,
              size: 19.sp,
              color: const Color(0xFF9A6A22),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w900,
                    color: _primaryTextColor(context),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(message, style: _bodyStyle(context)),
                if (onAction != null) ...[
                  SizedBox(height: 8.h),
                  OutlinedButton(
                    onPressed: onAction,
                    child: Text(actionLabel),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: _surfaceColor(context),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: _borderColor(context)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28.sp, color: AppColors.primary),
          SizedBox(height: 8.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w900,
              color: _primaryTextColor(context),
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: _bodyStyle(context),
          ),
          if (actionLabel != null && onAction != null) ...[
            SizedBox(height: 10.h),
            OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

Color _surfaceColor(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF171C22)
      : Colors.white;
}

Color _borderColor(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF2B3441)
      : AppColors.border;
}

Color _primaryTextColor(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFFF2F4F7)
      : AppColors.textPrimary;
}

TextStyle _bodyStyle(BuildContext context) {
  return TextStyle(
    fontSize: 12.sp,
    height: 1.48,
    color: Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFA3ABB6)
        : AppColors.textSecondary,
  );
}
