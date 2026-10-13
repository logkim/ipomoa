/// 숫자 및 금액 포맷팅 유틸리티
abstract final class CalcFormat {
  static const int _group = 3;

  static String _commas(String digits) {
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % _group == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  /// 천 단위 쉼표가 들어간 정수 문자열 ('1,234,567')
  static String number(int v) {
    final s = v.toString();
    final negative = s.startsWith('-');
    final body = negative ? s.substring(1) : s;
    return '${negative ? '-' : ''}${_commas(body)}';
  }

  /// 금액 포맷 ('1,234,567원')
  static String won(int v) => '${number(v)}원';

  /// 부호가 붙은 금액 ('+5,000원' · '−4,000원' · '0원')
  static String signedWon(int v) {
    final n = number(v.abs());
    return v > 0 ? '+$n원' : (v < 0 ? '−$n원' : '$n원');
  }

  /// 부호가 붙은 퍼센트 ('+198%' · '−12%' · '0%')
  static String signedPercent(int v) =>
      v > 0 ? '+$v%' : (v < 0 ? '−${v.abs()}%' : '0%');

  /// 최소 청약 단위(기본 10주, 증거금 50%) 금액 라벨
  /// 예: 7,800원 -> '10주/3.9만원', 18,500원 -> '10주/9.25만원', 10,000원 -> '10주/5만원'
  static String minDepositLabel(int offerPrice, {int minShares = 10}) {
    if (offerPrice <= 0) return '-';
    final deposit = (offerPrice * minShares * 0.5).round();
    if (deposit >= 10000) {
      final man = deposit / 10000.0;
      final formatted = man.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
      return '$minShares주/$formatted만원';
    } else {
      return '$minShares주/${won(deposit)}';
    }
  }

  /// 최소 청약 증거금액만 반환 (예: '3.9만원', '9.25만원')
  static String minDepositAmount(int offerPrice, {int minShares = 10}) {
    if (offerPrice <= 0) return '-';
    final deposit = (offerPrice * minShares * 0.5).round();
    if (deposit >= 10000) {
      final man = deposit / 10000.0;
      final formatted = man.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
      return '$formatted만원';
    } else {
      return won(deposit);
    }
  }

  /// 입력 칸 글자 → 숫자 (쉼표 무시). 비었거나 숫자가 아니면 null
  static int? parseInt(String? text) {
    if (text == null) return null;
    final clean = text.replaceAll(',', '').replaceAll('원', '').replaceAll('주', '').trim();
    return int.tryParse(clean);
  }
}