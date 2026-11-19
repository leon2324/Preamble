import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:preamble/data/cases/case_api_service.dart';
import 'package:preamble/data/cases/case_repository.dart';
import 'package:preamble/data/documents/document_repository.dart';
import 'package:preamble/data/following/following_api_service.dart';
import 'package:preamble/data/following/following_repository.dart';
import 'package:preamble/data/law_assistant/law_assistant_api_service.dart';
import 'package:preamble/data/law_assistant/law_assistant_repository.dart';
import 'package:preamble/data/moj/moj_feed_service.dart';
import 'package:preamble/data/official/official_feed_api_service.dart';
import 'package:preamble/data/official/official_feed_repository.dart';
import 'package:preamble/data/search/search_api_service.dart';
import 'package:preamble/data/search/search_repository.dart';
import 'package:preamble/data/statutes/statute_api_service.dart';
import 'package:preamble/data/statutes/statute_repository.dart';
import 'package:preamble/data/user/quota_api_service.dart';

// 台灣繁體中文教學註解：用可觀察的假 client 驗證資源所有權；
// 服務 dispose 後若此旗標仍為 false，表示共用連線沒有被錯誤關閉。
class _TrackingClient extends http.BaseClient {
  bool closed = false;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async =>
      http.StreamedResponse(const Stream<List<int>>.empty(), 200);

  @override
  void close() {
    closed = true;
  }
}

// 台灣繁體中文教學註解：除了確認共用 client 未關閉，也直接記錄注入 service 的
// dispose 呼叫次數，避免 repository 偷偷釋放外部資源卻被 client 測試掩蓋。
class _TrackingCaseApiService extends CaseApiService {
  _TrackingCaseApiService(http.Client client) : super(client: client);
  int disposeCount = 0;
  @override
  void dispose() => disposeCount++;
}

class _TrackingStatuteApiService extends StatuteApiService {
  _TrackingStatuteApiService(http.Client client) : super(client: client);
  int disposeCount = 0;
  @override
  void dispose() => disposeCount++;
}

class _TrackingSearchApiService extends SearchApiService {
  _TrackingSearchApiService(http.Client client) : super(client: client);
  int disposeCount = 0;
  @override
  void dispose() => disposeCount++;
}

void main() {
  test('後端服務與文件 repository 不關閉外部注入的 HTTP client', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final client = _TrackingClient();
    CaseApiService(client: client).dispose();
    SearchApiService(client: client).dispose();
    FollowingApiService(client: client).dispose();
    OfficialFeedApiService(client: client).dispose();
    LawAssistantApiService(client: client).dispose();
    StatuteApiService(client: client).dispose();
    MojFeedService(client: client).dispose();
    QuotaApiService(client: client).dispose();
    DocumentRepository(client: client, prefs: prefs).dispose();
    expect(client.closed, isFalse);
    client.close();
    expect(client.closed, isTrue);
  });

  test('組合型 repository 不釋放注入的依賴', () {
    final client = _TrackingClient();
    final caseApi = _TrackingCaseApiService(client);
    final statuteApi = _TrackingStatuteApiService(client);
    final searchApi = _TrackingSearchApiService(client);
    final caseRepository = CaseRepository(apiService: caseApi);
    final statuteRepository = StatuteRepository(apiService: statuteApi);
    SearchRepository(
      caseRepository: caseRepository,
      statuteRepository: statuteRepository,
      searchApiService: searchApi,
    ).dispose();
    caseRepository.dispose();
    statuteRepository.dispose();
    expect(caseApi.disposeCount, 0);
    expect(statuteApi.disposeCount, 0);
    expect(searchApi.disposeCount, 0);
    FollowingRepository(apiService: FollowingApiService(client: client))
        .dispose();
    LawAssistantRepository(apiService: LawAssistantApiService(client: client))
        .dispose();
    OfficialFeedRepository(
      mojFeedService: MojFeedService(client: client),
      apiService: OfficialFeedApiService(client: client),
    ).dispose();
    expect(client.closed, isFalse);
    client.close();
  });
}
