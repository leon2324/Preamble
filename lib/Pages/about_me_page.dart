import 'package:flutter/material.dart';

class AboutMePage extends StatefulWidget {
  const AboutMePage({super.key});

  @override
  AboutMeState createState() => AboutMeState();
}

class AboutMeState extends State<AboutMePage> {
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
                children: <AboutSearchBar>[AboutSearchBar()],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AboutSearchBar extends StatefulWidget {
  const AboutSearchBar({super.key});

  @override
  State<AboutSearchBar> createState() => _AboutSearchBarState();
}

class _AboutSearchBarState extends State<AboutSearchBar> {
  final FocusNode _focusNode = FocusNode();

  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

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
