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
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 156, 155, 155),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, 6), // changes position of shadow
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
