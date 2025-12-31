
import 'package:flutter/material.dart';
import 'package:lawapp/Reuseable/SearchRow_HomePage.dart';
import 'package:lawapp/component/HomePage_NewLegalNewsletter.dart';
import 'package:lawapp/component/HomePage_NewsToday.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final controller = TextEditingController();
  final focusNode = FocusNode(); //用來控制搜尋框的聚焦

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: SearchHeaderDelegate(
            minExtent: 75,
            maxExtent: 75,
            controller: controller,
          ),
        ),
        SliverToBoxAdapter(
          child: NewsTodayAtHomePage(),
        ),
        const SliverToBoxAdapter(
          child: HomePage_NewLegalNewsletter(),
        ),
      ],
    );
  }
}
