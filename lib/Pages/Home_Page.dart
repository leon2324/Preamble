import 'package:flutter/material.dart';
import 'package:lawapp/Reuseable/SearchBar.dart';
import 'package:lawapp/Reuseable/SearchRow_HomePage.dart';
import 'package:lawapp/component/HomePage_NewsToday.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  Homestate createState() => Homestate();
}

class Homestate extends State<Homepage> {
  final controller = TextEditingController();
  final focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SearchRowHomePage(hintText: "快速搜尋", controller: controller),
        Expanded(
          child: NewsTodayAtHomePage(),
        ),
        // Expanded(child:HomePageContent2()),
        // Expanded(child:HomePageContent3()),
      ],
    );
  }
}
