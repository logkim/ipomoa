import 'package:ipomoa/core/db/app_database.dart';
import 'package:ipomoa/features/ipo/domain/calc_format.dart';
import 'package:ipomoa/features/ipo/domain/ipo_math.dart';
import 'package:flutter_test/flutter_test.dart';

IpoItemData testItem(int id, {int price = 10000}) => IpoItemData(
      id: id,
      name: '종목$id',
      subscribeStart: DateTime(2026, 9, 1),
      subscribeEnd: DateTime(2026, 9, 2),
      offerPrice: price,
      createdAt: DateTime(2026, 9, 1),
    );

IpoRecordData testRecord(
  int id,
  int itemId, {
  String accountName = '기본계좌',
  int? allotted,
  int? soldPrice,
  int fee = 0,
  DateTime? soldOn,
}) =>
    IpoRecordData(
      id: id,
      itemId: itemId,
      accountName: accountName,
      quantity: 10,
      deposit: 50000,
      allotted: allotted,
      soldPrice: soldPrice,
      fee: fee,
      soldOn: soldOn,
      createdAt: DateTime(2026, 9, 1),
    );

void main() {
  test('기록 수익 = (매도가 − 공모가) × 배정 − 수수료. 배정 전·안 팔았으면 null', () {
    expect(
      IpoMath.profit(
        testRecord(1, 1, allotted: 2, soldPrice: 15000, fee: 300),
        10000,
      ),
      9700,
    );
    expect(
      IpoMath.profit(testRecord(2, 1, allotted: 2, soldPrice: 8000), 10000),
      -4000,
    );
    expect(IpoMath.profit(testRecord(3, 1, allotted: 2), 10000), isNull);
    expect(IpoMath.profit(testRecord(4, 1, soldPrice: 15000), 10000), isNull);
    expect(
      IpoMath.profit(testRecord(5, 1, allotted: 0, soldPrice: 15000), 10000),
      0,
    );
  });

  test('수익률(%) = 수익 ÷ (공모가 × 배정), 반올림. 안 팔았거나 배정 0이면 null', () {
    expect(
      IpoMath.rate(
        testRecord(1, 1, allotted: 2, soldPrice: 15000, fee: 300),
        10000,
      ),
      49, // 9,700 ÷ 20,000 = 48.5%
    );
    expect(
      IpoMath.rate(testRecord(2, 1, allotted: 1, soldPrice: 29800), 10000),
      198,
    );
    expect(IpoMath.rate(testRecord(3, 1, allotted: 2), 10000), isNull);
    expect(
      IpoMath.rate(testRecord(4, 1, allotted: 0, soldPrice: 15000), 10000),
      isNull,
    );
  });

  test('종목 수익률: 판 기록의 수익 합 ÷ 판 기록의 공모가 × 배정 합', () {
    final records = [
      testRecord(1, 1, allotted: 1, soldPrice: 15000),
      testRecord(2, 1, allotted: 2, soldPrice: 12000, fee: 100),
      testRecord(3, 1, allotted: 1),
    ];
    expect(IpoMath.totalRate(records, 10000), 30); // 8,900 ÷ 30,000
    expect(IpoMath.totalRate([testRecord(3, 1, allotted: 1)], 10000), isNull);
  });

  test('수익률 및 금액 표시 포맷팅', () {
    expect(CalcFormat.signedPercent(198), '+198%');
    expect(CalcFormat.signedPercent(-12), '−12%');
    expect(CalcFormat.signedPercent(0), '0%');

    expect(CalcFormat.signedWon(5000), '+5,000원');
    expect(CalcFormat.signedWon(-4000), '−4,000원');
    expect(CalcFormat.signedWon(0), '0원');
  });

  test('종목 합계: 판 기록만 더하고, 판 기록이 없으면 null', () {
    final records = [
      testRecord(1, 1, allotted: 1, soldPrice: 15000),
      testRecord(2, 1, allotted: 2, soldPrice: 12000, fee: 100),
      testRecord(3, 1, allotted: 1),
    ];
    expect(IpoMath.total(records, 10000), 5000 + 3900);
    expect(IpoMath.total([testRecord(3, 1, allotted: 1)], 10000), isNull);
  });

  test('월간 요약: 전체 · 올해 · 이번 달 (매도일 기준)', () {
    final items = [testItem(1, price: 10000), testItem(2, price: 20000)];
    final records = [
      testRecord(
        1,
        1,
        allotted: 1,
        soldPrice: 15000,
        soldOn: DateTime(2026, 10, 3),
      ),
      testRecord(2, 2, allotted: 1, soldPrice: 25000, soldOn: DateTime(2026, 3, 3)),
      testRecord(
        3,
        2,
        allotted: 1,
        soldPrice: 30000,
        soldOn: DateTime(2025, 12, 3),
      ),
      testRecord(4, 1, allotted: 1, soldPrice: 11000),
      testRecord(5, 1, allotted: 1),
    ];
    final s = IpoMath.summary(items, records, DateTime(2026, 10, 7));
    expect(s.all, 5000 + 5000 + 10000 + 1000);
    expect(s.year, 5000 + 5000);
    expect(s.month, 5000);
    expect(s.sold, 4);
    expect(s.monthRate, 50); // 5,000 ÷ 10,000
    expect(
      IpoMath.summary(items, records, DateTime(2026, 11, 7)).monthRate,
      isNull,
    );
  });

  test('계좌별 합계: 계좌명별 수익 큰 순 정렬', () {
    final items = [testItem(1, price: 10000)];
    final records = [
      testRecord(1, 1, accountName: 'KB(가족)', allotted: 1, soldPrice: 15000),
      testRecord(2, 1, accountName: '한투(본인)', allotted: 2, soldPrice: 15000),
      testRecord(3, 1, accountName: '미래(본인)', allotted: 1, soldPrice: 12000),
      testRecord(4, 1, accountName: 'KB(가족)', allotted: 1),
    ];
    final res = IpoMath.byAccount(items, records);
    expect(res.first.accountName, '한투(본인)');
    expect(res.first.profit, 10000);
    expect(res[1].accountName, 'KB(가족)');
    expect(res[1].profit, 5000);
    expect(res[2].accountName, '미래(본인)');
    expect(res[2].profit, 2000);
  });
}
