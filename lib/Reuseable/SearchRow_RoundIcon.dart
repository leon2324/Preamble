import 'package:flutter/material.dart';

class RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const RoundIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Ink(
        width: 55,
        height: 44,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 224, 224, 224),
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(255, 156, 155, 155),
              spreadRadius: -2,//決定陰影擴散的程度，數值越大陰影越大，越小陰影越明亮
              blurRadius: 10,//決定陰影模糊的程度，數值越大越模糊，越小隔閡感越大
              offset: Offset(0, 8),//決定陰影的偏移量，x向右偏移，y向下偏移
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.grey[600],
          size: 24,
        ),
      ),
    );
  }
}
