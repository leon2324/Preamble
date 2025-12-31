import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomePage_NewLegalNewsletter extends StatefulWidget {
  const HomePage_NewLegalNewsletter({super.key});

  @override
  State<HomePage_NewLegalNewsletter> createState() =>
      _HomePage_NewLegalNewsletterState();
}

class _HomePage_NewLegalNewsletterState
    extends State<HomePage_NewLegalNewsletter> {
  final PageController controller = PageController();
  int currentPage = 0;

  final bool ShowTip = true;

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
  Widget build(BuildContext context) {
    final cardWidth = 0.85.sw;
    final cardHeight = 240.h;

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
                  fontSize: 25.sp,
                ),
              ),
              IconButton(
                onPressed: () {
                  // TODO: Navigate to more new law news page
                },
                icon: Icon(Icons.arrow_forward_ios),
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
                return Container(
                  margin: EdgeInsets.only(
                      right: index == newsTitles.length - 1 ? 0 : 10.w),
                  decoration: BoxDecoration(
                    color: Color(0xFFF2EADF),
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  padding: EdgeInsets.all(12.w),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            //標題
                            child: Text(
                              newsTitles[index],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 20.sp,
                                color: Color(0xFF2B4499),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 6,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(height: 8.h),
                                  //內文
                                  Text(
                                    newsContent[index],
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: Color(0xFF2B4499),
                                      height: 1.4,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  //小提醒bool
                                  if (ShowTip) ...[
                                    Text(
                                      newsTip[index],
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: Color.fromARGB(255, 25, 134, 1),
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ]),
                          ),
                          Expanded(
                            flex: 4,
                            // child: ClipRRect(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.r),
                                  color:
                                      const Color.fromARGB(255, 160, 160, 160),
                                ),
                              ),
                            // ),
                          ),
                        ],
                      ),
                      //下面4個按鈕
                      Row(
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          InterActionButton(Icons.favorite_sharp, Color.fromARGB(255, 255, 0, 0), "300+", (){}),
                          InterActionButton(Icons.share, Color.fromARGB(255, 124, 108, 7), "100+", (){}),
                          InterActionButton(Icons.comment_rounded, Color.fromARGB(255, 0, 94, 42), "100+", (){}),
                          InterActionButton(Icons.download, Color.fromARGB(255, 0, 124, 124), "500+", (){}),
                                
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


Widget InterActionButton(IconData icon, Color color, String count , VoidCallback onPressed) {
  return InkWell(  // 用 InkWell 取代 IconButton
    onTap: () {
      // TODO: 按讚、分享等邏輯
    },
    borderRadius: BorderRadius.circular(8.r),  // 點擊波紋圓角
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),  // 自己控制 padding
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24.sp, color: color),
          SizedBox(width: 6.w),
          Text(
            count,
            style: TextStyle(fontSize: 14.sp, color: const Color.fromARGB(255, 0, 0, 0)),
          ),
        ],
      ),
    ),
  );
}