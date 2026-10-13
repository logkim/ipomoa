import 'package:ipomoa/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('스플래시 화면 기본 렌더링 테스트', (WidgetTester tester) async {
    await tester.pumpWidget(const IpoCrawlerApp(autoPreload: false));
    expect(find.text('공모주 청약 알리미'), findsOneWidget);
    expect(find.text('스마트한 공모주 일정 & 청약 분석'), findsOneWidget);
  });

  testWidgets('공모주 목록 페이지 직접 렌더링 테스트', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: IpoListPage(initialItems: []),
      ),
    );
    expect(find.text('공모주 청약 일정'), findsOneWidget);
  });
}
