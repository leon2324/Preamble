import 'package:flutter/material.dart';




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
              hintText: "搜尋判決、法律、實例...",
              // contentPadding: EdgeInsets.all(0),
              border: InputBorder.none,
              suffixIcon:Icon(
                Icons.search,
                size: 32,
                color: Colors.grey[600],
              ),
              suffixIconConstraints: const BoxConstraints(
                minHeight: 40,
                minWidth: 50,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
            ),
          ),
        ),
      ),
    );
  }
}