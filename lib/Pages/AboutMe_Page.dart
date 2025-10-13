import 'package:flutter/material.dart';

class AboutmePage extends StatefulWidget {
  const AboutmePage({super.key});

  @override
  aboutmeState createState() => aboutmeState();
}

class aboutmeState extends State<AboutmePage> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // 當偵測到滾動時隱藏鍵盤
      },
      child: ListView(
        children: const [
          Column(
            children: [
              Row(
                children: <SearchBar>[SearchBar()],
              ),
            ],
          ),
        ],
      ),
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
  final double _scrollThreshold = 50;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 122, 234, 122),
            borderRadius: BorderRadius.circular(10),
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
              hintStyle: TextStyle(color: Colors.grey[400]),
              hintText: '想搜尋的內容....',
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
}
