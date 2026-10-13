import 'package:ipomoa/core/db/app_database.dart';
import 'package:ipomoa/features/ipo/data/ipo_repository.dart';
import 'package:ipomoa/features/ipo/data/ipo_sync_service.dart';
import 'package:ipomoa/models/ipo_item.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late DriftIpoRepository repo;
  late IpoSyncService syncService;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftIpoRepository(db);
    syncService = IpoSyncService(repository: repo);
  });

  tearDown(() async {
    await db.close();
  });

  test('종목 CRUD 및 청약 기록 CRUD 정상 동작', () async {
    final itemId = await repo.saveItem(
      name: '테스트바이오',
      subscribeStart: DateTime(2026, 10, 15),
      subscribeEnd: DateTime(2026, 10, 16),
      offerPrice: 20000,
      underwriter: '한국투자증권',
    );

    final item = await repo.getItem(itemId);
    expect(item, isNotNull);
    expect(item!.name, '테스트바이오');
    expect(item.offerPrice, 20000);

    // 청약 기록 추가
    final recordId = await repo.saveRecord(
      itemId: itemId,
      accountName: '한투(본인)',
      quantity: 50,
      deposit: 500000,
      allotted: 5,
      soldPrice: 35000,
      fee: 2000,
      soldOn: DateTime(2026, 10, 25),
    );

    final records = await repo.getRecords(itemId);
    expect(records.length, 1);
    expect(records.first.id, recordId);
    expect(records.first.accountName, '한투(본인)');
    expect(records.first.allotted, 5);

    // 종목 삭제 시 하위 기록도 CASCADE 삭제 확인
    await repo.deleteItem(itemId);
    final emptyItems = await repo.getItems();
    final emptyRecords = await repo.getRecords(itemId);
    expect(emptyItems, isEmpty);
    expect(emptyRecords, isEmpty);
  });

  test('크롤링 데이터 동기화 시 신규 추가 및 기존 메모 보존 갱신', () async {
    // 1차 동기화: 신규 추가
    final crawledList = [
      IpoItem(
        name: '에이아이로보틱스',
        schedule: '2026.10.20~10.21',
        confirmedPrice: '30,000',
        expectedPrice: '25,000~30,000',
        competitionRate: '1500:1',
        underwriter: '미래에셋증권',
        refundDate: '2026-10-23',
        listingDate: '2026-10-30',
        memo: '로봇 대장주',
      ),
    ];

    final res1 = await syncService.syncItems(crawledList);
    expect(res1.inserted, 1);
    expect(res1.updated, 0);

    final insertedItem = await repo.getItemByName('에이아이로보틱스');
    expect(insertedItem, isNotNull);
    expect(insertedItem!.offerPrice, 30000);
    expect(insertedItem.memo, '로봇 대장주');

    // 사용자가 앱에서 메모를 수정했다고 가정
    await repo.saveItem(
      id: insertedItem.id,
      name: insertedItem.name,
      subscribeStart: insertedItem.subscribeStart,
      subscribeEnd: insertedItem.subscribeEnd,
      offerPrice: insertedItem.offerPrice,
      memo: '사용자가 직접 입력한 메모! 비례 5천 넣기',
    );

    // 2차 동기화 (경쟁률이 변경되어 재수집됨)
    final updatedList = [
      IpoItem(
        name: '에이아이로보틱스',
        schedule: '2026.10.20~10.21',
        confirmedPrice: '30,000',
        expectedPrice: '25,000~30,000',
        competitionRate: '2100:1',
        underwriter: '미래에셋증권',
        refundDate: '2026-10-23',
        listingDate: '2026-10-30',
        memo: '', // 웹 크롤링에서는 메모가 비어있음
      ),
    ];

    final res2 = await syncService.syncItems(updatedList);
    expect(res2.inserted, 0);
    expect(res2.updated, 1);

    final updatedItem = await repo.getItemByName('에이아이로보틱스');
    expect(updatedItem!.competition, '2100:1');
    // 사용자가 입력한 메모가 그대로 보존되었는지 검증!
    expect(updatedItem.memo, '사용자가 직접 입력한 메모! 비례 5천 넣기');
  });
}
