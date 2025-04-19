import 'package:flutter/material.dart';

class searchbar extends StatelessWidget {
  final String hintText;
  final focusNode = FocusNode();
  final TextEditingController controller;

  searchbar({
    Key? key,
    required this.hintText,
    required this.controller,
  }) : super(key: key);


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
            controller: controller,
            focusNode: focusNode,
            onTap: () {
              focusNode.requestFocus();
            },
            // onChanged: (value) {
            //   print("search query: $value");
            // },
            decoration: InputDecoration(
              hintStyle: TextStyle(color: Colors.grey[500]),
              hintText: hintText,
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
