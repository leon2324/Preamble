import 'package:flutter/material.dart';
import 'package:lawapp/home_page_content.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  Homestate createState() => Homestate();
}

class Homestate extends State<Homepage> {
  
  @override
  Widget build(BuildContext context) {
    return const Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(child:HomePageContent1()),
          Expanded(child:HomePageContent2()),
          Expanded(child:HomePageContent3()),
        ],
      )
    );
  }
}
