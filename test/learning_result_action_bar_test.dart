import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:preamble/components/home/v2/home_v2_palette.dart';
import 'package:preamble/pages/learning/widgets/learning_result_action_bar.dart';

void main() {
  const copyLabel = '複製文字';
  const noteLabel = '摘錄筆記';
  const exportLabel = '預覽與匯出 PDF';

  Future<void> pumpActionBar(
    WidgetTester tester, {
    required Size size,
    required double textScale,
    required VoidCallback onCopy,
    required VoidCallback onNote,
    required VoidCallback onExport,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        builder: (context, __) => MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
                size: size, textScaler: TextScaler.linear(textScale)),
            child: Scaffold(
              body: Padding(
                // 台灣繁體中文教學註解：學習頁外層、NotebookCard 與結果框合計
                // 約有 40.w 左右內距，393pt 裝置傳給操作列的實際寬度約為 309pt。
                padding: EdgeInsets.symmetric(horizontal: 40.w),
                child: LearningResultActionBar(
                  copyAction: LearningResultActionButton(
                    key: const ValueKey('copy-action'),
                    icon: Icons.copy,
                    label: copyLabel,
                    color: const Color(0xFFC2185B),
                    onPressed: onCopy,
                  ),
                  noteAction: LearningResultActionButton(
                    key: const ValueKey('note-action'),
                    icon: Icons.bookmark_add_outlined,
                    label: noteLabel,
                    color: const Color(0xFF8D7F70),
                    onPressed: onNote,
                  ),
                  exportAction: LearningResultActionButton(
                    key: const ValueKey('export-action'),
                    icon: Icons.picture_as_pdf_rounded,
                    label: exportLabel,
                    color: HomeV2Palette.trustGreen,
                    onPressed: onExport,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  void expectAllActionsVisible() {
    expect(find.text(copyLabel), findsOneWidget);
    expect(find.text(noteLabel), findsOneWidget);
    expect(find.text(exportLabel), findsOneWidget);
  }

  void expectActionLabelsAreNotTruncated(WidgetTester tester) {
    for (final label in [copyLabel, noteLabel, exportLabel]) {
      final paragraph = tester.renderObject<RenderParagraph>(find.text(label));
      expect(paragraph.didExceedMaxLines, isFalse, reason: '$label 不可被截斷');
    }
  }

  void expectSharedActionContainerStyle(WidgetTester tester) {
    final decorations = tester
        .widgetList<Ink>(find.byType(Ink))
        .map((ink) => ink.decoration! as BoxDecoration)
        .toList(growable: false);
    expect(decorations, hasLength(3));
    expect(
      decorations.map((decoration) => decoration.color).toSet(),
      hasLength(1),
    );
    expect(
      decorations
          .map((decoration) => (decoration.border! as Border).top.color)
          .toSet(),
      hasLength(1),
    );

    final labelColors = [copyLabel, noteLabel, exportLabel]
        .map((label) => tester.widget<Text>(find.text(label)).style!.color)
        .toSet();
    expect(labelColors, hasLength(1));
  }

  void expectAllActionsOnSameRow(WidgetTester tester) {
    final copyY =
        tester.getCenter(find.byKey(const ValueKey('copy-action'))).dy;
    final noteY =
        tester.getCenter(find.byKey(const ValueKey('note-action'))).dy;
    final exportY =
        tester.getCenter(find.byKey(const ValueKey('export-action'))).dy;
    expect(noteY, closeTo(copyY, 0.1));
    expect(exportY, closeTo(copyY, 0.1));
  }

  void expectPdfOnNextRow(WidgetTester tester) {
    final firstRowBottom =
        tester.getBottomRight(find.byKey(const ValueKey('copy-action'))).dy;
    final exportTop =
        tester.getTopLeft(find.byKey(const ValueKey('export-action'))).dy;
    expect(exportTop, greaterThan(firstRowBottom));
  }

  testWidgets('393pt at 80 percent keeps all actions on the same row',
      (tester) async {
    await pumpActionBar(
      tester,
      size: const Size(393, 852),
      textScale: 0.8,
      onCopy: () {},
      onNote: () {},
      onExport: () {},
    );

    expectAllActionsVisible();
    expectAllActionsOnSameRow(tester);
    expectActionLabelsAreNotTruncated(tester);
    expectSharedActionContainerStyle(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('393pt at 100 percent keeps all learning result actions visible',
      (tester) async {
    await pumpActionBar(
      tester,
      size: const Size(393, 852),
      textScale: 1,
      onCopy: () {},
      onNote: () {},
      onExport: () {},
    );

    expectAllActionsVisible();
    expectAllActionsOnSameRow(tester);
    expectActionLabelsAreNotTruncated(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('393pt at 120 percent keeps the PDF action fully readable',
      (tester) async {
    await pumpActionBar(
      tester,
      size: const Size(393, 852),
      textScale: 1.2,
      onCopy: () {},
      onNote: () {},
      onExport: () {},
    );

    expectAllActionsVisible();
    expectAllActionsOnSameRow(tester);
    expectActionLabelsAreNotTruncated(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      '320pt at 120 percent wraps actions and keeps every action tappable',
      (tester) async {
    var copyTapped = false;
    var noteTapped = false;
    var exportTapped = false;
    await pumpActionBar(
      tester,
      size: const Size(320, 568),
      textScale: 1.2,
      onCopy: () => copyTapped = true,
      onNote: () => noteTapped = true,
      onExport: () => exportTapped = true,
    );

    expectAllActionsVisible();
    expectPdfOnNextRow(tester);
    expectActionLabelsAreNotTruncated(tester);
    await tester.tap(find.text(copyLabel));
    await tester.tap(find.text(noteLabel));
    await tester.tap(find.text(exportLabel));
    expect(copyTapped, isTrue);
    expect(noteTapped, isTrue);
    expect(exportTapped, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      '375pt at 140 percent preserves every primary action without overflow',
      (tester) async {
    await pumpActionBar(
      tester,
      size: const Size(375, 812),
      textScale: 1.4,
      onCopy: () {},
      onNote: () {},
      onExport: () {},
    );

    expectAllActionsVisible();
    expectPdfOnNextRow(tester);
    expectActionLabelsAreNotTruncated(tester);
    expect(tester.takeException(), isNull);
  });
}
