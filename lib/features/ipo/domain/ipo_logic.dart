import '../../../core/db/app_database.dart';

/// 목록 배지 색: 청약 전(앰버/주황) · 청약 중(테라코타/빨강) · 마감(회색)
enum IpoTone { soon, open, done }

/// 공모주 일정 분기 및 포맷팅 로직 (날짜 단위, 시각은 자정 기준 무시)
abstract final class IpoLogic {
  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  /// [month]의 연·월에 청약을 시작하거나 진행하는 종목 (시작일 빠른 순)
  static List<IpoItemData> inMonth(List<IpoItemData> items, DateTime month) =>
      items
          .where(
            (i) =>
                (i.subscribeStart.year == month.year &&
                    i.subscribeStart.month == month.month) ||
                (i.subscribeEnd.year == month.year &&
                    i.subscribeEnd.month == month.month),
          )
          .toList()
        ..sort(
          (a, b) => a.subscribeStart.compareTo(b.subscribeStart) != 0
              ? a.subscribeStart.compareTo(b.subscribeStart)
              : a.id.compareTo(b.id),
        );

  /// 오늘 청약 중인 종목 (청약 시작일 ~ 마감일 안), 마감 빠른 순
  static List<IpoItemData> subscribing(List<IpoItemData> items, DateTime today) {
    final now = _day(today);
    return items
        .where(
          (i) =>
              !now.isBefore(_day(i.subscribeStart)) &&
              !now.isAfter(_day(i.subscribeEnd)),
        )
        .toList()
      ..sort((a, b) => a.subscribeEnd.compareTo(b.subscribeEnd));
  }

  /// 오늘이 청약 기간인지 (청약일 여부: 시작일 <= 오늘 <= 마감일)
  static bool isSubscriptionOpen(IpoItemData item, DateTime today) {
    final now = _day(today);
    return !now.isBefore(_day(item.subscribeStart)) &&
        !now.isAfter(_day(item.subscribeEnd));
  }

  /// '2026년 10월'
  static String monthLabel(DateTime d) => '${d.year}년 ${d.month}월';

  /// '10월 8일'
  static String day(DateTime d) => '${d.month}월 ${d.day}일';

  /// '2026-10-08'
  static String dateYmd(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// 청약 기간: '10월 8일 ~ 10월 9일', 하루면 날짜 하나
  static String period(IpoItemData item) {
    final start = _day(item.subscribeStart);
    final end = _day(item.subscribeEnd);
    return start == end ? day(start) : '${day(start)} ~ ${day(end)}';
  }

  /// 오늘이나 내일이 청약 기간에 걸리는지 (오늘 청약 중 또는 내일 시작)
  static bool urgent(IpoItemData item, DateTime today) {
    final now = _day(today);
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    return !_day(item.subscribeStart).isAfter(tomorrow) &&
        !_day(item.subscribeEnd).isBefore(now);
  }

  /// 목록 카드 배지: 'D-3' · '청약 중' · '오늘 마감' · '청약 마감'
  static ({String label, IpoTone tone}) badge(IpoItemData item, DateTime today) {
    final now = _day(today);
    final start = _day(item.subscribeStart);
    final end = _day(item.subscribeEnd);
    if (now.isBefore(start)) {
      final diff = start.difference(now).inDays;
      return (label: 'D-$diff', tone: IpoTone.soon);
    }
    if (now == end) return (label: '오늘 마감', tone: IpoTone.open);
    if (now.isBefore(end)) return (label: '청약 중', tone: IpoTone.open);
    return (label: '청약 마감', tone: IpoTone.done);
  }

  /// 상세 단계: '청약 D-n' · '청약 중' · '청약 마감일' · '환불 M월 d일' · '상장 M월 d일' · '완료'
  static String stage(IpoItemData item, DateTime today) {
    final now = _day(today);
    final start = _day(item.subscribeStart);
    final end = _day(item.subscribeEnd);
    if (now.isBefore(start)) return '청약 D-${start.difference(now).inDays}';
    if (now == end) return '오늘 마감';
    if (!now.isAfter(end)) return '청약 중';
    final refund = item.refundOn;
    if (refund != null && !now.isAfter(_day(refund))) {
      return '환불 ${day(refund)}';
    }
    final list = item.listOn;
    if (list != null && !now.isAfter(_day(list))) return '상장 ${day(list)}';
    return '완료';
  }
}
