import 'package:flutter/material.dart';

/// 搜尋列兩側共用的膠囊型 icon button。
class RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double width;
  final double height;
  final double iconSize;
  final List<BoxShadow>? boxShadow;
  final Color backgroundColor;

  const RoundIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.width = 59,
    this.height = 47,
    this.iconSize = 24,
    this.boxShadow,
    this.backgroundColor = const Color.fromARGB(255, 224, 224, 224),
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      // 把陰影放在最外層盒子，Material / InkWell 才不會把陰影裁掉。
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height / 2),
        boxShadow: boxShadow ??
            const [
              BoxShadow(
                color: Color.fromARGB(255, 92, 92, 92),
                spreadRadius: -4,
                blurRadius: 24,
                offset: Offset(0, 14),
              ),
            ],
      ),
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(height / 2),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(height / 2),
          child: SizedBox(
            width: width,
            height: height,
            child: Center(
              child: Icon(
                icon,
                color: Colors.grey[600],
                size: iconSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
