import 'package:flutter/material.dart';
import 'package:lawapp/theme/adaptive_layout.dart';

class AppSearchBar extends StatefulWidget {
  const AppSearchBar({
    super.key,
    required this.hintText,
    required this.controller,
  });

  final String hintText;
  final TextEditingController controller;

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final extraHeight = context.adaptiveBuffer(10);
    final fieldHeight = 52 + extraHeight;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
        child: Container(
          height: fieldHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE4E7EC)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12101828),
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            onSubmitted: (_) => FocusScope.of(context).unfocus(),
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: const TextStyle(color: Color(0xFF98A2B3)),
              border: InputBorder.none,
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: Color(0xFF667085),
              ),
              isCollapsed: true,
              contentPadding: EdgeInsets.symmetric(
                vertical: fieldHeight * 0.28,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
