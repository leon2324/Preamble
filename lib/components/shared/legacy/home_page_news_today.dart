import 'package:flutter/material.dart';

/// 舊版首頁新聞區塊。
///
/// 目前保留作為版型演進參考，不再是首頁正式使用的元件。
class NewsTodayAtHomePage extends StatelessWidget {
  NewsTodayAtHomePage({super.key});

  final List<String> newsTitles = [
    "快訊/運動部今天揭牌！",
    "午後變天！大台北防較大雨勢",
    "今晨地震嚇醒南部人",
    "最新防疫措施公布",
    "颱風生成機率提高",
    "台股早盤大跌200點",
    "醫界警告流感上升",
    "交通管制新制上路",
    "北市捷運新站試營運",
    "週末氣溫驟降注意保暖",
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '今日新聞',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              IconButton(
                onPressed: () {
                  // TODO: 之後接上「查看更多新聞」頁面。
                },
                icon: const Icon(Icons.arrow_forward_ios),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          SingleChildScrollView(
            clipBehavior: Clip.none,
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(newsTitles.length, (index) {
                return Container(
                  width: 164,
                  height: 175,
                  margin: EdgeInsets.only(
                      right: index == newsTitles.length - 1 ? 0 : 10),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 205, 226, 215),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 7,
                        ),
                        child: Stack(
                          clipBehavior: Clip.none, // 允許子元件超出卡片邊界
                          children: [
                            Center(
                              child: Container(
                                width: 140,
                                height: 95,
                                decoration: BoxDecoration(
                                  color:
                                      const Color.fromARGB(255, 158, 158, 158),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                            Positioned(
                              left: -10,
                              top: -15,
                              child: Container(
                                width: 44,
                                height: 40,
                                decoration: BoxDecoration(
                                  color:
                                      const Color.fromARGB(255, 194, 194, 194),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: const Center(
                                  child: Text(
                                    'logo',
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 0, 0, 0),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 2,
                        ),
                        child: Text(
                          newsTitles[index],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
