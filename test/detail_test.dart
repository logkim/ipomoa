// ignore_for_file: avoid_print
import 'package:cp949_dart/cp949_dart.dart' as cp949;
import 'package:flutter_test/flutter_test.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;

void main() {
  test('38.co.kr 상세 페이지 환불일/상장일 파싱 테스트', () async {
    final detailUri = Uri.parse('http://www.38.co.kr/html/fund/?o=v&no=2316');
    final res = await http.get(
      detailUri,
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
      },
    );

    expect(res.statusCode, 200);
    final decodedHtml = cp949.decode(res.bodyBytes);
    final doc = html_parser.parse(decodedHtml);

    String? refundDate;
    String? listingDate;

    // 모든 행을 순회하며 환불일, 신규상장일 탐색
    for (final tr in doc.querySelectorAll('tr')) {
      final tds = tr.querySelectorAll('td');
      for (var i = 0; i < tds.length; i++) {
        final text = tds[i].text.replaceAll('\u00a0', '').trim();
        if (text == '환불일' && i + 1 < tds.length) {
          refundDate = tds[i + 1].text.replaceAll('\u00a0', '').trim();
        } else if (text.contains('신규상장일') && i + 1 < tds.length) {
          listingDate = tds[i + 1].text.replaceAll('\u00a0', '').trim();
        }
      }
    }

    print('환불일: $refundDate');
    print('상장일: $listingDate');

    expect(refundDate, contains('2026.10.13'));
    expect(listingDate, contains('2026.10.20'));
  });
}
