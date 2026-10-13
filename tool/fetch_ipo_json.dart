// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'package:ipomoa/services/ipo_crawler_service.dart';

Future<void> main() async {
  print('=== 공모주 최신 데이터 크롤링 시작 (38.co.kr) ===');
  final crawler = IpoCrawlerService();
  try {
    final items = await crawler.fetchIpoList(
      fetchDetails: true,
      onProgress: (current, total) {
        stdout.write('\r상세정보 수집 중: $current / $total');
      },
    );
    print('\n수집 완료: 총 ${items.length}건');

    final jsonList = items.map((e) => e.toJson()).toList();
    final jsonStr = const JsonEncoder.withIndent('  ').convert(jsonList);

    final targetFile = File('assets/data/ipo_items.json');
    targetFile.parent.createSync(recursive: true);
    targetFile.writeAsStringSync(jsonStr);

    print('성공: ${targetFile.path} 에 ${items.length}개 종목 저장 완료!');
  } catch (e, stack) {
    print('오류 발생: $e');
    print(stack);
    exit(1);
  }
}
