import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:preamble/app/app_state.dart';
import 'package:preamble/pages/journal/widgets/assistant_prompt_bubble.dart';
import 'package:preamble/pages/journal/widgets/journal_palette.dart';
import 'package:preamble/pages/learning/know_law_page.dart';

void main() {
  testWidgets('AssistantPromptBubble renders correctly and navigates on tap',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    // Set a phone size so screenutil calculates correctly
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1179, 2556);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    final appState = PreambleState();
    addTearDown(appState.dispose);
    await appState.load();

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, __) => PreambleScope(
          state: appState,
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  final palette = JournalPalette.of(context);
                  return AssistantPromptBubble(palette: palette);
                },
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Mascot Image is present
    expect(find.byType(Image), findsOneWidget);

    // Verify default prompt text
    expect(find.textContaining('問問小法助：'), findsOneWidget);

    // Tap on the bubble
    await tester.tap(find.byType(AssistantPromptBubble));
    await tester.pumpAndSettle();

    // Should navigate to LawAssistantChatPage
    expect(find.byType(LawAssistantChatPage), findsOneWidget);
  });
}
