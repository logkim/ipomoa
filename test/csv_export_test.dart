// ignore_for_file: avoid_print
import 'package:ipomoa/models/ipo_item.dart';
import 'package:ipomoa/services/csv_export_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CSV 형식 및 데이터 변환 검증 테스트', () {
    final item = IpoItem(
      name: '모아전자',
      schedule: '2026.10.07~10.08',
      confirmedPrice: '15,000',
      expectedPrice: '12,000~15,000',
      competitionRate: '1500:1',
      underwriter: '한국투자증권',
      refundDate: '2026.10.12',
      listingDate: '2026.10.20',
      memo: '비례배정',
    );

    final row = item.toCsvRow();
    expect(row[0], '공모주'); // 분류
    expect(row[1], '모아전자'); // 종목명
    expect(row[2], '2026-10-07'); // 청약 시작
    expect(row[3], '2026-10-08'); // 청약 마감
    expect(row[4], '2026-10-12'); // 환불일
    expect(row[5], '2026-10-20'); // 상장일
    expect(row[6], '15000'); // 공모가 (숫자)
    expect(row[7], '한국투자증권'); // 주간사
    expect(row[8], '1500:1'); // 경쟁률
    expect(row[9], '비례배정'); // 메모

    // CSV 문자열 생성 및 헤더 검증
    final csvOutput = CsvExportService.generateCsv([item], includeBom: true);
    print('생성된 CSV 내용:\n$csvOutput');

    expect(csvOutput.startsWith('\uFEFF'), isTrue); // Excel 한글 깨짐 방지용 BOM
    expect(csvOutput, contains('분류,종목명,청약 시작,청약 마감,환불일,상장일,공모가,주간사,경쟁률,메모'));
    expect(csvOutput, contains('공모주,모아전자,2026-10-07,2026-10-08,2026-10-12,2026-10-20,15000,한국투자증권,1500:1,비례배정'));
  });

  test('isCurrentMonth 필터 로직 검증 테스트', () {
    final now = DateTime.now();
    final currentYearMonth = '${now.year}.${now.month.toString().padLeft(2, '0')}';
    final nextMonthDate = DateTime(now.year, now.month + 1, 15);
    final nextYearMonth = '${nextMonthDate.year}.${nextMonthDate.month.toString().padLeft(2, '0')}';

    final currentMonthItem = IpoItem(
      name: '당월종목',
      schedule: '$currentYearMonth.10~10.11',
      confirmedPrice: '10000',
      expectedPrice: '10000',
      competitionRate: '100:1',
      underwriter: '미래에셋증권',
    );

    final nextMonthItem = IpoItem(
      name: '익월종목',
      schedule: '$nextYearMonth.15~11.16',
      confirmedPrice: '20000',
      expectedPrice: '20000',
      competitionRate: '200:1',
      underwriter: 'NH투자증권',
    );

    expect(currentMonthItem.isCurrentMonth, isTrue);
    expect(currentMonthItem.isNextMonth, isFalse);
    expect(nextMonthItem.isCurrentMonth, isFalse);
    expect(nextMonthItem.isNextMonth, isTrue);
  });
}
