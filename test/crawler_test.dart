// ignore_for_file: avoid_print
import 'package:cp949_dart/cp949_dart.dart' as cp949;
import 'package:flutter_test/flutter_test.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;

void main() {
  test('38.co.kr 공모주 크롤링 및 파싱 테스트', () async {
    final uri = Uri.parse('http://www.38.co.kr/html/fund/index.htm?o=k');
    final response = await http.get(
      uri,
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
      },
    );

    expect(response.statusCode, 200);

    // EUC-KR / CP949 디코딩
    final decodedHtml = cp949.decode(response.bodyBytes);
    expect(decodedHtml.contains('공모주일정'), isTrue);

    final document = html_parser.parse(decodedHtml);
    final tables = document.querySelectorAll('table');
    
    // summary="공모주 청약일정" 또는 내용으로 테이블 찾기
    final ipoTable = tables.firstWhere(
      (tbl) =>
          tbl.attributes['summary']?.contains('공모주') == true ||
          tbl.text.contains('확정공모가'),
    );

    final rows = ipoTable.querySelectorAll('tr');
    print('총 행 개수: ${rows.length}');

    final parsedItems = <Map<String, String>>[];

    for (var i = 1; i < rows.length; i++) {
      final cols = rows[i].querySelectorAll('td');
      if (cols.length < 6) continue;

      final name = cols[0].text.replaceAll('\u00a0', '').trim();
      final schedule = cols[1].text.replaceAll('\u00a0', '').trim();
      final confirmedPrice = cols[2].text.replaceAll('\u00a0', '').trim();
      final expectedPrice = cols[3].text.replaceAll('\u00a0', '').trim();
      final competitionRate = cols[4].text.replaceAll('\u00a0', '').trim();
      final underwriter = cols[5].text.replaceAll('\u00a0', '').trim();

      if (name.isNotEmpty && schedule.contains('~')) {
        parsedItems.add({
          'name': name,
          'schedule': schedule,
          'confirmedPrice': confirmedPrice.isEmpty ? '-' : confirmedPrice,
          'expectedPrice': expectedPrice,
          'competitionRate': competitionRate.isEmpty ? '-' : competitionRate,
          'underwriter': underwriter,
        });
      }
    }

    print('파싱된 종목 수: ${parsedItems.length}');
    for (var item in parsedItems.take(5)) {
      print('종목: ${item['name']}, 일정: ${item['schedule']}, 확정가: ${item['confirmedPrice']}, 희망가: ${item['expectedPrice']}, 경쟁률: ${item['competitionRate']}, 주간사: ${item['underwriter']}');
    }

    expect(parsedItems.isNotEmpty, isTrue);
  });
}
