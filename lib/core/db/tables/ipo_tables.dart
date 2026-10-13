import 'package:drift/drift.dart';

/// 공모주 종목 한 건 (일정). 날짜는 자정 기준, 환불일·상장일은 아직 모르면 비워 둔다.
@DataClassName('IpoItemData')
class IpoItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  DateTimeColumn get subscribeStart => dateTime()();
  DateTimeColumn get subscribeEnd => dateTime()();
  DateTimeColumn get refundOn => dateTime().nullable()();
  DateTimeColumn get listOn => dateTime().nullable()();

  /// 공모가 (원)
  IntColumn get offerPrice => integer()();
  TextColumn get underwriter => text().nullable()();
  TextColumn get memo => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// 청약 경쟁률. 사이트에 적힌 글자 그대로 ('685:1')
  TextColumn get competition => text().nullable()();
}

/// 계좌 하나로 한 종목에 청약한 기록. 배정·매도는 나중에 채운다.
@DataClassName('IpoRecordData')
class IpoRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get itemId =>
      integer().references(IpoItems, #id, onDelete: KeyAction.cascade)();

  /// 계좌명/증권사 (예: '한투(본인)', 'KB(가족)') - 자유 텍스트
  TextColumn get accountName => text().withDefault(const Constant('기본계좌'))();

  /// 청약 수량 (주)
  IntColumn get quantity => integer()();

  /// 증거금 (원)
  IntColumn get deposit => integer()();

  /// 배정 수량 (주). 발표 전이면 null
  IntColumn get allotted => integer().nullable()();

  /// 매도 단가 (원). 아직 안 팔았으면 null
  IntColumn get soldPrice => integer().nullable()();

  /// 수수료 (원)
  IntColumn get fee => integer().withDefault(const Constant(0))();
  DateTimeColumn get soldOn => dateTime().nullable()();
  TextColumn get memo => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
