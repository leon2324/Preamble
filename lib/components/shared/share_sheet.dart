import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/components/shared/custom_toast.dart';
import 'package:lawapp/platform/native_share_bridge.dart';
import 'package:url_launcher/url_launcher.dart';

/// 全域分享面板。
///
/// 不再用「模擬分享」文字假裝完成外部動作；Line、Facebook 與 Threads 會優先開啟
/// 對應的公開分享 URL，主要 CTA 則走 iOS / Android 原生分享面板。若裝置或模擬器
/// 無法開啟，就退回複製連結，讓使用者仍拿得到分享內容。
class ShareSheet {
  const ShareSheet._();

  static void show(BuildContext context, {required String title, String? url}) {
    final effectiveUrl =
        url ?? 'https://lawapp.com/share/${Uri.encodeComponent(title)}';
    final hostContext = context;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final bg = isDark ? const Color(0xFF171C22) : const Color(0xFFFAF6F0);
        final card = isDark ? const Color(0xFF1F262F) : Colors.white;
        final border =
            isDark ? const Color(0xFF2D3748) : const Color(0xFFEDE4D8);
        final text = isDark ? const Color(0xFFFAF6F0) : const Color(0xFF234D3B);
        final muted =
            isDark ? const Color(0xFFA0AEC0) : const Color(0xFF828078);

        return SafeArea(
          top: false,
          child: Container(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              border: Border.all(color: border, width: 1.5.w),
            ),
            padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 14.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 48.w,
                    height: 5.h,
                    decoration: BoxDecoration(
                      color: border,
                      borderRadius: BorderRadius.circular(100.r),
                    ),
                  ),
                ),
                SizedBox(height: 18.h),
                Text(
                  '分享內容',
                  style: TextStyle(
                    color: text,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: muted,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 18.h),
                SizedBox(
                  height: 94.h,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildShareOption(
                        context: context,
                        label: 'Line',
                        icon: Icons.chat_bubble_outline_rounded,
                        color: const Color(0xFF06C755),
                        cardBg: card,
                        border: border,
                        textStyle: TextStyle(
                            color: text,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold),
                        onTap: () async {
                          Navigator.of(context).pop();
                          await _launchOrCopy(
                            hostContext,
                            Uri.parse(
                              'https://social-plugins.line.me/lineit/share?url=${Uri.encodeComponent(effectiveUrl)}&text=${Uri.encodeComponent(title)}',
                            ),
                            effectiveUrl,
                            successText: '已開啟 Line 分享頁。',
                          );
                        },
                      ),
                      _buildShareOption(
                        context: context,
                        label: 'Facebook',
                        icon: Icons.facebook_rounded,
                        color: const Color(0xFF1877F2),
                        cardBg: card,
                        border: border,
                        textStyle: TextStyle(
                            color: text,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold),
                        onTap: () async {
                          Navigator.of(context).pop();
                          await _launchOrCopy(
                            hostContext,
                            Uri.parse(
                              'https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(effectiveUrl)}',
                            ),
                            effectiveUrl,
                            successText: '已開啟 Facebook 分享頁。',
                          );
                        },
                      ),
                      _buildShareOption(
                        context: context,
                        label: '複製連結',
                        icon: Icons.link_rounded,
                        color: const Color(0xFF2E7D32),
                        cardBg: card,
                        border: border,
                        textStyle: TextStyle(
                            color: text,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold),
                        onTap: () async {
                          Navigator.of(context).pop();
                          await Clipboard.setData(
                              ClipboardData(text: effectiveUrl));
                          if (!hostContext.mounted) return;
                          CustomToast.show(
                            hostContext,
                            '連結已複製',
                            icon: Icons.link_rounded,
                          );
                        },
                      ),
                      _buildShareOption(
                        context: context,
                        label: 'Threads',
                        icon: Icons.alternate_email_rounded,
                        color: Colors.black,
                        cardBg: card,
                        border: border,
                        textStyle: TextStyle(
                            color: text,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold),
                        onTap: () async {
                          Navigator.of(context).pop();
                          await _launchOrCopy(
                            hostContext,
                            Uri.parse(
                              'https://www.threads.net/intent/post?text=${Uri.encodeComponent('$title $effectiveUrl')}',
                            ),
                            effectiveUrl,
                            successText: '已開啟 Threads 發文頁。',
                          );
                        },
                      ),
                      _buildShareOption(
                        context: context,
                        label: '系統',
                        icon: Icons.share_rounded,
                        color: const Color(0xFFE28743),
                        cardBg: card,
                        border: border,
                        textStyle: TextStyle(
                            color: text,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold),
                        onTap: () async {
                          Navigator.of(context).pop();
                          await _openNativeShare(
                            hostContext,
                            title: title,
                            url: effectiveUrl,
                          );
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 6.h),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: text,
                      foregroundColor: bg,
                      minimumSize: Size.fromHeight(46.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.r),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await _openNativeShare(
                        hostContext,
                        title: title,
                        url: effectiveUrl,
                      );
                    },
                    icon: Icon(Icons.ios_share_rounded, size: 18.sp),
                    label: Text(
                      '開啟系統分享',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Future<void> _openNativeShare(
    BuildContext context, {
    required String title,
    required String url,
  }) async {
    final didOpen = await NativeShareBridge.shareText(
      title: title,
      text: '$title\n$url',
    );
    if (didOpen) return;

    await Clipboard.setData(ClipboardData(text: '$title\n$url'));
    if (!context.mounted) return;
    CustomToast.show(context, '無法開啟\n已複製分享文字', icon: Icons.link_rounded);
  }

  static Future<void> _launchOrCopy(
    BuildContext context,
    Uri uri,
    String fallbackUrl, {
    required String successText,
  }) async {
    var launched = false;
    try {
      launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Object {
      launched = false;
    }
    if (launched) {
      if (context.mounted) {
        CustomToast.show(context, successText, icon: Icons.ios_share_rounded);
      }
      return;
    }

    await Clipboard.setData(ClipboardData(text: fallbackUrl));
    if (!context.mounted) return;
    CustomToast.show(context, '無法開啟\n已複製連結', icon: Icons.link_rounded);
  }

  static Widget _buildShareOption({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required Color cardBg,
    required Color border,
    required TextStyle textStyle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(right: 18.w),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 52.w,
              height: 52.w,
              decoration: BoxDecoration(
                color: cardBg,
                shape: BoxShape.circle,
                border: Border.all(color: border),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x06000000),
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, color: color, size: 24.sp),
            ),
            SizedBox(height: 8.h),
            SizedBox(
              width: 58.w,
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: textStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
