import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('pubspec version is the release baseline source value', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final version = RegExp(r'^version:\s*(\S+)\s*$', multiLine: true)
        .firstMatch(pubspec)
        ?.group(1);

    expect(version, '1.1.0+1');
  });

  test('Runner and Widget targets derive version from Flutter build values',
      () {
    final runnerInfo = File('ios/Runner/Info.plist').readAsStringSync();
    final widgetInfo =
        File('ios/PreambleTodayCaseWidget/Info.plist').readAsStringSync();
    final project =
        File('ios/Runner.xcodeproj/project.pbxproj').readAsStringSync();
    final versionConfig =
        File('ios/Flutter/Version.xcconfig').readAsStringSync();

    expect(runnerInfo, contains(r'<string>$(FLUTTER_BUILD_NAME)</string>'));
    expect(runnerInfo, contains(r'<string>$(FLUTTER_BUILD_NUMBER)</string>'));
    expect(widgetInfo, contains(r'<string>$(MARKETING_VERSION)</string>'));
    expect(
        widgetInfo, contains(r'<string>$(CURRENT_PROJECT_VERSION)</string>'));
    expect(versionConfig, contains('#include "Generated.xcconfig"'));
    expect(project, isNot(contains('MARKETING_VERSION = 1.0;')));
    expect(project, isNot(contains('CURRENT_PROJECT_VERSION = 1;')));
    expect(
      RegExp(
        r'PreambleTodayCaseWidget"[\s\S]*?baseConfigurationReference = '
        r'7B8F6C2A2F1C4A0B9D7E1101 /\* Version\.xcconfig \*/;',
      ).hasMatch(project),
      isTrue,
    );
    expect(project, contains(r'MARKETING_VERSION = "$(FLUTTER_BUILD_NAME)";'));
    expect(
      project,
      contains(r'CURRENT_PROJECT_VERSION = "$(FLUTTER_BUILD_NUMBER)";'),
    );
  });

  test('Profile page no longer contains fake release labels', () {
    final profile =
        File('lib/pages/profile/profile_page.dart').readAsStringSync();

    expect(profile, isNot(contains('Build 42')));
    expect(profile, isNot(contains('v1.0.0')));
  });
}
