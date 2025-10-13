import 'package:flutter/material.dart';
import 'package:lawapp/Reuseable/SearchBar.dart';


class trendPage extends StatefulWidget {
  const trendPage({super.key});

  @override
  trendState createState() => trendState();
}

class trendState extends State<trendPage> {

  final controller = TextEditingController();
  final focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            searchbar(
              hintText:"搜尋案件、人名...",
              controller: controller,
            ),
          ],
        ),
        const Text(
          "案件分類",
          style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 165, 144, 134)),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.only(left: 15, right: 15),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
            ),
            itemCount: 8,
            itemBuilder: (context, index) {
              final categories = [
                "意外",
                "入室搶劫",
                "冤獄",
                "水泥封屍",
                "強盜殺人",
                "投毒",
                "勒斃",
                "外役監",
              ];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Image.network(
                      "https://www.appoverride.com/wp-content/uploads/2024/03/floating_action_button-1024x538.png",
                      height: 70,
                      width: 80,
                    ),
                    // const SizedBox(height: 5),
                    Text(
                      categories[index],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

 