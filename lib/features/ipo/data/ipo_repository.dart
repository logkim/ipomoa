import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';

/// 공모주 저장소 인터페이스
abstract interface class IpoRepository {
  /// 모든 종목 (청약 시작일 순)
  Stream<List<IpoItemData>> watchItems();
  Future<List<IpoItemData>> getItems();
  Future<IpoItemData?> getItem(int id);
  Future<IpoItemData?> getItemByName(String name);

  /// 종목 추가 또는 수정
  Future<int> saveItem({
    int? id,
    required String name,
    required DateTime subscribeStart,
    required DateTime subscribeEnd,
    DateTime? refundOn,
    DateTime? listOn,
    required int offerPrice,
    String? underwriter,
    String? memo,
    String? competition,
  });

  /// 종목 삭제 (하위 청약 기록 CASCADE 삭제)
  Future<void> deleteItem(int id);

  /// 특정 종목의 청약 기록
  Stream<List<IpoRecordData>> watchRecords(int itemId);
  Future<List<IpoRecordData>> getRecords(int itemId);

  /// 모든 청약 기록
  Stream<List<IpoRecordData>> watchAllRecords();
  Future<List<IpoRecordData>> getAllRecords();

  /// 청약 기록 추가 또는 수정
  Future<int> saveRecord({
    int? id,
    required int itemId,
    required String accountName,
    required int quantity,
    required int deposit,
    int? allotted,
    int? soldPrice,
    int fee = 0,
    DateTime? soldOn,
    String? memo,
  });

  /// 청약 기록 삭제
  Future<void> deleteRecord(int id);
}

class DriftIpoRepository implements IpoRepository {
  DriftIpoRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<List<IpoItemData>> watchItems() =>
      (_db.select(_db.ipoItems)..orderBy([
            (i) => OrderingTerm.asc(i.subscribeStart),
            (i) => OrderingTerm.asc(i.id),
          ]))
          .watch();

  @override
  Future<List<IpoItemData>> getItems() =>
      (_db.select(_db.ipoItems)..orderBy([
            (i) => OrderingTerm.asc(i.subscribeStart),
            (i) => OrderingTerm.asc(i.id),
          ]))
          .get();

  @override
  Future<IpoItemData?> getItem(int id) =>
      (_db.select(_db.ipoItems)..where((i) => i.id.equals(id))).getSingleOrNull();

  @override
  Future<IpoItemData?> getItemByName(String name) =>
      (_db.select(_db.ipoItems)..where((i) => i.name.equals(name.trim()))).getSingleOrNull();

  @override
  Future<int> saveItem({
    int? id,
    required String name,
    required DateTime subscribeStart,
    required DateTime subscribeEnd,
    DateTime? refundOn,
    DateTime? listOn,
    required int offerPrice,
    String? underwriter,
    String? memo,
    String? competition,
  }) async {
    final cleanName = name.trim();
    final row = IpoItemsCompanion(
      name: Value(cleanName),
      subscribeStart: Value(subscribeStart),
      subscribeEnd: Value(subscribeEnd),
      refundOn: Value(refundOn),
      listOn: Value(listOn),
      offerPrice: Value(offerPrice),
      underwriter: Value(underwriter),
      memo: Value(memo),
      competition: Value(competition),
    );

    if (id == null) {
      // 혹시 동일 이름의 종목이 이미 있으면 업데이트
      final existing = await getItemByName(cleanName);
      if (existing != null) {
        await (_db.update(_db.ipoItems)..where((i) => i.id.equals(existing.id))).write(row);
        return existing.id;
      }
      return _db.into(_db.ipoItems).insert(row);
    }

    await (_db.update(_db.ipoItems)..where((i) => i.id.equals(id))).write(row);
    return id;
  }

  @override
  Future<void> deleteItem(int id) async {
    await (_db.delete(_db.ipoRecords)..where((r) => r.itemId.equals(id))).go();
    await (_db.delete(_db.ipoItems)..where((i) => i.id.equals(id))).go();
  }

  @override
  Stream<List<IpoRecordData>> watchRecords(int itemId) =>
      (_db.select(_db.ipoRecords)
            ..where((r) => r.itemId.equals(itemId))
            ..orderBy([(r) => OrderingTerm.asc(r.id)]))
          .watch();

  @override
  Future<List<IpoRecordData>> getRecords(int itemId) =>
      (_db.select(_db.ipoRecords)
            ..where((r) => r.itemId.equals(itemId))
            ..orderBy([(r) => OrderingTerm.asc(r.id)]))
          .get();

  @override
  Stream<List<IpoRecordData>> watchAllRecords() =>
      (_db.select(_db.ipoRecords)..orderBy([(r) => OrderingTerm.asc(r.id)])).watch();

  @override
  Future<List<IpoRecordData>> getAllRecords() =>
      (_db.select(_db.ipoRecords)..orderBy([(r) => OrderingTerm.asc(r.id)])).get();

  @override
  Future<int> saveRecord({
    int? id,
    required int itemId,
    required String accountName,
    required int quantity,
    required int deposit,
    int? allotted,
    int? soldPrice,
    int fee = 0,
    DateTime? soldOn,
    String? memo,
  }) async {
    final row = IpoRecordsCompanion(
      itemId: Value(itemId),
      accountName: Value(accountName.trim().isEmpty ? '기본계좌' : accountName.trim()),
      quantity: Value(quantity),
      deposit: Value(deposit),
      allotted: Value(allotted),
      soldPrice: Value(soldPrice),
      fee: Value(fee),
      soldOn: Value(soldOn),
      memo: Value(memo),
    );

    if (id == null) {
      return _db.into(_db.ipoRecords).insert(row);
    }

    await (_db.update(_db.ipoRecords)..where((r) => r.id.equals(id))).write(row);
    return id;
  }

  @override
  Future<void> deleteRecord(int id) =>
      (_db.delete(_db.ipoRecords)..where((r) => r.id.equals(id))).go();
}
