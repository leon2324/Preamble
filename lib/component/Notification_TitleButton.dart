import 'package:flutter/material.dart';

class SelectArea extends StatefulWidget {
  const SelectArea({super.key});

  @override
  State<SelectArea> createState() => SelectAreaState();
}

class SelectAreaState extends State<SelectArea> {
  int selectedIndex = 0;
  final List<String> buttonLabels = ["案件", "法律", "追蹤中"];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = (screenWidth) / 3; //90%寬減掉20的padding

    return Expanded(
      child: Transform.translate(
        offset: const Offset(2, -20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(buttonLabels.length, (index) {
            return Expanded(
                child: _EachButtonInArea(index, buttonLabels[index]));
          }),
        ),
      ),
    );
  }

  Widget _EachButtonInArea(int index, String text) {
    final bool isSelected = selectedIndex == index; // 假設第一個按鈕是選中的

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: Colors.grey[400],
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Transform.translate(
          offset: const Offset(30, 5),
          child: Text(
            buttonLabels[index],
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.grey[600],
              fontSize: 25,
            ),
          ),
        ),
      ),
    );
  }
}
