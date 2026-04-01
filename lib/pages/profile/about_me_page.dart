import 'package:flutter/material.dart';
import 'package:lawapp/components/search/search_page_layout.dart';

class AboutMePage extends StatefulWidget {
  const AboutMePage({super.key});

  @override
  AboutMeState createState() => AboutMeState();
}

class AboutMeState extends State<AboutMePage> {
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
