import 'package:flutter/material.dart';
import 'package:preamble/components/search/search_page_layout.dart';

/// 舊版我的頁骨架。
///
/// 正式主流程已改用 `ProfilePage`，這個檔案只保留作為早期搜尋式個人頁參考，
/// 不應再從正式入口導到這裡，避免使用者看到空白骨架。
class AboutMePageLegacy extends StatefulWidget {
  const AboutMePageLegacy({super.key});

  @override
  AboutMeLegacyState createState() => AboutMeLegacyState();
}

class AboutMeLegacyState extends State<AboutMePageLegacy> {
  final TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SearchPageLayout(
      controller: controller,
      hintText: '想搜尋的內容....',
      builder: (context, layout, contentTopPadding, contentBottomPadding) =>
          ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          contentTopPadding,
          16,
          contentBottomPadding,
        ),
        children: const [
          SizedBox(height: 4),
        ],
      ),
    );
  }
}
