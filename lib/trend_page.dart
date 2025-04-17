import 'package:flutter/material.dart';

class trendPage extends StatefulWidget {
  const trendPage({super.key});

  @override
  trendState createState() => trendState();
}

class trendState extends State<trendPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          children: [
            SearchBar(),
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

class SearchBar extends StatefulWidget {
  const SearchBar({super.key});

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final FocusNode _focusNode = FocusNode();

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 20, 15, 5),
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 211, 211, 211),
            borderRadius: BorderRadius.circular(50),
          ),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            onTap: () {
              _focusNode.requestFocus();
            },
            // onChanged: (value) {
            //   print("search query: $value");
            // },
            decoration: InputDecoration(
              hintStyle: TextStyle(color: Colors.grey[500]),
              hintText: "搜尋案件、人名...",
              // contentPadding: EdgeInsets.all(0),
              border: InputBorder.none,
              suffixIcon: Icon(
                Icons.search,
                size: 32,
                color: Colors.grey[600],
              ),
              suffixIconConstraints: const BoxConstraints(
                minHeight: 40,
                minWidth: 50,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
            ),
          ),
        ),
      ),
    );
  }
}