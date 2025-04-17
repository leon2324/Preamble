
import 'package:flutter/material.dart';

class HomePageContent1 extends StatelessWidget {
  const HomePageContent1({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 121, 197, 232),
              borderRadius: BorderRadius.circular(12),
            ),
            child: WhatIsPopularNow(
                casename: casename, case_taptimes: case_taptimes),
          ),
          const Positioned(
            top: 8,
            right: 0,
            child: Icon(
              Icons.keyboard_arrow_right_sharp,
              color: Color.fromARGB(255, 95, 92, 95),
              size: 55,
            ),
          ),
        ],
      ),
    );
  }
}

String casename = '台南殺警案';
String case_taptimes = '已有500個人對這個案件感興趣';

class WhatIsPopularNow extends StatelessWidget {
  const WhatIsPopularNow({
    super.key,
    required this.casename,
    required this.case_taptimes,
  });
  final String casename;
  final String case_taptimes;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Text(
                '最近夯什麼',
                style: TextStyle(fontSize: 25),
              ),
              // const SizedBox(
              //   height: 10,
              // ),
              Text(
                casename,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
              // const SizedBox(
              //   height: 15,
              // ),
              Text(
                case_taptimes,
                style: TextStyle(color: Colors.grey[700], fontSize: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class HomePageContent2 extends StatelessWidget {
  const HomePageContent2 ({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 121, 197, 232),
              borderRadius: BorderRadius.circular(12),
            ),
            child: WhatIsOnTrend(
              trend: trend, trend_taptimes: trend_taptimes
            ),
          ),
          const Positioned(
            top: 8,
            right: 0,
            child: Icon(
              Icons.keyboard_arrow_right_sharp,
              color: Color.fromARGB(255, 95, 92, 95),
              size: 55,
            ),
          ),
        ],
      ),
    );
  }
}

String trend = '廢死？不廢死？';
String trend_taptimes = '已有500個人對這個議題感興趣';

class WhatIsOnTrend extends StatelessWidget {
  const WhatIsOnTrend({
    super.key,
    required this.trend,
    required this.trend_taptimes,
  });
  final String trend;
  final String trend_taptimes;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Text(
                '最近吵什麼',
                style: TextStyle(fontSize: 25),
              ),
              // const SizedBox(
              //   height: 10,
              // ),
              Text(
                trend,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
              // const SizedBox(
              //   height: 15,
              // ),
              Text(
                trend_taptimes,
                style: TextStyle(color: Colors.grey[700], fontSize: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HomePageContent3 extends StatelessWidget {
  const HomePageContent3({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Stack(
        children: [
          Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 121, 197, 232),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const WhatAreYouLearning()),
          const Positioned(
              top: 8,
              right: 0,
              child: Icon(
                Icons.keyboard_arrow_right_sharp,
                color: Color.fromARGB(255, 95, 92, 95),
                size: 55,
              )),
        ],
      ),
    );
  }
}

class WhatAreYouLearning extends StatelessWidget {
  const WhatAreYouLearning({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '最近學什麼',
                  style: TextStyle(fontSize: 25),
                ),
              ],
            ),
            // const SizedBox(
            //   height: 20.0,
            // ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 117, 194, 39),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Text(
                        '民法',
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 117, 194, 39),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Text(
                        '刑法',
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 117, 194, 39),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Text(
                        '查看更多',
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
