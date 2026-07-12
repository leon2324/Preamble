import 'package:package_info_plus/package_info_plus.dart';

/// 台灣繁體中文教學註解：
/// BuildInfo 是 App 內顯示版本資訊的單一入口。
/// version/buildNumber 來自 iOS/Android bundle 實際安裝資訊，Git SHA 則由 CI 或本機建置時用
/// `--dart-define=GIT_SHA=...` 注入，避免把某一次 commit 永久寫死在產品程式碼。
class BuildInfo {
  const BuildInfo({
    required this.version,
    required this.buildNumber,
    required this.gitSha,
  });

  factory BuildInfo.fromValues({
    required String version,
    required String buildNumber,
    required String gitSha,
  }) {
    return BuildInfo(
      version: _normalizedValue(version, fallback: 'unknown'),
      buildNumber: _normalizedValue(buildNumber, fallback: 'unknown'),
      gitSha: _normalizedGitSha(gitSha),
    );
  }

  factory BuildInfo.unknown({String gitSha = _compileTimeGitSha}) {
    return BuildInfo.fromValues(
      version: 'unknown',
      buildNumber: 'unknown',
      gitSha: gitSha,
    );
  }

  static const _compileTimeGitSha = String.fromEnvironment(
    'GIT_SHA',
    defaultValue: 'unknown',
  );

  final String version;
  final String buildNumber;
  final String gitSha;

  String get shortGitSha {
    if (gitSha == 'unknown') return 'unknown';
    return gitSha.length <= 10 ? gitSha : gitSha.substring(0, 7);
  }

  bool get hasGitSha => shortGitSha != 'unknown';

  String get displayLabel {
    final base = '版本 $version（Build $buildNumber）';
    return hasGitSha ? '$base • $shortGitSha' : base;
  }

  static String _normalizedValue(String value, {required String fallback}) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? fallback : trimmed;
  }

  static String _normalizedGitSha(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? 'unknown' : trimmed;
  }
}

abstract class BuildInfoProvider {
  Future<BuildInfo> load();
}

class PackageBuildInfoProvider implements BuildInfoProvider {
  const PackageBuildInfoProvider();

  @override
  Future<BuildInfo> load() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return BuildInfo.fromValues(
        version: packageInfo.version,
        buildNumber: packageInfo.buildNumber,
        gitSha: const String.fromEnvironment(
          'GIT_SHA',
          defaultValue: 'unknown',
        ),
      );
    } catch (_) {
      // 台灣繁體中文教學註解：
      // Widget test 或 plugin 尚未註冊時，package_info_plus 可能無法讀取平台資料。
      // 版本列應降級顯示 placeholder，而不是讓整個「我的」頁面渲染失敗。
      return BuildInfo.unknown();
    }
  }
}
