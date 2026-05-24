import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract final class CaseTimeMachineColors {
  static const libraryMidnight = Color(0xFF061817);
  static const libraryDeepGreen = Color(0xFF0B2A24);
  static const libraryDeepTeal = Color(0xFF0F3A3A);
  static const libraryMistBlue = Color(0xFFA8C7C7);
  static const libraryMutedGold = Color(0xFFC6A96C);
  static const libraryFogWhite = Color(0xFFF2F5F2);
  static const libraryTextPrimary = Color(0xFFF2F5F2);
  static const libraryTextSecondary = Color(0xFFD7DFD8);
  static const libraryTextMuted = Color(0xFF91A3A0);
  static const libraryCardGlass = Color(0xE60B2A24);
  static const libraryBorderGold = Color(0xBFC6A96C);
  static const libraryBorderMist = Color(0x99A8C7C7);
}

abstract final class CaseTimeMachineTextStyles {
  static const _serif = 'Songti TC';
  static const _fallbacks = ['Songti SC', 'STSong', 'PingFang TC'];

  static TextStyle displayTitle(BuildContext context) => TextStyle(
        fontFamily: _serif,
        fontFamilyFallback: _fallbacks,
        fontSize: 36.sp,
        height: 1.1,
        letterSpacing: 3,
        fontWeight: FontWeight.w800,
        color: CaseTimeMachineColors.libraryTextPrimary,
      );

  static TextStyle pageTitle(BuildContext context) => TextStyle(
        fontFamily: _serif,
        fontFamilyFallback: _fallbacks,
        fontSize: 27.sp,
        height: 1.14,
        letterSpacing: 2.2,
        fontWeight: FontWeight.w800,
        color: CaseTimeMachineColors.libraryTextPrimary,
      );

  static TextStyle sectionTitle(BuildContext context) => TextStyle(
        fontSize: 17.sp,
        height: 1.25,
        fontWeight: FontWeight.w800,
        color: CaseTimeMachineColors.libraryTextPrimary,
      );

  static TextStyle cardTitle(BuildContext context) => TextStyle(
        fontSize: 15.sp,
        height: 1.28,
        fontWeight: FontWeight.w800,
        color: CaseTimeMachineColors.libraryTextPrimary,
      );

  static TextStyle body(BuildContext context) => TextStyle(
        fontSize: 13.sp,
        height: 1.58,
        color: CaseTimeMachineColors.libraryTextSecondary,
      );

  static TextStyle bodySmall(BuildContext context) => TextStyle(
        fontSize: 11.5.sp,
        height: 1.45,
        color: CaseTimeMachineColors.libraryTextSecondary,
      );

  static TextStyle caption(BuildContext context) => TextStyle(
        fontSize: 10.5.sp,
        height: 1.34,
        letterSpacing: 0.5,
        color: CaseTimeMachineColors.libraryTextMuted,
      );

  static TextStyle chipText(BuildContext context) => TextStyle(
        fontSize: 10.5.sp,
        fontWeight: FontWeight.w800,
        color: CaseTimeMachineColors.libraryMutedGold,
      );

  static TextStyle buttonText(BuildContext context) => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.4,
        color: CaseTimeMachineColors.libraryFogWhite,
      );
}

abstract final class CaseTimeMachineSpacing {
  static const double spaceXS = 4;
  static const double spaceS = 8;
  static const double spaceM = 12;
  static const double spaceL = 16;
  static const double spaceXL = 24;
  static const double spaceXXL = 32;
}

abstract final class CaseTimeMachineRadii {
  static const double radiusSmall = 8;
  static const double radiusMedium = 14;
  static const double radiusLarge = 20;
  static const double radiusXL = 28;
}

abstract final class CaseTimeMachineShadows {
  static BoxShadow get mistGlow => BoxShadow(
        color: CaseTimeMachineColors.libraryMistBlue.withValues(alpha: 0.22),
        blurRadius: 24,
        spreadRadius: -4,
        offset: const Offset(0, 8),
      );

  static BoxShadow get goldGlow => BoxShadow(
        color: CaseTimeMachineColors.libraryMutedGold.withValues(alpha: 0.18),
        blurRadius: 22,
        spreadRadius: -6,
        offset: const Offset(0, 10),
      );
}
