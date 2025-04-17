import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  notificationState createState() => notificationState();
}

class notificationState extends State<NotificationPage> {
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
                children: [SelectArea()],
              ),
              Row(
                children: [
                  SearchResult(),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SelectArea extends StatefulWidget {
  const SelectArea({super.key});

  @override
  State<SelectArea> createState() => _SelectAreaState();
}

class _SelectAreaState extends State<SelectArea> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final double buttonWidth = (MediaQuery.of(context).size.width - 40) / 3;

    return Expanded(
      // body: Center(
        // child: Container(
          // padding: const EdgeInsets.all(5),
          
          
        
      
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(3, (index) {
              return Padding(
                padding: const EdgeInsets.all(5),
                child: ElevatedButton(
                  
                  onPressed: () {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[400],
                    foregroundColor: selectedIndex == index
                      ? const Color.fromARGB(255, 0, 0, 0)
                      : const Color.fromARGB(255, 103, 103, 103),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    ["案件", "法律", "追蹤中"][index],
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
              );
            }),
          ),
        // ),
      // ),
    );
  }
}

class SearchResult extends StatelessWidget {
  const SearchResult({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            "歷史紀錄",
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: 23.4,
              color: Color.fromARGB(255, 44, 43, 46),
            ),
          ),
          Text(
            "你還沒有任何搜尋內容",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 23.4,
              color: Color.fromARGB(255, 184, 177, 199),
            ),
          ),
        ],
      ),
    );
  }
}
