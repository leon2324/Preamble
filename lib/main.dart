import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:lawapp/Pages/AboutMe_Page.dart';
import 'package:lawapp/Pages/InternationalCase_Page.dart';
import 'package:lawapp/Pages/Notifications_Page.dart';
import 'dart:async';
import 'Pages/Home_Page.dart';
import 'Pages/KnowLaw_Page.dart';
import 'Pages/Trend_Page.dart';
  
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await initializeDateFormatting("zh_TW", null);
  runApp(
    ScreenUtilInit(//使用flutter_screenutil套件來做響應式設計
      designSize: Size(375, 812),//設計稿Figma的尺寸，建議一律用375x812
      minTextAdapt: true,//文字自動適應開啟
      splitScreenMode: true,//支援分割螢幕與折疊手機
      builder: (context, child) {
        return MylawApp();
      },
    ),
  );
}

class MylawApp extends StatefulWidget {
  const MylawApp({super.key});

  @override
  State<MylawApp> createState() => _MylawAppState();
}

class _MylawAppState extends State<MylawApp> {
  int selectedIndex = 0;

  void _navigateBottomBar(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  final List _pages = [
    //首頁
    const HomePage(),

    //了解法律頁面
    const KnowLawPage(),

    //趨勢頁面
    const trendPage(),

    //國際刑案頁面
    const internationalcasePage(),

    //搜尋頁面
    const NotificationPage(),

    //關於我頁面
    const AboutmePage(),
  ];

  String dateTimeString = "載入中...";

  late Timer timer;

  @override
  void initState() {
    super.initState();
    updateDateTime(); //立即更新時間
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      //每分鐘更新一次
      updateDateTime();
    });
  }

  void updateDateTime() {
    setState(() {
      dateTimeString = DateFormat(
        "yyyy年MM月dd日EEEE",
        "zh_TW",
      ).format(DateTime.now());
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('zh', 'TW'),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue)
      ),
      title: 'MylawApp',
      home: Scaffold(
        // appBar: AppBar(
        //   backgroundColor: const Color.fromARGB(255, 120, 150, 238),
        //   title: ListTile(
        //     title: Text(
        //       dateTimeString,
        //       textAlign: TextAlign.center,
        //       style: const TextStyle(
        //           fontSize: 23.4, color: Color.fromARGB(255, 72, 0, 255)),
        //     ),
        //     subtitle: const SingleChildScrollView(
        //       scrollDirection: Axis.horizontal,
        //       child: Text(
        //         '如果末日沒有發生 不要等到來生 讓此時此刻能不虛此生－五月天<第二人生>',
        //         style: TextStyle(
        //           fontSize: 20,
        //         ),
        //       ),
        //     ),
        //   ),
        //   toolbarHeight: 70,
        // ),
        body: SafeArea(child: _pages[selectedIndex]),
        bottomNavigationBar: SizedBox(
          child: BottomNavigationBar(
            iconSize: 27,
            showUnselectedLabels: false,
            showSelectedLabels: false,
            currentIndex: selectedIndex,
            onTap: _navigateBottomBar,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: '首頁',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.inbox),
                label: '了解法律',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.archive_outlined),
                label: '趨勢',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.public),
                label: '國際案件',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications),
                label: '最新通知',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: '關於我',
              ),
            ],
            backgroundColor: Colors.white,
            selectedItemColor: const Color.fromARGB(255, 220, 189, 147),
            type: BottomNavigationBarType.fixed,
          ),
        ),
      ),
    );
  }
}

