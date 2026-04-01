import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lawapp/components/search/search_row_home_page.dart';
import 'package:lawapp/components/shared/page_section_header.dart';
import 'package:lawapp/theme/adaptive_layout.dart';

class SearchPageLayout extends StatefulWidget {
  const SearchPageLayout({
    super.key,
    required this.controller,
    required this.hintText,
    this.headerTitle,
    this.headerSubtitle,
    this.headerTitleSize = 28,
    required this.builder,
  });

  final TextEditingController controller;
  final String hintText;
  final String? headerTitle;
  final String? headerSubtitle;
  final double headerTitleSize;
  final Widget Function(
    BuildContext context,
    HomeSearchLayout layout,
    double contentTopPadding,
    double contentBottomPadding,
  ) builder;

  @override
  State<SearchPageLayout> createState() => _SearchPageLayoutState();
}

class _SearchPageLayoutState extends State<SearchPageLayout> {
  double _titleStretch = 0;
  double _searchCollapseProgress = 0;

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical || notification.depth != 0) {
      return false;
    }

    final nextStretch =
        notification.metrics.pixels < 0 ? -notification.metrics.pixels : 0.0;
    final nextCollapseProgress = notification.metrics.pixels <= 0
        ? 0.0
        : (notification.metrics.pixels / 56).clamp(0.0, 1.0);

    final shouldUpdateStretch = (nextStretch - _titleStretch).abs() >= 0.5;
    final shouldUpdateCollapse =
        (nextCollapseProgress - _searchCollapseProgress).abs() >= 0.01;
    if (!shouldUpdateStretch && !shouldUpdateCollapse) {
      return false;
    }

    setState(() {
      if (shouldUpdateStretch) {
        _titleStretch = nextStretch;
      }
      if (shouldUpdateCollapse) {
        _searchCollapseProgress = nextCollapseProgress;
      }
    });

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final layout = context.homeSearchLayout;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;
    final searchBarBottom = layout.searchBarTopOffset.h + 74.h;
    final hasPinnedHeader =
        widget.headerTitle != null && widget.headerSubtitle != null;
    final headerTop = searchBarBottom + 10.h;
    final headerHeight = hasPinnedHeader ? 86.h : 0.0;
    final contentTopPadding = hasPinnedHeader
        ? headerTop + headerHeight + 14.h
        : context.searchPageContentTopPadding;
    final contentBottomPadding =
        context.pageContentBottomPadding + 24 + keyboardInset;
    final titleMaskTop = headerTop + (headerHeight * 0.34);
    final titleMaskHeight = hasPinnedHeader ? 116.h : 0.0;
    final topBackdropHeight = hasPinnedHeader ? titleMaskTop + 8.h : 0.0;

    return Stack(
      children: [
        Positioned.fill(
          child: NotificationListener<ScrollNotification>(
            onNotification: _handleScrollNotification,
            child: widget.builder(
              context,
              layout,
              contentTopPadding,
              contentBottomPadding,
            ),
          ),
        ),
        if (hasPinnedHeader)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Container(
                height: topBackdropHeight,
                color: backgroundColor,
              ),
            ),
          ),
        if (hasPinnedHeader)
          Positioned(
            top: titleMaskTop,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Container(
                height: titleMaskHeight,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0, 0.18, 0.42, 0.72, 1],
                    colors: [
                      backgroundColor,
                      backgroundColor.withValues(alpha: 0.92),
                      backgroundColor.withValues(alpha: 0.64),
                      backgroundColor.withValues(alpha: 0.24),
                      backgroundColor.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        if (hasPinnedHeader)
          Positioned(
            top: headerTop,
            left: 16.w,
            right: 16.w,
            child: IgnorePointer(
              child: PageSectionHeader(
                title: widget.headerTitle!,
                subtitle: widget.headerSubtitle!,
                stretch: _titleStretch,
                titleSize: widget.headerTitleSize,
              ),
            ),
          ),
        Positioned(
          top: layout.searchBarTopOffset.h,
          left: 0,
          right: 0,
          child: SearchRowHomePage(
            controller: widget.controller,
            collapseProgress: _searchCollapseProgress,
            hintText: widget.hintText,
          ),
        ),
      ],
    );
  }
}
