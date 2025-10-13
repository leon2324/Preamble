import 'package:flutter/material.dart';

class internationalcasePage extends StatefulWidget {
  const internationalcasePage({super.key});

  @override
  internationalcasePageState createState() => internationalcasePageState();
}

class internationalcasePageState extends State<internationalcasePage> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: FirstContent(),
    );
  }
}

class FirstContent extends StatelessWidget {
  const FirstContent({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Text(
            textAlign: TextAlign.center,
            "此區內容尚未開放\n敬請期待！",
            style: TextStyle(
              fontSize: 23.4,
              color: Color.fromARGB(255, 184, 177, 199),
            ),
          ),
        ),
      ),
    );
  }
}
