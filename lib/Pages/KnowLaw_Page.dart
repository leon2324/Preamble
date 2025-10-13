import 'package:flutter/material.dart';
import '../Reuseable/SearchBar.dart';



class KnowLawPage extends StatefulWidget {
  const KnowLawPage({super.key});

  @override
  Liststate createState() => Liststate();
}

class Liststate extends State<KnowLawPage> {
  Liststate() : super();

  final controller = TextEditingController();
  final focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: SizedBox(
        height: 70,
        width: 70,
        child:FloatingActionButton(
          backgroundColor: const Color.fromARGB(255, 248, 204, 111),
          onPressed: () {},
          shape: const CircleBorder(),
          child: const Question(),
        ),
      ),
      body:Column(
        children: [
          Row(
            children: [
              searchbar(
                hintText:"搜尋判決、法律、實例...",
                controller: controller,),
            ],
          ),
          Expanded(
            child: ListView(
              children: [
                const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(
                    width: 15,
                  ),
                  Text(
                    '根據你最近查看的案件',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ]),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 28,
                    ),
                    TextButton(
                      style: ButtonStyle(
                        foregroundColor:
                            WidgetStateProperty.all<Color>(Colors.black),
                        overlayColor: WidgetStateProperty.resolveWith((states) {
                          return Colors.transparent;
                        }),
                      ),
                      onPressed: () {
                        print('按鈕被按下囉！');
                      },
                      child: const Text(
                        '勞動基準法',
                        style: TextStyle(
                          fontSize: 23,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 28,
                    ),
                    TextButton(
                      style: ButtonStyle(
                        foregroundColor:
                          WidgetStateProperty.all<Color>(Colors.black),
                        overlayColor: WidgetStateProperty.resolveWith((states) {
                          return Colors.transparent;
                        }),
                      ),
                      onPressed: () {
                        print('按鈕被按下囉！');
                      },
                      child: const Text(
                        '職業安全衛生設施條例',
                        style: TextStyle(
                          fontSize: 23,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 28,
                    ),
                    TextButton(
                      style: ButtonStyle(
                        foregroundColor:
                            WidgetStateProperty.all<Color>(Colors.black),
                        overlayColor: WidgetStateProperty.resolveWith((states) {
                          return Colors.transparent;
                        }),
                      ),
                      onPressed: () {
                        print('按鈕被按下囉！');
                      },
                      child: const Text(
                        '行政程序法',
                        style: TextStyle(
                          fontSize: 23,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 28,
                    ),
                    TextButton(
                      style: ButtonStyle(
                        foregroundColor:
                            WidgetStateProperty.all<Color>(Colors.black),
                        overlayColor: WidgetStateProperty.resolveWith((states) {
                          return Colors.transparent;
                        }),
                      ),
                      onPressed: () {
                        print('按鈕被按下囉！');
                      },
                      child: const Text(
                        '洗錢防制法',
                        style: TextStyle(
                          fontSize: 23,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 28,
                    ),
                    TextButton(
                      style: ButtonStyle(
                        foregroundColor:
                            WidgetStateProperty.all<Color>(Colors.black),
                        overlayColor: WidgetStateProperty.resolveWith((states) {
                          return Colors.transparent;
                        }),
                      ),
                      onPressed: () {
                        print('按鈕被按下囉！');
                      },
                      child: const Text(
                        '貪污治罪條例',
                        style: TextStyle(
                          fontSize: 23,
                        ),
                      ),
                    ),
                  ],
                ),
                const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(
                    width: 15,
                  ),
                  Text(
                    '你可能也會感興趣',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ]),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 28,
                    ),
                    TextButton(
                      style: ButtonStyle(
                        foregroundColor:
                            WidgetStateProperty.all<Color>(Colors.black),
                        overlayColor: WidgetStateProperty.resolveWith((states) {
                          return Colors.transparent;
                        }),
                      ),
                      onPressed: () {
                        print('按鈕被按下囉！');
                      },
                      child: const Text(
                        '道路交通處罰管理條例',
                        style: TextStyle(
                          fontSize: 23,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 28,
                    ),
                    TextButton(
                      style: ButtonStyle(
                        foregroundColor:
                            WidgetStateProperty.all<Color>(Colors.black),
                        overlayColor: WidgetStateProperty.resolveWith((states) {
                          return Colors.transparent;
                        }),
                      ),
                      onPressed: () {
                        print('按鈕被按下囉！');
                      },
                      child: const Text(
                        '證券交易法',
                        style: TextStyle(
                          fontSize: 23,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 28,
                    ),
                    TextButton(
                      style: ButtonStyle(
                        foregroundColor:
                            WidgetStateProperty.all<Color>(Colors.black),
                        overlayColor: WidgetStateProperty.resolveWith((states) {
                          return Colors.transparent;
                        }),
                      ),
                      onPressed: () {
                        print('按鈕被按下囉！');
                      },
                      child: const Text(
                        '銀行法',
                        style: TextStyle(
                          fontSize: 23,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 28,
                    ),
                    TextButton(
                      style: ButtonStyle(
                        foregroundColor:
                            WidgetStateProperty.all<Color>(Colors.black),
                        overlayColor: WidgetStateProperty.resolveWith((states) {
                          return Colors.transparent;
                        }),
                      ),
                      onPressed: () {
                        print('按鈕被按下囉！');
                      },
                      child: const Text(
                        '所得稅法',
                        style: TextStyle(
                          fontSize: 23,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 28,
                    ),
                    TextButton(
                      style: ButtonStyle(
                        foregroundColor:
                            WidgetStateProperty.all<Color>(Colors.black),
                        overlayColor: WidgetStateProperty.resolveWith((states) {
                          return Colors.transparent;
                        }),
                      ),
                      onPressed: () {
                        print('按鈕被按下囉！');
                      },
                      child: const Text(
                        '少年事件處理法',
                        style: TextStyle(
                          fontSize: 23,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 28,
                    ),
                    TextButton(
                      style: ButtonStyle(
                        foregroundColor:
                            WidgetStateProperty.all<Color>(Colors.black),
                        overlayColor: WidgetStateProperty.resolveWith((states) {
                          return Colors.transparent;
                        }),
                      ),
                      onPressed: () {
                        print('按鈕被按下囉！');
                      },
                      child: const Text(
                        '槍砲彈藥管理條例',
                        style: TextStyle(
                          fontSize: 23,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 28,
                    ),
                    TextButton(
                      style: ButtonStyle(
                        foregroundColor:
                            WidgetStateProperty.all<Color>(Colors.black),
                        overlayColor: WidgetStateProperty.resolveWith((states) {
                          return Colors.transparent;
                        }),
                      ),
                      onPressed: () {
                        print('按鈕被按下囉！');
                      },
                      child: const Text(
                        '著作權法',
                        style: TextStyle(
                          fontSize: 23,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



class Question extends StatelessWidget {
  
  const Question({super.key});
  
  void showKnowCard(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return const EveryDayKnowOneThing();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(  
      onTap: () {
        showKnowCard(context);
      },
      child: const Text(
        "？",
        style: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class EveryDayKnowOneThing extends StatelessWidget {
  const EveryDayKnowOneThing({super.key});

  @override
  Widget build(BuildContext context) {
    return const AlertDialog(
      backgroundColor: Color.fromARGB(255, 253, 216, 176),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(
              '跟人家發生車禍可以逃跑嗎？',
              style: TextStyle(
                fontSize: 23,
              ),
            ),
            subtitle: Text(
              '相信跟人家發生車禍這件事情常見，但發生了就是馬上叫警察處理喔，並不是跑掉，就算跑掉了以台灣監視器密度這麼高的情況下也可以隨時發函給你請你到案說明喔',
              style: TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }
}
