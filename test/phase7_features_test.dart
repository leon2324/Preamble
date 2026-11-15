import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:preamble/app/preamble_theme.dart';
import 'package:preamble/components/shared/preamble_empty_state.dart';
import 'package:preamble/components/shared/preamble_shimmer_skeleton.dart';
import 'package:preamble/utils/pii_data_masker.dart';

void main() {
  group('Phase 7 PiiDataMasker Security Tests', () {
    test('masks standard Taiwan ID', () {
      const input = '我的身分證字號是A123456789，請幫我查閱。';
      final masked = PiiDataMasker.mask(input);
      expect(masked, '我的身分證字號是[保護資訊]，請幫我查閱。');
    });

    test('masks standard Taiwan mobile phone', () {
      const input = '聯絡電話：0912-345-678 或 0987654321';
      final masked = PiiDataMasker.mask(input);
      expect(masked, '聯絡電話：[保護資訊] 或 [保護資訊]');
    });

    test('leaves non-PII text unchanged', () {
      const input = '我想了解民法第184條的侵權損害賠償。';
      final masked = PiiDataMasker.mask(input);
      expect(masked, input);
    });
  });

  group('Phase 7 UI/UX Components Tests', () {
    test('PreambleTheme generates Light and Dark themes', () {
      // ignore: deprecated_member_use_from_same_package
      final lightTheme = PreambleTheme.getLightTheme();
      // ignore: deprecated_member_use_from_same_package
      final darkTheme = PreambleTheme.getDarkTheme();

      expect(lightTheme.brightness, Brightness.light);
      expect(darkTheme.brightness, Brightness.dark);
      expect(lightTheme.primaryColor, const Color(0xFF2C5E43));
    });

    testWidgets('PreambleEmptyState renders title and button', (tester) async {
      bool buttonTapped = false;
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(393, 852),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: PreambleEmptyState(
                title: '找不到資料',
                subtitle: '請嘗試其他關鍵字',
                actionLabel: '重新搜尋',
                onAction: () => buttonTapped = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('找不到資料'), findsOneWidget);
      expect(find.text('請嘗試其他關鍵字'), findsOneWidget);
      expect(find.text('重新搜尋'), findsOneWidget);

      await tester.tap(find.text('重新搜尋'));
      expect(buttonTapped, true);
    });

    testWidgets('PreambleShimmerSkeleton builds without error', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(393, 852),
          builder: (context, child) => const MaterialApp(
            home: Scaffold(
              body: PreambleShimmerSkeleton(
                width: 200,
                height: 50,
              ),
            ),
          ),
        ),
      );

      // Verify the widget is in the tree
      expect(find.byType(PreambleShimmerSkeleton), findsOneWidget);
      // Wait for one frame of the animation
      await tester.pump();
    });
  });
}
