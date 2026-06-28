import 'package:flutter/material.dart';
import 'package:preamble/features/case_library/theme/case_library_theme.dart';

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
        backgroundColor:
            primary ? CaseLibraryColors.libraryDeepTeal : Colors.transparent,
        side: const BorderSide(color: CaseLibraryColors.libraryBorderGold),
      ),
      onPressed: onPressed,
      child: Text(label, style: CaseLibraryTextStyles.buttonText(context)),
    );
  }
}
