import '../../../core/db/app_database.dart';

/// 주관사 및 계좌 추천 칩 로직
abstract final class IpoUnderwriters {
  /// 국내 주요 공모주 주관 증권사 프리셋
  static const List<String> defaultUnderwriters = [
    '한국투자증권',
    '미래에셋증권',
    'KB증권',
    'NH투자증권',
    '삼성증권',
    '신한투자증권',
    '키움증권',
    '하나증권',
    '대신증권',
    '유진투자증권',
  ];

  /// 기본 계좌명 예시 프리셋
  static const List<String> defaultAccounts = [
    '본인',
    '배우자',
    '자녀1',
    '자녀2',
    '한투(본인)',
    'KB(본인)',
    '미래(본인)',
  ];

  /// 종목의 주관사 문자열에서 개별 증권사 목록을 분리 추출 (쉼표, 슬래시, 앰퍼샌드 등 분리)
  static List<String> parseItemUnderwriters(String? underwriterText) {
    if (underwriterText == null || underwriterText.trim().isEmpty) return const [];
    final cleaned = underwriterText.replaceAll('주관사:', '').replaceAll('주간사:', '').trim();
    if (cleaned.isEmpty || cleaned == '-') return const [];

    final result = <String>[];
    for (final part in cleaned.split(RegExp(r'[,/&+~·]'))) {
      final name = part.trim();
      if (name.isNotEmpty && !result.contains(name)) {
        result.add(name);
      }
    }
    return result;
  }

  /// 사용자가 사용한 주관사(최근 사용 순) + 기본 프리셋 (중복 제거)
  static List<String> suggestUnderwriters(List<IpoItemData> items) {
    final used = <String>{};
    final recent = List.of(items)..sort((a, b) => b.id.compareTo(a.id));
    for (final item in recent) {
      final list = parseItemUnderwriters(item.underwriter);
      for (final name in list) {
        used.add(name);
      }
    }
    return [...used, ...defaultUnderwriters.where((p) => !used.contains(p))];
  }

  /// 사용자가 입력한 청약 증권사/계좌명(최근 순) + 기본 주요 증권사 프리셋
  static List<String> suggestAccounts(List<IpoRecordData> records) {
    final used = <String>{};
    final recent = List.of(records)..sort((a, b) => b.id.compareTo(a.id));
    for (final r in recent) {
      final name = r.accountName.trim();
      if (name.isNotEmpty && name != '기본계좌') used.add(name);
    }
    return [...used, ...defaultUnderwriters.where((a) => !used.contains(a))];
  }
}
