import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

/// 全域分享面板。
///
/// 台灣繁體中文教學註解：
/// 不再用「模擬分享」文字假裝完成外部動作；Line、Facebook 與 Threads 會優先開啟
/// 對應的公開分享 URL，若裝置或模擬器無法開啟，就退回複製連結，讓使用者仍拿得到分享內容。
class ShareSheet {
  const ShareSheet._();

  static void show(BuildContext context, {required String title, String? url}) {
    final effectiveUrl =
        url ?? 'https://lawapp.com/share/${Uri.encodeComponent(title)}';

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

        return Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            border: Border.all(color: border, width: 1.5.w),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
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
              SizedBox(height: 20.h),
              SizedBox(
                height: 84.h,
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
                        final messenger = ScaffoldMessenger.of(context);
                        Navigator.of(context).pop();
                        await _launchOrCopy(
                          messenger,
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
                        final messenger = ScaffoldMessenger.of(context);
                        Navigator.of(context).pop();
                        await _launchOrCopy(
                          messenger,
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
                        final messenger = ScaffoldMessenger.of(context);
                        Navigator.of(context).pop();
                        await Clipboard.setData(
                            ClipboardData(text: effectiveUrl));
                        messenger.showSnackBar(
                          const SnackBar(content: Text('🔗 連結已成功複製至剪貼簿！')),
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
                        final messenger = ScaffoldMessenger.of(context);
                        Navigator.of(context).pop();
                        await _launchOrCopy(
                          messenger,
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
                      label: '更多分享',
                      icon: Icons.share_rounded,
                      color: const Color(0xFFE28743),
                      cardBg: card,
                      border: border,
                      textStyle: TextStyle(
                          color: text,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold),
                      onTap: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        Navigator.of(context).pop();
                        await Clipboard.setData(
                            ClipboardData(text: '$title\n$effectiveUrl'));
                        messenger.showSnackBar(
                          const SnackBar(content: Text('分享文字已複製，可貼到任何 App。')),
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
            ],
          ),
        );
      },
    );
  }

  static Future<void> _launchOrCopy(
    ScaffoldMessengerState messenger,
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
      messenger.showSnackBar(SnackBar(content: Text(successText)));
      return;
    }

    await Clipboard.setData(ClipboardData(text: fallbackUrl));
    messenger.showSnackBar(
      const SnackBar(content: Text('無法開啟外部分享頁，已改為複製連結。')),
    );
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
            Text(label, style: textStyle),
          ],
        ),
      ),
    );
  }
}
