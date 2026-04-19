import 'package:flutter/material.dart';
import 'package:lawapp/data/mock_data/followed_updates/followed_updates_mock_data.dart';

/// 舊版追蹤頁篩選按鈕實驗元件。
class SelectArea extends StatefulWidget {
  const SelectArea({super.key});

  @override
  State<SelectArea> createState() => SelectAreaState();
}

class SelectAreaState extends State<SelectArea> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Transform.translate(
        offset: const Offset(2, -20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(notificationFilterLabels.length, (index) {
            return Expanded(
                child:
                    _eachButtonInArea(index, notificationFilterLabels[index]));
          }),
        ),
      ),
    );
  }

  Widget _eachButtonInArea(int index, String text) {
    final bool isSelected = selectedIndex == index; // 依目前選中的索引決定樣式

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
            notificationFilterLabels[index],
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.grey[600],
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }
}
