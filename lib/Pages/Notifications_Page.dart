import 'package:flutter/material.dart';
import 'package:lawapp/component/Notification_TitleButton.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  notificationState createState() => notificationState();
}

class notificationState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        Column(
          children: [
            Row(
              children: [
                SelectArea(),
              ],
            ),
            Row(
              children: [
                SearchResult(),
              ],
            ),
          ],
        ),
      ],
    );
  }
}



class SearchResult extends StatelessWidget {
  const SearchResult({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            "歷史紀錄",
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: 23.4,
              color: Color.fromARGB(255, 44, 43, 46),
            ),
          ),
          Text(
            "你還沒有任何搜尋內容",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 23.4,
              color: Color.fromARGB(255, 184, 177, 199),
            ),
          ),
        ],
      ),
    );
  }
}
