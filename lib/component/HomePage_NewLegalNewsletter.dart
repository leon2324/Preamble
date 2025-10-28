import 'package:flutter/material.dart';

class HomePage_NewLegalNewsletter extends StatefulWidget {
  HomePage_NewLegalNewsletter({super.key});

  @override
  State<HomePage_NewLegalNewsletter> createState() =>
      _HomePage_NewLegalNewsletterState();
}

class _HomePage_NewLegalNewsletterState
    extends State<HomePage_NewLegalNewsletter> {
  final List<String> newsTitles = [
    "自拍時拍到別人臉，侵權了？！",
    "外送員摔倒找誰賠？",
    "租屋族必看！房東房客的權利與義務一次搞懂",
    "網路言論自由 vs. 網路誹謗：界線在哪裡？",
    "遇到警察臨檢，你有什麼權利？",
    "下半年連假多五個！",
    "公部門資安大升級！",
  ];

  final PageController controller = PageController(initialPage: 0);
  int CurrentPage = 0;

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
                '法律新知小報',
                style: TextStyle(
                  fontSize: 25,
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
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          PageView(
            clipBehavior: Clip.none,
            scrollDirection: Axis.horizontal,
            controller: controller,
            onPageChanged: (index) {
              setState(() {
                CurrentPage = index;
              });
            },
            children: List.generate(newsTitles.length, (index) {
              return Container(
                //pageview
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.height * 0.23,
                margin: EdgeInsets.only(
                    right: index == newsTitles.length - 1 ? 0 : 10),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 242, 234, 223),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(newsTitles.length, (index) {
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: CurrentPage == index
                      ? const Color.fromARGB(255, 0, 0, 0)
                      : const Color.fromARGB(255, 200, 200, 200),
                ),
              );
            }),
          )
        ],
      ),
    );
  }
}
