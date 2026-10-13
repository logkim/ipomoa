import 'package:ipomoa/core/db/app_database.dart';
import 'package:ipomoa/features/ipo/domain/ipo_logic.dart';
import 'package:flutter_test/flutter_test.dart';

IpoItemData item({
  int id = 1,
  required DateTime start,
  required DateTime end,
  DateTime? refund,
  DateTime? list,
}) =>
    IpoItemData(
      id: id,
      name: '종목$id',
      subscribeStart: start,
      subscribeEnd: end,
      refundOn: refund,
      listOn: list,
      offerPrice: 10000,
      createdAt: start,
    );

void main() {
  final today = DateTime(2026, 10, 8);

  test('달에 걸치는 종목 필터링', () {
    final items = [
      item(id: 1, start: DateTime(2026, 10, 1), end: DateTime(2026, 10, 2)),
      item(id: 2, start: DateTime(2026, 9, 30), end: DateTime(2026, 10, 1)),
      item(id: 3, start: DateTime(2026, 11, 1), end: DateTime(2026, 11, 2)),
    ];

    final oct = IpoLogic.inMonth(items, DateTime(2026, 10, 1));
    expect(oct.map((i) => i.id), [2, 1]);
  });

  test('오늘 청약 중인 종목', () {
    final items = [
      item(id: 1, start: DateTime(2026, 10, 7), end: DateTime(2026, 10, 8)),
      item(id: 2, start: DateTime(2026, 10, 9), end: DateTime(2026, 10, 10)),
      item(id: 3, start: DateTime(2026, 10, 5), end: DateTime(2026, 10, 6)),
    ];

    final sub = IpoLogic.subscribing(items, today);
    expect(sub.map((i) => i.id), [1]);
  });

  test('배지: D-day, 오늘 마감, 청약 중, 청약 마감', () {
    final before = item(start: DateTime(2026, 10, 11), end: DateTime(2026, 10, 12));
    final open = item(start: DateTime(2026, 10, 7), end: DateTime(2026, 10, 9));
    final lastDay = item(start: DateTime(2026, 10, 7), end: DateTime(2026, 10, 8));
    final closed = item(start: DateTime(2026, 10, 1), end: DateTime(2026, 10, 2));

    expect(IpoLogic.badge(before, today).label, 'D-3');
    expect(IpoLogic.badge(open, today).label, '청약 중');
    expect(IpoLogic.badge(lastDay, today).label, '오늘 마감');
    expect(IpoLogic.badge(closed, today).label, '청약 마감');
  });

  test('긴급 여부: 오늘 또는 내일 청약 기간 포함', () {
    final todayItem = item(start: DateTime(2026, 10, 8), end: DateTime(2026, 10, 9));
    final tomorrowItem = item(start: DateTime(2026, 10, 9), end: DateTime(2026, 10, 10));
    final laterItem = item(start: DateTime(2026, 10, 15), end: DateTime(2026, 10, 16));

    expect(IpoLogic.urgent(todayItem, today), isTrue);
    expect(IpoLogic.urgent(tomorrowItem, today), isTrue);
    expect(IpoLogic.urgent(laterItem, today), isFalse);
  });
}
