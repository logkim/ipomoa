import '../../../core/db/app_database.dart';

/// 수익 요약: 전체 · 올해 · 이번 달 (원), 판 기록 수, 이번 달 수익률(%, 판 기록이 없으면 null)
typedef IpoSummary = ({int all, int year, int month, int sold, int? monthRate});

/// 계좌(또는 증권사)별 수익
typedef IpoAccountProfit = ({String accountName, int profit});

/// 공모주 수익 계산. 순수 로직.
abstract final class IpoMath {
  /// 기록 수익 = (매도가 − 공모가) × 배정 − 수수료. 배정 전이거나 안 팔았으면 null
  static int? profit(IpoRecordData r, int offerPrice) =>
      profitOf(r.allotted, r.soldPrice, r.fee, offerPrice);

  /// 입력 중인 값으로 수익 계산 (기록 시트 미리보기). 배정 · 매도가가 없으면 null
  static int? profitOf(int? allotted, int? soldPrice, int fee, int offerPrice) {
    if (allotted == null || soldPrice == null) return null;
    return (soldPrice - offerPrice) * allotted - fee;
  }

  /// 기록 수익률(%) = 수익 ÷ (공모가 × 배정), 반올림. 안 팔았거나 배정 0이면 null
  static int? rate(IpoRecordData r, int offerPrice) =>
      rateOf(r.allotted, r.soldPrice, r.fee, offerPrice);

  /// 입력 중인 값으로 수익률 계산 (기록 시트 미리보기)
  static int? rateOf(int? allotted, int? soldPrice, int fee, int offerPrice) {
    final p = profitOf(allotted, soldPrice, fee, offerPrice);
    if (p == null || allotted == null || allotted <= 0 || offerPrice <= 0) return null;
    return _rate(p, offerPrice * allotted);
  }

  /// 종목 수익률(%): 판 기록의 수익 합 ÷ 판 기록의 (공모가 × 배정) 합
  static int? totalRate(List<IpoRecordData> records, int offerPrice) {
    var sum = 0, cost = 0;
    for (final r in records) {
      final p = profit(r, offerPrice);
      if (p == null || r.allotted == null || r.allotted! <= 0) continue;
      sum += p;
      cost += offerPrice * r.allotted!;
    }
    return _rate(sum, cost);
  }

  static int? _rate(int profit, int cost) =>
      cost <= 0 ? null : (profit * 100 / cost).round();

  /// 한 종목의 판 기록 합계 (총 실현 손익). 판 기록이 없으면 null
  static int? total(List<IpoRecordData> records, int offerPrice) {
    int? sum;
    for (final r in records) {
      final p = profit(r, offerPrice);
      if (p != null) sum = (sum ?? 0) + p;
    }
    return sum;
  }

  /// 한 종목의 총 배정 수량 (주)
  static int totalAllotted(List<IpoRecordData> records) {
    var sum = 0;
    for (final r in records) {
      if (r.allotted != null) sum += r.allotted!;
    }
    return sum;
  }

  /// 한 종목의 총 청약 수량 (주)
  static int totalApplied(List<IpoRecordData> records) {
    var sum = 0;
    for (final r in records) {
      sum += r.quantity;
    }
    return sum;
  }

  /// 한 종목의 총 증거금 (원)
  static int totalDeposit(List<IpoRecordData> records) {
    var sum = 0;
    for (final r in records) {
      sum += r.deposit;
    }
    return sum;
  }

  /// 월간 요약 (선택된 월 기준)
  static IpoSummary summary(
    List<IpoItemData> items,
    List<IpoRecordData> records,
    DateTime selectedMonth,
  ) {
    final price = {for (final i in items) i.id: i.offerPrice};
    var all = 0, year = 0, month = 0, sold = 0, monthCost = 0;

    for (final r in records) {
      final offer = price[r.itemId];
      if (offer == null) continue;
      final p = profit(r, offer);
      if (p == null) continue;
      sold++;
      all += p;

      final on = r.soldOn;
      if (on == null) continue;

      if (on.year == selectedMonth.year) {
        year += p;
        if (on.month == selectedMonth.month) {
          month += p;
          if (r.allotted != null && r.allotted! > 0) {
            monthCost += offer * r.allotted!;
          }
        }
      }
    }

    return (
      all: all,
      year: year,
      month: month,
      sold: sold,
      monthRate: _rate(month, monthCost),
    );
  }

  /// 계좌별 실현 손익 합계 (손익 큰 순서대로 정렬)
  static List<IpoAccountProfit> byAccount(
    List<IpoItemData> items,
    List<IpoRecordData> records,
  ) {
    final price = {for (final i in items) i.id: i.offerPrice};
    final sums = <String, int>{};

    for (final r in records) {
      final offer = price[r.itemId];
      final p = offer == null ? null : profit(r, offer);
      if (p == null) continue;
      final acc = r.accountName.trim().isEmpty ? '기본계좌' : r.accountName.trim();
      sums[acc] = (sums[acc] ?? 0) + p;
    }

    final result = [
      for (final e in sums.entries) (accountName: e.key, profit: e.value),
    ];
    return result..sort((a, b) => b.profit.compareTo(a.profit));
  }
}
