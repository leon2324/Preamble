import 'package:flutter/material.dart';
import 'package:lawapp/features/case_time_machine/theme/case_time_machine_theme.dart';

class FavoriteFollowButton extends StatelessWidget {
  const FavoriteFollowButton(
      {super.key,
      required this.label,
      required this.onPressed,
      this.primary = false});

  final String label;
  final VoidCallback onPressed;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: primary
            ? CaseTimeMachineColors.libraryDeepTeal
            : Colors.transparent,
        side: const BorderSide(color: CaseTimeMachineColors.libraryBorderGold),
      ),
      onPressed: onPressed,
      child: Text(label, style: CaseTimeMachineTextStyles.buttonText(context)),
    );
  }
}
