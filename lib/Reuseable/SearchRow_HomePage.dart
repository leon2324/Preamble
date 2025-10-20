import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lawapp/Reuseable/SearchRow_RoundIcon.dart';

class SearchRowHomePage extends StatelessWidget {
  final String hintText;
  final focusNode = FocusNode();
  final TextEditingController controller;
  final bool ShowLeftIcon;
  final double LeftIconSize;
  final double height;

  SearchRowHomePage({
    super.key,
    required this.hintText,
    required this.controller,
    this.ShowLeftIcon = true,
    this.LeftIconSize = 48,
    this.height = 44,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: Row(
        children: [
          AnimatedOpacity(
            opacity: ShowLeftIcon ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 150),
            // child: IconButton(
            //   icon: Icon(
            //     Icons.notifications_none,
            //     size: LeftIconSize,
            //   ),
            //   onPressed: () {
            //     //TODO: Navigate to notifications page
            //   },
            // ),
            child: AnimatedContainer(
              curve: Curves.easeOut,
              width: LeftIconSize,
              height: LeftIconSize,
              duration: const Duration(milliseconds: 150),
              child:RoundIconButton(
                icon: Icons.notifications_none,
                onPressed: () {},
              )
            ),
          ),
          Expanded(
            child: Container(
              height: 44,
              margin: const EdgeInsets.only(left: 10, right: 10),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 224, 224, 224),
                borderRadius: BorderRadius.circular(50),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromARGB(255, 156, 155, 155),
                    spreadRadius: -5, //決定陰影擴散的程度，數值越大陰影越大，越小陰影越明亮
                    blurRadius: 10, //決定陰影模糊的程度，數值越大越模糊，越小隔閡感越大
                    offset: Offset(0, 10), //決定陰影的偏移量，x向右偏移，y向下偏移
                  ),
                ],
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                onTap: () {
                  focusNode.requestFocus();
                },
                onSubmitted: (_) => FocusScope.of(context).unfocus(),
                onTapOutside: (_) =>
                    FocusScope.of(context).unfocus(), // 👈 點外面關鍵盤
                // onChanged: (value) {
                //   print("search query: $value");
                // },//用來回傳搜框內的東西
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
          RoundIconButton(
            icon: Icons.mic,
            onPressed: () {
              //TODO: Navigate to notifications page
            },
          ),
        ],
      ),
    );
  }
}

class SearchHeaderDelegate extends SliverPersistentHeaderDelegate {
  SearchHeaderDelegate({
    required this.minExtent,
    required this.maxExtent,
    required this.controller,
  });

  @override
  final double minExtent;
  @override
  final double maxExtent;
  final TextEditingController controller;

  // 計算滾動進度 (0～1)
  double _t(double shrinkOffset) {
    final total = (maxExtent - minExtent).clamp(1, double.infinity);
    return (shrinkOffset / total).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) {
    // 👇 這裡放「t 控制參數」的部分
    final double t = (shrinkOffset / 20.0).clamp(0.0, 1.0);
    final bool ShowIcon = t < 0.1;
    final double LeftIconSize = lerpDouble(48, 0, t)!;

    return Material(
      elevation: overlaps ? 2 : 0,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SearchRowHomePage(
        hintText: "快速搜尋",
        controller: controller,
        ShowLeftIcon: ShowIcon,
        LeftIconSize: LeftIconSize,
        height: 44,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SearchHeaderDelegate old) =>
      old.minExtent != minExtent || old.maxExtent != maxExtent;
}
