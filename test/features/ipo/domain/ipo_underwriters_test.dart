import 'package:ipomoa/features/ipo/domain/ipo_underwriters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IpoUnderwriters 단위 테스트', () {
    test('주관사가 2개 이상일 때 쉼표나 슬래시로 정확히 분리된다', () {
      final list1 = IpoUnderwriters.parseItemUnderwriters('미래에셋증권,삼성증권');
      expect(list1, ['미래에셋증권', '삼성증권']);

      final list2 = IpoUnderwriters.parseItemUnderwriters('대신증권/유진투자증권');
      expect(list2, ['대신증권', '유진투자증권']);

      final list3 = IpoUnderwriters.parseItemUnderwriters('한국투자증권, KB증권, 신한투자증권');
      expect(list3, ['한국투자증권', 'KB증권', '신한투자증권']);
    });

    test('주관사가 1개이거나 없거나 특수기호가 있을 때 안전하게 처리된다', () {
      expect(IpoUnderwriters.parseItemUnderwriters('한국투자증권'), ['한국투자증권']);
      expect(IpoUnderwriters.parseItemUnderwriters(null), isEmpty);
      expect(IpoUnderwriters.parseItemUnderwriters(''), isEmpty);
      expect(IpoUnderwriters.parseItemUnderwriters('-'), isEmpty);
      expect(IpoUnderwriters.parseItemUnderwriters('주관사: 미래에셋증권'), ['미래에셋증권']);
    });
  });
}
