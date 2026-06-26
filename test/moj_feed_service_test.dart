import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lawapp/data/moj/moj_feed_item.dart';
import 'package:lawapp/data/moj/moj_feed_service.dart';

void main() {
  test('MojFeedService parses numbered official list anchors', () async {
    // 法務部列表頁目前是 HTML 清單，不是乾淨 JSON；這個測試鎖住「序號 + 標題」
    // 的解析規則，未來官方版型變動時會先在測試裡被發現。
    final service = MojFeedService(
      client: MockClient((request) async {
        expect(request.url, MojFeedCategory.news.uri);

        return http.Response.bytes(
          utf8.encode('''
            <a href="/2204/2795/2796/123456/">1 精進觀護業務效能，強化社會安全網</a>
            <a href="/skip/">法務部全球資訊網</a>
            <a href="https://www.moj.gov.tw/2204/2795/2796/987654/">2 法務部發布重要政策說明</a>
            <a href="/duplicate/">2 精進觀護業務效能，強化社會安全網</a>
          '''),
          200,
        );
      }),
    );
    addTearDown(service.dispose);

    final items = await service.fetchItems(MojFeedCategory.news);

    expect(items, hasLength(2));
    expect(items.first.title, '精進觀護業務效能，強化社會安全網');
    expect(
      items.first.url,
      'https://www.moj.gov.tw/2204/2795/2796/123456/',
    );
    expect(items.last.title, '法務部發布重要政策說明');
  });

  test('MojFeedService maps empty official lists to readable exception',
      () async {
    final service = MojFeedService(
      client: MockClient((_) async => http.Response('<main></main>', 200)),
    );
    addTearDown(service.dispose);

    expect(
      () => service.fetchItems(MojFeedCategory.lawUpdates),
      throwsA(isA<MojFeedException>()),
    );
  });
}
