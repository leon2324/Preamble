import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:lawapp/components/search/search_bar.dart';
import 'package:lawapp/theme/adaptive_layout.dart';

/// 早期的熱門頁草稿，保留分類九宮格實驗版供後續參考。
class TrendPage extends StatefulWidget {
  const TrendPage({super.key});

  @override
  TrendState createState() => TrendState();
}

class TrendState extends State<TrendPage> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 字級放大時同步降低格子長寬比，避免分類文字被擠到兩行。
    final textScaleProgress =
        ((context.adaptiveTextScale - 1.0) / 0.4).clamp(0.0, 1.0);
    final gridAspectRatio = lerpDouble(1.5, 1.15, textScaleProgress) ?? 1.5;
    final imageHeight = 70 + context.adaptiveBuffer(18);

    return Column(
      children: [
        Row(
          children: [
            AppSearchBar(
              hintText: "搜尋案件、人名...",
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
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: gridAspectRatio,
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
                      height: imageHeight,
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
