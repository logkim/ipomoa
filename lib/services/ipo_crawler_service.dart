import 'package:cp949_dart/cp949_dart.dart' as cp949;
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;
import '../models/ipo_item.dart';

class IpoCrawlerService {
  static const String _ipoUrl = 'http://www.38.co.kr/html/fund/index.htm?o=k';

  /// 38커뮤니케이션 공모주 청약일정 메인 목록 크롤링
  Future<List<IpoItem>> fetchIpoList({bool fetchDetails = true, Function(int current, int total)? onProgress}) async {
    final response = await http.get(
      Uri.parse(_ipoUrl),
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('공모주 데이터를 가져오지 못했습니다. (HTTP ${response.statusCode})');
    }

    final decodedHtml = cp949.decode(response.bodyBytes);
    final document = html_parser.parse(decodedHtml);

    final tables = document.querySelectorAll('table');
    final ipoTable = tables.firstWhere(
      (tbl) =>
          tbl.attributes['summary']?.contains('공모주') == true ||
          tbl.text.contains('확정공모가'),
      orElse: () => throw Exception('공모주 일정 테이블을 찾을 수 없습니다.'),
    );

    final rows = ipoTable.querySelectorAll('tr');
    final List<IpoItem> items = [];

    for (var i = 1; i < rows.length; i++) {
      final cols = rows[i].querySelectorAll('td');
      if (cols.length < 6) continue;

      final name = cols[0].text.replaceAll('\u00a0', '').trim();
      final schedule = cols[1].text.replaceAll('\u00a0', '').trim();
      final confirmedPrice = cols[2].text.replaceAll('\u00a0', '').trim();
      final expectedPrice = cols[3].text.replaceAll('\u00a0', '').trim();
      final competitionRate = cols[4].text.replaceAll('\u00a0', '').trim();
      final underwriter = cols[5].text.replaceAll('\u00a0', '').trim();

      // 상세 페이지 링크 추출
      String? detailUrl;
      final anchor = cols[0].querySelector('a');
      if (anchor != null && anchor.attributes.containsKey('href')) {
        final href = anchor.attributes['href']!;
        if (href.startsWith('http')) {
          detailUrl = href;
        } else {
          detailUrl = 'http://www.38.co.kr$href';
        }
      }

      if (name.isNotEmpty && schedule.contains('~')) {
        items.add(
          IpoItem(
            name: name,
            schedule: schedule,
            confirmedPrice: confirmedPrice.isEmpty ? '-' : confirmedPrice,
            expectedPrice: expectedPrice.isEmpty ? '-' : expectedPrice,
            competitionRate: competitionRate.isEmpty ? '-' : competitionRate,
            underwriter: underwriter.isEmpty ? '-' : underwriter,
            detailUrl: detailUrl,
          ),
        );
      }
    }

    // 상세 정보(환불일, 상장일) 가져오기
    if (fetchDetails && items.isNotEmpty) {
      for (var i = 0; i < items.length; i++) {
        final item = items[i];
        if (item.detailUrl != null) {
          try {
            await fetchDetailDates(item);
          } catch (_) {
            // 개별 실패 시 무시하고 진행
          }
        }
        if (onProgress != null) {
          onProgress(i + 1, items.length);
        }
      }
    }

    return items;
  }

  /// 개별 종목 상세 페이지에서 환불일 및 상장일 파싱
  Future<void> fetchDetailDates(IpoItem item) async {
    if (item.detailUrl == null) return;

    final response = await http.get(
      Uri.parse(item.detailUrl!),
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
      },
    );

    if (response.statusCode != 200) return;

    final decodedHtml = cp949.decode(response.bodyBytes);
    final doc = html_parser.parse(decodedHtml);

    for (final tr in doc.querySelectorAll('tr')) {
      final tds = tr.querySelectorAll('td');
      for (var i = 0; i < tds.length; i++) {
        final text = tds[i].text.replaceAll('\u00a0', '').trim();
        if (text == '환불일' && i + 1 < tds.length) {
          item.refundDate = tds[i + 1].text.replaceAll('\u00a0', '').trim();
        } else if (text.contains('신규상장일') && i + 1 < tds.length) {
          item.listingDate = tds[i + 1].text.replaceAll('\u00a0', '').trim();
        }
      }
    }
  }
}
