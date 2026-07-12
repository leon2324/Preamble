import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:preamble/app/app_state.dart';
import 'package:preamble/app/build_info.dart';
import 'package:preamble/pages/profile/profile_page.dart';

void main() {
  test('formats normal version, build and git sha', () {
    final info = BuildInfo.fromValues(
      version: '1.1.0',
      buildNumber: '5',
      gitSha: '60b898c4bad672dd0547790687339dfec90bbbf0',
    );

    expect(info.shortGitSha, '60b898c');
    expect(info.displayLabel, '版本 1.1.0（Build 5） • 60b898c');
  });

  test('hides git sha when it is not provided', () {
    final info = BuildInfo.fromValues(
      version: '1.1.0',
      buildNumber: '5',
      gitSha: '',
    );

    expect(info.shortGitSha, 'unknown');
    expect(info.displayLabel, '版本 1.1.0（Build 5）');
  });

  test('formats git sha edge lengths consistently', () {
    BuildInfo infoFor(String gitSha) {
      return BuildInfo.fromValues(
        version: '1.1.0',
        buildNumber: '5',
        gitSha: gitSha,
      );
    }

    expect(infoFor('abc1234').shortGitSha, 'abc1234');
    expect(infoFor('abc12345').shortGitSha, 'abc1234');
    expect(infoFor('abc1234567').shortGitSha, 'abc1234');
    expect(
      infoFor('60b898c4bad672dd0547790687339dfec90bbbf0').shortGitSha,
      '60b898c',
    );
  });

  testWidgets('profile falls back when build info provider fails', (
    WidgetTester tester,
  ) async {
    await _pumpProfile(
      tester,
      size: const Size(320, 568),
      textScaleFactor: 1.4,
      buildInfoProvider: _FailingBuildInfoProvider(),
    );

    await tester.pump();

    expect(find.text('版本 unknown（Build unknown）'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('profile shows build info at 320pt and text 140%', (
    WidgetTester tester,
  ) async {
    await _pumpProfile(
      tester,
      size: const Size(320, 568),
      textScaleFactor: 1.4,
    );

    expect(find.text('版本 1.1.0（Build 5） • 60b898c'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('profile shows build info at 393pt and text 120%', (
    WidgetTester tester,
  ) async {
    await _pumpProfile(
      tester,
      size: const Size(393, 852),
      textScaleFactor: 1.2,
    );

    expect(find.text('版本 1.1.0（Build 5） • 60b898c'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('profile build info supports dark mode', (
    WidgetTester tester,
  ) async {
    await _pumpProfile(
      tester,
      size: const Size(393, 852),
      textScaleFactor: 1.2,
      brightness: Brightness.dark,
    );

    expect(find.text('版本 1.1.0（Build 5） • 60b898c'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpProfile(
  WidgetTester tester, {
  required Size size,
  required double textScaleFactor,
  Brightness brightness = Brightness.light,
  BuildInfoProvider buildInfoProvider = const _FakeBuildInfoProvider(),
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
      splitScreenMode: true,
      builder: (_, __) => PreambleScope(
        state: PreambleState(),
        child: MaterialApp(
          theme: ThemeData(
            brightness: brightness,
            useMaterial3: true,
          ),
          home: MediaQuery(
            data: MediaQueryData(
              size: size,
              textScaler: TextScaler.linear(textScaleFactor),
            ),
            child: ProfilePage(buildInfoProvider: buildInfoProvider),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.scrollUntilVisible(
    find.text('版本資訊'),
    240,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pump();
}

class _FakeBuildInfoProvider implements BuildInfoProvider {
  const _FakeBuildInfoProvider();

  @override
  Future<BuildInfo> load() async {
    return BuildInfo.fromValues(
      version: '1.1.0',
      buildNumber: '5',
      gitSha: '60b898c4bad672dd0547790687339dfec90bbbf0',
    );
  }
}

class _FailingBuildInfoProvider implements BuildInfoProvider {
  @override
  Future<BuildInfo> load() async => throw StateError('package info failed');
}
