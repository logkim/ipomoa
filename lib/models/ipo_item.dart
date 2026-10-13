class IpoItem {
  final String name;
  final String schedule; // e.g. 2026.11.24~11.25
  final String confirmedPrice; // 확정공모가 (e.g. 90,500)
  final String expectedPrice; // 희망공모가 (e.g. 70,400~90,500)
  final String competitionRate; // 청약경쟁률
  final String underwriter; // 주간사
  final String? detailUrl;

  // 상세 페이지에서 추가 수집되는 정보
  String refundDate; // 환불일 (YYYY-MM-DD)
  String listingDate; // 상장일 (YYYY-MM-DD)
  String memo;

  IpoItem({
    required this.name,
    required this.schedule,
    required this.confirmedPrice,
    required this.expectedPrice,
    required this.competitionRate,
    required this.underwriter,
    this.detailUrl,
    this.refundDate = '',
    this.listingDate = '',
    this.memo = '',
  });

  /// 청약 시작일 (YYYY-MM-DD 포맷)
  String get startDateFormatted {
    try {
      final parts = schedule.split('~');
      if (parts.isEmpty) return '';
      final startPart = parts[0].trim();
      final tokens = startPart.split('.');
      if (tokens.length >= 3) {
        final year = tokens[0].padLeft(4, '0');
        final month = tokens[1].padLeft(2, '0');
        final day = tokens[2].padLeft(2, '0');
        return '$year-$month-$day';
      }
    } catch (_) {}
    return '';
  }

  /// 청약 마감일 (YYYY-MM-DD 포맷)
  String get endDateFormatted {
    try {
      final parts = schedule.split('~');
      if (parts.length < 2) return '';
      final startTokens = parts[0].trim().split('.');
      final endTokens = parts[1].trim().split('.');

      final year = startTokens.isNotEmpty ? startTokens[0].padLeft(4, '0') : '';
      if (endTokens.length == 3) {
        final y = endTokens[0].padLeft(4, '0');
        final m = endTokens[1].padLeft(2, '0');
        final d = endTokens[2].padLeft(2, '0');
        return '$y-$m-$d';
      } else if (endTokens.length == 2 && year.isNotEmpty) {
        final m = endTokens[0].padLeft(2, '0');
        final d = endTokens[1].padLeft(2, '0');
        return '$year-$m-$d';
      }
    } catch (_) {}
    return '';
  }

  /// 정제된 환불일 (YYYY-MM-DD 포맷)
  String get refundDateFormatted => _formatDate(refundDate);

  /// 정제된 상장일 (YYYY-MM-DD 포맷)
  String get listingDateFormatted => _formatDate(listingDate);

  static String _formatDate(String raw) {
    if (raw.isEmpty) return '';
    // YYYY.MM.DD 또는 YYYY-MM-DD 추출
    final match = RegExp(r'(\d{4})[./-](\d{1,2})[./-](\d{1,2})').firstMatch(raw);
    if (match != null) {
      final y = match.group(1)!.padLeft(4, '0');
      final m = match.group(2)!.padLeft(2, '0');
      final d = match.group(3)!.padLeft(2, '0');
      return '$y-$m-$d';
    }
    return raw;
  }

  /// 공모가 숫자 (쉼표 제거 형태, 확정가 우선, 미확정시 희망공모가 상단)
  String get numericPrice {
    final cleanConfirmed = confirmedPrice.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanConfirmed.isNotEmpty) {
      return cleanConfirmed;
    }
    // 희망공모가에서 상단 금액 추출 (예: 15,000~17,800 -> 17800)
    final prices = expectedPrice.split('~');
    if (prices.length == 2) {
      final maxPrice = prices[1].replaceAll(RegExp(r'[^0-9]'), '');
      if (maxPrice.isNotEmpty) return maxPrice;
    }
    return '';
  }

  /// CSV 단일 행 데이터 반환 (분류, 종목명, 청약 시작, 청약 마감, 환불일, 상장일, 공모가, 주간사, 경쟁률, 메모)
  List<dynamic> toCsvRow() {
    return [
      '공모주',
      name,
      startDateFormatted,
      endDateFormatted,
      refundDateFormatted,
      listingDateFormatted,
      numericPrice,
      underwriter,
      competitionRate == '-' ? '' : competitionRate,
      memo,
    ];
  }

  /// 청약 상태 계산 (예정, 진행중, 마감)
  String get status {
    try {
      final parts = schedule.split('~');
      if (parts.length != 2) return '일정미정';

      final startPart = parts[0].trim();
      final endPart = parts[1].trim();

      final startTokens = startPart.split('.');
      if (startTokens.length < 3) return '일정미정';
      final startYear = int.parse(startTokens[0]);
      final startMonth = int.parse(startTokens[1]);
      final startDay = int.parse(startTokens[2]);
      final startDate = DateTime(startYear, startMonth, startDay);

      final endTokens = endPart.split('.');
      int endYear = startYear;
      int endMonth = startMonth;
      int endDay = 1;

      if (endTokens.length == 3) {
        endYear = int.parse(endTokens[0]);
        endMonth = int.parse(endTokens[1]);
        endDay = int.parse(endTokens[2]);
      } else if (endTokens.length == 2) {
        endMonth = int.parse(endTokens[0]);
        endDay = int.parse(endTokens[1]);
      } else {
        return '일정미정';
      }

      final endDate = DateTime(endYear, endMonth, endDay, 23, 59, 59);
      final now = DateTime.now();

      if (now.isBefore(startDate)) {
        final diff = startDate.difference(DateTime(now.year, now.month, now.day)).inDays;
        return diff == 0 ? '오늘 시작' : 'D-$diff';
      } else if (now.isAfter(endDate)) {
        return '청약마감';
      } else {
        return '청약진행중';
      }
    } catch (_) {
      return '일정미정';
    }
  }

  bool get isActive => status == '청약진행중' || status == '오늘 시작';

  /// 당월(이번 달) 청약 건인지 여부 (청약 시작일 또는 마감일이 이번 달에 속하는지)
  bool get isCurrentMonth {
    final now = DateTime.now();
    try {
      if (startDateFormatted.isNotEmpty) {
        final startTokens = startDateFormatted.split('-');
        if (int.parse(startTokens[0]) == now.year && int.parse(startTokens[1]) == now.month) {
          return true;
        }
      }
      if (endDateFormatted.isNotEmpty) {
        final endTokens = endDateFormatted.split('-');
        if (int.parse(endTokens[0]) == now.year && int.parse(endTokens[1]) == now.month) {
          return true;
        }
      }
    } catch (_) {}
    return false;
  }

  /// 차월(다음 달) 청약 건인지 여부 (청약 시작일 또는 마감일이 다음 달에 속하는지)
  bool get isNextMonth {
    final now = DateTime.now();
    final nextMonthDate = DateTime(now.year, now.month + 1, 1);
    final targetYear = nextMonthDate.year;
    final targetMonth = nextMonthDate.month;

    try {
      if (startDateFormatted.isNotEmpty) {
        final startTokens = startDateFormatted.split('-');
        if (int.parse(startTokens[0]) == targetYear && int.parse(startTokens[1]) == targetMonth) {
          return true;
        }
      }
      if (endDateFormatted.isNotEmpty) {
        final endTokens = endDateFormatted.split('-');
        if (int.parse(endTokens[0]) == targetYear && int.parse(endTokens[1]) == targetMonth) {
          return true;
        }
      }
    } catch (_) {}
    return false;
  }
  Map<String, dynamic> toJson() => {
        'name': name,
        'schedule': schedule,
        'confirmedPrice': confirmedPrice,
        'expectedPrice': expectedPrice,
        'competitionRate': competitionRate,
        'underwriter': underwriter,
        'detailUrl': detailUrl,
        'refundDate': refundDate,
        'listingDate': listingDate,
        'memo': memo,
      };

  factory IpoItem.fromJson(Map<String, dynamic> json) => IpoItem(
        name: json['name'] as String? ?? '',
        schedule: json['schedule'] as String? ?? '',
        confirmedPrice: json['confirmedPrice'] as String? ?? '',
        expectedPrice: json['expectedPrice'] as String? ?? '',
        competitionRate: json['competitionRate'] as String? ?? '',
        underwriter: json['underwriter'] as String? ?? '',
        detailUrl: json['detailUrl'] as String?,
        refundDate: json['refundDate'] as String? ?? '',
        listingDate: json['listingDate'] as String? ?? '',
        memo: json['memo'] as String? ?? '',
      );
}