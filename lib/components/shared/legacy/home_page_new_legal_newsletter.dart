import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomePageNewLegalNewsletter extends StatefulWidget {
  const HomePageNewLegalNewsletter({super.key});

  @override
  State<HomePageNewLegalNewsletter> createState() =>
      _HomePageNewLegalNewsletterState();
}

class _HomePageNewLegalNewsletterState
    extends State<HomePageNewLegalNewsletter> {
  final PageController controller = PageController();
  int currentPage = 0;

  final bool showTip = true;

  final List<String> newsTitles = [
    "自拍時拍到別人臉，侵權了？！",
    "外送員摔倒找誰賠？",
    "租屋族必看！房東房客的權利與義務一次搞懂",
    "網路言論自由 vs 網路誹謗：界線在哪裡？",
    "遇到警察臨檢，你有什麼權利？",
    "下半年連假多五個！",
    "公部門資安大升級！",
  ];

  final List<String> newsContent = [
    "公共場所攝影雖普遍，但若未經同意特寫他人，或將照片用於營利、醜化，恐侵犯「肖像權」。建議發布至公開平台前，適度針對路人臉部進行遮蔽，尊重他人隱私也保障自己。",
    "外送員意外受傷時，須視勞務關係而定。除了確認平台是否提供傷害險，若因路面坑洞造成意外，可蒐證向相關單位申請國賠；若與他車擦撞，則依交通事故處理程序釐清肇責。",
    "簽訂合約需載明修繕責任、押金上限與報稅權益。了解《租賃法》規定，能有效避免因修繕爭議或不合理條款產生的糾紛，保障雙方居住正義，讓租屋生活更加安心有保障。",
    "言論自由並非毫無節制，若在網路上發表不實指控，足以毀損他人名譽，便可能觸犯誹謗罪。發言前請務必查證事實，切勿讓自由成為傷害他人的利刃，以免惹上官司。",
    "警員執勤須表明身分並有合理懷疑。若無犯罪事實，民眾可依法拒絕搜身或車內檢查。若對程序有異議，請保持冷靜，並要求開立「臨檢異議紀錄表」，以利後續救濟維護權益。",
    "今年下半年小確幸來襲，經彈性調整後連假數量大增！這波長假是難得的休整機會，無論是安排長途旅遊或在家放鬆，快翻開行事曆提前規劃，與親友共度充實又愉快的假期時光。",
    "為守護國人個人隱私，政府導入零信任架構，強化關鍵基礎設施防護。透過嚴密控管與數據加密，嚴防駭客攻擊與數據外洩，為數位時代的資訊往來，建立起更穩固的防護網。",
  ];

  final List<String> newsTip = [
    "上傳前路人臉部先打碼，尊重肖像權避紛爭。",
    "",
    "簽約詳閱修繕與押金條款，保障權利避糾紛。",
    "發言應基於事實，避免人身攻擊，以免觸法。",
    "",
    "提早規劃行程與訂房，避開人潮享受好假期。",
    "使用強密碼與雙重驗證，共同守護資訊安全。",
  ];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isCompactScreen = screenHeight <= 700;
    final cardHeight = isCompactScreen ? 232.h : 240.h;

    return Padding(
      padding: EdgeInsets.fromLTRB(15.w, 0, 15.w, 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '法律新知小報',
                style: TextStyle(
                  fontSize: 20.sp,
                ),
              ),
              IconButton(
                onPressed: () {
                  // TODO: Navigate to more new law news page
                },
                icon: const Icon(Icons.arrow_forward_ios),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: cardHeight,
            child: PageView.builder(
              controller: controller,
              itemCount: newsTitles.length,
              onPageChanged: (i) => setState(() => currentPage = i),
              itemBuilder: (context, index) {
                final showTip = this.showTip &&
                    newsTip[index].isNotEmpty &&
                    MediaQuery.of(context).size.height >= 760;
                final contentMaxLines = showTip ? 3 : 4;

                return Container(
                  margin: EdgeInsets.only(
                      right: index == newsTitles.length - 1 ? 0 : 10.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2EADF),
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  padding: EdgeInsets.all(12.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        newsTitles[index],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isCompactScreen ? 18.sp : 20.sp,
                          color: const Color(0xFF2B4499),
                        ),
                      ),
                      SizedBox(height: isCompactScreen ? 6.h : 8.h),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 6,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    newsContent[index],
                                    maxLines: contentMaxLines,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: isCompactScreen ? 15.sp : 16.sp,
                                      color: const Color(0xFF2B4499),
                                      height: 1.4,
                                    ),
                                  ),
                                  SizedBox(
                                      height: showTip
                                          ? (isCompactScreen ? 6.h : 8.h)
                                          : 0),
                                  if (showTip)
                                    Text(
                                      newsTip[index],
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize:
                                            isCompactScreen ? 12.sp : 13.sp,
                                        color: const Color.fromARGB(
                                            255, 25, 134, 1),
                                        height: 1.4,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              flex: 4,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.r),
                                  color:
                                      const Color.fromARGB(255, 160, 160, 160),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: isCompactScreen ? 6.h : 8.h),
                      Wrap(
                        spacing: isCompactScreen ? 10.w : 12.w,
                        runSpacing: isCompactScreen ? 6.h : 8.h,
                        children: [
                          interactionButton(
                            Icons.favorite_sharp,
                            const Color.fromARGB(255, 255, 0, 0),
                            "300+",
                            isCompactScreen,
                            () {},
                          ),
                          interactionButton(
                            Icons.share,
                            const Color.fromARGB(255, 124, 108, 7),
                            "100+",
                            isCompactScreen,
                            () {},
                          ),
                          interactionButton(
                            Icons.comment_rounded,
                            const Color.fromARGB(255, 0, 94, 42),
                            "100+",
                            isCompactScreen,
                            () {},
                          ),
                          interactionButton(
                            Icons.download,
                            const Color.fromARGB(255, 0, 124, 124),
                            "500+",
                            isCompactScreen,
                            () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 12.h),
          //下方圓點指示器
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(newsTitles.length, (index) {
              return Container(
                width: 8.w,
                height: 8.w,
                margin: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: currentPage == index ? Colors.black : Colors.grey,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

Widget interactionButton(
  IconData icon,
  Color color,
  String count,
  bool isCompactScreen,
  VoidCallback onPressed,
) {
  return InkWell(
    // 用 InkWell 取代 IconButton
    onTap: onPressed,
    borderRadius: BorderRadius.circular(8.r), // 點擊波紋圓角
    child: Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isCompactScreen ? 2.w : 4.w,
        vertical: isCompactScreen ? 2.h : 4.h,
      ), // 自己控制 padding
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isCompactScreen ? 22.sp : 24.sp, color: color),
          SizedBox(width: isCompactScreen ? 4.w : 6.w),
          Text(
            count,
            style: TextStyle(
              fontSize: isCompactScreen ? 13.sp : 14.sp,
              color: const Color.fromARGB(255, 0, 0, 0),
            ),
          ),
        ],
      ),
    ),
  );
}
